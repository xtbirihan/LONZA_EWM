CLASS zcl_vi02_im_core_pts_filt_sort DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /scwm/if_ex_core_pts_filt_sort .
  PROTECTED SECTION.

    TYPES:
      BEGIN OF ts_bin_user_status,
        lgnum     TYPE lgnum,
        lgpla     TYPE /scwm/lgpla,
        status_db TYPE j_txt04,
        status    TYPE j_txt04,
      END OF ts_bin_user_status .
    TYPES:
      tt_bin_user_status TYPE SORTED TABLE OF ts_bin_user_status WITH KEY lgnum lgpla .

    METHODS is_lgtyp_relevant_chk_compar
      IMPORTING
        !is_t331         TYPE /scwm/t331
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_lgtyp_relevant_chk_batch
      IMPORTING
        !is_t331         TYPE /scwm/t331
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS get_needed_user_status
      IMPORTING
        !is_ltap         TYPE /scwm/ltap
      RETURNING
        VALUE(rv_status) TYPE j_txt04
      RAISING
        zcx_vi02_general_exception .
    METHODS filter_based_on_user_status
      IMPORTING
        !iv_status          TYPE j_txt04
        !it_bin_user_status TYPE zcl_vi02_service_compartment=>tt_bin_user_status
      CHANGING
        !ct_hlplagpl        TYPE /scwm/tt_lagpl .
    METHODS find_bin_with_user_status
      IMPORTING
        !iv_status          TYPE j_txt04
        !it_bin_user_status TYPE zcl_vi02_service_compartment=>tt_bin_user_status
      CHANGING
        !ct_hlplagpl        TYPE /scwm/tt_lagpl
      RETURNING
        VALUE(rv_found)     TYPE abap_bool .
    METHODS find_bin_with_same_batch
      IMPORTING
        !is_t331            TYPE /scwm/t331
        !iv_status          TYPE j_txt04
        !it_bin_user_status TYPE zcl_vi02_service_compartment=>tt_bin_user_status
        !is_ltap            TYPE /scwm/ltap
      CHANGING
        !ct_hlplagpl        TYPE /scwm/tt_lagpl
      RETURNING
        VALUE(rv_found)     TYPE abap_bool .
    METHODS find_bin_next_empty_comparment
      IMPORTING
        !iv_status          TYPE j_txt04
        !it_bin_user_status TYPE zcl_vi02_service_compartment=>tt_bin_user_status
      CHANGING
        !ct_hlplagpl        TYPE /scwm/tt_lagpl
      RETURNING
        VALUE(rv_found)     TYPE abap_bool .
    METHODS reserve_comparment
      IMPORTING
        !iv_status TYPE j_txt04 .
    METHODS get_bin_user_status_tab
      IMPORTING
        !is_t331                  TYPE /scwm/t331
        !it_hlplagpl              TYPE /scwm/tt_lagpl
      RETURNING
        VALUE(rt_bin_user_status) TYPE zcl_vi02_service_compartment=>tt_bin_user_status
      RAISING
        zcx_vi02_general_exception .
  PRIVATE SECTION.

    METHODS add_sy_msg_2_tab
      CHANGING
        !ct_bapiret TYPE bapirettab .
ENDCLASS.



CLASS ZCL_VI02_IM_CORE_PTS_FILT_SORT IMPLEMENTATION.


  METHOD /scwm/if_ex_core_pts_filt_sort~filt_sort.
*======================================================================*
* Definition
*======================================================================*
    DATA: lo_log      TYPE REF TO /sl0/cl_log_mfs,
          lo_log_sap  TYPE REF TO /scwm/cl_log,
          lt_qmat_old	TYPE /scwm/tt_aqua_int,
          lt_qmat_hlp	TYPE /scwm/tt_aqua_int,
          lt_qmat	    TYPE /scwm/tt_aqua_int.
*|Constants
    CONSTANTS: lc_processor TYPE char60 VALUE 'ZCL_VI02_IM_CORE_PTS_FILT_SORT->FILT_SORT'.

*======================================================================*
* Initialization
*======================================================================*

*======================================================================*
* Input
*======================================================================*

*======================================================================*
* Breakpoint-ID
*======================================================================*
    BREAK-POINT ID zcg_vi02_core_pts_filt_sort.


*======================================================================*
* Instantiate MFS helper and HU objects to select and process data
*======================================================================*
    TRY.
*           Initialize log protocol instance..
        lo_log ?= /sl0/cl_log_factory=>get_logger_instance( iv_lgnum   = is_ltap-lgnum
                                                            io_log     = lo_log
                                                            "io_sap_log = lo_log_sap
                                                             ).
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

*======================================================================*
* Filter and Sort Bins
*======================================================================*
    DATA(lo_filt_sort_compartment) = NEW zcl_vi02_im_pts_filt_sort_cmpr( ).

    lo_log_sap = lo_log->/sl0/if_log~get_sap_log( ).

    CALL METHOD lo_filt_sort_compartment->/sl0/if_ex_core_pts_filt_sort~filt_sort
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
        ct_bapiret     = et_bapiret
        ct_lagp_reserv = ct_lagp_reserv
        ct_qmat        = ct_qmat
        ct_hlplagpl    = ct_hlplagpl
        cs_ordim_cust  = cs_ordim_cust
        co_log         = lo_log_sap.



*======================================================================*
* Output
*======================================================================*
    TRY.

        lo_log->end_log( EXPORTING iv_processor   = lc_processor
                                   iv_proc_type   = /sl0/cl_log_abstract=>mc_proc_meth
                                   iv_force_write = abap_false
                                   io_log         = lo_log_sap ).

        APPEND LINES OF lo_log_sap->mp_protocol TO et_bapiret.

      CATCH /sl0/cx_general_exception.    "
      CATCH /scwm/cx_basics.    "
    ENDTRY.


  ENDMETHOD.


  METHOD add_sy_msg_2_tab.

    DATA:
      ls_bapiret TYPE bapiret2.

    IF sy-msgty NA 'SWIAXE'.
      RETURN.
    ENDIF.

    CLEAR ls_bapiret.
    ls_bapiret-type       = sy-msgty.
    ls_bapiret-id         = sy-msgid.
    ls_bapiret-number     = sy-msgno.
    ls_bapiret-message_v1 = sy-msgv1.
    ls_bapiret-message_v2 = sy-msgv2.
    ls_bapiret-message_v3 = sy-msgv3.
    ls_bapiret-message_v4 = sy-msgv4.


    MESSAGE ID ls_bapiret-id
          TYPE ls_bapiret-type
        NUMBER ls_bapiret-number
          WITH ls_bapiret-message_v1
               ls_bapiret-message_v2
               ls_bapiret-message_v3
               ls_bapiret-message_v4
          INTO ls_bapiret-message.


    APPEND ls_bapiret TO ct_bapiret.

  ENDMETHOD.


  METHOD filter_based_on_user_status.

    LOOP AT ct_hlplagpl ASSIGNING FIELD-SYMBOL(<ls_hlplagpl>).
      READ TABLE it_bin_user_status INTO DATA(ls_bin_user_status)
                                        WITH KEY lgnum = <ls_hlplagpl>-lgnum
                                                 lgpla = <ls_hlplagpl>-lgpla.
      IF sy-subrc IS NOT INITIAL.
        DELETE ct_hlplagpl.
        CONTINUE.
      ENDIF.

      IF ls_bin_user_status-status  NE iv_status
      AND ls_bin_user_status-status NE zcl_vi02_service_compartment=>co_user_status-init.
        DELETE ct_hlplagpl.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_bin_next_empty_comparment.
    CLEAR rv_found.

    LOOP AT ct_hlplagpl ASSIGNING FIELD-SYMBOL(<ls_hlplagpl>).
      READ TABLE it_bin_user_status INTO DATA(ls_bin_user_status)
                                        WITH KEY lgnum = <ls_hlplagpl>-lgnum
                                                 lgpla = <ls_hlplagpl>-lgpla.
      IF sy-subrc IS NOT INITIAL.
        DELETE ct_hlplagpl.
        CONTINUE.
      ENDIF.

      IF ls_bin_user_status-status  EQ zcl_vi02_service_compartment=>co_user_status-init.

        CONTINUE.
      ELSE.
        DELETE ct_hlplagpl.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_bin_with_same_batch.
    CLEAR rv_found.
    "Check if storage type is relevant (AA38,  AF36)
    IF is_lgtyp_relevant_chk_batch( is_t331 ) IS INITIAL.
      RETURN.
    ENDIF.


  ENDMETHOD.


  METHOD find_bin_with_user_status.

    DATA:
      lt_hlplagpl_same_status	TYPE /scwm/tt_lagpl.

    CLEAR rv_found.

    LOOP AT ct_hlplagpl ASSIGNING FIELD-SYMBOL(<ls_hlplagpl>).
      READ TABLE it_bin_user_status INTO DATA(ls_bin_user_status)
                                        WITH KEY lgnum = <ls_hlplagpl>-lgnum
                                                 lgpla = <ls_hlplagpl>-lgpla.
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_bin_user_status-status  EQ iv_status.
        APPEND <ls_hlplagpl> TO lt_hlplagpl_same_status.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF lt_hlplagpl_same_status IS NOT INITIAL.
      ct_hlplagpl = lt_hlplagpl_same_status.
      rv_found = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_bin_user_status_tab.
    DATA:
      ls_lgpla TYPE /scwm/s_lagp_key,
      lt_lgpla TYPE /scwm/tt_lagp_key.

    LOOP AT it_hlplagpl INTO DATA(ls_hlplagpl).
      CLEAR ls_hlplagpl.
      ls_lgpla-lgnum = ls_hlplagpl-lgnum.
      ls_lgpla-lgpla = ls_hlplagpl-lgpla.

      APPEND ls_lgpla TO  lt_lgpla.
    ENDLOOP.

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


  METHOD reserve_comparment.
  ENDMETHOD.
ENDCLASS.
