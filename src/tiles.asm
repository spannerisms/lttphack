pushpc

org $028068 : JSL LoadCustomHUDGFX

pullpc

LoadCustomHUDGFX:
	REP #$20
	SEP #$10

	LDY.b #$01

	LDX.b #$80            : STX.w VMAIN
	LDA.w #vram($E000)    : STA.w VMADDR
	LDA.w #$01][VMDATA    : STA.w DMAP0
	LDA.w #hud_table      : STA.w DMA0ADDRL
	LDX.b #^hud_table     : STX.w DMA0ADDRB
	LDA.w #hud_table:size : STA.w DMA0SIZE

	STY.w MDMAEN

	; Font
	LDA.w #vram($E100) : STA.w VMADDR
	LDA.w #$01][VMDATA : STA.w DMAP0

	; we're writing 16 2BPP tiles to VRAM
	; 16*64*2 = 2048 bits, or 256 bytes
	; AKA 0x100 bytes
	; since the offset is a multiple of 256, we can just swap the bytes and
	LDA.w CONFIG.hud_font
	XBA
	CLC
	ADC.w #hud_font
	STA.w DMA0ADDRL

	LDX.b #^hud_font : STX.w DMA0ADDRB
	LDA.w #16*8*2    : STA.w DMA0SIZE ; writing 16 2bpp tiles

	STY.w MDMAEN

	; Input display
	LDA.w CONFIG.input_display : AND.w #$0002 : BEQ .controller

	LDA.w #vram($F700)    : STA.w VMADDR
	LDA.w #hud_inputchars : STA.w DMA0ADDRL
	LDA.w #12*8*2         : STA.w DMA0SIZE ; writing 12 2bpp tiles

	STY.w MDMAEN

.controller
	JSL AddSentryIcons

	SEP #$30

	RTL

;===================================================================================================

incbin [hud_table] "resources/hud_gfx.2bpp"
incbin [hud_font] "resources/hud_font.2bpp"
incbin [cm_gfx] "resources/menu_font.2bpp"
incbin [hud_inputchars] "resources/inputchars.2bpp"
incbin [hud_sentryicons] "resources/sentry_icons.2bpp"

;===================================================================================================
