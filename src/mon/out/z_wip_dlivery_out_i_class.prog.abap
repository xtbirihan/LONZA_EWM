*&---------------------------------------------------------------------*
*& Include          Z_WIP_DLIVERY_OUT_I_CLASS
*&---------------------------------------------------------------------*
CLASS lcl_whritem_mon_out IMPLEMENTATION.

  METHOD initialization.
    REFRESH ct_data.
    CALL FUNCTION '/SCWM/DYNPRO_ELEMENTS_CLEAR'
      EXPORTING
        iv_repid = iv_repid.
  ENDMETHOD.

  METHOD  convert_date_time.
    CLEAR: ct_timestamp.

    MOVE: iv_datefrom TO ls_dattim_from-date,
          iv_timefrom TO ls_dattim_from-time,
          iv_dateto   TO ls_dattim_to-date,
          iv_timeto   TO ls_dattim_to-time.

    CALL FUNCTION '/SCWM/CONVERT_DATE_TIME'
      EXPORTING
        iv_lgnum           = iv_lgnum
        is_dattim_from     = ls_dattim_from
        is_dattim_to       = ls_dattim_to
      IMPORTING
        es_timestamp_range = ls_timestamp_r
      EXCEPTIONS
        input_error        = 1
        data_not_found     = 2
        OTHERS             = 3.
    CASE sy-subrc.
      WHEN 0.
        IF ls_timestamp_r IS NOT INITIAL.
          APPEND ls_timestamp_r TO ct_timestamp.
        ENDIF.
      WHEN 1.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDCASE.
  ENDMETHOD.

  METHOD fill_selection_table.

    DATA: ls_t300_md       TYPE          /scwm/s_t300_md,
          ls_data_parent   TYPE /scwm/s_wip_whrhead_out,
          ls_selection     TYPE /scwm/dlv_selection_str,
          lt_timestamp_r   TYPE /scwm/tt_timestamp_r,
          ls_timestamp_r   TYPE /scwm/s_timestamp_r,
          ls_docno         LIKE LINE OF  s_docno,
          ls_so_h          LIKE LINE OF  s_soi,
          ls_stprt         LIKE LINE OF  s_stprt,
          ls_tu            LIKE LINE OF  s_tu,
          ls_status_value  LIKE LINE OF  s_dpii,
          ls_prod          LIKE LINE OF  s_prod,
          ls_put           LIKE LINE OF s_put_h,
          ls_huident_r     TYPE          rsdsselopt,
          lt_huident_r     TYPE          rseloption,
          ls_ident_r       TYPE          rsdsselopt,
          lt_ident_r       TYPE          rseloption,
          ls_idart_r       TYPE          rsdsselopt,
          lt_idart_r       TYPE          rseloption,
          ls_stlo          LIKE LINE OF  s_stlo,
          ls_stprtf        LIKE LINE OF  s_stprtf,
          ls_lp            LIKE LINE OF  s_lp,
          ls_route         LIKE LINE OF  s_route,
          ls_huno          LIKE LINE OF  s_huno,
          ls_doctype       LIKE LINE OF  s_docty,
          ls_manual        LIKE LINE OF  s_manual,
          ls_tcdref        LIKE LINE OF  s_tcdref,
          ls_rma_h         LIKE LINE OF  s_rma_h,
          ls_po_h          LIKE LINE OF  s_po_h,
          ls_ppo_h         LIKE LINE OF  s_ppo_h,
          ls_pmo_h         LIKE LINE OF  s_pmo_h,
          ls_res_h         LIKE LINE OF  s_res_h,
          ls_erp_h         LIKE LINE OF  s_erp_h,
          ls_ero_h         LIKE LINE OF  s_ero_h,
          ls_mdpo_h        LIKE LINE OF  s_mdpo_h,
          ls_ecn           LIKE LINE OF  s_ecn,
          ls_bol           LIKE LINE OF  s_bol,
          ls_frd           LIKE LINE OF  s_frd,
          ls_tu_ext        LIKE LINE OF  s_tu_ex,
          ls_depart        LIKE LINE OF  s_depar,
          ls_dep_source    LIKE LINE OF  s_dep_s,
          ls_creby         LIKE LINE OF  s_creby,
          ls_tplt          LIKE LINE OF  so_tplt,
          ls_qdoccat_r     TYPE          rsdsselopt,
          lt_qdoccat_r     TYPE          rseloption,
          lt_docid         TYPE          /scdl/t_sp_k_item,
          ls_docid         TYPE          /scdl/s_sp_k_item,
          ls_tu_r          TYPE          /scwm/s_sel_tu_num_ext,
          lv_timestamp_l   TYPE          timestamp,
          lv_timestamp_h   TYPE          timestamp,
          ls_doccat_r      TYPE          /scwm/s_sel_dlv_doccat,
          ls_docid_tu      TYPE          /scwm/dlv_docid_itemid_str,
          lt_docid_tu      TYPE          /scwm/dlv_docid_itemid_tab,
          ls_docid_wave    TYPE          /scwm/dlv_docid_itemid_str,
          lt_docid_wave    TYPE          /scwm/dlv_docid_itemid_tab,
          lo_log_wm        TYPE REF TO   /scwm/cl_log,
          lo_query_tu      TYPE REF TO   /scwm/cl_sr_tu_query,
          ls_inparam       TYPE          /scwm/s_sp_qry_logfname_inp,
          lt_logfname_key  TYPE          /scdl/dl_logfname_key_tab,
          ls_logfname_key  TYPE          /scdl/dl_logfname_key_str,
          lt_logfname_map  TYPE          /scdl/dl_logfname_map_tab,
          ls_logfname_map2 TYPE          /scdl/dl_logfname_map_str,
          lv_rejected      TYPE          boole_d,
          lo_sp_core       TYPE REF TO   /scdl/cl_sp,
          lo_message_box   TYPE REF TO   /scdl/cl_sp_message_box,
          ls_dsiva         LIKE LINE OF  so_dsiva,
          ls_wavesel       LIKE LINE OF  s_waveno,
          ls_flp_value     LIKE LINE OF s_flp_h,
          lt_psguid_r      TYPE rseloption,
          ls_psguid_r      TYPE rsdsselopt,
          lt_piguid_r      TYPE rseloption,
          ls_piguid_r      TYPE rsdsselopt.

    DATA:
      gt_dfies       TYPE TABLE OF  dfies,
      go_stm         TYPE REF TO    /scdl/cl_stm,
      gs_dfies       TYPE REF TO    dfies,
      gs_functxt     TYPE           smp_dyntxt,
      gv_dsrc        TYPE           /scdl/dl_data_source VALUE 'DB',
      gv_change_data TYPE xfeld,
      go_taman       TYPE REF TO    /scwm/if_tm.

* Warehouse
* Get SC Unit location number
  CALL FUNCTION '/SCWM/T300_MD_READ_SINGLE'
    EXPORTING
      iv_lgnum   = iv_lgnum
*     IV_SCUGUID =
    IMPORTING
      es_t300_md = ls_t300_md
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc EQ 0.
    CLEAR ls_selection.
    ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_locationid_wh_h.
    ls_selection-sign      = 'I'.
    ls_selection-option    = 'EQ'.
    ls_selection-low       = ls_t300_md-scuguid.
    APPEND ls_selection TO ct_selection.
  ELSE.
    MESSAGE TEXT-006 TYPE 'E'.
  ENDIF.


* Delivery type
    LOOP AT s_docty INTO ls_doctype.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_doctype_h.
      ls_selection-sign      = ls_doctype-sign.
      ls_selection-option    = ls_doctype-option.
      ls_selection-low       = ls_doctype-low.
      ls_selection-high      = ls_doctype-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Delivery number
    LOOP AT s_docno INTO ls_docno.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docno_h.
      ls_selection-sign      = ls_docno-sign.
      ls_selection-option    = ls_docno-option.
      ls_selection-low       = ls_docno-low.
      ls_selection-high      = ls_docno-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* TCD reference number
    LOOP AT s_tcdref INTO ls_tcdref.
      CLEAR ls_selection.
      ls_selection-fieldname = /scwm/if_dl_logfname_c=>sc_refdocno_tcd_h.
      ls_selection-sign      = ls_tcdref-sign.
      ls_selection-option    = ls_tcdref-option.
      ls_selection-low       = ls_tcdref-low.
      ls_selection-high      = ls_tcdref-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Sales Order number
    LOOP AT s_soi INTO ls_so_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_so_i.
      ls_selection-sign      = ls_so_h-sign.
      ls_selection-option    = ls_so_h-option.
      ls_selection-low       = ls_so_h-low.
      ls_selection-high      = ls_so_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* RMA Document Number
    LOOP AT s_rma_h INTO ls_rma_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_rma_i.
      ls_selection-sign      = ls_rma_h-sign.
      ls_selection-option    = ls_rma_h-option.
      ls_selection-low       = ls_rma_h-low.
      ls_selection-high      = ls_rma_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Purchase Order Number
    LOOP AT s_po_h INTO ls_po_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_po_i.
      ls_selection-sign      = ls_po_h-sign.
      ls_selection-option    = ls_po_h-option.
      ls_selection-low       = ls_po_h-low.
      ls_selection-high      = ls_po_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Manufacturing Order Number
    LOOP AT s_ppo_h INTO ls_ppo_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_ppo_i.
      ls_selection-sign      = ls_ppo_h-sign.
      ls_selection-option    = ls_ppo_h-option.
      ls_selection-low       = ls_ppo_h-low.
      ls_selection-high      = ls_ppo_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Plant Maintenance Order Number
    LOOP AT s_pmo_h INTO ls_pmo_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_pmo_i.
      ls_selection-sign      = ls_pmo_h-sign.
      ls_selection-option    = ls_pmo_h-option.
      ls_selection-low       = ls_pmo_h-low.
      ls_selection-high      = ls_pmo_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Reservation Number
    LOOP AT s_res_h INTO ls_res_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_res_i.
      ls_selection-sign      = ls_res_h-sign.
      ls_selection-option    = ls_res_h-option.
      ls_selection-low       = ls_res_h-low.
      ls_selection-high      = ls_res_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* ERP document number
    LOOP AT s_erp_h INTO ls_erp_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_erp_i.
      ls_selection-sign      = ls_erp_h-sign.
      ls_selection-option    = ls_erp_h-option.
      ls_selection-low       = ls_erp_h-low.
      ls_selection-high      = ls_erp_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Original ERP document number
    LOOP AT s_ero_h INTO ls_ero_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_ero_i.
      ls_selection-sign      = ls_ero_h-sign.
      ls_selection-option    = ls_ero_h-option.
      ls_selection-low       = ls_ero_h-low.
      ls_selection-high      = ls_ero_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* MeDi Purchase Order
    LOOP AT s_mdpo_h INTO ls_mdpo_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_pom_i.
      ls_selection-sign      = ls_mdpo_h-sign.
      ls_selection-option    = ls_mdpo_h-option.
      ls_selection-low       = ls_mdpo_h-low.
      ls_selection-high      = ls_mdpo_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* External Consignment Order
    LOOP AT s_ecn INTO ls_ecn.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_ecn_h.
      ls_selection-sign      = ls_ecn-sign.
      ls_selection-option    = ls_ecn-option.
      ls_selection-low       = ls_ecn-low.
      ls_selection-high      = ls_ecn-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Bill of lading
    LOOP AT s_bol INTO ls_bol.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_bol_h.
      ls_selection-sign      = ls_bol-sign.
      ls_selection-option    = ls_bol-option.
      ls_selection-low       = ls_bol-low.
      ls_selection-high      = ls_bol-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* FRD document
    LOOP AT s_frd INTO ls_frd.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_frd_h.
      ls_selection-sign      = ls_frd-sign.
      ls_selection-option    = ls_frd-option.
      ls_selection-low       = ls_frd-low.
      ls_selection-high      = ls_frd-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Manual attribute
    LOOP AT s_manual INTO ls_manual.
      CLEAR ls_selection.
      MOVE-CORRESPONDING ls_manual TO ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_manual_h.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* HU number
    LOOP AT s_huno INTO ls_huno.
      CLEAR ls_huident_r.
      MOVE-CORRESPONDING ls_huno TO ls_huident_r.
      APPEND ls_huident_r TO lt_huident_r.
    ENDLOOP.
* Transport unit
    LOOP AT s_tu INTO ls_tu.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_transmeans_id_h.
      ls_selection-sign      = ls_tu-sign.
      ls_selection-option    = ls_tu-option.
      ls_selection-low       = ls_tu-low.
      ls_selection-high      = ls_tu-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Route
    LOOP AT s_route INTO ls_route.
      CLEAR ls_selection.
      ls_selection-fieldname = /scwm/if_dl_logfname_c=>sc_route_id_h.
      ls_selection-sign      = ls_route-sign.
      ls_selection-option    = ls_route-option.
      ls_selection-low       = ls_route-low.
      ls_selection-high      = ls_route-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Departure schedule
    LOOP AT s_depar INTO ls_depart.
      CLEAR ls_selection.
      ls_selection-fieldname = /scwm/if_dl_logfname_c=>sc_depart_sched_h.
      ls_selection-sign      = ls_depart-sign.
      ls_selection-option    = ls_depart-option.
      ls_selection-low       = ls_depart-low.
      ls_selection-high      = ls_depart-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Route / Departure schedule source
    LOOP AT s_dep_s INTO ls_dep_source.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scwm/if_dl_logfname_c=>sc_route_dep_source_h.
      ls_selection-sign      = ls_dep_source-sign.
      ls_selection-option    = ls_dep_source-option.
      ls_selection-low       = ls_dep_source-low.
      ls_selection-high      = ls_dep_source-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Ship to location
    LOOP AT s_stlo INTO ls_stlo.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_locationno_stlo_h.
      ls_selection-sign      = ls_stlo-sign.
      ls_selection-option    = ls_stlo-option.
      ls_selection-low       = ls_stlo-low.
      ls_selection-high      = ls_stlo-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Ship to party
    LOOP AT s_stprt INTO ls_stprt.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_partyno_stprt_h.
      ls_selection-sign      = ls_stprt-sign.
      ls_selection-option    = ls_stprt-option.
      ls_selection-low       = ls_stprt-low.
      ls_selection-high      = ls_stprt-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Final ship to party
    LOOP AT s_stprtf INTO ls_stprtf.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scwm/if_dl_logfname_c=>sc_partyno_stprtf_h.
      ls_selection-sign      = ls_stprtf-sign.
      ls_selection-option    = ls_stprtf-option.
      ls_selection-low       = ls_stprtf-low.
      ls_selection-high      = ls_stprtf-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Loading Point
    LOOP AT s_lp INTO ls_lp.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scwm/if_dl_logfname_c=>sc_locationno_lp_i.
      ls_selection-sign      = ls_lp-sign.
      ls_selection-option    = ls_lp-option.
      ls_selection-low       = ls_lp-low.
      ls_selection-high      = ls_lp-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

*Putaway Control Indicator
    LOOP AT s_put_h INTO ls_put.
      CLEAR ls_selection.
      ls_selection-fieldname = 'PUT_STRA_H'.
      ls_selection-sign      = ls_put-sign.
      ls_selection-option    = ls_put-option.
      ls_selection-low       = ls_put-low.
      ls_selection-high      = ls_put-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status goods issue
    LOOP AT s_dgii INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_status_value_dgi_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status picking
    LOOP AT s_dpii INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_status_value_dpi_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status planned picking
    LOOP AT s_deri INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_status_value_der_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status loading
    LOOP AT s_dloi INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_dlo_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status warehouse activity
    LOOP AT s_dwai INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_dwa_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status GTS check
    LOOP AT s_dgti INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scwm/if_dl_logfname_c=>sc_status_value_dgt_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status route determination
    LOOP AT s_drdh INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_drd_h.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status Completed
    LOOP AT s_dcoi INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_dco_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

*Ready for Shipping Status (Header)
    LOOP AT so_dshh INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_status_value_dsh_h.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

*Transportation Planning Type
    LOOP AT so_tplt INTO ls_tplt.
      CLEAR ls_selection.
      ls_selection-fieldname = /scwm/if_dl_logfname_c=>sc_transpl_type_h.
      ls_selection-sign      = ls_tplt-sign.
      ls_selection-option    = ls_tplt-option.
      ls_selection-low       = ls_tplt-low.
      ls_selection-high      = ls_tplt-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

*Archiving Status
    LOOP AT so_dach INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_status_value_dac_h.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status Blocked Overall
    IF NOT p_dboi IS INITIAL.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_dbo_i.
      ls_selection-sign   = 'I'.
      ls_selection-option = 'EQ'.
      ls_selection-low    = p_dboi.
      APPEND ls_selection TO ct_selection.
    ENDIF.

* NCTS
    LOOP AT s_dwnh INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scwm/if_dl_logfname_c=>sc_status_value_dwn_h.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.
* Created By
    LOOP AT s_creby INTO ls_creby.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_creusr_h.
      ls_selection-sign      = ls_creby-sign.
      ls_selection-option    = ls_creby-option.
      ls_selection-low       = ls_creby-low.
      ls_selection-high      = ls_creby-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Out of yard date
    me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                    iv_datefrom = p_yrddfr
                                    iv_timefrom = p_yrdtfr
                                    iv_dateto = p_yrddto
                                    iv_timeto = p_yrdtto
                           CHANGING ct_timestamp = lt_timestamp_r ).

    LOOP AT lt_timestamp_r INTO ls_timestamp_r.
      CLEAR ls_selection.
      IF ls_timestamp_r-sign = 'I'.
        ls_selection-fieldname =
          /scdl/if_dl_logfname_c=>sc_tstfr_toutyard_plan_h.
        ls_selection-option    = ls_timestamp_r-option.
        ls_selection-low       = ls_timestamp_r-low.
        ls_selection-high      = ls_timestamp_r-high.
        APPEND ls_selection TO ct_selection.
      ENDIF.
    ENDLOOP.

* Status Field Logistics Processing
    LOOP AT s_flp_h INTO ls_flp_value.
      CLEAR ls_selection.
      MOVE-CORRESPONDING ls_flp_value TO ls_selection.
      ls_selection-fieldname =
       /scwm/if_dl_logfname_c=>sc_flp_status_pdo_i.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Dynamic status (item)
    IF po_dsity IS NOT INITIAL.
      ls_inparam-structure = '/SCDL/S_SP_A_ITEM_STATUS'.
      ls_inparam-level     = /scdl/if_dl_object_c=>sc_object_level_i.
      ls_inparam-fieldname = 'STATUS_VALUE'.
      ls_logfname_key-keyfield = 'STATUS_TYPE'.
      ls_logfname_key-keyvalue = po_dsity.
      APPEND ls_logfname_key TO lt_logfname_key.

      TRY.
          CREATE OBJECT lo_message_box.
        CATCH /scdl/cx_sp_message_box.                  "#EC NO_HANDLER
      ENDTRY.
      CREATE OBJECT lo_sp_core
        TYPE
        /scdl/cl_sp_prd_inb
        EXPORTING
          io_message_box = lo_message_box
          iv_mode        = /scdl/cl_sp_prd_inb=>sc_mode_classic.

*   query the parameter
      lo_sp_core->query(
        EXPORTING inkeys      = lt_logfname_key
                  inparam     = ls_inparam
                  query       = /scwm/if_sp_c=>sc_qry_logfname
        IMPORTING outrecords  = lt_logfname_map
                  rejected    = lv_rejected ).
      IF lv_rejected = abap_true.
*      RAISE EXCEPTION TYPE /scwm/cx_sp.
      ENDIF.

*   prepare selection condition
      READ TABLE lt_logfname_map
        WITH KEY fieldname = 'STATUS_VALUE'
        INTO ls_logfname_map2.
      IF sy-subrc NE 0.
        ASSERT ID /scwm/ui_delivery CONDITION 1 = 0.
      ELSE.
        ls_selection-fieldname = ls_logfname_map2-logfname.
        LOOP AT so_dsiva INTO ls_dsiva.
          ls_selection-sign   = ls_dsiva-sign.
          ls_selection-option = ls_dsiva-option.
          ls_selection-low    = ls_dsiva-low.
          ls_selection-high   = ls_dsiva-high.
          APPEND ls_selection TO ct_selection.
        ENDLOOP.
      ENDIF.
    ENDIF.

* Planned delivery date
    me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                    iv_datefrom = p_dlvdfr
                                    iv_timefrom = p_dlvtfr
                                    iv_dateto = p_dlvdto
                                    iv_timeto = p_dlvtto
                           CHANGING ct_timestamp = lt_timestamp_r ).

    LOOP AT lt_timestamp_r INTO ls_timestamp_r.
      CLEAR ls_selection.
      IF ls_timestamp_r-sign = /scmb/cl_search=>sc_sign_i.
        ls_selection-fieldname =
          /scdl/if_dl_logfname_c=>sc_tstfr_tdelivery_plan_h.
        ls_selection-option    = ls_timestamp_r-option.
        ls_selection-low       = ls_timestamp_r-low.
        ls_selection-high      = ls_timestamp_r-high.
        APPEND ls_selection TO ct_selection.
      ENDIF.
    ENDLOOP.
* Final delivery date
    me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                iv_datefrom = p_fdldfr
                                iv_timefrom = p_fdltfr
                                iv_dateto = p_fdldto
                                iv_timeto = p_fdltto
                       CHANGING ct_timestamp = lt_timestamp_r ).

    LOOP AT lt_timestamp_r INTO ls_timestamp_r.
      CLEAR ls_selection.
      IF ls_timestamp_r-sign = /scmb/cl_search=>sc_sign_i.
        ls_selection-fieldname =
          /scwm/if_dl_logfname_c=>sc_tstfr_tdeliveryf_plan_h.
        ls_selection-option    = ls_timestamp_r-option.
        ls_selection-low       = ls_timestamp_r-low.
        ls_selection-high      = ls_timestamp_r-high.
        APPEND ls_selection TO ct_selection.
      ENDIF.
    ENDLOOP.

* Delivery creation Date
    me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                            iv_datefrom = p_cdatfr
                            iv_timefrom = p_ctimfr
                            iv_dateto = p_cdatto
                            iv_timeto = p_ctimto
                   CHANGING ct_timestamp = lt_timestamp_r ).

    LOOP AT lt_timestamp_r INTO ls_timestamp_r.
      CLEAR ls_selection.
      IF ls_timestamp_r-sign = /scmb/cl_search=>sc_sign_i.
        ls_selection-fieldname =
          /scdl/if_dl_logfname_c=>sc_cretst_h.
        ls_selection-option    = ls_timestamp_r-option.
        ls_selection-low       = ls_timestamp_r-low.
        ls_selection-high      = ls_timestamp_r-high.
        APPEND ls_selection TO ct_selection.
      ENDIF.
    ENDLOOP.

* Preselection if HU number was a search criterion ---------------------
    IF NOT lt_huident_r IS INITIAL OR lt_ident_r IS NOT INITIAL OR lt_piguid_r IS NOT INITIAL OR lt_psguid_r IS NOT INITIAL.
      CALL FUNCTION '/SCWM/HU_SELECT_PDO'
        EXPORTING
          iv_lgnum   = iv_lgnum
          ir_huident = lt_huident_r
          ir_ident   = lt_ident_r
          ir_idart   = lt_idart_r
          ir_piguid  = lt_piguid_r
          ir_psguid  = lt_psguid_r
        IMPORTING
          et_docid   = lt_docid
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.
      IF lt_docid IS INITIAL.
*     No data for specified HU => Clear sel. table and add dummy DOCID
        CLEAR:
          ct_selection,
          ls_selection.
        ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
        ls_selection-option    = /scmb/cl_search=>sc_eq.
        ls_selection-low       = 'NOT_EXISTENT'.
        APPEND ls_selection TO ct_selection.
        RETURN.
      ELSE.
        LOOP AT lt_docid INTO ls_docid.
          CLEAR ls_selection.
          ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
          ls_selection-option    = /scmb/cl_search=>sc_eq.
          ls_selection-low       = ls_docid-docid.
          APPEND ls_selection TO ct_selection.
        ENDLOOP.
      ENDIF.
    ENDIF.

* Preselection if TU number/TU selection period was a search criterion
    IF NOT s_tu_ex[] IS INITIAL OR
          ( p_tudfr IS NOT INITIAL OR
            p_tudto IS NOT INITIAL  ) .
*   Create required instances for TU query
      CREATE OBJECT lo_log_wm.
      CREATE OBJECT lo_query_tu
        EXPORTING
          io_log = lo_log_wm.

*   Set DOCCAT for query
      ls_doccat_r-sign   = /scmb/cl_search=>sc_sign_i.
      ls_doccat_r-option = /scmb/cl_search=>sc_eq.
      ls_doccat_r-low    = /scdl/if_dl_doc_c=>sc_doccat_out_prd.
      lo_query_tu->add_dlv_doccat(
        EXPORTING is_sel_dlv_doccat = ls_doccat_r ).

*   Fill TU_NUM_EXT to query
      IF s_tu_ex[] IS NOT INITIAL.
        LOOP AT s_tu_ex INTO ls_tu_ext.
          MOVE-CORRESPONDING ls_tu_ext TO ls_tu_r.
          lo_query_tu->add_tu_num_ext(
            EXPORTING is_tu_num_ext = ls_tu_r ).
        ENDLOOP.
      ELSE.
*     If TU number was not entered explicitly but a date was given then we
*     expect every TU within that timeframe
        CLEAR ls_tu_r.
        ls_tu_r-sign = 'I'.
        ls_tu_r-option = 'CP'.
        ls_tu_r-low = '*'.
        lo_query_tu->add_tu_num_ext(
          EXPORTING is_tu_num_ext = ls_tu_r ).
      ENDIF.

*   Start query with time selection range
      me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                        iv_datefrom = p_tudfr
                        iv_timefrom = p_tutfr
                        iv_dateto = p_tudto
                        iv_timeto = p_tutto
               CHANGING ct_timestamp = lt_timestamp_r ).

      CLEAR:
        ls_timestamp_r,
        lt_docid_tu.
      READ TABLE lt_timestamp_r INTO ls_timestamp_r INDEX 1.
      lv_timestamp_l = ls_timestamp_r-low.
      lv_timestamp_h = ls_timestamp_r-high.
      CALL FUNCTION '/SCWM/GET_DLV_BY_TU_QUERY'
        EXPORTING
          io_tu_query   = lo_query_tu
          iv_sel_start  = lv_timestamp_l
          iv_sel_end    = lv_timestamp_h
          iv_do_refresh = abap_true
          iv_call_mode  = wmesr_call_mode_read_only
        IMPORTING
          et_docid      = lt_docid_tu.

*   Adjust selection table
      IF lt_docid_tu IS INITIAL.
*     No data for specified TU => Clear sel. table and add dummy DOCID
        CLEAR:
          ct_selection,
          ls_selection.
        ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
        ls_selection-sign      = /scmb/cl_search=>sc_sign_i.
        ls_selection-option    = /scmb/cl_search=>sc_eq.
        ls_selection-low       = 'NOT_EXISTENT'.
        APPEND ls_selection TO ct_selection.
        RETURN.
      ELSE.
        LOOP AT lt_docid_tu INTO ls_docid_tu.
          CLEAR ls_selection.
          ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
          ls_selection-sign      = /scmb/cl_search=>sc_sign_i.
          ls_selection-option    = /scmb/cl_search=>sc_eq.
          ls_selection-low       = ls_docid_tu-docid.
          APPEND ls_selection TO ct_selection.
        ENDLOOP.
      ENDIF.
    ENDIF.

* Preselection if wave number was a search criterion ---------------------
    IF NOT s_waveno[] IS INITIAL.

      READ TABLE s_waveno INTO ls_wavesel INDEX 1.
      IF ls_wavesel-option EQ 'EQ' AND ls_wavesel-low EQ '0000000000'.
        ls_selection-fieldname = /scwm/if_dl_logfname_c=>sc_waveflg_i.
        ls_selection-sign      = /scmb/cl_search=>sc_sign_i.
        ls_selection-option    = /scmb/cl_search=>sc_eq.
        ls_selection-low       = ''.
        APPEND ls_selection TO ct_selection.
      ELSE.

*     Select waves of warehouse requests
        SELECT DISTINCT rdocid AS docid FROM /scwm/waveitm
           INTO CORRESPONDING FIELDS OF TABLE lt_docid_wave
           WHERE
            lgnum = iv_lgnum AND
            wave  IN s_waveno.

*     Adjust selection table
        IF lt_docid_wave IS INITIAL.
*       No data for specified wave => Clear sel. table and add dummy DOCID
          CLEAR:
            ct_selection,
            ls_selection.
          ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
          ls_selection-sign      = /scmb/cl_search=>sc_sign_i.
          ls_selection-option    = /scmb/cl_search=>sc_eq.
          ls_selection-low       = 'NOT_EXISTENT'.
          APPEND ls_selection TO ct_selection.
          RETURN.
        ELSE.
          LOOP AT lt_docid_wave INTO ls_docid_wave.
            CLEAR ls_selection.
            ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
            ls_selection-sign      = /scmb/cl_search=>sc_sign_i.
            ls_selection-option    = /scmb/cl_search=>sc_eq.
            ls_selection-low       = ls_docid_wave-docid.
            APPEND ls_selection TO ct_selection.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

* Finally specify the datasource
    IF p_db IS INITIAL.
      CLEAR ls_selection.
*   If datasource is DB then we don't do anything -> default behaviour
      IF p_arch IS NOT INITIAL.
        ls_selection-fieldname = /scwm/if_ui_c=>sc_field_data_source_arch.
        ls_selection-sign  = /scmb/cl_search=>sc_sign_i.
        ls_selection-option    = /scmb/cl_search=>sc_eq.
        ls_selection-low       = abap_true.
        gv_dsrc = /scdl/if_dl_query_c=>sc_source_archive.
      ELSEIF p_both IS NOT INITIAL.
        ls_selection-fieldname = /scwm/if_ui_c=>sc_field_data_source_both.
        ls_selection-sign  = /scmb/cl_search=>sc_sign_i.
        ls_selection-option    = /scmb/cl_search=>sc_eq.
        ls_selection-low       = abap_true.
        gv_dsrc = /scdl/if_dl_query_c=>sc_source_both.
      ELSE.
*   both parameters are initial, use the global variable
*   it happens during navigation (header -> item)
        CASE gv_dsrc.
          WHEN /scdl/if_dl_query_c=>sc_source_both.
            ls_selection-fieldname = /scwm/if_ui_c=>sc_field_data_source_both.
            ls_selection-sign  = /scmb/cl_search=>sc_sign_i.
            ls_selection-option    = /scmb/cl_search=>sc_eq.
            ls_selection-low       = abap_true.
          WHEN /scdl/if_dl_query_c=>sc_source_archive.
            ls_selection-fieldname = /scwm/if_ui_c=>sc_field_data_source_arch.
            ls_selection-sign  = /scmb/cl_search=>sc_sign_i.
            ls_selection-option    = /scmb/cl_search=>sc_eq.
            ls_selection-low       = abap_true.
        ENDCASE.
      ENDIF.
      IF ls_selection IS NOT INITIAL.
        APPEND ls_selection TO ct_selection.
      ENDIF.
    ELSE.
      gv_dsrc = /scdl/if_dl_query_c=>sc_source_db.
    ENDIF.

* Delivery number
    LOOP AT s_docno INTO ls_docno.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docno_h.
      ls_selection-sign      = ls_docno-sign.
      ls_selection-option    = ls_docno-option.
      ls_selection-low       = ls_docno-low.
      ls_selection-high      = ls_docno-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Sales Order number
    LOOP AT s_soi INTO ls_so_h.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_refdocno_so_i.
      ls_selection-sign      = ls_so_h-sign.
      ls_selection-option    = ls_so_h-option.
      ls_selection-low       = ls_so_h-low.
      ls_selection-high      = ls_so_h-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Transport unit
    LOOP AT s_tu INTO ls_tu.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_transmeans_id_h.
      ls_selection-sign      = ls_tu-sign.
      ls_selection-option    = ls_tu-option.
      ls_selection-low       = ls_tu-low.
      ls_selection-high      = ls_tu-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Ship to party
    LOOP AT s_stprt INTO ls_stprt.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_partyno_stprt_h.
      ls_selection-sign      = ls_stprt-sign.
      ls_selection-option    = ls_stprt-option.
      ls_selection-low       = ls_stprt-low.
      ls_selection-high      = ls_stprt-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Status picking
    LOOP AT s_dpii INTO ls_status_value.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_status_value_dpi_i.
      ls_selection-sign      = ls_status_value-sign.
      ls_selection-option    = ls_status_value-option.
      ls_selection-low       = ls_status_value-low.
      ls_selection-high      = ls_status_value-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Planned goods issue date
    me->convert_date_time( EXPORTING iv_lgnum = iv_lgnum
                                    iv_datefrom = p_pgidfr
                                    iv_timefrom = p_pgitfr
                                    iv_dateto = p_pgidto
                                    iv_timeto = p_pgitto
                           CHANGING ct_timestamp = lt_timestamp_r ).
    LOOP AT lt_timestamp_r INTO ls_timestamp_r.
      CLEAR ls_selection.
      ls_selection-fieldname =
        /scdl/if_dl_logfname_c=>sc_tstfr_sgoodsissue_plan_i.
      ls_selection-option    = ls_timestamp_r-option.
      ls_selection-low       = ls_timestamp_r-low.
      ls_selection-high      = ls_timestamp_r-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

* Product number
    LOOP AT s_prod INTO ls_prod.
      CLEAR ls_selection.
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_productno_i.
      ls_selection-sign      = ls_prod-sign.
      ls_selection-option    = ls_prod-option.
      ls_selection-low       = ls_prod-low.
      ls_selection-high      = ls_prod-high.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

  ENDMETHOD.

  METHOD fill_selection_table_item.
    DATA: ls_selection     TYPE /scwm/dlv_selection_str.

    LOOP AT it_data_parent ASSIGNING FIELD-SYMBOL(<is_data_parent>).
      ls_selection-fieldname = /scdl/if_dl_logfname_c=>sc_docid_h.
      ls_selection-sign      = wmegc_sign_inclusive.
      ls_selection-option    = wmegc_option_eq.
      ls_selection-low       = <is_data_parent>-docid.
      APPEND ls_selection TO ct_selection.
    ENDLOOP.

  ENDMETHOD.

  METHOD whritem_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
      'S_DOCNO'                     TO ls_mapping-selname,
      'DOCNO_H'                     TO ls_mapping-fieldname,
      abap_true                     TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
        'S_DOCTY'                     TO ls_mapping-selname,
        'DOCTYPE_H'                   TO ls_mapping-fieldname,
        abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_HUNO'                      TO ls_mapping-selname,
          'HUNO'                        TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
        'S_TU'                        TO ls_mapping-selname,
        'TRANSMEANS_ID_H'             TO ls_mapping-fieldname,
        abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
        'S_MANUAL'                    TO ls_mapping-selname,
        'MANUAL_H'                    TO ls_mapping-fieldname,
        abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: 'ZEWM_S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_PUT_H'                       TO ls_mapping-selname,
          'PUT_STRA'                    TO ls_mapping-fieldname,
          abap_true                     TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_TU_EX'                     TO ls_mapping-selname,
          'TU'                          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_TCDREF'                    TO ls_mapping-selname,
          'REFDOCNO_TCD_H'              TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
        'S_SOI'                       TO ls_mapping-selname,
        'REFDOCNO_SO_I'               TO ls_mapping-fieldname,
        abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
            'S_RMA_H'                    TO ls_mapping-selname,
            'REFDOCNO_RMA_I'             TO ls_mapping-fieldname,
            abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
             'S_PO_H'                   TO ls_mapping-selname,
             'REFDOCNO_PO_I'            TO ls_mapping-fieldname,
             abap_false                 TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
             'S_PPO_H'                  TO ls_mapping-selname,
             'REFDOCNO_PPO_H'           TO ls_mapping-fieldname,
             abap_false                 TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
             'S_PMO_H'                  TO ls_mapping-selname,
             'REFDOCNO_PMO_I'           TO ls_mapping-fieldname,
             abap_false                 TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
             'S_RES_H'                  TO ls_mapping-selname,
             'REFDOCNO_RES_I'           TO ls_mapping-fieldname,
             abap_false                 TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
         'S_ERP_H'                      TO ls_mapping-selname,
         'REFDOCNO_ERP_H'               TO ls_mapping-fieldname,
         abap_false                     TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_ERO_H'                     TO ls_mapping-selname,
          'REFDOCNO_ERO_I'              TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
            'S_MDPO_H'                  TO ls_mapping-selname,
            'REFDOCNO_MEDI_PO_H'        TO ls_mapping-fieldname,
            abap_false                  TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_ECN'                       TO ls_mapping-selname,
          'REFDOCNO_ECN_H'              TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_BOL'                       TO ls_mapping-selname,
          'REFDOCNO_BOL_H'              TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_FRD'                       TO ls_mapping-selname,
          'REFDOCNO_FRD_H'              TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_ROUTE'                     TO ls_mapping-selname,
          'ROUTE_ID_H'                  TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DEPAR'                     TO ls_mapping-selname,
          '/SCWM/DEPART_SCHED_H'        TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DEP_S'                     TO ls_mapping-selname,
          '/SCWM/ROUTE_DEP_SOURCE_H'    TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_STLO'                      TO ls_mapping-selname,
          'LOCATIONNO_STLO_H'           TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_STPRT'                     TO ls_mapping-selname,
          'PARTYNO_STPRT_H'             TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_STPRTF'                    TO ls_mapping-selname,
          'PARTYNO_STPRTF_H'            TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_LP'                        TO ls_mapping-selname,
          'LOCATIONNO_LP_I'             TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DGII'                      TO ls_mapping-selname,
          'STATUS_VALUE_DGI_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
         'S_DERI'                      TO ls_mapping-selname,
         'STATUS_VALUE_DER_I'          TO ls_mapping-fieldname,
         abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DLOI'                      TO ls_mapping-selname,
          'STATUS_VALUE_DLO_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DWAI'                      TO ls_mapping-selname,
          'STATUS_VALUE_DWA_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DRDH'                      TO ls_mapping-selname,
          'STATUS_VALUE_DRD_H'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'P_DBOI'                      TO ls_mapping-selname,
          'STATUS_VALUE_DBO_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DCOI'                      TO ls_mapping-selname,
          'STATUS_VALUE_DCO_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'SO_DSHH'                     TO ls_mapping-selname,
          'STATUS_VALUE_DSH_H'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DGTI'                      TO ls_mapping-selname,
          'STATUS_VALUE_DGT_I'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'P_CALC'                      TO ls_mapping-selname,
          'CALCULATE_PACKAGING'         TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_DWNH'                      TO ls_mapping-selname,
          'STATUS_VALUE_DWN_H'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'SO_DACH'                     TO ls_mapping-selname,
          'STATUS_VALUE_DAC_H'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_YARD'                      TO ls_mapping-selname,
          'TSTFR_TOUTYARD_PLAN_H'       TO ls_mapping-fieldname,
          abap_true                     TO ls_mapping-is_timestamp,
          'P_YRDDFR'                    TO ls_mapping-p_date_from,
          'P_YRDTFR'                    TO ls_mapping-p_time_from,
          'P_YRDDTO'                    TO ls_mapping-p_date_to,
          'P_YRDTTO'                    TO ls_mapping-p_time_to,
          'OUT_YARD_DATE'               TO ls_mapping-date_field,
          'OUT_YARD_TIME'               TO ls_mapping-time_field.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_TUDT'                      TO ls_mapping-selname,
          'TSTFR_TU'                    TO ls_mapping-fieldname,
          abap_true                     TO ls_mapping-is_timestamp,
          'P_TUDFR'                     TO ls_mapping-p_date_from,
          'P_TUTFR'                     TO ls_mapping-p_time_from,
          'P_TUDTO'                     TO ls_mapping-p_date_to,
          'P_TUTTO'                     TO ls_mapping-p_time_to,
          space                         TO ls_mapping-date_field,
          space                         TO ls_mapping-time_field.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'S_DLVDT'                    TO ls_mapping-selname,
          'TSTFR_TDELIVERY_PLAN_H'     TO ls_mapping-fieldname,
          abap_true                    TO ls_mapping-is_timestamp,
          'P_DLVDFR'                   TO ls_mapping-p_date_from,
          'P_DLVTFR'                   TO ls_mapping-p_time_from,
          'P_DLVDTO'                   TO ls_mapping-p_date_to,
          'P_DLVTTO'                   TO ls_mapping-p_time_to,
          'TDELIVERY_DATE_PLAN'        TO ls_mapping-date_field,
          'TDELIVERY_TIME_PLAN'        TO ls_mapping-time_field.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'S_FDLDT'                    TO ls_mapping-selname,
          '/SCWM/TSTFR_TDLVF_PLAN_H'   TO ls_mapping-fieldname,
          abap_true                    TO ls_mapping-is_timestamp,
          'P_FDLDFR'                   TO ls_mapping-p_date_from,
          'P_FDLTFR'                   TO ls_mapping-p_time_from,
          'P_FDLDTO'                   TO ls_mapping-p_date_to,
          'P_FDLTTO'                   TO ls_mapping-p_time_to,
          'TDELIVERYF_DATE_PLAN'       TO ls_mapping-date_field,
          'TDELIVERYF_TIME_PLAN'       TO ls_mapping-time_field.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
         'S_CDAT'                      TO ls_mapping-selname,
         '/TSTFR_TDELIVERY_CREATE'     TO ls_mapping-fieldname,
         abap_true                     TO ls_mapping-is_timestamp,
         'P_CDATFR'                    TO ls_mapping-p_date_from,
         'P_CTIMFR'                    TO ls_mapping-p_time_from,
         'P_CDATTO'                    TO ls_mapping-p_date_to,
         'P_CTIMTO'                    TO ls_mapping-p_time_to,
         'TDELIVERY_CRE_DATE'          TO ls_mapping-date_field,
         'TDELIVERY_CRE_TIME'          TO ls_mapping-time_field.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'P_CALC'                     TO ls_mapping-selname,
          'PACK_CALC'                  TO ls_mapping-fieldname.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'PO_DSITY'                   TO ls_mapping-selname,
          'STATUS_TYPE_ITEM'           TO ls_mapping-fieldname,
          abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'SO_DSIVA'                   TO ls_mapping-selname,
          'STATUS_VALUE_ITEM'          TO ls_mapping-fieldname,
          abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                  TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'P_CDYNS'                    TO ls_mapping-selname,
         'SKIP_DYN_STATUS_CALCULATION' TO ls_mapping-fieldname,
          abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                  TO ct_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'P_REFDOC'                   TO ls_mapping-selname,
          'DISP_REFNO'                 TO ls_mapping-fieldname,
          abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                  TO ct_mapping.

    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_WAVENO'                    TO ls_mapping-selname,
          'WAVE'                        TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.

    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'P_DGIND'                     TO ls_mapping-selname,
          'CALCULATE_DG_REL'            TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.

    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_CREBY'                     TO ls_mapping-selname,
          'CREATED_BY'                  TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.

    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'P_CNTATT'                    TO ls_mapping-selname,
          'NO_ATTACHMENT'               TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'SO_TPLT'                     TO ls_mapping-selname,
          'TRANSPL_TYPE_H'              TO ls_mapping-fieldname,
           abap_false                   TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.

    CLEAR ls_mapping.
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_FLP_H'                     TO ls_mapping-selname,
          '/SCWM/FLP_STATUS_H'          TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.

    "Item
    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
        'S_DPII'                      TO ls_mapping-selname,
        'STATUS_VALUE_DPI_I'          TO ls_mapping-fieldname,
        abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
         'S_PROD'                      TO ls_mapping-selname,
         'PRODUCTNO_I'                 TO ls_mapping-fieldname,
         abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND'  TO ls_mapping-tablename,
          'S_STPRT'                     TO ls_mapping-selname,
          'PARTYNO_STPRT_H'             TO ls_mapping-fieldname,
          abap_false                    TO ls_mapping-is_key.
    APPEND ls_mapping                   TO ct_mapping.
    CLEAR ls_mapping.

    MOVE: '/SCWM/S_WIP_Q_WHR_OUTBOUND' TO ls_mapping-tablename,
          'S_PGIDT'                    TO ls_mapping-selname,
          'TSTFR_SGOODSISSUE_PLAN_I'   TO ls_mapping-fieldname,
          abap_true                    TO ls_mapping-is_timestamp,
          'P_PGIDFR'                   TO ls_mapping-p_date_from,
          'P_PGITFR'                   TO ls_mapping-p_time_from,
          'P_PGIDTO'                   TO ls_mapping-p_date_to,
          'P_PGITTO'                   TO ls_mapping-p_time_to,
          'GI_DATE_PLAN'               TO ls_mapping-date_field,
          'GI_TIME_PLAN'               TO ls_mapping-time_field.
    APPEND ls_mapping                  TO ct_mapping.

  ENDMETHOD.

ENDCLASS.
