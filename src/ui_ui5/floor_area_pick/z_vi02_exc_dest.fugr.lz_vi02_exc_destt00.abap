*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVI02_EXC_DEST..................................*
DATA:  BEGIN OF STATUS_ZVI02_EXC_DEST                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVI02_EXC_DEST                .
CONTROLS: TCTRL_ZVI02_EXC_DEST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVI02_EXC_DEST                .
TABLES: ZVI02_EXC_DEST                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
