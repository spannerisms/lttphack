pushpc
org $008000
struct SA1IRAM $003000
	.SHORTCUT_USED: skip 2
	.corruption_watcher: skip 2

	.SCRATCH: skip 16

	.CONTROLLER_1:
	.CopyOf_F2: skip 1
	.CopyOf_F0: skip 1

	.CONTROLLER_1_FILTERED:
	.CopyOf_F6: skip 1
	.CopyOf_F4: skip 1

	.CONTROLLER_1_NEW:

	.JOYPAD2_NEW: skip 2

	.HUDSIZE: skip 2
	.number_of_line_sentries: skip 2
	.number_of_timer_triggers: skip 2

	.CachedThisFrame: skip 1
	.cm_submodule: skip 2
	.cm_cursor: skip 1 ; keep these together
	.cm_current_menu: skip 4
	.cm_current_selection: skip 4
	.cm_current_draw: skip 4
	.cm_draw_color: skip 2

	; these can be shared because they're never used at the same time
	.cm_writer:
	.cm_draw_type_offset: skip 2
	.cm_draw_filler: skip 2

	.cm_leftright: skip 1 ; N=left V=right
	.cm_updown: skip 1 ; N=up V=down
	.cm_ax: skip 1 ; N=A V=X
	.cm_y: skip 1 ; 
	.cm_shoulder: skip 1 ; N=l V=r
	skip 1 ; for safety

	.cm_writer_args: skip 4

	.preset_addr: skip 3

	.preset_prog: skip 3
	.preset_prog_end: skip 2

	.preset_pert: skip 3
	.preset_pert_end: skip 2

	.preset_reader: skip 3
	.preset_reader2: skip 3
	.preset_writer: skip 2
	.preset_type: skip 2
	.preset_scratch: skip 4

	.litestate_act: skip 2
	.litestate_last: skip 2
	.litestate_off: skip 2

	reset bytes

.savethis_start
	.TIMER_FLAG: skip 2
	.TIMER_ADD_SSFF: skip 2
	.TIMER_ADD_SCRATCH: skip 2

.timers_start
	.ROOM_TIME_F: skip 2
	.ROOM_TIME_S: skip 2
	.ROOM_TIME_LAG: skip 2
	.ROOM_TIME_IDLE: skip 2

	.SEG_TIME_F: skip 2
	.SEG_TIME_S: skip 2
	.SEG_TIME_M: skip 2

.timers_end
	.ROOM_TIME_F_DISPLAY: skip 2
	.ROOM_TIME_S_DISPLAY: skip 2
	.ROOM_TIME_LAG_DISPLAY: skip 2
	.ROOM_TIME_IDLE_DISPLAY: skip 2

	.SEG_TIME_F_DISPLAY: skip 2
	.SEG_TIME_S_DISPLAY: skip 2
	.SEG_TIME_M_DISPLAY: skip 2

	.SNTVAL1: skip 2
	.SNTVAL2: skip 2
	.SNTVAL3: skip 2
	.SNTVAL4: skip 2
	.SNTVAL5: skip 2

	.SNTADD1: skip 2
	.SNTADD2: skip 2
	.SNTADD3: skip 2
	.SNTADD4: skip 2
	.SNTADD5: skip 2

	.CopyOf_12: skip 1
	.CopyOf_1A: skip 1
	.CopyOf_1B: skip 1
	.CopyOf_20: skip 1
	.CopyOf_21: skip 1
	.CopyOf_22: skip 1
	.CopyOf_23: skip 1

	.CopyOf_57: skip 1
	.CopyOf_5B: skip 1
	.CopyOf_6C: skip 1
	.CopyOf_0372: skip 1

	.CopyOf_A0: skip 1
	.CopyOf_A1: skip 1
	.CopyOf_A4: skip 1
	.CopyOf_E2: skip 1

	.CopyOf_7EF36C: skip 1
	.CopyOf_7EF36D: skip 1
	.CopyOf_7EF3CA: skip 1

	; not copied, but just moved in rom
	.Moved_0208: skip 1
	.Moved_0209: skip 1
	.Moved_020A: skip 1

	.Moved_04A0: skip 2
	.Moved_04B4: skip 1

	; extra stuff
	.BossCycles: skip 16 ; 16 to be safe

	print ""
	print "SA1 dp: $", pc
	print "Saved: ", bytes, "/640 (acceptable savestate limit)"

	.QuickSwapLR: skip 1

.savethis_end

	; ancilla watch
	.LINEVAL:
	.LINE1VAL: skip 16
	.LINE2VAL: skip 16
	.LINE3VAL: skip 16
	.LINE4VAL: skip 16

	print "SA1 mirroring: $", pc

org $003680
	.SA1CorruptionBuffer: skip $180

	warnpc $003800

endstruct

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
warnpc $00F800

org $00FFB7 ; this barely fits
ReadJoyPad_long:
--	LSR.w $4212
	BCS --
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
	STY.w SA1IRAM.corruption_watcher
	RTS

org $028B07
	JSL UWOverlayWrapper

incsrc sa1hud.asm
incsrc sa1sram.asm

pullpc

;===================================================================================================

SNES_CORRUPTION_IRQ:
	SEP #$30 ; we don't need to preserve A, so it's fine
	LDA.b #$80 : STA.l $2202 ; acknowledge IRQ

	JSL RecoverFromCorruption

	PLP ; recover processor from the interrupt

	PLA ; remove address of interrupted location
	PHP ; push this so next pull is bigger
	PLA ; remove bank of interrupted location
	PLA ; remove routine that makes holes

	JML $01B897 ; return to exit of the loop

;===================================================================================================

UWOverlayWrapper:
	SEP #$20

	LDA.b #$80 : STA.w $2201 ; enable IRQ from here
	LDA.b #$82 : STA.w $2200

	JSL $01B83E ; Underworld_ApplyRoomOverlay

DisableCorruptionWatcher:
	SEP #$20

	STZ.w $2201

	REP #$30

	LDA.w #$FFFF : STA.w SA1IRAM.corruption_watcher

	SEP #$30

	LDA.w !config_somaria_pits : BEQ ++

	STZ.b $12

	; wait for NMI once for the main vram transfers
--	LDA.b $12 : BEQ --

	JSL Shortcut_ShowPits

	SEP #$30

++	RTL

;===================================================================================================

RecoverFromCorruption:
	REP #$30

	LDX.w SA1IRAM.corruption_watcher
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
	CMP.w #$4200-$1100
	BCS .really_bad

	TAX
	BRA .next

.end
	RTL

.really_bad
	JML CorruptionCrash

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

; watch for this to be a bad value
; if it's FFFF, then NMI occured and things are fine
CorruptionWatcher:
	SEP #$20
	LDA.b #$40 : STA.w $2209 ; irq vector

	REP #$30
	STZ.b SA1IRAM.corruption_watcher

	LDA.w #SNES_CORRUPTION_IRQ_BOUNCE
	STA.w $220E ; snes IRQ vector

.watch
	LDA.b SA1IRAM.corruption_watcher
	CMP.w #$FFFF
	BEQ .done

	CMP.w #$1080
	BCC .watch

	SEP #$20
	LDA.b #$C0 : STA.w $2209 ; trigger irq

	REP #$20
	LDA.w #$FFFF

--	CMP.b SA1IRAM.corruption_watcher
	BNE --

.done
	SEP #$20
	LDA.b #$00 : STA.w $2209 ; disable IRQ from snes
	RTS

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
; LDA.l long                    40    1328
; STA.b dp (x8)                192    1520
; LDA.b #i                      16    1536
; TCD                           14    1550
; RTL                           44    1594
; 1580 master cycles slow

; HUD triggers:
; JSR                           46      46
; ignore cacheSA1stuff
; LDA.b dp                      24      70
; BEQ (assume taken)            22      92
; LDA.b #i                      16     108
; STA.w abs                     32     140
; ignore INC.b $16
; RTS (sometimes)               42     182
; 1762 master cycles slow

; WasteTimeAsNeeded:
; JML                           32      32
; LSR.w abs                     46      78
; BCS (assume taken)            22     100
; ignore STZ
; JML                           32     132
; -22 for BRA that was used            110
; 1872 master cycles slow

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

; all together: 400 master cycles fast
;===================================================================================================
WasteTimeAsNeeded:
	LSR.w SA1IRAM.CachedThisFrame
	BCS ++

	JSL CacheSA1Stuff
	STZ.w SA1IRAM.CachedThisFrame ; ack

++	; waste any time that needs to be wasted here

	; skip entirely if these are on
	LDA.w SA1IRAM.number_of_line_sentries
	BNE .skip

	; timer triggers are 154 master cycles (JSL+LDA+STA.w+RTL) TODO compensate?


	LDA.b #08

	; 14 (DEC) + 22 (BNE) master cycles each
--	DEC
	BNE --
	;   288 master cycles
	; -   6 for last BNE
	; +  16 for LDA
	; +  48 for linecount check
	; = 346

	; 54 master cycles faster
	; leaves a bit of wiggle room for regular stuff

.skip
	STZ.b $12

	JML $008034

;===================================================================================================

CacheSA1Stuff:
	REP #$30 ; 16 bit first

	LDA.w #$3000
	TCD

	LDA.w $001A : STA.b SA1IRAM.CopyOf_1A
	LDA.w $0020 : STA.b SA1IRAM.CopyOf_20
	LDA.w $0022 : STA.b SA1IRAM.CopyOf_22
	LDA.w $00A0 : STA.b SA1IRAM.CopyOf_A0
	LDA.l $7EF36C : STA.b SA1IRAM.CopyOf_7EF36C

	LDX.b SA1IRAM.SNTADD1 : LDA.l $7E0000,X : STA.b SA1IRAM.SNTVAL1
	LDX.b SA1IRAM.SNTADD2 : LDA.l $7E0000,X : STA.b SA1IRAM.SNTVAL2
	LDX.b SA1IRAM.SNTADD3 : LDA.l $7E0000,X : STA.b SA1IRAM.SNTVAL3
	LDX.b SA1IRAM.SNTADD4 : LDA.l $7E0000,X : STA.b SA1IRAM.SNTVAL4
	LDX.b SA1IRAM.SNTADD5 : LDA.l $7E0000,X : STA.b SA1IRAM.SNTVAL5

	LDA.w #$0001 ; top byte 0x00

	; 8 bit stuff
	SEP #$30

	STA.b SA1IRAM.CachedThisFrame ; flag this with that 01

	LDA.w $00E2 : STA.b SA1IRAM.CopyOf_E2
	LDA.w $0057 : STA.b SA1IRAM.CopyOf_57
	LDA.w $005B : STA.b SA1IRAM.CopyOf_5B
	LDA.w $006C : STA.b SA1IRAM.CopyOf_6C
	LDA.w $00A4 : STA.b SA1IRAM.CopyOf_A4
	LDA.w $0372 : STA.b SA1IRAM.CopyOf_0372
	LDA.l $7EF3CA : STA.b SA1IRAM.CopyOf_7EF3CA

	LDA.b #$00 : TCD

	RTL

;===================================================================================================

Extra_SA1_Transfers:
	SEP #$30

	LDY.b #$06

.next
	LDA.w !config_linesentry1,Y
	BEQ .skip

	ASL
	TAX

	PHY

	TYA
	ASL
	ASL
	ASL
	TAY

	JSR (.subs,X)

	SEP #$30
	PLY

.skip
	DEY
	DEY
	BPL .next

	RTL

.subs
	dw .nothing
	dw .roomflag
	dw .camerax
	dw .cameray
	dw .owtran
	dw .owtran
	dw .ancilla04
	dw .ancilla59
	dw .ancillaIX

.owtran

.nothing
	RTS

;---------------------------------------------------------------------------------------------------

.roomflag
	LDA.w $0401 : STA.w SA1IRAM.LINEVAL+0,Y
	LDA.w $0403 : STA.w SA1IRAM.LINEVAL+1,Y
	LDA.w $0408 : STA.w SA1IRAM.LINEVAL+2,Y

	RTS

;---------------------------------------------------------------------------------------------------

.camerax
	LDA.b $A6 : STA.w SA1IRAM.LINEVAL+0,Y

	REP #$20
	
	LDA.b $E2 : STA.w SA1IRAM.LINEVAL+1,Y

	LDA.w $0608 : STA.w SA1IRAM.LINEVAL+3,Y
	LDA.w $060C : STA.w SA1IRAM.LINEVAL+5,Y
	LDA.w $060A : STA.w SA1IRAM.LINEVAL+7,Y
	LDA.w $060E : STA.w SA1IRAM.LINEVAL+9,Y

	RTS

;---------------------------------------------------------------------------------------------------

.cameray
	LDA.b $A7 : STA.w SA1IRAM.LINEVAL+0,Y

	REP #$20

	LDA.b $E8 : STA.w SA1IRAM.LINEVAL+1,Y

	LDA.w $0600 : STA.w SA1IRAM.LINEVAL+3,Y
	LDA.w $0604 : STA.w SA1IRAM.LINEVAL+5,Y
	LDA.w $0602 : STA.w SA1IRAM.LINEVAL+7,Y
	LDA.w $0606 : STA.w SA1IRAM.LINEVAL+9,Y

	RTS

;---------------------------------------------------------------------------------------------------

.ancilla04
	REP #$30
	BRA .use04

.ancilla59
	REP #$30
	LDA.w #$0005
	BRA .saveancilla

.ancillaIX
	LDA.w $03C4

	REP #$31

	AND.w #$00FF
	DEC

	CMP.w #$0080 ; if negative, show slots 0-4
	BCS .use04

	CMP.w #5
	BCS .saveancilla

.use04
	LDA.w #$0000

.saveancilla
	STA.w SA1IRAM.LINEVAL+10,Y

	TYA
	LSR ; /8 for props
	LSR
	LSR
	TAX
	LDA.w !config_ancprop1,X

	ASL
	TAX
	STA.w SA1IRAM.LINEVAL+8,Y

	LDA.l ancillawatch_props,X
	STA.w SA1IRAM.LINEVAL+12,Y
	CLC
	ADC.w SA1IRAM.LINEVAL+10,Y
	STA.w SA1IRAM.LINEVAL+14,Y
	TAX

	LDA.b $00,X : STA.w SA1IRAM.LINEVAL+0,Y
	LDA.b $02,X : STA.w SA1IRAM.LINEVAL+2,Y
	LDA.b $04,X : STA.w SA1IRAM.LINEVAL+4,Y

	RTS

;===================================================================================================

InitSA1:
	REP #$20

	LDA.w #$0020
	STA.w $2200

	LDA.w #SA1Reset00
	STA.w $2203

	LDA.w #SA1NMI00
	STA.w $2205

	LDA.w #SA1IRQ00
	STA.w $2207

	LDA.w #$8180
	STA.w $2220
	STA.w $2222

	SEP #$20
	LDA.b #$80
	STA.w $2226

	LDA.b #$03
	STA.w $2224

	LDA.b #$FF
	STA.w $2202
	STA.w $2229
	STZ.w $2228

	REP #$20

	LDA.w #$FFFF
	STA.w SA1IRAM.litestate_last
	STA.w SA1IRAM.litestate_act

	STZ.b $F0
	STZ.b $F2
	STZ.b $F4
	STZ.b $F6

	STZ.w SA1IRAM.CopyOf_F0
	STZ.w SA1IRAM.CopyOf_F2
	STZ.w SA1IRAM.CopyOf_F4
	STZ.w SA1IRAM.CopyOf_F6

	STZ.w SA1IRAM.cm_submodule
	STZ.w SA1IRAM.preset_addr
	STZ.w SA1IRAM.TIMER_FLAG

	STZ.w SA1IRAM.SEG_TIME_F
	STZ.w SA1IRAM.SEG_TIME_S
	STZ.w SA1IRAM.SEG_TIME_M
	STZ.w SA1IRAM.SEG_TIME_F_DISPLAY
	STZ.w SA1IRAM.SEG_TIME_S_DISPLAY
	STZ.w SA1IRAM.SEG_TIME_M_DISPLAY

	STZ.w SA1IRAM.SHORTCUT_USED
	STZ.w $2200

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
	STA.w $220C

	SEP #$30
	STZ.w $2209 ; but don't use it
	STZ.w $2210

	STZ.w $2230
	STZ.w $2231

	LDA.b #$80
	STA.w $2227

	LDA.b #$03
	STA.w $2225 ; image 3 for page $60

	LDA.b #$FF
	STA.w $222A

	LDA.b #$F0
	STA.w $220B

	LDA.b #$90
	STA.w $220A

	REP #$34
	LDX.w #(SA1RAM.end_of_clearable_sa1ram-SA1RAM.clearable_sa1ram)-2

--	STZ.w SA1RAM.clearable_sa1ram,X
	DEX
	DEX
	BPL --

--	BRA --

; SA1IRAM.TIMER_FLAG bitfield:
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

	SEP #$30
	LDA.b #$10
	STA.l $00220B

	PHK
	PLB

	LDA.w $2301
	AND.b #$03
	ASL
	TAX

	JSR.w (.nmis,X)

#SA1NMI_EXIT:
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
	STZ.w $2209

.nothing_at_all
	RTS

.enable_custom_nmi
	LDA.b #$10
	STA.w $2209
	RTS

;---------------------------------------------------------------------------------------------------

GetMod60:
	STZ.b SA1IRAM.TIMER_ADD_SCRATCH

	CMP.w #$0060
	BCC .fine

.adjust
	INC.b SA1IRAM.TIMER_ADD_SCRATCH

	SBC.w #$0060

	CMP.w #$0060
	BCS .adjust

.fine
	RTS

;---------------------------------------------------------------------------------------------------


; TODO 435 arrow hit in pod wall good, but 436 bad
SA1NMI_SENTRIES:
	SED

	; if $12 = 1, then we weren't done with game code
	; that means we're in a lag frame
	LDA.b SA1IRAM.CopyOf_12
	CMP.b #$01

	REP #$20

	LDA.b SA1IRAM.ROOM_TIME_LAG : ADC.w #$0000
	STA.b SA1IRAM.ROOM_TIME_LAG

	; ROOM TIMER
	LDA.b SA1IRAM.TIMER_ADD_SSFF
	AND.w #$00FF
	STA.b SA1IRAM.TIMER_ADD_SCRATCH

	LDA.b SA1IRAM.ROOM_TIME_F
	AND.w #$00FF
	SEC
	ADC.b SA1IRAM.TIMER_ADD_SCRATCH
	JSR GetMod60
	STA.b SA1IRAM.ROOM_TIME_F

	LDA.b SA1IRAM.TIMER_ADD_SSFF+1
	AND.w #$00FF
	ADC.b SA1IRAM.TIMER_ADD_SCRATCH
	ADC.b SA1IRAM.ROOM_TIME_S
	STA.b SA1IRAM.ROOM_TIME_S

	; SEGMENT TIMER
	LDA.b SA1IRAM.TIMER_ADD_SSFF
	AND.w #$00FF
	STA.b SA1IRAM.TIMER_ADD_SCRATCH

	LDA.b SA1IRAM.SEG_TIME_F
	AND.w #$00FF
	SEC
	ADC.b SA1IRAM.TIMER_ADD_SCRATCH
	JSR GetMod60
	STA.b SA1IRAM.SEG_TIME_F

	LDA.b SA1IRAM.TIMER_ADD_SSFF+1
	AND.w #$00FF
	ADC.b SA1IRAM.TIMER_ADD_SCRATCH
	ADC.b SA1IRAM.SEG_TIME_S
	JSR GetMod60
	STA.b SA1IRAM.SEG_TIME_S

	LDA.b SA1IRAM.TIMER_ADD_SCRATCH
	ADC.b SA1IRAM.SEG_TIME_M
	STA.b SA1IRAM.SEG_TIME_M

	STZ.b SA1IRAM.TIMER_ADD_SSFF

	; FLUSH
	REP #$18
	SEP #$20

	LDA.b SA1IRAM.TIMER_FLAG 
	BMI .donothing
	BEQ .donothing

	BIT.b SA1IRAM.TIMER_FLAG

	LDX.b SA1IRAM.ROOM_TIME_F    : STX.b SA1IRAM.ROOM_TIME_F_DISPLAY
	LDX.b SA1IRAM.ROOM_TIME_S    : STX.b SA1IRAM.ROOM_TIME_S_DISPLAY
	LDX.b SA1IRAM.ROOM_TIME_LAG  : STX.b SA1IRAM.ROOM_TIME_LAG_DISPLAY
	LDX.b SA1IRAM.ROOM_TIME_IDLE : STX.b SA1IRAM.ROOM_TIME_IDLE_DISPLAY

	LDX.b SA1IRAM.SEG_TIME_F     : STX.b SA1IRAM.SEG_TIME_F_DISPLAY
	LDX.b SA1IRAM.SEG_TIME_S     : STX.b SA1IRAM.SEG_TIME_S_DISPLAY
	LDX.b SA1IRAM.SEG_TIME_M     : STX.b SA1IRAM.SEG_TIME_M_DISPLAY

	BVC .dontreset

	LDX.w #$0000
	STX.b SA1IRAM.ROOM_TIME_F+0
	STX.b SA1IRAM.ROOM_TIME_F+2
	STX.b SA1IRAM.ROOM_TIME_F+4
	STX.b SA1IRAM.ROOM_TIME_F+6

.dontreset
	LDA.b #$80
	STA.b SA1IRAM.TIMER_FLAG

.donothing
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

	SEP #$30

	LDA.b #$80
	STA.l $00220B

	PHK
	PLB

	LDA.w $2301 ; get IRQ type
	AND.b #$03
	ASL
	TAX

	JSR (.irq_type,X)

	REP #$30
	PLB
	PLD
	PLY
	PLX
	PLA
	RTI

.irq_nothing
	RTS

.irq_type
	dw .irq_nothing
	dw .irq_shortcuts
	dw CorruptionWatcher
	dw .irq_hud

	dw .irq_nothing
	dw .irq_nothing
	dw .irq_nothing
	dw .irq_nothing

.irq_hud
	JSL draw_hud_extras
	RTS

.irq_shortcuts
	JSL DoShortCuts
	RTS
