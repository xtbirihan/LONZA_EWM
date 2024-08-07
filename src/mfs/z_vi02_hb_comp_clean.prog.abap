*----------------------------------------------------------------------*

* Swisslog

*----------------------------------------------------------------------*

* Package:     Z_VI02_MFS

* Description: Set Field ZZ_VI02_RACK of DB Table /SCWM/LAGP

*----------------------Documentation of Changes------------------------*

* Ver. ¦Date      ¦Author                ¦Description

* -----¦----------¦----------------------¦-----------------------------*

* 1.0  ¦2023-10-11¦Ferenc SPISAK         ¦Initial

*----------------------------------------------------------------------*

REPORT z_vi02_hb_comp_clean.



CLASS lcl_z_vi02_hb_comp_clean DEFINITION

  ABSTRACT

  FINAL

  CREATE PRIVATE.



  PUBLIC SECTION.

    CLASS-METHODS exec
      IMPORTING
        iv_lgnum          TYPE /scwm/lgnum
        iv_lgtyp          TYPE /scwm/lgtyp
        it_compartment_rg TYPE rseloption
        it_lgpla_rg       TYPE /scwm/tt_lgpla_r

        iv_test           TYPE tb_test
        io_log            TYPE REF TO /scwm/cl_log OPTIONAL
      RAISING
        zcx_vi02_general_exception.



ENDCLASS.



CLASS lcl_z_vi02_hb_comp_clean IMPLEMENTATION.



  METHOD exec.

*----------------------------------------------------------------------*

* Swisslog

*----------------------------------------------------------------------*
* Package:     Z_VI02_MFS
* Description:
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-10-11¦Ferenc SPISAK         ¦Initial
*----------------------------------------------------------------------*


    DATA:
      lv_nof_success TYPE i,
      lv_nof_error   TYPE i.

    TRY.

        DATA(lo_service) = zcl_vi02_service_compartment=>get_inst( iv_lgnum ).

        "select storage bins for the compartments
        DATA(lt_comp_lgpla) = lo_service->select_comp_lgpla(
          it_lgtyp_rg       = VALUE rseloption( ( sign = 'I' option = 'EQ' low = iv_lgtyp ) )
          it_lgpla_rg       = CONV #( it_lgpla_rg )
          it_compartment_rg = it_compartment_rg ).

        "select bin status
        DATA(lt_bin_user_status) = lo_service->get_bin_status_tab(
          iv_refresh_buffer = 'X'
          it_lgpla          = VALUE /scwm/tt_lagp_key( FOR ls_comp_lgpla IN lt_comp_lgpla ( lgnum = ls_comp_lgpla-lgnum lgpla = ls_comp_lgpla-lgpla ) ) ).


        "select empty compartments
        DATA(lt_compartment) = lo_service->select_empty_compartments(
          it_lgtyp_rg       = VALUE rseloption( ( sign = 'I' option = 'EQ' low = iv_lgtyp ) )
          it_lgpla_rg       = CONV #( it_lgpla_rg )
          it_compartment_rg = it_compartment_rg ).


        "now remove the compartments which have already status init
        SORT lt_compartment.

        LOOP AT lt_compartment ASSIGNING FIELD-SYMBOL(<lv_compartment>).
          DATA(lv_all_init) = 'X'.
          LOOP AT lt_comp_lgpla ASSIGNING FIELD-SYMBOL(<ls_comp_lgpla>) USING KEY compartment WHERE lgnum       EQ iv_lgnum
                                                                                                AND compartment EQ <lv_compartment>.
            READ TABLE lt_bin_user_status ASSIGNING FIELD-SYMBOL(<ls_bin_user_status>)  WITH KEY lgnum = <ls_comp_lgpla>-lgnum
                                                                                                 lgpla = <ls_comp_lgpla>-lgpla.
            IF sy-subrc IS NOT INITIAL OR <ls_bin_user_status>-status NE zcl_vi02_service_compartment=>co_user_status-init.
              CLEAR lv_all_init.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_all_init IS NOT INITIAL.
            DELETE lt_compartment.
          ENDIF.
        ENDLOOP.



        " &1 storage bins will be updated
        MESSAGE ID 'Z_VI02_GENERAL' TYPE /scwm/cl_log=>msgty_info NUMBER 105
           WITH |{ lines( lt_compartment ) }|
           INTO zcl_vi02_utils=>mv_msg_buf.

        IF lines( lt_compartment ) = 0.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
        ELSE.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
        ENDIF.

        IF iv_test EQ 'X'.
          RETURN.
        ENDIF.

        LOOP AT lt_compartment INTO DATA(lv_compartment).
          TRY.
              DATA(lo_compartment) = NEW zcl_vi02_compartment(
                iv_lgnum       = iv_lgnum
                iv_compartment = lv_compartment
             "  io_log         = io_log
              ).
              lo_compartment->reset( ).

              lv_nof_success = lv_nof_success + 1.

              "             COMMIT WORK.
            CATCH zcx_vi02_general_exception .
            CATCH /sl0/cx_general_exception .
              lv_nof_error = lv_nof_error + 1.
              ROLLBACK WORK.
          ENDTRY.
        ENDLOOP.
        IF lv_nof_success IS NOT INITIAL.
          " &1 storage bins updated
          MESSAGE s107(z_vi02_general)
             WITH |{ lv_nof_success  }|
             INTO zcl_vi02_utils=>mv_msg_buf.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
        ENDIF.

        IF lv_nof_error IS NOT INITIAL.
          " Could not update &1 storage bins
          MESSAGE e106(z_vi02_general)
             WITH |{ lv_nof_error }|
             INTO zcl_vi02_utils=>mv_msg_buf.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.

        ENDIF.

      CATCH /sl0/cx_general_exception .

    ENDTRY.

  ENDMETHOD.

ENDCLASS.


TABLES: /scwm/lagp.

DATA:
  BEGIN OF gs_dummy_4_sel,
    compartment TYPE z_vi02_de_compartment,
  END OF gs_dummy_4_sel,
  go_log TYPE REF TO /scwm/cl_log.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-sel. "'Selection'(sel).
  PARAMETERS:
    p_lgnum TYPE /scwm/lagp-lgnum OBLIGATORY MEMORY ID /scwm/lgn,
    p_lgtyp TYPE /scwm/lagp-lgtyp OBLIGATORY.
  SELECT-OPTIONS:
    s_comp   FOR gs_dummy_4_sel-compartment,
    s_lgpla  FOR /scwm/lagp-lgpla.
SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE TEXT-opt.
  PARAMETERS:
    p_test  TYPE tb_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK opt.

START-OF-SELECTION.
  "Laufzeitstatistik und Standardberechtigungsprüfung
  "runtime statistics and standard authority check
  "zcl_se_authority=>tcode_check_report_runtime( sy-repid ).

  go_log = NEW #( ).

  TRY.

      " Execute main logic
      lcl_z_vi02_hb_comp_clean=>exec(
        iv_lgnum          = p_lgnum
        iv_lgtyp          = p_lgtyp
        it_compartment_rg = CONV #( s_comp[] )
        it_lgpla_rg       = s_lgpla[]
        iv_test           = p_test
        io_log            = go_log ).

    CATCH zcx_vi02_general_exception ##NO_HANDLER.

  ENDTRY.



  " Show appl. log

  IF lines( go_log->mp_protocol ) > 0.

    CALL FUNCTION 'SUSR_DISPLAY_LOG'
      EXPORTING
        display_in_popup = abap_true
      TABLES
        it_log_bapiret2  = go_log->mp_protocol
      EXCEPTIONS
        OTHERS           = 0.

  ENDIF.
