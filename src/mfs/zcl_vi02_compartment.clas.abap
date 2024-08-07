class ZCL_VI02_COMPARTMENT definition
  public
  inheriting from /SL0/CL_OBJECT
  final
  create public .

public section.

  interfaces /SL0/IF_BC_OBJECT .

  methods CONSTRUCTOR
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_COMPARTMENT type Z_VI02_DE_COMPARTMENT
      !IO_LOG type ref to /SL0/CL_LOG_EWM optional
    raising
      ZCX_VI02_GENERAL_EXCEPTION
      /SL0/CX_GENERAL_EXCEPTION .
  methods SET_STATUSES_AS
    importing
      !IV_STATUS type J_TXT04
      !IV_REFRESH_BUFFER type XFELD default ABAP_TRUE
      !I_COMMIT type XFELD default ABAP_TRUE
      !I_WAIT type XFELD default ABAP_TRUE
    raising
      /SL0/CX_GENERAL_EXCEPTION .
  methods IS_NOT_USED
    returning
      value(RV_RESULT) type XFELD
    raising
      /SL0/CX_GENERAL_EXCEPTION .
  methods RESET
    raising
      ZCX_VI02_GENERAL_EXCEPTION
      /SL0/CX_GENERAL_EXCEPTION .
  methods RESERVE
    importing
      !IV_REFRESH_BUFFER type XFELD optional
      !I_COMMIT type XFELD optional
      !I_WAIT type XFELD optional
      !IV_STATUS type J_TXT04
    returning
      value(RV_RESULT) type XFELD
    raising
      ZCX_VI02_GENERAL_EXCEPTION
      /SL0/CX_GENERAL_EXCEPTION .
protected section.

  types:
    BEGIN OF ts_bin,
           lgpla      TYPE /scwm/lgpla,
           o_bin      TYPE REF TO /sl0/cl_storage_bin,
           old_status TYPE j_txt04,
           new_status TYPE j_txt04,
         END OF ts_bin .
  types:
    tt_bin TYPE STANDARD TABLE OF ts_bin WITH DEFAULT KEY .

  data MV_COMPARTMENT type Z_VI02_DE_COMPARTMENT .
  constants:
    BEGIN OF co_stsma,
      zbinstat TYPE crm_j_stsma VALUE 'ZBINSTAT' ##NO_TEXT,
    END OF co_stsma .
  constants:
    BEGIN OF co_user_status,
      init TYPE j_txt04 VALUE 'INIT' ##NO_TEXT,
      blck TYPE j_txt04 VALUE 'BLCK' ##NO_TEXT,
      zep0 TYPE j_txt04 VALUE 'ZEP0' ##NO_TEXT,
      zip0 TYPE j_txt04 VALUE 'ZIP0' ##NO_TEXT,
    END OF co_user_status .
  data MO_SERVICES type ref to ZCL_VI02_SERVICE_COMPARTMENT .

  methods CHANGE_USER_STATUSES
    importing
      !IV_REFRESH_BUFFER type XFELD default ABAP_TRUE
      !I_COMMIT type XFELD default ABAP_TRUE
      !I_WAIT type XFELD default ABAP_TRUE
    changing
      !CT_BIN_USER_STATUS_CHG type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS_CHG
    raising
      /SL0/CX_GENERAL_EXCEPTION .
  methods READ_BINS
    importing
      !IV_LOCK type XFELD optional
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
private section.

  data MT_LAGP type /SCWM/TT_LAGP .
ENDCLASS.



CLASS ZCL_VI02_COMPARTMENT IMPLEMENTATION.


  method /SL0/IF_BC_OBJECT~CLEANUP.
  endmethod.


  METHOD /sl0/if_bc_object~free.
  ENDMETHOD.


  METHOD change_user_statuses.

    DATA:
      ls_guid_loc TYPE /scwm/s_guid_loc,
      lt_guid_loc TYPE /scwm/tt_guid_loc.

* Check incoming parameter
    LOOP AT ct_bin_user_status_chg ASSIGNING FIELD-SYMBOL(<ls_bin_status_chg>).
      IF <ls_bin_status_chg>-status IS INITIAL.
        MESSAGE e011(/sl0/bin)  INTO /sl0/cl_log_ewm=>mv_dummy_msg.
        mo_log->add_message( ).
        /sl0/cx_general_exception=>raise_system_exception( ).
      ELSE.
        <ls_bin_status_chg>-estat = mo_services->conv_user_status_ext_2_int( <ls_bin_status_chg>-status ).
      ENDIF.

      IF  <ls_bin_status_chg>-estat IS INITIAL.
        MESSAGE e012(/sl0/bin) WITH <ls_bin_status_chg>-status INTO /sl0/cl_log_ewm=>mv_dummy_msg.
        mo_log->add_message( ).
        /sl0/cx_general_exception=>raise_system_exception( ).
      ENDIF.

      IF <ls_bin_status_chg>-guid_loc IS NOT INITIAL.
        <ls_bin_status_chg>-guid_loc =  mt_lagp[ lgnum = <ls_bin_status_chg>-lgnum
                                                 lgpla = <ls_bin_status_chg>-lgpla ]-guid_loc.
      ENDIF.

      IF <ls_bin_status_chg>-guid_loc IS INITIAL.
        MESSAGE e012(/sl0/bin) WITH <ls_bin_status_chg>-status INTO /sl0/cl_log_ewm=>mv_dummy_msg.
        mo_log->add_message( ).
        /sl0/cx_general_exception=>raise_system_exception( ).
      ENDIF.
      ls_guid_loc = VALUE #( guid_loc = <ls_bin_status_chg>-guid_loc ).
      APPEND ls_guid_loc TO lt_guid_loc.
    ENDLOOP.

* Fill buffer
    TRY.
        DATA(lt_bin_user_status) = mo_services->get_bin_status_tab( EXPORTING iv_refresh_buffer = iv_refresh_buffer
                                                                              it_guid_loc       = lt_guid_loc
                                                                             ).
      CATCH zcx_vi02_general_exception.
        /sl0/cx_general_exception=>raise_system_exception( ).
    ENDTRY.


* Change USER status
    LOOP AT ct_bin_user_status_chg ASSIGNING <ls_bin_status_chg>.

      CALL FUNCTION 'CRM_STATUS_CHANGE_EXTERN'
        EXPORTING
          objnr               = <ls_bin_status_chg>-guid_loc
          user_status         = <ls_bin_status_chg>-estat
          set_inact           = <ls_bin_status_chg>-set_inactive
          no_check            = abap_true
*   IMPORTING
*         STONR               =
        EXCEPTIONS
          object_not_found    = 1
          status_inconsistent = 2
          status_not_allowed  = 3
          error_messages      = 98
          OTHERS              = 99.
      DATA(lv_subrc) = sy-subrc.
      IF lv_subrc  IS NOT INITIAL.
        EXIT.
      ELSE.
        zcl_vi02_service_compartment=>update_bin_status_buffer(
          iv_guid_loc = <ls_bin_status_chg>-guid_loc
          iv_status   = <ls_bin_status_chg>-status
        ).
      ENDIF.
    ENDLOOP.
    IF lv_subrc  <> 0.

      mo_log->add_message( ).

      IF i_commit = abap_true.
        me->rollback( ).
      ENDIF.

      /sl0/cx_general_exception=>raise_system_exception( ).

    ELSE.

      CALL FUNCTION '/SCWM/BIN_STATUS_SAVE'.

      IF i_commit = abap_true.

        me->commit( i_wait = i_wait ).

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    super->constructor(
      EXPORTING
        i_lgnum = iv_lgnum
        io_log  = io_log ).

    mo_services = zcl_vi02_service_compartment=>get_inst( m_lgnum ).

    mv_compartment = iv_compartment.

    read_bins( ).
  ENDMETHOD.


  METHOD is_not_used.
    DATA:

      lt_tap     TYPE /scwm/tt_ltap_vb,
      lt_huitm   TYPE /scwm/tt_stock_select,
      lt_ordim_o TYPE /scwm/tt_ordim_o.
    CLEAR rv_result.

    TRY.

        read_bins( ).

      CATCH zcx_vi02_general_exception.
        /sl0/cx_general_exception=>raise_system_exception( ).
    ENDTRY.

    CALL FUNCTION '/SCWM/L_TO_GET_INFO'
      IMPORTING
        et_ltap_vb = lt_tap.


    LOOP AT lt_tap INTO DATA(ls_tap) WHERE vlpla IS NOT INITIAL OR nlpla IS NOT INITIAL.
      IF ls_tap-vlpla IS NOT INITIAL.
        IF line_exists( mt_lagp[ lgnum = m_lgnum lgpla = ls_tap-vlpla ] ).
          RETURN.
        ENDIF.
      ENDIF.
      IF ls_tap-nlpla IS NOT INITIAL.
        IF line_exists( mt_lagp[ lgnum = m_lgnum lgpla = ls_tap-nlpla ] ).
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION '/SCWM/SELECT_STOCK'
      EXPORTING
        iv_lgnum = m_lgnum
        ir_lgpla = VALUE rseloption( FOR ls_lagp IN mt_lagp ( sign = 'I' option = 'EQ' low = ls_lagp-lgpla ) )
      IMPORTING
        et_huitm = lt_huitm
      EXCEPTIONS
        error    = 1
        OTHERS   = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ELSEIF lt_ordim_o IS NOT INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION '/SCWM/TO_READ_DES'
      EXPORTING
        iv_lgnum         = m_lgnum
        it_lgpla         = VALUE /scwm/tt_lgpla( FOR ls_lagp IN mt_lagp ( ls_lagp-lgpla ) )
        iv_nobuf         = 'X'
        iv_add_to_memory = ' '
      IMPORTING
        et_ordim_o       = lt_ordim_o
      EXCEPTIONS
        wrong_input      = 1
        not_found        = 0
        foreign_lock     = 3
        OTHERS           = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ELSEIF lt_ordim_o IS NOT INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION '/SCWM/TO_READ_SRC'
      EXPORTING
        iv_lgnum         = m_lgnum
        it_lgpla         = VALUE /scwm/tt_lgpla( FOR ls_lagp IN mt_lagp ( ls_lagp-lgpla ) )
        iv_nobuf         = 'X'
        iv_add_to_memory = ' '
      IMPORTING
        et_ordim_o       = lt_ordim_o
      EXCEPTIONS
        wrong_input      = 1
        not_found        = 0
        foreign_lock     = 3
        OTHERS           = 99.
    IF sy-subrc <> 0.
      /sl0/cx_general_exception=>raise_system_exception( ).
    ELSEIF lt_ordim_o IS NOT INITIAL.
      RETURN.
    ENDIF.

    rv_result = 'X'.
  ENDMETHOD.


  METHOD read_bins.

    DATA: lt_lgpla TYPE  /scwm/tt_lagp_key,
          lr_lgpla TYPE /scwm/tt_lgpla_r.
*"
    CLEAR mt_lagp.

    LOOP AT zcl_vi02_service_compartment=>get_inst( iv_lgnum = m_lgnum )->get_bins_4_compartment( iv_compartment = mv_compartment ) INTO DATA(lv_lgpla).
      lr_lgpla = VALUE /scwm/tt_lgpla_r( BASE lr_lgpla ( sign   = if_fsbp_const_range=>sign_include
                                                         option = if_fsbp_const_range=>option_equal
                                                         low    = lv_lgpla ) ).
    ENDLOOP.

    IF lt_lgpla IS INITIAL.
      zcx_vi02_general_exception=>raise_sy_msg( ).
      RETURN.
    ENDIF.

    SELECT lgnum, lgpla
      FROM /scwm/lagp
      INTO CORRESPONDING FIELDS OF TABLE @lt_lgpla
     WHERE lgnum      = @m_lgnum
       AND lgtyp      IN ('AA38','AF36','AC37' )
*       AND lgber      IN lrt_lgber
       AND lgpla      IN @lr_lgpla[]. "LIKE @mv_compartment.
    IF sy-subrc IS NOT INITIAL.
      zcx_vi02_general_exception=>raise_sy_msg( ).
      RETURN.
    ENDIF.


    CALL FUNCTION '/SCWM/LAGP_READ_MULTI'
      EXPORTING
        it_lgpla      = lt_lgpla
        iv_enqueue    = iv_lock
        iv_complete   = iv_lock
      IMPORTING
        et_lagp       = mt_lagp
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        enqueue_error = 3
        OTHERS        = 4.
    IF sy-subrc IS NOT INITIAL.
      zcx_vi02_general_exception=>raise_sy_msg( ).
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD reserve.

    DATA:
      lv_status              TYPE j_txt04,
      lt_bin_user_status_chg TYPE zcl_vi02_service_compartment=>tt_bin_user_status_chg.

    IF is_not_used( ) EQ abap_true.


      LOOP AT mt_lagp INTO DATA(ls_lagp).
        IF zcl_vi02_service_compartment=>get_inst( iv_lgnum = m_lgnum )->is_bin_usable_for_status( iv_status = iv_status iv_lgpla = ls_lagp-lgpla ).
          lv_status = iv_status.
        ELSE.
          lv_status = co_user_status-blck.
        ENDIF.

        APPEND VALUE #( lgnum = ls_lagp-lgnum lgpla = ls_lagp-lgpla guid_loc = ls_lagp-guid_loc  status = lv_status ) TO lt_bin_user_status_chg.
      ENDLOOP.


      CALL METHOD change_user_statuses
        EXPORTING
          iv_refresh_buffer      = iv_refresh_buffer
          i_commit               = i_commit
          i_wait                 = i_wait
        CHANGING
          ct_bin_user_status_chg = lt_bin_user_status_chg.
    ELSE.
      MESSAGE e104(z_vi02_general) WITH mv_compartment INTO /sl0/cl_log_ewm=>mv_dummy_msg.
      mo_log->add_message( ).

      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.


  ENDMETHOD.


  METHOD reset.
    DATA:
      lt_bin_user_status_chg TYPE zcl_vi02_service_compartment=>tt_bin_user_status_chg.


    IF is_not_used( ) EQ abap_true.

      LOOP AT mt_lagp INTO DATA(ls_lagp).
        APPEND VALUE #( lgnum = ls_lagp-lgnum lgpla = ls_lagp-lgpla guid_loc = ls_lagp-guid_loc  status = co_user_status-init ) TO lt_bin_user_status_chg.
      ENDLOOP.


      CALL METHOD change_user_statuses
        EXPORTING
          iv_refresh_buffer      = 'X'
          i_commit               = 'X'
          i_wait                 = 'X'
        CHANGING
          ct_bin_user_status_chg = lt_bin_user_status_chg.

    ELSE.
      MESSAGE e104(z_vi02_general) WITH mv_compartment INTO /sl0/cl_log_ewm=>mv_dummy_msg.
      mo_log->add_message( ).

      /sl0/cx_general_exception=>raise_system_exception( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_statuses_as.
    DATA: lt_bin_user_status_chg TYPE zcl_vi02_service_compartment=>tt_bin_user_status_chg.
    "   *    TRY.
    LOOP AT mt_lagp INTO DATA(ls_lagp).
      APPEND VALUE #( lgnum = ls_lagp-lgnum lgpla = ls_lagp-lgpla guid_loc = ls_lagp-guid_loc  status = iv_status ) TO lt_bin_user_status_chg.
    ENDLOOP.
    CALL METHOD change_user_statuses
      EXPORTING
        iv_refresh_buffer      = iv_refresh_buffer "abap_true
        i_commit               = i_commit "abap_true
        i_wait                 = i_wait "abap_true
      CHANGING
        ct_bin_user_status_chg = lt_bin_user_status_chg.
    "    CATCH /sl0/cx_general_exception.
    "      /sl0/cx_general_exception=>raise_exception( ).
    "  ENDTRY.

  ENDMETHOD.
ENDCLASS.
