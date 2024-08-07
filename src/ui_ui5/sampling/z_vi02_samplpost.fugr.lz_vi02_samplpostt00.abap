*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z_VI02_V_SMPPOST................................*
TABLES: Z_VI02_V_SMPPOST, *Z_VI02_V_SMPPOST. "view work areas
CONTROLS: TCTRL_Z_VI02_V_SMPPOST
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_Z_VI02_V_SMPPOST. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_Z_VI02_V_SMPPOST.
* Table for entries selected to show on screen
DATA: BEGIN OF Z_VI02_V_SMPPOST_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE Z_VI02_V_SMPPOST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF Z_VI02_V_SMPPOST_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF Z_VI02_V_SMPPOST_TOTAL OCCURS 0010.
INCLUDE STRUCTURE Z_VI02_V_SMPPOST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF Z_VI02_V_SMPPOST_TOTAL.

*.........table declarations:.................................*
TABLES: ZVI02_SAMPL_POST               .
