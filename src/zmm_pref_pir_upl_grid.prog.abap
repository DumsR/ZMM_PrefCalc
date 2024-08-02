*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_Grid
*&---------------------------------------------------------------------*
**********************************************************************
class lcl_alv_grid definition
    friends cl_gui_alv_grid.

public section.
    type-pools: icon.
    .constants:
        yes type abap_bool value abap_true
    ,   no  type abap_bool value abap_false
    . "-----------------------------------------------
    data:
        util_dat            type ref to lcl_data
    ,   alv                    type ref to cl_gui_alv_grid
    ,   mt_fieldcat     type lvc_t_fcat
    ,   mv_keysON    like no.
    . "-----------------------------------------------
    events:
        user_cmd_event
            exporting value(e_ucomm) type sy-ucomm optional
    . "-----------------------------------------------
    methods:
        constructor
            importing iv_util_dat   type ref to lcl_data
    ,   prepare
    ,   refresh
    ,   switch_edit_mode
*            importing active type i
    ,   toolbar_cfg   for event toolbar of cl_gui_alv_grid
            importing e_object e_interactive
    ,   user_command  for event user_command of cl_gui_alv_grid
            importing e_ucomm
    ,   before_user_cmd
            for event before_user_command of cl_gui_alv_grid
            importing e_ucomm
    ,   after_user_cmd
            for event after_user_command of cl_gui_alv_grid
            importing e_ucomm
    ,   dbl_click for event double_click  of cl_gui_alv_grid
            importing e_row e_column
    ,   cell_changed for event data_changed_finished  of cl_gui_alv_grid
            importing e_modified et_good_cells
    ,   reset_color
    ,   set_color
            importing
                row_id type i
                col_id  type i  optional
                area    type c  default 'R'   "K-key / R-row / C-cell / I-InfoRec.
    ,   set_color_row
            importing       row_id type i
    ,   set_color_key
            importing       row_id type i
    ,   set_color_infoRec
            importing       row_id type i
    ,   set_color_cell
            importing       row_id type i
                                     col_id  type i
    . "-----------------------------------------------
protected section.
    methods:
        create_alv
    ,   fieldCat_by_data
            importing it_tab type any table  optional
            returning value(rt_fcat) type lvc_t_fcat
    ,   fieldCat_adjust
    ,   toggle_keys
    . "-----------------------------------------------
private section.
    methods:
        get_selceted_row
            importing getZero like NO
            returning value(e_row_id) type i
    . "-----------------------------------------------
endclass. "definition
class lcl_alv_grid implementation.
**********************************************************************
method constructor.
    super->constructor(  ).
    util_dat = iv_util_dat.
    util_dat->set_alv( me  ).
endmethod.
**********************************************************************
method dbl_click.
    message i000 with 'dbl_click in col/line'  e_row '/' e_column.
endmethod.
**********************************************************************
method before_user_cmd.
*    case e_ucomm.
*    when '&CHECK'.
*        reset_color(  ).
*        util_dat->map_data2db(  ).
*        refresh(  ).

*    endcase.
endmethod.
**********************************************************************
method after_user_cmd.
    case e_ucomm.
    when '&CHECK'.
        reset_color(  ).
        util_dat->map_data2db(  ).
        refresh(  ).

    endcase.
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
method toggle_keys.
    alv->get_frontend_fieldcatalog(
        importing et_fieldcatalog = mt_fieldcat ).
    loop at mt_fieldcat assigning field-symbol(<field>)
        where fieldname = 'SUPPLIER' or fieldname = 'MATERIAL'
              or fieldname = 'PLANT'       or fieldname = 'PRFZONE'.
        if <field>-key = no.
            mv_keysON = yes.
            <field>-key = yes.
            <field>-edit = no.
        else.
            mv_keysON = no.
            <field>-key = no.
            <field>-edit = yes.
        endif.
    endloop.
    alv->set_frontend_fieldcatalog(
        exporting it_fieldcatalog = mt_fieldcat ).
endmethod.
**********************************************************************
method prepare.
    if alv is not bound.
        create_alv(  ).
        endif.
    refresh(  ).
endmethod.
**********************************************************************
method create_alv.
    data:
        container  type ref to cl_gui_custom_container
    ,   layout        type lvc_s_layo
    .try.
        layout-cwidth_opt = yes.
        layout-zebra           = yes.
        layout-col_opt       = yes.
        layout-info_fname = 'COLOR_LINE'.
        layout-ctab_fname = 'COLOR_CELL'.

        mt_fieldcat = fieldCat_by_data(  ).
        fieldCat_adjust(  ).

        container = new #( 'ALV_CONTAINER' ).
        alv = new #( container ).

        alv->set_table_for_first_display(
*            exporting i_structure_name = 'MT_DATAINT'
            exporting is_layout               = layout
            changing it_outTab              = util_dat->mt_dataINT
                             it_fieldCatalog     = mt_fieldcat
            ).
        alv->register_edit_event(
            cl_gui_alv_grid=>mc_evt_enter ).
        alv->get_registered_events(
            importing events = data(alv_events) ).
        set handler me->toolbar_cfg     for alv.
        set handler me->dbl_click           for alv.
        set handler me->cell_changed     for alv.
        set handler me->user_command  for alv.
        set handler me->after_user_cmd    for alv.
*        set handler me->before_user_cmd  for alv.

        switch_edit_mode(  ).   "default: edit >> start closed

    catch cx_root into data(cx).
        data(info) = cx->get_text(  ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry.
endmethod.
**********************************************************************
method refresh.
    check alv is bound.

    data stable type lvc_s_stbl.
    stable-col = yes.
    stable-row = yes.

    alv->refresh_table_display( is_stable = stable ).
endmethod.
**********************************************************************
method switch_edit_mode.
    if alv->is_ready_for_input(  ) = 0.
        alv->set_ready_for_input( 1 ).   "open
    else.
        alv->set_ready_for_input( 0 ).   "lock
        endif.
endmethod.
**********************************************************************
method toolbar_cfg.
"  https://codezentrale.de/category/sap/sap-abap/sap-abap-gui/sap-abap-gui-grid/sap-abap-gui-grid-salv/page/2/
    data tb0 type ttb_button.
    field-symbols <btn> like line of tb0.
    tb0 = e_object->mt_toolbar.

    if lines( tb0 ) > 20.
        data(is_edit_toobar) = yes.
        endif.

    delete tb0 where function = '&DETAIL'.
    delete tb0 where function = '&&SEP00'.
    delete tb0 where function = '&MB_SUM'.
    delete tb0 where function = '&MB_SUBTOT'.
    delete tb0 where function = '&&SEP05'.
    delete tb0 where function = '&PRINT_BACK'.

    refresh e_object->mt_toolbar.
    assign e_object->mt_toolbar to field-symbol(<tb>).
    append initial line to <tb> assigning <btn>.
    <btn>-function  = 'switch'.
    <btn>-icon          = '@0Q@'.
    <btn>-quickInfo =  'switch edit mode'.

    append initial line to <tb> assigning <btn>.
    <btn>-function  = 'toggle_keys'.
    if mv_keysON = no.
        <btn>-icon          = '@06@'."  Icon Locked
        <btn>-quickInfo =  'set keys'.
    else.
        <btn>-icon          = '@07@'."  Icon UN-Locked
        <btn>-quickInfo =  'un-set keys'.
        endif.

    if is_edit_toobar = yes.
        data(idx) = line_index( tb0[ function = '&CHECK' ] ).
        append tb0[ idx ]  to <tb>.
        delete tb0 index idx.
        endif.

    if util_dat->mt_datadb is not initial.
        append initial line to <tb> assigning <btn>.
        <btn>-function  = 'persist'.
        <btn>-icon          = '@HK@'. " Persist
        <btn>-quickInfo =  'Save to DB'.
        endif.

    append initial line to <tb> assigning <btn>.
    <btn>-function  = 'show_msgs'.
    <btn>-icon          = '@0L@'.
    <btn>-quickInfo =  'Display notes'.
*   <btn>-disabled   = no.

    if is_edit_toobar = no.
        append initial line to <tb> assigning <btn>.
        <btn>-function  = '&sep01'.
        <btn>-butn_type = cntb_btype_sep.  "value 3
        endif.

    loop at tb0 assigning <btn>.
        append <btn> to <tb>.
    endloop.
endmethod.
**********************************************************************
method fieldCat_adjust.
    data checkLn type lvc_s_fcat.

    loop at mt_fieldcat assigning field-symbol(<field>).
    case <field>-fieldname.
        when 'SUPPLIER'.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'LIFNR'.
            <field>-key = yes.
        when 'MATERIAL'.
            <field>-key = yes.
            <field>-outputlen = 10.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'MATNR'.
            <field>-just = 'C'.
        when 'PLANT'.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'WERKS'.
            <field>-key = yes.

        when 'PRFZONE'.
            <field>-key = yes.
            <field>-ref_table = 'LFEI'.  "T604G
            <field>-ref_field  = 'GZOLX'.
            <field>-outputlen = 10.
            <field>-just = 'C'.
            <field>-f4availabl = yes.
            <field>-edit = yes.

        when 'DECLCODE'.
            <field>-coltext = 'Decl.Code'.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'PRENE'.
            <field>-outputlen = 8.
            <field>-just = 'C'.
            <field>-edit = yes.

        when 'VALID_TO'.
            <field>-coltext = 'valid_to'.
            <field>-ref_table = 'LFEI'.
            <field>-ref_field  = 'PRENG'.
            <field>-outputlen = 30.
            <field>-just = 'C'.
            <field>-edit = yes.
        endcase.
    endloop.
endmethod.
**********************************************************************
method fieldCat_by_data.
"  https://abapblog.com/articles/how-to/76-create-fieldcatalog-from-internal-table
    cl_salv_table=>factory(
        importing r_salv_table = data(salv_table)
        changing t_table = util_dat->mt_dataINT
        ).

    rt_fcat =
        cl_salv_controller_metadata=>get_lvc_fieldcatalog(
            r_columns       = salv_table->get_columns( ) " ALV Filter
            r_aggregations = salv_table->get_aggregations( )
            ).
endmethod.
**********************************************************************
method user_command.
*    message i000 with 'toolbar_click' e_salv_function.
    data rowIdx type i.
    data selRow like line of util_dat->mt_dataINT.

    case e_ucomm.
*    when  'check'.   "std.Cmd
*        util_dat->map_data2db(  ).
*        >>> before_user_command( )

    when 'switch'.
        switch_edit_mode(  ).
    when 'persist'.
        util_dat->persist_lines(  ).
        refresh(  ).
    when 'toggle_keys'.
        toggle_keys(  ).
        refresh(  ).

    when 'show_msgs'.
        util_dat->show_msgs(  ).
    endcase.
endmethod.
**********************************************************************
method get_selceted_row.
    data selRows type lvc_t_roid.  " lvc_t_row

    check util_dat->mt_dataINT is not initial.
    if  getZero = no.
        e_row_id = 1.                 endif.

    alv->get_selected_rows( importing et_row_no = selRows ).
    check selRows is not initial.

    e_row_id = selRows[ 1 ]-row_id.
endmethod.
**********************************************************************
method set_color.
    if area = 'R'.      "K-key / R-row / C-cell / I-InfoRecord
        set_color_row( row_id ).

    elseif area = 'K'.
        set_color_key( row_id ).

    elseif area = 'I'.  "Purchase Info Record
        set_color_infoRec( row_id ).

    elseif col_id is supplied.
        set_color_cell( row_id = row_id    col_id = col_id ).
    else.
        set_color_row( get_selceted_row( yes ) ).
        endif.
endmethod.
**********************************************************************
method set_color_row.
    read table util_dat->mt_dataINT index row_id
        assigning field-symbol(<dataLn>).
    check <dataLn> is assigned.

    <dataLn>-color_line = 'C600'.   "red line

*   line &1 - Check error &2 &3 &4
    message e008  with row_id  into data(msg).
    util_dat->grab_syMsg( msg ).
endmethod.
**********************************************************************
method set_color_key.
    data ls_colorCell type lvc_s_scol.

    read table util_dat->mt_dataINT index row_id
        assigning field-symbol(<dataLn>).
    check <dataLn> is assigned.

   ls_colorCell-color-col = 3. "yellow
   ls_colorCell-fname     = 'SUPPLIER'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'MATERIAL'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'PLANT'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'PRFZONE'.
   append ls_colorCell to <dataLn>-color_cell.

*   line &1 - Duplicate KEY error &2 &3 &4
    message e011  with row_id  into data(msg).
    util_dat->grab_syMsg( msg ).
endmethod.
**********************************************************************
method set_color_infoRec.
    data ls_colorCell type lvc_s_scol.

    read table util_dat->mt_dataINT index row_id
        assigning field-symbol(<dataLn>).
    check <dataLn> is assigned.

   ls_colorCell-color-col = 7.  "orange
   ls_colorCell-fname     = 'SUPPLIER'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'MATERIAL'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'PLANT'.
   append ls_colorCell to <dataLn>-color_cell.

*   line &1 - Purc.Info.Rec missing &2 &3 &4
    message e010  with row_id  into data(msg).
    util_dat->grab_syMsg( msg ).
endmethod.
**********************************************************************
method reset_color.
    loop at util_dat->mt_dataINT assigning field-symbol(<dataint>).
        clear <dataint>-color.
        clear <dataint>-color_line.
        refresh <dataint>-color_cell.  "color info tab
    endloop.
endmethod.
**********************************************************************
method set_color_cell.
    read table util_dat->mt_dataINT index row_id
        assigning field-symbol(<dataLn>).
    check <dataLn> is assigned.

    append initial line to <dataLn>-color_cell
        assigning field-symbol(<color_cell>).
    check <color_cell> is assigned.

    <color_cell>-color-col = 6.  "red
    <color_cell>-color-int  = 0.  "intensified
    <color_cell>-color-inv = 0.   "inverted
    data(ls_fcat) = mt_fieldcat[ col_pos = col_id ].
    check ls_fcat is not initial.
    <color_cell>-fname = ls_fcat-fieldname.

*   line &1 - Check error &2 &3 &4
*    message e008  with row_id  into data(msg).
*    util_dat->grab_syMsg( msg ).
*----------------------------------------------------
* Colour code :
* Colour is a 4-char field where :
*      - 1st char = C (color property)
*      - 2nd char = color code (from 0 to 7)
*                          0 = background color
*                          1 = blue
*                          2 = gray
*                          3 = yellow
*                          4 = blue/gray
*                          5 = green
*                          6 = red
*                          7 = orange
*      - 3rd char = intensified (0=off, 1=on)
*      - 4th char = inverse display (0=off, 1=on)
*
* Colour overwriting priority :
*   1. Line
*   2. Cell
*   3. Column
*----------------------------------------------------
endmethod.
**********************************************************************
endclass.  "lcl_alv implementation
