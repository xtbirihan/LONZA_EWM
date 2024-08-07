*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZVI02_TUTYPEMAP
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZVI02_TUTYPEMAP    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
