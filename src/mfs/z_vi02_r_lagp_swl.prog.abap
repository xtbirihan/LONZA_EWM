*----------------------------------------------------------------------*

* Swisslog

*----------------------------------------------------------------------*

* Package:     Z_VI02_MFS

* Description: Set Field ZZ_VI02_RACK of DB Table /SCWM/LAGP

*----------------------Documentation of Changes------------------------*

* Ver. ¦Date      ¦Author                ¦Description

* -----¦----------¦----------------------¦-----------------------------*

* 1.0  ¦2023-03-01¦Ivan Asenov           ¦Initial

* 2.0  ¦2023-10-11¦Thomas Rehmann        ¦Adaption for Lonza

*----------------------------------------------------------------------*

REPORT z_vi02_r_lagp_swl.



CLASS lcl_z_vi02_r_lagp_swl DEFINITION

  ABSTRACT

  FINAL

  CREATE PRIVATE.



  PUBLIC SECTION.

    CLASS-METHODS exec
      IMPORTING
        iv_lgnum    TYPE /scwm/lgnum
        iv_lgtyp    TYPE /scwm/lgtyp
        it_lgpla_rg TYPE /scwm/tt_lgpla_r
        iv_force    TYPE z_de_force_lagp_zfield_update
        iv_test     TYPE tb_test
        io_log      TYPE REF TO /scwm/cl_log OPTIONAL
      RAISING
        zcx_vi02_general_exception.



ENDCLASS.



CLASS lcl_z_vi02_r_lagp_swl IMPLEMENTATION.



  METHOD exec.

*----------------------------------------------------------------------*

* Swisslog

*----------------------------------------------------------------------*
* Package:     Z_VI02_MFS
* Description: Set Field ZZ_VI02_RACK of DB Table /SCWM/LAGP
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-01¦Ivan Asenov           ¦Initial
* 2.0  ¦2023-10-11¦Thomas Rehmann        ¦Adaption for Lonza
*----------------------------------------------------------------------*



    TRY.
        IF iv_force IS INITIAL.
          DATA(lt_rack_rg)        = VALUE rseloption( ( sign = 'I' option = 'EQ' low = space ) ).
          "          DATA(lt_compartment_rg) = VALUE rseloption( ( sign = 'I' option = 'EQ' low = space ) ).
        ENDIF.

        SELECT FROM /scwm/lagp
          FIELDS *
          WHERE lgnum         EQ @iv_lgnum
            AND lgtyp         EQ @iv_lgtyp
            AND lgpla         IN @it_lgpla_rg
            AND zz_vi02_rack  IN @lt_rack_rg   "OR  ( zz_vi02_compartment  IN @lt_compartment_rg ) )
          INTO TABLE @DATA(lt_lagp).

        "if there is no Bin selected
        DATA(lv_msg_type) = COND #( WHEN ( lines( lt_lagp ) = 0 AND iv_force = 'X' ) THEN /scwm/cl_log=>msgty_error
                                                                                     ELSE /scwm/cl_log=>msgty_info ).
        " &1 storage bins will be updated
        MESSAGE ID 'Z_VI02_GENERAL' TYPE lv_msg_type NUMBER 101
           WITH |{ lines( lt_lagp ) }|
           INTO zcl_vi02_utils=>mv_msg_buf.

        IF lines( lt_lagp ) = 0.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
        ELSE.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
        ENDIF.



        LOOP AT lt_lagp ASSIGNING FIELD-SYMBOL(<ls_lagp>).
          "ignore highbay prefix(if there is any)
          <ls_lagp>-zz_vi02_rack = SWITCH z_vi02_de_rack( <ls_lagp>-lgpla(2) WHEN 'AA' OR 'AC' OR 'AF'  THEN |{ <ls_lagp>-lgpla+4(3) ALPHA = OUT }|
                                                                                                        ELSE |{ <ls_lagp>-lgpla+2(3) ALPHA = OUT }| ) .

        ENDLOOP.


        IF iv_test EQ 'X'.
          RETURN.
        ENDIF.


        UPDATE /scwm/lagp FROM TABLE @lt_lagp .

        IF sy-subrc <> 0.
          " Could not update &1 storage bins
          MESSAGE e102(z_vi02_general)
             WITH |{ lines( lt_lagp ) }|
             INTO zcl_vi02_utils=>mv_msg_buf.
          zcl_vi02_utils=>get_inst( )->add_message( io_log ).
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.

        ENDIF.

        " &1 storage bins updated
        MESSAGE s103(z_vi02_general)
           WITH |{ lines( lt_lagp ) }|
           INTO zcl_vi02_utils=>mv_msg_buf.
        zcl_vi02_utils=>get_inst( )->add_message( io_log ).

        COMMIT WORK.

      CLEANUP.
        ROLLBACK WORK.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.


TABLES: /scwm/lagp.

DATA:
  go_log TYPE REF TO /scwm/cl_log.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-sel. "'Selection'(sel).
  PARAMETERS:
    p_lgnum TYPE /scwm/lagp-lgnum OBLIGATORY MEMORY ID /scwm/lgn,
    p_lgtyp TYPE /scwm/lagp-lgtyp OBLIGATORY.
  SELECT-OPTIONS:
    s_lgpla  FOR /scwm/lagp-lgpla.
SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE TEXT-opt.
  PARAMETERS:
    p_force TYPE z_de_force_lagp_zfield_update AS CHECKBOX,
    p_test  TYPE tb_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK opt.

START-OF-SELECTION.
  "Laufzeitstatistik und Standardberechtigungsprüfung
  "runtime statistics and standard authority check
  "zcl_se_authority=>tcode_check_report_runtime( sy-repid ).

  go_log = NEW #( ).

  TRY.

      " Execute main logic
      lcl_z_vi02_r_lagp_swl=>exec(
        iv_lgnum    = p_lgnum
        iv_lgtyp    = p_lgtyp
        it_lgpla_rg = s_lgpla[]
        iv_force    = p_force
        iv_test     = p_test
        io_log      = go_log ).

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
