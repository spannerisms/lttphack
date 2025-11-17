!SENTRY_ID #= -2
!SENTRY_GROUP_ID #= -1
!LINE_SENTRY_GROUP_ID #= -1

macro defsentry(name, varname, init)
	!SENTRY_ID #= !SENTRY_ID+2
	<varname> = !SENTRY_ID

	pushpc
		org sentry_inits+!SENTRY_ID         : dw <init>
		org sentry_routines+!SENTRY_ID      : dw ?code
		org sentry_name_pointers+!SENTRY_ID : dw ?name
	pullpc

__SENTRY_CODE_<varname>:

?name: db "<name>", $FF

?code:

endmacro

macro sentry(addr, name, varname)
	%defsentry("<name>", "SENTRY_<varname>", <addr>)
endmacro

macro sentry_no_init(name, varname)
	%defsentry("<name>", "SENTRY_<varname>", no_sentry_init)
endmacro

macro line_sentry(name, varname)
	%defsentry("<name>", "LINE_SENTRY_<varname>", __SENTRY_CODE_LINE_SENTRY_<varname>_init)
endmacro

macro set_sentry_icon(gfxoffset, props)
	pushpc
		org sentry_icons+!SENTRY_ID        : dw <props>|$2020
		org sentry_icongfx+!SENTRY_ID      : dw hud_sentryicons+(<gfxoffset>*$10)
	pullpc
endmacro

macro set_sentry_raw()
	pushpc
		org sentry_routines+!SENTRY_ID      : dw sentry_raw
	pullpc
endmacro

;===================================================================================================

macro sentry_group(name)
	!SENTRY_GROUP_ID #= !SENTRY_GROUP_ID+1

	pushpc
		org sentry_groups+(!SENTRY_GROUP_ID*8) : dw ?name, ?list
		-------------------------------------------------- ; big backwards label for easy access
		org SentryGroupCounts+0 : dw !SENTRY_GROUP_ID+1
	pullpc

?name: db "<name>", $FF

?list:

SentryGroup_!SENTRY_GROUP_ID:
.top

endmacro

;===================================================================================================

macro line_sentry_group(name)
	!LINE_SENTRY_GROUP_ID #= !LINE_SENTRY_GROUP_ID+1

	pushpc
		org line_sentry_groups+(!LINE_SENTRY_GROUP_ID*8) : dw ?name, ?list
		-------------------------------------------------- ; big backwards label for easy access
		org SentryGroupCounts+2 : dw !LINE_SENTRY_GROUP_ID+1
	pullpc

?name: db "<name>", $FF

?list:

LineSentryGroup_!LINE_SENTRY_GROUP_ID:
.top

endmacro

;---------------------------------------------------------------------------------------------------

macro end_sentry_group()
.end
	dw $FFFF

	pushpc
		org -------------------------------------------------- : db (.end-.top)/2
	pullpc
endmacro

;===================================================================================================

sentry_groups:
	; dw <name pointer>, <list pointer> : db <size> ; 3 bytes free
	fillword $0000 : fill 50*8

line_sentry_groups:
	fillword $0000 : fill 50*8

;===================================================================================================

GO_TO_SENTRY_PICKER:
	LDA.b #$C0
	BIT.b SA1IRAM.cm_ax
	BEQ .nothing

	JSR CMDO_SAVE_ADDRESS_00

	BIT.b SA1IRAM.cm_ax
	BMI .setting

.clearing
	LDA.b #$00
	STA.b [SA1IRAM.cm_writer]

	JSL CM_MenuSFX_empty

.nothing
	RTS

.setting
	REP #$30

	STX.w SA1RAM.sentry_type

	LDA.b SA1IRAM.cm_writer
	STA.b SA1IRAM.sentry_selected_address

	LDA.b (SA1IRAM.sentry_selected_address)
	STA.w SA1RAM.sentry_id

	STZ.w SA1RAM.sentry_submodule

	LDA.b [SA1IRAM.cm_current_selection],Y
	AND.w #$00FF
	STA.w SA1RAM.sentry_index

	LDA.w #$000E
	STA.b SA1IRAM.cm_submodule

	JSR GetSentryGroups
	JSR FindSentryMenuItem

	JSL CM_MenuSFX_submenu

	RTS

;===================================================================================================

FindSentryMenuItem:
	PHY

	REP #$30

	LDY.w SA1RAM.sentry_type
	LDA.w SentryGroupsList,Y
	STA.b SA1IRAM.SCRATCH+0

	LDY.w #$0000

.next_group
	LDA.b (SA1IRAM.SCRATCH+0),Y
	BEQ .failed

	PHY

	INY
	INY
	LDA.b (SA1IRAM.SCRATCH+0),Y
	STA.b SA1IRAM.SCRATCH+2

	INY
	INY
	LDA.b (SA1IRAM.SCRATCH+0),Y ; get menu item count
	AND.w #$001F
	STA.w SA1RAM.sentry_category_size
	DEC
	ASL
	TAY

	LDA.w SA1RAM.sentry_id

.next_item
	CMP.b (SA1IRAM.SCRATCH+2),Y
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
	STA.w SA1RAM.sentry_category
	JSR GetSentryCategoryInfo

.exit
	PLY
	RTS

.failed
	STZ.w SA1RAM.sentry_id
	STZ.w SA1RAM.sentry_item

	LDA.w #$0000
	BRA .set_category

.found_item
	TYA
	LSR
	STA.w SA1RAM.sentry_item

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

	LDA.w SA1RAM.sentry_category
	ASL
	ASL
	ASL
	STA.w SA1RAM.sentry_category_index
	TAY

	LDA.b (SA1IRAM.sentry_groups_pointer),Y
	STA.b SA1IRAM.sentry_cat_name_pointer

	INY
	INY
	LDA.b (SA1IRAM.sentry_groups_pointer),Y
	STA.b SA1IRAM.sentry_cat_list_pointer

	INY
	INY
	LDA.b (SA1IRAM.sentry_groups_pointer),Y
	AND.w #$00FF
	STA.w SA1RAM.sentry_category_size

	PLY
	PLP
	RTS

;===================================================================================================

GetSentryGroups:
	PHP

	REP #$30
	PHY

	LDY.w SA1RAM.sentry_type
	LDA.w SentryGroupsList,Y
	STA.b SA1IRAM.sentry_groups_pointer

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
	db "Setting sentry ", $FF

.line
	db "Setting line sentry ", $FF

;===================================================================================================

CM_SetSentry:
	JSR GetSentryGroups

	LDX.w SA1RAM.sentry_submodule
	JMP (.submods,X)

.submods
	dw SetSentry_Init
	dw SetSentry_Choose
	dw SetSentry_CloseMenu

;===================================================================================================

SetSentry_Init:
	INX
	INX
	STX.w SA1RAM.sentry_submodule

	JSR CM_PushMenuToStack

	JMP RedrawSentryMenu

;===================================================================================================

SetSentry_Exit:
	REP #$30

	LDX.w #$0004
	STX.b SA1IRAM.cm_submodule

	JMP CM_GoBack

;===================================================================================================

SetSentry_CloseMenu:
	JSR CM_PullMenuFromStack
	JMP CM_ExitTime

;===================================================================================================

SetSentry_Choose:
	JSR CM_getcontroller
	LDA.b SA1IRAM.cm_ax
	BPL .no_a_press

	JMP .pressed_a

.no_a_press
	BCS SetSentry_Exit

	LDA.b SA1IRAM.cm_leftright
	ORA.b SA1IRAM.cm_shoulder
	AND.b #$C0
	BNE .change_category

	LDA.w SA1RAM.sentry_item

	BIT.b SA1IRAM.cm_updown
	BMI .pressed_up
	BVS .pressed_down

	LDA.b SA1IRAM.CopyOf_F4
	BIT.b #$10
	BNE SetSentry_CloseMenu

	RTS

.pressed_up
	DEC.w SA1RAM.sentry_item
	BRA .check_wrap

.pressed_down
	INC.w SA1RAM.sentry_item

.check_wrap
	LDA.w SA1RAM.sentry_item
	BMI .set_to_max

	CMP.w SA1RAM.sentry_category_size
	BCC .cursor_fine

	STZ.w SA1RAM.sentry_item
	BRA .cursor_fine

.set_to_max
	LDA.w SA1RAM.sentry_category_size
	DEC
	STA.w SA1RAM.sentry_item

.cursor_fine
	JSL CM_MenuSFX_boop
	JMP RedrawSentryMenu

;---------------------------------------------------------------------------------------------------

.change_category
	ASL

	LDX.w SA1RAM.sentry_type

	LDA.w SA1RAM.sentry_category
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
	STA.w SA1RAM.sentry_category
	STZ.w SA1RAM.sentry_item

	JSR GetSentryCategoryInfo

	JSL CM_MenuSFX_bink
	JMP RedrawSentryMenu

;---------------------------------------------------------------------------------------------------

.pressed_a
	REP #$30

	LDA.w SA1RAM.sentry_item
	ASL
	TAY
	LDA.b (SA1IRAM.sentry_cat_list_pointer),Y
	STA.b (SA1IRAM.sentry_selected_address)

	JSL CM_MenuSFX_tinkle
	JMP RedrawSentryMenu

;===================================================================================================

RedrawSentryMenu:
	JSR EmptyEntireMenu

	REP #$30

	LDY.w SA1RAM.sentry_type
	LDA.w SentryGroupNames,Y
	JSR SetTextPointer

	; draw header
	LDY.w #$0000
	JSR CM_YRowToXOffset

	LDA.w #!HEADER
	STA.b SA1IRAM.cm_draw_color

	JSR DrawEmptyCharacter

	JSR DrawRowText

	LDA.w SA1RAM.sentry_index
	AND.w #$000F
	JSR DrawSingleCharacter

	JSR EmptyRestOfRow

	; draw category header
	LDY.w #$0002
	JSR CM_YRowToXOffset

	JSR DrawEmptyCharacter

	LDA.w #$007C ; left arrow
	JSR DrawSingleCharacter

	LDA.w SA1IRAM.sentry_cat_name_pointer
	JSR SetTextPointer

	JSR DrawRowText

	LDA.w #$007D ; right arrow
	JSR DrawSingleCharacter

	JSR EmptyRestOfRow

	; draw every option
	LDY.w #$0000

.next_option
	LDA.b (SA1IRAM.sentry_cat_list_pointer),Y
	CMP.w #$FFFF
	BEQ .done

	PHY
	PHA

	LDX.w #!UNSELECTED

	TYA
	LSR
	CMP.w SA1RAM.sentry_item
	BNE .not_selected

	LDX.w #!SELECTED

.not_selected
	STX.b SA1IRAM.cm_draw_color

	INY
	INY
	INY
	INY
	JSR CM_YRowToXOffset

	JSR DrawEmptyCharacter

	; get row's ID
	LDA 1,S

	LDY.w #$003A ; checkmark for selected
	CMP.b (SA1IRAM.sentry_selected_address)
	BEQ .active_sentry

	LDY.w #$002F

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
