FUNCTION z_vi02_hu_whse_task_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_KEYS) TYPE  ZZS_VI02_HU_WT_KEYS
*"  EXPORTING
*"     VALUE(ES_HU_WHSE_TASK) TYPE  ZZS_VI02_HU_WT
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA:
    ls_return TYPE bapiret2,
    lt_tanum  TYPE /scwm/if_api_whse_task=>yt_wht_tanum.

  go_sampling = lcl_sampling_doc=>get_instance( ).

  IF is_keys-lgnum IS INITIAL.
    MESSAGE e009(/scwm/l1) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  IF is_keys-tanum IS INITIAL.
    MESSAGE e001(/scwm/wm_sel) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

* "read
  DATA(ls_read) = VALUE /scwm/if_api_whse_task=>ys_read( ordim_o   = abap_true ordim_os  = abap_true
                                                         ordim_c   = abap_true ordim_cs  = abap_true
                                                         ordim_e   = abap_true ).

  lt_tanum = VALUE #( ( tanum = is_keys-tanum ) ).

  go_sampling->whse_task_read(
       EXPORTING
        iv_whno     = is_keys-lgnum
        is_read     = ls_read
        it_tanum    = lt_tanum
      IMPORTING
        eo_message  = DATA(lo_message)
        et_wht_data = DATA(lt_wht_data) ).

  DATA(lv_error) = lo_message->check( iv_msgty = /scwm/if_api_message=>sc_msgty_error ).
  IF lv_error IS NOT INITIAL.
    lo_message->get_messages( IMPORTING et_bapiret = DATA(lt_bapiret) ).
    APPEND LINES OF lt_bapiret TO et_return[].
    RETURN.
  ENDIF.

  DATA(ls_wht_data) = VALUE #( lt_wht_data[ tanum = is_keys-tanum ] OPTIONAL ).
  IF ls_wht_data-t_ordim_o IS NOT INITIAL.
    DATA(ls_ordim_o) = VALUE #( ls_wht_data-t_ordim_o[ tanum = is_keys-tanum  ] OPTIONAL ).
    es_hu_whse_task = CORRESPONDING #( ls_ordim_o ).
  ELSEIF ls_wht_data-t_ordim_c IS NOT INITIAL.
    DATA(ls_ordim_c) = VALUE #( ls_wht_data-t_ordim_c[ tanum = is_keys-tanum  ] OPTIONAL ).
    es_hu_whse_task = CORRESPONDING #( ls_ordim_c ).
  ENDIF.
ENDFUNCTION.
