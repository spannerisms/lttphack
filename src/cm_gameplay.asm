GAMEPLAY_SUBMENU:
%menu_header("GAMEPLAY")

;===================================================================================================

%toggle_onoff("Skip Triforce", CONFIG.skip_triforce)

%toggle("Disable beams", BWRAM.disable_beams)

%toggle_onoff("Lit rooms", BWRAM.light_rooms)

%toggle_onoff("Fast walls", CONFIG.fast_moving_walls)

%toggle_onoff("Visible probes", BWRAM.visible_probes)

%toggle_onoff("Show STC pits", CONFIG.somaria_pits)

%togglebit0("Disable BG1", BWRAM.disabled_layers)

%togglebit1("Disable BG2", BWRAM.disabled_layers)

%toggle_onoff("OoB mode", $037F)

;===================================================================================================
