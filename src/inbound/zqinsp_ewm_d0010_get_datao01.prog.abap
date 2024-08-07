*&---------------------------------------------------------------------*
*& Include          ZQINSP_EWM_D0010_GET_DATAO01
*&---------------------------------------------------------------------*
MODULE D0010_GET_DATA OUTPUT.
*-Get Data from the global attributes of adapter class
  call method go_subscr_1101_qeva->get_data
    exporting
      flt_val  = '17'
    importing
      e_qals   = qals
      e_rqeva  = rqeva.
ENDMODULE.                 " D0010_GET_DATA  OUTPUT
