FUNCTION z_vi02_mfs_max_weight_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_TELEGRAM) TYPE  /SCWM/S_MFS_TELETOTAL
*"     REFERENCE(IS_SWL_MFSCP) TYPE  /SL0/T_MFSCP
*"     REFERENCE(IV_HUIDENT) TYPE  /SCWM/HUIDENT OPTIONAL
*"     REFERENCE(IO_LOG) TYPE REF TO  /SL0/CL_LOG_MFS OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_ACCEPT_WEIGHT) TYPE  BOOLEAN
*"     REFERENCE(EV_MAX_WEIGHT) TYPE  /SL0/DE_MFSCP_MAX_WEIGHT
*"     REFERENCE(EV_MAX_WEIGHT_UOM) TYPE  /SL0/DE_MFSCP_MAX_WEIGHT_UOM
*"----------------------------------------------------------------------

*------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*------------------------------------------------------------------------------*
*
* Description: weight check at CP using HU type group (design doc. LOVIBI-408)
*
*------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*----------------------Documentation of Changes--------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-10-13 ¦Yuriy Dzhenyeyev¦Initial
*------------------------------------------------------------------------------*


  " ------------------------------------------ "
  "  Local Declarations..
  " ------------------------------------------ "
  CONSTANTS: lc_max_weight_uom TYPE /sl0/de_mfscp_max_weight_uom VALUE 'KG'
           .

  DATA: lo_mfs_hu          TYPE REF TO /sl0/cl_mfs_hu
      , ls_huhdr           TYPE /scwm/s_huhdr_int
      , lv_ret_code        TYPE sysubrc
      , lv_param_id        TYPE /sl0/de_param_id2
      , lv_measured_weight TYPE /scwm/brgew
      , lv_msgtext         TYPE bapi_msg
      , lo_log             TYPE REF TO /sl0/cl_log_mfs
      .
  CONSTANTS: lc_fname TYPE funcname VALUE 'Z_VI02_MFS_MAX_WEIGHT_CHECK'.

  " ------------------------------------------ "
  "  Initialization
  " ------------------------------------------ "

  "Setup logging
  " Create log instance..
  TRY.
*           Initialize log protocol instance..
      lo_log ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum     = is_swl_mfscp-lgnum
                                                          io_log       = io_log ).
    CATCH /sl0/cx_general_exception .
  ENDTRY.

  TRY.
      " Register begin of protocol logging..
      lo_log->start_log( EXPORTING iv_processor = lc_fname
                                   iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                   is_telegram  = is_telegram ).
    CATCH /sl0/cx_general_exception .                   "#EC NO_HANDLER
  ENDTRY.

  ev_max_weight_uom = lc_max_weight_uom.

*|  Create HU Instance
    lo_mfs_hu = NEW /sl0/cl_mfs_hu( iv_lgnum = is_swl_mfscp-lgnum ).
*|  Read HU Header
    lo_mfs_hu->read_assignment_huhdr( EXPORTING iv_huident      = iv_huident
                                      IMPORTING es_huhdr_data   = ls_huhdr
                                                ev_ret_code     = lv_ret_code ).
    IF lv_ret_code IS INITIAL.
      lv_param_id = ls_huhdr-hutypgrp.
    ENDIF.

*| set local measured weight.
  lv_measured_weight = is_telegram-/sl0/weight.

*| Get exceptional maximum weight of pallet
  IF lv_param_id IS NOT INITIAL.
    ev_max_weight  = /sl0/cl_param_select=>read_const( iv_lgnum      = is_swl_mfscp-lgnum
                                                       iv_param_prof = /sl0/cl_param_c=>c_prof_mfs
                                                       iv_context    = /sl0/cl_param_c=>c_context_max_weight
                                                       iv_parameter  = lv_param_id ).
  ENDIF.

*| Set local maximum weight
  IF ev_max_weight IS INITIAL.
*|  if no exceptional weight found, set default by cp settings
    ev_max_weight = is_swl_mfscp-max_weight.

  ELSEIF is_swl_mfscp-max_weight_uom NE lc_max_weight_uom.
    "convert exceptional maximum weight to max weight uom of CP
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = ev_max_weight
        no_type_check        = 'X'
*       ROUND_SIGN           = ' '
        unit_in              = lc_max_weight_uom   "UOM of exceptional max weight (kg)
        unit_out             = is_swl_mfscp-max_weight_uom "UOM of maximum weight
      IMPORTING
        output               = ev_max_weight
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          INTO lv_msgtext.
      IF io_log IS BOUND.
        lo_log->add_message( iv_row = 0 ).
      ENDIF.
      ev_accept_weight = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

  " ------------------------------------------ "
  "  Processing Logic..
  " ------------------------------------------ "
  "check SIS weight UOM is set.
  IF is_swl_mfscp-weight_uom IS INITIAL.
    MESSAGE e069(/sl0/mfs) INTO lv_msgtext
                 WITH is_swl_mfscp-cp.
    IF io_log IS BOUND.
      lo_log->add_message( iv_row = 0 ).
    ENDIF.
    ev_accept_weight = abap_false.
    RETURN.
  ENDIF.
  "check max. weight UOM is set
  IF is_swl_mfscp-max_weight_uom IS INITIAL.
    MESSAGE e070(/sl0/mfs) INTO lv_msgtext
                 WITH is_swl_mfscp-cp.
    IF io_log IS BOUND.
      lo_log->add_message( iv_row = 0 ).
    ENDIF.
    ev_accept_weight = abap_false.
    RETURN.
  ENDIF.
  "check max. weight is set
  IF ev_max_weight IS INITIAL.
    MESSAGE e071(/sl0/mfs) INTO lv_msgtext
                           WITH is_swl_mfscp-cp.
    IF io_log IS BOUND.
      lo_log->add_message( iv_row = 0 ).
    ENDIF.
    ev_accept_weight = abap_false.
    RETURN.
  ENDIF.

  IF is_swl_mfscp-weight_uom NE is_swl_mfscp-max_weight_uom.
*|  convert measured weight
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = lv_measured_weight
        no_type_check        = 'X'
*       ROUND_SIGN           = ' '
        unit_in              = is_swl_mfscp-weight_uom     "subsystem weight UOM
        unit_out             = is_swl_mfscp-max_weight_uom "UOM of maximum weight
      IMPORTING
        output               = lv_measured_weight          "Measured weight in UOM of max. weight
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          INTO lv_msgtext.
      IF io_log IS BOUND.
        lo_log->add_message( iv_row = 0 ).
      ENDIF.
      ev_accept_weight = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

  "check measured weight against maximum weight
  IF lv_measured_weight GT ev_max_weight.
    ev_accept_weight = abap_false.
    MESSAGE i067(/sl0/mfs) INTO lv_msgtext
                 WITH lv_measured_weight
                      is_swl_mfscp-max_weight_uom
                      is_swl_mfscp-max_weight
                      is_swl_mfscp-max_weight_uom.
    IF io_log IS BOUND.
      lo_log->add_message( iv_row = 0 ).
    ENDIF.
  ELSE.
    ev_accept_weight = abap_true.
    MESSAGE i068(/sl0/mfs) INTO lv_msgtext
                 WITH lv_measured_weight
                      is_swl_mfscp-max_weight_uom
                      is_swl_mfscp-max_weight
                      is_swl_mfscp-max_weight_uom.
    IF io_log IS BOUND.
      lo_log->add_message( iv_row = 0 ).
    ENDIF.
  ENDIF.

  " Log end of FM processing..
  TRY.
      lo_log->end_log( EXPORTING iv_huident   = is_telegram-huident
                                 iv_source    = is_telegram-source
                                 iv_dest      = is_telegram-dest
                                 iv_processor = lc_fname
                                 iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func ).
    CATCH /sl0/cx_general_exception.    "
    CATCH /scwm/cx_basics.    "
  ENDTRY.

ENDFUNCTION.
