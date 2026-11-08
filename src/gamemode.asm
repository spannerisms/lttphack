pushpc

org $008039
RequestShortcut:
	BIT.w IRAM.shortcut_used+1
	BPL .ask_for_shortcut

	JSL UseShortCut

	SEP #$30
	STZ.w IRAM.shortcut_used+1
	BRA .done

.ask_for_shortcut
	LDA.b #$81
	STA.w CCNT ; SA-1 IRQ, bit 1 for preparing shortcut checks
	BRA .done

safeorg $008051 : .done

pullpc

;===================================================================================================

ResetGameStack:
	REP #$FF

	LDA.w #$01FF : TCS
	LDA.w #$0000 : TCD

	STZ.b $F0 : STZ.w IRAM.copyof_F0
	STZ.b $F2 : STZ.w IRAM.copyof_F2
	STZ.b $F4 : STZ.w IRAM.copyof_F4
	STZ.b $F6 : STZ.w IRAM.copyof_F6

	STZ.w IRAM.SEG_TIME_F
	STZ.w IRAM.SEG_TIME_S
	STZ.w IRAM.SEG_TIME_M

	STZ.w IRAM.shortcut_used

	SEP #$30

	PHA : PLB

	STZ.b $12

	LDA.b #$0F : STA.b $13
	LDA.b #$81 : STA.w NMITIMEN

	JML jlong($008034)

;===================================================================================================

Rerandomize:
	LDA.w CONFIG.rerandomize : BEQ .dont_rerandomize

	REP #$20

	LDA.w IRAM.randomish

	SEP #$20

	STA.b $1A
	XBA
	STA.w $0FA1

.dont_rerandomize
	LDA.w BWRAM.framerule
	DEC
	BMI .no_fixed_framerule

	STA.b $1A

.no_fixed_framerule
	RTL

;===================================================================================================

UseShortCut:
	REP #$20

	; kill controller so SA-1 doesn't get confused next frame
	STZ.b $F0 : STZ.w IRAM.copyof_F0
	STZ.b $F2 : STZ.w IRAM.copyof_F2
	STZ.b $F4 : STZ.w IRAM.copyof_F4
	STZ.b $F6 : STZ.w IRAM.copyof_F6

	SEP #$20

	LDA.b $10
	CMP.b #$06 : BCC ShortcutsBanned
	CMP.b #$19 : BCS ShortcutsBanned
	CMP.b #$14 : BEQ ShortcutsBanned

	JMP.w (IRAM.shortcut_used)

;===================================================================================================

UseShortCutSA1:
	DEC
	PHA
	RTS

;===================================================================================================

ShortcutsBanned:
	SEP #$20

	LDA.b #$3C : STA.w APUIO2

SA1SideShortcut:
	RTL

;===================================================================================================

Shortcut_EnterPracticeMenu:
	JML CM_Main

;===================================================================================================

Shortcut_LoadLastPreset:
	JML LoadLastPreset

;===================================================================================================

Shortcut_SaveState:
	SEP #$20

	LDA.b $10 : CMP.b #$06 : BNE .can_state

	JMP ShortcutsBanned

.can_state
	PHK
	PLB

	REP #$10
	; Remember which song bank was loaded before load stating
	; I put it here too, since .end code runs both on save and load state..
	LDA.w $0136 : STA.w BWRAM.old_music_bank

	STZ.w NMITIMEN
	STZ.w HDMAEN

	LDA.b #$80 : STA.w INIDISP
	STA.w DMAP5 ; B to A
	JSR DMA_BWRAMSRAM

	JMP FinalizeSavestate

;===================================================================================================

Shortcut_LoadState:
	; music bank should only ever be 0 or 1
	; assume any other value means there's no save state
	SEP #$30

	LDA.w BWRAM.old_music_bank
	CMP.b #$02 : BCC .have_state

	JMP ShortcutsBanned

.have_state
	PHK
	PLB

	SEP #$20
	REP #$10

	; Remember which song and bank was in APU before load stating (so we can change if needed)
	LDA.w $0136 : STA.w BWRAM.old_music_bank
	LDA.w $0130 : STA.w BWRAM.old_music

	; Mute ambient sounds
	LDA.b #$05 : STA.w APUIO1

	LDA.b #$80 : STA.w INIDISP
	STZ.w HDMAEN
	STZ.w NMITIMEN

	LDA.b #$00 : STA.w DMAP5
	JSR DMA_BWRAMSRAM

	LDX.b $1C : STX.w TM
	LDX.b $1E : STX.w TMW
	LDX.b $94 : STX.w BGMODE
	LDX.b $96 : STX.w W12SEL
	LDX.b $99 : STX.w CGWSEL

	INC.b $15

	; Update which song is currently being played by the APU
	LDA.w BWRAM.old_music : STA.w $0133

	; Attempt to restart the current song if it isn't already playing
	LDA.w $0130 : STA.w $012C

	LDA.w $0131 : CMP.b #$17 : BEQ .annoying_sounds ; Bird music
	STA.w $012D : STZ.w $0131

.annoying_sounds
	LDA.w $0638 : STA.w M7X
	LDA.w $0639 : STA.w M7X
	LDA.w $063A : STA.w M7Y
	LDA.w $063B : STA.w M7Y
	LDA.b $98 : STA.w WOBJSEL
	LDA.b $9B : STA.w HDMAEN

	JSL Rerandomize

	SEP #$20

	JMP FinalizeSavestate

;===================================================================================================

DMA_BWRAMSRAM:
	PLX : STX.w IRAM.preset_scratch

	STA.w DMAP5 ; direction
	LDA.b #WMDATA : STA.w BBAD5 ; wram
	LDA.b #^SaveStateData : STA.w DMA5ADDRB

	LDX.w #$0000
	STX.w DMA5ADDRL ; bottom of bank

.next
	LDA.w .address_size+2,X ; get bank
	BEQ .last_buffers

	STA.w WMADDB

	LDY.w .address_size+0,X
	STY.w WMADDL

	LDY.w .address_size+3,X
	STY.w DMA5SIZE

	LDA.b #$20 : STA.w MDMAEN

	INX
	INX
	INX
	INX
	INX
	BRA .next

; need a completely separate space for this shit
.last_buffers
	STZ.w WMADDB
	LDY.w DMA5ADDRL : PHY ; get last location written

	LDA.b #^SaveStateExtra : STA.w DMA5ADDRB
	LDY.w #$C000 : STY.w DMA5ADDRL

	LDY.w #$6000 : STY.w WMADDL
	LDY.w #$3000 : STY.w DMA5SIZE
	LDA.b #$20   : STA.w MDMAEN

	LDA.b #$01   : STA.w WMADDB
	LDY.w #$4000 : STY.w WMADDL
	LDY.w #$1000 : STY.w DMA5SIZE
	LDA.b #$20   : STA.w MDMAEN

	PLY : STY.w DMA5ADDRL

	PHB
	REP #$20

	LDA.w #SavedVarsSize-1

	BIT.w DMAP5-1 ; which way to transfer?
	BPL .loading

.saving
	LDX.w #IRAM.savethis_start
	LDY.w DMA5ADDRL ; get location last written
	MVN $00, ^SaveStateData

	LDA.l HUD_NMI_DMA_SIZE : DEC
	LDX.w #BWRAM.HUD
	MVN $00, ^SaveStateData

	; DMA
	LDA.w #$004F
	LDX.w #$4300
	MVN $00, ^SaveStateData

	; HDMA
	LDA.w #$001F
	LDX.w #$4360
	MVN $00, ^SaveStateData
	BRA .done

.loading
	LDY.w #IRAM.savethis_start
	LDX.w DMA5ADDRL ; get location last written
	MVN ^SaveStateData, $00

	LDA.l HUD_NMI_DMA_SIZE : DEC
	LDY.w #BWRAM.HUD
	MVN ^SaveStateData, $00

	; DMA
	LDA.w #$004F
	LDY.w #$4300
	MVN ^SaveStateData, $00

	; HDMA
	LDA.w #$001F
	LDY.w #$4360
	MVN ^SaveStateData, $00

.done
	PLB

	SEP #$20

	LDX.w IRAM.preset_scratch : PHX

	RTS

;---------------------------------------------------------------------------------------------------

!SaveStateSize = 0
macro SaveStateBlock(addr, blocksize)
	dl {addr} : dw {blocksize}
	!SaveStateSize += {blocksize}
endmacro

.address_size
	%SaveStateBlock($7E0000, $0220)
	%SaveStateBlock($7E0280, $024B)
	%SaveStateBlock($7E04F0, $0158)
	%SaveStateBlock($7E0670, $00A8)
	%SaveStateBlock($7E0800, $11EA)
	%SaveStateBlock($7E1A00, $0078)
	%SaveStateBlock($7E1AB0, $03B8)
	%SaveStateBlock($7E1F00, $4100)
	%SaveStateBlock($7E9000, $0480)
	%SaveStateBlock($7EA680, $0C00)
	%SaveStateBlock($7EB940, $0480)
	%SaveStateBlock($7EC000, $0025)
	%SaveStateBlock($7EC100, $00AB)
	%SaveStateBlock($7EC200, $002A)
	%SaveStateBlock($7EC2F8, $0408)
	%SaveStateBlock($7EC880, $0080)
	%SaveStateBlock($7EE800, $0D00)
	%SaveStateBlock($7EF580, $0840)
	%SaveStateBlock($7EFE00, $0200)

	%SaveStateBlock($7F0000, $4000)
	%SaveStateBlock($7F5800, $0702)
	%SaveStateBlock($7F6918, $0001)
	%SaveStateBlock($7F7000, $01C0)
	%SaveStateBlock($7FDD80, $1400)
	%SaveStateBlock($7FF800, $0800)

	HUDBWRAMLOC = SaveStateData+!SaveStateSize
	TotalSaveStateSize = !SaveStateSize+$70+$800

	if TotalSaveStateSize > $FFFF
		error "Save states are too big!!!"
	endif

	printf "Save state size: ${0:X4}", !SaveStateSize
	dl 0

;===================================================================================================

FinalizeSavestate:
	LDA.w DMAP5
	ORA.b #$01
	STA.w DMAP5
	BMI .saving

.loading
	LDA.b #VMDATA
	CLV ; clear overflow for loading
	BRA .continue

.saving
	LDA.b #VMREADL
	SEP #$40 ; set overflow for saving

.continue
	STA.w BBAD5

	LDA.b #$80
	STA.w VMAIN

	LDX.w #$0000
	STX.w DMA5ADDRL

	LDA.b #^SaveStateVram
	STA.w DMA5ADDRB

	STX.w DMA5SIZE
	STX.w VMADDR
	BVC .no_dummy_read

	; necessary dummy read
	LDY.w VMREADL

.no_dummy_read
	LDA.b #$20 : STA.w MDMAEN
	; after vram is loaded, need to quickly swap in the sentry icons that may or may not be different
	BVS .no_sentry_icons

	JSL AddSentryIcons
	SEP #$30

.no_sentry_icons
	LDA.w BWRAM.old_music_bank : CMP.w $0136 : BEQ .song_bank_not_changed

	SEP #$34 ; I flag too

	STZ.w NMITIMEN
	STZ.w HDMAEN

	LDA.b #$FF : STA.w APUIO0

	LDA.b $1B : STA.w $0136
	BEQ .indoors

	JSL jlong($008925)
	BRA .reset

.indoors
	JSL jlong($008913)

.song_bank_not_changed
	; i hope this works
	; now we just reset to the main game loop

.reset
	JML ResetGameStack

;===================================================================================================

Shortcut_ToggleOoB:
	SEP #$20

	LDA.w $037F
	AND.b #$01 ; just in case
	EOR.b #$01
	STA.w $037F

	RTL

;===================================================================================================

Shortcut_ToggleCrystalSwitch:
	REP #$20

	LDA.b $10
	CMP.w #$0007

	SEP #$20
	BNE .not_safe

	LDA.l $7EC172 : EOR.b #$01 : STA.l $7EC172

	LDA.b #$16 : STA.b $11
	LDA.b #$25 : STA.w $012F

.not_safe
	RTL

;===================================================================================================

Shortcut_SkipText:
	SEP #$20

	LDA.b #$04 : STA.w $1CD4

	RTL

;===================================================================================================

Shortcut_DisableSprites:
	SEP #$20
	JML jlong($09C44E) ; Disable all sprites

;===================================================================================================

Shortcut_FillEverything:
	REP #$30
	SEP #$20

	PHB
	PHK
	PLB

	LDY.w #0
	LDX.w #$F340

.next_item
	LDA.w .table,Y ; value we're writing
	STA.l $7E0000,X

	INY

	INX
	CPX.w #$F37C
	BCC .next_item

.itemsover
	; do keys
	LDA.l $1B ; are we indoors?
	BEQ .no_keys

	LDA.w $040C ; are we in a dungeon?
	BMI .no_keys

	LDA.b #$09 : STA.l $7EF36F

.no_keys
	LDA.l $7EF3C5 : BNE .ignore_progress

	INC : STA.l $7EF3C5

.ignore_progress
	SEP #$30

	JSL FixLinkEquipment

	PLB
	RTL

;---------------------------------------------------------------------------------------------------

.table
	db 4   ; $F340 - silver bow w/ arrows
	db 2   ; $F341 - red boomerang
	db 1   ; $F342 - hookshot
	db 30  ; $F343 - max bombs
	db 2   ; $F344 - powder
	db 1   ; $F345 - fire rod
	db 1   ; $F346 - ice rod
	db 1   ; $F347 - bombos
	db 1   ; $F348 - ether
	db 1   ; $F349 - quake
	db 1   ; $F34A - lamp
	db 1   ; $F34B - hammer
	db 3   ; $F34C - active flute
	db 1   ; $F34D - bug net
	db 1   ; $F34E - book
	db 1   ; $F34F - bottles: slot 1 selected
	db 1   ; $F350 - somaria
	db 1   ; $F351 - byrna
	db 1   ; $F352 - cape
	db 2   ; $F353 - mirror
	db 2   ; $F354 - titan's mitt
	db 1   ; $F355 - boots
	db 1   ; $F356 - flippers
	db 1   ; $F357 - pearl
	db 0   ; $F358 - unused
	db 4   ; $F359 - gold sword
	db 3   ; $F35A - mirror shield
	db 2   ; $F35B - red mail
	db 4   ; $F35C - green potion
	db 3   ; $F35D - red potion
	db 5   ; $F35E - blue potion
	db 6   ; $F35F - fairy
	db $E7 ; $F360 - rupees
	db $03 ; $F361 - high byte
	db $E7 ; $F362 - rupees
	db $03 ; $F363 - high byte
	db $FF ; $F364 - every compass
	db $FF ; $F365 - more compasses
	db $FF ; $F366 - every big key
	db $FF ; $F367 - more big keys
	db $FF ; $F368 - every map
	db $FF ; $F369 - more maps
	db 0   ; $F36A - fairy donation
	db 0   ; $F36B - heart pieces
	db $A0 ; $F36C - 20 hearts
	db $98 ; $F36D - 1 less than max health
	db $78 ; $F36E - full magic - 8
	db $FF ; $F36F - keys
	db 7   ; $F370 - max bomb upgrades
	db 7   ; $F371 - max arrow upgrades
	db 0   ; $F372 - prevent filling of hp
	db 0   ; $F373 - prevent filling of magic
	db $07 ; $F374 - every pendant
	db 0   ; $F375 - prevent filling of bombs
	db 0   ; $F376 - prevent filling of arrows
	db 50  ; $F377 - max arrows
	db 0   ; $F378 - unused
	db $FE ; $F379 - every ability
	db $7F ; $F37A - every crystal
	db 1   ; $F37B - half magic

;===================================================================================================

Shortcut_ResetSegmentTimer:
	REP #$20

	STZ.w IRAM.SEG_TIME_F
	STZ.w IRAM.SEG_TIME_S
	STZ.w IRAM.SEG_TIME_M

	SEP #$20

	LDA.b #$02 : TSB.w IRAM.TIMER_FLAG

	RTL

;===================================================================================================

Shortcut_FixGraphics:
	SEP #$30
	LDA.b #$80 : STA.w INIDISP
	STZ.w NMITIMEN

	REP #$20
	LDA.w #$0280 : STA.w INIDISP
	LDA.w #$0313 : STA.w BG1SC
	LDA.w #$0063 : STA.w BG3SC ; zeros out unused bg4
	LDA.w #$0722 : STA.w BG12NBA
	STZ.w SETINI ; mode 7 register hit, but who cares

	SEP #$F0
	LDA.b $1B : BEQ .no_pegging

	JSL FixGraphics_Underworld
	JSL LoadCustomHUDGFX

	LDA.l $7EC172 : BEQ .no_pegging
	JSR FixGraphics_Pegs

.no_pegging
	LDA.b #$0F : STA.b $13
	LDA.b #$81 : STA.w NMITIMEN

	RTL

;===================================================================================================

FixGraphics_Pegs:
	REP #$30

	PHB

	LDX.w #$B4C0
	LDY.w #$F000
	LDA.w #$007F

	MVN $7E,$7F

	PLB

	SEP #$30

	LDA.b #$17 : STA.b $17

	RTS

;===================================================================================================

FixGraphics_Underworld: ; mostly copied from vanilla
	PHB

	LDA.b #$00 : PHA : PLB

	LDA.b $9B : PHA
	STZ.b $9B : STZ.w HDMAEN

	SEP #$30

	JSL jlong($00834B) ; Tile maps
	JSL jlong($00E1DB) ; Tile sets
	JSL jlong($0DFA8C) ; HUD

.just_redraw
	STZ.w $0418
	STZ.w $045C

.draw_quadrants
	JSL jlong($0091C4)
	JSL jlong($0090E3)
	JSL jlong($00913F)
	JSL jlong($0090E3)

	LDA.w $045C : CMP.b #$10 : BNE .draw_quadrants

	STZ.b $17
	STZ.b $B0

	PLA : STA.b $9B
	PLB

	RTL

;===================================================================================================

Shortcut_ShowPits:
	SEP #$30
	LDA.b $1B : BEQ .exit ; don't do this outdoors

	STZ.w NMITIMEN
	LDA.b #$80 : STA.b $13 : STA.w INIDISP
	STA.w VMAIN

	JSL ShowPits

	LDA.b #$0F : STA.b $13
	LDA.b #$81 : STA.w NMITIMEN

.exit
	RTL

;===================================================================================================

ShowPits:
	!PIT_GFX = $050F
	PHB ; rebalanced in redraw

	PEA $7F00
	PLB

	LDA.b $9B
	STZ.b $9B : STA.w HDMAEN

	PLB
	PHA

	REP #$30

	LDY.w #$0FFE

.next_object
	LDA.w $2000,Y : AND.w #$00FF ; checks tile attributes table
	CMP.w #$0020 : BNE .skip

	STZ.b $00

	TYA : ASL : TAX
	LDA.w #!PIT_GFX : STA.l $7E2000,X
	TXA
	BIT.w #$1000 : BEQ ++

	PHA
	LDA.w #$1000
	STA.b $00
	PLA
	EOR.w #$1000

++	BIT.w #$0040 : BEQ ++

	PHA
	LDA.w #$0800
	TSB.b $00
	PLA
	EOR.w #$0040

++	PHA
	AND.w #$FF80
	LSR
	STA.b $02
	PLA
	SEC ; TODO ADC first then SBC to remove the CLC (b/c LSR)
	SBC.b $02
	CLC
	ADC.b $00
	LSR
	STA.l VMADDR
	LDA.w #!PIT_GFX
	STA.l VMDATA

.skip
	DEY
	BPL .next_object

;---------------------------------------------------------------------------------------------------

	SEP #$30

	STZ.b $17
	STZ.b $B0

	PLA : STA.b $9B

	PLB

	RTL

;===================================================================================================
; DISGUSTING
; No shared slots except bottles
;===================================================================================================
QuickSwap:
	LDA.b $F6 : AND.b #$30 : BEQ .done

	PHX
	LDX.w $0202 : BEQ .done_x

;	CMP.b #$30 : BEQ .swap
	BIT.b #$10 : BEQ .no_r_press

	LDA.b $F2 : BIT.b #$20 : BNE .swap ; .swap_from_last_r
;	STZ.w IRAM.quickswap_lr
.find_r
	JSR .find_next
	BRA .store

.no_r_press
	LDA.b $F2 : BIT.b #$10 : BNE .swap ; .swap_from_last_l
;	STZ.w IRAM.quickswap_lr
.find_l
	JSR .find_prev
	BRA .store

.swap
	CPX.b #$10 : BNE .store ; not bottles
;	STX.w IRAM.quickswap_lr

	JSR FindNextBottle
	BRA .click

.store
	STX.w $0202

.click
	LDA.b #$20 : STA.w $012F

	JSL jlong($0DDB7F)

.done_x
	PLX

.done
	LDA.b $F6 : AND.b #$40
	RTL

;---------------------------------------------------------------------------------------------------

.swap_from_last_r
	LDA.w IRAM.quickswap_lr : BEQ .find_r
	BRA .store

.swap_from_last_l
	LDA.w IRAM.quickswap_lr : BEQ .find_l
	BRA .store

;---------------------------------------------------------------------------------------------------

.find_next
	INX
	CPX.b #$15 : BCC .not_at_end
	LDX.b #$00

.not_at_end
	LDA.l $7EF33F,X : BEQ .find_next
	RTS

.find_prev
	DEX : BPL .not_at_start
	LDX.b #$14
.not_at_start
	LDA.l $7EF33F,X : BEQ .find_prev
	RTS

;---------------------------------------------------------------------------------------------------

FindNextBottle:
	LDA.l $7EF34F
	TAX

.next
	INX : CPX.b #$05 : BCC .test_bottle

	LDX.b #$01

.test_bottle
	LDA.l $7EF35B,X
	BEQ .next

	TXA
	STA.l $7EF34F

	RTS

;---------------------------------------------------------------------------------------------------

BottleMenuButtonPress:
	BIT.b $F4 : BVC .try_x
	JSR FindNextBottle
	RTL

.try_x
	BIT.b $F6 : BVC .exit
	LDA.b #$07 : STA.w $0200

.exit
	RTL

;===================================================================================================
