*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZEWM_MATMAS_KEYS................................*
DATA:  BEGIN OF STATUS_ZEWM_MATMAS_KEYS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEWM_MATMAS_KEYS              .
CONTROLS: TCTRL_ZEWM_MATMAS_KEYS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZEWM_MATMAS_KEYS              .
TABLES: ZEWM_MATMAS_KEYS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
