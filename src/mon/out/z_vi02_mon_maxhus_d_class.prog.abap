*&---------------------------------------------------------------------*
*& Include          Z_VI02_MON_MAXHUS_D_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_maxhus DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      initialization
        IMPORTING
          iv_repid TYPE sy-repid
        CHANGING
          ct_data  TYPE ANY TABLE.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
