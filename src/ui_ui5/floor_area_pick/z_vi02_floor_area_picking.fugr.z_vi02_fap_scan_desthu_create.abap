FUNCTION z_vi02_fap_scan_desthu_create.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_PICKHUDATA) TYPE  ZZS_VI02_FAP_PICK_HU
*"  EXPORTING
*"     VALUE(ES_PICKHU_KEYS) TYPE  ZZS_VI02_FAP_READ_PICK_HU
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------

  DATA:
    ls_return  TYPE bapiret2,
    lv_tabix   TYPE sy-tabix,
    lv_huident TYPE /scwm/de_huident.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  IF is_pickhudata-huident IS INITIAL.
    MESSAGE e036(z_vi02_general) INTO DATA(lv_message).
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  IF is_pickhudata-who IS INITIAL OR is_pickhudata-lgnum IS INITIAL.
    MESSAGE e033(z_vi02_general) WITH TEXT-003 INTO lv_message.
    RETURN.
  ENDIF.

  go_floor_area_picking->lif_isolated_doc_pickhu~get_pick_hus_by_wo(
    EXPORTING
      iv_warehouseorder = is_pickhudata-who
      iv_ewmwarehouse   = is_pickhudata-lgnum
    IMPORTING
      et_pickhu         = DATA(lt_pickhu) ) .
  SORT lt_pickhu BY huident hukng DESCENDING.

  IF is_pickhudata-huident IS NOT INITIAL.
    lv_huident = |{ is_pickhudata-huident  ALPHA = IN }|.
    TRY.
        go_floor_area_picking->lif_isolated_doc_hu~hu_select_gen(
            EXPORTING
              iv_lgnum    = is_pickhudata-lgnum
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
    ENDTRY.
  ENDIF.

  IF lt_huhdr IS NOT INITIAL. "an already existing HU in EWM, then we use that pickHU for our warehouse order.

    DATA(ls_huhdr) = VALUE #( lt_huhdr[ 1 ] OPTIONAL ).

    READ TABLE lt_pickhu INTO DATA(ls_pickhus) WITH KEY  huident = ls_huhdr-huident.
    IF sy-subrc EQ 0.
      es_pickhu_keys = CORRESPONDING #( ls_pickhus ).
      RETURN.
    ENDIF.

    TRY.
        go_floor_area_picking->mo_handling_unit->/scwm/if_api_handling_unit~delete(
           EXPORTING
             iv_whno     = is_pickhudata-lgnum
             it_huident  = VALUE #( ( huident = ls_huhdr-huident ) )
           IMPORTING
              eo_message  = DATA(lo_message) ).
      CATCH /scwm/cx_api_faulty_call INTO DATA(lx_api_hu).
        RETURN.
    ENDTRY.

    DATA(lv_error) = lo_message->check( iv_msgty = /scwm/if_api_message=>sc_msgty_error ).
    IF lv_error IS NOT INITIAL.
      RETURN.
    ENDIF.

    go_floor_area_picking->mo_handling_unit->/scwm/if_api_handling_unit~save(
      IMPORTING
        eo_message = lo_message ).

    go_floor_area_picking->mo_handling_unit->/scwm/if_tm_appl~cleanup( iv_reason = '' ).
    COMMIT WORK AND WAIT.

    DATA(ls_pickhu) = go_floor_area_picking->lif_isolated_doc_pickhu~create_pick_hu(
      EXPORTING
        iv_ewmwarehouse      = is_pickhudata-lgnum
        iv_warehouseorder    = is_pickhudata-who
        iv_packagingmaterial = is_pickhudata-pmat
        iv_huid              = ls_huhdr-huident
        iv_hunumberinwo      = 001 ).
  ENDIF.

  es_pickhu_keys = CORRESPONDING #( ls_pickhu ).
ENDFUNCTION.
