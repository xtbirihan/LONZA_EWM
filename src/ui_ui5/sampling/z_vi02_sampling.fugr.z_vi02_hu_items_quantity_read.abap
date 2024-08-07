FUNCTION z_vi02_hu_items_quantity_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_WORKSTATION) TYPE  /SCWM/DE_WORKSTATION
*"     VALUE(IV_HUIDENT) TYPE  /SCWM/DE_HUIDENT
*"  EXPORTING
*"     VALUE(ET_HUITEMS_QUANTITY) TYPE  ZVI02_T_HU_ITEM_QUANTITY
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA:
    ls_return  TYPE bapiret2,
    lv_huident TYPE /scwm/de_huident.

  go_sampling = lcl_sampling_doc=>get_instance( ).
  lv_huident = |{ iv_huident ALPHA = IN }|.

  go_sampling->hu_read(
    EXPORTING
      iv_lgnum   = iv_lgnum
      iv_huident = lv_huident
    IMPORTING
      ev_error   = DATA(lv_error)
      es_huhdr   = DATA(ls_header)
      et_huitm   = DATA(lt_huitm) ).
  IF lv_error IS NOT INITIAL.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  LOOP AT lt_huitm INTO DATA(ls_huitem).
    LOOP AT ls_huitem-quan_t ASSIGNING FIELD-SYMBOL(<fs_quan>).
      APPEND INITIAL LINE TO et_huitems_quantity ASSIGNING FIELD-SYMBOL(<fs_huitem_quantity>).
      <fs_huitem_quantity>-huident      = iv_huident.
      <fs_huitem_quantity>-lgnum        = iv_lgnum.
      <fs_huitem_quantity>-guid_hu      = ls_header-guid_hu.
      <fs_huitem_quantity>-workstation  = iv_workstation.
      <fs_huitem_quantity>-unit         = <fs_quan>-unit.
      <fs_huitem_quantity>-quan         = <fs_quan>-quan.
    ENDLOOP.


  ENDLOOP.

ENDFUNCTION.
