; change small magic to E
org $0984DB : db $24
org $08C4F1 : LDA.l $7EF373
org $00D50D : dw $0A3A-2 ; A3A

; Hijack item receipt
org $098605
PHX ; move the PHX since we're gonna use X too
JSL CheckItemReceipt

org $05F08F+1 : db #$00 ; no heart pieces
org $0DEDF1+1 : db #$00 ; no heart pieces
org $05F095 : NOP : NOP

org $05EFC8 : db $00 ; fix grabbing hearts

;===================================================================================================

; no magic message
org $07B0C2 : CLC : RTS

;===================================================================================================

; Re-enter castle after aga
org $1BBC99 : db $00

;===================================================================================================

; Move mantle after rain state is over
org $068841 : JSL MantlePrep : RTS

;===================================================================================================

; No maidens
org $1E8B97 : dw $CF35
org $02970B : dw $9721
org $02970D : dw $97E9
org $1ECDDD : db $9C ; STZ

;===================================================================================================

; hammerable ganon
org $06F2EE : db $D8

;===================================================================================================
; Quick swap
; DISGUSTING
;===================================================================================================
org $0287FB : JSL QuickSwap
org $02A451 : JSL QuickSwap

;===================================================================================================
; Remove bottle submenu
;===================================================================================================
org $0DDF9A : JSL BottleMenuButtonPress : NOP
org $0DDE3D : db $80 ; BRA
org $0DDE9D : db $80 ; BRA


;===================================================================================================

; No dying priest
org $05DD04 : dw $05DDE5









;===================================================================================================
; Text fixes
;===================================================================================================
; TODO remove escape cutscene
; no text for items
org $08C5D5 : db $80 ; BRA
org $08C5EB : db $80 ; BRA

;; don't decompress attract graphics all the time
;org $0EEE58 : db $08
;
;; TODO change Y to FF for messages that get skipped and write something for that
;
;; hijack other message routines to check for validity
;org $0582C5 : JSL NoMessageRTL ; arrow game
;org $059A7D : JSL NoMessageRTL ; King Zora
;org $05DD83 : JSL NoMessageNPC ; priest
;org $05DDAB : JSL NoMessageNPC ; priest
;org $05DDD0 : LDY.b #$80 ; priest
;org $05DDE2 : db $80 ; priest
;org $05DDE3 : db $80 ; priest
;org $05DDE4 : db $80 ; priest
;org $05DE6A : JSL NoMessageNPC ; zelda telepathy
;org $05DF32 : LDY.b #$80 ; uncle
;org $05E4FB : JSL NoMessageNPC ; witch
;org $05EAE3 : LDY.b #$80 ; bottle vendor
;org $05EAED : JMP.w $05EAF2 ; bottle vendor - always accept
;org $05EB03 : JSL NoMessageNPC ; bottle vendor
;org $05EB0F : JSL NoMessageNPC ; bottle vendor
;org $05EB49 : JSL NoMessageNPC ; bottle vendor
;org $05EB55 : JSL NoMessageNPC ; bottle vendor
;org $05EDC8 : JSL NoMessageNPC ; zelda sanc ; TODO verify this works
;org $05EE09 : db $80 ; zelda sanc
;org $05EE0A : db $80 ; zelda sanc
;org $05EE0B : db $80 ; zelda sanc
;org $05F0BC : JSL NoMessageNPC ; heart pieces
;org $05F15E : db $80 ; sasha boots
;org $05F15F : db $80 ; sasha boots
;org $05F19E : JMP.w $05F1A4 ; just always give ice rod message
;org $05F1ED : JSL NoMessageNPC ; sasha
;org $05F212 : JSL NoMessageNPC ; sasha
;org $05F3BF : JSL MessageWithTest ; bombos
;org $05F429 : JSL MessageWithTest ; ether
;org $05F6A4 : LDY.b #$80 ; potion
;org $05F741 : LDY.b #$80 ; potion
;org $05F7E6 : LDY.b #$80 ; potion
;org $05F8E5 : LDY.b #$80 ; potion shop
;org $05F8F3 : LDY.b #$80 ; potion shop
;org $05FB70 : JSL NoMessageNPC ; magic bat
;org $05FBC2 : JSL NoMessageNPC ; magic bat
;org $068475 : JSL NoMessageNPC ; agahnim
;org $06B2A8 : LDY.b #$80 ; frog
;org $06B9C6 : JSL NoMessageNPC ; sick kid
;org $06B9E9 : JSL NoMessageNPC ; sick kid
;org $06BD4E : JMP.w $06BD53 ; lock smith always run
;org $06BD5D : JSL NoMessageNPC ; lock smith
;org $06BE5F : JSL NoMessageNPC ; hobo
;org $06CFDF : JSL NoMessageNPC ; fairy
;org $06CFEC : JMP.w $06CFEC ; fairy
;org $0DCB77 : LDY.b #$80 ; racing lady
;org $1D82B8 : STA.w $1CF1 ; flopping fish
;org $1DD299 : JSL NoMessageNPC ; cutscene agahnim
;org $1DD35E : JSL NoMessageNPC ; cutscene agahnim
;org $1DE122 : JSL NoMessageNPC ; catfish
;org $1DFC74 : LDY.b #$81 ; dig game guy
;org $1DFC89 : JMP.w $1DFC8E ; dig game guy
;org $1DFCA6 : JSL NoMessageNPC ; dig game guy
;org $1ED467 : JSL NoMessageNPC ; agahnim
;org $1ED467 : JSL NoMessageNPC ; agahnim
;org $1ED4FF : JSL NoMessageNPC ; agahnim
;org $1EDD79 : JSL NoMessageNPC ; bee
;org $1EDF16 : JSL NoMessageNPC ; bee
;org $1EE0E5 : LDY.b #$81 ; purple chest
;org $1EE1C0 : JSL NoMessageNPC ; bombs
;org $1EE208 : JSL NoMessageNPC ; big bomb
;org $1EE3E6 : JSL NoMessageNPC ; kiki
;org $1EE3EE : JMP.w $1EE3F3 ; kiki
;org $1EE400 : JSL NoMessageNPC ; kiki
;org $1EE414 : JSL NoMessageNPC ; kiki
;org $1EE4FB : JSL NoMessageNPC ; kiki
;org $1EE50C : JSL NoMessageNPC ; kiki
;org $1EE523 : JSL NoMessageNPC ; kiki
;org $1EE8CB : LDY.b #$81 ; blind maiden
;org $1EE9BC : LDY.b #$81 ; old man bank 09 messages
;org $1EEF7C : JSL NoMessageNPC ; shopkeeper
;org $1EEFBD : LDY.b #$81 ; chest guy
;org $1EEFC9 : JMP.w $1EEFCE ; chest game
;org $1EEFE0 : JSL NoMessageNPC ; chest game
;org $1EF045 : LDY.b #$81 ; nice thief
;org $1EF09C : LDY.b #$81 ; chest guy
;org $1EF0A6 : JMP.w $1EF0AB ; chest game
;org $1EF0BD : JSL NoMessageNPC ; chest game
;org $1EF108 : LDY.b #$81 ; chest guy
;org $1EF114 : JMP.w $1EF119 ; chest game
;org $1EF12B : JSL NoMessageNPC ; chest game
;org $1EF375 : JSL NoMessageNPC ; shop items
;
;; TODO stumpy and smiths and locksmith
;
;
;
;; TODO verify sanc cutscene removal is fine
;org $05DDA7
;	LDA.b #$03
;	STA.w $0D80,X
;	STZ.w $02E4
;	RTS
;
;org $05ECDF
;	LDA.b #$04
;	STA.w $0D80,X
;	JMP.w $05ED16
;
;org $05ED63
;	RTS
;
;
;; Medallions
;org $05F349 : db $81
;org $05F34D : db $81
;
;org $1EE03D : db $80 ; desert tablet
;org $1EE0D2 : JSL MessageWithTest ; desert tablet
;
;
;org $05E1AA : JSR FixMessageTest ; solicited
;org $05E1DD : JSL MaybeNoMessage ; solicited
;
;org $05E1F3 : JSR FixMessageTest ; on contact
;org $05E208 : JSL MaybeNoMessage ; on contact
;
;
;org $05E052 ; unreachable code
;FixMessageTest:
;	STY.w SA1RAM.MessageHighScratch
;
;	TYA
;	AND.b #$7F
;	STA.w $1CF1
;
;	RTS
;
;;===================================================================================================
;
;NoMessageNPC:
;	STA.w $1CF0
;	TYA
;	AND.b #$7F
;	STA.w $1CF1
;
;	STZ.w $1CE8
;
;	RTL
;
;;===================================================================================================
;
;MaybeNoMessage:
;	BIT.w SA1RAM.MessageHighScratch
;	BPL .show
;
;	STZ.w $1CE8
;
;#NoMessageRTL:
;	RTL
;
;#MessageWithTest:
;	CPY.b #$80
;	BCS NoMessageNPC
;
;.show
;	JML $85E219
;
;warnpc $85E0FE


;muffins notes:
;Ok did a bunch of testing. Coords and equip work great. Can I request 1 more bit after module 🥹, for the world ($0FFF)? 
;
;New lag indicator spinner is awesome btw.
;
;As for text, I went through the list, I wasn't 100% sure on some of them, like bee, flopping fish, old man 09, shopkeepers, fairy's, but the rest I noted down.
;
;* Arrow game still has text in rando, none in PH (I think? - I need to check later/tomorrow)
;* Zora good
;
;* Zelda is too high up in her cell, almost in the wall, but activates at the normal location
;* Can't push the mantle with Zelda if starting from a preset where you don't have her (Ball 'n Chains and earlier)
;* Zelda still talks during escape (HC Lobby, Mantle, Entering first water room, entering rat levers room)
;
;* Witch good
;* The bottle vendor triggers as soon as he is on screen and you have >=100 rupees
;* Heart pieces good
;* Saha good
;* Bombos and Ether text are still there, and after getting the item, Link does the sword spin fanfare like after getting a crystal and the game goes black
;* Potion shop good
;* Magic bat good - doesn't give an item, but does trigger 1/2 magic (I think this is expected?)
;* Aga good
;* Frog good
;* Sick kid good
;* Lock smith still has text
;* Hobo good
;* Racing lady good
;* Catfish still has a text box
;* Kiki good
;* Blind maiden good
;* Chest game good
;* Dig game good
;* Smiths still have a buch of text on rescue + hand in
;* Stumpy still has text and never fades away
;
;I also noticed the following:
;
;* Changing sword via equipment menu corrupts the sword sprite
;* Sword beams don't work?"
;* Once I saw some hud corruption below the coords sentry, but it was once and I couldn't reproduce. They were like red triangles




