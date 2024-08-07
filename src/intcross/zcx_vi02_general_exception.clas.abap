class ZCX_VI02_GENERAL_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  data GS_T100KEY type SCX_T100KEY .
  data GV_M_MSGTY type SYMSGTY .
  data GV_M_MSGV1 type SYMSGV .
  data GV_M_MSGV2 type SYMSGV .
  data GV_M_MSGV3 type SYMSGV .
  data GV_M_MSGV4 type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !GS_T100KEY type SCX_T100KEY optional
      !GV_M_MSGTY type SYMSGTY optional
      !GV_M_MSGV1 type SYMSGV optional
      !GV_M_MSGV2 type SYMSGV optional
      !GV_M_MSGV3 type SYMSGV optional
      !GV_M_MSGV4 type SYMSGV optional .
  class-methods RAISE_EXCEPTION
    importing
      !IV_MSGTY type SYMSGTY optional
      !IV_MSGID type SYMSGID
      !IV_MSGNO type SYMSGNO
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  class-methods RAISE_SYSTEM_EXCEPTION
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods GET_EXCEPTION_MESSAGE
    returning
      value(RV_RESULT) type STRING .
  class-methods RAISE_SY_MSG
    importing
      !IX_PREV type ref to CX_ROOT optional
    raising
      ZCX_VI02_GENERAL_EXCEPTION .
  methods GET_SY_MSG
    returning
      value(RV_MSG) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCX_VI02_GENERAL_EXCEPTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->GS_T100KEY = GS_T100KEY .
me->GV_M_MSGTY = GV_M_MSGTY .
me->GV_M_MSGV1 = GV_M_MSGV1 .
me->GV_M_MSGV2 = GV_M_MSGV2 .
me->GV_M_MSGV3 = GV_M_MSGV3 .
me->GV_M_MSGV4 = GV_M_MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  method GET_EXCEPTION_MESSAGE.
    IF me IS BOUND.
      cl_message_helper=>get_t100_text_for(
        EXPORTING
          obj     = me
          t100key = me->gs_t100key
        IMPORTING
          result  = rv_result ).
    ENDIF.

  endmethod.


  METHOD get_sy_msg.
    IF if_t100_message~t100key-msgid IS INITIAL
    OR if_t100_dyn_msg~msgty         IS INITIAL.
      " An exception was raised
      MESSAGE e530(sy) INTO rv_msg.
      RETURN.
    ENDIF.

    MESSAGE ID if_t100_message~t100key-msgid TYPE if_t100_dyn_msg~msgty NUMBER if_t100_message~t100key-msgno
      WITH if_t100_dyn_msg~msgv1 if_t100_dyn_msg~msgv2 if_t100_dyn_msg~msgv3 if_t100_dyn_msg~msgv4
      INTO rv_msg.
  ENDMETHOD.


  METHOD raise_exception.
    DATA: lx_ref_exception                 TYPE REF TO zcx_vi02_general_exception.

    CREATE OBJECT lx_ref_exception.
    CLEAR lx_ref_exception->gs_t100key.

    lx_ref_exception->gv_m_msgty       = iv_msgty.
    lx_ref_exception->gs_t100key-msgid = iv_msgid.
    lx_ref_exception->gs_t100key-msgno = iv_msgno.
    lx_ref_exception->gs_t100key-attr1 = 'M_MSGV1'.
    lx_ref_exception->gs_t100key-attr2 = 'M_MSGV2'.
    lx_ref_exception->gs_t100key-attr3 = 'M_MSGV3'.
    lx_ref_exception->gs_t100key-attr4 = 'M_MSGV4'.

    WRITE:
      iv_msgv1 TO lx_ref_exception->gv_m_msgv1 LEFT-JUSTIFIED,
      iv_msgv2 TO lx_ref_exception->gv_m_msgv2 LEFT-JUSTIFIED,
      iv_msgv3 TO lx_ref_exception->gv_m_msgv3 LEFT-JUSTIFIED,
      iv_msgv4 TO lx_ref_exception->gv_m_msgv4 LEFT-JUSTIFIED.

    RAISE EXCEPTION lx_ref_exception.
  ENDMETHOD.


  method RAISE_SYSTEM_EXCEPTION.
    raise_exception(
   iv_msgty = sy-msgty
   iv_msgid = sy-msgid
   iv_msgno = sy-msgno
   iv_msgv1 = sy-msgv1
   iv_msgv2 = sy-msgv2
   iv_msgv3 = sy-msgv3
   iv_msgv4 = sy-msgv4 ).
  endmethod.


  METHOD raise_sy_msg.
    IF sy-msgid IS INITIAL
    OR sy-msgty IS INITIAL.
      " An exception was raised
      RAISE EXCEPTION TYPE zcx_vi02_general_exception
        MESSAGE e530(sy)
        EXPORTING
          previous = ix_prev.
    ENDIF.

    RAISE EXCEPTION TYPE zcx_vi02_general_exception
      USING MESSAGE
      EXPORTING
        previous = ix_prev.
  ENDMETHOD.
ENDCLASS.
