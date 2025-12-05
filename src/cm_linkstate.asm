LINKSTATE_SUBMENU:
%menu_header("LINK STATE")

;===================================================================================================

%choice_here("Waterwalk", $005B, 4)
	%list_item("Unarmed")
	%list_item("Armed")
	%list_item("Armed (2)")
	%list_item("Deathholed")

;===================================================================================================

%toggle("Statue drag", $02FA)

%numfield_hex("Ancilla index", $03C4, $00, $7F, 5)

%numfield_hex("Spooky", $02A2, $00, $FF, $10)

;===================================================================================================

%toggle("Armed EG", $047A)

%choice_here("EG strength", $044A, 3)
	%list_item("EG 0")
	%list_item("Strong")
	%list_item("Weak")

;===================================================================================================

%func_filtered("Activate superbunny", this)
	LDA.b $5D
	CMP.b #$17
	BNE StateChangeBeep

	STZ.b $5D
	JML MenuSFX_poof

StateChangeBeep:
	JML MenuSFX_error

;===================================================================================================

%func_filtered("Activate Lonk", this)
	LDA.b $5D
	BNE StateChangeBeep

	LDA.b #$17
	STA.b $5D
	JML MenuSFX_oof

;===================================================================================================

%func_filtered("Finish mirror door", this)
	REP #$20

	LDA.b $10 : CMP.w #$0007 : BEQ .allow
	CMP.w #$010E : BNE StateChangeBeep
	LDA.w $010C : CMP.w #$1A07 : BNE StateChangeBeep

.allow
	LDA.w #$0111 : STA.b $C8

	RTL

;===================================================================================================

%func_filtered("Create portal", this)
	LDA.b $10 : CMP.b #$09 : BNE .no

	LDA.b $8A : CMP.b #$40 : BCS .no

	LDA.b $20 : STA.w $1ADF
	LDA.b $21 : STA.w $1AEF
	LDA.b $22 : STA.w $1ABF
	LDA.b $23 : STA.w $1ACF

	LDA.b #$3A : STA.w $031F

	JML $09AF89

.no
	JMP MenuSFX_error

;===================================================================================================
