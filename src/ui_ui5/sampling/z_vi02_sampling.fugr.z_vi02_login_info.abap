FUNCTION z_vi02_login_info.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     VALUE(IV_WORKSTATION) TYPE  /SCWM/DE_WORKSTATION
*"  EXPORTING
*"     VALUE(ES_WHN_WORKSTATION_PROFILE) TYPE
*"        ZZS_VI02_WAREHOUSE_WORKSTATION
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

  DATA:
    ls_return   TYPE bapiret2.

  go_sampling = lcl_sampling_doc=>get_instance( ).
  IF iv_lgnum       IS INITIAL OR
     iv_workstation IS INITIAL.
    MESSAGE e405(/scwm/who) INTO DATA(lv_message).
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

  go_sampling->t300_read_single(
    EXPORTING
      iv_lgnum = iv_lgnum
    IMPORTING
      es_t300  = DATA(ls_t300)
      es_t300t = DATA(ls_t300t) ).
  IF sy-subrc NE 0.
    MESSAGE e160(/sl0/ca) WITH iv_lgnum INTO lv_message.
    ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
    ls_return-row = VALUE #( ).
    APPEND ls_return TO et_return.
    RETURN.
  ENDIF.

*  TRY.
*      go_sampling->authority_check( iv_lgnum       = iv_lgnum
*                                    iv_workstation = iv_workstation ).
*    CATCH zcx_sampling INTO DATA(lx_sampling).
*      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
*      ls_return-row = VALUE #( ).
*      APPEND ls_return TO et_return.
*      RETURN.
*  ENDTRY.

  /scwm/cl_tm=>set_lgnum( iv_lgnum ).

  TRY.
      go_sampling->workstation_read_single(
        EXPORTING
          iv_lgnum       = iv_lgnum
          iv_workstation = iv_workstation
        IMPORTING
          es_workst      = DATA(ls_workst)
          es_workstt     = DATA(ls_workstt) ).
    CATCH zcx_sampling INTO DATA(lx_sampling).
      /scwm/cl_tm=>cleanup( ).
      ls_return =  /scwm/cl_qdoc=>convert_symsg_2_return( ).
      ls_return-row = VALUE #( ).
      APPEND ls_return TO et_return.
      RETURN.
  ENDTRY.

  MOVE-CORRESPONDING ls_workst TO es_whn_workstation_profile.
  es_whn_workstation_profile-spras       = ls_workstt-spras.
  es_whn_workstation_profile-description = ls_workstt-description.
  es_whn_workstation_profile-lnumt       = ls_t300t-lnumt.

  /scwm/cl_tm=>cleanup( ).


ENDFUNCTION.
