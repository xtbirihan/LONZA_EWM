class ZCL_VI02_MFS_TELE_CONV_DST_POR definition
  public
  inheriting from /SL0/CL_MFS_TELE_CONV_POR
  final
  create public .

public section.
protected section.

  methods PROCESS_POR0
    redefinition .
private section.

  constants MC_PROCESSOR_CLPREFIX type SEOCLSNAME value 'CL_DESTACKER_POR' ##NO_TEXT.
  constants MC_METH_PROCESS_POR0 type SEOCPDNAME value 'PROCESS_POR0' ##NO_TEXT.
  constants MC_METH_PROCESS_POR1 type SEOCPDNAME value 'PROCESS_POR1' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_VI02_MFS_TELE_CONV_DST_POR IMPLEMENTATION.


  method PROCESS_POR0.
************************************************************************
* Company     : Swisslog AG
*
* Package     : /SL0/MFS
* Method      : N/A
* Function    : /SL0/MFSACT_TELE_CONV_POR0
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
* Version ¦   Date    ¦  Author  ¦ Description
* ------- ¦ --------  ¦ -------- ¦ --------------------------------------
* 1.0     ¦2016-04-28 ¦ B7TARAH  ¦ Initial version
* 1.1     ¦2016-08-16 ¦ B7GOKHN  ¦ SCI Adjustments
* 1.2     |2016-09-07 ¦ B7TARAH  ¦ Delete DUMMY HUs on CPs which are customized to do so
* 1.3     |2017-11-29 ¦ G7SAMBS  ¦ Delete empty HUs on CPs which are customized to do so
* 2.0     ¦2018-05-04 ¦ B7GOKHN  ¦ Technical refactoring
* 2.1     ¦2022-05-17 ¦ G7GUERM  ¦ Log refactoring
* 3.0     ¦2023-03-02 ¦ G7GUERM  ¦ ATC Check Refactoring
************************************************************************

    " ------------------------------------------ "
    "  Local Declarations..
    " ------------------------------------------ "

    DATA: lv_msgtext    TYPE bapi_msg,                      "#EC NEEDED
          lv_who        TYPE /scwm/de_who,
          ls_tmfscp     TYPE /scwm/tmfscp,
          ls_swl_mfscp  TYPE /sl0/t_mfscp,
          ls_lagp       TYPE /scwm/lagp,
          lt_ordim_o    TYPE /scwm/tt_ordim_o,
          lx_mfs        TYPE REF TO /scwm/cx_mfs,
          lv_ret_code   TYPE sysubrc,
          ls_huhdr_data TYPE /scwm/s_huhdr_int,
          lv_processor  TYPE string,
          lo_excp       TYPE REF TO /sl0/cx_general_exception.

    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "

    lv_processor = me->mc_processor_clprefix && me->mc_arr && me->mc_meth_process_por0.

    "MESSAGE i031(/sl0/mfs) WITH is_telegram-cp INTO lv_msgtext.
    MESSAGE i345(/sl0/mfs) WITH lv_processor is_telegram-cp INTO lv_msgtext.
    mio_log->add_message( iv_row = 0 ).


    IF NOT is_telegram-mfs_error CO ' _0'.  " error
*|      Error reported from MFS
      CALL FUNCTION '/SCWM/MFS_REQ_EXCEPTION'
        EXPORTING
          iv_lgnum    = miv_lgnum
          iv_plc      = miv_plc
          iv_channel  = miv_channel
          is_telegram = is_telegram
          io_log      = mio_log->/sl0/if_log~get_sap_log( ).
      RETURN.
    ENDIF.

*|    Get storage bin
    CLEAR lo_excp.
    TRY.
        me->read_single_cp( EXPORTING iv_plc    = miv_plc
                                      iv_cp     = mis_telegram-cp
                            IMPORTING es_tmfscp = ls_tmfscp ).
      CATCH /sl0/cx_general_exception INTO lo_excp.
    ENDTRY.
    IF lo_excp IS BOUND.
      /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
    ENDIF.

    CALL FUNCTION '/SCWM/LAGP_READ_SINGLE'
      EXPORTING
        iv_lgnum = miv_lgnum
        iv_lgpla = ls_tmfscp-lgpla
      IMPORTING
        es_lagp  = ls_lagp
      EXCEPTIONS
        OTHERS   = 99. "#EC NUMBER_OK

    IF sy-subrc <> 0.
      /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
    ENDIF.

    CALL FUNCTION '/SCWM/TO_READ_SRC'
      EXPORTING
        iv_lgnum   = miv_lgnum
        iv_lgtyp   = ls_lagp-lgtyp
        iv_lgpla   = ls_lagp-lgpla
      IMPORTING
        et_ordim_o = lt_ordim_o[]
      EXCEPTIONS
        OTHERS     = 0.

*|    only the WT for the given HU should be changed
    IF is_telegram-huident IS NOT INITIAL.
      DELETE lt_ordim_o[] WHERE vlenr NE is_telegram-huident.
    ENDIF.


*|    set all open WTs from this CP to in process because
*|    the CP is empty per definition

    LOOP AT lt_ordim_o[] INTO DATA(ls_ordim_o) WHERE tostat = wmegc_to_open
                                                 AND kzsub  = wmegc_kzsub_uebergeben.
**|      only update WTs, which are intended for sub system
*        CHECK ls_ordim_o-kzsub = wmegc_kzsub_relevant OR
*              ls_ordim_o-kzsub = wmegc_kzsub_uebergeben.

      TRY.
          NEW /sl0/cl_wt( i_lgnum    = ls_ordim_o-lgnum
                          i_tanum    = ls_ordim_o-tanum
                          is_ordim_o = ls_ordim_o )->update_kzsub( EXPORTING iv_kzsub = wmegc_kzsub_process ).
        CATCH /sl0/cx_general_exception.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msgtext.
          mio_log->add_message( iv_row = 0 ).
      ENDTRY.

      IF sy-subrc IS INITIAL.
        MESSAGE i246(/scwm/mfs) WITH ls_ordim_o-tanum INTO lv_msgtext.
        mio_log->add_message( iv_row = 0 ).
      ENDIF.

    ENDLOOP.

    COMMIT WORK.

    TRY.
        " Get Swisslog customizing for CP..
        me->read_swl_cp_custdata( EXPORTING iv_cp        = is_telegram-cp
                                  IMPORTING es_swl_mfscp = ls_swl_mfscp
                                            ev_subrc     = DATA(lv_subrc) ).
    ENDTRY.
    IF lv_subrc <> 0.
*|      log error but carry on anyway...
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          INTO lv_msgtext.
      mio_log->add_message( iv_row = 0 ).
    ELSE.

      IF ls_swl_mfscp-del_dummy_hu          = abap_true OR
         ls_swl_mfscp-del_empty_hu          = abap_true OR "<SSA-20171128
         ls_swl_mfscp-del_rejreason_on_por0 = abap_true.

        mo_mfs_hu->read_assignment_huhdr( EXPORTING iv_huident    = is_telegram-huident "set on /sl0/mfsact_tele_conv_por based on assignmentid
                                          IMPORTING es_huhdr_data = ls_huhdr_data
                                                    ev_ret_code   = lv_ret_code ).
      ENDIF.

      IF lv_ret_code IS INITIAL.
*|        Check if DUMMY HUs should be deleted on this CP
        IF ls_swl_mfscp-del_dummy_hu = abap_true.
          IF ls_huhdr_data-pmat EQ mo_mfs_hu->get_pmat_unknown_hu( iv_plc = miv_plc
                                                                   iv_cp  = is_telegram-cp ).
*|            A dummy HU let's try and delete it.
            MESSAGE i086(/sl0/mfs) WITH is_telegram-huident
                                        is_telegram-cp
                                   INTO lv_msgtext.
            mio_log->add_message( iv_row = 0 ).
            TRY.
                mo_mfs_hu->delete( EXPORTING iv_guid_hu = ls_huhdr_data-guid_hu ).
              CATCH /sl0/cx_general_exception.
                mio_log->add_message( iv_row = 0 ).
            ENDTRY.
*</REPLACE>
*<SSA-20171129>
          ENDIF.
        ENDIF.

        IF ls_swl_mfscp-del_empty_hu = abap_true.
          TRY.
              IF mo_mfs_hu->is_empty( is_huhdr = ls_huhdr_data ) NE abap_false.
*|                A logically empty HU (or empty pallet stack), let's try and delete it.
                MESSAGE i319(/sl0/mfs) WITH is_telegram-huident
                                            is_telegram-cp
                                       INTO lv_msgtext.
                mio_log->add_message( iv_row = 0 ).

                mo_mfs_hu->delete( EXPORTING iv_guid_hu = ls_huhdr_data-guid_hu ).
              ENDIF.

            CATCH /sl0/cx_general_exception.
              mio_log->add_message( iv_row = 0 ).
          ENDTRY.
        ENDIF.
*</SSA-20171129>

*|        Check if reject reason entries should be deleted here
        IF ls_swl_mfscp-del_rejreason_on_por0 = abap_true.
          "CREATE OBJECT lo_reject_reason.
*|          delete all entries for this HUIDENT.
          IF ls_huhdr_data-huident IS NOT INITIAL.
            mo_reject_reason->save( EXPORTING iv_huident = ls_huhdr_data-huident CHANGING co_mfs_log = mio_log ).
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    TRY .
        " Call WT_DET_PREP..
        me->call_mfs_wt_det_prep( EXPORTING is_telegram = is_telegram ).
      CATCH /scwm/cx_mfs INTO lx_mfs.
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
            " Persist log, if not already done..
            TRY.
                mio_log->end_log( EXPORTING iv_processor = lv_processor
                                            iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth ).
              CATCH /sl0/cx_general_exception.
              CATCH /scwm/cx_basics.
            ENDTRY.

            MESSAGE i344(/sl0/mfs) INTO lv_msgtext WITH lv_processor.
            mio_log->add_message( iv_row = 0 ).
            TRY.
                " Persist log..

                mio_log->write_log( iv_plc          = miv_plc
                                    iv_processor    = lv_processor
                                    iv_huident      = mis_telegram-huident
                                    iv_cp           = mis_telegram-cp
                                    iv_sequno       = mis_telegram-sequ_no
                                    iv_who          = lv_who ).
              CATCH /scwm/cx_basics .                   "#EC NO_HANDLER
              CATCH /sl0/cx_general_exception .         "#EC NO_HANDLER
            ENDTRY.
            RAISE EXCEPTION lx_mfs.
        ENDTRY.
        " write log to DB
        " add end time to log
        TRY.
            " Persist log, if not already done..
            mio_log->end_log( EXPORTING iv_processor = lv_processor
                                        iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth ).
          CATCH /sl0/cx_general_exception .             "#EC NO_HANDLER
          CATCH /scwm/cx_basics .                       "#EC NO_HANDLER
        ENDTRY.
        MESSAGE i344(/sl0/mfs) INTO lv_msgtext WITH lv_processor.
        mio_log->add_message( iv_row = 0 ).
        TRY.
            " Persist log..
            mio_log->write_log( iv_plc          = miv_plc
                                iv_processor    = lv_processor
                                iv_huident      = mis_telegram-huident
                                iv_cp           = mis_telegram-cp
                                iv_sequno       = mis_telegram-sequ_no
                                iv_who          = lv_who ).
          CATCH /scwm/cx_basics .                       "#EC NO_HANDLER
          CATCH /sl0/cx_general_exception .             "#EC NO_HANDLER
        ENDTRY.
    ENDTRY.

  endmethod.
ENDCLASS.
