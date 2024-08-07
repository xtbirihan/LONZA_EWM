CLASS zcl_enh_vi02_mfs_act_cp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /scwm/if_ex_mfs_act_sp .
  PROTECTED SECTION.
    METHODS:
      det_dest_bin_ip
        IMPORTING
          iv_lgnum    TYPE        /scwm/lgnum
          iv_plc      TYPE        /scwm/de_mfsplc
          iv_channel  TYPE        /scwm/de_mfscch
          is_act_cp   TYPE        /scwm/tmfscp
          is_telegram TYPE        /scwm/s_mfs_teletotal
        EXPORTING
          ev_lgpla    TYPE        /scwm/lgpla
          ev_lgber    TYPE        /scwm/lgber
          ev_lgtyp    TYPE        /scwm/lgtyp,

      handle_waste_pal_at_ip
        IMPORTING
          iv_lgnum    TYPE        /scwm/lgnum
          iv_plc      TYPE        /scwm/de_mfsplc
          iv_channel  TYPE        /scwm/de_mfscch
          is_act_cp   TYPE        /scwm/tmfscp
          is_telegram TYPE        /scwm/s_mfs_teletotal
        EXPORTING
          ev_lgpla    TYPE        /scwm/lgpla
          ev_lgber    TYPE        /scwm/lgber
          ev_lgtyp    TYPE        /scwm/lgtyp,

      handle_box_at_ip
        IMPORTING
          iv_lgnum    TYPE        /scwm/lgnum
          iv_plc      TYPE        /scwm/de_mfsplc
          iv_channel  TYPE        /scwm/de_mfscch
          is_act_cp   TYPE        /scwm/tmfscp
          is_telegram TYPE        /scwm/s_mfs_teletotal
          iv_hu_empty TYPE abap_bool
        EXPORTING
          ev_lgpla    TYPE        /scwm/lgpla
          ev_lgber    TYPE        /scwm/lgber
          ev_lgtyp    TYPE        /scwm/lgtyp.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ENH_VI02_MFS_ACT_CP IMPLEMENTATION.


  METHOD /scwm/if_ex_mfs_act_sp~change_hutyp.
    CLEAR ev_hutyp.

    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    " HU type determination for I-Points
    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DATA: lv_tmfscp TYPE /scwm/tmfscp,
          lv_mfscp  TYPE /scwm/mfscp.

    CALL FUNCTION '/SCWM/TMFSCP_READ_SINGLE'
      EXPORTING
        iv_lgnum  = iv_lgnum
        iv_plc    = iv_plc
        iv_cp     = is_telegram-cp
      IMPORTING
        es_tmfscp = lv_tmfscp
        es_mfscp  = lv_mfscp
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.

    CHECK sy-subrc IS INITIAL.

    CHECK lv_tmfscp-cp_type EQ zif_vi02_c=>gc_cptype-ip. "ID-Point

    NEW /sl0/cl_mfs_process_helper( )->get_tutyp_mapping(
                                         EXPORTING
                                           iv_lgnum        = iv_lgnum
                                           iv_plc          = iv_plc
                                           iv_channel      = iv_channel
                                           iv_tutyp        = is_telegram-/sl0/tutype
                                           iv_height       = is_telegram-/sl0/height
                                           iv_width        = CONV #( nmax( val1 = is_telegram-/sl0/widthleft
                                                                           val2 = is_telegram-/sl0/widthright ) )
                                           iv_length       = CONV #( nmax( val1 = is_telegram-/sl0/lengthfront
                                                                           val2 = is_telegram-/sl0/lengthback ) )
                                           iv_weight       = is_telegram-/sl0/weight
                                           iv_only_typ     = abap_true
                                         IMPORTING
                                            es_wa_tutypemap = DATA(ls_tutypemap) ).

    ev_hutyp = ls_tutypemap-hutyp.

  ENDMETHOD.


  METHOD /scwm/if_ex_mfs_act_sp~check.
  ENDMETHOD.


  METHOD /scwm/if_ex_mfs_act_sp~det_dest_bin.
    IF is_act_cp-cp_type EQ zif_vi02_c=>gc_cptype-ip. "ID-Point
      det_dest_bin_ip(
        EXPORTING
          iv_lgnum    = iv_lgnum
          iv_plc      = iv_plc
          iv_channel  = iv_channel
          is_act_cp   = is_act_cp
          is_telegram = is_telegram
        IMPORTING
          ev_lgpla    = ev_lgpla
          ev_lgber    = ev_lgber
          ev_lgtyp    = ev_lgtyp ).
    ENDIF.
  ENDMETHOD.


  METHOD det_dest_bin_ip.
    DATA(lo_hu) = NEW /sl0/cl_mfs_hu(
      iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
      iv_huident      = is_telegram-huident                 " Handling Unit Identification
    ).

    lo_hu->read_hu_data(
      IMPORTING
        es_huhdr_data   = DATA(ls_huhdr_data)                 " HU Header Data
    ).

    lo_hu->get_hu_pmat(
      CHANGING
        es_huhdr_data = ls_huhdr_data                 " Internal Structure for Processing HU Headers
    ).

    DATA(lt_pmat_waste_r) = /sl0/cl_param_select=>read_const_range(
                            iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                            iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                            iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                            iv_parameter    = zif_vi02_c=>gc_param-pmat_wpallet               " Parameter name
                          ).

    IF lt_pmat_waste_r IS NOT INITIAL
      AND ls_huhdr_data-pmat IN lt_pmat_waste_r .
      "this is a waste pallet
      handle_waste_pal_at_ip(
        EXPORTING
          iv_lgnum    = iv_lgnum
          iv_plc      = iv_plc
          iv_channel  = iv_channel
          is_act_cp   = is_act_cp
          is_telegram = is_telegram
        IMPORTING
          ev_lgpla    = ev_lgpla
          ev_lgber    = ev_lgber
          ev_lgtyp    = ev_lgtyp ).

      RETURN.
    ENDIF.

    DATA(lv_hu_empty) = lo_hu->is_empty( is_huhdr = ls_huhdr_data ).

    IF lv_hu_empty EQ abap_true.
      "The same logic applies to Plastic Pallet Stack being a logically empty HU.
      "TODO: is this statement correct?

      "empty HU, try to resolve stacker
      DATA lt_lgpla_r TYPE rseloption.

      lt_lgpla_r = /sl0/cl_param_select=>read_const_range(
                                iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                                iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                                iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                                iv_parameter    = zif_vi02_c=>gc_param-pmat_stacker              " Parameter name
                          ).

      "we'll abuse ranges here using low for pmat and high for storage bin
      ev_lgpla = VALUE #( lt_lgpla_r[ low = ls_huhdr_data-pmat ]-high OPTIONAL ).

      CHECK ev_lgpla IS NOT INITIAL.
    ENDIF.

    DATA(lt_pmat_box_r) = /sl0/cl_param_select=>read_const_range(
                            iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                            iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                            iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                            iv_parameter    = zif_vi02_c=>gc_param-pmat_pal_box              " Parameter name
                          ).

    IF lt_pmat_box_r IS NOT INITIAL
      AND ls_huhdr_data-pmat IN lt_pmat_box_r.

      "this is a box
      handle_box_at_ip(
       EXPORTING
         iv_lgnum    = iv_lgnum
         iv_plc      = iv_plc
         iv_channel  = iv_channel
         is_act_cp   = is_act_cp
         is_telegram = is_telegram
         iv_hu_empty = lv_hu_empty
       IMPORTING
         ev_lgpla    = ev_lgpla
         ev_lgber    = ev_lgber
         ev_lgtyp    = ev_lgtyp ).
    ENDIF.

  ENDMETHOD.


  METHOD handle_box_at_ip.
    CASE iv_plc.
      WHEN zif_vi02_c=>gc_plc-conv12. "CONV12, pick area

        "Pre-picked boxes go to ambient storage
        ev_lgtyp = zif_vi02_c=>gc_lgtyp-ambient.

      WHEN zif_vi02_c=>gc_plc-conv15. "CONV15

        "Boxes returning from production
        IF iv_hu_empty = abap_true.
          DATA(lv_buffer) = zcl_vi02_mfs_pick_buf=>get_empty_buffer(
                              iv_lgnum       = iv_lgnum
                              iv_buffer_mode = zcl_vi02_mfs_pick_buf=>mc_buffer_mode-pallet_box ).

          IF lv_buffer IS INITIAL.
            "no available buffer found, send to CV14-OBS7.
            ev_lgpla = /sl0/cl_param_select=>read_const(
                                iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                                iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                                iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                                iv_parameter    = zif_vi02_c=>gc_param-loop_cv14            " Parameter name
                                ).
          ELSE.
            "send directly to the buffer
            ev_lgpla = lv_buffer.
          ENDIF.
        ELSE.
          "Box not empty, send to outfeed
          ev_lgpla = /sl0/cl_param_select=>read_const(
                                iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                                iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                                iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                                iv_parameter    = zif_vi02_c=>gc_param-lgpla_box_not_empty              " Parameter name
                          ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD handle_waste_pal_at_ip.
    CASE iv_plc.
      WHEN zif_vi02_c=>gc_plc-conv11. "CONV11
        "Waste pallets coming from Infeed have been emptied.
        "They should either go to a buffer or to the ambient storage.

        ev_lgpla = zcl_vi02_mfs_pick_buf=>get_empty_buffer(
          EXPORTING
            iv_lgnum       = iv_lgnum
            iv_buffer_mode = zcl_vi02_mfs_pick_buf=>mc_buffer_mode-waste_pallet ).

        CHECK ev_lgpla IS INITIAL.

        ev_lgtyp = zif_vi02_c=>gc_lgtyp-ambient.
      WHEN OTHERS.
        "Waste pallet coming from CONV12 or CONV13 pick zone should go to Outfeed
        "where it will be emptied.

        ev_lgpla = /sl0/cl_param_select=>read_const(
                                iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                                iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                                iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                                iv_parameter    = zif_vi02_c=>gc_param-lgpla_wpallet_full              " Parameter name
                          ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
