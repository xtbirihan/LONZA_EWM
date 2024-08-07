class ZCL_VI02_SERVICE_COMPARTMENT definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ts_comp_lgpla,
        lgnum       TYPE /scwm/lgnum,
        compartment TYPE z_vi02_de_compartment,
        lgpla       TYPE /scwm/lgpla,

      END OF ts_comp_lgpla .
  types:
    tt_comp_lgpla TYPE SORTED TABLE OF ts_comp_lgpla WITH NON-UNIQUE KEY lgnum lgpla
        WITH NON-UNIQUE SORTED KEY compartment COMPONENTS lgnum compartment .
  types:
    BEGIN OF ts_bin_user_status,
        lgnum     TYPE /scwm/lgnum,
        lgpla     TYPE /scwm/lgpla,
        guid_loc  TYPE /lime/guid_loc,
        status_db TYPE j_txt04,
        status    TYPE j_txt04,
      END OF ts_bin_user_status .
  types:
    tt_bin_user_status TYPE SORTED TABLE OF ts_bin_user_status WITH UNIQUE KEY lgnum lgpla
                                                                       WITH NON-UNIQUE SORTED KEY guid_loc COMPONENTS guid_loc .
  types:
    BEGIN OF ts_bin_user_status_chg,
        lgnum        TYPE /scwm/lgnum,
        lgpla        TYPE /scwm/lgpla,
        guid_loc     TYPE /lime/guid_loc,
        status       TYPE j_txt04,
        set_inactive TYPE xfeld,
        estat	       TYPE j_estat,
      END OF ts_bin_user_status_chg .
  types:
    tt_bin_user_status_chg TYPE STANDARD TABLE OF ts_bin_user_status_chg WITH DEFAULT KEY .

  constants CO_LANGU_EN type SYLANGU value 'E' ##NO_TEXT.
  constants:
    BEGIN OF co_stsma,
        zbinstat TYPE crm_j_stsma VALUE 'ZBINSTAT' ##NO_TEXT,
      END OF co_stsma .
  constants:
    BEGIN OF co_user_status,
        init TYPE j_txt04 VALUE 'INIT' ##NO_TEXT,
        blck TYPE j_txt04 VALUE 'BLCK' ##NO_TEXT,
        zep0 TYPE j_txt04 VALUE 'ZEP0' ##NO_TEXT,
        zip0 TYPE j_txt04 VALUE 'ZIP0' ##NO_TEXT,
      END OF co_user_status .

  class-methods GET_INST
    importing
      !IV_LGNUM type /SCWM/LGNUM
    returning
      value(RO_SERVICE) type ref to ZCL_VI02_SERVICE_COMPARTMENT .
  methods CHECK_STSMA
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods CONSTRUCTOR
    importing
      !IV_LGNUM type /SCWM/LGNUM .
  methods CONV_USER_STATUS_EXT_2_INT
    importing
      !IV_STATUS_EXT type J_TXT04
    returning
      value(RV_STATUS_INT) type CRM_J_STATUS .
  methods CONV_USER_STATUS_INT_2_EXT
    importing
      !IV_STATUS_INT type CRM_J_STATUS
    returning
      value(RV_STATUS_EXT) type J_TXT04 .
  methods GET_BINS_4_COMPARTMENT
    importing
      !IV_COMPARTMENT type Z_VI02_DE_COMPARTMENT
    returning
      value(RR_LGPLA) type /SCWM/TT_LGPLA .
  methods GET_BIN_STATUS_TAB
    importing
      !IV_REFRESH_BUFFER type XFELD optional
      !IT_GUID_LOC type /SCWM/TT_GUID_LOC optional
      !IT_LGPLA type /SCWM/TT_LAGP_KEY optional
    returning
      value(RT_BIN_USER_STATUS) type TT_BIN_USER_STATUS
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  class-methods GET_COMPARTMENT
    importing
      !IV_LGPLA type /SCWM/DE_LGPLA
    returning
      value(RV_COMPARTMENT) type Z_VI02_DE_COMPARTMENT .
  methods GET_NEEDED_USER_STATUS
    importing
      !IV_HUIDENT type /SCWM/DE_HUIDENT optional
      !IV_LETYP type /SCWM/DE_HUTYP optional
      !IV_HUTYPGRP type /SCWM/DE_HUTYPGRP optional
    returning
      value(RV_STATUS) type J_TXT04
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods IS_BIN_USABLE_FOR_STATUS
    importing
      !IV_STATUS type J_TXT04
      !IV_LGPLA type /SCWM/DE_LGPLA
    returning
      value(RV_RESULT) type XFELD .
  methods IS_EPAL
    importing
      !IV_HUIDENT type /SCWM/DE_HUIDENT optional
      !IV_LETYP type /SCWM/DE_HUTYP optional
      !IV_HUTYPGRP type /SCWM/DE_HUTYPGRP optional
    returning
      value(RV_RESULT) type XFELD
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods IS_LGNUM_RELEVANT
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods IS_LGTYP_RELEVANT_CHK_BATCH
    importing
      !IV_LGTYP type /SCWM/LGTYP
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods IS_LGTYP_RELEVANT_CHK_COMPAR
    importing
      !IV_LGTYP type /SCWM/LGTYP
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods MODIFY_PLCADDR
    importing
      !IV_LGPLA type /SCWM/LGPLA
      !IV_HUIDENT type /SCWM/DE_HUIDENT
      !IV_HUTYP type /SCWM/DE_HUTYP
    changing
      !CV_PLCOBJ type /SCWM/DE_MFSPLCOBJ .
  methods MODIFY_EWMADDR
    importing
      !IV_PLC type /SCWM/DE_MFSPLC
    changing
      !CV_LGPLA type /SCWM/LGPLA .
  methods RESERVE_COMPARTMENT .
  methods SELECT_COMPARTMENTS
    importing
      !IT_LGTYP_RG type RSELOPTION optional
      !IT_LGPLA_RG type RSELOPTION optional
      !IT_COMPARTMENT_RG type RSELOPTION optional
    returning
      value(RT_COMPARTMENT) type Z_VI02_TT_COMPARTMENT
    raising
      /SL0/CX_GENERAL_EXCEPTION .
  methods SELECT_COMP_LGPLA
    importing
      !IT_LGTYP_RG type RSELOPTION optional
      !IT_LGPLA_RG type RSELOPTION optional
      !IT_COMPARTMENT_RG type RSELOPTION optional
    returning
      value(RT_COMP_LGPLA) type TT_COMP_LGPLA .
  methods SELECT_EMPTY_COMPARTMENTS
    importing
      !IT_LGTYP_RG type RSELOPTION optional
      !IT_LGPLA_RG type RSELOPTION optional
      !IT_COMPARTMENT_RG type RSELOPTION optional
    returning
      value(RT_COMPARTMENT) type Z_VI02_TT_COMPARTMENT
    raising
      /SL0/CX_GENERAL_EXCEPTION .
  methods SET_STATUSES .
  class-methods UPDATE_BIN_STATUS_BUFFER
    importing
      !IV_LGNUM type /SCWM/LGNUM optional
      !IV_LGPLA type /SCWM/LGPLA optional
      !IV_GUID_LOC type /LIME/GUID_LOC optional
      value(IV_STATUS) type J_TXT04 .
  class-methods GET_BIN_STATUS_FROM_BUFFER
    importing
      !IV_LGNUM type /SCWM/LGNUM optional
      !IV_LGPLA type /SCWM/LGPLA optional
      !IV_GUID_LOC type /LIME/GUID_LOC optional
    returning
      value(RS_BIN_USER_STATUS) type TS_BIN_USER_STATUS .
  class-methods CLEAR_BIN_STATUS_BUFFER .
  class-methods SPLIT_PREFIX
    changing
      !CV_LGPLA type /SCWM/LGPLA
    returning
      value(RV_PREFIX) type CHAR02 .
  class-methods SPLIT_SUFFIX
    changing
      !CV_LGPLA type /SCWM/LGPLA
    returning
      value(RV_SUFFIX) type CHAR01 .
protected section.

  types:
    BEGIN OF ts_ref_buff,
      lgnum TYPE /scwm/lgnum,
      o_ref TYPE REF TO zcl_vi02_service_compartment,
    END OF ts_ref_buff .
  types:
    tt_ref_buff TYPE SORTED TABLE OF ts_ref_buff WITH UNIQUE KEY lgnum .

  class-data MT_REF_BUFF type TT_REF_BUFF .
  data MT_RG_HUTYPGRP_ZEPO type RSELOPTION .
  data MT_RG_LGTYP_CHECK_BATCH type RSELOPTION .
  data MT_RG_LGTYP_COMPARMENT type RSELOPTION .
  data MV_LGNUM type /SCWM/LGNUM .
  data MV_STSMA type CRM_J_STSMA .
  class-data GT_BIN_USER_STATUS type TT_BIN_USER_STATUS .

  methods LOAD_CUSTOMIZING .
private section.
ENDCLASS.



CLASS ZCL_VI02_SERVICE_COMPARTMENT IMPLEMENTATION.


  METHOD check_stsma.

    IF mv_stsma IS INITIAL.
      MESSAGE e149(/scwm/lc1) WITH mv_lgnum INTO DATA(lv_dummy).
      zcx_vi02_general_exception=>raise_sy_msg( ).
    ENDIF.

    IF mv_stsma NE co_stsma-zbinstat.
      MESSAGE e101(z_vi02_mfs) WITH mv_stsma mv_lgnum INTO lv_dummy.
      zcx_vi02_general_exception=>raise_sy_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD clear_bin_status_buffer.
    CLEAR gt_bin_user_status.
  ENDMETHOD.


  METHOD constructor.


    mv_lgnum = iv_lgnum.

    load_customizing( ).

  ENDMETHOD.


  METHOD conv_user_status_ext_2_int.

    CLEAR rv_status_int.
    CALL FUNCTION 'CRM_STATUS_TEXT_CONVERSION'
      EXPORTING
        client             = sy-mandt
        language           = co_langu_en
        mode               = 'E'
*       OBJNR              = ' '
        stsma              = mv_stsma
        txt04              = iv_status_ext
      IMPORTING
*       LANGUAGE_FOUND     =
        status_number      = rv_status_int
      EXCEPTIONS
        insufficient_input = 1
        not_found          = 2
        object_not_found   = 3
        wrong_mode         = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD conv_user_status_int_2_ext.

    clear rv_status_ext.

    CALL FUNCTION 'CRM_STATUS_NUMBER_CONVERSION'
      EXPORTING
        client             = sy-mandt
        language           = co_langu_en
*       OBJNR              = ' '
        status_number      = iv_status_int
        stsma              = mv_stsma
      IMPORTING
*       LANGUAGE_FOUND     =
        txt04              = rv_status_ext
*       TXT30              =
      EXCEPTIONS
        insufficient_input = 1
        object_not_found   = 2
        status_not_found   = 3
        stsma_not_found    = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDMETHOD.


  METHOD get_bins_4_compartment.
    DATA:
      lv_comp          TYPE numc3,
      lv_comp_base     TYPE i,
      lv_comp_in_aisle TYPE numc3,
      lv_compartment   TYPE z_vi02_de_compartment,
      lv_lgpla         TYPE /scwm/de_lgpla.

    IF iv_compartment IS INITIAL.
      RETURN.
    ENDIF.

    lv_compartment = iv_compartment.
    DATA(lv_prefix)     = split_prefix( CHANGING cv_lgpla = lv_compartment ).

    IF lv_compartment+5(2) EQ '00'.

      APPEND :
        |{ lv_prefix }{ lv_compartment(7) } { '001' }{ lv_compartment+7 }| TO rr_lgpla.
    ELSE.
      TRY.
          lv_comp_base = 1 + ( lv_compartment+5(2) ) * 5 .
        CATCH cx_root.
          CLEAR lv_comp_base.
      ENDTRY.

      lv_comp = lv_comp_base + 1.


      IF sy-sysid = 'D24'.

        TRY.
            lv_comp  = 1 + ( lv_compartment+5(2) - 1 ) * 5.
          CATCH cx_root.
            RETURN.
        ENDTRY.

        lv_comp = lv_comp + 1.
        DATA(lv_lgpla_main) = |{ lv_prefix }{ lv_compartment(5) }{ lv_comp }{ lv_compartment+7 }|.
        APPEND lv_lgpla_main TO rr_lgpla.

        "add the sub bins
        DO 5 TIMES.
          lv_comp = lv_comp + 1.
          APPEND |{ lv_lgpla_main }/{ lv_comp }| TO rr_lgpla.
        ENDDO.

        APPEND:
            |{ lv_prefix }{ lv_compartment(7) }{ 'A' }{ lv_compartment+7 }| TO rr_lgpla ,
            |{ lv_prefix }{ lv_compartment(7) }{ 'B' }{ lv_compartment+7 }| TO rr_lgpla,
            |{ lv_prefix }{ lv_compartment(7) }{ 'C' }{ lv_compartment+7 }| TO rr_lgpla.

      ELSE.

        APPEND:
           |{ lv_prefix }{ lv_compartment(7) }{ 'A' }{ lv_compartment+7 }| TO rr_lgpla,
           |{ lv_prefix }{ lv_compartment(7) }{ 'B' }{ lv_compartment+7 }| TO rr_lgpla,
           |{ lv_prefix }{ lv_compartment(7) }{ 'C' }{ lv_compartment+7 }| TO rr_lgpla.
      ENDIF.
    ENDIF.

ENDMETHOD.


  METHOD get_bin_status_from_buffer.

    CLEAR rs_bin_user_status .

    IF iv_guid_loc IS NOT INITIAL.
      rs_bin_user_status = VALUE #( gt_bin_user_status[ KEY guid_loc COMPONENTS guid_loc = iv_guid_loc ] OPTIONAL ).
    ELSE.
      rs_bin_user_status = VALUE #( gt_bin_user_status[ lgnum = iv_lgnum lgpla = iv_lgpla ] OPTIONAL ).
    ENDIF.

  ENDMETHOD.


  METHOD get_bin_status_tab.
    DATA:
      lt_lagp            TYPE /scwm/tt_lagp,
      lt_objnr           TYPE /scwm/tt_guid_loc,
      lt_stat            TYPE STANDARD TABLE OF crm_jest,
      lt_guid_loc	       TYPE /scwm/tt_guid_loc,
      lt_lgpla           TYPE /scwm/tt_lagp_key,

      ls_bin_user_status TYPE ts_bin_user_status.

    CLEAR rt_bin_user_status.

    CALL FUNCTION 'Z_VI02_COMP_BIN_STAT_REG_CLEAR'.

    IF iv_refresh_buffer IS NOT INITIAL.
*   refresh buffer data
      CALL FUNCTION '/SCWM/BIN_STATUS_REFRESH'.
      CALL FUNCTION 'CRM_STATUS_BUFFER_REFRESH'.
      clear_bin_status_buffer( ).
    ENDIF.

    lt_guid_loc = it_guid_loc.
    SORT lt_guid_loc.
    DELETE ADJACENT DUPLICATES FROM lt_guid_loc COMPARING ALL FIELDS.

    lt_lgpla = it_lgpla.
    SORT lt_lgpla.
    DELETE ADJACENT DUPLICATES FROM lt_lgpla COMPARING ALL FIELDS.

    CALL FUNCTION '/SCWM/LAGP_READ_MULTI'
      EXPORTING
        it_guid_loc   = lt_guid_loc
        it_lgpla      = lt_lgpla
      IMPORTING
        et_lagp       = lt_lagp
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        enqueue_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      zcx_vi02_general_exception=>raise_sy_msg( ).
    ELSE.
      lt_objnr = VALUE #( FOR ls_lagp_for IN lt_lagp ( guid_loc = ls_lagp_for-guid_loc ) ).
    ENDIF.

    LOOP AT lt_objnr INTO DATA(ls_objnr).
      CLEAR ls_bin_user_status.
      ls_bin_user_status = get_bin_status_from_buffer( iv_guid_loc =  ls_objnr-guid_loc  ).
      IF ls_bin_user_status IS NOT INITIAL.
        INSERT ls_bin_user_status INTO TABLE rt_bin_user_status.
        DELETE lt_objnr.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    IF lt_objnr IS NOT INITIAL.
*   fill status management buffer
      CALL FUNCTION '/SCWM/BIN_STAT_BUFFER_FILL'
        EXPORTING
          it_guid_loc = lt_objnr
        EXCEPTIONS
          error       = 1
          OTHERS      = 2.

      IF sy-subrc <> 0.
        zcx_vi02_general_exception=>raise_sy_msg( ).
      ENDIF.

*   read status of the storage bin
      CALL FUNCTION 'CRM_STATUS_READ_MULTI'
        EXPORTING
          client      = sy-mandt
          only_active = 'X'
*         ALL_IN_BUFFER        = ' '
*         GET_CHANGE_DOCUMENTS = ' '
*         NO_BUFFER_FILL       = ' '
        TABLES
          objnr_tab   = lt_objnr
          status      = lt_stat
*         jsto_tab    =
*         jcdo_tab    =
*         jcds_tab    =
        .

      SORT lt_lagp BY guid_loc.
      LOOP AT lt_stat INTO DATA(ls_stat) WHERE stat(1) EQ 'E'.

        READ TABLE lt_lagp INTO DATA(ls_lagp) WITH KEY guid_loc = ls_stat-objnr BINARY SEARCH.

        CHECK sy-subrc IS INITIAL.
        CLEAR ls_bin_user_status.
        ls_bin_user_status-lgnum      = ls_lagp-lgnum.
        ls_bin_user_status-lgpla      = ls_lagp-lgpla.
        ls_bin_user_status-guid_loc   = ls_lagp-guid_loc.
        ls_bin_user_status-status_db  = conv_user_status_int_2_ext( ls_stat-stat ).
        ls_bin_user_status-status     = ls_bin_user_status-status_db.

        INSERT ls_bin_user_status INTO TABLE rt_bin_user_status.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_compartment.
    DATA:
      lv_comp_in_aisle TYPE numc3.

    CLEAR rv_compartment.

    DATA(lv_lgpla)      = iv_lgpla.
    DATA(lv_prefix)     = split_prefix( CHANGING cv_lgpla = lv_lgpla ).
    DATA(lv_suffix)     = split_suffix( CHANGING cv_lgpla = lv_lgpla ).

    IF lv_lgpla+5(3) EQ '001'.
      rv_compartment = |{ lv_prefix }{ lv_lgpla(7) }{ lv_lgpla+8 }|.

    ELSEIF lv_lgpla+5(2) CO '1234567890'
       AND lv_lgpla+5(2) CN '0'
       AND lv_lgpla+7(1) CO 'ABC'.
      rv_compartment = |{ lv_prefix }{ lv_lgpla(7) }{ lv_lgpla+8 }|.

    ELSEIF lv_lgpla+5(3)  CO '1234567890'
      AND  lv_lgpla+5(3)  CN '0'.

      lv_comp_in_aisle  = ( lv_lgpla+5(3) + 3 ) DIV 5.
      IF lv_comp_in_aisle < 99.
        rv_compartment = |{ lv_prefix }{ lv_lgpla(5) }{ lv_comp_in_aisle(2)  ALPHA = IN  }{ lv_lgpla+8 }|.
      ENDIF.
    ENDIF.



*          IF sy-sysid = 'D24'.
*
*        rv_compartment = lv_lgpla.
*
*        "in the D24 the storage bins are created based on the old logic (only numbers)
*        "and also only first for every compartment (so to be able to test something just put 2 compartment together
*        rv_compartment(5) = iv_lgpla(5).
*        rv_compartment+5(3) = 1 + ( iv_lgpla+5(3) + 8 ) DIV 10.
*        rv_compartment+5(3) = |{ rv_compartment+5(3)  ALPHA = IN }|.
*        rv_compartment+8 = iv_lgpla+8.
*        rv_compartment = {lv_lgpla(5).
*      ELSE.
*        rv_compartment(5) = iv_lgpla(5).
*        rv_compartment+5(3) = 1 + ( iv_lgpla+5(3) + 3 ) DIV 5 + 100.
*        rv_compartment+5(3) = |{ rv_compartment+5(3)  ALPHA = IN }|.
*        rv_compartment+8 = iv_lgpla+8.
*
*      ENDIF.
  ENDMETHOD.


  METHOD get_inst.

    TRY.
        ro_service =  mt_ref_buff[ lgnum = iv_lgnum ]-o_ref.
      CATCH cx_sy_itab_line_not_found.
        ro_service = NEW zcl_vi02_service_compartment( iv_lgnum = iv_lgnum ).


        INSERT VALUE ts_ref_buff( lgnum = iv_lgnum
                                  o_ref = ro_service ) INTO TABLE  mt_ref_buff.

    ENDTRY.

  ENDMETHOD.


  METHOD get_needed_user_status.



    IF abap_true EQ  is_epal( EXPORTING iv_huident  = iv_huident
                                        iv_letyp    = iv_letyp
                                        iv_hutypgrp = iv_hutypgrp   ).
      rv_status = co_user_status-zep0.
    ELSE.
      rv_status = co_user_status-zip0.
    ENDIF.


*    DATA:
*      ls_huhdr    TYPE /scwm/s_huhdr_int,
*      lv_letyp    TYPE /scwm/de_hutyp,
*      ls_t307     TYPE /scwm/t307,
*      lv_hutypgrp TYPE /scwm/de_hutypgrp.
*
*    CLEAR rv_status.
*
*    lv_letyp    = iv_letyp.
*    lv_hutypgrp = iv_hutypgrp.
*
*    IF lv_hutypgrp IS INITIAL AND lv_letyp IS INITIAL AND iv_huident IS NOT INITIAL.
*      CALL FUNCTION '/SCWM/HU_READ'
*        EXPORTING
*          iv_appl    = wmegc_huappl_wme
*          iv_top     = abap_true
*          iv_lgnum   = mv_lgnum
*          iv_huident = iv_huident
*        IMPORTING
*          es_huhdr   = ls_huhdr
*        EXCEPTIONS
*          deleted    = 1
*          not_found  = 2
*          error      = 3
*          OTHERS     = 4.
*      IF sy-subrc IS NOT INITIAL.
*        zcx_vi02_general_exception=>raise_sy_msg( ).
*      ELSE.
*        lv_letyp    = ls_huhdr-letyp.
*        lv_hutypgrp = ls_huhdr-hutypgrp.
*      ENDIF.
*
*    ENDIF.
*
*    IF lv_hutypgrp IS INITIAL AND lv_letyp IS NOT INITIAL.
*      CALL FUNCTION '/SCWM/T307_READ_SINGLE'
*        EXPORTING
*          iv_lgnum    = mv_lgnum
*          iv_letyp    = lv_letyp
*        IMPORTING
*          es_t307     = ls_t307
*        EXCEPTIONS
*          not_found   = 1
*          wrong_input = 2
*          OTHERS      = 3.
*      IF sy-subrc <> 0.
*        zcx_vi02_general_exception=>raise_sy_msg( ).
*      ELSE.
*        lv_hutypgrp = ls_t307-hutypgrp.
*      ENDIF.
*
*    ENDIF.
*
*    IF lv_hutypgrp IN mt_rg_hutypgrp_zepo AND mt_rg_hutypgrp_zepo IS NOT INITIAL.
*      rv_status = co_user_status-zep0.
*    ELSE.
*      rv_status = co_user_status-zip0.
*    ENDIF.



  ENDMETHOD.


  METHOD is_bin_usable_for_status.
    DATA: lv_numc3      TYPE numc3,    lv_comp_place TYPE i.
    CLEAR rv_result.

    DATA(lv_lgpla)      = iv_lgpla.
    DATA(lv_prefix)     = split_prefix( CHANGING cv_lgpla = lv_lgpla ).
    DATA(lv_suffix)     = split_suffix( CHANGING cv_lgpla = lv_lgpla ).


    IF lv_lgpla+5(3) EQ '001'.
      rv_result = 'X'.
    ELSE.
      IF lv_lgpla+5(3) CO '0123456789'.

      ELSEIF lv_lgpla+5(2) CO '0123456789'
         AND lv_lgpla+7(1) CO 'ABC'.

      ENDIF.
  "    lv_comp_place = ( lv_numc3 - 2 ) MOD 5 + 1.

      CASE iv_status.
        WHEN co_user_status-zep0.
          IF lv_lgpla+7(1) CA 'ABC' OR lv_suffix  CA '135'.

            rv_result = 'X'.
          ENDIF.
        WHEN co_user_status-zip0.
          IF  lv_lgpla+7(1) CA 'AC' OR lv_suffix  CA '24'.
            rv_result = 'X'.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

      IF lv_lgpla+5(3) CO '0123456789'.

      ENDIF.
    ENDIF.
    TRY.

        IF lv_lgpla IS INITIAL.
          lv_numc3 = lv_lgpla+5(3).
        ELSE.
          lv_numc3 = iv_lgpla+7(3).
        ENDIF.
      CATCH cx_root.
        CLEAR lv_numc3.
    ENDTRY.


    CLEAR rv_result.


    IF iv_lgpla(2) EQ 'AA'
    OR iv_lgpla(2) EQ 'AC'
    OR iv_lgpla(2) EQ 'AF'.
      DATA(lv_with_prefix) = abap_true.
    ENDIF.
    TRY.
        IF lv_with_prefix IS INITIAL.
          lv_numc3 = iv_lgpla+5(3).
        ELSE.
          lv_numc3 = iv_lgpla+7(3).
        ENDIF.
      CATCH cx_root.
        CLEAR lv_numc3.
    ENDTRY.

    IF  lv_numc3 EQ '001'.
      rv_result = 'X'.
    ELSE.
      IF sy-sysid EQ 'D24'.
        IF
        lv_comp_place = ( lv_numc3 - 2 ) MOD 5 + 1.
        ELSE.

        ENDIF.
        CASE iv_status.
          WHEN co_user_status-zep0.
            IF lv_comp_place EQ 1 OR lv_comp_place EQ 3 OR lv_comp_place = 5.
              rv_result = 'X'.
            ENDIF.
          WHEN co_user_status-zip0.
            IF lv_comp_place EQ 2 OR lv_comp_place EQ 4.
              rv_result = 'X'.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ELSE.
        CASE iv_status.
          WHEN co_user_status-zep0.
            IF ( lv_with_prefix IS INITIAL AND iv_lgpla+7(1) CA 'ABC' )
            OR ( lv_with_prefix EQ 'X'     AND iv_lgpla+9(1) CA 'ABC' ).
              rv_result = 'X'.
            ENDIF.
          WHEN co_user_status-zip0.
            IF ( lv_with_prefix IS INITIAL AND iv_lgpla+7(1) CA 'AC' )
            OR ( lv_with_prefix EQ 'X'     AND iv_lgpla+9(1) CA 'AC').

              rv_result = 'X'.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

      ENDIF.
    ENDIF.



*    DATA: lv_numc3      TYPE numc3,    lv_comp_place TYPE i.
*
*    CLEAR rv_result.
*
*
*    IF iv_lgpla(2) EQ 'AA'
*    OR iv_lgpla(2) EQ 'AC'
*    OR iv_lgpla(2) EQ 'AF'.
*      DATA(lv_with_prefix) = abap_true.
*    ENDIF.
*    TRY.
*        IF lv_with_prefix IS INITIAL.
*          lv_numc3 = iv_lgpla+5(3).
*        ELSE.
*          lv_numc3 = iv_lgpla+7(3).
*        ENDIF.
*      CATCH cx_root.
*        CLEAR lv_numc3.
*    ENDTRY.
*
*    IF  lv_numc3 EQ '001'.
*      rv_result = 'X'.
*    ELSE.
*      IF sy-sysid EQ 'D24'.
*        IF
*        lv_comp_place = ( lv_numc3 - 2 ) MOD 5 + 1.
*        ELSE.
*
*        ENDIF.
*        CASE iv_status.
*          WHEN co_user_status-zep0.
*            IF lv_comp_place EQ 1 OR lv_comp_place EQ 3 OR lv_comp_place = 5.
*              rv_result = 'X'.
*            ENDIF.
*          WHEN co_user_status-zip0.
*            IF lv_comp_place EQ 2 OR lv_comp_place EQ 4.
*              rv_result = 'X'.
*            ENDIF.
*          WHEN OTHERS.
*        ENDCASE.
*      ELSE.
*        CASE iv_status.
*          WHEN co_user_status-zep0.
*            IF ( lv_with_prefix IS INITIAL AND iv_lgpla+7(1) CA 'ABC' )
*            OR ( lv_with_prefix EQ 'X'     AND iv_lgpla+9(1) CA 'ABC' ).
*              rv_result = 'X'.
*            ENDIF.
*          WHEN co_user_status-zip0.
*            IF ( lv_with_prefix IS INITIAL AND iv_lgpla+7(1) CA 'AC' )
*            OR ( lv_with_prefix EQ 'X'     AND iv_lgpla+9(1) CA 'AC').
*
*              rv_result = 'X'.
*            ENDIF.
*          WHEN OTHERS.
*        ENDCASE.
*
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD is_epal.
    DATA:
      ls_huhdr    TYPE /scwm/s_huhdr_int,
      lv_letyp    TYPE /scwm/de_hutyp,
      ls_t307     TYPE /scwm/t307,
      lv_hutypgrp TYPE /scwm/de_hutypgrp.

    CLEAR rv_result.

    lv_letyp    = iv_letyp.
    lv_hutypgrp = iv_hutypgrp.

    IF lv_hutypgrp IS INITIAL AND lv_letyp IS INITIAL AND iv_huident IS NOT INITIAL.
      CALL FUNCTION '/SCWM/HU_READ'
        EXPORTING
          iv_appl    = wmegc_huappl_wme
          iv_top     = abap_true
          iv_lgnum   = mv_lgnum
          iv_huident = iv_huident
        IMPORTING
          es_huhdr   = ls_huhdr
        EXCEPTIONS
          deleted    = 1
          not_found  = 2
          error      = 3
          OTHERS     = 4.
      IF sy-subrc IS NOT INITIAL.
        zcx_vi02_general_exception=>raise_sy_msg( ).
      ELSE.
        lv_letyp    = ls_huhdr-letyp.
        lv_hutypgrp = ls_huhdr-hutypgrp.
      ENDIF.

    ENDIF.

    IF lv_hutypgrp IS INITIAL AND lv_letyp IS NOT INITIAL.
      CALL FUNCTION '/SCWM/T307_READ_SINGLE'
        EXPORTING
          iv_lgnum    = mv_lgnum
          iv_letyp    = lv_letyp
        IMPORTING
          es_t307     = ls_t307
        EXCEPTIONS
          not_found   = 1
          wrong_input = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        zcx_vi02_general_exception=>raise_sy_msg( ).
      ELSE.
        lv_hutypgrp = ls_t307-hutypgrp.
      ENDIF.

    ENDIF.

    IF lv_hutypgrp IN mt_rg_hutypgrp_zepo AND mt_rg_hutypgrp_zepo IS NOT INITIAL.
      rv_result = 'X'.
      RETURN.
    ENDIF.



  ENDMETHOD.


  METHOD is_lgnum_relevant.

    CLEAR rv_result.

    IF mv_stsma  IS NOT INITIAL
    AND mv_stsma EQ co_stsma-zbinstat.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD is_lgtyp_relevant_chk_batch.

    CLEAR rv_result.

    IF iv_lgtyp IN mt_rg_lgtyp_check_batch AND mt_rg_lgtyp_check_batch IS NOT INITIAL.
      rv_result = abap_true.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD is_lgtyp_relevant_chk_compar.

    CLEAR rv_result.

    IF iv_lgtyp IN mt_rg_lgtyp_comparment AND mt_rg_lgtyp_comparment IS NOT INITIAL.
      rv_result = abap_true.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD load_customizing.

    DATA:
      ls_t340d TYPE /scwm/t340d.

    CALL FUNCTION '/SCWM/T340D_READ_SINGLE'
      EXPORTING
        iv_lgnum  = mv_lgnum
      IMPORTING
        es_t340d  = ls_t340d
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      "   zcx_vi02_general_exception=>raise_sy_msg( ).
    ENDIF.

    IF ls_t340d-stsma IS INITIAL.
      "      MESSAGE e149(/scwm/lc1) WITH mv_lgnum INTO DATA(lv_dummy).
      "      zcx_vi02_general_exception=>raise_sy_msg( ).
    ELSE.
      mv_stsma = ls_t340d-stsma.
    ENDIF.

    mt_rg_lgtyp_comparment = /sl0/cl_param_select=>read_const_range(
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_putaway
        iv_context    = zif_vi02_param_c=>c_context_pts_filt_sort
        iv_parameter  = zif_vi02_param_c=>c_param_lgtyp_chk_compar
    ).


    mt_rg_lgtyp_check_batch = /sl0/cl_param_select=>read_const_range(
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_putaway
        iv_context    = zif_vi02_param_c=>c_context_pts_filt_sort
        iv_parameter  = zif_vi02_param_c=>c_param_lgtyp_chk_batch
    ).


    mt_rg_hutypgrp_zepo = /sl0/cl_param_select=>read_const_range(
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_putaway
        iv_context    = zif_vi02_param_c=>c_context_pts_filt_sort
        iv_parameter  = zif_vi02_param_c=>c_param_hutypgrp_zepo
    ).

  ENDMETHOD.


  METHOD modify_ewmaddr.

    DATA:
      lv_numc3      TYPE numc3,
      lv_ccp        TYPE char03,
      lv_comp_base  TYPE i,
      lv_comp_place TYPE i.

    DATA(lv_lgpla)      = cv_lgpla.
    DATA(lv_prefix)     = split_prefix( CHANGING cv_lgpla = lv_lgpla ).


    IF iv_plc(4) = 'CRAN'.
      TRY.
          lv_numc3 = lv_lgpla+5(3).
        CATCH cx_root.
          CLEAR lv_numc3.
      ENDTRY.
    ENDIF.

    IF lv_numc3 > 1.
      lv_comp_base =  1 + ( lv_numc3 - 2 ) DIV 5.
      lv_comp_place = ( lv_numc3 - 2 ) MOD 5 + 1.

      IF sy-sysid = 'D24'.
         lv_ccp   = lv_numc3 - lv_comp_place + 1.
         cv_lgpla = |{ lv_prefix }{ lv_lgpla(5) }{ lv_ccp ALPHA = IN }{ lv_lgpla+8 }{ '/' }{ lv_comp_place }|.
      ELSE.

        IF lv_numc3 > 496.
          "cannot handle it wit ABC
        ELSE.

          lv_ccp(2)   = CONV numc2( lv_comp_base ).
          lv_ccp+2(1) = SWITCH char01( lv_comp_place WHEN 1 OR 2 THEN 'A'
                                                     WHEN 3      THEN 'B'
                                                     WHEN 4 OR 5 THEN 'C' ).

          cv_lgpla = |{ lv_prefix }{ lv_lgpla(5) }{ lv_ccp }{ lv_lgpla+8 }|.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD modify_plcaddr.

    DATA:
      lv_comp_base  TYPE i,
      lv_comp_place TYPE i.

    "we need the Storage bin type to check if it is relevant for compartments
    DATA: ls_lagp TYPE /scwm/lagp.
    CALL FUNCTION '/SCWM/LAGP_READ_SINGLE'
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_lgpla      = iv_lgpla
*       IV_NOBUF      =
*       IV_ENQ_WAIT   =
      IMPORTING
*       EV_GUID_LOC   =
        es_lagp       = ls_lagp
*       ES_LAGP_INT   =
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        enqueue_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    "Is in relevant for compartmets?
    IF abap_true EQ is_lgtyp_relevant_chk_compar( iv_lgtyp = ls_lagp-lgtyp  ).
      TRY.
          DATA(lv_epal) = is_epal( EXPORTING iv_huident = iv_huident
                                             iv_letyp   = iv_hutyp ).

        CATCH zcx_vi02_general_exception.
          " and now?
      ENDTRY.
      IF sy-sysid = 'D24'.

      ELSE.
        IF  cv_plcobj+5(2) CO '0123456789'
        AND cv_plcobj+5(2) CN '0'
        AND cv_plcobj+7(1) CA 'ABC'.
          lv_comp_base = 1 + ( cv_plcobj+5(2) - 1 ) * 5 .

          IF lv_epal EQ 'X'.
            lv_comp_place = SWITCH i( cv_plcobj+7(1) WHEN 'A' THEN 1
                                                     WHEN 'B' THEN 3
                                                     WHEN 'C' THEN 5 ).
          ELSE.
            lv_comp_place = SWITCH i( cv_plcobj+7(1) WHEN 'A' THEN 2
                                                     WHEN 'B' THEN 3 "" that is not really possible
                                                     WHEN 'C' THEN 4 ).
          ENDIF.

          cv_plcobj+5(3) = CONV numc3( lv_comp_base + lv_comp_place ).

        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD reserve_compartment.

  ENDMETHOD.


  METHOD select_compartments.

    "select storage bins for compartments
    DATA(lt_comp_lgpla_hlp) = select_comp_lgpla( it_lgtyp_rg       = it_lgtyp_rg
                                                 it_lgpla_rg       = it_lgpla_rg
                                                 it_compartment_rg = it_compartment_rg ).

    IF it_lgpla_rg IS INITIAL OR lt_comp_lgpla_hlp IS INITIAL.
      DATA(lt_comp_lgpla) = lt_comp_lgpla_hlp.
    ELSE.
      "if there was a restriction for the sprrage bin, then read it again with the detrmined compartment
      DATA(lt_compartment_rg) = VALUE rseloption( FOR ls_comp_lgpla IN lt_comp_lgpla ( sign = 'I' option = 'EQ' low = ls_comp_lgpla-compartment ) ) .

      lt_comp_lgpla = select_comp_lgpla( it_lgtyp_rg       = it_lgtyp_rg
                                         it_compartment_rg = lt_compartment_rg ).
    ENDIF.


    "check every storage bin (and mark if there are not empty)
    LOOP AT lt_comp_lgpla ASSIGNING FIELD-SYMBOL(<ls_comp_lgpla>).

      "just collect the compartment(s) in a table
      READ TABLE rt_compartment TRANSPORTING NO FIELDS
                                          WITH KEY table_line = <ls_comp_lgpla>-compartment
                                          BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO rt_compartment INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD select_comp_lgpla.

    CLEAR rt_comp_lgpla.

    DATA(lt_compartment_rg) = it_compartment_rg.
    SORT lt_compartment_rg.
    DELETE ADJACENT DUPLICATES FROM lt_compartment_rg COMPARING ALL FIELDS.

    SELECT FROM /scwm/lagp
      FIELDS lgnum, lgpla
      WHERE lgnum EQ @mv_lgnum
        AND lgtyp IN @it_lgtyp_rg
        AND lgpla IN @it_lgpla_rg
        INTO CORRESPONDING FIELDS OF TABLE @rt_comp_lgpla.

    LOOP AT rt_comp_lgpla ASSIGNING FIELD-SYMBOL(<ls_comp_lgpla>).
      <ls_comp_lgpla>-compartment = get_compartment( <ls_comp_lgpla>-lgpla ).
    ENDLOOP.

    DELETE rt_comp_lgpla WHERE compartment NOT IN lt_compartment_rg
                            OR compartment IS INITIAL.
  ENDMETHOD.


  METHOD select_empty_compartments.
    DATA:
      lt_tap                 TYPE /scwm/tt_ltap_vb,
      lt_tap_des             TYPE /scwm/tt_ltap_vb,
      lt_tap_src             TYPE /scwm/tt_ltap_vb,
      lt_lagp                TYPE /scwm/tt_lagp,
      lt_lgpla               TYPE /scwm/tt_lagp_key,
      lt_lgpla_error         TYPE /scwm/tt_lagp_key,
      lt_huitm               TYPE /scwm/tt_stock_select,
      lt_ordim_o_des         TYPE /scwm/tt_ordim_o,
      lt_ordim_o_src         TYPE /scwm/tt_ordim_o,
      lt_compartment         TYPE z_vi02_tt_compartment,
      lt_compartment_is_used TYPE z_vi02_tt_compartment.


    "select storage bins for compartments
    DATA(lt_comp_lgpla_hlp) = select_comp_lgpla( it_lgtyp_rg       = it_lgtyp_rg
                                                 it_lgpla_rg       = it_lgpla_rg
                                                 it_compartment_rg = it_compartment_rg ).

    IF it_lgpla_rg IS INITIAL OR lt_comp_lgpla_hlp IS INITIAL.
      DATA(lt_comp_lgpla) = lt_comp_lgpla_hlp.
    ELSE.
      "if there was a restriction for the storage bin, then read it again with the determined compartment
      DATA(lt_compartment_rg) = VALUE rseloption( FOR ls_comp_lgpla_hlp IN lt_comp_lgpla_hlp ( sign = 'I' option = 'EQ' low = ls_comp_lgpla_hlp-compartment ) ) .

      lt_comp_lgpla = select_comp_lgpla( it_lgtyp_rg       = it_lgtyp_rg
                                         it_compartment_rg = lt_compartment_rg ).
    ENDIF.


    IF lt_comp_lgpla IS INITIAL. "no Compartment/Storage bin?
      RETURN.
    ENDIF.

    "read Storage bins
    CALL FUNCTION '/SCWM/LAGP_READ_MULTI'
      EXPORTING
        it_lgpla       = VALUE /scwm/tt_lagp_key( FOR ls_comp_lgpla IN lt_comp_lgpla ( lgnum = ls_comp_lgpla-lgnum lgpla = ls_comp_lgpla-lgpla ) )
      IMPORTING
        et_lagp        = lt_lagp
      CHANGING
        ct_lgpla_error = lt_lgpla_error
      EXCEPTIONS
        wrong_input    = 1
        not_found      = 2
        enqueue_error  = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.

    IF lt_lagp IS INITIAL."no Storage bin?
      RETURN.
    ENDIF.

    SORT lt_lagp BY lgnum lgpla.

    "select stock (storage bin)
    CALL FUNCTION '/SCWM/SELECT_STOCK'
      EXPORTING
        iv_lgnum = mv_lgnum
        ir_lgpla = VALUE rseloption( FOR ls_lagp IN lt_lagp ( sign = 'I' option = 'EQ' low = ls_lagp-lgpla ) )
      IMPORTING
        et_huitm = lt_huitm
      EXCEPTIONS
        error    = 1
        OTHERS   = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.


    "get not saved WTs
    CALL FUNCTION '/SCWM/L_TO_GET_INFO'
      IMPORTING
        et_ltap_vb = lt_tap.

    "get open WT ( destination = storage bin )
    CLEAR lt_ordim_o_des.
    CALL FUNCTION '/SCWM/TO_READ_DES'
      EXPORTING
        iv_lgnum         = mv_lgnum
        it_lgpla         = VALUE /scwm/tt_lgpla( FOR ls_lagp IN lt_lagp ( ls_lagp-lgpla ) )
        iv_nobuf         = 'X'
        iv_add_to_memory = ' '
      IMPORTING
        et_ordim_o       = lt_ordim_o_des
      EXCEPTIONS
        wrong_input      = 1
        not_found        = 0
        foreign_lock     = 3
        OTHERS           = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.

    "get open WT ( source = storage bin )
    CLEAR lt_ordim_o_src.
    CALL FUNCTION '/SCWM/TO_READ_SRC'
      EXPORTING
        iv_lgnum         = mv_lgnum
        it_lgpla         = VALUE /scwm/tt_lgpla( FOR ls_lagp IN lt_lagp ( ls_lagp-lgpla ) )
        iv_nobuf         = 'X'
        iv_add_to_memory = ' '
      IMPORTING
        et_ordim_o       = lt_ordim_o_src
      EXCEPTIONS
        wrong_input      = 1
        not_found        = 0
        foreign_lock     = 3
        OTHERS           = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.


    "sort(s) and delete duplicates based on the storage bin (so the reads with binary search should be faster)
    SORT lt_lagp BY lgnum lgpla.

    SORT lt_lgpla_error BY lgnum lgpla.

    lt_tap_src = lt_tap.
    SORT lt_tap_src BY lgnum vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_tap_src COMPARING lgnum vlpla.
    DELETE lt_tap_src WHERE vlpla IS INITIAL.

    lt_tap_des = lt_tap.
    SORT lt_tap_des BY lgnum nlpla.
    DELETE ADJACENT DUPLICATES FROM lt_tap_des COMPARING lgnum nlpla.
    DELETE lt_tap_des WHERE nlpla IS INITIAL.


    SORT lt_ordim_o_src BY lgnum vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_ordim_o_src COMPARING lgnum vlpla.
    DELETE lt_ordim_o_src WHERE vlpla IS INITIAL.

    SORT lt_ordim_o_des BY lgnum nlpla.
    DELETE ADJACENT DUPLICATES FROM lt_ordim_o_des COMPARING lgnum nlpla.
    DELETE lt_ordim_o_des WHERE nlpla IS INITIAL.

    SORT lt_huitm BY lgnum lgpla.
    DELETE ADJACENT DUPLICATES FROM lt_huitm COMPARING lgnum lgpla.

    "check every storage bin (and mark if there are not empty)
    LOOP AT lt_comp_lgpla ASSIGNING FIELD-SYMBOL(<ls_comp_lgpla>).

      "just collect the compartment(s) in a table
      READ TABLE lt_compartment TRANSPORTING NO FIELDS
                                          WITH KEY table_line = <ls_comp_lgpla>-compartment
                                          BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment INDEX sy-tabix.
      ENDIF.

      "only do the check if the previous bin(s) of the comparment was empty)
      READ TABLE lt_compartment_is_used TRANSPORTING NO FIELDS
                                          WITH KEY table_line = <ls_comp_lgpla>-compartment
                                          BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        CONTINUE.
      ENDIF.

      "remember where we need to insert the new entry( to keep the table sorted)
      DATA(lv_tabix_not_empty) = sy-tabix.

      "is the bin was read and it has "empty" flag?
      READ TABLE lt_lagp ASSIGNING FIELD-SYMBOL(<ls_lagp>) WITH KEY lgnum = mv_lgnum
                                                                    lgpla = <ls_comp_lgpla>-lgpla
                                                                    BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL OR <ls_lagp>-kzler NE 'X'.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is the read of the bin was succesfull? (consider an error as in use )
      READ TABLE lt_lgpla_error TRANSPORTING NO FIELDS WITH KEY lgnum = mv_lgnum
                                                                lgpla = <ls_comp_lgpla>-lgpla
                                                                BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is there a non-saved WT from this storage bin?
      READ TABLE lt_tap_src TRANSPORTING NO FIELDS WITH KEY     lgnum = mv_lgnum
                                                                vlpla = <ls_comp_lgpla>-lgpla
                                                                BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is there a non-saved WT to this storage bin?
      READ TABLE lt_tap_des TRANSPORTING NO FIELDS WITH KEY     lgnum = mv_lgnum
                                                                nlpla = <ls_comp_lgpla>-lgpla
                                                                BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is there a saved WT from this storage bin?
      READ TABLE lt_ordim_o_src TRANSPORTING NO FIELDS WITH KEY lgnum = mv_lgnum
                                                                vlpla = <ls_comp_lgpla>-lgpla
                                                                BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is there a saved WT to this storage bin?
      READ TABLE lt_ordim_o_des TRANSPORTING NO FIELDS WITH KEY lgnum = mv_lgnum
                                                                nlpla = <ls_comp_lgpla>-lgpla
                                                                BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

      "is there stock on the storage bin?
      READ TABLE lt_huitm TRANSPORTING NO FIELDS WITH KEY lgnum = mv_lgnum
                                                          lgpla = <ls_comp_lgpla>-lgpla
                                                          BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        INSERT <ls_comp_lgpla>-compartment INTO lt_compartment_is_used INDEX lv_tabix_not_empty.
        CONTINUE.
      ENDIF.

    ENDLOOP.

    "filter out the the compartments which has a used bin
    LOOP AT lt_compartment ASSIGNING FIELD-SYMBOL(<lv_compartment>).
      READ TABLE lt_compartment_is_used TRANSPORTING NO FIELDS WITH KEY table_line = <lv_compartment>
                                                                          BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        APPEND <lv_compartment> TO rt_compartment.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.


  method SET_STATUSES.
  endmethod.


  METHOD split_prefix.

    CLEAR rv_prefix.

    CASE cv_lgpla(4).
      WHEN 'AF36' OR 'AC37' OR 'AA38'.

        rv_prefix = cv_lgpla(2).
        cv_lgpla  = cv_lgpla+2.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD split_suffix.

    CLEAR rv_suffix.

    DATA(lv_seppos) = strlen( cv_lgpla ) - 2.
    DATA(lv_lastpos) = strlen( cv_lgpla ) - 1.

    IF lv_seppos >= 1 AND cv_lgpla+lv_seppos(1) EQ '/'.

      rv_suffix = cv_lgpla+lv_lastpos(1).
      cv_lgpla  = cv_lgpla(lv_seppos).

    ENDIF.

  ENDMETHOD.


  METHOD update_bin_status_buffer.


    IF iv_guid_loc IS NOT INITIAL.
      ASSIGN gt_bin_user_status[ KEY guid_loc COMPONENTS guid_loc = iv_guid_loc ] TO FIELD-SYMBOL(<ls_bin_user_status>).

    ELSE.
      ASSIGN gt_bin_user_status[ lgnum = iv_lgnum lgpla = iv_lgpla  ] TO <ls_bin_user_status>.
    ENDIF.

    IF  <ls_bin_user_status> IS ASSIGNED.
      <ls_bin_user_status>-status = iv_status.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
