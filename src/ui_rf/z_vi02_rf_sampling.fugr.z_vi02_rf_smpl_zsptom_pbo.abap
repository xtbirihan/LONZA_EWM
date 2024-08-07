FUNCTION z_vi02_rf_smpl_zsptom_pbo .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZCS_VI02_RF_SAMPLING) TYPE  ZZS_VI02_RF_SAMPLING
*"     REFERENCE(CS_WRKC) TYPE  /SCWM/TWORKST
*"----------------------------------------------------------------------

  zcl_vi02_rf_sampling=>get_inst( )->zsptom_pbo( CHANGING  cs_vi02_rf_sampling    = zcs_vi02_rf_sampling
                                                           cs_wrkc                = cs_wrkc ).

ENDFUNCTION.
