CLASS zcl_z_vi02_sampling_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_z_vi02_sampling_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:  BEGIN OF ts_hudeep.
             INCLUDE              TYPE zcl_z_vi02_sampling_mpc=>ts_huheader.
    DATA:    huitem TYPE STANDARD TABLE OF zcl_z_vi02_sampling_mpc=>ts_huitem WITH DEFAULT KEY.
    DATA:    huitem_quantity      TYPE STANDARD TABLE OF zcl_z_vi02_sampling_mpc=>ts_huitemquantity WITH DEFAULT KEY.
    DATA:   END OF ts_hudeep.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_Z_VI02_SAMPLING_MPC_EXT IMPLEMENTATION.
ENDCLASS.
