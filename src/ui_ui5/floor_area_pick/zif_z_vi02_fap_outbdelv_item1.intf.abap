interface ZIF_Z_VI02_FAP_OUTBDELV_ITEM1
  public .


  types:
    /SCDL/DL_DOCID type X length 000016 .
  types:
    /SCDL/DL_ITEMID type X length 000016 .
  types:
    /SCDL/DL_ITEMNO type N length 000010 .
  types:
    /SCDL/DL_ITEMCAT type C length 000003 .
  types:
    /SCDL/DL_ITEMTYPE type C length 000004 .
  types:
    /SCDL/DL_ITEMUUID type X length 000016 .
  types:
    /SCDL/DL_MANUAL type C length 000001 .
  types:
    /SCDL/DL_OBJECT_STATE type C length 000002 .
  types:
    /SCDL/DL_OBJCHG type C length 000001 .
  types:
    BOOLE_D type C length 000001 .
  types:
    /SCDL/DL_DOCNO_INT type C length 000035 .
  types:
    /SCDL/DL_DOCCAT type C length 000003 .
  types:
    /SCDL/DL_PRODUCTID type X length 000016 .
  types:
    /SCDL/DL_PRODUCTNO type C length 000040 .
  types:
    /SCDL/DL_BATCHNO type C length 000020 .
  types:
    /SCDL/DL_PRODUCTNO_EXT type C length 000040 .
  types:
    /SCDL/DL_PROD_ENTERED type C length 000040 .
  types:
    /SCDL/DL_TEXT type C length 000040 .
  types:
    /SCDL/DL_STOCK_USAGE type C length 000001 .
  types:
    /SCDL/DL_STOCK_CATEGORY type C length 000002 .
  types:
    /SCDL/DL_STOCK_OWNER type C length 000010 .
  types:
    /SCDL/DL_STOCK_OWNER_ROLE type C length 000002 .
  types:
    /SCDL/DL_INDICATOR type C length 000001 .
  types:
    /SCDL/DL_WH_STOCK_RELEVANCE type C length 000001 .
  types:
    /SCWM/DE_UI_QUAN_DLV type P length 7  decimals 000003 .
  types:
    /SCDL/DL_UOM type C length 000003 .
  types:
    /SCWM/DLV_BATCHID type X length 000016 .
  types:
    /SCDL/DL_TEXTIND type C length 000001 .
  types:
    begin of ZZS_VI02_FAP_OUTBDELV_ITEM,
      DOCID type /SCDL/DL_DOCID,
      ITEMID type /SCDL/DL_ITEMID,
      ITEMNO type /SCDL/DL_ITEMNO,
      ITEMCAT type /SCDL/DL_ITEMCAT,
      ITEMTYPE type /SCDL/DL_ITEMTYPE,
      ITEMUUID type /SCDL/DL_ITEMUUID,
      MANUAL type /SCDL/DL_MANUAL,
      OBJECTSTATE type /SCDL/DL_OBJECT_STATE,
      OBJCHG type /SCDL/DL_OBJCHG,
      CHANGEABLE type BOOLE_D,
      DOCNO type /SCDL/DL_DOCNO_INT,
      DOCCAT type /SCDL/DL_DOCCAT,
      PRODUCTID type /SCDL/DL_PRODUCTID,
      PRODUCTNO type /SCDL/DL_PRODUCTNO,
      BATCHNO type /SCDL/DL_BATCHNO,
      PRODUCTNO_EXT type /SCDL/DL_PRODUCTNO_EXT,
      PRODUCTENT type /SCDL/DL_PROD_ENTERED,
      PRODUCT_TEXT type /SCDL/DL_TEXT,
      CHGVERSION type INT4,
      STOCK_USAGE type /SCDL/DL_STOCK_USAGE,
      STOCK_CATEGORY type /SCDL/DL_STOCK_CATEGORY,
      STOCK_OWNER type /SCDL/DL_STOCK_OWNER,
      STOCK_OWNER_ROLE type /SCDL/DL_STOCK_OWNER_ROLE,
      STOCK_CAT_IND type /SCDL/DL_INDICATOR,
      STOCK_REL type /SCDL/DL_WH_STOCK_RELEVANCE,
      QTY type /SCWM/DE_UI_QUAN_DLV,
      UOM type /SCDL/DL_UOM,
      BATCHID type /SCWM/DLV_BATCHID,
      TEXTIND type /SCDL/DL_TEXTIND,
      OD_DOCCAT type /SCDL/DL_DOCCAT,
      OD_DOCID type /SCDL/DL_DOCID,
    end of ZZS_VI02_FAP_OUTBDELV_ITEM .
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
