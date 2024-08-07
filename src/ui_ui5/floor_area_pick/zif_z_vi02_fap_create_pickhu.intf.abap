interface ZIF_Z_VI02_FAP_CREATE_PICKHU
  public .


  types:
    /SCWM/LGNUM type C length 000004 .
  types:
    /SCWM/DE_WHO type N length 000010 .
  types:
    /SCWM/DE_HUKNG type N length 000003 .
  types:
    /SCWM/DE_HUIDENT type C length 000020 .
  types:
    begin of ZZS_VI02_FAP_READ_PICK_HU,
      LGNUM type /SCWM/LGNUM,
      WHO type /SCWM/DE_WHO,
      HUKNG type /SCWM/DE_HUKNG,
      HUIDENT type /SCWM/DE_HUIDENT,
    end of ZZS_VI02_FAP_READ_PICK_HU .
  types:
    /SCWM/DE_LGPLA type C length 000018 .
  types:
    /SCWM/DE_RSRC type C length 000018 .
  types:
    /SCWM/DE_PMAT type C length 000040 .
  types:
    /SCWM/DE_MATID type X length 000016 .
  types:
    /SCWM/DE_PMTYP type C length 000004 .
  types:
    /SCWM/DE_UI_PMTYP_TEXT type C length 000040 .
  types:
    /SCWM/DE_HUTYP type C length 000004 .
  types:
    /SCWM/DE_UI_HUTYP_TEXT type C length 000040 .
  types:
    /SCWM/TANUM type N length 000012 .
  types:
    CHAR4 type C length 000004 .
  types:
    /SCWM/DE_PMAT_DESC type C length 000040 .
  types:
    BOOLE_D type C length 000001 .
  types:
    begin of ZZS_VI02_FAP_PICK_HU,
      LGNUM type /SCWM/LGNUM,
      WHO type /SCWM/DE_WHO,
      HUKNG type /SCWM/DE_HUKNG,
      HUIDENT type /SCWM/DE_HUIDENT,
      LGPLA type /SCWM/DE_LGPLA,
      RSRC type /SCWM/DE_RSRC,
      PMAT type /SCWM/DE_PMAT,
      PMAT_GUID type /SCWM/DE_MATID,
      PMTYP type /SCWM/DE_PMTYP,
      PMTYP_TEXT type /SCWM/DE_UI_PMTYP_TEXT,
      HUTYP type /SCWM/DE_HUTYP,
      HUTYP_TEXT type /SCWM/DE_UI_HUTYP_TEXT,
      TANUM type /SCWM/TANUM,
      TAPOS type CHAR4,
      PMTEXT type /SCWM/DE_PMAT_DESC,
      IS_RECOMMENDED type BOOLE_D,
    end of ZZS_VI02_FAP_PICK_HU .
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
