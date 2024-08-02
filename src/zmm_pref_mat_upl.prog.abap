*&---------------------------------------------------------------------*
*& Report zmm_pref_MAT_upl
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_pref_MAT_upl
  message-id zmm_rep.

include zmm_pref_mat_upl_top.
include zmm_pref_mat_upl_data.     "lcl util_data
data util_dat  type ref to lcl_mat_data.
include zmm_pref_mat_upl_grid.       "lcl_alv_Grid
data util_alv type ref to lcl_alv_Grid.
include zmm_pref_mat_upl_f01.          "Forms

* ---------------------------------------------------
INITIALIZATION.
    p_file = 'C:\OneDriveTemp\Almig\PrefCalc_S4H_Mat_v2.csv'.
    util_dat = new #( p_file  ).
    util_alv = new #( util_dat ).
* ---------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST for p_file.  "help-request
    p_file = util_dat->select_file(  ).

AT SELECTION-SCREEN OUTPUT.
perform at_sel_screen_OUT.

* ---------------------------------------------------
START-OF-SELECTION.
    if p_frmDB = util_dat->yes.
        util_dat->load_fromDB(
            iv_matnr     = p_matnr
            iv_plant       = p_plant        iv_prf_zone = p_prefz
            iv_vendStat = p_vstat        iv_vend_valid  = p_vvalid  ).
        util_dat->map_db2data(  ).
    else.
        util_dat->load_fromFile( p_file ).
        util_dat->map_csv2data( ).
        endif.

    call screen '0100'.
* ---------------------------------------------------
*end-of-selection.
