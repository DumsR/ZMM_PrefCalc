
*&---------------------------------------------------------------------*
*& Include zmm_pref_MAT_upl_data
*&---------------------------------------------------------------------*
**********************************************************************
class lcl_mat_data definition.
*    inheriting from cl_salv_model_base.
public section.
    types:
        begin of ty_data_int
        ,   material       type mape-matnr
        ,   plant             type mape-werks
        ,   prf_zone        type mape-gzolx
        ,   tarif_code     type marc-stawn
        ,   vend_status   type mape-prene
        ,   vend_valid_to type mape-preng
        ,   pref_status      type mape-prefe
        ,   pref_valid_to   type mape-preda
        ,   country            type t001w-land1
        ,   color_line  type c length 4  "Color line ALV_grid
        ,   color_cell  type lvc_t_scol   "Color cell ALV_grid
    ,   end of ty_data_int
    ,   begin of ty_data_db
        ,   matnr           type mape-matnr
        ,   werks            type mape-werks
        ,   gzolx             type mape-gzolx
        ,   stawn            type marc-stawn
        ,   prene             type mape-prene
        ,   preng             type mape-preng
        ,   prefe               type mape-prefe
        ,   preda              type mape-preda
        ,   land1              type t001w-land1
    ,   end of  ty_data_db
    .constants:
        yes       type abap_bool value abap_true
    ,   no        type abap_bool value abap_false
    ,   alv_cls type string value  'LCL_SALV'
    . "-----------------------------------------------
    data:
        mv_filepath      type string
    ,   mt_csv              type table of string
    ,   mt_dataINT      type standard  table of ty_data_int
    ,   mt_dataDB       type sorted table of ty_data_db  "MAPE+Marc+T001W
                                   with unique key matnr werks gzolx
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
               iv_matnr        type lfei-matnr optional
               iv_plant          type lfei-werks optional
               iv_prf_zone     type lfei-gzolx optional
               iv_vendStat     type lfei-prene optional
               iv_vend_valid  type lfei-preng
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
    ,   tarifCodes   type standard table of T604
    ,   vendStati     type standard table of DD07V
    ,   prefStati       type standard table of DD07V
    .methods:
        load_zoneValues
    ,   load_vendStati
    ,   load_prefStati
    ,   load_tarifCodes
    . "-----------------------------------------------
private section.
    methods:
        convert_date_in
            importing         iv_date  type string
            returning value(rv_date) type dats
    ,   map_line2db
            importing           is_int like line of mt_dataINT
            returning value(es_DB) like line of mt_dataDB
    ,   check_key
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_plantData      "MARC entry exist
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_prefZone
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_tarifCode
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_vendStatus
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   check_prefStatus
            importing  is_DB like line of mt_dataDB
            returning value(ok) like yes
    ,   get_country4plants
    . "-----------------------------------------------
endclass.        "definition
class lcl_mat_data implementation.
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
        clear dataLn.                                 "matnr in MARA:  18c
        dataln-material = |{ itStrg[ 1 ] width = 18 alpha = IN }|.
        dataln-plant                = itStrg[ 2 ].
        dataln-prf_zone          = itStrg[ 3 ].
        dataln-tarif_code        = itStrg[ 4 ].
        dataln-vend_status     = itStrg[ 5 ].
        dataLn-vend_valid_to = convert_date_IN( itStrg[ 6 ] ).
        dataln-pref_status       = itStrg[ 7 ].
        dataLn-pref_valid_to   = convert_date_IN( itStrg[ 8 ] ).

        append dataln to mt_dataINT.
    endloop.

    get_country4plants( ).
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
method load_fromDB.
    refresh mt_dataDB.

    data whereClause type string.
    if iv_matnr is supplied and iv_matnr is not initial.
        data(lv_matnr) = |{ iv_matnr  width = 18 alpha = IN }|.
        whereClause = |mp~matnr = @lv_matnr and|.
        endif.
    if iv_plant is supplied and iv_plant is not initial.
        whereClause = |{ whereClause } mp~werks = @iv_plant and|.
        endif.
    if iv_prf_zone is supplied and iv_prf_zone is not initial.
        whereClause = |{ whereClause } mp~gzolx = @iv_prf_zone and|.
        endif.
    if iv_vendStat is supplied and iv_vendStat is not initial.
        whereClause = |{ whereClause } mp~prene = @iv_vendStat and|.
        endif.
*    if iv_vend_valid is supplied and iv_vend_valid is not initial.
        whereClause = |{ whereClause } mp~preng >= @iv_vend_valid|.
*        endif.

    select
        from MAPE as mp   "mat>export info
        inner join T001W  as  plant  "plnt
            on mp~werks  = plant~werks
        inner join MARC    "matnr>plant info
            on mp~matnr = marc~matnr
            and mp~werks = marc~werks
        fields mp~matnr, mp~werks, mp~gzolx, marc~stawn,
            mp~prene, mp~preng, mp~prefe, mp~preda, plant~land1
        where    (whereClause)    "mp~matnr >= @lv_matnr
        into table @mt_dataDB.
endmethod.
**********************************************************************
method map_db2data.
    check mt_dataDB is not initial.
    refresh mt_dataINT.

    loop at mt_dataDB assigning field-symbol(<dbLn>).
        append initial line to mt_dataINT
                   assigning field-symbol(<dataLn>).
        <dataLn>-material     =  "matnr in MARA:  18char
                            |{ <dbLn>-matnr   width = 18 alpha = IN }|.
        <dataLn>-plant             = <dbLn>-werks.
        <dataLn>-prf_zone        = <dbLn>-gzolx.
        <dataLn>-tarif_code       = <dbLn>-stawn.
        <dataLn>-vend_status    = <dbLn>-prene.
        <dataLn>-vend_valid_to = <dbLn>-preng.
        <dataLn>-pref_status       = <dbLn>-prefe.
        <dataLn>-pref_valid_to    = <dbLn>-preda.
    endloop.
    get_country4plants( ).

    refresh mt_dataDB.  "cleanup for persist( ).
endmethod.
**********************************************************************
method map_line2db.
    es_DB-matnr  = |{ is_int-material width = 18 alpha = IN }|.
    es_DB-werks  =  is_int-plant.       "matnr in MARA:  18char
    es_DB-gzolx   = is_int-prf_zone.
    es_DB-stawn  = is_int-tarif_code.
    es_DB-prene  = is_int-vend_status.
    es_DB-preng  = is_int-vend_valid_to.
    es_DB-prefe   = is_int-pref_status.
    es_DB-preda  = is_int-pref_valid_to.

*    call function 'CONVERSION_EXIT_ALPHA_INPUT'
*        exporting  input = is_int-material
*        importing output = es_DB-matnr.   "
                             "0000000000000000000000000000000000000001
endmethod.
**********************************************************************
method check_key.
    if                                                                           "empty key
           (      is_DB-matnr is initial
           and is_DB-werks  is initial   and is_DB-gzolx is initial  )

    OR  line_exists(  mt_dataDB[                             "Duplicate?
                matnr = is_DB-matnr
                werks  = is_DB-werks   gzolx = is_DB-gzolx   ]  ).

*     Duplicate KEY error  ----------------------------------------
        ok = no.
        call method mo_alv->('SET_COLOR_KEY')
                exporting row_id = act_rowID.
    else.
        ok = yes.
    endif.
endmethod.
**********************************************************************
method check_plantData.
    select count( * ) from MARC
        where matnr = @is_DB-matnr
            and werks  = @is_DB-werks
        into @data(cnt).

    if cnt > 0.  "plantData -- exist
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
            exporting row_id = act_rowID  col_nm = 'PRF_ZONE'.
        message e009 with act_rowID is_DB-gzolx
            'Pref.Zone ' '(GZOLX)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method load_tarifCodes.
    check tarifCodes is initial.

    select * from T604 into table @tarifCodes.
endmethod.
**********************************************************************
method check_tarifCode.
    load_tarifCodes(  ).

    read table tarifCodes transporting no fields
        with key stawn = is_DB-stawn        land1 = is_DB-land1.

    if sy-subrc is initial.  "domValue found
        ok = yes.
    else.
        ok = no.
        call method mo_alv->('SET_COLOR_TARIFCODE')
            exporting row_id = act_rowID.
        message e009 with act_rowID is_DB-stawn
            'Tarif Code' '(T604)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method get_country4plants.
  types: begin of ty_werks
  ,     werks  type T001W-werks
  ,     land1  type T001W-land1
  ,     end of ty_werks
  .data:
    ln_werks type ty_werks
  , lt_werks type sorted table of ty_werks
            with unique key werks.
  field-symbols:
    <intLn> like line of mt_dataINT.

  select werks land1 from T001W
    into corresponding fields of table lt_werks
    for all entries in mt_dataINT
    where werks = mt_dataINT-plant.

  loop at mt_dataINT assigning <intLn>.
    read table lt_werks into ln_werks
      with key werks = <intLn>-plant.
    check sy-subrc is initial.

    <intLn>-country = ln_werks-land1.
  endloop.
endmethod.
**********************************************************************
method load_vendStati.
    check vendStati is initial.

    call function 'FM_DOMAINVALUE_CHECK'
        exporting i_domname = 'PRENE'
        tables        t_dd07v   = vendStati.
endmethod.
**********************************************************************
method check_vendStatus.
    load_vendStati(  ).

    read table vendStati transporting no fields
        with key domValue_L = is_DB-prene.

    if sy-subrc is initial.  "domValue found
        ok = yes.
    else.
        ok = no.
        call method mo_alv->('SET_COLOR_CELL')
            exporting row_id = act_rowID  col_Nm = 'VEND_STATUS'.
        message e009 with act_rowID is_DB-prene
            'Vend.Status ' '(PRENE)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method load_prefStati.
    check prefStati is initial.

    call function 'FM_DOMAINVALUE_CHECK'
        exporting i_domname = 'PREFE'  "pref.Status
        tables        t_dd07v   = prefStati.
endmethod.
**********************************************************************
method check_prefStatus.
    load_prefStati(  ).

    read table prefStati transporting no fields
        with key domValue_L = is_DB-prefe.  "pref.Status

    if sy-subrc is initial.  "domValue found
        ok = yes.
    else.
        ok = no.
        call method mo_alv->('SET_COLOR_CELL')
            exporting row_id = act_rowID  col_Nm = 'PREF_STATUS'.
        message e009 with act_rowID is_DB-prefe
            'pref.Status' '(PREFE)' into data(msg).
        grab_symsg( msg ).
    endif.
endmethod.
**********************************************************************
method map_data2db.
    data dbLn like line of mt_dataDB.
    refresh: mt_dataDB, mt_msgs.
    call method mo_alv->('RESET_COLOR').
*    get_country4plants( ).

    loop at mt_dataINT assigning field-symbol(<intLn>).
        act_rowID = sy-tabix.
        dbLn = map_line2db( <intLn> ).

        data(key_ok)   = check_key( dbLn  ).
        data(plant_ok)  = check_plantData( dbLn  ).
        data(prfZone_ok) = check_prefZone( dbLn  ).
        data(tarifCd_ok)    = yes.   "check_tarifCode( dbLn  ).   "T604 empty!
        data(vendStat_ok) = check_vendStatus( dbLn  ).
        data(prefStat_ok)   = check_prefStatus( dbLn  ).

*      all ok ? -------------------------------------
        check key_ok         = yes     and plant_ok      = yes
            and prfZone_ok = yes     and tarifCd_ok   = yes
            and vendStat_ok = yes    and prefStat_ok  = yes.

        insert dbLn into table mt_dataDB.
    endloop.

    if lines( mt_msgs  ) > 0.
        cl_rmsl_message=>display( mt_msgs ).
        refresh mt_dataDB.
        endif.
endmethod.
**********************************************************************
method persist_lines.  "line by line
    check mt_dataDB is not initial.
    refresh mt_msgs.
    data:
        rc            like sy-subrc
    ,   action     type string
    ,   msg        type string
    ,   okCnt     like sy-dbcnt
    ,   ln_mape  type MAPE
    .
    loop at mt_dataDB assigning field-symbol(<ln>).
        data(info) = |{ <ln>-matnr }-{ <ln>-werks }-{ <ln>-gzolx }|.

        move-corresponding <ln> to ln_mape.
        select count( * ) from MAPE into rc
            where matnr = <ln>-matnr
                and werks = <ln>-werks.
        if rc > 0.   "entry exist in DB
            action =  'update line'.
            update MAPE from ln_mape.
        else.
            action =  'insert line'.
            insert MAPE from ln_mape.
            endif.
        if sy-subrc is  initial.
            okCnt += 1.
            message s006  with okCnt action info into msg.
            grab_syMsg( msg ). "Save DB  - &1 &2 &3 &4
        else.                                           " modify & insert FAIL !!!
            message e005  with sy-dbcnt 'MAPE' action info into msg.
            grab_syMsg( msg ). "Save DB error - &1 &2 &3 &4
            endif.

        update MARC from @(
            value #( matnr = <ln>-matnr   werks = <ln>-werks   "key
                           stawn = <ln>-stawn   )  ).                       "upd.field
        if sy-subrc is not initial.
            action = 'update Tarif Code (stawn)'.
            message e005  with sy-dbcnt 'MARC' action info into msg.
            grab_syMsg( msg ). "Save DB error - &1 &2 &3 &4
            endif.
    endloop.

    if okCnt is not initial.
        message s006  with okCnt  'lines inserted to MAPE' into msg.
        grab_syMsg( msg ). "Save DB  - &1 &2 &3 &4
        endif.
    if mt_msgs is not initial.
        cl_rmsl_message=>display( mt_msgs ).
        endif.

    refresh mt_dataDB.  "cleanup for check( )
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
