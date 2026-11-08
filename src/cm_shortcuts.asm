SHORTCUTS_SUBMENU:
%menu_header("CONTROLLER SHORTCUTS")
	%ctrl_shortcut("Practice menu", PracMenuShortcut)
	%ctrl_shortcut("Load last preset", CONFIG.ctrl_load_last_preset)
	%ctrl_shortcut("Save state", CONFIG.ctrl_save_state)
	%ctrl_shortcut("Load state", CONFIG.ctrl_load_state)
	%ctrl_shortcut("Reset seg timer", CONFIG.ctrl_reset_segment_timer)
	%ctrl_shortcut("Toggle OoB", CONFIG.ctrl_toggle_oob)
	%ctrl_shortcut("Skip text", CONFIG.ctrl_skip_text)
	%ctrl_shortcut("Remove sprites", CONFIG.ctrl_disable_sprites)
	%ctrl_shortcut("Toggle switch", CONFIG.ctrl_toggle_switch)
	%ctrl_shortcut("Fill everything", CONFIG.ctrl_fill_everything)
	%ctrl_shortcut("VRAM repair", CONFIG.ctrl_fix_vram)
	%ctrl_shortcut("Mark all pits", CONFIG.ctrl_somaria_pits)

;===================================================================================================

DoShortCuts:
	PHK
	PLB

	REP #$30 ; This REP © Lui 2020

	LDA.b IRAM.joy1_filtered : BEQ .nothingused

	LDX.w #0

.nextcheck
	LDA.w .shortcut_routine,X
	BEQ .nothingused

	STA.b IRAM.SCRATCH+0
	LDA.b (IRAM.SCRATCH+0)

	AND.b IRAM.joy1
	CMP.b (IRAM.SCRATCH+0)
	BNE .fail

	AND.b IRAM.joy1_filtered
	BEQ .fail

	LDA.w .shortcut_routine+2,X
	BPL .forsnes

.forsa1
	PHA

	LDA.w #SA1SideShortcut
	STA.b IRAM.shortcut_used
	PLA

	JSL UseShortCutSA1

	JML SA1IRQ.exit

.forsnes
	ORA.w #$8000 ; add in bit 7 that was used as a flag in rom table
	STA.b IRAM.shortcut_used

.nothingused
	JML SA1IRQ.exit

.fail
	INX
	INX
	INX
	INX
	BRA .nextcheck

!CPU_SIDE = $7FFF ; for routines to be done by the SNES CPU
!SA1_SIDE = $FFFF ; for routines to be done by the SA1 instead of the CPU

.shortcut_routine
	dw PracMenuShortcut, Shortcut_EnterPracticeMenu&!CPU_SIDE
	dw CONFIG.ctrl_load_last_preset, Shortcut_LoadLastPreset&!CPU_SIDE
	dw CONFIG.ctrl_save_state, Shortcut_SaveState&!CPU_SIDE
	dw CONFIG.ctrl_load_state, Shortcut_LoadState&!CPU_SIDE
	dw CONFIG.ctrl_reset_segment_timer, Shortcut_ResetSegmentTimer&!SA1_SIDE
	dw CONFIG.ctrl_somaria_pits, Shortcut_ShowPits&!CPU_SIDE
	dw CONFIG.ctrl_fix_vram, Shortcut_FixGraphics&!CPU_SIDE
	dw CONFIG.ctrl_toggle_switch, Shortcut_ToggleCrystalSwitch&!CPU_SIDE
	dw CONFIG.ctrl_fill_everything, Shortcut_FillEverything&!CPU_SIDE
	dw CONFIG.ctrl_toggle_oob, Shortcut_ToggleOoB&!CPU_SIDE
	dw CONFIG.ctrl_skip_text, Shortcut_SkipText&!CPU_SIDE
	dw CONFIG.ctrl_disable_sprites, Shortcut_DisableSprites&!CPU_SIDE
	dw 0, 0

;===================================================================================================

PracMenuShortcut:
	dw $1010

;===================================================================================================
