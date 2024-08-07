*&---------------------------------------------------------------------*
*& Include          ZQINSP_EWM_D0010_INITO01
*&---------------------------------------------------------------------*

MODULE D0010_INIT OUTPUT.
*--Referenz auf die Instanz der Adapterklasse besorgen
  if go_subscr_1101_qeva is initial.
    call method cl_exithandler=>get_instance_for_subscreens
      changing
        instance = go_subscr_1101_qeva.
*  EXCEPTIONS
*    NO_REFERENCE                  = 1
*    NO_INTERFACE_REFERENCE        = 2
*    NO_EXIT_INTERFACE             = 3
*    DATA_INCONS_IN_EXIT_MANAGEM   = 4
*    CLASS_NOT_IMPLEMENT_INTERFACE = 5
*    others                        = 6

    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.
ENDMODULE.
