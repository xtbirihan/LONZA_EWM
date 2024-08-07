class ZCL_VI02_IM_HU_BASICS_PRODUCT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_HU_BASICS_PRODUCT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VI02_IM_HU_BASICS_PRODUCT IMPLEMENTATION.


  method /SCWM/IF_EX_HU_BASICS_PRODUCT~CAPACITY.
  endmethod.


  METHOD /scwm/if_ex_hu_basics_product~pack.

    "only for VI02
    IF is_request-lgnum NE zif_vi02_c=>gc_lgnum-vi02.
      RETURN.
    ENDIF.

    "check the source HU ( for sampling only 1 source HU is allowed/possible)
    CALL METHOD zcl_vi02_sampling=>get_instance( )->check_scr_huid_during_packing(
      EXPORTING
        is_request     = is_request
        is_source      = cs_source
        is_destination = cs_destination ).


  ENDMETHOD.
ENDCLASS.
