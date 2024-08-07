*&---------------------------------------------------------------------*
*& Report Z_VI02_R_FAP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_vi02_r_fap.

TABLES: trdir.
DATA  : lt_itab TYPE STANDARD TABLE OF string,
        lv_mess TYPE string,
        lv_lin  TYPE i,
        lv_wrd  TYPE string.
*        DIR  type TRDIR.

PARAMETERS: p_prgram RADIOBUTTON GROUP prg,
            p_prog   LIKE trdir-name VALUE CHECK,
            p_functn RADIOBUTTON GROUP prg,
            p_func   LIKE tfdir-funcname VALUE CHECK,
            p_no_rc  TYPE xfeld DEFAULT 'X'.

START-OF-SELECTION.

  IF p_functn IS NOT INITIAL.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = p_func
      IMPORTING
        include  = p_prog
      EXCEPTIONS
        OTHERS   = 2.
    CHECK sy-subrc = 0.
  ENDIF.

  SELECT SINGLE * INTO @DATA(ls_dir) FROM trdir WHERE name EQ @p_prog. "#EC CI_ALL_FIELDS_NEEDED
  CHECK sy-subrc EQ 0.

  READ REPORT p_prog INTO lt_itab.

  EDITOR-CALL FOR lt_itab.

  CHECK sy-subrc EQ 0.
  CHECK sy-ucomm EQ 'WB_SAVE'.

  SYNTAX-CHECK FOR lt_itab MESSAGE lv_mess LINE lv_lin WORD lv_wrd PROGRAM ls_dir-name.
  IF sy-subrc NE 0.
    MESSAGE lv_mess TYPE 'S'.
    WRITE: / lv_mess,
           / lv_lin,
           / lv_wrd.
    IF p_no_rc EQ space.
      CHECK sy-subrc NE 0.
    ENDIF.
  ENDIF.

  INSERT REPORT p_prog FROM lt_itab UNICODE ENABLING ls_dir-uccheck. "#EC CI_NOFIELD
  MESSAGE text-001 TYPE 'S'.
