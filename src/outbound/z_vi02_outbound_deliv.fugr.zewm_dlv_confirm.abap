FUNCTION zewm_dlv_confirm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_ORDIM_C) TYPE  /SCWM/TT_ORDIM_C
*"----------------------------------------------------------------------
  DATA: lt_od_creation  TYPE /scwm/dlv_od_create_tab.

  DATA(lo_dlv_management_prd) = /scwm/cl_dlv_management_prd=>get_instance( ).
  TRY.
      lo_dlv_management_prd->query(
        EXPORTING
          it_docid                    = VALUE #( FOR <ls_ordim_c> IN it_ordim_c
                                                   ( doccat = wmegc_doccat_pdo
                                                     docid = <ls_ordim_c>-rdocid ) )
          is_read_options             = VALUE #( item_part_select = abap_true
                                                 mix_in_object_instances = abap_true
                                                 data_retrival_only      = abap_true )
          is_include_data             = VALUE #( )
        IMPORTING
          et_headers                  = DATA(lt_headers)
          et_items                    = DATA(lt_items) ).

      LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<ls_head>).
        APPEND VALUE #( doccat = wmegc_doccat_pdo
                        docid = <ls_head>-docid
                        items = VALUE #( FOR <ls_item> IN lt_items
                                          WHERE ( docid = <ls_head>-docid )
                                          ( CORRESPONDING #( <ls_item> ) ) ) )
                  TO lt_od_creation.
      ENDLOOP.

      lo_dlv_management_prd->create_od(
        EXPORTING
          it_od_creation = lt_od_creation
        IMPORTING
          eo_message     = DATA(lo_message)
          et_od_created  = DATA(lt_od_created)  ).

      lo_dlv_management_prd->save(
        IMPORTING
          ev_rejected = DATA(lv_rejected)
          et_message  = DATA(lt_message) ).

      COMMIT WORK AND WAIT.
      lo_dlv_management_prd->cleanup( ).
    CATCH /scdl/cx_delivery. " For New Exceptions Use /SCDL/CX_DELIVERY_T100
  ENDTRY.
ENDFUNCTION.
