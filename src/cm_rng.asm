RNG_SUBMENU:
%menu_header("RNG CONTROL")

;===================================================================================================

%choice_here("Prize packs", SA1RAM.drop_rng, 3)
	%add_list_item(CMTEXT_VANILLA)
	%list_item("Always")
	%list_item("Never")

;===================================================================================================

%choice_prgtext("Frame rule", SA1RAM.framerule, $41, this)
	BEQ .unfixed

	DEC
	JML CMDRAW_HEX_2_DIGITS

.unfixed
	REP #$20

	LDA.w #CMTEXT_UNFIXED
	JMP CMDRAW_WORD_FUNCEND

;===================================================================================================

%choice_prgtext("Pokeys", SA1RAM.pokey_rng, 17, this)
	BEQ .random
	DEC

	REP #$21
	PHA

	AND.w #$0003 ; get for first pokey
	ASL ; multiply by 4 since that's the length of the string
	ASL

	ADC.w #.directions
	JSR CMDRAW_WORD

	PLA ; recover value
	AND.w #$000C ; the top 2 bits for second pokey - already shifted for us too!
	ADC.w #.directions ; carry should be clear always, I hope

	JMP CMDRAW_WORD_FUNCEND

.directions
	%cmstr("dr ")
	%cmstr("dl ")
	%cmstr("ur ")
	%cmstr("ul ")

.random
	JML CMDRAW_RANDOM

;===================================================================================================

%choice_here("Agahnim shots", SA1RAM.agahnim_rng, 3)
	%add_list_item(CMTEXT_RANDOM)
	%add_list_item(CMTEXT_YELLOW)
	%add_list_item(CMTEXT_BLUE)

;===================================================================================================

%choice_here("Helmasaur", SA1RAM.helmasaur_rng, 3)
	%add_list_item(CMTEXT_RANDOM)
	%list_item("No fireball")
	%list_item("Fireball")

;===================================================================================================

%choice_prgtext("First Vitty", SA1RAM.vitreous_rng, 10, this)
	BEQ .random

	CLC
	AND.b #$0F
	ADC.b #4 ; slot 5 is a value of 1
	PHA

	REP #$20
	LDA.w #.slot ; draw the word slot
	JSR CMDRAW_WORD

	SEP #$20
	PLA
	JML CMDRAW_DIGIT

.random
	JML CMDRAW_RANDOM

.slot
	%cmstr("Slot ")

;===================================================================================================

%choice_here("Ganon warps", SA1RAM.ganon_warp_rng, 3)
	%add_list_item(CMTEXT_RANDOM)
	%list_item("No warp")
	%list_item("Warp")

;===================================================================================================

%choice_here("Ganon warp to", SA1RAM.ganon_warp_location_rng, 5)
	%add_list_item(CMTEXT_RANDOM)
	%list_item("Far left")
	%list_item("Bottom left")
	%list_item("Bottom right")
	%list_item("Far right")

;===================================================================================================

%choice_here("Eyegore walk", SA1RAM.eyegore_rng, 4)
	%add_list_item(CMTEXT_RANDOM)
	%add_list_item(CMTEXT_SHORT)
	%add_list_item(CMTEXT_MEDIUM)
	%add_list_item(CMTEXT_LONG)


;===================================================================================================

%choice_here("Arrghus walk", SA1RAM.arrghus_rng, 6)
	%add_list_item(CMTEXT_RANDOM)
	%list_item("Shortest") : %ReusableText(CMTEXT_SHORTEST)
	%list_item("Short")    : %ReusableText(CMTEXT_SHORT)
	%list_item("Medium")   : %ReusableText(CMTEXT_MEDIUM)
	%list_item("Long")     : %ReusableText(CMTEXT_LONG)
	%list_item("Longest")

;===================================================================================================

%choice_prgtext("Turtle walk", SA1RAM.turtles_rng, 33, this)
	BEQ .random

	DEC ; special text for shortest
	BEQ .shortest

	CMP.b #$1F ; more special text
	BEQ .slowest

	JML CMDRAW_HEX_2_DIGITS

.slowest_text
	%cmstr("Slowest")

.slowest
	REP #$20
	LDA.w #.slowest_text
	JMP CMDRAW_WORD_FUNCEND

.shortest
	REP #$20
	LDA.w #CMTEXT_SHORTEST
	JMP CMDRAW_WORD_FUNCEND


.random
	JML CMDRAW_RANDOM

;===================================================================================================

%choice_prgtext("Lanmola exit", SA1RAM.lanmola_rng, 65, this)
	BNE .notrandom

	JML CMDRAW_RANDOM

.notrandom
	DEC

	SEP #$20
	PHA

	AND.b #$38 ; middle 3 bits for first character
	LSR
	LSR
	LSR
	JSL CMDRAW_DIGIT

	LDA.b #','
	JSL CMDRAW_CHAR

	PLA
	AND.b #$07
	JML CMDRAW_DIGIT

.random
	JML CMDRAW_RANDOM

;===================================================================================================

%choice_here("Moth conveyor", SA1RAM.conveyor_rng, 5)
	%add_list_item(CMTEXT_RANDOM)
	%list_item("Right")
	%list_item("Left")
	%list_item("Down")
	%list_item("Up")

;===================================================================================================
