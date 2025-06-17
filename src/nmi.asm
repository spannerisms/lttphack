pushpc

; Other interrupt stuff
org $00CF50
BadInterrupt:
	JML OOPS

warnpc $00CFBE

;===================================================================================================

org $00805D
	JML WasteTimeAsNeeded

org $00841E
	if !RANDO
		LDA.l !config_fastrom
		STA.l $420D
	endif

	LDA.b $F0 : STA.w SA1IRAM.CopyOf_F0
	LDA.b $F2 : STA.w SA1IRAM.CopyOf_F2
	LDA.b $F4 : STA.w SA1IRAM.CopyOf_F4
	LDA.b $F6 : STA.w SA1IRAM.CopyOf_F6

	LDA.b #$81 ; fire an IRQ to request shortcuts
	STA.w $2200

	JSL ClearOAM

	SEP #$30

	BIT.w SA1IRAM.SHORTCUT_USED+1
	BMI ++

	RTS

	; if shortcut was used, exit
++	PLA ; remove return point
	PLA

	PEA.w RequestShortcut-1

	RTS

warnpc $008489

org $0085FC
	JSL MergeOAM
	JMP.w $00865C


;===================================================================================================
; This small joypad improvement of 8 cycles gives us a little more leeway
; but we also use 10 cycles here for joypad 2
; net loss is 2 cycles, not an issue
;===================================================================================================
org $0083D1
	REP #$20

	LDA.w $421A
	STA.w SA1IRAM.JOYPAD2_NEW

	LDA.w $4218
	STA.b $00 ; not really necessary, but good for expected glitching

	SEP #$20
	STA.b $F2
	TAY
	EOR.b $FA
	AND.b $F2
	STA.b $F6
	STY.b $FA

	XBA
	STA.b $F0
	TAY
	EOR.b $F8
	AND.b $F0
	STA.b $F4
	STY.b $F8

	RTS

warnpc $0083F8

; NMI hook
org $0080D5
	JSL nmi_expand

; TM and TS writes
org $008176 : STA.w SA1RAM.layer_writer+0
org $00817B : STA.w SA1RAM.layer_writer+1

; The time this routine takes isn't relevant
; since it's never during game play
org $00E36A
	JSL LoadCustomHUDGFX
	PLB
	RTL

pullpc

; Needs to leave AI=8
nmi_expand:
	; enters AI=16
	SEP #$30
	; this covers the PHK : PLB we overwrote
	PHA ; A is 0 from right before the hook
	PLB ; and that happens to be the bank we want

	LDA.w SA1RAM.disabled_layers
	TRB.w SA1RAM.layer_writer+0
	TRB.w SA1RAM.layer_writer+1

	REP #$20
	LDA.w SA1RAM.layer_writer
	STA.w $212C
	SEP #$20

	LDA.b $12 : STA.w SA1IRAM.CopyOf_12

	LDA.b #$12 ; timers NMI
	STA.w $2200

	RTL


;===================================================================================================

ClearOAM:
	REP #$20

	LDX.b #$F0

	LDA.w #$0800
	TCD

	STX.b $01 : STX.b $05 : STX.b $09 : STX.b $0D
	STX.b $11 : STX.b $15 : STX.b $19 : STX.b $1D
	STX.b $21 : STX.b $25 : STX.b $29 : STX.b $2D
	STX.b $31 : STX.b $35 : STX.b $39 : STX.b $3D
	STX.b $41 : STX.b $45 : STX.b $49 : STX.b $4D
	STX.b $51 : STX.b $55 : STX.b $59 : STX.b $5D
	STX.b $61 : STX.b $65 : STX.b $69 : STX.b $6D
	STX.b $71 : STX.b $75 : STX.b $79 : STX.b $7D
	STX.b $81 : STX.b $85 : STX.b $89 : STX.b $8D
	STX.b $91 : STX.b $95 : STX.b $99 : STX.b $9D
	STX.b $A1 : STX.b $A5 : STX.b $A9 : STX.b $AD
	STX.b $B1 : STX.b $B5 : STX.b $B9 : STX.b $BD
	STX.b $C1 : STX.b $C5 : STX.b $C9 : STX.b $CD
	STX.b $D1 : STX.b $D5 : STX.b $D9 : STX.b $DD
	STX.b $E1 : STX.b $E5 : STX.b $E9 : STX.b $ED
	STX.b $F1 : STX.b $F5 : STX.b $F9 : STX.b $FD

	LDA.w #$0900
	TCD

	STX.b $01 : STX.b $05 : STX.b $09 : STX.b $0D
	STX.b $11 : STX.b $15 : STX.b $19 : STX.b $1D
	STX.b $21 : STX.b $25 : STX.b $29 : STX.b $2D
	STX.b $31 : STX.b $35 : STX.b $39 : STX.b $3D
	STX.b $41 : STX.b $45 : STX.b $49 : STX.b $4D
	STX.b $51 : STX.b $55 : STX.b $59 : STX.b $5D
	STX.b $61 : STX.b $65 : STX.b $69 : STX.b $6D
	STX.b $71 : STX.b $75 : STX.b $79 : STX.b $7D
	STX.b $81 : STX.b $85 : STX.b $89 : STX.b $8D
	STX.b $91 : STX.b $95 : STX.b $99 : STX.b $9D
	STX.b $A1 : STX.b $A5 : STX.b $A9 : STX.b $AD
	STX.b $B1 : STX.b $B5 : STX.b $B9 : STX.b $BD
	STX.b $C1 : STX.b $C5 : STX.b $C9 : STX.b $CD
	STX.b $D1 : STX.b $D5 : STX.b $D9 : STX.b $DD
	STX.b $E1 : STX.b $E5 : STX.b $E9 : STX.b $ED
	STX.b $F1 : STX.b $F5 : STX.b $F9 : STX.b $FD

	LDA.w #$0000
	TCD

	RTL

MergeOAM:
macro preponeoam(offset)
	LDA.b $0A20+$03+(<offset>*4) : ASL : ASL
	ORA.b $0A20+$02+(<offset>*4) : ASL : ASL
	ORA.b $0A20+$01+(<offset>*4) : ASL : ASL
	ORA.b $0A20+$00+(<offset>*4)
	STA.b $0A00+<offset>
endmacro
	PEA.w $0000
	PEA.w $0A00
	PLD

	%preponeoam($00) : %preponeoam($01) : %preponeoam($02) : %preponeoam($03)
	%preponeoam($04) : %preponeoam($05) : %preponeoam($06) : %preponeoam($07)
	%preponeoam($08) : %preponeoam($09) : %preponeoam($0A) : %preponeoam($0B)
	%preponeoam($0C) : %preponeoam($0D) : %preponeoam($0E) : %preponeoam($0F)
	%preponeoam($10) : %preponeoam($11) : %preponeoam($12) : %preponeoam($13)
	%preponeoam($14) : %preponeoam($15) : %preponeoam($16) : %preponeoam($17)
	%preponeoam($18) : %preponeoam($19) : %preponeoam($1A) : %preponeoam($1B)
	%preponeoam($1C) : %preponeoam($1D) : %preponeoam($1E) : %preponeoam($1F)

	PLD
	RTL

;===================================================================================================
; Custom NMI for hud
;===================================================================================================
NMI_UpdatePracticeHUD:
	REP #$20

	LDA.w #SA1RAM.MENU
	STA.w $4352

	LDA.w #$6C00
	STA.w $2116

	LDA.w #$0800
	STA.w $4355

	LDA.w #$1801
	STA.w $4350

	SEP #$20

	LDA.b #$80
	STA.w $2115

	STZ.w $4354

	LDA.b #$20
	STA.w $420B

	RTS

;===================================================================================================

SNES_ENABLE_CUSTOM_NMI:
--	SEP #$21

	LDA.b #$11
	STA.w $2200

	ROL A
-	DEC A : BPL -

	; check if custom NMI is enabled
	LDA.b #$10
	AND.w $2300
	BEQ --

	RTL

SNES_DISABLE_CUSTOM_NMI:
--	SEP #$21

	LDA.b #$10
	STA.w $2200

	ROL A
-	DEC A : BPL -

	; check if custom NMI is enabled
	LDA.b #$10
	AND.w $2300
	BNE --

	RTL

;===================================================================================================

SNES_CUSTOM_NMI:
	REP #$30
	PHA
	PHX
	PHY
	PHD
	PHB

	SEP #$21
	LDA.l $004210

	PEA.w $0000
	PLD
	TDC ; A = 0000
	TAX ; X = 0000

	PHK
	PLB

	STA.w $420C ; disable HDMA aggressively

	ROR ; A = 80
	STA.w $2100

	LDA.b $12
	BEQ .good_to_go

	JMP .lagging

.good_to_go
	INC.b $12

	JSR.w NMI_UpdatePracticeHUD

	PEA.w $0000 ; used to be D=0 later
	PEA.w $2100
	PLD

	PHK
	PLB

	SEP #$30

	LDA.b #$04 ; only show BG3
	STA.b $212C
	STZ.b $212D

	LDA.b #$09 : STA.w $2105 ; BG mode 1
	LDA.b #$63 : STA.w $2109 ; restore tilemap and char addresses
	LDA.b #$07 : STA.w $210C

	; BG 3 scroll
	LDA.b #$01
	STZ.b $2111
	STA.b $2111

	STZ.b $2112
	STA.b $2112

	STZ.b $2106 ; no mosaic

	STZ.b $2123 ; no windowing
	STZ.b $2124
	STZ.b $2125

	STZ.b $212E
	STZ.b $212F

	STZ.b $2131 ; no color math

	; handle music and sfx
	LDX.b #3

--	LDA.w $012C,X
	STA.b $40,X
	STZ.w $012C,X
	DEX
	BPL --

	PLD ; D=0000
	TDC ; A=0000

	; Refresh colors every frame just cause it's easier
	REP #$10
	LDY.w #0

.next_color
	LDA.w .cgrams,Y
	BMI .done_color

	INY
	STA.w $2121

	LDX.w .cgrams,Y
	INY
	INY

	STX.b $00

	LDA.b ($00)
	ASL
	TAX

	LDA.l COLORS_YAY,X
	STA.w $2122

	INX
	LDA.l COLORS_YAY,X
	STA.w $2122

	BRA .next_color

.done_color
	SEP #$30

	JSL ReadJoyPad_long

	LDA.b $F0 : STA.w SA1IRAM.CopyOf_F0
	LDA.b $F2 : STA.w SA1IRAM.CopyOf_F2
	LDA.b $F4 : STA.w SA1IRAM.CopyOf_F4
	LDA.b $F6 : STA.w SA1IRAM.CopyOf_F6

.lagging
	SEP #$20

	LDA.b #$0F
	STA.w $2100

	JMP.w SA1NMI_EXIT

.nothing
	RTS

.cgrams
	db 00 : dw !config_hud_bg
	db 03 : dw !config_hud_bg

	db 17 : dw !config_hud_header_hl
	db 18 : dw !config_hud_header_fg
	db 19 : dw !config_hud_header_bg

	db 22 : dw !config_hud_sel_fg
	db 23 : dw !config_hud_sel_bg

	db 30 : dw !config_hud_sel_bg
	db 31 : dw !config_hud_sel_fg

	db 26 : dw !config_hud_dis_fg
	db 27 : dw !config_hud_bg

	db $FF ; done
