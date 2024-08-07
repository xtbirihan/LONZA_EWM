FUNCTION z_vi02_comp_bin_stat_reg_clear.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------

  PERFORM clear_own_status_buffer ON COMMIT.
  PERFORM clear_own_status_buffer ON ROLLBACK.




ENDFUNCTION.
