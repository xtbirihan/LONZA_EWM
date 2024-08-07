FUNCTION z_vi02_get_user_default.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ES_S_T300T) TYPE  /SCWM/S_T300T
*"----------------------------------------------------------------------
  go_sampling = lcl_sampling_doc=>get_instance( ).
  DATA(lv_parameter_value) = go_sampling->get_parameter_from_memory( iv_parameter_id = lif_isolated_doc=>c_user_parameters-lgn ).
  IF lv_parameter_value IS INITIAL.
    lv_parameter_value = go_sampling->get_user_parameter( iv_parameter_id = lif_isolated_doc=>c_user_parameters-lgn ).
  ENDIF.

  IF lv_parameter_value IS INITIAL.
    lv_parameter_value = go_sampling->get_lgnum_from_transaction_mgr( ).
  ENDIF.

  IF lv_parameter_value IS INITIAL.
    DATA(ls_rsrc) = go_sampling->read_whnbr_of_resource( ).
    lv_parameter_value = ls_rsrc-lgnum.
  ENDIF.

  IF lv_parameter_value IS NOT INITIAL.
    go_sampling->t300_read_single(
      EXPORTING
        iv_lgnum = CONV #( lv_parameter_value )
      IMPORTING
        es_t300t = es_s_t300t ).
  ENDIF.
ENDFUNCTION.
