FUNCTION z_fm_update_material_field.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WMARA) TYPE  MARA
*"     VALUE(WMARC) TYPE  MARC
*"----------------------------------------------------------------------
********************************************************************
* Creation Date: 09.10.2023
* Author, UserID: Natali Petrova, NPETROVA
* Description: FM Update material fields for automatic creation
********************************************************************
  DATA:
    lv_qname      TYPE trfcqin-qname,
    lv_zewm_key   TYPE zewm_de_key,
    lv_rfcdest    TYPE rfcdest,
    lt_whprod     TYPE zewm_whprod_def,
    ls_mat_global TYPE /SCWM/s_material_global,
    ls_mat_lgnum  TYPE /scwm/s_material_lgnum,
    ls_mat_lgtyp  TYPE /scwm/s_material_lgtyp.

  SELECT SINGLE lgnum FROM /scwm/tmapstloc INTO @DATA(lv_lgnum)
      WHERE plant = @wmarc-werks.
  "AND stge_loc = @lv_lgort.
  CHECK sy-subrc = 0.

  SELECT SINGLE entitled FROM /scwm/tmapplant
                         WHERE plant = @wmarc-werks
    INTO @DATA(lv_entitled).

  IF lv_entitled IS INITIAL.
    MESSAGE e001(zewm_mat_upd).
  ENDIF.

  TRY.
      CALL FUNCTION '/SCWM/MATERIAL_READ_SINGLE'
        EXPORTING
          iv_matid      = NEW /scwm/cl_ui_stock_fields( )->get_matid_by_no( wmara-matnr )
          iv_entitled   = lv_entitled
          iv_lgnum      = lv_lgnum
        IMPORTING
          es_mat_lgnum  = ls_mat_lgnum
          es_mat_global = ls_mat_global.
    CATCH /scwm/cx_md.
      MESSAGE e000(zewm_mat_upd).
      CALL FUNCTION 'RESTART_OF_BACKGROUNDTASK'.
  ENDTRY.

  IF ls_mat_lgnum IS INITIAL.
    MESSAGE e000(zewm_mat_upd).
  ENDIF.

  IF wmara-tempb IS NOT INITIAL AND wmara-raube IS NOT INITIAL.
    SELECT SINGLE zewm_key FROM zewm_matmas_keys
                             WHERE werks = @wmarc-werks
                               AND ( tempb = @wmara-tempb OR tempb = @space )
                               AND ( raube = @wmara-raube OR raube = @space )
                               AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                               "AND lgort = @lv_lgort
                               AND matnr = @wmara-matnr
           INTO @lv_zewm_key.

    IF sy-subrc <> 0.
      SELECT SINGLE zewm_key FROM zewm_matmas_keys
                             WHERE werks = @wmarc-werks
                               AND ( tempb = @wmara-tempb OR tempb = @space )
                               AND ( raube = @wmara-raube OR raube = @space )
                               AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                               "AND lgort = @lv_lgort
                               AND matnr = @space
        INTO @lv_zewm_key.
    ENDIF.

  ELSEIF wmara-tempb IS NOT INITIAL.
    SELECT SINGLE zewm_key FROM zewm_matmas_keys
                         WHERE werks = @wmarc-werks
                           AND ( tempb = @wmara-tempb OR tempb = @space )
                           AND ( raube = @space )
                           AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                           "AND lgort = @lv_lgort
                           AND matnr = @wmara-matnr
       INTO @lv_zewm_key.

    IF sy-subrc <> 0.
      SELECT SINGLE zewm_key FROM zewm_matmas_keys
                             WHERE werks = @wmarc-werks
                               AND ( tempb = @wmara-tempb OR tempb = @space )
                               AND ( raube = @space )
                               AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                               "AND lgort = @lv_lgort
                               AND matnr = @space
        INTO @lv_zewm_key.
    ENDIF.

  ELSEIF wmara-raube IS NOT INITIAL.
    SELECT SINGLE zewm_key FROM zewm_matmas_keys
                      WHERE werks = @wmarc-werks
                        AND ( raube = @wmara-raube OR raube = @space )
                        AND ( tempb = @space )
                        AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                        "AND lgort = @lv_lgort
                        AND matnr = @wmara-matnr
      INTO @lv_zewm_key.

    IF sy-subrc <> 0.
      SELECT SINGLE zewm_key FROM zewm_matmas_keys
                             WHERE werks = @wmarc-werks
                               AND ( raube = @wmara-raube OR raube = @space )
                               AND ( tempb = @space )
                               AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                               "AND lgort = @lv_lgort
                               AND matnr = @space
        INTO @lv_zewm_key.
    ENDIF.

  ELSE.
    SELECT SINGLE zewm_key FROM zewm_matmas_keys
                    WHERE werks = @wmarc-werks
                      AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                      AND ( tempb = @space )
                      AND ( raube = @space )
                      "AND lgort = @lv_lgort
                      AND matnr = @wmara-matnr
      INTO @lv_zewm_key.

    IF sy-subrc <> 0.
      SELECT SINGLE zewm_key FROM zewm_matmas_keys
                             WHERE werks = @wmarc-werks
                               AND ( max_btgew = 0 OR max_btgew >= @wmara-brgew )
                               AND ( tempb = @space )
                               AND ( raube = @space )
                               "AND lgort = @lv_lgort
                               AND matnr = @space
        INTO @lv_zewm_key.
    ENDIF.
  ENDIF.

  IF lv_zewm_key IS NOT INITIAL.
    SELECT SINGLE * FROM zewm_whprod_def WHERE zewm_key = @lv_zewm_key
                    INTO @DATA(ls_whprod_def).

    IF ls_whprod_def IS NOT INITIAL.
      SELECT SINGLE put_stra FROM /scwm/t305q INTO ls_mat_lgnum-put_stra WHERE lgnum = lv_lgnum
                                                                           AND put_stra = ls_whprod_def-put_stra.

      SELECT SINGLE lgbkz FROM /scwm/t304 INTO ls_mat_lgnum-lgbkz WHERE lgnum = lv_lgnum
                                                                    AND lgbkz = ls_whprod_def-lgbkz.

      SELECT SINGLE stckdetgr FROM /scwm/tstckdetgt INTO ls_mat_lgnum-stckdetgr WHERE lgnum = lv_lgnum
                                                                                  AND stckdetgr = ls_whprod_def-stckdetgr.

      SELECT SINGLE drdetgr FROM /scwm/tdrdetgr INTO ls_mat_lgnum-drdetgr WHERE lgnum = lv_lgnum
                                                                            AND drdetgr = ls_whprod_def-drdetgr.

      SELECT SINGLE rem_stra FROM /scwm/t305r INTO ls_mat_lgnum-rem_stra WHERE lgnum = lv_lgnum
                                                                           AND rem_stra = ls_whprod_def-rem_stra.

      SELECT SINGLE ptdetind FROM /scwm/tptdetind INTO ls_mat_lgnum-ptdetind WHERE lgnum = lv_lgnum
                                                                              AND ptdetind = ls_whprod_def-ptdetind.

      TRY.
          CALL FUNCTION '/SCWM/MATERIAL_WHST_MAINT_MULT'
            EXPORTING
              it_mat_lgnum = VALUE /scwm/tt_material_lgnum_maint( ( CORRESPONDING #( ls_mat_lgnum ) ) )
              "it_mat_lgtyp = value /scwm/tt_material_lgtyp_maint( ( CORRESPONDING #( ls_mat_lgtyp ) ) )
              iv_lgnum     = lv_lgnum.
        CATCH /scwm/cx_md_lgnum_locid
              /scwm/cx_md_interface.
      ENDTRY.

    ELSE.
      MESSAGE e003(zewm_mat_upd).
    ENDIF.
*  ELSE.
*    MESSAGE e002(zewm_mat_upd).
  ENDIF.

ENDFUNCTION.
