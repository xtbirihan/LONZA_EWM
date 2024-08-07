CLASS zcl_vi02_mfs_tele_send_crane DEFINITION
  PUBLIC
  INHERITING FROM /sl0/cl_mfs_send_tele_q
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: map_telegram_data REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      update_huhdr
        IMPORTING
          is_huhdr_int    TYPE /scwm/s_huhdr_int
          io_hu           TYPE REF TO /scwm/cl_wm_packing
        RETURNING
          VALUE(rv_subrc) TYPE sy-subrc,
      has_same_delivery_and_door
        IMPORTING
          iv_huident_1   TYPE /scwm/de_huident
          iv_huident_2   TYPE /scwm/de_huident
        RETURNING
          VALUE(rv_same) TYPE abap_bool.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VI02_MFS_TELE_SEND_CRANE IMPLEMENTATION.


  METHOD has_same_delivery_and_door.
    DATA: lv_msgtext     TYPE bapi_msg,
          lv_done        TYPE boolean,
          lv_doccat_pdo  TYPE /scwm/de_doccat VALUE /scdl/if_dl_doc_c=>sc_doccat_out_prd,
          lv_to_type     TYPE /scwm/de_mfs_to_type,
          lv_tanum_inact TYPE /scwm/tanum,
          lv_huident     TYPE /scwm/de_huident,
          lv_docno_1     TYPE /scdl/dl_docno_int,
          lv_docno_2     TYPE /scdl/dl_docno_int,
          ls_huhdr       TYPE /scwm/s_huhdr_int,
          ls_docid       TYPE /scwm/dlv_docid_str,
          ls_ldgrp_seq   TYPE /sl0/t_ldgrp_seq,
          lt_ordim_o     TYPE /scwm/tt_ordim_o,
          lt_huref       TYPE /scwm/tt_huref_int,
          lt_docid_pdo   TYPE /scwm/dlv_docid_tab,
          lt_mapping_pdo TYPE /scwm/dlv_prd_map_tab,
          rr_md          TYPE rseloption,
          lo_delivery    TYPE REF TO /scwm/cl_dlv_management_prd,
          lo_log         TYPE REF TO /sl0/cl_log_mfs.

    FIELD-SYMBOLS: <fs_ordim_o>     TYPE /scwm/ordim_o,
                   <fs_huref>       TYPE /scwm/s_huref_int,
                   <fs_mapping_pdo> TYPE /scwm/dlv_prd_map_str.

    "***** Start & *****
    MESSAGE i007(/sl0/mfs) INTO lv_msgtext WITH 'has_same_delivery_and_door'.
    lo_log->add_message( iv_row = 0 ).

    "Populate range of marshalling doors
    rr_md = /sl0/cl_param_select=>read_const_range( iv_lgnum      = mv_lgnum
                                                    iv_param_prof = /sl0/cl_param_c=>c_prof_mfs_cus
                                                    iv_context    = /sl0/cl_param_c=>c_context_md
                                                    iv_parameter  = /sl0/cl_param_c=>c_param_md ).

    rv_same = abap_true.

    IF iv_huident_1 IS NOT INITIAL AND iv_huident_2 IS NOT INITIAL.
      DO 2 TIMES.
        CLEAR: lt_ordim_o, lt_docid_pdo, lt_mapping_pdo.

        IF lv_huident IS INITIAL.
          lv_huident = iv_huident_1.
        ELSEIF lv_huident = iv_huident_1.
          lv_huident = iv_huident_2.
        ELSE.
          EXIT. "Done
        ENDIF.

        " Get inactive WT for first HU and make sure it is going to a marshalling door.
        CALL FUNCTION '/SCWM/TO_READ_HU_MFS'
          EXPORTING
            iv_lgnum       = mv_lgnum
            iv_huident     = lv_huident
          IMPORTING
            ev_to_type     = lv_to_type
            ev_tanum_inact = lv_tanum_inact
            et_ordim_o     = lt_ordim_o[]
          EXCEPTIONS
            wrong_input    = 1
            OTHERS         = 2.

        IF lv_tanum_inact IS NOT INITIAL.
          LOOP AT lt_ordim_o ASSIGNING <fs_ordim_o> WHERE tanum = lv_tanum_inact.
            IF <fs_ordim_o>-nlpla NOT IN rr_md.
              lv_done = abap_true.
              EXIT. "only relevant when going to marshalling door (cv_same = abap_true is returned to caller)
            ELSEIF <fs_ordim_o>-rdoccat = lv_doccat_pdo.
              "Full pallets from highbay warehouse i.e. not pre-picked.
              ls_docid-docid = <fs_ordim_o>-rdocid.
              APPEND ls_docid TO lt_docid_pdo.
            ENDIF.
            EXIT.
          ENDLOOP.
          IF lv_done = abap_true.
            "HU &1 not going to a door, it is going to &2
            MESSAGE i337(/sl0/mfs) INTO lv_msgtext WITH lv_huident <fs_ordim_o>-nlpla.
            lo_log->add_message( iv_row = 0 ).
            EXIT. "main loop.
          ENDIF.
        ELSE.
          EXIT. "no point in going on, we need inactive WT (cv_same = abap_true is returned to caller)
        ENDIF.


        " Read HUHDR and HUREF. The HUHDR contains loadingroup and
        " the HUREF the DOCID i.e. the outbound delivery (for pre-
        " picked HUs).

        CALL FUNCTION '/SCWM/HU_READ'
          EXPORTING
            iv_appl    = wmegc_huappl_wme
            iv_lgnum   = mv_lgnum
            iv_huident = lv_huident
          IMPORTING
            es_huhdr   = ls_huhdr
            et_huref   = lt_huref
          EXCEPTIONS
            deleted    = 1
            not_found  = 2
            error      = 3
            OTHERS     = 4.

        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                              INTO lv_msgtext.
          lo_log->add_message( iv_row = 0 ).
          EXIT. "no point in going on, cv_same = abap_true is returned to caller)
        ENDIF.

        " Convert the DOCID to DOCNO, (for logging)

        DELETE lt_huref WHERE doccat <> lv_doccat_pdo.

        LOOP AT lt_huref ASSIGNING <fs_huref>.
          ls_docid-docid = <fs_huref>-docid.
          APPEND ls_docid TO lt_docid_pdo.
        ENDLOOP.

        IF lo_delivery IS NOT BOUND.
          CREATE OBJECT lo_delivery.
        ENDIF.

        "Method returns map containing docid and docno
        CALL METHOD lo_delivery->map_docid_to_docno
          EXPORTING
            iv_doccat  = /scdl/if_dl_doc_c=>sc_doccat_out_prd
            it_docid   = lt_docid_pdo
          IMPORTING
            et_mapping = lt_mapping_pdo.

        READ TABLE lt_mapping_pdo ASSIGNING <fs_mapping_pdo> INDEX 1.
        IF sy-subrc IS NOT INITIAL.
          EXIT. "no point in going on, cv_same = abap_true is returned to caller)
        ELSEIF lv_huident = iv_huident_1.
          lv_docno_1 = <fs_mapping_pdo>-docno.
          MESSAGE i336(/sl0/mfs) INTO lv_msgtext WITH lv_docno_1 iv_huident_1.
          lo_log->add_message( iv_row = 0 ).
        ELSEIF lv_huident = iv_huident_2.
          lv_docno_2 = <fs_mapping_pdo>-docno.
          MESSAGE i336(/sl0/mfs) INTO lv_msgtext WITH lv_docno_2 iv_huident_2.
          lo_log->add_message( iv_row = 0 ).
        ENDIF.
      ENDDO.
    ENDIF.

    IF lv_docno_1 IS NOT INITIAL
       AND lv_docno_2 IS NOT INITIAL
       AND lv_docno_1 NE lv_docno_2.

      "HUs on crane are for different deliveries returning cv_not_same = X
      MESSAGE i338(/sl0/mfs) INTO lv_msgtext.
      lo_log->add_message( iv_row = 0 ).

      rv_same = abap_false.
    ENDIF.

    "***** End & *****
    MESSAGE i008(/sl0/mfs) INTO lv_msgtext WITH 'has_same_delivery_and_door'.
    lo_log->add_message( iv_row = 0 ).
  ENDMETHOD.


  METHOD map_telegram_data.
* Logic taken from FM /SL0/MFS_TELE_SEND_CRANE_ARQ

    DATA : lv_returncode     TYPE nrreturn,                 "#EC NEEDED
           lv_task           TYPE char32,
           ls_tutypemap      TYPE /sl0/t_tutypemap,
           ls_swl_mfscp      TYPE /sl0/t_mfscp,
           ls_tmfscp         TYPE /scwm/tmfscp,
           ls_swl_mfsplc     TYPE /sl0/t_mfsplc,
           lv_rsrc_move_mode TYPE /scwm/de_mfsrmm,
           ls_crane          TYPE /sl0/t_crane,
           ls_mfscp_1        TYPE /scwm/mfscp,
           lv_changed_11     TYPE abap_bool,
           lv_changed_21     TYPE abap_bool,
           lv_msgtext        TYPE bapi_msg,                 "#EC NEEDED
           ls_huhdr_int_11   TYPE /scwm/s_huhdr_int,
           ls_huhdr_int_21   TYPE /scwm/s_huhdr_int,
           lo_hu             TYPE REF TO /scwm/cl_wm_packing,
           lv_src_changed    TYPE /scwm/de_mfssource,
           "<g7dzhey 20230809> TODO: separate MONORAIL logic
*         lv_mono_dep       TYPE /sl0/de_mono_dep,
           "</g7dzhey 20230809>
           lo_mfs_helper     TYPE REF TO /sl0/cl_mfs_process_helper,
           lo_crane          TYPE REF TO /sl0/cl_crane,
           lv_to_type        TYPE /scwm/de_mfs_to_type,
           lv_tanum_inact    TYPE /scwm/tanum,
           lt_ordim_o        TYPE /scwm/tt_ordim_o,
           ls_ordim_o        TYPE /scwm/ordim_o,
           lo_mfs_hu         TYPE REF TO /sl0/cl_mfs_hu,
           lx_mfs            TYPE REF TO /scwm/cx_mfs.

    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "

    " Central cleanup..
    /scwm/cl_tm=>cleanup( EXPORTING iv_lgnum = mv_lgnum ).

    IF ms_ordim_o IS INITIAL.
      IF cs_tele_snd-/sl0/assignmentid IS NOT INITIAL.
        " PIckup assignment and HU already on resource OR
        " DEposit assignment and HU not on resource then
        " dont retry sending ARQ telegram as its associated
        " ACP has already been received.
        " 22.03.2018 hta We have to retry sending ARQ, always if ACK has not been
        "                received. This code was introduced because our internal
        "                simulation does not gracefully handle repeated telegrams. The
        "                gateway however does handle repeated telegrams correctly thus
        "                if ACK was not received telegram must be repeated, gateway will
        "                determine whether telegram was repeat, if it was it will send
        "                ACK to EWM but will not pass the telegram on the subsystem.
        CALL FUNCTION '/SCWM/TO_READ_HU_MFS'
          EXPORTING
            iv_lgnum       = mv_lgnum
            iv_huident     = cs_tele_snd-huident
          IMPORTING
            ev_tanum_inact = lv_tanum_inact
            es_ordim_o     = ls_ordim_o
          EXCEPTIONS
            wrong_input    = 1
            OTHERS         = 2.
        IF ls_ordim_o IS NOT INITIAL AND ls_ordim_o-tanum = lv_tanum_inact.
          CLEAR ls_ordim_o.
        ENDIF.
        IF ls_ordim_o IS NOT INITIAL.
          SELECT SINGLE tanum, who
            FROM /scwm/mfsdelay
            INTO @DATA(ls_delay)
            WHERE lgnum   = @mv_lgnum
              AND plc     = @mv_plc
              AND channel = @mv_channel
              AND rsrc    = @cs_tele_snd-rsrc
              AND tanum   = @ls_ordim_o-tanum.
          IF sy-subrc IS NOT INITIAL.
            CLEAR ls_ordim_o.
          ENDIF.
        ENDIF.

        IF ls_ordim_o IS NOT INITIAL.
          IF ( cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_pi AND
               ls_ordim_o-vlpla IS INITIAL ) OR
             ( cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_de AND
               ls_ordim_o-srsrc IS INITIAL ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 RETRYING, ls_ordim_o-tanum:{ ls_ordim_o-tanum }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 ls_ordim_o-vlpla:{ ls_ordim_o-vlpla }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 ls_ordim_o-srsrc:{ ls_ordim_o-srsrc }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 cs_tele_snd-/sl0/assignmentid:{ cs_tele_snd-/sl0/assignmentid }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 cs_tele_snd-/sl0/assignmenttype:{ cs_tele_snd-/sl0/assignmenttype }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 cs_tele_snd-/sl0/fork:{ cs_tele_snd-/sl0/fork }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |1 cs_tele_snd-huident:{ cs_tele_snd-huident }|.
            mo_log->add_message( iv_row = 0 ).
          ELSE.

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |2 is_ordim_o RETRYING Tg unchanged|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |2 cs_tele_snd-/sl0/assignmentid:{ cs_tele_snd-/sl0/assignmentid }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |2 cs_tele_snd-/sl0/fork:{ cs_tele_snd-/sl0/fork }|.
            mo_log->add_message( iv_row = 0 ).

            MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |2 cs_tele_snd-huident:{ cs_tele_snd-huident }|.
            mo_log->add_message( iv_row = 0 ).
          ENDIF.
        ELSE.

          MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |3 no valid ORDIM_O found RETRYING anyway|.
          mo_log->add_message( iv_row = 0 ).

          MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |3 cs_tele_snd-/sl0/assignmentid:{ cs_tele_snd-/sl0/assignmentid }|.
          mo_log->add_message( iv_row = 0 ).

          MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |3 cs_tele_snd-/sl0/fork:{ cs_tele_snd-/sl0/fork }|.
          mo_log->add_message( iv_row = 0 ).

          MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |3 cs_tele_snd-huident:{ cs_tele_snd-huident }|.
          mo_log->add_message( iv_row = 0 ).
        ENDIF.
      ELSE.

        MESSAGE e000(/sl0/mfs) INTO lv_msgtext WITH |4 /sl0/assignmentid is initial leaving (nothing to retry)|.
        mo_log->add_message( iv_row = 0 ).

        MESSAGE e000(/sl0/mfs) INTO lv_msgtext WITH |4 cs_tele_snd-/sl0/assignmentid:{ cs_tele_snd-/sl0/assignmentid }|.
        mo_log->add_message( iv_row = 0 ).

        MESSAGE e000(/sl0/mfs) INTO lv_msgtext WITH |4 cs_tele_snd-/sl0/fork:{ cs_tele_snd-/sl0/fork }|.
        mo_log->add_message( iv_row = 0 ).

        MESSAGE e000(/sl0/mfs) INTO lv_msgtext WITH |4 cs_tele_snd-huident:{ cs_tele_snd-huident }|.
        mo_log->add_message( iv_row = 0 ).

        CLEAR: cs_tele_snd.
      ENDIF.

      finalize_logging(  ).

      RETURN.
    ENDIF.

    " --------------------------------------------- "
    "  Not an ARQ then we are done here
    " --------------------------------------------- "
    IF cs_tele_snd-teletype NE /sl0/if_c1_ewm_sp_c=>mc_telegram_arq.

      "No processing required for message of type &1 (crane interface)
      MESSAGE i106(/sl0/mfs) INTO lv_msgtext WITH cs_tele_snd-teletype.
      mo_log->add_message( iv_row = 0 ).

      finalize_logging( ).

      RETURN.
    ENDIF.

    " --------------------------------------------- "
    "  Get the crane object, we will need it
    " --------------------------------------------- "
    CREATE OBJECT lo_crane
      EXPORTING
        iv_lgnum   = mv_lgnum
        iv_plc     = mv_plc
        iv_channel = mv_channel
        iv_rsrc    = cs_tele_snd-rsrc.
    lo_crane->get_crane(
      EXPORTING
        io_log   = mo_log
      IMPORTING
        es_crane = ls_crane
        ev_rc = DATA(lv_subrc) ).

    IF lv_subrc NE 0 OR ls_crane IS INITIAL.
      "Crane NOT found for lgnum &1 plc &2 channel &3 and rsrc &4
      MESSAGE e133(/sl0/mfs) INTO lv_msgtext WITH mv_lgnum mv_plc mv_channel cs_tele_snd-rsrc.
      mo_log->add_message( iv_row = 0 ).

      finalize_logging( ).

      CLEAR cs_tele_snd.
      RETURN.
    ENDIF.

    " --------------------------------------------- "
    "  Sending ARQ message for crane and crane
    "  is not online then clear message and be done
    " --------------------------------------------- "
    IF cs_tele_snd-teletype = /sl0/if_c1_ewm_sp_c=>mc_telegram_arq.

      SELECT SINGLE /scwm/rsrc~rsrc,
                    /scwm/rsrc~mfs_queue,
                    /scwm/rsrc~exccode_overall
        FROM /scwm/rsrc
        JOIN /scwm/t346                                "#EC CI_BUFFJOIN
          ON   /scwm/rsrc~lgnum     = /scwm/t346~lgnum
         AND   /scwm/rsrc~mfs_queue = /scwm/t346~queue
         AND   /scwm/t346~rfrsrc    =  @wmegc_rfrsrc_mfs_with_rsrc
         AND   /scwm/rsrc~lgnum     =  @mv_lgnum
         AND   /scwm/t346~plc       =  @mv_plc
         AND   /scwm/rsrc~rsrc      =  @ls_crane-rsrc
          INTO (@DATA(ld_rsrc), @DATA(ld_queue), @DATA(ld_exccode) ).

      IF sy-subrc IS INITIAL AND ld_exccode IS NOT INITIAL.
        "ARQ to resource (assumed crane) and exception code is set, then dont send telegram.
        CLEAR cs_tele_snd. "MFS_SEND will terminate, and not send the ARQ message, the KZSUB of WT remains 'Y'

        "PLC &1 Resource &2, queue &3, not sending ARQ because exccode &4
        MESSAGE w058(/sl0/mfs) INTO lv_msgtext WITH mv_plc ld_rsrc ld_queue ld_exccode.
        mo_log->add_message( iv_row = 0 ).

        finalize_logging(  ).

        RETURN.
      ENDIF.
    ENDIF.
    " --------------------------------------------- "
    " Read Swisslog customizing for CP
    " --------------------------------------------- "
    IF cs_tele_snd-source IS NOT INITIAL.
      "Source is already in SIS notation we need to convert to an EWM object.
      SELECT SINGLE ewmobj FROM /scwm/mfsobjmap INTO @DATA(lv_cp)
                    WHERE lgnum   = @mv_lgnum   AND
                          plc     = @mv_plc     AND
                          plcobj  = @cs_tele_snd-source  AND
                          objtype = @wmegc_mfs_ewm_obj_cp.

      IF lv_cp IS NOT INITIAL.
        CALL FUNCTION '/SL0/MFSCP_READ_SINGLE'
          EXPORTING
            iv_lgnum     = mv_lgnum
            iv_plc       = mv_plc
            iv_cp        = lv_cp
          IMPORTING
            es_swl_mfscp = ls_swl_mfscp
          EXCEPTIONS
            error        = 1
            not_found    = 2
            OTHERS       = 99.
        IF sy-subrc <> 0.
          "log error but carry on anyway...
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                              INTO lv_msgtext.
          mo_log->add_message( iv_row = 0 ).
        ENDIF.
      ENDIF.
    ENDIF.

    " --------------------------------------------- "
    " Read Swisslog customizing for PLC
    " --------------------------------------------- "
    IF mv_plc IS NOT INITIAL.
      CALL FUNCTION '/SL0/MFSPLC_READ_SINGLE'
        EXPORTING
          iv_lgnum      = mv_lgnum
          iv_plc        = mv_plc
          iv_nobuf      = abap_true
        IMPORTING
          es_swl_mfsplc = ls_swl_mfsplc
        EXCEPTIONS
          error         = 1
          not_found     = 2
          OTHERS        = 99.
      IF sy-subrc <> 0.
        "log error but carry on anyway...
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                            INTO lv_msgtext.
        mo_log->add_message( iv_row = 0 ).
      ENDIF.
    ENDIF.


    " --------------------------------------------- "
    " Get the HU
    " --------------------------------------------- "
    CREATE OBJECT lo_hu.
    " Read HU Header Data..
    CALL METHOD lo_hu->/scwm/if_pack_bas~huheader_read
      EXPORTING
        iv_huident  = cs_tele_snd-huident
      IMPORTING
        es_huheader = ls_huhdr_int_11
      EXCEPTIONS
        not_found   = 1
        input       = 2
        error       = 3
        deleted     = 4
        OTHERS      = 5.
    IF sy-subrc NE 0.
      "Error reading HU Header Data
      MESSAGE e014(/sl0/mfs) INTO lv_msgtext.
      mo_log->add_message( iv_row = 0 ).

      finalize_logging( ).

      RETURN.
    ENDIF.


    " --------------------------------------------- "
    " Assignment ID
    " --------------------------------------------- "
    IF ls_huhdr_int_11-/sl0/assignmentid IS INITIAL.
      "Getting assignment ID for HU &1
      MESSAGE i087(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_11-huident.
      mo_log->add_message( iv_row = 0 ).

      DATA(lv_asgnid) = get_assignment_id( iv_huident = ls_huhdr_int_11-huident ).

      IF lv_asgnid IS NOT INITIAL.
        lv_changed_11 = abap_true. "Update HUHDR later
        ls_huhdr_int_11-/sl0/assignmentid = lv_asgnid.
      ENDIF.
    ENDIF.
    " Set Assignment ID in telegram.
    cs_tele_snd-/sl0/assignmentid = ls_huhdr_int_11-/sl0/assignmentid.


    " --------------------------------------------- "
    " Assignment Type
    "  --> PI: Pickup
    "  --> DE: Deposit
    "  --> CM: Complete Move
    " --------------------------------------------- "
    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    " Get WT Confirmation/Commissioning Control for
    " for the resource. (
    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    CREATE OBJECT lo_mfs_helper. " Instantiate helper object
    CALL METHOD lo_mfs_helper->get_wt_conf_control(
      EXPORTING
        iv_lgnum          = mv_lgnum
        iv_plc            = mv_plc
        iv_mfs_rsrc       = cs_tele_snd-rsrc
      IMPORTING
        ev_rsrc_move_mode = lv_rsrc_move_mode ).

    CASE lv_rsrc_move_mode.
      WHEN /sl0/if_c1_ewm_sp_c=>mc_rsrc_mode_a. " One-Step Confirmation
        cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_cm.
      WHEN /sl0/if_c1_ewm_sp_c=>mc_rsrc_mode_b. " Two-Step Confirmation
        "Determine whether HU is on Fork
        IF ( cs_tele_snd-huident = ls_crane-huident_reri AND
            ls_crane-forkload_reri = /sl0/if_c1_ewm_sp_c=>mc_forkload_lo )
        OR ( cs_tele_snd-huident = ls_crane-huident_rele AND
            ls_crane-forkload_rele = /sl0/if_c1_ewm_sp_c=>mc_forkload_lo )
        OR ( cs_tele_snd-huident = ls_crane-huident_frri AND
            ls_crane-forkload_frri = /sl0/if_c1_ewm_sp_c=>mc_forkload_lo )
        OR ( cs_tele_snd-huident = ls_crane-huident_frle AND
            ls_crane-forkload_frle = /sl0/if_c1_ewm_sp_c=>mc_forkload_lo ).
          "HU is on the fork, use deposit assignment
          cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_de.
        ELSE.
          cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_cm.
        ENDIF.
      WHEN ' '. " Two-Step Commissioning
        IF cs_tele_snd-source IS NOT INITIAL AND
           cs_tele_snd-dest IS INITIAL AND
           cs_tele_snd-rsrc IS NOT INITIAL.
          cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_pi.
        ELSEIF cs_tele_snd-source IS INITIAL AND
               cs_tele_snd-dest IS NOT INITIAL AND
               cs_tele_snd-rsrc IS NOT INITIAL.
          cs_tele_snd-/sl0/assignmenttype = /sl0/if_c1_ewm_sp_c=>mc_asgntyp_de.
        ENDIF.
      WHEN OTHERS.
        " No action..
    ENDCASE.



    " --------------------------------------------- "
    " TU Type
    " --------------------------------------------- "

    "TU Type determination based on Swisslog CP customizing
    IF ls_swl_mfscp-tutype_det = abap_true.
      TRY.
          CLEAR ls_tutypemap-/sl0/tutype.
          CALL FUNCTION ls_swl_mfscp-tutype_det_fm
            EXPORTING
              is_swl_mfscp = ls_swl_mfscp
              is_telegram  = cs_tele_snd
              iv_huident   = ls_huhdr_int_11-huident
              io_log       = mo_log
            IMPORTING
              ev_tutype    = ls_tutypemap-/sl0/tutype
            EXCEPTIONS
              OTHERS       = 99.
          IF sy-subrc EQ 0 AND ls_tutypemap-/sl0/tutype IS NOT INITIAL.
            IF ls_huhdr_int_11-/sl0/tutype NE ls_tutypemap-/sl0/tutype.
              "Change is only required if a different SIS TUType was determined
              cs_tele_snd-/sl0/tutype  = ls_tutypemap-/sl0/tutype.
              ls_huhdr_int_11-/sl0/tutype = ls_tutypemap-/sl0/tutype.
              lv_changed_11 = abap_true. "Update HUHDR later
            ENDIF.
          ENDIF.
        CATCH cx_sy_dyn_call_illegal_func.
          "TU Type determination on for &1 but FM &2 NOT FOUND
          MESSAGE e078(/sl0/mfs) INTO lv_msgtext
                       WITH ls_swl_mfscp-cp
                            ls_swl_mfscp-tutype_det_fm.
          mo_log->add_message( iv_row = 0 ).
      ENDTRY.
    ENDIF.

    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    " Crane TU Type may be different from the TU Type
    " used on the crane and conveyor.
    " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
    IF  /sl0/cl_param_select=>read_const( iv_lgnum      = mv_lgnum
                                          iv_param_prof = /sl0/cl_param_c=>c_prof_mfs_gen
                                          iv_context    = /sl0/cl_param_c=>c_context_crane_plc
                                          iv_parameter  = /sl0/cl_param_c=>c_param_det_sis_tutype ) = abap_true.
      CLEAR ls_tutypemap.
* g7dzhey22c TODO: implement project-specific code if applicable

*      lo_mfs_helper->get_tutyp_mapping(
*        EXPORTING
*          iv_lgnum        = mv_lgnum
*          iv_plc          = mv_plc
*          iv_channel      = mv_channel
*          iv_hutyp        = cs_tele_snd-hutyp
*          iv_only_typ     = abap_true
*        IMPORTING
*          es_wa_tutypemap = ls_tutypemap ).
*      IF ls_tutypemap-/sl0/tutype IS NOT INITIAL.
*        cs_tele_snd-/sl0/tutype    =  ls_tutypemap-/sl0/tutype.
*        ls_huhdr_int_11-/sl0/tutype = ls_tutypemap-/sl0/tutype.
*      ENDIF.
    ENDIF.


    " --------------------------------------------- "
    " Source
    " --------------------------------------------- "
    IF cs_tele_snd-slogpos IS NOT INITIAL.
      " It is a storage bin..
      CLEAR lv_src_changed.
      CONCATENATE cs_tele_snd-source cs_tele_snd-slogpos INTO lv_src_changed.
      CONDENSE lv_src_changed.
      cs_tele_snd-source = lv_src_changed.
    ENDIF.

    " --------------------------------------------- "
    " Dest
    " --------------------------------------------- "
    IF cs_tele_snd-dlogpos IS NOT INITIAL.
      " It is a storage bin..
      CLEAR lv_src_changed.
      CONCATENATE cs_tele_snd-dest cs_tele_snd-dlogpos INTO lv_src_changed.
      CONDENSE lv_src_changed.
      cs_tele_snd-dest = lv_src_changed.
      " Now we need to update the WT because although dlogpos is set correctly
      " in WT_DET it is not saved to the database. As standard SIS cranes do not
      " return the depth the HU was deposited on we need to rely on the dlogpos
      " in ordim_o when the WT is confirmed.
      CONCATENATE '/SL0/UPDDLOGPOS' "gc_task_prefix in function pool /sl0/mfs_tele_send
                  mv_plc ls_crane-rsrc INTO lv_task.

      CALL FUNCTION '/SL0/MFS_TELE_SEND_UPDDLOGPOS'
        STARTING NEW TASK lv_task
        EXPORTING
          iv_lgnum    = mv_lgnum
          iv_plc      = mv_plc
          is_ordim_o  = ms_ordim_o
          is_telegram = cs_tele_snd.
    ENDIF.

    " --------------------------------------------- "
    " Fork
    " --------------------------------------------- "

    CREATE OBJECT lo_mfs_hu
      EXPORTING
        iv_lgnum = mv_lgnum.
    " Default use rear fork
    cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_re.

    " Check if the source location of the WT is a CP
    " --------------------------------------------- "
    " Determine which fork to use
    " 1) HU on primary PUP -> RE
    " 2) HU on primary and secondary PUP -> BO
    " 3) HU on storage bin, one fork -> RE
    " 4) HU on storage bin, two fork -> RE, if not free then FR
    " 5) HU on resource, going to DEP -> RE, FR or BO as applicable
    " 6) HU on resource, going to storagbin -> RE, FR as applicable
    " --------------------------------------------- "

    IF ms_ordim_o-vlpla IS NOT INITIAL.

      CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
        EXPORTING
          iv_lgnum = mv_lgnum
          iv_lgpla = ms_ordim_o-vlpla
        IMPORTING
          es_mfscp = ls_mfscp_1
        EXCEPTIONS
          error    = 1
          OTHERS   = 2.
      IF sy-subrc EQ 0.
        " --------------------------------------------- "
        " HU is on a PickUp Point (PUP). Check whether
        " there is a secondary PUP with a WT which must
        " be picked up simultaneously. (crane with 2
        " forks!, two HUs on one fork are not supported
        " yet)
        " --------------------------------------------- "
        IF ls_mfscp_1-cp = ls_crane-cp_pup_11.
          " Get the HU on the other PUP i.e. the secondary pickup point
          SELECT SINGLE  /sl0/t_hop~occupied, /sl0/t_hop~huident
          INTO @DATA(ls_secondary_pup)
          FROM /sl0/t_hop
            WHERE lgnum = @mv_lgnum
              AND plc   = @ls_mfscp_1-plc
              AND cp    = @ls_crane-cp_pup_21.
          IF sy-subrc EQ 0 AND
             ls_secondary_pup-occupied = abap_true AND
             ls_secondary_pup-huident IS NOT INITIAL.
            " Get the WT for this HU
            lo_mfs_hu->to_read_hu_mfs(
                   EXPORTING
                     iv_huident     = ls_secondary_pup-huident
                   IMPORTING
                     ev_to_type     = lv_to_type
                     ev_tanum_inact = lv_tanum_inact
                     es_ordim_o     = ls_ordim_o
                     et_ordim_o     = lt_ordim_o[]
                   EXCEPTIONS
                     wrong_input    = 1
                     OTHERS         = 2 ).
            "Found a WT that was not sent on secondary PUP. Pick it up too.
            IF sy-subrc EQ 0 AND
               ls_ordim_o-tanum IS NOT INITIAL AND
               ls_ordim_o-kzsub NE wmegc_kzsub_uebergeben.
              "Get the HUHDR for the secondary HU, we need its assignment ID
              CALL METHOD lo_hu->/scwm/if_pack_bas~huheader_read
                EXPORTING
                  iv_huident  = ls_ordim_o-vlenr
                IMPORTING
                  es_huheader = ls_huhdr_int_21
                EXCEPTIONS
                  not_found   = 1
                  input       = 2
                  error       = 3
                  deleted     = 4
                  OTHERS      = 5.
              IF sy-subrc NE 0.
                "Failed to read HUHUDR of secondary HU &1
                MESSAGE e108(/sl0/mfs) INTO lv_msgtext WITH ls_ordim_o-vlenr.
                mo_log->add_message( iv_row = 0 ).
              ELSE.
                " --------------------------------------------------------
                " If the second HU doesnt have an assignment_id then
                " go and set it.
                " ---------------------------------------------------------
                IF ls_huhdr_int_21-/sl0/assignmentid IS INITIAL.
                  "Getting assignment ID for HU &1
                  MESSAGE i087(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_21-huident.
                  mo_log->add_message( iv_row = 0 ).

                  lv_asgnid = get_assignment_id( iv_huident = ls_huhdr_int_21-huident ).

                  IF lv_asgnid IS NOT INITIAL.
                    lv_changed_21 = abap_true. "Update HUHDR later
                    ls_huhdr_int_21-/sl0/assignmentid = lv_asgnid.
                  ENDIF.
                ENDIF.
                cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_bo.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        " Book assignment IDs onto crane.
        IF ls_huhdr_int_21-/sl0/assignmentid IS NOT INITIAL.
          " ----------------------------------------------
          " Picking up pallet on primary and secondary PUP
          " ----------------------------------------------
          IF ls_crane-assignmentid_rele IS NOT INITIAL OR ls_crane-assignmentid_frle IS NOT INITIAL.
            MESSAGE w110(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_11-huident ls_crane-rsrc
                                              ls_crane-assignmentid_rele
                                              ls_crane-assignmentid_frle.
            mo_log->add_message( iv_row = 0 ).
            CLEAR cs_tele_snd.
            finalize_logging( ).

            RETURN.
          ENDIF.
          IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = ls_huhdr_int_11-/sl0/assignmentid
                                                        iv_assignmentid_frle = ls_huhdr_int_21-/sl0/assignmentid
                                                        iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                        iv_fork              = cs_tele_snd-/sl0/fork
                                                        io_log               = mo_log ).
            CLEAR cs_tele_snd.

            "Set assignment failed, cannot send ARQ crane &1 asgnid &2 HU &3 step &4
            MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                              ls_huhdr_int_11-huident 101.
            mo_log->add_message( iv_row = 0 ).
            finalize_logging( ).

            RETURN.
          ENDIF.
        ELSE.
          " -------------------------------------
          " Picking up single HU from primary PUP
          " -------------------------------------
          IF ls_crane-assignmentid_rele IS NOT INITIAL.
            MESSAGE w109(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_11-huident ls_crane-rsrc
                                              ls_crane-assignmentid_rele.
            mo_log->add_message( iv_row = 0 ).
            CLEAR cs_tele_snd.
            finalize_logging( ).

            RETURN.
          ENDIF.

          IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = ls_huhdr_int_11-/sl0/assignmentid
                                                        iv_assignmenttype = cs_tele_snd-/sl0/assignmenttype
                                                        iv_fork           = cs_tele_snd-/sl0/fork
                                                        io_log            = mo_log ).
            CLEAR cs_tele_snd.

            "Set assignment failed, cannot send ARQ crane &1 asgnid &2 HU &3 step &4
            MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                              ls_huhdr_int_11-huident 102.
            mo_log->add_message( iv_row = 0 ).
            finalize_logging( ).

            RETURN.
          ENDIF.
        ENDIF.
      ELSE.
        " --------------------------------------------- "
        " HU is on a storage bin but not CP,
        " work out which fork to use.
        " --------------------------------------------- "
        IF ls_crane-two_forks = abap_false. "one fork
          IF ls_crane-assignmentid_rele IS INITIAL.
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = ls_huhdr_int_11-/sl0/assignmentid
                                                          iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork              = cs_tele_snd-/sl0/fork
                                                          io_log               = mo_log ).
              CLEAR cs_tele_snd.

              "Set assignment failed, cannot send ARQ crane &1 asgnid &2 HU &3 step &4
              MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 103.
              mo_log->add_message( iv_row = 0 ).

              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSE.
            "One fork and default fork has an assignment then we cannot send the message.
            MESSAGE w109(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_11-huident ls_crane-rsrc
                                              ls_crane-assignmentid_rele.
            mo_log->add_message( iv_row = 0 ).

            CLEAR cs_tele_snd.
            finalize_logging( ).

            RETURN.
          ENDIF.
        ELSE. "Two forks
          IF ls_crane-assignmentid_rele IS INITIAL.
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = ls_huhdr_int_11-/sl0/assignmentid
                                                          iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork              = cs_tele_snd-/sl0/fork
                                                          io_log               = mo_log ).
              CLEAR cs_tele_snd.

              "Set assignment failed, cannot send ARQ crane &1 asgnid &2 HU &3 step &4
              MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 104.
              mo_log->add_message( iv_row = 0 ).

              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSEIF ls_crane-assignmentid_frle IS INITIAL.
            cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_fr.
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_frle = ls_huhdr_int_11-/sl0/assignmentid
                                                          iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork              = cs_tele_snd-/sl0/fork
                                                          io_log               = mo_log ).
              CLEAR cs_tele_snd.

              "Set assignment failed, cannot send ARQ crane &1 asgnid &2 HU &3 step &4
              MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 105.
              mo_log->add_message( iv_row = 0 ).

              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSE.
            "Two forks and both have an assignment then we cannot send the message.
            MESSAGE w110(/sl0/mfs) INTO lv_msgtext WITH ls_huhdr_int_11-huident ls_crane-rsrc
                                              ls_crane-assignmentid_rele
                                              ls_crane-assignmentid_frle.
            mo_log->add_message( iv_row = 0 ).
            CLEAR cs_tele_snd.

            finalize_logging( ).

            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

    ELSEIF ms_ordim_o-srsrc IS NOT INITIAL.
      " -------------------------------
      " HU is on the resource i.e. fork
      " -------------------------------
      IF ms_ordim_o-nlpla IS NOT INITIAL.
        CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
          EXPORTING
            iv_lgnum = mv_lgnum
            iv_lgpla = ms_ordim_o-nlpla
          IMPORTING
            es_mfscp = ls_mfscp_1
          EXCEPTIONS
            error    = 1
            OTHERS   = 2.
        IF sy-subrc EQ 0.
          " --------------------------------------------- "
          " HU is on the fork and is supposed to go
          " to a DEP(-osit) position.
          " Forks with two HUs each are not supported yet.
          " --------------------------------------------- "
          IF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_rele.
            "Assignment is on the rear fork, left side, let's
            "see if there is an assignment on the front fork.
            IF ls_crane-assignmentid_frle IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_frle.
            ELSEIF ls_crane-assignmentid_frri IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_frri.
            ENDIF.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_reri.
            "Assignment is on the rear fork, right side, let's
            "see if there is an assignment on the front fork.
            IF ls_crane-assignmentid_frle IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_frle.
            ELSEIF ls_crane-assignmentid_frri IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_frri.
            ENDIF.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_frle.
            "Assignment is on the front fork, left side, let's
            "see if there is an assignment on the rear fork.
            IF ls_crane-assignmentid_rele IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_rele.
            ELSEIF ls_crane-assignmentid_reri IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_reri.
            ENDIF.
            "Tentatively set front fork, may change further on to both
            cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_fr.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_frri.
            "Assignment is on the front fork, right side, let's
            "see if there is an assignment on the rear fork.
            IF ls_crane-assignmentid_rele IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_rele.
            ELSEIF ls_crane-assignmentid_reri IS NOT INITIAL.
              lv_asgnid = ls_crane-assignmentid_reri.
            ENDIF.
            "Tentatively set front fork, may change further on to both
            cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_fr.
          ELSE.
            " ---------------------------------------------------
            " Assignment not found on the crane? shouldnt happen!
            " ---------------------------------------------------
            MESSAGE e136(/sl0/mfs) INTO lv_msgtext WITH cs_tele_snd-/sl0/assignmentid ls_crane-rsrc
                                              ls_huhdr_int_11-huident.
            mo_log->add_message( iv_row = 0 ).

            finalize_logging( ).

            CLEAR cs_tele_snd.
            RETURN.
          ENDIF.
          IF lv_asgnid IS NOT INITIAL.
            "We have another assignment, let's see if it is going
            "to a DEP(-osit) position too.
            " Get the WT for this HU
            lo_mfs_hu->to_read_hu_mfs( EXPORTING iv_assignmentid = lv_asgnid
                                       IMPORTING ev_to_type      = lv_to_type
                                                 ev_tanum_inact  = lv_tanum_inact
                                                 es_ordim_o      = ls_ordim_o
                                                 et_ordim_o      = lt_ordim_o[]
                                      EXCEPTIONS wrong_input    = 1
                                                 OTHERS         = 2 ).
            "Found a WT for the 'other' assignment.
            IF sy-subrc EQ 0.
              IF ls_ordim_o-tanum IS NOT INITIAL
                 AND ls_ordim_o-kzsub NE wmegc_kzsub_uebergeben.

                DATA(cv_same_dlv_and_door) = has_same_delivery_and_door(
                                               iv_huident_1 = ls_ordim_o-vlenr
                                               iv_huident_2 = ms_ordim_o-vlenr ).

                TRY.
                    IF ms_ordim_o-nlpla IN lo_crane->all_deposit_positions( ) AND
                       ls_ordim_o-nlpla IN lo_crane->all_deposit_positions( ) AND
                       cv_same_dlv_and_door EQ abap_true.
                      "---------------------------------------
                      " Deposit both HUs simultaneously on DEP
                      "---------------------------------------
                      IF cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_re.
                        "Telegram data is associated with rear fork
                        cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_bo.
                        IF NOT lo_crane->set_assignment_id(
                                            iv_assignmentid_rele = cs_tele_snd-/sl0/assignmentid
                                            iv_assignmentid_frle = lv_asgnid
                                            iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                            iv_fork              = cs_tele_snd-/sl0/fork
                                            io_log               = mo_log ).

                          CLEAR cs_tele_snd.

                          MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH
                            ls_crane-rsrc
                            cs_tele_snd-/sl0/assignmentid
                            cs_tele_snd-huident
                            106.

                          mo_log->add_message( iv_row = 0 ).

                          finalize_logging( ).

                          RETURN.
                        ENDIF.
                      ELSE.
                        "Telegram data is associated with front fork
                        cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_bo.
                        IF NOT lo_crane->set_assignment_id(
                                           iv_assignmentid_rele = lv_asgnid
                                           iv_assignmentid_frle = cs_tele_snd-/sl0/assignmentid
                                           iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                           iv_fork              = cs_tele_snd-/sl0/fork
                                           io_log               = mo_log ).

                          CLEAR cs_tele_snd.

                          MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH
                            ls_crane-rsrc
                            cs_tele_snd-/sl0/assignmentid
                            cs_tele_snd-huident
                            107.

                          mo_log->add_message( iv_row = 0 ).

                          finalize_logging( ).

                          RETURN.
                        ENDIF.
                      ENDIF.
                    ELSE.
                      "Different destinations
                      IF cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_re.
                        "Telegram is for rear fork
                        IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = cs_tele_snd-/sl0/assignmentid
                                                                      iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                                      iv_fork              = cs_tele_snd-/sl0/fork
                                                                      io_log               = mo_log ).
                          CLEAR cs_tele_snd.
                          MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc cs_tele_snd-/sl0/assignmentid
                                                            cs_tele_snd-huident 108.
                          mo_log->add_message( iv_row = 0 ).

                          finalize_logging( ).

                          RETURN.
                        ENDIF.
                      ELSE.
                        " Telegram is for front fork
                        "
                        " Since LOSC guides all pallets irrespective of which fork they are transported with
                        " via the primary deposition position. So we need to determine the correct DEP
                        " for the front fork here (i.e. we need SIS address for secondary DEP.

                        CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
                          EXPORTING
                            iv_lgnum  = mv_lgnum
                            iv_plc    = ls_crane-plc_dep_21 "conveyor plc
                            iv_cp     = ls_crane-cp_dep_21
                          IMPORTING
                            es_tmfscp = ls_tmfscp
                          EXCEPTIONS
                            error     = 1
                            OTHERS    = 2.

                        MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH | dest before:{ cs_tele_snd-dest }|.
                        mo_log->add_message( iv_row = 0 ).

                        cs_tele_snd-dest = lo_mfs_helper->ewmbin2sisaddr( iv_lgnum = mv_lgnum iv_plc = mv_plc iv_lgpla = ls_tmfscp-lgpla ).
                        MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |cp_dep21:{ ls_crane-cp_dep_21 } lgpla:{ ls_tmfscp-lgpla } dest:{ cs_tele_snd-dest }|.
                        mo_log->add_message( iv_row = 0 ).

                        MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |dest after:{ cs_tele_snd-dest }|.
                        mo_log->add_message( iv_row = 0 ).

                        IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_frle = cs_tele_snd-/sl0/assignmentid
                                                                      iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                                      iv_fork              = cs_tele_snd-/sl0/fork
                                                                      io_log               = mo_log ).

                          CLEAR cs_tele_snd.
                          MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc cs_tele_snd-/sl0/assignmentid
                                                            cs_tele_snd-huident 109.
                          mo_log->add_message( iv_row = 0 ).

                          finalize_logging( ).

                          RETURN.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  CATCH /scwm/cx_mfs INTO lx_mfs.
                    MESSAGE ID lx_mfs->if_t100_message~t100key-msgid
                            TYPE lx_mfs->mv_msgty
                            NUMBER lx_mfs->if_t100_message~t100key-msgno
                            WITH lx_mfs->mv_msgv1 lx_mfs->mv_msgv2
                                 lx_mfs->mv_msgv3 lx_mfs->mv_msgv4
                            INTO lv_msgtext.
                    mo_log->add_message( iv_row = 0 ).
                ENDTRY.
              ELSE.
                "Already sent
              ENDIF.
            ELSE.
              "No WT for 'assignment' that's bad, yes really bad
              "This can happen after serious fiddling with the crane when assignment data
              "is left on the crane but has no HUs associated. After such 'fiddling' the
              "user should always reset the crane data prior to restarting the crane but
              "experience has shown that this doesn't always happen.
              "Therefore we log the event and cancel the sending of the telegram.
              CLEAR cs_tele_snd.
              MESSAGE e322(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc cs_tele_snd-huident lv_asgnid.
              mo_log->add_message( iv_row = 0 ).
              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSE.
            IF cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_re.
              "Telegram is for rear fork
              IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_rele = cs_tele_snd-/sl0/assignmentid
                                                            iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                            iv_fork              = cs_tele_snd-/sl0/fork
                                                            io_log               = mo_log ).
                CLEAR cs_tele_snd.
                MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc cs_tele_snd-/sl0/assignmentid
                                                  cs_tele_snd-huident 110.
                mo_log->add_message( iv_row = 0 ).
                finalize_logging( ).

                RETURN.
              ENDIF.
            ELSE.
              " Telegram is for front fork
              "
              " Since LOSC guides all pallets irrespective of which fork they are transported with
              " via the primary deposition position. So we need to determine the correct DEP
              " for the front fork here (i.e. we need SIS address for secondary DEP.
              CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
                EXPORTING
                  iv_lgnum  = mv_lgnum
                  iv_plc    = ls_crane-plc_dep_21 "conveyor plc
                  iv_cp     = ls_crane-cp_dep_21
                IMPORTING
                  es_tmfscp = ls_tmfscp
                EXCEPTIONS
                  error     = 1
                  OTHERS    = 2.

              MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH | dest before:{ cs_tele_snd-dest }|.
              mo_log->add_message( iv_row = 0 ).

              cs_tele_snd-dest = lo_mfs_helper->ewmbin2sisaddr( iv_lgnum = mv_lgnum iv_plc = mv_plc iv_lgpla = ls_tmfscp-lgpla ).
              MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |cp_dep21:{ ls_crane-cp_dep_21 } lgpla:{ ls_tmfscp-lgpla } dest:{ cs_tele_snd-dest }|.
              mo_log->add_message( iv_row = 0 ).

              MESSAGE w000(/sl0/mfs) INTO lv_msgtext WITH |dest after:{ cs_tele_snd-dest }|.
              mo_log->add_message( iv_row = 0 ).

              IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmentid_frle = cs_tele_snd-/sl0/assignmentid
                                                            iv_assignmenttype    = cs_tele_snd-/sl0/assignmenttype
                                                            iv_fork              = cs_tele_snd-/sl0/fork
                                                            io_log               = mo_log ).
                CLEAR cs_tele_snd.
                MESSAGE e134(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc cs_tele_snd-/sl0/assignmentid
                                                  cs_tele_snd-huident 111.
                mo_log->add_message( iv_row = 0 ).
                finalize_logging( ).

                RETURN.
              ENDIF.
            ENDIF.
          ENDIF.


        ELSE.
          " ----------------------------------------- "
          " HU is on the fork, going to a storage bin
          " ----------------------------------------- "
          IF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_rele.
            "Rear fork
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmenttype = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork           = cs_tele_snd-/sl0/fork
                                                          io_log            = mo_log ).
              CLEAR cs_tele_snd.
              MESSAGE e135(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 112.
              mo_log->add_message( iv_row = 0 ).
              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_reri.
            "Rear fork
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmenttype = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork           = cs_tele_snd-/sl0/fork
                                                          io_log            = mo_log ).
              CLEAR cs_tele_snd.
              MESSAGE e135(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 113.
              mo_log->add_message( iv_row = 0 ).
              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_frle.
            "Front fork
            cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_fr.
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmenttype = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork           = cs_tele_snd-/sl0/fork
                                                          io_log            = mo_log ).
              CLEAR cs_tele_snd.
              MESSAGE e135(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 114.

              mo_log->add_message( iv_row = 0 ).

              finalize_logging( ).

              RETURN.
            ENDIF.
          ELSEIF cs_tele_snd-/sl0/assignmentid = ls_crane-assignmentid_frri.
            "Front fork
            cs_tele_snd-/sl0/fork = /sl0/if_c1_ewm_sp_c=>mc_fork_fr.
            IF NOT lo_crane->set_assignment_id( EXPORTING iv_assignmenttype = cs_tele_snd-/sl0/assignmenttype
                                                          iv_fork           = cs_tele_snd-/sl0/fork
                                                          io_log            = mo_log ).
              CLEAR cs_tele_snd.
              MESSAGE e135(/sl0/mfs) INTO lv_msgtext WITH ls_crane-rsrc ls_huhdr_int_11-/sl0/assignmentid
                                                ls_huhdr_int_11-huident 115.
              mo_log->add_message( iv_row = 0 ).
              finalize_logging( ).

              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    " --------------------------------------------- "
    " Speed, default HI
    " --------------------------------------------- "
    cs_tele_snd-/sl0/speed = /sl0/if_c1_ewm_sp_c=>mc_speed_hi.

    " --------------------------------------------- "
    " Forkside rear, default FU
    " --------------------------------------------- "
    cs_tele_snd-/sl0/forkside_rear = /sl0/if_c1_ewm_sp_c=>mc_forkside_fu.

    " --------------------------------------------- "
    " Forkside front, default FU
    " --------------------------------------------- "
    cs_tele_snd-/sl0/forkside_front = /sl0/if_c1_ewm_sp_c=>mc_forkside_fu.

    " -----------------------------------------------------------------
    " Note: it is not foreseen that we make changes to the HUHDR here.
    " The assignment ID and TU Type must have been set prior to the
    " HU being handled by the crane.
    " -----------------------------------------------------------------
    IF lv_changed_11 = abap_true.
      lv_subrc = update_huhdr(
          is_huhdr_int = ls_huhdr_int_11
          io_hu        = lo_hu ).

      IF lv_subrc IS NOT INITIAL.
        CLEAR cs_tele_snd.
      ENDIF.
    ENDIF.

    IF lv_changed_21 = abap_true.
      lv_subrc = update_huhdr(
                   is_huhdr_int = ls_huhdr_int_21
                   io_hu        = lo_hu ).

      IF lv_subrc IS NOT INITIAL.
        CLEAR cs_tele_snd.
      ENDIF.
    ENDIF.


    " Log end of FM processing..
    finalize_logging( ).
  ENDMETHOD.


  METHOD update_huhdr.
    DATA:lv_msgtext   TYPE bapi_msg,
         lv_count     TYPE sytabix,
         ls_huhdr_ret TYPE /scwm/s_huhdr_int.

    DO 100 TIMES.
      CALL FUNCTION 'ENQUEUE_/SCWM/EHU'
        EXPORTING
          mode_/scwm/s_huhdr_int = 'E'
          mandt                  = is_huhdr_int-mandt
          huident                = is_huhdr_int-huident
          lgnum                  = is_huhdr_int-lgnum
          _scope                 = 2
          _wait                  = abap_false
        EXCEPTIONS
          foreign_lock           = 1
          system_failure         = 2
          OTHERS                 = 3.

      rv_subrc = sy-subrc.

      CHECK rv_subrc IS INITIAL.

      CLEAR : ls_huhdr_ret.
      " Change the HU Header to update it with the Assignment ID generated..
      CALL METHOD io_hu->/scwm/if_pack_bas~change_huhdr
        EXPORTING
          is_huhdr   = is_huhdr_int
        IMPORTING
          es_huhdr   = ls_huhdr_ret
        EXCEPTIONS
          error      = 1
          not_locked = 2
          OTHERS     = 3.

      rv_subrc = sy-subrc.

      IF rv_subrc IS INITIAL.
        " Save the changes made to HU header data..
        CALL METHOD io_hu->/scwm/if_pack_bas~save
          EXPORTING
            iv_commit = ' '
            iv_wait   = ' '
          EXCEPTIONS
            error     = 1
            OTHERS    = 2.
        rv_subrc = sy-subrc.

        IF rv_subrc = 0.
          "HU &1 updated with Assignment ID &2
          MESSAGE s017(/sl0/mfs) INTO lv_msgtext
                       WITH is_huhdr_int-huident
                            is_huhdr_int-/sl0/assignmentid.
          mo_log->add_message( iv_row = 0 ).
        ELSE.
          "Error saving HU Header Data
          MESSAGE e016(/sl0/mfs) INTO lv_msgtext.
          mo_log->add_message( iv_row = 0 ).
        ENDIF.

        EXIT.
      ENDIF.

      lv_count = lv_count + 1.
      " Error occurred..try again
    ENDDO.

    IF rv_subrc IS NOT INITIAL.
      "Error changing HU Header Data
      MESSAGE e015(/sl0/mfs) INTO lv_msgtext.
      mo_log->add_message( iv_row = 0 ).
    ENDIF.

    IF lv_count IS NOT INITIAL.
      "HU locked for & times
      MESSAGE e028(/sl0/mfs) INTO lv_msgtext WITH lv_count.
      mo_log->add_message( iv_row = 0 ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
