*&---------------------------------------------------------------------*
*& Include          Z_VI02_MON_SAMPLING_I_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_sampling IMPLEMENTATION.
  METHOD initialization.
    REFRESH ct_data.
    CALL FUNCTION '/SCWM/DYNPRO_ELEMENTS_CLEAR'
      EXPORTING
        iv_repid = iv_repid.
  ENDMETHOD.
  METHOD create_mapping.

    DATA: ls_mapping  TYPE /scwm/s_map_selopt2field.

    MOVE: '/SCWM/LAGP'      TO ls_mapping-tablename,
          'S_LGPLA'         TO ls_mapping-selname,
          'LGPLA'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: 'S_LGTYP'         TO ls_mapping-selname,
          'LGTYP'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_LGBER'         TO ls_mapping-selname,
          'LGBER'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_LPTYP'         TO ls_mapping-selname,
          'LPTYP'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_KZLER'         TO ls_mapping-selname,
          'KZLER'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_AISLE'         TO ls_mapping-selname,
          'AISLE'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_STACK'         TO ls_mapping-selname,
          'STACK'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_LEVEL'         TO ls_mapping-selname,
          'LVL_V'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_BINSC'         TO ls_mapping-selname,
          'BINSC'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_DEPTH'         TO ls_mapping-selname,
          'DEPTH'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: 'S_PSA'           TO ls_mapping-selname,
          'PSA'             TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: '/SCWM/RSRC'      TO ls_mapping-tablename,
          'S_RSRC'          TO ls_mapping-selname,
          'RSRC'            TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: '/SCWM/TUNIT'     TO ls_mapping-tablename,
          'S_TUEXT'         TO ls_mapping-selname,
          'TU_NUM_EXT'      TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    MOVE: '/SCWM/TUNIT'     TO ls_mapping-tablename,
          'S_TSP'           TO ls_mapping-selname,
          'TSP'             TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.

    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_MATID'         TO ls_mapping-selname,
          'MATID'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_MATNR'         TO ls_mapping-selname,
          'MATNR'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_ENTIT'         TO ls_mapping-selname,
          'ENTITLED'        TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_OWNER'         TO ls_mapping-selname,
          'OWNER'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_STCAT'         TO ls_mapping-selname,
          'CAT'             TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/QUAN'      TO ls_mapping-tablename,
          'S_STOID'         TO ls_mapping-selname,
          'STOID'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_BATCH'         TO ls_mapping-selname,
          'CHARG'           TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'S_STKSEG'        TO ls_mapping-selname,
          'STK_SEG_LONG'    TO ls_mapping-fieldname,
          'X'               TO ls_mapping-is_key.
    APPEND ls_mapping       TO ct_mapping.


    MOVE: '/SCWM/AQUA'        TO ls_mapping-tablename,
          'S_HUIDEN'          TO ls_mapping-selname,
          'HUIDENT'           TO ls_mapping-fieldname,
          'X'                 TO ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_HUTYP'           TO ls_mapping-selname,
          'LETYP'             TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_P_MAT'           TO ls_mapping-selname,
          'PMAT_GUID'         TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_PMTYP'           TO ls_mapping-selname,
          'PMTYP'             TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/SERH'        TO ls_mapping-tablename,
          'S_SERID'           TO ls_mapping-selname,
          'LSERID'            TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/SERI'        TO ls_mapping-tablename,
          'S_UII'             TO ls_mapping-selname,
          'UII'               TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'P_SSTAT'           TO ls_mapping-selname,
          'SYSTEM_STATUS'     TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'P_USTAT'           TO ls_mapping-selname,
          'USER_STATUS'       TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'P_EMPTY'           TO ls_mapping-selname,
          'EMPTY'             TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_IDART'           TO ls_mapping-selname,
          'IDART'             TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_IDENT'           TO ls_mapping-selname,
          'IDENT'             TO ls_mapping-fieldname.
    APPEND ls_mapping         TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_PSID'            TO ls_mapping-selname,
          'PSID'              TO ls_mapping-fieldname.
    APPEND ls_mapping         TO ct_mapping.
    CLEAR ls_mapping-is_key.
    MOVE: '/SCWM/HUHDR'       TO ls_mapping-tablename,
          'S_PIID'            TO ls_mapping-selname,
          'PIID'              TO ls_mapping-fieldname.
    APPEND ls_mapping         TO ct_mapping.
    CLEAR ls_mapping-is_key.

    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'P_LGPLA'         TO ls_mapping-selname,
          'X_BIN'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.

    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'P_RSRC'          TO ls_mapping-selname,
          'X_RESOURCE'      TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.

    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'P_TU'            TO ls_mapping-selname,
          'X_TU'            TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.

    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'P_DIFF'          TO ls_mapping-selname,
          'X_DIFF'          TO ls_mapping-fieldname.

    APPEND ls_mapping       TO ct_mapping.
    MOVE: '/SCWM/AQUA'      TO ls_mapping-tablename,
          'P_LGNM'          TO ls_mapping-selname,
          'LGNUM'           TO ls_mapping-fieldname.
    APPEND ls_mapping       TO ct_mapping.


    MOVE: '/SCWM/WIPMAP'       TO ls_mapping-tablename,
          'S_WIP_NO'           TO ls_mapping-selname,
          'WIP_NO'         TO ls_mapping-fieldname.
    CLEAR ls_mapping-is_key.
    APPEND ls_mapping         TO ct_mapping.

  ENDMETHOD.
  METHOD create_alv.
    DATA: ls_layout            TYPE lvc_s_layo,

          lt_fieldcat          TYPE lvc_t_fcat,
          lt_toolbar_excluding TYPE ui_functions,
          lt_items             TYPE /scwm/tt_lime_all_mon,

          lv_container         TYPE scrfname VALUE 'ALV_CONTAINER'.

    CLEAR:
      go_call_off,
      go_call_cont.

    go_call_cont = NEW #( container_name = lv_container ).
    go_call_off = NEW #( i_parent = go_call_cont ).

    ls_layout-zebra      = abap_true.
    ls_layout-smalltitle = abap_true.
    ls_layout-numc_total = abap_true.
    ls_layout-cwidth_opt = abap_true.
    ls_layout-grid_title = TEXT-001.
    ls_layout-sel_mode   = 'A'.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = '/SCWM/S_LIME_ALL_MON'
      CHANGING
        ct_fieldcat            = lt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
      CASE <ls_fieldcat>-fieldname.
        WHEN OTHERS.
          <ls_fieldcat>-no_out = abap_true.
      ENDCASE.
    ENDLOOP.

*** exclude table for toolbar ***
    APPEND cl_gui_alv_grid=>mc_fc_graph   TO lt_toolbar_excluding.
    APPEND cl_gui_alv_grid=>mc_fc_info    TO lt_toolbar_excluding.

*    SET HANDLER me->handle_user_command_dlv FOR go_call_off.
*    SET HANDLER me->handle_toolbar_refresh FOR go_call_off.

    CALL METHOD go_call_off->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = ls_layout
        is_variant           = VALUE #( report = sy-repid )
        it_toolbar_excluding = lt_toolbar_excluding
      CHANGING
        it_outtab            = lt_items
        it_fieldcatalog      = lt_fieldcat.

  ENDMETHOD.
ENDCLASS.
