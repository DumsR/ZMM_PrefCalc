*&---------------------------------------------------------------------*
*& Include zedit_salv_cls
*&---------------------------------------------------------------------*
CLASS lcl_alv_event_handler DEFINITION.
  PUBLIC SECTION.
    class-methods:
        handle_data_changed for event data_changed of cl_gui_alv_grid
            importing   e_ucomm     er_data_changed sender.

ENDCLASS.
CLASS lcl_alv_event_handler IMPLEMENTATION.
**********************************************************************
METHOD handle_data_changed.
    data lv_juper type ty_line-juper.

    read table er_data_changed->mt_mod_cells index 1
        assigning field-symbol(<cell_info>).
    check sy-subrc = 0.

    er_data_changed->get_cell_value(
    exporting
        i_row_id     = <cell_info>-row_id
        i_tabix         = <cell_info>-tabix
        i_fieldname = <cell_info>-fieldname
    importing
        e_value         = lv_juper ).

    read table gt_data index <cell_info>-row_id
        assigning field-symbol(<cell>).
    check sy-subrc = 0.

    data(msg) = |Data has changed! Old value = { <cell>-juper }, |.
    message w000 with msg lv_juper.
ENDMETHOD.
**********************************************************************
ENDCLASS.
