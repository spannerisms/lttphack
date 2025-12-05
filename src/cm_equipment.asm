EQUIPMENT_SUBMENU:
%menu_header("EQUIPMENT")

;===================================================================================================

%numfield_func_prgtext("Health", $7EF36D, 0, $A0, 8, this, .draw_hp)
	LDA.l $7EF36D
	CMP.l $7EF36C
	BCC .not_max

	LDA.l $7EF36C
	BRA .set

.not_max
	BIT.b SA1IRAM.cm_shoulder
	BVS .flatten
	BPL .set

.flatten
	AND.b #$F8

.set
	STA.l $7EF36D
	RTL

;---------------------------------------------------------------------------------------------------

.draw_hp
	PHA ; save A
	LSR ; divide by 8 for hearts
	LSR
	LSR

	JSL CMDRAW_HEXTODEC_FROM_FUNC ; draw our max HP

	SEP #$20
	PLA
	AND.b #$07 ; get fractional
	ORA.b #$40
	JML CMDRAW_CHAR

;===================================================================================================

%numfield_func("Max HP", SA1RAM.cm_equipment_maxhp, 3, 20, 5, this)
	LDA.w SA1RAM.cm_equipment_maxhp
	ASL
	ASL
	ASL
	STA.l $7EF36C

	RTL

;===================================================================================================

%numfield("Magic", $7EF36E, 0, $80, 8)

;===================================================================================================

%numfield16_func("Rupees", $7EF360, 0, 999, 25, this)
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

%choice_func_filtered_prgtext("Sword", $7EF359, 5, set_sword, draw_sword)
draw_sword:
	INC
	CMP.b #$06
	BCS .bad

	REP #$30
	AND.w #$00FF
	ORA.w #(draw_sword>>8)&$FF00
	STA.b SA1IRAM.cm_writer+1

	AND.w #$00FF
	ASL
	ADC.w #.list
	STA.b SA1IRAM.cm_writer+0

	LDA.b [SA1IRAM.cm_writer+0]
	JMP CMDRAW_WORD_FUNCEND

.bad
	JML CMDRAW_ERROR

.list
%list_header(6)
	%list_item("Turned in")
	%add_list_item(CMTEXT_NO)
	%list_item("Fighter") : %ReusableText(CMTEXT_FIGHTER)
	%list_item("Master")
	%list_item("Tempered")
	%list_item("Gold")

;===================================================================================================

%choice_func_filtered_here("Shield", $7EF35A, 4, set_shield)
	%add_list_item(CMTEXT_NO)
	%add_list_item(CMTEXT_FIGHTER)
	%add_list_item(CMTEXT_RED)
	%add_list_item(CMTEXT_MIRROR)

;===================================================================================================

%choice_func_filtered_here("Armor", $7EF35B, 3, set_armor)
	%add_list_item(CMTEXT_GREEN)
	%add_list_item(CMTEXT_BLUE)
	%add_list_item(CMTEXT_RED)

;===================================================================================================

%choice_func_filtered_here("Gloves", $7EF354, 3, set_armor)
	%add_list_item(CMTEXT_NO)
	%list_item("Power glove")
	%list_item("Titan's mitt")

;===================================================================================================

%toggle_func("Boots", $7EF355, SetBootsFlag)

%toggle_func("Flippers", $7EF356, SetFlippersFlag)

;===================================================================================================

%toggle("Moon pearl", $7EF357)

%toggle("Half magic", $7EF37B)

%numfield_2digits("Heart pieces", $7EF36B, 0, 3, 1)

%add_menu_item(BOMBS_SETTER)

%numfield_capacity("Arrows", $7EF377)

;===================================================================================================

%numfield_prgtext("Bomb capacity", $7EF370, 0, 7, 1, this)
	PHA
	PHX

	REP #$20

	AND.w #$00FF
	TAX
	LDA.l $0DDB48,X

;===================================================================================================

TestBadCapacity:
	AND.w #$00FF
	SEP #$20
	PLX

	JSL CMDRAW_HEXTODEC_FROM_FUNC

	SEP #$20
	PLA
	CMP.b #$08
	BCC .capacity_fine

	REP #$20
	LDA.w #.bad
	JMP CMDRAW_WORD_FUNCEND

.capacity_fine
	RTL

.bad
	%cmstr(" bad")

;===================================================================================================

%numfield_prgtext("Arrow capacity", $7EF371, 0, 7, 1, this)
	PHA
	PHX

	REP #$20

	AND.w #$00FF
	TAX
	LDA.l $0DDB58,X
	JMP TestBadCapacity

;===================================================================================================

%numfield_2digits("Keys", $7EF36F, 0, 9, 1)

%submenu("Big keys", BIG_KEYS_SUBMENU)
%submenu("Small keys", SMALL_KEYS_SUBMENU)

;===================================================================================================

BIG_KEYS_SUBMENU:
%menu_header("BIG KEYS")
	%togglebit7("Sewers", $7EF367) : %ReusableText(CMTEXT_SEWERS)
	%togglebit6("Hyrule Castle", $7EF367)
	%togglebit5("Eastern Palace", $7EF367)
	%togglebit4("Desert Palace", $7EF367)
	%togglebit5("Tower of Hera", $7EF366)
	%togglebit3("Castle Tower", $7EF367)
	%togglebit1("Darkness", $7EF367)
	%togglebit2("Swamp Palace", $7EF367)
	%togglebit7("Skull Woods", $7EF366)
	%togglebit4("Thieves` Town", $7EF366)
	%togglebit0("Misery Mire", $7EF367)
	%togglebit6("Ice Palace", $7EF366)
	%togglebit3("Turtle Rock", $7EF366)
	%togglebit2("Ganon`s Tower", $7EF366)

;===================================================================================================

SMALL_KEYS_SUBMENU:
%menu_header("SMALL KEYS")
	%numfield("Hyrule Castle", $7EF37C, 0, 9, 1)
	%numfield("Eastern Palace", $7EF37E, 0, 9, 1)
	%numfield("Desert Palace", $7EF37F, 0, 9, 1)
	%numfield("Tower of Hera", $7EF386, 0, 9, 1)
	%numfield("Castle Tower", $7EF380, 0, 9, 1)
	%numfield("Darkness", $7EF382, 0, 9, 1)
	%numfield("Swamp Palace", $7EF381, 0, 9, 1)
	%numfield("Skull Woods", $7EF384, 0, 9, 1)
	%numfield("Thieves` Town", $7EF387, 0, 9, 1)
	%numfield("Ice Palace", $7EF385, 0, 9, 1)
	%numfield("Misery Mire", $7EF383, 0, 9, 1)
	%numfield("Turtle Rock", $7EF388, 0, 9, 1)
	%numfield("Ganon's Tower", $7EF389, 0, 9, 1)

;===================================================================================================
