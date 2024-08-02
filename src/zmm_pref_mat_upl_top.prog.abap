*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_top
*&---------------------------------------------------------------------*
data:
    gv_okcode     type sy-ucomm
.
**********************************************************************
parameters:
    p_frmDB    type abap_bool  radiobutton group BTNG
,   p_byFile     type  abap_bool radiobutton group BTNG "as checkbox
.
selection-screen begin of block FRMDATA with frame title text-001 .
parameters:
    p_matnr type mape-matnr    modif id SC1 default '1'
,   p_plant   type mape-werks    modif id SC1 default '1710'
,   p_prefz   type mape-gzolx     modif id SC1 default 'EFTA'
,   p_vstat    type mape-prene    modif id SC1 default 'D'
,   p_vvalid  type mape-preng obligatory  modif id SC1 default '20240502'
.selection-screen end of block FRMDATA.

selection-screen begin of block frmFile with frame title text-002.
parameters:
    p_file type string obligatory modif id SC2. "rlgrap-filename
*                    default 'C:\Temp\PrefCalc_Template1.xlsx'.
.selection-screen end of block frmFile.
**********************************************************************
