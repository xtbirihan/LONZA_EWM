FUNCTION z_vi02_mfs_tutype_det.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_SWL_MFSCP) TYPE  /SL0/T_MFSCP
*"     REFERENCE(IS_TELEGRAM) TYPE  /SCWM/S_MFS_TELETOTAL
*"     REFERENCE(IV_HUIDENT) TYPE  /SCWM/HUIDENT
*"     REFERENCE(IO_LOG) TYPE REF TO  /SL0/CL_LOG_MFS OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_TUTYPE) TYPE  /SL0/DE_TUTYPE
*"----------------------------------------------------------------------

*------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*------------------------------------------------------------------------------*
*
* Description: TU Type Determination (design doc. LOVIBI-409)
*
*------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*----------------------Documentation of Changes--------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-10-13 ¦Yuriy Dzhenyeyev¦Initial
*------------------------------------------------------------------------------*

  TYPES: BEGIN OF ty_materials,
           matid_c TYPE /scwm/de_matid,
           matnr_c TYPE /sapapo/matnr,
           matap_c TYPE /sapapo/matid,
         END OF ty_materials,

         BEGIN OF ty_sapapo_marm,
           matid      TYPE /sapapo/matid,
           meinh      TYPE /sapapo/lrmei,
           matnr      TYPE /sapapo/matnr,
           hutyp_dflt TYPE /scwm/de_hutyp_dflt,
         END OF ty_sapapo_marm.

  CONSTANTS: lc_fname TYPE funcname VALUE 'Z_VI02_MFS_TUTYPE_DET'.

  DATA : lo_mfs_hu      TYPE REF TO /sl0/cl_mfs_hu,
         lo_log         TYPE REF TO /sl0/cl_log_mfs,
         lt_materials   TYPE STANDARD TABLE OF ty_materials,
         ls_materials   TYPE ty_materials,
         lt_marm        TYPE STANDARD TABLE OF ty_sapapo_marm,
         ls_marm        TYPE ty_sapapo_marm,
         lv_message     TYPE string,                        "#EC NEEDED
         lv_par_id      TYPE /sl0/de_param_id2,
         lv_par_value   TYPE /sl0/de_param_low,
         lv_tanum_inact TYPE /scwm/tanum,
         lt_ordim_o     TYPE /scwm/tt_ordim_o.

  " ------------------------------------------ "
  "  Initialization
  " ------------------------------------------ "
  /scwm/cl_tm=>cleanup( EXPORTING iv_lgnum = is_swl_mfscp-lgnum ).
  CLEAR ev_tutype.

*|Read HU Data..
  lo_mfs_hu = NEW /sl0/cl_mfs_hu( iv_lgnum   = is_swl_mfscp-lgnum
                                  iv_huident = iv_huident ).
*| Setup logging
  " Create log instance..
  TRY.
*           Initialize log protocol instance..
      lo_log ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum = is_swl_mfscp-lgnum
                                                          io_log   = io_log ).

      " Register begin of protocol logging..
      lo_log->start_log( EXPORTING iv_processor = lc_fname
                                   iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                   is_telegram  = is_telegram ).
    CATCH /sl0/cx_general_exception .                   "#EC NO_HANDLER
  ENDTRY.

  " ------------------------------------------ "
  "  Processing Logic..
  " ------------------------------------------ "

*|Get HU Data..
  lo_mfs_hu->read_hu_data( IMPORTING es_huhdr_data = DATA(ls_huhdr_data)
                                     et_huitm      = DATA(lt_huitm)
                                     ev_ret_code   = DATA(lv_ret_code) ).

  IF lv_ret_code IS NOT INITIAL.
*|  Error reading HU data..
    MESSAGE i039(/sl0/mfs) INTO lv_message.
    lo_log->add_message( iv_row = 0 ).

    TRY.
        lo_log->end_log( EXPORTING iv_plc       = is_swl_mfscp-plc
                                   iv_huident   = iv_huident
                                   iv_cp        = is_telegram-cp
                                   iv_sequno    = is_telegram-sequ_no
                                   iv_processor = lc_fname
                                   iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                   io_log       = lo_log->/sl0/if_log~get_sap_log( )
                                   iv_no_commit = abap_true ).
      CATCH /sl0/cx_general_exception.    "
      CATCH /scwm/cx_basics.    "
    ENDTRY.

    RETURN.
  ENDIF.

*| Get packaging material of the HU..
  lo_mfs_hu->get_hu_pmat( CHANGING es_huhdr_data = ls_huhdr_data ).

  IF lt_huitm IS NOT INITIAL.
* read putaway strategy for materials on the HU
    DATA(lt_matid) = VALUE /scwm/tt_matid( FOR ls_wa IN lt_huitm ( ls_wa-matid ) ).
    DATA lt_mat_lgnum TYPE /scwm/tt_material_lgnum.
    DATA lt_matid_bapiret TYPE /scwm/tt_matid_bapiret.

    TRY.
        CALL FUNCTION '/SCWM/MATERIAL_READ_MULTIPLE'
          EXPORTING
            it_matid     = lt_matid                 " Material GUID16  mit Konvertierungsexit
            iv_entitled  = lt_huitm[ 1 ]-entitled                 " Verfügungsberechtigter
            iv_lgnum     = is_swl_mfscp-lgnum                 " Lagernummer/Lagerkomplex
            iv_notext    = 'X'              " No text (descreption) is required
          IMPORTING
            et_mat_lgnum = lt_mat_lgnum
            et_mat_error = lt_matid_bapiret.

*      CATCH /scwm/cx_md_interface.      " Import Parameter fehlerhaft
*      CATCH /scwm/cx_md_material_exist. " Material existiert nicht
*      CATCH /scwm/cx_md_lgnum_locid.    " Lagernummer ist keiner APO-Lokation zugeordnet
      CATCH /scwm/cx_md INTO DATA(lx_md).                " Stammdaten Ausnahme
        lo_log->add_cx_message( lx_md ).
    ENDTRY.

    SORT lt_mat_lgnum BY put_stra.
    DELETE ADJACENT DUPLICATES FROM lt_mat_lgnum COMPARING put_stra.

    IF lines( lt_mat_lgnum ) GT 1.
      "Anbiguous temperature class for HU &1
      MESSAGE e346(/sl0/mfs) WITH
      iv_huident
      INTO lv_message.

      lo_log->add_message( ).
      RETURN.
    ENDIF.

    DATA(lv_putstra) = lt_mat_lgnum[ 1 ]-put_stra.
  ENDIF.

  IF lv_putstra IS INITIAL.
    "pallet is empty, lookup with packaging material only.
    SELECT SINGLE FROM zvi02_tutypemap FIELDS tutype
      WHERE lgnum = @is_swl_mfscp-lgnum
      AND pmat = @ls_huhdr_data-pmat
      AND put_stra = @( VALUE /scwm/de_put_stra( ) )
      INTO @ev_tutype.
  ELSE.
    SELECT SINGLE FROM zvi02_tutypemap FIELDS tutype
      WHERE lgnum = @is_swl_mfscp-lgnum
      AND pmat = @ls_huhdr_data-pmat
      AND put_stra = @lv_putstra
      INTO @ev_tutype.
  ENDIF.

  IF ev_tutype IS INITIAL.
    "TU Type of &1 telegram at CP &2 is initial.
    MESSAGE e263(/sl0/mfs) WITH
      is_telegram-teletype
      is_telegram-cp
      INTO lv_message.

    lo_log->add_message( ).
  ELSE.
    "TU Type &1 determined for HU &2.
    MESSAGE s167(/sl0/mfs) WITH
      ev_tutype
      iv_huident
      INTO lv_message.

    lo_log->add_message( ).
  ENDIF.

  TRY.
      lo_log->end_log( EXPORTING iv_plc       = is_swl_mfscp-plc
                                 iv_huident   = ls_huhdr_data-huident
                                 iv_cp        = is_telegram-cp
                                 iv_sequno    = is_telegram-sequ_no
                                 iv_processor = lc_fname
                                 iv_proc_type = /sl0/cl_log_abstract=>mc_proc_func
                                 io_log       = lo_log->/sl0/if_log~get_sap_log( )
                                 iv_no_commit = abap_true ).
    CATCH /sl0/cx_general_exception.    "
    CATCH /scwm/cx_basics.    "
  ENDTRY.

ENDFUNCTION.
