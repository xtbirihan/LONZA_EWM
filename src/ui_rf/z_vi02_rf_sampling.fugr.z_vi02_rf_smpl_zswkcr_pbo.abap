FUNCTION z_vi02_rf_smpl_zswkcr_pbo .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZCS_VI02_RF_SAMPLING) TYPE  ZZS_VI02_RF_SAMPLING
*"----------------------------------------------------------------------

  zcl_vi02_rf_sampling=>get_inst( )->zswkcr_pbo( CHANGING cs_vi02_rf_sampling = zcs_vi02_rf_sampling ).

ENDFUNCTION.
