"Name: \PR:SAPLMV02\EX:IDOC_INPUT_MATMAS01_31\EI
ENHANCEMENT 0 ZEWM_IE_IDOC_INPUT_MATMAS31.
********************************************************************
* Creation Date: 22.03.2023
* Author, UserID: Natali Petrova, NPETROVA
* Description: Implicit enhancement for automatic material creation
********************************************************************

  DATA:
    lv_rfcdest TYPE rfcdest,
    lv_qname   TYPE trfcqin-qname,
    ls_wmara   TYPE mara,
    ls_wmarc   TYPE marc.

  DATA(ls_data_mara_ueb) = i_mara_ueb.
  DATA(ls_data_marc_ueb) = i_marc_ueb.

  MOVE-CORRESPONDING ls_data_mara_ueb TO ls_wmara.
  MOVE-CORRESPONDING ls_data_marc_ueb TO ls_wmarc.

  SELECT SINGLE 'X' FROM zewm_whprod_ctl INTO @DATA(lv_xfeld)
    WHERE werks = @ls_wmarc-werks AND
          autowhprod = @abap_true.

  IF sy-subrc = 0.
    CALL FUNCTION 'Z_FM_MATERIAL_FIELD'
      IN UPDATE TASK
      EXPORTING
        is_wmara = ls_wmara
        is_wmarc = ls_wmarc.
  ENDIF.


ENDENHANCEMENT.
