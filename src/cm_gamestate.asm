GAMESTATE_SUBMENU:
%menu_header("GAME STATE")

;===================================================================================================

%func("Skip text", this)
	LDA.b #$04
	STA.w $1CD4
	RTL

;===================================================================================================

%func("Remove sprites", this)
	SEP #$30

	LDA.b #$21 : STA.w $012F

	JML $09C44E

;===================================================================================================

%submenu("Reset dungeons", cm_game_reset_dungeons_submenu)

%submenu("Toggle bosses defeated", cm_game_state_bosses_submenu)

%submenu("Pendants and crystals", cm_game_state_crystals_submenu)

%submenu("Game flags", cm_game_state_game_flags_submenu)

%submenu("Drops", cm_game_state_drops_submenu)

;===================================================================================================

%choice_func_here("Follower", $7EF3CC, 15, $00D463)
	%add_list_item(CMTEXT_NO)
	%list_item("Zelda") : %ReusableText(CMTEXT_ZELDA)
	%list_item("Garbage")
	%list_item("Trash")
	%list_item("Old man")
	%list_item("Zelda text")
	%list_item("Blind")
	%list_item("Frog")
	%list_item("Dwarf")
	%list_item("Sign man")
	%list_item("Kiki")
	%list_item("??????")
	%list_item("Purple chest")
	%list_item("Super bomb")
	%list_item("Sasha text")

;===================================================================================================

%togglebit6_customtext("World", $7EF3CA, this)
%list_header(2)
	%list_item("Light World") : %ReusableText(CMTEXT_LIGHTWORLD)
	%list_item("Dark World")  : %ReusableText(CMTEXT_DARKWORLD)

;===================================================================================================

%choice_here("Progress", $7EF3C5, 4)
	%list_item("Started")
	%list_item("Uncle")
	%add_list_item(CMTEXT_ZELDA)
	%add_list_item(CMTEXT_AGAHNIM)

;===================================================================================================

%choicepick("M16 cache index", SA1RAM.map16cacheindex, 4, .func, .list)

.func
	REP #$30

	LDA.w SA1RAM.map16cacheindex
	ASL
	TAX

	LDA.l .addresses,X
	STA.w $04AC

	RTL


.addresses
	dw $0000
	dw $7EFE00-$7EF880-$20
	dw $7F6000-$7EF880-$20
	dw $7F71C0-$7EF880-$20

.list
%list_header(4)
	%list_item("Base")
	%list_item("Tile props")
	%list_item("Damage table")
	%list_item("Messages")

;===================================================================================================

cm_game_state_bosses_submenu:
%menu_header("BOSSES DEFEATED")
	%togglebit3_customtext("Armos", $7EF191, bossalivetext)
	%togglebit3_customtext("Lanmola", $7EF067, bossalivetext)
	%togglebit3_customtext("Moldorm", $7EF00F, bossalivetext)
	%togglebit3_func_customtext("Agahnim", $7EF041, toggle_aga1, bossalivetext) : %ReusableText(CMTEXT_AGAHNIM)
	%togglebit3_customtext("Helmasaur", $7EF0B5, bossalivetext)
	%togglebit3_customtext("Blind", $7EF159, bossalivetext)
	%togglebit3_customtext("Mothula", $7EF053, bossalivetext)
	%togglebit3_customtext("Kholdstare", $7EF1BD, bossalivetext)
	%togglebit3_customtext("Arrghus", $7EF00D, bossalivetext)
	%togglebit3_customtext("Vitreous", $7EF121, bossalivetext)
	%togglebit3_customtext("Trinexx", $7EF149, bossalivetext)
	%togglebit3_func_customtext("Agahnim 2", $7EF01B, toggle_aga2, bossalivetext)

bossalivetext:
	%toggletext("Alive", "Dead")

;===================================================================================================

toggle_aga1:
	LDA.l $7EF041
	JSR .set_bit
	BEQ .no_castle_overlay

	LDX.b #$1B : JSR .set_overlay

.no_castle_overlay
	LDX.b #$02 : JSR .set_overlay

	RTL

;---------------------------------------------------------------------------------------------------

#toggle_aga2:
	LDA.l $7EF01B
	JSR .set_bit

	LDX.b #$5B : JSR .set_overlay

	RTL

;---------------------------------------------------------------------------------------------------

#toggle_sanc:
	LDA.l $7EF3C6
	ASL
	JSR .set_bit

	LDX.b #$1B : JSR .set_overlay

	RTL

;---------------------------------------------------------------------------------------------------

.set_bit
	AND.b #$08
	ASL
	ASL
	STA.b SA1IRAM.cm_writer
	RTS

.set_overlay
	LDA.l $7EF280,X
	AND.b #$DF
	ORA.b SA1IRAM.cm_writer
	STA.l $7EF280,X
	RTS

;===================================================================================================

cm_game_state_game_flags_submenu:
%menu_header("GAME FLAGS")
	%togglebit0("Uncle dead", $7EF3C6)
	%togglebit1("Sanc priest", $7EF3C6)
	%togglebit2_func("Escaped", $7EF3C6, toggle_sanc)
	%togglebit0("Hobo bottle", $7EF3C9)
	%togglebit1("Vendor bottle", $7EF3C9)
	%togglebit3("Stumpy", $7EF3C9)
	%togglebit4("Purple chest", $7EF3C9)
	%togglebit5("Smithy rescued", $7EF3C9)
	%togglebit7("Tempering", $7EF3C9)

;===================================================================================================

cm_game_state_drops_submenu:
%menu_header("ENEMY DROPS")

%choice_here("Drop luck", $7E0CF9, 3)
	%list_item("Normal")
	%list_item("Great")
	%list_item("Trouble")

%numfield("Lucky kills", $7E0CFA, 0, 10, 1)
%numfield("Rupee pull kills", $7E0CFB, 0, 255, 16)
%numfield("Rupee pull hits", $7E0CFC, 0, 255, 16)

%choice_prgtext("Prize pack 1", $7E0FC7, 8, draw_prize_pack_1)
%choice_prgtext("Prize pack 2", $7E0FC8, 8, draw_prize_pack_2)
%choice_prgtext("Prize pack 3", $7E0FC9, 8, draw_prize_pack_3)
%choice_prgtext("Prize pack 4", $7E0FCA, 8, draw_prize_pack_4)
%choice_prgtext("Prize pack 5", $7E0FCB, 8, draw_prize_pack_5)
%choice_prgtext("Prize pack 6", $7E0FCC, 8, draw_prize_pack_6)
%choice_prgtext("Prize pack 7", $7E0FCD, 8, draw_prize_pack_7)

;===================================================================================================

cm_game_state_crystals_submenu:
%menu_header("PENDANTS AND CRYSTALS")
	%togglebit2("Eastern Palace", $7EF374)
	%togglebit1("Desert Palace", $7EF374)
	%togglebit0("Tower of Hera", $7EF374)
	%togglebit1("Darkness", $7EF37A)
	%togglebit5("Thieves` Town", $7EF37A)
	%togglebit6("Skull Woods", $7EF37A)
	%togglebit2("Ice Palace", $7EF37A)
	%togglebit4("Swamp Palace", $7EF37A)
	%togglebit0("Misery Mire", $7EF37A)
	%togglebit3("Turtle Rock", $7EF37A)

;===================================================================================================

cm_game_reset_dungeons_submenu:
%menu_header("RESET DUNGEONS")
	%func("Escape", reset_dungeon_func)
	%func("Eastern Palace", reset_dungeon_func)
	%func("Desert Palace", reset_dungeon_func)
	%func("Tower of Hera", reset_dungeon_func)
	%func("Castle Tower", reset_dungeon_func)
	%func("Palace of Darkness", reset_dungeon_func)
	%func("Swamp Palace", reset_dungeon_func)
	%func("Skull Woods", reset_dungeon_func)
	%func("Thieves' Town", reset_dungeon_func)
	%func("Ice Palace", reset_dungeon_func)
	%func("Misery Mire", reset_dungeon_func)
	%func("Turtle Rock", reset_dungeon_func)
	%func("Ganon's Tower", reset_dungeon_func)
	%func("Other", reset_dungeon_func)

!EX = $01 ; escape
!EP = $02 ; eastern palace
!DP = $03 ; desert palace
!TH = $04 ; tower of hera

!AT = $0A ; aga's tower

!PD = $11 ; palace of darkness
!SP = $12 ; swamp palace
!SW = $13 ; skull woods
!TT = $14 ; thieves' town
!IP = $15 ; ice palace
!MM = $16 ; misery mire
!TR = $17 ; turtle rock
!GT = $18 ; ganon's tower

!CV = $FF ; caves and houses
!UU = !CV ; unused caves, just for convenience

#room_to_dungeon_id:
	; eg1
	dw !CV, !EX, !EX, !CV, !TR, !UU, !SP, !TH, !CV, !PD, !PD, !PD, !GT, !GT, !IP, !UU
	dw !CV, !EX, !EX, !TR, !TR, !TR, !SP, !TH, !CV, !PD, !PD, !PD, !GT, !GT, !IP, !IP
	dw !AT, !EX, !EX, !TR, !TR, !UU, !SP, !TH, !SP, !SW, !PD, !PD, !CV, !UU, !IP, !CV
	dw !AT, !TH, !EX, !DP, !SP, !SP, !SP, !SP, !SP, !SW, !PD, !PD, !CV, !GT, !IP, !IP
	dw !AT, !EX, !EX, !DP, !TT, !TT, !SP, !UU, !UU, !SW, !PD, !PD, !GT, !GT, !IP, !IP
	dw !EX, !EX, !EX, !DP, !SP, !CV, !SW, !SW, !SW, !SW, !PD, !GT, !GT, !GT, !IP, !IP
	dw !EX, !EX, !EX, !DP, !TT, !TT, !SP, !SW, !SW, !UU, !PD, !GT, !GT, !GT, !IP, !UU
	dw !EX, !EX, !EX, !DP, !DP, !DP, !SP, !TH, !UU, !UU, !UU, !GT, !GT, !GT, !IP, !IP
	dw !EX, !EX, !EX, !DP, !DP, !DP, !UU, !TH, !UU, !EP, !UU, !GT, !GT, !GT, !IP, !UU
	dw !MM, !MM, !MM, !MM, !UU, !GT, !GT, !MM, !MM, !EP, !UU, !GT, !GT, !GT, !IP, !IP
	dw !MM, !MM, !MM, !MM, !TR, !GT, !GT, !TH, !EP, !EP, !EP, !TT, !TT, !UU, !IP, !IP
	dw !AT, !MM, !MM, !MM, !TR, !TR, !TR, !TR, !EP, !EP, !EP, !TT, !TT, !UU, !IP, !IP
	dw !AT, !MM, !MM, !MM, !TR, !TR, !TR, !TR, !EP, !EP, !UU, !TT, !TT, !UU, !IP, !UU
	dw !AT, !MM, !MM, !CV, !CV, !TR, !TR, !UU, !EP, !EP, !EP, !TT, !TT, !UU, !IP, !CV
	dw !AT, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !UU, !CV, !CV, !UU, !CV, !CV, !CV
	dw !CV, !CV, !CV, !CV, !CV, !CV, !UU, !UU, !CV, !CV, !CV, !CV, !UU, !CV, !CV, !CV

	; eg 2
	dw !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV
	dw !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV
	dw !CV, !CV, !CV, !CV, !CV, !CV, !CV, !CV

reset_dungeon_func:
	PHB : PHK : PLB
	PHD

	LDY.b SA1IRAM.cm_cursor
	LDX.w .list,Y

	REP #$30

	LDA.w #$0000
	TCD
	STX.b $00

	LDX.w #(256+40)*2 ; eg1 size + eg2 size, words

--	LDY.w room_to_dungeon_id,X
	CPY.b $00 : BNE ++
	STA.l $7EF000,X
++	DEX #2 : BPL --

	; check current room
	INC ; sets accum to #$0001
	BIT.b $1B : BEQ ++ ; make sure we're indoors

	LDA.b $A0 : ASL : TAX
	LDA.w room_to_dungeon_id,X
	CMP.b $00 : BNE ++
	STZ.w $0400 : STZ.w $0402 : STZ.w $0408

++	PLD
	PLB
	RTL

.list
	db !EX
	db !EP
	db !DP
	db !TH
	db !AT
	db !PD
	db !SP
	db !SW
	db !TT
	db !IP
	db !MM
	db !TR
	db !GT
	db !CV

;===================================================================================================

draw_prize_pack:
	JSL CMDRAW_DIGIT

	LDA.b #' '
	JSL CMDRAW_CHAR

	REP #$20 ; to also pull high byte to have 00 in B
	PLA
	SEP #$20

	PHX
	TAX

	; get prize pack # from index + pack
	ASL : ASL : ASL
	ADC.w $0FC7,X
	TAX

	LDA.l $06FA78,X
	SBC.b #$D8-1

	CMP.b #$0C
	BCS .bad

	REP #$F3
	ASL
	TAX

	LDA.w .item_names,X

	PLX

	JMP CMDRAW_WORD_FUNCEND

.bad
	PLX
	JML CMDRAW_ERROR

;---------------------------------------------------------------------------------------------------

#draw_prize_pack_1:
	PEA.w $0000 : BRA draw_prize_pack

#draw_prize_pack_2:
	PEA.w $0001 : BRA draw_prize_pack

#draw_prize_pack_3:
	PEA.w $0002 : BRA draw_prize_pack

#draw_prize_pack_4:
	PEA.w $0003 : BRA draw_prize_pack

#draw_prize_pack_5:
	PEA.w $0004 : BRA draw_prize_pack

#draw_prize_pack_6:
	PEA.w $0005 : BRA draw_prize_pack

#draw_prize_pack_7:
	PEA.w $0006 : BRA draw_prize_pack

;---------------------------------------------------------------------------------------------------

.item_names
%list_header(12)
	%list_item("Heart")
	%list_item("Grn rupee")
	%list_item("Blue rupee")
	%list_item("Red rupee")
	%list_item("Bomb (1)")
	%list_item("Bomb (4)")
	%list_item("Bomb (8)")
	%list_item("Magic")
	%list_item("Big magic")
	%list_item("Arrow (5)")
	%list_item("Arrow (10)")
	%list_item("Fairy") : %ReusableText(CMTEXT_FAIRY)

;===================================================================================================
