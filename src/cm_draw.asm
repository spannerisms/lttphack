
;===================================================================================================

ERROR_TEXT:         %cmstr("BAD VAL")

CMTEXT_RANDOM:      %cmstr("Random")
CMTEXT_UNFIXED:     %cmstr("Unfixed")

CMTEXT_NO:          %cmstr("No")
CMTEXT_YES:         %cmstr("Yes")
CMTEXT_VANILLA:     %cmstr("Vanilla")

CMTEXT_DEFAULT:     %cmstr("Default")
CMTEXT_CURRENT:     %cmstr("Current")


;===================================================================================================

EmptyEntireMenu:
	REP #$20
	SEP #$10

	LDX.b #$00
	LDA.w #' '

.loop
	STA.w SA1RAM.MENU+$0000,X : STA.w SA1RAM.MENU+$0080,X
	STA.w SA1RAM.MENU+$0100,X : STA.w SA1RAM.MENU+$0180,X
	STA.w SA1RAM.MENU+$0200,X : STA.w SA1RAM.MENU+$0280,X
	STA.w SA1RAM.MENU+$0300,X : STA.w SA1RAM.MENU+$0380,X
	STA.w SA1RAM.MENU+$0400,X : STA.w SA1RAM.MENU+$0480,X
	STA.w SA1RAM.MENU+$0500,X : STA.w SA1RAM.MENU+$0580,X
	STA.w SA1RAM.MENU+$0600,X : STA.w SA1RAM.MENU+$0680,X
	STA.w SA1RAM.MENU+$0700,X : STA.w SA1RAM.MENU+$0780,X

	INX
	INX
	BPL .loop

;===================================================================================================

RedrawMenuTrim:
	LDX.w .length
	LDA.w #$3101

.headera
	STA.w SA1RAM.MENU+$0000,X

	DEX
	DEX
	BPL .headera

	LDX.w .length

	ORA.w #$8000

.headerb
	STA.w SA1RAM.MENU+$0080,X
	DEX
	DEX
	BPL .headerb

	RTS

.length
	dw $003E

;===================================================================================================

EmptyCurrentMenu:
	REP #$30

	LDY.w #0

	; clean every row
.nextclean
	LDA.b [SA1IRAM.cm_current_menu],Y
	BPL RedrawMenuTrim ; if we hit a 0, we're done

	JSR EmptyCurrentRow

	INY
	INY
	BRA .nextclean

;===================================================================================================

RedrawCurrentMenu:
	JSR DrawCurrentMenu
	RTL

;===================================================================================================

DrawCurrentMenu:
	REP #$30

	LDA.w #NoBonusRoutine
	STA.w SA1RAM.NMIBonusVector

	LDY.w #0

.nextdraw
	LDA.b [SA1IRAM.cm_current_menu],Y
	BPL RedrawMenuTrim

	PHY

	JSR DrawCurrentRow

	PLY
	INY
	INY
	BRA .nextdraw

;===================================================================================================

SetTextPointer:
	LDY.w #SetTextPointer>>8
	STY.b SA1IRAM.cm_current_draw+1

	STA.b SA1IRAM.cm_current_draw+0

	LDY.w #$0000

	RTS

;===================================================================================================

DrawRowText:
	; write out item name
.next_letter
	LDA.b [SA1IRAM.cm_current_draw],Y
	AND.w #$00FF
	BEQ .done_row_name

	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X

	INY

	INX
	INX
	BRA .next_letter

.done_row_name
	RTS

;===================================================================================================

DrawEmptyCharacter:
	LDA.w #' '

DrawSingleCharacter:
	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X
	INX
	INX
	RTS

;===================================================================================================

CMDRAW_DIGIT:
	ORA.b #$10

CMDRAW_CHAR:
	REP #$20

	AND.w #$007F
	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X

	SEP #$20

	INX
	INX

	RTL


;===================================================================================================

EmptyCurrentRow:
	LDX.w YRowToXOffset,Y

	STZ.b SA1IRAM.cm_draw_color

;===================================================================================================

EmptyRestOfRow:
	LDA.w #' '
	ORA.b SA1IRAM.cm_draw_color
	STA.b SA1IRAM.cm_draw_filler

.next
	LDA.b SA1IRAM.cm_draw_filler
	STA.w SA1RAM.MENU,X

	INX
	INX
	TXA
	AND.w #$003F
	BNE .next

	RTS

;===================================================================================================


YRowToXOffset:
	dw $0040
	dw $00C0
	dw $0100
	dw $0140
	dw $0180
	dw $01C0
	dw $0200
	dw $0240
	dw $0280
	dw $02C0
	dw $0300
	dw $0340
	dw $0380
	dw $03C0
	dw $0400
	dw $0440
	dw $0480
	dw $04C0
	dw $0500
	dw $0540
	dw $0580
	dw $05C0
	dw $0600
	dw $0640
	dw $0680
	dw $06C0
	dw $0700
	dw $0740
	dw $0780
	dw $07C0

;===================================================================================================

; in this case,Y holds the cursor index, not the message index
DrawCurrentRow_ShiftY:
	SEP #$10 ; clear top of Y, just in case
	REP #$30
	TYA
	INC
	ASL
	TAY

;===================================================================================================

; Y = index into thing where 0 = header
DrawCurrentRow:
	; location of row text
	LDA.b SA1IRAM.cm_current_menu+1
	STA.b SA1IRAM.cm_current_draw+1

	LDA.b [SA1IRAM.cm_current_menu],Y
	STA.b SA1IRAM.cm_current_draw+0

	TYA
	LSR

	DEC ; negative means it was 0, aka a header
	BMI .header

	SEP #$20
	CMP.b SA1IRAM.cm_cursor ; does it match our selection?
	REP #$20
	BNE .noselect

.select
	LDX.b SA1IRAM.cm_submodule
	LDA.w SelectionColors,X
	BRA .setcol

.header
	LDA.w #!HEADER
	BRA .setcol

.noselect
	LDA.w #!UNSELECTED

.setcol
	STA.b SA1IRAM.cm_draw_color

	LDX.w YRowToXOffset,Y

	ORA.w #' ' ; fill first character
	STA.w SA1RAM.MENU,X
	INX
	INX

	TYA
	BEQ .isheader

	LDA.b [SA1IRAM.cm_current_draw] ; what routine type is it?
	AND.w #$00FF

.isheader
	PHX
	TAX

	ASL
	STA.b SA1IRAM.cm_draw_type_offset ; remember the type for drawing

	LDA.w ActionLengths,X ; this is how many bytes the header is for the item
	AND.w #$00FF
	TAY ; location of name
	STY.b SA1IRAM.prgtext_jump

	LDA.w ActionIcons,X
	AND.w #$00FF
	PLX

	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X
	INX
	INX

;---------------------------------------------------------------------------------------------------

	; write out item name
.next_letter
	LDA.b [SA1IRAM.cm_current_draw],Y
	AND.w #$00FF
	BEQ .done_row_name

	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X

	INY

	INX
	INX
	BRA .next_letter

.done_row_name
	TYA
	SBC.b SA1IRAM.prgtext_jump

	; remember where name ended
	INY
	STY.b SA1IRAM.prgtext_jump

	EOR.w #$FFFF
	CLC
	ADC.w #16
	BMI .long_name

	TAY

	LDA.w #' '
	ORA.b SA1IRAM.cm_draw_color

.next_mid_fill
	STA.w SA1RAM.MENU,X

	INX
	INX
	DEY
	BPL .next_mid_fill

;---------------------------------------------------------------------------------------------------

.long_name
	; now draw the specific routine type
	LDY.b SA1IRAM.cm_draw_type_offset
	LDA.w ActionDrawRoutines,Y
	STA.b SA1IRAM.cm_draw_filler

	PEA.w .return-1

	SEP #$20 ; more useful during drawing
	LDY.w #1 ; to skip the draw type

	JMP.w (SA1IRAM.cm_draw_filler)

.return
	REP #$20

	JMP EmptyRestOfRow

;===================================================================================================

CMDRAW_GET_DATA_ADDRESS:
	LDY.w #$0001

CMDraw_ReadNextAddress:
	REP #$20

	LDA.b [SA1IRAM.cm_current_draw],Y
	INY
	INY

	STA.b SA1IRAM.cm_writer+0

	LDA.w #$0000 ; clear top byte to be nice

	SEP #$20

	LDA.b [SA1IRAM.cm_current_draw],Y
	STA.b SA1IRAM.cm_writer+2
	INY

	RTS

;===================================================================================================

CMDraw_GetCustomTextAddress:
	REP #$21

	LDY.b SA1IRAM.prgtext_jump

	LDA.b [SA1IRAM.cm_current_draw],Y
	STA.b SA1IRAM.prgtext_jump+0

	INY
	INY

	SEP #$20

	LDA.b [SA1IRAM.cm_current_draw],Y
	STA.b SA1IRAM.prgtext_jump+2

	RTS

;===================================================================================================

CMDRAW_WORD_LONG:
	PHP
	REP #$30
	PHY
	PHB

	STA.b SA1IRAM.draw_text_ptr

	SEP #$20
	LDA.b SA1IRAM.cm_writer+2
	PHA
	PLB

	REP #$20
	BRA CMDRAW_WORD_START

;===================================================================================================

CMDRAW_WORD_CUSTOMTEXT:
	PHP
	REP #$30
	PHY
	PHB

	STA.b SA1IRAM.draw_text_ptr

	SEP #$20
	LDA.b SA1IRAM.prgtext_jump+2
	PHA
	PLB

	REP #$20
	BRA CMDRAW_WORD_START

;===================================================================================================

CMDRAW_WORD:
	PHP
	REP #$30
	PHY

	PHB
	PHK
	PLB

	STA.b SA1IRAM.draw_text_ptr

CMDRAW_WORD_START:
	LDY.w #0

.next
	LDA.b (SA1IRAM.draw_text_ptr),Y
	AND.w #$00FF
	BEQ .done

	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X
	INX
	INX
	INY
	BRA .next

.done
	PLB
	PLY
	PLP
	RTS

;===================================================================================================

CMDRAW_RANDOM:
	REP #$20
	LDA.w #CMTEXT_RANDOM
	JSR CMDRAW_WORD
	RTL

;===================================================================================================

CMDRAW_ERROR:
	REP #$20
	LDA.w #ERROR_TEXT
	JSR CMDRAW_WORD
	RTL

;===================================================================================================

CMDRAW_WORD_FUNCEND:
	PHK
	PLB

	JSR CMDRAW_WORD
	RTL

;===================================================================================================

CMDRAW_ONOFF:
%toggletext("Off", "On")

;===================================================================================================

CMDRAW_HEX_2_DIGITS:
	LDY.w #2
	BRA CMDRAW_HEX

CMDRAW_HEX_3_DIGITS:
	LDY.w #3
	BRA CMDRAW_HEX

CMDRAW_HEX_4_DIGITS:
	LDY.w #4
	BRA CMDRAW_HEX

CMDRAW_HEX:
	PHP

	REP #$20
	PHA ; remember number

	LDA.w #'$' ; first add hex prefix to menu
	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X

	TYA
	ASL
	STA.w $0000
	TXA
	ADC.w $0000 ; A now points to last digit of the number
	TAX ; let X have that for later

	PLA ; get A back
	PHX ; save X position, we're going to decrement it soon

	BRA .fill_hex

.next_digit
	LSR
	LSR
	LSR
	LSR

.fill_hex
	PHA

	AND.w #$000F
	ORA.b SA1IRAM.cm_draw_color
	ORA.w #$0010
	STA.w SA1RAM.MENU,X

	PLA

	DEX
	DEX

	DEY
	BNE .next_digit

	PLX ; recover position
	INX ; set it to after the last digit
	INX

	PLP
	RTL


;===================================================================================================

CMDRAW_TOGGLEBIT0:
CMDRAW_TOGGLEBIT0_FUNC:
	LDA.b #1<<0 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT1:
CMDRAW_TOGGLEBIT1_FUNC:
	LDA.b #1<<1 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT2:
CMDRAW_TOGGLEBIT2_FUNC:
	LDA.b #1<<2 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT3:
CMDRAW_TOGGLEBIT3_FUNC:
	LDA.b #1<<3 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT4:
CMDRAW_TOGGLEBIT4_FUNC:
	LDA.b #1<<4 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT5:
CMDRAW_TOGGLEBIT5_FUNC:
	LDA.b #1<<5 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT6:
CMDRAW_TOGGLEBIT6_FUNC:
	LDA.b #1<<6 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLEBIT7:
CMDRAW_TOGGLEBIT7_FUNC:
	LDA.b #1<<7 : BRA CMDRAW_CHECKBIT

CMDRAW_TOGGLE:
CMDRAW_TOGGLE_FUNC:
	LDA.b #$FF

;---------------------------------------------------------------------------------------------------

CMDRAW_CHECKBIT:
	PHA

	JSR CMDraw_ReadNextAddress

	PLA
	AND.b [SA1IRAM.cm_writer]

	REP #$20
	BNE .yes

	LDA.w #CMTEXT_NO
	JMP CMDRAW_WORD

.yes
	LDA.w #CMTEXT_YES
	JMP CMDRAW_WORD

;===================================================================================================

CMDRAW_TOGGLEBIT0_CUSTOMTEXT:
CMDRAW_TOGGLEBIT0_FUNC_CUSTOMTEXT:
	LDA.b #1<<0 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT1_CUSTOMTEXT:
CMDRAW_TOGGLEBIT1_FUNC_CUSTOMTEXT:
	LDA.b #1<<1 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT2_CUSTOMTEXT:
CMDRAW_TOGGLEBIT2_FUNC_CUSTOMTEXT:
	LDA.b #1<<2 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT3_CUSTOMTEXT:
CMDRAW_TOGGLEBIT3_FUNC_CUSTOMTEXT:
	LDA.b #1<<3 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT4_CUSTOMTEXT:
CMDRAW_TOGGLEBIT4_FUNC_CUSTOMTEXT:
	LDA.b #1<<4 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT5_CUSTOMTEXT:
CMDRAW_TOGGLEBIT5_FUNC_CUSTOMTEXT:
	LDA.b #1<<5 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT6_CUSTOMTEXT:
CMDRAW_TOGGLEBIT6_FUNC_CUSTOMTEXT:
	LDA.b #1<<6 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLEBIT7_CUSTOMTEXT:
CMDRAW_TOGGLEBIT7_FUNC_CUSTOMTEXT:
	LDA.b #1<<7 : BRA CMDRAW_CHECKBIT_CUSTOMTEXT

CMDRAW_TOGGLE_CUSTOMTEXT:
CMDRAW_TOGGLE_FUNC_CUSTOMTEXT:
	LDA.b #$FF

;---------------------------------------------------------------------------------------------------

CMDRAW_CHECKBIT_CUSTOMTEXT:
	PHA

	JSR CMDraw_ReadNextAddress

	PLA
	AND.b [SA1IRAM.cm_writer]
	PHP

	JSR CMDraw_GetCustomTextAddress

	PLA

	REP #$20

	AND.w #$0002 ; isolate zero flag
	EOR.w #$0002
	TAY

	LDA.b [SA1IRAM.prgtext_jump],Y
	JMP CMDRAW_WORD_CUSTOMTEXT

;===================================================================================================

CMDRAW_TOGGLE_ROOMFLAG:
	REP #$20

	LDA.b [SA1IRAM.cm_current_draw],Y
	AND.w #$00FF
	ASL
	TAY

	PHX

	LDA.w SA1RAM.loadroomid : ASL : TAX
	LDA.l $7EF000,X
	TYX
	AND.l CM_BITS_ASCENDING,X

	PLX

	CMP.w #$0001

	LDA.w #'0'
	ADC.w #$0000

	JMP DrawSingleCharacter

;===================================================================================================

CM_BITS_ASCENDING:
	dw 1<<0
	dw 1<<1
	dw 1<<2
	dw 1<<3
	dw 1<<4
	dw 1<<5
	dw 1<<6
	dw 1<<7
	dw 1<<8
	dw 1<<9
	dw 1<<10
	dw 1<<11
	dw 1<<12
	dw 1<<13
	dw 1<<14
	dw 1<<15

;===================================================================================================

CMDRAW_NUMFIELD16:
CMDRAW_NUMFIELD16_FUNC:
	JSR CMDraw_ReadNextAddress

.continue_3
	LDY.w #3

.continue
	PHY

	REP #$20

	LDA.b [SA1IRAM.cm_writer]
	JSR CMDRAW_HEX16_TO_DEC

	PLY
	JMP CMDRAW_NUMBER_DEC

;---------------------------------------------------------------------------------------------------

CMDRAW_NUMFIELD_2DIGITS:
CMDRAW_NUMFIELD_CAPACITY: ; so bombs and arrows align better
	JSR CMDraw_ReadNextAddress
	LDY.w #2
	BRA .continue

#CMDRAW_NUMFIELD:
#CMDRAW_NUMFIELD_FUNC:
	JSR CMDraw_ReadNextAddress

.continue_3
	LDY.w #3

.continue
	PHY

	LDA.b [SA1IRAM.cm_writer]
	JSR CMDRAW_HEX8_TO_DEC

	PLY

;===================================================================================================

CMDRAW_NUMBER_DEC:
	REP #$20

	; TODO figure out how to right align numbers because I screwed it up
;	CPY.w SA1RAM.dec_count
;	BEQ .count_fine
;	BCC .count_fine

	LDY.w SA1RAM.dec_count

.count_fine
	STY.b SA1IRAM.cm_writer

	TYA
	SBC.w #4
	STA.b SA1IRAM.cm_writer

	DEY

.next_digit
	LDA.w SA1RAM.dec_out,Y
	AND.w #$000F
	ORA.w #$0010
	ORA.b SA1IRAM.cm_draw_color

	STA.w SA1RAM.MENU,X
	INX
	INX

	DEY
	BPL .next_digit

	RTS

;===================================================================================================

CMDRAW_INFO_4HEX:
	JSR CMDraw_ReadNextAddress

	REP #$20

	LDA.b [SA1IRAM.cm_writer]
	JSL CMDRAW_HEX_4_DIGITS

	RTS


CMDRAW_INFO_1DIGIT:
	JSR CMDraw_ReadNextAddress

	LDA.b [SA1IRAM.cm_writer]
	AND.b #$0F

	JSL CMDRAW_DIGIT
	RTS

;===================================================================================================

CMDRAW_NUMFIELD_HEX_UPDATEWHOLEMENU:
CMDRAW_NUMFIELD_HEX:
CMDRAW_NUMFIELD_FUNC_HEX:
	JSR CMDraw_ReadNextAddress

	LDA.b [SA1IRAM.cm_writer]
	JSL CMDRAW_HEX_2_DIGITS

	RTS

;===================================================================================================

CMDRAW_HEX8_TO_DEC:
	REP #$20
	AND.w #$00FF

CMDRAW_HEX16_TO_DEC:
	PHX

	STZ.w SA1RAM.dec_out+3 ; clear 1k and 10k
	CMP.w #1000
	BCC .under_1k

	TAY
	STA.l $4204 ; dividend

	SEP #$20

	LDA.b #100
	STA.l $4206 ; divide by 100

	REP #$20

	LDA.w #4
	CPY.w #10000
	ADC.w #0
	TAY

	LDA.l $4214 ; get quotient for hundreds and 10s
	ASL
	TAX
	LDA.l hex_to_dec_fast_table,X

	SEP #$20
	LSR
	LSR
	LSR
	LSR
	STA.w SA1RAM.dec_out+3

	XBA
	AND.b #$0F
	STA.w SA1RAM.dec_out+4

	REP #$20
	LDA.l $4216 ; remainder for the lower digits
	BRA .get_lower_digits

.under_1k
	LDY.w #3

	CMP.w #100
	BCS .get_lower_digits

	DEY

	CMP.w #10
	BCS .get_lower_digits

	DEY

.get_lower_digits
	ASL
	TAX

	LDA.l hex_to_dec_fast_table,X

	CMP.w #$0010 ; compare 10s
	AND.w #$0F0F ; now get the 100s and 1s

	SEP #$20
	STA.w SA1RAM.dec_out+0

	LDA.l hex_to_dec_fast_table,X
	LSR
	LSR
	LSR
	LSR
	STA.w SA1RAM.dec_out+1

	XBA
	STA.w SA1RAM.dec_out+2

	STY.w SA1RAM.dec_count

	PLX
	RTS

;===================================================================================================

CMDRAW_HEXTODEC_FROM_FUNC:
	PHY

	JSR CMDRAW_HEX8_TO_DEC
	JSR CMDRAW_NUMBER_DEC

	PLY
	RTL

;===================================================================================================

CMDRAW_CTRL_SHORTCUT:
	JSR CMDraw_ReadNextAddress

	REP #$30

	LDA.b [SA1IRAM.cm_writer]
	XBA
	TAY

	STZ.b SA1IRAM.cm_writer

	; remap buttons to a more useful order
	; LRABXYSs^v<>
	SEP #$20
	; dpad
	ASL : ASL : ASL : ASL
	TSB.b SA1IRAM.cm_writer

	; start and select
	TYA : AND.b #$30
	LSR : LSR : LSR : LSR
	TSB.b SA1IRAM.cm_writer+1

	; B
	TYA : AND.b #$80 : LSR : LSR : LSR
	TSB.b SA1IRAM.cm_writer+1

	; Y
	TYA : AND.b #$40 : LSR : LSR : LSR : LSR
	TSB.b SA1IRAM.cm_writer+1

	XBA
	TAY

	; LR
	AND.b #$30 : ASL : ASL
	TSB.b SA1IRAM.cm_writer+1

	; A
	TYA : AND.b #$80 : LSR : LSR
	TSB.b SA1IRAM.cm_writer+1

	; X
	TYA : AND.b #$40 : LSR : LSR : LSR
	TSB.b SA1IRAM.cm_writer+1
	REP #$20

	LDA.w #12
	STA.b SA1IRAM.preset_scratch+2

	LDY.w #$0070

.next_button
	ASL.b SA1IRAM.cm_writer
	BCC .nopress

	TYA
	ORA.b SA1IRAM.cm_draw_color
	STA.w SA1RAM.MENU,X
	INX
	INX

.nopress
	INY
	CPY.w #$007C
	BCC .next_button

	RTS

;===================================================================================================


CMDRAW_NUMFIELD_PRGTEXT:
CMDRAW_CHOICE_PRGTEXT:
CMDRAW_CHOICEPICK_PRGTEXT:
	JSR CMDraw_GetCustomTextAddress
	BRA CMDRAW_PRGTEXT

;---------------------------------------------------------------------------------------------------

CMDRAW_NUMFIELD_FUNC_PRGTEXT:
CMDRAW_CHOICE_FUNC_PRGTEXT:
CMDRAW_CHOICE_FUNC_FILTERED_PRGTEXT:
	JSR CMDraw_GetCustomTextAddress

;---------------------------------------------------------------------------------------------------

CMDRAW_PRGTEXT:
	LDY.w #1

	JSR CMDraw_ReadNextAddress

	LDA.b [SA1IRAM.cm_writer]

	PHK
	PEA.w .return-1

	JML.w [SA1IRAM.prgtext_jump]

.return
	RTS

;===================================================================================================

; All of these just empty the rest of the row
CMDRAW_HEADER:
CMDRAW_LABEL:
CMDRAW_PRESET_UW:
CMDRAW_PRESET_OW:
CMDRAW_SUBMENU:
CMDRAW_SUBMENU_VARIABLE:
CMDRAW_FUNC:
CMDRAW_FUNC_FILTERED:
	RTS

;===================================================================================================

CMDRAW_CHOICE:
CMDRAW_CHOICE_FUNC:
CMDRAW_CHOICEPICK:
CMDRAW_CHOICE_FUNC_FILTERED:
	JSR CMDraw_ReadNextAddress

	LDA.b [SA1IRAM.cm_writer]
	CMP.b [SA1IRAM.cm_current_draw],Y
	BEQ .fine
	BCS .bad

.fine
	PHA
	INY
	JSR CMDraw_ReadNextAddress

	PLA
	ASL
	TAY

	REP #$20
	LDA.b [SA1IRAM.cm_writer],Y

	JMP CMDRAW_WORD_LONG

.bad
	JSL CMDRAW_ERROR
	RTS

;===================================================================================================

CMDRAW_LITESTATE:
	LDA.b [SA1IRAM.cm_current_draw],Y
	REP #$30

	JSL ValidateLiteState
	BCC .invalid

	PHX

	LDX.w SA1IRAM.litestate_off
	LDA.l LiteStateData+$10+LiteSRAMSize,X ; get $1B cache

	PLX
	AND.w #$0001 : BEQ .ow_state

.uw_state
	LDA.w #.uw_text
	JSR CMDRAW_WORD
	PHX

	LDX.w SA1IRAM.litestate_off
	LDA.l LiteStateData+$10+$01+LiteSRAMSize+0,X
	LDY.w #$03
	BRA .draw_id

.ow_state
	LDA.w #.ow_text
	JSR CMDRAW_WORD
	PHX

	LDX.w SA1IRAM.litestate_off
	LDA.l LiteStateData+$10+$01+LiteSRAMSize+4,X
	LDY.w #$02

.draw_id
	PLX

	JSL CMDRAW_HEX
	RTS

.invalid
	LDA.w #.invalid_text
	JMP CMDRAW_WORD

.uw_text
	%cmstr("UW ")

.ow_text
	%cmstr("OW  ")

.invalid_text
	%cmstr("Empty")

;===================================================================================================

CMDRAW_SENTRY_PICKER:
CMDRAW_LINE_SENTRY_PICKER:
	REP #$21
	TXA
	SBC.w #16-1
	TAX

	JSR CMDraw_ReadNextAddress

	REP #$20
	LDA.b (SA1IRAM.cm_writer+0)

	JSR CMDRAW_SENTRY_BY_ID

	RTS

;===================================================================================================

function lorc(y,x) = SA1RAM.LoadoutPopupDraw+(((x+1)+((y+1)*!LOPOPUPLENGTH))*2)
function lop(c) = $2580+c

--	LDX.w #NoBonusRoutine
	STX.w SA1RAM.NMIBonusVector
	PLX
	RTS

CMDRAW_CHOICEPICK_LOADOUT:
	JSR CMDRAW_CHOICEPICK_PRGTEXT

	REP #$30

	PHX

	LDA.b SA1IRAM.cm_draw_color
	CMP.w #!SELECTED
	BNE --

++	LDA.w #$4040
	STA.b SA1IRAM.SCRATCH+1

	LDA.w SA1RAM.loadout_to_save
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	STA.w SA1RAM.LoadoutPopupVRAM
	ASL
	ADC.w SA1RAM.LoadoutPopupVRAM
	ADC.w #SA1RAM.CustomLoadout.slot1
	STA.b SA1IRAM.SCRATCH+0

	TXA
	AND.w #$FFC0
	LSR
	ADC.w #$6C32
	STA.w SA1RAM.LoadoutPopupVRAM

;---------------------------------------------------------------------------------------------------
	; empty popup

	; corners
	LDA.w #$3589
	STA.w SA1RAM.LoadoutPopupDraw+0
	ORA.w #$4000
	STA.w SA1RAM.LoadoutPopupDraw+!LOPOPUPSIZE-2

	LDA.w #$358D
	STA.w SA1RAM.LoadoutPopupDraw+(!LOPOPUPSIZE*6)
	ORA.w #$4000
	STA.w SA1RAM.LoadoutPopupDraw+(!LOPOPUPSIZE*7)-2

	LDA.w #$358A
	LDX.w #(!LOPOPUPSIZE)-4

.next_top_row
	STA.w SA1RAM.LoadoutPopupDraw,X
	DEX
	DEX
	BNE .next_top_row


	LDA.w #$358C
	LDX.w #(!LOPOPUPSIZE)-4

.next_bottom_row
	STA.w SA1RAM.LoadoutPopupDraw+(!LOPOPUPSIZE*6),X
	DEX
	DEX
	BNE .next_bottom_row

	; clear main parts
	LDY.w #5
	LDX.w #!LOPOPUPSIZE

.next_main_row
	PHY

	LDY.w #!LOPOPUPLENGTH-2
	LDA.w #$758B
	STA.w SA1RAM.LoadoutPopupDraw,X
	INX
	INX

	LDA.w #$24BF

.next_main_column
	STA.w SA1RAM.LoadoutPopupDraw,X

	INX
	INX

	DEY
	BNE .next_main_column

	LDA.w #$358B
	STA.w SA1RAM.LoadoutPopupDraw,X
	INX
	INX

	PLY
	DEY
	BNE .next_main_row

;---------------------------------------------------------------------------------------------------

	SEP #$20

	LDX.b SA1IRAM.SCRATCH

	; Bow
	LDA.l $400000+$00,X
	BEQ .no_bow

	LDY.w #$2580
	CMP.b #$03
	BCC .set_bow

	LDY.w #$2585

.set_bow
	STY.w lorc(0,0)

.no_bow
	; shroom/poweder
	LDA.l $400000+$04,X
	BEQ .no_powder

	LDY.w #$2584
	CMP.b #$01
	BNE .draw_powder

	LDY.w #$2595

.draw_powder
	STY.w lorc(0,4)

.no_powder
	; flute
	LDA.l $400000+$0C,X
	BEQ .no_flute

	LDY.w #$25A5
	CMP.b #$01
	BEQ .draw_flute

	LDY.w #$25A2

.draw_flute
	STY.w lorc(2,2)

.no_flute
	; gloves
	LDA.l $400000+$14,X
	BEQ .no_glove

	LDY.w #$25C1
	CMP.b #$01
	BEQ .draw_glove

	LDY.w #$25C4

.draw_glove
	STY.w lorc(4,1)

.no_glove
	LDA.b #$24
	XBA

	; sword
	LDA.l $400000+$19,X
	BEQ .no_sword

	CMP.b #$FF
	BEQ .no_sword

	CMP.b #$02
	ORA.b #$90
	TAY
	STY.w lorc(0,7)

	LDY.w #$2586
	BCC .weak_sword

	INY

.weak_sword
	STY.w lorc(0,6)

.no_sword
	; shield
	LDA.l $400000+$1A,X
	BEQ .no_shield

	LDY.w #$2596
	CMP.b #$02
	BCC .draw_shield
	BEQ .fire_shield

	INY

.fire_shield
	INY

.draw_shield
	STY.w lorc(1,6)

	ORA.b #$90
	TAY
	STY.w lorc(1,7)

.no_shield
	; armor
	LDA.l $400000+$1B,X
	ORA.b #$90
	TAY
	STY.w lorc(2,7)

	LDY.w #$2588
	STY.w lorc(2,6)

	; bottle
	LDY.w #$2490

	LDA.l $400000+$1C,X
	BEQ .no_bottle_1

	INY

.no_bottle_1
	LDA.l $400000+$1D,X
	BEQ .no_bottle_2

	INY

.no_bottle_2
	LDA.l $400000+$1E,X
	BEQ .no_bottle_3

	INY

.no_bottle_3
	LDA.l $400000+$1F,X
	BEQ .no_bottle_4

	INY

.no_bottle_4
	CPY.w #$2490
	BEQ .no_bottle

	STY.w lorc(3,7)

	LDY.w #$25B0
	STY.w lorc(3,6)


.no_bottle
	; hearts

	LDY.w #$25B2
	STY.w lorc(4,5)

	LDA.l $400000+$22,X

	REP #$20

	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.l hex_to_dec_fast_table,X
	LSR
	LSR
	LSR
	LSR
	BEQ .no_hearts_tens

	ORA.w #$2490
	STA.w lorc(4,6)

.no_hearts_tens
	LDA.l hex_to_dec_fast_table,X
	AND.w #$000F

	ORA.w #$2490
	STA.w lorc(4,7)

	LDX.w #$0000
	BRA .start_draw_loop

;---------------------------------------------------------------------------------------------------

.valid_draw
	LDA.b [SA1IRAM.SCRATCH],Y
	AND.w #$00FF
	BEQ .no_item_draw

	LDA.w .draw_data+2,X
	LDY.w .draw_data+4,X
	STA.w $0000,Y

.no_item_draw
	INX
	INX
	INX
	INX

.skipped
	INX
	INX

.start_draw_loop
	LDY.w .draw_data,X
	BPL .valid_draw

;---------------------------------------------------------------------------------------------------

	LDX.w #NMIBonusLoadoutPopup
	STX.w SA1RAM.NMIBonusVector

	PLX

	RTS

.draw_data
; dw offset, char, location
	dw $0001, $2581, lorc(0,1) ; boomerang
	dw $0002, $2582, lorc(0,2) ; hookshot
	dw $0003, $2583, lorc(0,3) ; bombs
	dw $0005, $2590, lorc(1,0) ; fire rod
	dw $0006, $2591, lorc(1,1) ; ice rod
	dw $0007, $2592, lorc(1,2) ; bombos
	dw $0008, $2593, lorc(1,3) ; ether
	dw $0009, $2594, lorc(1,4) ; quake
	dw $000A, $25A0, lorc(2,0) ; lamp
	dw $000B, $25A1, lorc(2,1) ; hammer
	dw $000D, $25A3, lorc(2,3) ; net
	dw $000E, $25A4, lorc(2,4) ; book
	dw $000F, $25B0, lorc(3,0) ; bottle
	dw $0010, $25B1, lorc(3,1) ; somaria
	dw $0011, $25B1, lorc(3,2) ; byrna
	dw $0012, $25B3, lorc(3,3) ; cape
	dw $0013, $25B4, lorc(3,4) ; mirror
	dw $0015, $25C0, lorc(4,0) ; boots
	dw $0016, $25C2, lorc(4,2) ; flippers
	dw $0017, $25C3, lorc(4,3) ; pearl
	dw $0028, $25A7, lorc(4,4) ; half magic
	dw $FFFF

;===================================================================================================
