pushpc

org $008B7C
	; need to calculate a dynamic size for it
	LDX.w SA1IRAM.HUDSIZE ; make hud bigger

org $0DFC29
	JML fire_hud_irq

; for boss cycle counters
org $05A39B
	JML ResetLanmoCycles

org $05A40E
	JSL UpdateLanmoCycles
	NOP

org $06919F
	JSL ResetAgaCycles
	NOP

org $1ED632
	JSL UpdateAgaCycles
	NOP


if !RANDO
	org $0DFC26 : JMP ++ : ++
	org $0DFBDD : JMP ++ : ++
endif

pullpc

;===================================================================================================

fire_hud_irq:
	JSL CacheSA1Stuff ; cache the big boy stuff we need for hud

	; don't want to be transferring too much
	; certain things will get designated as slow
	LDA.w SA1IRAM.highestline
	BEQ .noextra

	JSL Extra_SA1_Transfers
	SEP #$30

.noextra
	LDA.b #$83 ; request a hud update from SA-1
	STA.w $2200

	REP #$30

	LDA.l $7EF37B
	JML $0DFC2F

;===================================================================================================

HUDJumpCallA:
	STA.w SA1RAM.EasyJMP

HUDJumpCall:
	JMP.w (SA1RAM.EasyJMP)

;===================================================================================================

HUDJumpCallY:
	STY.w SA1RAM.EasyJMP
	JMP.w (SA1RAM.EasyJMP)

;===================================================================================================

UpdateLanmoCycles:
	INC.w $0D80,X
	INC.w SA1IRAM.BossCycles,X
	LDA.b #$18
	RTL

ResetLanmoCycles:
	STA.l $7FF81E,X
	STZ.w SA1IRAM.BossCycles,X
	RTL

ResetAgaCycles:
	STZ.w $0DC0,X

	STZ.w SA1IRAM.BossCycles+0
	STZ.w SA1IRAM.BossCycles+1
	STZ.w SA1IRAM.BossCycles+2

	RTL

UpdateAgaCycles:
	INC.w $0D80,X
	LDY.b #$04

	INC.w SA1IRAM.BossCycles,X
	RTL

;===================================================================================================
; A = address
; Y = color
;===================================================================================================
Draw:
.all_one
	STA.b SA1IRAM.SCRATCH+10
	STY.b SA1IRAM.hud_props
	BRA .digit1

.all_two
	STA.b SA1IRAM.SCRATCH+10
	STY.b SA1IRAM.hud_props
	BRA .digit10_always

.all_three
	STA.b SA1IRAM.SCRATCH+10
	STY.b SA1IRAM.hud_props
	BRA .digit100_always

.short_three
	STA.b SA1IRAM.SCRATCH+10
	STY.b SA1IRAM.hud_props
	JSR .set_conditional_flags_d3

.digit100
	BVC .digit10

.digit100_always
	LDA.b (SA1IRAM.SCRATCH+10)
	XBA
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+10,X
	BRA .digit10_always

.short_two
	STA.b SA1IRAM.SCRATCH+10
	STY.b SA1IRAM.hud_props
	JSR .set_conditional_flags_d2

.digit10
	BCC .digit1

.digit10_always
	LDA.b (SA1IRAM.SCRATCH+10)
	AND.w #$00F0
	LSR
	LSR
	LSR
	LSR
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+12,X

.digit1
	LDA.b (SA1IRAM.SCRATCH+10)
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+14,X

.done
	RTS

.set_conditional_flags_d3
	LDA.b (SA1IRAM.SCRATCH+10)
	CLC
	ADC.w #$7F00 ; overflow set if digit 3 exists

.set_conditional_flags_d2
	LDA.b (SA1IRAM.SCRATCH+10)
	CMP.w #$0010 ; carry set if digit 2 or 3 exists
	RTS

;===================================================================================================

PrepHexToDecDraw:
	PHX

	ASL
	TAX
	LDA.w hex_to_dec_fast_table,X
	PLX

	STA.b SA1IRAM.SCRATCH

	LDA.w #SA1IRAM.SCRATCH
	RTS

;===================================================================================================

hex_to_dec_fast:
	ASL : TAX

	LDA.w hex_to_dec_fast_table,X
	TAY : AND.w #$000F : STA.b SA1IRAM.SCRATCH+4
	TYA : AND.w #$00F0 : LSR : LSR : LSR : LSR : STA.b SA1IRAM.SCRATCH+2
	TYA : XBA : AND.w #$000F : STA.b SA1IRAM.SCRATCH+0

	RTS

hex_to_dec_fast_table:
	dw $000, $001, $002, $003, $004, $005, $006, $007, $008, $009
	dw $010, $011, $012, $013, $014, $015, $016, $017, $018, $019
	dw $020, $021, $022, $023, $024, $025, $026, $027, $028, $029
	dw $030, $031, $032, $033, $034, $035, $036, $037, $038, $039
	dw $040, $041, $042, $043, $044, $045, $046, $047, $048, $049
	dw $050, $051, $052, $053, $054, $055, $056, $057, $058, $059
	dw $060, $061, $062, $063, $064, $065, $066, $067, $068, $069
	dw $070, $071, $072, $073, $074, $075, $076, $077, $078, $079
	dw $080, $081, $082, $083, $084, $085, $086, $087, $088, $089
	dw $090, $091, $092, $093, $094, $095, $096, $097, $098, $099
	dw $100, $101, $102, $103, $104, $105, $106, $107, $108, $109
	dw $110, $111, $112, $113, $114, $115, $116, $117, $118, $119
	dw $120, $121, $122, $123, $124, $125, $126, $127, $128, $129
	dw $130, $131, $132, $133, $134, $135, $136, $137, $138, $139
	dw $140, $141, $142, $143, $144, $145, $146, $147, $148, $149
	dw $150, $151, $152, $153, $154, $155, $156, $157, $158, $159
	dw $160, $161, $162, $163, $164, $165, $166, $167, $168, $169
	dw $170, $171, $172, $173, $174, $175, $176, $177, $178, $179
	dw $180, $181, $182, $183, $184, $185, $186, $187, $188, $189
	dw $190, $191, $192, $193, $194, $195, $196, $197, $198, $199
	dw $200, $201, $202, $203, $204, $205, $206, $207, $208, $209
	dw $210, $211, $212, $213, $214, $215, $216, $217, $218, $219
	dw $220, $221, $222, $223, $224, $225, $226, $227, $228, $229
	dw $230, $231, $232, $233, $234, $235, $236, $237, $238, $239
	dw $240, $241, $242, $243, $244, $245, $246, $247, $248, $249
	dw $250, $251, $252, $253, $254, $255, $256, $257, $258, $259
	dw $260, $261, $262, $263, $264, $265, $266, $267, $268, $269
	dw $270, $271, $272, $273, $274, $275, $276, $277, $278, $279
	dw $280, $281, $282, $283, $284, $285, $286, $287, $288, $289
	dw $290, $291, $292, $293, $294, $295, $296, $297, $298, $299
	dw $300, $301, $302, $303, $304, $305, $306, $307, $308, $309
	dw $310, $311, $312, $313, $314, $315, $316, $317, $318, $319
	dw $320, $321, $322, $323, $324, $325, $326, $327, $328, $329
	dw $330, $331, $332, $333, $334, $335, $336, $337, $338, $339
	dw $340, $341, $342, $343, $344, $345, $346, $347, $348, $349
	dw $350, $351, $352, $353, $354, $355, $356, $357, $358, $359
	dw $360, $361, $362, $363, $364, $365, $366, $367, $368, $369
	dw $370, $371, $372, $373, $374, $375, $376, $377, $378, $379
	dw $380, $381, $382, $383, $384, $385, $386, $387, $388, $389
	dw $390, $391, $392, $393, $394, $395, $396, $397, $398, $399
	dw $400, $401, $402, $403, $404, $405, $406, $407, $408, $409
	dw $410, $411, $412, $413, $414, $415, $416, $417, $418, $419
	dw $420, $421, $422, $423, $424, $425, $426, $427, $428, $429
	dw $430, $431, $432, $433, $434, $435, $436, $437, $438, $439
	dw $440, $441, $442, $443, $444, $445, $446, $447, $448, $449
	dw $450, $451, $452, $453, $454, $455, $456, $457, $458, $459
	dw $460, $461, $462, $463, $464, $465, $466, $467, $468, $469
	dw $470, $471, $472, $473, $474, $475, $476, $477, $478, $479
	dw $480, $481, $482, $483, $484, $485, $486, $487, $488, $489
	dw $490, $491, $492, $493, $494, $495, $496, $497, $498, $499
	dw $500, $501, $502, $503, $504, $505, $506, $507, $508, $509
	dw $510, $511, $512, $513, $514, $515, $516, $517, $518, $519
	dw $520, $521, $522, $523, $524, $525, $526, $527, $528, $529
	dw $530, $531, $532, $533, $534, $535, $536, $537, $538, $539
	dw $540, $541, $542, $543, $544, $545, $546, $547, $548, $549
	dw $550, $551, $552, $553, $554, $555, $556, $557, $558, $559
	dw $560, $561, $562, $563, $564, $565, $566, $567, $568, $569
	dw $570, $571, $572, $573, $574, $575, $576, $577, $578, $579
	dw $580, $581, $582, $583, $584, $585, $586, $587, $588, $589
	dw $590, $591, $592, $593, $594, $595, $596, $597, $598, $599
	dw $600, $601, $602, $603, $604, $605, $606, $607, $608, $609
	dw $610, $611, $612, $613, $614, $615, $616, $617, $618, $619
	dw $620, $621, $622, $623, $624, $625, $626, $627, $628, $629
	dw $630, $631, $632, $633, $634, $635, $636, $637, $638, $639
	dw $640, $641, $642, $643, $644, $645, $646, $647, $648, $649
	dw $650, $651, $652, $653, $654, $655, $656, $657, $658, $659
	dw $660, $661, $662, $663, $664, $665, $666, $667, $668, $669
	dw $670, $671, $672, $673, $674, $675, $676, $677, $678, $679
	dw $680, $681, $682, $683, $684, $685, $686, $687, $688, $689
	dw $690, $691, $692, $693, $694, $695, $696, $697, $698, $699
	dw $700, $701, $702, $703, $704, $705, $706, $707, $708, $709
	dw $710, $711, $712, $713, $714, $715, $716, $717, $718, $719
	dw $720, $721, $722, $723, $724, $725, $726, $727, $728, $729
	dw $730, $731, $732, $733, $734, $735, $736, $737, $738, $739
	dw $740, $741, $742, $743, $744, $745, $746, $747, $748, $749
	dw $750, $751, $752, $753, $754, $755, $756, $757, $758, $759
	dw $760, $761, $762, $763, $764, $765, $766, $767, $768, $769
	dw $770, $771, $772, $773, $774, $775, $776, $777, $778, $779
	dw $780, $781, $782, $783, $784, $785, $786, $787, $788, $789
	dw $790, $791, $792, $793, $794, $795, $796, $797, $798, $799
	dw $800, $801, $802, $803, $804, $805, $806, $807, $808, $809
	dw $810, $811, $812, $813, $814, $815, $816, $817, $818, $819
	dw $820, $821, $822, $823, $824, $825, $826, $827, $828, $829
	dw $830, $831, $832, $833, $834, $835, $836, $837, $838, $839
	dw $840, $841, $842, $843, $844, $845, $846, $847, $848, $849
	dw $850, $851, $852, $853, $854, $855, $856, $857, $858, $859
	dw $860, $861, $862, $863, $864, $865, $866, $867, $868, $869
	dw $870, $871, $872, $873, $874, $875, $876, $877, $878, $879
	dw $880, $881, $882, $883, $884, $885, $886, $887, $888, $889
	dw $890, $891, $892, $893, $894, $895, $896, $897, $898, $899
	dw $900, $901, $902, $903, $904, $905, $906, $907, $908, $909
	dw $910, $911, $912, $913, $914, $915, $916, $917, $918, $919
	dw $920, $921, $922, $923, $924, $925, $926, $927, $928, $929
	dw $930, $931, $932, $933, $934, $935, $936, $937, $938, $939
	dw $940, $941, $942, $943, $944, $945, $946, $947, $948, $949
	dw $950, $951, $952, $953, $954, $955, $956, $957, $958, $959
	dw $960, $961, $962, $963, $964, $965, $966, $967, $968, $969
	dw $970, $971, $972, $973, $974, $975, $976, $977, $978, $979
	dw $980, $981, $982, $983, $984, $985, $986, $987, $988, $989
	dw $990, $991, $992, $993, $994, $995, $996, $997, $998, $999

;===================================================================================================

HUD_LineSize:
	dw $014A ; 0
	dw $0180 ; 1
	dw $01C0 ; 2
	dw $0200 ; 3

HUD_NMI_DMA_SIZE:
	dw $0240 ; 4

;===================================================================================================

draw_hud_extras:
	PHP
	PHB
	PHK
	PLB

	; clear up sentries
	REP #$30

	LDA.w #$0080
	TRB.b SA1IRAM.TIMER_FLAG

	LDX.w #$207F

	LDA.w #SA1RAM.HUD+($40*0) : TCD

	STX.b $26 : STX.b $28 : STX.b $2A : STX.b $2C : STX.b $2E : STX.b $30
	STX.b $32 : STX.b $34 : STX.b $36 : STX.b $38 : STX.b $3A : STX.b $3C

	STX.b $66 : STX.b $68 : STX.b $6A : STX.b $6C : STX.b $6E : STX.b $70
	STX.b $72 : STX.b $74 : STX.b $76 : STX.b $78 : STX.b $7A : STX.b $7C

	STX.b $90 : STX.b $92 : STX.b $94 : STX.b $96 : STX.b $98 : STX.b $9A
	STX.b $9C : STX.b $9E

	STX.b $A6 : STX.b $A8 : STX.b $AA : STX.b $AC : STX.b $AE : STX.b $B0
	STX.b $B2 : STX.b $B4 : STX.b $B6 : STX.b $B8 : STX.b $BA : STX.b $BC

	STX.b $E6 : STX.b $E8 : STX.b $EA : STX.b $EC : STX.b $EE : STX.b $F0
	STX.b $F2 : STX.b $F4 : STX.b $F6 : STX.b $F8 : STX.b $FA : STX.b $FC

	LDA.w #SA1RAM.HUD+($40*4) : TCD

	STX.b $26 : STX.b $28 : STX.b $2A : STX.b $2C : STX.b $2E : STX.b $30
	STX.b $32 : STX.b $34 : STX.b $36 : STX.b $38 : STX.b $3A : STX.b $3C

	STX.b $4A : STX.b $4C : STX.b $4E : STX.b $50 : STX.b $52 : STX.b $54
	STX.b $56 : STX.b $58 : STX.b $5A : STX.b $5C : STX.b $5E : STX.b $60
	STX.b $62 : STX.b $64 : STX.b $66 : STX.b $68 : STX.b $6A : STX.b $6C
	STX.b $6E : STX.b $70 : STX.b $72 : STX.b $74 : STX.b $76 : STX.b $78
	STX.b $7A : STX.b $7C : STX.b $7E : STX.b $80 : STX.b $82 : STX.b $84
	STX.b $86 : STX.b $88 : STX.b $8A : STX.b $8C : STX.b $8E : STX.b $90
	STX.b $92 : STX.b $94 : STX.b $96 : STX.b $98 : STX.b $9A : STX.b $9C
	STX.b $9E : STX.b $A0 : STX.b $A2 : STX.b $A4 : STX.b $A6 : STX.b $A8
	STX.b $AA : STX.b $AC : STX.b $AE : STX.b $B0 : STX.b $B2 : STX.b $B4
	STX.b $B6 : STX.b $B8 : STX.b $BA : STX.b $BC : STX.b $BE : STX.b $C0
	STX.b $C2 : STX.b $C4 : STX.b $C6 : STX.b $C8 : STX.b $CA : STX.b $CC
	STX.b $CE : STX.b $D0 : STX.b $D2 : STX.b $D4 : STX.b $D6 : STX.b $D8
	STX.b $DA : STX.b $DC : STX.b $DE : STX.b $E0 : STX.b $E2 : STX.b $E4
	STX.b $E6 : STX.b $E8 : STX.b $EA : STX.b $EC : STX.b $EE : STX.b $F0
	STX.b $F2 : STX.b $F4 : STX.b $F6 : STX.b $F8 : STX.b $FA : STX.b $FC
	STX.b $FE

	LDA.w #SA1RAM.HUD+($40*8) : TCD
	STX.b $00 : STX.b $02 : STX.b $04 : STX.b $06 : STX.b $08 : STX.b $0A
	STX.b $0C : STX.b $0E : STX.b $10 : STX.b $12 : STX.b $14 : STX.b $16
	STX.b $18 : STX.b $1A : STX.b $1C : STX.b $1E : STX.b $20 : STX.b $22
	STX.b $24 : STX.b $26 : STX.b $28 : STX.b $2A : STX.b $2C : STX.b $2E
	STX.b $30 : STX.b $32 : STX.b $34 : STX.b $36 : STX.b $38 : STX.b $3A
	STX.b $3C : STX.b $3E : STX.b $40 : STX.b $42 : STX.b $44 : STX.b $46
	STX.b $48

	LDA.w #$3000 : TCD

;===================================================================================================

	LDA.w !config_heart_display
	ASL
	TAX
	JSR (draw_hearts_options,X)

;===================================================================================================

	LDA.w !config_hudlag_spinner
	BNE .dohudlag

	LDA.w #$207F
	BRA .write_spinner

.char
	dw $2D3F|$0000
	dw $2D3F|$4000
	dw $2D3F|$C000
	dw $2D3F|$8000

.dohudlag
	LDA.b SA1IRAM.CopyOf_1A
	AND.w #$000C
	LSR
	TAX

	LDA.w .char,X

.write_spinner
	STA.w SA1RAM.HUD+$02

if !RANDO
	LDA.w #$207F
	LDX.w !config_fastrom
	BEQ .write_fastrom

	LDA.w #$2CA8

.write_fastrom
	STA.w SA1RAM.HUD+$00

endif

	LDX.w !config_state_icons : BNE ++

	LDA.w #$207F
	STA.w SA1RAM.HUD+$042
	STA.w SA1RAM.HUD+$082
	STA.w SA1RAM.HUD+$0C2
	STA.w SA1RAM.HUD+$102
	BRA draw_hud_sentry

	; super speed
++	SEP #$10

	LDA.w #char($1C)|!RED_PAL
	LDX.b SA1IRAM.CopyOf_0372 : BNE ++

	LDA.w #char($1C)|!GRAY_PAL

++	STA.w SA1RAM.HUD+$042

	; water walk
	LDA.w #char($1D)|!BLUE_PAL
	LDX.b SA1IRAM.CopyOf_5B : BNE ++

	LDA.w #char($1D)|!GRAY_PAL

++	STA.w SA1RAM.HUD+$082

	; door state
	LDA.w #char($1A)|!BROWN_PAL
	LDX.b SA1IRAM.CopyOf_6C : BNE ++

	LDA.w #char($1A)|!GRAY_PAL

++	STA.w SA1RAM.HUD+$0C2

	; stair drag
	LDA.w #char($1B)|!BROWN_PAL
	LDX.b SA1IRAM.CopyOf_57 : BNE ++

	LDA.w #char($1B)|!GRAY_PAL

++	STA.w SA1RAM.HUD+$102

	REP #$30

;===================================================================================================

draw_hud_sentry:
	LDY.w !config_sentry1 : LDA.w sentry_routines,Y : STA.w SA1RAM.EasyJMP
	LDX.w #$002E : LDA.w SA1IRAM.SNTVAL1 : JSR HUDJumpCall

	LDY.w !config_sentry2 : LDA.w sentry_routines,Y : STA.w SA1RAM.EasyJMP
	LDX.w #$006E : LDA.w SA1IRAM.SNTVAL2 : JSR HUDJumpCall

	LDY.w !config_sentry3 : LDA.w sentry_routines,Y : STA.w SA1RAM.EasyJMP
	LDX.w #$00AE : LDA.w SA1IRAM.SNTVAL3 : JSR HUDJumpCall

	LDY.w !config_sentry4 : LDA.w sentry_routines,Y : STA.w SA1RAM.EasyJMP
	LDX.w #$00EE : LDA.w SA1IRAM.SNTVAL4 : JSR HUDJumpCall

	LDY.w !config_sentry5 : LDA.w sentry_routines,Y : STA.w SA1RAM.EasyJMP
	LDX.w #$012E : LDA.w SA1IRAM.SNTVAL5 : JSR HUDJumpCall

;===================================================================================================

draw_hud_linesentrys:
	LDA.w !config_hide_lines
	BNE .no_line_sentries

	LDY.w #16*0 : LDX.w !config_linesentry1
	LDA.w sentry_routines,X : LDX.w #$014A : JSR HUDJumpCallA

	LDY.w #16*1 : LDX.w !config_linesentry2
	LDA.w sentry_routines,X : LDX.w #$018A : JSR HUDJumpCallA

	LDY.w #16*2 : LDX.w !config_linesentry3
	LDA.w sentry_routines,X : LDX.w #$01CA : JSR HUDJumpCallA

	LDY.w #16*3 : LDX.w !config_linesentry4
	LDA.w sentry_routines,X : LDX.w #$020A : JSR HUDJumpCallA

.no_line_sentries

;===================================================================================================

hud_draw_input_display:
	LDA.w !config_input_display
	AND.w #$0003
	ASL : TAX

	LDA.b SA1IRAM.CONTROLLER_1
	XBA

	JSR (.options,X)

;===================================================================================================
; clean up the stuff right under items
	REP #$30

	LDA.w #$207F
	STA.w SA1RAM.HUD+$10A
	STA.w SA1RAM.HUD+$10C
	STA.w SA1RAM.HUD+$10E

	LDA.b SA1IRAM.CopyOf_1B
	LSR
	BCC draw_quickwarp

	JSR draw_boss_cycles

	BRA .skip

;===================================================================================================

#draw_quickwarp:
	SEP #$30

	LDA.w !config_qw_toggle
	EOR.b #$01
	ORA.b SA1IRAM.CopyOf_1B
	BNE .skip

	LDA.b SA1IRAM.CopyOf_E2 : AND.b #$06 : CMP.b #$06 ; sets carry if 06

	REP #$30

	LDA.w #$300C

	BCC .not_qw

	ORA.w #$3800

.not_qw
	STA.w SA1RAM.HUD+$10A
	INC
	STA.w SA1RAM.HUD+$10C

.skip

;===================================================================================================

done_extras:
	PLB
	PLP
	RTL

;===================================================================================================

draw_hearts_options:
	dw .practicehack
	dw .vanilla

;---------------------------------------------------------------------------------------------------

.practicehack
	SEP #$21
	LDA.b SA1IRAM.CopyOf_7EF36C
	SBC.b SA1IRAM.CopyOf_7EF36D
	CMP.b #$04

	REP #$30
	LDA.w #$24A0
	ADC.w #$0000
	STA.w SA1RAM.HUD+$90

	LDA.b SA1IRAM.CopyOf_7EF36D
	AND.w #$00FF
	LSR
	LSR
	LSR
	JSR hex_to_dec_fast

	LDA.b SA1IRAM.SCRATCH+2
	ORA.w #$3C90
	STA.w SA1RAM.HUD+$92

	LDA.b SA1IRAM.SCRATCH+4
	ORA.w #$3C90
	STA.w SA1RAM.HUD+$94

	LDA.b SA1IRAM.CopyOf_7EF36D
	AND.w #$0007
	ORA.w #$3490
	STA.w SA1RAM.HUD+$96

	LDA.w #$207F
	STA.w SA1RAM.HUD+$98

	; containers
	LDA.w #$24A2
	STA.w SA1RAM.HUD+$9A

	LDA.b SA1IRAM.CopyOf_7EF36C
	AND.w #$00FF
	LSR
	LSR
	LSR
	JSR hex_to_dec_fast

	LDA.b SA1IRAM.SCRATCH+2
	ORA.w #$3C90
	STA.w SA1RAM.HUD+$9C

	LDA.b SA1IRAM.SCRATCH+4
	ORA.w #$3C90
	STA.w SA1RAM.HUD+$9E

	RTS

;---------------------------------------------------------------------------------------------------

.vanilla
	; --LIFE--
	LDA.w #$288B : STA.w SA1RAM.HUD+$02C
	LDA.w #$288F : STA.w SA1RAM.HUD+$02E
	LDA.w #$24AB : STA.w SA1RAM.HUD+$030
	LDA.w #$24AC : STA.w SA1RAM.HUD+$032
	LDA.w #$688F : STA.w SA1RAM.HUD+$034
	LDA.w #$688B : STA.w SA1RAM.HUD+$036

	LDA.b SA1IRAM.CopyOf_7EF36C
	LSR ; shift both right at once
	LSR
	LSR
	AND.w #$1F1F

	SEP #$10

	TAX ; X has max health
	XBA
	TAY ; Y has current health

	LDA.w #SA1RAM.HUD+$068
	STA.b SA1IRAM.SCRATCH+0
	STA.b SA1IRAM.SCRATCH+2

..next_filled_heart
	CPX.b #1 ; do we have at least 1 HP?
	BMI ..done_hearts

	LDA.w #$24A0

	CPY.b #1
	BPL ..add_heart

	LDA.w #$24A2

..add_heart
	STA.b (SA1IRAM.SCRATCH+0)

	DEY
	DEX

	LDA.b SA1IRAM.SCRATCH+0
	INC
	INC
	CMP.w #SA1RAM.HUD+$07C
	BEQ ..nextrow

	CMP.w #SA1RAM.HUD+$0BC
	BNE ..fine

..nextrow
	ADC.w #$002B ; +1 carry +2 from inc

..fine
	STA.b SA1IRAM.SCRATCH+0

	CPY.b #$00
	BNE ..next_filled_heart ; save pointer when we have 0 hearts left to add

	STA.b SA1IRAM.SCRATCH+2
	BRA ..next_filled_heart

..done_hearts
	LDA.b SA1IRAM.CopyOf_7EF36D
	AND.w #$0007
	BEQ ..skip_partial

	CMP.w #$0005
	LDA.w #$24A0
	BCS ..more_than_half

	INC ; 1-4 means half heart

..more_than_half
	STA.b (SA1IRAM.SCRATCH+2)

..skip_partial
	LDA.w SA1IRAM.Moved_0209
	BIT.w #$FF00
	BEQ ..done

	AND.w #$00FF
	ASL
	TAX

	LDA.l $0DFA29,X
	STA.b (SA1IRAM.SCRATCH+2)

..done
	RTS

;===================================================================================================

; wrap at 7a
hud_draw_input_display_options:
	dw .off
	dw .cool
	dw .classic
	dw .classicgray

.off
	RTS

;---------------------------------------------------------------------------------------------------

.cool
	STA.b SA1IRAM.SCRATCH ; dpad
	AND.w #$000F : ORA.w #$2D70 : STA.w SA1RAM.HUD+$66+2

	; need buttons in this order: xbya
	SEP #$30

	LDA.b SA1IRAM.SCRATCH+0 : AND.b #$C0
	LSR : LSR : LSR : LSR : LSR ; b and y in place
	STA.b SA1IRAM.SCRATCH+2

	LDA.b SA1IRAM.SCRATCH+1 : AND.b #$40
	LSR : LSR : LSR ; x in place
	ORA.b SA1IRAM.SCRATCH+2
	
	; this ASL takes care of one for figuring out LR inputs
	ASL.b SA1IRAM.SCRATCH+1 : ADC.b #$70 ; a in place

	; #$70 is the character offset we want
	; top byte contains $29 from doing dpad, which is what we want
	REP #$20
	STA.w SA1RAM.HUD+$66+6

	; start and select
	LDA.b SA1IRAM.SCRATCH : AND.w #$0030
	LSR : LSR : LSR : LSR
	ORA.w #$2C00
	STA.w SA1RAM.HUD+$66+4

	; L and R
	ASL.b SA1IRAM.SCRATCH : ASL.b SA1IRAM.SCRATCH ; L into carry and remember where R is
	LDA.w #$2C04 : ADC.w #$0000 : STA.w SA1RAM.HUD+$26+2

	ASL.b SA1IRAM.SCRATCH ; R into carry
	LDA.w #$6C04 : ADC.w #$0000 : STA.w SA1RAM.HUD+$26+6

	LDA.w #$2C06 : STA.w SA1RAM.HUD+$26+4

	RTS

;---------------------------------------------------------------------------------------------------

.classic
	REP #$70 ; clear overflow means classic
	BRA ++

.classicgray
	REP #$20
	SEP #$40 ; set overflow means classic gray

	; Y will hold the current input character
++	STA.b SA1IRAM.SCRATCH+0
	XBA
	LSR
	LSR
	LSR
	LSR
	STA.b SA1IRAM.SCRATCH+1 ; for high byte

	LDX.w #$0000

..next_button
	LDY.w .classic_locations,X

	TXA
	LSR

	LSR.b SA1IRAM.SCRATCH
	BCC ..nopress

..press
	ORA.w #$2570
	BRA ..addchr

..nopress
	BVC ..nochar
	ORA.w #$3170

..addchr
	STA.w SA1RAM.HUD,Y

..nochar
	INX
	INX
	CPX.w #23
	BCC ..next_button

	RTS

;---------------------------------------------------------------------------------------------------

.classic_locations
	dw $68+4  ; dpad right
	dw $68+0  ; dpad left
	dw $68+2  ; dpad down
	dw $28+2  ; dpad up

	dw $68+10 ; start
	dw $28+10 ; select
	dw $28+6  ; Y
	dw $68+6  ; B

	dw $28+4  ; R shoulder
	dw $28+0  ; L shoulder
	dw $28+8  ; X
	dw $68+8  ; A

;===================================================================================================

draw_boss_cycles:
	LDA.w !config_toggle_boss_cycles
	BEQ .no

	LDA.b SA1IRAM.CopyOf_A0
	CMP.w #$0033 : BEQ .three ; lanmo
	CMP.w #$000D : BEQ .three ; agahnim

	BRA .no

.three
	LDA.w #$0002
	BRA .start

.start
	TAX
	ASL
	TAY

.next
	LDA.b SA1IRAM.BossCycles,X
	AND.w #$00FF
	ORA.w #$2010
	STA.w SA1RAM.HUD+$10A,Y

	DEY
	DEY
	DEX
	BPL .next

.no
	RTS

;===================================================================================================

DrawHex:

.4digit
	STA.b SA1IRAM.hud_val
.4digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+14,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR

.3digit
	STA.b SA1IRAM.hud_val
.3digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+14,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR

.2digit
	STA.b SA1IRAM.hud_val
.2digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+14,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR

.1digit
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD+14,X
	DEX : DEX

	RTS

;---------------------------------------------------------------------------------------------------

.white_4
	LDY.w #!white

.4digit_prepped
	STY.b SA1IRAM.hud_props
	JMP .4digit

.white_3
	LDY.w #!white

.3digit_prepped
	STY.b SA1IRAM.hud_props
	JMP .3digit

.white_2
	LDY.w #!white

.2digit_prepped
	STY.b SA1IRAM.hud_props
	JMP .2digit

.white_1
	LDY.w #!white

.1digit_prepped
	STY.b SA1IRAM.hud_props
	JMP .1digit

;---------------------------------------------------------------------------------------------------

.red_4
	LDY.w #!red : STY.b SA1IRAM.hud_props
	JMP .4digit

.red_3
	LDY.w #!red : STY.b SA1IRAM.hud_props
	JMP .3digit

.red_2
	LDY.w #!red : STY.b SA1IRAM.hud_props
	JMP .2digit

.red_1
	LDY.w #!red : STY.b SA1IRAM.hud_props
	JMP .1digit

;---------------------------------------------------------------------------------------------------

.gray_4
	LDY.w #!gray : STY.b SA1IRAM.hud_props
	JMP .4digit

.gray_3
	LDY.w #!gray : STY.b SA1IRAM.hud_props
	JMP .3digit

.gray_2
	LDY.w #!gray : STY.b SA1IRAM.hud_props
	JMP .2digit

.gray_1
	LDY.w #!gray : STY.b SA1IRAM.hud_props
	JMP .1digit

;---------------------------------------------------------------------------------------------------

.yellow_4
	LDY.w #!yellow : STY.b SA1IRAM.hud_props
	JMP .4digit

.yellow_3
	LDY.w #!yellow : STY.b SA1IRAM.hud_props
	JMP .3digit

.yellow_2
	LDY.w #!yellow : STY.b SA1IRAM.hud_props
	JMP .2digit

.yellow_1
	LDY.w #!yellow : STY.b SA1IRAM.hud_props
	JMP .1digit

;===================================================================================================

DrawHexForward:

.4digit
	STA.b SA1IRAM.hud_val

.4digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD-2,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR


.3digit
	STA.b SA1IRAM.hud_val

.3digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD-2,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR

.2digit
	STA.b SA1IRAM.hud_val

.2digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD-2,X
	LDA.b SA1IRAM.hud_val
	DEX : DEX
	LSR : LSR : LSR : LSR

.1digit
.1digit_start
	AND.w #$000F
	ORA.b SA1IRAM.hud_props
	STA.w SA1RAM.HUD-2,X

	LDX.b SA1IRAM.hud_val2

	RTS

;---------------------------------------------------------------------------------------------------

.4digit_color_set
	STA.b SA1IRAM.hud_val
	BRA .4prepped

.4digit_prep
	STA.b SA1IRAM.hud_props

.4prepped
	TXA : CLC : ADC.w #(4*2)
	TAX

	STX.b SA1IRAM.hud_val2
	LDA.b SA1IRAM.hud_val
	JMP .4digit_start

;---------------------------------------------------------------------------------------------------

.3digit_color_set
	STA.b SA1IRAM.hud_val
	BRA .3prepped

.3digit_prep
	STA.b SA1IRAM.hud_props

.3prepped
	TXA : CLC : ADC.w #(3*2)
	TAX

	STX.b SA1IRAM.hud_val2
	LDA.b SA1IRAM.hud_val
	JMP .3digit_start


;---------------------------------------------------------------------------------------------------

.2digit_color_set
	STA.b SA1IRAM.hud_val
	BRA .2prepped

.2digit_prep
	STA.b SA1IRAM.hud_props

.2prepped
	TXA : CLC : ADC.w #(2*2)
	TAX

	STX.b SA1IRAM.hud_val2
	LDA.b SA1IRAM.hud_val
	JMP .2digit_start

;---------------------------------------------------------------------------------------------------

.1digit_color_set
	STA.b SA1IRAM.hud_val
	BRA .1prepped

.1digit_prep
	STA.b SA1IRAM.hud_props

.1prepped
	STX.b SA1IRAM.hud_val2
	LDA.b SA1IRAM.hud_val
	JMP .1digit_start

;---------------------------------------------------------------------------------------------------

.white_4
	STA.b SA1IRAM.hud_val
	LDA.w #!white
	JMP .4digit_prep

.white_3
	STA.b SA1IRAM.hud_val
	LDA.w #!white
	JMP .3digit_prep

.white_2
	STA.b SA1IRAM.hud_val
	LDA.w #!white
	JMP .2digit_prep

.white_1
	STA.b SA1IRAM.hud_val
	LDA.w #!white
	JMP .1digit_prep

;---------------------------------------------------------------------------------------------------

.red_4
	STA.b SA1IRAM.hud_val
	LDA.w #!red
	JMP .4digit_prep

.red_3
	STA.b SA1IRAM.hud_val
	LDA.w #!red
	JMP .3digit_prep

.red_2
	STA.b SA1IRAM.hud_val
	LDA.w #!red
	JMP .2digit_prep

.red_1
	STA.b SA1IRAM.hud_val
	LDA.w #!red
	JMP .1digit_prep

;---------------------------------------------------------------------------------------------------

.gray_4
	STA.b SA1IRAM.hud_val
	LDA.w #!gray
	JMP .4digit_prep

.gray_3
	STA.b SA1IRAM.hud_val
	LDA.w #!gray
	JMP .3digit_prep

.gray_2
	STA.b SA1IRAM.hud_val
	LDA.w #!gray
	JMP .2digit_prep

.gray_1
	STA.b SA1IRAM.hud_val
	LDA.w #!gray
	JMP .1digit_prep

;---------------------------------------------------------------------------------------------------

.yellow_4
	STA.b SA1IRAM.hud_val
	LDA.w #!yellow
	JMP .4digit_prep

.yellow_3
	STA.b SA1IRAM.hud_val
	LDA.w #!yellow
	JMP .3digit_prep

.yellow_2
	STA.b SA1IRAM.hud_val
	LDA.w #!yellow
	JMP .2digit_prep

.yellow_1
	STA.b SA1IRAM.hud_val
	LDA.w #!yellow
	JMP .1digit_prep

;===================================================================================================
