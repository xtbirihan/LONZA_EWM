class ZCL_VI02_MFS_TELE_CONV_STK_POR definition
  public
  inheriting from /SL0/CL_MFS_TELE_CONV_POR
  final
  create public .

public section.
protected section.

  methods PROCESS_POR1
    redefinition .
private section.

  constants MC_PROCESSOR_CLPREFIX type SEOCLSNAME value 'CL_CONV_POR' ##NO_TEXT.
  constants MC_METH_PROCESS_POR0 type SEOCPDNAME value 'PROCESS_POR0' ##NO_TEXT.
  constants MC_METH_PROCESS_POR1 type SEOCPDNAME value 'PROCESS_POR1' ##NO_TEXT.
  constants MC_METH_CREATE_STACK type SEOCPDNAME value 'CREATE_CREATE_STACK' ##NO_TEXT.
  constants MC_METH_CREATE_WT_TO_OUTFEED type SEOCPDNAME value 'CREATE_WT_TO_OUTFEED' ##NO_TEXT.

  methods CREATE_STACK
    exporting
      !ES_HUHDR type /SCWM/S_HUHDR_INT
      !EV_EXCCODE type /SCWM/DE_EXCCODE
    raising
      /SCWM/CX_MFS .
  methods CREATE_WT_TO_OUTFEED
    importing
      !IV_CP type /SCWM/DE_MFSCP
      !IS_HUHDR type /SCWM/S_HUHDR_INT
    returning
      value(RV_TANUM) type /SCWM/TANUM
    raising
      /SL0/CX_GENERAL_EXCEPTION
      /SCWM/CX_MFS .
ENDCLASS.



CLASS ZCL_VI02_MFS_TELE_CONV_STK_POR IMPLEMENTATION.


  METHOD create_stack.

    DATA:  lv_processor TYPE string.

    "initialize
    CLEAR: ev_exccode,
           es_huhdr.
    TRY.
        DATA(lo_log) = NEW /scwm/cl_log( ).

        lv_processor = mc_processor_clprefix && '->' && me->mc_meth_create_stack.


        mio_log->start_log( EXPORTING iv_processor = lv_processor
                                      iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth
                                      is_telegram  = mis_telegram                      ).

        "Create dummy HU; as HU is unkown /wrong location
        CALL FUNCTION '/SCWM/MFS_DUMMY_HU_CREATE'
          EXPORTING
            iv_lgnum    = miv_lgnum
            iv_plc      = miv_plc
            iv_unknown  = 'X'
            is_telegram = mis_telegram
            io_log      = lo_log
          IMPORTING
            ev_exccode  = ev_exccode
            es_huhdr    = es_huhdr.

        mio_log->add_message(  it_bapiret = lo_log->get_prot( ) ).

        mio_log->end_log( EXPORTING iv_processor = lv_processor
                                    iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth
                                    is_telegram  = mis_telegram    ).

      CATCH cx_sy_dyn_call_illegal_type cx_sy_dyn_call_param_missing /sl0/cx_general_exception /scwm/cx_basics.
        /scwm/cx_mfs=>raise_exception( ).
    ENDTRY.

  ENDMETHOD.


  METHOD create_wt_to_outfeed.

      DATA: lv_severity  TYPE bapi_mtype,
            lv_processor TYPE string,
            ls_tmfscp    TYPE /scwm/tmfscp,
            ls_create_hu TYPE /scwm/s_to_crea_hu,
            lt_create_hu TYPE /scwm/tt_to_crea_hu,
            lt_changed   TYPE /scwm/tt_changed,
            lt_ordim     TYPE /scwm/tt_ordim_o_int,
            lt_bapiret   TYPE bapirettab,
            lv_message   TYPE string.

      lv_processor = mc_processor_clprefix && '->' && me->mc_meth_create_wt_to_outfeed.

      TRY.
*        mio_log = /sl0/cl_log_mfs=>initialize_log( EXPORTING iv_lgnum = miv_lgnum ).
          mio_log->start_log( EXPORTING iv_processor = lv_processor
                                        iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth
                                        is_telegram  = mis_telegram                       ).


          "Use outfeed destination from parameter framework.
          read_single_cp(
           EXPORTING
             iv_plc    = miv_plc            " Programmable Logic Controller
             iv_cp     = iv_cp              " Communication Point for Conveyor Technique
             iv_lgpla  = iv_cp              " Storage Bin
             iv_nobuf  = space              " Select data directly from database
           IMPORTING
             es_tmfscp = DATA(ls_tmsscp)    " Communication Points
             es_mfscp  = DATA(ls_mfscp) ).  " Communication Points - Application Data

          read_single_plc(
            EXPORTING
              iv_plc     = miv_plc             " Programmable Logic Controller
           IMPORTING
              es_tmfsplc = DATA(ls_tmfsplc) ). " PLC

            catch /sl0/cx_general_exception. " Error handling class
      ENDTRY.

      IF  ls_tmsscp-cp_clarify IS INITIAL.
        "the reject bin is missing in CP customizing
        MESSAGE e001(z_vi02_mfs) INTO /sl0/cl_log_mfs=>mv_dummy_msg.
        /scwm/cx_mfs=>raise_exception( iv_syst = abap_true ).
      ENDIF.

      IF  ls_tmfsplc-proctype_err IS INITIAL.
        "no process type for error case maintained in the PLC customizing
        MESSAGE e002(z_vi02_mfs) INTO /sl0/cl_log_mfs=>mv_dummy_msg.
        /scwm/cx_mfs=>raise_exception( iv_syst = abap_true ).
      ENDIF.

      ls_create_hu-nlpla = ls_tmsscp-cp_clarify .

      ls_create_hu-huident = is_huhdr-huident.
      ls_create_hu-procty = ls_tmfsplc-proctype_err.

      APPEND ls_create_hu TO lt_create_hu.

      MESSAGE i036(zew_3_mfs) WITH ls_create_hu-nlpla "Creating WT to outfeed &1 for stack &2
                                   ls_create_hu-huident
                              INTO lv_message.
      mio_log->add_message( iv_row = 0 ).

      CALL FUNCTION '/SCWM/TO_CREATE_MOVE_HU'
        EXPORTING
          iv_lgnum       = miv_lgnum
          iv_wtcode      = wmegc_wtcode_mfs
          iv_update_task = ' '
          iv_commit_work = ' '
          it_create_hu   = lt_create_hu
        IMPORTING
          ev_severity    = lv_severity
          et_bapiret     = lt_bapiret
          et_ltap_vb     = lt_ordim.

      mio_log->add_message( it_bapiret = lt_bapiret ).

      IF lv_severity CA 'AE' OR lt_ordim IS INITIAL.
        ROLLBACK WORK.
        /scwm/cl_tm=>cleanup( ).
*       write WT log to DB
        CALL FUNCTION '/SCWM/WT_WRITE_LOG'
          EXPORTING
            iv_lgnum    = miv_lgnum
            iv_severity = lv_severity
            it_bapiret  = lt_bapiret.
        COMMIT WORK AND WAIT.
*       add WT log also to MFS log
        mio_log->add_log( it_prot = lt_bapiret ).
      ELSE.
        IF lt_bapiret IS NOT INITIAL.
          mio_log->add_log( it_prot = lt_bapiret ).
        ENDIF.
        COMMIT WORK AND WAIT.
        READ TABLE lt_ordim ASSIGNING FIELD-SYMBOL(<ls_ordim>) INDEX 1.
        IF sy-subrc IS INITIAL.
          rv_tanum = <ls_ordim>-tanum.
        ENDIF.
      ENDIF.

      TRY.
          mio_log->end_log( EXPORTING iv_processor    =  lv_processor
                                      iv_proc_type    =  /sl0/cl_log_abstract=>mc_proc_meth
                                      is_telegram     =  mis_telegram    ).
        CATCH /sl0/cx_general_exception.
        CATCH /scwm/cx_basics.
      ENDTRY.

    ENDMETHOD.


  METHOD process_por1.
************************************************************************
* Company     : Swisslog AG
*
* Package     : /SL0/MFS
* Method      : N/A
* Function    : /SL0/MFSACT_TELE_CONV_POR1
* Enhancement : MFS Action FM
* Description :
* This FM is called from fm /SCWM/MFS_PROCESS_TELE_Q, when a Telegram
*   Category I (Location empty) is received.
* If the telegram contains an error code function module
*   /SCWM/MFS_REQ_EXCEPTION is called to handle the exception and
*   trigger the follow-up actions. If the telegram contains no error, It
*   will be checked, that the Location is filled in the Telegram. After
*   this, the BAdI /SCWM/EX_MFS_ACT_LOC_EMPTY is called, for detecting
*   a specific Warehouse Task and/or Queue (an example implementation
*   will be provided). Then the FM /SCWM/MFS_WT_DET_PREP is called
*   asynchronously to trigger the telegram sending to the PLC.
* This FM is a Swisslog adapted copy of SAP Standard FM '/SCWM/MFSACT_LOC_EMPTY'
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦   Date   ¦  Author  ¦ Description
* ------- ¦ -------- ¦ -------- ¦ --------------------------------------
* 1.0     ¦2016-04-28¦ B7TARAH  ¦ Initial version
* 1.1     ¦2016-08-16¦ B7GOKHN  ¦ SCI Adjustments
* 2.0     ¦2018-05-04¦ B7GOKHN  ¦ Technical refactoring
* 2.1     ¦2022-05-17¦ G7GUERM  ¦ Log refactoring
************************************************************************

    " ------------------------------------------ "
    "  Local Declarations..
    " ------------------------------------------ "

    DATA : lv_msgtext   TYPE bapi_msg,                      "#EC NEEDED
           lv_who       TYPE /scwm/de_who,
           lv_task      TYPE char20,
           ls_t340d     TYPE /scwm/t340d,
           lx_mfs       TYPE REF TO /scwm/cx_mfs,
           lv_processor TYPE string.

    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "

    TRY .
        MESSAGE i032(/sl0/mfs) WITH is_telegram-cp INTO lv_msgtext.
        mio_log->add_message( iv_row = 0 ).
        " add start time and WP process ID to log
        TRY.
            " Register begin of protocol logging..
            mio_log->start_log( EXPORTING iv_processor = lv_processor
                                          iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth
                                          is_telegram  = mis_telegram ).
          CATCH /sl0/cx_general_exception .             "#EC NO_HANDLER
        ENDTRY.

        IF NOT is_telegram-mfs_error CO ' _0'.  " error
          " Error reported from MFS
          CALL FUNCTION '/SCWM/MFS_REQ_EXCEPTION'
            EXPORTING
              iv_lgnum    = miv_lgnum
              iv_plc      = miv_plc
              iv_channel  = miv_channel
              is_telegram = is_telegram
              io_log      = mio_log->/sl0/if_log~get_sap_log( ).
          RETURN.
        ENDIF.
        COMMIT WORK.
        lv_task = is_telegram-cp.


        create_stack(  IMPORTING  es_huhdr   = DATA(ls_huhdr)      " Internal Structure for Processing HU Headers
                                  ev_exccode = DATA(ev_exccode) ). " Exception Code

        create_wt_to_outfeed( EXPORTING iv_cp    = is_telegram-cp
                                        is_huhdr = ls_huhdr ).

        "give system time to send telegramm and update assigment id.
*        WAIT UP TO 2 SECONDS.

        " Call MFS_WT_DET_PREP..
        me->call_mfs_wt_det_prep( EXPORTING is_telegram = is_telegram
                                            iv_task     = lv_task ).

      CATCH /scwm/cx_mfs INTO lx_mfs .
        MESSAGE ID lx_mfs->if_t100_message~t100key-msgid
                TYPE lx_mfs->mv_msgty
                NUMBER lx_mfs->if_t100_message~t100key-msgno
                WITH lx_mfs->mv_msgv1 lx_mfs->mv_msgv2
                     lx_mfs->mv_msgv3 lx_mfs->mv_msgv4
                INTO lv_msgtext.
        mio_log->add_message( iv_row = 0 ).
        " write log to DB
        " add end time to log
        TRY.
            " Finalize logging..
            mio_log->end_log( EXPORTING iv_processor = lv_processor
                                        iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth ).
          CATCH /sl0/cx_general_exception .             "#EC NO_HANDLER
          CATCH /scwm/cx_basics .                       "#EC NO_HANDLER
        ENDTRY.
        MESSAGE i008(/sl0/mfs) WITH me->mc_meth_process_por1 INTO lv_msgtext.
        mio_log->add_message( iv_row = 0 ).
        TRY.
            mio_log->write_log( iv_plc          = miv_plc
                                iv_processor    = lv_processor
                                iv_huident      = mis_telegram-huident
                                iv_sequno       = mis_telegram-sequ_no
                                iv_who          = lv_who ).
          CATCH /scwm/cx_basics .                       "#EC NO_HANDLER
          CATCH /sl0/cx_general_exception .             "#EC NO_HANDLER
        ENDTRY.
        RAISE EXCEPTION lx_mfs.
    ENDTRY.
    " write log to DB
    " add end time to log
    TRY.
        " Finalize logging..
        mio_log->end_log( EXPORTING iv_processor = lv_processor
                                    iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth ).
      CATCH /sl0/cx_general_exception .                 "#EC NO_HANDLER
      CATCH /scwm/cx_basics .                           "#EC NO_HANDLER
    ENDTRY.
    MESSAGE i008(/sl0/mfs) WITH me->mc_meth_process_por1 INTO lv_msgtext.
    mio_log->add_message( iv_row = 0 ).
    TRY.
        mio_log->write_log( iv_plc          = miv_plc
                            iv_processor    = lv_processor
                            iv_huident      = mis_telegram-huident
                            iv_cp           = mis_telegram-cp
                            iv_sequno       = mis_telegram-sequ_no
                            iv_who          = lv_who ).
      CATCH /scwm/cx_basics .                           "#EC NO_HANDLER
      CATCH /sl0/cx_general_exception .                 "#EC NO_HANDLER
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
