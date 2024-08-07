FUNCTION z_vi02_rf_smpl_zssrhu_pbo .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZCS_VI02_RF_SAMPLING) TYPE  ZZS_VI02_RF_SAMPLING
*"     REFERENCE(SELECTION) TYPE  /SCWM/S_RF_SELECTION
*"     REFERENCE(CS_WRKC) TYPE  /SCWM/TWORKST
*"----------------------------------------------------------------------

  zcl_vi02_rf_sampling=>get_inst( )->zssrhu_pbo( CHANGING  cs_vi02_rf_sampling  = zcs_vi02_rf_sampling
                                                           cs_selection         = selection
                                                           cs_wrkc              = cs_wrkc ).

ENDFUNCTION.
