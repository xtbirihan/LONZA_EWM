FUNCTION zewm_fm_whritem_mon_out.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM DEFAULT '0001'
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE DEFAULT '1'
*"     REFERENCE(IT_DATA_PARENT) TYPE  /SCWM/TT_WIP_WHRHEAD_OUT
*"       OPTIONAL
*"     REFERENCE(IV_KEYS_ONLY) TYPE  BOOLE_D OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"     REFERENCE(ET_DATA) TYPE  ZEWM_TT_WIP_WHRITEM_OUT
*"     REFERENCE(ET_KEY) TYPE  /SCWM/DLV_DOCID_TAB
*"  CHANGING
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"     REFERENCE(CT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"     REFERENCE(CT_SELECTION) TYPE  /SCWM/DLV_SELECTION_TAB OPTIONAL
*"  RAISING
*"      /SCWM/CX_MON_NOEXEC
*"----------------------------------------------------------------------

  DATA:
    lt_data           TYPE /scwm/tt_wip_whritem_out,
    lv_error          TYPE  boole_d,
    lt_mapping        TYPE  /scwm/tt_map_selopt2field,
    lt_selection      TYPE  /scwm/dlv_selection_tab,
    lt_selection_head TYPE /scwm/dlv_selection_tab,
    ls_mat_global     TYPE /scwm/s_material_global,
    ls_mat_lgnum      TYPE /scwm/s_material_lgnum.

  DATA lo_whritem_mon_out TYPE REF TO lcl_whritem_mon_out.
  CREATE OBJECT lo_whritem_mon_out.

  CLEAR et_data.

  IF it_data_parent IS NOT INITIAL.
    CALL FUNCTION '/SCWM/FILL_SELOPT_BY_KEYS'
      EXPORTING
        iv_repid       = sy-repid
        it_mapping     = lt_mapping
        it_data_parent = it_data_parent.
  ENDIF.

* Fill selection table -------------------------------------------------
  lo_whritem_mon_out->fill_selection_table_item(
      EXPORTING
        iv_lgnum = iv_lgnum
        it_data_parent = it_data_parent
      CHANGING
        ct_selection = lt_selection
        cv_error = lv_error ).

  IF lv_error = abap_true.
    RETURN.
  ENDIF.

* Adjust selection table for wildcard searches -------------------------
  /scwm/cl_dlv_ui_services=>modify_wildcard_selections(
     CHANGING ct_selections_prd = lt_selection ).

* Select data ----------------------------------------------------------
  CALL FUNCTION '/SCWM/WHRITEM_MON_OUT_COMMON'
    EXPORTING
      iv_lgnum            = iv_lgnum
      it_selection        = lt_selection
      iv_skip_status_calc = p_cdyns
      iv_keys_only        = iv_keys_only
    IMPORTING
      et_data             = lt_data
      et_key              = et_key
    CHANGING
      ct_fieldcat         = ct_fieldcat.

*Get materials
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

    IF NOT <ls_data>-productno IN s_prod.
      CONTINUE.
    ENDIF.

    CALL FUNCTION '/SCWM/MATERIAL_READ_SINGLE'
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_entitled   = <ls_data>-entitled
        iv_matid      = NEW /scwm/cl_ui_stock_fields( )->get_matid_by_no( iv_matnr = <ls_data>-productno )
      IMPORTING
        es_mat_global = ls_mat_global
        es_mat_lgnum  = ls_mat_lgnum.

    IF ls_mat_lgnum-put_stra IN s_put_h .
      APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<es_data>).
      <es_data> = VALUE #( BASE CORRESPONDING #( <ls_data> ) put_stra = ls_mat_lgnum-put_stra ).
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
