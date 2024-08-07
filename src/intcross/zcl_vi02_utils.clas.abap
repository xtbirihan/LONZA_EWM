CLASS zcl_vi02_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES:

      BEGIN OF ts_tmstmp_date_time,
        lgnum     TYPE /scwm/lgnum,
        timestamp TYPE tzntstmps,
        timezone  TYPE tznzone,
        date      TYPE dats,
        time      TYPE tims,
      END OF ts_tmstmp_date_time .

    CLASS-DATA mv_msg_buf TYPE string .

    DATA go_stock_fields TYPE REF TO /scwm/cl_ui_stock_fields READ-ONLY .

    CLASS-METHODS class_constructor .

    CLASS-METHODS get_inst
      RETURNING
        VALUE(ro_util) TYPE REF TO zcl_vi02_utils .

    METHODS conv_exit_in
      IMPORTING
        !iv_input        TYPE simple
      RETURNING
        VALUE(rv_output) TYPE string .

    METHODS conv_exit_out
      IMPORTING
        !iv_input        TYPE simple
      RETURNING
        VALUE(rv_output) TYPE string .

    METHODS conv_dom_txt
      IMPORTING
        !iv_input        TYPE simple
        !iv_lang         TYPE syst_langu DEFAULT sy-langu
      RETURNING
        VALUE(rv_output) TYPE string .

    METHODS check_dom_val
      IMPORTING
        !iv_input        TYPE simple
      RETURNING
        VALUE(rv_result) TYPE abap_bool .

    METHODS conv_qty
      IMPORTING
        VALUE(iv_matid) TYPE /scwm/de_matid OPTIONAL
        !iv_matnr       TYPE /scwm/de_matnr OPTIONAL
        !iv_qty         TYPE /scwm/de_quantity
        !iv_uom_in      TYPE /scwm/de_unit OPTIONAL
        !iv_uom_out     TYPE /scwm/de_unit OPTIONAL
      RETURNING
        VALUE(rs_qty)   TYPE /scdl/dl_qty_str
      RAISING
        zcx_vi02_general_exception .

    METHODS conv_string_2_symsg
      IMPORTING
        VALUE(iv_input) TYPE clike
        !iv_msgty       TYPE syst_msgty DEFAULT /scwm/cl_log=>msgty_info
      RETURNING
        VALUE(rs_symsg) TYPE symsg .

    METHODS get_tmstmp
      RETURNING
        VALUE(rv_tmstmp) TYPE tzntstmps .

    METHODS conv_tmstmp_2_date_time
      IMPORTING
        !iv_lgnum        TYPE /scwm/lgnum
        !iv_tmstmp       TYPE tzntstmps
      RETURNING
        VALUE(rs_result) TYPE ts_tmstmp_date_time
      RAISING
        zcx_vi02_general_exception .

    METHODS add_message
      IMPORTING
        !io_log TYPE REF TO /scwm/cl_log .

    METHODS write_log
      IMPORTING
        !is_bal TYPE bal_s_log
        !io_log TYPE REF TO /scwm/cl_log .

    METHODS write_log_actlog
      IMPORTING
        !iv_lgnum TYPE /scwm/lgnum
        !is_bal   TYPE bal_s_log
        !io_log   TYPE REF TO /scwm/cl_log .

    METHODS check_log_error
      IMPORTING
        !it_log TYPE ANY TABLE
      RAISING
        zcx_vi02_general_exception
        cx_sy_dyn_table_ill_line_type .

    METHODS get_docid_lgnum
      IMPORTING
        !iv_doccat      TYPE /scdl/dl_doccat
        !iv_docid       TYPE /scdl/dl_docid
      RETURNING
        VALUE(rv_lgnum) TYPE /scwm/lgnum
      RAISING
        cx_sy_ref_is_initial .

    METHODS sleep
      IMPORTING
        !iv_sec TYPE i DEFAULT 1
      RAISING
        zcx_vi02_general_exception .

    METHODS line_exists_gen
      IMPORTING
        !it_itab         TYPE ANY TABLE
        !iv_key          TYPE clike DEFAULT 'primary_key'
        !iv_from         TYPE i DEFAULT 1
        !iv_to           TYPE i OPTIONAL
        !iv_cond         TYPE clike
      RETURNING
        VALUE(rv_exists) TYPE abap_bool  ##NO_TEXT.

    METHODS line_index_gen
      IMPORTING
        !it_itab        TYPE ANY TABLE
        !iv_key         TYPE clike DEFAULT 'primary_key'
        !iv_from        TYPE i DEFAULT 1
        !iv_to          TYPE i OPTIONAL
        !iv_cond        TYPE clike
      RETURNING
        VALUE(rv_index) TYPE i  ##NO_TEXT.

    METHODS reg_dummy_upd_fm .

    METHODS get_t300_md
      IMPORTING
        !iv_lgnum         TYPE /scwm/lgnum OPTIONAL
        !iv_scuguid       TYPE /scmb/mdl_scuguid OPTIONAL
          PREFERRED PARAMETER iv_lgnum
      RETURNING
        VALUE(rs_t300_md) TYPE /scwm/s_t300_md
      RAISING
        zcx_vi02_general_exception .

    METHODS get_t340d
      IMPORTING
        !iv_lgnum       TYPE /scwm/lgnum
      RETURNING
        VALUE(rs_t340d) TYPE /scwm/s_t340d
      RAISING
        zcx_vi02_not_found .

    METHODS check_dbtab_read
      IMPORTING
        !iv_data  TYPE any
        !it_param TYPE char40_t OPTIONAL
        !io_log   TYPE REF TO /scwm/cl_log OPTIONAL
      RAISING
        zcx_vi02_not_found .

    METHODS get_cp_cust
      IMPORTING
        !iv_lgnum         TYPE /scwm/lgnum
        !iv_plc           TYPE /scwm/de_mfsplc
        !iv_cp            TYPE /scwm/de_mfscp
      RETURNING
        VALUE(rs_cp_cust) TYPE /scwm/tmfscp
      RAISING
        zcx_vi02_not_found .

    METHODS get_lgpla_mast
      IMPORTING
        !iv_lgnum         TYPE /scwm/lgnum
        !iv_lgpla         TYPE /scwm/lgpla
        !iv_read_from_buf TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_lagp)    TYPE /scwm/lagp
      RAISING
        zcx_vi02_not_found .
    METHODS i_eq
      IMPORTING
        !iv_input        TYPE simple
      RETURNING
        VALUE(rt_output) TYPE rseloption .

    METHODS conv_qty_2_string
      IMPORTING
        !iv_qty          TYPE /scwm/de_quantity
        !iv_uom          TYPE /scwm/de_unit OPTIONAL
      RETURNING
        VALUE(rv_string) TYPE string .
    METHODS get_matnr_by_matid
      IMPORTING
        !iv_matid       TYPE /scwm/de_matid
      RETURNING
        VALUE(rv_matnr) TYPE /scwm/de_matnr .
  PRIVATE SECTION.

    CONSTANTS mc_conv_exit_fm_input TYPE string VALUE 'CONVERSION_EXIT_&1_INPUT' ##NO_TEXT.


    CONSTANTS mc_conv_exit_fm_output TYPE string VALUE 'CONVERSION_EXIT_&1_OUTPUT' ##NO_TEXT.


    CLASS-DATA mo_singleton TYPE REF TO zcl_vi02_utils.


    METHODS on_transaction_finished
        FOR EVENT transaction_finished OF cl_system_transaction_state.


    METHODS constructor.

    METHODS conv_exit
      IMPORTING
        iv_input  TYPE simple
        iv_exit   TYPE string
      EXPORTING
        ev_output TYPE simple
      RAISING
        zcx_vi02_general_exception.
ENDCLASS.



CLASS ZCL_VI02_UTILS IMPLEMENTATION.


  METHOD add_message.

    "=== Local structures ======================================================
    DATA:
      ls_symsg TYPE symsg.
    "===========================================================================

    IF sy-msgid IS INITIAL
    OR sy-msgty IS INITIAL.
      " No message found
      MESSAGE e800(fdt_core) INTO mv_msg_buf.
    ENDIF.

    IF io_log IS BOUND.
      " Since IO_LOG->ADD_MESSAGE( ) can change SY fields, copy and re-raise the
      " message afterwards
      ls_symsg = CORRESPONDING #( sy ).
      io_log->add_message( ).
      MESSAGE ID ls_symsg-msgid TYPE ls_symsg-msgty NUMBER ls_symsg-msgno
        WITH ls_symsg-msgv1 ls_symsg-msgv2 ls_symsg-msgv3 ls_symsg-msgv4
        INTO mv_msg_buf.
    ENDIF.

  ENDMETHOD.


  METHOD check_dbtab_read.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Check if DB table read was successful
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-09¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    "=== Local objects =================================================
    DATA:
      lo_type_descr TYPE REF TO cl_abap_typedescr.
    "=== Local structures ==============================================
    DATA:
      ls_symsg TYPE symsg.
    "=== Local values ==================================================
    DATA:
      lv_numb_of_entries TYPE i.
    "=== Local field symbols ===========================================
    FIELD-SYMBOLS:
      <lt_data> TYPE ANY TABLE.
    "===================================================================

    lo_type_descr = cl_abap_typedescr=>describe_by_data( iv_data ).

    IF lo_type_descr IS INSTANCE OF cl_abap_tabledescr.
      ASSIGN iv_data TO <lt_data>.
      lv_numb_of_entries = lines( <lt_data> ).
      lo_type_descr = CAST cl_abap_tabledescr( lo_type_descr )->get_table_line_type( ).
    ELSE.
      lv_numb_of_entries = COND #( WHEN iv_data IS INITIAL
                                   THEN 0
                                   ELSE 1 ).
    ENDIF.

    IF lines( it_param ) = 0.
      " &1 entries found in DB table &2
      MESSAGE i022(z_vi02_general)
         WITH lv_numb_of_entries
              lo_type_descr->get_relative_name( )
         INTO mv_msg_buf.
    ELSE.
      ls_symsg = conv_string_2_symsg( concat_lines_of( table = it_param
                                                       sep   = ` -> ` ) ).
      " &1 entries found in DB table &2 for query "&3&4"
      MESSAGE i023(z_vi02_general)
         WITH lv_numb_of_entries
              lo_type_descr->get_relative_name( )
              ls_symsg-msgv1 ls_symsg-msgv2
         INTO mv_msg_buf.
    ENDIF.

    IF lv_numb_of_entries = 0.
      sy-msgty = /scwm/cl_log=>msgty_error.
      add_message( io_log ).
      RAISE EXCEPTION TYPE zcx_vi02_not_found USING MESSAGE.
    ELSE.
      add_message( io_log ).
    ENDIF.

  ENDMETHOD.


  METHOD check_dom_val.

    "=== Local objects =========================================================
    DATA:
      lo_elem_descr TYPE REF TO cl_abap_elemdescr.
    "=== Local tables ==========================================================
    DATA:
      lt_value TYPE ddfixvalues.
    "=== Local field symbols ===================================================
    FIELD-SYMBOLS:
      <ls_value> TYPE ddfixvalue.
    "===========================================================================

    lo_elem_descr ?= cl_abap_elemdescr=>describe_by_data( iv_input ).

    lo_elem_descr->get_ddic_fixed_values(
      RECEIVING
        p_fixed_values = lt_value
      EXCEPTIONS
        not_found      = 1
        no_ddic_type   = 2
        OTHERS         = 3 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_value ASSIGNING <ls_value>.
      IF iv_input IN VALUE rseloption( ( sign   = wmegc_sign_inclusive
                                         option = <ls_value>-option
                                         low    = <ls_value>-low
                                         high   = <ls_value>-high ) ).
        rv_result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_log_error.

    "=== Local references ======================================================
    DATA:
      ld_bapiret TYPE REF TO bapiret2,
      ld_msg     TYPE REF TO /scdl/dm_message_str.
    "===========================================================================

    CASE CAST cl_abap_tabledescr(
      cl_abap_typedescr=>describe_by_data( it_log )
    )->get_table_line_type( )->absolute_name.

      WHEN CAST cl_abap_refdescr(
        cl_abap_typedescr=>describe_by_data( ld_bapiret )
      )->get_referenced_type( )->absolute_name.

        LOOP AT it_log REFERENCE INTO ld_bapiret.
          CHECK ld_bapiret->type CA wmegc_severity_eax.
          MESSAGE ID ld_bapiret->id TYPE ld_bapiret->type NUMBER ld_bapiret->number
            WITH ld_bapiret->message_v1 ld_bapiret->message_v2 ld_bapiret->message_v3 ld_bapiret->message_v4
            INTO mv_msg_buf.
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
        ENDLOOP.

      WHEN CAST cl_abap_refdescr(
        cl_abap_typedescr=>describe_by_data( ld_msg )
      )->get_referenced_type( )->absolute_name.

        LOOP AT it_log REFERENCE INTO ld_msg.
          CHECK ld_msg->msgty CA wmegc_severity_eax.
          MESSAGE ID ld_msg->msgid TYPE ld_msg->msgty NUMBER ld_msg->msgno
            WITH ld_msg->msgv1 ld_msg->msgv2 ld_msg->msgv3 ld_msg->msgv4
            INTO mv_msg_buf.
          RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
        ENDLOOP.

      WHEN OTHERS.

        RAISE EXCEPTION TYPE cx_sy_dyn_table_ill_line_type
          EXPORTING
            textid  = cx_sy_dyn_table_ill_line_type=>cx_sy_dyn_table_error
            tabname = cl_abap_typedescr=>describe_by_data( it_log )->get_relative_name( ).

    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    mo_singleton = NEW #( ).

  ENDMETHOD.


  METHOD constructor.

    go_stock_fields = NEW #( ).

  ENDMETHOD.


  METHOD conv_dom_txt.

    "=== Local objects =========================================================
    DATA:
      lo_elem_descr TYPE REF TO cl_abap_elemdescr.
    "=== Local tables ==========================================================
    DATA:
      lt_value TYPE ddfixvalues.
    "=== Local field symbols ===================================================
    FIELD-SYMBOLS:
      <ls_value> TYPE ddfixvalue.
    "===========================================================================

    lo_elem_descr ?= cl_abap_elemdescr=>describe_by_data( iv_input ).

    lo_elem_descr->get_ddic_fixed_values(
      EXPORTING
        p_langu        = iv_lang
      RECEIVING
        p_fixed_values = lt_value
      EXCEPTIONS
        not_found      = 1
        no_ddic_type   = 2
        OTHERS         = 3 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_value ASSIGNING <ls_value> WHERE ddlanguage = iv_lang.
      IF iv_input IN VALUE rseloption( ( sign   = wmegc_sign_inclusive
                                         option = <ls_value>-option
                                         low    = <ls_value>-low
                                         high   = <ls_value>-high ) ).
        rv_output = <ls_value>-ddtext.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD conv_exit.

    "=== Local objects =========================================================
    DATA:
      lo_elem_descr TYPE REF TO cl_abap_elemdescr.
    "=== Local exceptions ======================================================
    DATA:
      lx_root TYPE REF TO cx_root.
    "=== Local values ==========================================================
    DATA:
      lv_conv_exit_fm TYPE string.
    "===========================================================================

    CLEAR ev_output.

    lo_elem_descr ?= cl_abap_elemdescr=>describe_by_data( iv_input ).

    IF lo_elem_descr->edit_mask IS INITIAL.
      " No conversion exits found
      RAISE EXCEPTION TYPE zcx_vi02_general_exception
        MESSAGE e218(rs_general).
    ENDIF.

    lv_conv_exit_fm = replace( val  = iv_exit
                               sub  = '&1'
                               with = replace( val   = lo_elem_descr->edit_mask
                                               regex = '^=='  ##REGEX_POSIX
                                               with  = space ) ).

    TRY.
        CALL FUNCTION lv_conv_exit_fm
          EXPORTING
            input  = iv_input
          IMPORTING
            output = ev_output
          EXCEPTIONS
            OTHERS = 1.

        IF sy-subrc <> 0.
          " Error in conversion exit
          RAISE EXCEPTION TYPE zcx_vi02_general_exception
            MESSAGE e032(rsan_wb).
        ENDIF.

      CATCH cx_root INTO lx_root ##CATCH_ALL.
        " Error in conversion exit
        RAISE EXCEPTION TYPE zcx_vi02_general_exception
          MESSAGE e032(rsan_wb)
          EXPORTING
            previous = lx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_exit_in.

    TRY.
        conv_exit( EXPORTING iv_input  = iv_input
                             iv_exit   = mc_conv_exit_fm_input
                   IMPORTING ev_output = rv_output ).
      CATCH zcx_vi02_general_exception.
        rv_output = iv_input.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_exit_out.

    TRY.
        conv_exit( EXPORTING iv_input  = iv_input
                             iv_exit   = mc_conv_exit_fm_output
                   IMPORTING ev_output = rv_output ).
      CATCH zcx_vi02_general_exception.
        rv_output = iv_input.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_qty.

    "=== Local objects =================================================
    DATA:
      lx_root TYPE REF TO cx_root.
    "=== Local structures ==============================================
    DATA:
      ls_mat_glob TYPE /scwm/s_material_global.
    "===================================================================

    " Importing parameter logic:
    "   0) if IV_MATID is missing, it will be taken from IV_MATNR
    "   1) if IV_UOM_IN is missing, IV_MATID/MATNR must be filled; SUoM = BUoM
    "   2) if IV_UOM_OUT is missing, IV_MATID/MATNR must be filled; TUoM = BUoM
    "   3) if IV_MATID/MATNR are missing, SUoM must be convertible to TUoM
    "      independently of a product master (e.g., KG is always convertible to G)

    TRY.
        " Process inputs
        IF  iv_matid IS NOT INITIAL
        AND iv_matnr IS NOT INITIAL.
          RAISE EXCEPTION TYPE /scmb/cx_mdl_interface.
        ELSEIF iv_matnr IS NOT INITIAL.
          iv_matid = go_stock_fields->get_matid_by_no( iv_matnr ).
        ENDIF.

        IF  iv_uom_in  IS INITIAL
        AND iv_uom_out IS INITIAL.
          RAISE EXCEPTION TYPE /scmb/cx_mdl_interface.
        ELSEIF iv_uom_in IS INITIAL
           AND iv_matid  IS INITIAL.
          RAISE EXCEPTION TYPE /scmb/cx_mdl_interface.
        ELSEIF iv_uom_out IS INITIAL
           AND iv_matid   IS INITIAL.
          RAISE EXCEPTION TYPE /scmb/cx_mdl_interface.
        ENDIF.

        IF iv_uom_in = iv_uom_out.
          " Nothing to convert
          rs_qty-qty = iv_qty.
        ELSE.
          " Convert quantity
          CALL FUNCTION '/SCMB/MDL_QUAN_CONVERSION'
            EXPORTING
              iv_product_id = iv_matid
              iv_quan       = iv_qty
              iv_unit_from  = iv_uom_in
              iv_unit_to    = iv_uom_out
            IMPORTING
              ev_quan       = rs_qty-qty.
        ENDIF.

        " Circumvent rounding issues
        rs_qty-qty = /qos/cl_qty_aux=>round_qty( rs_qty-qty ).

        " Fill target UoM
        IF iv_uom_out IS NOT INITIAL.
          rs_qty-uom = iv_uom_out.
        ELSE.
          CALL FUNCTION '/SCWM/MATERIAL_READ_SINGLE'
            EXPORTING
              iv_matid      = iv_matid
            IMPORTING
              es_mat_global = ls_mat_glob.
          rs_qty-uom = ls_mat_glob-meins.
        ENDIF.

      CATCH cx_root INTO lx_root ##CATCH_ALL.
        " Error in quantity conversion
        RAISE EXCEPTION TYPE zcx_vi02_general_exception
          MESSAGE e002(/scdl/af_qo)
          EXPORTING
            previous = lx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_qty_2_string.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Convert quantity (+/- UoM) to user-friendly string
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-21¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    rv_string = |{ round( val = iv_qty dec = 3 ) NUMBER = USER }|.
    IF iv_uom IS NOT INITIAL.
      rv_string = |{ rv_string } { conv_exit_out( iv_uom ) }|.
    ENDIF.

  ENDMETHOD.


  METHOD conv_string_2_symsg.

    "=== Local values ==================================================
    DATA:
      lv_string_msg TYPE string.
    "=== Local field symbols ===========================================
    FIELD-SYMBOLS:
      <lv_msgv> TYPE symsgv.
    "===================================================================

    " &1&2&3&4
    rs_symsg = VALUE #( msgid = 'RT'
                        msgty = iv_msgty
                        msgno = '363' ).

    DO 4 TIMES.
      IF strlen( iv_input ) = 0.
        EXIT.
      ENDIF.

      ASSIGN COMPONENT |MSGV{ sy-index }| OF STRUCTURE rs_symsg TO <lv_msgv>.

      lv_string_msg = substring( val = iv_input
                                 len = nmin( val1 = strlen( iv_input )
                                             val2 = 50 ) ) ##NUMBER_OK.

      iv_input = match( val   = lv_string_msg
                        regex = '\s+$' ) ##REGEX_POSIX
              && shift_left( val    = iv_input
                             places = nmin( val1 = strlen( iv_input )
                                            val2 = 50 ) ) ##NUMBER_OK.

      <lv_msgv> = lv_string_msg.
    ENDDO.

    MESSAGE ID rs_symsg-msgid TYPE rs_symsg-msgty NUMBER rs_symsg-msgno
      WITH rs_symsg-msgv1 rs_symsg-msgv2 rs_symsg-msgv3 rs_symsg-msgv4
      INTO mv_msg_buf.

  ENDMETHOD.


  METHOD conv_tmstmp_2_date_time.

    "=== Local tables ==================================================
    DATA:
      lt_date_time TYPE /scwm/tt_tstmp_date_time.
    "=== Local values ==================================================
    DATA:
      lv_timezone TYPE tznzone.
    "===================================================================

    CALL FUNCTION '/SCWM/CONVERT_TIMESTAMP'
      EXPORTING
        iv_lgnum       = iv_lgnum
        it_timestamp   = VALUE /scwm/tt_timestamp( ( iv_tmstmp ) )
      IMPORTING
        ev_timezone    = lv_timezone
        et_date_time   = lt_date_time
      EXCEPTIONS
        input_error    = 1
        data_not_found = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
    ENDIF.

    TRY.
        rs_result = VALUE #( lgnum     = iv_lgnum
                             timestamp = iv_tmstmp
                             timezone  = lv_timezone
                             date      = lt_date_time[ timestamp = iv_tmstmp ]-date
                             time      = lt_date_time[ timestamp = iv_tmstmp ]-time ).
      CATCH cx_sy_itab_line_not_found INTO DATA(lx_sy_line).
        " Error when converting UTC time stamp &1 in date/time.
        RAISE EXCEPTION TYPE zcx_vi02_general_exception
          MESSAGE e022(/sapcnd/maintenance)
             WITH iv_tmstmp
          EXPORTING
            previous = lx_sy_line.
    ENDTRY.

  ENDMETHOD.


  METHOD get_cp_cust.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Get CP customizing
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-15¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
      EXPORTING
        iv_lgnum  = iv_lgnum
        iv_plc    = iv_plc
        iv_cp     = iv_cp
      IMPORTING
        es_tmfscp = rs_cp_cust
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_vi02_not_found USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD get_docid_lgnum.

    "=== Local objects =========================================================
    DATA:
      lo_man TYPE REF TO /scwm/cl_dlv_management.
    "===========================================================================

    /scwm/cl_dlv_management=>get_doccat_instance(
      EXPORTING
        iv_doccat    = iv_doccat
      RECEIVING
        eo_instance  = lo_man
      EXCEPTIONS
        wrong_doccat = 1
        OTHERS       = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_ref_is_initial.
    ENDIF.

    lo_man->get_warehouse(
      EXPORTING
        iv_doccat = iv_doccat
        iv_docid  = iv_docid
      IMPORTING
        ev_whno   = rv_lgnum ).

  ENDMETHOD.


  METHOD get_inst.

    ro_util = mo_singleton.

  ENDMETHOD.


  METHOD get_lgpla_mast.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Get storage bin's master data
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-15¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    CALL FUNCTION '/SCWM/LAGP_READ_SINGLE'
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_lgpla      = iv_lgpla
        iv_nobuf      = CONV xfeld( xsdbool( NOT iv_read_from_buf = abap_true ) )
      IMPORTING
        es_lagp       = rs_lagp
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        enqueue_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_vi02_not_found USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD get_matnr_by_matid.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Get material number by material ID
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-23¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    go_stock_fields->get_matkey_by_id(
      EXPORTING
        iv_matid = iv_matid
      IMPORTING
        ev_matnr = rv_matnr ).

  ENDMETHOD.


  METHOD get_t300_md.

    CALL FUNCTION '/SCWM/T300_MD_READ_SINGLE'
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_scuguid = iv_scuguid
      IMPORTING
        es_t300_md = rs_t300_md
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_vi02_general_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD get_t340d.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Read from DB table /SCWM/T340D
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-20¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    CALL FUNCTION '/SCWM/T340D_READ_SINGLE'
      EXPORTING
        iv_lgnum  = iv_lgnum
      IMPORTING
        es_t340d  = rs_t340d
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_vi02_not_found USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD get_tmstmp.

    GET TIME STAMP FIELD rv_tmstmp.

  ENDMETHOD.


  METHOD i_eq.
*----------------------------------------------------------------------*
* Swisslog / Qinlox for SBB
*----------------------------------------------------------------------*
* Package:     ZEW_1
* Description: Convert a single value to an inclusive range
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author                ¦Description
* -----¦----------¦----------------------¦-----------------------------*
* 1.0  ¦2023-03-15¦Ivan Asenov           ¦Initial
*----------------------------------------------------------------------*

    rt_output = VALUE #( ( sign   = wmegc_sign_inclusive
                           option = wmegc_option_eq
                           low    = iv_input ) ).

  ENDMETHOD.


  METHOD line_exists_gen.

    LOOP AT it_itab
      TRANSPORTING NO FIELDS
      USING KEY (iv_key)
      FROM iv_from
      TO COND #( WHEN iv_to IS SUPPLIED
                 THEN iv_to
                 ELSE lines( it_itab ) )
      WHERE (iv_cond).

      rv_exists = abap_true.
      RETURN.

    ENDLOOP.

  ENDMETHOD.


  METHOD line_index_gen.

    LOOP AT it_itab
      TRANSPORTING NO FIELDS
      USING KEY (iv_key)
      FROM iv_from
      TO COND #( WHEN iv_to IS SUPPLIED
                 THEN iv_to
                 ELSE lines( it_itab ) )
      WHERE (iv_cond).

      rv_index = sy-tabix.
      RETURN.

    ENDLOOP.

  ENDMETHOD.


  METHOD on_transaction_finished.

    " Deregister self
    SET HANDLER on_transaction_finished ACTIVATION abap_false.

  ENDMETHOD.


  METHOD reg_dummy_upd_fm.

    " DEV NOTE: at most one registration is done per SAP LUW
    SET HANDLER on_transaction_finished.
    IF sy-subrc = 0.
      CALL FUNCTION '/BOBF/TRA_DUMMY_UPDATE_TASK' IN UPDATE TASK.
    ENDIF.

  ENDMETHOD.


  METHOD sleep.

    " Avoid communication with the enqueue server if possible
    IF iv_sec <= 0.
      RETURN.
    ENDIF.

    " Suspend execution for several seconds
    " (*) without releasing the work process
    " (*) without causing an implicit database commit
    CALL FUNCTION 'ENQUE_SLEEP'
      EXPORTING
        seconds        = iv_sec
      EXCEPTIONS
        system_failure = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      " System failure
      RAISE EXCEPTION TYPE zcx_vi02_general_exception
        MESSAGE e010(s10).
    ENDIF.

  ENDMETHOD.


  METHOD write_log.

    IF io_log IS NOT BOUND
    OR lines( io_log->mp_protocol ) = 0.
      RETURN.
    ENDIF.

    CALL FUNCTION '/SCWM/APP_LOG_WRITE_V2'
      IN UPDATE TASK
      EXPORTING
        is_log     = is_bal
        it_bapiret = io_log->mp_protocol.

  ENDMETHOD.


  METHOD write_log_actlog.

    "=== Local structures ======================================================
    DATA:
      ls_log_act TYPE /scwm/log_act,
      ls_bal     TYPE bal_s_log.
    "=== Local tables ==========================================================
    DATA:
      lt_bapiret TYPE bapirettab.
    "===========================================================================

    IF io_log IS NOT BOUND
    OR lines( io_log->mp_protocol ) = 0.
      RETURN.
    ENDIF.

    " Get activation level of log
    CALL FUNCTION '/SCWM/LOG_ACT_READ_SINGLE'
      EXPORTING
        iv_lgnum     = iv_lgnum
        iv_subobject = is_bal-subobject
      IMPORTING
        es_log_act   = ls_log_act
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Determine if whole log should be written based on severity
    CASE ls_log_act-actglob.
      WHEN wmegc_log_vip.
        IF io_log->mp_severity NA wmegc_severity_abort.
          RETURN.
        ENDIF.

      WHEN wmegc_log_imp.
        IF io_log->mp_severity NA wmegc_severity_ea.
          RETURN.
        ENDIF.

      WHEN wmegc_log_med.
        IF io_log->mp_severity NA wmegc_severity_wea.
          RETURN.
        ENDIF.

      WHEN wmegc_log_add.
        IF io_log->mp_severity NA wmegc_severity_wea
                               && /scwm/cl_log=>msgty_success
                               && /scwm/cl_log=>msgty_info.
          RETURN.
        ENDIF.

      WHEN OTHERS.
        RETURN.
    ENDCASE.

    " Remove informational messages if necessary
    lt_bapiret = io_log->mp_protocol.
    IF ls_log_act-no_info = abap_true.
      DELETE lt_bapiret WHERE type = /scwm/cl_log=>msgty_info.
    ENDIF.
    IF lines( lt_bapiret ) = 0.
      RETURN.
    ENDIF.

    " Determine expiration date for log
    ls_bal = is_bal.
    CALL FUNCTION '/SCWM/APP_LOG_EXPIRY_DATE_DET'
      EXPORTING
        is_log_act = ls_log_act
      CHANGING
        cs_log     = ls_bal.

    " Write application log in update task with low priority
    CALL FUNCTION '/SCWM/APP_LOG_WRITE_V2'
      IN UPDATE TASK
      EXPORTING
        is_log     = ls_bal
        it_bapiret = lt_bapiret.

  ENDMETHOD.
ENDCLASS.
