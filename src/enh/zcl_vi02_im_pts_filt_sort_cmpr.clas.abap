CLASS zcl_vi02_im_pts_filt_sort_cmpr DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /sl0/if_ex_core_pts_filt_sort .
  PROTECTED SECTION.

    METHODS filter_and_sort_bins
      IMPORTING
        !is_t331        TYPE /scwm/t331
        !is_t333        TYPE /scwm/t333
        !is_ltap        TYPE /scwm/ltap
        !is_mat_global  TYPE /scwm/s_material_global
        !is_mat_lgnum   TYPE /scwm/s_material_lgnum
        !is_mat_lgtyp   TYPE /scwm/s_material_lgtyp
        !is_mat_hazard  TYPE /scwm/s_material_hazard
        !it_mat_uom     TYPE /scwm/tt_material_uom
      CHANGING
        !ct_lagp_reserv TYPE /scwm/tt_nearfixbin
        !ct_qmat        TYPE /scwm/tt_aqua_int
        !ct_hlplagpl    TYPE /scwm/tt_lagpl
        !cs_ordim_cust  TYPE /scwm/incl_eew_s_ordim
        !co_log         TYPE REF TO /scwm/cl_log .
private section.

  methods FILTER_BASED_ON_USER_STATUS
    importing
      !IV_STATUS type J_TXT04
      !IS_LTAP type /SCWM/LTAP
      !IT_BIN_USER_STATUS type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
    changing
      !CT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !CT_QMAT type /SCWM/TT_AQUA_INT
      !CT_HLPLAGPL type /SCWM/TT_LAGPL
      !CO_LOG type ref to /SCWM/CL_LOG .
  methods FILTER_BLOCKED
    importing
      !IS_LTAP type /SCWM/LTAP
      !IT_BIN_USER_STATUS type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
    changing
      !CT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !CT_QMAT type /SCWM/TT_AQUA_INT
      !CT_HLPLAGPL type /SCWM/TT_LAGPL
      !CO_LOG type ref to /SCWM/CL_LOG .
  methods FIND_BIN_NEXT_EMPTY_COMPARMENT
    importing
      !IV_STATUS type J_TXT04
      !IT_BIN_USER_STATUS type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
      !IS_LTAP type /SCWM/LTAP
    changing
      !CT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !CT_QMAT type /SCWM/TT_AQUA_INT
      !CT_HLPLAGPL type /SCWM/TT_LAGPL
      !CO_LOG type ref to /SCWM/CL_LOG
    returning
      value(RV_FOUND) type ABAP_BOOL .
  methods FIND_BIN_WITH_SAME_BATCH
    importing
      !IS_T331 type /SCWM/T331
      !IV_STATUS type J_TXT04
      !IT_BIN_USER_STATUS type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
      !IS_LTAP type /SCWM/LTAP
    changing
      !CT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !CT_QMAT type /SCWM/TT_AQUA_INT
      !CT_HLPLAGPL type /SCWM/TT_LAGPL
      !CO_LOG type ref to /SCWM/CL_LOG
    returning
      value(RV_FOUND) type ABAP_BOOL .
  methods FIND_BIN_WITH_USER_STATUS
    importing
      !IV_STATUS type J_TXT04
      !IT_BIN_USER_STATUS type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
      !IS_LTAP type /SCWM/LTAP
    changing
      !CT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !CT_QMAT type /SCWM/TT_AQUA_INT
      !CT_HLPLAGPL type /SCWM/TT_LAGPL
      !CO_LOG type ref to /SCWM/CL_LOG
    returning
      value(RV_FOUND) type ABAP_BOOL .
  methods GET_BIN_USER_STATUS_TAB
    importing
      !IS_T331 type /SCWM/T331
      !IT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
      !IT_QMAT type /SCWM/TT_AQUA_INT
      !IT_HLPLAGPL type /SCWM/TT_LAGPL
    changing
      !CO_LOG type ref to /SCWM/CL_LOG
    returning
      value(RT_BIN_USER_STATUS) type ZCL_VI02_SERVICE_COMPARTMENT=>TT_BIN_USER_STATUS
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods GET_NEEDED_USER_STATUS
    importing
      !IS_LTAP type /SCWM/LTAP
    returning
      value(RV_STATUS) type J_TXT04
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods IS_LGTYP_RELEVANT_CHK_BATCH
    importing
      !IS_T331 type /SCWM/T331
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods IS_LGTYP_RELEVANT_CHK_COMPAR
    importing
      !IS_T331 type /SCWM/T331
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods RESERVE_COMPARTMENT
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_COMPARTMENT type Z_VI02_DE_COMPARTMENT
      !IV_STATUS type J_TXT04
    changing
      !CO_LOG type ref to /SCWM/CL_LOG
    returning
      value(RV_RESULT) type XFELD .
  methods BUILD_LGPLA_RANGE
    importing
      !IT_QMAT type /SCWM/TT_AQUA_INT
      !IT_HLPLAGPL type /SCWM/TT_LAGPL
      !IT_LAGP_RESERV type /SCWM/TT_NEARFIXBIN
    returning
      value(RR_LGPLA) type /SCWM/TT_LGPLA_R .
ENDCLASS.



CLASS ZCL_VI02_IM_PTS_FILT_SORT_CMPR IMPLEMENTATION.


  METHOD /sl0/if_ex_core_pts_filt_sort~filt_sort.

*======================================================================*
* Definition
*======================================================================*
    DATA: lo_log      TYPE REF TO /sl0/cl_log_mfs.
*|Constants
    CONSTANTS: lc_processor TYPE char60 VALUE 'ZCL_VI02_IM_PTS_FILT_SORT_CMPR->FILT_SORT'.

*======================================================================*
* Initialization
*======================================================================*
    "Check if storage type is relevant (AA38, AC37, AF36)
    IF abap_true NE is_lgtyp_relevant_chk_compar( is_t331 ).
      RETURN. "not relevant
    ENDIF.

*======================================================================*
* Input
*======================================================================*

*======================================================================*
* Instantiate MFS helper and HU objects to select and process data
*======================================================================*
    TRY.
*           Initialize log protocol instance..
        lo_log ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum   = is_ltap-lgnum
                                                            io_log     = lo_log
                                                            io_sap_log = co_log ).
      CATCH /sl0/cx_general_exception .
    ENDTRY.
*======================================================================*
* Register begin of protocol logging
*======================================================================*
    TRY.
        lo_log->start_log( EXPORTING iv_processor = lc_processor
                                     iv_proc_type = /sl0/cl_log_abstract=>mc_proc_meth ).
      CATCH /sl0/cx_general_exception .                 "#EC NO_HANDLER
    ENDTRY.

    CALL METHOD filter_and_sort_bins
      EXPORTING
        is_t331        = is_t331
        is_t333        = is_t333
        is_ltap        = is_ltap
        is_mat_global  = is_mat_global
        is_mat_lgnum   = is_mat_lgnum
        is_mat_lgtyp   = is_mat_lgtyp
        is_mat_hazard  = is_mat_hazard
        it_mat_uom     = it_mat_uom
      CHANGING
        ct_lagp_reserv = ct_lagp_reserv
        ct_qmat        = ct_qmat
        ct_hlplagpl    = ct_hlplagpl
        cs_ordim_cust  = cs_ordim_cust
        co_log         = co_log.

*======================================================================*
* Output
*======================================================================*
    TRY.

        lo_log->end_log( EXPORTING iv_processor   = lc_processor
                                   iv_proc_type   = /sl0/cl_log_abstract=>mc_proc_meth
                                   iv_force_write = abap_false
                                   io_log         = co_log ).

      CATCH /sl0/cx_general_exception.    "
      CATCH /scwm/cx_basics.    "
    ENDTRY.


  ENDMETHOD.


  METHOD build_lgpla_range.
    CLEAR rr_lgpla .
    LOOP AT it_qmat INTO DATA(ls_qmat).
      rr_lgpla = VALUE /scwm/tt_lgpla_r( BASE rr_lgpla ( sign   = if_fsbp_const_range=>sign_include
                                                         option = if_fsbp_const_range=>option_equal
                                                         low    = ls_qmat-lgpla ) ).
    ENDLOOP.

    LOOP AT it_hlplagpl INTO DATA(ls_hlplagpl).
      rr_lgpla = VALUE /scwm/tt_lgpla_r( BASE rr_lgpla ( sign   = if_fsbp_const_range=>sign_include
                                                         option = if_fsbp_const_range=>option_equal
                                                         low    = ls_hlplagpl-lgpla ) ).
    ENDLOOP.


    LOOP AT it_lagp_reserv INTO DATA(ls_lagp_reserv).
      rr_lgpla = VALUE /scwm/tt_lgpla_r( BASE rr_lgpla ( sign   = if_fsbp_const_range=>sign_include
                                                         option = if_fsbp_const_range=>option_equal
                                                         low    = ls_lagp_reserv-lgpla ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_and_sort_bins.

    TRY.
        "check the storage bin type ( it should be relevant otherwise this method would not be called )
        IF abap_true NE is_lgtyp_relevant_chk_compar( is_t331 ).
          RETURN.
        ENDIF.

        "get the needed user status based on the HU type
        DATA(lv_status) = get_needed_user_status( is_ltap ).


        DATA(lt_bin_user_status) = get_bin_user_status_tab( EXPORTING is_t331        = is_t331
                                                                      it_lagp_reserv = ct_lagp_reserv
                                                                      it_qmat        = ct_qmat
                                                                      it_hlplagpl    = ct_hlplagpl
                                                            CHANGING  co_log         = co_log ).

        filter_blocked( EXPORTING is_ltap            = is_ltap
                                  it_bin_user_status = lt_bin_user_status
                        CHANGING  ct_lagp_reserv     = ct_lagp_reserv
                                  ct_qmat            = ct_qmat
                                  ct_hlplagpl        = ct_hlplagpl
                                  co_log             = co_log ).

        "Filter all (blocked) foreign storage bins
        filter_based_on_user_status( EXPORTING iv_status          = lv_status
                                               is_ltap            = is_ltap
                                               it_bin_user_status = lt_bin_user_status
                                     CHANGING  ct_lagp_reserv     = ct_lagp_reserv
                                               ct_qmat            = ct_qmat
                                               ct_hlplagpl        = ct_hlplagpl
                                               co_log             = co_log ).


        "search for the same product+batch
        IF abap_true EQ find_bin_with_same_batch(
                                            EXPORTING   is_t331             = is_t331
                                                        it_bin_user_status  = lt_bin_user_status
                                                        iv_status           = lv_status
                                                        is_ltap             = is_ltap
                                            CHANGING    ct_lagp_reserv      = ct_lagp_reserv
                                                        ct_qmat             = ct_qmat
                                                        ct_hlplagpl         = ct_hlplagpl
                                                        co_log              = co_log ).
          RETURN.
        ENDIF.

        "find bin with same status(e.g. ZEP0)
        IF abap_true EQ find_bin_with_user_status(
                                            EXPORTING   iv_status          = lv_status
                                                        is_ltap            = is_ltap
                                                        it_bin_user_status = lt_bin_user_status
                                            CHANGING    ct_lagp_reserv     = ct_lagp_reserv
                                                        ct_qmat            = ct_qmat
                                                        ct_hlplagpl        = ct_hlplagpl
                                                        co_log             = co_log ).
          RETURN.
        ENDIF.

        "find bin with INIT user status
        IF abap_true EQ find_bin_next_empty_comparment( EXPORTING  iv_status          = lv_status
                                                                   is_ltap            = is_ltap
                                                                   it_bin_user_status = lt_bin_user_status
                                                        CHANGING   ct_lagp_reserv     = ct_lagp_reserv
                                                                   ct_qmat            = ct_qmat
                                                                   ct_hlplagpl        = ct_hlplagpl
                                                                   co_log             = co_log ).
          RETURN.
        ENDIF.

      CATCH zcx_vi02_general_exception INTO DATA(lx_gen_exc).
        "something has seriously went wrong
        "so better to clear the bins table(s) (so no bin will be found for this storage bin)
        "and write the last error to the log
        CLEAR:  ct_lagp_reserv,
                ct_qmat,
                ct_hlplagpl.

        lx_gen_exc->get_sy_msg( ).
        co_log->add_message( ip_row = 0 ).

    ENDTRY.


  ENDMETHOD.


  METHOD filter_based_on_user_status.
    DATA:
      lr_lgpla_no_status_match TYPE /scwm/tt_lgpla_r.

    DATA(lr_lgpla) = build_lgpla_range( it_qmat        = ct_qmat
                                        it_hlplagpl    = ct_hlplagpl
                                        it_lagp_reserv = ct_lagp_reserv
                                        ).
    IF lr_lgpla IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT it_bin_user_status INTO DATA(ls_bin_user_status) WHERE lgnum    EQ is_ltap-lgnum
                                                               AND lgpla    IN lr_lgpla
                                                               AND  status  NE iv_status
                                                               AND status   NE zcl_vi02_service_compartment=>co_user_status-init.
      lr_lgpla_no_status_match = VALUE /scwm/tt_lgpla_r( BASE lr_lgpla_no_status_match (  sign   = if_fsbp_const_range=>sign_include
                                                                                          option = if_fsbp_const_range=>option_equal
                                                                                          low    = ls_bin_user_status-lgpla ) ).
    ENDLOOP.

    IF lr_lgpla_no_status_match IS INITIAL.
      RETURN.
    ENDIF.

    DELETE ct_lagp_reserv WHERE lgpla IN lr_lgpla_no_status_match.
    DELETE ct_qmat        WHERE lgpla IN lr_lgpla_no_status_match.
    DELETE ct_hlplagpl    WHERE lgpla IN lr_lgpla_no_status_match.


  ENDMETHOD.


  METHOD filter_blocked.
    DATA:
      lr_lgpla_blck TYPE /scwm/tt_lgpla_r.

    DATA(lr_lgpla) = build_lgpla_range( it_qmat        = ct_qmat
                                        it_hlplagpl    = ct_hlplagpl
                                        it_lagp_reserv = ct_lagp_reserv
                                        ).


    IF lr_lgpla IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_bin_user_status INTO DATA(ls_bin_user_data) WHERE lgnum  EQ is_ltap-lgnum
                                                             AND lgpla  IN lr_lgpla
                                                             AND status EQ zcl_vi02_service_compartment=>co_user_status-blck.
      lr_lgpla_blck = VALUE /scwm/tt_lgpla_r( BASE lr_lgpla_blck (  sign   = if_fsbp_const_range=>sign_include
                                                                    option = if_fsbp_const_range=>option_equal
                                                                    low    = ls_bin_user_data-lgpla ) ).
    ENDLOOP.


    IF lr_lgpla_blck IS INITIAL.
      RETURN.
    ENDIF.
*|Delete all blocked storage bins
    DELETE ct_lagp_reserv WHERE lgpla IN lr_lgpla_blck.
    DELETE ct_qmat        WHERE lgpla IN lr_lgpla_blck.
    DELETE ct_hlplagpl    WHERE lgpla IN lr_lgpla_blck.

  ENDMETHOD.


  METHOD find_bin_next_empty_comparment.

    DATA: lt_compartment  TYPE STANDARD TABLE OF z_vi02_de_compartment.
    DATA: lr_lgpla_useable TYPE  /scwm/tt_lgpla_r.
    CLEAR rv_found.

    CLEAR ct_qmat.

    DATA(lo_service) = zcl_vi02_service_compartment=>get_inst( iv_lgnum = is_ltap-lgnum ).

    DATA(lr_lgpla) = build_lgpla_range( it_qmat        = ct_qmat
                                        it_hlplagpl    = ct_hlplagpl
                                        it_lagp_reserv = ct_lagp_reserv
                                        ).
    IF lr_lgpla IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT lr_lgpla ASSIGNING FIELD-SYMBOL(<ls_lgpla>).
      IF abap_true NE lo_service->is_bin_usable_for_status( iv_status = iv_status
                                                            iv_lgpla  = <ls_lgpla>-low ).
        CONTINUE.
      ENDIF.
      READ TABLE it_bin_user_status INTO DATA(ls_bin_user_status)
                                  WITH KEY lgnum = is_ltap-lgnum
                                           lgpla = <ls_lgpla>-low.
      IF sy-subrc IS INITIAL AND ls_bin_user_status-status  EQ zcl_vi02_service_compartment=>co_user_status-init.
        DATA(lv_compartment) = lo_service->get_compartment( <ls_lgpla>-low ).
        IF lv_compartment IS NOT INITIAL.

        ENDIF.
      ENDIF.

    ENDLOOP.

    LOOP AT lt_compartment INTO lv_compartment.
      IF abap_true EQ reserve_compartment(  EXPORTING   iv_lgnum  = is_ltap-lgnum
                                                        iv_compartment = lv_compartment
                                                        iv_status = iv_status
                                            CHANGING     co_log    = co_log ).
        rv_found = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rv_found EQ 'X'.

      LOOP AT lo_service->get_bins_4_compartment( lv_compartment ) INTO DATA(lv_lgpla).
        IF abap_true NE lo_service->is_bin_usable_for_status( iv_status = iv_status
                                                      iv_lgpla  = lv_lgpla ).
          CONTINUE.
        ENDIF.

        lr_lgpla_useable = VALUE /scwm/tt_lgpla_r( BASE lr_lgpla_useable ( sign   = if_fsbp_const_range=>sign_include
                                                                           option = if_fsbp_const_range=>option_equal
                                                                           low    = lv_lgpla ) ).
      ENDLOOP.

      DELETE ct_lagp_reserv WHERE lgpla NOT IN lr_lgpla_useable.
      DELETE ct_qmat        WHERE lgpla NOT IN lr_lgpla_useable.
      DELETE ct_hlplagpl    WHERE lgpla NOT IN lr_lgpla_useable.
    ELSE.
      CLEAR ct_lagp_reserv.
      CLEAR ct_qmat.
      CLEAR ct_hlplagpl.
    ENDIF.


  ENDMETHOD.


  METHOD find_bin_with_same_batch.

    DATA: lt_dst_hu_stock           TYPE /scwm/tt_stock_select,
          lt_huhdr                  TYPE /scwm/tt_huhdr,
          ls_dst_hu_stock_not_saved TYPE /scwm/s_stock_select,
          lt_ltap_not_saved         TYPE /scwm/tt_ltap_vb,
          lt_qmat_not_saved         TYPE /scwm/tt_aqua_int.

    CLEAR rv_found.

    "Check if storage type is relevant (AA38,  AF36)
    IF is_lgtyp_relevant_chk_batch( is_t331 ) IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lr_lgpla) = build_lgpla_range(   it_qmat        = ct_qmat
                                          it_hlplagpl    = ct_hlplagpl
                                          it_lagp_reserv = ct_lagp_reserv
                                        ).


    IF lr_lgpla IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION '/SCWM/SELECT_STOCK'
      EXPORTING
        iv_lgnum = is_ltap-lgnum
        ir_lgpla =  CONV rseloption( lr_lgpla )
      IMPORTING
        et_huitm = lt_dst_hu_stock
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION '/SCWM/L_TO_GET_INFO'
      IMPORTING
        "      et_ltap_vb = lt_ltap_not_saved
        et_qmat = lt_qmat_not_saved.


    LOOP AT lt_qmat_not_saved INTO DATA(ls_qmat_not_saved) WHERE lgpla IN lr_lgpla.
      ls_dst_hu_stock_not_saved = CORRESPONDING #( ls_qmat_not_saved ).
      APPEND ls_dst_hu_stock_not_saved TO lt_dst_hu_stock.
    ENDLOOP.

    DATA(lt_dst_hu_stock_same_batch) = VALUE /scwm/tt_stock_select( FOR ls_dst_hu_stock_for IN lt_dst_hu_stock WHERE ( matid   EQ is_ltap-matid
                                                                                                                   AND batchid EQ is_ltap-batchid )
                                                                                                                   ( ls_dst_hu_stock_for ) ).

    IF lt_dst_hu_stock_same_batch IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lr_lgpla_same_batch) = VALUE /scwm/tt_lgpla_r( FOR ls_dst_hu_stock_same_batch IN lt_dst_hu_stock_same_batch ( sign   = if_fsbp_const_range=>sign_include
                                                                                                                       option = if_fsbp_const_range=>option_equal
                                                                                                                       low    = ls_dst_hu_stock_same_batch-lgpla ) ).

    IF lr_lgpla_same_batch IS NOT INITIAL.

      rv_found  = 'X'.

      DELETE ct_lagp_reserv WHERE lgpla NOT IN lr_lgpla_same_batch.
      DELETE ct_qmat        WHERE lgpla NOT IN lr_lgpla_same_batch.
      DELETE ct_hlplagpl    WHERE lgpla NOT IN lr_lgpla_same_batch.

    ENDIF.



  ENDMETHOD.


  METHOD find_bin_with_user_status.

    DATA:
      lr_lgpla_status_match TYPE /scwm/tt_lgpla_r.

    DATA(lr_lgpla) = build_lgpla_range( it_qmat        = ct_qmat
                                        it_hlplagpl    = ct_hlplagpl
                                        it_lagp_reserv = ct_lagp_reserv
                                        ).
    IF lr_lgpla IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT it_bin_user_status INTO DATA(ls_bin_user_status) WHERE lgnum    EQ is_ltap-lgnum
                                                               AND lgpla    IN lr_lgpla
                                                               AND  status  EQ iv_status.
      lr_lgpla_status_match = VALUE /scwm/tt_lgpla_r( BASE lr_lgpla_status_match (  sign   = if_fsbp_const_range=>sign_include
                                                                                    option = if_fsbp_const_range=>option_equal
                                                                                    low    = ls_bin_user_status-lgpla ) ).
    ENDLOOP.

    IF lr_lgpla_status_match IS NOT INITIAL.
      rv_found  = 'X'.
      RETURN.
    ENDIF.

    DELETE ct_lagp_reserv WHERE lgpla NOT IN lr_lgpla_status_match.
    DELETE ct_qmat        WHERE lgpla NOT IN lr_lgpla_status_match.
    DELETE ct_hlplagpl    WHERE lgpla NOT IN lr_lgpla_status_match.

*    "return just the first one..
*    IF ct_lagp_reserv IS NOT INITIAL.
*      ct_lagp_reserv = VALUE #( ( ct_lagp_reserv[ 1 ] ) ).
*    ENDIF.
*    IF ct_qmat IS NOT INITIAL.
*      ct_qmat = VALUE #( ( ct_qmat[ 1 ] ) ).
*    ENDIF.
*    IF ct_hlplagpl IS NOT INITIAL.
*      ct_hlplagpl = VALUE #( ( ct_hlplagpl[ 1 ] ) ).
*    ENDIF.

  ENDMETHOD.


  METHOD get_bin_user_status_tab.

    CLEAR rt_bin_user_status.

    DATA(lt_lgpla) = VALUE /scwm/tt_lagp_key( FOR ls_lagp_reserv IN it_lagp_reserv (  lgnum   = ls_lagp_reserv-lgnum
                                                                                      lgpla   = ls_lagp_reserv-lgpla ) ).

    lt_lgpla = VALUE /scwm/tt_lagp_key( BASE lt_lgpla FOR ls_hlplagpl  IN it_hlplagpl ( lgnum   = ls_hlplagpl-lgnum
                                                                                        lgpla   = ls_hlplagpl-lgpla ) ).

    lt_lgpla = VALUE /scwm/tt_lagp_key( BASE lt_lgpla FOR ls_qmat IN it_qmat (  lgnum   = ls_qmat-lgnum
                                                                                lgpla   = ls_qmat-lgpla ) ).

    IF lt_lgpla IS INITIAL.
      RETURN.
    ENDIF.

    rt_bin_user_status =  zcl_vi02_service_compartment=>get_inst( is_t331-lgnum )->get_bin_status_tab( EXPORTING it_lgpla = lt_lgpla ).

  ENDMETHOD.


  METHOD get_needed_user_status.

    CLEAR rv_status.

    rv_status  = zcl_vi02_service_compartment=>get_inst( is_ltap-lgnum )->get_needed_user_status( iv_huident  = is_ltap-nlenr
                                                                                                  iv_letyp    = is_ltap-letyp
                                                                                                  iv_hutypgrp = is_ltap-hutypgrp ).
  ENDMETHOD.


  METHOD is_lgtyp_relevant_chk_batch.
    CLEAR rv_result.
    rv_result  = zcl_vi02_service_compartment=>get_inst( is_t331-lgnum )->is_lgtyp_relevant_chk_batch( is_t331-lgtyp ).

  ENDMETHOD.


  METHOD is_lgtyp_relevant_chk_compar.

    CLEAR rv_result.

    rv_result  = zcl_vi02_service_compartment=>get_inst( is_t331-lgnum )->is_lgtyp_relevant_chk_compar( is_t331-lgtyp ).

  ENDMETHOD.


  METHOD RESERVE_COMPARTMENT.


    TRY.
        DATA(lo_compartment) = NEW zcl_vi02_compartment(
          iv_lgnum       = iv_lgnum
          iv_compartment = iv_compartment
       "  io_log         = co_log
        ).

        CALL METHOD lo_compartment->reserve
          EXPORTING
*           iv_refresh_buffer =
*           i_commit  =
*           i_wait    =
            iv_status = iv_status
          RECEIVING
            rv_result = rv_result.
      CATCH zcx_vi02_general_exception.
      CATCH /sl0/cx_general_exception.
        CLEAR rv_result.
    ENDTRY.



  ENDMETHOD.
ENDCLASS.
