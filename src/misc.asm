pushpc

org $02B793 : JML triforce_transition

org $06F99E : JML dropluck
afterdropluck:

org $1CF640 : JSL swordbeams

org $01CA66
	JSL set_moving_wall_speed
	RTS

org $01F473 : JSL GetLitRoom
org $01F50A : JSL GetLitRoom
org $028204 : JSL GetLitRoom
org $028A7E : JSL GetLitRoom
org $02A148 : JSL GetLitRoom

org $05C21D
	JML probe_draw
after_probe_draw:

pullpc

;===================================================================================================

GetLitRoom:
	LDA.w !config_lit_rooms_toggle : BNE ++
	LDA.l $02A0DC,X
	RTL

++	LDA.b #$00
	RTL

;===================================================================================================

triforce_transition:
	LDA.w !config_skip_triforce_toggle : BNE .skip_triforce

	JSL $02A0BE
	JML $02B797

.skip_triforce
	JML $02B7A1

;===================================================================================================

dropluck:
	PHA ; overwrote PHA : LDY addr, so LEAVE UNBALANCED

	; use this value when it isn't 0 or "random"
	; use vanilla value when this is 0 so that it can be used
	; by people who want to test fairy stuff I guess
	LDY.w SA1RAM.drop_rng : BNE .overwrite

.vanilla
	LDY.w $0CF9

.overwrite
	JML afterdropluck

;===================================================================================================

swordbeams:
	LDY.w SA1RAM.disable_beams : BNE .nobeams

	JML $099D04

.nobeams
	SEC ; indicates failed to add an ancilla

	RTL

;===================================================================================================

set_moving_wall_speed:
	LDA.w !config_fast_moving_walls : BNE .fast

.vanilla
	LDA.w #$2200 : CLC : ADC.w $041C : STA.w $041C
	ROL : AND.w #$0001

	RTL

.fast
	LDA.w #$0008

	RTL

;===================================================================================================

probe_draw:
	LDA.w !config_probe_toggle : BNE .draw

.vanilla
	LDA.b $01 : ORA.b $03
	JML after_probe_draw

.draw
	LDA.b $00 : STA.b ($90),Y
	LDA.b $01 : CMP.b #$01
	LDA.b #$01 : ROL : STA.b ($92)
	REP #$21
	LDA.b $02 : INY
	ADC.w #$0010 : CMP.w #$0100 : SEP #$20 : BCS .skip
	SBC.b #$0F : STA.b ($90),Y
	INY
	LDA.b #$AA : STA.b ($90),Y
	INY
	LDA.b $05 : AND.b #$30
	ORA.b #$0E : STA.b ($90),Y
.skip
	LDA.b $01 : ORA.b $03
	JML after_probe_draw

;===================================================================================================

MantlePrep:
	LDA.w $0D00,X
	CLC
	ADC.b #$03
	STA.w $0D00,X

	LDA.l $7EF3C5
	CMP.b #$02

	LDA.w $0D10,X
	BCS .move

.stay
	ADC.b #$08
	STA.w $0D10,X
--	RTL

.move
	ADC.b #$22
	STA.w $0D10,X
	BCC --

	INC.w $0D30,X

	RTL

;===================================================================================================

RoomHasPitDamage:
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x000
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x008
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x010
	db 0, 0, 1, 0, 1, 0, 0, 0 ; 0x018
	db 0, 0, 0, 0, 1, 0, 0, 0 ; 0x020
	db 0, 0, 1, 0, 0, 0, 0, 0 ; 0x028
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x030
	db 0, 0, 0, 0, 1, 0, 0, 0 ; 0x038
	db 1, 0, 0, 0, 1, 0, 0, 0 ; 0x040
	db 0, 1, 0, 1, 1, 0, 1, 0 ; 0x048
	db 0, 0, 0, 0, 0, 0, 1, 1 ; 0x050
	db 1, 0, 0, 0, 1, 0, 0, 0 ; 0x058
	db 0, 0, 0, 0, 0, 0, 0, 1 ; 0x060
	db 1, 0, 0, 0, 0, 0, 0, 0 ; 0x068
	db 0, 0, 1, 0, 0, 0, 0, 0 ; 0x070
	db 0, 0, 0, 1, 1, 1, 0, 1 ; 0x078
	db 0, 0, 1, 0, 0, 0, 0, 0 ; 0x080
	db 0, 0, 0, 1, 0, 1, 0, 0 ; 0x088
	db 0, 0, 1, 0, 0, 1, 1, 0 ; 0x090
	db 1, 0, 0, 1, 1, 1, 0, 0 ; 0x098
	db 1, 0, 1, 1, 0, 1, 0, 0 ; 0x0A0
	db 0, 0, 0, 0, 0, 0, 0, 1 ; 0x0A8
	db 0, 0, 0, 0, 1, 1, 0, 0 ; 0x0B0
	db 0, 0, 0, 0, 1, 0, 0, 0 ; 0x0B8
	db 1, 0, 0, 1, 0, 1, 1, 1 ; 0x0C0
	db 0, 1, 0, 0, 0, 0, 0, 0 ; 0x0C8
	db 0, 1, 0, 0, 0, 1, 1, 0 ; 0x0D0
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x0D8
	db 0, 0, 0, 0, 0, 0, 1, 1 ; 0x0E0
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x0E8
	db 1, 1, 0, 0, 0, 0, 0, 0 ; 0x0F0
	db 0, 0, 0, 1, 0, 0, 0, 0 ; 0x0F8
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x100
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x108
	db 0, 0, 1, 0, 0, 0, 0, 0 ; 0x110
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x118
	db 1, 0, 0, 1, 0, 0, 0, 0 ; 0x120
	db 0, 0, 0, 0, 0, 0, 0, 0 ; 0x128

;===================================================================================================

CheckItemReceipt:
	STY.w $02E4

	LDA.w !config_vanillaitems
	BNE .return

	LDX.w $02D8

	LDA.l ReplaceVanilla,X
	STA.w $02D8

.return
	RTL

jnk = $45
ReplaceVanilla:
	db jnk ; 00 - FIGHTER SWORD
	db jnk ; 01 - MASTER SWORD
	db jnk ; 02 - TEMPERED SWORD
	db jnk ; 03 - BUTTER SWORD
	db jnk ; 04 - FIGHTER SHIELD
	db jnk ; 05 - FIRE SHIELD
	db jnk ; 06 - MIRROR SHIELD
	db jnk ; 07 - FIRE ROD
	db jnk ; 08 - ICE ROD
	db jnk ; 09 - HAMMER
	db jnk ; 0A - HOOKSHOT
	db jnk ; 0B - BOW
	db jnk ; 0C - BOOMERANG
	db jnk ; 0D - POWDER
	db $0E ; 0E - BOTTLE REFILL (BEE)
	db jnk ; 0F - BOMBOS
	db jnk ; 10 - ETHER
	db jnk ; 11 - QUAKE
	db jnk ; 12 - LAMP
	db jnk ; 13 - SHOVEL
	db jnk ; 14 - FLUTE
	db jnk ; 15 - SOMARIA
	db jnk ; 16 - BOTTLE
	db jnk ; 17 - HEART PIECE
	db jnk ; 18 - BYRNA
	db jnk ; 19 - CAPE
	db jnk ; 1A - MIRROR
	db jnk ; 1B - GLOVE
	db jnk ; 1C - MITTS
	db jnk ; 1D - BOOK
	db jnk ; 1E - FLIPPERS
	db jnk ; 1F - PEARL
	db $20 ; 20 - CRYSTAL
	db jnk ; 21 - NET
	db jnk ; 22 - BLUE MAIL
	db jnk ; 23 - RED MAIL
	db $24 ; 24 - SMALL KEY
	db $25 ; 25 - COMPASS
	db jnk ; 26 - HEART CONTAINER FROM 4/4
	db $27 ; 27 - BOMB
	db $28 ; 28 - 3 BOMBS
	db jnk ; 29 - MUSHROOM
	db jnk ; 2A - RED BOOMERANG
	db $2B ; 2B - FULL BOTTLE (RED)
	db $2C ; 2C - FULL BOTTLE (GREEN)
	db $2D ; 2D - FULL BOTTLE (BLUE)
	db $2E ; 2E - POTION REFILL (RED)
	db $2F ; 2F - POTION REFILL (GREEN)
	db $30 ; 30 - POTION REFILL (BLUE)
	db $31 ; 31 - 10 BOMBS
	db $32 ; 32 - BIG KEY
	db $33 ; 33 - MAP
	db $34 ; 34 - 1 RUPEE
	db $35 ; 35 - 5 RUPEES
	db $36 ; 36 - 20 RUPEES
	db $37 ; 37 - GREEN PENDANT
	db $38 ; 38 - BLUE PENDANT
	db $39 ; 39 - RED PENDANT
	db jnk ; 3A - TOSSED BOW
	db jnk ; 3B - SILVERS
	db jnk ; 3C - FULL BOTTLE (BEE)
	db jnk ; 3D - FULL BOTTLE (FAIRY)
	db jnk ; 3E - BOSS HC
	db jnk ; 3F - SANC HC
	db $40 ; 40 - 100 RUPEES
	db $41 ; 41 - 50 RUPEES
	db $42 ; 42 - HEART
	db $43 ; 43 - ARROW
	db $44 ; 44 - 10 ARROWS
	db $45 ; 45 - SMALL MAGIC
	db $46 ; 46 - 300 RUPEES
	db $47 ; 47 - 20 RUPEES GREEN
	db jnk ; 48 - FULL BOTTLE (GOOD BEE)
	db jnk ; 49 - TOSSED FIGHTER SWORD
	db jnk ; 4A - FLUTE (ACTIVATED)
	db jnk ; 4B - BOOTS

;===================================================================================================


