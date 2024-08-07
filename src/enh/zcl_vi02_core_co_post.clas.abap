class ZCL_VI02_CORE_CO_POST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_CORE_CO_POST .
protected section.
private section.

  methods WTCONF_CTRL_GET
    importing
      !IS_ORDIM_C type /SCWM/ORDIM_C
      !IV_CALLER type ZEWM_DE_CALLERBADI
    exporting
      !ET_WTCONF type ZEWM_WTCONF_CTRL_TT .
ENDCLASS.



CLASS ZCL_VI02_CORE_CO_POST IMPLEMENTATION.


  METHOD /scwm/if_ex_core_co_post~post.
    DATA:
      lt_conf         TYPE zewm_wtconf_ctrl_tt,
      lo_class        TYPE REF TO object,
      lt_ordim_c      TYPE /scwm/tt_ordim_c,
      lo_dlv          TYPE REF TO /scwm/cl_dlv_management_prd,
      lt_dlv_sel      TYPE /scwm/dlv_selection_tab,
      ls_dlv_sel      TYPE /scwm/dlv_selection_str,
      ls_read_options TYPE /scwm/dlv_query_contr_str,
      lt_prd_hdr_act  TYPE /scwm/dlv_header_out_prd_tab,
      ls_include_data TYPE /scwm/dlv_query_incl_str_prd.

    LOOP AT it_ordim_c INTO DATA(ls_ordim_c).
      CLEAR: lt_conf[].

      me->wtconf_ctrl_get( EXPORTING is_ordim_c = ls_ordim_c
                                     iv_caller  = 'CO'
                           IMPORTING et_wtconf  = lt_conf ).

      IF lt_conf IS NOT INITIAL.
        IF ls_ordim_c-tostat = 'C' AND ls_ordim_c-rdoccat = wmegc_doccat_pdo.

          ls_include_data-head_status = abap_true.
          ls_include_data-item_status = abap_true.
          ls_include_data-head_status_dyn = abap_true.
          ls_read_options-keys_only = 'X'.
          ls_include_data-head_partyloc = 'X'.

          TRY.
              CALL METHOD lo_dlv->query
                EXPORTING
                  it_docid        = VALUE #( ( docid = ls_ordim_c-rdocid
                                               doccat = wmegc_doccat_pdo ) )
                  iv_doccat       = wmegc_doccat_pdo
                  is_read_options = ls_read_options
                  is_include_data = ls_include_data
                IMPORTING
                  et_headers      = lt_prd_hdr_act.

            CATCH /scdl/cx_delivery.
          ENDTRY.

          IF lt_prd_hdr_act IS NOT INITIAL.
            LOOP AT lt_prd_hdr_act ASSIGNING FIELD-SYMBOL(<ls_header>).
              ASSIGN <ls_header>-status[ status_type = 'DER' ] TO FIELD-SYMBOL(<ls_der>).
              CHECK sy-subrc = 0.
              IF <ls_der>-status_value = '9'.
                IF  it_ordim_o_upd IS INITIAL.

                  CLEAR: lt_ordim_c[].
                  APPEND ls_ordim_c TO lt_ordim_c[].

                  LOOP AT lt_conf INTO DATA(ls_conf).
                    TRY.
                        " call handling class and method dynamically
                        CREATE OBJECT lo_class TYPE (ls_conf-class).

                        CALL METHOD lo_class->(ls_conf-method)
                          EXPORTING
                            it_ordim_c = lt_ordim_c.
                      CATCH /scwm/cx_core.
                    ENDTRY.
                  ENDLOOP.
                ELSE.
                  RETURN.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method WTCONF_CTRL_GET.

    DATA:
      lt_conf   TYPE    zewm_wtconf_ctrl_tt.
    DATA(ls_ordim_c) = is_ordim_c.
*--------------------------------------------------------------------*
* . VOLL QUALIFIZIERT
*--------------------------------------------------------------------*
    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM zewm_wtconf_ctrl INTO TABLE lt_conf
     WHERE lgnum  = ls_ordim_c-lgnum
       AND vltyp  = ls_ordim_c-vltyp
       AND vlpla  = ls_ordim_c-vlpla
       AND nltyp  = ls_ordim_c-nltyp
       AND nlpla  = ls_ordim_c-nlpla
       AND procty = ls_ordim_c-procty
       AND callerbadi = iv_caller.
    IF sy-subrc NE 0.
      " Check for NLPLA only to trigger prints for check list etc.
      "----------------------------------------------------------
      " NLTYP + NLPLA
      "----------------------------------------------------------
      SELECT *                                "#EC CI_ALL_FIELDS_NEEDED
         FROM zewm_wtconf_ctrl INTO TABLE lt_conf
         WHERE lgnum  = ls_ordim_c-lgnum
           AND nltyp  = ls_ordim_c-nltyp
           AND nlpla  = ls_ordim_c-nlpla
           AND callerbadi = iv_caller.

      IF sy-subrc NE 0.
        "----------------------------------------------------------
        " . VLTYP + NLTYP + PROCTY
        "----------------------------------------------------------
        SELECT  *                             "#EC CI_ALL_FIELDS_NEEDED
          FROM zewm_wtconf_ctrl INTO TABLE lt_conf
         WHERE lgnum      = ls_ordim_c-lgnum
           AND vltyp      = ls_ordim_c-vltyp
           AND nltyp      = ls_ordim_c-nltyp
           AND procty     = ls_ordim_c-procty
           AND callerbadi = iv_caller.
        IF sy-subrc NE 0.
          "----------------------------------------------------------
          " . VLTYP + NLTYP
          "----------------------------------------------------------
          SELECT *                            "#EC CI_ALL_FIELDS_NEEDED
            FROM zewm_wtconf_ctrl INTO TABLE lt_conf
           WHERE lgnum      = ls_ordim_c-lgnum
             AND vltyp      = ls_ordim_c-vltyp
             AND nltyp      = ls_ordim_c-nltyp
             AND callerbadi = iv_caller.
          IF sy-subrc NE 0.
            "----------------------------------------------------------
            " . NLTYP + PROCTY
            "----------------------------------------------------------
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
              FROM zewm_wtconf_ctrl INTO TABLE lt_conf
             WHERE lgnum      = ls_ordim_c-lgnum
               AND vltyp      = ' '             " VON Lagertyp <LEER> gepflegt
               AND nltyp      = ls_ordim_c-nltyp
               AND procty     = ls_ordim_c-procty
               AND callerbadi = iv_caller.
            IF sy-subrc NE 0.
              SELECT *                        "#EC CI_ALL_FIELDS_NEEDED
              FROM zewm_wtconf_ctrl INTO TABLE lt_conf
             WHERE lgnum      = ls_ordim_c-lgnum
               AND vltyp      = ls_ordim_c-vltyp  " VON Lagertyp
               AND nltyp      = ' '               " NACH Lagertyp <LEER> gepflegt
               AND procty     = '9201'            " Process type <0000> gepflegt für spezielle Findung
               AND callerbadi = iv_caller.
              IF sy-subrc NE 0.
                SELECT *                      "#EC CI_ALL_FIELDS_NEEDED
                FROM zewm_wtconf_ctrl INTO TABLE lt_conf
               WHERE lgnum      = ls_ordim_c-lgnum
                 AND vltyp      = ' '             " VON Lagertyp <LEER> gepflegt
                 AND nltyp      = ' '             " NACH Lagertyp <LEER> gepflegt
                 AND procty     = '0000'          " Process type <0000> gepflegt für spezielle Findung
                 AND callerbadi = iv_caller.
                IF sy-subrc NE 0.
                  CLEAR: lt_conf.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    DELETE lt_conf WHERE noact EQ abap_true.

    et_wtconf = lt_conf.

  endmethod.
ENDCLASS.
