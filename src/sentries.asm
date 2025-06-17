
;===================================================================================================

sentry_name_pointers:
	fillword $0000 : fill 256*2

sentry_routines:
	fillword sentry_nothing : fill 512*2

sentry_inits:
	fillword no_sentry_init : fill 512*2

;===================================================================================================

reinit_sentry_addresses:
	REP #$30

	PHB
	PHK
	PLB

	LDX.w #$0008

.next
	LDY.w !config_sentry1,X
	LDA.w sentry_inits,Y
	STA.w SA1IRAM.SNTADD1,X
	DEX
	DEX
	BPL .next

	SEP #$30
	PLB
	RTL


;===================================================================================================

Extra_SA1_Transfers:
	REP #$30

	LDX.w !config_linesentry1 : LDY.w #$0000 : JSR.w (sentry_inits,X)
	LDX.w !config_linesentry2 : LDY.w #$0010 : JSR.w (sentry_inits,X)
	LDX.w !config_linesentry3 : LDY.w #$0020 : JSR.w (sentry_inits,X)
	LDX.w !config_linesentry4 : LDY.w #$0030 : JSR.w (sentry_inits,X)

	RTL

;===================================================================================================

%sentry_group("Off")
	dw SENTRY_OFF
%end_sentry_group()

%sentry_group("Timers")
	dw SENTRY_ROOMTIME
	dw SENTRY_ROOMLIVE
	dw SENTRY_LAGFRAMES
	dw SENTRY_LAGLIVE
	dw SENTRY_IDLEFRAMES
	dw SENTRY_SEGTIME
%end_sentry_group()

%sentry_group("Link")
	dw SENTRY_COORDINATES
	dw SENTRY_VELOCITY
	dw SENTRY_SUBPIXELS
	dw SENTRY_SPINTIME
%end_sentry_group()

%sentry_group("Enemies")
	dw SENTRY_BOSSHP
	dw SENTRY_ARCVAR
	dw SENTRY_ENEMY0ALT
%end_sentry_group()

%sentry_group("Underworld")
	dw SENTRY_ROOMID
	dw SENTRY_QUADRANT
	dw SENTRY_LINKTILE
	dw SENTRY_PITBEHAVIOR
%end_sentry_group()

%sentry_group("Minor glitches")
	dw SENTRY_SPOOKY
	dw SENTRY_HOVERING
%end_sentry_group()

%sentry_group("Major glitches")
	dw SENTRY_WESTSOM
	dw SENTRY_ANCINDEX
	dw SENTRY_HOOKSLOT
	dw SENTRY_PLAIDTILE
%end_sentry_group()

;===================================================================================================

%line_sentry_group("Off")
	dw SENTRY_OFF
%end_sentry_group()

%line_sentry_group("Underworld")
	dw LINE_SENTRY_ROOMFLAGS
	dw LINE_SENTRY_UWCAMX
	dw LINE_SENTRY_UWCAMY
%end_sentry_group()

%line_sentry_group("Overworld")
	dw LINE_SENTRY_OWTRANSX
	dw LINE_SENTRY_OWTRANSY
%end_sentry_group()

%line_sentry_group("Ancilla front slots")
	dw LINE_SENTRY_ANCF_ID
	dw LINE_SENTRY_ANCF_XCOORD
	dw LINE_SENTRY_ANCF_YCOORD
	dw LINE_SENTRY_ANCF_ZCOORD
	dw LINE_SENTRY_ANCF_LAYER
	dw LINE_SENTRY_ANCF_EXTEND
	dw LINE_SENTRY_ANCF_TILE
	dw LINE_SENTRY_ANCF_EG
	dw LINE_SENTRY_ANCF_DIR
	dw LINE_SENTRY_ANCF_DECAY
%end_sentry_group()

%line_sentry_group("Ancilla back slots")
	dw LINE_SENTRY_ANCB_ID
	dw LINE_SENTRY_ANCB_XCOORD
	dw LINE_SENTRY_ANCB_YCOORD
	dw LINE_SENTRY_ANCB_ZCOORD
	dw LINE_SENTRY_ANCB_LAYER
	dw LINE_SENTRY_ANCB_EXTEND
	dw LINE_SENTRY_ANCB_TILE
	dw LINE_SENTRY_ANCB_EG
	dw LINE_SENTRY_ANCB_DIR
	dw LINE_SENTRY_ANCB_DECAY
%end_sentry_group()

%line_sentry_group("Ancilla indexed slots")
	dw LINE_SENTRY_ANCX_ID
	dw LINE_SENTRY_ANCX_XCOORD
	dw LINE_SENTRY_ANCX_YCOORD
	dw LINE_SENTRY_ANCX_ZCOORD
	dw LINE_SENTRY_ANCX_LAYER
	dw LINE_SENTRY_ANCX_EXTEND
	dw LINE_SENTRY_ANCX_TILE
	dw LINE_SENTRY_ANCX_EG
	dw LINE_SENTRY_ANCX_DIR
	dw LINE_SENTRY_ANCX_DECAY
%end_sentry_group()

;===================================================================================================

%sentry_no_init("Off", "OFF")
	RTS

;===================================================================================================

; for consistent timing
no_sentry_init:
;	LDA.l $000000
;	STA.w SA1IRAM.sentry_cache,Y

sentry_nothing:
	RTS

;===================================================================================================

NoDisplaySentry:
	LDA.w #$608B : STA.w SA1RAM.HUD+12,X
	STA.w SA1RAM.HUD+14,X
	RTS

;===================================================================================================

sentry_raw:
	PHA

	TYA
	STA.w SA1RAM.HUD+10,X

	PLA
	AND.w #$00FF

	JMP DrawHex_white_2

;===================================================================================================

%sentry_no_init("Room time", "ROOMTIME")
	LDY.w #!yellow
	LDA.w #SA1IRAM.ROOM_TIME_F_DISPLAY
	JSR Draw_all_two

	DEX ; down 4
	DEX
	DEX
	DEX
	LDY.w #!white
	LDA.w #SA1IRAM.ROOM_TIME_S_DISPLAY
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Room time (live)", "ROOMLIVE")
	LDY.w #!yellow
	LDA.w #SA1IRAM.ROOM_TIME_F
	JSR Draw_all_two

	DEX ; down 4
	DEX
	DEX
	DEX
	LDY.w #!white
	LDA.w #SA1IRAM.ROOM_TIME_S
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Segment time", "SEGTIME")
	LDY.w #!gray
	LDA.w #SA1IRAM.SEG_TIME_F_DISPLAY
	JSR Draw_all_two

	DEX
	DEX
	DEX
	DEX
	LDY.w #!yellow
	LDA.w #SA1IRAM.SEG_TIME_S_DISPLAY
	JSR Draw_all_two

	DEX
	DEX
	DEX
	DEX
	LDY.w #!white
	LDA.w #SA1IRAM.SEG_TIME_M_DISPLAY
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Lag frames", "LAGFRAMES")
	LDY.w #!red
	LDA.w #SA1IRAM.ROOM_TIME_LAG_DISPLAY
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Lag frames (live)", "LAGLIVE")
	LDY.w #!red
	LDA.w #SA1IRAM.ROOM_TIME_LAG
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Idle frames", "IDLEFRAMES")
	LDA.w SA1IRAM.ROOM_TIME_IDLE_DISPLAY

	PHX
	JSR hex_to_dec_fast
	PLX

	XBA
	SEP #$20

	LDA.b SA1IRAM.SCRATCH+2
	ASL
	ASL
	ASL
	ASL
	ORA.b SA1IRAM.SCRATCH+4

	REP #$20
	STA.b SA1IRAM.SCRATCH

	LDY.w #!white
	LDA.w #SA1IRAM.SCRATCH
	JMP Draw_short_three

;===================================================================================================

%sentry_no_init("Coordinates", "COORDINATES")
	LDA.b SA1IRAM.CopyOf_20
	JSR DrawHex_yellow_4

	LDA.b SA1IRAM.CopyOf_22
	JMP DrawHex_white_4

;===================================================================================================

%sentry($0030, "Velocity", "VELOCITY")
	PHA

	LDY.w #$355C

	AND.w #$00FF
	BNE .nonzero_y

	LDY.w #$342E
	BRA .positive_y

.nonzero_y
	CMP.w #$0080
	BCC .positive_y

	EOR.w #$FFFF
	INC
	LDY.w #$355B

.positive_y
	PHY

	JSR DrawHex_yellow_2

	PLA
	STA.w SA1RAM.HUD+14,X
	DEX
	DEX

;---------------------------------------------------------------------------------------------------

	PLA
	XBA

	LDY.w #$3D5A

	AND.w #$00FF
	BNE .nonzero_x

	LDY.w #$3C2D
	BRA .positive_x

.nonzero_x
	CMP.w #$0080
	BCC .positive_x

	EOR.w #$FFFF
	INC
	LDY.w #$3D59

.positive_x
	PHY

	JSR DrawHex_white_2

	PLA
	STA.w SA1RAM.HUD+14,X

	RTS

;===================================================================================================

%sentry($002A, "Subpixel velocity", "SUBPIXELS")
	PHA
	AND.w #$00FF
	JSR DrawHex_yellow_2

	PLA
	XBA
	AND.w #$00FF
	JMP DrawHex_white_2

;===================================================================================================

%sentry($0079, "Spin attack timer", "SPINTIME")
	TAY

	LDA.w #char(23)|!BLUE_PAL
	STA.w SA1RAM.HUD+10,X

	TYA

	LDY.w #!gray
	AND.w #$00FF
	CMP.w #48
	BCC .cant_spin

	LDY.w #!white

.cant_spin
	JSR PrepHexToDecDraw

	JMP Draw_short_three

;===================================================================================================

%sentry($0E50, "Boss HP", "BOSSHP")
	LDY.w #$2CA1
	JMP sentry_raw

;===================================================================================================

%sentry($0B08, "Arc variable", "ARCVAR")
	JMP DrawHex_white_4

;===================================================================================================

%sentry($0F70, "Slot 0 altitude", "ENEMY0ALT")
	JMP DrawHex_white_2

;===================================================================================================

%sentry($00A0, "Room ID", "ROOMID")
	; calculate correct room id first
	LDA.b SA1IRAM.CopyOf_21 : AND.w #$00FE
	ASL : ASL : ASL
	STA.b SA1IRAM.SCRATCH+14

	LDA.b SA1IRAM.CopyOf_23 : AND.w #$00FE : LSR ; bit 0 is off, so it clears carry
	ADC.b SA1IRAM.SCRATCH+14 : STA.b SA1IRAM.SCRATCH+14

	LDA.b SA1IRAM.CopyOf_1B
	AND.w #$00FF
	BEQ .overworld

	LDA.b SA1IRAM.SCRATCH+14
	CMP.b SA1IRAM.CopyOf_A0
	BNE .desync

.sync
	PEA.w !SYNCED
	LDY.w #!gray
	BRA .draw

.desync
	PEA.w !DESYNC
	LDY.w #!red
	BRA .draw

.overworld
	PEA.w char($11)|!GRAY_PAL

	LDA.w #$608B
	STA.w SA1RAM.HUD+14,X
	STA.w SA1RAM.HUD+12,X
	STA.w SA1RAM.HUD+10,X

	TXA
	SEC
	SBC.w #$0006
	TAX
	BRA ++

.draw
	LDA.b SA1IRAM.SCRATCH+14
	JSR DrawHex_3digit_prepped

++	PLA
	STA.w SA1RAM.HUD+14,X
	DEX
	DEX

	LDA.b SA1IRAM.CopyOf_A0
	JMP DrawHex_white_3

;===================================================================================================

%sentry($00A9, "Quadrant", "QUADRANT")
	LDY.b SA1IRAM.CopyOf_1B-1
	CPY.w #$0100 ; see if 1B is 00
	BCC .no

	LSR
	BCS .east
	; $AA is 0 or 2, and will be the only bit remaining, no matter what

.west
	BEQ .northwest

.southwest
	LDY.w #2
	LDA.w #char(5+2)|!RED_PAL
	BRA .doQuadrant

.no
	JMP NoDisplaySentry

.northwest
	LDY.w #3
	LDA.w #char(5+3)|!RED_PAL
	BRA .doQuadrant

.east
	BEQ .northeast

.southeast
	LDY.w #1
	LDA.w #char(5+1)|!RED_PAL
	BRA .doQuadrant

.northeast
	LDY.w #0
	LDA.w #char(5+0)|!RED_PAL

.doQuadrant
	STY.b SA1IRAM.SCRATCH+14

	STA.w SA1RAM.HUD+10,X

.calc_correct_quadrant
	LDA.w #$0100 ; checking the same bit on both coordinates

	BIT.b SA1IRAM.CopyOf_22 : BNE ..east

..west
	BIT.b SA1IRAM.CopyOf_20 : BEQ ..northwest

	; using the gray pal means we only need to ORA if desynched
	; and can leave it alone otherwise
..southwest
	LDY.w #2
	LDA.w #char(5+2)|!GRAY_PAL
	BRA .drawQuadrant

..northwest
	LDY.w #3
	LDA.w #char(5+3)|!GRAY_PAL
	BRA .drawQuadrant

..east
	BIT.b SA1IRAM.CopyOf_20 : BEQ ..northeast

..southeast
	LDY.w #1
	LDA.w #char(5+1)|!GRAY_PAL
	BRA .drawQuadrant

..northeast
	LDY.w #0
	LDA.w #char(5+0)|!GRAY_PAL

.drawQuadrant
	CPY.b SA1IRAM.SCRATCH+14
	BEQ .sync

.desync
	ORA.w #!TEXT_PAL
	STA.w SA1RAM.HUD+14,X

	LDA.w #!DESYNC
	BRA .drawSync

.sync
	STA.w SA1RAM.HUD+14,X
	LDA.w #!SYNCED

.drawSync
	STA.w SA1RAM.HUD+12,X
	RTS

;===================================================================================================

%sentry($0114, "Tile under foot", "LINKTILE")
	AND.w #$00FF
	TAY

	LDA.w #char(24)|!GREEN_PAL
	STA.w SA1RAM.HUD+10,X

	LDA.b SA1IRAM.CopyOf_1B
	AND.w #$00FF
	BEQ .no

	TYA
	JMP DrawHex_white_2

.no
	JMP NoDisplaySentry

;===================================================================================================

%sentry($C000, "Pit behavior", "PITBEHAVIOR")
	LDY.b SA1IRAM.CopyOf_1B-1
	CPY.w #$0100 ; see if 1B is 00
	BCC .no

	AND.w #$00FF
	JSR DrawHex_white_2

	TXY
	LDX.b SA1IRAM.CopyOf_A0
	LDA.l RoomHasPitDamage,X
	TYX

	LSR
	BCS .pitdamage

.warphole
	LDA.w #char($16)|!GRAY_PAL
	BRA .drawflag

.no
	JMP NoDisplaySentry

.pitdamage
	LDA.w #char($16)|!YELLOW_PAL

.drawflag
	STA.w SA1RAM.HUD+14,X
	RTS

;===================================================================================================

%sentry($02A2, "Spooky action", "SPOOKY")
	LDY.w #char(3)|!RED_PAL
	JMP sentry_raw

;===================================================================================================

%sentry($0374, "Hovering", "HOVERING")
	AND.w #$00FF

	CMP.w #$0000
	BEQ ++

	; carry guaranteed to be set since CMP #0
	PHA
	LDA.w #$001E
	SBC 1,S
	PLY

	PHX
	JSR hex_to_dec_fast
	PLX

	LDA.b SA1IRAM.SCRATCH+2
	ASL
	ASL
	ASL
	ASL
	ORA.b SA1IRAM.SCRATCH+4

++	STA.b SA1IRAM.SCRATCH

	LDY.w #!white
	LDA.w #SA1IRAM.SCRATCH
	JMP Draw_short_two

;===================================================================================================

%sentry($0690, "WEST SOMARIA", "WESTSOM")
	LDY.w #char(23)|!RED_PAL
	JMP sentry_raw

;===================================================================================================

%sentry($03C4, "Ancilla search index", "ANCINDEX")
	LDY.w #char(4)|!BLUE_PAL
	JMP sentry_raw

;===================================================================================================

%sentry($0394, "Hookslot", "HOOKSLOT")
	LDY.w #char(2)|!RED_PAL
	JMP sentry_raw

;===================================================================================================

%sentry($00EC, "Plaid tile index", "PLAIDTILE")
	TAY

	LDA.b SA1IRAM.CopyOf_1B
	AND.w #$00FF
	BEQ .no

	LDA.w #char(24)|!BLUE_PAL
	STA.w SA1RAM.HUD+6,X

	TYA
	AND.b SA1IRAM.CopyOf_20
	AND.w #$FFF8
	ASL
	ASL
	ASL
	STA.b SA1IRAM.SCRATCH+12

	TYA
	AND.b SA1IRAM.CopyOf_22
	LSR
	LSR
	LSR
	AND.w #$003F
	CLC
	ADC.b SA1IRAM.SCRATCH+12
	CLC
	ADC.w #$2000

	JMP DrawHex_white_4

.no
	JMP NoDisplaySentry

;===================================================================================================
;===================================================================================================
;===================================================================================================
;===================================================================================================

%line_sentry("Room flags", ROOMFLAGS)
	LDA.w SA1IRAM.LINEVAL+1,Y : AND.w #$0FFF : STA.b SA1IRAM.SCRATCH+10
	LDA.w SA1IRAM.LINEVAL-1,Y : AND.w #$F000 : ORA.b SA1IRAM.SCRATCH+10

	; rearrange it into the order we want
	; Start: dddd qqqq hkcc cccc
	; End:   hkcc cccc dddd qqqq
	XBA 
	STA.b SA1IRAM.SCRATCH+10

	LDA.w #char($19)|!RED_PAL : STA.w SA1RAM.HUD,X ; flag symbol

	LDY.w #0

.next_flag
	INX
	INX
	LDA.w .char,Y
	ASL.b SA1IRAM.SCRATCH+10
	BCS .on

.off
	AND.w #$E3FF
	ORA.w #!GRAY_PAL

.on
	STA.w SA1RAM.HUD,X
	INY
	INY
	CPY.w #32
	BCC .next_flag

	RTS

.char
	dw $20A0|!RED_PAL
	dw $2071|!YELLOW_PAL
	dw $2071|!YELLOW_PAL
	dw $20A8|!BLUE_PAL
	dw char($15)|!REDYELLOW
	dw char($15)|!REDYELLOW
	dw char($15)|!REDYELLOW
	dw char($15)|!REDYELLOW
	dw char($1A)|!BROWN_PAL
	dw char($1A)|!BROWN_PAL
	dw char($1A)|!BROWN_PAL
	dw char($1A)|!BROWN_PAL
	dw char($14)|!HFLIP|!BLUE_PAL
	dw char($14)|!RED_PAL
	dw char($14)|!HFLIP|!VFLIP|!GREEN_PAL
	dw char($14)|!VFLIP|!YELLOW_PAL

.init
	SEP #$20

	LDA.w $0401 : STA.w SA1IRAM.LINEVAL+0,Y
	LDA.w $0403 : STA.w SA1IRAM.LINEVAL+1,Y
	LDA.w $0408 : STA.w SA1IRAM.LINEVAL+2,Y

	RTS

;===================================================================================================

%line_sentry("Underworld camera X", UWCAMX)
	LDA.w #char(9)
	PEA.w !white
	JMP LineSentryUWCameras

.init
	SEP #$20

	LDA.b $A6 : STA.w SA1IRAM.LINEVAL+0,Y

	REP #$20

	LDA.b $E2 : STA.w SA1IRAM.LINEVAL+1,Y

	LDA.w $0608 : STA.w SA1IRAM.LINEVAL+3,Y
	LDA.w $060C : STA.w SA1IRAM.LINEVAL+5,Y
	LDA.w $060A : STA.w SA1IRAM.LINEVAL+7,Y
	LDA.w $060E : STA.w SA1IRAM.LINEVAL+9,Y

	RTS

;===================================================================================================

%line_sentry("Underworld camera Y", UWCAMY)
	LDA.w #char(11)
	PEA.w !yellow
	JMP LineSentryUWCameras

.init
	SEP #$20

	LDA.b $A7 : STA.w SA1IRAM.LINEVAL+0,Y

	REP #$20

	LDA.b $E8 : STA.w SA1IRAM.LINEVAL+1,Y

	LDA.w $0600 : STA.w SA1IRAM.LINEVAL+3,Y
	LDA.w $0604 : STA.w SA1IRAM.LINEVAL+5,Y
	LDA.w $0602 : STA.w SA1IRAM.LINEVAL+7,Y
	LDA.w $0606 : STA.w SA1IRAM.LINEVAL+9,Y

	RTS

;===================================================================================================

LineSentryUWCameras:
	STA.b SA1IRAM.SCRATCH+14 ; save the icon

	PLA
	STA.b SA1IRAM.hud_props
	STA.b SA1IRAM.SCRATCH+12

	LDA.w #char($13)|!GRAY_PAL ; camera icon
	STA.w SA1RAM.HUD,X
	INX
	INX

	LDA.w SA1IRAM.LINEVAL+1,Y : JSR DrawHexForward_4digit_color_set
	PHX ; save X for sync icon
	INX
	INX

	; check which set to use
	LDA.w SA1IRAM.LINEVAL+0,Y
	BIT.w #$0002
	BNE .set2

	; +3 and +5 which are done first should be color of axis
.set1
	LDA.w SA1IRAM.LINEVAL+3,Y
	STA.b SA1IRAM.SCRATCH+4

	LDA.w SA1IRAM.LINEVAL+5,Y
	STA.b SA1IRAM.SCRATCH+6

	LDA.b SA1IRAM.SCRATCH+12 
	PEA.w !gray ; other set is gray
	BRA .draw

.set2
	LDA.w SA1IRAM.LINEVAL+7,Y
	STA.b SA1IRAM.SCRATCH+4

	LDA.w SA1IRAM.LINEVAL+9,Y
	STA.b SA1IRAM.SCRATCH+6

	PEI.b (SA1IRAM.SCRATCH+12) ; +3 and +5 should have gray
	LDA.w #!gray 

.draw
	STA.b SA1IRAM.hud_props ; set 1 color
	PLA
	STA.b SA1IRAM.SCRATCH+12 ; save set 2 color to here (don't need axis color anymore)

	LDA.w SA1IRAM.LINEVAL+1,Y ; save camera position
	PHA

	INY ; so we start at the +3
	JSR .draw1 ; draw first 2 camera values

	INC.b SA1IRAM.SCRATCH+14
	JSR .draw1

	LDA.b SA1IRAM.SCRATCH+12
	STA.b SA1IRAM.hud_props

	DEC.b SA1IRAM.SCRATCH+14
	JSR .draw1 ; draw first next 2 camera values

	INC.b SA1IRAM.SCRATCH+14
	JSR .draw1

	PLA ; get camera position
	PLX ; get HUD position of sync icon

	CMP.b SA1IRAM.SCRATCH+4
	BCC .desync
	DEC
	CMP.b SA1IRAM.SCRATCH+6
	BCS .desync

.sync
	LDA.w #!SYNCED
	BRA .drawsync

.desync
	LDA.w #!DESYNC

.drawsync
	STA.w SA1RAM.HUD,X
	RTS

.draw1
	INY
	INY
	LDA.b SA1IRAM.hud_props
	ORA.b SA1IRAM.SCRATCH+14
	STA.w SA1RAM.HUD,X
	INX
	INX

	LDA.w SA1IRAM.LINEVAL,Y
	JMP DrawHexForward_4digit_color_set

;===================================================================================================

%line_sentry("OW transition X", OWTRANSX)
	PEA.w $02A83B
	PEA.w char(9)|!white
	LDA.w #$FFFF
	JMP LineSentryOWCameras

.init
	LDA.l $7EF3CA : STA.w SA1IRAM.LINEVAL+0,Y
	RTS

;===================================================================================================

%line_sentry("OW transition Y", OWTRANSY)
	PEA.w $02A7BB
	PEA.w char(11)|!yellow
	LDA.w #$FFF8
	JMP LineSentryOWCameras

.init
	LDA.l $7EF3CA : STA.w SA1IRAM.LINEVAL+0,Y
	RTS

;===================================================================================================

LineSentryOWCameras:
	STA.b SA1IRAM.SCRATCH+6 ; increment amount
	PLA : STA.b SA1IRAM.SCRATCH+8 ; icon
	AND.w #$FC00 : ORA.w #$0010 : STA.b SA1IRAM.hud_props

	LDA.b SA1IRAM.CopyOf_1B
	AND.w #$00FF
	BEQ ++

	; gray if overworld
	LDA.w #$1C00
	TRB.b SA1IRAM.SCRATCH+8
	TRB.b SA1IRAM.hud_props

	LDA.w #!GRAY_PAL
	TSB.b SA1IRAM.SCRATCH+8
	TSB.b SA1IRAM.hud_props


++	PHB

	LDA.b SA1IRAM.CopyOf_20
	AND.w #$1E00
	ASL A
	ASL A
	ASL A
	STA.b SA1IRAM.SCRATCH+12

	LDA.b SA1IRAM.CopyOf_22
	AND.w #$1E00
	ORA.b SA1IRAM.SCRATCH+12

	XBA
	STA.b SA1IRAM.SCRATCH+12

	PEA.w $0202
	PLB : PLB

;---------------------------------------------------------------------------------------------------

	STZ.b SA1IRAM.SCRATCH+4

	JSR .draw_one

	INC.b SA1IRAM.SCRATCH+8

	LDA.b SA1IRAM.SCRATCH+6 : EOR.w #$FFFF : INC : STA.b SA1IRAM.SCRATCH+6
	LDA.w $02A77B,Y : AND.w #$00FF : INC : XBA : STA.b SA1IRAM.SCRATCH+4

	INX : INX : INX : INX
	JSR .draw_one

	PLB
	PLA

	RTS

.draw_one
	LDY.b SA1IRAM.SCRATCH+12

	LDA (4,S),Y
	CLC : ADC.b SA1IRAM.SCRATCH+4

	JSR DrawHexForward_4digit_color_set

	LDA.b SA1IRAM.SCRATCH+8
	STA.w SA1RAM.HUD,X
	INX
	INX

	TYA : AND.w #$00FF : LSR : PHA
	CLC : ADC.b SA1IRAM.SCRATCH+6
	AND.w #$00FF
	TAY

	LDA.w $02A4E3,Y
	ORA.w SA1IRAM.LINEVAL+0,Y
	PLY

	JMP DrawHexForward_2digit_color_set

;===================================================================================================

HUDAncillaLineBasic:
	LDA.w #$0005
	STA.b SA1IRAM.SCRATCH+14

.next_ancilla
	INX
	INX

	LDA.w SA1IRAM.LINEVAL,Y
	JSR DrawHexForward_white_2

.continue
	INY

	DEC.b SA1IRAM.SCRATCH+14
	BNE .next_ancilla

	RTS

;===================================================================================================

HUDAncillaLineBasicYellow:
	LDA.w #$0005
	STA.b SA1IRAM.SCRATCH+14

.next_ancilla
	INX
	INX

	LDA.w SA1IRAM.LINEVAL,Y
	JSR DrawHexForward_yellow_2

.continue
	INY

	DEC.b SA1IRAM.SCRATCH+14
	BNE .next_ancilla

	RTS

;===================================================================================================

HUDAncillaLineID:
	LDA.w #$0005
	STA.b SA1IRAM.SCRATCH+14

.next_ancilla
	INX
	INX

	LDA.w SA1IRAM.LINEVAL,Y
	AND.w #$00FF : BEQ .zero

	CMP.w #$0A : BEQ .replace
	CMP.w #$3C : BEQ .replace
	CMP.w #$13 : BNE .normal

.replace
	JSR DrawHexForward_red_2
	BRA .continue

.zero
	JSR DrawHexForward_gray_2
	BRA .continue

.normal
	JSR DrawHexForward_white_2

.continue
	INY

	DEC.b SA1IRAM.SCRATCH+14
	BNE .next_ancilla

	RTS

;===================================================================================================

HUDAncillaLineEG:
	LDA.w #$0005
	STA.b SA1IRAM.SCRATCH+14

.next_ancilla
	INX
	INX

	LDA.w SA1IRAM.LINEVAL,Y
	AND.w #$00FF : BEQ .zero

.bad
	JSR DrawHexForward_red_2
	BRA .continue

.zero
	JSR DrawHexForward_gray_2

.continue
	INY

	DEC.b SA1IRAM.SCRATCH+14
	BNE .next_ancilla

	RTS

;===================================================================================================
;===================================================================================================
;===================================================================================================
;===================================================================================================
;===================================================================================================

macro ancilla_line_group(addr, icon, propname, varname, drawroutine)

%line_sentry("AncF <propname>", "ANCF_<varname>")
	LDA.w #<icon>
	STA.w SA1RAM.HUD+0,X

	LDA.w #$A82F
	STA.w SA1RAM.HUD+2,X

	INX : INX : INX : INX
	JMP <drawroutine>

.init
	REP #$30
	LDX.w #<addr>
	JMP CollectAncilla

%line_sentry("AncB <propname>", "ANCB_<varname>")
	LDA.w #<icon>
	STA.w SA1RAM.HUD+0,X

	LDA.w #$3C2F
	STA.w SA1RAM.HUD+2,X

	INX : INX : INX : INX
	JMP <drawroutine>

.init
	REP #$30
	LDX.w #<addr>+5
	JMP CollectAncilla

%line_sentry("AncX <propname>", "ANCX_<varname>")
	LDA.w #<icon>
	STA.w SA1RAM.HUD+0,X

	LDA.w #$2D54
	STA.w SA1RAM.HUD+2,X

	INX : INX : INX : INX
	JMP <drawroutine>

.init
	REP #$31
	LDX.w #<addr>
	JMP CollectAncillaX

endmacro

%ancilla_line_group($0C4A, $2551, "ID", "ID", HUDAncillaLineID)
%ancilla_line_group($0C04, $242D, "X coordinate", "XCOORD", HUDAncillaLineBasic)
%ancilla_line_group($0BFA, $242E, "Y coordinate", "YCOORD", HUDAncillaLineBasicYellow)
%ancilla_line_group($029E, $2553, "Altitude", "ZCOORD", HUDAncillaLineBasic)
%ancilla_line_group($0C7C, $256B, "Layer", "LAYER", HUDAncillaLineBasic)
%ancilla_line_group($0C5E, $2552, "Extension", "EXTEND", HUDAncillaLineBasic)
%ancilla_line_group($03E4, $2D68, "Tile type", "TILE", HUDAncillaLineBasic)
%ancilla_line_group($03A4, $2966, "EG check", "EG", HUDAncillaLineEG)
%ancilla_line_group($0C72, $3D64, "Direction", "DIR", HUDAncillaLineBasic)
%ancilla_line_group($03B1, $2967, "Decay", "DECAY", HUDAncillaLineBasic)

;===================================================================================================

CollectAncillaX:
	LDA.w $03C4

	AND.w #$00FF
	SBC.w #$0005-1
	CMP.w #$0080-5 ; default to slots 0-4 if bad value
	BCS CollectAncilla

	PHA
	TXA
	ADC 1,S
	TAX
	PLA

;---------------------------------------------------------------------------------------------------

CollectAncilla:
	LDA.b $00,X : STA.w SA1IRAM.LINEVAL+0,Y
	LDA.b $02,X : STA.w SA1IRAM.LINEVAL+2,Y
	LDA.b $04,X : STA.w SA1IRAM.LINEVAL+4,Y

	RTS

;===================================================================================================



