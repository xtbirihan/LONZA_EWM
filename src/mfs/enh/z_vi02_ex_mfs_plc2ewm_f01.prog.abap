*&---------------------------------------------------------------------*
*&  Include  /SL0/EX_MFS_PLC2EWM_F01
*&---------------------------------------------------------------------*

************************************************************************
* Company     : Swisslog AG
*
* Package     : /SL0/MFS
* Group       : /SL0/MFS_PLC_TO_EWM_OBJ
* Function    : /SL0/MFS_PLC_TO_EWM_OBJ
* Enhancement : BAdI /SCWM/EX_MFS_TELE_PLC2EWMOB
* Description : This ABAP is used to map PLC to SAP EWM Object
*
*
************************************************************************
* REVISIONS:
* ---------
*
* Version ¦ Date       ¦ Author           ¦ Description
* ------- ¦ ---------- ¦ ---------------- ¦ ----------------------------
* 1.0     ¦ 2016-04-24 ¦ B7TARAH          ¦ Initial version
* 1.0     ¦ 2016-06-29 ¦ B7GOKHN          ¦ Encapsulated in EI Framework
*
************************************************************************

" Call to the mapping FM..
CALL FUNCTION '/SL0/MFS_PLC_TO_EWM_OBJ'
  EXPORTING
    iv_lgnum    = iv_lgnum
    iv_plc      = iv_plc
    iv_plcobj   = iv_plcobj
    iv_objtype  = iv_objtype
    is_telegram = is_telegram
  CHANGING
    cv_ewmobj   = cv_ewmobj.

" ------------------------------------------------------------------ "
