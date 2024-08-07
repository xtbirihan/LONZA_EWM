class ZCL_VI02_IM_CORE_PTS_BINGENMFS definition
  public
  final
  create public .

public section.
  type-pools WMEGC .

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_CORE_PTS_BINGEN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_VI02_IM_CORE_PTS_BINGENMFS IMPLEMENTATION.


  METHOD /scwm/if_ex_core_pts_bingen~change.
*------------------------------------------------------------------------------*
* Swisslog AG
*------------------------------------------------------------------------------*
* Package:       Z_VI02_ENH
* Interface:     /SCWM/IF_EX_CORE_PTS_BINGEN~CHANGE
* BAdI Def Name: /SCWM/EX_CORE_PTS_BINGEN
*
* Description:
* For putaway towards MFS conveyor system we must create the putaway WTs
* with generic WT, means only the storage type (maximum the storage section)
* shall be known in the WT as destination. Because user can drop wherever
* it might be the best.
*
*------------------------------------------------------------------------------*
* Intellectual property of Swisslog
*----------------------Documentation of Changes--------------------------------*
* Ver.      ¦Date       ¦Author        ¦Description
* ----------¦-----------¦--------------¦--------------------------------------------*
* 2023.0.0  ¦2023-10-02 ¦T. Rehmann    ¦Initial
*------------------------------------------------------------------------------*
*IV_PARTDET  Input value from the the caller
*IV_BINGEN   Input value from the customizing
*CV_PARTDET  Result preset from the SAP based on the IV_PARTDET/IV_BINGEN


    "Implement here the design:
    "C4bF_0330_FDS SAP EWM Putaway RF drop Conveyor Infeed - Generic WT.docx
    "
*   Change CV_PARTDET:
*   When CV_PARTDET = <empty>
*   AND
*   source storage type is a non MFS storage type role
*   AND
*   destination is storage type role is MFS relevant as H or J
*   THEN we set CV_PARTDET = ‘2’ (only storage type)


    BREAK-POINT ID zcg_vi02_core_pts_bingen.

    DATA:
      ls_t331_from TYPE /scwm/t331.



    CHECK 1 EQ 2 "remove after testing in debugger
    OR ( sy-uname = 'FSPISAK' and sy-sysid = 'D24' ).
    CALL FUNCTION '/SCWM/T331_READ_SINGLE'
      EXPORTING
        iv_lgnum  = is_ltap-lgnum
        iv_lgtyp  = is_ltap-vltyp
      IMPORTING
        es_t331   = ls_t331_from
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    CASE cv_partdet.
      WHEN wmegc_bingn_not_generic.     "' '
        "if the source is not MFS and the destination is MFS then we want Generic (so no bin determination)
        IF  ( ls_t331_from-st_role  NE wmegc_strole_mfs AND ls_t331_from-st_role NE wmegc_strole_mfs_ctrl )
        AND ( is_t331-st_role       EQ wmegc_strole_mfs OR  is_t331-st_role      EQ wmegc_strole_mfs_ctrl ).
          cv_partdet = wmegc_bingn_only_strg_type.
        ENDIF.

      WHEN wmegc_bingn_strg_type_sect   "'1'
        OR wmegc_bingn_only_strg_type.  "'2'
        "if both the source and the destination are MFS then we need to determine a bin
        IF  ( ls_t331_from-st_role  EQ wmegc_strole_mfs OR ls_t331_from-st_role EQ wmegc_strole_mfs_ctrl )
        AND ( is_t331-st_role       EQ wmegc_strole_mfs OR is_t331-st_role      EQ wmegc_strole_mfs_ctrl ).
          cv_partdet = wmegc_bingn_not_generic.
        ENDIF.
      WHEN OTHERS.
        "there is a special value 'Y' which is not in the domain, it is used internally, and it means that the caller requested Not Generic (IV_PARTDET eq 'X')
        "so let it be Not Generic

    ENDCASE.


  ENDMETHOD.
ENDCLASS.
