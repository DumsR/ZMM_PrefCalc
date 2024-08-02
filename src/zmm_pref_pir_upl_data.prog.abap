
*&---------------------------------------------------------------------*
*& Include zmm_pref_PIR_upl_data
*&---------------------------------------------------------------------*
**********************************************************************
*class lcl_alv definition load.

class lcl_data definition.
*    inheriting from cl_salv_model_base.
public section.
    types:
        begin of ty_data_line
        ,   supplier    type lfei-lifnr
        ,   material    type lfei-matnr
        ,   plant         type lfei-werks
        ,   prfZone     type lfei-gzolx
        ,   declCode  type lfei-prene
        ,   valid_to     type lfei-preng
        ,   color          type lvc_t_scol  "ColorInfo SALV
        ,   color_line  type c length 4  "Color line ALV_grid
        ,   color_cell  type lvc_t_scol   "Color cell ALV_grid
    ,   end of ty_data_line
    ,   begin of ty_nm_map
    ,       extNm    type string
    ,       intNm     type string
    ,   end of  ty_nm_map
    .constants:
        yes       type abap_bool value abap_true
    ,   no        type abap_bool value abap_false
    ,   alv_cls type string value  'LCL_SALV'
    . "-----------------------------------------------
    data:
        mv_filepath      type string
    ,   mt_csv              type table of string
    ,   mt_dataINT      type standard  table of ty_data_line
    ,   mt_dataDB       type sorted table of LFEI
                                   with unique key lifnr matnr werks gzolx
    ,   mt_mapCfg     type standard table of ty_nm_map
    ,   mt_msgs          type bapiRet2_T
    ,   mo_alv             type ref to object "lcl_alv / cl_gui_alv_grid
    . "----------------------------------" cl_salv_model_base
    methods:                                        "
        constructor
            importing iv_filepath type string optional
    ,   set_alv
            importing iv_alv type ref to object "any "cl_salv_model_base
    ,   select_file
            importing iv_filepath type string optional
            returning value(rv_filepath) type string
    ,   load_fromDB
            importing
               iv_suppl       type lfei-lifnr      optional
               iv_matnr       type lfei-matnr optional
               iv_plant         type lfei-werks optional
               iv_prfZone    type lfei-gzolx  optional
               iv_declCode  type lfei-prene optional
               iv_valid          type any table  "so for lfei-preng
    ,   load_fromFile
            importing iv_filepath type string optional
            returning value(done) like yes
    ,   map_csv2data
    ,   map_data2db
    ,   map_db2data
    ,   persist_lines "line by line
    ,   grab_syMsg
            importing msgTxt type string optional
    ,   show_msgs
    . "-----------------------------------------------
protected section.
    data:
        act_rowID    type sy-tabix
    ,   zoneValues  type standard table of T604G
    ,   delcCodes  type standard table of DD07V
    .methods:
        map_data2db_dyn
    ,   persist_table
    ,   load_zoneValues
    ,   load_delcCodes
    . "-----------------------------------------------
private section.
    methods:
        convert_date_in
            importing         iv_date  type string
            returning value(rv_date) type dats
    ,   get_mapping_cfg
    ,   map_line2db
            importing           is_int like line of mt_dataINT
            returning value(es_DB) like line of mt_dataDB
    ,   check_key
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_infoRec      "Purch.Info.Record
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_prefZone
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_delcCode
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    . "-----------------------------------------------
endclass.        "definition
class lcl_data implementation.
**********************************************************************
method map_csv2data.
    check mt_csv is not initial.
    data:
      strgln like line of mt_csv
    , dataln like line of mt_dataINT
    , itStrg type table of string
    .
    loop at mt_csv from 2 into strgln. "skip headerLine
        split strgln at ';' into table itStrg.

        dataln-supplier     = itStrg[ 1 ].
*        dataln-material    = itStrg[ 2 ].
        dataln-plant           = itStrg[ 3 ].
        dataln-prfZone       = itStrg[ 4 ].
        dataln-declCode     = itStrg[ 5 ].   "matnr in MARA:  18c
        dataln-material  = |{ itStrg[ 2 ] width = 18 alpha = IN }|.
        dataLn-valid_to         = convert_date_IN( itStrg[ 6 ] ).

        append dataln to mt_dataINT.
    endloop.

*        data matnrDB type LFEI-matnr.
*        call function 'CONVERSION_EXIT_ALPHA_INPUT'
*            exporting  input =  itStrg[ 2 ]
*            importing output = matnrDB.
*        dataln-material = matnrDB.
endmethod.
**********************************************************************
method convert_date_in.
    data(lv) = condense( val = iv_date  from = '.'  to = '' ).
    rv_date = lv+4(4) && lv+2(2) && lv(2).

*    rv_date = iv_date+6(4) && iv_date+3(2) && iv_date(2).
*        dataLn-valid_to =  |{  iv_strg  alpha = IN  }|.
*      read table itStrg index 1 into dataLn-supplier.
*    , cntry type land1 value 'EN'
*    set country cntry.
*    write iv_strg to dataln-valid_to yymmdd.  ">> 02.05.20
*    dataLn-valid_to = |{ iv_strg  alpha = IN  }|. ">> 02.05.20
*    COUNTRY = cntry
*    DATE = USER/ENVIRONMENT
endmethod.
**********************************************************************
method constructor.
    super->constructor(  ).

    if iv_filepath is supplied.  "Param set upperCase :-(
        mv_filepath = iv_filepath.
        endif.
endmethod.
**********************************************************************
method set_alv.
*    data alv type ref to object. " LCL_ALV
*    create object mo_alv type (alv_cls) exporting iv_util_dat = me.
    mo_alv = iv_alv.
endmethod.
**********************************************************************
method select_file.
    data:
        lv_rc      like sy-subrc
    ,   it_files   type filetable
    ,   fileinfo   like line of it_files
    ,   lv_title   type string
    ,   lv_dir     type string
    ,   lv_file    type string
    ,   offset     type i
    .
    lv_title = 'select a file'(003).
    lv_dir = 'C:\Temp'(004).

    if iv_filepath is supplied
    and iv_filepath is not initial.
      mv_filepath = iv_filepath.
      endif.

    offset = find( val = mv_filepath  sub = '\'  occ = -1 ).
    lv_dir = substring( val = mv_filepath len = offset ).
    lv_file = substring( val = mv_filepath off = offset + 1 ).

    cl_gui_frontend_services=>file_open_dialog(
    exporting
        window_title       = lv_title
        default_filename   = lv_file
        default_extension  = '.xlsx'
        initial_directory  = lv_dir
        multiselection     = no
    changing
        file_table         = it_files
        rc                 = lv_rc
    exceptions
       cntl_error           = 1
       error_no_gui          = 2
       not_supported_by_gui   = 3
       file_open_dialog_failed = 4
       others = 5  ).

   if sy-subrc is initial
   and it_files is not initial.
      read table it_files index 1 into fileinfo.
      rv_filepath = mv_filepath = fileinfo-filename.
      message s001 with mv_filepath 'done'.
   else.
      message i001 with mv_filepath 'FAIL !!!' display like 'E'.
      endif. "File &1 selection &2 &3 &4
endmethod.
**********************************************************************
method load_fromDB.

    refresh mt_dataDB.     "matnr ... 18 !!!

    data sqlCond type string.
    if iv_suppl is supplied and iv_suppl is not initial.
        sqlCond = |lifnr = iv_suppl and|.
        endif.
    if iv_matnr is supplied and iv_matnr is not initial.
        data(lv_matnr) = |{ iv_matnr  width = 18 alpha = IN }|.
        sqlCond = |{ sqlCond } matnr = lv_matnr and|.
        endif.
    if iv_plant is supplied and iv_plant is not initial.
        sqlCond = |{ sqlCond } werks = iv_plant and|.
        endif.
    if iv_prfZone is supplied and iv_prfZone is not initial.
        sqlCond = |{ sqlCond } gzolx = iv_prfZone and|.
        endif.
    if iv_declCode is supplied and iv_declCode is not initial.
        sqlCond = |{ sqlCond } prene = iv_declCode and|.
        endif.
*    if iv_valid is supplied and iv_valid is not initial.
        sqlCond = |{ sqlCond } preng IN iv_valid[] |.

    select * from LFEI
        into table mt_dataDB
            where (sqlCond).
*          where matnr >= lv_matnr.
*        where lifnr      = iv_suppl
*            and matnr  = lv_matnr
*            and werks   = iv_plant
*            and gzolx   = iv_prfZone
*            and prene   = iv_declCode
*            and preng  IN iv_valid[].

endmethod.
**********************************************************************
method load_fromFile.
  if mv_filepath is initial.
      message e003 with mv_filepath.
      endif. "FilePath missing!

  call function 'GUI_UPLOAD'
    exporting
      filename                = mv_filepath
      filetype                = 'ASC'
*      codePage                = cdPage "4110 UTF-8
    tables
      data_tab                = mt_csv
    exceptions
      file_open_error         = 1
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
      done = yes.
      message s002 with mv_filepath 'done'.
   else.
      message e002 with mv_filepath 'FAIL !!!'.
      endif. "File &1 upload &2 &3 &4.
endmethod.
**********************************************************************
method map_db2data.
    check mt_dataDB is not initial.
    refresh mt_dataINT.

    loop at mt_dataDB assigning field-symbol(<dbLn>).
        append initial line to mt_dataINT
                   assigning field-symbol(<dataLn>).
        <dataLn>-supplier  =  <dbLn>-lifnr.
        <dataLn>-plant        =  <dbLn>-werks.
        <dataLn>-prfZone   = <dbLn>-gzolx.
        <dataLn>-declCode = <dbLn>-prene.
        <dataLn>-valid_to    = <dbLn>-preng.
        <dataLn>-material  =  "matnr in MARA:  18char
                            |{ <dbLn>-matnr   width = 18 alpha = IN }|.
*      <dataLn>-material  =  |{ <dbLn>-matnr alpha = out }|.
    endloop.
    refresh mt_dataDB.  "cleanup for persist( ).
endmethod.
**********************************************************************
method map_line2db.
*   https://codezentrale.de/tag/conversion_exit_alpha_input/ ... matnr
    es_DB-lifnr     =  is_int-supplier.
    es_DB-werks  =  is_int-plant.
    es_DB-gzolx   = is_int-prfzone.
    es_DB-prene  = is_int-declcode.
    es_DB-preng  = is_int-valid_to.  "matnr in MARA:  18char
    es_DB-matnr  = |{ is_int-material width = 18 alpha = IN }|.

*    call function 'CONVERSION_EXIT_ALPHA_INPUT'
*        exporting  input = is_int-material
*        importing output = es_DB-matnr.   "
                             "0000000000000000000000000000000000000001
endmethod.
**********************************************************************
method check_key.
    if                                                                           "empty key
           (      is_DB-lifnr    is initial    and is_DB-matnr is initial
           and is_DB-werks  is initial   and is_DB-gzolx is initial  )

    OR  line_exists(  mt_dataDB[                             "Duplicate?
                lifnr    = is_DB-lifnr       matnr = is_DB-matnr
                werks  = is_DB-werks   gzolx   = is_DB-gzolx   ]  ).

*     Duplicate KEY error  ----------------------------------------
        ok = no.
        call method mo_alv->('SET_COLOR_KEY')
                exporting row_id = act_rowID.
    else.
        ok = yes.
    endif.
endmethod.
**********************************************************************
method check_infoRec.
*    select infnr, werks from EINE
*        where werks  = @is_DB-werks
*        into table @data(infoRecs).
*
*    select infnr, matnr, lifnr from EINA
*        for all entries in @infoRecs
*        where infNr = @infoRecs-infNr
*        into table @data(einaRecs).

    select count( * ) from EINE
    inner join EINA on eine~infnr = eina~infnr
        where eine~werks  = @is_DB-werks
*          and eine~ekorg  = @is_DB-werks
            and eina~lifnr     = @is_DB-lifnr
            and eina~matnr = @is_DB-matnr
*            and eine~loeKz is initial
        into @data(cnt).

    if cnt > 0.  "Purch.Info.Record -- exist
        ok = yes.
    else.
        ok = no.      "Purc.Info.Rec missing
        call method mo_alv->('SET_COLOR_INFOREC')
            exporting row_id = act_rowID.
        endif.
endmethod.
**********************************************************************
method load_zoneValues.
    check zoneValues is initial.

    select * from T604G into table @zoneValues.
endmethod.
**********************************************************************
method check_prefZone.
    load_zoneValues(  ).

    read table zoneValues transporting no fields
        with key gzolx = is_DB-gzolx.

    if sy-subrc is initial.  "domValue found
        ok = yes.
    else.
        ok = no.
        call method mo_alv->('SET_COLOR_CELL')
            exporting row_id = act_rowID  col_id = 4.
        message e009 with act_rowID is_DB-gzolx
            'Pref.Zone ' '(GZOLX)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method load_delcCodes.
    check delcCodes is initial.

    call function 'FM_DOMAINVALUE_CHECK'
        exporting i_domname = 'PRENE'
        tables        t_dd07v   = delcCodes.
endmethod.
**********************************************************************
method check_delcCode.
    load_delcCodes(  ).

    read table delcCodes transporting no fields
        with key domValue_L = is_DB-prene.

    if sy-subrc is initial.  "domValue found
        ok = yes.
    else.
        ok = no.
        call method mo_alv->('SET_COLOR_CELL')
            exporting row_id = act_rowID  col_id = 4.
        message e009 with act_rowID is_DB-prene
            'Decl.Code ' '(PRENE)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method map_data2db.
    data dbLn like line of mt_dataDB.
    refresh: mt_dataDB, mt_msgs.
    call method mo_alv->('RESET_COLOR').

    loop at mt_dataINT assigning field-symbol(<intLn>).
        act_rowID = sy-tabix.
        dbLn = map_line2db( <intLn> ).

        data(key_ok) = check_key( dbLn  ).
        data(pir_ok)   = check_infoRec( dbLn  ).
        data(prfZ_ok) = check_prefZone( dbLn  ).
        data(dclC_ok) = check_delcCode( dbLn  ).

*      all ok ? -------------------------------------
        check key_ok = yes     and  pir_ok = yes
            and prfZ_ok = yes   and dclC_ok = yes.

        insert dbLn into table mt_dataDB.
    endloop.

    if lines( mt_msgs  ) > 0.
        cl_rmsl_message=>display( mt_msgs ).
        refresh mt_dataDB.
        endif.
endmethod.
**********************************************************************
method map_data2db_dyn.
    field-symbols:
        <intLn>     like line of mt_dataINT
    ,   <dbLn>      like line of mt_dataDB
    ,   <mapFld> like line of mt_mapCfg
    ,   <csvFld>   type data
    ,   <dbFld>    type data
    .
    get_mapping_cfg( ).
    refresh mt_dataDB.

    loop at mt_dataINT assigning <intLn>.
        append initial line to mt_dataDB assigning <dbLn>.

        loop at mt_mapCfg assigning <mapFld>.
            data(intNm) = <mapFld>-extNm.
            data(dbNm)    = <mapFld>-intNm.
            assign component intNm of structure <intLn> to <csvFld>.
            assign component dbNm of structure <intLn>  to <dbFld>.
            <dbFld> = <csvFld>.
        endloop.  "fields

    endloop.     "lines (mt_data)
endmethod.
**********************************************************************
method persist_lines.  "line by line
    check mt_dataDB is not initial.

    data okCnt like sy-dbcnt.
    data rc        like sy-subrc.
    refresh mt_msgs.

    loop at mt_dataDB assigning field-symbol(<ln>).
        data(info) = |{ <ln>-lifnr }-{ <ln>-matnr }-{ <ln>-werks }|.

        modify LFEI from <ln>.      "update line -------------------------
        if sy-subrc is  initial.
            okCnt += 1.
            message s006  with okCnt 'updated line' info into data(msg).
            grab_syMsg( msg ). "Save DB  - &1 &2 &3 &4
            continue.
            endif.

        insert LFEI from <ln>.          "insert line -------------------------
        if sy-subrc is  initial.
            okCnt += 1.
            message s006  with okCnt 'inserted line' info into msg.
            grab_syMsg( msg ). "Save DB  - &1 &2 &3 &4
            continue.
            endif.

*      modify & insert FAIL !!!
        message e005  with sy-dbcnt 'LFEI' info into msg.
        grab_syMsg( msg ). "Save DB error - &1 &2 &3 &4
    endloop.

    if okCnt is not initial.
        message s006  with okCnt 'lines' 'inserted to' 'LFEI'  into msg.
        grab_syMsg( msg ). "Save DB  - &1 &2 &3 &4
        endif.
    if mt_msgs is not initial.
        cl_rmsl_message=>display( mt_msgs ).
        endif.

    refresh mt_dataDB.  "cleanup for check( )
endmethod.
**********************************************************************
method persist_table.  ""by table
    try.
        insert LFEI from table @mt_dataDB.

        message i004 with sy-dbcnt 'table LFEI'.
*                       &1 lines saved to DB &2 &3 &4

    catch cx_root into data(cx).    "Save DB error - &1 &2 &3 &4
        message e005 with cx->get_text(  ).
    endtry.
endmethod.
**********************************************************************
method show_msgs.
    if lines( mt_msgs ) > 0.
        cl_rmsl_message=>display( mt_msgs ).
    else.
        message i000 with 'No messages found'.
    endif.
endmethod.
**********************************************************************
method get_mapping_cfg.
    check mt_mapCfg is initial.

    mt_mapCfg = value #(
        ( extNm = 'supplier'      intNm = 'lifnr' )
        ( extNm = 'material'      intNm = 'matnr' )
        ( extNm = 'plant'           intNm = 'werks' )
        ( extNm = 'prfZone'      intNm = 'gzolx' )
        ( extNm = 'declCode'   intNm = 'prene' )
        ( extNm = 'valid_to'      intNm = 'preng' )
    ).
endmethod.
**********************************************************************
method grab_syMsg.
    check sy-msgNo is not initial.

    append  initial line to mt_msgs assigning field-symbol(<bapiMsg>).
    if msgTxt is supplied.
        <bapiMsg>-message = msgTxt.
        endif.
    <bapiMsg>-type       = sy-msgty.
    <bapiMsg>-id           = sy-msgid.
    <bapiMsg>-number = sy-msgno.
    <bapiMsg>-message_v1 = sy-msgv1.
    <bapiMsg>-message_v2 = sy-msgv2.
    <bapiMsg>-message_v3 = sy-msgv3.
    <bapiMsg>-message_v4 = sy-msgv4.
endmethod.
**********************************************************************
endclass.
