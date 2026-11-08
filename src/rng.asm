pushpc

org $0688E9 : JSL rng_pokey

org $1ED6EF : JSL rng_agahnim

org $1E8262 : JSL rng_helmasaur

org $1D9488 : JSL rng_ganon_warp_location
org $1D91E3 : JSL rng_ganon_warp

org $1DE5E4 : JSL choose_vitty_eye

org $1EC89C : JSL rng_eyegore

org $1EB5F7 : JSL rng_arrghus

org $1EB2A6 : JSL rng_turtles

org $05A3F4 : JSL rng_lanmola_1
org $05A401 : JSL rng_lanmola_2

org $09BD5D : JSL rng_conveyor_belt

pullpc

;===================================================================================================

rng_pokey:
	LDA.w BWRAM.pokey_rng : BEQ VanillaRNG

	DEC

	; left = 3 ; right = 5
	CPX.b #$05 : BNE .exit

	LSR : LSR

.exit
	RTL

;===================================================================================================

; Agahnim
rng_agahnim:
	LDA.w BWRAM.agahnim_rng : BEQ VanillaRNG

	CMP.b #$01 : BEQ .exit

	LDA.b #$00

.exit
	RTL

;===================================================================================================

rng_helmasaur:
	LDA.w BWRAM.helmasaur_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

rng_ganon_warp_location:
	LDA.w BWRAM.ganon_warpto_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

rng_ganon_warp:
	LDA.w BWRAM.ganon_warp_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

rng_eyegore:
	LDA.w BWRAM.eyegore_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

rng_arrghus:
	LDA.w BWRAM.arrghus_rng : BNE .get_speed

;---------------------------------------------------------------------------------------------------

; In the middle for best access
#VanillaRNG:
	LDA.w SLVH
	LDA.w OPHCT
	ADC.b $1A
	ADC.w $0FA1
	STA.w $0FA1
	RTL

;---------------------------------------------------------------------------------------------------

.get_speed
	TXY
	TAX : LDA.l .speeds-1,X
	TYX

	RTL

.speeds
	db $00, $10, $20, $30, $3F

;===================================================================================================

rng_turtles:
	LDA.w BWRAM.turtles_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

rng_lanmola_1:
	LDA.w BWRAM.lanmola_rng : BEQ VanillaRNG
	DEC
	RTL

rng_lanmola_2:
	LDA.w BWRAM.lanmola_rng : BEQ VanillaRNG
	DEC
	LSR
	LSR
	LSR
	RTL

;===================================================================================================

rng_conveyor_belt:
	LDA.w BWRAM.conveyor_rng : BEQ VanillaRNG
	DEC
	RTL

;===================================================================================================

choose_vitty_eye:
	LDA.w BWRAM.vitreous_rng : BEQ VanillaRNG

	LDA.w $0E70,X : BNE VanillaRNG

	INC : STA.w $0E70,X ; set to 1
	LDA.w BWRAM.vitreous_rng
	DEC

	RTL

;===================================================================================================
