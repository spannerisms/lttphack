;===================================================================================================

LITESTATES_SUBMENU:
%menu_header("LITE STATES")
	%litestate("Lite State 01", $00)
	%litestate("Lite State 02", $01)
	%litestate("Lite State 03", $02)
	%litestate("Lite State 04", $03)
	%litestate("Lite State 05", $04)
	%litestate("Lite State 06", $05)
	%litestate("Lite State 07", $06)
	%litestate("Lite State 08", $07)
	%litestate("Lite State 09", $08)
	%litestate("Lite State 10", $09)
	%litestate("Lite State 11", $0A)
	%litestate("Lite State 12", $0B)
	%litestate("Lite State 13", $0C)
	%litestate("Lite State 14", $0D)
	%litestate("Lite State 15", $0E)
	%litestate("Lite State 16", $0F)

;===================================================================================================

GetLiteStateOffset:
	AND.w #$00FF
	XBA
	ASL
	ASL
	ASL
	RTS

;===================================================================================================

ValidateLiteState:
	PHP
	REP #$30
	PHX
	PHY
	PHB

	PHK
	PLB

	JSR GetLiteStateOffset
	TAX
	STA.w SA1IRAM.litestate_off

	LDY.w #$0000
	SEP #$20

.test_header
	LDA.w LiteStateHeader,Y
	CMP.l LiteStateData,X
	BNE .fail

	INY
	INX
	CPY.w #$0010 : BCC .test_header

	SEC
	BRA .set_return

.fail
	CLC

	; set carry flag for P pulled
.set_return
	LDA 6,S
	AND.b #$FE
	ADC.b #$00
	STA 6,S

	PLB

	REP #$10
	PLY
	PLX
	PLP

	RTL

;===================================================================================================

LiteStateHeader:
	;  "0123456789ABCDEF"
	db "LITESTATELUIV001"

;===================================================================================================

DeleteLiteState:
	PHP
	REP #$30
	PHX
	PHY

	JSR GetLiteStateOffset
	TAX

	LDA.w #$0000
	STA.l LiteStateData+$0,X
	STA.l LiteStateData+$2,X
	STA.l LiteStateData+$4,X
	STA.l LiteStateData+$6,X
	STA.l LiteStateData+$8,X
	STA.l LiteStateData+$A,X
	STA.l LiteStateData+$C,X
	STA.l LiteStateData+$E,X

	PLY
	PLX
	PLP

	RTL

;===================================================================================================

; save room data to sram before saving
; hold Y to set
; hold X to clear
; press A to load
; save preset type so loadlastpreset works with these
SaveLiteState:
	PHP
	REP #$30
	PHA
	PHX
	PHY
	PHD
	PHB

	SEP #$20

	LDA.w $008A : BMI .banned
	LDA.w $0010 : CMP.b #$06 : BEQ .banned

	REP #$20
	; map
	; header (0x10 bytes)
	; SRAM (0x402 bytes)
	; Overlords+Sprites ($F0)
	; Overlords+Sprites ($30)
	; Sprites (0x200 bytes)
	PHD : PHK : PLB

	PEA.w $0000
	PLD
	JSL $02B87B
	PLD

	REP #$30

	LDA.w SA1IRAM.litestate_act
	JSR GetLiteStateOffset
	TAY

	LDA.w #$000F
	LDX.w #LiteStateHeader
	%MVN(LiteStateHeader>>16,LiteStateData>>16)

	PHK
	PLB

	SEP #$20

	LDA.b #$80
	JSR DMALiteStates

.exit
	REP #$30
	PLB
	PLD
	PLY
	PLX
	PLA
	PLP
--	RTL

.banned
	JSL MenuSFX_error
	BRA .exit

;===================================================================================================

LoadLiteState:
	REP #$30

	JSL ValidateLiteState
	BCC --

	STZ.w SA1IRAM.preset_addr
	LDA.w SA1IRAM.litestate_last

	JSR GetLiteStateOffset
	ADC.w #$0010
	TAY

	PHK
	PLB

	SEP #$20

	LDA.b #$80 : STA.w $2100 : STA.w $0013
	STZ.w $4200

	LDA.b #$00
	JSR DMALiteStates

	JSL HandleCustomLoadout
	JSL SetHUDItemGraphics

	JSL FixLinkEquipment

	JSL ApplyAfterLoading

	SEP #$30
	JSL Rerandomize

	JML TriggerTimerAndReset

;===================================================================================================

LiteSRAMSize = $0402

DMALiteStates:
	STZ.w $4200

	REP #$10

	STA.w $4350

	LDA.b #$80 : STA.w $4351 ; wram

	STY.w $4352
	LDA.b #LiteStateData>>16 : STA.w $4354

	STZ.w $2183
	LDY.w #$F000 : STY.w $2181
	LDY.w #LiteSRAMSize : STY.w $4355

	LDA.b #$20 : STA.w $420B

	LDX.w #.utmost_importance
	JSR .do_transfer

	; room stuff
	LDA.w $001B : BEQ .dumb_fake_room

	REP #$20
	LDA.w $00A0
	ASL
	CLC
	ADC.w #$DF80
	TAY
	SEP #$20
	BRA .not_dumb_fake_room

.dumb_fake_room
	LDY.w #$FF00

.not_dumb_fake_room
	STY.w $2181

	LDA.b #$7F : STA.w $2183
	LDY.w #$0002 : STY.w $4355
	LDA.b #$20 : STA.w $420B

	NOP

	STZ.w $2183

	; back to normal transfers
	LDY.w $4352
	STY.w SA1RAM.LiteStateDupeOffset ; remember location of data
	JSR .do_duped_importance

	LDA.w $4350 : CMP.b #$80 : BEQ .saving

	JSR SaveATonLiteState
	JSR SaveATonLiteState

	JSL ResetBeforeLoading

	JSR PullATonLiteState

	JSR .do_duped_importance

	LDA.b $1B : BEQ .overworld

.underworld
	; save important values
	LDA.l $7E0468 : PHA ; shutters
	LDA.l $7EC172 : PHA ; pegs

	LDA.w $010E : JSL SetDungeonEntranceAndProperties

	JSL PresetLoadArea_UW

	SEP #$20
	LDA.b #$01 : STA.w $4200

	PLA : JSL HandlePegState
	SEP #$20
	PLA : JSL HandleOpenShutters

	REP #$20
	LDA.w #$0007 : STA.b $10

	BRA .done_stuff_1

.overworld
	REP #$20

	LDA.b $E2 : STA.w $011E
	LDA.b $E0 : STA.w $0120
	LDA.b $E6 : STA.w $0124
	LDA.b $E8 : STA.w $0122

	JSL HandleOverworldLoad

.done_stuff_1
	JSR PullATonLiteState

	JSR .do_duped_importance

.saving
	LDX.w #.less_importance
	JSR .do_transfer

	LDA.b $4350 : BPL .done_loading

	; Some dumb after hacks
	LDA.b $5D
	CMP.b #$04 : BEQ .leave_state
	CMP.b #$17 : BEQ .leave_state

.leave_state

.done_loading
.done_set
	RTS

;---------------------------------------------------------------------------------------------------

.do_duped_importance
	LDY.w SA1RAM.LiteStateDupeOffset
	STY.w $4352

	LDX.w #.duped_importance

.do_transfer
	LDY.w $0000,X
	BEQ .done_set

	STY.w $2181

	LDA.w $0002,X : STA.w $2183

	LDA.w $0003,X
	STA.w $4355 : STZ.w $4356

	LDA.b #$20 : STA.w $420B

	INX : INX : INX : INX
	BRA .do_transfer

;===================================================================================================

	; dl addr : db size
.utmost_importance
	dl $7E001B : db $01 ; indoorsness
	dl $7E00A0 : db $04 ; UW screen ID
	dl $7E008A : db $04 ; OW screen ID
	dl $7E0020 : db $04 ; coordinates

	dl $7E002F : db $01 ; direction
	dl $7E0084 : db $06 ; OW tilemap
	dl $7E00EE : db $01 ; layer
	dl $7E010E : db $02 ; entrance
	dl $7E0303 : db $01 ; item
	dl $7E0468 : db $01 ; shutters
	dl $7E0476 : db $01 ; layer
	dl $7E048E : db $02 ; room ID
	dl $7E0AA0 : db $18 ; gfx

	dw $0000 ; end

	; these few things need reinforcement to preserve them, unfortunately
.duped_importance
	dl $7E0400 : db $0D ; dungeon stuff + overworld screen ID
	dl $7E0600 : db $20 ; camera stuff
	dl $7E00E0 : db $04 ; camera
	dl $7E00E6 : db $04 ; camera
	dl $7E0ABD : db $01 ; color math
	dl $7EC172 : db $01 ; pegs
	dw $0000 ; end

.less_importance
	dl $7E0046 : db $01 ; i frames
	dl $7E0056 : db $01 ; bunny
	dl $7E005B : db $01 ; falling
	dl $7E005D : db $01 ; state
	dl $7E006C : db $01 ; door state
	dl $7E00A4 : db $07 ; floor and quadrants
	dl $7E00B7 : db $05 ; object pointers
	dl $7E0130 : db $03 ; music stuff
	dl $7E0136 : db $01 ; music bank
	dl $7E029E : db $05 ; ancilla altitude
	dl $7E02E0 : db $01 ; bunny
	dl $7E02E2 : db $01 ; bunny
	dl $7E02FA : db $01 ; statue drag
	dl $7E031F : db $01 ; i frames
	dl $7E0345 : db $01 ; swimming
	dl $7E03C4 : db $01 ; ancilla index
	dl $7E044A : db $02 ; EG strength
	dl $7E045A : db $02 ; torches lit
	dl $7E047A : db $01 ; armed EG
	dl $7E04F0 : db $04 ; torch timers
	dl $7E0624 : db $08 ; camera stuff
	dl $7E0642 : db $01 ; shutter tags
	dl $7E0B08 : db $02 ; overlord
	dl $7E0B10 : db $02 ; overlord
	dl $7E0B20 : db $02 ; overlord
	dl $7E0CF7 : db $01 ; bush prizes
	dl $7E0CF9 : db $04 ; drop luck and trees
	dl $7E0FC7 : db $08 ; prize packs
	dl $7E1ABF : db $01 ; mirror portal
	dl $7E1ACF : db $01 ; mirror portal
	dl $7E1ADF : db $01 ; mirror portal
	dl $7E1AEF : db $01 ; mirror portal
	dl $7EC140 : db $31 ; cache stuff
	dl $7EC180 : db $2A ; cache stuff
	dw $0000 ; end

;===================================================================================================

SaveATonLiteState:
	REP #$30
	PLA

	PHP
	PHD
	PHY
	PHX

	PHK
	PLB

	LDY.w $4350 : PHY
	LDY.w $4352 : PHY
	LDY.w $4354 : PHY
	LDY.w $4356 : PHY

	PHA

	LDA.w #$0000
	TCD

	SEP #$30

	RTS

PullATonLiteState:
	REP #$30
	PLA

	PHK
	PLB

	PLY : STY.w $4356
	PLY : STY.w $4354
	PLY : STY.w $4352
	PLY : STY.w $4350

	PLX
	PLY
	PLD
	PLP

	PHA
	SEP #$20
	RTS

;===================================================================================================
