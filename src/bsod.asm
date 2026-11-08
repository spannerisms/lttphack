bankguard off

Pekola:
incbin "resources/pekola.8bpp"
fill byte count $40 :: $00
.end

bankguard half

encoder MenuEncoding

;===================================================================================================

CorruptionCrash:
	SEP #$34

	PHK
	PLB

	STZ.w NMITIMEN
	STZ.w HDMAEN

	PEA.w $2100
	PLD

	LDX.b #$80 : STX.b INIDISP
	STX.b VMAIN

	REP #$30

	LDA.w #$7800 : STA.b VMADDR

	LDA.w #$203F
	LDX.w #36*32
--	STA.b VMDATA
	DEX
	BNE --

	LDX.w #.text-1
	JSR DrawCrashText

	JSR DrawPekola

	BRA <

.text
	; "012345678901234567890123456789012"
	db "If this were vanilla, the game$"
	db "would have locked up.$"
	db "This is a simulated hardlock.$"
	db "You may reset your console."
	db $FF

;===================================================================================================

SA1CRASHED:

.draw
	LDA.w #$2966
	STA.l BWRAM.HUD+$90
	STA.l BWRAM.HUD+$92
	STA.l BWRAM.HUD+$94
	STA.l BWRAM.HUD+$96
	STA.l BWRAM.HUD+$98
	STA.l BWRAM.HUD+$9A
	STA.l BWRAM.HUD+$9C
	STA.l BWRAM.HUD+$9E
	STA.l BWRAM.HUD+$A0
	BRA .draw

;===================================================================================================

OOPS:
	REP #$30
	TSC

	LDX.w #$D939 ; this has a 3F for our bank lol
	TXS
	PLB

	TCS

	LDA.l $33213E ; read STAT77/78
	CMP.w #$3333 ; if we get this, it's open bus, and thus the SA-1
	BNE .snes_crash

	JMP SA1CRASHED

.snes_crash
	SEP #$34

	LDX.b #$80 : STX.w INIDISP
	STX.w VMAIN

	STZ.w NMITIMEN
	STZ.w HDMAEN

	REP #$30

	LDA.w #$2100
	TCD

	LDA.w #$05F0 : STA.b APUIO0
	LDA.w #$2B0C : STA.b APUIO2

	LDA.w #$7800 : STA.b VMADDR

	LDA.w #$203F
	LDX.w #36*32
--	STA.b VMDATA
	DEX
	BNE --

;---------------------------------------------------------------------------------------------------
	; Upload stack
	LDA.w #vram($F0FA) : STA.b VMADDR

	TSC : XBA : AND.w #$00FF : CLC : ADC.w #$2070 : STA.b VMDATA
	TSC : AND.w #$00FF : CLC : ADC.w #$2070 : STA.b VMDATA

	LDA.w #vram($F102) : STA.b VMADDR

	TSX
	BMI .done_stack

	TCS
	LDY.w #$FFFF

	INX
	STX.w DMAP5

	LDX.w #$0200

--	DEX
	CPX.w DMAP5 : BCC .done_stack
	INY
	CPY.w #$001E : BCC ++

	LDY.w #$0000
	TSC
	ADC.w #$001F
	STA.b VMADDR
	TCS

++	LDA.l $000000,X
	AND.w #$00FF
	CLC
	ADC.w #$2070
	STA.b VMDATA
	BRA --

.done_stack

;---------------------------------------------------------------------------------------------------

	LDX.w #.text-1
	JSR DrawCrashText

	JSR DrawPekola

	BRA <

.text
	; "012345678901234567890123456789012"
	db "A fatal error has occured.$"
	db "The system has halted to$"
	db "help prevent config damage."
	db $FF

;===================================================================================================

DrawCrashText:
	LDA.w #$2100
	TCD

	LDY.w #vram($F042) : STY.b VMADDR

.next
	INX
	LDA.w $0000,X
	AND.w #$00FF

	CMP.w #$00FF
	BEQ .done_text

	CMP.w #'$' : BNE .not_newline

	TYA
	ADC.w #$0020-1 ; carry set if equal
	STA.b VMADDR
	TAY

	BRA .next

.not_newline
	ORA.w #$2000
	STA.b VMDATA
	BRA .next

.done_text
	RTS

;===================================================================================================

DrawPekola:
	SEP #$14
	REP #$20

	LDA.w #$2100
	TCD

	LDX.b #$80 : STX.b VMAIN

	LDY.b #$FD : STY.b BG1VOFS : STY.b BG1VOFS : STY.b BG1VOFS

	LDY.b #$00
	STY.b BG1HOFS : STY.b BG1HOFS
	STZ.b BG2HOFS : STZ.b BG2HOFS

	STZ.b TMW
	STZ.b CGWSEL
	STZ.b SETINI

	STY.b MOSAIC
	STY.b CGADD

	LDA.w #$0303 : STA.b TM
	LDY.b #$04 : STY.b BGMODE

	LDA.w #$7870 : STA.b BG1SC
	LDA.w #$6060 : STA.b BG3SC
	STA.b BG12NBA

	LDA.w #$7000 : STA.b VMADDR

	REP #$10

	LDA.w #$02C0
	LDX.w #6*32
--	STA.b VMDATA
	DEX
	BNE --

	LDX.w #22*32
	LDA.w #$0000
--	STA.b VMDATA
	INC
	DEX
	BNE --

	LDX.w #3*32

--	STZ.b VMDATA
	DEX
	BNE --

	LDX.w #1*32
--	STA.b VMDATA
	DEX
	BNE --

	SEP #$10

	LDA.w #$4300 : TCD

	LDA.w #vram($C000) : STA.w VMADDR
	LDA.w #$1809 : STA.b DMAP0
	LDX.b #^ZeroLand : STX.b DMA0ADDRB
	LDA.w #ZeroLand : STA.b DMA0ADDRL
	LDA.w #$0080 : STA.b DMA0SIZE
	LDY.b #$01 : STY.w MDMAEN

	STZ.w VMADDR

	LDA.w #$01][VMDATA : STA.b DMAP0

	LDX.b #^Pekola : STX.b DMA0ADDRB
	LDA.w #$8000 : STA.b DMA0ADDRL
	STA.b DMA0SIZE
	STY.w MDMAEN

	INX : STX.b DMA0ADDRB
	STA.b DMA0ADDRL
	LDA.w #Pekola.end&$7FFF : STA.b DMA0SIZE
	STY.w MDMAEN

	LDA.w #vram($C100) : STA.w VMADDR
	LDA.w #cm_gfx+$0100 : STA.b DMA0ADDRL
	LDX.b #^cm_gfx : STX.b DMA0ADDRB
	LDA.w #16*16*6 : STA.b DMA0SIZE
	STY.w MDMAEN

	LDA.w #.hex : STA.b DMA0ADDRL
	LDX.b #^.hex : STX.b DMA0ADDRB
	LDA.w #256*16 : STA.b DMA0SIZE
	STY.w MDMAEN

	LDA.w #$2200 : STA.b DMAP0
	LDA.w #.palette : STA.b DMA0ADDRL
	LDA.w #512 : STA.b DMA0SIZE
	STY.w MDMAEN

	LDX.b #$0F : STX.w INIDISP

	RTS

.zero
	db $00

.palette
dw $2800, $0000, $7FFF, $0000, $0000, $635C, $7BFF, $77DF, $73DF, $77FE, $7BFE, $7FDE, $73DE, $7BDF, $73BF, $7BBF, $7FBE, $6FBF, $77BE, $77BE, $77DD, $7FBD, $6BBE, $779E, $7B9C, $6F9D, $6F9D, $739E, $739C, $779E, $6F9E, $7B9C, $6B9C, $7B9C, $737D, $6F7C, $637C, $777B, $6F7B, $6B7C, $637B, $677B, $6B7C, $6F5C, $6B5B, $775B, $6F5B, $735A, $5F5B, $635C, $5B5B, $6B5A, $5B5A, $5F5A, $635C, $5B3B, $673A, $6B3B, $6F3A, $5F3B, $633A, $6739, $5B3A, $573A, $631A, $631A, $5B1A, $671A, $5F39, $6B18, $5B1A, $6318, $571A, $6718, $5319, $5AF9, $62F9, $62F8, $5EF8, $52F8, $56F8, $5EF7, $56F9, $6AF8, $52F7, $5AF8, $62F7, $66F6, $66D7, $5ED7, $5AD7, $52D8, $5AD6, $4ED7, $4ED6, $62B6, $5EB6, $62B6, $52B6, $5AB5, $4AB6, $5EB5, $4EB6, $56B6, $56B5, $4E97, $4E96, $5A96, $5E95, $4A96, $5A95, $5A94, $4A95, $5E94, $4E95, $4A79, $4695, $4E93, $5A74, $4A75, $5673, $5674, $5275, $4A77, $4675, $5274, $4674, $4A74, $4274, $4655, $4254, $5253, $4E54, $4653, $5653, $5252, $4253, $4254, $3E53, $5652, $4E52, $4652, $5233, $4A33, $4A33, $4234, $4E32, $3E33, $4E31, $4232, $3E32, $4E11, $4612, $3A12, $4A10, $3E11, $4211, $3A11, $3611, $3DF2, $49F1, $39F2, $35F1, $4DF0, $39F1, $35F0, $45F0, $3DD0, $39D0, $41CF, $41CF, $39CF, $45D0, $49CE, $35D0, $39CE, $31CF, $31AF, $35AF, $45AD, $31AE, $35AE, $2DAE, $458D, $3D8E, $3DAD, $31AD, $318E, $498C, $2D8E, $318D, $298D, $298D, $418C, $3D6D, $2D8B, $2D6D, $356C, $296D, $2D6C, $454B, $256C, $256C, $354C, $294A, $454A, $294C, $254C, $294B, $294B, $254B, $312B, $3D2A, $2D4A, $254A, $3D2A, $4529, $292B, $212B, $252B, $3129, $4909, $212A, $350A, $2529, $254A, $2129, $210A, $4907, $3508, $2508, $2509, $38E9, $2108, $40E8, $38E9, $44E7, $3CC7, $1CE8, $1CE6, $44C6, $3CA6, $14C6, $1CA6, $14C6, $3CA6, $40A5, $14A6, $4485, $10A4, $4484, $4463, $4444, $4423, $4402, $4401

.hex
incbin "resources/bsodhex.2bpp"
