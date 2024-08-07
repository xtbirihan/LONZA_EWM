*&---------------------------------------------------------------------*
*& Include          Z_VI02_MON_SAMPLING_D_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_sampling DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      initialization
        IMPORTING
          iv_repid TYPE sy-repid
        CHANGING
          ct_data  TYPE ANY TABLE,
      create_mapping
        CHANGING ct_mapping TYPE /scwm/tt_map_selopt2field,
      create_alv.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_call_off  TYPE REF TO cl_gui_alv_grid,
                go_call_cont TYPE REF TO cl_gui_custom_container.
ENDCLASS.
