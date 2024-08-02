*&---------------------------------------------------------------------*
*& Program ZEDITABLE_SALV - Version 14.06.2021
*& Author: Lino Lopes - CD TECNOLOGIA (lino2112@gmail.com)
*&---------------------------------------------------------------------*
*& Example of a SALV TABLE, fullscreen or in a container, with an editable field.
*& By clicking toolbar buttons "Open" and "Close" you toggle column JUPER between editable and non-editable.
*& To use it:
*&   1) In SE38, create a program of type INCLUDE named after ZCL_SALV_BUDDY and
*&      copy the contents of supplied file LCL_SALV_BUDDY_CLASS.txt to it;
*&   2) Also in SE38, create a program of type REPORT named ZEDITABLE_SALV and
*&      copy the contents of this file to it;
*&   3) In the program created on 2), create a screen named, for example, 0100 with a CONTAINER for the SALV table.
*&      Name this container SALV_CONTAINER or as you wish.
*&   4) Specify variable GV_OKCODE_0100 as the okcode for this screen;
*&   5) Create a STATUS_GUI named 0100, for example for screen 0100 with five buttons with
*&      user commands: BACK, EXIT, CANCEL as exit commands (E) and also OPEN and CLOSE as normal commands (space);
*&   6) In the screen 0100 PROCESS BEFORE OUTPUT section, include instruction:
*&        MODULE pbo_0100.
*&   7) In the screen 0100 PROCESS AFTER INPUT section, include instructions:
*&        MODULE at_exit_command_0100 AT EXIT-COMMAND.
*&        MODULE user_command_0100.
*&   8) Run the program. The fields you chose to be editable in module pbo_0100 should appear as so.
*&   9) If you ever need the ALV to be displayed in fullscreen mode, such as the results of a report:
*&        a) Comment all references to variable GO_CONTAINER;
*&        b) Uncomment in line R_CONTAINER = CL_GUI_CUSTOM_CONTAINER=>DEFAULT_SCREEN in method FACTORY call;
*&        c) Delete custom container named SALV_CONTAINER in screen 0100.
*&---------------------------------------------------------------------*
REPORT zsalv_editable
  message-id zmm_rep.

*include zedit_salv_top.
    types:
        begin of ty_line
    ,       molga TYPE t001p-molga
    ,       juper TYPE t001p-juper
    ,       style TYPE lvc_t_styl
    ,   end of ty_line
    ,    tty_data  type table of ty_line
            with non-unique key molga
    ."---------------------------------------
    data:
        gt_data           type tty_data
    ,   gv_okcode     type sy-ucomm
    ,   go_container type ref to cl_gui_custom_container
    ,   go_alv             type ref to cl_salv_table
    .

include zedit_salv_cls.
include zedit_salv_f01.

START-OF-SELECTION.
    perform fill_data.

end-of-selection.
*    perform create_alv.
    call screen '0100'.
