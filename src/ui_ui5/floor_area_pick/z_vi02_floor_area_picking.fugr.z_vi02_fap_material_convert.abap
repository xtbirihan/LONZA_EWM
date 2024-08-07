FUNCTION z_vi02_fap_material_convert.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATID) TYPE  /SCWM/DE_MATID
*"     VALUE(IV_QUAN) TYPE  /SCWM/DE_QUANTITY
*"     VALUE(IV_UNIT_FROM) TYPE  /SCWM/DE_UNIT
*"     VALUE(IV_UNIT_TO) TYPE  /SCWM/DE_UNIT
*"     VALUE(IV_BATCHID) TYPE  /SCWM/DE_BATCHID
*"  EXPORTING
*"     VALUE(EV_QUAN) TYPE  /SCWM/DE_QUANTITY
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).
  TRY.
      go_floor_area_picking->lif_isolated_doc_material~material_quan_convert(
        EXPORTING
          iv_matid     = iv_matid
          iv_quan      = iv_quan
          iv_unit_from = iv_unit_from
          iv_unit_to   = iv_unit_to
          iv_batchid   = iv_batchid
        IMPORTING
          ev_quan     = ev_quan
      ).
    CATCH /scwm/cx_md_interface
          /scwm/cx_md_batch_required
          /scwm/cx_md_internal_error
          /scwm/cx_md_batch_not_required
          /scwm/cx_md_material_exist.
      go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
      RETURN.
  ENDTRY.

ENDFUNCTION.
