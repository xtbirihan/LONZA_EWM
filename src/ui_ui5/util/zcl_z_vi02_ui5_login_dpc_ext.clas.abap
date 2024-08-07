CLASS zcl_z_vi02_ui5_login_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_z_vi02_ui5_login_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.


    DATA gs_logoff TYPE zcl_z_vi02_ui5_login_mpc=>ts_logoff .

    METHODS logoff_from_workstation
      IMPORTING
        !io_data_provider TYPE REF TO /iwbep/if_mgw_entry_provider
      RETURNING
        VALUE(rs_entity)  TYPE REF TO data
      RAISING
        /iwbep/cx_mgw_tech_exception
        /iwbep/cx_mgw_busi_exception .

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_entity
        REDEFINITION .

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entity
        REDEFINITION .

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS execute_logoff
      RAISING
        /iwbep/cx_mgw_tech_exception
        /iwbep/cx_mgw_busi_exception .

    METHODS get_entity_input_data
      IMPORTING
        !it_key_tab      TYPE /iwbep/t_mgw_name_value_pair
      RETURNING
        VALUE(rs_result) TYPE zcl_z_vi02_ui5_login_mpc=>ts_logon
      RAISING
        /iwbep/cx_mgw_tech_exception .
ENDCLASS.



CLASS ZCL_Z_VI02_UI5_LOGIN_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_entity.


    CLEAR: er_entity.
    TRY.
        er_entity = logoff_from_workstation( io_data_provider = io_data_provider ).
      CATCH  /iwbep/cx_mgw_tech_exception.
      CATCH  /iwbep/cx_mgw_busi_exception.
        DATA(lo_container) = mo_context->get_message_container( ).
        lo_container->add_message( iv_msg_type               = sy-msgty
                                   iv_msg_id                 = sy-msgid
                                   iv_msg_number             = sy-msgno
                                   iv_msg_v1                 = sy-msgv1
                                   iv_msg_v2                 = sy-msgv2
                                   iv_msg_v3                 = sy-msgv3
                                   iv_msg_v4                 = sy-msgv4
                                   iv_add_to_response_header = abap_true ).
    ENDTRY.


  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entity.

    DATA: ls_logon TYPE ZCL_Z_VI02_UI5_LOGIN_MPC=>ts_logon.
    " ------------------------------------------ "
    "  Processing Logic..
    " ------------------------------------------ "
    TRY.
        CASE iv_entity_name.
          WHEN ZCL_Z_VI02_UI5_LOGIN_MPC=>gc_logon.
            ls_logon = get_entity_input_data( it_key_tab = it_key_tab ).

        ENDCASE.

        copy_data_to_ref( EXPORTING is_data = ls_logon
                          CHANGING  cr_data = er_entity ).
      CATCH /iwbep/cx_mgw_tech_exception.
        DATA(lo_container) = mo_context->get_message_container( ).
        lo_container->add_message( iv_msg_type    = sy-msgty
                                   iv_msg_id      = sy-msgid
                                   iv_msg_number  = sy-msgno
                                   iv_msg_v1      = sy-msgv1
                                   iv_msg_v2      = sy-msgv2
                                   iv_msg_v3      = sy-msgv3
                                   iv_msg_v4      = sy-msgv4
                                   iv_add_to_response_header = abap_true ).
    ENDTRY.
  ENDMETHOD.


  METHOD execute_logoff.
    DATA: ls_t300    TYPE /scwm/s_t300,
          ls_result  TYPE zcl_z_vi02_ui5_login_mpc=>ts_logon,
          lv_msg     TYPE string,
          lo_ws      TYPE REF TO /sl0/cl_workstation,
          lv_huident TYPE /scwm/de_huident.

    TRY.
        CREATE OBJECT lo_ws
          EXPORTING
            iv_lgnum       = gs_logoff-lgnum
            iv_workstation = gs_logoff-workstation
            iv_lock        = abap_false.

        IF lo_ws IS BOUND.
          IF lo_ws->get_data( )-active = abap_true AND lo_ws->get_data( )-last_login_user = sy-uname ##USER_OK.
            lo_ws->deactivate( ).
          ENDIF.
        ENDIF.
      CATCH /sl0/cx_general_exception INTO DATA(lo_exc).
    ENDTRY.

  ENDMETHOD.


 METHOD get_entity_input_data.
   CONSTANTS: lc_tab_lgnum_name TYPE string VALUE '/SCWM/T300',
              lc_tab_works_name TYPE string VALUE 'sl0/T_WORKS'.
   DATA: ls_t300   TYPE /scwm/s_t300,
         ls_result TYPE zcl_z_vi02_ui5_login_mpc=>ts_logon,
         lv_msg    TYPE string.
   " ------------------------------------------ "
   "  Processing Logic..
   " ------------------------------------------ "
   LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
     CASE <ls_key>-name.
       WHEN 'LGNUM'.
         ls_result-lgnum = <ls_key>-value.

       WHEN 'WORKSTATION'.
         ls_result-workstation = <ls_key>-value.
       WHEN 'WS_MODE'.
         ls_result-ws_mode = <ls_key>-value.

     ENDCASE.
   ENDLOOP.

   " determine entered workstation
   TRY.
       DATA(lo_workstation) = /sl0/cl_workstation=>read_workstation( EXPORTING iv_workstation = ls_result-workstation ).

       DATA(ls_works) = lo_workstation->get_data( ).

     CATCH /sl0/cx_general_exception.

   ENDTRY.


   IF ls_works IS INITIAL OR ls_works-lgnum IS INITIAL.
     MESSAGE e009(33) WITH ls_result-workstation lc_tab_works_name INTO lv_msg.
*      RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception( ).
     RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
   ENDIF.

   IF lo_workstation IS BOUND.
     lo_workstation->set_ws_mode( CONV #( ls_result-ws_mode ) ).


     IF lo_workstation->get_data( )-active = abap_true             AND
        lo_workstation->get_data( )-last_login_user IS NOT INITIAL AND
        lo_workstation->get_data( )-last_login_user <> sy-uname.

       "Workstation already in use!
       MESSAGE e013(/sl0/ws) WITH lo_workstation->get_data( )-last_login_user INTO /sl0/cl_log=>m_dummy_msg.
*          RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception( ).
       RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.

     ELSE.
       lo_workstation->activate( ).
     ENDIF.

   ENDIF.

   CALL FUNCTION '/SCWM/T300_READ_SINGLE'
     EXPORTING
       iv_lgnum  = ls_works-lgnum
     IMPORTING
       es_t300   = ls_t300
     EXCEPTIONS
       not_found = 1
       OTHERS    = 2.
   IF sy-subrc <> 0 OR ls_t300-lgnum IS INITIAL.
     ##NEEDED
     MESSAGE e009(33) WITH ls_works-lgnum lc_tab_lgnum_name INTO lv_msg.
*      RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception( ).
     RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
   ENDIF.

   rs_result-lgnum = ls_works-lgnum.
   rs_result-workstation = ls_works-workstation.
   rs_result-ws_mode = lo_workstation->get_ws_mode( ).

 ENDMETHOD.


  METHOD logoff_from_workstation.
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = gs_logoff ).

    execute_logoff( ).

    copy_data_to_ref( EXPORTING is_data = gs_logoff CHANGING cr_data = rs_entity ).
  ENDMETHOD.
ENDCLASS.
