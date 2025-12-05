;===================================================================================================

FixLinkEquipment:
	PHB
	PHD

	REP #$20
	LDA.w #$0000 : TCD

	SEP #$30
	PHA : PLB

	JSL set_sword
	JSL set_shield
	JSL set_armor

	PLD
	PLB
	RTL

;===================================================================================================

GetLoadoutOffset:
	REP #$30

	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	STA.l SA1IRAM.LoadOutScratch
	ASL
	ADC.l SA1IRAM.LoadOutScratch
	ADC.w #SA1RAM.Loadouts

	RTS

;===================================================================================================

HandleCustomLoadout:
	SEP #$31

	LDA.l SA1RAM.loadout_to_use
	SBC.b #$01
	BCC .exit

#LoadCustomLoadout:
	JSR GetLoadoutOffset
	TAX

	LDY.w #$7EF340

	PHB

	LDA.w #$0021
	%MVN($40, $7E)

	LDA.w $7EF360 : STA.w $7EF362

	SEP #$20

	LDA.l $400000,X : STA.w $7EF36C
	LDA.l $400001,X : STA.w $7EF36D
	LDA.l $400002,X : STA.w $7EF36E
	LDA.l $400003,X : STA.w $7EF370
	LDA.l $400004,X : STA.w $7EF371
	LDA.l $400005,X : STA.w $7EF377
	LDA.l $400006,X : STA.w $7EF37B
	LDA.l $400007,X : STA.w $7E0303

	PLB

	JSL SetFlippersFlag
	JSL SetBootsFlag

	SEP #$31

.exit
	RTL

;===================================================================================================

CacheCurrentEquipment:
	SEP #$30

	LDA.b #$00

;===================================================================================================

SaveCustomLoadout:
	JSR GetLoadoutOffset
	TAY

	LDX.w #$7EF340

	PHB

	LDA.w #$0021
	%MVN($7E, $40)

	SEP #$20

	LDA.l $7EF36C : STA.w $0000,Y
	LDA.l $7EF36D : STA.w $0001,Y
	LDA.l $7EF36E : STA.w $0002,Y
	LDA.l $7EF370 : STA.w $0003,Y
	LDA.l $7EF371 : STA.w $0004,Y
	LDA.l $7EF377 : STA.w $0005,Y
	LDA.l $7EF37B : STA.w $0006,Y
	LDA.l $7E0303 : STA.w $0007,Y

	PLB

	RTL

;===================================================================================================

SetHUDItemGraphics:
	PHD

	PHB
	PHK
	PLB

	PEA.w $3000
	PLD

	SEP #$30

	; fix bow

	LDA.l $7EF340 : BEQ .no_bow
	CMP.b #$05 : BCC .no_bow ; ignore illegal bows

	LDA.l $7EF377 ; get arrows into carry
	CMP.b #$01

	LDA.l $7EF340
	AND.b #$FE
	ADC.b #$00
	STA.l $7EF340

.no_bow
	LDA.b #$7E
	STA.b SA1IRAM.preset_reader+2

	LDY.w $0303
	LDA.w .item_to_menu,Y
	STA.w $0202

	TAX
	LDA.l $7EF340-1,X
	BEQ .empty_slot

	CPY.b #$00

.empty_slot
	REP #$30
	BEQ .missing_item

.have_item
	TYA
	ASL : ASL
	TAY

	LDX.w .item_HUD-4,Y ; bank0D offset
	STX.b SA1IRAM.preset_reader2

	LDA.w .item_HUD-2,Y ; bank7E SRAM val
	STA.b SA1IRAM.preset_reader+0

	LDA.b [SA1IRAM.preset_reader]
	AND.w #$00FF
	BEQ .missing_item

	CPY.w #$0001*4 : BEQ .bombs_adjust
	CPY.w #$000B*4 : BNE .normal_item

.bottle_adjust
	TAX
	LDA.l $7EF35C-1,X
	AND.w #$00FF

.normal_item
	ASL
	ASL
	ASL
	ADC.b SA1IRAM.preset_reader2
	TAX
	BRA .draw_item

.missing_item
	SEP #$30

	TYA
	LSR
	LSR
	STA.b SA1IRAM.preset_reader2

	TAX

.find_items
	DEX
	BPL .no_overflow

	LDX.b #$13

.no_overflow
	CPX.b SA1IRAM.preset_reader2
	BEQ .no_item_at_all

	LDA.l $7EF340,X
	BEQ .find_items

	; find index
	TXA : INC
	LDY.b #$14

.find_index
	CMP.w .item_to_menu,Y
	BEQ .found

	DEY
	BPL .find_index

	BRA .no_item_at_all

.found
	LDA.w .item_to_menu,Y
	STA.w $0202
	STY.w $0303

	REP #$30
	BRA .have_item

.bombs_adjust
	CMP.w #$0001
	BCC .missing_item

	LDA.w #$0001
	BRA .normal_item

.no_item_at_all
	STZ.w $0202
	STZ.w $0303

	REP #$30

.no_item
	LDX.w #$FEE7 ; address happens to have $207F x4

.draw_item
	LDA.l $0D0000,X : STA.w SA1RAM.HUD+$04A
	LDA.l $0D0002,X : STA.w SA1RAM.HUD+$04C
	LDA.l $0D0004,X : STA.w SA1RAM.HUD+$08A
	LDA.l $0D0006,X : STA.w SA1RAM.HUD+$08C

;---------------------------------------------------------------------------------------------------

	; now do the small icons
	LDA.l $7EF340
	AND.w #$00FF
	CMP.w #$0003
	BCC .wooden_arrows

	LDA.w #$2486 : STA.w SA1RAM.HUD+$01E
	LDA.w #$2487 : STA.w SA1RAM.HUD+$020

	BRA .done_arrows

.wooden_arrows
	LDA.w #$20A7 : STA.w SA1RAM.HUD+$01E
	LDA.w #$20A9 : STA.w SA1RAM.HUD+$020

.done_arrows
	LDA.l $7EF37B
	AND.w #$00FF
	BEQ .no_half_magic

	LDA.w #$28F7 : STA.w SA1RAM.HUD+$004
	LDA.w #$2851 : STA.w SA1RAM.HUD+$006
	LDA.w #$28FA : STA.w SA1RAM.HUD+$008
	BRA .done_half_magic

.no_half_magic
	LDA.w #$2850 : STA.w SA1RAM.HUD+$004
	LDA.w #$A856 : STA.w SA1RAM.HUD+$006
	LDA.w #$2852 : STA.w SA1RAM.HUD+$008

.done_half_magic
	PLB
	PLD
	RTL

;---------------------------------------------------------------------------------------------------
	; $0303 -> $0202
.item_to_menu
	db $00 ; $00 - Nothing
	db $04 ; $01 - Bombs
	db $02 ; $02 - Boomerang
	db $01 ; $03 - Bow
	db $0C ; $04 - Hammer
	db $06 ; $05 - Fire Rod
	db $07 ; $06 - Ice Rod
	db $0E ; $07 - Bug catching net
	db $0D ; $08 - Flute
	db $0B ; $09 - Lamp
	db $05 ; $0A - Magic Powder
	db $10 ; $0B - Bottle
	db $0F ; $0C - Book of Mudora
	db $12 ; $0D - Cane of Byrna
	db $03 ; $0E - Hookshot
	db $08 ; $0F - Bombos Medallion
	db $09 ; $10 - Ether Medallion
	db $0A ; $11 - Quake Medallion
	db $11 ; $12 - Cane of Somaria
	db $13 ; $13 - Cape
	db $14 ; $14 - Magic Mirror

	; dw bank0D address, SRAM address
.item_HUD
	dw $0DF699, $7EF343 ; $01 - Bombs
	dw $0DF671, $7EF341 ; $02 - Boomerang
	dw $0DF649, $7EF340 ; $03 - Bow
	dw $0DF721, $7EF34B ; $04 - Hammer
	dw $0DF6C1, $7EF345 ; $05 - Fire Rod
	dw $0DF6D1, $7EF346 ; $06 - Ice Rod
	dw $0DF751, $7EF34D ; $07 - Bug catching net
	dw $0DF731, $7EF34C ; $08 - Flute
	dw $0DF711, $7EF34A ; $09 - Lamp
	dw $0DF6A9, $7EF344 ; $0A - Magic Powder
	dw $0DF771, $7EF34F ; $0B - Bottle
	dw $0DF761, $7EF34E ; $0C - Book of Mudora
	dw $0DF7C9, $7EF351 ; $0D - Cane of Byrna
	dw $0DF689, $7EF342 ; $0E - Hookshot
	dw $0DF6E1, $7EF347 ; $0F - Bombos Medallion
	dw $0DF6F1, $7EF348 ; $10 - Ether Medallion
	dw $0DF701, $7EF349 ; $11 - Quake Medallion
	dw $0DF7B9, $7EF350 ; $12 - Cane of Somaria
	dw $0DF7D9, $7EF352 ; $13 - Cape
	dw $0DF7E9, $7EF353 ; $14 - Magic Mirror

;===================================================================================================

set_sword:
	SEP #$30
	JSL $00D308 ; decomp sword
	JML $1BED03 ; sword palette

set_shield:
	SEP #$30
	JSL $00D348 ; decomp shield
	JML $1BED29 ; shield palette

set_armor:
	SEP #$30
	JML $1BEDF9 ; mail palette

;===================================================================================================

SetFlippersFlag:
	LDA.l $7EF356
	CMP.b #$01

	LDA.l $7EF379
	AND.b #$FD
	BCC .set

	ORA.b #$02

.set
	STA.l $7EF379

	RTL

;===================================================================================================

SetBootsFlag:
	LDA.l $7EF355
	CMP.b #$01

	LDA.l $7EF379
	AND.b #$FB
	BCC .set

	ORA.b #$04

.set
	STA.l $7EF379

	RTL

;===================================================================================================
