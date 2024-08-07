class ZCL_VI02_IM_CORE_LSC_LAYOUT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_CORE_LSC_LAYOUT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VI02_IM_CORE_LSC_LAYOUT IMPLEMENTATION.


  method /SCWM/IF_EX_CORE_LSC_LAYOUT~LAYOUT.

    IF 1 = 2.
      "test

    ENDIF.

  endmethod.
ENDCLASS.
