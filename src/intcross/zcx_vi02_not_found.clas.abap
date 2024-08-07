class ZCX_VI02_NOT_FOUND definition
  public
  inheriting from ZCX_VI02_GENERAL_EXCEPTION
  create public .

public section.

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
protected section.
private section.
ENDCLASS.



CLASS ZCX_VI02_NOT_FOUND IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
GS_T100KEY = GS_T100KEY
GV_M_MSGTY = GV_M_MSGTY
GV_M_MSGV1 = GV_M_MSGV1
GV_M_MSGV2 = GV_M_MSGV2
GV_M_MSGV3 = GV_M_MSGV3
GV_M_MSGV4 = GV_M_MSGV4
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
