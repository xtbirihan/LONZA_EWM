class ZCL_IM_QM_STOCK_INSP_EXT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_QM_STOCK_INSP_EXT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_QM_STOCK_INSP_EXT IMPLEMENTATION.


  METHOD /scwm/if_ex_qm_stock_insp_ext~set_ability_to_perform_qinsp.
    LOOP AT it_qm_stock ASSIGNING FIELD-SYMBOL(<ls_stock_status>).
      ASSIGN ct_stock_status_qaction[ guid_parent = <ls_stock_status>-guid_parent
                                      guid_stock  = <ls_stock_status>-guid_stock ] TO FIELD-SYMBOL(<ls_qaction>).
      IF sy-subrc = 0.
      ELSE.
        APPEND INITIAL LINE TO ct_stock_status_qaction ASSIGNING <ls_qaction>.
        <ls_qaction>-guid_parent = <ls_stock_status>-guid_parent.
        <ls_qaction>-guid_stock  = <ls_stock_status>-guid_stock.
      ENDIF.

      <ls_qaction>-qstatus = is_icon-status_todo.
      <ls_qaction>-qstatus_flg = '2'.
      <ls_qaction>-qaction = is_icon-find_todo.
    ENDLOOP.
  ENDMETHOD.


  method /SCWM/IF_EX_QM_STOCK_INSP_EXT~SET_STOCK_FIELDS.
    "Currently not required
  endmethod.
ENDCLASS.
