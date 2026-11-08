CONFIGURATION_SUBMENU:
%menu_header("CONFIGURATION")

;===================================================================================================

%submenu("System and ROM", SYSTEM_SUBMENU)

;===================================================================================================

%toggle_onoff("Rerandomize", CONFIG.rerandomize)

;===================================================================================================

if !RANDO
	%toggle_onoff("FastROM", CONFIG.fastrom)
	%toggle_onoff("Vanilla items", CONFIG.vanillaitems)
endif

;===================================================================================================

%toggle_func_customtext("Music", CONFIG.feature_music, .func, .text)

.text
%toggletext("Muted", "Enabled")

.func
	LDA.w CONFIG.feature_music

	REP #$20
	BNE .unmute

.mute
	LDA.w #MutedInstruments
	BRA .transfer

.unmute
	LDA.w #UnmutedInstruments

.transfer
	JSR transfer_adsr

	LDA.w $0133 : STA.w $012C
	STZ.w $0133

	RTL

;===================================================================================================

mute_music:
	REP #$20

	LDA.w #MutedInstruments
	JSR transfer_adsr

	RTL

;===================================================================================================

transfer_adsr:
	STA.w $0000

	LDA.w #$0000
	PHD
	TCD

	SEP #$30

	LDA.b #$FF : STA.w APUIO0
	STZ.w NMITIMEN

	LDA.b #^UnmutedInstruments
	JSL jlong($00891D)

	SEP #$30

	PLD
	RTS

;===================================================================================================

%toggle_customtext("Menu open", CONFIG.cm_save_place, this)

%toggletext("Save place", "Main menu")

;===================================================================================================

%choice_here("HUD font", CONFIG.hud_font, 23)
	%list_item("LTTP")
	%list_item("Klonoa")
	%list_item("TI-83")
	%list_item("Shin-chan")
	%list_item("SMT")
	%list_item("Mario World")
	%list_item("DKC")
	%list_item("ZAMN")
	%list_item("Emerald")
	%list_item("Earthbound")
	%list_item("FF6")
	%list_item("Lufia 2")
	%list_item("Goonies 2")
	%list_item("Pac-Man")
	%list_item("DOOM")
	%list_item("Undertale")
	%list_item("Pocky")
	%list_item("Skyroads")
	%list_item("Yoshi's")
	%list_item("S. Metroid")
	%list_item("NES Open")
	%list_item("Black Bass")
	%list_item("Loopz")

;===================================================================================================

!color_count = 22
!color_id = -1

piling COLORS_YAY :: !color_count * 2
fill word count !color_count :: $0000

;===================================================================================================

%submenu("Color config", COLOR_CONFIG_SUBMENU)

;===================================================================================================

macro AddMenuColor(val, name)
	%list_item("{name}")
	pile COLORS_YAY :: dw col({val})
endmacro

;===================================================================================================

COLOR_CONFIG_SUBMENU:

%menu_header("COLOR CONFIG")

%choice_func("Menu BG", CONFIG.hud_bg, !color_count, set_color, color_list)

%choice_func("Header FG", CONFIG.hud_header_fg, !color_count, set_color, color_list)
%choice_func("Header HL", CONFIG.hud_header_hl, !color_count, set_color, color_list)
%choice_func("Header BG", CONFIG.hud_header_bg, !color_count, set_color, color_list)

%choice_func("Selection FG", CONFIG.hud_sel_fg, !color_count, set_color, color_list)
%choice_func("Selection BG", CONFIG.hud_sel_bg, !color_count, set_color, color_list)

%choice_func("Inactive FG", CONFIG.hud_dis_fg, !color_count, set_color, color_list)

;===================================================================================================

set_color:
	BIT.b IRAM.cm_ax
	BVC .dontreset

	LDA.b IRAM.cm_cursor
	TAX
	ASL
	TAY

	LDA.l .defaults,X
	STA.w CONFIG.hud_bg,Y

.dontreset
	RTL

.defaults
	db  0 ; HUD BG: black

	db  1 ; Header FG: white
	db  0 ; Header HL: black
	db 10 ; Header BG: lui

	db  8 ; Selection FG: me
	db  9 ; Selection BG: mine

	db  3 ; Inactive FG: gray

;===================================================================================================

color_list:
%list_header(!color_count)
	%AddMenuColor($000000, "Black")
	%AddMenuColor($F8F8F8, "White")
	%AddMenuColor($C06000, "Brown")
	%AddMenuColor($A8A8A8, "Gray")

	%AddMenuColor($C00000, "Red")        : %ReusableText(CMTEXT_RED)
	%AddMenuColor($E0A800, "Yellow")     : %ReusableText(CMTEXT_YELLOW)
	%AddMenuColor($20C028, "Green")      : %ReusableText(CMTEXT_GREEN)
	%AddMenuColor($4870D0, "Blue")       : %ReusableText(CMTEXT_BLUE)

	%AddMenuColor($C8C8F8, "Periwinkle")
	%AddMenuColor($000090, "Dark Blue")
	%AddMenuColor($06A969, "Lui green")
	%AddMenuColor($20A8F8, "Glan blue") ; fantasy

	%AddMenuColor($F8B000, "Orange")
	%AddMenuColor($782878, "Purple")
	%AddMenuColor($605800, "Garbage")
	%AddMenuColor($8090A0, "Blilver")

	%AddMenuColor($F858A8, "Pink")
	%AddMenuColor($F76D61, "Peach42")
	%AddMenuColor($2AA8D9, "Siriusly?")
	%AddMenuColor($B8D850, "Chartreuse")

	%AddMenuColor($FFBFFF, "Blunt pink")
	%AddMenuColor($78886A, "Futaba")

;===================================================================================================

UnmutedInstruments:
	dw .data.size, $3D00

.data
	db $00, $FF, $E0, $B8, $04, $70
	db $01, $FF, $E0, $B8, $07, $90
	db $02, $FF, $E0, $B8, $09, $C0
	db $03, $FF, $E0, $B8, $04, $00
	db $04, $FF, $E0, $B8, $04, $00
	db $05, $FF, $E0, $B8, $04, $70
	db $06, $FF, $E0, $B8, $04, $70
	db $07, $FF, $E0, $B8, $04, $70
	db $08, $FF, $E0, $B8, $07, $A0
	db $09, $8F, $E9, $B8, $01, $E0
	db $0A, $8A, $E9, $B8, $01, $E0
	db $0B, $FF, $E0, $B8, $03, $00
	db $0C, $FF, $E0, $B8, $03, $A0
	db $0D, $FF, $E0, $B8, $01, $00
	db $0E, $FF, $EF, $B8, $0E, $A0
	db $0F, $FF, $EF, $B8, $06, $00
	db $10, $FF, $E0, $B8, $03, $D0
	db $11, $8F, $E0, $B8, $03, $00
	db $12, $8F, $E0, $B8, $06, $F0
	db $13, $FD, $E0, $B8, $07, $A0
	db $14, $FF, $E0, $B8, $07, $A0
	db $15, $FF, $E0, $B8, $03, $D0
	db $16, $8F, $E0, $B8, $03, $00
	db $17, $FF, $E0, $B8, $02, $C0
	db $18, $FE, $8F, $B8, $06, $F0

^..size
	dw $0000, $0800

;===================================================================================================

MutedInstruments:
	dw .data.size, $3D00

.data
	db $00, $00, $00, $00, $04, $70
	db $01, $00, $00, $00, $07, $90
	db $02, $00, $00, $00, $09, $C0
	db $03, $00, $00, $00, $04, $00
	db $04, $00, $00, $00, $04, $00
	db $05, $00, $00, $00, $04, $70
	db $06, $FF, $E0, $B8, $04, $70 ; mirror uses this, leave unmuted
	db $07, $00, $00, $00, $04, $70
	db $08, $00, $00, $00, $07, $A0
	db $09, $00, $00, $00, $01, $E0
	db $0A, $00, $00, $00, $01, $E0
	db $0B, $00, $00, $00, $03, $00
	db $0C, $00, $00, $00, $03, $A0
	db $0D, $00, $00, $00, $01, $00
	db $0E, $00, $00, $00, $0E, $A0
	db $0F, $00, $00, $00, $06, $00
	db $10, $00, $00, $00, $03, $D0
	db $11, $00, $00, $00, $03, $00
	db $12, $00, $00, $00, $06, $F0
	db $13, $00, $00, $00, $07, $A0
	db $14, $00, $00, $00, $07, $A0
	db $15, $00, $00, $00, $03, $D0
	db $16, $00, $00, $00, $03, $00
	db $17, $00, $00, $00, $02, $C0
	db $18, $00, $00, $00, $06, $F0

^..size
	dw $0000, $0800

;===================================================================================================

SYSTEM_SUBMENU:
%menu_header("SYSTEM AND ROM")

%info1d("CPU version", $4210)
%info1d("PPU1 version", $213E)
%info1d("PPU2 version", $213F)

%info1d("SA-1 version", $00230E)

%info4h("ROM checksum 1", $00FFDC)
%info4h("ROM checksum 2", $00FFDE)

%func("Crash test", this)
	BRK #$BE

;===================================================================================================
