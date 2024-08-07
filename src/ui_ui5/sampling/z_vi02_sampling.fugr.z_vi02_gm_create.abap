FUNCTION z_vi02_gm_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_UOM_QUAN) TYPE  ZZS_VI02_UOM_QUANTITY
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    lt_return           TYPE TABLE OF bapiret2,
    ls_return           TYPE bapiret2,
    lv_huident          TYPE /scwm/de_huident,
    ls_huheader         TYPE zzs_vi02_hu_header,
    lt_huitems          TYPE zvi02_t_hu_item,
    lt_huitems_quantity TYPE zvi02_t_hu_item_quantity,
    ls_gm_header        TYPE /scwm/s_gmheader,
    lt_gm_item          TYPE /scwm/tt_gmitem,
    ls_gm_item          TYPE /scwm/s_gmitem,
    ls_quan             TYPE /scwm/s_quan,
    lo_acc_cust         TYPE REF TO /scwm/cl_acc_cust,
    ls_reasoncode       TYPE /scwm/s_reasoncode.


  IF is_uom_quan-quan <= 0.
    MESSAGE e033(z_vi02_general) WITH TEXT-002 INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  IF is_uom_quan-unit IS INITIAL.
    MESSAGE e033(z_vi02_general) WITH TEXT-003 INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  go_sampling = lcl_sampling_doc=>get_instance( ).
*  go_sampling->mv_delete_hu = abap_false.
  lv_huident = |{ is_uom_quan-huident ALPHA = IN }|.

  CALL FUNCTION 'Z_VI02_HU_READ_ALL_DETAILS'
    EXPORTING
      iv_lgnum            = is_uom_quan-lgnum
      iv_workstation      = is_uom_quan-workstation
      iv_huident          = lv_huident
    IMPORTING
      es_huheader         = ls_huheader
      et_huitems          = lt_huitems
      et_huitems_quantity = lt_huitems_quantity
    TABLES
      et_return           = lt_return.
  LOOP AT lt_return INTO ls_return WHERE type CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    APPEND LINES OF lt_return TO et_return.
    RETURN.
  ENDIF.

  IF lt_huitems IS INITIAL.
    MESSAGE e146(/scwm/hugeneral) INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  DATA(ls_huitems) = VALUE #( lt_huitems[ 1 ] OPTIONAL ).

***  DATA(lv_flg_suom) = go_sampling->check_is_uom_stock_relevant(
***    EXPORTING
***      iv_lgnum    = is_uom_quan-lgnum
***      iv_matid    = ls_huitems-matid
***      iv_uom      = is_uom_quan-unit ).
***
***  IF lv_flg_suom IS INITIAL.
***    MESSAGE e213(/scwm/hugeneral) WITH is_uom_quan-unit
***                                       ls_huitems-matnr INTO lv_message.
***    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
***    ls_return-row = VALUE #( ).
***    APPEND ls_return TO et_return.
***    RETURN.
***  ENDIF.

  go_sampling->all_uoms_of_product_read(
    EXPORTING
      iv_lgnum    = is_uom_quan-lgnum
      iv_matid    = ls_huitems-matid
      iv_entitled = ls_huitems-entitled
    IMPORTING
      ev_buom     = DATA(lv_base_uom)
      ev_puom     = DATA(lv_alternative_uom)
      et_mat_uom  = DATA(lt_material_all_uom)
  ).

  TRY.
      go_sampling->material_quan_convert(
        EXPORTING
          iv_matid     = ls_huitems-matid
          iv_quan      = is_uom_quan-quan
          iv_unit_from = lv_base_uom
          iv_unit_to   = is_uom_quan-unit
          iv_batchid   = ls_huitems-batchid
        IMPORTING
          ev_quan      = DATA(lv_quan)  ).
    CATCH /scwm/cx_md_interface.          " Import Parameter Incorrect
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    CATCH /scwm/cx_md_batch_required.     " Batch is required for conversion
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    CATCH /scwm/cx_md_internal_error.     " Internal Error
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    CATCH /scwm/cx_md_batch_not_required. " Material not subject to batch management, no batch required
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
    CATCH /scwm/cx_md_material_exist.     " Material does not exist
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
  ENDTRY.

* header data
  ls_gm_header-lgnum      = is_uom_quan-lgnum.
  ls_gm_header-created_by = sy-uname.
  ls_gm_header-code       = wmegc_gmcode_post.
  ls_gm_header-post       = abap_true.
  ls_gm_header-compl      = abap_true.

* item data
  ls_gm_item-id = 1.
  ls_gm_item-id_group = 3.
  ls_gm_item-guid_hu = ls_huitems-guid_parent.

*     move stock attributes
  MOVE-CORRESPONDING ls_huitems TO ls_gm_item-source_s.     "#EC ENHOK
  MOVE-CORRESPONDING ls_huitems TO ls_gm_item-dest_s.       "#EC ENHOK
  CLEAR: ls_gm_item-dest_s-guid_stock,
         ls_gm_item-dest_s-guid_stock0,
         ls_gm_item-dest_s-stock_cnt.

  ls_gm_item-direction  = wmegc_lime_post_outbound.



  CALL FUNCTION '/SCWM/TREASON_READ_SINGLE'
    EXPORTING
      iv_lgnum      = is_uom_quan-lgnum
      iv_reason     = wmegc_lime_reason_smpl
    IMPORTING
      es_reasoncode = ls_reasoncode
    EXCEPTIONS
      not_found     = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ls_gm_item-reason     = ls_reasoncode-reason.

  lo_acc_cust = /scwm/cl_acc_cust=>get_instance( ).
  lo_acc_cust->get( EXPORTING iv_lgnum = is_uom_quan-lgnum IMPORTING et_acc_cat = DATA(lt_acc_cat) ).

  DATA(ls_acc_cat) = VALUE #( lt_acc_cat[ acc_obj_comp = 'COSTCENTER' ] OPTIONAL ).
*CREATE OBJECT lo_acc.
  ls_gm_item-acc_obj = ls_huitems-kostl.
  ls_gm_item-acc_cat = ls_acc_cat-acc_cat.
*      ls_gm_item-acc_obj_sub = is_acc_data-acc_obj_sub.

  "Quantity
  CLEAR: ls_gm_item-t_quan.
  ls_quan-quan = lv_quan.
  ls_quan-unit = is_uom_quan-unit.

  APPEND ls_quan TO ls_gm_item-t_quan.
  APPEND ls_gm_item TO lt_gm_item.

  go_sampling->call_gm_save_memory( ).

  TRY.
      go_sampling->gm_create(
        EXPORTING
          is_header   = ls_gm_header
          it_item     = lt_gm_item
        IMPORTING
          ev_tanum    = DATA(lv_tanum)
          et_bapiret  = DATA(lt_bapiret)
          ev_severity = DATA(lv_severity)
      ).
    CATCH /scwm/cx_core.
      ROLLBACK WORK.
      /scwm/cl_tm=>cleanup( ).
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
  ENDTRY.
  IF lt_bapiret IS NOT INITIAL.
    APPEND LINES OF lt_bapiret TO et_return.
  ENDIF.
  IF lv_tanum IS NOT INITIAL.
    MESSAGE s022(/scwm/gm) WITH lv_tanum INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
*    RETURN.
  ENDIF.
  LOOP AT lt_bapiret INTO DATA(ls_bapiret) WHERE type CA 'EXA'.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    RETURN.
  ENDIF.

*  CLEAR: ls_huheader, lt_huitems, lt_huitems_quantity.
*  CALL FUNCTION 'Z_VI02_HU_READ_ALL_DETAILS'
*    EXPORTING
*      iv_lgnum            = is_uom_quan-lgnum
*      iv_workstation      = is_uom_quan-workstation
*      iv_huident          = lv_huident
*    IMPORTING
*      es_huheader         = ls_huheader
*      et_huitems          = lt_huitems
*      et_huitems_quantity = lt_huitems_quantity
*    TABLES
*      et_return           = lt_return.
*  IF lt_huitems IS INITIAL.
*    go_sampling->mv_delete_hu = abap_true.
*  ENDIF.
ENDFUNCTION.
