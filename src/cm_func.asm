CMDO_SAVE_ADDRESS:
	REP #$20

	LDA.b [SA1IRAM.cm_current_selection],Y
	INY
	INY

	STA.b SA1IRAM.cm_writer+0

	SEP #$20

	LDA.b [SA1IRAM.cm_current_selection],Y
	STA.b SA1IRAM.cm_writer+2
	INY

	RTS

;===================================================================================================

CMDO_GET_FUNC_ADDRESS:
	SEP #$31

	LDA.b SA1IRAM.cm_action_length
	SBC.b #3
	TAY

	REP #$20

	LDA.b [SA1IRAM.cm_current_selection],Y
	STA.b SA1IRAM.cm_writer+0
	INY

	LDA.b [SA1IRAM.cm_current_selection],Y
	STA.b SA1IRAM.cm_writer+1

	SEP #$20

	RTS

;===================================================================================================

; These do nothing
ACTION_EXIT:
CMDO_HEADER:
CMDO_LABEL:
CMDO_INFO_1DIGIT:
CMDO_INFO_4HEX:
	RTS

;===================================================================================================

CMDO_TOGGLEBIT0_FUNC:
CMDO_TOGGLEBIT0_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT0
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT1_FUNC:
CMDO_TOGGLEBIT1_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT1
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT2_FUNC:
CMDO_TOGGLEBIT2_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT2
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT3_FUNC:
CMDO_TOGGLEBIT3_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT3
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT4_FUNC:
CMDO_TOGGLEBIT4_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT4
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT5_FUNC:
CMDO_TOGGLEBIT5_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT5
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT6_FUNC:
CMDO_TOGGLEBIT6_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT6
	JMP CMDO_PERFORM_FUNC

CMDO_TOGGLEBIT7_FUNC:
CMDO_TOGGLEBIT7_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLEBIT7
	JMP CMDO_PERFORM_FUNC

;---------------------------------------------------------------------------------------------------

CMDO_TOGGLEBIT0:
CMDO_TOGGLEBIT0_CUSTOMTEXT:
	LDA.b #1<<0 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT1:
CMDO_TOGGLEBIT1_CUSTOMTEXT:
	LDA.b #1<<1 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT2:
CMDO_TOGGLEBIT2_CUSTOMTEXT:
	LDA.b #1<<2 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT3:
CMDO_TOGGLEBIT3_CUSTOMTEXT:
	LDA.b #1<<3 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT4:
CMDO_TOGGLEBIT4_CUSTOMTEXT:
	LDA.b #1<<4 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT5:
CMDO_TOGGLEBIT5_CUSTOMTEXT:
	LDA.b #1<<5 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT6:
CMDO_TOGGLEBIT6_CUSTOMTEXT:
	LDA.b #1<<6 : BRA CMDO_TOGGLEBIT

CMDO_TOGGLEBIT7:
CMDO_TOGGLEBIT7_CUSTOMTEXT:
	LDA.b #1<<7 : BRA CMDO_TOGGLEBIT

;===================================================================================================

CMDO_TOGGLEBIT:
	PHA

	JSR CMDO_SAVE_ADDRESS

	PLA

	BIT.b SA1IRAM.cm_ax
	BMI .toggle
	BVS .clear

	BIT.b SA1IRAM.cm_leftright
	BMI .toggle
	BVS .toggle

	BIT.b SA1IRAM.cm_y
	BMI .enable

	CLC
	RTS

.clear
	EOR.b #$FF ; get complement for the AND
	STZ.b SA1IRAM.cm_writer_args+0 ; EOR in nothing
	JSL MenuSFX_empty
	BRA CMDO_TOGGLE_SAVE_A

.enable
	STA.b SA1IRAM.cm_writer_args+0 ; EOR will toggle but
	STA.b SA1IRAM.cm_writer_args+2 ; it also gets ORA'd in

	JSL MenuSFX_fill
	BRA CMDO_TOGGLE_SAVE_B

.toggle
	STA.b SA1IRAM.cm_writer_args+0

	LDA.b #$FF
	BRA CMDO_TOGGLE_SAVE_A

;===================================================================================================

CMDO_TOGGLE:
CMDO_TOGGLE_CUSTOMTEXT:
	JSR CMDO_SAVE_ADDRESS

	SEP #$20

	LDA.b #$01
	STA.b SA1IRAM.cm_writer_args+0

	BIT.b SA1IRAM.cm_ax
	BVS .clear
	BMI .toggle

	BIT.b SA1IRAM.cm_leftright
	BMI .toggle
	BVS .toggle

	BIT.b SA1IRAM.cm_y
	BMI .enable

	CLC
	RTS

;---------------------------------------------------------------------------------------------------

.toggle
#CMDO_TOGGLE_SAVE_A:
	STZ.b SA1IRAM.cm_writer_args+2

#CMDO_TOGGLE_SAVE_B:
	STA.b SA1IRAM.cm_writer_args+1

#CMDO_PERFORM_TOGGLE:
	SEC ; set the carry here, since that means something happened

	LDA.b [SA1IRAM.cm_writer]
	EOR.b SA1IRAM.cm_writer_args+0
	AND.b SA1IRAM.cm_writer_args+1
	ORA.b SA1IRAM.cm_writer_args+2
	STA.b [SA1IRAM.cm_writer]

	JSL MenuSFX_bink
	RTS

.clear
	JSL MenuSFX_empty
	LDA.b #$00
	BRA CMDO_TOGGLE_SAVE_A

.enable
	STA.b SA1IRAM.cm_writer_args+2
	JSL MenuSFX_fill
	BRA CMDO_TOGGLE_SAVE_B

;===================================================================================================

CMDO_TOGGLE_FUNC:
CMDO_TOGGLE_FUNC_CUSTOMTEXT:
	JSR CMDO_TOGGLE
	JMP CMDO_PERFORM_FUNC

;===================================================================================================

CMDO_FUNC_FILTERED:
	LDA.b SA1IRAM.cm_ax
	ASL
	BCC .exit

#CMDO_PERFORM_FUNC_FILTERED:
	JSR CMDO_GET_FUNC_ADDRESS

	PHD
	PEA.w $0000
	PLD

	PHK
	PEA.w .return-1

	SEP #$30
	JML.w [SA1IRAM.cm_writer]

	SEP #$20
	STZ.b $15

.return
	PLD
	SEC
	JSL MenuSFX_switch

.exit
	RTS

;===================================================================================================

; jump here for anything with an attached function
; expects Y to point to the current function argument
; carry means a function should happen
CMDO_FUNC:
	LDA.b SA1IRAM.cm_ax ; get A press in carry

CMDO_PERFORM_FUNC_asl:
	ASL

CMDO_PERFORM_FUNC:
	BCC .exit

	JSR CMDO_GET_FUNC_ADDRESS

	PHK
	PEA.w .return-1

	SEP #$30
	JML.w [SA1IRAM.cm_writer]

.return
	SEC
	JSL MenuSFX_switch

.exit
	RTS


;===================================================================================================

CMDO_CHOICEPICK:
CMDO_CHOICEPICK_PRGTEXT:
	JSR CMDO_CHOICE
	JMP CMDO_FUNC

CMDO_CHOICEPICK_LOADOUT:
	JSR CMDO_SAVE_ADDRESS

	JSR CMDO_CHOICE_NOEMPTY

	SEP #$20
	LDA.b SA1IRAM.cm_ax
	ORA.b SA1IRAM.cm_y

	JMP CMDO_PERFORM_FUNC_asl

CMDO_CHOICE_FUNC:
CMDO_CHOICE_FUNC_PRGTEXT:
	JSR CMDO_CHOICE
	JMP CMDO_PERFORM_FUNC

CMDO_CHOICE_FUNC_FILTERED_PRGTEXT:
CMDO_CHOICE_FUNC_FILTERED:
	JSR CMDO_CHOICE
	JMP CMDO_PERFORM_FUNC_FILTERED

;===================================================================================================

CMDO_NUMFIELD_FUNC:
CMDO_NUMFIELD_FUNC_HEX:
CMDO_NUMFIELD_FUNC_PRGTEXT:
	JSR CMDO_NUMFIELD
	JMP CMDO_PERFORM_FUNC

CMDO_NUMFIELD16_FUNC:
	JSR CMDO_NUMFIELD16
	JMP CMDO_PERFORM_FUNC

CMDO_NUMFIELD_HEX_UPDATEWHOLEMENU:
	JSR CMDO_NUMFIELD
	JSR EmptyCurrentMenu
	JMP DrawCurrentMenu

;===================================================================================================

CMDO_CHOICE:
CMDO_CHOICE_PRGTEXT:
	JSR CMDO_SAVE_ADDRESS

	BIT.b SA1IRAM.cm_ax
	BVS .empty

#CMDO_CHOICE_NOEMPTY:
	LDA.b [SA1IRAM.cm_writer]

	BIT.b SA1IRAM.cm_leftright
	BMI .decrement
	BVS .increment
	INY
	CLC ; carry clear = nothing actionable, so no functions
	RTS

.decrement
	CMP.b #$00
	BNE .not_max

	; the max value needs to be decremented too
	LDA.b [SA1IRAM.cm_current_selection],Y

.not_max
	DEC
	BRA .set

.increment
	INC
	CMP.b [SA1IRAM.cm_current_selection],Y
	BCC .set

.clear
	LDA.b #$00

.set
	STA.b [SA1IRAM.cm_writer]
	INY
	SEC ; carry set = actionable, so do functions
	JSL MenuSFX_bink
	RTS

.empty
	JSL MenuSFX_empty
	BRA .clear

;===================================================================================================

CMDO_SUBMENU:
	BIT.b SA1IRAM.cm_ax
	BPL .no

	JSR EmptyCurrentMenu
	JSR CM_PushMenuToStack

	REP #$30
	LDA.b [SA1IRAM.cm_current_selection]
	AND.w #$FF00
	STA.b SA1IRAM.cm_cursor+0

	LDY.w #$0002
	LDA.b [SA1IRAM.cm_current_selection],Y
	STA.b SA1IRAM.cm_cursor+2

.drawmenu
	JSR DrawCurrentMenu

	JSR CM_UpdateCurrentSelection
	JSL MenuSFX_submenu

.no
	RTS

#CMDO_SUBMENU_VARIABLE:
	BIT.b SA1IRAM.cm_ax
	BPL .no

	JSR EmptyCurrentMenu
	JSR CM_PushMenuToStack

	JSL MenuSFX_submenu
	SEC

	JSR CMDO_PERFORM_FUNC
	BRA .drawmenu

;===================================================================================================

CMDO_PRESET_UW:
CMDO_PRESET_OW:
	BIT.b SA1IRAM.cm_ax
	BMI .go

	RTS

.go
	JSR CMDO_SAVE_ADDRESS

	REP #$20
	TXA
	AND.w #$00FF
	STA.b SA1IRAM.preset_type

	LDA.b SA1IRAM.cm_writer+0
	STA.b SA1IRAM.preset_addr+0

	JSL CM_Exiting

	SEP #$30

	LDA.b SA1IRAM.cm_current_menu+2
	STA.b SA1IRAM.preset_addr+2

	JML LoadPreset

;===================================================================================================

CMDO_CTRL_SHORTCUT:
	JSR CMDO_SAVE_ADDRESS

	LDA.b #$C0
	BIT.b SA1IRAM.cm_ax
	BEQ .no

	REP #$20

	LDA.b SA1IRAM.cm_writer
	CMP.w #PracMenuShortcut
	BEQ .banned

	STZ.b SA1IRAM.preset_scratch

	LDA.w #$0000
	STA.b [SA1IRAM.cm_writer]
	BVS .delete

	LDA.w #$0008
	STA.b SA1IRAM.cm_submodule
	JSL MenuSFX_setshortcut
	RTS

.delete
	JSL MenuSFX_empty

.no
	RTS

.banned
	JSL MenuSFX_error
	RTS

;===================================================================================================

CMDO_LITESTATE:
	LDA.b [SA1IRAM.cm_current_selection],Y
	STA.w SA1IRAM.litestate_act

	BIT.b SA1IRAM.cm_ax
	BMI .load
	BVS .delete

	BIT.b SA1IRAM.cm_y
	BMI .save

	RTS

.save
	REP #$30
	LDA.w #$000A
	STA.b SA1IRAM.cm_submodule
	STZ.b SA1IRAM.preset_scratch

	RTS

.delete
	LDA.w SA1IRAM.litestate_act
	JSL ValidateLiteState
	BCC .invalid

	REP #$30
	LDA.w #$000C
	STA.b SA1IRAM.cm_submodule
	STZ.b SA1IRAM.preset_scratch
	RTS

.load
	JSL ValidateLiteState
	BCC .invalid

	JSL CM_Exiting

	REP #$20
	LDA.w SA1IRAM.litestate_act
	STA.w SA1IRAM.litestate_last
	JML LoadLiteState

.invalid
	JSL MenuSFX_error
	RTS

;===================================================================================================

CMDO_TOGGLE_ROOMFLAG:
	REP #$20

	LDA.b [SA1IRAM.cm_current_selection],Y
	AND.w #$00FF
	ASL
	TAY

	LDA.w SA1RAM.loadroomid
	AND.w #$00FF
	ASL
	TAX

	LDA.w CM_BITS_ASCENDING,Y

	BIT.b SA1IRAM.cm_ax-1
	BVS .clear
	BMI .toggle

	BIT.b SA1IRAM.cm_leftright-1
	BMI .toggle
	BVS .toggle

	BIT.b SA1IRAM.cm_y-1
	BMI .enable

	RTS

.clear
	EOR.w #$FFFF
	AND.l $7EF000,X
	STA.l $7EF000,X
	JSL MenuSFX_empty
	RTS

.toggle
	EOR.l $7EF000,X
	STA.l $7EF000,X
	JSL MenuSFX_bink
	RTS

.enable
	ORA.l $7EF000,X
	STA.l $7EF000,X
	JSL MenuSFX_fill
	RTS

;===================================================================================================

; very dumb hack
CMDO_NUMFIELD_CAPACITY:
	JSR CMDO_SAVE_ADDRESS

	REP #$30

	PHY
	PEI.b (SA1IRAM.cm_current_selection+2)
	PEI.b (SA1IRAM.cm_current_selection+0)

	PHX

	LDX.w #$7EF371
	LDY.w #$0DDB58

	LDA.b SA1IRAM.cm_writer
	CMP.w #$7EF377
	BEQ .arrows

	DEX
	LDY.w #$0DDB48

.arrows
	LDA.l $7E0000,X
	AND.w #$00FF
	STY.b SA1IRAM.cm_current_selection
	CLC
	ADC.b SA1IRAM.cm_current_selection
	TAX

	LDA.l $0D0000,X
	AND.w #$00FF
	ORA.w #$0500
	STZ.b SA1IRAM.preset_reader2+0
	STA.b SA1IRAM.preset_reader2+1

	STZ.b SA1IRAM.cm_current_selection+1
	LDA.w #SA1IRAM.preset_reader2
	STA.b SA1IRAM.cm_current_selection+0

	PLX
	SEP #$30

	LDY.b #$00

	JSR CMDO_NUMFIELD_MAIN

	REP #$30

	PLY
	STY.b SA1IRAM.cm_current_selection+0
	PLY
	STY.b SA1IRAM.cm_current_selection+2
	PLY

	RTS

;===================================================================================================

CMDO_NUMFIELD16:
	JSR CMDO_SAVE_ADDRESS
	REP #$20
	BRA CMDO_NUMFIELD_MAIN

CMDO_NUMFIELD:
CMDO_NUMFIELD_HEX:
CMDO_NUMFIELD_PRGTEXT:
CMDO_NUMFIELD_2DIGITS:
	JSR CMDO_SAVE_ADDRESS

CMDO_NUMFIELD_MAIN:
	PHX

	CLC

	LDA.b #$00
	SEC ; if 16 bit, this will be a high byte
	XBA ; put 00 in high byte
	LDA.l .zero
	ROL ; put carry in place
	TAX

	LDA.b [SA1IRAM.cm_writer]
	BIT.b SA1IRAM.cm_ax-1,X
	BVS .delete

	; Y currently points to our minimum value
	BIT.b SA1IRAM.cm_y-1,X
	BMI .get_max_min

	BIT.b SA1IRAM.cm_leftright-1,X
	BMI .decrement

	JSR .iny_twice_if_16 ; Y now points to our maximum
	BVS .increment

	JSR .iny_twice_if_16 ; now point to slider size or whatever you wanna call it
	BIT.b SA1IRAM.cm_shoulder-1,X
	BMI .dec_big
	BVS .inc_big

	JSR .iny_twice_if_16

	PLX
	CLC
	RTS

.delete
	JSL MenuSFX_empty
	BRA .clear_min

.topoff
	JSL MenuSFX_fill
	BRA .get_max_min

.increment
	CMP.b [SA1IRAM.cm_current_selection],Y
	INC
	BCC .in_range_max

.clear_max
	JSR .dey_twice_if_16

.clear_min
	LDA.b [SA1IRAM.cm_current_selection],Y

.in_range_min
	JSR .iny_twice_if_16 ; point to max

.in_range_max
	JSR .iny_twice_if_16 ; point to slide

.in_range_slide
.set
	STA.b [SA1IRAM.cm_writer]

	JSR .iny_twice_if_16 ; this should now point to after slide
	SEC
	JSL MenuSFX_bink
	PLX
	RTS

.decrement
	CMP.l .zero
	BEQ .get_max_min
	DEC

	; now our new value against the minimum
	CMP.b [SA1IRAM.cm_current_selection],Y
	JSR .iny_twice_if_16 ; point this to max, just in case we need it
	BCS .in_range_max
	BRA .get_max_max ; since we're already pointed there

.get_max_min
	JSR .iny_twice_if_16

.get_max_max
	LDA.b [SA1IRAM.cm_current_selection],Y
	BRA .in_range_max

.dec_big ; also these shouldn't wrap on overflow
	SEC
	SBC.b [SA1IRAM.cm_current_selection],Y
	JSR .dey_twice_if_16 ; pointing to max
	BCC .clear_max ; if we borrowed here, we need to floor ourselves

	JSR .dey_twice_if_16 ; pointing to min
	CMP.b [SA1IRAM.cm_current_selection],Y
	BCS .in_range_min ; we're fine
	BRA .clear_min ; don't go past the minimum

.inc_big
	CLC
	ADC.b [SA1IRAM.cm_current_selection],Y
	JSR .dey_twice_if_16 ; pointing to max
	BCS .get_max_max ; if we went too high, cap now

	CMP.b [SA1IRAM.cm_current_selection],Y
	BCS .get_max_max ; will cap if we match, but that's fine
	BRA .in_range_max

.zero
	dw 0

.iny_twice_if_16
	INY
	INY

	; if 8 bit, then it will DEY, otherwise it will BIT
	BIT.b #$FF
	DEY

	RTS

.dey_twice_if_16
	DEY
	DEY

	; if 8 bit, then it will INY, otherwise it will BIT
	BIT.b #$FF
	INY

	RTS

;===================================================================================================

CMDO_SENTRY_PICKER:
	LDX.b #$00

	JMP GO_TO_SENTRY_PICKER

CMDO_LINE_SENTRY_PICKER:
	LDX.b #$02

	JMP GO_TO_SENTRY_PICKER

;===================================================================================================
