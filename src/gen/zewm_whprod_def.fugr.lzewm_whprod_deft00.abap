*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZEWM_V_WHPRDEF..................................*
TABLES: ZEWM_V_WHPRDEF, *ZEWM_V_WHPRDEF. "view work areas
CONTROLS: TCTRL_ZEWM_V_WHPRDEF
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZEWM_V_WHPRDEF. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZEWM_V_WHPRDEF.
* Table for entries selected to show on screen
DATA: BEGIN OF ZEWM_V_WHPRDEF_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZEWM_V_WHPRDEF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEWM_V_WHPRDEF_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZEWM_V_WHPRDEF_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZEWM_V_WHPRDEF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZEWM_V_WHPRDEF_TOTAL.

*...processing: ZEWM_WHPROD_DEF.................................*
DATA:  BEGIN OF STATUS_ZEWM_WHPROD_DEF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEWM_WHPROD_DEF               .
CONTROLS: TCTRL_ZEWM_WHPROD_DEF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZEWM_WHPROD_DEF               .
TABLES: ZEWM_WHPROD_DEF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
