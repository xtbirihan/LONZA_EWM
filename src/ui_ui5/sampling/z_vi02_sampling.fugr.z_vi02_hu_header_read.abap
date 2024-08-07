FUNCTION z_vi02_hu_header_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_WORKSTATION) TYPE  /SCWM/DE_WORKSTATION
*"     VALUE(IV_HUIDENT) TYPE  /SCWM/DE_HUIDENT
*"  EXPORTING
*"     VALUE(ES_HUHEADER) TYPE  ZZS_VI02_HU_HEADER
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    ls_return  TYPE bapiret2,
    lv_huident TYPE /scwm/de_huident.

  go_sampling = lcl_sampling_doc=>get_instance( ).
  IF lv_huident+0(1) = 'T'.
*‘Please scan the Sample HU number and not a trolley
    MESSAGE e031(z_vi02_general) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  lv_huident = |{ iv_huident ALPHA = IN }|.

  go_sampling->hu_read(
    EXPORTING
      iv_lgnum   = iv_lgnum
      iv_huident = lv_huident
    IMPORTING
      ev_error   = DATA(lv_error)
      es_huhdr   = DATA(ls_huheader) ).
  IF lv_error IS NOT INITIAL.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  DATA(lt_workstation) = go_sampling->workstation_read_by_bin(
    EXPORTING
      iv_lgnum   = iv_lgnum
      iv_lgtyp   = ls_huheader-lgtyp
      iv_bin     = ls_huheader-lgpla ).
  LOOP AT lt_workstation INTO DATA(ls_workstation) WHERE lgnum = iv_lgnum
                                                     AND workstation  = iv_workstation.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    MESSAGE e208(/scwm/rf_en) WITH lv_huident iv_workstation INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  MOVE-CORRESPONDING ls_huheader TO es_huheader.
  es_huheader-workstation = iv_workstation.
  IF ls_huheader-top IS INITIAL AND ls_huheader-higher_guid IS NOT INITIAL.
    go_sampling->hu_read(
      EXPORTING
         iv_lgnum  = iv_lgnum
        iv_guid_hu = ls_huheader-higher_guid
      IMPORTING
        es_huhdr   = DATA(ls_top_huhdr) ).
    es_huheader-higher_huident =  ls_top_huhdr-huident.
  ENDIF.


  IF ls_huheader-zzvi02_src_huid IS NOT INITIAL.
    go_sampling->hu_read(
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_huident = |{ ls_huheader-zzvi02_src_huid ALPHA = IN }|
      IMPORTING
        ev_error   = lv_error
        es_huhdr   = DATA(ls_sourcehu_header) ).
  ELSE.
    IF ls_huheader IS NOT INITIAL.
      go_sampling->hu_whse_tasks(
      EXPORTING
          iv_whno      = iv_lgnum
          iv_huident   = lv_huident
          iv_vhi       = ls_huheader-vhi
        IMPORTING
          et_wht_data = DATA(lt_hutask) ) .
    ENDIF.
    DELETE lt_hutask WHERE t_ordim_c IS INITIAL.
    SORT lt_hutask BY tanum DESCENDING.
    LOOP AT lt_hutask INTO DATA(ls_hutask).
*    SORT ls_hutask-t_ordim_c BY vfdat DESCENDING wdatu DESCENDING.
      LOOP AT ls_hutask-t_ordim_c INTO DATA(ls_ordim_c) WHERE nlenr = ls_huheader-huident.
        DATA(lv_source_hu) = ls_ordim_c-vlenr.
        EXIT.
      ENDLOOP.
      IF lv_source_hu IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.

  IF lv_source_hu IS NOT INITIAL.
    lv_source_hu = |{ lv_source_hu ALPHA = IN }|.
    go_sampling->hu_read(
      EXPORTING
        iv_lgnum   = iv_lgnum
        iv_huident = lv_source_hu
      IMPORTING
        ev_error   = lv_error
        es_huhdr   = ls_sourcehu_header ).
  ENDIF.

  IF ls_sourcehu_header IS NOT INITIAL.
    DATA(ls_pmat) = go_sampling->mat_details_read_from_matid( ls_sourcehu_header-pmat_guid ).

    es_huheader-vguid_hu     = ls_sourcehu_header-guid_hu  .
    es_huheader-vhuident     = ls_sourcehu_header-huident  .
    es_huheader-vpmat_guid   = ls_sourcehu_header-pmat_guid.
    es_huheader-vpmat        = ls_pmat-matnr.
    es_huheader-vpmtext      = VALUE #( ls_pmat-txt[ langu = sy-langu ]-maktx OPTIONAL ).
    es_huheader-vletyp       = ls_sourcehu_header-letyp    .

  ENDIF.

ENDFUNCTION.
