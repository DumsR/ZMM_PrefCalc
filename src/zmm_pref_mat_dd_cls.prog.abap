*&---------------------------------------------------------------------*
*& Include zmm_pref_calc_upld2_cls
*&---------------------------------------------------------------------*

class lcl_helper definition inheriting from cl_salv_model_base.
  public section.
    types:
      begin of ty_data_line,
        material       type marc-matnr,
        plant            type marc-werks,
        tarif_code    type marc-stawn,
        prf_zone       type mape-gzolx,
        decl_code    type mape-prene,
        valid_to        type mape-preng,
        pref_calc      type mape-prefe,
        pred_to        type mape-preda,
        color            type lvc_t_scol, "ColorInfo
      end of ty_data_line,
      begin of ty_nm_map,
        extNm type string,
        intNm type string,
      end of ty_nm_map.
    "-----------------------------------------------
    constants:
      yes type abap_bool value abap_true,
      no  type abap_bool value abap_false.
     "-----------------------------------------------
    data:
      mv_filepath type string,
      mo_alv      type ref to cl_salv_table,
      alv_grid    type ref to cl_gui_alv_grid,
      mt_csv      type table of string,
      mt_dataINT  type standard table of ty_data_line,
      mt_dataDB   type sorted table of mape
                        with unique key matnr werks gzolx,
      mt_mapCfg   type standard table of ty_nm_map,
      mt_msgs     type bapiret2_t.
     "-----------------------------------------------
    methods:
      constructor importing iv_filepath type string optional,

      select_file importing iv_filepath        type string optional
                  returning value(rv_filepath) type string,

      load_from_DB importing iv_matnr type marc-matnr
                               iv_plant type marc-werks,

      load_from_file importing iv_filepath type string optional
                returning value(done) like abap_true,

      map_csv2data,
      prepare_alv,
      map_data2db,
      map_db2data,

      persist_lines
*     show_msgs.
    . "-----------------------------------------------
  protected section.
    methods:
*    get_mapping_cfg,
      create_alv,
      display_alv,
      get_selceted_row
        returning value(rowIdx) type i,
      grab_syMsg importing msgTxt type string optional
*            set_color IMPORTING rowIdx TYPE i,
*            set_color_key IMPORTING rowIdx TYPE i.
. "-----------------------------------------------
  private section.
    methods convert_date_in
      importing iv_date        type string
      returning value(rv_date) type dats
*    ,   map_data2db_dyn

    . "-----------------------------------------------
endclass.
class lcl_helper implementation.
**********************************************************************
method constructor.
    super->constructor( ).
    if iv_filepath is supplied.
      mv_filepath = iv_filepath.
    endif.
endmethod.
**********************************************************************
method select_file.
    data: it_files type filetable,
          lv_title type string,
          lv_dir   type string,
              lv_file    TYPE string,
              offset     TYPE i.

    lv_title = 'Select a file'.
    lv_dir = 'C:\Temp'.

    if iv_filepath is supplied and iv_filepath is not initial.
      mv_filepath = iv_filepath.
    endif.

    offset = find( val = mv_filepath  sub = '\'  occ = -1 ).
    lv_dir = substring( val = mv_filepath len = offset ).
    lv_file = substring( val = mv_filepath off = offset + 1 ).

    call function 'GUI_UPLOAD'
      exporting
                  filename                          = mv_filepath
                  filetype                            = 'ASC'
      tables
                 data_tab                           = mt_csv
      exceptions file_open_error         = 1
                 file_read_error                  = 2
                 no_batch                           = 3
                 gui_refuse_filetransfer      = 4
                 invalid_type                      = 5
                 no_authority                     = 6
                 unknown_error                 = 7
                 bad_data_format             = 8
                 header_not_allowed        = 9
                 separator_not_allowed    = 10
                 header_too_long              = 11
                 unknown_dp_error           = 12
                 access_denied                  = 13
                 dp_out_of_memory          = 14
                 disk_full                             = 15
                 dp_timeout                      = 16
                 not_supported_by_gui     = 17
                 error_no_gui                     = 18
                 others                               = 19.
*<<<<
*        IF sy-subrc IS INITIAL.
*            done = abap_true.
*            MESSAGE s002 WITH mv_filepath 'done'.
*        ELSE.
*            MESSAGE e002 WITH mv_filepath 'FAIL !!!'.
*        ENDIF.
  endmethod.
**********************************************************************
method load_from_DB.
    data(lv_matnr) = |{ iv_matnr alpha = out }|.

    data lt_mape type table of mape.
    select * from mape
        where matnr = @iv_matnr
            and werks  = @iv_plant
        appending corresponding fields of table  @lt_mape.

    refresh mt_dataINT.
    loop at lt_mape into data(ls_mape).
        append initial line to mt_dataINT
            assigning field-symbol(<ls_dataINT>).
        <ls_dataINT>-material = ls_mape-matnr.
        <ls_dataINT>-plant      = ls_mape-werks.
*        <ls_dataINT>-tarif_code = ls_mape-stawn.   "table marc
        <ls_dataINT>-prf_zone = ls_mape-gzolx.
        <ls_dataINT>-decl_code = ls_mape-prene.
        <ls_dataINT>-valid_to = ls_mape-preng.
        <ls_dataINT>-pref_calc = ls_mape-prefe.
        <ls_dataINT>-pred_to = ls_mape-preda.
    endloop.
  endmethod.
**********************************************************************
  method load_from_file.
    " TODO: parameter IV_FILEPATH is never used (ABAP cleaner)

    if mv_filepath is initial.
      message e003 with mv_filepath.
    endif.

    call function 'GUI_UPLOAD'
      exporting  filename                = mv_filepath
                 filetype                = 'ASC'
      tables     data_tab                = mt_csv
      exceptions file_open_error         = 1
                 file_read_error         = 2
                 no_batch                = 3
                 gui_refuse_filetransfer = 4
                 invalid_type            = 5
                 no_authority            = 6
                 unknown_error           = 7
                 bad_data_format         = 8
                 header_not_allowed      = 9
                 separator_not_allowed   = 10
                 header_too_long         = 11
                 unknown_dp_error        = 12
                 access_denied           = 13
                 dp_out_of_memory        = 14
                 disk_full               = 15
                 dp_timeout              = 16
                 not_supported_by_gui    = 17
                 error_no_gui            = 18
                 others                  = 19.

    if sy-subrc is initial.
      done = abap_true.
      message s002 with mv_filepath 'done'.
    else.
      message e002 with mv_filepath 'FAIL !!!'.
    endif.
  endmethod.
**********************************************************************
  method map_csv2data.
    check mt_csv is not initial.
    data: strgln like line of mt_csv,
          dataln like line of mt_dataINT,
          itstrg type table of string.

    loop at mt_csv from 2 into strgln. " skip headerLine
      split strgln at ';' into table itstrg.
      clear dataln.
      dataln-material    = itstrg[ 1 ].
      dataln-plant       = itstrg[ 2 ].
      dataln-tarif_code = itstrg[ 3 ].
      dataln-prf_zone    = itstrg[ 4 ].
      dataln-decl_code   = itstrg[ 5 ].
      dataln-valid_to    = convert_date_in( itstrg[ 6 ] ).
      dataln-pref_calc   = itstrg[ 7 ].
      dataln-pred_to     = convert_date_in( itstrg[ 8 ] ).

      " Validierung
      if    dataln-material    is initial
         or dataln-plant       is initial
         or dataln-tarif_code is initial
         or dataln-prf_zone    is initial
         or dataln-decl_code   is initial
         or dataln-valid_to    is initial
         or dataln-pref_calc   is initial
         or dataln-pred_to     is initial.
        " Fehlerbehandlung
        dataln-color = value #( ( color-col = 6 ) ). " Rot
      endif.

      append dataln to mt_dataINT.
    endloop.
  endmethod.
**********************************************************************
  method convert_date_in.
    data(lv) = condense( val  = iv_date
                         from = '.'
                         to   = '' ).
    rv_date = lv+4(4) && lv+2(2) && lv(2).
  endmethod.
**********************************************************************
  method prepare_alv.
    create_alv( ).
    display_alv( ).
  endmethod.
**********************************************************************
  method create_alv.
    check mo_alv is not bound.
    try.
        data container type ref to cl_gui_custom_container.
        container = new #( 'ALV_CONTAINER' ).

        cl_salv_table=>factory(
            exporting r_container  = container
            importing r_salv_table = mo_alv
            changing  t_table      = mt_dataINT ).

*        data(alv_events) = mo_alv->get_event( ).
*        SET HANDLER lcl_helper=>hndl_dbl_click FOR alv_events.
*        SET HANDLER me->toolbar_click FOR alv_events.

      catch cx_root into data(cx).
        data(info) = cx->get_text( ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry.
  endmethod.
**********************************************************************
  method display_alv.
    try.
        mo_alv->display( ).

*        alv_grid = get_grid_from_salv( mo_alv ).
*        if alv_grid is bound.
*            set handler me->toolbar_cfg FOR alv_grid.
*        endif.

        mo_alv->refresh( ). " Toolbar refresh
      catch cx_root into data(cx).
        data(info) = cx->get_text( ).
        message e000 with 'ALV' 'display' 'FAIL ---' info.
    endtry.
  endmethod.
**********************************************************************
  method get_selceted_row.
    check mt_dataINT is not initial.
    data(selRows) = mo_alv->get_selections( )->get_selected_rows( ).
    if selRows is initial.
      return.
    endif.
    rowIdx = selRows[ 1 ].
  endmethod.
**********************************************************************
  method map_db2data.
    check mt_dataDB is not initial.
    refresh mt_dataINT.

    loop at mt_dataDB assigning field-symbol(<dbLn>).
      append initial line to mt_dataINT
             assigning field-symbol(<dataLn>).

      <dataLn>-material  = <dbLn>-matnr.
      <dataLn>-plant     = <dbLn>-werks.
*        <dataLn>-tarif_code = <dbLn>-stawn.
      <dataLn>-prf_zone  = <dbLn>-gzolx.
      <dataLn>-decl_code = <dbLn>-prene.
      <dataLn>-valid_to  = <dbLn>-preng.
      <dataLn>-pref_calc = <dbLn>-prefe.
      <dataLn>-pred_to   = <dbLn>-preda.
    endloop.
  endmethod.
**********************************************************************
  method map_data2db.
    refresh mt_dataDB.
    data dbLn like line of mt_dataDB.

    loop at mt_dataINT assigning field-symbol(<intLn>).
      data(rowID) = sy-tabix.
      dbLn-matnr = <intLn>-material.
      dbLn-werks = <intLn>-plant.
*        dbLn-stawn = <intLn>-tarif_code.
      dbLn-gzolx = <intLn>-prf_zone.
      dbLn-prene = <intLn>-decl_code.
      dbLn-preng = <intLn>-valid_to.
      dbLn-prefe = <intLn>-pref_calc.
      dbLn-preda = <intLn>-pred_to.

      " Überprüfen auf doppelten Schlüssel
      if not line_exists( mt_dataDB[              matnr = dbLn-matnr
                                                                    werks = dbLn-werks
                                                                    gzolx = dbLn-gzolx ] ).
        insert dbLn into table mt_dataDB. "append
      else.
        refresh mt_dataDB.
*            set_color_key( rowID ).
*           continue.
      endif.
    endloop.
  endmethod.
**********************************************************************
  method persist_lines.
    check mt_dataDB is not initial.

    data okCnt like sy-dbcnt.
    refresh mt_msgs.

    loop at mt_dataDB assigning field-symbol(<ln>).
      data(info) = |{ <ln>-matnr }-{ <ln>-werks }-{ <ln>-gzolx }|.

      modify mape from <ln>.
      if sy-subrc is initial.
        okCnt += 1.
        message s006 with okCnt 'updated line' info into data(msg).
        grab_syMsg( msg ).
        continue.
      endif.

      insert mape from <ln>.
      if sy-subrc is initial.
        okCnt += 1.
        message s006 with okCnt 'inserted line' info into msg.
        grab_syMsg( msg ).
        continue.
      endif.

      " modify & insert FAIL !!!
      message e005 with sy-dbcnt 'MAPE' info into msg.
      grab_syMsg( msg ).
    endloop.

    if okCnt is not initial.
      message s006 with okCnt 'lines' 'inserted to' 'MAPE' into msg.
      grab_syMsg( msg ).
    endif.

    if mt_msgs is not initial.
      cl_rmsl_message=>display( mt_msgs ).
    endif.
  endmethod.

  method grab_syMsg.
    check sy-msgno is not initial.

    append initial line to mt_msgs assigning field-symbol(<bapiMsg>).
    if msgTxt is supplied.
      <bapiMsg>-message = msgTxt.
    endif.
    <bapiMsg>-type       = sy-msgty.
    <bapiMsg>-id         = sy-msgid.
    <bapiMsg>-number     = sy-msgno.
    <bapiMsg>-message_v1 = sy-msgv1.
    <bapiMsg>-message_v2 = sy-msgv2.
    <bapiMsg>-message_v3 = sy-msgv3.
    <bapiMsg>-message_v4 = sy-msgv4.
  endmethod.
  " ---------------------------------------------------------------------
endclass.  " Implementation
