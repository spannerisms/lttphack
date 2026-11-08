ROOMLOAD_SUBMENU:
%menu_header("ROOM MASTER")

;===================================================================================================

%numfield_hex_update("Set room", BWRAM.loadroom_id, $00, $FF, $10)

;===================================================================================================

%func("Load selected room", this)
	REP #$30
	JSL CM_Exiting
	JML LoadArbitraryRoom

;===================================================================================================

%submenu("Configure loading", ROOMLOADCONFIGURATION_SUBMENU)

;===================================================================================================

%toggle_roomflag("Door 0", 15)
%toggle_roomflag("Door 1", 14)
%toggle_roomflag("Door 2", 13)
%toggle_roomflag("Door 3", 12)

%toggle_roomflag("Boss", 11)
%toggle_roomflag("Key", 10)
%toggle_roomflag("Key 2", 9)
%toggle_roomflag("Rupee floor", 8)

%toggle_roomflag("Chest 0", 4)
%toggle_roomflag("Chest 1", 5)
%toggle_roomflag("Chest 2", 6)
%toggle_roomflag("Chest 3", 7)

%toggle_roomflag("NW quadrant", 3)
%toggle_roomflag("NE quadrant", 2)
%toggle_roomflag("SW quadrant", 1)
%toggle_roomflag("SE quadrant", 0)

;===================================================================================================

ROOMLOADCONFIGURATION_SUBMENU:
%menu_header("ROOM LOAD CONFIGURATION")

%toggle_onoff("Open shutters", BWRAM.loadroom_shutters)

%toggle_onoff("Kill sprites", BWRAM.loadroom_kill)

%choice_here("Peg state", BWRAM.loadroom_pegset, 3)
	%add_list_item(CMTEXT_RED)
	%add_list_item(CMTEXT_BLUE)
	%add_list_item(CMTEXT_CURRENT)

%choice_here("World state", BWRAM.loadroom_worldset, 4)
	%add_list_item(CMTEXT_DEFAULT)
	%add_list_item(CMTEXT_CURRENT)
	%add_list_item(CMTEXT_LIGHTWORLD)
	%add_list_item(CMTEXT_DARKWORLD)

%choice_here("Dungeon ID", BWRAM.loadroom_dungeonset, 18)
	%add_list_item(CMTEXT_DEFAULT)
	%add_list_item(CMTEXT_CURRENT)
	%add_list_item(CMTEXT_SEWERS)
	%list_item("Hyrule")
	%list_item("Eastern")
	%list_item("Desert")
	%list_item("Hera")
	%list_item("Aga Tower")
	%list_item("PoD")
	%list_item("Swamp")
	%list_item("Skull")
	%list_item("Thieves")
	%list_item("Ice")
	%list_item("Mire")
	%list_item("TRock")
	%list_item("GTower")
	%list_item("Caves")
	%list_item("Caves FD")

;===================================================================================================
