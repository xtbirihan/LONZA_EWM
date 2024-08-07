class ZCL_VI02_RF_DUMMY_TRANSPORT definition
  public
  final
  create protected .

public section.
  type-pools WMEGC .

  class-methods GET_INST
    returning
      value(RO_RF_DUMMY_TRANSPORT) type ref to ZCL_VI02_RF_DUMMY_TRANSPORT .
  methods VALID_HUIDENT
    importing
      !IS_VALID_PRF type /SCWM/S_VALID_PRF_EXT
      !IV_FLG_VERIFIED type XFELD
    exporting
      !EV_FLG_VERIFIED type XFELD
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT optional .
  methods VALID_LGPLA
    importing
      !IS_VALID_PRF type /SCWM/S_VALID_PRF_EXT
      !IV_FLG_VERIFIED type XFELD
    exporting
      !EV_FLG_VERIFIED type XFELD
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT optional .
  methods VALID_PMAT
    importing
      !IS_VALID_PRF type /SCWM/S_VALID_PRF_EXT
      !IV_FLG_VERIFIED type XFELD
    exporting
      !EV_FLG_VERIFIED type XFELD
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT optional .
  methods ZDTRH2_PAI
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods ZDTRH2_PBO
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods ZDTRHU_PAI
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods ZDTRHU_PBO
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
protected section.

  types:
    BEGIN OF ty_s_list ,
        value TYPE  char100,
        text  TYPE /scwm/de_rf_text,
      END OF ty_s_list .
  types:
    ty_t_list TYPE STANDARD TABLE OF  ty_s_list WITH DEFAULT KEY .

  class-data GO_SINGLETON type ref to ZCL_VI02_RF_DUMMY_TRANSPORT .
  class-data MV_LGNUM type /SCWM/LGNUM .
  data MV_MSG_BUF type STRING .
  data MT_LIST_PMAT type TY_T_LIST .
  data MT_LIST_LGPLA type TY_T_LIST .

  class-methods GET_RSRC_DATA
    returning
      value(RS_RSRC) type /SCWM/RSRC .
  class-methods INIT .
  methods CHECK_LGPLA
    importing
      !IV_CHECK_HOP type XFELD default ''
      !IV_CHECK_HOP_OCCUPIED type XFELD default ''
    changing
      !CV_LGPLA type /SCWM/DE_RF_LGPLA
    raising
      ZCX_VI02_RF .
  methods CHECK_PMAT
    changing
      !CV_PMAT type /SCWM/DE_RF_PMAT
    raising
      ZCX_VI02_RF .
  methods CONSTRUCTOR .
  methods CREATE_DUMMY_TRANSPORT_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_HUIDENT type /SCWM/DE_HUIDENT optional
      !IV_PMAT type /SCMB/MDL_PRODUCT_NO optional
      !IV_LGPLA type /SCWM/LGPLA
    exporting
      !ES_HUHDR type /SCWM/S_HUHDR_INT
    raising
      ZCX_VI02_RF .
  methods DETRM_NLPLA
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT
    raising
      ZCX_VI02_RF .
  methods GET_DEF_DATA
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods GET_LISTS
    exporting
      !ET_LIST_LGPLA type TY_T_LIST
      !ET_LIST_PMAT type TY_T_LIST
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods DETRM_PROCTY
    changing
      !CS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT
    raising
      ZCX_VI02_RF .
  methods HANDLE_ERROR
    importing
      !IX_EXCEPTION type ref to ZCX_VI02_RF
      !IV_FLG_CONTINUE_FLOW type XFELD default ABAP_TRUE
      !IV_FCODE type /SCWM/DE_FCODE
      !IV_MSG_VIEW type /SCWM/DE_MSG_VIEW default '1' .
  methods MOVE_DUMMY_TRANSPORT_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PROCTY type /SCWM/DE_PROCTY
      !IV_VLPLA type /SCWM/DE_RF_VLPLA
      !IV_NLPLA type /SCWM/DE_RF_NLPLA
    raising
      ZCX_VI02_RF .
  methods SET_DEF_DATA
    importing
      !IS_DUMMY_TRANSPORT type ZZVI02_S_RF_DUMMY_TRANSPORT .
  methods SET_LISTBOX_VALUES
    importing
      !IV_FIELDNAME type /SCWM/DE_SCRELM_NAME
      !IT_LIST type TY_T_LIST .
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF c_rf_ltrans,
        zdtr01 TYPE /scwm/de_ltrans     VALUE 'ZDTR01' ##NO_TEXT, "
        zdtr02 TYPE /scwm/de_ltrans     VALUE 'ZDTR02' ##NO_TEXT, "
        zdtr03 TYPE /scwm/de_ltrans     VALUE 'ZDTR03' ##NO_TEXT, "
        zdtr04 TYPE /scwm/de_ltrans     VALUE 'ZDTR04' ##NO_TEXT, "
        zdtr05 TYPE /scwm/de_ltrans     VALUE 'ZDTR05' ##NO_TEXT, "
      END OF c_rf_ltrans .
    CONSTANTS:
      BEGIN OF c_rf_steps ##NEEDED,
        zdtrhu TYPE /scwm/de_step VALUE 'ZDTRHU' ##NO_TEXT, "  Create HU
        zdtrh2 TYPE /scwm/de_step VALUE 'ZDTRH2' ##NO_TEXT, "  verify/move HU
      END OF c_rf_steps .
    CONSTANTS:
      BEGIN OF c_rf_fcode,
        init   TYPE /scwm/de_fcode VALUE 'INIT'  ##NO_TEXT,
        enter  TYPE /scwm/de_fcode VALUE 'ENTER'  ##NO_TEXT,
        enterf TYPE /scwm/de_fcode VALUE 'ENTERF' ##NO_TEXT,
        back   TYPE /scwm/de_fcode VALUE 'BACK'   ##NO_TEXT,
        backf  TYPE /scwm/de_fcode VALUE 'BACKF'  ##NO_TEXT,
        leave  TYPE /scwm/de_fcode VALUE 'LEAVE'  ##NO_TEXT,
        hucr   TYPE /scwm/de_fcode VALUE 'HUCR'  ##NO_TEXT,
        trnsp  TYPE /scwm/de_fcode VALUE 'TRNSP' ##NO_TEXT,
        zdtrh2 TYPE /scwm/de_fcode VALUE 'ZDTRH2' ##NO_TEXT,
      END OF c_rf_fcode .
    CONSTANTS:
      BEGIN OF c_rf_sname,
        nlpla         TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-NLPLA',
        lgpla         TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-LGPLA',
        pmat          TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-PMAT',
        rfhu          TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-RFHU',
        lastrfhu      TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-LASTRFHU',
        huident_verif TYPE /scwm/de_screlm_name VALUE 'ZZVI02_S_RF_DUMMY_TRANSPORT-HUIDENT_VERIF',

      END OF c_rf_sname .
    CONSTANTS:
      BEGIN OF c_rf_pname,
        zcs_dummy_transport TYPE /scwm/de_param_name VALUE 'ZCS_DUMMY_TRANSPORT',
      END OF c_rf_pname .
    CONSTANTS:
      BEGIN OF c_rf_memid, "Memory ID's
        zrf_def_pmat  TYPE char60 VALUE 'Z_VI02_RF_DEF_PMAT',  "Memory ID for inbound Feed
        zrf_def_lgpla TYPE char60 VALUE 'Z_VI02_RF_DEF_LGPLA', "Memory ID for pack material
      END OF c_rf_memid .
    CONSTANTS:
      BEGIN OF c_rf_parid,
        zrf_def_pmat  TYPE memoryid VALUE 'Z_VI02_RF_DEF_PMAT',  "Memory ID for inbound Feed
        zrf_def_lgpla TYPE memoryid VALUE 'Z_VI02_RF_DEF_LGPLA', "Memory ID for pack material
      END OF c_rf_parid .
ENDCLASS.



CLASS ZCL_VI02_RF_DUMMY_TRANSPORT IMPLEMENTATION.


  METHOD check_lgpla.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->CHECK_LGPLA
* Description:  Check Storage bin Input
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    DATA:
      lv_excpmsg TYPE bapi_msg.

    TRY.
        DATA(lo_bin) = NEW /sl0/cl_storage_bin( i_lgnum = mv_lgnum
                                                i_lgpla = cv_lgpla ) ##NEEDED.
      CATCH /sl0/cx_general_exception INTO DATA(lx_ewm_gen).
        zcx_vi02_rf=>raise_from_ewm_gen( lx_ewm_gen ).
    ENDTRY.

    IF iv_check_hop           IS NOT INITIAL
    OR iv_check_hop_occupied  IS NOT INITIAL.

      IF  sy-sysid EQ 'D24'.
        "no check (MFS) is not yet customized in the development system)
      ELSE.
        TRY.
            DATA: lo_log_mfs  TYPE REF TO /sl0/cl_log_mfs .

            "need to provide a dummy log instance otherwise the /SL0/HOP dumps..
            lo_log_mfs ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum     = mv_lgnum
                                                                    iv_object    = wmegc_apl_object_wme
                                                                    iv_balsubobj = wmegc_apl_subob_mfs
                                                                    io_log       = lo_log_mfs ).
            DATA(lo_hop) = NEW /sl0/cl_hop( iv_lgnum = mv_lgnum
                                            iv_lgpla = cv_lgpla
                                            io_log   = lo_log_mfs ).
            IF iv_check_hop_occupied IS NOT INITIAL AND lo_hop->hop( )-occupied = abap_false.
              "Pallet was not placed on Conveyor Infeed’
              MESSAGE e303(z_vi02_rf) INTO mv_msg_buf.
              zcx_vi02_rf=>raise_from_sy_msg( ).
            ENDIF.

          CATCH /scwm/cx_mfs INTO DATA(lx_mfs).
            CALL METHOD lx_mfs->get_text
              RECEIVING
                result = lv_excpmsg.

            MESSAGE e305(z_vi02_rf) WITH lv_excpmsg(50) lv_excpmsg+50(50) lv_excpmsg+100(50) lv_excpmsg+150(50)
              INTO mv_msg_buf.

            zcx_vi02_rf=>raise_from_sy_msg( ).
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_pmat.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->CHECK_PMAT
* Description:  Check Pack material
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA:
       lo_pmat        TYPE REF TO /sl0/cl_pack_mat.

    DATA: ls_matnr TYPE /scmb/mdl_matnr_str,
          ls_matid TYPE /scmb/mdl_matid_str ##NEEDED.


    ls_matnr-matnr = cv_pmat.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = ls_matnr-matnr
      IMPORTING
        output       = ls_matnr-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc IS NOT INITIAL.
      zcx_vi02_rf=>raise_from_sy_msg(  ).
    ENDIF.

    TRY.
        CALL FUNCTION '/SCMB/MDL_PRODUCT_READ'
          EXPORTING
            is_key  = ls_matnr
          IMPORTING
            es_data = ls_matid.

      CATCH /scmb/cx_mdl INTO DATA(lx_mdl) ##NEEDED.
        MESSAGE e304(z_vi02_rf) WITH cv_pmat INTO mv_msg_buf.
        zcx_vi02_rf=>raise_from_sy_msg( ).
    ENDTRY.

    TRY.
        CREATE OBJECT lo_pmat
          EXPORTING
            i_lgnum     = mv_lgnum
*           io_log      = mo_log
*           i_matid_r16 =
*           i_matid_c22 =
            i_matnr_c40 = cv_pmat
*           is_matpack  =
          .
      CATCH /sl0/cx_general_exception INTO DATA(lx_ewm_gen).
        zcx_vi02_rf=>raise_from_ewm_gen( lx_ewm_gen ).

    ENDTRY.

  ENDMETHOD.


  METHOD constructor.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_PUTAWAY=>CONSTRUCTOR
* Description:  Get an instance of this class
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    init( ).
  ENDMETHOD.


  METHOD create_dummy_transport_hu.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->CREATE_DUMMY_TRANSPORT_HU
* Description:  Create dummy transport HU
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    CLEAR es_huhdr.
    TRY.
        "is there any other HU still on this BIN? if that so, then it is not OK
        DATA(lt_hus_at_bin) = NEW /sl0/cl_storage_bin( i_lgnum = iv_lgnum
                                                       i_lgpla = iv_lgpla )->get_hus_on_bin( iv_sort_by_newest = abap_false ).

*    "Delete bottom HUs
*    DELETE lt_hus_at_bin WHERE top NE abap_true.

        IF lines( lt_hus_at_bin ) GT 0.
          "Get the ones which has open HU WT
          SELECT tanum, procty, vlpla, nlpla, vlenr FROM /scwm/ordim_o INTO TABLE @DATA(lt_hu_wts) FOR ALL ENTRIES IN @lt_hus_at_bin WHERE lgnum   EQ @iv_lgnum
                                                                                                          AND vlenr   EQ @lt_hus_at_bin-huident
                                                                                                          AND flghuto EQ @abap_true.
          IF lines( lt_hu_wts ) GT 0.
            "Delete the ones which has alread open HU WTs
            DELETE lt_hus_at_bin WHERE huident IN VALUE rseloption( FOR ls_hu_wts IN lt_hu_wts
                                                                              ( sign   = wmegc_sign_inclusive
                                                                                option = wmegc_option_eq
                                                                                low    = ls_hu_wts-vlenr ) ).
          ENDIF.
        ENDIF.

        IF lt_hus_at_bin IS NOT INITIAL.
          IF lt_hus_at_bin[ 1 ]-huident NE iv_huident.
            "there is still another HU on the Bin ->that's not OK
            MESSAGE e306(z_vi02_rf) WITH lt_hus_at_bin[ 1 ]-huident INTO mv_msg_buf.
            zcx_vi02_rf=>raise_from_sy_msg( ).
          ENDIF.

        ENDIF.

        DATA(ls_hu_wt) = VALUE #( lt_hu_wts[ vlenr = iv_huident ] OPTIONAL ).
        IF ls_hu_wt IS NOT INITIAL.
          MESSAGE e312(z_vi02_rf) WITH ls_hu_wt-vlenr ls_hu_wt-tanum ls_hu_wt-vlpla ls_hu_wt-nlpla  INTO mv_msg_buf.
          zcx_vi02_rf=>raise_from_sy_msg( ).
        ENDIF.

        DATA(lv_pmat)	= iv_pmat.


        IF iv_huident IS NOT INITIAL.
          "HU exists?
          /sl0/cl_hu=>is_hu_existing( EXPORTING i_lgnum    = iv_lgnum
                                                i_huident  = iv_huident
                                      IMPORTING e_existing = DATA(lv_hu_exist) ).

          IF lv_hu_exist EQ abap_true.
            DATA(lo_hu) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                          i_huident      = iv_huident
                                          i_lock         = abap_true
                                          i_read_hu_tree = abap_true ).
            DATA(ls_huhdr) = lo_hu->get_huhdr_hu( ).

            IF ls_huhdr-huident NE iv_huident.
              "HU is an underHU->  that's not OK
              MESSAGE e307(z_vi02_rf) WITH iv_huident INTO mv_msg_buf.
              zcx_vi02_rf=>raise_from_sy_msg( ).
            ENDIF.

            lo_hu->get_item_hu( EXPORTING i_guid_hu = ls_huhdr-guid_hu
                                IMPORTING et_huitm  = DATA(lt_huitm) ).
            IF lt_huitm IS NOT INITIAL.
              "HU has content ->  that's not OK
              MESSAGE e308(z_vi02_rf) WITH iv_huident INTO mv_msg_buf.
              zcx_vi02_rf=>raise_from_sy_msg( ).
            ENDIF.

            IF  lv_pmat IS INITIAL.
              lv_pmat = ls_huhdr-pmat.
            ENDIF.

            IF  iv_lgpla  EQ ls_huhdr-lgpla
            AND lv_pmat   EQ ls_huhdr-pmat.
              "if it is already on the bin then it may not be really needed to delete it,
              "but they need the label, so that's why delete it anyway
              lo_hu->delete( ).
              DATA(lv_create) = 'X'.
            ELSE.
              lo_hu->delete( ).
              lv_create = 'X'.
            ENDIF.
          ELSE.
            lv_create = 'X'.
          ENDIF.

        ELSE.
          lv_create = 'X'.
        ENDIF.

        IF lv_create EQ 'X'.
          lo_hu = NEW /sl0/cl_hu( i_create_hu    = abap_true
                                  i_lgnum        = iv_lgnum
                                  i_huident      = iv_huident
                                  i_pmat         = lv_pmat
                                  i_lgpla        = iv_lgpla
                                  i_lock         = abap_true
                                  i_read_hu_tree = abap_true ).
          es_huhdr = lo_hu->get_huhdr_hu( ).
        ELSE.
          lo_hu = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                  i_huident      = iv_huident
                                  i_lock         = abap_true
                                  i_read_hu_tree = abap_true ).
          es_huhdr = lo_hu->get_huhdr_hu( ).
        ENDIF.
      CATCH /sl0/cx_general_exception INTO DATA(lx_ewm_gen).
        zcx_vi02_rf=>raise_from_ewm_gen( ix_ewm_gen = lx_ewm_gen ).
    ENDTRY.

  ENDMETHOD.


  METHOD detrm_nlpla.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->DETRM_NLPLA
* Description:  Get/check Destination Bin from parameter framework
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    DATA lv_nlpla TYPE /scwm/de_rf_nlpla.

    DATA(lv_ltrans) = /scwm/cl_rf_bll_srvc=>get_ltrans( ).

    DATA(lv_parameter) = SWITCH /sl0/de_param_id2( lv_ltrans WHEN c_rf_ltrans-zdtr01 THEN zif_vi02_param_c=>c_param_dest_eg
                                                             WHEN c_rf_ltrans-zdtr02 THEN zif_vi02_param_c=>c_param_dest_mz
                                                             WHEN c_rf_ltrans-zdtr03 THEN zif_vi02_param_c=>c_param_dest_1og
                                                             WHEN c_rf_ltrans-zdtr04 THEN zif_vi02_param_c=>c_param_dest_2og
                                                             WHEN c_rf_ltrans-zdtr05 THEN zif_vi02_param_c=>c_param_dest_mz
                                                             ELSE space ).
    IF lv_parameter IS INITIAL.
      "No destination bin is determined for Parameter &1 (context &2/profile &3)
      MESSAGE e301(z_vi02_rf) WITH lv_ltrans INTO mv_msg_buf.
      zcx_vi02_rf=>raise_from_sy_msg( ).
    ENDIF.

    lv_nlpla = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_mfs
        iv_context    = zif_vi02_param_c=>c_context_inb_dummy_transport
        iv_parameter  = lv_parameter
    ).

    IF lv_nlpla IS INITIAL.
      "No destination bin is determined for Parameter &1 (context &2/profile &3)
      MESSAGE e302(z_vi02_rf) WITH  lv_parameter
                                    zif_vi02_param_c=>c_context_inb_dummy_transport
                                    zif_vi02_param_c=>c_prof_mfs
                              INTO  mv_msg_buf.
      zcx_vi02_rf=>raise_from_sy_msg( ).
    ENDIF.

    CALL METHOD check_lgpla
      CHANGING
        cv_lgpla = lv_nlpla.

    IF lv_nlpla IS INITIAL.

      zcx_vi02_rf=>raise_from_sy_msg( ).
    ENDIF.

    cs_dummy_transport-nlpla = lv_nlpla.
  ENDMETHOD.


  METHOD DETRM_PROCTY.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->DETRM_PROCTY
* Description:  Read the process type from the parameter framework
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA:
      lv_procty TYPE /scwm/de_procty,
      ls_t333   TYPE /scwm/t333.

    CLEAR cs_dummy_transport-procty.

    lv_procty = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = mv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_mfs
        iv_context    = zif_vi02_param_c=>c_context_inb_dummy_transport
        iv_parameter  = zif_vi02_param_c=>c_param_procty
    ).

    IF lv_procty IS INITIAL.
      MESSAGE e309(z_vi02_rf) WITH  zif_vi02_param_c=>c_param_procty
                                    zif_vi02_param_c=>c_context_inb_dummy_transport
                                    zif_vi02_param_c=>c_prof_mfs
                              INTO  mv_msg_buf.
      zcx_vi02_rf=>raise_from_sy_msg( ).
    ELSE.

      CALL FUNCTION '/SCWM/T333_READ_SINGLE'
        EXPORTING
          iv_lgnum    = mv_lgnum
          iv_procty   = lv_procty
*         IV_NOBUF    = ' '
        IMPORTING
          es_t333     = ls_t333
*         ES_T333T    =
*         ET_T333     =
*         ET_T333T    =
        EXCEPTIONS
          not_found   = 1
          wrong_input = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        zcx_vi02_rf=>raise_from_sy_msg( ).
      ENDIF.
    ENDIF.
*** further checks for the ls_t333 ***
    IF  ls_t333-trart NE wmegc_trart_put "'1'
    AND ls_t333-trart NE wmegc_trart_int. "'3'.
      MESSAGE e310(z_vi02_rf) WITH  lv_procty
                              INTO  mv_msg_buf.
      zcx_vi02_rf=>raise_from_sy_msg( ).

    ENDIF.

    cs_dummy_transport-procty = lv_procty.

  ENDMETHOD.


  METHOD get_def_data.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->GET_DEF_DATA
* Description:  Load previously entered data for the infeed and for the
*               packmaterial
*               1. from a memory ID
*               2. from a parameter ID
*               3. from the parameter frame work
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA:
      lv_def_lgpla TYPE  /scwm/de_rf_lgpla,
      lv_def_pmat  TYPE  /scwm/de_rf_pmat.

    IF cs_dummy_transport-default_loaded IS NOT INITIAL.
      RETURN.
    ENDIF.

    cs_dummy_transport-default_loaded = 'X'.

    IF cs_dummy_transport-lgpla IS INITIAL.
      DO 3 TIMES.
        CASE sy-index.
          WHEN 1.
            IMPORT def_lgpla  = lv_def_lgpla  FROM MEMORY ID c_rf_memid-zrf_def_lgpla.
          WHEN 2.
            GET PARAMETER ID c_rf_parid-zrf_def_lgpla FIELD lv_def_lgpla.
          WHEN 3.
            lv_def_lgpla = /sl0/cl_param_select=>read_const(
              EXPORTING
                iv_lgnum      = mv_lgnum
                iv_param_prof = zif_vi02_param_c=>c_prof_mfs
                iv_context    = zif_vi02_param_c=>c_context_inb_dummy_transport
                iv_parameter  = zif_vi02_param_c=>c_param_def_lgpla
            ).
          WHEN OTHERS.
            EXIT.
        ENDCASE.

        IF lv_def_lgpla IS NOT INITIAL.

          TRY.
              CALL METHOD check_lgpla
                CHANGING
                  cv_lgpla = lv_def_lgpla.
            CATCH zcx_vi02_rf.
              CLEAR lv_def_lgpla.
          ENDTRY.

        ENDIF.

        IF lv_def_lgpla IS NOT INITIAL.
          cs_dummy_transport-lgpla = lv_def_lgpla.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    IF cs_dummy_transport-pmat IS INITIAL.
      DO 3 TIMES.
        CASE sy-index.
          WHEN 1.
            IMPORT def_pmat   = lv_def_pmat   FROM MEMORY ID c_rf_memid-zrf_def_pmat.
          WHEN 2.
            GET PARAMETER ID c_rf_parid-zrf_def_pmat FIELD lv_def_pmat.
          WHEN 3.
            lv_def_pmat = /sl0/cl_param_select=>read_const(
              EXPORTING
                iv_lgnum      = mv_lgnum
                iv_param_prof = zif_vi02_param_c=>c_prof_mfs
                iv_context    = zif_vi02_param_c=>c_context_inb_dummy_transport
                iv_parameter  = zif_vi02_param_c=>c_param_def_pmat
            ).
          WHEN OTHERS.
            EXIT.
        ENDCASE.

        IF lv_def_pmat IS NOT INITIAL.
          TRY.

              CALL METHOD check_pmat
                CHANGING
                  cv_pmat = lv_def_pmat.
            CATCH zcx_vi02_rf.
              CLEAR lv_def_pmat.
          ENDTRY.
        ENDIF.
        IF lv_def_pmat IS NOT INITIAL.
          cs_dummy_transport-pmat = lv_def_pmat.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDMETHOD.


  METHOD get_inst.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT=>GET_INST
* Description:  Get an instance of this class
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    IF go_singleton IS NOT BOUND.
      go_singleton = NEW #( ).
    ENDIF.

    ro_rf_dummy_transport = go_singleton.

  ENDMETHOD.


  METHOD get_lists ##NEEDED.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->GET_LISTS
* Description:  Here would be possible to define the possible values for
*               the input fields
*               Not used at the moment (only a placeholder)
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*


  ENDMETHOD.


  METHOD get_rsrc_data.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_PUTAWAY=>GET_RSRC_DATA
* Description:  Get the resource data which is used by the user
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    CALL FUNCTION '/SCWM/RSRC_RESOURCE_MEMORY'
      EXPORTING
        iv_uname = sy-uname
      CHANGING
        cs_rsrc  = rs_rsrc.
  ENDMETHOD.


  METHOD handle_error.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->HANDLE_ERROR
* Description:  show the message from the exception and continue
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    ix_exception->get_sy_msg( ).

    /scwm/cl_rf_bll_srvc=>message( iv_flg_continue_flow = iv_flg_continue_flow
                                   iv_msgid             = ix_exception->if_t100_message~t100key-msgid
                                   iv_msgty             = ix_exception->msgty
                                   iv_msgno             = ix_exception->if_t100_message~t100key-msgno
                                   iv_msgv1             = ix_exception->msgv1
                                   iv_msgv2             = ix_exception->msgv2
                                   iv_msgv3             = ix_exception->msgv3
                                   iv_msgv4             = ix_exception->msgv4
                                   iv_msg_view          = iv_msg_view ).

    /scwm/cl_rf_bll_srvc=>set_prmod( iv_prmod    = /scwm/cl_rf_bll_srvc=>c_prmod_background
                                     iv_ovr_cust = abap_true ).
    /scwm/cl_rf_bll_srvc=>clear_fcode_bckg( ).
    /scwm/cl_rf_bll_srvc=>set_fcode( iv_fcode ).

  ENDMETHOD.


  METHOD init.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_PUTAWAY=>INIT
* Description:  Get the warehouse number from the resource
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    mv_lgnum = get_rsrc_data( )-lgnum.
  ENDMETHOD.


  METHOD move_dummy_transport_hu.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->MOVE_DUMMY_TRANSPORT_HU
* Description:  Create a WT for HU to move it towards the destination
*               and inform the user about the result (success/or error message)
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    TRY.
        DATA(lo_hu) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                      i_huident      = iv_huident
                                      i_lock         = abap_true
                                      i_read_hu_tree = abap_true ).

        DATA(ls_ordim_o) = lo_hu->get_open_hu_wt( ).
        IF ls_ordim_o IS NOT INITIAL.
          IF ls_ordim_o-vlpla   NE iv_vlpla
          OR ls_ordim_o-nlpla   NE iv_nlpla
          OR ls_ordim_o-procty  NE iv_procty.
            "Open WT &2 (&3->&4) for HU &1
            MESSAGE e312(z_vi02_rf) WITH ls_ordim_o-tanum ls_ordim_o-vlpla ls_ordim_o-nlpla ls_ordim_o-vlenr INTO mv_msg_buf.
            /sl0/cx_general_exception=>raise_system_exception( ).
          ELSE.
            "Open WT &2 (&3->&4) for HU &1
            MESSAGE s312(z_vi02_rf) WITH ls_ordim_o-tanum ls_ordim_o-vlpla ls_ordim_o-nlpla ls_ordim_o-vlenr INTO mv_msg_buf.
            /scwm/cl_rf_bll_srvc=>message( iv_flg_continue_flow = 'X'
                                           iv_msgid             = sy-msgid
                                           iv_msgty             = sy-msgty
                                           iv_msgno             = sy-msgno
                                           iv_msgv1             = sy-msgv1
                                           iv_msgv2             = sy-msgv2
                                           iv_msgv3             = sy-msgv3
                                           iv_msgv4             = sy-msgv4
                                           iv_msg_view          = '0' ).
          ENDIF.
        ELSE.
          DATA(lo_wt) = lo_hu->move(
            EXPORTING
              i_procty = iv_procty
              i_nlpla  = iv_nlpla
          ).

          "HU-WT & for & created
          MESSAGE i006(/sl0/disp) WITH      lo_wt->get_tanum( )
                                            iv_huident
                                  INTO mv_msg_buf.
          /scwm/cl_rf_bll_srvc=>message( iv_flg_continue_flow = 'X'
                                         iv_msgid             = sy-msgid
                                         iv_msgty             = sy-msgty
                                         iv_msgno             = sy-msgno
                                         iv_msgv1             = sy-msgv1
                                         iv_msgv2             = sy-msgv2
                                         iv_msgv3             = sy-msgv3
                                         iv_msgv4             = sy-msgv4
                                         iv_msg_view          = '0' ).

        ENDIF.
        "   go_log_ewm->add_message( ).
      CATCH /sl0/cx_general_exception INTO DATA(lx_ewm_gen).
        zcx_vi02_rf=>raise_from_ewm_gen( ix_ewm_gen = lx_ewm_gen ).
    ENDTRY.


  ENDMETHOD.


  METHOD set_def_data.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->SET_DEF_DATA
* Description:  Store the user input(Infeed/packmaterial) in a parameter id
*               ( and in a memory id (with it the same LUW))

*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    "   set PARAMETER ID
    IF is_dummy_transport-lgpla IS NOT INITIAL.
      EXPORT def_lgpla  = is_dummy_transport-lgpla  TO MEMORY ID c_rf_memid-zrf_def_lgpla.
      SET PARAMETER ID c_rf_parid-zrf_def_lgpla FIELD is_dummy_transport-lgpla.
    ENDIF.

    IF is_dummy_transport-pmat IS NOT INITIAL.
      EXPORT def_pmat   = is_dummy_transport-pmat   TO MEMORY ID c_rf_memid-zrf_def_pmat.
      SET PARAMETER ID c_rf_parid-zrf_def_pmat  FIELD is_dummy_transport-pmat.
    ENDIF.

  ENDMETHOD.


  METHOD set_listbox_values.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT=>SET_LISTBOX_VALUES
* Description:  Set the List Box (possible) Values for a field
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    " initialize list
    /scwm/cl_rf_bll_srvc=>init_listbox( iv_fieldname = iv_fieldname ).

    " set list
    LOOP AT it_list ASSIGNING FIELD-SYMBOL(<ls_list>).
      /scwm/cl_rf_bll_srvc=>insert_listbox(
        iv_fieldname = iv_fieldname
        iv_value     = <ls_list>-value
        iv_text      = <ls_list>-text ).
    ENDLOOP.

  ENDMETHOD.


  METHOD valid_huident.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->VALID_HUIDENT
* Description:  check that the scanned HU number is the expected one
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    FIELD-SYMBOLS: <lv_huident>       TYPE /scwm/de_rf_rfhu,
                   <lv_huident_verif> TYPE /scwm/de_rf_huident_verif.

    CLEAR ev_flg_verified.

    IF iv_flg_verified = 'X'.
      ev_flg_verified = 'X'.
      RETURN.
    ENDIF.

    IF cs_dummy_transport IS NOT INITIAL.
      IF is_valid_prf-valval_fldname IS INITIAL.

        ASSIGN COMPONENT is_valid_prf-valval_fldname
               OF STRUCTURE cs_dummy_transport TO <lv_huident>.

        ASSIGN COMPONENT is_valid_prf-valinp_fldname
               OF STRUCTURE cs_dummy_transport TO <lv_huident_verif>.
        IF <lv_huident_verif> IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lv_huident_verif>
            IMPORTING
              output = <lv_huident_verif>.

          IF <lv_huident_verif> EQ <lv_huident>.
            ev_flg_verified = 'X'.
          ELSE.
            "ev_flg_verified = 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD valid_lgpla.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->VALID_LGPLA
* Description:  check the storage bin directly after the input with
*               a validation profile otherwise it is only checked after
*               all input is entered
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    FIELD-SYMBOLS: <lv_lgpla> TYPE /scwm/de_lgpla.

    CLEAR ev_flg_verified.
    IF iv_flg_verified = 'X'.
      ev_flg_verified = 'X'.
      RETURN.
    ENDIF.

    IF cs_dummy_transport IS NOT INITIAL.
      IF is_valid_prf-valval_fldname IS INITIAL.

        ASSIGN COMPONENT is_valid_prf-valinp_fldname
               OF STRUCTURE cs_dummy_transport TO <lv_lgpla>.
        IF <lv_lgpla> IS NOT INITIAL.
          TRY.

              CALL METHOD check_lgpla
*          EXPORTING
*            iv_check_hop          = ''
*            iv_check_hop_occupied = ''
                CHANGING
                  cv_lgpla = <lv_lgpla>.
              ev_flg_verified = 'X'.
            CATCH zcx_vi02_rf.
              CLEAR <lv_lgpla>.
              ev_flg_verified = 'E'.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD valid_pmat.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->VALID_PMAT
* Description:  check the pack material directly after the input with
*               a validation profile otherwise it is only checked after
*               all input is entered
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    FIELD-SYMBOLS: <lv_pmat> TYPE /scwm/de_rf_pmat.

    CLEAR ev_flg_verified.

    IF iv_flg_verified = 'X'.
      ev_flg_verified = 'X'.
      RETURN.
    ENDIF.

    IF cs_dummy_transport IS NOT INITIAL.
      IF is_valid_prf-valval_fldname IS INITIAL.

        ASSIGN COMPONENT is_valid_prf-valinp_fldname
               OF STRUCTURE cs_dummy_transport TO <lv_pmat>.
        IF <lv_pmat> IS NOT INITIAL.
          TRY.


              CALL METHOD check_pmat
                CHANGING
                  cv_pmat = <lv_pmat>.
              ev_flg_verified = 'X'.
            CATCH zcx_vi02_rf.
              CLEAR <lv_pmat>.
              ev_flg_verified = 'E'.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zdtrh2_pai.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->ZDTRH2_PAI
* Description:  PAI for the Transfer/Move HU screen
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    BREAK-POINT ID zcg_vi02_rf_dummy_transport.

* Get actual fcode and line
    DATA(lv_fcode) = /scwm/cl_rf_bll_srvc=>get_fcode( ).

* Set process mode to foreground as default
    /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).

    TRY.
        CASE lv_fcode.
          WHEN c_rf_fcode-backf.

            CLEAR: cs_dummy_transport-rfhu,
                   cs_dummy_transport-lastrfhu,
                   cs_dummy_transport-huident_verif.

            /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
*           /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-back ).

          WHEN c_rf_fcode-enter.

            "force the creation after the HU was verified (no need to push the button)
            IF  cs_dummy_transport-huident_verif  IS NOT INITIAL.

              /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
              /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-trnsp ).
            ENDIF.

          WHEN c_rf_fcode-trnsp.

            CALL FUNCTION 'CONVERSION_EXIT_RFHU_INPUT'
              EXPORTING
                input  = cs_dummy_transport-huident_verif
              IMPORTING
                output = cs_dummy_transport-huident_verif.

            IF cs_dummy_transport-lastrfhu NE cs_dummy_transport-huident_verif.
              CLEAR cs_dummy_transport-huident_verif.
              MESSAGE e311(z_vi02_rf) INTO mv_msg_buf.
              zcx_vi02_rf=>raise_from_sy_msg( ).
            ENDIF.

            CALL METHOD move_dummy_transport_hu
              EXPORTING
                iv_lgnum   = cs_dummy_transport-lgnum
                iv_huident = CONV #( cs_dummy_transport-lastrfhu )
                iv_procty  = cs_dummy_transport-procty
                iv_vlpla   = cs_dummy_transport-lgpla
                iv_nlpla   = cs_dummy_transport-nlpla.

            /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).

            CLEAR: cs_dummy_transport-rfhu,
                   cs_dummy_transport-lastrfhu,
                   cs_dummy_transport-huident_verif.

          WHEN OTHERS.


        ENDCASE.
      CATCH zcx_vi02_rf INTO DATA(lx_vi02_rf).
        "init
        CALL METHOD handle_error
          EXPORTING
            ix_exception = lx_vi02_rf
            iv_fcode     = c_rf_fcode-init.
    ENDTRY.

  ENDMETHOD.


  METHOD zdtrh2_pbo.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->ZDTRH2_PBO
* Description:  PBO for the Transfer/Move HU screen
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    BREAK-POINT ID zcg_vi02_rf_dummy_transport.

* Initiate screen parameter
    /scwm/cl_rf_bll_srvc=>init_screen_param( ).

* Set screen parameter
    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_dummy_transport ).

    /scwm/cl_rf_bll_srvc=>set_screlm_required_on( c_rf_sname-huident_verif ).

    CLEAR cs_dummy_transport-huident_verif.
  ENDMETHOD.


  METHOD zdtrhu_pai.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->ZDTRHU_PAI
* Description:  PAI for the Create HU screen
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    BREAK-POINT ID zcg_vi02_rf_dummy_transport.

* Get actual fcode and line
    DATA(lv_fcode) = /scwm/cl_rf_bll_srvc=>get_fcode( ).

* Set process mode to foreground as default
    /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).
    TRY.
        CASE lv_fcode.
          WHEN c_rf_fcode-backf.
            CLEAR cs_dummy_transport.
            /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
            "  /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-back ).

          WHEN c_rf_fcode-enter.

            IF cs_dummy_transport-rfhu IS NOT INITIAL.
              TRY.
                  CALL METHOD /sl0/cl_hu=>is_hu_existing
                    EXPORTING
                      i_lgnum    = cs_dummy_transport-lgnum
                      i_huident  = CONV #( cs_dummy_transport-rfhu )
                    IMPORTING
                      e_existing = DATA(lv_hu_exists).
                CATCH /sl0/cx_general_exception INTO DATA(lx_gen_exc).
                  zcx_vi02_rf=>raise_from_ewm_gen( lx_gen_exc ).
              ENDTRY.
            ENDIF.

            IF  cs_dummy_transport-lgpla  IS NOT INITIAL
            AND cs_dummy_transport-rfhu   IS NOT INITIAL
            AND ( cs_dummy_transport-pmat IS NOT INITIAL OR lv_hu_exists IS NOT INITIAL ).

              /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
              /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-hucr ).
            ENDIF.

          WHEN c_rf_fcode-hucr.

            IF cs_dummy_transport-lgpla IS NOT INITIAL.

              CALL METHOD check_lgpla
                EXPORTING
                  iv_check_hop          = 'X'
                  iv_check_hop_occupied = 'X'
                CHANGING
                  cv_lgpla              = cs_dummy_transport-lgpla.

            ENDIF.

            CALL METHOD create_dummy_transport_hu
              EXPORTING
                iv_lgnum   = cs_dummy_transport-lgnum
                iv_huident = CONV #( cs_dummy_transport-rfhu )
                iv_pmat    = cs_dummy_transport-pmat
                iv_lgpla   = cs_dummy_transport-lgpla
              IMPORTING
                es_huhdr   = DATA(ls_huhdr).

            cs_dummy_transport-lastrfhu = ls_huhdr-huident.


            CALL METHOD set_def_data
              EXPORTING
                is_dummy_transport = cs_dummy_transport.

            IF cs_dummy_transport-rfhu IS INITIAL.
              /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
              /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-zdtrh2 ).
            ELSE.
              /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
              /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-trnsp ).
            ENDIF.
          WHEN c_rf_fcode-trnsp.

            CALL METHOD move_dummy_transport_hu
              EXPORTING
                iv_lgnum   = cs_dummy_transport-lgnum
                iv_huident = CONV #( cs_dummy_transport-lastrfhu )
                iv_procty  = cs_dummy_transport-procty
                iv_vlpla   = cs_dummy_transport-lgpla
                iv_nlpla   = cs_dummy_transport-nlpla.

            CLEAR: cs_dummy_transport-rfhu,
                   cs_dummy_transport-lastrfhu,
                   cs_dummy_transport-huident_verif.

          WHEN OTHERS.


        ENDCASE.
      CATCH zcx_vi02_rf INTO DATA(lx_vi02_rf).
        "just leave since it will not work without important data
        CALL METHOD handle_error
          EXPORTING
            ix_exception = lx_vi02_rf
            iv_fcode     = c_rf_fcode-init.
    ENDTRY.

  ENDMETHOD.


  METHOD zdtrhu_pbo.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_DUMMY_TRANSPORT->ZDTRHU_PAI
* Description:  PAI for the Create HU screen
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    BREAK-POINT ID zcg_vi02_rf_dummy_transport.

* Initiate screen parameter
    /scwm/cl_rf_bll_srvc=>init_screen_param( ).

* Set screen parameter
    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_dummy_transport ).

    TRY.

        cs_dummy_transport-lgnum = mv_lgnum.

        cs_dummy_transport-txt_header = SWITCH #( /scwm/cl_rf_bll_srvc=>get_ltrans( )
                                          WHEN c_rf_ltrans-zdtr01 THEN 'HU Transport to EG'(h01)
                                          WHEN c_rf_ltrans-zdtr02 THEN 'HU Transport to MZ'(h02)
                                          WHEN c_rf_ltrans-zdtr03 THEN 'HU Transport to 1.OG'(h03)
                                          WHEN c_rf_ltrans-zdtr04 THEN 'HU Transport to 2.OG'(h04)
                                          WHEN c_rf_ltrans-zdtr05 THEN 'HU Transport to MC1'(h05)
                                          ELSE space ).

        /scwm/cl_rf_bll_srvc=>set_screlm_required_on( c_rf_sname-lgpla ).

        CALL METHOD detrm_nlpla
          CHANGING
            cs_dummy_transport = cs_dummy_transport.

        CALL METHOD detrm_procty
          CHANGING
            cs_dummy_transport = cs_dummy_transport.

        CALL METHOD get_def_data
          CHANGING
            cs_dummy_transport = cs_dummy_transport.

        CALL METHOD get_lists
          IMPORTING
            et_list_lgpla      = mt_list_lgpla
            et_list_pmat       = mt_list_pmat
          CHANGING
            cs_dummy_transport = cs_dummy_transport.

        CALL METHOD set_listbox_values
          EXPORTING
            iv_fieldname = c_rf_sname-lgpla
            it_list      = mt_list_lgpla.

        CALL METHOD set_listbox_values
          EXPORTING
            iv_fieldname = c_rf_sname-pmat
            it_list      = mt_list_pmat.

      CATCH zcx_vi02_rf INTO DATA(lx_vi02_rf).
        "just leave since it will not work without important data
        CALL METHOD handle_error
          EXPORTING
            ix_exception = lx_vi02_rf
            iv_msg_view  = '0'
            iv_fcode     = c_rf_fcode-leave.

    ENDTRY.


  ENDMETHOD.
ENDCLASS.
