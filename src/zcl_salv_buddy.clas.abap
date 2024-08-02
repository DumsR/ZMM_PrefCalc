*class zcl_salv_buddy definition
*  public
*  inheriting from cl_salv_controller
*  final
*  create public .
*
*  public section.
*  protected section.
*  private section.
*endclass.
*
*
*
* Developed by Lino Lopes (lino2112@gmail.com) - Version 2.0 - 20.03.2019
*
* This class is meant to be used with SALV objects to gain access to the GUI control that exists behind them.
* All standard SALV objects are descendants of the CL_SALV_MODEL_BASE class.
* Currently, there are the following SALV object classes:
*   CL_SALV_TABLE
*   CL_SALV_HIERSEQ_TABLE
*   CL_SALV_TREE
*
* This LCL_SALV_BUDDY class inherits from the abstract class CL_SAL_CONTROLLER because SALV objects have it as a FRIEND,
*   thus making us a FRIEND of SALV objects. That allows us to have access to ALL attributes and methods of
*   SALV objects, regardless of them being PUBLIC, PROTECTED or PRIVATE. Example: Attribute R_CONTROLLER.
* Since this class has only STATIC methods, there's no need to instantiate objects of its type, thus the CREATE PRIVATE.
* Also, I see no need to inherit from this class, so it is declared FINAL.
* Finally, this class declares interface IF_ALV_RM_GRID_FRIEND because CL_GUI_ALV_GRID is a FRIEND of this interface,
*   thus making us a FRIED of CL_GUI_ALV_GRID. That allows us to have access to ALL attributes and methods of
*   the CL_GUI_ALV_GRID object that exists behind all SALV objects.
*----------------------------------------------------------------------*
CLASS zcl_salv_buddy definition
    public
    inheriting from cl_salv_controller
*    inheriting from cl_salv_model_base
    final
    create public .

PUBLIC SECTION.
    INTERFACES: if_alv_rm_grid_friend.

*----------------------------------------------------------------------*
* GET_CONTROL_RTTI - Returns runtime type information for the control that is behind a SALV object.
*   Parameter E_ADAPTER_TYPE returns the adapter type of a SALV object.
*     Based on this information, method GET_CONTROL will return a different control in its returrning parameter R_CONTROL.
*     You can use this runtime type information to choose the right control object to supply to the returning parameter R_CONTROL of method GET_CONTROL.
*   Parameter E_CONTROL_RTTI returns a TYPE HANDLE that you can use to create an object compatible with the returning parameter R_CONTROL of method GET_CONTROL.
* Below there is a correspondence between the adapter type returned in parameter E_ADAPTER_TYPE and
* the type of the control expected in parameter R_CONTROL of method GET_CONTROL:
*
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_FULLSCREEN       CL_GUI_ALV_GRID
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_GRID             CL_GUI_ALV_GRID
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_HIERSEQ          nothing (null)
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_LIST             CL_SALV_TABLE
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_TREE             CL_SALV_GUI_TREE
*   IF_SALV_ADAPTER~C_ADAPTER_TYPE_APPEND           nothing (null)
*----------------------------------------------------------------------*
    CLASS-METHODS: get_control_rtti IMPORTING i_salv         TYPE REF TO cl_salv_model_base
                                    EXPORTING e_adapter_type TYPE salv_de_adapter_type
                                              e_control_rtti TYPE REF TO cl_abap_typedescr,

*----------------------------------------------------------------------*
* GET_CONTROL - Returns the control that is behind the SALV object.
*   MUST be called AFTER the DISPLAY method of the SALV object, because it's the DISPLAY method that actually creates the GUI control.
*   If you call method GET_CONTROL before calling the DISPLAY method of the SALV object, you'll get a null pointer in return.
*   See method GET_CONTROL_RTTI above for a correspondence between what you supply in paramter I_SALV and what you get back in parameter R_CONTROL.
*----------------------------------------------------------------------*
      get_control IMPORTING i_salv           TYPE REF TO cl_salv_model_base
                  RETURNING VALUE(r_control) TYPE REF TO object,

*----------------------------------------------------------------------*
* SET_EDITABLE - Enables OR disables editing on a CL_SALV_TABLE object.
*   Item 1) is *NOT* working... Yet to check why
*   1) If you supply both parameters I_ROW and I_COL and supply them NOT INITIAL,
*        you get that particular cell enabled or disabled for editing, depending on parameter I_EDITABLE.
*        For this to work, your data table MUST have a column of type LVC_T_STYL.
*   2) If you supply parameter I_ROW and supply it NOT INITIAL and
*        do not supply parameter I_COL or supply it INITIAL,
*        you get that entire row enabled or disabled for editing, depending on parameter I_EDITABLE.
*        For this to work, your data table MUST have a column of type LVC_T_STYL.
*   3) If you do not supply parameter I_ROW or supply it INITIAL and
*        supply parameter I_COL and supply it NOT INITIAL,
*        you get that entire column enabled or disabled for editing, depending on parameter I_EDITABLE.
*   4) If you do not supply nrither parameter I_ROW nor I_COL or supply both of them INITIAL,
*        you get all fields of the table enabled or disabled for editing, depending on parameter I_EDITABLE.
*   Parameter I_SALV_TABLE is the CL_SALV_TABLE object you want to enable or disable editing for.
*   Parameter I_EDITABLE should be ABAP_TRUE to enable editing or ABAP_FALSE to disable it.
*   Parameter I_REFRESH indicates whether you want the control to be refreshed or not. REFRESH in this context means: TO UPDATE THE SCREEN.
*             You'll only see the changes you've made using any of these methods AFTER you do a refresh on the CL_SALV_TABLE object.
*   NOTE: If you want field per field editing capabilities, you MUST make sure editing for the whole table is disabled.
*         The CL_SALV_TABLE is disabled for editing by default, so if you haven't enabled it, you can ignore this note.
*----------------------------------------------------------------------*
      set_editable IMPORTING VALUE(i_row)      TYPE i         OPTIONAL
                             VALUE(i_col)      TYPE csequence OPTIONAL
                             i_salv_table      TYPE REF TO cl_salv_table
                             VALUE(i_editable) TYPE abap_bool DEFAULT abap_true
                             VALUE(i_refresh)  TYPE abap_bool DEFAULT abap_true.

  PRIVATE SECTION.

*----------------------------------------------------------------------*
* GET_CONTROL_INTERNAL - It is the guts of method GET_CONTROL.
*   It does all the heavy lifting and method GET_CONTROL gets all the credits
*----------------------------------------------------------------------*
    CLASS-METHODS: get_control_internal IMPORTING i_salv         TYPE REF TO cl_salv_model_base
                                        EXPORTING e_adapter_type TYPE salv_de_adapter_type
                                                  e_control      TYPE REF TO object.

ENDCLASS.                    "lcl_salv_buddy DEFINITION

CLASS zcl_salv_buddy IMPLEMENTATION.

method get_control_internal.
    data:
        lo_controller                 TYPE REF TO cl_salv_controller_model
    ,   lo_adapter                     TYPE REF TO cl_salv_adapter
    .
    CHECK e_adapter_type IS REQUESTED OR
          e_control      IS REQUESTED.

    IF  e_adapter_type IS REQUESTED.
      CLEAR e_adapter_type.
    ENDIF.

    IF  e_control IS REQUESTED.
      CLEAR e_control.
    ENDIF.

    lo_controller = i_salv->r_controller.
    CHECK lo_controller IS BOUND.

    lo_adapter = lo_controller->r_adapter.
    CHECK lo_adapter IS BOUND.

    IF e_adapter_type IS REQUESTED.
      e_adapter_type = lo_adapter->type.
    ENDIF.

    CHECK e_control IS REQUESTED.
*  ------------------------------------------------------------------
    data:
        lo_fullscreen_adapter   TYPE REF TO cl_salv_fullscreen_adapter
    ,   lo_grid_adapter             TYPE REF TO cl_salv_grid_adapter
    ,   lo_grid_gui_adapt         TYPE REF TO cl_salv_gui_om_adpt_grid
    ,   lo_tree_adapter_base     TYPE REF TO cl_salv_tree_adapter_base
    ,   lo_table_display_adapter TYPE REF TO if_salv_table_display_adapter
    .
    CASE lo_adapter->type.
      WHEN lo_adapter->if_salv_adapter~c_adapter_type_fullscreen.
        lo_fullscreen_adapter ?= lo_adapter.
*        e_control = lo_fullscreen_adapter->get_grid( ).  " Warn !!!

      WHEN lo_adapter->if_salv_adapter~c_adapter_type_grid.
*        e_control = lo_grid_adapter->get_grid( ). " Warn !!!
*        if lo_adapter is_instance_of lo_grid_adapter  "ABAP 7.51
        case type of lo_adapter.
        when type cl_salv_grid_adapter.
            lo_grid_adapter ?= lo_adapter.
            e_control = lo_adapter->r_controller.
        when type cl_salv_gui_om_adpt_grid.
            lo_grid_gui_adapt ?= lo_adapter.
            e_control = lo_adapter->r_controller.
        endcase.

      WHEN lo_adapter->if_salv_adapter~c_adapter_type_hierseq.

      WHEN lo_adapter->if_salv_adapter~c_adapter_type_list.
        lo_table_display_adapter ?= lo_adapter.
*        e_control = lo_table_display_adapter->r_table. " Warn !!!

      WHEN lo_adapter->if_salv_adapter~c_adapter_type_tree.
        lo_tree_adapter_base ?= lo_adapter.
        e_control = lo_tree_adapter_base->r_tree.

      WHEN lo_adapter->if_salv_adapter~c_adapter_type_append.

    ENDCASE.

  ENDMETHOD.                    "get_control_internal

  METHOD get_control_rtti.

    DATA: lv_adapter_type TYPE salv_de_adapter_type,
          lo_control      TYPE REF TO object.

    CHECK e_adapter_type IS REQUESTED OR
          e_control_rtti IS REQUESTED.

    IF  e_adapter_type IS REQUESTED.
      CLEAR e_adapter_type.
    ENDIF.

    IF  e_control_rtti IS REQUESTED.
      CLEAR e_control_rtti.
    ENDIF.

    get_control_internal( EXPORTING i_salv = i_salv IMPORTING e_adapter_type = lv_adapter_type e_control = lo_control ).

    IF e_adapter_type IS REQUESTED.
      e_adapter_type = lv_adapter_type.
    ENDIF.

    IF e_control_rtti IS REQUESTED.
      e_control_rtti = cl_abap_typedescr=>describe_by_object_ref( lo_control ).
    ENDIF.

  ENDMETHOD.                    "get_control_rtti

  METHOD get_control.

    CHECK r_control IS REQUESTED.

    get_control_internal( EXPORTING i_salv = i_salv IMPORTING e_control = r_control ).

  ENDMETHOD.                    "get_control

  METHOD set_editable.
    CONSTANTS: lc_stable TYPE lvc_s_stbl VALUE 'XX'.

    DATA: lo_grid        TYPE REF TO cl_gui_alv_grid,
          lt_fieldcat    TYPE lvc_t_fcat,
          ls_layout      TYPE lvc_s_layo,
          lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
          lo_structdescr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE cl_abap_structdescr=>component_table,
          ls_styl        TYPE LINE OF lvc_t_styl.

    FIELD-SYMBOLS: <fs_fieldcat>   LIKE LINE OF lt_fieldcat,
                   <fs_t_outtab>   TYPE table,
                   <fs_outtab>     TYPE any,
                   <fs_components> LIKE LINE OF lt_components,
                   <fs_t_styl>     TYPE lvc_t_styl.
*   Warn!!! -----------------------------------------
*    data salv_mbase type ref to cl_salv_model_base.
*    salv_mbase = new #(  ).  "?= i_salv_table.
    data salv_omBase      type ref to cl_salv_model_base.
    data(salv_omIF) = i_salv_table->if_salv_gui_om_table_info~extended_grid_api(  ).
    salv_omBase ?= salv_omIF.

    lo_grid ?= get_control(  salv_omBase ).    "Warn!!!
    CHECK lo_grid IS BOUND.

    lo_grid->m_fcat_complete = abap_true.
    lo_grid->register_edit_event(
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2 ).
    lo_grid->register_edit_event(
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2 ).
    lo_grid->set_ready_for_input( 1 ).

    IF i_row IS SUPPLIED    AND
       i_row IS NOT INITIAL AND
       i_col IS SUPPLIED    AND
       i_col IS NOT INITIAL.
      lo_grid->get_frontend_layout( IMPORTING es_layout = ls_layout ).
      ASSIGN lo_grid->mt_outtab->* TO <fs_t_outtab>.
      lo_tabledescr ?= cl_abap_typedescr=>describe_by_data( <fs_t_outtab> ).
      lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
      lt_components = lo_structdescr->get_components( ).
      CLEAR ls_layout-stylefname.
      LOOP AT lt_components ASSIGNING <fs_components>.
        IF <fs_components>-type->get_relative_name( ) = 'LVC_T_STYL'.
          ls_layout-stylefname = <fs_components>-name.
          EXIT.
        ENDIF.
      ENDLOOP.
      CHECK ls_layout-stylefname IS NOT INITIAL.
      lo_grid->set_frontend_layout( EXPORTING is_layout = ls_layout ).
      READ TABLE <fs_t_outtab> ASSIGNING <fs_outtab> INDEX i_row.
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT ls_layout-stylefname OF STRUCTURE <fs_outtab> TO <fs_t_styl>.
      CHECK sy-subrc = 0.
      DELETE <fs_t_styl> WHERE fieldname = i_col.
      IF i_editable = abap_true.
        ls_styl-fieldname = i_col.
        ls_styl-style     = cl_gui_alv_grid=>mc_style_enabled.
        INSERT ls_styl INTO TABLE <fs_t_styl>.
      ENDIF.
    ELSEIF i_row IS SUPPLIED AND
           i_row IS NOT INITIAL.
      lo_grid->get_frontend_layout( IMPORTING es_layout = ls_layout ).
      ASSIGN lo_grid->mt_outtab->* TO <fs_t_outtab>.
      lo_tabledescr ?= cl_abap_typedescr=>describe_by_data( <fs_t_outtab> ).
      lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
      lt_components = lo_structdescr->get_components( ).
      CLEAR ls_layout-stylefname.
      LOOP AT lt_components ASSIGNING <fs_components>.
        IF <fs_components>-type->get_relative_name( ) = 'LVC_T_STYL'.
          ls_layout-stylefname = <fs_components>-name.
          EXIT.
        ENDIF.
      ENDLOOP.
      CHECK ls_layout-stylefname IS NOT INITIAL.
      lo_grid->set_frontend_layout( EXPORTING is_layout = ls_layout ).
      READ TABLE <fs_t_outtab> ASSIGNING <fs_outtab> INDEX i_row.
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT ls_layout-stylefname OF STRUCTURE <fs_outtab> TO <fs_t_styl>.
      CHECK sy-subrc = 0.
      REFRESH <fs_t_styl>.
      IF i_editable = abap_true.
        ls_styl-style = cl_gui_alv_grid=>mc_style_enabled.
        INSERT ls_styl INTO TABLE <fs_t_styl>.
      ENDIF.
    ELSEIF i_col IS SUPPLIED AND
           i_col IS NOT INITIAL.
      lo_grid->get_frontend_fieldcatalog( IMPORTING et_fieldcatalog = lt_fieldcat ).
      READ TABLE lt_fieldcat ASSIGNING <fs_fieldcat> WITH KEY fieldname = i_col.
      CHECK sy-subrc = 0.
      <fs_fieldcat>-edit = i_editable.
      lo_grid->set_frontend_fieldcatalog( lt_fieldcat ).
    ELSE.
      lo_grid->get_frontend_layout( IMPORTING es_layout = ls_layout ).
      ls_layout-edit = i_editable.
      lo_grid->set_frontend_layout( EXPORTING is_layout = ls_layout ).
    ENDIF.

    CHECK i_refresh = abap_true.
    lo_grid->refresh_table_display(
      EXPORTING
        is_stable      = lc_stable
        i_soft_refresh = abap_false
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

  ENDMETHOD.                    "set_editable

ENDCLASS.                    "lcl_salv_buddy IMPLEMENTATION
