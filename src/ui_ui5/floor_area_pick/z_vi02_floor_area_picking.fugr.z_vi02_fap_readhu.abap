FUNCTION z_vi02_fap_readhu.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HUKEYS) TYPE  ZZS_VI02_SCANHU_KEYS
*"  EXPORTING
*"     VALUE(ES_HUHEADER) TYPE  ZZS_VI02_FAP_HUHEADER
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    ls_return     TYPE bapiret2,
    lv_tabix      TYPE sy-tabix,
    lv_huident    TYPE /scwm/de_huident,
    lt_hu         TYPE /scwm/if_api_whse_task=>yt_wht_hu,
    lt_who        TYPE /scwm/if_api_whse_order=>yt_who,
    lt_conf       TYPE /scwm/if_api_whse_task=>yt_wht_conf_hu,
    ls_huheader_r TYPE zzs_vi02_fap_huheader_detail.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  lv_huident = |{ is_hukeys-huident  ALPHA = IN }|.

  ""--> Workstation
  TRY.
      go_floor_area_picking->lif_isolated_doc_workstation~workstation_read_single(
        EXPORTING
          iv_lgnum       = is_hukeys-lgnum
          iv_workstation = is_hukeys-workstation
        IMPORTING
          es_workst      = DATA(ls_workst)
          es_workstt     = DATA(ls_workstt)
      ).
    CATCH /scwm/cx_batch_management.
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
      RETURN.
  ENDTRY.

  TRY.
      go_floor_area_picking->lif_isolated_doc_workstation~workcenter_bins_read(
        EXPORTING
          is_workstation = ls_workst
        IMPORTING
          et_lgpla       = DATA(lt_lgpla)
          et_lagp        = DATA(lt_lagp) ).

    CATCH /scwm/cx_cust_returns_error.
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
      RETURN.
  ENDTRY.

  IF lt_lgpla IS INITIAL.
    MESSAGE e021(/scwm/returns) INTO DATA(lv_message).
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  TRY.
      go_floor_area_picking->lif_isolated_doc_hu~hu_select_gen(
          EXPORTING
            iv_lgnum    = is_hukeys-lgnum
            ir_huident  = VALUE #( ( sign   = wmegc_sign_inclusive
                                     option = wmegc_option_eq
                                     low    = lv_huident )  )
          IMPORTING
            et_guid_hu = DATA(lt_guid_hu)
            et_huhdr   = DATA(lt_huhdr)
            et_huitm   = DATA(lt_huitm)
            et_hutree  = DATA(lt_hutree)
            et_huref   = DATA(lt_huref)
            et_high    = DATA(lt_high)
            et_ident   = DATA(lt_ident) ).
    CATCH /scwm/cx_core_t100.
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
      RETURN.
  ENDTRY.

  IF lt_huitm IS INITIAL.
    MESSAGE e146(/scwm/hugeneral) INTO lv_message.
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.
  DATA(ls_huheader) = lt_huhdr[ 1 ].

  ""--> Check Workstation
* check if HU is located at work center
  READ TABLE lt_lagp WITH KEY lgpla = ls_huheader-lgpla ASSIGNING FIELD-SYMBOL(<fs_lgpla_read>).
  IF sy-subrc <> 0.
    MESSAGE e063(/scwm/ui_packing) INTO lv_message.
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  LOOP AT lt_lagp ASSIGNING FIELD-SYMBOL(<fs_lagp>) WHERE lgber = ls_huheader-lgber
                                                      AND lgber EQ ls_workst-i_section.
    EXIT.
  ENDLOOP.
  IF sy-subrc <> 0.
    LOOP AT lt_lagp ASSIGNING <fs_lagp> WHERE lgpla = ls_huheader-lgpla.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e021(/scwm/returns) INTO lv_message.
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
      RETURN.
    ENDIF.
  ENDIF.

  ""-->>Warehouse Tasks
  lt_hu    = VALUE #( BASE lt_hu
                      FOR ls_hu_hdr IN lt_huhdr
                      ( huident = ls_hu_hdr-huident  vhi = ls_hu_hdr-vhi ) ).

* "read
  DATA(ls_read) = VALUE /scwm/if_api_whse_task=>ys_read( ordim_o   = abap_true ordim_os  = abap_true
                                                         ordim_c   = abap_true ordim_cs  = abap_true
                                                         ordim_e   = abap_true ).

  TRY.
      go_floor_area_picking->mo_whse_task->/scwm/if_api_whse_task~read_by_hu(
        EXPORTING
          iv_whno     = is_hukeys-lgnum
          it_hu       = lt_hu
          is_read     = ls_read
        IMPORTING
          eo_message  = DATA(lo_message_whse_task)
          et_wht_data = DATA(lt_wht_data) ).
    CATCH /scwm/cx_api_whse_task INTO DATA(lx_api_whse_task).
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
  ENDTRY.

  LOOP AT lt_wht_data INTO DATA(ls_whse_task).
    "If the HU’s HU-WT was not confirmed yet
    "(by RF screen that can move the pallet from conveyor outfeed element to the workstation by HU or system-selection)
    "the HU-WT shall be confirmed by this screen here and now.
    LOOP AT ls_whse_task-t_ordim_o INTO DATA(ls_ordim_o) WHERE flghuto = abap_true.
      lt_conf = VALUE #( BASE lt_conf (  tanum = ls_whse_task-tanum ) ) .
    ENDLOOP.

    "selection of first pickWT that belongs to our workstation
    IF lt_who IS INITIAL.
      LOOP AT lt_lagp ASSIGNING <fs_lagp> .
        READ TABLE  ls_whse_task-t_ordim_o INTO ls_ordim_o WITH KEY nlpla   = <fs_lagp>-lgpla
                                                                    flghuto = abap_false
                                                                    trart   = wmegc_trart_pick.
        IF sy-subrc EQ 0.
          es_huheader-nlenr   = ls_ordim_o-nlenr.
          es_huheader-tanum   = ls_ordim_o-tanum.
          es_huheader-rdoccat = ls_ordim_o-rdoccat.
          es_huheader-rdocid  = ls_ordim_o-rdocid.
          es_huheader-ritmid  = ls_ordim_o-ritmid.
          APPEND VALUE #( who = ls_ordim_o-who ) TO lt_who.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  IF lt_who IS INITIAL.
    MESSAGE e000(/scwm/returns) WITH TEXT-001 INTO lv_message.
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  ""--> Confirm HU-WT
  go_floor_area_picking->confirm_hu_wt(
    EXPORTING
      iv_lgnum   = is_hukeys-lgnum
      it_conf    = lt_conf
    CHANGING
      ct_bapiret = et_return[] ).

  "-->Warehouse Order
  IF lt_who IS NOT INITIAL.
    DATA(ls_include) =  VALUE /scwm/if_api_whse_order=>ys_include( open_wt     = abap_true
                                                                   open_wt_ser = abap_true
                                                                   conf_wt     = abap_true
                                                                   conf_wt_ser = abap_true ).
    TRY.
        go_floor_area_picking->mo_whse_order->/scwm/if_api_whse_order~read(
          EXPORTING
            iv_whno    = is_hukeys-lgnum
            it_who     = lt_who
            is_include = ls_include "Default All
          IMPORTING
            eo_message = DATA(lo_message_whse_order)
            et_who     = DATA(lt_warehouse_orders) ).

      CATCH /scwm/cx_api_whse_order INTO DATA(lx_api_whse_order).
        go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    ENDTRY.

    go_floor_area_picking->append_api_message(
       EXPORTING
         io_api_message = lo_message_whse_order
       CHANGING
         ct_bapiret   = et_return[] ).


    DATA(lt_who_totals) =  go_floor_area_picking->calculate_whse_order_totals(
                             EXPORTING
                               iv_lgnum      = is_hukeys-lgnum
                               it_who        = lt_who ).

    DATA(ls_warehouse_order) = VALUE #( lt_warehouse_orders[ 1 ] OPTIONAL ).
    DATA(ls_who_totals)       = VALUE #( lt_who_totals[ 1 ] OPTIONAL ).

    es_huheader-who          = ls_warehouse_order-who.
    es_huheader-sum_weight   = ls_who_totals-sum_weight.
    es_huheader-unit_w       = ls_who_totals-unit_w    .
    es_huheader-sum_volum    = ls_who_totals-sum_volum .
    es_huheader-unit_v       = ls_who_totals-unit_v    .
    "•  Case 1: PickHU already exists:
*    DATA(ls_pickhus) = go_floor_area_picking->get_pickhu(  EXPORTING  iv_ewmwarehouse   = is_hukeys-lgnum
*                                                                      iv_warehouseorder = ls_warehouse_order-who  ).
    go_floor_area_picking->lif_isolated_doc_pickhu~get_pick_hus_by_wo(
        EXPORTING
          iv_warehouseorder = ls_warehouse_order-who
          iv_ewmwarehouse   = is_hukeys-lgnum
        IMPORTING
          et_pickhu         = DATA(lt_pickhu) ) .

    SORT lt_pickhu BY hukng DESCENDING.

    READ TABLE lt_pickhu INDEX 1 INTO DATA(ls_pickhus).

    es_huheader-pickhu_pmat           = ls_pickhus-pmat          .
    es_huheader-pickhu_pmat_guid      = ls_pickhus-pmat_guid     .
    es_huheader-pickhu_huident        = ls_pickhus-huident       .
    es_huheader-pickhu_hukng          = ls_pickhus-hukng         .
    es_huheader-pickhu_lgpla          = ls_pickhus-lgpla         .
    es_huheader-pickhu_rsrc           = ls_pickhus-rsrc           .
    es_huheader-pickhu_pmtyp          = ls_pickhus-pmtyp         .
    es_huheader-pickhu_pmtyp_text     = ls_pickhus-pmtyp_text    .
    es_huheader-pickhu_hutyp          = ls_pickhus-hutyp         .
    es_huheader-pickhu_hutyp_text     = ls_pickhus-hutyp_text    .
    es_huheader-pickhu_tanum          = ls_pickhus-tanum         .
    es_huheader-pickhu_tapos          = ls_pickhus-tapos         .
    es_huheader-pickhu_pmtext         = ls_pickhus-pmtext        .
    es_huheader-pickhu_is_recommended = ls_pickhus-is_recommended.

  ENDIF.

  "read topHUs
  LOOP AT lt_high INTO DATA(ls_high).
    DATA(ls_pmat) = go_floor_area_picking->lif_isolated_doc_material~mat_details_read_from_matid( ls_high-pmat_guid ).
    CLEAR: ls_pmat.
    es_huheader-lgnum             = is_hukeys-lgnum.
    es_huheader-workstation       = is_hukeys-workstation.
    es_huheader-huident           = |{ ls_high-huident  ALPHA = OUT }|.
    es_huheader-letyp             = ls_high-letyp.
    es_huheader-pmtyp             = ls_high-pmtyp.
    es_huheader-packgr            = ls_high-packgr.
    es_huheader-pmat_guid         = ls_high-pmat_guid.
    es_huheader-pmat              = ls_pmat-matnr.
    es_huheader-pmtext            = VALUE #( ls_pmat-txt[ langu = sy-langu ]-maktx OPTIONAL ).
  ENDLOOP.

  "read subHUs
  LOOP AT lt_huhdr INTO DATA(ls_huhdr) WHERE top    = abap_false
                                         AND bottom = abap_true.

    IF es_huheader-subhu1 IS INITIAL.
      es_huheader-subhu1 = |{ ls_huhdr-huident  ALPHA = OUT }|.
    ELSEIF es_huheader-subhu2 IS INITIAL.
      es_huheader-subhu2 = |{ ls_huhdr-huident  ALPHA = OUT }|.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.

*  LOOP AT lt_huitm INTO DATA(ls_item).
  READ TABLE lt_huitm INTO DATA(ls_item) INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ls_pmat = go_floor_area_picking->lif_isolated_doc_material~mat_details_read_from_matid( ls_item-matid ).

*    ls_pmat-MEX-HNDLCODE

  IF ls_pmat-mex-hndlcode IS NOT INITIAL.
    CALL METHOD /scmb/cl_mdl_wh_reader=>thndlcd_read
      EXPORTING
        iv_hndlcode = ls_pmat-mex-hndlcode
        iv_langu    = sy-langu
      IMPORTING
        es_hndlcdt  = DATA(ls_thndlcdt).
  ENDIF.

  TRY.
      DATA(ls_batch) = go_floor_area_picking->lif_isolated_doc_material~batch_detail_read(
        iv_productid = ls_item-matid
        iv_batchid   = ls_item-batchid
        iv_lgnum     = is_hukeys-lgnum
        iv_entitled  = ls_item-entitled
      ).
    CATCH /scwm/cx_batch_management.
      " Ignore, no need to take over the process type
  ENDTRY.

*    DATA(lv_batchno) = NEW /scwm/cl_ui_stock_fields( )->get_batchno_by_id( ls_item-batchid ).
  es_huheader-matid             = ls_item-matid.
  es_huheader-matnr             = |{ ls_pmat-matnr  ALPHA = OUT }|.
  es_huheader-maktx             = VALUE #( ls_pmat-txt[ langu = sy-langu ]-maktx OPTIONAL ).
  es_huheader-owner             = ls_item-owner.
  es_huheader-entitled          = ls_item-entitled.
  es_huheader-hndlcode          = ls_pmat-mex-hndlcode.
  es_huheader-hndlcode_text     = ls_thndlcdt-text.
  es_huheader-charg             = ls_batch-charg.
  es_huheader-cat               = ls_item-cat.
  IF ls_item-cat IS NOT INITIAL.
    DATA(lv_cat_text) = go_floor_area_picking->cat_text_read(
                         EXPORTING
                           iv_lgnum          = is_hukeys-lgnum
                           iv_cat            = es_huheader-cat ).
  ENDIF.

  es_huheader-quan_after        = ls_item-quan.
  es_huheader-quan              = ls_item-quan.
  es_huheader-meins             = ls_item-meins.
  es_huheader-quana             = ls_item-quana.
  es_huheader-altme             = ls_item-altme.


ENDFUNCTION.
