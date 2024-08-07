CLASS zcl_vi02_mfs_tele_conv_ipr DEFINITION
  PUBLIC
  INHERITING FROM /sl0/cl_mfs_tele_conv_ipr
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS process_telegram
        REDEFINITION .
  PROTECTED SECTION.

    CONSTANTS:
      "! SAP's most significant bit is to the right, PLC's to the left. The values in the comment are those of PLC
      BEGIN OF mc_io_bit,
        "! 256: Scanner NOREAD
        scanner_no_read     TYPE int1 VALUE 8,
        "! 128: WMS data error
        wms_data_error      TYPE int1 VALUE 9,
        "! 64: Runner / Tunnel Error
        runner_tunnel_error TYPE int1 VALUE 10,
        "! 32: Weight Error
        weight_error        TYPE int1 VALUE 11,
        "! 16: Length Back Error
        lenght_back_error   TYPE int1 VALUE 12,
        "! 8: Length Front Error
        length_front_error  TYPE int1 VALUE 13,
        "! 4: Width Error Right
        width_error_right   TYPE int1 VALUE 14,
        "! 2: Width Error Left
        width_error_left    TYPE int1 VALUE 15,
        "! 1: Height Error
        height_error        TYPE int1 VALUE 16,
      END OF mc_io_bit .

    METHODS write_evtlog_and_rejreason
      IMPORTING
        !iv_reject_reason TYPE /scwm/de_mfs_error
        !is_telegram      TYPE /scwm/s_mfs_teletotal
        !iv_event_type    TYPE /sl0/de_eventtype OPTIONAL
        !iv_message       TYPE /sl0/de_message OPTIONAL
        !iv_param_1       TYPE string OPTIONAL
        !iv_param_2       TYPE string OPTIONAL
        !iv_param_3       TYPE string OPTIONAL
        !iv_param_4       TYPE string OPTIONAL
        !iv_param_5       TYPE string OPTIONAL
        !iv_param_6       TYPE string OPTIONAL
        !iv_param_7       TYPE string OPTIONAL
        !iv_param_8       TYPE string OPTIONAL
        !iv_param_9       TYPE string OPTIONAL
        !iv_param_10      TYPE string OPTIONAL
        !iv_dialog_type   TYPE string OPTIONAL
        !it_bapiret       TYPE bapirettab OPTIONAL
        !iv_processed_kz  TYPE xfeld OPTIONAL
        !iv_dummy_hu      TYPE /scwm/de_huident OPTIONAL .
    METHODS handle_unknown_hu
      IMPORTING
        !is_telegram         TYPE /scwm/s_mfs_teletotal
        VALUE(is_huhdr_data) TYPE /scwm/s_huhdr_int .
    METHODS move_hu
      IMPORTING
        !io_badi           TYPE REF TO /scwm/ex_mfs_act_sp
        !is_tmfsplc        TYPE /scwm/tmfsplc
        !is_tmfscp         TYPE /scwm/tmfscp
        !is_huhdr_data     TYPE /scwm/s_huhdr_int
        VALUE(is_telegram) TYPE /scwm/s_mfs_teletotal
        !iv_hex_iodata     TYPE t_hex_iodata
      RAISING
        /scwm/cx_mfs .
    METHODS move_hu_to_nio
      IMPORTING
        !iv_nlpla_clarif     TYPE /scwm/lgpla
        !is_telegram         TYPE /scwm/s_mfs_teletotal
        !is_huhdr_data       TYPE /scwm/s_huhdr_int
        !iv_proctype_err     TYPE /scwm/de_procty
        VALUE(iv_hex_iodata) TYPE t_hex_iodata
      RAISING
        /scwm/cx_mfs .
    METHODS determine_tutype
      IMPORTING
        !is_swl_mfscp TYPE /sl0/t_mfscp
        !is_telegram  TYPE /scwm/s_mfs_teletotal
        !iv_huident   TYPE /scwm/huident
      CHANGING
        !cv_tutype    TYPE /sl0/de_tutype .
    METHODS change_huhdr_attr
      IMPORTING
        !is_telegram   TYPE /scwm/s_mfs_teletotal
        !is_huhdr_data TYPE /scwm/s_huhdr_int
        !is_swl_mfscp  TYPE /sl0/t_mfscp
      RAISING
        /scwm/cx_mfs .
    METHODS get_huhdr_by_id
      IMPORTING
        !is_telegram      TYPE /scwm/s_mfs_teletotal
      EXPORTING
        !es_huhdr_data    TYPE /scwm/s_huhdr_int
        !ev_hex_iodata    TYPE t_hex_iodata
        !ev_reject_reason TYPE /scwm/de_mfs_error .
    METHODS check_hu_weight
      IMPORTING
        VALUE(is_swl_mfscp) TYPE /sl0/t_mfscp
        !is_huhdr_int       TYPE /scwm/s_huhdr_int
      CHANGING
        !cv_hex_iodata      TYPE t_hex_iodata
        !cs_telegram        TYPE /scwm/s_mfs_teletotal .
    METHODS adjust_location
      IMPORTING
        !is_ordim_o          TYPE /scwm/ordim_o
        !is_tmfscp           TYPE /scwm/tmfscp
        !is_telegram         TYPE /scwm/s_mfs_teletotal
      EXPORTING
        !ev_success          TYPE abap_bool
        !ev_dummy_hu_created TYPE abap_bool
        !ev_exccode          TYPE /scwm/de_exccode
      CHANGING
        !cs_huhdr_data       TYPE /scwm/s_huhdr_int .
    METHODS try_enqueue_hu
      IMPORTING
        is_telegram       TYPE /scwm/s_mfs_teletotal
        is_huhdr_data     TYPE /scwm/s_huhdr_int
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    METHODS match_barcode
      IMPORTING
        is_telegram      TYPE /scwm/s_mfs_teletotal
      EXPORTING
        ev_barcode       TYPE string
        ev_reject_reason TYPE /scwm/de_mfs_error
      CHANGING
        cs_huhdr_data    TYPE /scwm/s_huhdr_int
        cv_hex_iodata    TYPE t_hex_iodata.

    METHODS check_hu_dimensions
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VI02_MFS_TELE_CONV_IPR IMPLEMENTATION.


  METHOD adjust_location.
    CLEAR: ev_dummy_hu_created, ev_success, ev_exccode.

    " Adjust location.
    IF is_ordim_o-tanum IS INITIAL.
      "No Warehouse Task available at CP &1
      MESSAGE i103 INTO DATA(lv_msgtext) WITH is_tmfscp-cp_type.
      mio_log->add_message( iv_row = 0 ).
    ENDIF.

    " Adjust location..
    mo_mfs_hu->hu_adj_loc( EXPORTING iv_plc         = miv_plc
                                     iv_cp          = is_telegram-cp
                                     iv_lgpla       = is_telegram-source
                                     iv_telecat     = wmegc_mfs_telecat_ip
                                     is_telegram    = is_telegram
                           IMPORTING ev_exccode     = DATA(lv_exccode)
                                     ev_subrc       = DATA(lv_subrc)
                            CHANGING co_log         = mio_log
                                     cs_huhdr       = cs_huhdr_data ).

    IF lv_subrc IS NOT INITIAL.                             "#EC NEEDED
      " -----------------------------------------------------------
      " Adjust location failed, pallet will remain
      " stationary on I-Point. We dont want that so
      " we create a DUMMY HU and send it to the
      " clarification point.
      " This happens for instance when ID-Point processing
      " interferes with goods receipt posting....
      TRY .
          "HU_ADJ_LOC failed subrc &1 HU &2 VHI &3 CP &4
          MESSAGE w036(/sl0/mfs_a) INTO lv_msgtext WITH lv_subrc
                                                        cs_huhdr_data-huident
                                                        cs_huhdr_data-vhi
                                                        is_telegram-cp.
          mio_log->add_message( iv_row = 0 ).

          " HU unknown, creating a dummy one,
          CALL FUNCTION '/SCWM/MFS_DUMMY_HU_CREATE'
            EXPORTING
              iv_lgnum    = miv_lgnum
              iv_plc      = miv_plc
              iv_unknown  = 'X'
              is_telegram = is_telegram
              io_log      = mio_log->/sl0/if_log~get_sap_log( )
            IMPORTING
              ev_exccode  = lv_exccode
              es_huhdr    = cs_huhdr_data.

          " Dummy HU generated..
          " Must be directed to clarification bin.
          ev_dummy_hu_created = abap_true.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_param_1       = |{ cs_huhdr_data-huident }|
              iv_param_2       = |{ is_telegram-cp }|
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_adj_hu_2_loc
              is_telegram      = is_telegram
              iv_dummy_hu      = cs_huhdr_data-huident
          ).

        CATCH /scwm/cx_mfs INTO DATA(lx_mfs).
          MESSAGE e000 INTO lv_msgtext WITH lx_mfs->if_message~get_text( ).
          mio_log->add_message( iv_row = 0 ).

          RETURN.
      ENDTRY.
    ENDIF.

    ev_success = abap_true.

  ENDMETHOD.


  METHOD change_huhdr_attr.
    DATA lt_changed TYPE /scwm/tt_changed.
    "Update HU gross weight
    IF is_telegram-/sl0/weight IS NOT INITIAL AND
       is_telegram-/sl0/weight NE /sl0/if_mfs_tele_conv_c=>mc_9999999 AND
       is_telegram-/sl0/weight NE /sl0/if_mfs_tele_conv_c=>mc_0000000.

      DATA(ls_changed) = VALUE /scwm/s_changed( fieldname = 'G_WEIGHT' ).

      IF is_swl_mfscp-update_gweight = abap_true.

        "Subsystem UOM for weight must be maintained on I-Point to update gross weight
        IF is_swl_mfscp-weight_uom IS NOT INITIAL.

          "convert weight from telegram string to decimal
          ls_changed-value_q = is_telegram-/sl0/weight.

          mo_process_helper->unit_conversion_simple( EXPORTING iv_input         = ls_changed-value_q "measured weight
                                                               iv_no_type_check = 'X'
                                                               iv_unit_in       = is_swl_mfscp-weight_uom    " subsystem uom
                                                               iv_unit_out      = is_huhdr_data-unit_gw    " EWM unit of measure
                                                     IMPORTING ev_output        = ls_changed-value_q ).

          IF sy-subrc <> 0.
            "Weight conversion failed, HU &1 at CP &2 and weight &3
            MESSAGE e064 INTO DATA(lv_msgtext) WITH is_huhdr_data-huident
                                              is_telegram-cp
                                              ls_changed-value_q.
            mio_log->add_message( iv_row = 0 ).
          ELSE.
            APPEND ls_changed TO lt_changed.
          ENDIF.
        ELSE.
          "Subsystem weight UOM not maintained
          MESSAGE e065 INTO lv_msgtext WITH is_telegram-cp.
          mio_log->add_message( iv_row = 0 ).
        ENDIF.
      ENDIF.
    ENDIF.

    "Make sure retry flag for conveyor to monorail hand-over
    "for putaway in the highbay warehouse is reset.
    APPEND VALUE #( fieldname = '/SL0/RETRY_BIN_DET' ) TO lt_changed.

    IF is_telegram-/sl0/height IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/HEIGHT'
                      value_c   = is_telegram-/sl0/height ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/widthright IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/WIDTHRIGHT'
                      value_c   = is_telegram-/sl0/widthright ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/widthleft IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/WIDTHLEFT'
                      value_c   = is_telegram-/sl0/widthleft ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/lengthfront IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/LENGTHFRONT'
                      value_c   = is_telegram-/sl0/lengthfront ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/lengthback IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/LENGTHBACK'
                      value_c   = is_telegram-/sl0/lengthback ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/weight IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/WEIGHT'
                      value_c   = is_telegram-/sl0/weight ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/tunnel IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/TUNNEL'
                      value_c   = is_telegram-/sl0/tunnel ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/runner IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/RUNNER'
                      value_c   = is_telegram-/sl0/runner ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/scannererror IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/SCANNERERROR'
                      value_c   = is_telegram-/sl0/scannererror ) TO lt_changed.
    ENDIF.

    IF is_telegram-/sl0/tutype IS NOT INITIAL.
      APPEND VALUE #( fieldname = '/SL0/TUTYPE'
                      value_c   = is_telegram-/sl0/tutype ) TO lt_changed.
    ENDIF.

    "IO data is always updated to ensure it is set to 000 if
    "it was not explicitely set to something else
    APPEND VALUE #( fieldname = '/SL0/IODATA'
                    value_q   = is_huhdr_data-/sl0/iodata ) TO lt_changed.

    "update HU type in case changed during processing
    APPEND VALUE #( fieldname = 'LETYP'
                  value_c = is_huhdr_data-letyp ) TO lt_changed.

    "update assignment-ID in case it was generated during the processing
    APPEND VALUE #( fieldname = '/SL0/ASSIGNMENTID'
                        value_c   = is_huhdr_data-/sl0/assignmentid ) TO lt_changed.

    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    "  HU to be Rejected..
    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    IF is_telegram-mfs_error CN ' _0'.
      " Set the reason for rejection, make sure it exsists

      TRY.
          DATA(lv_exccode) = /sl0/cl_services_ewm=>get_exccode_details( i_lgnum   = miv_lgnum
                                                                  i_exccode = is_telegram-mfs_error )-exccode.

        CATCH /sl0/cx_general_exception .
          " Exception code does not exist..
          MESSAGE e018(/scwm/lm_ms) INTO lv_msgtext WITH lv_exccode.
          mio_log->add_message( iv_row = 0 ).
      ENDTRY.

      IF sy-subrc IS INITIAL.
        APPEND VALUE #( fieldname = 'MFSERROR'
                        value_c = lv_exccode ) TO lt_changed.

      ENDIF.
    ELSE.
      "No mfs_error then clear exception of HU
      APPEND VALUE #( fieldname = 'MFSERROR' ) TO lt_changed.
    ENDIF.

    " central cleanup
    /scwm/cl_tm=>cleanup( EXPORTING iv_lgnum = miv_lgnum ).

    " HU data of HU &1 being adjusted to data of telegram
    MESSAGE i181(/scwm/mfs) INTO lv_msgtext
                            WITH is_huhdr_data-huident.
    mio_log->add_message( iv_row = 0 ).
    TRY.
        " Change HU Header Attributes..
        CALL FUNCTION '/SCWM/HUHDR_ATTR_CHANGE'
          EXPORTING
            iv_guid_hu = is_huhdr_data-guid_hu
            it_changed = lt_changed.

        CLEAR: lt_changed.
      CATCH /scwm/cx_basics INTO DATA(lo_cx_basics).
        MESSAGE e000 INTO lv_msgtext WITH lo_cx_basics->if_message~get_text( ).
        mio_log->add_message( iv_row = 0 ).
    ENDTRY.

    DATA:
      lv_severity TYPE bapi_mtype,
      lt_bapiret  TYPE bapirettab.

    IF lo_cx_basics IS INITIAL.
      " Update Internal Warehouse Task Tables..
      CALL FUNCTION '/SCWM/TO_POST'
        EXPORTING
          iv_update_task = ' '
          iv_commit_work = ' '
        IMPORTING
          ev_severity    = lv_severity
          et_bapiret     = lt_bapiret.

      IF lv_severity CA wmegc_severity_ea.
        ROLLBACK WORK.                                 "#EC CI_ROLLBACK
        " Add WT log also to MFS log
        mio_log->add_log( it_prot = lt_bapiret ).

        /scwm/cl_tm=>cleanup( ).

        /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_hu_dimensions.
*--------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*--------------------------------------------------------------------------------*
*
* For dimensions, we only have to check for apparent sensor issues here.
* There was an implicit dimension check already as we were looking for a HU type
* based on TU type and HU dimensions
*--------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*----------------------Documentation of Changes----------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-10-26 ¦Yuriy Dzhenyeyev¦Initial
*--------------------------------------------------------------------------------*


    DATA : lv_msgtext       TYPE string,                    "#EC NEEDED
           lv_accept_weight TYPE boolean,
           lv_act_deviation TYPE /sl0/de_percentage_2d,
           lv_max_deviation TYPE /sl0/de_percentage_2d.

    IF mo_eventlog IS BOUND.
      " -> HEIGHT..
      CASE cs_telegram-/sl0/height.
        WHEN 0.
          " No sensor for height detection --> OK
        WHEN 9. "Sensor failure
          SET BIT: mc_io_bit-height_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_height
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> WIDTH LEFT..
      CASE cs_telegram-/sl0/widthleft.
        WHEN 0.
          " No sensor for height detection --> OK
        WHEN 9. "Sensor failure
          "set I/O data field.
          SET BIT: mc_io_bit-width_error_left OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_width_left
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> WIDTH RIGHT..
      CASE cs_telegram-/sl0/widthright.
        WHEN 0.
          " No sensor for width detection --> OK
        WHEN 9. "Sensor failure
          "set I/O data field.
          SET BIT: mc_io_bit-width_error_right OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_width_right
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> LENGTH FRONT..
      CASE cs_telegram-/sl0/lengthfront.
        WHEN 0.
          " No sensor for length detection --> OK
        WHEN 9. "Sensor failure
          "set I/O data field.
          SET BIT: mc_io_bit-length_front_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_length_front
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> LENGTH BACK..
      CASE cs_telegram-/sl0/lengthback.
        WHEN 0.
          " No sensor for length detection --> OK
        WHEN 9. "Sensor failure
          "set I/O data field.
          SET BIT: mc_io_bit-lenght_back_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_length_back
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> WEIGHT..
      CASE cs_telegram-/sl0/weight.
        WHEN 0.
          " No scale --> OK
        WHEN /sl0/if_mfs_tele_conv_c=>mc_9999999. "Sensor failure
          "set I/O data field.
          SET BIT: mc_io_bit-weight_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_weigh_failure
              is_telegram      = cs_telegram
          ).
        WHEN OTHERS.
          check_hu_weight(
            EXPORTING
              is_swl_mfscp  = cs_swl_mfscp
              is_huhdr_int  = is_huhdr_int
            CHANGING
              cv_hex_iodata = cv_hex_iodata
              cs_telegram   = cs_telegram
          ).
      ENDCASE.
      " -> TUNNEL..
      CASE cs_telegram-/sl0/tunnel.
        WHEN 0.
          " No Sensor for tunnel detection --> OK
        WHEN 1.
          " Tunnel OK
        WHEN OTHERS.
          " Tunnel not OK
          "set I/O data field.
          SET BIT: mc_io_bit-runner_tunnel_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_tunnel
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> RUNNER..
      CASE cs_telegram-/sl0/runner.
        WHEN 0.
          " No Sensor for runner detection --> OK
        WHEN 1.
          " Runner OK
        WHEN OTHERS.
          " Runner not OK
          "set I/O data field.
          SET BIT: mc_io_bit-runner_tunnel_error OF cv_hex_iodata TO 1.
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_runner
              is_telegram      = cs_telegram
          ).
      ENDCASE.
      " -> SCANNER ERROR..
      CASE cs_telegram-/sl0/scannererror.
        WHEN /sl0/if_mfs_tele_conv_c=>mc_000.
          " No scanner error
        WHEN OTHERS.
          " scanner error
          "set I/O data field.
          SET BIT: mc_io_bit-scanner_no_read OF cv_hex_iodata TO 1.
          " Set exception in case of scan error inspite of other parameters determined OK..
          cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.
          "no need to set mfs-error, it will have already been
          "set to MUFO whilst creating the the dummy HU

          write_evtlog_and_rejreason(
            EXPORTING
              iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_no_read
              is_telegram      = cs_telegram
          ).
      ENDCASE.
    ENDIF.

    DATA(lo_hu) = NEW /sl0/cl_mfs_hu( ).

    IF lo_hu->is_empty( is_huhdr = is_huhdr_int ).
      "should be height class 1, otherwise it is not empty
      IF cs_telegram-/sl0/height GT 1.
        SET BIT: mc_io_bit-height_error OF cv_hex_iodata TO 1.
        cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon. "own exception code 'not empty'?

        write_evtlog_and_rejreason(
          EXPORTING
            iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_height
            is_telegram      = cs_telegram
        ).
      ENDIF.

      "TODO: check weight in some way? Material Master of the PMAT + 10%?
    ENDIF.

  ENDMETHOD.


  METHOD check_hu_weight.
    DATA: lv_accept_weight TYPE abap_bool,
          lv_act_deviation TYPE /sl0/de_percentage_2d,
          lv_max_deviation TYPE /sl0/de_percentage_2d,
          lv_max_weight    TYPE /sl0/de_mfscp_max_weight.

    IF is_swl_mfscp-verify_weight = abap_true.
      TRY.
          CALL FUNCTION is_swl_mfscp-verify_weight_fm
            EXPORTING
              iv_measured_weight = cs_telegram-/sl0/weight
              cs_swl_mfscp       = is_swl_mfscp
              iv_huident         = is_huhdr_int-huident
              io_log             = mio_log->/sl0/if_log~get_sap_log( )
            IMPORTING
              ev_accept_weight   = lv_accept_weight
              ev_act_deviation   = lv_act_deviation
              ev_max_deviation   = lv_max_deviation.
        CATCH cx_sy_dyn_call_illegal_func.
          "Weight verification on for &1 but FM &2 NOT FOUND
          MESSAGE e072 INTO DATA(lv_msgtext)
                       WITH is_swl_mfscp-cp
                            is_swl_mfscp-verify_weight_fm.
          mio_log->add_message( iv_row = 0 ).
      ENDTRY.

      IF lv_accept_weight = abap_false.
        "set I/O data field.
        SET BIT: mc_io_bit-weight_error OF cv_hex_iodata TO 1.
        cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

        write_evtlog_and_rejreason(
          EXPORTING
            iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_plausi_weight
            is_telegram      = cs_telegram
            iv_param_1       = |{ cs_telegram-/sl0/weight }|
            iv_param_2       = |{ is_swl_mfscp-weight_uom }|
            iv_param_3       = |{ is_huhdr_int-g_weight }|
            iv_param_4       = |{ is_huhdr_int-unit_gw }|
            iv_param_5       = |{ lv_act_deviation }|
            iv_param_6       = |{ lv_max_deviation }|
        ).
      ENDIF.
    ENDIF.

    CLEAR lv_accept_weight.

    " Maximum check of weight required?
    IF is_swl_mfscp-max_weight_check = abap_true.
      TRY.
          CALL FUNCTION is_swl_mfscp-max_weight_fm
            EXPORTING
              is_telegram       = cs_telegram
              is_swl_mfscp      = is_swl_mfscp
              io_log            = mio_log
            IMPORTING
              ev_accept_weight  = lv_accept_weight
              ev_max_weight     = lv_max_weight
              ev_max_weight_uom = is_swl_mfscp-max_weight_uom.

          is_swl_mfscp-max_weight = lv_max_weight.

        CATCH cx_sy_dyn_call_illegal_func.
          MESSAGE e073 INTO lv_msgtext
                       WITH is_swl_mfscp-cp
                            is_swl_mfscp-max_weight_fm.
          mio_log->add_message( iv_row = 0 ).
      ENDTRY.

      IF lv_accept_weight = abap_false.
        "set I/O data field.
        SET BIT: mc_io_bit-weight_error OF cv_hex_iodata TO 1.
        cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.

        write_evtlog_and_rejreason(
          EXPORTING
            iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_over_weight
            is_telegram      = cs_telegram
            iv_param_1       = |{ cs_telegram-/sl0/weight }|
            iv_param_2       = |{ is_swl_mfscp-weight_uom }|
            iv_param_3       = |{ is_swl_mfscp-max_weight }|
            iv_param_4       = |{ is_swl_mfscp-max_weight_uom }|
        ).

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD determine_tutype.
    DATA lv_tutype      TYPE /sl0/de_tutype.

    TRY.
        CALL FUNCTION is_swl_mfscp-tutype_det_fm
          EXPORTING
            is_swl_mfscp = is_swl_mfscp
            is_telegram  = is_telegram
            iv_huident   = iv_huident
            io_log       = mio_log->/sl0/if_log~get_sap_log( )
          IMPORTING
            ev_tutype    = lv_tutype
          EXCEPTIONS
            OTHERS       = 99. "#EC NUMBER_OK

        "the above FM should make sure that the HU type and TU type are compatible!

        CHECK: sy-subrc IS INITIAL,
               lv_tutype IS NOT INITIAL.

        cv_tutype = lv_tutype.

      CATCH cx_sy_dyn_call_illegal_func.
        "TU Type determination on for &1 but FM &2 NOT FOUND
        MESSAGE e078 INTO DATA(lv_msgtext) WITH is_swl_mfscp-cp
                                          is_swl_mfscp-tutype_det_fm.
        mio_log->add_message( iv_row = 0 ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_huhdr_by_id.
    CLEAR: ev_hex_iodata,
           es_huhdr_data,
           ev_reject_reason.

    IF is_telegram-/sl0/assignmentid IS NOT INITIAL
      AND is_telegram-/sl0/assignmentid NE /sl0/if_mfs_tele_conv_c=>mc_00000000 " No assignment
      AND is_telegram-/sl0/assignmentid NE /sl0/if_mfs_tele_conv_c=>mc_99999999. " Assignment Unknown

      mo_mfs_hu->read_assignment_huhdr( EXPORTING iv_assignmentid = is_telegram-/sl0/assignmentid
                                        IMPORTING es_huhdr_data   = es_huhdr_data
                                                  ev_ret_code     = DATA(lv_ret_code) ).
    ELSEIF is_telegram-/sl0/tuid IS NOT INITIAL AND
       is_telegram-/sl0/tuid NE /sl0/if_mfs_tele_conv_c=>mc_18x0 AND " No TU ID
       is_telegram-/sl0/tuid NE /sl0/if_mfs_tele_conv_c=>mc_18x9.    " TU ID unknown

      mo_mfs_hu->read_assignment_huhdr( EXPORTING iv_huident      = CONV #( is_telegram-/sl0/tuid )
                                        IMPORTING es_huhdr_data   = es_huhdr_data
                                                  ev_ret_code     = lv_ret_code ).
    ENDIF.

    IF lv_ret_code IS NOT INITIAL.
      " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
      " HU Id could not be determined for incoming TU Id..
      " We are not going to try find a TU using the
      " barcode in the label field!
      " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
      "set I/O data field for unknown HU.
      SET BIT: mc_io_bit-wms_data_error OF ev_hex_iodata TO 1. "32: HU Unknown

      ev_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_hu_unknown.
    ENDIF.
  ENDMETHOD.


  METHOD handle_unknown_hu.
    mo_mfs_hu->hu_adj_loc( EXPORTING iv_plc         = miv_plc
                                     iv_cp          = is_telegram-cp
                                     iv_telecat     = wmegc_mfs_telecat_ip
                                     is_telegram    = is_telegram
                           IMPORTING ev_subrc       = DATA(lv_subrc)
                            CHANGING co_log         = mio_log
                                     cs_huhdr       = is_huhdr_data "this parameter is more or less pro forma here.
                                                                    "hu_adj_loc may result in creation of a dummy HU
                                                                    "instead of the one in question, but this is not
                                                                    "applicable to our case where we already operate
                                                                    "with a dummy HU
                                      ).

    IF lv_subrc IS NOT INITIAL.
      " Error, cancel the WT in case of a failure..
      mo_mfs_hu->mfs_wt_cancel( EXPORTING
                                  iv_huident  = is_huhdr_data-huident
                                  is_mfs_conf = VALUE /scwm/s_mfs_conf( )
                                IMPORTING
                                  ev_subrc    = lv_subrc
                                CHANGING
                                  co_log      = mio_log ).
    ENDIF.

    TRY.
        mo_mfs_hu->delete( iv_guid_hu = is_huhdr_data-guid_hu ).
      CATCH /sl0/cx_general_exception.
        mio_log->add_message( iv_row = 0 ).
    ENDTRY.

  ENDMETHOD.


  METHOD match_barcode.
    CLEAR: ev_barcode,
           ev_reject_reason.

    CHECK is_telegram-/sl0/scannererror IS INITIAL.

    IF cs_huhdr_data-huident IS INITIAL.
      "no HU determined, try to resolve using barcode.

      me->get_barcode_from_label( EXPORTING
                                    iv_label_length = is_telegram-/sl0/labellength
                                    iv_label        = is_telegram-/sl0/label
                                  CHANGING
                                    cv_barcode      = ev_barcode ).

      " Read HU assignment number..
      mo_mfs_hu->read_assignment_huhdr( EXPORTING
                                          iv_huident    = CONV #( ev_barcode )
                                        IMPORTING
                                          es_huhdr_data = cs_huhdr_data
                                          ev_ret_code   = DATA(lv_ret_code) ).

      " HU Id could not be determined for incoming TU Id i.e. barcode!
      IF lv_ret_code IS NOT INITIAL.

        SET BIT: mc_io_bit-wms_data_error OF cv_hex_iodata TO 1.

        ev_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_hu_unknown_bc.
      ENDIF.
    ELSE.
      " We found valid HU with assignment ID or TU ID.
      " Check whether the HU matches the scanned barcoded.
      me->get_barcode_from_label( EXPORTING
                                    iv_label_length = is_telegram-/sl0/labellength
                                    iv_label = is_telegram-/sl0/label
                                  CHANGING
                                    cv_barcode = ev_barcode ).

      IF |{ ev_barcode ALPHA = OUT }| NE |{ cs_huhdr_data-huident ALPHA = OUT }| .
        "Mismatch between tracked HU &1 and barcode &2
        MESSAGE w379 INTO DATA(lv_msgtext)
                     WITH cs_huhdr_data-huident
                          ev_barcode.
        mio_log->add_message( iv_row = 0 ).

        SET BIT: mc_io_bit-wms_data_error OF cv_hex_iodata TO 1.

        ev_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_hu_barcode_mismatch.

        CLEAR cs_huhdr_data.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD move_hu.
    DATA(ls_create_hu) = VALUE /scwm/s_to_crea_hu( huident = is_huhdr_data-huident ).

    "pass HUIDENT to BAdI
    is_telegram-huident = is_huhdr_data-huident.

    " Call to ID-Point Processing BAdI..
    IF io_badi IS BOUND.
      " BAdI: Determination of Putaway Bin (Destination Bin)..
      CALL BADI io_badi->det_dest_bin
        EXPORTING
          iv_lgnum    = miv_lgnum
          iv_plc      = miv_plc
          iv_channel  = miv_channel
          is_act_cp   = is_tmfscp
          is_telegram = is_telegram
        IMPORTING
          ev_lgpla    = ls_create_hu-nlpla
          ev_lgber    = ls_create_hu-nlber
          ev_lgtyp    = ls_create_hu-nltyp.
    ENDIF.

    " Destination for Next HU movement NOT yet determined, done below..
    IF is_tmfscp-proctype IS INITIAL.
      ls_create_hu-procty = is_tmfsplc-proctype.
    ELSE.
      ls_create_hu-procty = is_tmfscp-proctype.
    ENDIF.

    "Creating WT for HU &1
    MESSAGE i166(/scwm/mfs) INTO DATA(lv_msgtext)
                            WITH ls_create_hu-huident.
    mio_log->add_message( iv_row = 0 ).

    me->wt_create_move_hu( EXPORTING iv_update_task = ' '
                                     iv_commit_work = ' '
                                     iv_wtcode      = wmegc_wtcode_mfs
                                     it_create_hu   = VALUE #( ( ls_create_hu ) )
                           IMPORTING et_ltap_vb     = DATA(lt_ordim)
                                     et_bapiret     = DATA(lt_bapiret)
                                     ev_severity    = DATA(lv_severity) ).

    IF lv_severity CA wmegc_severity_ea OR lt_ordim IS INITIAL.

      ROLLBACK WORK.                                   "#EC CI_ROLLBACK

      /scwm/cl_tm=>cleanup( ).

      " write WT log to DB
      CALL FUNCTION '/SCWM/WT_WRITE_LOG'
        EXPORTING
          iv_lgnum    = miv_lgnum
          iv_severity = lv_severity
          it_bapiret  = lt_bapiret.

      COMMIT WORK AND WAIT.

      " Add WT log also to MFS log
      mio_log->add_log( it_prot = lt_bapiret ).

      IF is_tmfscp-cp_clarify IS NOT INITIAL.
        TRY.
            me->read_single_cp( EXPORTING iv_plc    = is_tmfscp-plc_clarify
                                          iv_cp     = is_tmfscp-cp_clarify
                                IMPORTING es_tmfscp = DATA(ls_tmfscp_cla) ).

          CATCH /sl0/cx_general_exception.              "#EC NO_HANDLER
            /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
        ENDTRY.

        "Move HU to Clarification Bin
        move_hu_to_nio(
          EXPORTING
            iv_nlpla_clarif = ls_tmfscp_cla-lgpla
            is_telegram = is_telegram
            iv_hex_iodata = iv_hex_iodata
            is_huhdr_data = is_huhdr_data
            iv_proctype_err = is_tmfsplc-proctype_err ).
      ELSE.
        /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD move_hu_to_nio.
    " Move HU..
    me->wt_create_move_hu( EXPORTING iv_update_task = ' '
                                     iv_commit_work = ' '
                                     iv_wtcode      = wmegc_wtcode_mfs_cla
                                     it_create_hu   = VALUE #( ( huident = is_huhdr_data-huident
                                                                 procty  = iv_proctype_err
                                                                 nlpla   = iv_nlpla_clarif
                                                                 norou   = wmegc_norou_yes ) )
                           IMPORTING et_ltap_vb     = DATA(lt_ordim)
                                     et_bapiret     = DATA(lt_bapiret)
                                     ev_severity    = DATA(lv_severity) ).

    IF lv_severity CA wmegc_severity_ea OR lt_ordim IS INITIAL.

      ROLLBACK WORK.                                  "#EC CI_ROLLBACK.
      /scwm/cl_tm=>cleanup( ).

      " Write WT log to DB..
      CALL FUNCTION '/SCWM/WT_WRITE_LOG'
        EXPORTING
          iv_lgnum    = miv_lgnum
          iv_severity = lv_severity
          it_bapiret  = lt_bapiret.
      COMMIT WORK AND WAIT.

      " Add WT log also to MFS log
      mio_log->add_log( it_prot = lt_bapiret ).

      /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).

    ELSE.
      DELETE lt_bapiret WHERE parameter <> wmegc_wtcode_mfs.

      IF lt_bapiret IS NOT INITIAL.
        mio_log->add_log( it_prot = lt_bapiret ).
      ENDIF.

      "Add log entry and reject reason to show the user at NIO
      write_evtlog_and_rejreason(
        EXPORTING
          iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_no_dest
          is_telegram      = is_telegram
          iv_param_1       = |{ is_huhdr_data-huident }|
      ).

      mo_reject_reason->save( EXPORTING iv_huident = is_huhdr_data-huident
                               CHANGING co_mfs_log = mio_log ).

      SET BIT: mc_io_bit-wms_data_error OF iv_hex_iodata TO 1.

      " central cleanup
      /scwm/cl_tm=>cleanup( EXPORTING iv_lgnum = miv_lgnum ).

      "HU data of HU &1 being adjusted to data of telegram
      MESSAGE i181(/scwm/mfs) INTO DATA(lv_msgtext)
                              WITH is_huhdr_data-huident.

      mio_log->add_message( iv_row = 0 ).

      TRY.
          " Change HU Header Attributes..
          CALL FUNCTION '/SCWM/HUHDR_ATTR_CHANGE'
            EXPORTING
              iv_guid_hu = is_huhdr_data-guid_hu
              it_changed = VALUE /scwm/tt_changed( ( fieldname = '/SL0/IODATA'
                                                     value_c   = iv_hex_iodata ) ).

        CATCH /scwm/cx_basics INTO DATA(lx_basics).     "#EC NO_HANDLER
          MESSAGE e000 INTO lv_msgtext WITH lx_basics->if_message~get_text( ).
          mio_log->add_message( iv_row = 0 ).
      ENDTRY.

      CALL FUNCTION '/SCWM/TO_POST'
        EXPORTING
          iv_update_task = ' '
          iv_commit_work = ' '
        IMPORTING
          ev_severity    = lv_severity
          et_bapiret     = lt_bapiret.

      IF lv_severity CA 'EA'.
        ROLLBACK WORK.
        /scwm/cl_tm=>cleanup( ).

*         add WT log to MFS log
        mio_log->add_log( it_prot = lt_bapiret ).
        /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD process_telegram.

    " Make local copy of the telegram data
    DATA(ls_wa_telegram) = mis_telegram.

    " Initialization..
    DATA(lv_processor) = me->mc_processor_clprefix && me->mc_arr && me->mc_meth_process_telegram.

    TRY.
*           Initialize log protocol instance..
        mio_log ?= /sl0/cl_log_factory=>get_logger_instance( EXPORTING iv_lgnum    = miv_lgnum
                                                                       io_log      = mio_log ).
        " Register begin of protocol logging..
        mio_log->start_log( EXPORTING iv_processor = lv_processor
                                      iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth
                                      is_telegram   = mis_telegram ).
      CATCH /sl0/cx_general_exception .                 "#EC NO_HANDLER
    ENDTRY.

    DATA lo_badi TYPE REF TO /scwm/ex_mfs_act_sp.

    TRY .
        GET BADI lo_badi
          FILTERS
            lgnum = miv_lgnum.
      CATCH cx_badi INTO DATA(lx_badi).
        IF lx_badi IS BOUND.
          MESSAGE s000 INTO DATA(lv_msgtext)
                       WITH lx_badi->if_message~get_text( ).
          mio_log->add_message( iv_row = 0 ).
        ENDIF.
    ENDTRY.

    DO 1 TIMES.

      TRY.
          IF ls_wa_telegram-cp IS NOT INITIAL.
            "Processing communication point &1 &2
            MESSAGE i198(/scwm/mfs) WITH
              miv_plc
              ls_wa_telegram-cp
              INTO lv_msgtext.

            mio_log->add_message( iv_row = 0 ).
          ENDIF.

          " Read Swisslog customizing for CP..
          me->read_swl_cp_custdata( EXPORTING iv_cp        = ls_wa_telegram-cp
                                    IMPORTING es_swl_mfscp = DATA(ls_swl_mfscp) ).

          get_huhdr_by_id(
            EXPORTING
              is_telegram     = ls_wa_telegram
            IMPORTING
              es_huhdr_data    = DATA(ls_huhdr_data)
              ev_hex_iodata    = DATA(lv_hex_iodata)
              ev_reject_reason = DATA(lv_reject_reason)
          ).

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "If we have a HU then let's check if the packaging material
          "is associated with the packaging material for dummy HU's
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          IF ls_huhdr_data-huident IS NOT INITIAL.
            DATA(lv_pmat_ufo) = mo_mfs_hu->get_pmat_unknown_hu( iv_plc = miv_plc
                                                          iv_cp = mis_telegram-cp ).
            IF lv_pmat_ufo = ls_huhdr_data-pmat.
              " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
              "  Handle dummy HU at I-Point (confirm WT, delete HU)
              " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
              handle_unknown_hu(
                EXPORTING
                  is_telegram = ls_wa_telegram
                  is_huhdr_data = ls_huhdr_data
              ).

              CLEAR ls_huhdr_data.
            ENDIF.
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "Try and find HU using barcode as scanned by barcode reader
          "We do this when we did not find a HU using assignment ID or
          "TU ID from the IPR message earlier or if we've just processed
          "a dummy HU arrving at the I-Point.
          "
          " If we have already determined the HU by Assignment- or TU-ID,
          " make sure it matches the barcode.
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          match_barcode(
            EXPORTING
              is_telegram      = ls_wa_telegram
            IMPORTING
              ev_barcode       = DATA(lv_barcode)
              ev_reject_reason = lv_reject_reason
            CHANGING
              cs_huhdr_data    = ls_huhdr_data
              cv_hex_iodata    = lv_hex_iodata ).

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Validate HU / Generate Dummy HU..
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

          IF ls_huhdr_data-huident IS NOT INITIAL.
            " lock HU in advance to be able to check if the HU
            " couldn't be locked or if the HU is not there.
            " FM /SCWM/HU_READ gives always NOT_FOUND.
            "
            "If not successful, ls_huhdr_data will be cleared.

            IF NOT try_enqueue_hu( is_telegram   = ls_wa_telegram
                                   is_huhdr_data = ls_huhdr_data ).

              CLEAR ls_huhdr_data.
            ENDIF.
          ENDIF.

          IF ls_huhdr_data-huident IS INITIAL.
            TRY.
                DATA lv_exccode TYPE /scwm/de_exccode.

                " HU unknown, creating a dummy one, reason for doing so will have being logged earlier.
                CALL FUNCTION '/SCWM/MFS_DUMMY_HU_CREATE'
                  EXPORTING
                    iv_lgnum    = miv_lgnum
                    iv_plc      = miv_plc
                    iv_unknown  = 'X'
                    is_telegram = ls_wa_telegram
                    io_log      = mio_log->/sl0/if_log~get_sap_log( )
                  IMPORTING
                    ev_exccode  = lv_exccode
                    es_huhdr    = ls_huhdr_data.

                IF ls_wa_telegram-mfs_error CO ' _0'.
                  ls_wa_telegram-mfs_error = lv_exccode.
                ENDIF.

                " Dummy HU generated..
                " Will be directed to clarification bin.
                DATA(lv_dummy_hu) = abap_true.

              CATCH /scwm/cx_mfs INTO DATA(lx_mfs).
                IF lx_mfs IS BOUND.
                  MESSAGE e000 INTO lv_msgtext WITH lx_mfs->if_message~get_text( ).
                  mio_log->add_message( iv_row = 0 ).
                  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  "  If we should have created a DUMMY HU but we cann't, then we can
                  "  terminate here, we will not be able to move the pallet.
                  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  EXIT. "finalize the log, return
                ENDIF.
            ENDTRY.
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Get the HU type.
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

          "TODO: HUTYP darf anhand der Höhe umdefiniert werden.
          "      Breite und Länge führen zu Fehlermeldung
          "      ev. erst nach check_hu_dimensions
          ">>>>>>>>>>>>
          IF lo_badi IS BOUND.
            " BAdi: Redetermine HU Type..
            "Lonza: implicit check against TU Dimensions (/sl0/t_tutypemap)
            CALL BADI lo_badi->change_hutyp
              EXPORTING
                iv_lgnum    = miv_lgnum
                iv_plc      = miv_plc
                iv_channel  = miv_channel
                is_telegram = ls_wa_telegram
              IMPORTING
                ev_hutyp    = DATA(lv_hutyp_new).
          ENDIF.

          IF lv_hutyp_new IS INITIAL.
            "No HUTYP found for this TU and dimensions
            SET BIT: mc_io_bit-wms_data_error OF cv_hex_iodata TO 1.
            cs_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_mcon.
          else.
            AND lv_hutyp_new NE ls_huhdr_data-letyp.
            " Check HUTYP for existence, mark an exception in case it does not..
            CALL FUNCTION '/SCWM/T307_READ_SINGLE'
              EXPORTING
                iv_lgnum    = miv_lgnum
                iv_letyp    = lv_hutyp_new
              EXCEPTIONS
                not_found   = 1
                wrong_input = 2
                OTHERS      = 3.

            IF sy-subrc IS INITIAL.
              "change HU type
              ls_huhdr_data-letyp = lv_hutyp_new.
            ELSE.
              "HU type & does not exist in warehouse number &2 (check your entry)
              MESSAGE e204(/scwm/l3) INTO lv_msgtext
                                     WITH lv_hutyp_new
                                          miv_lgnum.

              /scwm/cx_mfs=>raise_exception( iv_syst = 'X' ).
            ENDIF.
          ENDIF.
          "<<<<<<<<<<<<<<<<<<

          " Read CP data
          TRY.
              me->read_single_cp( EXPORTING iv_plc    = miv_plc
                                            iv_cp     = ls_wa_telegram-cp
                                  IMPORTING es_tmfscp = DATA(ls_tmfscp) ).
            CATCH /sl0/cx_general_exception.            "#EC NO_HANDLER
          ENDTRY.

          " Read PLC Structure.
          TRY.
              me->read_single_plc( EXPORTING iv_plc     = miv_plc
                                   IMPORTING es_tmfsplc = DATA(ls_tmfsplc) ).
            CATCH /sl0/cx_general_exception .           "#EC NO_HANDLER
          ENDTRY.

          IF ls_huhdr_data-huident IS NOT INITIAL.
            IF lv_dummy_hu IS INITIAL. "Normal behavior

              " Read WT for HU for MFS..
              mo_mfs_hu->to_read_hu_mfs( EXPORTING  iv_huident     = ls_huhdr_data-huident
                                         IMPORTING  ev_tanum_inact = DATA(lv_wtnum_inact)
                                                    es_ordim_o     = DATA(ls_ordim_o)
                                                    et_ordim_o     = DATA(lt_ordim_o)
                                         EXCEPTIONS OTHERS         = 0 ).

              "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              " Adjust location of HU.
              " MFS_HU_ADJ_LOC may create a dummy HU if for instance
              " it does not like the current position of the HU!
              "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              adjust_location(
                      EXPORTING
                        is_ordim_o    = ls_ordim_o
                        is_tmfscp = ls_tmfscp
                        is_telegram = ls_wa_telegram
                      IMPORTING
                        ev_dummy_hu_created = lv_dummy_hu
                        ev_success = DATA(lv_success)
                        ev_exccode = lv_exccode
                      CHANGING
                        cs_huhdr_data = ls_huhdr_data "will create dummy HU if adjust location fails
                         ).

              IF ls_wa_telegram-mfs_error CO ' _0'
                AND lv_exccode IS NOT INITIAL.
                "Make sure that if dummy HU was created HU will have
                "an exception set and subsequently be rejected to NIO
                ls_wa_telegram-mfs_error = lv_exccode.
              ENDIF.

              "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              "  If we should have created a DUMMY HU but we cann't, then we can
              "  terminate here, we will not be able to move the pallet.
              "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              CHECK lv_success = abap_true. "otherwise exit do, finalize the log, return
            ELSE.
              " Dummy HU was created. For what reason?
              CASE lv_reject_reason.
                WHEN /sl0/if_mfs_tele_conv_c=>mc_exc_hu_unknown.
                  write_evtlog_and_rejreason(
                    EXPORTING
                      iv_reject_reason = lv_reject_reason
                      is_telegram      = ls_wa_telegram
                      iv_param_1       = |{ ls_wa_telegram-/sl0/tuid }|
                      iv_param_2       = |{ ls_wa_telegram-/sl0/assignmentid }|
                      iv_param_3       = |{ lv_barcode }|
                      iv_dummy_hu      = |{ ls_huhdr_data-huident }|
                  ).
                WHEN /sl0/if_mfs_tele_conv_c=>mc_exc_hu_barcode_mismatch.
                  write_evtlog_and_rejreason(
                    EXPORTING
                      iv_reject_reason = lv_reject_reason
                      is_telegram      = ls_wa_telegram
                      iv_param_1       = |{ lv_barcode }|
                      iv_param_2       = |{ ls_wa_telegram-/sl0/assignmentid }|
                      iv_param_3       = |{ ls_huhdr_data-huident }| ).
                WHEN /sl0/if_mfs_tele_conv_c=>mc_exc_hu_unknown_bc.
                  write_evtlog_and_rejreason(
                    EXPORTING
                      iv_reject_reason = lv_reject_reason
                      is_telegram      = ls_wa_telegram
                      iv_param_1       = |{ lv_barcode }|
                      iv_dummy_hu      = |{ ls_huhdr_data-huident }|
                  ).
              ENDCASE.
            ENDIF.
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          " Additional checks using BAdI /scwm/ex_mfs_act_sp
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

          IF lo_badi IS BOUND.
            " BAdI: Additional checks at start bin..
            CALL BADI lo_badi->check
              EXPORTING
                iv_lgnum    = miv_lgnum
                iv_plc      = miv_plc
                iv_channel  = miv_channel
                is_telegram = ls_wa_telegram
              IMPORTING
                ev_error    = DATA(lv_error)
                ev_exccode  = lv_exccode
                ev_no_async = cv_no_async.

            IF lv_exccode IS NOT INITIAL.
              ls_wa_telegram-mfs_error = lv_exccode.
            ENDIF.

            IF cv_no_async IS NOT INITIAL.
              "Asynchronous call of action function module deactivated
              MESSAGE i293(/scwm/mfs) INTO lv_msgtext.
              mio_log->add_message( iv_row = 0 ).
            ENDIF.

            CHECK lv_error IS INITIAL. "otherwise exit do, finalize the log, return
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          " Re-determination of TU Type required?
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          IF ls_swl_mfscp-tutype_det = abap_true.
            determine_tutype(
              EXPORTING
                is_swl_mfscp = ls_swl_mfscp
                is_telegram  = ls_wa_telegram
                iv_huident   = ls_huhdr_data-huident
              CHANGING
                cv_tutype    = ls_huhdr_data-/sl0/tutype ).
          ENDIF.

          "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          "  Check if HU is logically empty --> Reject.
          "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          TRY.
              IF mo_mfs_hu->is_empty( is_huhdr = ls_huhdr_data ) EQ abap_true.

                " A logically empty HU detected, send to clarification bin
                " Set MFS Error: Logically Empty HU (ZHUE).
                ls_wa_telegram-mfs_error = /sl0/if_mfs_tele_conv_c=>mc_exccode_zhue.

                write_evtlog_and_rejreason(
                  EXPORTING
                    iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exccode_zhue
                    is_telegram      = ls_wa_telegram
                    iv_param_1       = |{ ls_huhdr_data-huident }|
                    iv_param_2       = |{ ls_huhdr_data-letyp }|
                    iv_param_3       = |{ ls_wa_telegram-cp }|
                    iv_param_4       = |{ ls_huhdr_data-/sl0/tutype }|
                ).

                "HU &1 (Type &2) determined as logically empty at CP &3.
                MESSAGE w320(/sl0/mfs) INTO lv_msgtext
                                       WITH ls_huhdr_data-huident
                                            ls_huhdr_data-letyp
                                            ls_wa_telegram-cp.
                mio_log->add_message( iv_row = 0 ).
              ENDIF.
            CATCH /sl0/cx_general_exception.
              mio_log->add_message( iv_row = 0 ).
          ENDTRY.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Evaluating HU parameters received within IPR..
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          me->check_hu_dimensions( EXPORTING is_huhdr_int  = ls_huhdr_data
                                   CHANGING  cs_swl_mfscp  = ls_swl_mfscp
                                             cs_telegram   = ls_wa_telegram
                                             cv_hex_iodata = lv_hex_iodata ).

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          " Get Assignment ID if none has been set yet
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          IF ls_huhdr_data-/sl0/assignmentid IS INITIAL.

* gdzhey22c TODO: there is an instance method /sl0/cl_mfs_send_tele_q->get_assignment_id
            DATA lv_asgnid TYPE /sl0/de_assignmentid.
            PERFORM get_assignment_id IN PROGRAM /sl0/saplmfs_tele_send
                                      USING miv_lgnum
                                            ls_huhdr_data-huident
                                      CHANGING ls_huhdr_data-/sl0/assignmentid.
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Update HU Data..
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          ls_huhdr_data-/sl0/iodata = lv_hex_iodata.

          change_huhdr_attr(
            EXPORTING
              is_telegram   = ls_wa_telegram
              is_huhdr_data = ls_huhdr_data
              is_swl_mfscp  = ls_swl_mfscp
          ).

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Write reject reasons for HU to database
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          mo_reject_reason->save(
                              EXPORTING
                                iv_huident = ls_huhdr_data-huident
                              CHANGING
                                co_mfs_log = mio_log ).

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  If profile error, no read, uknown HU etc then
          "  now is the time to determine the NIO dest.
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          IF ls_wa_telegram-mfs_error CN ' _0'.
            " Error reported from MFS

            " Send to clarification bin
            CALL FUNCTION '/SCWM/MFS_REQ_EXCEPTION'
              EXPORTING
                iv_lgnum     = miv_lgnum
                iv_plc       = miv_plc
                iv_channel   = miv_channel
                is_telegram  = ls_wa_telegram
                is_huhdr_int = ls_huhdr_data
*               iv_exccode_mfs = lv_exccode
                io_log       = mio_log->/sl0/if_log~get_sap_log( ).

            EXIT. "finalize the log, return
          ENDIF.

          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          "  Move HU..
          " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
          move_hu(
            EXPORTING
              io_badi = lo_badi
              is_huhdr_data = ls_huhdr_data
              is_tmfsplc = ls_tmfsplc
              is_tmfscp = ls_tmfscp
              is_telegram = ls_wa_telegram
              iv_hex_iodata = lv_hex_iodata ).

        CATCH /scwm/cx_mfs INTO lx_mfs.
          IF lx_mfs->if_t100_message~t100key IS NOT INITIAL.
            MESSAGE e000 INTO lv_msgtext WITH lx_mfs->if_message~get_text( ).
          ELSE.
            MESSAGE e900(/sl0/mfs) WITH mis_telegram-teletype INTO lv_msgtext.
          ENDIF.

          mio_log->add_message( iv_row = 0 ).

          " Write log to DB
          TRY.
              mio_log->end_log( EXPORTING iv_plc         = miv_plc
                                          iv_huident     = ls_wa_telegram-huident
                                          iv_cp          = ls_wa_telegram-cp
                                          iv_sequno      = ls_wa_telegram-sequ_no
                                          iv_processor   = lv_processor
                                          iv_proc_type   = /sl0/cl_log_abstract=>mc_proc_meth
                                          iv_force_write = abap_true ).

            CATCH /sl0/cx_general_exception .           "#EC NO_HANDLER
            CATCH /scwm/cx_basics .                     "#EC NO_HANDLER
          ENDTRY.

          RAISE EXCEPTION lx_mfs.
      ENDTRY.
    ENDDO.

    TRY.
        mio_log->end_log( EXPORTING iv_plc         = miv_plc
                                    iv_huident     = ls_wa_telegram-huident
                                    iv_cp          = ls_wa_telegram-cp
                                    iv_sequno      = ls_wa_telegram-sequ_no
                                    iv_processor   = lv_processor
                                    iv_proc_type   = /sl0/cl_log_abstract=>mc_proc_meth
                                    iv_force_write = abap_true ).

      CATCH /sl0/cx_general_exception .                 "#EC NO_HANDLER
      CATCH /scwm/cx_basics .                           "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.


  METHOD try_enqueue_hu.
    CALL FUNCTION 'ENQUEUE_/SCWM/EHU'
      EXPORTING
        mode_/scwm/s_huhdr_int = 'E'
        mandt                  = sy-mandt
        huident                = is_huhdr_data-huident
        lgnum                  = miv_lgnum
        _scope                 = '3'
        _wait                  = abap_true
      EXCEPTIONS
        foreign_lock           = 1
        system_failure         = 2.

    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    " In case of an excpetion here, rejecting the HU to the NOK station.
    " Log event and save rejection reason
    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IF sy-subrc IS INITIAL.
      rv_success = abap_true.
    ELSE.
      CASE sy-subrc.
        WHEN 1.
          " Record is locked..
          MESSAGE e117(/scwm/mfs) INTO DATA(lv_msgtext) WITH is_huhdr_data-huident.
        WHEN 2.
          " Unable to lock HU &1 during WT confirmation
          MESSAGE e118(/scwm/mfs) INTO lv_msgtext WITH is_huhdr_data-huident.
      ENDCASE.

      mio_log->add_message( iv_row = 0 ).

      write_evtlog_and_rejreason(
        EXPORTING
          iv_param_1       = |{ is_huhdr_data-huident }|
          iv_reject_reason = /sl0/if_mfs_tele_conv_c=>mc_exc_hu_lock_error
          is_telegram      = is_telegram
      ).
    ENDIF.
  ENDMETHOD.


  METHOD write_evtlog_and_rejreason.
    mo_eventlog->do(
      EXPORTING
        iv_lgnum         = miv_lgnum
        iv_plc           = miv_plc
        iv_channel       = miv_channel
        iv_reject_reason = iv_reject_reason
        is_telegram      = is_telegram
        iv_param_1       = iv_param_1
        iv_param_2       = iv_param_2
        iv_param_3       = iv_param_3
        iv_param_4       = iv_param_4
        iv_param_5       = iv_param_5
        iv_param_6       = iv_param_6
        iv_param_7       = iv_param_7
        iv_param_8       = iv_param_8
        iv_param_9       = iv_param_9
        iv_param_10      = iv_param_10
        iv_message       = iv_message
        it_bapiret       = it_bapiret
        iv_dummy_hu      = iv_dummy_hu
    ).

    mo_reject_reason->add(
      EXPORTING
        iv_lgnum        = miv_lgnum
        iv_plc          = miv_plc
        iv_channel      = miv_channel
        iv_message      = COND #( WHEN iv_message IS SUPPLIED THEN iv_message ELSE iv_reject_reason )
        iv_event_type   = COND #( WHEN iv_event_type IS SUPPLIED THEN iv_event_type ELSE is_telegram-teletype )
        iv_cp           = is_telegram-cp
        iv_param_1       = iv_param_1
        iv_param_2       = iv_param_2
        iv_param_3       = iv_param_3
        iv_param_4       = iv_param_4
        iv_param_5       = iv_param_5
        iv_param_6       = iv_param_6
        iv_param_7       = iv_param_7
        iv_param_8       = iv_param_8
        iv_param_9       = iv_param_9
        iv_param_10      = iv_param_10
        iv_dialog_type   = iv_dialog_type
        it_bapiret       = it_bapiret
        iv_processed_kz  = iv_processed_kz
    ).
  ENDMETHOD.
ENDCLASS.
