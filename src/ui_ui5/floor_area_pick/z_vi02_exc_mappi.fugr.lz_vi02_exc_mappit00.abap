*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVI02_EXC_MAPPIN................................*
DATA:  BEGIN OF STATUS_ZVI02_EXC_MAPPIN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVI02_EXC_MAPPIN              .
CONTROLS: TCTRL_ZVI02_EXC_MAPPIN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVI02_EXC_MAPPIN              .
TABLES: ZVI02_EXC_MAPPIN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
