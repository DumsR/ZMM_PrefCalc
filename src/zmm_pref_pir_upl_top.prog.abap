*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_top
*&---------------------------------------------------------------------*
data:
    gv_okcode     type sy-ucomm
,   so_base      type string value 'LFEI-PRENG'
.
**********************************************************************
parameters:
    p_frmDB    type abap_bool  radiobutton group BTNG
,   p_byFile     type  abap_bool radiobutton group BTNG "as checkbox
.
selection-screen begin of block FRMDATA with frame title text-001 .
parameters:
    p_suppl  type lfei-lifnr      modif id SC1 default 'BP1710' "Almig 'A00006'
,   p_matnr type lfei-matnr   modif id SC1 default '11'         "Almig '2'
,   p_plant   type lfei-werks   modif id SC1 default '1710'     "Almig  '7720'
,   p_prefz   type lfei-gzolx    modif id SC1 default 'EFTA'
,   p_status type lfei-prene    modif id SC1 default 'F'
.select-options:
    so_valid  for (so_base)  modif id SC1 default '20240502' to '20241231'.
.selection-screen end of block FRMDATA.

selection-screen begin of block frmFile with frame title text-002.
parameters:
    p_file type string obligatory modif id SC2. "rlgrap-filename
.selection-screen end of block frmFile.
**********************************************************************
