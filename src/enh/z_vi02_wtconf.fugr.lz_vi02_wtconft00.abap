*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZEWM_WTCONF_CTRL................................*
DATA:  BEGIN OF STATUS_ZEWM_WTCONF_CTRL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEWM_WTCONF_CTRL              .
CONTROLS: TCTRL_ZEWM_WTCONF_CTRL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZEWM_WTCONF_CTRL              .
TABLES: ZEWM_WTCONF_CTRL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
