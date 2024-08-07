*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVI02_TUTYPEMAP.................................*
DATA:  BEGIN OF STATUS_ZVI02_TUTYPEMAP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVI02_TUTYPEMAP               .
CONTROLS: TCTRL_ZVI02_TUTYPEMAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVI02_TUTYPEMAP               .
TABLES: ZVI02_TUTYPEMAP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
