FUNCTION z_vi02_gm_create_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_UOM_QUAN) TYPE  ZZS_VI02_UOM_QUANTITY
*"  EXPORTING
*"     VALUE(ES_HUHEADER) TYPE  ZZS_VI02_HU_HEADER
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    lt_return   TYPE TABLE OF bapiret2,
    lv_huident  TYPE /scwm/de_huident,
    ls_huheader TYPE zzs_vi02_hu_header.

  go_sampling = lcl_sampling_doc=>get_instance( ).
  lv_huident = |{ is_uom_quan-huident ALPHA = IN }|.

  CALL FUNCTION 'Z_VI02_HU_HEADER_READ'
    EXPORTING
      iv_lgnum       = is_uom_quan-lgnum
      iv_workstation = is_uom_quan-workstation
      iv_huident     = lv_huident
    IMPORTING
      es_huheader    = es_huheader
    TABLES
      et_return      = lt_return.

  LOOP AT lt_return INTO DATA(ls_return) WHERE type CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    RETURN.
  ENDIF.

*  IF go_sampling->mv_delete_hu = abap_true.
*    go_sampling->delete_hu(
*      iv_whno    = is_uom_quan-lgnum
*      it_huident = VALUE #( ( huident = IS_UOM_QUAN-huident ) )
*    ).
*    CLEAR: go_sampling->mv_delete_hu.
*  ENDIF.
ENDFUNCTION.
