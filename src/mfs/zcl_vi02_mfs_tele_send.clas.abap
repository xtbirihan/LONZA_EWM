CLASS zcl_vi02_mfs_tele_send DEFINITION
  PUBLIC
  INHERITING FROM /sl0/cl_mfs_send_tele_q
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: map_telegram_data REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VI02_MFS_TELE_SEND IMPLEMENTATION.


  METHOD map_telegram_data.
    " ------------------------------------------ "
    "  Local Declarations..
    " ------------------------------------------ "

    DATA : lv_asgnid     TYPE /sl0/de_assignmentid,
           lv_plciftype  TYPE /scwm/de_mfsplc_iftype,
           lv_teletotal  TYPE strukname,
           ls_tutypemap  TYPE /sl0/t_tutypemap,
           ls_swl_mfscp  TYPE /sl0/t_mfscp,
           ls_swl_mfsplc TYPE /sl0/t_mfsplc,
           lv_cp         TYPE /scwm/de_mfscp,
           lv_tabname    TYPE ddobjname,
           lt_str_fields TYPE STANDARD TABLE OF dfies,
           ls_str_fields TYPE dfies,
           lv_changed    TYPE abap_bool,
           lv_message    TYPE string,                       "#EC NEEDED
           ls_huhdr_int  TYPE /scwm/s_huhdr_int,
           lv_task       TYPE char32,
           ls_huhdr_ret  TYPE /scwm/s_huhdr_int,            "#EC NEEDED
           lo_pack       TYPE REF TO /scwm/cl_wm_packing,
           lv_count      TYPE sytabix,
           lv_subrc      TYPE sysubrc,
           lo_mfs_helper TYPE REF TO /sl0/cl_mfs_process_helper,
           lo_mfs_hu     TYPE REF TO /sl0/cl_mfs_hu.

    " ------------------------------------------ "
    "  Initialization
    " ------------------------------------------ "
*| Instantiate helper object to select and process data..
    lo_mfs_helper = NEW /sl0/cl_mfs_process_helper( ).

    /scwm/cl_tm=>cleanup( EXPORTING iv_lgnum = mv_lgnum ).

*| Create HU Instance
    lo_mfs_hu = NEW /sl0/cl_mfs_hu( iv_lgnum        = mv_lgnum
                                    iv_assignmentid = cs_tele_snd-/sl0/assignmentid
                                    iv_huident      = cs_tele_snd-huident ).

    " ------------------------------------------ "
    "  Import Parameter
    " ------------------------------------------ "
    CLEAR: lv_subrc.

    IF mv_lgnum   IS INITIAL.
      MESSAGE i110(/sl0/ca) INTO lv_message
         WITH lv_plciftype mv_lgnum mv_plc lv_subrc.
      mo_log->add_message( iv_row = 0 ).
      lv_subrc = 1.
    ENDIF.

    IF mv_plc     IS INITIAL OR
       mv_channel IS INITIAL.
      MESSAGE i296(/sl0/mfs) INTO lv_message
         WITH lv_plciftype mv_lgnum mv_plc lv_subrc.
      mo_log->add_message( iv_row = 0 ).
      lv_subrc = 2.
    ENDIF.

    IF lv_subrc IS NOT INITIAL.
      finalize_logging( ).
      RETURN.
    ENDIF.

    " ------------------------------------------ "
    "  Read PLC Interface Type
    " ------------------------------------------ "
*| Read PLC Interface Type
    lo_mfs_helper->read_plc_if_type( EXPORTING iv_lgnum     = mv_lgnum
                                               iv_plc       = mv_plc
                                     IMPORTING ev_plciftype = lv_plciftype
                                               ev_rc        = lv_subrc ).

*| PLC Interface Type could (not) be determined..
    IF lv_plciftype IS INITIAL.
      "PLC Interface Type could not be determined.
      MESSAGE e006(/sl0/mfs) INTO lv_message.
      mo_log->add_message( iv_row = 0 ).

      finalize_logging( ).
      RETURN.
    ELSE.
      "Determined interface type &1 for lgnum &2 plc &3 and rc &4
      MESSAGE i119(/sl0/mfs) INTO lv_message.
      mo_log->add_message( iv_row = 0 ).
    ENDIF.

    " ------------------------------------------ "
    "  Processing External ARQ Logic..
    " ------------------------------------------ "
* Crane processing logic migrated into zcl_vi02_mfs_tele_send_crane, see table /sl0/t_mfsconfig

    " ------------------------------------------ "
    "  Read Swisslog customizing for CP
    " ------------------------------------------ "
    IF cs_tele_snd-source IS NOT INITIAL.
      "Source is already in SIS notation we need to convert to an EWM object.

      lv_cp = lo_mfs_helper->sisaddr2ewmbin( iv_lgnum      = mv_lgnum
                                             iv_plc        = mv_plc
                                             iv_sisaddress = cs_tele_snd-source
                                             iv_objtype    = wmegc_mfs_ewm_obj_cp ).

*|  Read swisslog customizing for Communication Point
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
*|        log error but carry on anyway...
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                              INTO lv_message.
          mo_log->add_message( iv_row = 0 ).
        ENDIF.
      ENDIF.
    ENDIF.

    " ------------------------------------------ "
    "  Read Swisslog customizing for PLC
    " ------------------------------------------ "
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

    IF sy-subrc IS NOT INITIAL.
*|  log error but carry on anyway...
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          INTO lv_message.
      mo_log->add_message( iv_row = 0 ).
    ENDIF.

*| Get the TELETOTAL Structure configured for the telegram type..
    SELECT SINGLE teletotal
      FROM /scwm/tmfsteltoi
      INTO lv_teletotal
     WHERE lgnum     = mv_lgnum
       AND plciftype = lv_plciftype
       AND teletype  = cs_tele_snd-teletype.

    IF sy-subrc     IS INITIAL AND
       lv_teletotal IS NOT INITIAL.

      lv_tabname = lv_teletotal.

*|  Get the fieldlist of the configured structure..
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lv_tabname
        TABLES
          dfies_tab      = lt_str_fields[]
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc NE 0.
        CLEAR lt_str_fields[].
      ENDIF.

*|  Validating the Telegram type to execute the relevant processing logic..
      CASE cs_tele_snd-teletype.
          " -------------------- "
          "       ARQ / AMQ      "
          " -------------------- "
        WHEN /sl0/if_c1_ewm_sp_c=>mc_telegram_arq OR /sl0/if_c1_ewm_sp_c=>mc_telegram_amq.

          FREE lo_pack.
          CLEAR lv_count.

*|      Generate instance only if not already done..
          lo_pack = NEW /scwm/cl_wm_packing( ).

*        IF lo_pack IS BOUND.
**|      Read HU Header Data..
          lo_pack->/scwm/if_pack_bas~huheader_read( EXPORTING iv_huident  = cs_tele_snd-huident
                                                    IMPORTING es_huheader = ls_huhdr_int
                                                   EXCEPTIONS not_found   = 1
                                                              input       = 2
                                                              error       = 3
                                                              deleted     = 4
                                                              OTHERS      = 5 ).
          IF sy-subrc IS INITIAL.
            IF ls_huhdr_int-db_lock IS NOT INITIAL.
              lv_count = lv_count + 1.
              MESSAGE i028(/sl0/mfs) INTO lv_message
                           WITH lv_count.
              mo_log->add_message( iv_row = 0 ).
            ENDIF.

*|        HU Header Data read..
            CLEAR lv_changed.
            LOOP AT lt_str_fields[] INTO ls_str_fields  "#EC CI_CONV_OK
                                    WHERE fieldname IS NOT INITIAL.
*|          Process fieldlist..
              CASE ls_str_fields-fieldname.
                WHEN '/SL0/ASSIGNMENTID'.
                  IF ls_huhdr_int-/sl0/assignmentid IS INITIAL.
                    MESSAGE i087(/sl0/mfs) INTO lv_message WITH ls_huhdr_int-huident.
                    mo_log->add_message( iv_row = 0 ).

                    lv_asgnid = get_assignment_id( ls_huhdr_int-huident ).

                    IF lv_asgnid IS NOT INITIAL.
                      lv_changed = abap_true.
                      ls_huhdr_int-/sl0/assignmentid = lv_asgnid.
                    ENDIF.
                  ENDIF.
*|              Set Assignment ID in telegram.
                  cs_tele_snd-/sl0/assignmentid = ls_huhdr_int-/sl0/assignmentid.

                WHEN '/SL0/TUTYPE'.
                  "TU Type determination based on Swisslog CP customizing
                  IF ls_swl_mfscp-tutype_det = abap_true.
                    TRY.
                        CLEAR ls_tutypemap-/sl0/tutype.
                        CALL FUNCTION ls_swl_mfscp-tutype_det_fm
                          EXPORTING
                            is_swl_mfscp = ls_swl_mfscp
                            is_telegram  = cs_tele_snd
                            iv_huident   = ls_huhdr_int-huident
                            io_log       = mo_log
                          IMPORTING
                            ev_tutype    = ls_tutypemap-/sl0/tutype
                          EXCEPTIONS
                            OTHERS       = 99.

                        IF sy-subrc IS INITIAL
                           AND ls_tutypemap-/sl0/tutype IS NOT INITIAL
                           AND ls_huhdr_int-/sl0/tutype NE ls_tutypemap-/sl0/tutype.

*|                        Change is only required if a different SIS TUType was determined
                          cs_tele_snd-/sl0/tutype = ls_huhdr_int-/sl0/tutype = ls_tutypemap-/sl0/tutype.
                          lv_changed = abap_true.
                        ENDIF.
                      CATCH cx_sy_dyn_call_illegal_func.
                        MESSAGE e078(/sl0/mfs) INTO lv_message
                                     WITH ls_swl_mfscp-cp
                                          ls_swl_mfscp-tutype_det_fm.
                        mo_log->add_message( iv_row = 0 ).
                    ENDTRY.
                  ENDIF.
                WHEN '/SL0/TUIDPRESENT'.
                  IF cs_tele_snd-huident IS INITIAL.
                    cs_tele_snd-/sl0/tuidpresent = 0.
                  ELSE.
                    cs_tele_snd-/sl0/tuidpresent = 1.
                  ENDIF.

                WHEN '/SL0/TUID'.
                  IF cs_tele_snd-huident IS NOT INITIAL.
                    CALL FUNCTION 'CONVERSION_EXIT_HUID_OUTPUT'
                      EXPORTING
                        input  = cs_tele_snd-huident
                      IMPORTING
                        output = cs_tele_snd-/sl0/tuid.
                  ENDIF.

                  "Padding and alignment
                  IF ls_swl_mfsplc-tuid_padchar_ri IS NOT INITIAL AND ls_swl_mfsplc-tuid_padchar_ri NE space.
                    "Right padding required? Padding character cannot be a blank
                    cs_tele_snd-/sl0/tuid = |{ cs_tele_snd-/sl0/tuid WIDTH = 18 ALIGN = LEFT PAD = ls_swl_mfsplc-tuid_padchar_ri }|.
                  ELSE.
                    "No right padding, then align right and pad with spaces
                    cs_tele_snd-/sl0/tuid = |{ cs_tele_snd-/sl0/tuid WIDTH = 18 ALIGN = RIGHT PAD = space }|.
                  ENDIF.
                WHEN '/SL0/IODATA'.
                  IF ls_swl_mfscp-iodata_in_arq = abap_true.
                    cs_tele_snd-/sl0/iodata = ls_huhdr_int-/sl0/iodata.

                  ELSEIF lv_plciftype = /sl0/if_c1_ewm_sp_c=>mc_plcifty_m.
*|                IO data is always relevant for monorail
                    cs_tele_snd-/sl0/iodata = ls_huhdr_int-/sl0/iodata.
                  ELSE.
                    cs_tele_snd-/sl0/iodata = 0.
                  ENDIF.

                WHEN OTHERS.
                  " No action..
              ENDCASE.
            ENDLOOP.
            " Apply changes to HU Header only when made..
            IF lv_changed = abap_true.
              CLEAR lv_count.
              DO 100 TIMES.
                CLEAR : ls_huhdr_ret,
                        lv_message.
                " Change the HU Header to update it with the Assignment ID generated..
                lo_pack->/scwm/if_pack_bas~change_huhdr( EXPORTING is_huhdr   = ls_huhdr_int
                                                         IMPORTING es_huhdr   = ls_huhdr_ret
                                                        EXCEPTIONS error      = 1
                                                                   not_locked = 2
                                                                   OTHERS     = 3 ).
                IF sy-subrc = 0.
                  " Save the changes made to HU header data..
                  lo_pack->/scwm/if_pack_bas~save( EXPORTING iv_commit = ' '
                                                             iv_wait   = ' '
                                                  EXCEPTIONS error     = 1
                                                             OTHERS    = 2 ).
                  IF sy-subrc = 0.
                    " HU Header data was successfully updated..
                    MESSAGE s017(/sl0/mfs) INTO lv_message
                                 WITH cs_tele_snd-huident
                                      cs_tele_snd-/sl0/assignmentid.
                    mo_log->add_message( iv_row = 0 ).
                  ELSE.
                    " Error occurred..implement suitable error handling here
                    IF mo_log IS BOUND.
                      MESSAGE e016(/sl0/mfs) INTO lv_message.
                      mo_log->add_message( iv_row = 0 ).
*|                  Add protocol of faild save to application log for more details
                      IF lo_pack->go_log IS BOUND.
                        mo_log->add_log( io_ewm_log = lo_pack->go_log ).
                      ENDIF.
                    ENDIF.
                  ENDIF.
                  EXIT.
                ELSE.
                  "Could not lock then go and updated asynchronously.
                  MESSAGE i397(/sl0/mfs) INTO lv_message "Trigger async. update of HU[&1] Ass.Id[&2] TUType[&3]
                                         WITH ls_huhdr_int-huident
                                              ls_huhdr_int-/sl0/assignmentid
                                              ls_huhdr_int-/sl0/tutype.
                  mo_log->add_message( iv_row = 0 ).
                  lv_task = |HU{ mv_plc }{ ls_huhdr_int-huident }|.
                  CALL FUNCTION '/SL0/MFS_TELE_SEND_UPDHUHDR'
                    STARTING NEW TASK lv_task
                    EXPORTING
                      iv_lgnum    = mv_lgnum
                      iv_plc      = mv_plc
                      is_huhdr    = ls_huhdr_int
                      is_telegram = cs_tele_snd.
                  EXIT. "exit loop.
                ENDIF.
              ENDDO.
            ENDIF.
          ELSE.
            " Error occurred..implement suitable error handling here
            MESSAGE e014(/sl0/mfs) INTO lv_message.
            IF mo_log IS BOUND.
              mo_log->add_message( iv_row = 0 ).
            ENDIF.
          ENDIF.

*|      Note: Reset occupied flag of HOP tabel to avoid overtaking POR(1)
          TRY.
              DATA(lo_hop) = NEW /sl0/cl_hop( iv_lgnum          = mv_lgnum
                                              iv_plc            = mv_plc
                                              iv_channel        = mv_channel
                                              iv_lgpla          = lv_cp
                                              iv_retry_interval = 0
                                              io_log            = mo_log ).
            CATCH /scwm/cx_mfs.
*|          Error: No relevant entry found in HOP table &1
              MESSAGE i050(/sl0/mfs) WITH lv_cp INTO lv_message.
              mo_log->add_message( iv_row = 0 ).

              FREE lo_hop.
          ENDTRY.

          TRY.
              IF /sl0/cl_param_select=>read_const( iv_lgnum      = mv_lgnum
                                                   iv_param_prof = /sl0/cl_param_c=>c_prof_mfs_gen
                                                   iv_context    = /sl0/cl_param_c=>c_context_monorail
                                                   iv_parameter  = /sl0/cl_param_c=>c_param_rtry_hu_not_on_troll ) NE abap_true.
                "In simulated environment we dont want the monorail dep to be cleared.
                IF lo_hop IS BOUND.
                  IF lo_hop->hop( )-hop_type EQ /sl0/cl_hop=>mc_dep_mo.
                    lo_hop->lock( iv_occupied = abap_false ).
                    lo_hop->update( iv_occupied = abap_false ).
                  ENDIF.
                ENDIF.
              ENDIF.
            CATCH /scwm/cx_mfs.
*|          No special error handling
              mo_log->add_message( iv_row = 0 ).
          ENDTRY.

          FREE lo_hop.

        WHEN /sl0/if_c1_ewm_sp_c=>mc_telegram_dum.
          CLEAR: cs_tele_snd-handshake.
        WHEN OTHERS.
          " No action..
      ENDCASE.
    ELSE.
      " Telegram Str. for PLC I/F Type could not be determined..
      MESSAGE e027(/sl0/mfs) INTO lv_message.
      mo_log->add_message( iv_row = 0 ).
    ENDIF.


*|  Finalize logging
    finalize_logging( ).

  ENDMETHOD.
ENDCLASS.
