FUNCTION z_vi02_rf_smpl_zstrhu_pai .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZCS_VI02_RF_SAMPLING) TYPE  ZZS_VI02_RF_SAMPLING
*"     REFERENCE(ZCS_VI02_RF_SAMPLING_WT) TYPE  ZZS_VI02_RF_SAMPLING_WT
*"     REFERENCE(ZCT_VI02_RF_SAMPLING_WT) TYPE  Z_T_VI02_RF_SAMPLING_WT
*"     REFERENCE(SELECTION) TYPE  /SCWM/S_RF_SELECTION
*"     REFERENCE(CS_WRKC) TYPE  /SCWM/TWORKST
*"----------------------------------------------------------------------

  zcl_vi02_rf_sampling=>get_inst( )->zstrhu_pai( CHANGING  cs_vi02_rf_sampling    = zcs_vi02_rf_sampling
                                                           cs_vi02_rf_sampling_wt = zcs_vi02_rf_sampling_wt
                                                           ct_vi02_rf_sampling_wt = zct_vi02_rf_sampling_wt
                                                           cs_selection           = selection
                                                           cs_wrkc                = cs_wrkc ).

ENDFUNCTION.
