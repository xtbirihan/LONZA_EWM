FUNCTION z_vi02_fap_outbdelv_item.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOCID) TYPE  /SCDL/DL_DOCID
*"     VALUE(IV_ITEMID) TYPE  /SCDL/DL_ITEMID
*"  EXPORTING
*"     VALUE(ES_OUTBDELV_ITEM) TYPE  ZZS_VI02_FAP_OUTBDELV_ITEM
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  TRY.
      go_floor_area_picking->lif_isolated_doc_delivery~query(
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

  DATA(ls_items) = VALUE #( lt_items[ 1 ] OPTIONAL ).

  es_outbdelv_item =  CORRESPONDING #( ls_items EXCEPT qty  ).
  es_outbdelv_item-qty = ls_items-qty-qty.
  es_outbdelv_item-uom = ls_items-qty-uom.
ENDFUNCTION.
