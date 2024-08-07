FUNCTION z_vi02_fap_huidentifier_single.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_FKEY) TYPE  Z_DE_FKEY
*"  EXPORTING
*"     VALUE(ES_MAPPING) TYPE  ZZS_VI02_EXC_MAPPING
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    ls_return TYPE bapiret2,
    lv_tabix  TYPE sy-tabix.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  IF iv_lgnum IS INITIAL OR iv_fkey IS INITIAL.
    MESSAGE e039(z_vi02_general) INTO DATA(lv_message).
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  go_floor_area_picking->exception_mapping(
       EXPORTING
         iv_lgnum   = iv_lgnum
         iv_fkey    = iv_fkey
       IMPORTING
         es_mapping = es_mapping ).
*        et_mapping
  IF es_mapping IS INITIAL.
    MESSAGE e033(z_vi02_general) WITH TEXT-004 INTO lv_message.
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.




ENDFUNCTION.
