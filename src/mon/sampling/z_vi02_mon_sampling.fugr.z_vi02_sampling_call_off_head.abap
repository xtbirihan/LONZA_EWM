FUNCTION z_vi02_sampling_call_off_head.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE DEFAULT '1'
*"     REFERENCE(IT_DATA_PARENT) TYPE  /SCWM/TT_LIME_ALL_MON OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_DATA) TYPE  ZVI02_TT_SAMPLING_HEAD
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"  CHANGING
*"     REFERENCE(CT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"  RAISING
*"      /SCWM/CX_MON_NOEXEC
*"----------------------------------------------------------------------
  DATA: lt_physical_stock TYPE /scwm/tt_lime_all_mon.

  CALL FUNCTION 'Z_VI02_SAMPLING_CALL_OFF'
    EXPORTING
      iv_lgnum      = iv_lgnum
      iv_variant    = iv_variant
      iv_mode       = iv_mode
    IMPORTING
      et_data       = lt_physical_stock
      ev_returncode = ev_returncode
      ev_variant    = ev_variant
    CHANGING
      ct_fieldcat   = ct_fieldcat
      ct_tab_range  = ct_tab_range.

  LOOP AT lt_physical_stock ASSIGNING FIELD-SYMBOL(<ls_phys_stock>).
    ASSIGN et_data[ matid = <ls_phys_stock>-matid ] TO FIELD-SYMBOL(<ls_data>).
    IF sy-subrc = 0.
      <ls_data>-quan = <ls_data>-quan + <ls_phys_stock>-quan.
    ELSE.
      APPEND CORRESPONDING #( <ls_phys_stock> ) TO et_data.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
