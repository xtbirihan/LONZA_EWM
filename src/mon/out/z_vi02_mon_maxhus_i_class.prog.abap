*&---------------------------------------------------------------------*
*& Include          Z_VI02_MON_MAXHUS_I_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_maxhus IMPLEMENTATION.
  METHOD initialization.
    REFRESH ct_data.
    CALL FUNCTION '/SCWM/DYNPRO_ELEMENTS_CLEAR'
      EXPORTING
        iv_repid = iv_repid.
  ENDMETHOD.

  ENDCLASS.
