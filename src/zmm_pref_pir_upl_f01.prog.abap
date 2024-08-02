*&---------------------------------------------------------------------*
*& Include zmm_pref_calc_upld_f01
*&---------------------------------------------------------------------*
**********************************************************************
MODULE STATUS_0100 OUTPUT.
*  set pf-status  '0100'.
    set titlebar     '0100'.
    if util_alv->alv is not bound.
        util_alv->prepare(  ).
        endif.
endmodule.

module USER_COMMAND_0100.
  PERFORM user_cmd_100.
endmodule.
**********************************************************************
form user_cmd_100.
    case gv_okcode.
    when 'BACK' or 'EXIT' or 'CANCEL'.
        leave to screen 0.
    when others.
        leave to screen 0.
    endcase.
endform.
**********************************************************************
form at_sel_screen_OUT.
    loop at screen.
        if p_frmDB = util_dat->no.
            if screen-group1 = 'SC1'.
                screen-active = 0.
                endif.
        else.
            if screen-group1 = 'SC2'.
                screen-active = 0.
                endif.
        endif.
        MODIFY SCREEN.
    endloop.
endform.
**********************************************************************
