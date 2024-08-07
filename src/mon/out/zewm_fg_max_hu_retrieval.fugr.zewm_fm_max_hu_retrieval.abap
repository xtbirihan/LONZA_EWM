FUNCTION zewm_fm_max_hu_retrieval.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"----------------------------------------------------------------------
gv_lgnum = iv_lgnum.

  CALL SCREEN 0100
    STARTING AT 45 5
    ENDING AT 100 14.

ENDFUNCTION.
