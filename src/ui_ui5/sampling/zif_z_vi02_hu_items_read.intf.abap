interface ZIF_Z_VI02_HU_ITEMS_READ
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
    /LIME/KEY_INDEX type C length 000003 .
  types:
    /SCWM/DE_BASE_UOM type C length 000003 .
  types:
    /SCWM/DE_AUNIT type C length 000003 .
  types:
    /SCWM/DE_NWEIGHT type P length 8  decimals 000003 .
  types:
    /SCWM/DE_WGT_UOM type C length 000003 .
  types:
    /SCWM/DE_NVOLUME type P length 8  decimals 000003 .
  types:
    /SCWM/DE_VOL_UOM type C length 000003 .
  types:
    /SCWM/DE_CAPAUSE type P length 8  decimals 000003 .
  types:
    /SCWM/DE_WDATU type P length 8  decimals 000000 .
  types:
    /SCWM/DE_COO type C length 000003 .
  types:
    /SCMB/MDL_DZUSTD type C length 000001 .
  types:
    /SCWM/DE_STK_SEG_LONG type C length 000040 .
  types:
    /SCWM/DE_INSPIDTYP type C length 000001 .
  types:
    /SCWM/DE_INSPID type X length 000016 .
  types:
    /SCWM/DE_IDPLATE type C length 000020 .
  types:
    /SCWM/DE_DOCCAT type C length 000003 .
  types:
    /SCWM/DE_DOCID type X length 000016 .
  types:
    /SCWM/DE_ITMID type X length 000016 .
  types:
    /SCWM/DE_CWUNIT type C length 000003 .
  types:
    /SCWM/DE_CWEXACT type C length 000001 .
  types:
    /SCWM/DE_MATID type X length 000016 .
  types:
    /SCWM/DE_MATNR type C length 000040 .
  types:
    /SCWM/DE_BATCHID type X length 000016 .
  types:
    /SCWM/DE_CHARG type C length 000010 .
  types:
    /LIME/STOCK_CATEGORY type C length 000002 .
  types:
    /SCWM/DE_STOCK_DOCCAT type C length 000003 .
  types:
    /SCWM/DE_STOCK_DOCNO type C length 000035 .
  types:
    /SCWM/DE_STOCK_ITMNO type N length 000010 .
  types:
    /LIME/STOCK_USAGE type C length 000001 .
  types:
    /SCWM/DE_OWNER type C length 000010 .
  types:
    /LIME/OWNER_ROLE type C length 000002 .
  types:
    /SCWM/DE_ENTITLED type C length 000010 .
  types:
    /SCWM/DE_ENTITLED_ROLE type C length 000002 .
  types:
    /SCWM/DE_STOCK_CNT type N length 000006 .
  types:
    /LIME/VSI type C length 000001 .
  types:
    /SCWM/DE_QUANTITY type P length 16  decimals 000014 .
  types:
    /SCWM/DE_CWQUAN type P length 16  decimals 000014 .
  types:
    /SCWM/DE_AAREA type C length 000004 .
  types:
    /SCWM/DE_WAVE type N length 000010 .
  types:
    /SCMB/DE_BATCH_REQ type C length 000001 .
  types:
    /SCWM/DE_PACKGR type C length 000004 .
  types:
    /SCWM/DE_HUTYP_DFLT type C length 000004 .
  types:
    /SCMB/DE_WHMATGR type C length 000004 .
  types:
    /SCMB/DE_WHSTC type C length 000002 .
  types:
    /SCMB/DE_HNDLCODE type C length 000004 .
  types:
    /SCWM/DE_DESC40 type C length 000040 .
  types:
    SPRAS type C length 000001 .
  types:
    MATKL type C length 000009 .
  types:
    /SCMB/MDL_PARTNER_ID type C length 000032 .
  types:
    PRQ_PARTRO type C length 000002 .
  types:
    BU_PARTNER type C length 000010 .
  types:
    BU_TYPE type C length 000001 .
  types:
    BU_NAMEP_L type C length 000040 .
  types:
    AD_ADDRNUM type C length 000010 .
  types:
    KOSTL type C length 000010 .
  types:
    /SCWM/DE_PUT_STRA_PLAN type C length 000004 .
  types:
    begin of ZZS_VI02_HU_ITEM,
      LGNUM type /SCWM/LGNUM,
      GUID_HU type /SCWM/GUID_HU,
      HUIDENT type /SCWM/DE_HUIDENT,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      GUID_PARENT type /LIME/GUID_PARENT,
      GUID_STOCK type /LIME/GUID_STOCK,
      IDX_STOCK type /LIME/KEY_INDEX,
      GUID_STOCK0 type /LIME/GUID_STOCK,
      MEINS type /SCWM/DE_BASE_UOM,
      ALTME type /SCWM/DE_AUNIT,
      WEIGHT type /SCWM/DE_NWEIGHT,
      UNIT_W type /SCWM/DE_WGT_UOM,
      VOLUM type /SCWM/DE_NVOLUME,
      UNIT_V type /SCWM/DE_VOL_UOM,
      CAPA type /SCWM/DE_CAPAUSE,
      WDATU type /SCWM/DE_WDATU,
      VFDAT type DATS,
      COO type /SCWM/DE_COO,
      BRESTR type /SCMB/MDL_DZUSTD,
      STK_SEG_LONG type /SCWM/DE_STK_SEG_LONG,
      INSPTYP type /SCWM/DE_INSPIDTYP,
      INSPID type /SCWM/DE_INSPID,
      IDPLATE type /SCWM/DE_IDPLATE,
      QDOCCAT type /SCWM/DE_DOCCAT,
      QDOCID type /SCWM/DE_DOCID,
      QITMID type /SCWM/DE_ITMID,
      CWUNIT type /SCWM/DE_CWUNIT,
      CWEXACT type /SCWM/DE_CWEXACT,
      MATID type /SCWM/DE_MATID,
      MATNR type /SCWM/DE_MATNR,
      BATCHID type /SCWM/DE_BATCHID,
      CHARG type /SCWM/DE_CHARG,
      CAT type /LIME/STOCK_CATEGORY,
      STOCK_DOCCAT type /SCWM/DE_STOCK_DOCCAT,
      STOCK_DOCNO type /SCWM/DE_STOCK_DOCNO,
      STOCK_ITMNO type /SCWM/DE_STOCK_ITMNO,
      DOCCAT type /SCWM/DE_DOCCAT,
      STOCK_USAGE type /LIME/STOCK_USAGE,
      OWNER type /SCWM/DE_OWNER,
      OWNER_ROLE type /LIME/OWNER_ROLE,
      ENTITLED type /SCWM/DE_ENTITLED,
      ENTITLED_ROLE type /SCWM/DE_ENTITLED_ROLE,
      STOCK_CNT type /SCWM/DE_STOCK_CNT,
      VSI type /LIME/VSI,
      QUAN type /SCWM/DE_QUANTITY,
      CWQUAN type /SCWM/DE_CWQUAN,
      RESQ type /SCWM/DE_QUANTITY,
      QUANA type /SCWM/DE_QUANTITY,
      GM_DECRESE type /SCWM/DE_QUANTITY,
      AAREA_CAP type /SCWM/DE_AAREA,
      WAVE type /SCWM/DE_WAVE,
      BATCH_REQ type /SCMB/DE_BATCH_REQ,
      PACKGR type /SCWM/DE_PACKGR,
      RMATP type /SCWM/DE_MATID,
      HUTYP_DFLT type /SCWM/DE_HUTYP_DFLT,
      WHMATGR type /SCMB/DE_WHMATGR,
      WHSTC type /SCMB/DE_WHSTC,
      HNDLCODE type /SCMB/DE_HNDLCODE,
      HNDLCODE_T type /SCWM/DE_DESC40,
      LANGU type SPRAS,
      MAKTX type /SCWM/DE_DESC40,
      MATKL type MATKL,
      PARTNER_GUID type /SCMB/MDL_PARTNER_ID,
      PARTNER_ROLE type PRQ_PARTRO,
      PARTNER type BU_PARTNER,
      TYPE type BU_TYPE,
      NAME type BU_NAMEP_L,
      ADDRNUMBER type AD_ADDRNUM,
      KOSTL type KOSTL,
      PUT_STRA_PLAN type /SCWM/DE_PUT_STRA_PLAN,
      PUT_STRA_PLAN_T type /SCWM/DE_DESC40,
    end of ZZS_VI02_HU_ITEM .
  types:
    ZVI02_T_HU_ITEM                type standard table of ZZS_VI02_HU_ITEM               with non-unique default key .
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
