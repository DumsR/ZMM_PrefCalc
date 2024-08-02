*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_ALV (grid)
*&---------------------------------------------------------------------*
**********************************************************************
class lcl_alv definition
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
    ,   alv_grid            type ref to cl_gui_alv_grid
    ,   fieldcat            type lvc_t_fcat

    . "-----------------------------------------------
    methods:
        constructor
            importing iv_util_dat   type ref to lcl_data
    ,   prepare
    ,   toolbar_click  for event added_function of cl_salv_events_table
            importing e_salv_function
    ,   toolbar_cfg   for event toolbar of cl_gui_alv_grid
            importing e_object sender
    ,   dbl_click for event double_click  of cl_salv_events_table
            importing row column
    ,   cell_changed for event data_changed_finished  of cl_gui_alv_grid
            importing e_modified et_good_cells
    ,   set_color
            importing       rowIdx type i
    ,   set_color_key
            importing       rowIdx type i
    . "-----------------------------------------------
protected section.
    methods:
        create_alv
    ,   config_alv_grid          "ABAP 7.02
    ,   display_alv
    ,   edit_open_grid
    ,   edit_close_salv
    . "-----------------------------------------------
private section.
    methods:
        get_selceted_row
            importing getZero like NO
            returning value(rowIdx) type i
    ,   get_grid_from_salv
            importing          io_salv_tab  type ref to cl_salv_table
            returning value(ro_alv_grid) type ref to cl_gui_alv_grid
    ,   get_grid_from_salv_702
            importing          io_salv_tab  type ref to cl_salv_table
            returning value(ro_alv_grid) type ref to cl_gui_alv_grid
    . "-----------------------------------------------
endclass. "definition
class lcl_alv implementation.
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
method cell_changed.
    check e_modified = yes.


*    alv_grid->set_ready_for_input(  ).

*     data sel_rows type lvc_t_roid.
*     alv_grid->get_selected_rows( importing et_row_no = sel_rows  ).
*     sel_rows = value #( ( row_id = 3 )  ).
*     alv_grid->set_selected_rows( is_keep_other_selections = yes
*        it_row_no  = sel_rows ).

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
method edit_open_grid.
    field-symbols <field> like line of fieldCat.

    alv_grid->set_ready_for_input( 1 ). "yes

*    alv_grid->get_frontend_fieldCatalog(
*        importing et_fieldcatalog = fieldCat ).
*    loop at fieldCat assigning <field>.
*        case <field>-fieldname.
*        when 'PRFZONE'.
*            <field>-edit = yes.
*
*        endcase.
*    endloop.
*    alv_grid->set_frontend_fieldCatalog(
*        exporting it_fieldcatalog = fieldCat ).
endmethod.
**********************************************************************
method edit_close_salv.
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
    display_alv(  ).

    config_alv_grid( ).     " ABAP 7.02
*   toolbar_cfg( ).           " event

    alv->refresh(  ).         "FieldCat refresh
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

        data(alv_events) =                  alv->get_event(  ).
        set handler me->dbl_click           for alv_events.
        set handler me->toolbar_click    for alv_events.

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method display_alv.
    try.
        alv->display( ).

        alv_grid = get_grid_from_salv( alv ).
        if alv_grid is bound.
            set handler me->toolbar_cfg  for alv_grid.
            set handler me->cell_changed  for alv_grid.
            alv_grid->register_edit_event( "i_event_id =
                cl_gui_alv_grid=>mc_evt_modified ).
            endif.

    catch cx_root into data(cx).
        data(info) = cx->get_text( ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry..
endmethod.
**********************************************************************
method get_grid_from_salv.
    check io_salv_tab is bound.
    try.
        data(model) =
            cast cl_salv_model_base(  io_salv_tab->extended_grid_api(  ) ).

        check model->r_controller is bound.
        data(cntrl) = model->r_controller.

        check cntrl->r_adapter is bound.
        data(adapter) = cntrl->r_adapter.

        check adapter is instance of if_salv_table_display_adapter.
        data(tableAdpt) = cast if_salv_table_display_adapter( adapter ).

        ro_alv_grid = tableAdpt->get_grid(  ).

    catch cx_root into data(cx).
        message w000 with 'get_alv_from_salv' '.... FAIL !!!'.
    endtry.
endmethod.
**********************************************************************
method get_grid_from_salv_702.
    data:
        modelTyp type salv_de_constant
    ,   model type ref to CL_SALV_MODEL_BASE
    ,   cntrl type ref to CL_SALV_CONTROLLER_TABLE
    ,   cx type ref to cx_root
    ,   info type string
    ,   instOf like yes
    .
    try.
        check io_salv_tab is bound.
*        modelTyp = io_salv_tab->model.   "ABAP 7.02
        modelTyp = io_salv_tab->if_salv_gui_om_model_info~model_type(  ).
        check modelTyp = if_salv_c_model=>table. "11 - TABLE
*        model ?=  io_salv_tab ).                    "ABAP 7.02
        check model->r_controller is bound.
        cntrl ?= model->r_controller.

        check cntrl->r_adapter is bound.
        info = cl_wdy_wb_reflection_helper=>get_class( cntrl->r_adapter ).
        case info.
        when 'CL_SALV_GRID_ADAPTER'.
            data adapt_grid type ref to CL_SALV_GRID_ADAPTER.
            adapt_grid ?= cntrl->r_adapter.
*            ro_alv_grid = adapt_grid->get_grid( ).

        when 'CL_SALV_FULLSCREEN_ADAPTER'.
            data adapt_fs type ref to CL_SALV_FULLSCREEN_ADAPTER.
            adapt_fs ?= cntrl->r_adapter.
*            ro_alv_grid = adapt_fs->get_grid( ).

        when others.
            message e000 with 'ALV->model->r_controller->r_adapter' 'NOT accepted !!! '.
         endcase.

    catch cx_root into cx.
        info = cx->get_text(  ).
        message e000 with 'ALV' 'get_grid_from_salv' 'FAIL !!!' info.
    endtry.
endmethod.
**********************************************************************
method toolbar_cfg.
"  https://codezentrale.de/category/sap/sap-abap/sap-abap-gui/sap-abap-gui-grid/sap-abap-gui-grid-salv/page/2/
    field-symbols <tb> like e_object->mt_toolbar.
    assign e_object->mt_toolbar to <tb>.

    data btnLn like line of <tb>.
    data separator like line of <tb>.

*    delete <tb> where function = '&DETAIL'.
    delete <tb> where function = '&&SEP00'.
    delete <tb> where function = '&MB_SUM'.
    delete <tb> where function = '&MB_SUBTOT'.
    delete <tb> where function = '&&SEP05'.
    delete <tb> where function = '&PRINT_BACK'.
    delete <tb> where function = '&GRAPH'.

    btnLn-butn_type = cntb_btype_button.
    btnLn-function  = 'newLine'.
    btnLn-icon          = '@17@'. " Insert line
    btnLn-quickInfo = 'Insert new line (at end)'.
    insert btnLn into <tb> index 1.

    btnLn-function  = 'delLine'.
    btnLn-icon          = '@18@'. " 'Delete line
    btnLn-quickInfo = 'Delete line'.
    insert btnLn into <tb> index 2.

    btnLn-function  = 'copyLine'.
    btnLn-icon          = '@14@'. " 'Delete line
    btnLn-quickInfo = 'Copy line (to end)'.
    insert btnLn into <tb> index 3.

    separator-function   = '&sep01'.
    separator-butn_type = cntb_btype_sep.
    insert separator into <tb> index 4.

    btnLn-butn_type = cntb_btype_button.
    btnLn-function  = 'openEdit'.
    btnLn-icon          = '@0Z@'. " Edit (Change)
    btnLn-quickInfo = 'Open for edit'.
    insert btnLn into <tb> index 5.

    btnLn-function  = 'closeEdit'.
    btnLn-icon          = '@10@'. " Display
    btnLn-quickInfo = 'Close edit (read only)'.
    insert btnLn into <tb> index 6.

    btnLn-function  = 'check'.
    btnLn-icon         = '@01@'.
    btnLn-quickInfo =  'Check Data types'.
    insert btnLn into <tb> index 7.

    btnLn-function  = 'persist'.
    btnLn-icon          = '@HK@'. " Persist
    btnLn-quickInfo =  'Save to DB'.
    btnLn-disabled   = yes.
    insert btnLn into <tb> index 8.

    btnLn-function  = 'show_msgs'.
    btnLn-icon          = '@0L@'.
    btnLn-quickInfo =  'Display notes'.
    btnLn-disabled   = no.
    insert btnLn into <tb> index 9.

    separator-function  = '&sep02'.
    insert separator into <tb> index 10.
endmethod.
**********************************************************************
method config_alv_grid.
    alv_grid->get_frontend_fieldCatalog(
        importing et_fieldcatalog = fieldCat ).

    loop at fieldCat assigning field-symbol(<field>).
        case <field>-fieldname.
        when 'SUPPLIER'.
            <field>-key = yes.
        when 'MATERIAL'.
            <field>-key = yes.
            <field>-outputlen = 10.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'MATNR'.
            <field>-just = 'C'.
        when 'PLANT'.
            <field>-key = yes.

        when 'PRFZONE'.
            <field>-key = yes.
            <field>-outputlen = 10.
            <field>-just = 'C'.
            <field>-edit = yes.
*            <field>-input = yes.
        when 'DECLCODE'.
            <field>-outputlen = 8.
            <field>-just = 'C'.
            <field>-edit = yes.

        endcase.
    endloop.

    alv_grid->set_frontend_fieldCatalog(
        exporting it_fieldcatalog = fieldCat ).

*    SALV: reset fieldcat config !!!!!!!!!!!!!!!!!!!!
*    data(columns) = alv->get_columns(  ).
*    columns->set_color_column( 'COLOR' ).
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
        edit_open_grid(  ).
        alv->refresh(  ).
    when 'closeEdit'.
        edit_close_salv(  ).
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
