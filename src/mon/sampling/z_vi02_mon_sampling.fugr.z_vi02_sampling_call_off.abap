FUNCTION z_vi02_sampling_call_off.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IV_VARIANT) TYPE  VARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  /SCWM/DE_MON_FM_MODE DEFAULT '1'
*"     REFERENCE(IT_DATA_PARENT) TYPE  ZVI02_TT_SAMPLING_HEAD OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_DATA) TYPE  /SCWM/TT_LIME_ALL_MON
*"     REFERENCE(EV_RETURNCODE) TYPE  XFELD
*"     REFERENCE(EV_VARIANT) TYPE  VARIANT
*"  CHANGING
*"     REFERENCE(CT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"     REFERENCE(CT_TAB_RANGE) TYPE  RSDS_TRANGE OPTIONAL
*"  RAISING
*"      /SCWM/CX_MON_NOEXEC
*"----------------------------------------------------------------------

  DATA:
    lv_repid          TYPE sy-repid,
    lt_mapping        TYPE /scwm/tt_map_selopt2field,
    lt_stock_mon      TYPE /scwm/tt_stock_mon,
    ls_data           TYPE /scwm/s_lime_all_mon,
    ls_t331           TYPE /scwm/t331,
    lt_stock_docno_r  TYPE /scwm/tt_stock_docno_r,
    ls_stock_docno_r  TYPE /scwm/s_stock_docno_r,
    lt_stock_doccat_r TYPE /scwm/tt_stock_doccat_r,
    ls_stock_doccat_r TYPE /scwm/s_stock_doccat_r,
    lt_data_tmp       TYPE /scwm/tt_lime_all_mon,
    lo_wip_map_srv    TYPE REF TO /scwm/cl_wip_map_db_service.

  FIELD-SYMBOLS:
    <ls_stock_mon> TYPE /scwm/s_stock_mon,
    <ls_mapping>   TYPE /scwm/s_map_selopt2field.

* Get program name
  lv_repid = sy-repid.

  DATA(lo_sampling) = NEW lcl_sampling( ).
  go_mon_stock = NEW #( iv_lgnum ).

* Adjust field catalog
  LOOP AT ct_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
    IF <ls_fieldcat>-fieldname = 'UNIT_EXACT'
      OR <ls_fieldcat>-fieldname = 'QUAN_EXACT'.
      <ls_fieldcat>-no_out = abap_true.
    ENDIF.
  ENDLOOP.

* Only display popup and exit
  IF iv_mode = '3'.
    CALL FUNCTION 'RS_VARIANT_CATALOG'
      EXPORTING
        report               = lv_repid
        dynnr                = '0600'
      IMPORTING
        sel_variant          = ev_variant
      EXCEPTIONS
        no_report            = 1
        report_not_existent  = 2
        report_not_supplied  = 3
        no_variants          = 4
        no_variant_selected  = 5
        variant_not_existent = 6
        OTHERS               = 7.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    RETURN.
  ENDIF.

* Initialization
  lo_sampling->initialization(
    EXPORTING
      iv_repid = sy-repid
    CHANGING
      ct_data  = et_data ).

  lo_sampling->create_mapping(
    CHANGING
      ct_mapping = lt_mapping ).

  IF iv_variant IS NOT INITIAL.
*   Use the selection criteria from a pre-defined variant without
*   presenting a selection screen
    CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
      EXPORTING
        report               = lv_repid
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

  IF lines( ct_tab_range ) > 0.
*   Table it_tab_range contains selection criteria passed to FM
*   -> these selection criteria should be visible on selection screen
    CALL FUNCTION '/SCWM/RANGETAB2SELOPT'
      EXPORTING
        iv_repid     = lv_repid
        it_mapping   = lt_mapping
      CHANGING
        ct_tab_range = ct_tab_range.
  ELSEIF iv_variant IS INITIAL.
*   only set it up if selection screen is shown
    IF iv_mode EQ '1'.
      p_rsrc = 'X'.
      p_tu = 'X'.
    ENDIF.
  ENDIF.

  IF lines( it_data_parent ) > 0.
    CALL FUNCTION '/SCWM/FILL_SELOPT_BY_KEYS'
      EXPORTING
        iv_repid       = lv_repid
        it_mapping     = lt_mapping
        it_data_parent = it_data_parent.
  ENDIF.

  IF iv_mode = '1'.
*   Move warehouse number into selection parameter for F4-Help
    p_lgnum = iv_lgnum.
*   Show selection screen
    CALL SELECTION-SCREEN '0600' STARTING AT 10 10
                                 ENDING AT 130 30.
    IF sy-subrc <> 0.
      ev_returncode = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

* Export selection criteria
  CALL FUNCTION '/SCWM/SELOPT2RANGETAB'
    EXPORTING
      iv_repid     = lv_repid
      it_mapping   = lt_mapping
    IMPORTING
      et_tab_range = ct_tab_range.
*----------------------------------------------------------------------*
* Add wip no to monitor -- begin
*----------------------------------------------------------------------*
  lo_wip_map_srv = NEW /scwm/cl_wip_map_db_service( ).
  IF s_wip_no[] IS NOT INITIAL.
    TRY.
        lo_wip_map_srv->query(
          EXPORTING
            iv_lgnum       = iv_lgnum
*            ir_mes_bs      =
*            ir_entitled    =
            ir_wip_no      = s_wip_no[]
*            ir_stock_docno =
          IMPORTING
          et_wip_map     = DATA(lt_wip_map)
              ).
      CATCH /scwm/cx_wip.
    ENDTRY.
    IF lt_wip_map IS INITIAL.
      RETURN.
    ENDIF.
    ls_stock_docno_r-sign = 'I'.
    ls_stock_docno_r-option = 'EQ'.
    LOOP AT lt_wip_map INTO DATA(ls_wip_map).
      ls_stock_docno_r-low = ls_wip_map-stock_docno.
      APPEND ls_stock_docno_r TO lt_stock_docno_r.
    ENDLOOP.
    ls_stock_doccat_r-sign = 'I'.
    ls_stock_doccat_r-option = 'EQ'.
    ls_stock_doccat_r-low = 'WIP'.
    APPEND ls_stock_doccat_r TO lt_stock_doccat_r.
  ENDIF.
*----------------------------------------------------------------------*
* Add wip no to monitor -- end
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Select the data according to the selection criteria
*----------------------------------------------------------------------*
  IF iv_mode = '2' OR
     iv_mode = '4' AND lines( it_data_parent ) > 0.
*   Drill down or refresh after drill down:
*   Additional select-options S_LGPLA, S_RSRC, S_TUEXT and S_TSP come
*   from parent node 'Stock Overview'
    CALL METHOD go_mon_stock->get_physical_stock
      EXPORTING
        iv_drill_down     = abap_true
        iv_skip_bin       = p_lgpla
        iv_skip_resource  = p_rsrc
        iv_skip_tu        = p_tu
        iv_skip_logpos    = p_e_logp
        it_matnr_r        = s_matnr[]
        it_cat_r          = s_stcat[]
        it_owner_r        = s_owner[]
        it_entitled_r     = s_entit[]
        it_charg_r        = s_batch[]
        it_stkseg_r       = s_stkseg[]
        it_idplate_r      = s_stoid[]
        it_serid_r        = s_serid[]
        it_uii_r          = s_uii[]
        it_huident_r      = s_huiden[]
        it_stock_doccat_r = lt_stock_doccat_r
        it_stock_docno_r  = lt_stock_docno_r
      IMPORTING
        et_stock_mon      = lt_stock_mon
        ev_error          = ev_returncode.
  ELSE.
    CALL METHOD go_mon_stock->get_physical_stock
      EXPORTING
        iv_drill_down     = abap_false
        iv_skip_bin       = p_lgpla
        iv_skip_resource  = p_rsrc
        iv_skip_tu        = p_tu
        iv_skip_logpos    = p_e_logp
        it_matnr_r        = s_matnr[]
        it_cat_r          = s_stcat[]
        it_owner_r        = s_owner[]
        it_entitled_r     = s_entit[]
        it_charg_r        = s_batch[]
        it_stkseg_r       = s_stkseg[]
        it_idplate_r      = s_stoid[]
        it_serid_r        = s_serid[]
        it_uii_r          = s_uii[]
        it_huident_r      = s_huiden[]
        it_stock_doccat_r = lt_stock_doccat_r
        it_stock_docno_r  = lt_stock_docno_r
      IMPORTING
        et_stock_mon      = lt_stock_mon
        ev_error          = ev_returncode.
  ENDIF.
*get wip no
  CLEAR: lt_wip_map,ls_wip_map.
  ls_stock_docno_r-sign = wmegc_sign_inclusive.
  ls_stock_docno_r-option = wmegc_option_eq.
  LOOP AT lt_stock_mon ASSIGNING <ls_stock_mon>.
    IF <ls_stock_mon>-stock_doccat EQ wmegc_stock_doccat_wip.
      ls_stock_docno_r-low = <ls_stock_mon>-stock_docno.
      APPEND ls_stock_docno_r TO lt_stock_docno_r.
    ENDIF.
  ENDLOOP.
  IF lt_stock_docno_r IS NOT INITIAL.
    TRY.
        lo_wip_map_srv->query(
          EXPORTING
            iv_lgnum       = iv_lgnum
            ir_stock_docno = lt_stock_docno_r
          IMPORTING
            et_wip_map     = lt_wip_map
          ).
      CATCH /scwm/cx_wip.                               "#EC NO_HANDLER
    ENDTRY.
    SORT lt_wip_map BY stock_docno.
  ENDIF.
* Fill exporting table
  LOOP AT lt_stock_mon ASSIGNING <ls_stock_mon>.
    CLEAR ls_data.
    MOVE-CORRESPONDING <ls_stock_mon> TO ls_data.           "#EC ENHOK
    ls_data-unit        = <ls_stock_mon>-meins.
    ls_data-cat_txt     = <ls_stock_mon>-cat_text.
    ls_data-doccat      = <ls_stock_mon>-qdoccat.
    ls_data-docno       = <ls_stock_mon>-qdocno.
    ls_data-itmno       = <ls_stock_mon>-qitemno.
********START:***In case of drill down, WIP NO is not initial, then only show records with matching WIP no with it_data_parent.
    IF <ls_stock_mon>-stock_doccat EQ wmegc_stock_doccat_wip.
      READ TABLE lt_wip_map INTO ls_wip_map WITH KEY stock_docno = <ls_stock_mon>-stock_docno BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-wip_no = ls_wip_map-wip_no.
      ENDIF.
    ENDIF.
********END:***In case of drill down, WIP NO is not initial, then only show records with matching WIP no with it_data_parent.
    ls_data-stock_docno = <ls_stock_mon>-stock_docno_ext.
    ls_data-quan_exact  = <ls_stock_mon>-quan_int.
    ls_data-unit_exact  = <ls_stock_mon>-meins.
*   In case of drill down, for filtering cross products, consider
*   entries for storage types managed batch neutral, separately,
*   because the parent entries have initial field CHARG.
*   Remark: stock overview is already aggregated on HU level and
*           has therefore no field HUIDENT
    IF ( iv_mode = '2' OR
         iv_mode = '4' AND lines( it_data_parent ) > 0 ).
      IF ls_data-lgtyp IS NOT INITIAL.
        CALL FUNCTION '/SCWM/T331_READ_SINGLE'
          EXPORTING
            iv_lgnum  = iv_lgnum
            iv_lgtyp  = ls_data-lgtyp
          IMPORTING
            es_t331   = ls_t331
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc = 0 AND
           ls_t331-avqbtc = wmegc_batch_neutral.
          APPEND ls_data TO lt_data_tmp.
          CONTINUE.
        ENDIF.
      ENDIF.
      APPEND ls_data TO et_data.
    ELSE.
      APPEND ls_data TO et_data.
    ENDIF.
  ENDLOOP.

* In case of drill down: filter cross products
  IF iv_mode = '2' OR
     iv_mode = '4' AND lines( it_data_parent ) > 0.
    CALL FUNCTION '/SCWM/WIP_FILTER_CROSS_PRODUCT'
      EXPORTING
        iv_lgnum       = iv_lgnum
        it_data        = et_data
        it_data_parent = it_data_parent
        it_mapping     = lt_mapping
      IMPORTING
        et_data        = et_data.
    IF lines( lt_data_tmp ) > 0.
*     CHARG of parent is initial due to storage type
*     => CHARG must not be key fields for filtering cross products
      LOOP AT lt_mapping ASSIGNING <ls_mapping>.
        IF <ls_mapping>-fieldname = 'CHARG'.
          <ls_mapping>-is_key = abap_false.
        ENDIF.
      ENDLOOP.
      CALL FUNCTION '/SCWM/WIP_FILTER_CROSS_PRODUCT'
        EXPORTING
          iv_lgnum       = iv_lgnum
          it_data        = lt_data_tmp
          it_data_parent = it_data_parent
          it_mapping     = lt_mapping
        IMPORTING
          et_data        = lt_data_tmp.
      APPEND LINES OF lt_data_tmp TO et_data.
    ENDIF.
  ENDIF.

  SORT et_data BY tu_num_ext
                  rsrc
                  lgpla.


ENDFUNCTION.
