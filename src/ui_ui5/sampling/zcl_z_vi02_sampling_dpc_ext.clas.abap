class ZCL_Z_VI02_SAMPLING_DPC_EXT definition
  public
  inheriting from ZCL_Z_VI02_SAMPLING_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
    redefinition .
protected section.

  methods HUITEMQUANTITYSE_GET_ENTITYSET
    redefinition .
  methods HUITEMSET_GET_ENTITYSET
    redefinition .
  methods HUWAREHOUSETASKS_CREATE_ENTITY
    redefinition .
  methods PRODUCTUNITOFMEA_GET_ENTITYSET
    redefinition .
  methods HUWAREHOUSETASKS_GET_ENTITY
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_Z_VI02_SAMPLING_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA:
      ls_s_t300t                 TYPE /scwm/s_t300t,
      ls_whn_workstation_profile TYPE zzs_vi02_warehouse_workstation,
      lt_return                  TYPE STANDARD TABLE OF bapiret2,
      lv_lgnum                   TYPE  /scwm/lgnum,
      lv_workstation             TYPE  /scwm/de_workstation.

    CASE iv_action_name.
      WHEN 'GetUserDefaultWarehouse'.
        CALL FUNCTION 'Z_VI02_GET_USER_DEFAULT'
          IMPORTING
            es_s_t300t = ls_s_t300t.

        copy_data_to_ref(
          EXPORTING
            is_data = ls_s_t300t
          CHANGING
            cr_data = er_data ).

      WHEN 'Login'.
        lv_lgnum       = VALUE #( it_parameter[ name = 'WarehouseNumber' ]-value OPTIONAL ).
        lv_workstation = VALUE #( it_parameter[ name = 'WorkStation' ]-value OPTIONAL ).
        " Use Z_VI02_UI5_LOGIN service. The logic is invalid at function module!
*        CALL FUNCTION 'Z_VI02_LOGIN_INFO'
*          EXPORTING
*            iv_lgnum                   = lv_lgnum
*            iv_workstation             = lv_workstation
*          IMPORTING
*            es_whn_workstation_profile = ls_whn_workstation_profile
*          TABLES
*            et_return                  = lt_return.

*        MESSAGE e405(/scwm/who) INTO DATA(lv_message).
        MESSAGE e208(00) WITH TEXT-001 INTO DATA(lv_message)..

        DATA(ls_return) =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
        ls_return-row = VALUE #( ).
        APPEND ls_return TO lt_return.

        LOOP AT lt_return INTO ls_return.
          EXIT.
        ENDLOOP.
        IF sy-subrc EQ 0.
          mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_return
                                                              iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid  = /iwbep/cx_mgw_busi_exception=>business_error
              message = ls_return-message.
        ELSE.
          copy_data_to_ref(
          EXPORTING
            is_data = ls_whn_workstation_profile
          CHANGING
            cr_data = er_data ).
        ENDIF.

      WHEN OTHERS.
        CALL METHOD super->/iwbep/if_mgw_appl_srv_runtime~execute_action
          EXPORTING
            iv_action_name          = iv_action_name
            it_parameter            = it_parameter
            io_tech_request_context = io_tech_request_context
          IMPORTING
            er_data                 = er_data.
    ENDCASE.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA lt_return  TYPE bapiret2_t.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
*    DATA ls_converted_keys LIKE er_entity.
*    DATA lv_source_entity_set_name TYPE string.
    DATA ls_huheader         TYPE zzs_vi02_hu_header.
    DATA lt_huitems          TYPE zvi02_t_hu_item.
    DATA lt_huitems_quantity TYPE zvi02_t_hu_item_quantity.
    DATA: ls_expand LIKE zcl_z_vi02_sampling_mpc_ext=>ts_hudeep.
    DATA: lv_lgnum       TYPE  /scwm/lgnum,
          lv_workstation TYPE  /scwm/de_workstation,
          lv_huident     TYPE  /scwm/de_huident.

    CASE iv_entity_set_name.
      WHEN 'HUHeaderSet'.
        lv_huident       = it_key_tab[ name = 'Huident' ]-value.
        lv_lgnum         = it_key_tab[ name = 'Lgnum' ]-value.
        lv_workstation   = it_key_tab[ name = 'Workstation' ]-value.
*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
        lv_rfc_name = 'Z_VI02_HU_READ_ALL_DETAILS' .

        TRY.
            CALL FUNCTION 'Z_VI02_HU_READ_ALL_DETAILS'
              EXPORTING
                iv_lgnum            = lv_lgnum
                iv_workstation      = lv_workstation
                iv_huident          = lv_huident
              IMPORTING
                es_huheader         = ls_huheader
                et_huitems          = lt_huitems
                et_huitems_quantity = lt_huitems_quantity
              TABLES
                et_return           = lt_return
              EXCEPTIONS
                system_failure      = 1000 message lv_exc_msg
                OTHERS              = 1002.

            lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
          CATCH cx_root INTO lx_root.
            lv_subrc = 1001.
            lv_exc_msg = lx_root->if_message~get_text( ).
        ENDTRY.
*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
        MOVE-CORRESPONDING ls_huheader TO ls_expand.
        APPEND LINES OF lt_huitems TO ls_expand-huitem.
        APPEND LINES OF lt_huitems_quantity TO ls_expand-huitem_quantity.
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
        IF lv_subrc <> 0.
* Execute the RFC exception handling process
          me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
            EXPORTING
              iv_subrc            = lv_subrc
              iv_exp_message_text = lv_exc_msg ).
        ENDIF.

        IF lt_return IS NOT INITIAL.
          me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
            EXPORTING
              iv_entity_type = iv_entity_name
              it_return      = lt_return
              it_key_tab     = it_key_tab ).
        ENDIF.

        APPEND 'NAVTOITEM'               TO et_expanded_tech_clauses.
        APPEND 'NAVTOHUITEMQUANTITY'     TO et_expanded_tech_clauses.

        copy_data_to_ref(
          EXPORTING
            is_data = ls_expand
          CHANGING
            cr_data = er_entity ).

      WHEN OTHERS.

    ENDCASE.
  ENDMETHOD.


  METHOD huitemquantityse_get_entityset.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA iv_huident TYPE zif_z_vi02_hu_items_quantity_r=>/scwm/de_huident.
    DATA iv_lgnum TYPE zif_z_vi02_hu_items_quantity_r=>/scwm/lgnum.
    DATA iv_workstation TYPE zif_z_vi02_hu_items_quantity_r=>/scwm/de_workstation.
    DATA et_huitems_quantity  TYPE zif_z_vi02_hu_items_quantity_r=>zvi02_t_hu_item_quantity.
    DATA et_return  TYPE zif_z_vi02_hu_items_quantity_r=>__bapiret2.
    DATA ls_et_huitems_quantity  TYPE LINE OF zif_z_vi02_hu_items_quantity_r=>zvi02_t_hu_item_quantity.
    DATA ls_et_return  TYPE LINE OF zif_z_vi02_hu_items_quantity_r=>__bapiret2.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lv_filter_str TYPE string.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA ls_converted_keys LIKE LINE OF et_entityset.
    DATA ls_filter TYPE /iwbep/s_mgw_select_option.
    DATA ls_filter_range TYPE /iwbep/s_cod_select_option.
    DATA lr_huident LIKE RANGE OF ls_converted_keys-huident.
    DATA ls_huident LIKE LINE OF lr_huident.
    DATA lr_lgnum LIKE RANGE OF ls_converted_keys-lgnum.
    DATA ls_lgnum LIKE LINE OF lr_lgnum.
    DATA lr_workstation LIKE RANGE OF ls_converted_keys-workstation.
    DATA ls_workstation LIKE LINE OF lr_workstation.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
    DATA ls_gw_et_huitems_quantity LIKE LINE OF et_entityset.
    DATA lv_skip     TYPE int4.
    DATA lv_top      TYPE int4.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
    lo_filter = io_tech_request_context->get_filter( ).
    lt_filter_select_options = lo_filter->get_filter_select_options( ).
    lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
    IF  lv_filter_str            IS NOT INITIAL
    AND lt_filter_select_options IS INITIAL.
      " If the string of the Filter System Query Option is not automatically converted into
      " filter option table (lt_filter_select_options), then the filtering combination is not supported
      " Log message in the application log
      me->/iwbep/if_sb_dpc_comm_services~log_message(
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
          iv_msg_number = 025 ).
      " Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid = /iwbep/cx_mgw_tech_exception=>internal_error.
    ENDIF.

* Get key table information
    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values  = ls_converted_keys ).

    ls_paging-top = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).

* Maps filter table lines to function module parameters
    LOOP AT lt_filter_select_options INTO ls_filter.

      LOOP AT ls_filter-select_options INTO ls_filter_range.
        CASE ls_filter-property.
          WHEN 'HUIDENT'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_huident ).

            READ TABLE lr_huident INTO ls_huident INDEX 1.
            IF sy-subrc = 0.
              iv_huident = ls_huident-low.
            ENDIF.
          WHEN 'LGNUM'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_lgnum ).

            READ TABLE lr_lgnum INTO ls_lgnum INDEX 1.
            IF sy-subrc = 0.
              iv_lgnum = ls_lgnum-low.
            ENDIF.
          WHEN 'WORKSTATION'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_workstation ).

            READ TABLE lr_workstation INTO ls_workstation INDEX 1.
            IF sy-subrc = 0.
              iv_workstation = ls_workstation-low.
            ENDIF.
          WHEN OTHERS.
            " Log message in the application log
            me->/iwbep/if_sb_dpc_comm_services~log_message(
              EXPORTING
                iv_msg_type   = 'E'
                iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                iv_msg_number = 020
                iv_msg_v1     = ls_filter-property ).
            " Raise Exception
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
              EXPORTING
                textid = /iwbep/cx_mgw_tech_exception=>internal_error.
        ENDCASE.
      ENDLOOP.

    ENDLOOP.

* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    IF iv_huident IS INITIAL.
      iv_huident = VALUE #( it_key_tab[ name = 'Huident' ]-value OPTIONAL ).
    ENDIF.

    IF iv_lgnum IS INITIAL.
      iv_lgnum = VALUE #( it_key_tab[ name = 'Lgnum' ]-value OPTIONAL ).
    ENDIF.
    IF iv_workstation IS INITIAL.
      iv_workstation   = VALUE #( it_key_tab[ name = 'Workstation' ]-value OPTIONAL ).
    ENDIF.
*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_HU_ITEMS_QUANTITY_READ'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              iv_workstation      = iv_workstation
              iv_huident          = iv_huident
              iv_lgnum            = iv_lgnum
            IMPORTING
              et_huitems_quantity = et_huitems_quantity
            TABLES
              et_return           = et_return
            EXCEPTIONS
              system_failure      = 1000 message lv_exc_msg
              OTHERS              = 1002.

          lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
        CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          iv_workstation        = iv_workstation
          iv_huident            = iv_huident
          iv_lgnum              = iv_lgnum
        IMPORTING
          et_huitems_quantity   = et_huitems_quantity
        TABLES
          et_return             = et_return
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
    IF lv_subrc <> 0.
* Execute the RFC exception handling process
      me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_exc_msg ).
    ENDIF.

    IF et_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
        EXPORTING
          iv_entity_type = iv_entity_name
          it_return      = et_return
          it_key_tab     = it_key_tab ).
    ENDIF.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
    IF ls_paging-skip IS NOT INITIAL.
*  If the Skip value was requested at runtime
*  the response table will provide backend entries from skip + 1, meaning start from skip +1
*  for example: skip=5 means to start get results from the 6th row
      lv_skip = ls_paging-skip + 1.
    ENDIF.
*  The Top value was requested at runtime but was not handled as part of the function interface
    IF  ls_paging-top <> 0
    AND lv_skip IS NOT INITIAL.
*  if lv_skip > 0 retrieve the entries from lv_skip + Top - 1
*  for example: skip=5 and top=2 means to start get results from the 6th row and end in row number 7
      lv_top = ls_paging-top + lv_skip - 1.
    ELSEIF ls_paging-top <> 0
    AND    lv_skip IS INITIAL.
      lv_top = ls_paging-top.
    ELSE.
      lv_top = lines( et_huitems_quantity ).
    ENDIF.

*  - Map properties from the backend to the Gateway output response table -

    LOOP AT et_huitems_quantity INTO ls_et_huitems_quantity
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
         FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
      MOVE-CORRESPONDING ls_et_huitems_quantity TO ls_gw_et_huitems_quantity.
      APPEND ls_gw_et_huitems_quantity TO et_entityset.
      CLEAR ls_gw_et_huitems_quantity.
    ENDLOOP.
  ENDMETHOD.


  METHOD huitemset_get_entityset.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA iv_huident TYPE zif_z_vi02_hu_items_read=>/scwm/de_huident.
    DATA iv_lgnum TYPE zif_z_vi02_hu_items_read=>/scwm/lgnum.
    DATA iv_workstation TYPE zif_z_vi02_hu_items_read=>/scwm/de_workstation.
    DATA et_huitems  TYPE zif_z_vi02_hu_items_read=>zvi02_t_hu_item.
    DATA et_return  TYPE zif_z_vi02_hu_items_read=>__bapiret2.
    DATA ls_et_huitems  TYPE LINE OF zif_z_vi02_hu_items_read=>zvi02_t_hu_item.
    DATA ls_et_return  TYPE LINE OF zif_z_vi02_hu_items_read=>__bapiret2.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lv_filter_str TYPE string.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA ls_converted_keys LIKE LINE OF et_entityset.
    DATA ls_filter TYPE /iwbep/s_mgw_select_option.
    DATA ls_filter_range TYPE /iwbep/s_cod_select_option.
    DATA lr_lgnum LIKE RANGE OF ls_converted_keys-lgnum.
    DATA ls_lgnum LIKE LINE OF lr_lgnum.
    DATA lr_workstation LIKE RANGE OF ls_converted_keys-workstation.
    DATA ls_workstation LIKE LINE OF lr_workstation.
    DATA lr_huident LIKE RANGE OF ls_converted_keys-huident.
    DATA ls_huident LIKE LINE OF lr_huident.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
    DATA ls_gw_et_huitems LIKE LINE OF et_entityset.
    DATA lv_skip     TYPE int4.
    DATA lv_top      TYPE int4.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
    lo_filter = io_tech_request_context->get_filter( ).
    lt_filter_select_options = lo_filter->get_filter_select_options( ).
    lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
    IF  lv_filter_str            IS NOT INITIAL
    AND lt_filter_select_options IS INITIAL.
      " If the string of the Filter System Query Option is not automatically converted into
      " filter option table (lt_filter_select_options), then the filtering combination is not supported
      " Log message in the application log
      me->/iwbep/if_sb_dpc_comm_services~log_message(
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
          iv_msg_number = 025 ).
      " Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid = /iwbep/cx_mgw_tech_exception=>internal_error.
    ENDIF.

* Get key table information
    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values  = ls_converted_keys ).

    ls_paging-top = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).

* Maps filter table lines to function module parameters
    LOOP AT lt_filter_select_options INTO ls_filter.

      LOOP AT ls_filter-select_options INTO ls_filter_range.
        CASE ls_filter-property.
          WHEN 'LGNUM'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_lgnum ).

            READ TABLE lr_lgnum INTO ls_lgnum INDEX 1.
            IF sy-subrc = 0.
              iv_lgnum = ls_lgnum-low.
            ENDIF.
          WHEN 'WORKSTATION'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_workstation ).

            READ TABLE lr_workstation INTO ls_workstation INDEX 1.
            IF sy-subrc = 0.
              iv_workstation = ls_workstation-low.
            ENDIF.
          WHEN 'HUIDENT'.
            lo_filter->convert_select_option(
              EXPORTING
                is_select_option = ls_filter
              IMPORTING
                et_select_option = lr_huident ).

            READ TABLE lr_huident INTO ls_huident INDEX 1.
            IF sy-subrc = 0.
              iv_huident = ls_huident-low.
            ENDIF.
          WHEN OTHERS.
            " Log message in the application log
            me->/iwbep/if_sb_dpc_comm_services~log_message(
              EXPORTING
                iv_msg_type   = 'E'
                iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                iv_msg_number = 020
                iv_msg_v1     = ls_filter-property ).
            " Raise Exception
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
              EXPORTING
                textid = /iwbep/cx_mgw_tech_exception=>internal_error.
        ENDCASE.
      ENDLOOP.

    ENDLOOP.

* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    IF iv_huident IS INITIAL.
      iv_huident = VALUE #( it_key_tab[ name = 'Huident' ]-value OPTIONAL ).
    ENDIF.

    IF iv_lgnum IS INITIAL.
      iv_lgnum = VALUE #( it_key_tab[ name = 'Lgnum' ]-value OPTIONAL ).
    ENDIF.
    IF iv_workstation IS INITIAL.
      iv_workstation   = VALUE #( it_key_tab[ name = 'Workstation' ]-value OPTIONAL ).
    ENDIF.
*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_HU_ITEMS_READ'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          DATA: lt_huitems TYPE zvi02_t_hu_item.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              iv_lgnum       = iv_lgnum
              iv_workstation = iv_workstation
              iv_huident     = iv_huident
            IMPORTING
              et_huitems     = lt_huitems
            TABLES
              et_return      = et_return
            EXCEPTIONS
              system_failure = 1000 message lv_exc_msg
              OTHERS         = 1002.
          et_huitems = CORRESPONDING #( lt_huitems ).
          lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
        CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          iv_lgnum              = iv_lgnum
          iv_workstation        = iv_workstation
          iv_huident            = iv_huident
        IMPORTING
          et_huitems            = et_huitems
        TABLES
          et_return             = et_return
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
    IF lv_subrc <> 0.
* Execute the RFC exception handling process
      me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_exc_msg ).
    ENDIF.

    IF et_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
        EXPORTING
          iv_entity_type = iv_entity_name
          it_return      = et_return
          it_key_tab     = it_key_tab ).
    ENDIF.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
    IF ls_paging-skip IS NOT INITIAL.
*  If the Skip value was requested at runtime
*  the response table will provide backend entries from skip + 1, meaning start from skip +1
*  for example: skip=5 means to start get results from the 6th row
      lv_skip = ls_paging-skip + 1.
    ENDIF.
*  The Top value was requested at runtime but was not handled as part of the function interface
    IF  ls_paging-top <> 0
    AND lv_skip IS NOT INITIAL.
*  if lv_skip > 0 retrieve the entries from lv_skip + Top - 1
*  for example: skip=5 and top=2 means to start get results from the 6th row and end in row number 7
      lv_top = ls_paging-top + lv_skip - 1.
    ELSEIF ls_paging-top <> 0
    AND    lv_skip IS INITIAL.
      lv_top = ls_paging-top.
    ELSE.
      lv_top = lines( et_huitems ).
    ENDIF.

*  - Map properties from the backend to the Gateway output response table -

    LOOP AT et_huitems INTO ls_et_huitems
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
         FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
      MOVE-CORRESPONDING ls_et_huitems TO ls_gw_et_huitems.
      APPEND ls_gw_et_huitems TO et_entityset.
      CLEAR ls_gw_et_huitems.
    ENDLOOP.

  ENDMETHOD.


  METHOD huwarehousetasks_create_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA es_keys TYPE zzs_vi02_hu_wt_keys.
    DATA is_hu_whse_task TYPE zzs_vi02_hu_wt.
    DATA et_return  TYPE bapiret2_t.
    DATA ls_et_return  LIKE  LINE OF et_return.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA ls_request_input_data TYPE zcl_z_vi02_sampling_mpc=>ts_huwarehousetask.
    DATA ls_entity TYPE REF TO data.
    DATA lo_tech_read_request_context TYPE REF TO /iwbep/cl_sb_gen_read_aftr_crt.
    DATA ls_key TYPE /iwbep/s_mgw_tech_pair.
    DATA lt_keys TYPE /iwbep/t_mgw_tech_pairs.
    DATA lv_entityset_name TYPE string.
    DATA lv_entity_name TYPE string.
    FIELD-SYMBOLS: <ls_data> TYPE any.
    DATA ls_converted_keys LIKE er_entity.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get request input data
    io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).

* Map request input fields to function module parameters
    is_hu_whse_task-lgnum = ls_request_input_data-lgnum.
    is_hu_whse_task-tanum = ls_request_input_data-tanum.
    is_hu_whse_task-tapos = ls_request_input_data-tapos.
    is_hu_whse_task-huident = ls_request_input_data-huident.
    is_hu_whse_task-guid_hu = ls_request_input_data-guid_hu.
    is_hu_whse_task-procty = ls_request_input_data-procty.
    is_hu_whse_task-reason = ls_request_input_data-reason.
    is_hu_whse_task-squit = ls_request_input_data-squit.
    is_hu_whse_task-norou = ls_request_input_data-norou.
    is_hu_whse_task-nltyp = ls_request_input_data-nltyp.
    is_hu_whse_task-nlber = ls_request_input_data-nlber.
    is_hu_whse_task-nlpla = ls_request_input_data-nlpla.
    is_hu_whse_task-nlenr = ls_request_input_data-nlenr.
    is_hu_whse_task-dguid_hu = ls_request_input_data-dguid_hu.
    is_hu_whse_task-drsrc = ls_request_input_data-drsrc.
    is_hu_whse_task-entitled = ls_request_input_data-entitled.
    is_hu_whse_task-matnr = ls_request_input_data-matnr.

* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_HU_WHSE_TASK_CREATE'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              is_hu_whse_task = is_hu_whse_task
            IMPORTING
              es_keys         = es_keys
            TABLES
              et_return       = et_return
            EXCEPTIONS
              system_failure  = 1000 message lv_exc_msg
              OTHERS          = 1002.

          lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
        CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          is_hu_whse_task       = is_hu_whse_task
        IMPORTING
          es_keys               = es_keys
        TABLES
          et_return             = et_return
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
    IF lv_subrc <> 0.
* Execute the RFC exception handling process
      me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_exc_msg ).
    ENDIF.

    IF et_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
        EXPORTING
          iv_entity_type = iv_entity_name
          it_return      = et_return
          it_key_tab     = it_key_tab ).
    ENDIF.

* Call RFC commit work
    me->/iwbep/if_sb_dpc_comm_services~commit_work(
      EXPORTING
        iv_rfc_dest = lv_destination
    ).
*-------------------------------------------------------------------------*
*             - Read After Create -
*-------------------------------------------------------------------------*
    CREATE OBJECT lo_tech_read_request_context.

* Create key table for the read operation

    ls_key-name = 'TAPOS'.
    ls_key-value = es_keys-tapos.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'TANUM'.
    ls_key-value = es_keys-tanum.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'LGNUM'.
    ls_key-value = es_keys-lgnum.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'LGNUM'.
    ls_key-value = is_hu_whse_task-lgnum.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'TANUM'.
    ls_key-value = is_hu_whse_task-tanum.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'TAPOS'.
    ls_key-value = is_hu_whse_task-tapos.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

* Set into request context object the key table and the entity set name
    lo_tech_read_request_context->set_keys( EXPORTING  it_keys = lt_keys ).
    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).
    lo_tech_read_request_context->set_entityset_name( EXPORTING iv_entityset_name = lv_entityset_name ).
    lv_entity_name = io_tech_request_context->get_entity_type_name( ).
    lo_tech_read_request_context->set_entity_type_name( EXPORTING iv_entity_name = lv_entity_name ).

* Call read after create
    /iwbep/if_mgw_appl_srv_runtime~get_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_tech_request_context = lo_tech_read_request_context
        it_navigation_path      = it_navigation_path
      IMPORTING
        er_entity               = ls_entity ).

* Send the read response to the caller interface
    ASSIGN ls_entity->* TO <ls_data>.
    er_entity = <ls_data>.
  ENDMETHOD.


  METHOD huwarehousetasks_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA es_hu_whse_task TYPE zzs_vi02_hu_wt.
    DATA is_keys TYPE zzs_vi02_hu_wt_keys.
    DATA et_return  TYPE bapiret2_t.
    DATA ls_et_return  LIKE LINE OF et_return.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA ls_converted_keys LIKE er_entity.
    DATA lv_source_entity_set_name TYPE string.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get key table information - for direct call
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_converted_keys ).

* Maps key fields to function module parameters

    lv_source_entity_set_name = io_tech_request_context->get_source_entity_set_name( ).

    IF lv_source_entity_set_name = 'HUWarehouseTaskSet' AND
       lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_converted_keys ).

    ENDIF.

    is_keys-tapos = ls_converted_keys-tapos.
    is_keys-tanum = ls_converted_keys-tanum.
    is_keys-lgnum = ls_converted_keys-lgnum.
* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_HU_WHSE_TASK_READ'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              is_keys         = is_keys
            IMPORTING
              es_hu_whse_task = es_hu_whse_task
            TABLES
              et_return       = et_return
            EXCEPTIONS
              system_failure  = 1000 message lv_exc_msg
              OTHERS          = 1002.

          lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
        CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          is_keys               = is_keys
        IMPORTING
          es_hu_whse_task       = es_hu_whse_task
        TABLES
          et_return             = et_return
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
    IF lv_subrc <> 0.
* Execute the RFC exception handling process
      me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_exc_msg ).
    ENDIF.

    IF et_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
        EXPORTING
          iv_entity_type = iv_entity_name
          it_return      = et_return
          it_key_tab     = it_key_tab ).
    ENDIF.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
* Map properties from the backend to the Gateway output response structure

*    er_entity-drsrc = es_hu_whse_task-drsrc.
*    er_entity-dguid_hu = es_hu_whse_task-dguid_hu.
*    er_entity-nlenr = es_hu_whse_task-nlenr.
*    er_entity-nlpla = es_hu_whse_task-nlpla.
*    er_entity-nlber = es_hu_whse_task-nlber.
*    er_entity-nltyp = es_hu_whse_task-nltyp.
*    er_entity-norou = es_hu_whse_task-norou.
*    er_entity-squit = es_hu_whse_task-squit.
*    er_entity-reason = es_hu_whse_task-reason.
*    er_entity-procty = es_hu_whse_task-procty.
*    er_entity-guid_hu = es_hu_whse_task-guid_hu.
*    er_entity-huident = es_hu_whse_task-huident.
*    er_entity-tapos = es_hu_whse_task-tapos.
*    er_entity-tanum = es_hu_whse_task-tanum.
*    er_entity-lgnum = es_hu_whse_task-lgnum.
    er_entity = CORRESPONDING #( es_hu_whse_task ).
  ENDMETHOD.


  method PRODUCTUNITOFMEA_GET_ENTITYSET.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA iv_product TYPE zif_z_vi02_vh_product=>zzs_vi02_vh_product-product.
 DATA et_product_uom  TYPE zif_z_vi02_vh_product=>zvi02_t_vh_product.
 DATA et_return  TYPE zif_z_vi02_vh_product=>__bapiret2.
 DATA ls_et_product_uom  TYPE LINE OF zif_z_vi02_vh_product=>zvi02_t_vh_product.
 DATA ls_et_return  TYPE LINE OF zif_z_vi02_vh_product=>__bapiret2.
 DATA lv_rfc_name TYPE tfdir-funcname.
 DATA lv_destination TYPE rfcdest.
 DATA lv_subrc TYPE syst-subrc.
 DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
 DATA lx_root TYPE REF TO cx_root.
 DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
 DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
 DATA lv_filter_str TYPE string.
 DATA ls_paging TYPE /iwbep/s_mgw_paging.
 DATA ls_converted_keys LIKE LINE OF et_entityset.
 DATA ls_filter TYPE /iwbep/s_mgw_select_option.
 DATA ls_filter_range TYPE /iwbep/s_cod_select_option.
 DATA lr_product LIKE RANGE OF ls_converted_keys-product.
 DATA ls_product LIKE LINE OF lr_product.
 DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
 DATA ls_gw_et_product_uom LIKE LINE OF et_entityset.
 DATA lv_skip     TYPE int4.
 DATA lv_top      TYPE int4.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
 lo_filter = io_tech_request_context->get_filter( ).
 lt_filter_select_options = lo_filter->get_filter_select_options( ).
 lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
 IF  lv_filter_str            IS NOT INITIAL
 AND lt_filter_select_options IS INITIAL.
   " If the string of the Filter System Query Option is not automatically converted into
   " filter option table (lt_filter_select_options), then the filtering combination is not supported
   " Log message in the application log
   me->/iwbep/if_sb_dpc_comm_services~log_message(
     EXPORTING
       iv_msg_type   = 'E'
       iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
       iv_msg_number = 025 ).
   " Raise Exception
   RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
     EXPORTING
       textid = /iwbep/cx_mgw_tech_exception=>internal_error.
 ENDIF.

* Get key table information
 io_tech_request_context->get_converted_source_keys(
   IMPORTING
     es_key_values  = ls_converted_keys ).

 ls_paging-top = io_tech_request_context->get_top( ).
 ls_paging-skip = io_tech_request_context->get_skip( ).

* Maps filter table lines to function module parameters
 LOOP AT lt_filter_select_options INTO ls_filter.

   LOOP AT ls_filter-select_options INTO ls_filter_range.
     CASE ls_filter-property.
       WHEN 'PRODUCT'.
         lo_filter->convert_select_option(
           EXPORTING
             is_select_option = ls_filter
           IMPORTING
             et_select_option = lr_product ).

         READ TABLE lr_product INTO ls_product INDEX 1.
         IF sy-subrc = 0.
           iv_product = ls_product-low.
         ENDIF.
       WHEN OTHERS.
         " Log message in the application log
         me->/iwbep/if_sb_dpc_comm_services~log_message(
           EXPORTING
             iv_msg_type   = 'E'
             iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
             iv_msg_number = 020
             iv_msg_v1     = ls_filter-property ).
         " Raise Exception
         RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
           EXPORTING
             textid = /iwbep/cx_mgw_tech_exception=>internal_error.
     ENDCASE.
   ENDLOOP.

 ENDLOOP.

* Get RFC destination
 lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
 lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
 lv_rfc_name = 'Z_VI02_VH_PRODUCT'.

 IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

   TRY.
       CALL FUNCTION lv_rfc_name
         EXPORTING
           iv_product     = iv_product
         IMPORTING
           et_product_uom = et_product_uom
         TABLES
           et_return      = et_return
         EXCEPTIONS
           system_failure = 1000 message lv_exc_msg
           OTHERS         = 1002.

       lv_subrc = sy-subrc.
*in case of co-deployment the exception is raised and needs to be caught
     CATCH cx_root INTO lx_root.
       lv_subrc = 1001.
       lv_exc_msg = lx_root->if_message~get_text( ).
   ENDTRY.

 ELSE.

   CALL FUNCTION lv_rfc_name DESTINATION lv_destination
     EXPORTING
       iv_product            = iv_product
     IMPORTING
       et_product_uom        = et_product_uom
     TABLES
       et_return             = et_return
     EXCEPTIONS
       system_failure        = 1000 MESSAGE lv_exc_msg
       communication_failure = 1001 MESSAGE lv_exc_msg
       OTHERS                = 1002.

   lv_subrc = sy-subrc.

 ENDIF.

*-------------------------------------------------------------
*  Map the RFC response to the caller interface - Only mapped attributes
*-------------------------------------------------------------
*-------------------------------------------------------------
* Error and exception handling
*-------------------------------------------------------------
 IF lv_subrc <> 0.
* Execute the RFC exception handling process
   me->/iwbep/if_sb_dpc_comm_services~rfc_exception_handling(
     EXPORTING
       iv_subrc            = lv_subrc
       iv_exp_message_text = lv_exc_msg ).
 ENDIF.

 IF et_return IS NOT INITIAL.
   me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
     EXPORTING
       iv_entity_type = iv_entity_name
       it_return      = et_return
       it_key_tab     = it_key_tab ).
 ENDIF.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
 IF ls_paging-skip IS NOT INITIAL.
*  If the Skip value was requested at runtime
*  the response table will provide backend entries from skip + 1, meaning start from skip +1
*  for example: skip=5 means to start get results from the 6th row
   lv_skip = ls_paging-skip + 1.
 ENDIF.
*  The Top value was requested at runtime but was not handled as part of the function interface
 IF  ls_paging-top <> 0
 AND lv_skip IS NOT INITIAL.
*  if lv_skip > 0 retrieve the entries from lv_skip + Top - 1
*  for example: skip=5 and top=2 means to start get results from the 6th row and end in row number 7
   lv_top = ls_paging-top + lv_skip - 1.
 ELSEIF ls_paging-top <> 0
 AND    lv_skip IS INITIAL.
   lv_top = ls_paging-top.
 ELSE.
   lv_top = lines( et_product_uom ).
 ENDIF.

*  - Map properties from the backend to the Gateway output response table -

 LOOP AT et_product_uom INTO ls_et_product_uom
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
      FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
***   ls_gw_et_product_uom-unitofmeasurecommercialname = ls_et_product_uom-unitofmeasurecommercialname.
***   ls_gw_et_product_uom-unitofmeasure_e = ls_et_product_uom-unitofmeasure_e.
***   ls_gw_et_product_uom-unitofmeasuretechnicalname = ls_et_product_uom-unitofmeasuretechnicalname.
***   ls_gw_et_product_uom-unitofmeasurename = ls_et_product_uom-unitofmeasurename.
***   ls_gw_et_product_uom-unitofmeasurelongname = ls_et_product_uom-unitofmeasurelongname.
***   ls_gw_et_product_uom-unitofmeasure = ls_et_product_uom-unitofmeasure.
***   ls_gw_et_product_uom-language = ls_et_product_uom-language.
***   ls_gw_et_product_uom-baseunit = ls_et_product_uom-baseunit.
***   ls_gw_et_product_uom-unitofmeasurecategory = ls_et_product_uom-unitofmeasurecategory.
***   ls_gw_et_product_uom-productmeasurementunit = ls_et_product_uom-productmeasurementunit.
***   ls_gw_et_product_uom-quantitydenominator = ls_et_product_uom-quantitydenominator.
***   ls_gw_et_product_uom-quantitynumerator = ls_et_product_uom-quantitynumerator.
***   ls_gw_et_product_uom-alternativeunit = ls_et_product_uom-alternativeunit.
***   ls_gw_et_product_uom-product = ls_et_product_uom-product.
   ls_gw_et_product_uom = CORRESPONDING #( ls_et_product_uom ).
   APPEND ls_gw_et_product_uom TO et_entityset.
   CLEAR ls_gw_et_product_uom.
 ENDLOOP.


  endmethod.
ENDCLASS.
