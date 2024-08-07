*&---------------------------------------------------------------------*
*& Include          Z_VI02_EX_MFS_EWM2PLC_F01
*&---------------------------------------------------------------------*
************************************************************************
* Company     : Swisslog AG
*
* Package     : Z_VI02_MFS_ENH
* Enhancement : BAdI /SCWM/EX_MFS_TELE_EWM2PLCOB
* Description : This ABAP is used to map SAP EWM to PLC Object
*               Copy of the /SL0/EX_MFS_EWM2PLC2_F01 with using the
*               /SL0/CL_MFS_PROCESS_HELPER
*
* PARAMETERS:
* ----------
* Importing:
* --> IV_LGNUM     : Warehouse Number/Warehouse Complex
* --> IV_PLC       : PLC Programmable Logic Controller
* --> IV_EWMOBJ    : EWM object such a a CP, CS, RSRC etc.
* --> IV_OBJTYPE   : PLC object type
* --> IS_TELEGRAM  : s_mfs_total structure
* Changing
* <-> CV_PLCOBJ    : Changed EWM object
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦ Date       ¦ Author           ¦ Description
* ------- ¦ ---------- ¦ ---------------- ¦ ----------------------------
* 1.0     ¦ 2023-11-09 ¦ FSPISAK          ¦ Intitial
************************************************************************

*| Local Declaration
CONSTANTS: lc_fname TYPE funcname VALUE 'BAdI->EWM2PLCOBJ'.

DATA: ls_swl_mfsplc TYPE /sl0/t_mfsplc,
*    , lv_plciftype  TYPE /scwm/de_mfsplc_iftype,
      lv_logpos     TYPE /scwm/de_logpos,
      lv_msgtxt     TYPE string.

DATA: lo_log        TYPE REF TO /sl0/cl_log_mfs,
      lo_mfs_helper TYPE REF TO zcl_vi02_mfs_process_helper.

CREATE OBJECT lo_mfs_helper. " Instantiate helper object

*| Setup logging
TRY.
*           Initialize log protocol instance..
    lo_log ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum = iv_lgnum
                                                        io_log   = co_log ).
  CATCH /sl0/cx_general_exception .
ENDTRY.

TRY.
    " Register begin of protocol logging..
    lo_log->start_log( EXPORTING iv_processor = lc_fname
                                 iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                 is_telegram  = is_telegram ).
  CATCH /sl0/cx_general_exception .                     "#EC NO_HANDLER
ENDTRY.

**| Get PLC Type
*SELECT SINGLE plciftype
*  INTO lv_plciftype
*  FROM /scwm/tmfsplc
* WHERE lgnum = iv_lgnum
*   AND plc   = iv_plc.

*| Now read Swisslog customizing for PLC
CALL FUNCTION '/SL0/MFSPLC_READ_SINGLE'
  EXPORTING
    iv_lgnum      = iv_lgnum
    iv_plc        = iv_plc
*   iv_nobuf      = abap_true
  IMPORTING
    es_swl_mfsplc = ls_swl_mfsplc
  EXCEPTIONS
    error         = 1
    not_found     = 2
    OTHERS        = 99.

IF sy-subrc IS INITIAL. "OR cv_plcobj is initial.

*| Get logical position of bin
  CASE iv_ewmobj.
    WHEN is_telegram-source.
      lv_logpos = is_telegram-slogpos.
    WHEN is_telegram-dest.
      lv_logpos = is_telegram-dlogpos.
    WHEN OTHERS.
      CLEAR: lv_logpos. "00
  ENDCASE.

  cv_plcobj = lo_mfs_helper->ewmbin2sisaddr( EXPORTING iv_lgnum   = iv_lgnum
                                                       iv_plc     = iv_plc
                                                       iv_lgpla   = iv_ewmobj
                                                       iv_logpos  = lv_logpos
                                                       iv_objtype = iv_objtype
                                                       iv_hutyp   = is_telegram-hutyp
                                                       iv_huident = is_telegram-huident ).

  IF cv_plcobj IS INITIAL.
*|  Error Assigning SIS Address for &IV_PLC_& &iv_ewmobj& &iv_objtype& not
    MESSAGE e514(/sl0/mfs)
       WITH iv_plc iv_ewmobj iv_objtype
       INTO lv_msgtxt.

    lo_log->add_message( ip_row = 0 ).
  ENDIF.

*| Finalize logging
  TRY.
      lo_log->end_log( EXPORTING iv_plc       = iv_plc
                                 iv_huident   = is_telegram-huident
                                 iv_cp        = is_telegram-cp
                                 iv_sequno    = is_telegram-sequ_no
                                 iv_no_commit = abap_true
                                 iv_processor = lc_fname
                                 iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                 io_log       = lo_log->/sl0/if_log~get_sap_log( ) ).
    CATCH /sl0/cx_general_exception.    "
    CATCH /scwm/cx_basics.    "
  ENDTRY.

ENDIF.
