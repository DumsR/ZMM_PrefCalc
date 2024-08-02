*&---------------------------------------------------------------------*
*& Report zmm_pref_mat_upl
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zmm_pref_mat_dd message-id zmm_rep.

INCLUDE ZMM_PREF_MAT_DD_TOP.
*include zmm_pref_mat_upl_top.
INCLUDE ZMM_PREF_MAT_DD_CLS.
*include zmm_pref_mat_upl_cls.
data util type ref to lcl_helper.

INCLUDE ZMM_PREF_MAT_DD_F01.
*include zmm_pref_mat_upl_f01.
" ---------------------------------------------------------------------
initialization.
  p_file = 'C:\Temp\PrefCalc_S4H_Mat_v2.csv'.
  util = new #( p_file  ).

at selection-screen on value-request for p_file.
  p_file = util->select_file( ).

at selection-screen output.
  perform at_sel_screen_out.

start-of-selection.
  if p_frmDB = util->yes.
    util->load_from_DB( iv_matnr = p_matnr
                          iv_plant = p_plant ).
    util->map_db2data( ).
  else.
    util->load_from_file( p_file ).
    util->map_csv2data( ).
  endif.

  call screen '0100'.
