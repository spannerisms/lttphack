;===================================================================================================

!UPDATE_TIMER = $02
!RESET_TIMER = $41

;===================================================================================================

pushpc

; Underworld
org $02B917 : JSL UpdateOnUWTransition
org $01C411 : JSL UpdateOnUWStairs
org $01C5CF : JSL UpdateOnSwitchPress
org $02A0B1 : JSL UpdateOnUWMirror
org $0794EB : JSL UpdateOnUWPitTransition
org $01C4B8 : JSL UpdateOnKillRoom
org $06B949 : JSL UpdateOnPegSwitch
org $07D127 : JSL UpdateOnWarpTile
org $07BC9A : JSL UpdateOnIntraroomStairs
org $01D2C0 : JSL UpdateOnBombableWallUW
org $01D2DE : JSL UpdateOnBombableFloor
org $01CA56 : JSL UpdateOnMovingWallStart : NOP
org $01C927 : JSL UpdateOnMovingWallEndPodMire
org $01C9DB : JSL UpdateOnMovingWallEndDesert
org $01C78C : JSL UpdateOnGanonKill
org $01F6A7 : JSL UpdateOnTriforceDoor

; avoid rewriting vanilla code with a small optimization on the SFX
org $01CF77 : JSL UpdateOnKeyDoor
org $01CF88 : ORA.b #$14

; This causes some double triggers, but always on the same frame
; so it should be fine
org $01C3A7 : JSL UpdateOnInterRoomStairs

org $09969E : STZ.w $0380 ; just change order of operations for the STZ
JSL UpdateOnExplodingWall ; so that this can replace STZ dp LDA dp

; Overworld
org $02A9BA : JSL UpdateOnOWTransition
org $1BBD73 : JSL UpdateOnOWUWTransition
org $05AFC6 : JSL UpdateOnOWMirror
org $07A995 : JSL UpdateOnOWMirror2
org $0794DB : JSL UpdateOnOWPitTransition
org $04E8CF : JSL UpdateOnOWToSpecial
org $04E966 : JSL UpdateOnSpecialToOW
org $1EEED8 : JSL UpdateOnWhirlPool
org $1EEE83 : JSL UpdateOnOWMirror
org $1BC209 : JSL UpdateOnBombableWallOW
org $08E06A : JSL UpdateOnFlute

; Messaging
org $028818 : JSL UpdateOnItemMenu
org $0DDFD3 : JSL UpdateOnItemMenuClose
org $0EF27C : JSL UpdateOnExitingText
org $1CFD7E : JML UpdateOnEnteringMessaging
org $05FC83 : JSL UpdateOnKey ; bonk key
org $06D192 : JSL UpdateOnKey ; normal key
org $078FFB : JSL UpdateOnBonk
org $0799F3 : JSL UpdateOnReceiveItem
org $09F775 : JSL UpdateOnDeath

;===================================================================================================

; Wait for key
org $0EFB90
	LDA.b $F4 ; vanilla pointlessly used absolute; dp is better
	JSL WaitKeyIdleCounter ; now we have an easy 4 bytes here for the JSL

; EndMessage
org $0EFBBB : JSL EndMessageIdleCounter

; MenuActive
org $0DDF1E : JSL MenuIdleCounter

; BottleMenu
org $0DE0E2 : JSL MenuIdleCounter

; Choosing
org $0EF881 : JSL ChoiceIdleCounter : ORA.b #$00
org $0EF8F9 : JSL ChoiceIdleCounter : ORA.b #$00
org $0EF718 : JSL ChoiceBIdleCounter : NOP

; Waiting
org $0EFA61 : JSL HoldAIdleCounter

org $0EF77E : JSL ItemTossCounter : AND.b #$C0

;===================================================================================================

; ledge hops (too many of these!!!!)
org $07895E : JSL UpdateOnLedgeHop : NOP
org $078E34 : JSL UpdateOnLedgeHop : NOP
org $07BBEC : JSL UpdateOnLedgeHop : NOP
org $07BC27 : JSL UpdateOnLedgeHop : NOP
org $07BF30 : JSL UpdateOnLedgeHop : NOP
org $07BFED : JSL UpdateOnLedgeHop : NOP
org $07C07D : JSL UpdateOnLedgeHop : NOP
org $07C6C8 : JSL UpdateOnLedgeHop : NOP
org $07C97F : JSL UpdateOnLedgeHop : NOP
org $07C9DB : JSL UpdateOnLedgeHop : NOP
org $07CA4D : JSL UpdateOnLedgeHop : NOP
org $07CAAA : JSL UpdateOnLedgeHop : NOP

org $07C2F0 : JSL UpdateOnWaterHop
org $07C3ED : JSL UpdateOnWaterHop
org $07CC67 : JSL UpdateOnWaterHop

;===================================================================================================

; sprites
org $1E848C : JSL UpdateOnHelmaMaskBreak

pullpc

;===================================================================================================

UpdateOnLedgeHop:
	; vanilla
	; * = ignore because both routines do it
	; LDA.b #$20       - *
	; JSR Sfx2         - 6    6
	;    JSR GetPan    - 6    12
	;    STA.w $0CF8   - *
	;    JSL CalcSfx   - *
	;    ORA.w $0CF8   - *
	;    RTS           - 6    18
	; STA.w $012E      - *
	; RTS              - 6    24

	; prachack:
	; JSL              - 6    6
	; LDA.b #Update    - 2    8
	; STA.w Flag       - 6    14
	; LDA.b #$20       - *
	; STA.w $0CF8      - *
	; JSL CalcSfx      - *
	; ORA.w $0CF8      - *
	; STA.w $012E      - *
	; RTL              - 6    20
	; NOP              - 2    22

	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG

	; JSL + 8 + 6
	; No JSR - 6 - 6
	LDA.b #$20
	XBA : XBA ; TODO remove these and add a NOP
	STA.w $0CF8

	JSL jlong($8DBB67) ; CalculateLinkSFXPan
	ORA.w $0CF8
	STA.w $012E

	RTL

;===================================================================================================

UpdateOnWaterHop:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$06 : STA.b $5D

	RTL

;===================================================================================================

; Underworld updates
UpdateOnUWTransition:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b $67 : AND.b #$03
	RTL

UpdateOnUWStairs:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	JML jlong($07F243)

UpdateOnSwitchPress:
	STA.b $11
	LDX.b $0C

UpdateOnKeyDoor:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	RTL

UpdateOnUWMirror:
	STA.b $11 : STZ.b $B0
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG 
	RTL

UpdateOnUWPitTransition:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG 
	LDA.l jlong($01C31F),X
	RTL

UpdateOnKillRoom:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$05 : STA.b $11
	RTL

UpdateOnBombableWallOW:
UpdateOnExitingText:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$01 : STA.b $14
	RTL

UpdateOnPegSwitch:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$16 : STA.b $11
	RTL

UpdateOnWarpTile:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG 
	LDA.b #$15 : STA.b $11
	RTL

UpdateOnIntraroomStairs:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$07 : STA.b $10
	RTL

UpdateOnInterRoomStairs:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG 
	JML jlong($02B861)

UpdateOnBombableWallUW:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$09 : STA.b $11
	RTL

UpdateOnBombableFloor:
	SEP #$30
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$1B
	RTL

UpdateOnExplodingWall:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	STZ.b $50
	LDA.b $EE
	RTL

UpdateOnGanonKill:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	STZ.b $B0
	STZ.b $AE
	RTL

UpdateOnTriforceDoor:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	STZ.b $11
	STZ.b $B0
	RTL

;===================================================================================================

UpdateOnMovingWallStart:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$01 : STA.w $02E4
	RTL

; mire/pod slow: 17"04 | fast: 00"17
UpdateOnMovingWallEndPodMire:
	LDA.w CONFIG.fast_moving_walls : BEQ .slowwalls

	LDY.b #$02 : STY.w IRAM.TIMER_ADD_INDEX

.slowwalls
	LDY.b #$02 : STY.w IRAM.TIMER_FLAG
	LDY.b #$00 : STY.b $AE,X
	RTL

; desert slow: 09"18 | fast: 00"10
UpdateOnMovingWallEndDesert:
	LDA.w CONFIG.fast_moving_walls : BEQ .slowwalls

	LDY.b #$04 : STY.w IRAM.TIMER_ADD_INDEX

.slowwalls
	LDY.b #$02 : STY.w IRAM.TIMER_FLAG
	LDY.b #$00 : STY.b $AE,X
	RTL

;===================================================================================================

; Overworld updates
UpdateOnOWUWTransition:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	STZ.b $11 : STZ.b $B0
	RTL

UpdateOnOWTransition:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	INC.b $11 : LDA.b $00
	RTL

UpdateOnOWMirror:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$23 : STA.b $11
	RTL

UpdateOnOWMirror2:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$14 : STA.b $5D
	RTL

UpdateOnOWPitTransition:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	JML jlong($1BB860) ; Overworld_Hole

UpdateOnOWToSpecial:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$17 : STA.b $11
	RTL

UpdateOnSpecialToOW:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$24 : STA.b $11
	RTL

UpdateOnWhirlPool:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$2E : STA.b $11
	RTL

UpdateOnFlute:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$0A : STA.b $11
	RTL

;===================================================================================================

; Messaging updates
UpdateOnEnteringMessaging:
UpdateOnItemMenu:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b #$0E : STA.b $10
	RTL

UpdateOnItemMenuClose:
	STA.b $10
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.b $11
	RTL

UpdateOnDeath:
	LDA.b #!RESET_TIMER : STA.w IRAM.TIMER_FLAG
	LDA.l $7EC227
	RTL

;===================================================================================================

; Other updates
UpdateOnKey:
	STA.l $7EF36F
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	RTL

UpdateOnBonk:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	STA.b $5D ; needs $02
	RTL

UpdateOnReceiveItem:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDY.b #$04
	LDA.b #$22
	RTL

UpdateOnHelmaMaskBreak:
	LDA.b #!UPDATE_TIMER : STA.w IRAM.TIMER_FLAG
	LDY.b #$0F
	LDA.b #$00
	RTL

;===================================================================================================
; Idle frames
;===================================================================================================
WaitKeyIdleCounter:
	; LDA $F4 from entry point
	ORA.b $F6 : AND.b #$C0 : BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.pressed_key
	; AND.b #$C0 executed again after wedge
	RTL

;---------------------------------------------------------------------------------------------------

EndMessageIdleCounter:
	LDA.b $F4 : ORA.b $F6 : BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

	ORA.b #$00 ; TODO change to    SEP #$22 ; set zero flag for exit

.pressed_key
	RTL

;---------------------------------------------------------------------------------------------------

MenuIdleCounter:
	LDA.b $F4 : BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.pressed_key
	AND.b #$10
	RTL

;---------------------------------------------------------------------------------------------------

ChoiceIdleCounter:
	LDA.b $F6
	AND.b #$C0
	ORA.b $F4

	BIT.b #$DC ; must preserve contents
	BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.pressed_key
	; AND.b 
	RTL

;---------------------------------------------------------------------------------------------------

ChoiceBIdleCounter:
	LDA.b $F6
	LDY.b $F4
	AND.b #$C0
	ORA.b $F4

	BIT.b #$CC
	BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.pressed_key
	; AND.b #$C0 executed again after wedge
	RTL

;---------------------------------------------------------------------------------------------------

ItemTossCounter:
	LDA.b $F6
	AND.b #$C0
	ORA.b $F4
	AND.b #$CF
	BNE .pressed_key

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.pressed_key
	LDA.b $F4
	ORA.b $F6
	RTL

;---------------------------------------------------------------------------------------------------

HoldAIdleCounter:
	LDA.b $F2 : BPL .no_a_press

	REP #$20
	INC.w IRAM.ROOM_TIME_IDLE
	SEP #$20

.no_a_press
	AND.b #$80
	RTL

;===================================================================================================
