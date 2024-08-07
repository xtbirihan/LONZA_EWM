interface ZIF_Z_VI02_VH_PRODUCT
  public .


  types:
    MATNR type C length 000040 .
  types:
    MEINH type C length 000003 .
  types:
    UMREZ type P length 3  decimals 000000 .
  types:
    UMREN type P length 3  decimals 000000 .
  types:
    MEABM type C length 000003 .
  types:
    DE_EWMTY2TQ type C length 000001 .
  types:
    MEINS type C length 000003 .
  types:
    SPRAS type C length 000001 .
  types:
    MSEHI type C length 000003 .
  types:
    MSEHL type C length 000030 .
  types:
    MSEHT type C length 000010 .
  types:
    MSEH6 type C length 000006 .
  types:
    MSEH3 type C length 000003 .
  types:
    begin of ZZS_VI02_VH_PRODUCT,
      PRODUCT type MATNR,
      ALTERNATIVEUNIT type MEINH,
      QUANTITYNUMERATOR type UMREZ,
      QUANTITYDENOMINATOR type UMREN,
      PRODUCTMEASUREMENTUNIT type MEABM,
      UNITOFMEASURECATEGORY type DE_EWMTY2TQ,
      BASEUNIT type MEINS,
      LANGUAGE type SPRAS,
      UNITOFMEASURE type MSEHI,
      UNITOFMEASURELONGNAME type MSEHL,
      UNITOFMEASURENAME type MSEHT,
      UNITOFMEASURETECHNICALNAME type MSEH6,
      UNITOFMEASURE_E type MSEH3,
      UNITOFMEASURECOMMERCIALNAME type MSEH3,
    end of ZZS_VI02_VH_PRODUCT .
  types:
    ZVI02_T_VH_PRODUCT             type standard table of ZZS_VI02_VH_PRODUCT            with non-unique default key .
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
