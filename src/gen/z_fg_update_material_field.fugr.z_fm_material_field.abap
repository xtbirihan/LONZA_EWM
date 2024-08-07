FUNCTION z_fm_material_field.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_WMARA) TYPE  MARA
*"     VALUE(IS_WMARC) TYPE  MARC
*"----------------------------------------------------------------------
********************************************************************
* Creation Date: 20.10.2023
* Author, UserID: Natali Petrova, NPETROVA
* Description: Update task to give a chance of the standart to pass
********************************************************************
  DATA: lv_qname TYPE trfcqin-qname.

  CONCATENATE 'ZEWM_MAT_' is_wmara-matnr INTO lv_qname.

  CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
    EXPORTING
      qin_name           = lv_qname
    EXCEPTIONS
      invalid_queue_name = 1
      OTHERS             = 2.

  CALL FUNCTION 'Z_FM_UPDATE_MATERIAL_FIELD'
    IN BACKGROUND TASK
    AS SEPARATE UNIT
    EXPORTING
      wmara = is_wmara
      wmarc = is_wmarc.

ENDFUNCTION.
