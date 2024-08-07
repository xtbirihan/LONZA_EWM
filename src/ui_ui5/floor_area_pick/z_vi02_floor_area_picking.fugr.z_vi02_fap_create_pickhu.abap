FUNCTION z_vi02_fap_create_pickhu.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_PICKHUDATA) TYPE  ZZS_VI02_FAP_PICK_HU
*"  EXPORTING
*"     VALUE(ES_PICKHU_KEYS) TYPE  ZZS_VI02_FAP_READ_PICK_HU
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA:
    ls_return  TYPE bapiret2,
    lv_tabix   TYPE sy-tabix,
    lv_huident TYPE /scwm/de_huident.

  go_floor_area_picking = lcl_floor_area_picking=>get_instance( ).

  IF is_pickhudata-pmat IS INITIAL AND is_pickhudata-huident IS INITIAL.
    MESSAGE e036(z_vi02_general) INTO DATA(lv_message).
    go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
    RETURN.
  ENDIF.

  IF is_pickhudata-pmat IS INITIAL.
    MESSAGE e036(z_vi02_general) INTO lv_message.
    RETURN.
  ENDIF.
*  IF is_pickhudata-pmat IS NOT INITIAL AND is_pickhudata-huident IS NOT INITIAL.
*    MESSAGE e035(z_vi02_general) INTO lv_message.
*    RETURN.
*  ENDIF.

  IF is_pickhudata-who IS INITIAL OR is_pickhudata-lgnum IS INITIAL.
    MESSAGE e033(z_vi02_general) WITH TEXT-003 INTO lv_message.
    RETURN.
  ENDIF.

  go_floor_area_picking->lif_isolated_doc_pickhu~get_pick_hus_by_wo(
    EXPORTING
      iv_warehouseorder = is_pickhudata-who
      iv_ewmwarehouse   = is_pickhudata-lgnum
    IMPORTING
      et_pickhu         = DATA(lt_pickhu) ) .
  SORT lt_pickhu BY huident hukng DESCENDING.

  IF is_pickhudata-huident IS NOT INITIAL.
    lv_huident = |{ is_pickhudata-huident  ALPHA = IN }|.
    TRY.
        go_floor_area_picking->lif_isolated_doc_hu~hu_select_gen(
            EXPORTING
              iv_lgnum    = is_pickhudata-lgnum
              ir_huident  = VALUE #( ( sign   = wmegc_sign_inclusive
                                       option = wmegc_option_eq
                                       low    = lv_huident )  )
            IMPORTING
              et_guid_hu = DATA(lt_guid_hu)
              et_huhdr   = DATA(lt_huhdr)
              et_huitm   = DATA(lt_huitm)
              et_hutree  = DATA(lt_hutree)
              et_huref   = DATA(lt_huref)
              et_high    = DATA(lt_high)
              et_ident   = DATA(lt_ident) ).
      CATCH /scwm/cx_core_t100.
    ENDTRY.
  ENDIF.


  IF is_pickhudata-pmat IS NOT INITIAL AND is_pickhudata-huident IS INITIAL.

    DATA(ls_pickhu) = go_floor_area_picking->lif_isolated_doc_pickhu~create_pick_hu(
       EXPORTING
         iv_ewmwarehouse      = is_pickhudata-lgnum
         iv_warehouseorder    = is_pickhudata-who
         iv_packagingmaterial = is_pickhudata-pmat
         iv_huid              = VALUE #( )
         iv_hunumberinwo      = VALUE #( ) ).

  ELSEIF is_pickhudata-pmat IS NOT INITIAL AND is_pickhudata-huident IS NOT INITIAL.

    IF lt_huhdr IS NOT INITIAL. "an already existing HU in EWM, then we use that pickHU for our warehouse order.

      go_floor_area_picking->lif_isolated_doc_material~packaging_mattype_from_matnr(
       EXPORTING
         iv_matnr       = is_pickhudata-pmat
       IMPORTING
         et_matid_pmtyp = DATA(lt_matid_pmtyp) ) .

      DATA(ls_matid_pmtyp) = VALUE #( lt_matid_pmtyp[ 1 ] OPTIONAL ).
      DATA(ls_huhdr) = VALUE #( lt_huhdr[ 1 ] OPTIONAL ).

      "If the packaging material type differs, there is an error when there is already stock in that HU.
      IF ls_matid_pmtyp-pmtyp NE ls_huhdr-pmtyp AND lt_huitm[] IS NOT INITIAL.
        MESSAGE e037(z_vi02_general) INTO lv_message.
        go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
        RETURN.
      ENDIF.

      "If the HU is empty the old HU is deleted and new HU is created with the same HU number but new packaging material.
      IF lt_huitm IS INITIAL.

        TRY.
            go_floor_area_picking->mo_handling_unit->/scwm/if_api_handling_unit~delete(
               EXPORTING
                 iv_whno     = is_pickhudata-lgnum
                 it_huident  = VALUE #( ( huident = ls_huhdr-huident ) )
               IMPORTING
                  eo_message  = DATA(lo_message) ).
          CATCH /scwm/cx_api_faulty_call INTO DATA(lx_api_hu).
            RETURN.
        ENDTRY.

        DATA(lv_error) = lo_message->check( iv_msgty = /scwm/if_api_message=>sc_msgty_error ).
        IF lv_error IS NOT INITIAL.
          RETURN.
        ENDIF.

        go_floor_area_picking->mo_handling_unit->/scwm/if_api_handling_unit~save(
          IMPORTING
            eo_message = lo_message ).

        go_floor_area_picking->mo_handling_unit->/scwm/if_tm_appl~cleanup( iv_reason = '' ).
        COMMIT WORK AND WAIT.

        ls_pickhu = go_floor_area_picking->lif_isolated_doc_pickhu~create_pick_hu(
          EXPORTING
            iv_ewmwarehouse      = is_pickhudata-lgnum
            iv_warehouseorder    = is_pickhudata-who
            iv_packagingmaterial = is_pickhudata-pmat
            iv_huid              = ls_huhdr-huident
            iv_hunumberinwo      = 001 ).
      ELSE.
        MESSAGE e038(z_vi02_general) INTO lv_message.
        go_floor_area_picking->append_sy_message( CHANGING ct_bapiret = et_return[] ).
        RETURN.
      ENDIF.

    ELSEIF lt_huhdr IS INITIAL. "HU number at an external number range → Then the HU is created with that number
      ls_pickhu = go_floor_area_picking->lif_isolated_doc_pickhu~create_pick_hu(
        EXPORTING
          iv_ewmwarehouse      = is_pickhudata-lgnum
          iv_warehouseorder    = is_pickhudata-who
          iv_packagingmaterial = is_pickhudata-pmat
          iv_huid              = is_pickhudata-huident
          iv_hunumberinwo      = 001 ).
    ENDIF.
  ENDIF.

  es_pickhu_keys = CORRESPONDING #( ls_pickhu ).
ENDFUNCTION.
