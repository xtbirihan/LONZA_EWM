FUNCTION Z_VI02_RF_DMY_TRANS_ZDTRH2_PAI .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZCS_DUMMY_TRANSPORT) TYPE  ZZVI02_S_RF_DUMMY_TRANSPORT
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
* Package:      Z_VI02_UI_RF
* Type          Function module
* Name:         Z_VI02_RF_DMY_TRANS_ZDTRH2_PAI
* Description:  handle PAI for RF step ZDTRH2
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

  zcl_vi02_rf_dummy_transport=>get_inst( )->zdtrh2_pai( CHANGING cs_dummy_transport = zcs_dummy_transport ).

ENDFUNCTION.
