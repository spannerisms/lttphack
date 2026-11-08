pushpc

;===================================================================================================

org $00F7E1
SA1Reset00:
	JML SA1Reset

SA1NMI00:
	JML SA1NMI

SA1IRQ00:
	JML SA1IRQ

SNES_CUSTOM_NMI_BOUNCE:
	JML SNES_CUSTOM_NMI

SNES_CORRUPTION_IRQ_BOUNCE:
	JML SNES_CORRUPTION_IRQ
guardpc $00F800

org $00FFB7 ; this barely fits
ReadJoyPad_long:
	LSR.w HVBJOY
	BCS ReadJoyPad_long
	JSR.w $0083D1
	RTL

; This is critical to the survival of the SA1
; during somaria glitches, the SA-1 will listen for writes here
; and if the SNES goes too far, it triggers an IRQ

; save irq type 2 (#$82) to sa1 when starting
org $01F7EC
	JMP CorruptionSave

org $01FEAA
CorruptionSave:
	STY.b $0C
	STY.w IRAM.corruption_watcher
	RTS

org $028B07
	JSL UWOverlayWrapper

incsrc "sa1hud.asm", "sa1sram.asm"

pullpc

;===================================================================================================
; CacheSA1Stuff is critical to balancing lag
; so if it isn't called from the HUD, we need to call it here
; otherwise, we're a lot less laggy than vanilla
; this is run every frame
;===================================================================================================

; master cycles
; JSL - 62 : RTL - 44   - 18 more master cycles
; JSR - 46 : RTS - 42

; ClearOAMBuffer vanilla:
; instructions                  CPU              Master
; LDX.b #$60                     2      2           16     16
; LDA.b #$F0                     2      4           16     32
; STA.w abs,X (x32)            160    164   (38)  1216   1248
; TXA                            2    166           14   1262
; SEC                            2    168           14   1274
; SBC.b #$20                     2    170           16   1290
; TXA                            2    172           16   1306
; BPL                            3    175           22   1328
; 4 loops = 5306 master cycles (-6 from last BPL not branching)

; ClearOAMBuffer new:
; instructions                  CPU              Master
; REP #$20                       3      3           22     22
; LDX.b #$F0                     2      5           16     38
; LDA.w #i (x3)                  9     14   (24)   112    150
; TCD      (x3)                  6     32   (14)    42    192
; STX.b dp (x64)               192    224   (24)  4608   4800
; Saves 5306 - 4800 - 18 = 488 master cycles fast

; NMI expansion:
;                  master
; JSL                62      62
; LDA.w abs          32      94
; TRB.w abs          46     140
; TRB.w abs          46     186
; REP                22     208
; LDA.w abs          40     248
; STA.w abs          40     288
; SEP                22     310
; LDA.b dp           24     334
; STA.w ans          40     374
; LDA.b #i           16     390
; STA.w abs          40     430
; RTL                44     474
; 14 master cycles fast

; CacheSA1Stuff:
;                             master
; JSL                           62      62
; REP                           22      84
; LDA.w #i                      24     108
; TCD                           14     122
; LDA.w abs (x4)        (40)   160     282
; LDA.l long                    48     330
; LDX.b dp (x5)         (32)   160     490
; LDA.l long,X (x5)     (48)   240     730
; STA.b dp (x10)        (32)   320    1050
; LDA.w #i                      24    1074
; SEP                           22    1096
; LDA.w abs (x6)        (32)   192    1288
; STA.b dp (x7)                168    1456
; LDA.b #i                      16    1472
; TCD                           14    1486
; RTL                           44    1530
; 1516 master cycles slow

; HUD triggers:
; JML                           32      32
; ignore cacheSA1stuff
; LDA.b dp                      24      56
; BEQ (assume taken)            22      78
; LDA.b #i                      16      94
; STA.w abs                     32     126
; RTS (sometimes)               42     168
; 1684 master cycles slow

; WasteTimeAsNeeded:
; JML                           32      32
; LSR.w abs                     46      78
; BCS (assume taken)            22     100
; ignore STZ
; JML                           32     132
; -22 for BRA that was used            110
; 1590 master cycles slow

; PrepareOAMForTransfer:
; LDY.b #i                      16      16
; ASL (x26)             (14)   364     364
; DEY (x4)              (14)    56     420
; op.w abs,X (x16)      (32)   512     932
; STA.w abs,Y (x4)      (38)   152    1084
; TAX                           14    1098
; TYA                           14    1112
; BPL                           22    1134
; 8 loops = 9072 + 16
; minus 6 for 9082 vanilla master cycles
;
; rewrite:
;                             master
; LDA.b dp                      24      24
; ORA.b dp (x3)         (24)    72      96
; ASL (x6)              (14)    84     180
; STA.b dp                      24     204
; 32 of these for 6528
;
; JSL                           62      62
; PEA.w abs (x2)        (40)    80     142
; PLD (x2)              (36)    72     214
; RTL                           44     258
; JMP abs                       24     282
; 6810 master cycles for rewrite
; rewrite is 2272 master cycles faster

; all together: 474 master cycles fast
;===================================================================================================

WasteTimeAsNeeded:
	LSR.w IRAM.cached_this_frame
	BCS ++

	JSL CacheSA1Stuff
	STZ.w IRAM.cached_this_frame ; ack

++	; waste any time that needs to be wasted here

	; skip entirely if these are on
	LDA.w IRAM.highestline
	BNE .skip

	; timer triggers are 154 master cycles (JSL+LDA+STA.w+RTL) TODO compensate?
	LDA.b #09

	; 14 (DEC) + 22 (BNE) master cycles each
--	DEC
	BNE --
	;   324 master cycles
	; -   6 for last BNE
	; +  16 for LDA
	; +  48 for linecount check
	; = 382

	; ~50 something master cycles faster
	; leaves a bit of wiggle room for regular stuff

.skip
	STZ.b $12

	JML jlong($008034)

;===================================================================================================

CacheSA1Stuff:
	REP #$30 ; 16 bit first

	LDA.w #IRAM
	TCD

	LDA.w $001A : STA.b IRAM.copyof_1A
	LDA.w $0020 : STA.b IRAM.copyof_20
	LDA.w $0022 : STA.b IRAM.copyof_22
	LDA.w $00A0 : STA.b IRAM.copyof_A0
	LDA.l $7EF36C : STA.b IRAM.copyof_7EF36C

	LDX.b IRAM.sentry_address_1 : LDA.l $7E0000,X : STA.b IRAM.sentry_value_1
	LDX.b IRAM.sentry_address_2 : LDA.l $7E0000,X : STA.b IRAM.sentry_value_2
	LDX.b IRAM.sentry_address_3 : LDA.l $7E0000,X : STA.b IRAM.sentry_value_3
	LDX.b IRAM.sentry_address_4 : LDA.l $7E0000,X : STA.b IRAM.sentry_value_4
	LDX.b IRAM.sentry_address_5 : LDA.l $7E0000,X : STA.b IRAM.sentry_value_5

	LDA.w #$0001 ; top byte 0x00

	SEP #$30 ; 8 bit stuff

	STA.b IRAM.cached_this_frame ; flag this with that 01

	LDA.w $00E2 : STA.b IRAM.copyof_E2
	LDA.w $0057 : STA.b IRAM.copyof_57
	LDA.w $005B : STA.b IRAM.copyof_5B
	LDA.w $006C : STA.b IRAM.copyof_6C
	LDA.w $00A4 : STA.b IRAM.copyof_A4
	LDA.w $0372 : STA.b IRAM.copyof_0372

	LDA.b #$00 : TCD

if !RANDO
	REP #$20

	LDA.b $10 : STA.w BWRAM.mfn_cache.gamemode
	LDA.w $0FFF : STA.w BWRAM.mfn_cache.world

	LDX.b #$2E

.next_equip
	LDA.l $7EF340,X : STA.w BWRAM.mfn_cache.equipment,X

	DEX
	DEX
	BPL .next_equip

	SEP #$30
endif

	RTL

;===================================================================================================

InitSA1:
	REP #$20

	LDA.w #$0020
	STA.w CCNT

	LDA.w #SA1Reset00
	STA.w CRV

	LDA.w #SA1NMI00
	STA.w CNV

	LDA.w #SA1IRQ00
	STA.w CIV

	LDA.w #$8180
	STA.w CXB
	STA.w EXB

	SEP #$20
	LDA.b #$80
	STA.w SBWE

	LDA.b #$03
	STA.w BMAPS

	LDA.b #$FF
	STA.w SIC
	STA.w SIWP
	STZ.w BWPA

	REP #$20

	LDA.w #$FFFF
	STA.w IRAM.litestate_last
	STA.w IRAM.litestate_act

	STZ.b $F0
	STZ.b $F2
	STZ.b $F4
	STZ.b $F6

	STZ.w IRAM.copyof_F0
	STZ.w IRAM.copyof_F2
	STZ.w IRAM.copyof_F4
	STZ.w IRAM.copyof_F6

	STZ.w IRAM.cm_submodule
	STZ.w IRAM.preset_addr
	STZ.w IRAM.TIMER_FLAG

	STZ.w IRAM.SEG_TIME_F
	STZ.w IRAM.SEG_TIME_S
	STZ.w IRAM.SEG_TIME_M
	STZ.w IRAM.SEG_TIME_F_DISPLAY
	STZ.w IRAM.SEG_TIME_S_DISPLAY
	STZ.w IRAM.SEG_TIME_M_DISPLAY

	STZ.w IRAM.shortcut_used
	STZ.w CCNT

	SEP #$30
	RTL

;===================================================================================================

SA1Reset:
	SEI
	CLC
	XCE

	REP #$FB

	LDA.w #$0000
	TCD

	LDA.w #$37FF
	TCS

	PHK
	PLB

	LDA.w #SNES_CUSTOM_NMI_BOUNCE ; set up custom NMI vector
	STA.w SNV

	SEP #$30
	STZ.w SCNT ; but don't use it
	STZ.w TMC

	STZ.w DCNT
	STZ.w CDMA

	LDA.b #$80
	STA.w CBWE

	LDA.b #$03
	STA.w BMAP ; image 3 for page $60

	LDA.b #$FF
	STA.w CIWP

	LDA.b #$F0
	STA.w CIC

	LDA.b #$90
	STA.w CIE

	REP #$34
	LDX.w #ClearableSRAMSize-2

.clear_init
	STZ.w BWRAM.clearable_sa1ram,X
	DEX
	DEX
	BPL .clear_init

;===================================================================================================
; SA-1 should spin in IRAM
;===================================================================================================
if !RANDO
	LDX.w #SA1Spin.size+2

.copy_spin
	LDA.l SA1Spin,X
	STA.w IRAM.spin_ram,X

	DEX
	DEX
	BPL .copy_spin

	JML IRAM.spin_ram
endif

;===================================================================================================

SA1Spin:
	CLC

.reset_rng
	LDA.w #$BEBE
	BCC .start

.loop
	STA.b IRAM.randomish

.start
	ROL.b IRAM.randomish
	ROR
	ADC.b IRAM.randomish
	BNE .loop

	SEC
	BRA .reset_rng

^.size

;===================================================================================================

; IRAM.TIMER_FLAG bitfield:
; 7 - timers have been set and are awaiting a hud update
; 6 - reset timer
; 5
; 4
; 3
; 2 - Update without blocking further updates
; 1 - One update then no more
; 0 - 
SA1NMI:
	REP #$30
	PHA
	PHX
	PHY
	PHD
	PHB

	LDA.w #$0000
	TCD

	SEP #$30

	LDA.b #$10
	STA.l CIC

	PHK
	PLB

	LDA.w CFR
	AND.b #$03
	ASL
	TAX

	JSR.w (.nmis,X)

.exit
	REP #$30
	PLB
	PLD
	PLY
	PLX
	PLA
	RTI

.nmis
	dw .disable_custom_nmi
	dw .enable_custom_nmi
	dw SA1NMI_SENTRIES
	dw .nothing_at_all

.disable_custom_nmi
	STZ.w SCNT

.nothing_at_all
	RTS

.enable_custom_nmi
	LDA.b #$10
	STA.w SCNT
	RTS

;---------------------------------------------------------------------------------------------------

GetMod60:
	STZ.b IRAM.TIMER_ADD_SCRATCH

	CMP.w #$0060
	BCC .fine

.adjust
	INC.b IRAM.TIMER_ADD_SCRATCH

	SBC.w #$0060
	CMP.w #$0060 ; TODO is this necessary? seems not
	BCS .adjust

.fine
	RTS

;---------------------------------------------------------------------------------------------------

TimerAddAdjustments:
	dw $0000 ; nothing
	dw $1647 ; Pod/Mire wall
	dw $0908 ; Desert wall

;===================================================================================================

SA1NMI_SENTRIES:
	SEP #$38

	; if $12 = 1, then we weren't done with game code
	; that means we're in a lag frame
	LDA.b IRAM.copyof_12
	CMP.b #$01

	REP #$20

	LDA.b IRAM.ROOM_TIME_LAG : ADC.w #$0000
	STA.b IRAM.ROOM_TIME_LAG

	; ROOM TIMER
	LDX.b IRAM.TIMER_ADD_INDEX

	LDA.w TimerAddAdjustments,X
	STA.b IRAM.TIMER_ADD_SSFF

	AND.w #$00FF
	STA.b IRAM.TIMER_ADD_SCRATCH

	LDA.b IRAM.ROOM_TIME_F
	AND.w #$00FF
	SEC
	ADC.b IRAM.TIMER_ADD_SCRATCH
	JSR GetMod60
	STA.b IRAM.ROOM_TIME_F

	LDA.b IRAM.TIMER_ADD_SSFF+1
	AND.w #$00FF
	ADC.b IRAM.TIMER_ADD_SCRATCH
	ADC.b IRAM.ROOM_TIME_S
	STA.b IRAM.ROOM_TIME_S

	; SEGMENT TIMER
	LDA.b IRAM.TIMER_ADD_SSFF
	AND.w #$00FF
	STA.b IRAM.TIMER_ADD_SCRATCH

	LDA.b IRAM.SEG_TIME_F
	AND.w #$00FF
	SEC
	ADC.b IRAM.TIMER_ADD_SCRATCH
	JSR GetMod60
	STA.b IRAM.SEG_TIME_F

	LDA.b IRAM.TIMER_ADD_SSFF+1
	AND.w #$00FF
	ADC.b IRAM.TIMER_ADD_SCRATCH
	ADC.b IRAM.SEG_TIME_S
	JSR GetMod60
	STA.b IRAM.SEG_TIME_S

	LDA.b IRAM.TIMER_ADD_SCRATCH
	ADC.b IRAM.SEG_TIME_M
	STA.b IRAM.SEG_TIME_M

	STZ.b IRAM.TIMER_ADD_SSFF
	STZ.b IRAM.TIMER_ADD_INDEX

	; FLUSH
	REP #$18
	SEP #$20

	LDA.b IRAM.TIMER_FLAG 
	BMI .donothing
	BEQ .donothing

	BIT.b IRAM.TIMER_FLAG

	LDX.b IRAM.ROOM_TIME_F    : STX.b IRAM.ROOM_TIME_F_DISPLAY
	LDX.b IRAM.ROOM_TIME_S    : STX.b IRAM.ROOM_TIME_S_DISPLAY
	LDX.b IRAM.ROOM_TIME_LAG  : STX.b IRAM.ROOM_TIME_LAG_DISPLAY
	LDX.b IRAM.ROOM_TIME_IDLE : STX.b IRAM.ROOM_TIME_IDLE_DISPLAY

	LDX.b IRAM.SEG_TIME_F     : STX.b IRAM.SEG_TIME_F_DISPLAY
	LDX.b IRAM.SEG_TIME_S     : STX.b IRAM.SEG_TIME_S_DISPLAY
	LDX.b IRAM.SEG_TIME_M     : STX.b IRAM.SEG_TIME_M_DISPLAY

	BVC .dontreset

	LDX.w #$0000
	STX.b IRAM.ROOM_TIME_F+0
	STX.b IRAM.ROOM_TIME_F+2
	STX.b IRAM.ROOM_TIME_F+4
	STX.b IRAM.ROOM_TIME_F+6

.dontreset
	LDA.b #$80
	STA.b IRAM.TIMER_FLAG

.donothing
	REP #$20

	LDA.b IRAM.copyof_20 : STA.w BWRAM.mfn_cache.coords+0
	LDA.b IRAM.copyof_22 : STA.w BWRAM.mfn_cache.coords+2

	RTS

;---------------------------------------------------------------------------------------------------

; For everything not a timer
SA1IRQ:
	SEI

	REP #$30
	PHA
	PHX
	PHY
	PHD
	PHB

	LDA.w #IRAM : TCD

	SEP #$30

	LDA.b #$80
	STA.l CIC

	LDA.l CFR ; get IRQ type
	AND.b #$03
	ASL
	TAX

	JMP (.irq_type,X)

; TODO use NMI's exit
.exit
	REP #$30
	PLB
	PLD
	PLY
	PLX
	PLA
	RTI

.irq_type
	dw .exit
	dw .irq_shortcuts
	dw CorruptionWatcher
	dw .irq_hud

	dw .exit
	dw .exit
	dw .exit
	dw .exit

.irq_hud
	JML DrawHudExtras

.irq_shortcuts
	JML DoShortCuts

;===================================================================================================

; watch for this to be a bad value
; if it's FFFF, then NMI occured and things are fine
CorruptionWatcher:
	PHK
	PLB

	SEP #$20
	LDA.b #$40 : STA.w SCNT ; irq vector

	REP #$30

	STZ.b IRAM.corruption_watcher

	LDA.w #SNES_CORRUPTION_IRQ_BOUNCE
	STA.w SIV ; snes IRQ vector

.watch
	LDA.b IRAM.corruption_watcher
	CMP.w #$FFFF
	BEQ .done

	CMP.w #$1080
	BCC .watch

	SEP #$20
	LDA.b #$C0 : STA.w SCNT ; trigger irq

	REP #$20
	LDA.w #$FFFF

.wait
	CMP.b IRAM.corruption_watcher
	BNE .wait

.done
	SEP #$20

	LDA.b #$00 : STA.w SCNT ; disable IRQ from snes

	JMP SA1IRQ.exit

;===================================================================================================

SNES_CORRUPTION_IRQ:
	SEP #$30 ; we don't need to preserve A, so it's fine
	LDA.b #$80 : STA.l SIC ; acknowledge IRQ

	JSL RecoverFromCorruption

	PLP ; recover processor from the interrupt

	PLA ; remove address of interrupted location
	PHP ; push this so next pull is bigger
	PLA ; remove bank of interrupted location
	PLA ; remove routine that makes holes

	JML jlong($01B897) ; return to exit of the loop

;===================================================================================================

UWOverlayWrapper:
	SEP #$20

	LDA.b #$80 : STA.w SIE ; enable IRQ from here
	LDA.b #$82 : STA.w CCNT

	JSL jlong($01B83E) ; Underworld_ApplyRoomOverlay

;---------------------------------------------------------------------------------------------------

DisableCorruptionWatcher:
	SEP #$20

	STZ.w SIE

	REP #$30

	LDA.w #$FFFF : STA.w IRAM.corruption_watcher

	SEP #$30

	LDA.w CONFIG.somaria_pits : BEQ .exit

	STZ.b $12

	; wait for NMI once for the main vram transfers
.spin
	LDA.b $12
	BEQ .spin

	JSL Shortcut_ShowPits

	SEP #$30

.exit
	RTL

;===================================================================================================

RecoverFromCorruption:
	REP #$30

	LDX.w IRAM.corruption_watcher
	LDY.b $BA

.next
	LDA.b [$B7],Y
	CMP.w #$FFFF
	BEQ .end

	STA.b $00

	SEP #$20

	AND.b #$FC
	STA.b $08

	INY
	INY

	XBA
	LSR
	LSR
	LSR
	ROR.b $08
	STA.b $09

	INY
	STY.b $BA

	REP #$20

	PHX

	LDA.w #$0004
	STA.b $0A

.next_super
	LDX.b $08

	JSR .check_one_pit
	JSR .check_one_pit
	JSR .check_one_pit
	JSR .check_one_pit

	LDA.b $08
	ADC.w #$0080
	STA.b $08

	DEC.b $0A
	BNE .next_super

	PLA
	ADC.w #$0030
	CMP.w #NMITIMEN-$1100
	BCS .really_bad

	TAX
	BRA .next

.end
	RTL

;---------------------------------------------------------------------------------------------------

.really_bad
	JML CorruptionCrash

;---------------------------------------------------------------------------------------------------

.check_one_pit
	PHX

	TXA
	LSR
	PHA

	LDA.l $7E2000,X
	AND.w #$03FE

	PLX

	; high byte will already be 00 for floors
	CMP.w #$00EE
	BEQ .floor

	CMP.w #$00FE
	BEQ .floor

	LDA.w #$2000 ; put value in high byte, so it's XBA'd
	             ; which makes the whole thing easier

.floor
	SEP #$20
	XBA
	STA.l $7F2000,X

	REP #$21

	PLX
	INX
	INX

	RTS

;===================================================================================================
