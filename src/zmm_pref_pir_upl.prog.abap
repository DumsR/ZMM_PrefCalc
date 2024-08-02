*&---------------------------------------------------------------------*
*& Report zmm_pref_PIR_upld
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zmm_pref_PIR_upld
  message-id zmm_rep.

include zmm_pref_PIR_upl_top.
include zmm_pref_PIR_upl_data.      "lcl util_data
data util_dat  type ref to lcl_data.

*include zmm_pref_PIR_upl_SALV.      "lcl util sALV
*data util_alv  type ref to lcl_SALV.
*include zmm_pref_PIR_upl_ALV.        "lcl util ALV
*data util_alv type ref to lcl_ALV.
include zmm_pref_PIR_upl_Grid.        "lcl_alv_Grid
data util_alv type ref to lcl_alv_Grid.

include zmm_pref_PIR_upl_f01.          "forms

* ---------------------------------------------------
initialization.
    p_file = 'C:\OneDriveTemp\PrefCalc_S4H_PRI_v2.csv'.
    util_dat = new #( p_file  ).
    util_alv = new #( util_dat ).
* ---------------------------------------------------
at selection-screen on value-request for p_file.  "help-request
    p_file = util_dat->select_file(  ).

at selection-screen output.
perform at_sel_screen_OUT.

* ---------------------------------------------------
START-OF-SELECTION.
    if p_frmDB = util_dat->yes.
        util_dat->load_fromDB(
            iv_suppl  = p_suppl             iv_matnr     = p_matnr
            iv_plant   = p_plant             iv_prfZone  = p_prefz
            iv_declCode = p_status      iv_valid   = so_valid[]  ).
        util_dat->map_db2data(  ).
    else.
        util_dat->load_fromFile( p_file ).
        util_dat->map_csv2data( ).
        endif.

    call screen '0100'.
* ---------------------------------------------------
*end-of-selection.
