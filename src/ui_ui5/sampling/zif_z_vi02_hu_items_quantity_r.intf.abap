interface ZIF_Z_VI02_HU_ITEMS_QUANTITY_R
  public .


  types:
    /SCWM/LGNUM type C length 000004 .
  types:
    /SCWM/GUID_HU type X length 000016 .
  types:
    /SCWM/DE_HUIDENT type C length 000020 .
  types:
    /SCWM/DE_WORKSTATION type C length 000004 .
  types:
    /LIME/GUID_PARENT type X length 000016 .
  types:
    /LIME/GUID_STOCK type X length 000016 .
  types:
    /SCWM/DE_UNIT type C length 000003 .
  types:
    /SCWM/DE_QUANTITY type P length 16  decimals 000014 .
  types:
    begin of ZZS_VI02_HU_ITEM_QUANTITY,
      LGNUM type /SCWM/LGNUM,
      GUID_HU type /SCWM/GUID_HU,
      HUIDENT type /SCWM/DE_HUIDENT,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      GUID_PARENT type /LIME/GUID_PARENT,
      GUID_STOCK type /LIME/GUID_STOCK,
      UNIT type /SCWM/DE_UNIT,
      QUAN type /SCWM/DE_QUANTITY,
    end of ZZS_VI02_HU_ITEM_QUANTITY .
  types:
    ZVI02_T_HU_ITEM_QUANTITY       type standard table of ZZS_VI02_HU_ITEM_QUANTITY      with non-unique default key .
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
