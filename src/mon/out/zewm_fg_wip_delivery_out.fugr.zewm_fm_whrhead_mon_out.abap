FUNCTION zewm_fm_whrhead_mon_out .
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
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_WIP_WHRHEAD_OUT
*"     REFERENCE(ET_KEY) TYPE  /SCWM/DLV_DOCID_TAB
*"  CHANGING
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"     REFERENCE(CT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"  RAISING
*"      /SCWM/CX_MON_NOEXEC
*"----------------------------------------------------------------------

  DATA:
    lv_error          TYPE  boole_d,
    lt_mapping        TYPE  /scwm/tt_map_selopt2field,
    lt_selection      TYPE  /scwm/dlv_selection_tab,
    lt_selection_head TYPE /scwm/dlv_selection_tab,
    ls_mat_global     TYPE /scwm/s_material_global,
    ls_mat_lgnum      TYPE /scwm/s_material_lgnum,
    lt_data           TYPE /scwm/tt_wip_whritem_out,
    lt_timestamp_r    TYPE /scwm/tt_timestamp_r.

  DATA lo_whritem_mon_out TYPE REF TO lcl_whritem_mon_out.
  CREATE OBJECT lo_whritem_mon_out.

  CONSTANTS:
    lc_dynnr  TYPE  sydynnr  VALUE '0100'.

* If iv_mode = 3 -> display only popup and exit ------------------------
  IF iv_mode = 3.
    CALL FUNCTION 'RS_VARIANT_CATALOG'
      EXPORTING
        report               = sy-repid
*       NEW_TITLE            = ' '
        dynnr                = lc_dynnr
*       POP_UP               = ' '
      IMPORTING
        sel_variant          = ev_variant
      EXCEPTIONS
        no_report            = 1
        report_not_existent  = 2
        report_not_supplied  = 3
        no_variants          = 4
        no_variant_selected  = 5
        variant_not_existent = 6
        OTHERS               = 99.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    RETURN.
  ENDIF.

* Initialization -------------------------------------------------------

  lo_whritem_mon_out->initialization(
    EXPORTING iv_repid = sy-repid
    CHANGING ct_data = et_data ).

* Fill mapping table
  lo_whritem_mon_out->whritem_mapping(
    CHANGING ct_mapping = lt_mapping ).

* Fill warehouse number for WH dependent search helps
  p_lgnum = iv_lgnum.

*  SORT lt_mapping.
*  DELETE ADJACENT DUPLICATES FROM lt_mapping.

  IF NOT iv_variant IS INITIAL.
*   Use the selection criteria from a pre-defined variant without
*   presenting a selection screen
    CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
      EXPORTING
        report               = sy-repid
        variant              = iv_variant
      EXCEPTIONS
        variant_not_existent = 1
        variant_obsolete     = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  IF ct_tab_range IS NOT INITIAL.
*   The table it_tab_range contains the selection criteria, which
*   have been passed to the function module
*   these selection criteria should be visible in the selection screen
    CALL FUNCTION '/SCWM/RANGETAB2SELOPT'
      EXPORTING
        iv_repid     = sy-repid
        iv_lgnum     = iv_lgnum
        it_mapping   = lt_mapping
      CHANGING
        ct_tab_range = ct_tab_range.
  ENDIF.

* Move warehouse number into selection parameter for F4-Help
  p_lgnum = iv_lgnum.

  IF iv_mode = '1'.
*   show selection screen and use the selection criteria entered on
*   the screen. This screen can also be used for definition of a
*   variant (standard functionality of selection-screens)
    CALL SELECTION-SCREEN lc_dynnr STARTING AT 10 10
                                   ENDING AT 130 30.
    IF sy-subrc IS NOT INITIAL.
      MOVE 'X' TO ev_returncode.
      RETURN.
    ENDIF.
  ENDIF.

* Convert parameter to time stamps -------------------------------------
  lo_whritem_mon_out->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                  iv_datefrom = p_yrddfr
                                  iv_timefrom = p_yrdtfr
                                  iv_dateto = p_yrddto
                                  iv_timeto = p_yrdtto
                         CHANGING ct_timestamp = lt_timestamp_r ).

  lo_whritem_mon_out->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                   iv_datefrom = p_tudfr
                                   iv_timefrom = p_tutfr
                                   iv_dateto = p_tudto
                                   iv_timeto = p_tutto
                         CHANGING ct_timestamp = lt_timestamp_r ).

  lo_whritem_mon_out->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                   iv_datefrom = p_dlvdfr
                                   iv_timefrom = p_dlvtfr
                                   iv_dateto = p_dlvdto
                                   iv_timeto = p_dlvtto
                         CHANGING ct_timestamp = lt_timestamp_r ).

  lo_whritem_mon_out->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                   iv_datefrom = p_fdldfr
                                   iv_timefrom = p_fdltfr
                                   iv_dateto = p_fdldto
                                   iv_timeto = p_fdltto
                         CHANGING ct_timestamp = lt_timestamp_r ).

  lo_whritem_mon_out->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                   iv_datefrom = p_cdatfr
                                   iv_timefrom = p_ctimfr
                                   iv_dateto = p_cdatto
                                   iv_timeto = p_ctimto
                         CHANGING ct_timestamp = lt_timestamp_r ).

* Export selection criteria --------------------------------------------
  CALL FUNCTION '/SCWM/SELOPT2RANGETAB'
    EXPORTING
      iv_repid     = sy-repid
      it_mapping   = lt_mapping
    IMPORTING
      et_tab_range = ct_tab_range.

* Fill selection table -------------------------------------------------
* Parent node criteria
  lo_whritem_mon_out->fill_selection_table(
     EXPORTING
        iv_lgnum = iv_lgnum
     CHANGING
        ct_selection = lt_selection ).

  IF s_put_h IS NOT INITIAL.
* Select data ----------------------------------------------------------
    CALL FUNCTION '/SCWM/WHRITEM_MON_OUT_COMMON'
      EXPORTING
        it_selection         = lt_selection
        iv_lgnum             = iv_lgnum
        iv_skip_status_calc  = p_cdyns
        iv_keys_only         = iv_keys_only
      IMPORTING
        et_data              = lt_data
        et_key               = et_key
      CHANGING
        ct_fieldcat          = ct_fieldcat.

*Get materials
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      CALL FUNCTION '/SCWM/MATERIAL_READ_SINGLE'
        EXPORTING
          iv_lgnum      = iv_lgnum
          iv_entitled   = <ls_data>-entitled
          iv_matid      = NEW /scwm/cl_ui_stock_fields( )->get_matid_by_no( iv_matnr = <ls_data>-productno )
        IMPORTING
          es_mat_global = ls_mat_global
          es_mat_lgnum  = ls_mat_lgnum.

      IF ls_mat_lgnum-put_stra IN s_put_h .
        lt_selection_head = VALUE #( BASE lt_selection_head ( fieldname = 'DOCID'
                                                              sign      = wmegc_sign_inclusive
                                                              option    = wmegc_option_eq
                                                              low       = <ls_data>-docid ) ).
      ENDIF.
    ENDLOOP.
  ELSE.
    APPEND LINES OF lt_selection TO lt_selection_head.
  ENDIF.

* Adjust selection table for wildcard searches -------------------------
  /scwm/cl_dlv_ui_services=>modify_wildcard_selections(
     CHANGING ct_selections_prd = lt_selection ).

* Execute query and fill output table ----------------------------------
  CALL FUNCTION '/SCWM/WHRHEAD_MON_OUT_COMMON'
    EXPORTING
      it_selection         = lt_selection_head
      iv_lgnum             = iv_lgnum
      iv_calc_pack_status  = p_calc
      iv_skip_status_calc  = p_cdyns
      iv_keys_only         = iv_keys_only
      iv_dgrel_calc        = p_dgind
      iv_get_refdoc        = p_refdoc
      iv_count_attachments = p_cntatt
    IMPORTING
      et_data              = et_data
      et_key               = et_key
    CHANGING
      ct_fieldcat          = ct_fieldcat.

ENDFUNCTION.
