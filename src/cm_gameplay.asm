GAMEPLAY_SUBMENU:
%menu_header("GAMEPLAY")

;===================================================================================================

%toggle("Skip Triforce", CONFIG.skip_triforce)

%toggle("Disable beams", BWRAM.disable_beams)

%toggle("Lit rooms", BWRAM.light_rooms)

%toggle("Fast walls", CONFIG.fast_moving_walls)

%toggle("Visible probes", BWRAM.visible_probes)

%toggle("Show STC pits", CONFIG.somaria_pits)

%togglebit0("Disable BG1", BWRAM.disabled_layers)

%togglebit1("Disable BG2", BWRAM.disabled_layers)

%toggle("OoB mode", $037F)

;===================================================================================================
