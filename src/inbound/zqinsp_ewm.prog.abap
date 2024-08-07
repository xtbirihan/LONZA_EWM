*&---------------------------------------------------------------------*
*& Report ZQINSP_EWM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zqinsp_ewm.
tables: qals, rqeva.

data:   go_subscr_1101_qeva  type ref to if_ex_qeva_subscreen_1101.
INCLUDE zqinsp_ewm_d0010_inito01.

INCLUDE zqinsp_ewm_d0010_get_datao01.
