pushpc
; Code that is run once after the game has been powered on.

org $008004
	LDA.b #$FF
	STA.w SIC
	NOP

org $00802F
	JML init_hook
	NOP
init_done:

; optimize message pointer creation by a lot
org $1CF37A
	PEA.w MessagePointers
	PEA.w $71C0
	PEA.w MessagePointers.size
	SEC ; bank 7F

; push to stack: source, destination, size
; carry = wram bank
DoWRAMBig:
	REP #$20
	PLA
	STA.w DMA0SIZE

	PLA
	STA.w WMADDL

	PLA
	STA.w DMA0ADDRL

	LDA.w #$00][WMDATA
	STA.w DMAP0

	SEP #$30
	LDA.b #^MessagePointers
	STA.w DMA0ADDRB

	LDA.b #$00
	ROL
	STA.w WMADDB

	LDA.b #$01
	STA.w MDMAEN

	RTL

DoWRAM4BPP:
	PEA.w WRAMGFX
	PEA.w $9000
	PEA.w WRAMGFX:size

	CLC ; bank 7E
	BRA DoWRAMBig

guardpc $1CF3D4

org $0EFCB2
	PEA.w FiveBeeZeroZero
	PEA.w $5B00
	PEA.w FiveBeeZeroZero.size
	SEC ; bank 7F
	JML DoWRAMBig

pullpc

;===================================================================================================

init_hook:
	SEP #$30

	LDA.b #$03 : STA.l BMAPS ; image 3 for page $60

	LDA.l CONFIG.feature_music : BNE ++

	JSL mute_music

++	LDA.b #$22 : STA.l APUIO3 ; BWOOWOOOWOWOOOOOO

	JSL InitSA1

	REP #$20
	SEP #$10
	STZ.w WMADDH

	LDA.w #$2000
	STA.w WMADDH
ZeroLand = !:pc+1 ; TODO MOVE THIS
	LDA.w #$4300
	TCD

	LDA.w #ZeroLand
	STA.b DMA1ADDRL
	STA.b DMA0ADDRL

	LDX.b #^ZeroLand
	STX.b DMA1ADDRB
	STX.b DMA0ADDRB

	LDA.w #$E000 ; this many bytes for WRAM
	STA.b DMA1SIZE

	LDA.w #$08][WMDATA
	STA.b DMAP1
	STA.b DMAP0

	LDX.b #$02
	STX.w MDMAEN

	DEX
	STX.w WMADDB
	STZ.w WMADDL
	STX.w MDMAEN

	REP #$30

	LDA.w #$FFFF

	LDX.w #$017E

--	STA.l IRAM.corruption_defense,X
	DEX
	DEX
	BPL --

	LDA.w #$0000
	TCD

;===================================================================================================
; Done doing what ALTTP needs done but faster
;===================================================================================================

	SEP #$30
	; check for reset config combo
	LDA.b #$01 : STA.w JOYPAD : STZ.w JOYPAD ; pulse controller

	STZ.b $00 : STZ.b $01
	LDY.b #$10 ; reading 16 bits

.poll_joypad
	LDA.w JOYPAD ; if the last bit is on, carry will be set, otherwise, it won't; A is still 1
	LSR
	ROL.b $00 : ROL.b $01 ; roll carry from A and then from $00
	DEY
	BNE .poll_joypad

	REP #$20
	LDA.b $00
	AND.w #$FF00 : CMP.w #$3000 : BEQ .forcereset
	LDA.w CONFIG.init_sig : CMP.w #!INIT_SIGNATURE : BEQ .noforcereset

.forcereset
	JSR ResetConfig
	BRA .sram_initialized

.noforcereset
	LDA.w CONFIG.sram_initialized
	CMP.w #$0031 : BCC .forcereset

.sram_initialized
	REP #$10
	; clear unused config settings, for when they're used in future updates
	LDX.w #!config_size

	SEP #$20
	LDA.b #$00
	BRA ++ ; TODO not necessary to BRA, just go right into loop

--	STA.l BWRAM.SETTINGS,X
	INX
++	CPX.w #$0400
	BCC --

	SEP #$30

	STZ.w $037F

;===================================================================================================
; everything is done now
; back to the game
;===================================================================================================
	JSL jlong($028000)
	JSL jlong($028022)
	JSL jlong($0EF572)
	JSL DoWRAM4BPP

	JSL InitializeSentries

	REP #$30

	JSL ConfigMenuSize

	SEP #$30

	LDA.b #$15 : STA.b $1C

	STZ.b $11
	STZ.b $12

	LDA.b #$01
	STA.b $10
	STA.w $04AA

	LDA.b #$81 : STA.w NMITIMEN

	JML init_done

;===================================================================================================

ResetConfig:
	SEP #$20

	LDA.b #$1F : STA.w APUIO3
	STA.l BWRAM.old_music_bank

	REP #$30

	LDY.w #ConfigInitTable

	PHB
	PHK
	PLB

.next
	LDX.w $0000,Y
	BEQ .done_options

	INY
	INY

	LDA.w $0000,Y
	STA.l ^&CONFIG,X

	INY
	INY
	BRA .next

.done_options

;---------------------------------------------------------------------------------------------------

	SEP #$30

	LDY.b #$00
	STY.b $00

.next_loadout
	LDA.b #$00
	LDX.b #$7F

.clear_loadout
	STA.l $7EF340,X

	DEX
	BPL .clear_loadout

	INC.b $00

	LDX.b #$FF

.next_row
	JSR .get_row

	INX : JSR .add_if_set
	INX : JSR .add_if_set
	INX : JSR .add_if_set
	INX : JSR .add_if_set
	INX : JSR .add_if_set

	CPX.b #$13
	BCC .next_row

	JSR .get_row

	LDA.b #$01

	LDX.b #$15 : JSR .add_if_set
	LDX.b #$14 : JSR .add_if_set
	LDX.b #$16 : JSR .add_if_set
	LDX.b #$17 : JSR .add_if_set
	LDX.b #$3B : JSR .add_if_set

	PHY

	; fix mirror
	LDA.l $7EF353
	ASL
	STA.l $7EF353

	; set hearts
	LDA.b #$18
	STA.l $7EF36C
	STA.l $7EF36D

	JSL SetFlippersFlag
	JSL SetBootsFlag

	LDA.b $00
	JSL SaveCustomLoadout

	SEP #$30

	PLY

	LDA.b $00
	CMP.b #$08
	BCC .next_loadout

.done_loadouts
	PLB
	RTS

;===================================================================================================

.get_row
	LDA.w .equipment_sets,Y
	STA.b $02

	LDA.b #$01
	INY
	RTS

.add_if_set
	ASL.b $02
	BCC .no

	STA.l $7EF340,X

.no
	RTS

.equipment_sets
	db %01110000
	db %01001000
	db %01110000
	db %01000000
	db %01000000

	db %01001000
	db %01001000
	db %01001000
	db %01001000
	db %00110000

	db %01001000
	db %01101000
	db %01011000
	db %01001000
	db %01001000

	db %01110000
	db %00100000
	db %00100000
	db %00100000
	db %01110000

	db %01110000
	db %01001000
	db %01110000
	db %01001000
	db %01001000

	db %01001000
	db %01001000
	db %01001000
	db %01001000
	db %00110000

	db %01010000
	db %01010000
	db %01010000
	db %00000000
	db %01010000

	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000

;===================================================================================================

incbin [WRAMGFX] "resources/decomped.4bpp"

MessagePointers:
	dw $8000, $8001, $800E, $801B, $803C, $805C, $806D, $8078
	dw $8083, $808E, $8097, $80A0, $80DF, $818F, $81B7, $81E4
	dw $8211, $823E, $826A, $8297, $82C0, $82E9, $8313, $8457
	dw $848D, $84B6, $853E, $855F, $8648, $866E, $8728, $8775
	dw $87B0, $8809, $8837, $8892, $8929, $895E, $89BC, $89EA
	dw $8A18, $8A3F, $8AAF, $8B89, $8BE5, $8C0E, $8C2C, $8C8B
	dw $8CB0, $8D86, $8DF0, $8E27, $8F97, $9003, $9039, $916B
	dw $935A, $9389, $93B9, $93D8, $93E7, $93FA, $9415, $942E
	dw $944B, $945C, $947A, $9495, $94B4, $94BF, $94EE, $94FE
	dw $950F, $9533, $955E, $958C, $95B7, $9616, $9631, $9650
	dw $9673, $9693, $96B8, $96DE, $970C, $9731, $975B, $9787
	dw $97BF, $97F3, $982A, $9857, $9886, $98BB, $98DD, $990C
	dw $9940, $9972, $99AB, $99E2, $9A18, $9A48, $9A72, $9A9E
	dw $9ACD, $9AFA, $9B27, $9B59, $9B85, $9BB6, $9BDA, $9C81
	dw $9CAA, $9CD7, $9D05, $9D39, $9D61, $9D8D, $9DB5, $9DE5
	dw $9E13, $9E38, $9E60, $9E97, $9EF1, $9F47, $9FAF, $A018
	dw $A054, $A066, $A09B, $A0D1, $A123, $A138, $A161, $A185
	dw $A1CA, $A1E5, $A207, $A237, $A261, $A27B, $A2A5, $A2C6
	dw $A2E1, $A302, $A322, $A352, $A382, $A3B2, $A3E1, $A454
	dw $A508, $A524, $A5B8, $A5E9, $A680, $A70E, $A7A3, $A81B
	dw $A876, $A96D, $A9F2, $AA0F, $AA3E, $AAD3, $AAFE, $AB19
	dw $AB34, $AB52, $AB61, $AB71, $AB80, $ABB0, $ABCB, $ABDB
	dw $ABED, $AC1D, $AC41, $ACA1, $AD23, $AD47, $ADA6, $AE01
	dw $AE61, $AE95, $AEC2, $AEE4, $AF13, $AF41, $AF9F, $AFD3
	dw $B019, $B068, $B099, $B0C2, $B0F4, $B154, $B176, $B1A3
	dw $B1CD, $B1ED, $B212, $B23E, $B261, $B280, $B29A, $B2C6
	dw $B30C, $B330, $B352, $B373, $B397, $B3BE, $B3E6, $B425
	dw $B44F, $B473, $B491, $B4B4, $B4D1, $B4ED, $B51A, $B56F
	dw $B5EF, $B60D, $B622, $B64B, $B6F9, $B71B, $B738, $B75A
	dw $B801, $B82A, $B85F, $B889, $B8BB, $B8EC, $B91E, $B951
	dw $B97F, $B9AD, $BA04, $BA38, $BA58, $BA81, $BAB8, $BAE5
	dw $BB14, $BB41, $BB6D, $BB9E, $BBD0, $BC17, $BC8D, $BCB6
	dw $BD53, $BDC6, $BE1D, $BE4C, $BED4, $BEF4, $BEFF, $BF0A
	dw $BF73, $BF8F, $BFA2, $BFCF, $BFF2, $C015, $C038, $C08D
	dw $C0DD, $C2AB, $C2EB, $C32C, $C36A, $C38F, $C3BD, $C3EA
	dw $C404, $C42F, $C47F, $C49F, $C4CC, $C51A, $C545, $C56B
	dw $C588, $C5B4, $C5C7, $C5E2, $C6F2, $C750, $C77D, $C7B0
	dw $C7DA, $C807, $C820, $C84B, $C875, $C8A4, $C8CF, $C8F1
	dw $C91C, $CC51, $CF83, $D1D9, $D3C4, $D643, $D85D, $DAB2
	dw $DADC, $DB05, $DB27, $DDD0, $DE21, $DEB5, $DEE2, $DF14
	dw $DF72, $DF9D, $DFE8, $E06D, $E096, $E0C3, $E126, $E158
	dw $E2C3, $E305, $E30C, $E313, $E33A, $E367, $E3F5, $E404
	dw $E413, $E422, $E432, $E446, $E45E, $E476, $E48E, $E4B5
	dw $E4DC, $E4FA, $E5DC, $E608, $E6BD, $E6ED, $E71F, $E76E
	dw $E792, $E7B9, $E7DE, $E7F5, $E81F, $E848, $E868, $E891
	dw $E8B5, $E8D7, $E901, $E91B, $E948, $E970, $E9F8, $EA25
	dw $EA8C, $EAEA, $EE1A, $EE29, $EE7A, $EE88, $EEB3, $EEDA
	dw $EF09, $EF25, $EF45, $EF62, $EFEA, $F039, $F050, $F072
	dw $F0C1, $F157, $F1E4, $F204, $F233, $F24E, $F29E, $F2C8
	dw $F2EC, $F310, $F325, $F356
^.size

;===================================================================================================

FiveBeeZeroZero:
raw 00001A003300490062007E009900B400D000EC0008011E013B014D0168018401
raw 9D01B801D101EE0109022302430263027F029902B402C602DE02F60215032E03
raw 4D03690383039D03B703D003F0030E042D04490463047C049104AD04CD04ED04
raw 0C0524053E055A0574058D05A705C405E205FB0511062A0644065C067C069C06
raw BC06D906F90619073907590777079707A807B907CB07DA07EC07FC070E082208
raw 35084E08680885089D08BA08D808EF08030921093D095B0976098909A309BB09
raw D209EF09090A230A3E0A580A780A980AB80AD60AF00A0B0B240B3F0B5C0B740B
raw 930BB00BBC0BD50BF20B0A0C290C490C690C830C9F0CB70CCC0CEA0C090D290D
raw 490D610D7B0D930DAD0DC70DE60D040E240E3C0E5A0E730E8C0EA60EC60EE60E
raw 020F1F0F3F0F5F0F7F0F9B0FB90FD90FEB0FFC0F0C101C102C103E1050106010
raw 72108C10A410BE10D810F1100B1125113F11591173118D11A711C111DB11F511
raw 0E12281242125A1274128E12A712C112DB12F5120F132A1344135E1377139113
raw AB13C513DF13F813121427143F145C1474147C148314A114BC14C714D114DC14
raw EE140015121537154E156015721584159615A015AC15B415BC15C415E4150316
raw 1E163B16561670168C16AB16D116F7160B17311745176B177F179117A117B317
raw C517D717E917FB170D181F18311843185518671879188B189D18AF18C118D318
raw D318F31813193219551973199319AE19CE19EE190E1A2E1A4F1A6F1A8B1AAA1A
raw C91AE91A091B291B491B691B891BA31BC11BDE1BFE1B1E1C3C1C5C1C7C1C9C1C
raw BC1CDA1CF91C181D341D521D6C1D871DA91DCB1DEB1D0B1E2B1E4C1E6C1E8B1E
raw AB1EC81EE81E061F261F461F661F831FA01FBE1FDF1FFC1F1C203B2057207520
raw 9520B520D320F0200F212C214E216C218C21AC21CA21EA210B22292247226522
raw 8522A522C522E32205232123402360238123A123C123E123FE231F243D245724
raw 76249624B424D424F32413253125512570258E25AE25CC25E825082628264826
raw 66268626A326BF26DE26FD2615273427542773279327B127D127EF270D282B28
raw 482868288828A828C828E92808292829472967298729A829C929E729052A252A
raw 452A662A862AA72AC72AE32A032B242B422B622B822BA42BC02BDF2BFF2B1D2C
raw 3E2C5E2C7C2C9B2CBA2CD82CEA2C052D252D432D642D852DA52DC22DE22D042E
raw 232E442E622E7F2EA12EC22EE42E052F252F452F662F872FA82FC62FE62F0530
raw 2730493068308A30AB30CE30F03012313331533175319331B231D531F6311532
raw 3332543276329332B432D432F43216333833573376339433B433D133F2331234
raw 3434553476349634B834D834F83415353635573574359535B835D935F9351B363D
raw 365B367B369D36BF36DF36FC361C373E375E377F37A037C237E437043824384438

^.size
