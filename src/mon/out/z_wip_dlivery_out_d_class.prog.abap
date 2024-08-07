*&---------------------------------------------------------------------*
*& Include          Z_WIP_DLIVERY_OUT_D_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_whritem_mon_out DEFINITION FINAL.
  PUBLIC SECTION.

    METHODS:
      initialization
        IMPORTING
          iv_repid TYPE sy-repid
        CHANGING
          ct_data  TYPE ANY TABLE,

      whritem_mapping
        CHANGING ct_mapping TYPE /scwm/tt_map_selopt2field,

      convert_date_time
        IMPORTING
          iv_lgnum     TYPE /scwm/lgnum
          iv_datefrom  TYPE datum
          iv_timefrom  TYPE uzeit
          iv_dateto    TYPE datum
          iv_timeto    TYPE uzeit
        CHANGING
          ct_timestamp TYPE /scwm/tt_timestamp_r,

      fill_selection_table
        IMPORTING
          iv_lgnum       TYPE /scwm/lgnum
        CHANGING
          ct_selection   TYPE /scwm/dlv_selection_tab,

      fill_selection_table_item
        IMPORTING
          iv_lgnum     TYPE /scwm/lgnum
          it_data_parent TYPE /scwm/tt_wip_whrhead_out
        CHANGING
          ct_selection TYPE /scwm/dlv_selection_tab
          cv_error     TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.
