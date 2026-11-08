!SENTRY_ID = -2
!SENTRY_GROUP_ID = -1
!LINE_SENTRY_GROUP_ID = -1

!MAX_SENTRIES = 100

;===================================================================================================

macro defsentry(name, varname)
	!SENTRY_ID += 2
	{varname} = !SENTRY_ID

	plop sentry_name_pointers+!SENTRY_ID :: dw !:here
		%cmstr("{name}")

	plop sentry_routines+!SENTRY_ID      :: dw !:here
	__SENTRY_CODE_{varname}:
endmacro

;---------------------------------------------------------------------------------------------------

macro sentry(name, varname)
	%defsentry("{name}", "SENTRY_{varname}")
endmacro

;---------------------------------------------------------------------------------------------------

macro sentry_var(var)
	plop sentry_inits+!SENTRY_ID :: dw {var}
endmacro

;---------------------------------------------------------------------------------------------------

macro sentry_init()
	plop sentry_inits+!SENTRY_ID :: dw !:here
endmacro

;---------------------------------------------------------------------------------------------------

macro line_sentry(name, varname)
	%defsentry("{name}", "LINE_SENTRY_{varname}")
endmacro

;---------------------------------------------------------------------------------------------------

macro sentry_icon(gfxoffset, props)
	plop sentry_icons+!SENTRY_ID        :: dw {props}|$2020
	plop sentry_icongfx+!SENTRY_ID      :: dw hud_sentryicons+{gfxoffset}*$10
endmacro

;---------------------------------------------------------------------------------------------------

macro set_sentry_routine(routine)
	plop sentry_routines+!SENTRY_ID      :: dw {routine}
endmacro

;===================================================================================================

macro sentry_group(name)
	!SENTRY_GROUP_ID += 1

{?}name:
	%cmstr("{name}")

{?}list:

SentryGroup_{?}:
	plop sentry_groups+(!SENTRY_GROUP_ID*8) :: dw {?}name, {?}list, .size/2
	plop SentryGroupCounts+0 :: dw !SENTRY_GROUP_ID+1

endmacro

;===================================================================================================

macro line_sentry_group(name)
	!LINE_SENTRY_GROUP_ID += 1


{?}name:
	%cmstr("{name}")

{?}list:

LineSentryGroup_{?}:
	plop line_sentry_groups+(!LINE_SENTRY_GROUP_ID*8) :: dw {?}name, {?}list, .size/2
	plop SentryGroupCounts+2 :: dw !LINE_SENTRY_GROUP_ID+1

endmacro

;---------------------------------------------------------------------------------------------------

macro end_sentry_group()
^.size
	dw $FFFF
endmacro

;===================================================================================================

sentry_groups:
	; dw <name pointer>, <list pointer> : db <size> ; 3 bytes free
	fill double count !MAX_SENTRIES :: $0000

line_sentry_groups:
	fill double count !MAX_SENTRIES :: $0000

;===================================================================================================

GO_TO_SENTRY_PICKER:
	LDA.b #$C0
	BIT.b IRAM.cm_ax
	BEQ .nothing

	JSR CMDO_SAVE_ADDRESS

	BIT.b IRAM.cm_ax
	BMI .setting

.clearing
	LDA.b #$00
	STA.b [IRAM.cm_writer]

	JSL MenuSFX.empty

.nothing
	RTS

.setting
	REP #$30

	STX.w BWRAM.sentry_type

	LDA.b IRAM.cm_writer
	STA.b IRAM.sentry_selected_address

	LDA.b (IRAM.sentry_selected_address)
	STA.w BWRAM.sentry_id

	STZ.w BWRAM.sentry_submodule

	LDA.b [IRAM.cm_current_selection],Y
	AND.w #$00FF
	STA.w BWRAM.sentry_index

	LDA.w #$000E
	STA.b IRAM.cm_submodule

	JSR GetSentryGroups
	JSR FindSentryMenuItem

	JSL MenuSFX.submenu

	RTS

;===================================================================================================

FindSentryMenuItem:
	PHY

	REP #$30

	LDY.w BWRAM.sentry_type
	LDA.w SentryGroupsList,Y
	STA.b IRAM.SCRATCH+0

	LDY.w #$0000

.next_group
	LDA.b (IRAM.SCRATCH+0),Y
	BEQ .failed

	PHY

	INY
	INY
	LDA.b (IRAM.SCRATCH+0),Y
	STA.b IRAM.SCRATCH+2

	INY
	INY
	LDA.b (IRAM.SCRATCH+0),Y ; get menu item count
	AND.w #$001F
	STA.w BWRAM.sentry_category_size
	DEC
	ASL
	TAY

	LDA.w BWRAM.sentry_id

.next_item
	CMP.b (IRAM.SCRATCH+2),Y
	BEQ .found_item

	DEY
	DEY
	BPL .next_item

	PLA
	CLC
	ADC.w #$0008
	TAY
	BRA .next_group

.set_category
	STA.w BWRAM.sentry_category
	JSR GetSentryCategoryInfo

.exit
	PLY
	RTS

.failed
	STZ.w BWRAM.sentry_id
	STZ.w BWRAM.sentry_item

	LDA.w #$0000
	BRA .set_category

.found_item
	TYA
	LSR
	STA.w BWRAM.sentry_item

	PLA ; get category from stack
	LSR
	LSR
	LSR

	BRA .set_category

;===================================================================================================

GetSentryCategoryInfo:
	PHP
	REP #$30
	PHY

	LDA.w BWRAM.sentry_category
	ASL
	ASL
	ASL
	STA.w BWRAM.sentry_category_index
	TAY

	LDA.b (IRAM.sentry_groups_pointer),Y
	STA.b IRAM.sentry_cat_name_pointer

	INY
	INY
	LDA.b (IRAM.sentry_groups_pointer),Y
	STA.b IRAM.sentry_cat_list_pointer

	INY
	INY
	LDA.b (IRAM.sentry_groups_pointer),Y
	AND.w #$00FF
	STA.w BWRAM.sentry_category_size

	PLY
	PLP
	RTS

;===================================================================================================

GetSentryGroups:
	PHP

	REP #$30
	PHY

	LDY.w BWRAM.sentry_type
	LDA.w SentryGroupsList,Y
	STA.b IRAM.sentry_groups_pointer

	PLY
	PLP
	RTS

;===================================================================================================

SentryGroupsList:
	dw sentry_groups
	dw line_sentry_groups

SentryGroupCounts:
	dw 0
	dw 0

SentryGroupNames:
	dw .normal
	dw .line

.normal
	%cmstr("Setting sentry ")

.line
	%cmstr("Setting line sentry ")

;===================================================================================================

CM_SetSentry:
	JSR GetSentryGroups

	LDX.w BWRAM.sentry_submodule
	JMP (.submods,X)

.submods
	dw SetSentry_Init
	dw SetSentry_Choose
	dw SetSentry_CloseMenu

;===================================================================================================

SetSentry_Init:
	INX
	INX
	STX.w BWRAM.sentry_submodule

	JSR CM_PushMenuToStack

	JMP RedrawSentryMenu

;===================================================================================================

SetSentry_Exit:
	REP #$30

	LDX.w #$0004
	STX.b IRAM.cm_submodule

	JMP CM_GoBack

;===================================================================================================

SetSentry_CloseMenu:
	JSR CM_PullMenuFromStack
	JMP CM_ExitTime

;===================================================================================================

SetSentry_Choose:
	JSR CM_getcontroller
	LDA.b IRAM.cm_ax
	BPL .no_a_press

	JMP .pressed_a

.no_a_press
	BCS SetSentry_Exit

	LDA.b IRAM.cm_leftright
	ORA.b IRAM.cm_shoulder
	AND.b #$C0
	BNE .change_category

	LDA.w BWRAM.sentry_item

	BIT.b IRAM.cm_updown
	BMI .pressed_up
	BVS .pressed_down

	LDA.b IRAM.copyof_F4
	BIT.b #$10
	BNE SetSentry_CloseMenu

	RTS

.pressed_up
	DEC.w BWRAM.sentry_item
	BRA .check_wrap

.pressed_down
	INC.w BWRAM.sentry_item

.check_wrap
	LDA.w BWRAM.sentry_item
	BMI .set_to_max

	CMP.w BWRAM.sentry_category_size
	BCC .cursor_fine

	STZ.w BWRAM.sentry_item
	BRA .cursor_fine

.set_to_max
	LDA.w BWRAM.sentry_category_size
	DEC
	STA.w BWRAM.sentry_item

.cursor_fine
	JSL MenuSFX.boop
	JMP RedrawSentryMenu

;---------------------------------------------------------------------------------------------------

.change_category
	ASL

	LDX.w BWRAM.sentry_type

	LDA.w BWRAM.sentry_category
	BCS .pressed_left

.pressed_right
	INC
	BRA .handle_category_wrap

.pressed_left
	BEQ .max_category
	DEC

.handle_category_wrap
	CMP.w SentryGroupCounts,X
	BCC .set_category

	LDA.b #$00
	BRA .set_category

.max_category
	LDA.w SentryGroupCounts,X
	DEC

.set_category
	STA.w BWRAM.sentry_category
	STZ.w BWRAM.sentry_item

	JSR GetSentryCategoryInfo

	JSL MenuSFX.bink
	JMP RedrawSentryMenu

;---------------------------------------------------------------------------------------------------

.pressed_a
	REP #$30

	LDA.w BWRAM.sentry_item
	ASL
	TAY
	LDA.b (IRAM.sentry_cat_list_pointer),Y
	STA.b (IRAM.sentry_selected_address)

	JSL MenuSFX.tinkle
	JMP RedrawSentryMenu

;===================================================================================================

RedrawSentryMenu:
	JSR EmptyEntireMenu

	REP #$30

	LDY.w BWRAM.sentry_type
	LDA.w SentryGroupNames,Y
	JSR SetTextPointer

	; draw header
	LDY.w #$0000
	LDX.w YRowToXOffset,Y

	LDA.w #!HEADER
	STA.b IRAM.cm_draw_color

	JSR DrawEmptyCharacter

	JSR DrawRowText

	LDA.w BWRAM.sentry_index
	AND.w #$000F
	ORA.w #$0010
	JSR DrawSingleCharacter

	JSR EmptyRestOfRow

	; draw category header
	LDY.w #$0002
	LDX.w YRowToXOffset,Y

	JSR DrawEmptyCharacter

	LDA.w #$007C ; left arrow
	JSR DrawSingleCharacter

	LDA.w IRAM.sentry_cat_name_pointer
	JSR SetTextPointer

	JSR DrawRowText

	LDA.w #$007D ; right arrow
	JSR DrawSingleCharacter

	JSR EmptyRestOfRow

	; draw every option
	LDY.w #$0000

.next_option
	LDA.b (IRAM.sentry_cat_list_pointer),Y
	CMP.w #$FFFF
	BEQ .done

	PHY
	PHA

	LDX.w #!UNSELECTED

	TYA
	LSR
	CMP.w BWRAM.sentry_item
	BNE .not_selected

	LDX.w #!SELECTED

.not_selected
	STX.b IRAM.cm_draw_color

	INY
	INY
	INY
	INY
	LDX.w YRowToXOffset,Y

	JSR DrawEmptyCharacter

	; get row's ID
	LDA 1,S

	LDY.w #$0064 ; checkmark for selected
	CMP.b (IRAM.sentry_selected_address)
	BEQ .active_sentry

	LDY.w #' '

.active_sentry
	TYA
	JSR DrawSingleCharacter

	PLA
	JSR CMDRAW_SENTRY_BY_ID
	JSR EmptyRestOfRow

	PLY
	INY
	INY
	BRA .next_option

.done
	RTS

;===================================================================================================

CMDRAW_SENTRY_BY_ID:
	TAY
	LDA.w sentry_name_pointers,Y
	JSR SetTextPointer
	JMP DrawRowText

;===================================================================================================
