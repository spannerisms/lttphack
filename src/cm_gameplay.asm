GAMEPLAY_SUBMENU:
%menu_header("GAMEPLAY")

;===================================================================================================

%toggle_onoff("Skip Triforce", !config_skip_triforce)

%toggle("Disable beams", SA1RAM.disable_beams)

%toggle_onoff("Lit rooms", SA1RAM.light_rooms)

%toggle_onoff("Fast walls", !config_fast_moving_walls)

%toggle_onoff("Visible probes", SA1RAM.visible_probes)

%toggle_onoff("Show STC pits", !config_somaria_pits)

%togglebit0("Disable BG1", SA1RAM.disabled_layers)

%togglebit1("Disable BG2", SA1RAM.disabled_layers)

%toggle_onoff("OoB mode", $037F)

;===================================================================================================
