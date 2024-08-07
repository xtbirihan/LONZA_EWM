class ZCL_VI02_RF_SAMPLING definition
  public
  final
  create protected .

public section.

  class-methods GET_INST
    returning
      value(RO_RF_SAMPLING) type ref to ZCL_VI02_RF_SAMPLING .
  methods ZSPICK_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_VI02_RF_SAMPLING_WT type ZZS_VI02_RF_SAMPLING_WT
      !CT_VI02_RF_SAMPLING_WT type Z_T_VI02_RF_SAMPLING_WT
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSPICK_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_VI02_RF_SAMPLING_WT type ZZS_VI02_RF_SAMPLING_WT
      !CT_VI02_RF_SAMPLING_WT type Z_T_VI02_RF_SAMPLING_WT
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSPTOM_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSPTOM_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSPUTB_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSPUTB_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSSRHU_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CT_VI02_RF_SAMPLING_WT type Z_T_VI02_RF_SAMPLING_WT
      !CT_VI02_RF_SAMPLING_HU type Z_T_VI02_RF_SAMPLING_HU
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSSRHU_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSTRHU_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_VI02_RF_SAMPLING_WT type ZZS_VI02_RF_SAMPLING_WT
      !CT_VI02_RF_SAMPLING_WT type Z_T_VI02_RF_SAMPLING_WT
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSTRHU_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_VI02_RF_SAMPLING_WT type ZZS_VI02_RF_SAMPLING_WT
      !CT_VI02_RF_SAMPLING_WT type Z_T_VI02_RF_SAMPLING_WT
      !CS_SELECTION type /SCWM/S_RF_SELECTION
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSWKCR_PAI
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING
      !CS_WRKC type /SCWM/TWORKST .
  methods ZSWKCR_PBO
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING .
protected section.

  class-data GO_SINGLETON type ref to ZCL_VI02_RF_SAMPLING .
  data MV_LGNUM type /SCWM/LGNUM .
  data MX_EXC_BUF type ref to ZCX_VI02_RF .
  data MV_MSG_BUF type STRING .

  class-methods GET_RSRC_DATA
    returning
      value(RS_RSRC) type /SCWM/RSRC .
  class-methods GET_USER_DEFAULT
    changing
      !CS_VI02_RF_SAMPLING type ZZS_VI02_RF_SAMPLING .
  class-methods INIT .
  methods CONSTRUCTOR .
  methods ERROR_RESTART_TRANSACTION
    importing
      !IV_SUBRC type SYSUBRC
    changing
      !CV_PROC type CHAR1 .
  methods INITIALIZE_PACKING
    importing
      !IV_MANUAL type XFELD optional
      !IS_WRKC type /SCWM/TWORKST
    changing
      !CO_WM_PACK type ref to /SCWM/CL_WM_PACKING .
  methods SELECT_SAMPLE_WT_OR_HU
    exporting
      !ET_ORDIM_O type /SCWM/TT_ORDIM_O
      !ET_SMPL_HUHDR type /SCWM/TT_HUHDR .
PRIVATE SECTION.

  CONSTANTS:
    BEGIN OF c_rf_ltrans,
      zsabtr TYPE /scwm/de_ltrans     VALUE 'ZSABTR' ##NO_TEXT, "Sample Ambient Trigger
      zsdist TYPE /scwm/de_ltrans     VALUE 'ZSDIST' ##NO_TEXT, "Sample Distributor
      zsmalh TYPE /scwm/de_ltrans     VALUE 'ZSMALH' ##NO_TEXT, "Sample MAL Handover
      zswkst TYPE /scwm/de_ltrans     VALUE 'ZSWKST' ##NO_TEXT, "Sample WorkStation
    END OF c_rf_ltrans .
  CONSTANTS:
    BEGIN OF c_rf_steps,
      zspick TYPE /scwm/de_step VALUE 'ZSPICK' ##NO_TEXT, "  Sampling: Sample Pick
      zsputb TYPE /scwm/de_step VALUE 'ZSPUTB' ##NO_TEXT, "  Sampling: Sample Putback
      zssrhu TYPE /scwm/de_step VALUE 'ZSSRHU' ##NO_TEXT, "  Sampling: Enter Source HU
      zstrhu TYPE /scwm/de_step VALUE 'ZSTRHU' ##NO_TEXT, "  Sampling: Enter Destination Trolley
      zswkcr TYPE /scwm/de_step VALUE 'ZSWKCR' ##NO_TEXT, "  Sampling: Enter Work Center
    END OF c_rf_steps .
  CONSTANTS:
    BEGIN OF c_rf_fcode,
      enter  TYPE /scwm/de_fcode VALUE 'ENTER' ##NO_TEXT,
      enterf TYPE /scwm/de_fcode VALUE 'ENTERF' ##NO_TEXT,
      back   TYPE /scwm/de_fcode VALUE 'BACK' ##NO_TEXT,
      backf  TYPE /scwm/de_fcode VALUE 'BACKF' ##NO_TEXT,
      leave  TYPE /scwm/de_fcode VALUE 'LEAVE' ##NO_TEXT,
      zsptom TYPE /scwm/de_fcode VALUE 'ZSPTOM' ##NO_TEXT,
      zssrhu TYPE /scwm/de_fcode VALUE 'ZSSRHU' ##NO_TEXT,
      zspick TYPE /scwm/de_fcode VALUE 'ZSPICK' ##NO_TEXT,
    END OF c_rf_fcode .
  CONSTANTS:
    BEGIN OF c_rf_sname,
      workstation TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING-WORKSTATION',
      kquan_chr   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-KQUAN_CHR',
      kquan_verif TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-KQUAN_VERIF',
      batch_vrf   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-BATCH_VERIF',
      batch       TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-BATCH',
      vsola_chr   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-VSOLA_CHR',
      nlenr_vrf   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF',
      nlenr       TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-NLENR',
      rfhu        TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-RFHU',
      nista_vrf   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-NISTA_VERIF',
      matid_vrf   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-MATID_VERIF',
      ndifa_vrf   TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-NDIFA_VERIF',
      ndifa       TYPE /scwm/de_screlm_name VALUE 'ZZS_VI02_RF_SAMPLING_WT-NDIFA',
    END OF c_rf_sname .
  CONSTANTS:
    BEGIN OF c_rf_pname,
      zcs_vi02_rf_sampling    TYPE /scwm/de_param_name VALUE 'ZCS_VI02_RF_SAMPLING',
      zcs_vi02_rf_sampling_wt TYPE /scwm/de_param_name VALUE 'ZCS_VI02_RF_SAMPLING_WT',
      selection               TYPE /scwm/de_param_name VALUE 'SELECTION',
    END OF c_rf_pname .
  CONSTANTS:
    BEGIN OF c_rf_memid, "Memory ID's
      zrf_smpl_1 TYPE char10 VALUE 'ZRF_SMPL_1', "Memory ID for work center
      zrf_smpl_2 TYPE char10 VALUE 'ZRF_SMPL_2', "Memory ID for tx type of WC
    END OF c_rf_memid .
  CONSTANTS:
    BEGIN OF c_sample_workst_type ,
      both        TYPE zde_vi02_sample_workst_type VALUE IS INITIAL,
      sample_pick TYPE zde_vi02_sample_workst_type VALUE 'S',
      putback     TYPE zde_vi02_sample_workst_type VALUE 'P',
    END OF c_sample_workst_type.
  CONSTANTS:
    BEGIN OF c_sample_process_type ,
      initial     TYPE zde_vi02_sample_process_type VALUE IS INITIAL,
      sample_pick TYPE zde_vi02_sample_process_type VALUE 'S',
      putback     TYPE zde_vi02_sample_process_type VALUE 'P',
    END OF c_sample_process_type .
  CONSTANTS c_db_upd_err TYPE char01 VALUE 'E' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_VI02_RF_SAMPLING IMPLEMENTATION.


  METHOD constructor.
    init( ).
  ENDMETHOD.


  METHOD error_restart_transaction.
* restart transaction if required.
    IF iv_subrc <> 0.
      /scwm/cl_rf_bll_srvc=>set_flg_dequeue_all( ).

      /scwm/cl_rf_bll_srvc=>message(
        iv_msg_view          = '0' "Pop-up message screen '
        iv_flg_continue_flow = ' '
        iv_msgid             = '/SCWM/RF_EN'
        iv_msgty             = 'E'
        iv_msgno             = '023' ).

      cv_proc = c_db_upd_err. "'E'
    ELSE.
      cv_proc = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD get_inst.


    IF go_singleton IS NOT BOUND.
      go_singleton = NEW #( ).
    ENDIF.

    ro_rf_sampling = go_singleton.

  ENDMETHOD.


  METHOD get_rsrc_data.

    CALL FUNCTION '/SCWM/RSRC_RESOURCE_MEMORY'
      EXPORTING
        iv_uname = sy-uname
      CHANGING
        cs_rsrc  = rs_rsrc.

  ENDMETHOD.


  METHOD get_user_default.

    DATA: ls_rsrc TYPE /scwm/rsrc.

    CALL FUNCTION '/SCWM/RSRC_RESOURCE_MEMORY'
      EXPORTING
        iv_uname = sy-uname
      CHANGING
        cs_rsrc  = ls_rsrc.

    cs_vi02_rf_sampling-lgnum = ls_rsrc-lgnum.

    IF cs_vi02_rf_sampling-lgnum IS INITIAL.
      MESSAGE e010(/scwm/rf_de).
    ENDIF.

    cs_vi02_rf_sampling-rsrc = ls_rsrc-rsrc.

    CALL METHOD /scwm/cl_tm=>set_lgnum( ls_rsrc-lgnum ).

  ENDMETHOD.


  METHOD init.

  ENDMETHOD.


  METHOD initialize_packing.
    DATA: ls_pack_controle TYPE /scwm/s_pack_controle.

    DATA: lo_wm_pack TYPE REF TO /scwm/cl_wm_packing.

    IF co_wm_pack IS NOT BOUND.
      CREATE OBJECT lo_wm_pack.
      co_wm_pack = lo_wm_pack.
    ENDIF.

    ls_pack_controle-cdstgrp_mat = 'X'.
    ls_pack_controle-cdstgrp_hu = 'X'.

    ls_pack_controle-chkpack_dstgrp = COND #( WHEN iv_manual IS NOT INITIAL THEN '2' ELSE space ).


* Determine processor from sy-user in case LM is activ
    ls_pack_controle-processor_det = 'X'.


    CALL METHOD co_wm_pack->init_by_workstation
      EXPORTING
        is_workstation   = is_wrkc
        is_pack_controle = ls_pack_controle
        iv_no_hu_by_wc   = COND #( WHEN iv_manual IS INITIAL THEN 'X' ELSE space )
      EXCEPTIONS
        error            = 1
        OTHERS           = 2.

    IF sy-subrc <> 0.
      /scwm/cl_pack_view=>msg_error( ).
    ENDIF.

  ENDMETHOD.


  METHOD select_sample_wt_or_hu.

    DATA:
      lt_ordim_o      TYPE /scwm/tt_ordim_o,
      lt_sample_huhdr TYPE /scwm/tt_huhdr.


    CLEAR:  et_ordim_o,
            et_smpl_huhdr.








  ENDMETHOD.


  METHOD zspick_pai.

    DATA: lv_line                TYPE numc4,
          lv_restart_transaction TYPE xfeld VALUE IS INITIAL, "#EC NEEDED
          lv_applic              TYPE /scwm/de_applic,
          lv_pres_prf            TYPE /scwm/de_pres_prf,
          lv_ltrans              TYPE /scwm/de_ltrans,
          lv_step                TYPE /scwm/de_step,
          lv_fcode               TYPE /scwm/de_fcode,
          lv_state               TYPE /scwm/de_state,
          lv_return              TYPE sy-subrc,
          lv_flg_nest_hu         TYPE xfeld,                "#EC NEEDED
          lv_flg_mixed_hu        TYPE xfeld,                "#EC NEEDED
          lv_flg_huent_ok        TYPE xfeld,                "#EC NEEDED
          lv_field_act           TYPE text60,
          lv_hu_verif            TYPE /scwm/de_vlenr_verif,
          lv_ser_err             TYPE xfeld.

    DATA: ls_who       TYPE /scwm/who,
          ls_ordim_o   TYPE /scwm/ordim_o,
          ls_pipo      TYPE /scwm/s_rf_pipo,
          ls_huhdr     TYPE /scwm/huhdr,
          ls_huhdr_int TYPE /scwm/s_huhdr_int,
          ls_ltap      TYPE /scwm/ltap,
          ls_resource  TYPE /scwm/rsrc,
          ls_rsrc      TYPE /scwm/s_rsrc,
          ls_who_int   TYPE /scwm/s_who_int.

    DATA: lt_ordim_o   TYPE /scwm/tt_ordim_o,
          lt_valid_prf TYPE /scwm/tt_valid_prf_ext,
          lt_who       TYPE /scwm/tt_who_int.


    DATA: lo_badi TYPE REF TO /scwm/ex_rf_prt_wo_hu,
          oref    TYPE REF TO /scwm/cl_wm_packing.


    BREAK-POINT ID zcg_vi02_rf_sampling.


* Get actual fcode and line
    lv_fcode = /scwm/cl_rf_bll_srvc=>get_fcode( ).
    lv_line = /scwm/cl_rf_bll_srvc=>get_line( ).

    READ TABLE ct_vi02_rf_sampling_wt INTO cs_vi02_rf_sampling_wt INDEX lv_line.

* Set process mode to foreground as default
    /scwm/cl_rf_bll_srvc=>set_prmod(
      /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).

    CASE lv_fcode.
      WHEN OTHERS.
        " when
    ENDCASE.

  ENDMETHOD.


  METHOD zspick_pbo.
    BREAK-POINT ID zcg_vi02_rf_sampling.


    DATA: lv_field       TYPE ddobjname,
          lv_step        TYPE /scwm/de_step,
          lv_state       TYPE /scwm/de_state,
          lv_line        TYPE i,
          lv_severity    TYPE bapi_mtype,
          lv_huident     TYPE /scwm/de_huident,
          lv_vhi         TYPE /scwm/vhi,
          lv_copst       TYPE /scwm/de_copst,
          lv_top         TYPE /scwm/de_top,
          lv_text        TYPE /scwm/de_rf_text,
          lv_dstgrp_item TYPE xfeld,
          lv_pickhu      TYPE /scwm/de_rf_pickhu,
          lv_fcode       TYPE /scwm/de_fcode,
          lv_applic      TYPE /scwm/de_applic,
          lv_pres_prf    TYPE /scwm/de_pres_prf,
          lv_ltrans      TYPE /scwm/de_ltrans,
          lv_msg         TYPE bapi_msg,
          lv_empty       TYPE xfeld,
          lv_dstgrp      TYPE /scwm/de_dstgrp.

    DATA: ls_mat_global       TYPE /scwm/s_material_global,
          ls_mat_uom          TYPE /scwm/s_material_uom,
          ls_ordim_o          TYPE /scwm/ordim_o,
          ls_dfies            TYPE dfies,
          ls_valid_prf_pickhu TYPE /scwm/s_valid_prf_ext,
          ls_range_copst      TYPE rsdsselopt,
          ls_range_vhi        TYPE rsdsselopt,
          ls_range_top        TYPE rsdsselopt,
          ls_range_lgtyp      TYPE rsdsselopt,
          ls_hu_valid         TYPE /scwm/s_guid_hu,
          ls_huhdr_ship       TYPE /scwm/s_huhdr_int,
          ls_huhdr            TYPE /scwm/s_huhdr_int,
          ls_who              TYPE /scwm/who,
          ls_huhdr_x          TYPE /scwm/huhdr,
          ls_rf_pick_hus      TYPE /scwm/s_rf_pick_hus,
          ls_pickhu           TYPE /scwm/s_huident,
          ls_query_hu         TYPE /lime/query_hu_global,
          ls_bapiret          TYPE bapiret2,
          ls_range_dstgrp     TYPE rsdsselopt,
          ls_lagp             TYPE /scwm/lagp,
          ls_guid_lgpla       TYPE  /scwm/s_guid_loc.

    DATA: lt_mat_uom      TYPE /scwm/tt_material_uom,
          ls_text         TYPE /scwm/s_rf_text,
          lt_text         TYPE /scwm/tt_rf_text,
          lt_valid_prf    TYPE /scwm/tt_valid_prf_ext,
          lt_pickhu       TYPE /scwm/tt_huident,
          lt_hu_valid     TYPE /scwm/tt_guid_hu,
          lt_huitm_ship   TYPE /scwm/tt_huitm_int,
          lt_result_huhdr TYPE /scwm/tt_huhdr_int,
          lt_range_copst  TYPE rseloption,
          lt_range_vhi    TYPE rseloption,
          lt_range_top    TYPE rseloption,
          lt_range_lgtyp  TYPE rseloption,
          lt_rf_pick_hus  TYPE  /scwm/tt_rf_pick_hus,
          lt_ordim_o      TYPE /scwm/tt_ordim_o,
          lt_huitm        TYPE /scwm/tt_huitm_int,          "#EC NEEDED
          lt_lagp         TYPE /scwm/tt_lagp,
          lt_huhdr        TYPE /scwm/tt_huhdr,
          lt_query_tree   TYPE /lime/t_query_tree,
          lt_quan         TYPE /lime/t_query_quan,
          lt_bapiret      TYPE bapiret2_t,
          lt_range_dstgrp TYPE rseloption,
          lt_guid_lgpla   TYPE  /scwm/tt_guid_loc.

    DATA: lo_wm_pack          TYPE REF TO /scwm/cl_wm_packing,
          lo_badi             TYPE REF TO /scwm/ex_rf_pick_pickhu_det,
          lo_badi_lagp_filter TYPE REF TO /scwm/ex_rf_pick_lagp_filter.

    FIELD-SYMBOLS: <fs_huhdr>     TYPE /scwm/s_huhdr_int,
                   <fs_pipo>      TYPE /scwm/s_rf_pipo,
                   <fs_lagp>      TYPE /scwm/lagp,
                   <huhdr>        TYPE /scwm/huhdr,
                   <s_query_tree> TYPE /lime/query_tree.

    BREAK-POINT ID /scwm/rf_pickpoint.

* need to prepare data for current step.

* Set execution step for exception
    " cs_pipo_work-exec_step = wmegc_execstep_26.

* Initiate screen parameter
    /scwm/cl_rf_bll_srvc=>init_screen_param( ).
* Set screen parameter
    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_vi02_rf_sampling_wt ). "'CS_VI02_RF_SAMPLING_WT'
    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_vi02_rf_sampling ). "'CS_VI02_RF_SAMPLING'

* get current line.
    lv_line = /scwm/cl_rf_bll_srvc=>get_line( ).
    IF lv_line = 0.
      lv_line = 1.
      /scwm/cl_rf_bll_srvc=>set_line( lv_line ).
    ENDIF.

    READ TABLE ct_vi02_rf_sampling_wt INDEX lv_line INTO cs_vi02_rf_sampling_wt.

    CREATE OBJECT lo_wm_pack.

* check if HU exists
    CALL METHOD lo_wm_pack->get_hu
      EXPORTING
        iv_huident = cs_vi02_rf_sampling_wt-vlenr
      IMPORTING
        es_huhdr   = ls_huhdr
        et_huitm   = lt_huitm
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Read additional data (e.g. material master for description)
    TRY.
        CALL FUNCTION '/SCWM/MATERIAL_READ_SINGLE'
          EXPORTING
            iv_matid      = cs_vi02_rf_sampling_wt-matid
            iv_langu      = sy-langu
            iv_entitled   = cs_vi02_rf_sampling_wt-entitled
            iv_lgnum      = cs_vi02_rf_sampling-lgnum
          IMPORTING
            es_mat_global = ls_mat_global
            et_mat_uom    = lt_mat_uom.
      CATCH /scwm/cx_md_interface.
*       one/more parameter(s) missing
        MESSAGE e004(/scwm/rf_en) WITH cs_vi02_rf_sampling_wt-matid.
      CATCH /scwm/cx_md_material_exist.
*       Material does not exist
        MESSAGE e004(/scwm/rf_en) WITH cs_vi02_rf_sampling_wt-matid.
      CATCH /scwm/cx_md_lgnum_locid.
*       Warehouse number is not assigned to an APO Location
        MESSAGE e004(/scwm/rf_en) WITH cs_vi02_rf_sampling_wt-matid.
      CATCH /scwm/cx_md.
        MESSAGE e004(/scwm/rf_en) WITH cs_vi02_rf_sampling_wt-matid.
    ENDTRY.

*   Store original data before displaying in screen.
*   Actual data may changed after user input data.
    READ TABLE lt_mat_uom INTO ls_mat_uom
      WITH KEY meinh = ls_mat_global-meins.

    cs_vi02_rf_sampling_wt-p_brgew = ls_mat_uom-brgew.
    cs_vi02_rf_sampling_wt-p_gewei = ls_mat_uom-gewei.
    cs_vi02_rf_sampling_wt-p_volum = ls_mat_uom-volum.
    cs_vi02_rf_sampling_wt-p_voleh = ls_mat_uom-voleh.
    cs_vi02_rf_sampling_wt-p_laeng = ls_mat_uom-laeng.
    cs_vi02_rf_sampling_wt-p_breit = ls_mat_uom-breit.
    cs_vi02_rf_sampling_wt-p_hoehe = ls_mat_uom-hoehe.
    cs_vi02_rf_sampling_wt-p_meabm = ls_mat_uom-meabm.
    cs_vi02_rf_sampling_wt-maktx = ls_mat_global-maktx.
    cs_vi02_rf_sampling_wt-matnr = ls_mat_global-matnr.
    cs_vi02_rf_sampling_wt-vlenr_o = cs_vi02_rf_sampling_wt-vlenr.
    cs_vi02_rf_sampling_wt-nlpla_o = cs_vi02_rf_sampling_wt-nlpla.
    cs_vi02_rf_sampling_wt-nlenr_o = cs_vi02_rf_sampling_wt-nlenr.

* For display purpose.
    cs_vi02_rf_sampling_wt-kquan_chr = cs_vi02_rf_sampling_wt-kquan.
    cs_vi02_rf_sampling_wt-vsola_chr = cs_vi02_rf_sampling_wt-vsola.

    cs_vi02_rf_sampling_wt-cwunit = ls_mat_global-cwunit.
    cs_vi02_rf_sampling_wt-cwrel  = ls_mat_global-cwrel.

    CALL FUNCTION '/SCWM/RF_CW_IND_READ'
      EXPORTING
        iv_cwrel     = cs_vi02_rf_sampling_wt-cwrel
      IMPORTING
        ev_cwrel_ind = cs_vi02_rf_sampling_wt-cwrel_ind.

* If no remaining quantity for scraping turn display off.
    IF cs_vi02_rf_sampling_wt-kquan = 0.
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-kquan_chr ).
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-kquan_verif ).
      /scwm/cl_rf_bll_srvc=>set_screlm_input_off( c_rf_sname-kquan_verif ).
    ENDIF.
* If Material is not batch relevant turn display+verification off.
    IF ls_mat_global-batch_req IS INITIAL AND cs_vi02_rf_sampling_wt IS INITIAL.
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-batch_vrf ).
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-batch ).
      /scwm/cl_rf_bll_srvc=>set_screlm_input_off( c_rf_sname-batch_vrf ).
    ELSE.
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_off( c_rf_sname-batch ).
      IF NOT cs_vi02_rf_sampling_wt-dbind IS INITIAL AND cs_vi02_rf_sampling_wt-batch IS INITIAL.
        /scwm/cl_rf_bll_srvc=>set_screlm_input_on( c_rf_sname-batch ).
        /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-batch_vrf ).
      ENDIF.
      IF NOT ls_mat_global-batch_req IS INITIAL.
        /scwm/cl_rf_bll_srvc=>set_screlm_invisible_off( c_rf_sname-batch_vrf ).
        /scwm/cl_rf_bll_srvc=>set_screlm_input_on( c_rf_sname-batch_vrf ).

        cs_vi02_rf_sampling_wt-batch_req = 'X'.
        cs_vi02_rf_sampling_wt-batchid_o = cs_vi02_rf_sampling_wt-batchid.
        cs_vi02_rf_sampling_wt-batch_o = cs_vi02_rf_sampling_wt-batch.
      ENDIF.
    ENDIF.

* respect the pick_all functionality - change visibility of field
    IF ( cs_vi02_rf_sampling_wt-pick_all = wmegc_pick_all_no_disp ).
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-vsola_chr ).
    ENDIF.

* In case it is needed read the hazmat indicator text.
    IF NOT ls_mat_global-hazmat IS INITIAL.
      CALL FUNCTION '/SCWM/RF_HAZMAT_IND_READ'
        EXPORTING
          iv_hazmat     = ls_mat_global-hazmat
        IMPORTING
          ev_hazmat_ind = cs_vi02_rf_sampling_wt-hazmat_ind.
    ENDIF.

* Read texts (Delivery and Hazardous material)
    CALL FUNCTION '/SCWM/RF_TEXT_GET_AND_SET'
      EXPORTING
        iv_lgnum        = cs_vi02_rf_sampling_wt-lgnum
        iv_actty        = cs_vi02_rf_sampling_wt-act_type
        iv_rdoccat      = cs_vi02_rf_sampling_wt-rdoccat
        iv_rdocid       = cs_vi02_rf_sampling_wt-rdocid
        iv_ritmid       = cs_vi02_rf_sampling_wt-ritmid
        iv_matid        = cs_vi02_rf_sampling_wt-matid
        iv_rtext        = cs_vi02_rf_sampling_wt-rtext
      IMPORTING
        ev_text_ind     = cs_vi02_rf_sampling_wt-text_ind
      EXCEPTIONS
        interface_error = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF cs_vi02_rf_sampling_wt-text_ind IS NOT INITIAL.
        CLEAR: cs_vi02_rf_sampling_wt-text_scr.
        CALL METHOD /scwm/cl_rf_bll_srvc=>get_rf_text
          RECEIVING
            rt_rf_text = lt_text.
        LOOP AT lt_text INTO ls_text.
          FIND ls_text-text IN cs_vi02_rf_sampling_wt-text_scr.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.

          IF ls_text-text IS NOT INITIAL.
            IF cs_vi02_rf_sampling_wt-text_scr IS INITIAL.
              cs_vi02_rf_sampling_wt-text_scr = ls_text-text.
            ELSE.
              CONCATENATE
                 cs_vi02_rf_sampling_wt-text_scr
                 ls_text-text
                 INTO cs_vi02_rf_sampling_wt-text_scr SEPARATED BY space.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR: cs_vi02_rf_sampling_wt-text_scr.
      ENDIF.
    ENDIF.

* Fill the relevant text for screen display
    IF NOT cs_vi02_rf_sampling_wt-stock_doccat IS INITIAL.
      CALL FUNCTION '/SCWM/RF_DOCCAT_TXT_READ'
        EXPORTING
          iv_stock_doccat      = cs_vi02_rf_sampling_wt-stock_doccat
        IMPORTING
          ev_stock_doccat_text = cs_vi02_rf_sampling_wt-stock_doccat_ind.
    ENDIF.

* Clear pick_all text.
    CLEAR cs_vi02_rf_sampling_wt-pick_all_ind.

* In case it is needed read the pick all text.
    IF NOT cs_vi02_rf_sampling_wt-pick_all IS INITIAL.
      MOVE '/SCWM/DE_RF_PICK_ALL_IND' TO lv_field.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lv_field
          langu          = sy-langu
          all_types      = 'X'
        IMPORTING
          dfies_wa       = ls_dfies
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.

*   Fill in the pick all indicator text
      IF sy-subrc = 0.
*     Move short text to pick all indicator
        MOVE ls_dfies-scrtext_s TO cs_vi02_rf_sampling_wt-pick_all_ind.
      ENDIF.
    ENDIF.

    CALL FUNCTION '/SCWM/RF_SN_CHECK'
      EXPORTING
        iv_lgnum    = cs_vi02_rf_sampling_wt-lgnum
        iv_matid    = cs_vi02_rf_sampling_wt-matid
        iv_entitled = cs_vi02_rf_sampling_wt-entitled
        iv_difty    = ' '
      IMPORTING
        ev_stock    = cs_vi02_rf_sampling_wt-sn_type
*       ES_SERIAL   =
      .
* Set starting time and processor
    cs_vi02_rf_sampling_wt-processor = sy-uname.
    GET TIME STAMP FIELD cs_vi02_rf_sampling_wt-started_at.

* PARTI Indicator: Confirmation of split quantity
* X=TO remain open; blank=End confirmation;
* Only filled by exception.
    cs_vi02_rf_sampling_wt-parti = ' '.

    "   DESCRIBE TABLE ct_vi02_rf_sampling_wt LINES cs_vi02_rf_sampling-no_tot_wt.

** Fill container for application specific verification
*    CALL FUNCTION '/SCWM/RF_FILL_WME_VERIF'
*      EXPORTING
*        iv_lgnum     = cs_vi02_rf_sampling_wt-lgnum
*        iv_procty    = cs_vi02_rf_sampling_wt-procty
*        iv_trart     = cs_vi02_rf_sampling_wt-trart
*        iv_act_type  = cs_vi02_rf_sampling_wt-act_type
*        iv_aarea     = cs_vi02_rf_sampling_wt-aarea
*      IMPORTING
*        es_wme_verif = wme_verif.
*    lv_step = /scwm/cl_rf_bll_srvc=>get_step( ).
*    lv_state = /scwm/cl_rf_bll_srvc=>get_state( ).
*
*    CALL METHOD /scwm/cl_rf_bll_srvc=>get_valid_prf
*      EXPORTING
*        iv_step      = lv_step
*        iv_state     = lv_state
*      RECEIVING
*        rt_valid_prf = lt_valid_prf.
*
*    READ TABLE lt_valid_prf INTO ls_valid_prf_pickhu
*         WITH KEY param_name = 'CT_VI02_RF_SAMPLING_WT'
*                  valid_obj = 'NLENR_VERIF'.
*
*    cs_vi02_rf_sampling-last_step = lv_step.

    DATA: ls_pipo TYPE /scwm/s_rf_pipo.
    MOVE-CORRESPONDING cs_vi02_rf_sampling_wt TO ls_pipo.
* What will be shown in the list of possible pick-HUs
* If the WT contains a consolidation group:
*  - all HUs with this cons. group
*    - If the HU doesn't contain the cons. group on header level, at least one item
*      must have the cons. group
*  - all initial (empty) HUs
* If the WT contains no cons. group:
*  - all HUs with the same destination bin (based on WS fields in HUHDR)
*  - all initial (empty) HUs
*  - the HUs mustn't have a cons. group
* If a pick-HU is created during execution this HU is proposed as pick-HU

* Select HU's which can be used as destination HU.
    CALL METHOD /scwm/cl_wm_packing=>get_workcenter_bins
      EXPORTING
        is_workstation = cs_wrkc
      IMPORTING
        et_lagp        = lt_lagp
      EXCEPTIONS
        error          = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      /scwm/cl_pack_view=>msg_error( ).
    ENDIF.

* BADI to filter LAGPs
    TRY.
        GET BADI lo_badi_lagp_filter
          FILTERS
            lgnum = cs_wrkc-lgnum.

        CALL BADI lo_badi_lagp_filter->filter_lagps
          EXPORTING
            iv_lgnum = cs_wrkc-lgnum
            is_pipo  = ls_pipo
            it_lagp  = lt_lagp
          IMPORTING
            et_lagp  = lt_lagp.

      CATCH cx_badi.                                    "#EC NO_HANDLER

    ENDTRY.

* collect guids of the source bins
    LOOP AT lt_lagp INTO ls_lagp.
      ls_guid_lgpla-guid_loc = ls_lagp-guid_loc.
      APPEND ls_guid_lgpla TO lt_guid_lgpla.
    ENDLOOP.

    lv_copst = ' '.
    ls_range_copst-low  = lv_copst.
    ls_range_copst-sign   = 'I'.
    ls_range_copst-option = 'EQ'.
    APPEND ls_range_copst TO lt_range_copst.

    IF cs_vi02_rf_sampling_wt-dstgrp IS NOT INITIAL.
      lv_dstgrp = cs_vi02_rf_sampling_wt-dstgrp.
      ls_range_dstgrp-low  = lv_dstgrp.
      ls_range_dstgrp-sign   = 'I'.
      ls_range_dstgrp-option = 'EQ'.
      APPEND ls_range_dstgrp TO lt_range_dstgrp.
    ENDIF.

    lv_dstgrp = ' '.
    ls_range_dstgrp-low  = lv_dstgrp.
    ls_range_dstgrp-sign   = 'I'.
    ls_range_dstgrp-option = 'EQ'.
    APPEND ls_range_dstgrp TO lt_range_dstgrp.

    lv_vhi = ' '.
    ls_range_vhi-low  = lv_vhi.
    ls_range_vhi-sign   = 'I'.
    ls_range_vhi-option = 'EQ'.
    APPEND ls_range_vhi TO lt_range_vhi.

    lv_top = 'X'.
    ls_range_top-low  = lv_top.
    ls_range_top-sign   = 'I'.
    ls_range_top-option = 'EQ'.
    APPEND ls_range_top TO lt_range_top.

    ls_range_lgtyp-sign   = 'I'.
    ls_range_lgtyp-option = 'EQ'.
    LOOP AT lt_lagp ASSIGNING <fs_lagp>.
      READ TABLE lt_range_lgtyp WITH KEY low = <fs_lagp>-lgtyp
        TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_range_lgtyp-low = <fs_lagp>-lgtyp.
        APPEND ls_range_lgtyp TO lt_range_lgtyp.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION '/SCWM/HU_SELECT_GEN'
      EXPORTING
        iv_lgnum      = cs_wrkc-lgnum
        it_guid_lgpla = lt_guid_lgpla
        ir_lgtyp      = lt_range_lgtyp
        ir_copst      = lt_range_copst
        ir_dstgrp     = lt_range_dstgrp
        ir_vhi        = lt_range_vhi
        ir_top        = lt_range_top
      IMPORTING
        et_guid_hu    = lt_hu_valid
        e_rc_severity = lv_severity.

    IF lv_severity CA 'EA'.
      /scwm/cl_pack_view=>msg_error( ).
    ENDIF.

    MOVE-CORRESPONDING ls_pipo TO ls_ordim_o.               "#EC ENHOK

    IF lt_hu_valid IS NOT INITIAL.

*   for HUs without consolidation group check if
*   they are empty, if they are top or bottom

*   only the entry with empty dstgrp remains
      IF lines( lt_range_dstgrp ) > 1.
        DELETE lt_range_dstgrp INDEX 1.
      ENDIF.
      CALL FUNCTION '/SCWM/HU_SELECT_HUHDR'
        EXPORTING
          it_guid_hu  = lt_hu_valid
          ir_dstgrp   = lt_range_dstgrp
        IMPORTING
          et_huhdr    = lt_huhdr
        EXCEPTIONS
          wrong_input = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        /scwm/cl_pack_view=>msg_error( ).
      ENDIF.
      ls_query_hu-idx = wmegc_idx_hu.
*   remove dummy HUs and nested HUs.
      LOOP AT lt_huhdr ASSIGNING <huhdr>.
        IF <huhdr>-top IS INITIAL OR
          <huhdr>-bottom IS INITIAL OR
          <huhdr>-vhi IS NOT INITIAL.
          READ TABLE lt_hu_valid TRANSPORTING NO FIELDS WITH KEY
                      guid_hu = <huhdr>-guid_hu.
          DELETE lt_hu_valid INDEX sy-tabix.
          DELETE lt_huhdr.
          CONTINUE.
        ELSE.
          APPEND <huhdr>-guid_hu TO ls_query_hu-t_guid.
        ENDIF.
      ENDLOOP.
* now check in lime if the remaining HUs are empty.
      IF NOT ls_query_hu-t_guid IS INITIAL.
        CALL FUNCTION '/LIME/QUERY_CONTENT'
          EXPORTING
            is_hu         = ls_query_hu
          IMPORTING
            et_tree       = lt_query_tree
            et_quan       = lt_quan
            et_bapiret    = lt_bapiret
            e_rc_severity = lv_severity.
        IF lv_severity = 'E'.
          READ TABLE lt_bapiret INTO ls_bapiret WITH KEY type = 'E'.
          MESSAGE ID ls_bapiret-id
                  TYPE ls_bapiret-type
                  NUMBER ls_bapiret-number
                  WITH ls_bapiret-message_v1
                       ls_bapiret-message_v2
                       ls_bapiret-message_v3
                       ls_bapiret-message_v4
                       INTO lv_msg.
          /scwm/cl_pack_view=>msg_error( ).
        ENDIF.

*     remove those entries where the qty zero.
        DELETE lt_quan WHERE quan = 0.
        SORT lt_quan BY guid_stock guid_parent.

        LOOP AT lt_query_tree ASSIGNING <s_query_tree>.
          lv_empty = abap_true.

*       HU contains other HU -> cannot be empty.
          IF <s_query_tree>-type = wmegc_lime_type_hu.
            CLEAR lv_empty.
*       If the entry type stock, then chekc the quantity.
          ELSEIF <s_query_tree>-type = wmegc_lime_type_stock.
            READ TABLE lt_quan TRANSPORTING NO FIELDS BINARY SEARCH
                 WITH KEY guid_stock  = <s_query_tree>-guid
                          guid_parent = <s_query_tree>-guid_parent.
            IF sy-subrc = 0.
              CLEAR lv_empty.
            ENDIF.
          ENDIF.

*       If the HU is not empty, the remove it from the list.
          IF lv_empty = abap_false.
            READ TABLE lt_hu_valid TRANSPORTING NO FIELDS WITH KEY
                       guid_hu = <s_query_tree>-guid_parent.
            IF sy-subrc IS INITIAL.
              DELETE lt_hu_valid INDEX sy-tabix.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lt_hu_valid IS NOT INITIAL.
        CALL FUNCTION '/SCWM/HU_GT_FILL'
          EXPORTING
            it_guid_hu = lt_hu_valid
          IMPORTING
            et_huhdr   = lt_result_huhdr
          EXCEPTIONS
            error      = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        CLEAR lt_result_huhdr.

        LOOP AT lt_hu_valid INTO ls_hu_valid.
          CALL FUNCTION '/SCWM/HU_READ'
            EXPORTING
              iv_lock    = ' '
              iv_guid_hu = ls_hu_valid-guid_hu
              iv_lgnum   = cs_wrkc-lgnum
            IMPORTING
              es_huhdr   = ls_huhdr_ship
              et_huitm   = lt_huitm_ship
            EXCEPTIONS
              deleted    = 1
              not_found  = 2
              error      = 3
              OTHERS     = 4.
          IF sy-subrc = 0.
            CHECK ls_huhdr_ship-top IS NOT INITIAL.

            IF cs_vi02_rf_sampling_wt-dstgrp IS NOT INITIAL.
              CLEAR lv_dstgrp_item.
              IF ls_huhdr_ship-dstgrp IS INITIAL.
                READ TABLE lt_huitm_ship
                  WITH KEY dstgrp = cs_vi02_rf_sampling_wt-dstgrp
                  TRANSPORTING NO FIELDS.
                IF sy-subrc = 0.
                  lv_dstgrp_item = 'X'.
                ENDIF.
              ENDIF.
              IF ( ( ls_huhdr_ship-dstgrp IS INITIAL AND
                     ( ls_huhdr_ship-empty IS NOT INITIAL OR
                       lv_dstgrp_item IS NOT INITIAL ) ) OR
                   ( ls_huhdr_ship-dstgrp = cs_vi02_rf_sampling_wt-dstgrp ) ).
                APPEND ls_huhdr_ship TO lt_result_huhdr.
                MOVE-CORRESPONDING ls_huhdr_ship TO ls_pickhu. "#EC ENHOK
                APPEND ls_pickhu TO lt_pickhu.
                MOVE-CORRESPONDING ls_huhdr_ship TO ls_rf_pick_hus. "#EC ENHOK
                APPEND ls_rf_pick_hus TO lt_rf_pick_hus.
              ENDIF.
            ELSE.
              IF ( ( ls_huhdr_ship-empty IS NOT INITIAL ) OR
                   ( ls_huhdr_ship-wsbin = cs_vi02_rf_sampling_wt-nlpla ) ).
                IF ls_huhdr_ship-dstgrp IS INITIAL.
                  APPEND ls_huhdr_ship TO lt_result_huhdr.
                  MOVE-CORRESPONDING ls_huhdr_ship TO ls_pickhu. "#EC ENHOK
                  APPEND ls_pickhu TO lt_pickhu.
                  MOVE-CORRESPONDING ls_huhdr_ship TO ls_rf_pick_hus. "#EC ENHOK
                  APPEND ls_rf_pick_hus TO lt_rf_pick_hus.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION '/SCWM/HUENT_DET'
          EXPORTING
            is_ordim_o   = ls_ordim_o
            it_pickhu    = lt_pickhu
            iv_desc_sort = 'X'
          IMPORTING
            ev_huent     = cs_vi02_rf_sampling_wt-huent
            ev_nlenr     = cs_vi02_rf_sampling_wt-nlenr
          EXCEPTIONS
            wrong_data   = 1
            OTHERS       = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*     Special logic because /SCWM/HUENT_DET can't propose the right pick-hu
*     If HUENT is set then we take the proposed HU.
*     If proposed HU contains cons.grp. we take the proposed HU.
*     If proposed HU contains no cons.grp. we try to find one with same
*     cons.grp. from WT. If there is none we take the proposed one.
*     If there is one we take this one. This is a not empty HU.
        IF cs_vi02_rf_sampling_wt-huent IS NOT INITIAL.
          lv_pickhu = cs_vi02_rf_sampling_wt-nlenr.
        ELSE.
          IF cs_vi02_rf_sampling_wt-nlenr IS INITIAL.
            READ TABLE lt_rf_pick_hus INTO ls_rf_pick_hus
              WITH KEY dstgrp = ls_ordim_o-dstgrp.
            IF sy-subrc = 0.
              lv_pickhu = ls_rf_pick_hus-huident.
              cs_vi02_rf_sampling_wt-nlenr = ls_rf_pick_hus-huident.
            ENDIF.
          ELSE.
            READ TABLE lt_rf_pick_hus INTO ls_rf_pick_hus
              WITH KEY huident = cs_vi02_rf_sampling_wt-nlenr.
            IF ls_rf_pick_hus-dstgrp = ls_ordim_o-dstgrp.
              lv_pickhu = cs_vi02_rf_sampling_wt-nlenr.
            ELSE.
              READ TABLE lt_rf_pick_hus INTO ls_rf_pick_hus
                WITH KEY dstgrp = ls_ordim_o-dstgrp.
              IF sy-subrc = 0.
                lv_pickhu = ls_rf_pick_hus-huident.
                cs_vi02_rf_sampling_wt-nlenr = ls_rf_pick_hus-huident.
              ELSE.
                lv_pickhu = cs_vi02_rf_sampling_wt-nlenr.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

**     BADI to propose pick-hu
*        TRY.
*            GET BADI lo_badi
*              FILTERS
*                lgnum = cs_wrkc-lgnum.
*
*            lv_fcode = /scwm/cl_rf_bll_srvc=>get_fcode( ).
*            lv_applic   = /scwm/cl_rf_bll_srvc=>get_applic( ).
*            lv_pres_prf = /scwm/cl_rf_bll_srvc=>get_pres_prf( ).
*            lv_ltrans   = /scwm/cl_rf_bll_srvc=>get_ltrans( ).
*            lv_step = /scwm/cl_rf_bll_srvc=>get_step( ).
*            lv_state = /scwm/cl_rf_bll_srvc=>get_state( ).
*            MOVE-CORRESPONDING who TO ls_who.
*            MOVE-CORRESPONDING ls_huhdr TO ls_huhdr_x.      "#EC ENHOK
*
*            CLEAR ls_ordim_o.
*            LOOP AT ct_pipo ASSIGNING <fs_pipo>.
*              MOVE-CORRESPONDING <fs_pipo> TO ls_ordim_o.   "#EC ENHOK
*              APPEND ls_ordim_o TO lt_ordim_o.
*            ENDLOOP.
*
*            CALL BADI lo_badi->propose
*              EXPORTING
*                iv_lgnum    = cs_wrkc-lgnum
*                iv_applic   = lv_applic
*                iv_pres_prf = lv_pres_prf
*                iv_ltrans   = lv_ltrans
*                iv_step     = lv_step
*                iv_fcode    = lv_fcode
*                iv_state    = lv_state
*                is_who      = ls_who
*                it_ordim_o  = lt_ordim_o
*                is_huhdr    = ls_huhdr_x
*                it_pick_hus = lt_rf_pick_hus
*                iv_pickhu   = lv_pickhu
*              IMPORTING
*                ev_pickhu   = lv_pickhu.
*
*            cs_vi02_rf_sampling_wt-nlenr = lv_pickhu.
*
*          CATCH cx_badi.                                "#EC NO_HANDLER
*
*        ENDTRY.

        CALL METHOD /scwm/cl_rf_bll_srvc=>init_listbox
          EXPORTING
            iv_fieldname = c_rf_sname-nlenr_vrf. " 'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'

        LOOP AT lt_result_huhdr ASSIGNING <fs_huhdr>.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = <fs_huhdr>-huident
            IMPORTING
              output = lv_huident.

          IF <fs_huhdr>-dstgrp IS NOT INITIAL.
            CONCATENATE lv_huident <fs_huhdr>-dstgrp INTO lv_text
              SEPARATED BY ' / '.
          ELSE.
            lv_text = lv_huident.
          ENDIF.
*       Build text HU with DSPGRP or with EMPTY indicator
          IF <fs_huhdr>-empty IS NOT INITIAL.
            MOVE '/SCWM/DE_RF_EMPTY' TO lv_field.
            CALL FUNCTION 'DDIF_FIELDINFO_GET'
              EXPORTING
                tabname        = lv_field
                langu          = sy-langu
                all_types      = 'X'
              IMPORTING
                dfies_wa       = ls_dfies
              EXCEPTIONS
                not_found      = 1
                internal_error = 2
                OTHERS         = 3.

*         Fill in the empty indicator text
            IF sy-subrc = 0.
*           Move short text to F8 list text
              CONCATENATE lv_text ls_dfies-scrtext_m INTO lv_text
              SEPARATED BY ' / '.
            ENDIF.
          ENDIF.

          IF cs_vi02_rf_sampling_wt-nlenr IS NOT INITIAL.
            CALL METHOD /scwm/cl_rf_bll_srvc=>insert_listbox
              EXPORTING
                iv_fieldname      = c_rf_sname-nlenr_vrf  "'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'
                iv_value          = <fs_huhdr>-huident
                iv_text           = lv_text
                iv_add_dest_field = c_rf_sname-nlenr. "  'ZZS_VI02_RF_SAMPLING_WT-NLENR'.
          ELSE.
            CALL METHOD /scwm/cl_rf_bll_srvc=>insert_listbox
              EXPORTING
                iv_fieldname      = c_rf_sname-nlenr "'ZZS_VI02_RF_SAMPLING_WT-NLENR'
                iv_value          = <fs_huhdr>-huident
                iv_text           = lv_text
                iv_add_dest_field = c_rf_sname-nlenr_vrf. "'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_hu_valid IS INITIAL.
      CALL FUNCTION '/SCWM/HUENT_DET'
        EXPORTING
          is_ordim_o   = ls_ordim_o
          it_pickhu    = lt_pickhu
          iv_desc_sort = 'X'
        IMPORTING
          ev_huent     = cs_vi02_rf_sampling_wt-huent
          ev_nlenr     = cs_vi02_rf_sampling_wt-nlenr
        EXCEPTIONS
          wrong_data   = 1
          OTHERS       = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

* If pick-HU (destination HU) is empty, open field and close validation.
    IF cs_vi02_rf_sampling_wt-nlenr IS INITIAL.
*     Set input on and verifcation off
      /scwm/cl_rf_bll_srvc=>set_screlm_input_off( c_rf_sname-nlenr_vrf ). " 'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_on( c_rf_sname-nlenr_vrf ). "'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'
      /scwm/cl_rf_bll_srvc=>set_screlm_input_on( c_rf_sname-nlenr ). " 'ZZS_VI02_RF_SAMPLING_WT-NLENR' ).
      cs_vi02_rf_sampling_wt-flg_nlenr_needed = 'X'.
    ELSE.
*     Set input off and verifcation on
      /scwm/cl_rf_bll_srvc=>set_screlm_input_on( c_rf_sname-nlenr_vrf ). " 'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'
      /scwm/cl_rf_bll_srvc=>set_screlm_invisible_off( c_rf_sname-nlenr_vrf ). " 'ZZS_VI02_RF_SAMPLING_WT-NLENR_VERIF'
      /scwm/cl_rf_bll_srvc=>set_screlm_input_off( c_rf_sname-nlenr ). " 'ZZS_VI02_RF_SAMPLING_WT-NLENR' ).
    ENDIF.

    MODIFY ct_vi02_rf_sampling_wt FROM cs_vi02_rf_sampling_wt INDEX lv_line.


  ENDMETHOD.


  METHOD zsptom_pai.

    BREAK-POINT ID zcg_vi02_rf_sampling.

* Get actual fcode and line
    DATA(lv_fcode) = /scwm/cl_rf_bll_srvc=>get_fcode( ).

* Set process mode to foreground as default
    /scwm/cl_rf_bll_srvc=>set_prmod(
      /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).

    CASE lv_fcode.
      WHEN c_rf_fcode-backf
        OR c_rf_fcode-enter.
        /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
        /scwm/cl_rf_bll_srvc=>set_fcode( /scwm/cl_rf_bll_srvc=>c_fcode_compl_ltrans ).
      WHEN OTHERS.

        " when
    ENDCASE.

  ENDMETHOD.


  METHOD zsptom_pbo.

    BREAK-POINT ID zcg_vi02_rf_sampling.

* Initiate screen parameter
    /scwm/cl_rf_bll_srvc=>init_screen_param( ).
* Set screen parameter
    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_vi02_rf_sampling ). "'CS_VI02_RF_SAMPLING'

  ENDMETHOD.


  METHOD zsputb_pai.
    BREAK-POINT ID zcg_vi02_rf_sampling.

* Get actual fcode and line
    DATA(lv_fcode) = /scwm/cl_rf_bll_srvc=>get_fcode( ).

* Set process mode to foreground as default
    /scwm/cl_rf_bll_srvc=>set_prmod(
      /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).

    CASE lv_fcode.
      WHEN c_rf_fcode-backf.

      WHEN c_rf_fcode-enter.

      WHEN OTHERS.

        " when
    ENDCASE.
  ENDMETHOD.


  METHOD zsputb_pbo.
    BREAK-POINT ID zcg_vi02_rf_sampling.
  ENDMETHOD.


  METHOD zssrhu_pai.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_SAMPLING->ZSSRHU_PBO
* Description:  PBO for (Source) HU selection
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA: lv_severity     TYPE bapi_mtype,
          lv_lsd          TYPE /scwm/de_lsd,
          lv_wcr          TYPE /scwm/de_wcr,
          lv_type         TYPE /scwm/de_wcrtype,
          lv_proc         TYPE char1,
          lv_check_hu_wt  TYPE char1,
          lv_fcode        TYPE /scwm/de_fcode,
          lv_new_sel      TYPE char1,
          lv_lines_who    TYPE i,
          lv_lines_o      TYPE i,
          lv_lines_o_who  TYPE i,
          lv_rebundle     TYPE char1,
          lv_flg_nest_hu  TYPE xfeld VALUE IS INITIAL,
          lv_flg_mixed_hu TYPE xfeld VALUE IS INITIAL,      "#EC NEEDED
          lv_flg_huent_ok TYPE xfeld VALUE IS INITIAL,
          lv_hu_verif     TYPE /scwm/de_vlenr_verif,
          lv_applic       TYPE /scwm/de_applic,
          lv_ltrans       TYPE /scwm/de_ltrans,
          lv_work_who     TYPE /scwm/de_who.

    DATA: ls_ordim_o    TYPE /scwm/ordim_o,
          ls_tanum      TYPE rsdsselopt,
          ls_whoid      TYPE /scwm/s_whoid,
          ls_bapiret    TYPE bapiret2,
          ls_who        TYPE /scwm/s_who_int,
          ls_pipo       TYPE /scwm/s_rf_pipo,
          ls_huhdr      TYPE /scwm/s_huhdr_int,
          ls_conf       TYPE /scwm/to_conf,
          ls_lagp_key   TYPE /scwm/s_lagp_key,
          ls_rsrc       TYPE /scwm/rsrc,
          ls_wo_rsrc_ty TYPE /scwm/wo_rsrc_ty.

    DATA: lt_ordim_o     TYPE /scwm/tt_ordim_o,
          lt_ordim_o_who TYPE /scwm/tt_ordim_o,
          lt_tanum       TYPE rseloption,
          lt_whoid       TYPE /scwm/tt_whoid,
          lt_who         TYPE /scwm/tt_who_int,
          lt_who_old     TYPE /scwm/tt_who_int,
          lt_bapiret     TYPE bapirettab,
          lt_huhdr       TYPE /scwm/tt_huhdr_int,           "#EC NEEDED
          lt_huitm       TYPE /scwm/tt_huitm_int,           "#EC NEEDED
          lt_conf        TYPE /scwm/to_conf_tt,
          lt_lgpla_read  TYPE /scwm/tt_lagp_key,
          lt_lgpla       TYPE rseloption,
          lt_wo_rsrc_ty  TYPE /scwm/tt_wo_rsrc_ty.

    DATA: lo_wm_pack TYPE REF TO /scwm/cl_wm_packing,
          lo_log     TYPE REF TO /scwm/cl_log.

    FIELD-SYMBOLS: <who>      TYPE /scwm/s_who_int,
                   <wa_lgpla> TYPE rsdsselopt.

    DATA: ls_vi02_rf_sampling_wt  TYPE zzs_vi02_rf_sampling_wt.
    BREAK-POINT ID zcg_vi02_rf_sampling.

    lv_fcode = /scwm/cl_rf_bll_srvc=>get_fcode( ).

    IF lv_fcode = c_rf_fcode-backf.
      /scwm/cl_rf_bll_srvc=>set_prmod(
        /scwm/cl_rf_bll_srvc=>c_prmod_background ).
      "      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-leave ).
      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-back ).
      RETURN.
    ENDIF.

    IF cs_selection-rfhu IS INITIAL.
      MESSAGE e074(/scwm/rf_en).
    ENDIF.

* Prüfen ob eingegebene HU am Workcenter steht
*   get instance and initialize log
    initialize_packing(
      EXPORTING
        iv_manual  = 'X'
        is_wrkc    = cs_wrkc
      CHANGING
        co_wm_pack = lo_wm_pack ).


    cs_selection-huident = cs_selection-rfhu.

    IF sy-sysid EQ 'D24'.
      DO 3 TIMES.
        CLEAR ls_vi02_rf_sampling_wt.
        ls_vi02_rf_sampling_wt-lgnum = cs_vi02_rf_sampling-lgnum.
        ls_vi02_rf_sampling_wt-tanum = sy-index.
        ls_vi02_rf_sampling_wt-matnr = 'MAT1'.
        ls_vi02_rf_sampling_wt-batch = 'BATCH1'.
        APPEND ls_vi02_rf_sampling_wt TO ct_vi02_rf_sampling_wt .
      ENDDO.
      RETURN.
    ENDIF.
* check if HU exists
    CALL METHOD lo_wm_pack->get_hu
      EXPORTING
        iv_huident = cs_selection-huident
        iv_nlevel  = 'X'
      IMPORTING
        et_huitm   = lt_huitm
        es_huhdr   = ls_huhdr
        et_huhdr   = lt_huhdr
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* get all bins of work center
    CALL METHOD /scwm/cl_wm_packing=>get_workcenter_bins
      EXPORTING
        is_workstation = cs_wrkc
      IMPORTING
        et_lgpla       = lt_lgpla
      EXCEPTIONS
        error          = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_lgpla ASSIGNING <wa_lgpla>.
      ls_lagp_key-lgpla = <wa_lgpla>-low.
      ls_lagp_key-lgnum = cs_wrkc-lgnum.
      APPEND ls_lagp_key TO lt_lgpla_read.
    ENDLOOP.

    CLEAR lv_check_hu_wt.
    READ TABLE lt_lgpla_read
      WITH KEY lgnum = cs_vi02_rf_sampling-lgnum
               lgpla = ls_huhdr-lgpla
      TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      IF ls_huhdr-flgmove IS INITIAL.
        MESSAGE e208(/scwm/rf_en) WITH cs_selection-huident cs_vi02_rf_sampling-workstation.
      ELSE.
        lv_check_hu_wt = 'X'.
      ENDIF.
    ENDIF.

    DO.
*   Read all open WT with the entered HU as source HU.
      CALL FUNCTION '/SCWM/TO_READ_HU'
        EXPORTING
          iv_lgnum       = cs_vi02_rf_sampling-lgnum
          iv_huident     = cs_selection-huident
        IMPORTING
          et_ordim_o_src = lt_ordim_o
        EXCEPTIONS
          error          = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CLEAR lv_new_sel.

*   Delete all "inactiv" TOs
      LOOP AT lt_ordim_o INTO ls_ordim_o.
        IF ls_ordim_o-tostat = wmegc_to_inactiv.
          DELETE lt_ordim_o INDEX sy-tabix.
          CONTINUE.
        ENDIF.
*     Check if all WT's are picking-WT or internal-WT
        IF ls_ordim_o-trart <> wmegc_trart_pick AND
           ls_ordim_o-trart <> wmegc_trart_int.
          DELETE lt_ordim_o INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        IF lv_check_hu_wt IS NOT INITIAL.
          IF ls_ordim_o-flghuto = 'X' AND ls_ordim_o-vlenr = cs_selection-huident.
            READ TABLE lt_lgpla_read
              WITH KEY lgnum = cs_vi02_rf_sampling-lgnum
                       lgpla = ls_ordim_o-nlpla
              TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              CLEAR lv_check_hu_wt.

*           We found an open HU-WT to the pick point.
*           We confirm it because the HU already arrived.
              MOVE-CORRESPONDING ls_ordim_o TO ls_conf.     "#EC ENHOK
              MOVE 'X' TO ls_conf-squit.

              APPEND ls_conf TO lt_conf.
              CALL FUNCTION '/SCWM/TO_CONFIRM'
                EXPORTING
                  iv_lgnum         = cs_wrkc-lgnum
                  iv_qname         = sy-uname
                  it_conf          = lt_conf
                  iv_processor_det = 'X'
                IMPORTING
                  ev_severity      = lv_severity
                  et_bapiret       = lt_bapiret.
              IF lv_severity CA 'EA'.
                lo_wm_pack->go_log->add_log( it_prot = lt_bapiret ).
                /scwm/cl_pack_view=>msg_error( ).
              ELSE.
                COMMIT WORK AND WAIT.
                CALL METHOD /scwm/cl_tm=>cleanup( ).

                initialize_packing(
                  EXPORTING
                    iv_manual  = 'X'
                    is_wrkc    = cs_wrkc
                  CHANGING
                    co_wm_pack = lo_wm_pack ).

                lv_new_sel = 'X'.
                EXIT.                "#EC CI_NOORDER   "LOOP lt_ordim_o
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        IF ls_ordim_o-flghuto IS INITIAL.  "Only product-WT are valid
          MOVE: ls_ordim_o-tanum TO ls_tanum-low,
                'I'              TO ls_tanum-sign,
                'EQ'             TO ls_tanum-option.

          COLLECT ls_tanum INTO lt_tanum.

          ls_whoid-who = ls_ordim_o-who.
          COLLECT ls_whoid INTO lt_whoid.
        ENDIF.

      ENDLOOP.
      IF lv_new_sel IS NOT INITIAL.
        CLEAR lt_ordim_o.
        CLEAR lt_whoid.
      ELSE.
        EXIT.   "DO
      ENDIF.
    ENDDO.

    IF lt_whoid IS INITIAL OR
       lv_check_hu_wt IS NOT INITIAL.


      IF ls_huhdr-top IS INITIAL.
        MESSAGE e463(/scwm/rf_en) WITH cs_selection-huident.
      ELSE.
        MESSAGE e418(/scwm/rf_en) WITH cs_selection-huident.
      ENDIF.

    ENDIF.


*    IF cs_vi02_rf_sampling-only_selection IS INITIAL.

*   Check if rebundle is necessary.
*   Read all open WT from the HU.
*     Check if they all belong to only one WO.
*     Read all open WT for the WO.
*     If the number of open WT from the WO is the same as
*       the number of open WT from the HU.
*     -> No rebundling necessary.

    CLEAR lv_rebundle.
*   Read all open WT from the HU. Is done before. Result LT_ORDIM_O
    DESCRIBE TABLE lt_ordim_o LINES lv_lines_o.

*   Check if they all belong to only one WO.
    DESCRIBE TABLE lt_whoid LINES lv_lines_who.
    IF lv_lines_who = 1.
      TRY.
          CALL FUNCTION '/SCWM/WHO_SELECT'
            EXPORTING
              iv_to      = 'X'
              iv_lgnum   = cs_vi02_rf_sampling-lgnum
              it_who     = lt_whoid
            IMPORTING
              et_who     = lt_who_old
              et_ordim_o = lt_ordim_o_who.

          DESCRIBE TABLE lt_ordim_o_who LINES lv_lines_o_who.

          IF lv_lines_o_who <> lv_lines_o.
            lv_rebundle = 'X'.
          ENDIF.

        CATCH /scwm/cx_core.                            "#EC NO_HANDLER

      ENDTRY.
    ELSE.
      lv_rebundle = 'X'.
    ENDIF.

    IF lv_rebundle IS NOT INITIAL.
*     Read "old" WO to get WCR and latest LSD
      TRY.
          CALL FUNCTION '/SCWM/WHO_SELECT'
            EXPORTING
              iv_lgnum = cs_vi02_rf_sampling-lgnum
              it_who   = lt_whoid
            IMPORTING
              et_who   = lt_who_old.

        CATCH /scwm/cx_core.                            "#EC NO_HANDLER

      ENDTRY.

      LOOP AT lt_who_old INTO ls_who.
        IF ls_who-lsd < lv_lsd OR
            lv_lsd IS INITIAL.
          lv_lsd = ls_who-lsd.
          lv_wcr = ls_who-wcr.       "We could have different one
          lv_type = ls_who-type.
        ENDIF.
      ENDLOOP.

*     Re-bundle the WT and lock the new WT for processing
      CALL FUNCTION '/SCWM/WO_REBUNDLE_MAN'
        EXPORTING
          iv_lgnum    = cs_vi02_rf_sampling-lgnum
          ir_tanum    = lt_tanum
        IMPORTING
          ev_severity = lv_severity
          et_wo       = lt_who
          et_bapiret  = lt_bapiret.

      IF lv_severity CA wmegc_severity_ea.
*       Error
        READ TABLE lt_bapiret INTO ls_bapiret
           WITH KEY type = wmegc_severity_err.
        IF sy-subrc = 0.
*         Message from bapiret
          MESSAGE ID ls_bapiret-id TYPE ls_bapiret-type
              NUMBER ls_bapiret-number
              WITH ls_bapiret-message_v1 ls_bapiret-message_v2
                   ls_bapiret-message_v3 ls_bapiret-message_v4.

          RETURN.
        ELSE.
*         Picking not possible for any reason
          MESSAGE e031(/scwm/rf_en).
        ENDIF.
      ELSE.
        IF lt_who IS INITIAL.
          MESSAGE e118(/scwm/ui_rf) WITH 'LT_WHO' cs_vi02_rf_sampling-lgnum.
          RETURN.
        ENDIF.

*       Go on and move updated data to common table
        COMMIT WORK AND WAIT.

*       Restart Transaction in case of update errors
        CALL METHOD error_restart_transaction
          EXPORTING
            iv_subrc = sy-subrc
          CHANGING
            cv_proc  = lv_proc.

        CALL METHOD /scwm/cl_tm=>cleanup( ).

        IF lv_proc = c_db_upd_err.
          RETURN.
        ENDIF.

*       Set WCR and LSD from original WO
        IF lv_lsd IS NOT INITIAL OR
           lv_wcr IS NOT INITIAL OR
           lv_type IS NOT INITIAL.
          LOOP AT lt_who ASSIGNING <who>.
            <who>-lsd = lv_lsd .
            <who>-wcr = lv_wcr.
            <who>-type = lv_type.
            <who>-updkz = 'U'.
            MODIFY lt_who INDEX sy-tabix FROM <who> TRANSPORTING lsd.
          ENDLOOP.

*         Update tables /scwm/who and /scwm/wo_rsrc_ty
          CALL FUNCTION '/SCWM/WHO_DB_UPDATE'
            EXPORTING
              it_who = lt_who.

          COMMIT WORK AND WAIT.

          CALL METHOD /scwm/cl_tm=>cleanup( ).
        ENDIF.
      ENDIF.

      CLEAR lt_whoid.

      LOOP AT lt_who INTO ls_who.
        ls_whoid-who = ls_who-who.
        APPEND ls_whoid TO lt_whoid.
      ENDLOOP.
    ENDIF.

*   Set WO to status 'In processing' and update resource
    CALL FUNCTION '/SCWM/RSRC_RESOURCE_MEMORY'
      EXPORTING
        iv_uname = sy-uname
      CHANGING
        cs_rsrc  = ls_rsrc.

    lv_applic = /scwm/cl_rf_bll_srvc=>get_applic( ).
    lv_ltrans = /scwm/cl_rf_bll_srvc=>get_ltrans( ).

    LOOP AT lt_whoid INTO ls_whoid.
      CLEAR lt_wo_rsrc_ty.
      ls_wo_rsrc_ty-lgnum = cs_vi02_rf_sampling-lgnum.
      ls_wo_rsrc_ty-who = ls_whoid-who.

      APPEND ls_wo_rsrc_ty TO lt_wo_rsrc_ty.

      CLEAR lv_work_who.
      SET PARAMETER ID '/SCWM/WORK_WHO' FIELD lv_work_who.

      CALL FUNCTION '/SCWM/RSRC_WHO_SELECT'
        EXPORTING
          iv_applic         = lv_applic
          iv_ltrans         = lv_ltrans
          iv_man_wo_sel     = 'X'
        CHANGING
          cs_rsrc           = ls_rsrc
          ct_wo_rsrc_ty     = lt_wo_rsrc_ty
        EXCEPTIONS
          no_rstyp_attached = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDLOOP.

*    ENDIF.

    CLEAR lt_ordim_o.
    /scwm/cl_log=>get_instance( IMPORTING eo_instance = lo_log ).

    TRY.
        CALL FUNCTION '/SCWM/WHO_SELECT'
          EXPORTING
            iv_to       = 'X'
            iv_lgnum    = cs_vi02_rf_sampling-lgnum
            iv_lock_who = 'X'
            io_prot     = lo_log
            it_who      = lt_whoid
          IMPORTING
            et_ordim_o  = lt_ordim_o.

      CATCH /scwm/cx_core.                              "#EC NO_HANDLER

    ENDTRY.

    IF lo_log->get_severity( ) CA 'AE'.
      lt_bapiret = lo_log->get_prot( ).
      READ TABLE lt_bapiret INTO ls_bapiret
         WITH KEY type = wmegc_severity_err.
      IF sy-subrc = 0.
*     Message from bapiret
        MESSAGE ID ls_bapiret-id TYPE ls_bapiret-type
            NUMBER ls_bapiret-number
            WITH ls_bapiret-message_v1 ls_bapiret-message_v2
                 ls_bapiret-message_v3 ls_bapiret-message_v4.
      ENDIF.
    ENDIF.

    IF lt_ordim_o IS INITIAL.
      MESSAGE e118(/scwm/ui_rf) WITH 'LT_ORDIM_O' cs_vi02_rf_sampling-lgnum.
      RETURN.
    ENDIF.

    CLEAR ct_vi02_rf_sampling_wt.

    LOOP AT lt_ordim_o INTO ls_ordim_o.
      CLEAR ls_pipo.
      MOVE-CORRESPONDING ls_ordim_o TO ls_pipo.             "#EC ENHOK
      ls_pipo-seqno = sy-tabix.
      ls_pipo-batch = ls_ordim_o-charg.

*   Do the check only if the actual HU is different from the last one
      IF ls_pipo-vlenr <> lv_hu_verif.
*     Check if source HU is nested
        lv_hu_verif = ls_pipo-vlenr.

        CLEAR: lv_flg_nest_hu,
               lv_flg_huent_ok,
               lv_flg_mixed_hu.

        CALL FUNCTION '/SCWM/RF_PIPO_HUNEST_CHECK'
          EXPORTING
            iv_hu_verif        = lv_hu_verif
            iv_hu_parent       = ls_pipo-vlenr
            iv_lgnum           = ls_pipo-lgnum
            iv_lgpla           = ls_huhdr-lgpla
          IMPORTING
            ev_flg_nest_ok     = lv_flg_nest_hu
            ev_flg_huent_ok    = lv_flg_huent_ok
            ev_flg_mixed_hu    = lv_flg_mixed_hu
          CHANGING
            cs_pipo            = ls_pipo
          EXCEPTIONS
            hu_not_in_location = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          CASE sy-subrc.
            WHEN 1.
***          MESSAGE e044.
            WHEN OTHERS.
              MESSAGE ID sy-msgid
                    TYPE sy-msgty
                  NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2
                         sy-msgv3 sy-msgv4.
          ENDCASE.
        ENDIF.
      ENDIF.

      IF lv_flg_nest_hu IS NOT INITIAL.
        ls_pipo-vlein_nest = 'X'.
      ENDIF.
      IF lv_flg_huent_ok IS NOT INITIAL.
        ls_pipo-huent = 'X'.
      ENDIF.
      ls_pipo-hu_lgpla = ls_huhdr-lgpla.


      CLEAR ls_vi02_rf_sampling_wt.
      MOVE-CORRESPONDING ls_pipo TO ls_vi02_rf_sampling_wt.
      APPEND ls_vi02_rf_sampling_wt  TO ct_vi02_rf_sampling_wt.

    ENDLOOP.

    SORT ct_vi02_rf_sampling_wt ASCENDING BY lgnum who whoseq pathseq tanum.

  ENDMETHOD.


  METHOD zssrhu_pbo.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_SAMPLING->ZSSRHU_PBO
* Description:  PBO for (Source) HU selection
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
    BREAK-POINT ID zcg_vi02_rf_sampling.

    SET PARAMETER ID '/SCWM/WORK_WHO' FIELD space.

*    PERFORM get_wc CHANGING cs_wrkc
*                            cs_pipo_work.
*
*    IF cs_wrkc IS NOT INITIAL.
*      /scwm/cl_rf_bll_srvc=>set_prmod( gc_prmod_foregr ).
*      /scwm/cl_rf_bll_srvc=>set_fcode( gc_fcode_enter ).
*    ENDIF.

    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-selection ).

  ENDMETHOD.


  METHOD zstrhu_pai.

    BREAK-POINT ID zcg_vi02_rf_sampling.

    /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).


    IF ct_vi02_rf_sampling_wt IS NOT INITIAL.

      /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-zsptom ).

    ELSE.

      /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-zsptom ).

    ENDIF.


  ENDMETHOD.


  METHOD zstrhu_pbo.


    BREAK-POINT ID zcg_vi02_rf_sampling.


  ENDMETHOD.


  METHOD zswkcr_pai.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_SAMPLING->ZSWKCR_PAI
* Description:  PAI for Sampling Work center selection
*                 check if the entered Work center is allowed or not
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA: lv_trtyp TYPE /scwm/de_workst_trtyp,
          lv_fcode TYPE /scwm/de_fcode.

    DATA: ls_wrktyp    TYPE /scwm/twrktyp,
          ls_worksttyp TYPE /scwm/twrktyp.

    DATA: lo_wm_pack   TYPE REF TO /scwm/cl_wm_packing.

    BREAK-POINT ID zcg_vi02_rf_sampling.

    lv_fcode = /scwm/cl_rf_bll_srvc=>get_fcode( ).

    IF lv_fcode = c_rf_fcode-backf.
      /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).
*      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-leave ).
      /scwm/cl_rf_bll_srvc=>set_fcode( c_rf_fcode-back ).
      RETURN.
    ENDIF.

* Set default values
    get_user_default( CHANGING cs_vi02_rf_sampling = cs_vi02_rf_sampling ).

* Valid work centers have:
*   - WC type (TRTYP)'Packing General' or 'Deconsolidation'
*   - assigned to a storage type or a storage bin
* If the WC has no process step assigned, the pick-HU can't be closed
    CALL FUNCTION '/SCWM/TWORKST_READ_SINGLE'
      EXPORTING
        iv_lgnum       = cs_vi02_rf_sampling-lgnum
        iv_workstation = cs_vi02_rf_sampling-workstation
      IMPORTING
        es_workst      = cs_wrkc
      EXCEPTIONS
        error          = 1
        not_found      = 2
        OTHERS         = 3.

    IF sy-subrc NE 0.
      MESSAGE e040(/scwm/rf_de).
    ELSE.
      IF cs_wrkc-wrksttyp IS INITIAL.
        MESSAGE e040(/scwm/rf_de).
      ENDIF.

      CALL FUNCTION '/SCWM/TWRKTYP_READ_SINGLE'
        EXPORTING
          iv_lgnum    = cs_vi02_rf_sampling-lgnum
          iv_wrksttyp = cs_wrkc-wrksttyp
        IMPORTING
          es_wrktyp   = ls_wrktyp
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF ls_wrktyp-trtyp <> '1' AND
         ls_wrktyp-trtyp = '2'.
        MESSAGE e040(/scwm/rf_de).
      ENDIF.

*   Work center must have at least storage type or a storage bin
      IF cs_wrkc-lgtyp IS INITIAL AND cs_wrkc-lgpla IS INITIAL.
        MESSAGE e040(/scwm/rf_de).
      ENDIF.

    ENDIF.

    EXPORT s_wrkc = cs_wrkc TO MEMORY ID c_rf_memid-zrf_smpl_1.
    MOVE ls_worksttyp-trtyp TO lv_trtyp.
    EXPORT trtyp = lv_trtyp TO MEMORY ID c_rf_memid-zrf_smpl_2.

    cs_vi02_rf_sampling-workstation = cs_wrkc-workstation.
    cs_vi02_rf_sampling-trtyp       = lv_trtyp.

*   get instance and initialize log
    initialize_packing(
      EXPORTING
        is_wrkc    = cs_wrkc
      CHANGING
        co_wm_pack = lo_wm_pack ).
  ENDMETHOD.


  METHOD zswkcr_pbo.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_SAMPLING->ZSWKCR_PBO
* Description:  PBO for Sampling Work center selection
*                 Propose the List of the sampling work centers
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

    DATA: ls_wrkc   TYPE /scwm/tworkst,
          ls_wrktyp TYPE /scwm/twrktyp.

    DATA: lt_wrkc   TYPE TABLE OF /scwm/tworkst,
          lt_result TYPE TABLE OF /scwm/tworkst.

    BREAK-POINT ID zcg_vi02_rf_sampling.

* Get default values
    get_user_default( CHANGING cs_vi02_rf_sampling = cs_vi02_rf_sampling ).

    SELECT * FROM /scwm/tworkst INTO TABLE lt_wrkc
              WHERE lgnum = cs_vi02_rf_sampling-lgnum.

* Valid work centers have:
*   - WC type (TRTYP)'Packing General'
*   - assigned to a storage type or a storage bin
* If the WC has no process step assigned, the pick-HU can't be closed

    LOOP AT lt_wrkc INTO ls_wrkc.
      CHECK ls_wrkc-lgnum = cs_vi02_rf_sampling-lgnum.
      CHECK ls_wrkc-wrksttyp IS NOT INITIAL.

      CALL FUNCTION '/SCWM/TWRKTYP_READ_SINGLE'
        EXPORTING
          iv_lgnum    = cs_vi02_rf_sampling-lgnum
          iv_wrksttyp = ls_wrkc-wrksttyp
        IMPORTING
          es_wrktyp   = ls_wrktyp
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CHECK ls_wrktyp-trtyp = '1'.

*   Work center must have at least storage type or a storage bin
      IF ls_wrkc-lgtyp IS INITIAL AND ls_wrkc-lgpla IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND ls_wrkc TO lt_result.

    ENDLOOP.

    CALL METHOD /scwm/cl_rf_bll_srvc=>init_listbox
      EXPORTING
        iv_fieldname = c_rf_sname-workstation.

    LOOP AT lt_result INTO ls_wrkc.
      CALL METHOD /scwm/cl_rf_bll_srvc=>insert_listbox
        EXPORTING
          iv_fieldname = c_rf_sname-workstation
          iv_value     = ls_wrkc-workstation.
    ENDLOOP.

    /scwm/cl_rf_bll_srvc=>set_screen_param( c_rf_pname-zcs_vi02_rf_sampling ).

  ENDMETHOD.
ENDCLASS.
