HUDEXTRAS_SUBMENU:
	%menu_header("HUD EXTRAS", 16)

;===================================================================================================
%choice_here("Health display", !config_heart_display, 2)
	%list_item("Numerical")
	%list_item("Vanilla")

;===================================================================================================
%choice_here("Input display", !config_input_display, 4)
	%list_item("Off")
	%list_item("Graphical")
	%list_item("Classic")
	%list_item("Classic Gray")

;===================================================================================================

%sentry_picker(1, !config_sentry1)
%sentry_picker(2, !config_sentry2)
%sentry_picker(3, !config_sentry3)
%sentry_picker(4, !config_sentry4)
%sentry_picker(5, !config_sentry5)

;===================================================================================================

%line_sentry_picker(1, !config_linesentry1)
%line_sentry_picker(2, !config_linesentry2)
%line_sentry_picker(3, !config_linesentry3)
%line_sentry_picker(4, !config_linesentry4)

;===================================================================================================

%toggle_onoff("Hide lines", !config_hide_lines)

%toggle_onoff("HUD spinner", !config_hudlag_spinner)

%toggle_onoff("State icons", !config_state_icons)

%toggle_onoff("Quick warp icon", !config_qw_toggle)

%toggle_onoff("Boss cycles", !config_toggle_boss_cycles)
