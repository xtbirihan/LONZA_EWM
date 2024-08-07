FUNCTION z_vi02_fap_outbdelv_header .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOCID) TYPE  /SCDL/DL_DOCID
*"  EXPORTING
*"     VALUE(ES_OUTBDELV_HEADER) TYPE  ZZS_VI02_FAP_OUTBDELV_HEADER
*"  TABLES
*"      ET_OUTBDELV_ITEMS STRUCTURE  ZZS_VI02_FAP_OUTBDELV_ITEM
*"       OPTIONAL
*"      ET_RETURN TYPE  BAPIRET2_T OPTIONAL
*"----------------------------------------------------------------------
  DATA: ls_outbdelv_items TYPE zzs_vi02_fap_outbdelv_item.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  TRY.
      go_floor_area_picking->lif_isolated_doc_delivery~query(
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

      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).

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

      RETURN.
  ENDTRY.

  DATA(ls_header) = VALUE #( lt_headers[ 1 ] OPTIONAL ).
  es_outbdelv_header = CORRESPONDING #( ls_header ).

  IF et_outbdelv_items IS SUPPLIED.
    LOOP AT lt_items INTO DATA(ls_items).
      ls_outbdelv_items =  CORRESPONDING #( ls_items EXCEPT qty  ).
      ls_outbdelv_items-qty = ls_items-qty-qty.
      ls_outbdelv_items-uom = ls_items-qty-uom.
      APPEND ls_outbdelv_items TO et_outbdelv_items.
      CLEAR: ls_outbdelv_items.
    ENDLOOP.
  ENDIF.


ENDFUNCTION.
