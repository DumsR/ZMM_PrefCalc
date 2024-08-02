*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_Grid
*&---------------------------------------------------------------------*
**********************************************************************
class lcl_alv_grid definition
    friends cl_gui_alv_grid.

public section.
*    type-pools: icon.
    .constants:
        yes type abap_bool value abap_true
    ,   no  type abap_bool value abap_false
    . "-----------------------------------------------
    data:
        util_dat            type ref to lcl_mat_data
    ,   alv                    type ref to cl_gui_alv_grid
    ,   mt_f4               type lvc_t_f4
    ,   mt_fieldcat     type lvc_t_fcat
    ,   ms_fieldcat     type lvc_s_fcat
    ,   mv_keysON    like no.
    . "-----------------------------------------------
    events:
        user_cmd_event
            exporting value(e_ucomm) type sy-ucomm optional
    . "-----------------------------------------------
    methods:
        constructor
            importing iv_util_dat   type ref to lcl_mat_data
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
    ,   on_f4 for event onf4 of cl_gui_alv_grid
            importing e_fieldName e_fieldValue
                es_row_no     er_event_data      et_bad_cells    e_display
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
    ,   set_color_tarifCode
            importing       row_id type i
    ,   set_color_cell
            importing       row_id type i
                                     col_id  type i           optional
                                     col_nm type string optional
    . "-----------------------------------------------
protected section.
    methods:
        create_alv
    ,   fieldCat_by_data
            importing it_tab type any table  optional
            returning value(rt_fcat) type lvc_t_fcat
    ,   fieldCat_adjust
    ,   f4_fields_register
    ,   toggle_keys
    ,   f4_by_domain  "ZH_Domain > ms_fieldcat-domName
          importing domName type simple
          returning value(retVal) type string
    ,   f4_by_dd_table  "fieldCat-checktable
          importing iv_tabName type simple optional
                            iv_lang         type sy-langu optional
                            preferred parameter iv_lang
          returning value(retVal) type string
    ,   f4_by_int_table  "fieldCat-checktable
          importing iv_tabName type simple optional
          returning value(retVal) type string
    ,   f4_pref_zone
            importing shlp_name type shlpName default 'H_T604'
            returning value(retVal) type string
    ,   f4_tarif_code
            importing shlp_name type shlpName default 'H_T604'
            returning value(retVal) type string
    ,   f4_pref_status
            importing shlp_name type shlpName default 'SDSH_DOMAIN_FIXED_VALUES'
            returning value(retVal) type string
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
method on_f4.
*    message i000 with 'Event <on_f4> in row: '
*        es_row_no-row_id       'field: ' e_fieldName .

    data:
        tabNm   type dd03v-tabname
    ,   fieldNm type dd03v-fieldname
    ,   retVal      type string
    .field-symbols:
        <ln_data>  like line of util_dat->mt_dataint
    ,   <fld_dat> type any
    ,   <retVal>     type any
    .
    read table mt_fieldcat assigning field-symbol(<fcatLn>)
        with key fieldname = e_fieldName.
    check <fcatLn> is assigned.
    read table util_dat->mt_dataint
        index es_row_no-row_id assigning <ln_data>.
    check <ln_data> is ASSIGNED.

    ms_fieldCat = <fcatLn>.
    case e_fieldName.
    when 'PRF_ZONE'.        " f4_pref_zone(  ).
        retVal = f4_by_int_table( <fcatLn>-checktable ).
*        retVal = f4_by_dd_table( <fcatLn>-checktable ).
    when 'TARIF_CODE'.
        retVal = f4_tarif_code(  ).
    when 'VEND_STATUS'.
        retVal = f4_by_domain( <fcatLn>-domName ).
    when 'PREF_STATUS'.
        retVal = f4_by_domain( <fcatLn>-domName ).
        endcase.

    assign component e_fieldName
        of structure <ln_data> to <fld_dat>.
    if alv->is_ready_for_input(  ) = 0.
        message i013."ALV not in Write-Mode !!!
    elseif  retVal is not initial.
        <fld_dat> = retVal.
        endif.

    er_event_data->m_event_handled = yes.
    refresh(  ).
endmethod.
**********************************************************************
method f4_by_int_table.
    data lv_tabName type string.
    if iv_tabName is  supplied.
                lv_tabName = iv_tabName.
    else.    lv_tabName = ms_fieldCat-checktable.
                endif.

    data intValues type standard table of T604G.
*    data lo_data type ref to data.
*    field-symbols <intValues> type any table.
*    data dataDescr type ref to CL_ABAP_DATADESCR.
*    dataDescr ?= cl_abap_tableDescr=>describe_by_name( lv_tabName ).
**    create data lo_data type handle dataDescr.
*    create data lo_data type standard table of T604G.
*    assign lo_data->* to <intValues>.

    select * from (lv_tabName)   "T604G
        into table @intValues.

    data retValues  type standard table of ddshRetval.
    call function 'F4IF_INT_TABLE_VALUE_REQUEST'
        exporting
            value_org = 'S'  "Structure
            ddic_structure = 'T604G'
            retField = ms_fieldCat-ref_field    " 'GZOLX'
        tables
            value_tab = intValues
            return_tab = retValues
        exceptions
            parameter_error = 1
            field_not_found = 2.

    if sy-subrc is  initial.
        read table retValues index 1 assigning field-symbol(<retInfo>).
        check <retInfo> is assigned.
        retVal = <retInfo>-fieldval.
    else.
        message i000 with 'Error:' sy-subrc
            '(1-paramError/2-field_not_found)' display like 'E'.
        endif.
endmethod.
**********************************************************************
method f4_by_dd_table.
    data lv_tabName type string.
    if iv_tabName is  supplied.
                lv_tabName = iv_tabName.
    else.    lv_tabName = ms_fieldCat-checktable.
        endif.
    data retValues  type standard table of ddshRetval.
    call function 'F4IF_FIELD_VALUE_REQUEST'
        exporting
            tabName = ms_fieldCat-checktable  "param tabName?
            fieldName = ms_fieldCat-ref_field
        tables
            return_tab = retValues
        exceptions
            field_not_found = 1
            no_values_found = 2.

    if sy-subrc is  initial.
        read table retValues index 1 assigning field-symbol(<retInfo>).
        check <retInfo> is assigned.
        retVal = <retInfo>-fieldval.
    else.
        message i000 with 'Not found' sy-subrc
            '(1-field/2-value)' display like 'E'.
        endif.
endmethod.
**********************************************************************
method f4_by_domain.
*   get searchHelp
    data shlp type shlp_descr.              "at Almig:  'ZH_DOMAIN'.
    data shlp_name type shlpName value 'SDSH_DOMAIN_FIXED_VALUES'.

    call function 'F4IF_GET_SHLP_DESCR'
        exporting shlpName = shlp_name
        importing shlp     = shlp.

*  return fields  (slhp OUT)
    loop at shlp-interface assigning field-symbol(<if>).
        if  <if>-shlpField = ' DOMAIN_VALUE'.
            <if>-valField   = domName.
            endif.
    endloop.

*   set values  (slhp IN)
    append initial line to shlp-selopt assigning field-symbol(<selOpt>).
    <selOpt>-shlpfield = 'DOMAIN_NAME'.
    <selOpt>-sign = 'I'.
    <selOpt>-option = 'EQ'.
    <selOpt>-low  = domName.
    append initial line to shlp-selopt assigning <selOpt>.
    <selOpt>-shlpfield = 'LANGUAGE'.
    <selOpt>-sign = 'I'.
    <selOpt>-option = 'EQ'.
    <selOpt>-low  = sy-langu.

*   call slhp
    data lrc like sy-subrc.
    data lt_retVal type standard table of ddshRetval.
    call function 'F4IF_START_VALUE_REQUEST'
        exporting       shlp = shlp
        importing            rc = lrc
        tables return_values = lt_retVal.
    check lrc is initial.

    field-symbols <ls_retVal> like line of lt_retVal.
    read table lt_retVal assigning <ls_retVal>
        with key fieldname = 'DOMAIN_VALUE'.
    check <ls_retVal> is ASSIGNED.
        retVal = <ls_retVal>-fieldval.

endmethod.
**********************************************************************
method f4_pref_status.
endmethod.
**********************************************************************
method f4_pref_zone.
endmethod.
**********************************************************************
method f4_tarif_code.

*   get searchHelp
    data:
        shlp             type shlp_descr
*    ,   shlp_name type shlpName value 'H_T604'
    .
    call function 'F4IF_GET_SHLP_DESCR'
    exporting shlpName = shlp_name
*                      shlpType   = 'SH'  "default
    importing shlp          = shlp.

*  return fields  (slhp OUT)
    loop at shlp-interface assigning field-symbol(<if>).
        if       <if>-shlpField = 'STAWN'.
                  <if>-valField   = 'STAWN'.
        elseif <if>-shlpField = 'LAND1'.
                  <if>-valField   = 'LAND1'.
            endif.
    endloop.

*   set values  (slhp IN)
    append initial line to shlp-selopt assigning field-symbol(<selOpt>).
    <selOpt>-shlpfield = 'LAND1'.
    <selOpt>-sign = 'I'.
    <selOpt>-option = 'EQ'.
    <selOpt>-low  = sy-langu.

*   call slhp
    data lt_retVal type standard table of ddshRetval.
    field-symbols <ls_retVal> like line of lt_retVal.

    call function 'F4IF_START_VALUE_REQUEST'
    exporting shlp = shlp
*                 disponly  = yes
    tables return_values = lt_retVal.

    read table lt_retVal
        with key fieldname = 'STAWN' assigning <ls_retVal>.
    check <ls_retVal> is ASSIGNED.
    retVal = <ls_retVal>-fieldval.
*    Version1 ---------------------------------------------
* data:
* ,   lv_fieldValue type dynfieldvalue
* ,   lt_f4 type table of ddshretval
* .
*    lv_fieldValue = e_fieldValue.
*    perform f4_set in program bcalv_f4
*        using alv   mt_fieldcat     et_bad_cells   row  <ln_dataInt>.
*
*    call function 'F4IF_FIELD_VALUE_REQUEST' exporting
*        tabname            = lv_tabNm
*        fieldname            = lv_fieldNm
*        display                   = e_display
*        callback_program = 'BCALV_F4'
*        value                        = lv_fieldValue
*        callback_form          = 'F4'
*      tables    return_tab      = lt_f4.

*    Version 0 ---------------------------------------------
*   data:
*        lt_fields  type standard table of dfies
*    ,   lt_values type standard table of string
*    ,   lt_returns type standard table of ddshretval
*    .
*    call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting retfield = e_fieldName
**                      value_org = 'C'   "default
*    tables  field_tab  = lt_fields
*                value_tab = lt_values
*                return_tab = lt_returns.
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
        where fieldname = 'MATERIAL' or fieldname = 'PLANT'
              or fieldname = 'PRF_ZONE'.
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
        f4_fields_register(  ).
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
        alv->register_f4_for_fields( mt_f4 ).
        alv->get_registered_events(
            importing events = data(alv_events) ).
        set handler me->toolbar_cfg     for alv.
        set handler me->dbl_click           for alv.
        set handler me->on_f4                 for alv.
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
        when 'MATERIAL'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'MATNR'.
            <field>-key = yes.
            <field>-outputlen = 10.
            <field>-just = 'C'.

        when 'PLANT'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'WERKS'.
            <field>-key = yes.
        when 'COUNTRY'.
            <field>-col_pos = 3.

        when 'PRF_ZONE'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'GZOLX'.
            <field>-outputlen = 10.
            <field>-key = yes.
            <field>-just = 'C'.

        when 'TARIF_CODE'.
            <field>-coltext     = 'Tarif Code'.
            <field>-ref_table  ='MARC'.
            <field>-ref_field   ='STAWN'.
            <field>-edit = yes.
            <field>-just = 'C'.

        when 'VEND_STATUS'.
            <field>-coltext = 'Vend.Status'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'PRENE'.
            <field>-outputlen = 8.
            <field>-just = 'C'.
            <field>-edit = yes.

        when 'VEND_VALID_TO'.
            <field>-coltext = 'vend.Valid-to'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'PRENG'.
            <field>-outputlen = 30.
            <field>-just = 'C'.
            <field>-edit = yes.

        when 'PREF_STATUS'.
            <field>-coltext = 'Pref.Status'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'PREFE'.
            <field>-outputlen = 8.
            <field>-just = 'C'.
            <field>-edit = yes.

        when 'PREF_VALID_TO'.
            <field>-coltext = 'pref.Valid-to'.
            <field>-ref_table = 'MAPE'.
            <field>-ref_field  = 'PREDA'.
            <field>-outputlen = 30.
            <field>-just = 'C'.
            <field>-edit = yes.
         endcase.
    endloop.
endmethod.
**********************************************************************
method f4_fields_register.
    data f4regLn like line of mt_f4.
    f4regLn-register     = yes.
    f4regLn-getbefore  = yes.
    f4regLn-chngeafter = yes.

    loop at mt_fieldcat assigning field-symbol(<fcat>).
        case <fcat>-fieldname.
        when 'PRF_ZONE'.
            <fcat>-f4availabl = yes.  "T604G
            <fcat>-checktable = 'T604G'.
            <fcat>-domname = 'GZOLX'.
            f4regLn-fieldname = <fcat>-fieldname.
            insert f4regLn into table mt_f4.
        when  'TARIF_CODE'.
            <fcat>-f4availabl = yes.  "H_T604
            <fcat>-domname = 'STAWN'.
            f4regLn-fieldname = <fcat>-fieldname.
            insert f4regLn into table mt_f4.
        when 'VEND_STATUS'.
            <fcat>-f4availabl = yes.
           <fcat>-domname = 'PRENE'.
            f4regLn-fieldname =  <fcat>-fieldname.
            insert f4regLn into table mt_f4.
        when 'PREF_STATUS'.
            <fcat>-f4availabl = yes.
            <fcat>-domname = 'PREFE'.
            f4regLn-fieldname =  <fcat>-fieldname.
            insert f4regLn into table mt_f4.
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
        set_color_tarifCode( row_id ).

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
   ls_colorCell-fname     = 'MATERIAL'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'PLANT'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'PRF_ZONE'.
   append ls_colorCell to <dataLn>-color_cell.

*   line &1 - Duplicate KEY error &2 &3 &4
    message e011  with row_id  into data(msg).
    util_dat->grab_syMsg( msg ).
endmethod.
**********************************************************************
method set_color_tarifCode.
    data ls_colorCell type lvc_s_scol.

    read table util_dat->mt_dataINT index row_id
        assigning field-symbol(<dataLn>).
    check <dataLn> is assigned.

   ls_colorCell-color-col = 7.  "orange
   ls_colorCell-fname     = 'PLANT'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'COUNTRY'.
   append ls_colorCell to <dataLn>-color_cell.
   ls_colorCell-fname     = 'TARIF_CODE'.
   append ls_colorCell to <dataLn>-color_cell.

*   line &1 - Tarif Code missing &2 &3 &4
    data(msg) = |({ <dataLn>-tarif_code }-{ <dataLn>-country })|.
    message e011  with row_id  <dataLn>-tarif_code  msg into msg.
    util_dat->grab_syMsg( msg ).
endmethod.
**********************************************************************
method reset_color.
    loop at util_dat->mt_dataINT assigning field-symbol(<dataint>).
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

    if col_Nm is supplied.
        <color_cell>-fname = col_nm.
    elseif col_id is supplied.
        data(ls_fcat) = mt_fieldcat[ col_pos = col_id ].
         check ls_fcat is not initial.
        <color_cell>-fname = ls_fcat-fieldname.
    else.
        <color_cell>-fname = 'MATERIAL'.
        endif.
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
