!NUMBER_OF_COMMANDS = 100
!COMMAND_ID = -1

!CM_HEADER_ID = 0

!LIST_ITEM = -1

!LAST_HEADER_SIZE = 0
!MENU_ITEM = 0
!LAST_HEADER = "OOPS"

!CM_LAST_NAMES_PTR = ""

!NOPARAMS #= 0
!HASADDR #= 3
!HASPTEXT #= 0
!HASFUNC #= 3
!HASPTR #= 2
!HASID #= 1
!HASINDEX #= 1
!HASNUMFIELD #= 3
!HAS16NUMFIELD #= 6
!HASMAX #= 1
!HASMIN #= 1
!HASLIST #= 3





;===================================================================================================

macro cmstr(text)
------------
	db "<text>", $00
endmacro

macro ReusableText(lbl)
pushpc
	org ------------
	#<lbl>:
pullpc
endmacro

;===================================================================================================

this = 0
macro menu_header(name)
	!MENU_ITEM #= 0
.name_pointers
#CM_MENU_!{CM_HEADER_ID}:
	dw .header_text
	fillword 0 : fill 24*2
	dw 0

.header_text
	%cmstr("<name>")

	!CM_LAST_NAMES_PTR := CM_MENU_!{CM_HEADER_ID}

	!CM_HEADER_ID #= !CM_HEADER_ID+1
	!LAST_HEADER = "<name>"

endmacro

macro add_self()
	%add_menu_item(++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
endmacro

macro add_menu_item(label)
	!MENU_ITEM #= !MENU_ITEM+1

	if !MENU_ITEM > 250
		error "!LAST_HEADER has too many items\! !MENU_ITEM"
	endif

	pushpc
	org !{CM_LAST_NAMES_PTR}+(!MENU_ITEM*2) : dw <label>
	pullpc

CM_ITEM_!{CM_HEADER_ID}_!{MENU_ITEM}:

endmacro

;===================================================================================================

!LIST_HEADER_ID = 0
!LAST_LIST_SIZE = 0
macro list_header(size)
.LIST_HEADER!LIST_HEADER_ID
	!LIST_ITEM = 0
..list_table
	fillword $0000 : fill <size>*2

	!LIST_HEADER_ID #= !LIST_HEADER_ID+1
	!LAST_LIST_SIZE = <size>
endmacro

macro add_list_item(l)
	!LIST_ITEM #= !LIST_ITEM+1
	if !LIST_ITEM > !LAST_LIST_SIZE
		error "Too many items\! !LIST_ITEM > !LAST_LIST_SIZE"
	endif

	pushpc
	org ..list_table-2+(!LIST_ITEM*2) : dw <l>
	pullpc
endmacro

macro list_item(text)
	%add_list_item(++++)

++++
	%cmstr("<text>")
endmacro

;---------------------------------------------------------------------------------------------------

macro toggletext(offtext, ontext)
	%list_header(2)
		%list_item("<offtext>")
		%list_item("<ontext>")
endmacro

;===================================================================================================
; Each command is defined here so that everything is organized automatically
; ADDRESS_TEXT should always follow ADDRESS
; Except for NUMFIELD ranges and CHOICE list size
; FUNC should always be last
;===================================================================================================

ActionLengths:
	fillbyte 0 : fill !NUMBER_OF_COMMANDS

ActionIcons:
	fillbyte 0 : fill !NUMBER_OF_COMMANDS

ActionDoRoutines:
	fillword ACTION_EXIT : fill !NUMBER_OF_COMMANDS*2

ActionDrawRoutines:
	fillword ACTION_EXIT-1 : fill !NUMBER_OF_COMMANDS*2

macro MenuAction(name, icon, args)
	!COMMAND_ID #= !COMMAND_ID+1
	!CM_<name> := !COMMAND_ID

	if greaterequal(!COMMAND_ID,!NUMBER_OF_COMMANDS)
		error "Too many commands\! !COMMAND_ID >= !NUMBER_OF_COMMANDS"
	endif

	org ActionLengths+!COMMAND_ID : db 1+<args> ; 1 for ID
	org ActionIcons+!COMMAND_ID : db <icon>
	org ActionDoRoutines+(2*!COMMAND_ID) : dw CMDO_<name>
	org ActionDrawRoutines+(2*!COMMAND_ID) : dw CMDRAW_<name>
endmacro

pushpc

;---------------------------------------------------------------------------------------------------
%MenuAction("HEADER", $3F, -1)

;---------------------------------------------------------------------------------------------------
; leave UW after header, so it can go right to preset type
%MenuAction("PRESET_UW", $09, !HASPTR)
macro preset_UW(name, category, segment, scene)
	%preset("UW", "<name>", "<category>", "<segment>", "<scene>")
endmacro

%MenuAction("PRESET_OW", $09, !HASPTR)
macro preset_OW(name, category, segment, scene)
	%preset("OW", "<name>", "<category>", "<segment>", "<scene>")
endmacro

macro preset(type, name, category, segment, scene)
#presetmenu_<category>_<segment>_<scene>:
	%add_self()
	db !CM_PRESET_<type>
	dw presetdata_<category>_<segment>_<scene>
	%cmstr("<name>")

#presetdata_<category>_<segment>_<scene>:
	dw presetpersistent_<category>_<segment>_<scene>_end
	dw presetSRAM_<category>_<segment>_<scene>_end
endmacro

macro existing_preset(category, segment, scene)
	%add_menu_item(presetmenu_<category>_<segment>_<scene>)
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("LITESTATE", $09, !HASID)
macro litestate(name, id)
	%add_self()
	db !CM_LITESTATE
	db <id>
	%cmstr("<name>")
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("LABEL", $3F, !NOPARAMS)
macro label(name)
	%add_self()
	db !CM_LABEL
	%cmstr("<name>")
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("TOGGLE", $06, !HASADDR)
macro toggle(name, addr)
	%add_self()
	db !CM_TOGGLE
	dl <addr>
	%cmstr("<name>")
endmacro

%MenuAction("TOGGLE_FUNC", $06, !HASADDR+!HASFUNC)
macro toggle_func(name, addr, pfunc)
	%add_self()
	db !CM_TOGGLE_FUNC
	dl <addr>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")

#?here:
endmacro

%MenuAction("TOGGLE_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
macro toggle_customtext(name, addr, ptext)
	%add_self()
	db !CM_TOGGLE_CUSTOMTEXT
	dl <addr>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

%MenuAction("TOGGLE_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
macro toggle_func_customtext(name, addr, pfunc, ptext)
	%add_self()
	db !CM_TOGGLE_FUNC_CUSTOMTEXT
	dl <addr>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:

endmacro

macro toggle_func_customtext_here(name, addr, pfunc)
	%toggle_func_customtext(<name>, <addr>, <pfunc>, this)
	%list_header(2)
endmacro

%MenuAction("TOGGLE_ROOMFLAG", $06, !HASINDEX)
macro toggle_roomflag(name, bit)
	%add_self()
	db !CM_TOGGLE_ROOMFLAG
	db <bit>
	%cmstr("<name>")

#?here:
endmacro

;---------------------------------------------------------------------------------------------------
macro toggle_onoff(name, addr)
;	%toggle_customtext(<name>, <addr>, CMDRAW_ONOFF)
	%toggle(<name>, <addr>)
endmacro

macro toggle_func_onoff(name, addr, pfunc)
;	%toggle_func_customtext(<name>, <addr>, <pfunc>, CMDRAW_ONOFF)
	%toggle_func(<name>, <addr>, <pfunc>)
endmacro

macro toggle_func_onoff_here(name, addr)
;	%toggle_func_customtext(<name>, <addr>, ?here, CMDRAW_ONOFF)
	%toggle_func(<name>, <addr>, ?here)
#?here:
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("SUBMENU", $04, !HASADDR)
macro submenu(name, addr)
	%add_self()
	db !CM_SUBMENU
	dl <addr>
	%cmstr("<name>")
endmacro

%MenuAction("SUBMENU_VARIABLE", $04, !HASADDR)
macro submenu_variable(name, addr)
	%add_self()
	db !CM_SUBMENU_VARIABLE
	dl select(equal(<addr>,this), ?here, <addr>)
	%cmstr("<name>")

#?here:
endmacro

;---------------------------------------------------------------------------------------------------

%MenuAction("NUMFIELD", $08, !HASADDR+!HASNUMFIELD)
macro numfield(name, addr, start, end, increment)
	%add_self()
	db !CM_NUMFIELD
	dl <addr>
	db <start>, <end>, <increment>
	%cmstr("<name>")
endmacro

%MenuAction("NUMFIELD_HEX", $08, !HASADDR+!HASNUMFIELD)
macro numfield_hex(name, addr, start, end, increment)
	%add_self()
	db !CM_NUMFIELD_HEX
	dl <addr>
	db <start>, <end>, <increment>
	%cmstr("<name>")
endmacro

%MenuAction("NUMFIELD_HEX_UPDATEWHOLEMENU", $08, !HASADDR+!HASNUMFIELD)
macro numfield_hex_update(name, addr, start, end, increment)
	%add_self()
	db !CM_NUMFIELD_HEX_UPDATEWHOLEMENU
	dl <addr>
	db <start>, <end>, <increment>
	%cmstr("<name>")
endmacro

%MenuAction("NUMFIELD16", $08, !HASADDR+!HAS16NUMFIELD)
macro numfield16(name, addr, start, end, increment)
	%add_self()
	db !CM_NUMFIELD16
	dl <addr>
	dw <start>, <end>, <increment>
	%cmstr("<name>")
endmacro

%MenuAction("NUMFIELD_2DIGITS", $08, !HASADDR+!HASNUMFIELD)
macro numfield_2digits(name, addr, start, end, increment)
	%add_self()
	db !CM_NUMFIELD_2DIGITS
	dl <addr>
	db <start>, <end>, <increment>
	%cmstr("<name>")
endmacro

%MenuAction("NUMFIELD_FUNC", $08, !HASADDR+!HASNUMFIELD+!HASFUNC)
macro numfield_func(name, addr, start, end, increment, pfunc)
	%add_self()
	db !CM_NUMFIELD_FUNC
	dl <addr>
	db <start>, <end>, <increment>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")
#?here:
endmacro

%MenuAction("NUMFIELD_FUNC_HEX", $08, !HASADDR+!HASNUMFIELD+!HASFUNC)
macro numfield_func_hex(name, addr, start, end, increment, pfunc)
	%add_self()
	db !CM_NUMFIELD_FUNC_HEX
	dl <addr>
	db <start>, <end>, <increment>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")
#?here:
endmacro

%MenuAction("NUMFIELD_FUNC_PRGTEXT", $08, !HASADDR+!HASNUMFIELD+!HASFUNC+!HASPTEXT)
macro numfield_func_prgtext(name, addr, start, end, increment, pfunc, ptext)
	%add_self()
	db !CM_NUMFIELD_FUNC_PRGTEXT
	dl <addr>
	db <start>, <end>, <increment>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")
	dl <ptext>

#?here:
endmacro

%MenuAction("NUMFIELD16_FUNC", $08, !HASADDR+!HAS16NUMFIELD+!HASFUNC+!HASPTEXT)
macro numfield16_func(name, addr, start, end, increment, pfunc)
	%add_self()
	db !CM_NUMFIELD16_FUNC
	dl <addr>
	dw <start>, <end>, <increment>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")
#?here:
endmacro

%MenuAction("NUMFIELD_PRGTEXT", $08, !HASADDR+!HASNUMFIELD+!HASPTEXT)
macro numfield_prgtext(name, addr, start, end, increment, ptext)
	%add_self()
	db !CM_NUMFIELD_PRGTEXT
	dl <addr>
	db <start>, <end>, <increment>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

%MenuAction("NUMFIELD_CAPACITY", $08, !HASADDR)
macro numfield_capacity(name, addr)
	%add_self()
	db !CM_NUMFIELD_CAPACITY
	dl <addr>
	%cmstr("<name>")

#?here:
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("TOGGLEBIT0", $06, !HASADDR)
%MenuAction("TOGGLEBIT1", $06, !HASADDR)
%MenuAction("TOGGLEBIT2", $06, !HASADDR)
%MenuAction("TOGGLEBIT3", $06, !HASADDR)
%MenuAction("TOGGLEBIT4", $06, !HASADDR)
%MenuAction("TOGGLEBIT5", $06, !HASADDR)
%MenuAction("TOGGLEBIT6", $06, !HASADDR)
%MenuAction("TOGGLEBIT7", $06, !HASADDR)
macro ___togglebit(name, addr, bitx)
	%add_self()
	db !CM_TOGGLEBIT<bitx>
	dl <addr>
	%cmstr("<name>")
endmacro

macro togglebit0(name, addr)
	%___togglebit(<name>, <addr>, 0)
endmacro
macro togglebit1(name, addr)
	%___togglebit(<name>, <addr>, 1)
endmacro
macro togglebit2(name, addr)
	%___togglebit(<name>, <addr>, 2)
endmacro
macro togglebit3(name, addr)
	%___togglebit(<name>, <addr>, 3)
endmacro
macro togglebit4(name, addr)
	%___togglebit(<name>, <addr>, 4)
endmacro
macro togglebit5(name, addr)
	%___togglebit(<name>, <addr>, 5)
endmacro
macro togglebit6(name, addr)
	%___togglebit(<name>, <addr>, 6)
endmacro
macro togglebit7(name, addr)
	%___togglebit(<name>, <addr>, 7)
endmacro


%MenuAction("TOGGLEBIT0_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT1_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT2_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT3_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT4_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT5_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT6_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
%MenuAction("TOGGLEBIT7_CUSTOMTEXT", $06, !HASADDR+!HASPTEXT)
macro ___togglebit_customtext(name, addr, bitx, ptext)
	%add_self()
	db !CM_TOGGLEBIT<bitx>_CUSTOMTEXT
	dl <addr>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

macro togglebit0_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 0, <ptext>)
endmacro
macro togglebit1_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 1, <ptext>)
endmacro
macro togglebit2_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 2, <ptext>)
endmacro
macro togglebit3_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 3, <ptext>)
endmacro
macro togglebit4_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 4, <ptext>)
endmacro
macro togglebit5_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 5, <ptext>)
endmacro
macro togglebit6_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 6, <ptext>)
endmacro
macro togglebit7_customtext(name, addr, ptext)
	%___togglebit_customtext(<name>, <addr>, 7, <ptext>)
endmacro

%MenuAction("TOGGLEBIT0_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT1_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT2_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT3_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT4_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT5_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT6_FUNC", $06, !HASADDR+!HASFUNC)
%MenuAction("TOGGLEBIT7_FUNC", $06, !HASADDR+!HASFUNC)
macro ___togglebit_func(name, addr, bitx, pfunc)
	%add_self()
	db !CM_TOGGLEBIT<bitx>_FUNC
	dl <addr>
	dl select(equal(<pfunc>,this), ?here, <pfunc>)
	%cmstr("<name>")

#?here:
endmacro

macro togglebit0_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 0, <pfunc>)
endmacro
macro togglebit1_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 1, <pfunc>)
endmacro
macro togglebit2_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 2, <pfunc>)
endmacro
macro togglebit3_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 3, <pfunc>)
endmacro
macro togglebit4_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 4, <pfunc>)
endmacro
macro togglebit5_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 5, <pfunc>)
endmacro
macro togglebit6_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 6, <pfunc>)
endmacro
macro togglebit7_func(name, addr, pfunc)
	%___togglebit_func(<name>, <addr>, 7, <pfunc>)
endmacro

%MenuAction("TOGGLEBIT0_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT1_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT2_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT3_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT4_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT5_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT6_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
%MenuAction("TOGGLEBIT7_FUNC_CUSTOMTEXT", $06, !HASADDR+!HASFUNC+!HASPTEXT)
macro ___togglebit_func_customtext(name, addr, bitx, pfunc, ptext)
	%add_self()
	db !CM_TOGGLEBIT<bitx>_FUNC_CUSTOMTEXT
	dl <addr>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

macro togglebit0_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 0, <pfunc>, <ptext>)
endmacro
macro togglebit1_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 1, <pfunc>, <ptext>)
endmacro
macro togglebit2_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 2, <pfunc>, <ptext>)
endmacro
macro togglebit3_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 3, <pfunc>, <ptext>)
endmacro
macro togglebit4_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 4, <pfunc>, <ptext>)
endmacro
macro togglebit5_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 5, <pfunc>, <ptext>)
endmacro
macro togglebit6_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 6, <pfunc>, <ptext>)
endmacro
macro togglebit7_func_customtext(name, addr, pfunc, ptext)
	%___togglebit_func_customtext(<name>, <addr>, 7, <pfunc>, <ptext>)
endmacro




;---------------------------------------------------------------------------------------------------
%MenuAction("FUNC", $05, !HASFUNC)
macro func(name, addr)
	%add_self()
	db !CM_FUNC
	dl select(equal(<addr>,this), ?here, <addr>)
	%cmstr("<name>")

#?here:
endmacro

; this one is a bit more special and does some register fixing before going
%MenuAction("FUNC_FILTERED", $05, !HASFUNC)
macro func_filtered(name, addr)
	%add_self()
	db !CM_FUNC_FILTERED
	dl select(equal(<addr>,this), ?here, <addr>)
	%cmstr("<name>")

#?here:
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("CTRL_SHORTCUT", $0A, !HASADDR)
macro ctrl_shortcut(name, addr)
	%add_self()
	db !CM_CTRL_SHORTCUT
	dl <addr>
	%cmstr("<name>")
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("CHOICE", $07, !HASADDR+!HASMAX+!HASLIST)
macro choice(name, addr, max, listptr)
	%add_self()
	db !CM_CHOICE
	dl <addr>
	db <max>
	dl select(equal(<listptr>,this), ?here, <listptr>)
	%cmstr("<name>")

#?here:
endmacro

macro choice_here(name, addr, max)
	%choice(<name>, <addr>, <max>, this)
	%list_header(<max>)
endmacro

%MenuAction("CHOICE_PRGTEXT", $07, !HASADDR+!HASMAX+!HASPTEXT)
macro choice_prgtext(name, addr, max, ptext)
	%add_self()
	db !CM_CHOICE_PRGTEXT
	dl <addr>
	db <max>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("CHOICE_FUNC", $07, !HASADDR+!HASMAX+!HASLIST+!HASFUNC)
macro choice_func(name, addr, max, pfunc, listptr)
	%add_self()
	db !CM_CHOICE_FUNC
	dl <addr>
	db <max>
	dl select(equal(<listptr>,this), ?here, <listptr>)
	dl <pfunc>
	%cmstr("<name>")

#?here:
endmacro

macro choice_func_here(name, addr, max, pfunc)
	%choice_func(<name>, <addr>, <max>, <pfunc>, this)
	%list_header(<max>)
endmacro

%MenuAction("CHOICE_FUNC_FILTERED", $07, !HASADDR+!HASMAX+!HASLIST+!HASFUNC)
macro choice_func_filtered(name, addr, max, pfunc, listptr)
	%add_self()
	db !CM_CHOICE_FUNC_FILTERED
	dl <addr>
	db <max>
	dl select(equal(<listptr>,this), ?here, <listptr>)
	dl <pfunc>
	%cmstr("<name>")

#?here:
endmacro

macro choice_func_filtered_here(name, addr, max, pfunc)
	%choice_func_filtered(<name>, <addr>, <max>, <pfunc>, this)
	%list_header(<max>)
endmacro

%MenuAction("CHOICE_FUNC_PRGTEXT", $07, !HASADDR+!HASMAX+!HASPTEXT+!HASFUNC)
macro choice_func_prgtext(name, addr, max, pfunc, ptext)
	%add_self()
	db !CM_CHOICE_FUNC_PRGTEXT
	dl <addr>
	db <max>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

%MenuAction("CHOICE_FUNC_FILTERED_PRGTEXT", $07, !HASADDR+!HASMAX+!HASPTEXT+!HASFUNC)
macro choice_func_filtered_prgtext(name, addr,  max, pfunc, ptext)
	%add_self()
	db !CM_CHOICE_FUNC_FILTERED_PRGTEXT
	dl <addr>
	db <max>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

%MenuAction("CHOICEPICK", $07, !HASADDR+!HASMAX+!HASLIST+!HASFUNC)
macro choicepick(name, addr, max, pfunc, listptr)
	%add_self()
	db !CM_CHOICEPICK
	dl <addr>
	db <max>
	dl select(equal(<listptr>,this), ?here, <listptr>)
	dl <pfunc>
	%cmstr("<name>")

#?here:
endmacro

%MenuAction("CHOICEPICK_PRGTEXT", $07, !HASADDR+!HASMAX+!HASPTEXT+!HASFUNC)
macro choicepick_prgtext(name, addr, max, pfunc, ptext)
	%add_self()
	db !CM_CHOICEPICK_PRGTEXT
	dl <addr>
	db <max>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

%MenuAction("CHOICEPICK_LOADOUT", $02, !HASADDR+!HASMAX+!HASPTEXT+!HASFUNC)
macro choicepick_loadout(name, addr, max, pfunc, ptext)
	%add_self()
	db !CM_CHOICEPICK_LOADOUT
	dl <addr>
	db <max>
	dl <pfunc>
	%cmstr("<name>")
	dl select(equal(<ptext>,this), ?here, <ptext>)

#?here:
endmacro

;---------------------------------------------------------------------------------------------------
%MenuAction("INFO_1DIGIT", $03, !HASADDR)
macro info1d(name, addr)
	%add_self()
	db !CM_INFO_1DIGIT
	dl <addr>
	%cmstr("<name>")
endmacro

%MenuAction("INFO_4HEX", $03, !HASADDR)
macro info4h(name, addr)
	%add_self()
	db !CM_INFO_4HEX
	dl <addr>
	%cmstr("<name>")
endmacro

;---------------------------------------------------------------------------------------------------

%MenuAction("SENTRY_PICKER", $02, !HASADDR+!HASINDEX)
macro sentry_picker(index, addr)
	%add_self()
	db !CM_SENTRY_PICKER
	dl <addr>
	db <index>
	%cmstr("Sentry <index>:")
endmacro

%MenuAction("LINE_SENTRY_PICKER", $02, !HASADDR+!HASINDEX)
macro line_sentry_picker(index, addr)
	%add_self()
	db !CM_LINE_SENTRY_PICKER
	dl <addr>
	db <index>
	%cmstr("Line <index>:")
endmacro

;===================================================================================================
; END OF COMMAND DEFINITIONS
;===================================================================================================

print "MENU COMMANDS: $", hex(!COMMAND_ID)

pullpc
