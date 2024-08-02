*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_salv
*&---------------------------------------------------------------------*
**********************************************************************
class lcl_sAlv definition
    inheriting from cl_salv_model_base.
public section.
    type-pools: icon.
    .constants:
        yes type abap_bool value abap_true
    ,   no  type abap_bool value abap_false
    . "-----------------------------------------------
    data:
        util_dat            type ref to lcl_data
    ,   alv                    type ref to cl_salv_table
    . "-----------------------------------------------
    methods:
        constructor
            importing iv_util_dat   type ref to lcl_data
    ,   prepare
    ,   toolbar_click  for event added_function of cl_salv_events_table
            importing e_salv_function
    ,   dbl_click for event double_click  of cl_salv_events_table
            importing row column
    ,   set_color
            importing       rowIdx type i
    ,   set_color_key
            importing       rowIdx type i
    . "-----------------------------------------------
protected section.
    methods:
        create_alv
    ,   config_alv
    ,   toolbar_cfg
    ,   display_alv
    ,   edit_open
    ,   edit_close
    . "-----------------------------------------------
private section.
    methods:
        get_selceted_row
            importing getZero like NO
            returning value(rowIdx) type i
    . "-----------------------------------------------
endclass. "definition
class lcl_sAlv implementation.
**********************************************************************
method constructor.
    super->constructor(  ).
    util_dat = iv_util_dat.
    util_dat->set_alv( me  ).
endmethod.
**********************************************************************
method dbl_click.
    message i000 with 'hndl_dbl_click in col/line'  column '/' row.
endmethod.
**********************************************************************
method get_selceted_row.
    check util_dat->mt_dataINT is not initial.
    if  getZero = no.
        rowIdx = 1.                 endif.

    data(selRows) = alv->get_selections(  )->get_selected_rows(  ).
    check selRows is not initial.

    rowIdx = selRows[ 1 ].
endmethod.
**********************************************************************
method edit_open.
    try.
        data(salv_omBase) =
            alv->if_salv_gui_om_table_info~extended_grid_api(  ).
        data(if_edit) =
            salv_omBase->editable_restricted(  ).
        if if_edit->is_restricted_edit_mode_on(  ).
            return.
            endif.

*        if_edit->set_attributes_for_columnname( 'SUPPLIER' ).
*            columName = 'SUPPLIER   all_cells_input_enabled = abap_true ).
        if_edit->set_attributes_for_columnname( 'PRFZONE' ).

        if_edit->set_attributes_for_columnname(
                             columnName =    'DECLCODE'
                             urge_foreign_key_check  = yes  ).
        if_edit->set_attributes_for_columnname( 'VALID_TO' ).

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'open edit' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method edit_close.
      try.
        data(salv_omBase) =
            alv->if_salv_gui_om_table_info~extended_grid_api(  ).
        data(if_edit) =
            salv_omBase->editable_restricted(  ).

        if_edit->set_restricted_edit_mode_off(  ).

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'open edit' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method prepare.
    create_alv(  ).
    config_alv(  ).
    toolbar_cfg(  ).
    alv->display( ).

*    display_alv(  ).
*    alv->refresh(  ).   "FieldCat refresh
endmethod.
**********************************************************************
method create_alv.
    data container  type ref to cl_gui_custom_container.
    check alv is not bound.

    try.
        container = new #( 'ALV_CONTAINER' ).

        cl_salv_table=>factory(
             exporting  r_container  = container
             importing r_salv_table = alv
             changing  t_table = util_dat->mt_dataINT   ).

        data(alv_events) = alv->get_event(  ).
        set handler me->dbl_click          for alv_events.
        set handler me->toolbar_click   for alv_events.

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method display_alv.
    try.
        alv->display( ).

    catch cx_root into data(cx).
        data(info) = cx->get_text( ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry..
endmethod.
**********************************************************************
method config_alv.
  try.
    data(selections) = alv->get_selections(  ).
    selections->set_selection_mode(
       if_salv_c_selection_mode=>row_column ).

    data(columns) = alv->get_columns(  ).
    columns->set_color_column( 'COLOR' ).

    data(col) = columns->get_column( 'SUPPLIER' ).
    col->set_alignment( if_salv_c_alignment=>centered ).
    col->set_ddic_reference( value #( table = 'LFEI'  field = 'LIFNR'  ) ).
    col->set_tooltip( 'DDIC-reference: LFEI-lifnr' ).
    data(colTb) = CAST cl_salv_column_table( col ).
    colTb->set_key( yes ).

    col = columns->get_column( 'MATERIAL' ).
    col->set_alignment( if_salv_c_alignment=>right ).
    col->set_ddic_reference( value #( table = 'LFEI'  field = 'MATNR'  ) ).
    col->set_output_length( 10 ).
    colTb = CAST cl_salv_column_table( col ).
    colTb->set_key( yes ).

    col = columns->get_column( 'PLANT' ).
    col->set_alignment( if_salv_c_alignment=>centered ).
    col->set_ddic_reference( value #( table = 'LFEI'  field = 'WERKS'  ) ).
    col->set_output_length( 7 ).
    colTb = CAST cl_salv_column_table( col ).
    colTb->set_key( yes ).

    col = columns->get_column( 'PRFZONE' ).
    col->set_alignment( if_salv_c_alignment=>centered ).
    col->set_ddic_reference( value #( table = 'LFEI'  field = 'GZOLX'  ) ).
    col->set_output_length( 12 ).
    colTb = CAST cl_salv_column_table( col ).
    colTb->set_key( yes ).

    col = columns->get_column( 'DECLCODE' ).
    col->set_alignment( if_salv_c_alignment=>centered ).
    col->set_output_length( 9 ).
    col->set_ddic_reference( value #( table = 'LFEI'  field = 'PRENE'  ) ).
    col->set_medium_text( 'VDecl.state' ).
    col->set_short_text( 'state' ).

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'config' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method toolbar_cfg.
  try.
    data(alv_funcs) = alv->get_functions(  ).
    alv_funcs->set_all( ). "    abap_false ).   "Standardbuttons OFF
    alv_funcs->remove_function(  '&SORT_ASC' ).

    alv_funcs->add_function(
        name    = 'newLine'       icon =  '@17@'       " Insert line ----------
        text        = space             tooltip = 'Insert new line (at end)'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'delLine'         icon =     '@18@'   " Delete line ----------
        text        = space             tooltip = 'Delete line'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'copyLine'       icon =   '@14@'    " Copy line ----------
        text        = space             tooltip = 'Copy line'
        position = if_salv_c_function_position=>left_of_salv_functions  ).

    alv_funcs->add_function(
        name    = 'openEdit'       icon =   '@0Z@'    " Change ------------
        text        = space             tooltip = 'Open for edit'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'closeEdit'       icon =   '@10@'    " Display --------------
        text        = space             tooltip = 'Close edit (read only)'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'check'             icon =  '@01@'        " Check -------------
        text        = space              tooltip = 'Check Data types'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'persist'          icon =    '@HK@' " Persist ----------------
        text        = space             tooltip = 'Save to DB'
        position = if_salv_c_function_position=>left_of_salv_functions  ).
    alv_funcs->add_function(
        name    = 'show_msgs'  icon =    '@0L@' " Display Notes  --------
        text        = space             tooltip = 'Display Notes'
        position = if_salv_c_function_position=>left_of_salv_functions  ).

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'toolbar_cfg' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method toolbar_click.
*    message i000 with 'toolbar_click' e_salv_function.
    data rowIdx type i.
    data selRow like line of util_dat->mt_dataINT.

    case e_salv_function.
    when  'check'.
        util_dat->map_data2db(  ).
        alv->refresh(  ).
    when 'persist'.
        util_dat->persist_lines(  ).

    when 'openEdit'.
        edit_open(  ).
        alv->refresh(  ).
    when 'closeEdit'.
        edit_close(  ).
        alv->refresh(  ).

    when 'newLine'.
        append initial line to util_dat->mt_dataINT.
        alv->refresh(  ).
    when 'copyLine'.
        check util_dat->mt_dataINT is not initial.
        rowIdx = get_selceted_row( no ).
        selRow = util_dat->mt_dataINT[ rowIdx ].
        append selRow to util_dat->mt_dataINT.
        alv->refresh(  ).
    when 'delLine'.
        check util_dat->mt_dataINT is not initial.
        rowIdx = get_selceted_row( yes ).  "getZero
        check rowIdx > 0.
        delete util_dat->mt_dataINT index rowIdx.
        alv->refresh(  ).

    when 'show_msgs'.
        util_dat->show_msgs(  ).
    endcase.
endmethod.
**********************************************************************
method set_color.                    " 1 lightBlue 2 grey (default)     3-blue
    read table util_dat->mt_dataINT index rowIdx
        assigning field-symbol(<dataLn>).
    <dataLn>-color =
        value #( (  color-col = 5  ) ).  "green
endmethod.
**********************************************************************
method set_color_key.
    read table util_dat->mt_dataINT index rowIdx
        assigning field-symbol(<dataLn>).
    <dataLn>-color = value #(                                   " 1 lightBlue
         ( fName = 'SUPPLIER'    color-col = 6  )         " 2 grey (default)
         ( fName = 'MATERIAL'  color-col = 6  )          " 4 light green
         ( fName = 'PLANT'        color-col = 6  )          " 6 RED
         ( fName = 'PRFZONE'   color-col = 6  )       ). " 5 green / 7 Orange

    data rowID type lvc_s_row.
    data colID  type lvc_s_col.
    rowID-index = rowIdx.
    colID = 'PRFZONE'.
*    alv_grid->set_current_cell_via_id(
*        is_column_id = colID
*        is_row_id = rowID            ).

     data sel_rows type lvc_t_roid.
*     alv_grid->get_selected_rows( importing et_row_no = sel_rows  ).
     sel_rows = value #( ( row_id = rowID )  ).
*     alv_grid->set_selected_rows( is_keep_other_selections = yes
*        it_row_no  = sel_rows ).

    message e007  with rowIdx  into data(msg).
    util_dat->grab_syMsg( msg ). "Double KEY error in line &1 &2 &3 &4
endmethod.
**********************************************************************
endclass.  "lcl_alv implementation
