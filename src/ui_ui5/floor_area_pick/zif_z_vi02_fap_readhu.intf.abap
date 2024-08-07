interface ZIF_Z_VI02_FAP_READHU
  public .


  types:
    /SCWM/LGNUM type C length 000004 .
  types:
    /SCWM/DE_WORKSTATION type C length 000004 .
  types:
    /SCWM/DE_HUIDENT type C length 000020 .
  types:
    /SCWM/DE_HUTYP type C length 000004 .
  types:
    /SCWM/DE_PMTYP type C length 000004 .
  types:
    /SCWM/DE_PACKGR type C length 000004 .
  types:
    /SCWM/DE_MATID type X length 000016 .
  types:
    /SCWM/DE_PMAT type C length 000040 .
  types:
    /SCWM/DE_PMAT_DESC type C length 000040 .
  types:
    /SCWM/DE_MATNR type C length 000040 .
  types:
    /SCWM/DE_UI_MAKTX type C length 000040 .
  types:
    /SCWM/DE_UI_QUAN type P length 7  decimals 000003 .
  types:
    /SCWM/DE_BASE_UOM type C length 000003 .
  types:
    /SCWM/DE_UI_QUAN_PACKED type P length 7  decimals 000003 .
  types:
    /SCWM/DE_AUNIT type C length 000003 .
  types:
    /SCWM/DE_CAT type C length 000002 .
  types:
    /SCWM/DE_CAT_TXT type C length 000030 .
  types:
    /SCWM/DE_CHARG type C length 000010 .
  types:
    /SCWM/DE_OWNER type C length 000010 .
  types:
    /SCWM/DE_ENTITLED type C length 000010 .
  types:
    /SCMB/DE_HNDLCODE type C length 000004 .
  types:
    /SCWM/DE_DESC40 type C length 000040 .
  types:
    /SCWM/LTAP_NLENR type C length 000020 .
  types:
    /SCWM/TANUM type N length 000012 .
  types:
    /SCWM/DE_WHO type N length 000010 .
  types:
    /SCWM/DE_NWEIGHT type P length 8  decimals 000003 .
  types:
    /SCWM/DE_WGT_UOM type C length 000003 .
  types:
    /SCWM/DE_NVOLUME type P length 8  decimals 000003 .
  types:
    /SCWM/DE_VOL_UOM type C length 000003 .
  types:
    /SCWM/DE_DOCCAT type C length 000003 .
  types:
    /SCWM/DE_DOCID type X length 000016 .
  types:
    /SCWM/DE_ITMID type X length 000016 .
  types:
    /SCWM/DE_HUKNG type N length 000003 .
  types:
    /SCWM/DE_LGPLA type C length 000018 .
  types:
    /SCWM/DE_RSRC type C length 000018 .
  types:
    /SCWM/DE_UI_PMTYP_TEXT type C length 000040 .
  types:
    /SCWM/DE_UI_HUTYP_TEXT type C length 000040 .
  types:
    CHAR4 type C length 000004 .
  types:
    BOOLE_D type C length 000001 .
  types:
    begin of ZZS_VI02_FAP_HUHEADER,
      LGNUM type /SCWM/LGNUM,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      HUIDENT type /SCWM/DE_HUIDENT,
      LETYP type /SCWM/DE_HUTYP,
      SUBHU1 type /SCWM/DE_HUIDENT,
      SUBHU2 type /SCWM/DE_HUIDENT,
      PMTYP type /SCWM/DE_PMTYP,
      PACKGR type /SCWM/DE_PACKGR,
      PMAT_GUID type /SCWM/DE_MATID,
      PMAT type /SCWM/DE_PMAT,
      PMTEXT type /SCWM/DE_PMAT_DESC,
      MATID type /SCWM/DE_MATID,
      MATNR type /SCWM/DE_MATNR,
      MAKTX type /SCWM/DE_UI_MAKTX,
      QUAN_AFTER type /SCWM/DE_UI_QUAN,
      QUAN type /SCWM/DE_UI_QUAN,
      MEINS type /SCWM/DE_BASE_UOM,
      QUANA type /SCWM/DE_UI_QUAN_PACKED,
      ALTME type /SCWM/DE_AUNIT,
      CAT type /SCWM/DE_CAT,
      CAT_TXT type /SCWM/DE_CAT_TXT,
      CHARG type /SCWM/DE_CHARG,
      OWNER type /SCWM/DE_OWNER,
      ENTITLED type /SCWM/DE_ENTITLED,
      HNDLCODE type /SCMB/DE_HNDLCODE,
      HNDLCODE_TEXT type /SCWM/DE_DESC40,
      NLENR type /SCWM/LTAP_NLENR,
      TANUM type /SCWM/TANUM,
      WHO type /SCWM/DE_WHO,
      SUM_WEIGHT type /SCWM/DE_NWEIGHT,
      UNIT_W type /SCWM/DE_WGT_UOM,
      SUM_VOLUM type /SCWM/DE_NVOLUME,
      UNIT_V type /SCWM/DE_VOL_UOM,
      RDOCCAT type /SCWM/DE_DOCCAT,
      RDOCID type /SCWM/DE_DOCID,
      RITMID type /SCWM/DE_ITMID,
      PICKHU_PMAT type /SCWM/DE_PMAT,
      PICKHU_PMAT_GUID type /SCWM/DE_MATID,
      PICKHU_HUIDENT type /SCWM/DE_HUIDENT,
      PICKHU_HUKNG type /SCWM/DE_HUKNG,
      PICKHU_LGPLA type /SCWM/DE_LGPLA,
      PICKHU_RSRC type /SCWM/DE_RSRC,
      PICKHU_PMTYP type /SCWM/DE_PMTYP,
      PICKHU_PMTYP_TEXT type /SCWM/DE_UI_PMTYP_TEXT,
      PICKHU_HUTYP type /SCWM/DE_HUTYP,
      PICKHU_HUTYP_TEXT type /SCWM/DE_UI_HUTYP_TEXT,
      PICKHU_TANUM type /SCWM/TANUM,
      PICKHU_TAPOS type CHAR4,
      PICKHU_PMTEXT type /SCWM/DE_PMAT_DESC,
      PICKHU_IS_RECOMMENDED type BOOLE_D,
    end of ZZS_VI02_FAP_HUHEADER .
  types:
    begin of ZZS_VI02_SCANHU_KEYS,
      LGNUM type /SCWM/LGNUM,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      HUIDENT type /SCWM/DE_HUIDENT,
    end of ZZS_VI02_SCANHU_KEYS .
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
