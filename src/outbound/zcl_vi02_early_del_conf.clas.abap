class ZCL_VI02_EARLY_DEL_CONF definition
  public
  final
  create public .

public section.

  methods CO_POST_DELIVERY_CONF
    importing
      !IT_ORDIM_C type /SCWM/TT_ORDIM_C .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VI02_EARLY_DEL_CONF IMPLEMENTATION.


  METHOD co_post_delivery_conf.

    DATA:
      lv_qname   TYPE trfcqin-qname,
      lv_rfcdest TYPE rfcdest,
      lt_ordim_c TYPE STANDARD TABLE OF /scwm/ordim_c,
      ls_ordim_c TYPE /scwm/ordim_c.

    IF it_ordim_c IS INITIAL. RETURN. ENDIF.

    READ TABLE it_ordim_c INTO ls_ordim_c INDEX 1.
    IF sy-subrc <> 0. RETURN. ENDIF.

    IF NOT ls_ordim_c-dstgrp IS INITIAL.
      CONCATENATE 'ZEWM_CNF_' ls_ordim_c-tanum INTO lv_qname.
    ENDIF.

    CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
      EXPORTING
        qin_name           = lv_qname
      EXCEPTIONS
        invalid_queue_name = 1
        OTHERS             = 2.

*  empty destination -> NONE
    CALL FUNCTION 'ZEWM_DLV_CONFIRM'
      IN BACKGROUND TASK
      AS SEPARATE UNIT
      DESTINATION lv_rfcdest
      EXPORTING
        it_ordim_c = it_ordim_c.

  ENDMETHOD.
ENDCLASS.
