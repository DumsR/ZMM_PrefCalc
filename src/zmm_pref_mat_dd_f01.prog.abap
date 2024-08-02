*&---------------------------------------------------------------------*
*& Include zmm_pref_calc_upld2_f01
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status '100'.
*  set titlebar '0100'.
  if util->mo_alv is not bound.
    util->prepare_alv( ).
  endif.
endmodule.
**********************************************************************
module user_command_0100.
  perform user_cmd_100.
endmodule.
**********************************************************************
form user_cmd_100.
  case gv_okcode.
    when 'BACK' or 'EXIT' or 'CANCEL'.
        leave to screen 0.
    when 'PERSIST'.
        util->map_data2db(  ).
        util->persist_lines(  ).

    when others.
        leave to screen 0.
  endcase.
endform.
**********************************************************************
form at_sel_screen_out.
  loop at screen.
    if p_frmDB = util->no.
      if screen-group1 = 'SC1'.
        screen-active = 0.
      endif.
    else.
      if screen-group1 = 'SC2'.
        screen-active = 0.
      endif.
    endif.
    modify screen.
  endloop.
endform.
