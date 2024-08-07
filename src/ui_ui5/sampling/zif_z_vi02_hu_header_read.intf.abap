interface ZIF_Z_VI02_HU_HEADER_READ
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
    /SCWM/DE_MATID type X length 000016 .
  types:
    UNAME type C length 000012 .
  types:
    TZNTSTMPS type P length 8  decimals 000000 .
  types:
    LOGSYS type C length 000010 .
  types:
    /SCWM/BRGEW type P length 8  decimals 000003 .
  types:
    /SCWM/NTGEW type P length 8  decimals 000003 .
  types:
    /SCWM/DE_WGT_UOM type C length 000003 .
  types:
    /SCWM/TARAG type P length 8  decimals 000003 .
  types:
    /SCWM/BTVOL type P length 8  decimals 000003 .
  types:
    /SCWM/NTVOL type P length 8  decimals 000003 .
  types:
    /SCWM/DE_VOL_UOM type C length 000003 .
  types:
    /SCWM/TAVOL type P length 8  decimals 000003 .
  types:
    /SCWM/DE_GCAPA type P length 8  decimals 000003 .
  types:
    /SCWM/DE_NCAPA type P length 8  decimals 000003 .
  types:
    /SCWM/DE_TCAPA type P length 8  decimals 000003 .
  types:
    /SCWM/LENGTH type P length 8  decimals 000003 .
  types:
    /SCWM/WIDTH type P length 8  decimals 000003 .
  types:
    /SCWM/HEIGHT type P length 8  decimals 000003 .
  types:
    /SCWM/DIMEH type C length 000003 .
  types:
    /SCWM/DE_MAXW type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXW_TOL type P length 2  decimals 000001 .
  types:
    /SCWM/DE_TARE_VAR type C length 000001 .
  types:
    /SCWM/DE_MAXV type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXV_TOL type P length 2  decimals 000001 .
  types:
    /SCWM/DE_CLOSED_PM type C length 000001 .
  types:
    /SCWM/DE_MAXC type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXC_TOL type P length 2  decimals 000001 .
  types:
    /SCWM/DE_MAXL type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXB type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXH type P length 8  decimals 000003 .
  types:
    /SCWM/DE_MAXDIM_UOM type C length 000003 .
  types:
    /SCWM/VHI type C length 000001 .
  types:
    /SCWM/DE_HUTYP type C length 000004 .
  types:
    /SCWM/FLGAVQ type C length 000001 .
  types:
    /SCWM/FLGMOVE type C length 000001 .
  types:
    /SCWM/DE_PROCS type C length 000004 .
  types:
    /SCWM/DE_COPST type C length 000001 .
  types:
    /SCWM/DE_PRCES type C length 000004 .
  types:
    /SCWM/DE_DSTGRP type C length 000010 .
  types:
    /SCWM/DE_WKLID type N length 000012 .
  types:
    /SCWM/DE_ENTITLED type C length 000010 .
  types:
    /SCWM/LGTYP type C length 000004 .
  types:
    /SCWM/LGBER type C length 000004 .
  types:
    /SCWM/LGPLA type C length 000018 .
  types:
    /SCWM/DE_WCR type C length 000004 .
  types:
    /SCWM/DE_MFSERROR type C length 000004 .
  types:
    /SCWM/DE_HU_UKCON type C length 000001 .
  types:
    /SCWM/DE_TRANSIT type C length 000001 .
  types:
    /SCWM/DE_MFS_STOCKTRANS_CNT type N length 000002 .
  types:
    /SCWM/DE_FLGTWEXT type C length 000001 .
  types:
    /SCWM/DL_PICKHUIND type C length 000001 .
  types:
    /SCWM/DE_PMTYP type C length 000004 .
  types:
    /SCWM/DE_PACKGR type C length 000004 .
  types:
    /SCWM/DE_PHYSTAT type C length 000001 .
  types:
    /SCWM/DE_PMAT type C length 000040 .
  types:
    /SCWM/DE_PMAT_DESC type C length 000040 .
  types:
    GUID type X length 000016 .
  types:
    /LIME/KEY_INDEX type C length 000003 .
  types:
    /SCWM/DE_LOC_TYPE type C length 000001 .
  types:
    /SCWM/DE_LGTYP type C length 000004 .
  types:
    /SCWM/DE_LGPLA type C length 000018 .
  types:
    /SCWM/DE_LGBER type C length 000004 .
  types:
    /SCWM/DE_RSRC type C length 000018 .
  types:
    /SCWM/DE_TU_NUM type C length 000018 .
  types:
    /SCWM/DE_LGNUM_VIEW type C length 000001 .
  types:
    CHAR1 type C length 000001 .
  types:
    begin of ZZS_VI02_HU_HEADER,
      LGNUM type /SCWM/LGNUM,
      GUID_HU type /SCWM/GUID_HU,
      HUIDENT type /SCWM/DE_HUIDENT,
      WORKSTATION type /SCWM/DE_WORKSTATION,
      PMAT_GUID type /SCWM/DE_MATID,
      CREATED_BY type UNAME,
      CREATED_AT type TZNTSTMPS,
      ORIG_SYSTEM type LOGSYS,
      CHANGED_BY type UNAME,
      CHANGED_AT type TZNTSTMPS,
      G_WEIGHT type /SCWM/BRGEW,
      N_WEIGHT type /SCWM/NTGEW,
      UNIT_GW type /SCWM/DE_WGT_UOM,
      T_WEIGHT type /SCWM/TARAG,
      UNIT_TW type /SCWM/DE_WGT_UOM,
      G_VOLUME type /SCWM/BTVOL,
      N_VOLUME type /SCWM/NTVOL,
      UNIT_GV type /SCWM/DE_VOL_UOM,
      T_VOLUME type /SCWM/TAVOL,
      UNIT_TV type /SCWM/DE_VOL_UOM,
      G_CAPA type /SCWM/DE_GCAPA,
      N_CAPA type /SCWM/DE_NCAPA,
      T_CAPA type /SCWM/DE_TCAPA,
      LENGTH type /SCWM/LENGTH,
      WIDTH type /SCWM/WIDTH,
      HEIGHT type /SCWM/HEIGHT,
      UNIT_LWH type /SCWM/DIMEH,
      MAX_WEIGHT type /SCWM/DE_MAXW,
      TOLW type /SCWM/DE_MAXW_TOL,
      TARE_VAR type /SCWM/DE_TARE_VAR,
      MAX_VOLUME type /SCWM/DE_MAXV,
      TOLV type /SCWM/DE_MAXV_TOL,
      CLOSED_PACKAGE type /SCWM/DE_CLOSED_PM,
      MAX_CAPA type /SCWM/DE_MAXC,
      TOLC type /SCWM/DE_MAXC_TOL,
      MAX_LENGTH type /SCWM/DE_MAXL,
      MAX_WIDTH type /SCWM/DE_MAXB,
      MAX_HEIGHT type /SCWM/DE_MAXH,
      UNIT_MAX_LWH type /SCWM/DE_MAXDIM_UOM,
      VHI type /SCWM/VHI,
      LETYP type /SCWM/DE_HUTYP,
      FLGAVQ type /SCWM/FLGAVQ,
      FLGMOVE type /SCWM/FLGMOVE,
      PROCS type /SCWM/DE_PROCS,
      COPST type /SCWM/DE_COPST,
      PRCES type /SCWM/DE_PRCES,
      DSTGRP type /SCWM/DE_DSTGRP,
      WKLID type /SCWM/DE_WKLID,
      ENTITLED type /SCWM/DE_ENTITLED,
      WSTYP type /SCWM/LGTYP,
      WSSEC type /SCWM/LGBER,
      WSBIN type /SCWM/LGPLA,
      WCR type /SCWM/DE_WCR,
      MFSERROR type /SCWM/DE_MFSERROR,
      UKCON type /SCWM/DE_HU_UKCON,
      TRANSIT type /SCWM/DE_TRANSIT,
      MFS_STOCKTRANS_CNT type /SCWM/DE_MFS_STOCKTRANS_CNT,
      FLGTWEXT type /SCWM/DE_FLGTWEXT,
      PICKHUIND type /SCWM/DL_PICKHUIND,
      PMTYP type /SCWM/DE_PMTYP,
      PACKGR type /SCWM/DE_PACKGR,
      PHYSTAT type /SCWM/DE_PHYSTAT,
      PMAT type /SCWM/DE_PMAT,
      PMTEXT type /SCWM/DE_PMAT_DESC,
      GUID_LOC type GUID,
      LOC_IDX type /LIME/KEY_INDEX,
      LOC_TYPE type /SCWM/DE_LOC_TYPE,
      LGTYP type /SCWM/DE_LGTYP,
      LGPLA type /SCWM/DE_LGPLA,
      LGBER type /SCWM/DE_LGBER,
      RSRC type /SCWM/DE_RSRC,
      TU_NUM type /SCWM/DE_TU_NUM,
      LGNUM_VIEW type /SCWM/DE_LGNUM_VIEW,
      TOP type CHAR1,
      HIGHER_GUID type /SCWM/GUID_HU,
      HIGHER_HUIDENT type /SCWM/DE_HUIDENT,
    end of ZZS_VI02_HU_HEADER .
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
