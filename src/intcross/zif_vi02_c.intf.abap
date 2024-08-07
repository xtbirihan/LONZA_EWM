INTERFACE zif_vi02_c
  PUBLIC .


  CONSTANTS: BEGIN OF gc_lgnum,
               vi02 TYPE /scwm/lgnum VALUE 'VI02',
             END OF gc_lgnum,
             BEGIN OF gc_lgtyp,
               ambient TYPE /scwm/lgtyp VALUE 'AA38',
             END OF gc_lgtyp,
             BEGIN OF gc_param,
               pmat_wpallet           TYPE /sl0/de_param_id2 VALUE 'PMAT_WPALLET',
               pmat_plastic_pal       TYPE /sl0/de_param_id2 VALUE 'PMAT_PLASTIC_PAL',
               pmat_plastic_pal_stack TYPE /sl0/de_param_id2 VALUE 'PMAT_PLASTIC_STACK',
               loop_cv14              TYPE /sl0/de_param_id2 VALUE 'LOOP_CV14',
               pmat_pal_box           TYPE /sl0/de_param_id2 VALUE 'PMAT_PALLET_BOX',
               pmat_stacker           TYPE /sl0/de_param_id2 VALUE 'PMAT_STACKER',
               lgpla_wpallet_full     TYPE /sl0/de_param_id2 VALUE 'LGPLA_WPALLET_FULL',
               lgpla_box_not_empty    TYPE /sl0/de_param_id2 VALUE 'LGPLA_BOX_NOT_EMPTY',
             END OF gc_param,
             BEGIN OF gc_cptype,
               ip TYPE /scwm/de_mfscp_type VALUE 'IP',
             END OF gc_cptype,
             BEGIN OF gc_plc,
               conv11 TYPE /scwm/de_mfsplc VALUE 'CONV11',
               conv12 TYPE /scwm/de_mfsplc VALUE 'CONV12',
               conv13 TYPE /scwm/de_mfsplc VALUE 'CONV13',
               conv14 TYPE /scwm/de_mfsplc VALUE 'CONV14',
               conv15 TYPE /scwm/de_mfsplc VALUE 'CONV15',
             END OF gc_plc .
ENDINTERFACE.
