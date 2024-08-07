class ZCX_VI02_RF definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  aliases MSGTY
    for IF_T100_DYN_MSG~MSGTY .
  aliases MSGV1
    for IF_T100_DYN_MSG~MSGV1 .
  aliases MSGV2
    for IF_T100_DYN_MSG~MSGV2 .
  aliases MSGV3
    for IF_T100_DYN_MSG~MSGV3 .
  aliases MSGV4
    for IF_T100_DYN_MSG~MSGV4 .
  aliases T100KEY
    for IF_T100_MESSAGE~T100KEY .

  class-data SV_MSG_BUF type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !SV_MSG_BUF type STRING optional
      !MSGTY type SYMSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional .
  class-methods RAISE_FROM_SY_MSG
    importing
      !IX_PREV type ref to CX_ROOT optional
      !IV_RESUME type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_VI02_RF .
  class-methods RAISE_FROM_EWM_GEN
    importing
      !IX_EWM_GEN type ref to /SL0/CX_GENERAL_EXCEPTION
      !IV_RESUME type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_VI02_RF .
  methods GET_SY_MSG
    returning
      value(RV_MSG) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCX_VI02_RF IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->SV_MSG_BUF = SV_MSG_BUF .
me->MSGTY = MSGTY .
me->MSGV1 = MSGV1 .
me->MSGV2 = MSGV2 .
me->MSGV3 = MSGV3 .
me->MSGV4 = MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD get_sy_msg.
    IF t100key-msgid IS INITIAL
    OR msgty         IS INITIAL.
      " An exception was raised
      MESSAGE e530(sy) INTO rv_msg.
      RETURN.
    ENDIF.

    MESSAGE ID t100key-msgid TYPE msgty NUMBER t100key-msgno
      WITH msgv1 msgv2 msgv3 msgv4
      INTO rv_msg.
  ENDMETHOD.


  method RAISE_FROM_EWM_GEN.
    IF ix_ewm_gen                IS NOT BOUND
    OR ix_ewm_gen->t100key-msgid IS INITIAL
    OR ix_ewm_gen->m_msgty       IS INITIAL.
      " An exception was raised
      MESSAGE e530(sy) INTO sv_msg_buf.
    ELSE.
      MESSAGE ID ix_ewm_gen->t100key-msgid
        TYPE ix_ewm_gen->m_msgty
        NUMBER ix_ewm_gen->t100key-msgno
        WITH ix_ewm_gen->m_msgv1 ix_ewm_gen->m_msgv2 ix_ewm_gen->m_msgv3 ix_ewm_gen->m_msgv4
        INTO sv_msg_buf.
    ENDIF.

    raise_from_sy_msg( ix_prev   = ix_ewm_gen
                       iv_resume = iv_resume ).
  endmethod.


  METHOD raise_from_sy_msg.
    IF sy-msgid IS INITIAL
    OR sy-msgty IS INITIAL.
      " An exception was raised
      MESSAGE e530(sy) INTO sv_msg_buf.
    ENDIF.

    IF iv_resume = abap_false.
      RAISE EXCEPTION TYPE zcx_vi02_rf
        MESSAGE ID sy-msgid
        TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING
          previous = ix_prev.
    ELSE.
      RAISE RESUMABLE EXCEPTION TYPE zcx_vi02_rf
        MESSAGE ID sy-msgid
        TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING
          previous = ix_prev.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
