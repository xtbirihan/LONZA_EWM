CLASS zcl_enh_vi02_mfse_route_node DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /sl0/if_mfse_badi_route_node .
  PROTECTED SECTION.
    METHODS:
      get_color
        IMPORTING
                  io_node         TYPE REF TO /sl0/cl_mfse_route_node
        RETURNING VALUE(rv_color) TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ENH_VI02_MFSE_ROUTE_NODE IMPLEMENTATION.


  METHOD /sl0/if_mfse_badi_route_node~get_graphviz_header.
  ENDMETHOD.


  METHOD /sl0/if_mfse_badi_route_node~get_graphviz_node.
    rv_result = |"{ io_node->gv_name }" [shape=box{ get_color( io_node ) }, label="{ io_node->gv_name(2) }-{ io_node->gv_name+2(3) }-{ io_node->gv_name+5(4) }-{ io_node->gv_name+9(3) }"]|.

* addin list of telegrams
    SELECT tg_class FROM /sl0/convtel INTO TABLE @DATA(lt_telealias)
      WHERE sisadr = @io_node->gv_name.

    CHECK lt_telealias IS NOT INITIAL.

    DATA(lv_list) = REDUCE string( INIT lv_tmp TYPE string
                             FOR ls_line IN lt_telealias
                             NEXT lv_tmp = lv_tmp
                                  && SWITCH string( strlen( lv_tmp ) WHEN 0 THEN '' ELSE '\n' )
                                  && ls_line-tg_class ).

    rv_result = |"{ io_node->gv_name }" [shape=box{ get_color( io_node ) }, label="{ io_node->gv_name(2) }-{ io_node->gv_name+2(3) }-{ io_node->gv_name+5(4) }-{ io_node->gv_name+9(3) }\n{ lv_list }"]|.

* fill boxes with color: e.g. [shape=box, style=filled, fillcolor="orange"]
* also possible with color as #RRGGBB

* for other attributes see https://graphviz.org/doc/info/attrs.html

  ENDMETHOD.


  METHOD /sl0/if_mfse_badi_route_node~is_allowed.
    "unchanged
  ENDMETHOD.


  METHOD get_color.
    TYPES: BEGIN OF t_kv,
             sw_group TYPE char5,
             color    TYPE string,
           END OF t_kv,

           tt_kv TYPE TABLE OF t_kv WITH EMPTY KEY.

    DATA(lt_kv) = VALUE tt_kv(
     ( sw_group = '11001' color = '#b7dde8' )
     ( sw_group = '11002' color = '#ddd6e5' )
     ( sw_group = '11003' color = '#d7e3bf' )
     ( sw_group = '11004' color = '#e5b9b5' )
     ( sw_group = '11005' color = '#ffc1fe' )
     ( sw_group = '11006' color = '#fee599' )
     ( sw_group = '11007' color = '#99ff99' )
     ( sw_group = '11008' color = '#ccccff' )
     ( sw_group = '11009' color = '#ffd7bb' )

     ( sw_group = '12001' color = '#b7dde8' )
     ( sw_group = '12002' color = '#ddd6e5' )
     ( sw_group = '12003' color = '#e3ebd2' )
     ( sw_group = '12004' color = '#edcecb' )
     ( sw_group = '12005' color = '#ffc1fe' )
     ( sw_group = '12006' color = '#fee599' )
     ( sw_group = '12007' color = '#99ff99' )
     ( sw_group = '12008' color = '#ccccff' )
     ( sw_group = '12009' color = '#ffddff' )
    ).

    DATA(lv_sw_group) = io_node->gv_name(5).

    READ TABLE lt_kv WITH KEY sw_group = lv_sw_group INTO data(ls_kv).

    check sy-subrc is initial.

    rv_color = |, style=filled, fillcolor="{ ls_kv-color }"|.

  ENDMETHOD.
ENDCLASS.
