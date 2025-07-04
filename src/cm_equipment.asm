EQUIPMENT_SUBMENU:
%menu_header("EQUIPMENT", 19)

;===================================================================================================
%numfield_long_func_prgtext("Health", $7EF36D, 0, $A0, 8, this, cm_draw_hp)
	LDA.l $7EF36D
	CMP.l $7EF36C
	BCC ..not_max

	LDA.l $7EF36C
	BRA ..set

..not_max
	BIT.b SA1IRAM.cm_shoulder
	BVS ..flatten
	BPL ..set

..flatten
	AND.b #$F8

..set
	STA.l $7EF36D
	RTL

#cm_draw_hp:
	PHA ; save A
	LSR ; divide by 8 for hearts
	LSR
	LSR

	JSL CMDRAW_NUMFIELD_DEC_FROM_FUNC ; draw our max HP

	SEP #$20
	PLA
	AND.b #$07 ; get fractional
	ORA.b #$40
	JML CMDRAW_1_CHARACTER

;===================================================================================================
%numfield_func("Max HP", SA1RAM.cm_equipment_maxhp, 3, 20, 5, this)
	LDA.w SA1RAM.cm_equipment_maxhp
	ASL
	ASL
	ASL
	STA.l $7EF36C

	RTL

;===================================================================================================
%numfield_long("Magic", $7EF36E, 0, $80, 8)

;===================================================================================================
%numfield16_long_func("Rupees", $7EF360, 0, 999, 25, this)
	REP #$20

	LDA.l $7EF360
	STA.l $7EF362

	RTL

;===================================================================================================
%func("Fill everything", this)
	JSL Shortcut_FillEverything
	JSL CM_CacheWRAM

	JML RedrawCurrentMenu

;===================================================================================================

%choice_long_func_filtered_prgtext("Sword", $7EF359, 5, set_sword, draw_sword)
#draw_sword:
	INC
	CMP.b #$06
	BCS ..bad

	REP #$30
	AND.w #$00FF
	ORA.w #(draw_sword>>8)&$FF00
	STA.b SA1IRAM.cm_writer+1

	AND.w #$00FF
	ASL
	ADC.w #..list
	STA.b SA1IRAM.cm_writer+0

	LDA.b [SA1IRAM.cm_writer+0]
	JSL CMDRAW_WORD_LONG_LONG
	RTL

..bad
	JML CMDRAW_ERROR

..list
%list_header(6)
	%list_item("Turned in")
	%list_item("None")
	%list_item("Fighter")
	%list_item("Master")
	%list_item("Tempered")
	%list_item("Gold")

#set_sword:
	SEP #$30
	JSL $00D308 ; decomp sword
	JML $1BED03 ; sword palette

;===================================================================================================
%choice_long_func_filtered_here("Shield", $7EF35A, 4, set_shield)
	%list_item("No")
	%list_item("Fighter")
	%list_item("Red")
	%list_item("Mirror")

#set_shield:
	SEP #$30
	JSL $00D348 ; decomp shield
	JML $1BED29 ; shield palette

;===================================================================================================
%choice_long_func_filtered_here("Armor", $7EF35B, 3, set_armor)
	%list_item("Green")
	%list_item("Blue")
	%list_item("Red")

#set_link_equips:
	JSL set_sword
	JSL set_shield

#set_armor:
	SEP #$30
	JML $1BEDF9 ; mail palette

;===================================================================================================

%choice_long_func_filtered_here("Gloves", $7EF354, 3, set_armor)
	%list_item("No")
	%list_item("Power glove")
	%list_item("Titan's mitt")

;===================================================================================================
%toggle_long_func("Boots", $7EF355, SetBootsFlag)

#SetBootsFlag:
	LDA.l $7EF355
	CMP.b #$01

	LDA.l $7EF379
	AND.b #$FB
	BCC ++

	ORA.b #$04

++	STA.l $7EF379

	RTL

;===================================================================================================
%toggle_long_func("Flippers", $7EF356, SetFlippersFlag)

#SetFlippersFlag:
	LDA.l $7EF356
	CMP.b #$01

	LDA.l $7EF379
	AND.b #$FD
	BCC ++

	ORA.b #$02
++	STA.l $7EF379

	RTL

;===================================================================================================
%toggle_long("Moon pearl", $7EF357)

;===================================================================================================
%toggle_long("Half magic", $7EF37B)

;===================================================================================================
%numfield_long_2digits("Heart pieces", $7EF36B, 0, 3, 1)

;===================================================================================================
%add_menu_item(BOMBS_SETTER)
%numfield_long_2digits("Arrows", $7EF377, 0, 50, 5)
%numfield_long_2digits("Keys", $7EF36F, 0, 9, 1)

;===================================================================================================
%submenu("Big keys", BIG_KEYS_SUBMENU)

;===================================================================================================
%submenu("Small keys", SMALL_KEYS_SUBMENU)

;===================================================================================================
BIG_KEYS_SUBMENU:
%menu_header("BIG KEYS", 14)
	%toggle_bit_long("Sewers", $7EF367, 7)
	%toggle_bit_long("Escape", $7EF367, 6)
	%toggle_bit_long("Eastern", $7EF367, 5)
	%toggle_bit_long("Desert", $7EF367, 4)
	%toggle_bit_long("Hera", $7EF366, 5)
	%toggle_bit_long("ATower", $7EF367, 3)
	%toggle_bit_long("Darkness", $7EF367, 1)
	%toggle_bit_long("Swamp", $7EF367, 2)
	%toggle_bit_long("Skull", $7EF366, 7)
	%toggle_bit_long("Thieves", $7EF366, 4)
	%toggle_bit_long("Mire", $7EF367, 0)
	%toggle_bit_long("Ice", $7EF366, 6)
	%toggle_bit_long("Turtle Rock", $7EF366, 3)
	%toggle_bit_long("GTower", $7EF366, 2)

;===================================================================================================
SMALL_KEYS_SUBMENU:
%menu_header("SMALL KEYS", 13)
	%numfield_long("Escape", $7EF37C, 0, 9, 1)
	%numfield_long("Eastern", $7EF37E, 0, 9, 1)
	%numfield_long("Desert", $7EF37F, 0, 9, 1)
	%numfield_long("Hera", $7EF386, 0, 9, 1)
	%numfield_long("ATower", $7EF380, 0, 9, 1)
	%numfield_long("Darkness", $7EF382, 0, 9, 1)
	%numfield_long("Swamp", $7EF381, 0, 9, 1)
	%numfield_long("Skull", $7EF384, 0, 9, 1)
	%numfield_long("Thieves", $7EF387, 0, 9, 1)
	%numfield_long("Ice", $7EF385, 0, 9, 1)
	%numfield_long("Mire", $7EF383, 0, 9, 1)
	%numfield_long("Turtle Rock", $7EF388, 0, 9, 1)
	%numfield_long("GTower", $7EF389, 0, 9, 1)
