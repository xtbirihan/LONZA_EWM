FUNCTION z_vi02_sh_work_center.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
  TYPES: BEGIN OF t_result,
           lgnum       TYPE /scwm/lgnum,
           workstation TYPE /scwm/de_workstation,
           description TYPE /scwm/de_desc40,
           procs       TYPE /scwm/de_procs,
         END OF t_result.
  DATA: ls_shlp_selopt TYPE ddshselopt,
        lr_lgnum       TYPE rseloption,
        ls_lgnum       TYPE rsdsselopt,
        lr_workst      TYPE rseloption,
        ls_workst      TYPE rsdsselopt,
        lr_procs       TYPE rseloption,
        ls_procs       TYPE rsdsselopt,
        lr_trtyp       TYPE rseloption,
        ls_trtyp       TYPE rsdsselopt,
        lr_wrksttyp    TYPE rseloption,
        ls_wrksttyp    TYPE rsdsselopt,
        ls_tworkst     TYPE /scwm/tworkst,
        ls_tworkstt    TYPE /scwm/tworkstt,
        lt_tworkst     TYPE TABLE OF /scwm/tworkst,
        lt_tworkstt    TYPE TABLE OF /scwm/tworkstt,
        ls_result      TYPE t_result,
        lt_result      TYPE TABLE OF t_result.
  STATICS: st_twrktyp TYPE TABLE OF /scwm/twrktyp.

  CHECK callcontrol-step = 'SELECT'.

**-->> added by tbirihan
*0) Check sampling layout of workcenter
*Standard value help copied *0 added to extend search help
  DATA(lv_lgnum) = VALUE #( shlp-selopt[ shlpfield = 'LGNUM' ]-low OPTIONAL ).
  IF lv_lgnum IS INITIAL. RETURN.  ENDIF.

  DATA(lv_layout) = /sl0/cl_param_select=>read_const(
    EXPORTING
      iv_lgnum      = CONV #( lv_lgnum )
      iv_param_prof = zif_vi02_param_c=>c_prof_sampling
      iv_context    = zif_vi02_param_c=>c_context_sampling
      iv_parameter  = zif_vi02_param_c=>c_param_workstation_layout
  ).
  IF lv_layout IS INITIAL. RETURN. ENDIF.
  APPEND VALUE #( sign = wmegc_sign_inclusive option = wmegc_option_eq low = lv_layout ) TO lr_wrksttyp.
**--<< added by tbirihan

*1) Prepare input data for the selects
* warehouse
  LOOP AT shlp-selopt INTO ls_shlp_selopt
    WHERE shlpfield = 'LGNUM'.
    CLEAR ls_lgnum.
    MOVE-CORRESPONDING ls_shlp_selopt TO ls_lgnum.
    APPEND ls_lgnum TO lr_lgnum.
  ENDLOOP.

* WORK CENTER
  LOOP AT shlp-selopt INTO ls_shlp_selopt
    WHERE shlpfield = 'WORKSTATION'.
    CLEAR ls_workst.
    MOVE-CORRESPONDING ls_shlp_selopt TO ls_workst.
    APPEND ls_workst TO lr_workst.
  ENDLOOP.

* Process Step
  LOOP AT shlp-selopt INTO ls_shlp_selopt
    WHERE shlpfield = 'PROCS'.
    CLEAR ls_procs.
    MOVE-CORRESPONDING ls_shlp_selopt TO ls_procs.
    APPEND ls_procs TO lr_procs.
  ENDLOOP.

* Transaction Type
  LOOP AT shlp-selopt INTO ls_shlp_selopt
    WHERE shlpfield = 'TRTYP'.
    CLEAR ls_trtyp.
    MOVE-CORRESPONDING ls_shlp_selopt TO ls_trtyp.
    APPEND ls_trtyp TO lr_trtyp.
  ENDLOOP.

*2) Select all necessary data
* Select in /SCWM/TWRKTYP
  IF st_twrktyp IS INITIAL.
* assume that the lr_trtyp is always the same in one LUW
    SELECT * FROM /scwm/twrktyp INTO TABLE st_twrktyp WHERE
                              lgnum IN lr_lgnum AND
                              wrksttyp IN lr_wrksttyp AND
                              trtyp IN lr_trtyp.
  ENDIF.
  CHECK st_twrktyp IS NOT INITIAL."no full table scan

** select in /SCWM/TWORKST
  SELECT * FROM /scwm/tworkst INTO TABLE lt_tworkst
            FOR ALL ENTRIES IN st_twrktyp
                 WHERE   wrksttyp = st_twrktyp-wrksttyp
                     AND lgnum IN lr_lgnum
                     AND workstation IN lr_workst
                     AND procs IN lr_procs.

* select description
  CHECK lt_tworkst IS NOT INITIAL."no full table scan
  SELECT * FROM /scwm/tworkstt INTO TABLE lt_tworkstt
            FOR ALL ENTRIES IN lt_tworkst
                 WHERE   workstation = lt_tworkst-workstation
                     AND lgnum = lt_tworkst-lgnum
                     AND spras = sy-langu.
* Combine the hits from the WORKST and the TWORKST
* -> this is the reason, why we can't use a view/join
  LOOP AT lt_tworkst INTO ls_tworkst. "complete hit-list
    CLEAR: ls_result, ls_tworkstt.
    MOVE-CORRESPONDING ls_tworkst TO ls_result.
    READ TABLE lt_tworkstt INTO ls_tworkstt
              WITH KEY lgnum = ls_tworkst-lgnum
                       workstation = ls_tworkst-workstation.
    IF sy-subrc IS INITIAL.
      ls_result-description = ls_tworkstt-description.
    ENDIF.
    APPEND ls_result TO lt_result.
  ENDLOOP.



*3) Convert data for display in F4
  CALL FUNCTION 'F4UT_RESULTS_MAP'
    TABLES
      shlp_tab          = shlp_tab
      record_tab        = record_tab
      source_tab        = lt_result
    CHANGING
      shlp              = shlp
      callcontrol       = callcontrol
    EXCEPTIONS
      illegal_structure = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Skip to the DISP event
  callcontrol-step = 'DISP'.



ENDFUNCTION.
