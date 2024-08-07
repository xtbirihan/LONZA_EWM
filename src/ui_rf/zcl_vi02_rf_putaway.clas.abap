class ZCL_VI02_RF_PUTAWAY definition
  public
  final
  create protected .

public section.
  type-pools WMEGC .

  class-methods GET_INST
    returning
      value(RO_RF_PUTAWAY) type ref to ZCL_VI02_RF_PUTAWAY .
  methods PTHUDS_PBO
    changing
      !CS_PTWY type /SCWM/S_RF_PTWY
      !CS_ADMIN type /SCWM/S_RF_ADMIN
      !CT_PTWY type /SCWM/TT_RF_PTWY
      !CT_LGPLA type /SCWM/TT_LGPLA
      !CS_WME_VERIF type /SCWM/S_WME_VERIF
      !CT_SERNR type /SCWM/TT_RF_SERNR
      !CT_NESTED_HU type /SCWM/TT_RF_NESTED_HU .
protected section.

  class-data GO_SINGLETON type ref to ZCL_VI02_RF_PUTAWAY .
  class-data MV_LGNUM type /SCWM/LGNUM .
  data MX_EXC_BUF type ref to ZCX_VI02_RF .
  data MV_MSG_BUF type STRING .

  class-methods GET_RSRC_DATA
    returning
      value(RS_RSRC) type /SCWM/RSRC .
  class-methods INIT .
  methods CONSTRUCTOR .
private section.

  constants:
    BEGIN OF c_rf_ltrans,
      pthucl TYPE /scwm/de_ltrans     VALUE 'PTHUCL' ##NO_TEXT, " Putaway HU (Clustered)
      pthusi TYPE /scwm/de_ltrans     VALUE 'PTHUSI' ##NO_TEXT, " Putaway HU (Single)
      pthusy TYPE /scwm/de_ltrans     VALUE 'PTHUSY' ##NO_TEXT, " Putaway HU called by Manual Selection
      ptwosi TYPE /scwm/de_ltrans     VALUE 'PTWOSI' ##NO_TEXT, " Putaway WO
      ptwosy TYPE /scwm/de_ltrans     VALUE 'PTWOSY' ##NO_TEXT, " Putaway WO system guided
    END OF c_rf_ltrans .
  constants:
    BEGIN OF c_rf_steps,
      pthucb TYPE /scwm/de_step VALUE 'PTHUCB' ##NO_TEXT, "  Change destination storage bin
      pthuds TYPE /scwm/de_step VALUE 'PTHUDS' ##NO_TEXT, "  HU destination data
    END OF c_rf_steps .
  constants:
    BEGIN OF c_rf_fcode,
      enter  TYPE /scwm/de_fcode VALUE 'ENTER'  ##NO_TEXT,
      enterf TYPE /scwm/de_fcode VALUE 'ENTERF' ##NO_TEXT,
      back   TYPE /scwm/de_fcode VALUE 'BACK'   ##NO_TEXT,
      backf  TYPE /scwm/de_fcode VALUE 'BACKF'  ##NO_TEXT,
      leave  TYPE /scwm/de_fcode VALUE 'LEAVE'  ##NO_TEXT,
    END OF c_rf_fcode .
  constants:
    BEGIN OF c_rf_sname,
      nlpla_verif TYPE /scwm/de_screlm_name VALUE '/SCWM/S_RF_PTWY-NLPLA_VERIF',
      nlpla       TYPE /scwm/de_screlm_name VALUE '/SCWM/S_RF_PTWY-NLPLA',
    END OF c_rf_sname .
  constants:
    BEGIN OF c_rf_pname,
      cs_ptwy TYPE /scwm/de_param_name VALUE 'CS_PTWY',
    END OF c_rf_pname .
  constants:
    BEGIN OF c_rf_shortcut,
      chbd TYPE /scwm/de_shortcut VALUE 'CHBD',
    END OF c_rf_shortcut .
ENDCLASS.



CLASS ZCL_VI02_RF_PUTAWAY IMPLEMENTATION.


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


  METHOD get_inst.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_PUTAWAY=>GET_INST
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

    ro_rf_putaway = go_singleton.

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


METHOD pthuds_pbo.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type:         Method
* Name:         ZCL_VI02_RF_PUTAWAY->PTHUSD_PBO
* Polarion:     LOVIBI-383 - Receiving and Putaway:
*               HU Transfer to MFS Infeed Conveyors
*               RF Screen needs built-in CHDB Exception Code
* Description:  call the standard function module for step PTHUDS
*               (FM /SCWM/RF_PT_HU_DEST_PBO )
*               force the exception CHBD to change the destination bin
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

  BREAK-POINT ID zcg_vi02_rf_putaway.

  "call the standard PBO function module
  CALL FUNCTION '/SCWM/RF_PT_HU_DEST_PBO'
    CHANGING
      cs_ptwy   = cs_ptwy
      cs_admin  = cs_admin
      ct_ptwy   = ct_ptwy
      ct_lgpla  = ct_lgpla
      wme_verif = cs_wme_verif.

  "is the function is activated? (built-in CHDB Exception Code)
  IF abap_true EQ /sl0/cl_dynswt=>get_switch_state( iv_lgnum = cs_admin-lgnum
*                                                   iv_vltyp = cs_ptwy-vltyp
*                                                   iv_vlpla = cs_ptwy-vlpla
                                                    iv_nltyp = cs_ptwy-nltyp
*                                                   iv_nlpla = cs_ptwy-nlpla
                                                    iv_ipnum = zif_vi02_dynswt_c=>c_ipnum_built_in_chbd ).

    "Only if the BIN has not been changed
    "( Only if the BIN is filled, otherwise it is possible to enter it directly anyway)
    IF  NOT ( line_exists( cs_ptwy-exc_tab[ iprcode = wmegc_iprcode_chbd ] ) )
    AND cs_ptwy-nlpla IS NOT INITIAL.

      "set the shortcut as CHBD
      CALL METHOD /scwm/cl_rf_bll_srvc=>set_shortcut
        EXPORTING
          iv_shortcut = c_rf_shortcut-chbd.

      "call PAI Putaway Exceptions
      CALL FUNCTION '/SCWM/RF_PT_EXCEPTION'
        CHANGING
          cs_ptwy       = cs_ptwy
          cs_admin      = cs_admin
          ct_ptwy       = ct_ptwy
          ct_sernr      = ct_sernr
          tt_nested_hu  = ct_nested_hu
        EXCEPTIONS
          error_message = 99.     "catch error messages
      IF sy-subrc IS NOT INITIAL.
        "in case of error simply do nothing (they can enter the exception manually, and then see the error)
        CALL METHOD /scwm/cl_rf_bll_srvc=>clear_shortcut.
        RETURN.
      ELSE.
        "force the execution in background processing
        CALL METHOD /scwm/cl_rf_bll_srvc=>set_prmod
          EXPORTING
            iv_prmod    = /scwm/cl_rf_bll_srvc=>c_prmod_background
            iv_ovr_cust = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
