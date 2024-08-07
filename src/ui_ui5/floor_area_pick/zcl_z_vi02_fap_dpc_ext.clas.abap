class ZCL_Z_VI02_FAP_DPC_EXT definition
  public
  inheriting from ZCL_Z_VI02_FAP_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.

  methods HUIDENTIFIERSET_GET_ENTITYSET
    redefinition .
  methods OUTBDELVHEADERSE_GET_ENTITY
    redefinition .
  methods OUTBDELVITEMSET_GET_ENTITY
    redefinition .
  methods OUTBDELVITEMSET_GET_ENTITYSET
    redefinition .
  methods PICKHUSET_CREATE_ENTITY
    redefinition .
  methods PICKHUSET_GET_ENTITY
    redefinition .
  methods SCANHANDLINGUNIT_GET_ENTITY
    redefinition .
  methods HUIDENTIFIERSET_GET_ENTITY
    redefinition .
  PRIVATE SECTION.
    METHODS:
      outbound_delivery_query
        IMPORTING
          it_docid        TYPE /scwm/dlv_docid_item_tab OPTIONAL
          it_docno        TYPE /scwm/dlv_docno_itemno_tab OPTIONAL
          iv_whno         TYPE /scwm/lgnum OPTIONAL
          it_selection    TYPE /scwm/dlv_selection_tab OPTIONAL
          iv_doccat       TYPE /scdl/dl_doccat OPTIONAL
          is_read_options TYPE /scwm/dlv_query_contr_str OPTIONAL
          is_include_data TYPE /scwm/dlv_query_incl_str_prd OPTIONAL
        EXPORTING
          et_headers      TYPE /scwm/dlv_header_out_prd_tab
          et_items        TYPE /scwm/dlv_item_out_prd_tab
          eo_message      TYPE REF TO /scwm/cl_dm_message_no
        RAISING
          /scdl/cx_delivery .
ENDCLASS.



CLASS ZCL_Z_VI02_FAP_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    DATA:
      ls_s_t300t                 TYPE /scwm/s_t300t.

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


  METHOD huidentifierset_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA iv_lgnum TYPE zcl_z_vi02_fap_mpc=>ts_huidentifier-lgnum.
    DATA iv_fkey TYPE zcl_z_vi02_fap_mpc=>ts_huidentifier-fkey.
    DATA et_return  TYPE  bapiret2_t.
    DATA ls_et_return  TYPE bapiret2.
    DATA es_mapping TYPE zzs_vi02_exc_mapping.
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

    IF lv_source_entity_set_name = 'HUIdentifierSet' AND
       lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_converted_keys ).

    ENDIF.

    iv_lgnum = ls_converted_keys-lgnum.
    iv_fkey = ls_converted_keys-fkey.
* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    TRY.
        CALL FUNCTION 'Z_VI02_FAP_HUIDENTIFIER_SINGLE'
          EXPORTING
            iv_lgnum       = iv_lgnum
            iv_fkey        = iv_fkey
          IMPORTING
            es_mapping     = es_mapping
          TABLES
            et_return      = et_return
          EXCEPTIONS
            system_failure = 1000 message lv_exc_msg
            OTHERS         = 1002.
      CATCH cx_root INTO lx_root.
        lv_subrc = 1001.
        lv_exc_msg = lx_root->if_message~get_text( ).
    ENDTRY.
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
    er_entity = CORRESPONDING #( es_mapping ).

  ENDMETHOD.


  METHOD huidentifierset_get_entityset.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA iv_lgnum TYPE /scwm/lgnum.
    DATA et_mapping  TYPE zvi02_t_exc_mapping.
    DATA et_return  TYPE bapiret2_t.
    DATA ls_et_return  LIKE LINE OF et_return.
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
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
    DATA ls_gw_et_mapping LIKE LINE OF et_entityset.
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
    lv_rfc_name = 'Z_VI02_FAP_HUIDENTIFIERS'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.
      TRY.
          CALL FUNCTION 'Z_VI02_FAP_HUIDENTIFIERS'
            EXPORTING
              iv_lgnum       = iv_lgnum
            IMPORTING
              et_mapping     = et_mapping
            TABLES
              et_return      = et_return
            EXCEPTIONS
              system_failure = 1000 message lv_exc_msg
              OTHERS         = 1002.
        CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

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
      lv_top = lines( et_mapping ).
    ENDIF.

*  - Map properties from the backend to the Gateway output response table -

    LOOP AT et_mapping INTO DATA(ls_mapping)
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
         FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
      ls_gw_et_mapping = CORRESPONDING #( ls_mapping ).
      APPEND ls_gw_et_mapping TO et_entityset.
      CLEAR ls_gw_et_mapping.
    ENDLOOP.

  ENDMETHOD.


  METHOD outbdelvheaderse_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA es_header TYPE zcl_z_vi02_fap_mpc=>ts_outbdelvheader.
    DATA iv_docid TYPE  zcl_z_vi02_fap_mpc=>ts_outbdelvheader-docid.
    DATA et_return  TYPE bapiret2_t.
* DATA it_behavior_control  TYPE /iwbep/if_sepm_gws_so_get_de1=>sepm_gws_behavior_control_t.
    DATA ls_et_return  LIKE LINE OF et_return.
* DATA ls_it_behavior_control  LIKE LINE OF it_behavior_control.
*    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA lt_key_tab TYPE /iwbep/t_mgw_tech_pairs.
    DATA ls_keys TYPE /iwbep/s_mgw_tech_pair.
    DATA lv_source_entity_set_name TYPE string.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
    lt_key_tab = io_tech_request_context->get_keys( ).
    IF lt_key_tab IS INITIAL.
      " In Referential Constraints scenario, the keys will come from the source entity set node
      lt_key_tab = io_tech_request_context->get_source_keys( ).
    ENDIF.

    lv_source_entity_set_name = io_tech_request_context->get_source_entity_set_name( ).
    LOOP AT lt_key_tab INTO ls_keys.
      CASE ls_keys-name.
        WHEN 'DOCID'.
          iv_docid = ls_keys-value.
        WHEN OTHERS.
          " Log message in the application log
          me->/iwbep/if_sb_dpc_comm_services~log_message(
            EXPORTING
              iv_msg_type   = 'E'
              iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
              iv_msg_number = 021
              iv_msg_v1     = ls_keys-name ).
          " Raise Exception
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
            EXPORTING
              textid = /iwbep/cx_mgw_tech_exception=>internal_error.
      ENDCASE.

    ENDLOOP.


* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    TRY.
        me->outbound_delivery_query(
          EXPORTING
            it_selection    = VALUE /scwm/dlv_selection_tab( (
                                  fieldname = /scdl/if_dl_logfname_c=>sc_docid_i
                                  sign      = /scdl/if_dl_query_c=>sc_sign_include
                                  option    = /scdl/if_dl_query_c=>sc_option_eq
                                  low       =  iv_docid
                                ) )
            iv_doccat       = /scdl/if_dl_c=>sc_doccat_out_prd
            is_read_options = VALUE #( data_retrival_only = abap_true
                                       mix_in_object_instances = /scwm/if_dl_c=>sc_mix_in_load_instance )
          IMPORTING
            et_headers      = DATA(lt_headers)
            et_items        = DATA(lt_items)
            eo_message      = DATA(lo_message) ).

      CATCH /scdl/cx_delivery INTO DATA(lx_delivery).

        MESSAGE ID lx_delivery->if_t100_message~t100key-msgid TYPE 'E'
          NUMBER lx_delivery->if_t100_message~t100key-msgno
          INTO DATA(lv_message)
          WITH lx_delivery->if_t100_message~t100key-attr1 lx_delivery->if_t100_message~t100key-attr2
               lx_delivery->if_t100_message~t100key-attr3 lx_delivery->if_t100_message~t100key-attr4.

        DATA: lv_tabix   TYPE sy-tabix.
        DATA(ls_return) =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
        ls_return-row = lv_tabix.
        APPEND ls_return TO et_return.

        DATA(lt_message) = lo_message->get_messages( ).
        LOOP AT lt_message INTO DATA(ls_message).
          APPEND VALUE #( type       = ls_message-msgty
                          id         = ls_message-msgid
                          number     = ls_message-msgno
                          message_v1 = ls_message-msgv1
                          message_v2 = ls_message-msgv2
                          message_v3 = ls_message-msgv3
                          message_v4 = ls_message-msgv4
                          parameter  = VALUE #( )
                          row        = VALUE #( )
                          field      = VALUE #( ) ) TO et_return.
        ENDLOOP.
    ENDTRY.

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
    READ TABLE lt_headers INTO DATA(ls_header) INDEX 1.
    es_header = CORRESPONDING #( ls_header ).
    er_entity = CORRESPONDING #( es_header ).
  ENDMETHOD.


  METHOD outbdelvitemset_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
*    DATA es_outbdelv_item TYPE zcl_z_vi02_fap_mpc=>ts_outbdelvitem.
    DATA iv_docid TYPE zcl_z_vi02_fap_mpc=>ts_outbdelvitem-docid.
    DATA iv_itemid TYPE zcl_z_vi02_fap_mpc=>ts_outbdelvitem-itemid.
    DATA et_return  TYPE  bapiret2_t.
    DATA ls_et_return  TYPE bapiret2.
*    DATA lv_rfc_name TYPE tfdir-funcname.
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

    IF lv_source_entity_set_name = 'OutbDelvItemSet' AND
       lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_converted_keys ).

    ENDIF.

    iv_itemid = ls_converted_keys-itemid.
    iv_docid = ls_converted_keys-docid.
* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    TRY.
        me->outbound_delivery_query(
          EXPORTING
            it_docid        = VALUE /scwm/dlv_docid_item_tab( ( docid  = iv_docid
                                                                itemid = iv_itemid
                                                                doccat =  /scdl/if_dl_c=>sc_doccat_out_prd ) )
            iv_doccat       = /scdl/if_dl_c=>sc_doccat_out_prd
            is_read_options = VALUE #( data_retrival_only = abap_true
                                       mix_in_object_instances = /scwm/if_dl_c=>sc_mix_in_load_instance )
          IMPORTING
            et_headers      = DATA(lt_headers)
            et_items        = DATA(lt_items)
            eo_message      = DATA(lo_message) ).

      CATCH /scdl/cx_delivery INTO DATA(lx_delivery).

        MESSAGE ID lx_delivery->if_t100_message~t100key-msgid TYPE 'E'
          NUMBER lx_delivery->if_t100_message~t100key-msgno
          INTO DATA(lv_message)
          WITH lx_delivery->if_t100_message~t100key-attr1 lx_delivery->if_t100_message~t100key-attr2
               lx_delivery->if_t100_message~t100key-attr3 lx_delivery->if_t100_message~t100key-attr4.

        DATA: lv_tabix   TYPE sy-tabix.
        DATA(ls_return) =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
        ls_return-row = lv_tabix.
        APPEND ls_return TO et_return.

        DATA(lt_message) = lo_message->get_messages( ).
        LOOP AT lt_message INTO DATA(ls_message).
          APPEND VALUE #( type       = ls_message-msgty
                          id         = ls_message-msgid
                          number     = ls_message-msgno
                          message_v1 = ls_message-msgv1
                          message_v2 = ls_message-msgv2
                          message_v3 = ls_message-msgv3
                          message_v4 = ls_message-msgv4
                          parameter  = VALUE #( )
                          row        = VALUE #( )
                          field      = VALUE #( ) ) TO et_return.
        ENDLOOP.
    ENDTRY.

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
    READ TABLE lt_items INTO DATA(ls_items) INDEX 1.
    er_entity = CORRESPONDING #( ls_items EXCEPT qty ).
    er_entity-qty = ls_items-qty-qty.
    er_entity-uom = ls_items-qty-uom.
  ENDMETHOD.


  METHOD outbdelvitemset_get_entityset.

    DATA iv_docid TYPE zcl_z_vi02_fap_mpc=>ts_outbdelvitem-docid.
    DATA et_return  TYPE  bapiret2_t.
    DATA ls_et_return  TYPE bapiret2.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lv_filter_str TYPE string.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA lt_key_tab TYPE /iwbep/t_mgw_tech_pairs.
    DATA ls_keys TYPE /iwbep/s_mgw_tech_pair.
    DATA lv_source_entity_set_name TYPE string.
    DATA ls_filter TYPE /iwbep/s_mgw_select_option.
    DATA ls_filter_range TYPE /iwbep/s_cod_select_option.
    DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
    DATA ls_gw_et_items LIKE LINE OF et_entityset.
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
    lt_key_tab = io_tech_request_context->get_source_keys( ).
    ls_paging-top = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).


* Maps key fields to function module parameters
    IF lt_key_tab IS NOT INITIAL.

      lv_source_entity_set_name = io_tech_request_context->get_source_entity_set_name( ).

      LOOP AT lt_key_tab INTO ls_keys.

        IF lv_source_entity_set_name = 'OutbDelvHeaderSet'.
          CASE ls_keys-name.
            WHEN 'DOCID'.
              iv_docid = ls_keys-value.
            WHEN OTHERS.
              " Log message in the application log
              me->/iwbep/if_sb_dpc_comm_services~log_message(
                EXPORTING
                  iv_msg_type   = 'E'
                  iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                  iv_msg_number = 021
                  iv_msg_v1     = ls_keys-name ).
              " Raise Exception
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                EXPORTING
                  textid = /iwbep/cx_mgw_tech_exception=>internal_error.
          ENDCASE.
          CONTINUE.
        ENDIF.

      ENDLOOP.

    ELSEIF it_filter_select_options IS NOT INITIAL.

* Maps filter table lines to function module parameters
      LOOP AT lt_filter_select_options INTO ls_filter.

        LOOP AT ls_filter-select_options INTO ls_filter_range.
          CASE ls_filter-property.
            WHEN 'DOCID'.
              iv_docid = ls_filter_range-low.
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

    ENDIF.

* Append lines of table parameters in the function call
*    IF ls_it_behavior_control IS NOT INITIAL.
*      APPEND ls_it_behavior_control TO it_behavior_control.
*    ENDIF.

* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    TRY.
        me->outbound_delivery_query(
          EXPORTING
            it_selection    = VALUE /scwm/dlv_selection_tab( (
                                  fieldname = /scdl/if_dl_logfname_c=>sc_docid_i
                                  sign      = /scdl/if_dl_query_c=>sc_sign_include
                                  option    = /scdl/if_dl_query_c=>sc_option_eq
                                  low       =  iv_docid
                                ) )
            iv_doccat       = /scdl/if_dl_c=>sc_doccat_out_prd
            is_read_options = VALUE #( data_retrival_only = abap_true
                                       mix_in_object_instances = /scwm/if_dl_c=>sc_mix_in_load_instance )
          IMPORTING
            et_headers      = DATA(lt_headers)
            et_items        = DATA(lt_items)
            eo_message      = DATA(lo_message) ).

      CATCH /scdl/cx_delivery INTO DATA(lx_delivery).

        MESSAGE ID lx_delivery->if_t100_message~t100key-msgid TYPE 'E'
          NUMBER lx_delivery->if_t100_message~t100key-msgno
          INTO DATA(lv_message)
          WITH lx_delivery->if_t100_message~t100key-attr1 lx_delivery->if_t100_message~t100key-attr2
               lx_delivery->if_t100_message~t100key-attr3 lx_delivery->if_t100_message~t100key-attr4.

        DATA: lv_tabix   TYPE sy-tabix.
        DATA(ls_return) =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
        ls_return-row = lv_tabix.
        APPEND ls_return TO et_return.

        DATA(lt_message) = lo_message->get_messages( ).
        LOOP AT lt_message INTO DATA(ls_message).
          APPEND VALUE #( type       = ls_message-msgty
                          id         = ls_message-msgid
                          number     = ls_message-msgno
                          message_v1 = ls_message-msgv1
                          message_v2 = ls_message-msgv2
                          message_v3 = ls_message-msgv3
                          message_v4 = ls_message-msgv4
                          parameter  = VALUE #( )
                          row        = VALUE #( )
                          field      = VALUE #( ) ) TO et_return.
        ENDLOOP.
    ENDTRY.


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
      lv_top = lines( lt_items ).
    ENDIF.

*  - Map properties from the backend to the Gateway output response table -

    LOOP AT lt_items INTO DATA(ls_items)
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
         FROM lv_skip TO lv_top.
*  Only fields that were mapped will be delivered to the response table
      ls_gw_et_items = CORRESPONDING #( ls_items EXCEPT qty ).
      ls_gw_et_items-qty = ls_items-qty-qty.
      ls_gw_et_items-uom = ls_items-qty-uom.
      APPEND ls_gw_et_items TO et_entityset.
      CLEAR ls_gw_et_items.
    ENDLOOP.

  ENDMETHOD.


  METHOD outbound_delivery_query.

    CLEAR: et_headers, et_items, eo_message.
    DATA(lo_manag) = /scwm/cl_dlv_management_prd=>get_instance( ).
    lo_manag->query(
      EXPORTING
        it_docid        = it_docid
        it_docno        = it_docno
        iv_whno         = iv_whno
        it_selection    = it_selection
        iv_doccat       = iv_doccat
        is_read_options = is_read_options
        is_include_data = is_include_data
      IMPORTING
        et_headers      = et_headers
        et_items        = et_items
        eo_message      = eo_message ).

  ENDMETHOD.


  METHOD pickhuset_create_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA es_pickhu_keys TYPE zif_z_vi02_fap_create_pickhu=>zzs_vi02_fap_read_pick_hu.
    DATA is_pickhudata TYPE zif_z_vi02_fap_create_pickhu=>zzs_vi02_fap_pick_hu.
    DATA et_return  TYPE zif_z_vi02_fap_create_pickhu=>__bapiret2.
    DATA ls_et_return  TYPE LINE OF zif_z_vi02_fap_create_pickhu=>__bapiret2.
    DATA lv_rfc_name TYPE tfdir-funcname.
    DATA lv_destination TYPE rfcdest.
    DATA lv_subrc TYPE syst-subrc.
    DATA lv_exc_msg TYPE /iwbep/mgw_bop_rfc_excep_text.
    DATA lx_root TYPE REF TO cx_root.
    DATA ls_request_input_data TYPE zcl_z_vi02_fap_mpc=>ts_pickhu.
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
    is_pickhudata-hutyp_text = ls_request_input_data-hutyp_text.
    is_pickhudata-hutyp = ls_request_input_data-hutyp.
    is_pickhudata-pmtyp_text = ls_request_input_data-pmtyp_text.
    is_pickhudata-pmtyp = ls_request_input_data-pmtyp.
    is_pickhudata-pmat_guid = ls_request_input_data-pmat_guid.
    is_pickhudata-tanum = ls_request_input_data-tanum.
    is_pickhudata-rsrc = ls_request_input_data-rsrc.
    is_pickhudata-lgpla = ls_request_input_data-lgpla.
    is_pickhudata-huident = ls_request_input_data-huident.
    is_pickhudata-hukng = ls_request_input_data-hukng.
    is_pickhudata-who = ls_request_input_data-who.
    is_pickhudata-lgnum = ls_request_input_data-lgnum.
    is_pickhudata-tapos = ls_request_input_data-tapos.
    is_pickhudata-pmtext = ls_request_input_data-pmtext.
    is_pickhudata-pmat = ls_request_input_data-pmat.
    is_pickhudata-is_recommended = ls_request_input_data-is_recommended.

* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_FAP_CREATE_PICKHU'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              is_pickhudata  = is_pickhudata
            IMPORTING
              es_pickhu_keys = es_pickhu_keys
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
          is_pickhudata         = is_pickhudata
        IMPORTING
          es_pickhu_keys        = es_pickhu_keys
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
        ) .
*-------------------------------------------------------------------------*
*             - Read After Create -
*-------------------------------------------------------------------------*
    CREATE OBJECT lo_tech_read_request_context.

* Create key table for the read operation

    ls_key-name = 'HUIDENT'.
    ls_key-value = es_pickhu_keys-huident.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'WHO'.
    ls_key-value = es_pickhu_keys-who.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'LGNUM'.
    ls_key-value = es_pickhu_keys-lgnum.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'HUKNG'.
    ls_key-value = es_pickhu_keys-hukng.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'HUIDENT'.
    ls_key-value = is_pickhudata-huident.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'HUKNG'.
    ls_key-value = is_pickhudata-hukng.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'WHO'.
    ls_key-value = is_pickhudata-who.
    IF ls_key IS NOT INITIAL.
      APPEND ls_key TO lt_keys.
    ENDIF.

    ls_key-name = 'LGNUM'.
    ls_key-value = is_pickhudata-lgnum.
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
        iv_entity_name     = iv_entity_name
        iv_entity_set_name = iv_entity_set_name
        iv_source_name     = iv_source_name
        it_key_tab         = it_key_tab
        io_tech_request_context = lo_tech_read_request_context
        it_navigation_path = it_navigation_path
      IMPORTING
        er_entity          = ls_entity ).

* Send the read response to the caller interface
    ASSIGN ls_entity->* TO <ls_data>.
    er_entity = <ls_data>.
  ENDMETHOD.


  METHOD pickhuset_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA es_pickhudata TYPE zif_z_vi02_fap_read_pickhu=>zzs_vi02_fap_pick_hu.
    DATA is_pickhu_keys TYPE zif_z_vi02_fap_read_pickhu=>zzs_vi02_fap_read_pick_hu.
    DATA et_return  TYPE zif_z_vi02_fap_read_pickhu=>__bapiret2.
    DATA ls_et_return  TYPE LINE OF zif_z_vi02_fap_read_pickhu=>__bapiret2.
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

    IF lv_source_entity_set_name = 'PickHuSet' AND
       lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

      io_tech_request_context->get_converted_source_keys(
      IMPORTING es_key_values = ls_converted_keys ).

    ENDIF.

    is_pickhu_keys-who = ls_converted_keys-who.
    is_pickhu_keys-hukng = ls_converted_keys-hukng.
    is_pickhu_keys-huident = ls_converted_keys-huident.
    is_pickhu_keys-lgnum = ls_converted_keys-lgnum.
* Get RFC destination
    lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
    lv_rfc_name = 'Z_VI02_FAP_READ_PICKHU'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              is_pickhu_keys = is_pickhu_keys
            IMPORTING
              es_pickhudata  = es_pickhudata
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
          is_pickhu_keys        = is_pickhu_keys
        IMPORTING
          es_pickhudata         = es_pickhudata
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

    er_entity-pmtyp_text = es_pickhudata-pmtyp_text.
    er_entity-who = es_pickhudata-who.
    er_entity-hukng = es_pickhudata-hukng.
    er_entity-huident = es_pickhudata-huident.
    er_entity-is_recommended = es_pickhudata-is_recommended.
    er_entity-pmtext = es_pickhudata-pmtext.
    er_entity-tapos = es_pickhudata-tapos.
    er_entity-tanum = es_pickhudata-tanum.
    er_entity-hutyp_text = es_pickhudata-hutyp_text.
    er_entity-hutyp = es_pickhudata-hutyp.
    er_entity-lgnum = es_pickhudata-lgnum.
    er_entity-pmtyp = es_pickhudata-pmtyp.
    er_entity-pmat_guid = es_pickhudata-pmat_guid.
    er_entity-pmat = es_pickhudata-pmat.
    er_entity-rsrc = es_pickhudata-rsrc.
    er_entity-lgpla = es_pickhudata-lgpla.
  ENDMETHOD.


  METHOD scanhandlingunit_get_entity.
*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
 DATA es_huheader TYPE zif_z_vi02_fap_readhu=>zzs_vi02_fap_huheader.
 DATA is_hukeys TYPE zif_z_vi02_fap_readhu=>zzs_vi02_scanhu_keys.
 DATA et_return  TYPE zif_z_vi02_fap_readhu=>__bapiret2.
 DATA ls_et_return  TYPE LINE OF zif_z_vi02_fap_readhu=>__bapiret2.
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

      IF lv_source_entity_set_name = 'ScanHandlingUnitSet' AND
         lv_source_entity_set_name NE io_tech_request_context->get_entity_set_name( ).

        io_tech_request_context->get_converted_source_keys(
        IMPORTING es_key_values = ls_converted_keys ).

      ENDIF.

      is_hukeys-workstation = ls_converted_keys-workstation.
      is_hukeys-lgnum = ls_converted_keys-lgnum.
      is_hukeys-huident = ls_converted_keys-huident.
* Get RFC destination
      lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
      lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

*-------------------------------------------------------------
*  Call RFC function module
*-------------------------------------------------------------
      lv_rfc_name = 'Z_VI02_FAP_READHU'.

      IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

        TRY.
            CALL FUNCTION lv_rfc_name
              EXPORTING
                is_hukeys      = is_hukeys
              IMPORTING
                es_huheader    = es_huheader
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
            is_hukeys             = is_hukeys
          IMPORTING
            es_huheader           = es_huheader
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
      er_entity = CORRESPONDING #( es_huheader ).

  ENDMETHOD.
ENDCLASS.
