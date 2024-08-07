*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVI02_PICK_BUF..................................*
DATA:  BEGIN OF STATUS_ZVI02_PICK_BUF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVI02_PICK_BUF                .
CONTROLS: TCTRL_ZVI02_PICK_BUF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVI02_PICK_BUF                .
TABLES: ZVI02_PICK_BUF                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
