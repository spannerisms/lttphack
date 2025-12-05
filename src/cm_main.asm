!SELECTED = $3480
!UNSELECTED = $3800
!SHORTCUTTING = $3C80
!HEADER = $3100

;===================================================================================================

cm_mainmenu:
%menu_header("ALTTP Practice Hack !VERSION")
	%submenu_variable("Presets", PRESET_SUBMENU)
	%submenu("Y items", ITEMS_SUBMENU)
	%submenu("Equipment", EQUIPMENT_SUBMENU)
	%submenu("Game state", GAMESTATE_SUBMENU)
	%submenu("Link state", LINKSTATE_SUBMENU)
	%submenu("Gameplay", GAMEPLAY_SUBMENU)
	%submenu("RNG control", RNG_SUBMENU)
	%submenu("HUD extras", HUDEXTRAS_SUBMENU)
	%submenu("Lite states", LITESTATES_SUBMENU)
	%submenu("Room master", ROOMLOAD_SUBMENU)
	%submenu("Shortcuts", SHORTCUTS_SUBMENU)
	%submenu("Preset config", PRESET_CONFIG_SUBMENU)
	%submenu("Configuration", CONFIG_SUBMENU)

;===================================================================================================

CM_Main:
	PHB : PHK : PLB

	LDA.b #$14 : STA.w $2142

	PHD
	PEA.w $3000
	PLD

	JSL SNES_ENABLE_CUSTOM_NMI

	JSR CM_PrepPPU
	JSL CM_CacheWRAM

	REP #$20

	STZ.b SA1IRAM.SHORTCUT_USED
	STZ.b SA1IRAM.CONTROLLER_1
	STZ.b SA1IRAM.CONTROLLER_1_FILTERED

	LDA.w #15
	STA.w SA1RAM.cm_input_timer

	LDA.b SA1IRAM.cm_submodule
	CMP.w #2
	BEQ .fine

	; assume something went wrong if it's not 2
	STZ.b SA1IRAM.cm_submodule

	BRA .loop

.fine
	SEP #$20

	LDA.w !config_cm_save_place
	BEQ .loop

	JSR EmptyEntireMenu
	JSR CM_ResetStackAndMenu
	JSR DrawCurrentMenu

.loop
	SEP #$30

	LDA.b #$81
	STA.w $4200

	STZ.w $0012

--	LDA.w $0012
	BEQ --

	LDX.b SA1IRAM.cm_submodule

	JSR (.submodules,X)
	BRA .loop

.submodules
	dw CM_Init              ; 00
	dw CM_DrawMenu          ; 02
	dw CM_Active            ; 04
	dw CM_Return            ; 06
	dw CM_ShortcutConfig    ; 08
	dw CM_SetLiteState      ; 0A
	dw CM_DeleteLiteState   ; 0C
	dw CM_SetSentry         ; 0E

;===================================================================================================

SelectionColors:
	dw !SELECTED      ; CM_Init
	dw !SELECTED      ; CM_DrawMenu
	dw !SELECTED      ; CM_Active
	dw !SELECTED      ; CM_Return
	dw !SHORTCUTTING  ; CM_ShortcutConfig
	dw !SHORTCUTTING  ; CM_SetLiteState
	dw !SHORTCUTTING  ; CM_DeleteLiteState
	dw !SELECTED      ; CM_SetSentry

;===================================================================================================

CM_DrawMenu:
	LDX.b #$04
	STX.b SA1IRAM.cm_submodule

	JMP DrawCurrentMenu

;===================================================================================================

CM_Return:
	REP #$20
	PLA ; remove the return of the JSR
	PLD

	JSL SetHUDItemGraphics
	JSL CM_Exiting

	LDA.b #$81 : STA.w $4200

	PLB
	RTL

;===================================================================================================

CM_Exiting:
	SEP #$30
	STZ.w $4200

	LDY.b #$80
	STY.w $2100
	STY.w $2115

	REP #$30

	LDA.w #$0002
	STA.w SA1IRAM.cm_submodule

	JSR GetHighestActiveLine

.hide_all
	CPY.w SA1IRAM.highestline
	BCS .no_hide

	JSL ClearLineSentryLine

	INY
	INY
	BRA .hide_all

.no_hide
	JSL LoadCustomHUDGFX
	JSL InitializeSentries
	JSL ConfigMenuSize

	SEP #$30

	LDA.b #$15 : STA.w $2142

	STZ.b $12
	INC.b $15 ; trigger a CGRAM update

	JSL SNES_DISABLE_CUSTOM_NMI

	RTL

;===================================================================================================

ClearLineSentryLine:
	TYA
	ASL
	ASL
	ASL
	ASL
	ADC.w #$60E5
	STA.w $2116

	LDA.w #$207F
	LDX.w #26

.clear_vram
	STA.w $2118
	DEX
	BNE .clear_vram

	; check 
	TYA
	ASL
	ASL
	ASL
	ASL
	ASL
	TAX

	LDA.l $42C1CA,X
	CMP.w #$28F3
	BEQ .do_not_clear_savestate
	CMP.w #$28C8
	BEQ .do_not_clear_savestate

	PHY

	LDA.w #$207F
	LDY.w #26

.clear_savestate
	STA.l $42C1CA,X
	INX
	INX
	DEY
	BNE .clear_savestate

	PLY

.do_not_clear_savestate
	RTL

;===================================================================================================

CM_ShortcutConfig:
	REP #$30
	LDY.w #$0001
	JSR CMDO_SAVE_ADDRESS

	REP #$20
	LDA.b SA1IRAM.CONTROLLER_1
	CMP.b [SA1IRAM.cm_writer]
	BNE .notheld

	INC.b SA1IRAM.preset_scratch
	LDA.b SA1IRAM.preset_scratch
	CMP.w #$0061
	BCC CM_UpdateHeldOption

	JSL MenuSFX_shortcut_done

#CM_AbortHeldOption:
	LDA.w #$0004
	STA.b SA1IRAM.cm_submodule
	BRA CM_UpdateHeldOption

.notheld
	STA.b [SA1IRAM.cm_writer]
	STZ.b SA1IRAM.preset_scratch

;===================================================================================================

CM_UpdateHeldOption:
	SEP #$30

	LDY.b SA1IRAM.cm_cursor
	JMP DrawCurrentRow_ShiftY

;===================================================================================================

CM_SetLiteState:
	REP #$20

	LDA.b SA1IRAM.CONTROLLER_1
	CMP.w #$4000
	BNE CM_AbortHeldOption

	LDA.b SA1IRAM.preset_scratch
	CMP.w #60
	BCS .save_litestate

	INC
	STA.b SA1IRAM.preset_scratch
	BRA CM_UpdateHeldOption

.save_litestate
	LDA.w SA1IRAM.litestate_act
	JSL SaveLiteState
	JSL MenuSFX_shortcut_done

	BRA CM_AbortHeldOption

;===================================================================================================

CM_DeleteLiteState:
	REP #$20

	LDA.b SA1IRAM.CONTROLLER_1
	CMP.w #$0040
	BNE CM_AbortHeldOption

	LDA.b SA1IRAM.preset_scratch
	CMP.w #60
	BCS .delete_litestate

	INC
	STA.b SA1IRAM.preset_scratch
	BRA CM_UpdateHeldOption

.delete_litestate
	LDA.w SA1IRAM.litestate_act
	JSL DeleteLiteState
	JSL MenuSFX_empty

	BRA CM_AbortHeldOption

;===================================================================================================

CM_PrepPPU:
	SEP #$30

	LDA.b #$80 : STA.w $2100
	STZ.w $4200

	; transfer menu tileset
	REP #$10

	LDA.b #$80 : STA.w $2115

	LDX.w #$7000 : STX.w $2116
	LDX.w #cm_gfx>>0 : STX.w $4352
	LDA.b #cm_gfx>>16 : STA.w $4354
	LDX.w #$2000 : STX.w $4355
	LDX.w #$1801 : STX.w $4350
	LDA.b #$20 : STA.w $420B

	RTS

;===================================================================================================

; save temp variables that the menu uses
CM_CacheWRAM:
	SEP #$30

	; Bow
	LDA.l $7EF340 : BEQ .no_bow
	CMP.b #$03
	LDA.b #$01
	ADC.b #$00

.no_bow
	STA.w SA1RAM.cm_item_bow

	; MaxHP
	LDA.l $7EF36C
	LSR
	LSR
	LSR
	STA.w SA1RAM.cm_equipment_maxhp

;===================================================================================================

ConfigMenuSize:
	REP #$30

	JSR GetHighestActiveLine
	STY.w SA1IRAM.highestline

	TYX
	LDA.l HUD_LineSize,X
	STA.w SA1IRAM.HUDSIZE

	RTL

;===================================================================================================

GetHighestActiveLine:
	LDY.w !config_hide_lines
	BNE .hide

	LDY.w !config_linesentry4 : BEQ .no_line_4
	LDY.w #8
	RTS

.no_line_4
	LDY.w !config_linesentry3 : BEQ .no_line_3
	LDY.w #6
	RTS

.no_line_3
	LDY.w !config_linesentry2 : BEQ .no_line_2
	LDY.w #4
	RTS

.no_line_2
	LDY.w !config_linesentry1 : BEQ .exit

	LDY.w #2
	RTS

.hide
	LDY.w #0

.exit
	RTS


;===================================================================================================

CM_Init:
	JSR EmptyEntireMenu
	JSR CM_ResetStackAndMenu

	SEP #$20

	LDA.b #$02 : STA.b SA1IRAM.cm_submodule
	STZ.w SA1RAM.cm_input_timer

	RTS

;===================================================================================================
; Menu sounds; here for standardization, even though they're simple routines
;===================================================================================================
MenuSFX:
.beep
	PEA.w $0C00
	BRA .continue

.boop
	PEA.w $002D
	BRA .continue

.bink
	PEA.w $2000
	BRA .continue

.fill
	PEA.w $0A00
	BRA .continue

.empty
	PEA.w $0700
	BRA .continue

.poof
	PEA.w $0014
	BRA .continue

.oof
	PEA.w $0026
	BRA .continue

.shortcut_done
	PEA.w $2F00
	BRA .continue

.setshortcut
.switch
	PEA.w $2500
	BRA .continue

.submenu
	PEA.w $2400
	BRA .continue

.submenuback
	PEA.w $1300
	BRA .continue

.error
	PEA.w $003C
	BRA .continue

.tinkle
	PEA.w $0031
	BRA .continue

.continue
	PHP
	REP #$20
	PHA ; save our A

	LDA.w $012E
	BNE .sfx_busy

	LDA 4,S ; get our PEA
	STA.w $012E

.sfx_busy
	LDA 2,S ; move the P to top of stack
	STA 4,S

	PLA ; recover A
	STA 1,S ; recover it again
	PLA

	PLP
	RTL

;===================================================================================================

CM_BackToTipTop:
	JSL MenuSFX_submenuback
	JSR EmptyCurrentMenu
	JSR CM_ResetStackAndMenu
	JMP DrawCurrentMenu

;===================================================================================================

CM_ExitTime:
	LDA.b #$06
	STA.b SA1IRAM.cm_submodule
	RTS

;===================================================================================================

CM_Active:
	SEP #$30
	LDY.b SA1IRAM.cm_cursor

	JSR CM_getcontroller
	BNE .actionable_action
	BCS CM_GoBack

	BIT.b SA1IRAM.cm_updown
	BMI .pressed_up
	BVS .pressed_down

	; start / select is lowest priority
	LDA.b SA1IRAM.CopyOf_F4
	BIT.b #$10
	BNE CM_ExitTime
	BIT.b #$20
	BNE CM_BackToTipTop
	RTS

.pressed_up
	DEC.b SA1IRAM.cm_cursor
	BRA CM_AdjustForWrap

.pressed_down
	INC.b SA1IRAM.cm_cursor
	BRA CM_AdjustForWrap

.actionable_action
	LDA.b [SA1IRAM.cm_current_selection]

	REP #$30

	AND.w #$00FF
	TAX

	ASL
	TAY

	LDA.w ActionLengths,X
	AND.w #$00FF
	STA.b SA1IRAM.cm_action_length

	PEA.w CM_UpdateHeldOption-1

	TYX
	LDA.l ActionDoRoutines,X
	STA.b SA1IRAM.SCRATCH

	SEP #$30
	LDY.b #1 ; for when the routine uses it
	JMP.w (SA1IRAM.SCRATCH)

;===================================================================================================

CM_AdjustForWrap:
	PHY

	LDA.b SA1IRAM.cm_cursor
	BMI .find_max

	INC
	ASL
	TAY

	; just check if we hit the end of the headers
	REP #$20
	LDA.b [SA1IRAM.cm_current_menu],Y
	SEP #$20
	BNE .not_max
	BRA .reset_too_far ; oops!

#CM_DontGoBack:
	STZ.b SA1IRAM.cm_cursor
	CPY.b #$00 ; are we at the top of the menu
	BNE .moved_cursor
	RTS ; just leave if we're already at the top too

#CM_GoBack:
	JSR EmptyCurrentMenu
	JSR CM_PullMenuFromStack
	JSR DrawCurrentMenu
	JSL MenuSFX_submenuback
	RTS

.find_max
	LDY.b #0 ; increment first, to skip header and condense loop

	REP #$20

.next_check
	INY
	INY
	LDA.b [SA1IRAM.cm_current_menu],Y
	BNE .next_check

	SEP #$20
	TYA
	LSR
	DEC
	DEC

.reset_too_far
	STA.b SA1IRAM.cm_cursor

.not_max
	PLY

.moved_cursor
	JSL MenuSFX_boop

;===================================================================================================

CM_ReDrawCursorPosition:
	JSR DrawCurrentRow_ShiftY

	LDY.b SA1IRAM.cm_cursor
	JSR DrawCurrentRow_ShiftY

	JMP CM_UpdateCurrentSelection

;===================================================================================================
; Puts presses into the 6th and 7th bits for easy testing
; Carry = B
; Zero  = No actions
;===================================================================================================
CM_getcontroller:
	REP #$20
	SEP #$10
	STZ.b SA1IRAM.cm_leftright
	STZ.b SA1IRAM.cm_ax
	STZ.b SA1IRAM.cm_y

	LDA.b SA1IRAM.CONTROLLER_1

	CMP.w SA1RAM.cm_last_input
	STA.w SA1RAM.cm_last_input

	BEQ .same_as_last_frame

	LDX.b #15
	STX.w SA1RAM.cm_input_timer

	CMP.b SA1IRAM.CONTROLLER_1_FILTERED
	SEP #$20
	BNE .no_presses

.handle_all_new
	JSR .repeatables ; get udlrLR

	; get A and X, but only new presses
	LDA.b SA1IRAM.CopyOf_F6
	STA.b SA1IRAM.cm_ax

	; get new B presses in carry
	; this also puts Y presses in bit 7
	LDA.b SA1IRAM.CopyOf_F4
	ASL
	AND.b #$80 ; get rid of other bits
	STA.b SA1IRAM.cm_y

	; now combine see if anything actionable was pressed
	ORA.b SA1IRAM.cm_leftright
	ORA.b SA1IRAM.cm_ax
	ORA.b SA1IRAM.cm_shoulder
	AND.b #$C0

	RTS

.same_as_last_frame
	CMP.w #$0001
	SEP #$22 ; set zero flag
	BCS .holding_buttons
	RTS

.holding_buttons
	LDA.w SA1RAM.cm_input_timer
	BEQ .continue

	DEC
	STA.w SA1RAM.cm_input_timer

.no_presses
	LDA.b #$00 ; get 0
	CLC
	RTS

.continue
	LDA.b #4
	STA.w SA1RAM.cm_input_timer

.repeatables
	; get left and right
	LDA.b SA1IRAM.CopyOf_F0
	LSR
	ROR.b SA1IRAM.cm_leftright
	LSR
	ROR.b SA1IRAM.cm_leftright

	; get up and down
	LSR
	ROR.b SA1IRAM.cm_updown
	LSR
	ROR.b SA1IRAM.cm_updown

	; get l and r
	LDA.b SA1IRAM.CopyOf_F2
	ASL
	ASL
	STA.b SA1IRAM.cm_shoulder

	; get actionable presses
	LDA.b SA1IRAM.cm_leftright
	ORA.b SA1IRAM.cm_shoulder
	AND.b #$C0
	CLC ; no B press
	RTS

;===================================================================================================
; X points to first empty slot
;===================================================================================================
CM_ResetStackAndMenu:
	REP #$20

	STZ.w SA1RAM.CM_SubMenuIndex

	LDA.w #cm_mainmenu<<8
	STA.b SA1IRAM.cm_cursor+0

	LDA.w #cm_mainmenu>>8
	STA.b SA1IRAM.cm_cursor+2

CM_UpdateCurrentSelection:
	REP #$20
	SEP #$10

	LDA.b SA1IRAM.cm_cursor
	INC
	ASL
	TAY

	LDA.b [SA1IRAM.cm_current_menu],Y
	STA.b SA1IRAM.cm_current_selection+0

	LDY.b SA1IRAM.cm_current_menu+2
	STY.b SA1IRAM.cm_current_selection+2

	RTS

;===================================================================================================

CM_PushMenuToStack:
	PHX
	PHY
	PHP

	REP #$20
	SEP #$10

	LDX.w SA1RAM.CM_SubMenuIndex

	LDA.b SA1IRAM.cm_cursor+0
	STA.w SA1RAM.CM_SubMenuStack,X

	INX
	INX
	LDA.b SA1IRAM.cm_cursor+2
	STA.w SA1RAM.CM_SubMenuStack,X

	INX
	INX
	STX.w SA1RAM.CM_SubMenuIndex

	JSR CM_UpdateCurrentSelection

	PLP
	PLY
	PLX
	RTS

;===================================================================================================

; carry = successful pull
CM_PullMenuFromStack:
	PHX
	PHY

	SEC ; set carry now, so we can just jump on success
	PHP
	SEP #$10

	LDX.w SA1RAM.CM_SubMenuIndex
	CPX.b #$04
	BCC .cannot

	DEX
	DEX
	DEX
	DEX

	REP #$20
	LDA.w SA1RAM.CM_SubMenuStack+0,X
	STA.b SA1IRAM.cm_cursor+0

	LDA.w SA1RAM.CM_SubMenuStack+2,X
	STA.b SA1IRAM.cm_cursor+2

	STX.w SA1RAM.CM_SubMenuIndex
	JSR CM_UpdateCurrentSelection

	PLP
	PLY
	PLX
	RTS

.cannot
	PLP
	PLY
	PLX

	CLC
	JMP CM_ResetStackAndMenu

;===================================================================================================
