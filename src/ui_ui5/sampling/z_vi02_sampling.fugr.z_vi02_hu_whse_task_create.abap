FUNCTION z_vi02_hu_whse_task_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HU_WHSE_TASK) TYPE  ZZS_VI02_HU_WT
*"  EXPORTING
*"     VALUE(ES_KEYS) TYPE  ZZS_VI02_HU_WT_KEYS
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    ls_return         TYPE bapiret2,
    lv_sampling_hu    TYPE /scwm/de_huident,
    lv_destination_hu TYPE /scwm/de_huident,
    lt_create         TYPE /scwm/if_api_whse_task=>yt_wht_create_adhoc_hu,
    ls_create         TYPE /scwm/if_api_whse_task=>ys_wht_create_adhoc_hu,
    lv_material       TYPE char18,
    lt_huident        TYPE /scwm/if_api_handling_unit=>yt_huident.

  go_sampling = lcl_sampling_doc=>get_instance( ).

  IF is_hu_whse_task-lgnum IS INITIAL.
    MESSAGE e009(/scwm/l1) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  IF ( is_hu_whse_task-huident IS INITIAL AND is_hu_whse_task-guid_hu IS INITIAL ) OR
     ( is_hu_whse_task-nlenr IS INITIAL AND is_hu_whse_task-dguid_hu IS INITIAL ).
    MESSAGE e157(/scwm/hugeneral) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  IF is_hu_whse_task-huident IS NOT INITIAL.
    IF is_hu_whse_task-huident = is_hu_whse_task-nlenr.
      MESSAGE e079(/scwm/hugeneral) INTO lv_message.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    ENDIF.
  ENDIF.

  IF is_hu_whse_task-guid_hu IS NOT INITIAL.
    IF is_hu_whse_task-guid_hu = is_hu_whse_task-dguid_hu.
      MESSAGE e079(/scwm/hugeneral) INTO lv_message.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    ENDIF.
  ENDIF.


  IF is_hu_whse_task-entitled IS INITIAL.
    MESSAGE e045(z_vi02_general) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  IF is_hu_whse_task-matnr IS INITIAL.
    MESSAGE e044(z_vi02_general) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.


  lv_sampling_hu      = |{ is_hu_whse_task-huident ALPHA = IN }|.
  lv_destination_hu = |{ is_hu_whse_task-nlenr ALPHA = IN }|.

  IF lv_sampling_hu IS NOT INITIAL.
    go_sampling->hu_read(
      EXPORTING
        iv_lgnum   = is_hu_whse_task-lgnum
        iv_huident = lv_sampling_hu
      IMPORTING
        ev_error   = DATA(lv_error)
        es_huhdr   = DATA(ls_sampling_huheader) ).
    IF lv_error IS NOT INITIAL.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    ENDIF.
  ELSE.
    go_sampling->hu_read(
      EXPORTING
        iv_lgnum   = is_hu_whse_task-lgnum
        iv_guid_hu = is_hu_whse_task-guid_hu
      IMPORTING
        ev_error   = lv_error
        es_huhdr   = ls_sampling_huheader ).
    IF lv_error IS NOT INITIAL.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    ENDIF.
  ENDIF.

  IF ls_sampling_huheader-zzvi02_src_huid IS NOT INITIAL.
    go_sampling->hu_read(
      EXPORTING
        iv_lgnum   = is_hu_whse_task-lgnum
        iv_huident = |{ ls_sampling_huheader-zzvi02_src_huid ALPHA = IN }|
      IMPORTING
        ev_error   = lv_error
        es_huhdr   = DATA(ls_sourcehu_header)
        et_huitm   = DATA(lt_sourcehu_item) ).
  ENDIF.


****  IF lv_destination_hu IS NOT INITIAL.
****    go_sampling->hu_read(
****    EXPORTING
****      iv_lgnum   = is_hu_whse_task-lgnum
****      iv_huident = lv_destination_hu
****    IMPORTING
****      ev_error   = lv_error
****      es_huhdr   = DATA(ls_destination_huheader) ).
****    IF lv_error IS NOT INITIAL.
****      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
****      ls_return-row = VALUE #( ).
****      APPEND ls_return TO et_return.
****      RETURN.
****    ENDIF.
****  ELSE.
****    go_sampling->hu_read(
****    EXPORTING
****      iv_lgnum   = is_hu_whse_task-lgnum
****      iv_guid_hu = is_hu_whse_task-dguid_hu
****    IMPORTING
****      ev_error   = lv_error
****      es_huhdr   = ls_destination_huheader ).
****    IF lv_error IS NOT INITIAL.
****      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
****      ls_return-row = VALUE #( ).
****      APPEND ls_return TO et_return.
****      RETURN.
****    ENDIF.
****  ENDIF.

  go_sampling->check_parameter_framework(
    EXPORTING
      iv_lgnum          = is_hu_whse_task-lgnum
    IMPORTING
      ev_paci            = DATA(lv_paci)
      ev_ambient_buffer  = DATA(lv_ambient_buffer)
      ev_buffer_ptwy_wpt = DATA(lv_buffer_ptwy_wpt)
      et_return          = DATA(lt_return) ).
  IF lt_return IS NOT INITIAL.
    APPEND LINES OF lt_return TO et_return.
    RETURN.
  ENDIF.

  DATA(ls_t300_md)     = go_sampling->read_location( is_hu_whse_task-lgnum ).
  DATA(ls_partner)     = go_sampling->partner_read( is_hu_whse_task-entitled ).
  lv_material = |{ is_hu_whse_task-matnr ALPHA = IN }|.
  DATA(ls_matlwh) = go_sampling->material_warehouse_data_read(  iv_matnr        = CONV #( lv_material )
                                                                iv_scuguid      = ls_t300_md-scuguid
                                                                iv_entitled_id  = CONV #( ls_partner-partner_guid ) ).
  IF lv_paci NE ls_matlwh-put_stra_plan.
    MESSAGE e041(z_vi02_general) WITH lv_paci INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

*  DATA(ls_sourcehu_pmat) = go_sampling->material_read_single( ls_sourcehu_header-pmat ).
  TRY.
      go_sampling->material_read_single(
        EXPORTING
         iv_matid      = ls_sourcehu_header-pmat_guid
        IMPORTING
         es_mat_global  = DATA(ls_sourcehu_pmat)  ).
    CATCH
      /scwm/cx_md_interface
      /scwm/cx_md_material_exist
      /scwm/cx_md_mat_lgnum_exist
      /scwm/cx_md_lgnum_locid
      /scwm/cx_md.

  ENDTRY.

  DATA(lt_storage_type) =  go_sampling->read_storage_type_data(
     EXPORTING
       iv_matnr       = ls_sourcehu_pmat-matnr
       iv_scuguid     = ls_t300_md-scuguid
       iv_entitled_id = CONV #( ls_partner-partner_guid )
       it_lgtyp       = VALUE /scmb/mdl_lgtyp_tab( ( lgtyp = lv_ambient_buffer ) ) ).
  IF lt_storage_type IS INITIAL.
    MESSAGE e043(z_vi02_general) WITH lv_ambient_buffer INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.


  DATA(lt_sample_hus) = go_sampling->get_sample_hus( EXPORTING
                                                       iv_lgnum = is_hu_whse_task-lgnum
                                                       iv_src_huident = ls_sampling_huheader-zzvi02_src_huid ).
  LOOP AT lt_sample_hus INTO DATA(ls_sample_hus) WHERE huident NE lv_sampling_hu.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    MESSAGE e046(z_vi02_general) WITH lv_ambient_buffer INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  TRY.
      go_sampling->hu_whse_tasks(
        EXPORTING
          iv_whno     = is_hu_whse_task-lgnum
          iv_huident  = ls_sourcehu_header-huident
          iv_vhi      = ls_sourcehu_header-vhi
        IMPORTING
          et_wht_data = DATA(lt_wht_data) ).
    CATCH /scwm/cx_api_whse_task INTO DATA(lx_api_whse_task).

  ENDTRY.

  LOOP AT lt_wht_data INTO DATA(ls_wht_data).
    LOOP AT ls_wht_data-t_ordim_o INTO DATA(ls_ordim_o).
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      MESSAGE e047(z_vi02_general) WITH lv_ambient_buffer INTO lv_message.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF et_return IS NOT INITIAL.
    RETURN.
  ENDIF.

  "we process this last Sample HU and send
  "When the source HU has no other warehouse task then we trigger a putaway HU-WT of that source HU (back to highbay).

  ls_create-huident    = ls_sourcehu_header-huident.
  ls_create-guid_hu    = ls_sourcehu_header-guid_hu.
  ls_create-procty     = CONV #( lv_buffer_ptwy_wpt ).
****
****  ls_create-reason     = is_hu_whse_task-reason.
****  ls_create-squit      = is_hu_whse_task-squit.
****  ls_create-norou      = is_hu_whse_task-norou.
****  ls_create-nltyp      = COND #( WHEN is_hu_whse_task-nltyp IS NOT INITIAL THEN is_hu_whse_task-nltyp
****                                 ELSE ls_destination_huheader-lgtyp ).
****  ls_create-nlber      = COND #( WHEN is_hu_whse_task-nlber IS NOT INITIAL THEN is_hu_whse_task-nlber
****                                 ELSE ls_destination_huheader-lgber ).
****  ls_create-nlpla      = COND #( WHEN is_hu_whse_task-nlpla IS NOT INITIAL THEN is_hu_whse_task-nlpla
****                                 ELSE ls_destination_huheader-lgpla ).
****
****  ls_create-nlenr      = ls_destination_huheader-huident.
****  ls_create-dguid_hu   = ls_destination_huheader-guid_hu.
****  DATA(rs_rsrc)        = go_sampling->read_whnbr_of_resource( ).
****  ls_create-drsrc      = rs_rsrc-rsrc.
****
  APPEND ls_create TO lt_create.

  go_sampling->whse_task_create_for_hu(
      EXPORTING
       iv_whno        = is_hu_whse_task-lgnum
       it_create      = lt_create
     IMPORTING
       et_created_wht = DATA(lt_created_wht)
       eo_message     = DATA(lo_message) ).

  lv_error = lo_message->check( iv_msgty = /scwm/if_api_message=>sc_msgty_error ).
  IF lv_error IS NOT INITIAL.
    lo_message->get_messages( IMPORTING et_bapiret = DATA(lt_bapiret) ).
    APPEND LINES OF lt_bapiret TO et_return[].
    RETURN.
  ENDIF.

  "	Destroy the quant (e.g. with unplanned goods issue)  --> not decided how to desttroy it.
  " and delete the sample HU
  lt_huident = VALUE #( ( huident = lv_sampling_hu ) ).
  go_sampling->delete_hu(
     EXPORTING
       iv_whno    = is_hu_whse_task-lgnum
       it_huident = lt_huident ).


  DATA(ls_created_wht) = VALUE #( lt_created_wht[ 1 ] OPTIONAL ).
  es_keys-lgnum = is_hu_whse_task-lgnum.
  es_keys-tanum = ls_created_wht-tanum.
  es_keys-tapos = ls_created_wht-tapos.

ENDFUNCTION.
