CLASS zcl_vi02_mfs_process_helper DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .
    METHODS ewmbin2sisaddr
      IMPORTING
        !iv_lgnum             TYPE /scwm/lgnum
        !iv_plc               TYPE /scwm/de_mfsplc
        !iv_lgpla             TYPE /scwm/lgpla
        !iv_logpos            TYPE /scwm/de_logpos OPTIONAL
        !iv_objtype           TYPE /scwm/de_mfsobjtype DEFAULT wmegc_mfs_ewm_obj_bin
        !iv_huident           TYPE /scwm/de_huident OPTIONAL
        !iv_hutyp             TYPE /scwm/de_hutyp OPTIONAL
      RETURNING
        VALUE(rv_sis_address) TYPE /scwm/de_mfsplcobj .
    METHODS sisaddr2ewmbin
      IMPORTING
        !iv_lgnum       TYPE /scwm/lgnum
        !iv_plc         TYPE /scwm/de_mfsplc
        !iv_sisaddress  TYPE /scwm/de_mfsplcobj
        !iv_objtype     TYPE /scwm/de_mfsobjtype DEFAULT wmegc_mfs_ewm_obj_cs
      EXPORTING
        !ev_lgpla       TYPE /scwm/lgpla
        !ev_logpos      TYPE /scwm/de_logpos
      RETURNING
        VALUE(rv_lgpla) TYPE /scwm/lgpla .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VI02_MFS_PROCESS_HELPER IMPLEMENTATION.


  METHOD constructor.
  ENDMETHOD.


  METHOD ewmbin2sisaddr.
************************************************************************
* Company     : Swisslog AG
*
* Package     : /SL0/MFS
* Class       : /SL0/CL_MFS_PROCESS_HELPER
* Method      : EWMBIN2SISADDR
* Description : This ABAP is used to translate storage to SIS address
*
*
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦ Date       ¦ Author           ¦ Description
* ------- ¦ ---------- ¦ ---------------- ¦ ----------------------------
* 1.0     ¦ 2017-05-04 ¦ B7TARAH          ¦ Initial version
************************************************************************


    " ------------------------------------------ "
    "  Local Declarations..
    " ------------------------------------------ "

    DATA : ls_mfsobjmap  TYPE /scwm/mfsobjmap.
    DATA: ls_swl_mfsplc TYPE /sl0/t_mfsplc.
    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "
    SELECT SINGLE * FROM /scwm/mfsobjmap                    "#EC WARNOK
                    INTO ls_mfsobjmap
                    WHERE lgnum = iv_lgnum
                    AND plc     = iv_plc
                    AND ewmobj  = iv_lgpla
                    AND objtype = iv_objtype.

    IF sy-subrc IS INITIAL.
      rv_sis_address = ls_mfsobjmap-plcobj.
      RETURN.
    ENDIF.

    IF iv_plc IS NOT INITIAL.
*|    Now read Swisslog customizing for PLC
      CALL FUNCTION '/SL0/MFSPLC_READ_SINGLE'
        EXPORTING
          iv_lgnum      = iv_lgnum
          iv_plc        = iv_plc
          iv_nobuf      = abap_true
        IMPORTING
          es_swl_mfsplc = ls_swl_mfsplc
        EXCEPTIONS
          error         = 1
          not_found     = 2
          OTHERS        = 99.
      IF sy-subrc <> 0.
        CLEAR ls_swl_mfsplc.
      ENDIF.
    ENDIF.


    rv_sis_address = iv_lgpla.

    "remove the prefix if needed
    DATA(lv_prefix_length) = strlen( ls_swl_mfsplc-hbw_bin_prefix ).
    IF lv_prefix_length IS NOT INITIAL.

      "check prefix, and remove it if matching
      IF rv_sis_address(lv_prefix_length) = ls_swl_mfsplc-hbw_bin_prefix.

        SHIFT rv_sis_address LEFT BY lv_prefix_length PLACES.

      ELSE.
        "not the same prefix?

      ENDIF.
    ENDIF.


    IF rv_sis_address CS '-'.
      REPLACE ALL OCCURRENCES OF '-' IN rv_sis_address WITH space.
    ENDIF.

    DATA(lo_service_compartment) = zcl_vi02_service_compartment=>get_inst( iv_lgnum ).
    CALL METHOD lo_service_compartment->modify_plcaddr
      EXPORTING
        iv_lgpla   = iv_lgpla
        iv_huident = iv_huident
        iv_hutyp   = iv_hutyp
      CHANGING
        cv_plcobj  = rv_sis_address.


*    "we need the Storage bin type to check if it is relevant for compartments
*    DATA: ls_lagp TYPE /scwm/lagp.
*    CALL FUNCTION '/SCWM/LAGP_READ_SINGLE'
*      EXPORTING
*        iv_lgnum      = iv_lgnum
*        iv_lgpla      = iv_lgpla
**       IV_NOBUF      =
**       IV_ENQ_WAIT   =
*      IMPORTING
**       EV_GUID_LOC   =
*        es_lagp       = ls_lagp
**       ES_LAGP_INT   =
*      EXCEPTIONS
*        wrong_input   = 1
*        not_found     = 2
*        enqueue_error = 3
*        OTHERS        = 4.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    DATA(lo_service_compartment) = zcl_vi02_service_compartment=>get_inst( iv_lgnum ).
*    DATA lv_comp_base   TYPE i.
*    DATA lv_comp_place TYPE i.
*    "Is in relevant for compartmets?
*    IF abap_true EQ lo_service_compartment->is_lgtyp_relevant_chk_compar( iv_lgtyp = ls_lagp-lgtyp  ).
*      TRY.
*          DATA(lv_epal) = lo_service_compartment->is_epal( EXPORTING iv_huident = iv_huident
*                                                                     iv_letyp   = iv_hutyp ).
*
*        CATCH zcx_vi02_general_exception.
*          " and now?
*      ENDTRY.
*
*      IF  rv_sis_address+5(2) CO '0123456789'
*      AND rv_sis_address+5(2) CN '0'
*      AND rv_sis_address+7(1) CA 'ABC'.
*        lv_comp_base = 1 + ( rv_sis_address+5(2) - 1 ) * 5 .
*
*        IF lv_epal EQ 'X'.
*          lv_comp_place = SWITCH i( rv_sis_address+7(1) WHEN 'A' THEN 1
*                                                        WHEN 'B' THEN 3
*                                                        WHEN 'C' THEN 5 ).
*        ELSE.
*          lv_comp_place = SWITCH i( rv_sis_address+7(1) WHEN 'A' THEN 2
*                                                        WHEN 'B' THEN 3 "" that is not really possible
*                                                        WHEN 'C' THEN 4 ).
*        ENDIF.
*
*        rv_sis_address+5(3) = CONV numc3( lv_comp_base + lv_comp_place ).
*
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD sisaddr2ewmbin.
************************************************************************
* Company     : Swisslog AG
*
* Package     : /SL0/MFS
* Group       : /SL0/MFS_PLC_TO_EWM_OBJ
* Function    : /SL0/MFS_PLC_TO_EWM_OBJ
* Enhancement : BAdI /SCWM/EX_MFS_TELE_PLC2EWMOB
* Description : This ABAP is used to map PLC to SAP EWM Object it is
*               called from /SCWM/MFS_PLC2EWM_OBJ
*
*
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦ Date       ¦ Author           ¦ Description
* ------- ¦ ---------- ¦ ---------------- ¦ ----------------------------
* 1.0     ¦ 2016-01-01 ¦ B7TARAH          ¦ Initial version
* 1.1     ¦ 2016-09-21 ¦ B7REHMT          ¦ Quick change for SIS crane prefix
* 1.1     ¦ 2016-09-28 ¦ B7TARAH          ¦ Customizable prefix for storagebins in the highbay warehouse
* 1.2     | 2017-09-15 | G7SAMBS          | Bugfix & Refactoring ????
* 1.2     | 2017-09-15 | B7TARAH          | And now it works again.
************************************************************************

    " ------------------------------------------ "
    "  Local Declarations..
    " ------------------------------------------ "
    DATA: ls_swl_mfsplc TYPE /sl0/t_mfsplc
*        , ls_prefix     TYPE CHAR2.
        .

    " ------------------------------------------ "
    "  Initialization / Import..
    " ------------------------------------------ "
    CLEAR ev_lgpla.

    IF iv_sisaddress IS INITIAL.
      RETURN.
    ENDIF.

    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "
*|  Get the Assignment of MFS Objects to EWM Objects..
    SELECT SINGLE ewmobj
      FROM /scwm/mfsobjmap                                  "#EC WARNOK
      INTO ev_lgpla
     WHERE lgnum = iv_lgnum
       AND plc = iv_plc
       AND plcobj = iv_sisaddress
       AND objtype = iv_objtype. "wmegc_mfs_ewm_obj_cs.

    IF sy-subrc IS INITIAL.
      rv_lgpla = ev_lgpla.
      RETURN.
    ENDIF.

    CLEAR: ev_lgpla.

*|  SIS address is is not mapped to an object (i.e. communication point, segment resource etc)
*|  thus it must be a storage bin in high-bay racking

    IF iv_plc IS NOT INITIAL.
*|    Now read Swisslog customizing for PLC
      CALL FUNCTION '/SL0/MFSPLC_READ_SINGLE'
        EXPORTING
          iv_lgnum      = iv_lgnum
          iv_plc        = iv_plc
          iv_nobuf      = abap_true
        IMPORTING
          es_swl_mfsplc = ls_swl_mfsplc
        EXCEPTIONS
          error         = 1
          not_found     = 2
          OTHERS        = 99.
      IF sy-subrc <> 0.
        CLEAR ls_swl_mfsplc.
      ENDIF.
    ENDIF.

*|  We map the SIS address to the following format PPmmrrrsssll where PP is a two character, customizable value
*|  or for compartments to PPmmrrrccpll, where the ccp is calculated from the sss
*|  cc is the compartment number p is s sufix (place in the compartment)

*|  (No depth as crane does not supply depth)

    ev_lgpla = |{ ls_swl_mfsplc-hbw_bin_prefix }{ iv_sisaddress+0(2) }{ iv_sisaddress+2(3) }{ iv_sisaddress+5(3) }{ iv_sisaddress+8(2) }|.


    DATA(lo_service_compartment) = zcl_vi02_service_compartment=>get_inst( iv_lgnum ).
    CALL METHOD lo_service_compartment->modify_ewmaddr
      EXPORTING
        iv_plc   = iv_plc
      CHANGING
        cv_lgpla = ev_lgpla.

*    DATA lv_comp_base   TYPE i.
*    DATA lv_comp_place TYPE i.
*    "Is in relevant for compartmets?
*    IF abap_true EQ lo_service_compartment->is_lgtyp_relevant_chk_compar( iv_lgtyp = ls_lagp-lgtyp  ).
*    DATA:
*      lv_numc3      TYPE numc3,
*      lv_ccp        TYPE char03,
*      lv_comp_base  TYPE i,
*      lv_comp_place TYPE i.
*
*    TRY.
*        lv_numc3 = iv_sisaddress+5(3).
*      CATCH cx_root.
*        CLEAR lv_numc3.
*    ENDTRY.
*
*
*    IF lv_numc3 > 1
*    AND iv_plc(4) = 'CRAN'.
*
*      lv_comp_base =  1 + ( lv_numc3 - 2 ) DIV 5.
*      lv_comp_place = ( lv_numc3 - 2 ) MOD 5 + 1.
*      lv_ccp(2)   = CONV numc2( lv_comp_base ).
*      lv_ccp+2(1) = SWITCH char01( lv_comp_place WHEN 1 OR 2 THEN 'A'
*                                                 WHEN 3      THEN 'B'
*                                                 WHEN 4 OR 5 THEN 'C' ).
*      ev_lgpla = |{ ls_swl_mfsplc-hbw_bin_prefix }{ iv_sisaddress+0(2) }{ iv_sisaddress+2(3) }{ lv_ccp }{ iv_sisaddress+8(2) }|.
*    ELSE.
*      ev_lgpla = |{ ls_swl_mfsplc-hbw_bin_prefix }{ iv_sisaddress+0(2) }{ iv_sisaddress+2(3) }{ iv_sisaddress+5(3) }{ iv_sisaddress+8(2) }|.
*    ENDIF.


*|  Set return parameter
      rv_lgpla = ev_lgpla.

    ENDMETHOD.
ENDCLASS.
