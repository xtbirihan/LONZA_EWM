*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZEWM_WHPROD_CTL.................................*
DATA:  BEGIN OF STATUS_ZEWM_WHPROD_CTL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEWM_WHPROD_CTL               .
CONTROLS: TCTRL_ZEWM_WHPROD_CTL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZEWM_WHPROD_CTL               .
TABLES: ZEWM_WHPROD_CTL                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
