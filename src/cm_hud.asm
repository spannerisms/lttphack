HUDEXTRAS_SUBMENU:
	%menu_header("HUD EXTRAS")

;===================================================================================================

%choice_here("Health display", CONFIG.heart_display, 2)
	%list_item("Numerical")
	%add_list_item(CMTEXT_VANILLA)

;===================================================================================================

%choice_here("Input display", CONFIG.input_display, 4)
	%list_item("Off")
	%list_item("Graphical")
	%list_item("Classic")
	%list_item("Classic Gray")

;===================================================================================================

%sentry_picker(1, CONFIG.sentry1)
%sentry_picker(2, CONFIG.sentry2)
%sentry_picker(3, CONFIG.sentry3)
%sentry_picker(4, CONFIG.sentry4)
%sentry_picker(5, CONFIG.sentry5)

;===================================================================================================

%line_sentry_picker(1, CONFIG.linesentry1)
%line_sentry_picker(2, CONFIG.linesentry2)
%line_sentry_picker(3, CONFIG.linesentry3)
%line_sentry_picker(4, CONFIG.linesentry4)

;===================================================================================================

%toggle_onoff("Hide lines", CONFIG.hide_lines)

%toggle_onoff("HUD spinner", CONFIG.hudlag_spinner)

%toggle_onoff("State icons", CONFIG.state_icons)

%toggle_onoff("Quick warp icon", CONFIG.qw_toggle)

%toggle_onoff("Boss cycles", CONFIG.boss_cycles)

;===================================================================================================
