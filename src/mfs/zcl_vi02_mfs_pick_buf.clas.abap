CLASS zcl_vi02_mfs_pick_buf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF mc_buffer_mode,
        waste_pallet         TYPE z_vi02_de_buffer_mode VALUE 'W',
        pallet_box           TYPE z_vi02_de_buffer_mode VALUE 'B',
        source_pallet        TYPE z_vi02_de_buffer_mode VALUE 'S',
        plastic_pallet       TYPE z_vi02_de_buffer_mode VALUE 'P',
        plastic_pallet_stack TYPE z_vi02_de_buffer_mode VALUE 'D',
      END OF mc_buffer_mode .

    CLASS-METHODS get_empty_buffer
      IMPORTING
        !iv_lgnum       TYPE /scwm/lgnum
        !iv_buffer_mode TYPE z_vi02_de_buffer_mode
        !iv_nlpla       TYPE /scwm/ltap_nlpla OPTIONAL
      RETURNING
        VALUE(rv_lgpla) TYPE /scwm/lgpla .
    CLASS-METHODS find_in_buffer
      IMPORTING
        !iv_lgnum           TYPE /scwm/lgnum
        !iv_buffer_mode     TYPE z_vi02_de_buffer_mode
        !iv_nlpla           TYPE /scwm/ltap_nlpla OPTIONAL
        !iv_product_who     TYPE /scwm/de_who OPTIONAL
      RETURNING
        VALUE(RT_huhdr_mon) TYPE /SCWM/TT_huhdr_mon .
    CLASS-METHODS pull
      IMPORTING
        !iv_lgnum     TYPE /scwm/lgnum
        !iv_lgpla_buf TYPE /scwm/lgpla
      RETURNING
        VALUE(ro_wt)  TYPE REF TO /sl0/cl_wt.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS:
      pull_pallet_box
        IMPORTING
          !iv_lgnum     TYPE /scwm/lgnum
          !iv_lgpla_buf TYPE /scwm/lgpla
        RETURNING
          VALUE(ro_wt)  TYPE REF TO /sl0/cl_wt,
      pull_plastic_pallet_stack
        IMPORTING
          !iv_lgnum     TYPE /scwm/lgnum
          !iv_lgpla_buf TYPE /scwm/lgpla
        RETURNING
          VALUE(ro_wt)  TYPE REF TO /sl0/cl_wt,
      pull_waste_pallet
        IMPORTING
          !iv_lgnum     TYPE /scwm/lgnum
          !iv_lgpla_buf TYPE /scwm/lgpla
        RETURNING
          VALUE(ro_wt)  TYPE REF TO /sl0/cl_wt ,
      pull_plastic_pallet
        IMPORTING
          !iv_lgnum     TYPE /scwm/lgnum
          !iv_lgpla_buf TYPE /scwm/lgpla
        RETURNING
          VALUE(ro_wt)  TYPE REF TO /sl0/cl_wt .
ENDCLASS.



CLASS ZCL_VI02_MFS_PICK_BUF IMPLEMENTATION.


  METHOD find_in_buffer.
*--------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*--------------------------------------------------------------------------------*
*
* Description:
* Find all HUs for a specific buffer mode (i.e. source pallets, waste or box pallets)
* in the buffer of a specific workstation bin (iv_nlpla). The iv_product_who constraint
* only makes sense for source pallets.
*
* Only HUs without WT will be returned (as potential candidates for WT creation)
*--------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*---------------------- Documentation of Changes --------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-11-09 ¦Yuriy Dzhenyeyev¦Initial
*--------------------------------------------------------------------------------*
    DATA lt_nlpla_r TYPE /scwm/tt_nlpla_r.
    IF iv_nlpla IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = iv_nlpla ) TO lt_nlpla_r.
    ENDIF.

    SELECT FROM zvi02_pick_buf AS b
      JOIN /scwm/lagp AS l
        ON l~lgnum = b~lgnum
          AND l~lgpla = b~lgpla
      LEFT JOIN /scwm/ordim_o AS o
        ON o~lgnum = b~lgnum
        AND o~vlpla = b~lgpla
      FIELDS 'I' AS sign, 'EQ' AS option, b~lgpla AS low
      WHERE b~lgnum = @iv_lgnum
        AND buffer_mode = @iv_buffer_mode
        AND b~nlpla IN @lt_nlpla_r
        AND b~lgpla <> b~nlpla "not the workstation target
        AND l~skzua = @( VALUE /scwm/lagp_skzua( ) ) "available to the workstation
        AND l~kzler = @( VALUE /scwm/lagp_kzler( ) ) "not empty
        AND o~tanum IS NULL "no outbound WT from this buffer
      INTO TABLE @DATA(lt_lgpla_r).

    CHECK lt_lgpla_r IS NOT INITIAL.

    "get HUs from these storage bins
    NEW /scwm/cl_mon_stock( iv_lgnum )->get_hu(
      EXPORTING
        it_lgpla_r       = CONV #( lt_lgpla_r )                 " Range Table Type for Field Name LGPLA
      IMPORTING
        et_hu_mon        = rt_huhdr_mon               " Handling Unit Header Data for the Monitor
        ev_error         = DATA(lv_error)                 " Checkbox
    ).

    CHECK: iv_product_who IS NOT INITIAL,
           rt_huhdr_mon IS NOT INITIAL.

    "filter for HUs assigned to the specified warehouse order
    "(this only makes sense if buffer is configured for source pallets)
    DATA(lt_huident_r) = VALUE /scwm/tt_huident_r(
                           FOR ls_huhdr_mon IN rt_huhdr_mon (
                             VALUE #( sign = 'I' option = 'EQ' low = ls_huhdr_mon-huident ) ) ).

    DATA lt_huident_wo_r TYPE /scwm/tt_huident_r.

    SELECT FROM /scwm/ordim_o
      FIELDS 'I' AS sign, 'EQ' AS option, vlenr AS low
      WHERE lgnum = @iv_lgnum
        AND vlenr IN @lt_huident_r
        AND flghuto = ' ' "product-WTs
        AND who = @iv_product_who
      INTO TABLE @lt_huident_wo_r.

    rt_huhdr_mon = VALUE #( FOR ls_huhdr_mon IN rt_huhdr_mon
                            WHERE ( huident IN lt_huident_wo_r ) ( ls_huhdr_mon ) ).

  ENDMETHOD.


  METHOD get_empty_buffer.
*--------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*--------------------------------------------------------------------------------*
*
* Description:
* Find an empty buffer. The iv_nlpla (being the target storage bin at the workstation)
* constraint makes sense only for source pallet buffers, as source pallets belong
* to picking orders and therefore to specific workstations.
* In other cases, a workstation with the lowest stock of the provided buffer mode
* (i.e. waste or box pallets) will be returned.
*
*--------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*---------------------- Documentation of Changes --------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-11-09 ¦Yuriy Dzhenyeyev¦Initial
*--------------------------------------------------------------------------------*

    DATA lt_nlpla_r TYPE /scwm/tt_lgpla_r.

    IF iv_nlpla IS NOT INITIAL.
      "we are looking into a specific workstation source
      APPEND VALUE #( sign = 'I' option = 'EQ' low = iv_nlpla ) TO lt_nlpla_r.
    ENDIF.

    SELECT FROM zvi02_pick_buf AS b
      JOIN /scwm/lagp AS l
        ON l~lgnum = b~lgnum
          AND l~lgpla = b~lgpla
      LEFT JOIN /scwm/ordim_o AS o_in "WTs to buffer
        ON o_in~lgnum = b~lgnum
          AND o_in~nlpla = b~lgpla
      LEFT JOIN /scwm/ordim_o AS o_out "WTs from buffer
        ON o_out~lgnum = b~lgnum
          AND o_out~vlpla = b~lgpla
      FIELDS b~lgpla, b~nlpla, l~kzler, l~skzue, l~skzua,
             b~buffer_mode, o_in~tanum AS tanum_in, o_out~tanum AS tanum_out,
             "you can create an entry for the workstation source with LGPLA = NLPLA
             "if workstation source and its buffers are empty, workstation source will be served first
             CASE WHEN b~lgpla = b~nlpla THEN 1 ELSE 2 END AS flg_wkss
      WHERE b~lgnum = @iv_lgnum
        AND buffer_mode = @iv_buffer_mode
        AND b~nlpla IN @lt_nlpla_r
      INTO TABLE @DATA(lt_pick_buf).

    TYPES:
      BEGIN OF t_nlpla_cnt,
        nlpla TYPE /scwm/ltap_nlpla,
        cnt   TYPE int2,
      END OF t_nlpla_cnt.

    " check if smth. is already stored in the buffers
    DATA lt_nlpla_cnt TYPE TABLE OF t_nlpla_cnt WITH EMPTY KEY.
    DATA ls_nlpla_cnt TYPE t_nlpla_cnt.

    LOOP AT lt_pick_buf
      INTO DATA(ls_pick_buf)
      WHERE kzler IS INITIAL "buffer not empty
        AND skzua IS INITIAL "available to the workstation
        AND tanum_out IS INITIAL "HU is not leaving the buffer
        AND buffer_mode EQ iv_buffer_mode
      GROUP BY ( nlpla = ls_pick_buf-nlpla cnt = GROUP SIZE ) INTO ls_nlpla_cnt.

      APPEND ls_nlpla_cnt TO lt_nlpla_cnt.
    ENDLOOP.

    "add missing target storage bins with count = 0
    LOOP AT lt_pick_buf INTO ls_pick_buf.
      CHECK NOT line_exists( lt_nlpla_cnt[ nlpla = ls_pick_buf-nlpla ] ).

      APPEND VALUE #( nlpla = ls_pick_buf-nlpla ) TO lt_nlpla_cnt.
    ENDLOOP.

    " select a workstation with the least available HUs in the buffer
    SORT lt_nlpla_cnt BY cnt ASCENDING.

    LOOP AT lt_nlpla_cnt INTO ls_nlpla_cnt.
      DO 2 TIMES.
        ls_pick_buf = VALUE #( lt_pick_buf[ nlpla = ls_nlpla_cnt-nlpla " workstation target bin with the least buffered HUs
                                            kzler = 'X' "buffer is empty
                                            skzue = VALUE /scwm/lagp_skzue( ) "buffer is not locked for putaway
                                            tanum_in = VALUE /scwm/tanum( ) "no inbound WT
                                            buffer_mode = iv_buffer_mode "buffer of the right mode
                                            flg_wkss = sy-index ] "if the workstation AND its buffers are empty, serve workstation first
                                            OPTIONAL ).

        IF ls_pick_buf IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDDO.

      CHECK ls_pick_buf IS NOT INITIAL.
      EXIT.
    ENDLOOP.

    CHECK ls_pick_buf IS NOT INITIAL.

    "try lock the buffer to prevent concurrent access
    CALL FUNCTION 'ENQUEUE_/SCWM/ELLAGPE'
      EXPORTING
*       mode_/scwm/lagp = 'E'              " Lock mode for table /SCWM/LAGP
        lgnum          = iv_lgnum
        lgpla          = ls_pick_buf-lgpla
*       _scope         = '2'
*       _wait          = space
*       _collect       = ' '              " Initially only collect lock
      EXCEPTIONS
        foreign_lock   = 1                " Object already locked
        system_failure = 2                " Internal error from enqueue server
        OTHERS         = 3.

    CHECK sy-subrc IS INITIAL.

    "use this buffer
    rv_lgpla = ls_pick_buf-lgpla.

  ENDMETHOD.


  METHOD pull.
*--------------------------------------------------------------------------------*
* Swisslog GmbH, Dortmund
*--------------------------------------------------------------------------------*
*
* Request a HU for a buffer
*
*--------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*---------------------- Documentation of Changes --------------------------------*
* Ver. ¦Date       ¦Author          ¦Description
* -----¦-----------¦----------------¦--------------------------------------------*
* 1.0  ¦2023-11-13 ¦Yuriy Dzhenyeyev¦Initial
*--------------------------------------------------------------------------------*
    "What mode is assigned to this buffer?
    SELECT SINGLE FROM zvi02_pick_buf AS b
      JOIN /scwm/lagp AS l
      ON l~lgnum = b~lgnum
        AND l~lgpla = b~lgpla
      FIELDS b~buffer_mode, l~skzue
      WHERE b~lgnum = @iv_lgnum
      AND b~lgpla = @iv_lgpla_buf
      INTO @DATA(ls_buf).

    CHECK:
      ls_buf-buffer_mode NE mc_buffer_mode-source_pallet, "buffer for source pallets cannot pull HUs
      ls_buf-skzue IS INITIAL. "buffer should not be locked for putaway

    CASE ls_buf-buffer_mode.
      WHEN mc_buffer_mode-pallet_box.
        ro_wt = pull_pallet_box(
                  iv_lgnum = iv_lgnum
                  iv_lgpla_buf = iv_lgpla_buf
                ).
      WHEN mc_buffer_mode-waste_pallet.
        ro_wt = pull_waste_pallet(
                  iv_lgnum = iv_lgnum
                  iv_lgpla_buf = iv_lgpla_buf
                ).
      WHEN mc_buffer_mode-plastic_pallet.
        ro_wt = pull_plastic_pallet(
                  iv_lgnum = iv_lgnum
                  iv_lgpla_buf = iv_lgpla_buf
                ).
      WHEN mc_buffer_mode-plastic_pallet_stack.
        ro_wt = pull_plastic_pallet_stack(
                  iv_lgnum = iv_lgnum
                  iv_lgpla_buf = iv_lgpla_buf
                ).
    ENDCASE.

  ENDMETHOD.


  METHOD pull_pallet_box.
    "box pallets can be pulled from the loop at CONV14 production returns or from Ambient Storage

    DATA(lt_pmat_r) = /sl0/cl_param_select=>read_const_range(
                        iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                        iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                        iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                        iv_parameter    = zif_vi02_c=>gc_param-pmat_pal_box              " Parameter name
                      ).

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Pull from the loop ( boxes returning from production)
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*  |   ^
*  v   |
*  +<--+<-- CV14-OBS6 <---------------+<----
*  |   ^                              ^
*  v   |                              |
*  +-->+------------------->CV14-OBS7-+---->

* If there is a pallet box in the loop, that can be used, it will be waiting at CV14-OBS7 w/o a WT.
* Additional attempt to find a destination for a pallet box should be made upon its arrival (ACP).
* This is out of this method's scope though.

    DATA(lt_lgpla_r) = /sl0/cl_param_select=>read_const_range(
                            iv_lgnum        = iv_lgnum                 " Warehouse Number/Warehouse Complex
                            iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs                 " /SL0/DO_PARAM_PROF
                            iv_context      = /sl0/cl_param_c=>c_context_id_point                 " Context for Parameter (Program, BADI, ..)
                            iv_parameter    = zif_vi02_c=>gc_param-loop_cv14              " Parameter name
                          ).

    CHECK lt_lgpla_r IS NOT INITIAL.

    DATA(lo_mon_stock) = NEW /scwm/cl_mon_stock( iv_lgnum ).

    lo_mon_stock->get_hu(
      EXPORTING
        it_pmat_r        = CONV #( lt_pmat_r )
        iv_hu_empty      = 'X'
        it_lgpla_r       = CONV #( lt_lgpla_r )
      IMPORTING
        et_hu_mon        = DATA(lt_hu_mon)
        ev_error         = DATA(lv_error)
    ).

    LOOP AT lt_hu_mon INTO DATA(ls_hu_mon)
      WHERE flgmove IS INITIAL. "there should be only one HU w/o WT here

      ro_wt = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum                 " Warehouse Number/Warehouse Complex
                              i_huident = ls_hu_mon-huident
                              )->move( i_procty = 'TODO'
                                       i_nlpla  = iv_lgpla_buf ).

      RETURN. "done
    ENDLOOP.

*~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Pull from ambient storage
*~~~~~~~~~~~~~~~~~~~~~~~~~~~

    lo_mon_stock->get_hu(
      EXPORTING
        it_pmat_r        = CONV #( lt_pmat_r )
        iv_hu_empty      = 'X'
        it_lgtyp_r       = VALUE #( ( sign = 'I' option = 'EQ' low = zif_vi02_c=>gc_lgtyp-ambient ) )
      IMPORTING
        et_hu_mon        = lt_hu_mon
        ev_error         = lv_error
    ).

    CHECK lt_hu_mon IS NOT INITIAL.

    "kind of FIFO
    SORT lt_hu_mon BY changed_date ASCENDING.

    ro_wt = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum                 " Warehouse Number/Warehouse Complex
                            i_huident = lt_hu_mon[ 1 ]-huident
                            )->move( i_procty = 'TODO'
                                     i_nlpla  = iv_lgpla_buf ).
  ENDMETHOD.


  METHOD pull_plastic_pallet.
* Plastic pallets can be pulled from destacker.

    DATA(lt_huhdr) = find_in_buffer(
                      iv_lgnum       = iv_lgnum
*                      iv_nlpla = ... "There is only one destacker for plastic pallets at Lonza
                                      "and (possibly) two workstations, hence no assignment
                                      "to a specific workstation
                      iv_buffer_mode = mc_buffer_mode-plastic_pallet ).

    CHECK lt_huhdr IS NOT INITIAL.

    "there is a pallet stack in the destacker, proceed

    DATA(lv_pmat_plastic_pal) = /sl0/cl_param_select=>read_const(
                        iv_lgnum        = iv_lgnum
                        iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs
                        iv_context      = /sl0/cl_param_c=>c_context_id_point
                        iv_parameter    = zif_vi02_c=>gc_param-pmat_plastic_pal ).

    NEW /scwm/cl_wm_packing( )->create_hu(
      EXPORTING
        iv_pmat      = CONV #( lv_pmat_plastic_pal )                 " Material GUID16 with Conversion Exit
        i_location   = lt_huhdr[ 1 ]-lgpla "destacker
      RECEIVING
        es_huhdr = DATA(ls_huhdr)
      EXCEPTIONS
        error        = 1
        OTHERS       = 2
    ).

    CHECK sy-subrc IS INITIAL.

    DATA:
      lv_severity TYPE bapi_mtype,
      lt_bapiret  TYPE bapirettab.

    CALL FUNCTION '/SCWM/TO_POST'
      EXPORTING
        iv_update_task = ' '
      IMPORTING
        ev_severity    = lv_severity
        et_bapiret     = lt_bapiret.

    IF lv_severity CA 'EAX'.
      ROLLBACK WORK.
      /scwm/cl_tm=>cleanup( ).

      RETURN.
    ENDIF.

    "move dummy-HU to the buffer
    TRY.
        ro_wt = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum
                                i_huident = ls_huhdr-huident
                                )->move( i_procty   = 'TODO'
                                         i_nlpla    =  iv_lgpla_buf ).
      CATCH /sl0/cx_general_exception. " Error handling class

    ENDTRY.
  ENDMETHOD.


  METHOD pull_plastic_pallet_stack.
    "TODO Eser
  ENDMETHOD.


  METHOD pull_waste_pallet.
    DATA(lt_pmat_r) = /sl0/cl_param_select=>read_const_range(
                        iv_lgnum        = iv_lgnum
                        iv_param_prof   = /sl0/cl_param_c=>c_prof_mfs
                        iv_context      = /sl0/cl_param_c=>c_context_id_point
                        iv_parameter    = zif_vi02_c=>gc_param-pmat_wpallet ).

    NEW /scwm/cl_mon_stock( iv_lgnum )->get_hu(
      EXPORTING
        it_pmat_r        = CONV #( lt_pmat_r )
        iv_hu_empty      = 'X'
        it_lgtyp_r       = VALUE #( ( sign = 'I' option = 'EQ' low = zif_vi02_c=>gc_lgtyp-ambient ) )
      IMPORTING
        et_hu_mon        = DATA(lt_hu_mon)
        ev_error         = DATA(lv_error)
    ).

    CHECK lt_hu_mon IS NOT INITIAL.

    "kind of FIFO
    SORT lt_hu_mon BY changed_date ASCENDING.

    ro_wt = NEW /sl0/cl_hu( i_lgnum   = iv_lgnum                 " Warehouse Number/Warehouse Complex
                            i_huident = lt_hu_mon[ 1 ]-huident
                            )->move( i_procty = 'TODO'
                                     i_nlpla  = iv_lgpla_buf ).
  ENDMETHOD.
ENDCLASS.
