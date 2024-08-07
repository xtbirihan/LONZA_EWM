interface ZIF_Z_VI02_GM_CREATE
  public .


  types:
    /SCWM/LGNUM type C length 000004 .
  types:
    /SCWM/DE_HUIDENT type C length 000020 .
  types:
    /SCWM/DE_WORKSTATION type C length 000004 .
  types:
    /SCWM/DE_UNIT type C length 000003 .
  types:
    /SCWM/DE_QUANTITY type P length 16  decimals 000014 .
  types:
    begin of ZZS_VI02_UOM_QUANTITY,
      LGNUM type /SCWM/LGNUM,
      HUIDENT type /SCWM/DE_HUIDENT,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      UNIT type /SCWM/DE_UNIT,
      QUAN type /SCWM/DE_QUANTITY,
    end of ZZS_VI02_UOM_QUANTITY .
  types:
    BAPI_MTYPE type C length 000001 .
  types:
    SYMSGID type C length 000020 .
  types:
    SYMSGNO type N length 000003 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    BALOGNR type C length 000020 .
  types:
    BALMNR type N length 000006 .
  types:
    SYMSGV type C length 000050 .
  types:
    BAPI_PARAM type C length 000032 .
  types:
    BAPI_FLD type C length 000030 .
  types:
    BAPILOGSYS type C length 000010 .
  types:
    begin of BAPIRET2,
      TYPE type BAPI_MTYPE,
      ID type SYMSGID,
      NUMBER type SYMSGNO,
      MESSAGE type BAPI_MSG,
      LOG_NO type BALOGNR,
      LOG_MSG_NO type BALMNR,
      MESSAGE_V1 type SYMSGV,
      MESSAGE_V2 type SYMSGV,
      MESSAGE_V3 type SYMSGV,
      MESSAGE_V4 type SYMSGV,
      PARAMETER type BAPI_PARAM,
      ROW type INT4,
      FIELD type BAPI_FLD,
      SYSTEM type BAPILOGSYS,
    end of BAPIRET2 .
  types:
    __BAPIRET2                     type standard table of BAPIRET2                       with non-unique default key .
endinterface.
