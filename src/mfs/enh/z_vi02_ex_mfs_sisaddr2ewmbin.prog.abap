*&---------------------------------------------------------------------*
*& Include          Z_VI02_EX_MFS_SISADDR2EWMBIN
*&---------------------------------------------------------------------*

************************************************************************
* Company     : Swisslog AG
*
* Package     : Z_VI02_MFS_ENH
* Enhancement : BAdI /SCWM/EX_MFS_TELE_EWM2PLCOB
* Description : This ABAP is used to map PLC Object to SAP EWM
*               called at the beginning of the Method SISADDR2EWMBIN of class
*               /SL0/CL_MFS_PROCESS_HELPER
*
* PARAMETERS:
* ----------
*      IMPORTING
*        !iv_lgnum       TYPE /scwm/lgnum
*        !iv_plc         TYPE /scwm/de_mfsplc
*        !iv_sisaddress  TYPE /scwm/de_mfsplcobj
*        !iv_objtype     TYPE /scwm/de_mfsobjtype DEFAULT wmegc_mfs_ewm_obj_cs
*      EXPORTING
*        !ev_lgpla       TYPE /scwm/lgpla
*        !ev_logpos      TYPE /scwm/de_logpos
*      RETURNING
*        VALUE(rv_lgpla) TYPE /scwm/lgpla .
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦ Date       ¦ Author           ¦ Description
* ------- ¦ ---------- ¦ ---------------- ¦ ----------------------------
* 1.0     ¦ 2023-11-10 ¦ FSPISAK          ¦ Initial version
************************************************************************

    IF iv_lgnum EQ zif_vi02_c=>gc_lgnum-vi02. "VI02

      DATA(lo_helper_vi02) = NEW zcl_vi02_mfs_process_helper( ).
      CALL METHOD lo_helper_vi02->sisaddr2ewmbin
        EXPORTING
          iv_lgnum      = iv_lgnum
          iv_plc        = iv_plc
          iv_sisaddress = iv_sisaddress
          iv_objtype    = iv_objtype
        IMPORTING
          ev_lgpla      = ev_lgpla
          ev_logpos     = ev_logpos
        RECEIVING
          rv_lgpla      = rv_lgpla.

      "so ther rest of the code of the method is ignored
      RETURN.

    ENDIF.
