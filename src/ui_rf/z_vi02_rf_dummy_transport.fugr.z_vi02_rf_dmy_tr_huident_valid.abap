FUNCTION z_vi02_rf_dmy_tr_huident_valid.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_VALID_PRF) TYPE  /SCWM/S_VALID_PRF_EXT
*"     REFERENCE(IV_FLG_VERIFIED) TYPE  XFELD
*"  EXPORTING
*"     REFERENCE(EV_FLG_VERIFIED) TYPE  XFELD
*"  CHANGING
*"     REFERENCE(ZCS_DUMMY_TRANSPORT) TYPE  ZZVI02_S_RF_DUMMY_TRANSPORT
*"       OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type          Function module
* Name:         Z_VI02_RF_DMY_TR_HUIDENT_VALID
* Description:  verify HU Indent
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*

  BREAK-POINT ID zcg_vi02_rf_dummy_transport.

  zcl_vi02_rf_dummy_transport=>get_inst( )->valid_huident( EXPORTING  is_valid_prf        = is_valid_prf
                                                                      iv_flg_verified     = iv_flg_verified
                                                           IMPORTING  ev_flg_verified     = ev_flg_verified
                                                           CHANGING   cs_dummy_transport  = zcs_dummy_transport ).
ENDFUNCTION.
