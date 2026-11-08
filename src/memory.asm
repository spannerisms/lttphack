;===================================================================================================
; Memory map:
; Bank 40:
;    $0000..$1FFF - vanilla SRAM
;    $2000..$20FF - meta data
;    $2100..$24FF - custom loadout
;    $2500..$5FFF - unused
;    $6000..$7FFF - mirrored to page $60 for SNES
;    $8000..$FFFF - self modifying code
; Bank 41: savestates
; Bank 42: savestates vram
; Bank 43:
;    $0000..$7FFF - Lite States
;    $8000..$BFFF - unused
;    $C000..$FFFF - Save States
;===================================================================================================

GameSaveData = $400000
SaveStateData = $410000
SaveStateVram = $420000

HUDProxy = $3000
function HUDProxyOffset(x) => HUDProxy+{x}

allocate $003000 :: $0100
IRAM:
	.shortcut_used      :: 2
	.corruption_watcher :: 2
	.randomish          :: 2
	.SCRATCH            :: 16

	.joy1
	.copyof_F2 :: 1
	.copyof_F0 :: 1

	.joy1_filtered
	.copyof_F6 :: 1
	.copyof_F4 :: 1

	.joy2_new :: 2

	.cached_this_frame    :: 1
	.cm_submodule         :: 2
	.cm_cursor            :: 1 ; keep these together
	.cm_current_menu      :: 4
	.cm_current_selection :: 4
	.cm_current_draw      :: 4
	.cm_action_length     :: 2
	.cm_draw_color        :: 2

	.cm_writer ; these can be shared because they're never used at the same time
	.cm_draw_type_offset :: 2
	.cm_draw_filler      :: 2

	.cm_leftright        :: 1 ; N=left V=right
	.cm_updown           :: 1 ; N=up V=down
	.cm_ax               :: 1 ; N=A V=X
	.cm_y                :: 1 ; 
	.cm_shoulder         :: 1 ; N=l V=r
	skip 1 ; for safety

	.prgtext_jump
	.cm_writer_args :: 4

	.preset_addr :: 3 ; never share memory with this
	.preset_type :: 2 ; never share memory with this
	.preset_pert :: 3 ; never share memory with this
	.preset_prog :: 3 ; never share memory with this

	.draw_text_ptr
	.preset_pert_end :: 2
	.preset_prog_end :: 2

	.sentry_groups_pointer
	.preset_reader :: 3

	.sentry_cat_name_pointer
	.preset_reader2 :: 3

	.sentry_cat_list_pointer
	.preset_writer :: 2

	.sentry_selected_address
	.preset_scratch :: 4

	.hud_props :: 2
	.hud_val   :: 2
	.hud_val2  :: 2

.savethis_start
	.TIMER_FLAG        :: 2
	.TIMER_ADD_INDEX   :: 2
	.TIMER_ADD_SSFF    :: 2
	.TIMER_ADD_SCRATCH :: 2

.timers_start
	.ROOM_TIME_F    :: 2
	.ROOM_TIME_S    :: 2
	.ROOM_TIME_LAG  :: 2
	.ROOM_TIME_IDLE :: 2

	.SEG_TIME_F :: 2
	.SEG_TIME_S :: 2
	.SEG_TIME_M :: 2

.timers_end
	.ROOM_TIME_F_DISPLAY    :: 2
	.ROOM_TIME_S_DISPLAY    :: 2
	.ROOM_TIME_LAG_DISPLAY  :: 2
	.ROOM_TIME_IDLE_DISPLAY :: 2

	.SEG_TIME_F_DISPLAY :: 2
	.SEG_TIME_S_DISPLAY :: 2
	.SEG_TIME_M_DISPLAY :: 2

	.sentry_temp :: 2

	.sentry_value_1 :: 2
	.sentry_value_2 :: 2
	.sentry_value_3 :: 2
	.sentry_value_4 :: 2
	.sentry_value_5 :: 2

	.sentry_address_1 :: 2
	.sentry_address_2 :: 2
	.sentry_address_3 :: 2
	.sentry_address_4 :: 2
	.sentry_address_5 :: 2

	.copyof_12 :: 1
	.copyof_1A :: 1
	.copyof_1B :: 1
	.copyof_20 :: 1
	.copyof_21 :: 1
	.copyof_22 :: 1
	.copyof_23 :: 1

	.copyof_57 :: 1
	.copyof_5B :: 1
	.copyof_6C :: 1
	.copyof_0372 :: 1

	.copyof_A0 :: 1
	.copyof_A1 :: 1
	.copyof_A4 :: 1
	.copyof_E2 :: 1

	.copyof_7EF36C :: 1
	.copyof_7EF36D :: 1

	; extra stuff
	.boss_cycles :: 16 ; 16 to be safe

	; not copied, but just moved in rom
	.relocated_0208 :: 1
	.relocated_0209 :: 1
	.relocated_020A :: 1

.savethis_end ; TODO should this save icons?
	.sentry_icon1 :: 2
	.sentry_icon2 :: 2
	.sentry_icon3 :: 2
	.sentry_icon4 :: 2
	.sentry_icon5 :: 2

SavedVarsSize = .savethis_end-.savethis_start
	print
	printf "SA1 dp end: ${0:X4}", !:here
	printf "Saved: {0}/640 (acceptable savestate limit)", SavedVarsSize

;---------------------------------------------------------------------------------------------------

allocate * :: $0400

	; ancilla watch
	.line_args ; +14 = icon
	..1 :: 16
	..2 :: 16
	..3 :: 16
	..4 :: 16

	.sentry_vector1 :: 2
	.sentry_vector2 :: 2
	.sentry_vector3 :: 2
	.sentry_vector4 :: 2
	.sentry_vector5 :: 2

	.line_vector1 :: 2
	.line_vector2 :: 2
	.line_vector3 :: 2
	.line_vector4 :: 2

	.quickswap_lr :: 1

	.litestate_act :: 2
	.litestate_last :: 2
	.litestate_off :: 2

	.hud_size :: 2
	.highestline :: 2
	.loudout_scratch :: 2

	printf "SA1 mirroring: ${0:X4}", !:here

;---------------------------------------------------------------------------------------------------

; TODO SWAP THE LOCATION OF THESE

allocate * :: $0100
	.spin_ram


allocate * :: $0200
	.corruption_defense :: $180

endallocate

;===================================================================================================
;===================================================================================================
;===================================================================================================

allocate $400000 :: $02000
BWRAM:

allocate $402000 :: $0100 ; DO NOT CHANGE THIS

allocate * :: $4000
	.loadouts
	..slot0 :: $30
	..slot1 :: $30*!CUSTOM_LOADOUTS

;===================================================================================================

allocate $406000 :: $1000 ; DO NOT CHANGE THIS
	.HUD :: $800 ; bg3 HUD
	.MENU :: $800 ; practice menu

;===================================================================================================

allocate $407000 :: $0C00 ; DO NOT CHANGE THIS
	.SETTINGS :: $400

	.hex2dec_tmp :: 8

	.dec_pref :: 2
	.dec_count :: 2
	.dec_out :: 8

	.old_music      :: 1
	.old_music_bank :: 1

.clearable_sa1ram
	skip 2

	.disable_beams   :: 2
	.drop_rng        :: 2
	.loadout_to_save :: 2
	.loadout_to_use  :: 2

	.visible_probes  :: 2
	.light_rooms     :: 2

	.map16cacheindex :: 2

	.pokey_rng        :: 2
	.agahnim_rng      :: 2
	.helmasaur_rng    :: 2
	.ganon_warpto_rng :: 2
	.ganon_warp_rng   :: 2
	.eyegore_rng      :: 2
	.arrghus_rng      :: 2
	.turtles_rng      :: 2
	.framerule        :: 2
	.lanmola_rng      :: 2
	.conveyor_rng     :: 2
	.vitreous_rng     :: 2
	.ganon_bats       :: 2

	.submenu_index :: 2
	.submenu_stack :: 40

	.loadroom_id         :: 2
	.loadroom_shutters   :: 2
	.loadroom_kill       :: 2
	.loadroom_pegset     :: 2
	.loadroom_dungeonset :: 2
	.loadroom_worldset   :: 2
	.loadroom_equip      :: 2
	.loadroom_dungeon    :: 1
	.loadroom_pegstate   :: 1
	.loadroom_eg         :: 1

	.disabled_layers :: 2
	.layer_writer    :: 2

	.highestline :: 2

	.sentry_submodule      :: 2
	.sentry_type           :: 2
	.sentry_category_size  :: 2
	.sentry_id             :: 2
	.sentry_index          :: 2
	.sentry_category       :: 2
	.sentry_category_index :: 2
	.sentry_item           :: 2

ClearableSRAMSize = !:here-.clearable_sa1ram

	.cm_input_timer :: 2
	.cm_last_input  :: 2

	.extra_sa1_required :: 2
	.cm_item_bow        :: 1
	.cm_equipment_maxhp :: 1

	.fast_jmp :: 2

	.litestate_offset_copy :: 2

	.arbitrary_mvn :: 4

	.message_high_scratch :: 2

	.nmi_bonus_vector :: 2

	.loadout_popup_vram   :: 2
	.loadout_popup_canvas :: $100

	printf "End of BWRAM: {0:A}", !:here

;===================================================================================================

allocate $407C00 :: $0400 ; DO NOT CHANGE THIS
.mfn_cache
	..coords          :: 4
	..gamemode        :: 2
	..world           :: 2
	..equipment       :: $30

endallocate

;===================================================================================================

macro def_config(name, default)
	CONFIG.{name} :: 2

	pile ConfigInitTable :: dw CONFIG.{name}, {default}
endmacro

!OFF = 0
!ON = 1

;===================================================================================================

allocate $407000 :: $400

CONFIG:
%def_config("sram_initialized", !SRAM_VERSION)

; permanent config that doesn't reinit across versions
%def_config("init_sig", !INIT_SIGNATURE)

%def_config("cm_save_place", 0)

%def_config("ctrl_load_last_preset", $A020)
%def_config("ctrl_unused", $0000)
%def_config("ctrl_save_state", $6010)
%def_config("ctrl_load_state", $6020)

%def_config("ctrl_toggle_oob", !OFF)
%def_config("ctrl_skip_text", !OFF)
%def_config("ctrl_disable_sprites", !OFF)
%def_config("ctrl_reset_segment_timer", !OFF)

%def_config("ctrl_toggle_switch", !OFF)
%def_config("ctrl_fill_everything", !OFF)
%def_config("ctrl_fix_vram", !OFF)
%def_config("ctrl_somaria_pits", !OFF)

%def_config("preset_category", $0000)

%def_config("hud_font", 0)

%def_config("input_display", 1)
%def_config("heart_display", 0)
%def_config("feature_music", !ON)

%def_config("rerandomize", !ON)

%def_config("hide_lines", !OFF)

%def_config("qw_toggle", !ON)
%def_config("hudlag_spinner", !OFF)
%def_config("boss_cycles", !ON)

%def_config("skip_triforce", !OFF)
%def_config("fast_moving_walls", !ON)
%def_config("somaria_pits", !OFF)

%def_config("fastrom", !OFF)
%def_config("vanillaitems", !OFF)


%def_config("hud_bg", 0)
%def_config("hud_header_fg", 1)
%def_config("hud_header_hl", 0)
%def_config("hud_header_bg", 10)
%def_config("hud_sel_fg", 8)
%def_config("hud_sel_bg", 9)
%def_config("hud_dis_fg", 3)

%def_config("death_reload", !OFF)
; EVERYTHING ABOVE HERE SHOULD BE CONSIDERED RELATIVELY STABLE AND NOT MOVED

%def_config("state_icons", !OFF)

%def_config("sentry1", SENTRY_ROOMTIME)
%def_config("sentry2", SENTRY_LAGFRAMES)
%def_config("sentry3", SENTRY_IDLEFRAMES)
%def_config("sentry4", SENTRY_OFF)
%def_config("sentry5", SENTRY_COORDINATES)

%def_config("linesentry1", !OFF)
%def_config("linesentry2", !OFF)
%def_config("linesentry3", !OFF)
%def_config("linesentry4", !OFF)

%def_config("safeties_nmg_sanc_heart", !OFF)
%def_config("safeties_nmg_powder", !OFF)
%def_config("safeties_nmg_gs", !OFF)
%def_config("safeties_nmg_bottles", !OFF)
%def_config("safeties_nmg_red_mail", !OFF)

%def_config("safeties_100nmg_trinexx_boom", !OFF)

%def_config("safeties_ad2020_silvers", !OFF)

%def_config("safeties_adold_silvers", !OFF)

%def_config("safeties_anyrmg_hook", !OFF)

!config_size = !:here-CONFIG

endallocate

;===================================================================================================

pile ConfigInitTable :: dw $0000 ; sentinel value

print
printf "Config size: ${0:X3}", !config_size

if !config_size > $3FF
	error "Too many config settings!"
endif

;===================================================================================================

allocate $430000 :: $8000
LiteStateData:
	.header        :: $10
	.save_data     :: $0402
	.state_data
	.copyof_1B     :: 1
	.copyofA0      :: 4
	.copyof8A      :: 4


allocate * :: $4000


allocate * :: $4000

SaveStateExtra:


endallocate

