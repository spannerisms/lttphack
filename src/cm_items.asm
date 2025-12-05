ITEMS_SUBMENU:
%menu_header("ITEMS")

;===================================================================================================

%choice_func_here("Bow", SA1RAM.cm_item_bow, 3, cm_set_bow)
	%add_list_item(CMTEXT_NO)
	%list_item("Normal")
	%list_item("Silver")

cm_set_bow:
	LDA.w SA1RAM.cm_item_bow
	ASL
	BEQ .set

	TAX

	LDA.l $7EF377
	BNE .have_arrows

	DEX

.have_arrows
	TXA

.set
	STA.l $7EF340

	RTL

;===================================================================================================

%choice_here("Boomerang", $7EF341, 3)
	%add_list_item(CMTEXT_NO)
	%add_list_item(CMTEXT_BLUE)
	%add_list_item(CMTEXT_RED)

;===================================================================================================

%toggle("Hookshot", $7EF342)

;===================================================================================================

BOMBS_SETTER:
%numfield_capacity("Bombs", $7EF343)

;===================================================================================================

%choice_here("Powder", $7EF344, 3) : %ReusableText(CMTEXT_POWDER)
	%add_list_item(CMTEXT_NO)
	%list_item("Mushroom") : %ReusableText(CMTEXT_MUSHROOM)
	%add_list_item(CMTEXT_POWDER)

;===================================================================================================

%toggle("Fire rod", $7EF345)
%toggle("Ice rod", $7EF346)
%toggle("Bombos", $7EF347)
%toggle("Ether", $7EF348)
%toggle("Quake", $7EF349)
%toggle("Lamp", $7EF34A)
%toggle("Hammer", $7EF34B)

;===================================================================================================

%choice_here("Flute", $7EF34C, 4) : %ReusableText(CMTEXT_FLUTE)
	%add_list_item(CMTEXT_NO)
	%list_item("Shovel")
	%list_item("Flute (off)")
	%add_list_item(CMTEXT_FLUTE)

;===================================================================================================

%toggle("Net", $7EF34D)
%toggle("Book", $7EF34E)

;===================================================================================================

%choice("Bottle 1", $7EF35C, 9, bottle_items)
%choice("Bottle 2", $7EF35D, 9, bottle_items)
%choice("Bottle 3", $7EF35E, 9, bottle_items)
%choice("Bottle 4", $7EF35F, 9, bottle_items)

;===================================================================================================

%toggle("Somaria", $7EF350)
%toggle("Byrna", $7EF351)
%toggle("Cape", $7EF352)
%togglebit1("Mirror", $7EF353) : %ReusableText(CMTEXT_MIRROR)

;===================================================================================================

bottle_items:
%list_header(9)
	%add_list_item(CMTEXT_NO)
	%add_list_item(CMTEXT_MUSHROOM)
	%list_item("Empty")
	%add_list_item(CMTEXT_RED)
	%add_list_item(CMTEXT_GREEN)
	%add_list_item(CMTEXT_BLUE)
	%add_list_item(CMTEXT_FAIRY)
	%list_item("Bee")
	%list_item("Golden bee")

;===================================================================================================
