FUNCTION z_vi02_rf_pt_hu_dest_pbo.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(CS_PTWY) TYPE  /SCWM/S_RF_PTWY
*"     REFERENCE(CS_ADMIN) TYPE  /SCWM/S_RF_ADMIN
*"     REFERENCE(CT_PTWY) TYPE  /SCWM/TT_RF_PTWY
*"     REFERENCE(CT_LGPLA) TYPE  /SCWM/TT_LGPLA OPTIONAL
*"     REFERENCE(WME_VERIF) TYPE  /SCWM/S_WME_VERIF OPTIONAL
*"     REFERENCE(CT_SERNR) TYPE  /SCWM/TT_RF_SERNR
*"     REFERENCE(TT_NESTED_HU) TYPE  /SCWM/TT_RF_NESTED_HU
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type          Function module
* Name:         Z_VI02_RF_PT_HU_DEST_PBO
* Description:  handle PBO for RF step PTHUDS
*
*----------------------------------------------------------------------*
*
*----------------------Documentation of Changes------------------------*
* Ver. ¦Date      ¦Author            ¦Description
* -----¦----------¦------------------¦---------------------------------*
* 1.0  ¦2023-09-18¦ Ferenc SPISAK	   ¦Initial
*
*----------------------------------------------------------------------*
  BREAK-POINT ID /scwm/rf_putaway.
  BREAK-POINT ID zcg_vi02_rf_putaway.

  zcl_vi02_rf_putaway=>get_inst( )->pthuds_pbo( CHANGING  cs_ptwy       = cs_ptwy
                                                          cs_admin      = cs_admin
                                                          ct_ptwy       = ct_ptwy
                                                          ct_lgpla      = ct_lgpla
                                                          cs_wme_verif  = wme_verif
                                                          ct_sernr      = ct_sernr
                                                          ct_nested_hu  = tt_nested_hu ).

ENDFUNCTION.
