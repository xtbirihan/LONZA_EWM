FUNCTION z_vi02_hu_read_all_details.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_WORKSTATION) TYPE  /SCWM/DE_WORKSTATION
*"     VALUE(IV_HUIDENT) TYPE  /SCWM/DE_HUIDENT
*"  EXPORTING
*"     VALUE(ES_HUHEADER) TYPE  ZZS_VI02_HU_HEADER
*"     VALUE(ET_HUITEMS) TYPE  ZVI02_T_HU_ITEM
*"     VALUE(ET_HUITEMS_QUANTITY) TYPE  ZVI02_T_HU_ITEM_QUANTITY
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    ls_return  TYPE bapiret2,
    lv_huident TYPE /scwm/de_huident.

  CALL FUNCTION 'Z_VI02_HU_HEADER_READ'
    EXPORTING
      iv_lgnum       = iv_lgnum
      iv_workstation = iv_workstation
      iv_huident     = iv_huident
    IMPORTING
      es_huheader    = es_huheader
    TABLES
      et_return      = et_return.
  IF et_return IS NOT INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION 'Z_VI02_HU_ITEMS_READ'
    EXPORTING
      iv_lgnum       = iv_lgnum
      iv_workstation = iv_workstation
      iv_huident     = iv_huident
    IMPORTING
      et_huitems     = et_huitems
    TABLES
      et_return      = et_return.

  CALL FUNCTION 'Z_VI02_HU_ITEMS_QUANTITY_READ'
    EXPORTING
      iv_lgnum            = iv_lgnum
      iv_workstation      = iv_workstation
      iv_huident          = iv_huident
    IMPORTING
      et_huitems_quantity = et_huitems_quantity
    TABLES
      et_return           = et_return.

ENDFUNCTION.
