org $0DFEC3
dw !EMPTY, !EMPTY, !EMPTY, !EMPTY, !EMPTY, !EMPTY

FloorIndicator = BWRAM.HUD+$0A2

org $008B71 : LDX.w #BWRAM.HUD
org $008B77 : LDA.b #^BWRAM.HUD

; move floor indicators (not just to iram, but also a different location)
org $0AFDB5 : STA.l FloorIndicator+$0000
org $0AFDB9 : STA.l FloorIndicator+$0040
org $0AFDBD : STA.l FloorIndicator+$0002
org $0AFDC1 : STA.l FloorIndicator+$0042

; move timer locations (not just to iram, but also a different location)
org $0AFE25 : STA.l FloorIndicator+$0000,X
org $0AFE2C : STA.l FloorIndicator+$0040,X

; vanilla stuff to leave alone, so it writes nowhere useful
org $0AFD9F : STA.l FloorIndicator+$0000,X
org $0AFDA6 : STA.l FloorIndicator+$0040,X
org $0AFD48 : STA.l FloorIndicator+$0000
org $0AFD4D : STA.l FloorIndicator+$0042
org $0AFD52 : STA.l FloorIndicator+$0040
org $0AFD59 : STA.l FloorIndicator+$0002

org $0DFA99 : LDY.w #BWRAM.HUD
org $0DFA9C : MVN $0D,$0D

org $0DFB2B : STA.l BWRAM.HUD+$01E
org $0DFB31 : STA.l BWRAM.HUD+$01F
org $0DFB37 : STA.l BWRAM.HUD+$020
org $0DFB3D : STA.l BWRAM.HUD+$021
org $0DFB94 : STA.l BWRAM.HUD+$04A
org $0DFB9C : STA.l BWRAM.HUD+$04C
org $0DFBA4 : STA.l BWRAM.HUD+$08A
org $0DFBAC : STA.l BWRAM.HUD+$08C
org $0DFC3A : STA.l BWRAM.HUD+$004
org $0DFC41 : STA.l BWRAM.HUD+$006
org $0DFC48 : STA.l BWRAM.HUD+$008
org $0DFC5E : STA.l BWRAM.HUD+$046
org $0DFC65 : STA.l BWRAM.HUD+$086
org $0DFC6C : STA.l BWRAM.HUD+$0C6
org $0DFC73 : STA.l BWRAM.HUD+$106
org $0DFC88 : STA.l BWRAM.HUD+$050
org $0DFC94 : STA.l BWRAM.HUD+$052
org $0DFCA0 : STA.l BWRAM.HUD+$054
org $0DFCB8 : STA.l BWRAM.HUD+$058
org $0DFCC4 : STA.l BWRAM.HUD+$05A
org $0DFCDC : STA.l BWRAM.HUD+$05E
org $0DFCE8 : STA.l BWRAM.HUD+$060
org $0DFD0A : STA.l BWRAM.HUD+$064
org $0DFD13 : STA.l BWRAM.HUD+$024
org $0DFD5D : STA.l BWRAM.HUD+$042,X
org $0DFD73 : STA.l BWRAM.HUD+$042,X
org $0DFD7C : STA.l BWRAM.HUD+$044,X
org $0DFD8E : STA.l BWRAM.HUD+$042,X
org $0DFD97 : STA.l BWRAM.HUD+$044,X
org $0DFDA2 : STA.l BWRAM.HUD+$042,X
org $0DFDAB : STA.l BWRAM.HUD+$044,X
org $0DFDB4 : STA.l BWRAM.HUD+$046,X

; HP stuff we leave writing to vanilla WRAM
; org $0DFDC1 : STA.l BWRAM.HUD+$042,X

; tracking stuff related to heart refill, but leaving it alone
;org $0DF151 : LDA.b #<BWRAM.HUD+$068
;org $0DF155 : LDA.b #>BWRAM.HUD+$068
;org $0DF159 : LDA.b #^BWRAM.HUD+$068
;org $0DFBC2 : LDA.b #<BWRAM.HUD+$068
;org $0DFBC6 : LDA.b #>BWRAM.HUD+$068
;org $0DFBCA : LDA.b #^BWRAM.HUD+$068
;org $0DFBEE : LDA.b #<BWRAM.HUD+$068
;org $0DFBF2 : LDA.b #>BWRAM.HUD+$068
;org $0DFBF6 : LDA.b #^BWRAM.HUD+$068

; Heart refill variable is something that doesn't bother me to move
org $07A1A1 : STA.w IRAM.relocated_0208
org $07A1CC : STA.w IRAM.relocated_0208
org $07A202 : STA.w IRAM.relocated_0208
org $08F454 : LDA.w IRAM.relocated_020A
org $09F71A : LDA.w IRAM.relocated_020A
org $0DDCA8 : LDA.w IRAM.relocated_020A
org $0DDCFF : INC.w IRAM.relocated_020A
org $0DDD04 : STA.w IRAM.relocated_0208
org $0DF140 : LDA.w IRAM.relocated_020A
org $0DF15D : DEC.w IRAM.relocated_0208
org $0DF184 : LDX.w IRAM.relocated_0209
org $0DF18B : STA.w IRAM.relocated_0208
org $0DF19E : LDA.w IRAM.relocated_0209
org $0DF1A4 : STA.w IRAM.relocated_0209
org $0DF1AE : STZ.w IRAM.relocated_020A

;===================================================================================================
