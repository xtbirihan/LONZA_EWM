FUNCTION z_vi02_fap_read_pickhu.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_PICKHU_KEYS) TYPE  ZZS_VI02_FAP_READ_PICK_HU
*"  EXPORTING
*"     VALUE(ES_PICKHUDATA) TYPE  ZZS_VI02_FAP_PICK_HU
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA:
    ls_return  TYPE bapiret2,
    lv_tabix   TYPE sy-tabix,
    lv_huident TYPE /scwm/de_huident.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  lv_huident = |{ is_pickhu_keys-huident  ALPHA = IN }|.

  go_floor_area_picking->lif_isolated_doc_pickhu~get_pick_hus_by_wo(
      EXPORTING
        iv_warehouseorder = is_pickhu_keys-who
        iv_ewmwarehouse   = is_pickhu_keys-lgnum
      IMPORTING
        et_pickhu         = DATA(lt_pickhu) ) .

  SORT lt_pickhu BY huident hukng.

  IF lt_pickhu IS NOT INITIAL.
    READ TABLE lt_pickhu INTO DATA(ls_pickhu) WITH KEY huident = is_pickhu_keys-huident
                                                       hukng   = is_pickhu_keys-hukng BINARY SEARCH.
  ENDIF.
  IF ls_pickhu IS NOT INITIAL.
    es_pickhudata = CORRESPONDING #( ls_pickhu ).
  ENDIF.

ENDFUNCTION.
