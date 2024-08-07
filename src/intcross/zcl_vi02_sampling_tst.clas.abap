class ZCL_VI02_SAMPLING_TST definition
  public
  final
  create public .

public section.
  type-pools GCWMB .

  class-methods GET_INSTANCE
    returning
      value(RO_SAMPLING) type ref to ZCL_VI02_SAMPLING_TST .
  methods CHECK_SCR_HUID_DURING_PACKING
    importing
      !IS_REQUEST type /SCWM/S_PACK_REQUEST
      !IS_SOURCE type /SCWM/S_HUHDR_INT
      !IS_DESTINATION type /SCWM/S_HUHDR_INT
    raising
      /SCWM/CX_BASICS .
  methods GET_DEFAULTS
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_WORKSTATION type /SCWM/DE_WORKSTATION optional
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT optional
    exporting
      !EV_PROCTY_PUTBACK type /SCWM/DE_PROCTY
      !EV_PROCTY_FETCH type /SCWM/DE_PROCTY
      !EV_HUTYP_SAMPLING type /SCWM/DE_HUTYP
      !EV_PMAT_SAMPLING type /SCMB/MDL_PRODUCT_NO .
  methods GET_SAMPLE_DATA
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT .
  methods GET_SAMPLE_HUS
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT
    returning
      value(RT_SAMPLE_HUS) type /SCWM/TT_HUHDR .
  methods GET_SRC_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
    returning
      value(RS_SRC_HUHDR) type /SCWM/HUHDR .
  methods GET_SRC_HUID
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
    returning
      value(RV_SRC_HUIDENT) type /SCWM/DE_HUIDENT .
  methods PACK_MAT_INTO_SAMPLE_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PMAT type /SCMB/MDL_PRODUCT_NO optional
      !IV_LGPLA type /SCWM/LGPLA optional
      !IS_HU_CREATE type /SCWM/S_HUHDR_CREATE_EXT optional
      !IV_RSRC type /SCWM/DE_RSRC optional
      !IV_PROCTY type /SCWM/DE_PROCTY
      !IT_HUITM_SRC_2_PACK type /SCWM/TT_HUITM_INT .
  methods SET_SRC_HUID
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT .
  methods XCREATE_SAMPLING_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT optional
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PMAT type /SCMB/MDL_PRODUCT_NO optional
      !IV_LGPLA type /SCWM/LGPLA optional
      !IS_HU_CREATE type /SCWM/S_HUHDR_CREATE_EXT optional
      !IV_RSRC type /SCWM/DE_RSRC optional .
  methods XFETCH_SOURCE_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PROCTY_FETCH type /SCWM/DE_PROCTY
      !IO_LOG type ref to /SCWM/CL_LOG optional .
  methods XPICK_SAMPLING_QUANTITY .
  methods XPUTBACK_SOURCE_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SRC_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PROCTY_PUTBACK type /SCWM/DE_PROCTY
      !IO_LOG type ref to /SCWM/CL_LOG optional .
  methods XSWAP_TROLLEYS
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_TROLLEY_FR_HUIDENT type /SCWM/DE_HUIDENT
      !IV_TROLLEY_TO_HUIDENT type /SCWM/DE_HUIDENT .
  methods YPUT_ON_TROLLEY
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_SAMPLE_HUIDENT type /SCWM/DE_HUIDENT
      !IV_TROLLEY_HUIDENT type /SCWM/DE_HUIDENT .
protected section.

  class-data GO_SINGLETON type ref to ZCL_VI02_SAMPLING_TST .
  class-data GV_MESSAGE type STRING .

  methods XMOVE_HU
    importing
      !IV_LGNUM type /SCWM/LGNUM
      !IV_HUIDENT type /SCWM/DE_HUIDENT
      !IV_PROCTY type /SCWM/DE_PROCTY .
private section.
ENDCLASS.



CLASS ZCL_VI02_SAMPLING_TST IMPLEMENTATION.


  METHOD CHECK_SCR_HUID_DURING_PACKING.
    DATA: lt_dst_hu_stock TYPE  /scwm/tt_stock_select.
    "only for VI02
    IF is_request-lgnum NE zif_vi02_c=>gc_lgnum-vi02.
      RETURN.
    ENDIF.

  "is the destination HU already exists?
    IF is_destination-guid_hu IS NOT INITIAL.

      "check if dest HU is a sampling HU for an others soruce HU
      "( also check/allow that the source is already a sampling HU, with a source )
      IF is_destination-zzvi02_src_huid IS INITIAL.

        IF is_source-zzvi02_src_huid IS NOT INITIAL.
          "is something is already in the destination HU?
          CALL FUNCTION '/SCWM/SELECT_STOCK'
            EXPORTING
              iv_lgnum   = is_request-lgnum
              it_guid_hu = VALUE /scwm/tt_guid_hu( ( guid_hu = is_destination-guid_hu ) )
            IMPORTING
              et_huitm   = lt_dst_hu_stock
            EXCEPTIONS
              error      = 1
              OTHERS     = 2.

          IF lt_dst_hu_stock IS NOT INITIAL.
            "Cannot pack from &1 into &2 ( &1 is not empty, and &2 is a sample HU)
            MESSAGE e002(z_vi02) WITH is_source-huident
                                      is_destination-huident
                                      is_source-zzvi02_src_huid
                                 INTO DATA(lv_dummy).
            RAISE EXCEPTION TYPE /scwm/cx_basics.
          ENDIF.

        ELSE.
          "destination a Sample HU
          IF is_destination-zzvi02_src_huid   NE is_source-huident
          AND is_destination-zzvi02_src_huid  NE is_source-zzvi02_src_huid.

            "Cannot pack from &1 into &2 ( it is already used by source &3)
            MESSAGE e003(z_vi02) WITH is_source-huident
                                      is_destination-huident
                                      is_destination-zzvi02_src_huid
                                 INTO lv_dummy.

            RAISE EXCEPTION TYPE /scwm/cx_basics.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD GET_DEFAULTS.

    CLEAR:  ev_hutyp_sampling,
            ev_pmat_sampling,
            ev_procty_putback,
            ev_procty_fetch.

    "TDO read from somewhere

    ev_hutyp_sampling = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_sampling
        iv_context    = zif_vi02_param_c=>c_context_sampling
        iv_parameter  = zif_vi02_param_c=>c_param_hutyp_sampling
    ).

    ev_pmat_sampling = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_sampling
        iv_context    = zif_vi02_param_c=>c_context_sampling
        iv_parameter  = zif_vi02_param_c=>c_param_pmat_sampling
    ).

    ev_procty_putback = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_sampling
        iv_context    = zif_vi02_param_c=>c_context_sampling
        iv_parameter  = zif_vi02_param_c=>c_param_procty_putback
    ).

    ev_procty_fetch = /sl0/cl_param_select=>read_const(
      EXPORTING
        iv_lgnum      = iv_lgnum
        iv_param_prof = zif_vi02_param_c=>c_prof_sampling
        iv_context    = zif_vi02_param_c=>c_context_sampling
        iv_parameter  = zif_vi02_param_c=>c_param_procty_fetch
    ).


  ENDMETHOD.


  METHOD GET_INSTANCE.
    IF go_singleton IS NOT BOUND.
      go_singleton = NEW #( ).
    ENDIF.

    ro_sampling = go_singleton.
  ENDMETHOD.


  METHOD GET_SAMPLE_DATA.
    TRY.
        "need the data
        DATA(lo_hu_src) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                          i_huident      = iv_src_huident
                                          i_read_hu_tree = abap_true ).

        CALL METHOD lo_hu_src->get_stock
          IMPORTING
            et_stock = DATA(lt_stock).

        LOOP AT lt_stock INTO DATA(ls_stock).
          TRY.
              CALL METHOD /scwm/cl_batch_appl=>get_instance
                EXPORTING
                  iv_productid = ls_stock-matid
                  iv_batchid   = ls_stock-batchid
                  iv_lgnum     = iv_lgnum
                RECEIVING
                  ro_instance  = DATA(lo_batch).

              CALL METHOD lo_batch->get_batch
                IMPORTING
                  es_batch    = DATA(ls_batch)
                  et_val_char = DATA(lt_val_char).


            CATCH /scwm/cx_batch_management.
          ENDTRY.

        ENDLOOP.
      CATCH /sl0/cx_general_exception.

    ENDTRY.
  ENDMETHOD.


  METHOD GET_SAMPLE_HUS.

    DATA:
      lt_guid_hu TYPE /scwm/tt_guid_hu.

    REFRESH  rt_sample_hus .

    IF iv_src_huident IS INITIAL.
      RETURN.
    ENDIF.

    "first just select the guids for the sample HUs ( with the source HU id)
    SELECT guid_hu
        FROM /scwm/huhdr
        INTO CORRESPONDING FIELDS OF TABLE @lt_guid_hu
        WHERE lgnum           EQ @iv_lgnum
          AND zzvi02_src_huid EQ @iv_src_huident.

    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    "read HUs header with /SCWM/HU_SELECT (may replace it with SL0/CL_HU=>READ_HUS_BY_GUID in the future)
    CALL FUNCTION '/SCWM/HU_SELECT'
      EXPORTING
        it_guid_hu = lt_guid_hu
      IMPORTING
        et_huhdr   = rt_sample_hus
      EXCEPTIONS
        not_found  = 1
        error      = 2
        OTHERS     = 3.
    IF sy-subrc IS NOT INITIAL.
      "just continue...
    ENDIF.

    DELETE rt_sample_hus WHERE zzvi02_src_huid EQ iv_src_huident.

  ENDMETHOD.


  METHOD GET_SRC_HU.
    DATA:
      lt_sample_huhdr TYPE /scwm/tt_huhdr,
      lt_src_huhdr    TYPE /scwm/tt_huhdr.

    CALL FUNCTION '/SCWM/HU_SELECT'
      EXPORTING
        it_huident = VALUE /scwm/tt_huident( ( lgnum = iv_lgnum huident = iv_sample_huident ) )
      IMPORTING
        et_huhdr   = lt_sample_huhdr
      EXCEPTIONS
        not_found  = 1
        error      = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE lt_sample_huhdr INTO DATA(ls_sample_huhdr) INDEX 1.
    CASE sy-tfill.
      WHEN 0.
        " nothing found ...
        RETURN.
      WHEN 1.
        IF ls_sample_huhdr-zzvi02_src_huid IS INITIAL.
          RETURN.
        ENDIF.
      WHEN OTHERS.
        "more then one found??????
        IF ls_sample_huhdr-zzvi02_src_huid IS INITIAL.
          RETURN.
        ENDIF.
    ENDCASE.

    CALL FUNCTION '/SCWM/HU_SELECT'
      EXPORTING
        it_huident = VALUE /scwm/tt_huident( ( lgnum = iv_lgnum huident = ls_sample_huhdr-zzvi02_src_huid ) )
      IMPORTING
        et_huhdr   = lt_src_huhdr
      EXCEPTIONS
        not_found  = 1
        error      = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE lt_src_huhdr INTO rs_src_huhdr INDEX 1.
    CASE sy-tfill.
      WHEN 0.
        " nothing found ...
        RETURN.
      WHEN 1.
        "OK
      WHEN OTHERS.
        "more then one found??????

    ENDCASE.
  ENDMETHOD.


  METHOD GET_SRC_HUID.

    rv_src_huident = get_src_hu(  iv_lgnum          = iv_lgnum
                                  iv_sample_huident = iv_sample_huident )-huident.

  ENDMETHOD.


  METHOD PACK_MAT_INTO_SAMPLE_HU.


    TRY.
        DATA(lo_hu_src) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                          i_huident      = iv_src_huident
                                          i_lock         = abap_true
                                          i_read_hu_tree = abap_true ).

        /sl0/cl_hu=>is_hu_existing( EXPORTING i_lgnum    = iv_lgnum
                                              i_huident  = iv_sample_huident
                                    IMPORTING e_existing = DATA(lv_sample_hu_exist) ).

        IF lv_sample_hu_exist EQ abap_true.
          DATA(lo_hu_sample) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                               i_huident      = iv_sample_huident
                                               i_lock         = abap_true
                                               i_read_hu_tree = abap_true ).
        ELSE.
          DATA(ls_hu_create) = is_hu_create.
          ls_hu_create-zzvi02_src_huid = iv_src_huident.
          lo_hu_sample = NEW /sl0/cl_hu( i_create_hu    = abap_true
                                         i_lgnum        = iv_lgnum
                                         i_huident      = iv_sample_huident
                                         is_hu_create   = ls_hu_create
                                         i_lgpla        = iv_lgpla
                                         i_rsrc         = iv_rsrc
                                         i_lock         = abap_true
                                         i_read_hu_tree = abap_true ).

        ENDIF.

        CALL METHOD lo_hu_sample->pack_hu_stock_to_hu
          EXPORTING
            i_procty     = iv_procty
            i_huguid_src = lo_hu_src->get_guid( )
            it_huitm_src = it_huitm_src_2_pack
            i_save       = abap_true
            i_commit     = abap_true
            i_wait       = abap_true.


      CATCH /sl0/cx_general_exception.

    ENDTRY.



  ENDMETHOD.


  METHOD SET_SRC_HUID.
*     the class /SL0/CL_HU has methods which can archive this functions easyly
*     so let's wait if this will be imported here or not
    TRY.
        DATA(lo_hu) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                      i_huident      = iv_sample_huident
                                      i_lock         = abap_true
                                      i_read_hu_tree = abap_true ).
        "Read the HU header ( NOT the TOP )
        DATA(ls_huhdr) = lo_hu->get_huhdr_hu( iv_sample_huident  ).

        ls_huhdr-zzvi02_src_huid = iv_src_huident.

        lo_hu->update_huhdr( EXPORTING is_huhdr = ls_huhdr ).

      CATCH /sl0/cx_general_exception.

    ENDTRY.

  ENDMETHOD.


  METHOD xcreate_sampling_hu.

    TRY.
        IF iv_src_huident IS NOT INITIAL.
          DATA(lo_hu_src) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                            i_huident      = iv_src_huident
                                            i_lock         = abap_true
                                            i_read_hu_tree = abap_true ).
        ENDIF.

        /sl0/cl_hu=>is_hu_existing( EXPORTING i_lgnum    = iv_lgnum
                                              i_huident  = iv_sample_huident
                                    IMPORTING e_existing = DATA(lv_sample_hu_exist) ).

        IF lv_sample_hu_exist EQ abap_true.
          DATA(lo_hu_sample) = NEW /sl0/cl_hu( i_lgnum        = iv_lgnum
                                               i_huident      = iv_sample_huident
                                               i_lock         = abap_true
                                               i_read_hu_tree = abap_true ).
          DATA(ls_huhdr) = lo_hu_sample->get_huhdr_hu( iv_sample_huident ).



          IF iv_pmat NE ls_huhdr-pmat.
            "not good...
          ELSEIF iv_lgpla IS NOT INITIAL.
          ENDIF.
        ELSE.

          DATA(ls_hu_create) = is_hu_create.

          IF iv_src_huident IS NOT INITIAL.
            ls_hu_create-zzvi02_src_huid = iv_src_huident.
          ENDIF.

          lo_hu_sample = NEW /sl0/cl_hu( i_create_hu    = abap_true
                                         i_lgnum        = iv_lgnum
                                         i_huident      = iv_sample_huident
                                         is_hu_create   = ls_hu_create
                                         i_pmat         = iv_pmat
                                         i_lgpla        = iv_lgpla
                                         i_rsrc         = iv_rsrc
                                         i_lock         = abap_true
                                         i_read_hu_tree = abap_true ).

        ENDIF.

      CATCH /sl0/cx_general_exception.

    ENDTRY.



  ENDMETHOD.


  METHOD XFETCH_SOURCE_HU.

    DATA(lv_procty_fetch)	= iv_procty_fetch.

    IF lv_procty_fetch IS INITIAL.
      CALL METHOD me->get_defaults
        EXPORTING
          iv_lgnum        = iv_lgnum
          iv_src_huident  = iv_src_huident
        IMPORTING
          ev_procty_fetch = lv_procty_fetch.
    ENDIF.

    TRY.

        DATA(lo_hu) = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum
"                                        io_log    = lo_log_ewm
                                      i_huident = iv_src_huident ).

        DATA(ls_ordim_o) = lo_hu->get_open_hu_wt( ).

        IF ls_ordim_o IS NOT INITIAL AND ls_ordim_o-procty EQ lv_procty_fetch.
          "that#s OK
        ELSEIF ls_ordim_o IS NOT INITIAL.
          "that"s not OK
        ELSE.
          DATA(lo_wt) = lo_hu->move( EXPORTING i_procty = lv_procty_fetch
*                                             i_nlpla  =
                                              ).

          "HU-WT &1 for &2 created
          MESSAGE s006(/sl0/disp) INTO gv_message WITH lo_wt->get_tanum( )
                                                       iv_src_huident.

          io_log->add_message( ).
        ENDIF.


      CATCH /sl0/cx_general_exception INTO DATA(lx_gen).
        io_log->add_message( ip_msg = CONV #( lx_gen->get_exception_message( ) ) ).
        ROLLBACK WORK.
    ENDTRY.



  ENDMETHOD.


  METHOD XMOVE_HU.

  ENDMETHOD.


  METHOD xpick_sampling_quantity.

*    lo_wt->set_destination( EXPORTING i_nlenr = CONV /scwm/de_huident( gs_user_command-nlenr ) ).
*
*    "Init who class
*    DATA(lo_who) = NEW /sl0/cl_who( i_lgnum   = iv_lgnum
*                                    i_who     = iv_who
*                                    i_hu_read = abap_true ).
*
*    "get WTs
*    TRY.
*        lo_who->get_pick_wts( IMPORTING et_all_pick_wts       = DATA(lt_all_pick_wts)
*                                        et_open_pick_wts      = DATA(lt_open_pick_wts)
*                                        et_confirmed_pick_wts = DATA(lt_processed_pick_wts) ).
*      CATCH /sl0/cx_general_exception.
*    ENDTRY.
*
*    DATA(lo_wt) = lt_open_pick_wts[ tanum = iv_tanum ]-o_wt.



  ENDMETHOD.


  METHOD XPUTBACK_SOURCE_HU.

    DATA(lv_procty_putback)	= iv_procty_putback.

    IF lv_procty_putback IS INITIAL.
      CALL METHOD me->get_defaults
        EXPORTING
          iv_lgnum          = iv_lgnum
          iv_src_huident    = iv_src_huident
        IMPORTING
          ev_procty_putback = lv_procty_putback.
    ENDIF.

    TRY.

        DATA(lo_hu) = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum
"                                        io_log    = lo_log_ewm
                                      i_huident = iv_src_huident ).

        DATA(ls_ordim_o) = lo_hu->get_open_hu_wt( ).

        IF ls_ordim_o IS NOT INITIAL AND ls_ordim_o-procty EQ lv_procty_putback.
          "that#s OK
        ELSEIF ls_ordim_o IS NOT INITIAL.
          "that"s not OK
        ELSE.
          DATA(lo_wt) = lo_hu->move( EXPORTING i_procty = lv_procty_putback
*                                             i_nlpla  =
                                              ).

          "HU-WT &1 for &2 created
          MESSAGE s006(/sl0/disp) INTO gv_message WITH lo_wt->get_tanum( )
                                                       iv_src_huident.

          io_log->add_message( ).
        ENDIF.


      CATCH /sl0/cx_general_exception INTO DATA(lx_gen).
        io_log->add_message( ip_msg = CONV #( lx_gen->get_exception_message( ) ) ).
        ROLLBACK WORK.
    ENDTRY.



  ENDMETHOD.


  METHOD xswap_trolleys.
    DATA:
      lr_trolley_to_hu TYPE REF TO /sl0/cl_hu,
      lr_trolley_fr_hu TYPE REF TO /sl0/cl_hu,
      ls_guid_sub_hu   TYPE /scwm/s_guid_hu,
      lt_guid_sub_hu   TYPE /scwm/tt_guid_hu.

    TRY.
        CREATE OBJECT lr_trolley_fr_hu
          EXPORTING
            i_lgnum        = iv_lgnum
            i_huident      = iv_trolley_fr_huident
    "       io_log         = co_log
            i_read_hu_tree = abap_true.

        DATA(ls_huhdr_top) = lr_trolley_fr_hu->get_huhdr_top( ).

        IF ls_huhdr_top-huident NE iv_trolley_fr_huident.
          " not good...
        ENDIF.

        "get sub hus
        DATA(lt_hutree)   = lr_trolley_fr_hu->get_hutree( ).

        LOOP AT lt_hutree INTO DATA(ls_hutree) WHERE guid_parent EQ ls_huhdr_top-guid_hu.
          CLEAR ls_guid_sub_hu.
          ls_guid_sub_hu-guid_hu = ls_hutree-guid.
          APPEND ls_guid_sub_hu TO lt_guid_sub_hu.

        ENDLOOP.

*   Create top HU reference
        CREATE OBJECT lr_trolley_to_hu
          EXPORTING
            i_lgnum        = iv_lgnum
            i_huident      = iv_trolley_to_huident
    "       io_log         = co_log
            i_read_hu_tree = abap_true.

        lr_trolley_to_hu->pack_hu_to_hu( EXPORTING it_source_guid_hu = lt_guid_sub_hu ).
        lr_trolley_to_hu->refresh( iv_read_hu_tree = abap_true ).

      CATCH  /sl0/cx_general_exception.

    ENDTRY.

  ENDMETHOD.


  METHOD yput_on_trolley.
    DATA:
      lr_sample_hu   TYPE REF TO /sl0/cl_hu,
      lr_trolley_hu  TYPE REF TO /sl0/cl_hu,
      ls_guid_sub_hu TYPE /scwm/s_guid_hu,
      lt_guid_sub_hu TYPE /scwm/tt_guid_hu.

    TRY.
        CREATE OBJECT lr_sample_hu
          EXPORTING
            i_lgnum        = iv_lgnum
            i_huident      = iv_sample_huident
    "       io_log         = co_log
            i_read_hu_tree = abap_true.

        DATA(ls_huhdr) = lr_sample_hu->get_huhdr_hu( iv_sample_huident ).

        IF ls_huhdr-huident NE iv_sample_huident.
          " not good...
        ELSE.

        ENDIF.

        CLEAR ls_guid_sub_hu.
        ls_guid_sub_hu-guid_hu = ls_huhdr-guid_hu.
        APPEND ls_guid_sub_hu TO lt_guid_sub_hu.

*   Create top HU reference
        CREATE OBJECT lr_trolley_hu
          EXPORTING
            i_lgnum        = iv_lgnum
            i_huident      = iv_trolley_huident
    "       io_log         = co_log
            i_read_hu_tree = abap_true.

        lr_trolley_hu->pack_hu_to_hu( EXPORTING it_source_guid_hu = lt_guid_sub_hu ).
        lr_trolley_hu->refresh( iv_read_hu_tree = abap_true ).

      CATCH  /sl0/cx_general_exception.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
