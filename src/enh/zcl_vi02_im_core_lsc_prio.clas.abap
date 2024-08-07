class ZCL_VI02_IM_CORE_LSC_PRIO definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_CORE_LSC_PRIO .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VI02_IM_CORE_LSC_PRIO IMPLEMENTATION.


  method /SCWM/IF_EX_CORE_LSC_PRIO~SORT.
  endmethod.


  method /SCWM/IF_EX_CORE_LSC_PRIO~SORT_NOFIT.
  endmethod.
ENDCLASS.
