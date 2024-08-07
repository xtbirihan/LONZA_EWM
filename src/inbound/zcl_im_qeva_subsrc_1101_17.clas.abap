class ZCL_IM_QEVA_SUBSRC_1101_17 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_QEVA_SUBSCREEN_1101 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_QEVA_SUBSRC_1101_17 IMPLEMENTATION.


  METHOD if_ex_qeva_subscreen_1101~get_data.

* Im PAI des rufenden Dynpros und im PBO des gerufenden Dynpros:
* Globale Attribute der Adapterklasse über die Schnittstelle zurückgeben

* PAI of the calling screen and PBO of the called screen:
* Fill the interface parameter with the values of the global attributes
* of the adapter class
    MOVE if_ex_qeva_subscreen_1101~g_qals  TO e_qals.
    MOVE if_ex_qeva_subscreen_1101~g_rqeva TO e_rqeva.

  ENDMETHOD.


  METHOD if_ex_qeva_subscreen_1101~process_ok_code.
* Die Methode dient zur Verarbeitung des ok-codes im Subscreen des
* Dynpros 1101 in der Funktionsgruppe QEVA.
* Im Subscreen können verschiedene ok-codes verwendet werden,
* beginnend mit '+BADI1101', z.B. '+BADI1101_1'.
    TYPES:
      BEGIN OF ts_qinsp_doc_number,
        insp_doc_number TYPE char12,
      END OF ts_qinsp_doc_number,
      tt_qinsp_doc_number TYPE STANDARD TABLE OF ts_qinsp_doc_number.


    DATA: lv_insp_doc_no_char TYPE char12,
          lv_receiver         TYPE rfc_dest,
          lv_subrc            TYPE sy-subrc,
          lv_insp_termination TYPE sy-subrc,

          ls_qals             TYPE qals,
          ls_ret              TYPE bapiret2,
          lv_message          TYPE bapiret2-message.

    DATA: lt_inspdoc_no_ext TYPE tt_qinsp_doc_number,
          lt_ret_messages   TYPE bapiret2_tab.

    DATA:
*   Variables to check parameters of function module
*   Parameters other than export are just provided because they are
*   mandatory for function module FUNCTION_IMPORT_DOKU
      lt_doc_par TYPE TABLE OF funct,
      lt_exc_par TYPE TABLE OF rsexc,
      lt_exp_par TYPE TABLE OF rsexp,
      lt_imp_par TYPE TABLE OF rsimp,
      lt_tbl_par TYPE TABLE OF rstbl,
      ls_imp_par TYPE rsimp,
      lv_display TYPE char1.

    CONSTANTS:
         cv_1                 TYPE i                VALUE 1.

    CASE i_ok_code.
      WHEN '+BADI1101_1'.
        CALL METHOD if_ex_qeva_subscreen_1101~get_data(
          EXPORTING
            flt_val = '17'
          IMPORTING
            e_qals  = ls_qals ).

        IF sy-subrc = 0.

*       Truncate inspection document number
          lv_insp_doc_no_char = ls_qals-insp_doc_number.

*       Initialize queue and get receiver
          CALL METHOD /spe/cl_distribution=>qie_queue_set
            EXPORTING
              iv_logsys   = ls_qals-log_system
              iv_qinsp_no = lv_insp_doc_no_char
            IMPORTING
              ev_receiver = lv_receiver
            EXCEPTIONS
              no_receiver = 1
              queue_error = 2
              OTHERS      = 3.

          IF sy-subrc = 0.

            IF ls_qals-charg IS NOT INITIAL.
              CALL FUNCTION 'DEQUEUE_EMMCH1E'
                EXPORTING
*                 MODE_MCH1       = 'E'
*                 MANDT = SY-MANDT
                  matnr = ls_qals-matnr
                  charg = ls_qals-charg
*                 X_MATNR         = ' '
*                 X_CHARG         = ' '
*                 _SCOPE          = '3'
*                 _SYNCHRON       = ' '
*                 _COLLECT        = ' '
                .
            ENDIF.

            APPEND ls_qals-insp_doc_number TO lt_inspdoc_no_ext.

            IF sy-tcode EQ 'QA13'.

              CALL FUNCTION 'FUNCTION_IMPORT_DOKU' DESTINATION lv_receiver
                EXPORTING
                  funcname           = '/SCWM/QUI_INSP_RFC'
                TABLES
                  dokumentation      = lt_doc_par
                  exception_list     = lt_exc_par
                  export_parameter   = lt_exp_par
                  import_parameter   = lt_imp_par
                  tables_parameter   = lt_tbl_par
                EXCEPTIONS
                  error_message      = 1
                  function_not_found = 2
                  invalid_name       = 3
                  OTHERS             = 4.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              LOOP AT lt_imp_par INTO ls_imp_par
                WHERE parameter = 'IV_DISPLAY'.
                IF sy-subrc EQ 0.
                  MOVE 'X' TO lv_display.
                ENDIF.
              ENDLOOP.
              IF lv_display IS INITIAL.
                MESSAGE s052(ppegui).
              ELSE.
*            Do inspection based on EWM stock items remotely
                CALL FUNCTION '/SCWM/QUI_INSP_RFC'
                  DESTINATION lv_receiver
                  EXPORTING
                    it_insp_doc_number    = lt_inspdoc_no_ext
                    iv_inspector          = 'TESTERX'
                    iv_display            = 'X'
                  IMPORTING
                    et_return             = lt_ret_messages
                  EXCEPTIONS
                    communication_failure = 1 MESSAGE lv_message
                    system_failure        = 2 MESSAGE lv_message
                    not_exist             = 3
                    OTHERS                = 99.
                IF sy-subrc NE 0.
                  MESSAGE e057(/scwm/pi_appl) WITH lv_message.
                ENDIF.
              ENDIF.
            ELSE.
*            Do inspection based on EWM stock items remotely
              CALL FUNCTION '/SCWM/QUI_INSP_RFC'
                DESTINATION lv_receiver
                EXPORTING
                  it_insp_doc_number    = lt_inspdoc_no_ext
                  iv_inspector          = 'TESTERX'
                  iv_display            = ' '
                IMPORTING
                  et_return             = lt_ret_messages
                EXCEPTIONS
                  communication_failure = 1 MESSAGE lv_message
                  system_failure        = 2 MESSAGE lv_message
                  not_exist             = 3
                  OTHERS                = 99.
              IF sy-subrc NE 0.
                MESSAGE e057(/scwm/pi_appl) WITH lv_message.
              ENDIF.
            ENDIF.

            IF lt_ret_messages IS NOT INITIAL.
              READ TABLE lt_ret_messages INTO ls_ret INDEX 1.
              IF sy-subrc IS INITIAL.
                MESSAGE ls_ret-message
                        TYPE   ls_ret-type.
              ENDIF.
            ENDIF.
            IF ls_qals-charg IS NOT INITIAL.
              CALL FUNCTION 'ENQUEUE_EMMCH1E'
                EXPORTING
*                 MODE_MCH1       = 'E'
*                 MANDT = SY-MANDT
                  matnr = ls_qals-matnr
                  charg = ls_qals-charg
*                 X_MATNR         = ' '
*                 X_CHARG         = ' '
*                 _SCOPE          = '3'
*                 _SYNCHRON       = ' '
*                 _COLLECT        = ' '
                .
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.


  method IF_EX_QEVA_SUBSCREEN_1101~PUT_DATA.
* Im PBO des rufenden Dynpros und PAI des gerufenen Dynpros:
* Schnittstellenwerte an globale Attribute der Adapterklasse übergeben

* PBO of the calling screen and PAI of the called screen:
* put the interface data to the global attributes of the adapter class
  move i_qals  to if_ex_qeva_subscreen_1101~g_qals.
  move i_rqeva to if_ex_qeva_subscreen_1101~g_rqeva.
  endmethod.
ENDCLASS.
