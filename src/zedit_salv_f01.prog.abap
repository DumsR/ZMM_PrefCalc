*&---------------------------------------------------------------------*
*& Include zedit_salv_f01
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  PERFORM create_alv.
ENDMODULE.

MODULE at_exit_command_0100 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.

MODULE user_command_0100 INPUT.
  PERFORM user_cmd_100.
ENDMODULE.
**********************************************************************
form fill_data.
    gt_data[] = VALUE #(
                        ( molga = '37' juper = '0001' )
                        ( molga = '37' juper = '0002' )
                        ( molga = '37' juper = '0003' )
                        ( molga = '37' juper = '0004' )
                        ( molga = '37' juper = '0005' ) ).
endform.
**********************************************************************
FORM create_alv.
    data:
        columns TYPE REF TO cl_salv_columns_table
    ,   display_set TYPE REF TO cl_salv_display_settings
    .
    if go_alv is not bound.
        go_container = new #( 'ALV_CONTAINER' ).
        cl_salv_table=>factory(
        exporting  r_container  = go_container
        importing  r_salv_table = go_alv
        changing   t_table         = gt_data ).
*      exp...           r_container = cl_gui_custom_container=>default_screen

        columns = go_alv->get_columns( ).
        columns->set_optimize( ).
        display_set = go_alv->get_display_settings( ).
        display_set->set_striped_pattern( abap_true ).
    endif.

    set handler lcl_alv_event_handler=>handle_data_changed
        for all instances activation abap_true.

    go_alv->display( ).

*  ZCL_salv_buddy=>set_editable(
*    EXPORTING
**      i_row        = 4
*      i_col        = 'JUPER'
*      i_salv_table = go_alv
*      i_editable   = abap_true ).
endform..
**********************************************************************
form user_cmd_100.
    data:
        lv_valid               type abap_bool
    ,   alv_grid               type ref to cl_gui_alv_grid
    ,   salv_omBase      type ref to cl_salv_model_base
    ,   salv_omIF           type ref to if_salv_gui_om_extend_grid_api
    ,   salv_cntrl            type ref to cl_salv_controller
*    ,   salv_cntrlOM     type ref to cl_salv_controller_model
    ,   salv_cntrlOM     type ref to CL_SALV_GUI_OM_CNTRLR_TABLE
    ,   alv_grid_adapt   type ref to cl_salv_gui_om_adpt_grid
    .
    salv_omIF = go_alv->if_salv_gui_om_table_info~extended_grid_api(  ).
    salv_omBase ?= salv_omIF.
    salv_omBase->get_functions_base(  ).
    salv_omBase->set_function( 'OPEN' ).

    salv_cntrlOM ?= ZCL_salv_buddy=>get_control( salv_omBase ).
    data(evMod) = salv_cntrlOM->if_salv_controller_model~event_modus.
    data(chgList) = salv_cntrlOM->if_salv_controller_metadata~t_changelist.

*    alv_grid->check_changed_data( importing e_valid = lv_valid ).
*    check lv_valid = abap_true.

  CASE gv_okcode.
    when 'BACK' or 'EXIT' or 'CANCEL'.
        leave to screen 0.

    WHEN 'OPEN'.
      ZCL_salv_buddy=>set_editable(
        EXPORTING
*          i_row        = 4
          i_col        = 'JUPER'
          i_salv_table = go_alv
          i_editable   = abap_true ).
    WHEN 'CLOSE'.
      ZCL_salv_buddy=>set_editable(
        EXPORTING
*          i_row        = 4
          i_col        = 'JUPER'
          i_salv_table = go_alv
          i_editable   = abap_false ).
  ENDCASE.

ENDFORM.
**********************************************************************
