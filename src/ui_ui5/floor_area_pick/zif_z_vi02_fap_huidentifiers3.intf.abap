interface ZIF_Z_VI02_FAP_HUIDENTIFIERS3
  public .


  types:
    /SCWM/LGNUM type C length 000004 .
  types:
    Z_DE_FKEY type C length 000010 .
  types:
    /SCWM/DE_EXCCODE type C length 000004 .
  types:
    Z_DE_ERRFLAG type C length 000020 .
  types:
    begin of ZZS_VI02_EXC_MAPPING,
      LGNUM type /SCWM/LGNUM,
      FKEY type Z_DE_FKEY,
      EXCCODE type /SCWM/DE_EXCCODE,
      IDENTIFIER type Z_DE_ERRFLAG,
    end of ZZS_VI02_EXC_MAPPING .
  types:
    ZVI02_T_EXC_MAPPING            type standard table of ZZS_VI02_EXC_MAPPING           with non-unique default key .
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
