FUNCTION z_vi02_hu_items_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_WORKSTATION) TYPE  /SCWM/DE_WORKSTATION
*"     VALUE(IV_HUIDENT) TYPE  /SCWM/DE_HUIDENT
*"  EXPORTING
*"     VALUE(ET_HUITEMS) TYPE  ZVI02_T_HU_ITEM
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA:
    ls_return  TYPE bapiret2,
    lv_huident TYPE /scwm/de_huident.

  go_sampling = lcl_sampling_doc=>get_instance( ).

  IF lv_huident+0(1) = 'T'.
    MESSAGE e031(z_vi02_general) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  lv_huident = |{ iv_huident ALPHA = IN }|.

  go_sampling->hu_read(
    EXPORTING
      iv_lgnum   = iv_lgnum
      iv_huident = lv_huident
    IMPORTING
      ev_error   = DATA(lv_error)
      es_huhdr   = DATA(ls_header)
      et_huitm   = DATA(lt_huitm) ).
  IF lv_error IS NOT INITIAL.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  DATA(lt_item) = lt_huitm.
  SORT lt_item BY matid.
  DELETE ADJACENT DUPLICATES FROM lt_item COMPARING matid.
  IF sy-subrc EQ 0.
    MESSAGE e032(z_vi02_general) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  SORT lt_item BY batchid.
  DELETE ADJACENT DUPLICATES FROM lt_item COMPARING batchid.
  IF sy-subrc EQ 0.
    MESSAGE e032(z_vi02_general) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  LOOP AT lt_huitm ASSIGNING FIELD-SYMBOL(<fs_item>).
    APPEND INITIAL LINE TO et_huitems ASSIGNING FIELD-SYMBOL(<fs_huitem>).
    MOVE-CORRESPONDING <fs_item> TO <fs_huitem>.
    <fs_huitem>-huident = iv_huident.
    <fs_huitem>-lgnum = iv_lgnum.
    <fs_huitem>-guid_hu = ls_header-guid_hu.
    <fs_huitem>-workstation = iv_workstation.
    TRY.
        DATA(lo_batch) = /scwm/cl_batch_appl=>get_instance(
            iv_productid = <fs_item>-matid
            iv_batchid   = <fs_item>-batchid
            iv_lgnum     = iv_lgnum
            iv_entitled  = <fs_item>-entitled ).

        lo_batch->get_batch(
          IMPORTING
            es_batch = DATA(ls_batch) ).
      CATCH /scwm/cx_batch_management.
        " Ignore, no need to take over the process type
    ENDTRY.
    IF ls_batch IS NOT INITIAL.
      <fs_huitem>-charg = ls_batch-charg.
    ENDIF.

    TRY.
        go_sampling->material_read_single(
          EXPORTING
            iv_matid      = <fs_item>-matid
          IMPORTING
            es_mat_global = DATA(ls_mat_global)
        ).
      CATCH /scwm/cx_md_interface.
      CATCH /scwm/cx_md_material_exist.
      CATCH /scwm/cx_md_mat_lgnum_exist.
      CATCH /scwm/cx_md_lgnum_locid.
      CATCH /scwm/cx_md.
    ENDTRY.

    <fs_huitem>-matnr      =  ls_mat_global-matnr      .
    <fs_huitem>-batch_req  =  ls_mat_global-batch_req  .
    <fs_huitem>-packgr     =  ls_mat_global-packgr     .
    <fs_huitem>-rmatp      =  ls_mat_global-rmatp      .
    <fs_huitem>-hutyp_dflt =  ls_mat_global-hutyp_dflt .
    <fs_huitem>-whmatgr    =  ls_mat_global-whmatgr    .
    <fs_huitem>-whstc      =  ls_mat_global-whstc      .
    <fs_huitem>-hndlcode   =  ls_mat_global-hndlcode   .
    IF <fs_huitem>-hndlcode IS NOT INITIAL.
      CALL METHOD /scmb/cl_mdl_wh_reader=>thndlcd_read
        EXPORTING
          iv_hndlcode = <fs_huitem>-hndlcode
          iv_langu    = sy-langu
        IMPORTING
          es_hndlcdt  = DATA(ls_thndlcdt).

      <fs_huitem>-hndlcode_t = ls_thndlcdt-text.
    ENDIF.
    <fs_huitem>-langu      =  ls_mat_global-langu      .
    <fs_huitem>-maktx      =  ls_mat_global-maktx      .
    <fs_huitem>-matkl      =  ls_mat_global-matkl      .

    DATA(ls_mara) = go_sampling->material_master_read_single(
      EXPORTING
        iv_matnr = ls_mat_global-matnr ).

    DATA(lv_cost_center) = go_sampling->cost_center_read_single(
      EXPORTING
        iv_lgnum       = iv_lgnum
        iv_workstation = iv_workstation
        iv_matnr       = ls_mat_global-matnr
        iv_mtart       = ls_mara-mtart ).
    IF lv_cost_center IS INITIAL.
      MESSAGE e033(z_vi02_general) WITH TEXT-001 INTO lv_message.
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    ENDIF.
    <fs_huitem>-kostl = lv_cost_center.

    DATA(ls_mdl_partner) = go_sampling->partner_read(
      EXPORTING
        iv_partner     = <fs_item>-entitled ).

    <fs_huitem>-partner_guid = ls_mdl_partner-partner_guid.
    <fs_huitem>-partner_role = ls_mdl_partner-partner_role.
    <fs_huitem>-partner      = ls_mdl_partner-partner.
    <fs_huitem>-type         = ls_mdl_partner-type.
    <fs_huitem>-type         = ls_mdl_partner-type.
    <fs_huitem>-name         = ls_mdl_partner-name.
    <fs_huitem>-addrnumber   = ls_mdl_partner-addrnumber.

    DATA(ls_t300_md)     = go_sampling->read_location( iv_lgnum ).
    DATA(ls_partner)     = go_sampling->partner_read( <fs_item>-entitled ).

    DATA(ls_matlwh) = go_sampling->material_warehouse_data_read(
          !iv_matnr        = ls_mat_global-matnr
          !iv_scuguid      = ls_t300_md-scuguid
          !iv_entitled_id  = CONV #( ls_partner-partner_guid ) ).


    <fs_huitem>-put_stra_plan = ls_matlwh-put_stra_plan.
    IF <fs_huitem>-put_stra_plan IS NOT INITIAL.
      <fs_huitem>-put_stra_plan_t = go_sampling->read_putaway_strategy_text(  EXPORTING iv_lgnum = iv_lgnum
                                                                                        iv_put_stra = <fs_huitem>-put_stra_plan ).
    ENDIF.
    CLEAR: ls_batch, ls_mat_global, lv_cost_center, ls_thndlcdt.
  ENDLOOP.


ENDFUNCTION.
