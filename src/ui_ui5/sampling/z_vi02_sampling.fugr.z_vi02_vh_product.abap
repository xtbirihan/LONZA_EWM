FUNCTION z_vi02_vh_product.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PRODUCT) TYPE  MATNR
*"  EXPORTING
*"     VALUE(ET_PRODUCT_UOM) TYPE  ZVI02_T_VH_PRODUCT
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    ls_return  TYPE bapiret2,
    lv_product TYPE char18,
    lv_matnr   TYPE mara-matnr.

  go_sampling = lcl_sampling_doc=>get_instance( ).

  IF iv_product IS INITIAL.
*‘Please scan the Sample HU number and not a trolley
    MESSAGE e034(z_vi02_general) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  lv_product = |{ iv_product  ALPHA = IN }|.
  lv_matnr = lv_product.
  go_sampling->product_uoms_read(
    EXPORTING
     iv_product     = lv_matnr
   IMPORTING
     et_product_uom = DATA(lt_product_uom) ).

  et_product_uom = CORRESPONDING #( lt_product_uom ).
ENDFUNCTION.
