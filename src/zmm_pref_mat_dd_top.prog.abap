*&---------------------------------------------------------------------*
*& Include zmm_pref_calc_upld2_top
*&---------------------------------------------------------------------*

data gv_okcode type sy-ucomm.

parameters:
    p_frmDB  type abap_bool radiobutton group btng,  " default 'X'.
    p_byFile type abap_bool radiobutton group btng.

selection-screen begin of block frmdat2 with frame title text-001.
  parameters:
      p_matnr type marc-matnr obligatory modif id sc1 default '1'   ,
      p_plant type marc-werks obligatory modif id sc1 default '1010'.
selection-screen end of block frmdat2.

selection-screen begin of block frmfile2 with frame title text-002.
  parameters p_file type string obligatory modif id sc2.
selection-screen end of block frmfile2.
*** INCLUDE ZMM_PREF_MAT_UPL_TOP
*** INCLUDE ZMM_PREF_MAT_UPL_TOP
