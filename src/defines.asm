!SRAM_VERSION = $0033
!INIT_SIGNATURE = $26B9

function hexto555(h) = ((((h&$FF)/8)<<10)|(((h>>8&$FF)/8)<<5)|(((h>>16&$FF)/8)<<0))
function RoomFlags(room) = $7EF000+(room*2)

!white = $3C10
!blue = $2C10
!yellow = $3410
!red = $3810
!gray = $2010

function char(n) = $2150+n

!BROWN_PAL #= (0<<10)
!RED_PAL #= (1<<10)
!YELLOW_PAL #= (2<<10)
!BLUE_PAL #= (3<<10)
!GRAY_PAL #= (4<<10)
!REDYELLOW #= (5<<10)
!TEXT_PAL #= (6<<10)
!GREEN_PAL #= (7<<10)

!VFLIP #= (1<<15)
!HFLIP #= (1<<14)

!P3 = $2000
!SYNCED = char($10)|!BLUE_PAL
!DESYNC = char($11)|!RED_PAL
!HAMMER = char($12)|!BROWN_PAL

!CUSTOM_LOADOUTS #= 8

!LOPOPUPLENGTH #= 10
!LOPOPUPSIZE #= !LOPOPUPLENGTH*2

macro MVN(src, dest) ; why asar
	MVN <dest>, <src>
endmacro

macro MVP(src, dest)
	MVP <dest>, <src>
endmacro


; Magic words
!EMPTY = $207F
!QMARK = $252A
!BLANK_TILE = $24F5

; special stuff

!offset = $407000
!offsetinc = 0
!OFF = 0
!ON = 1


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

SA1SRAM = $400000
LiteStateData = $430000

HUDProxy = $3000
function HUDProxyOffset(x) = $3000+x


org $008000
struct SA1IRAM $003000
	.SHORTCUT_USED: skip 2
	.corruption_watcher: skip 2

	.randomish: skip 2

	.SCRATCH: skip 16

	.CONTROLLER_1:
	.CopyOf_F2: skip 1
	.CopyOf_F0: skip 1

	.CONTROLLER_1_FILTERED:
	.CopyOf_F6: skip 1
	.CopyOf_F4: skip 1

	.CONTROLLER_1_NEW:

	.JOYPAD2_NEW: skip 2

	.CachedThisFrame: skip 1
	.cm_submodule: skip 2
	.cm_cursor: skip 1 ; keep these together
	.cm_current_menu: skip 4
	.cm_current_selection: skip 4
	.cm_current_draw: skip 4
	.cm_action_length: skip 2
	.cm_draw_color: skip 2

	; these can be shared because they're never used at the same time
	.cm_writer:
	.cm_draw_type_offset: skip 2
	.cm_draw_filler: skip 2

	.cm_leftright: skip 1 ; N=left V=right
	.cm_updown: skip 1 ; N=up V=down
	.cm_ax: skip 1 ; N=A V=X
	.cm_y: skip 1 ; 
	.cm_shoulder: skip 1 ; N=l V=r
	skip 1 ; for safety

	.prgtext_jump:
	.cm_writer_args: skip 4

	.preset_addr: skip 3 ; never share memory with this
	.preset_type: skip 2 ; never share memory with this

	.preset_prog: skip 3
	.preset_prog_end: skip 2

	.draw_text_ptr:
	.preset_pert: skip 3
	.preset_pert_end: skip 2

	.sentry_groups_pointer:
	.preset_reader: skip 3

	.sentry_cat_name_pointer: 
	.preset_reader2: skip 3

	.sentry_cat_list_pointer:
	.preset_writer: skip 2

	.sentry_selected_address:
	.preset_scratch: skip 4

	.hud_props: skip 2
	.hud_val: skip 2
	.hud_val2: skip 2

.savethis_start
	.TIMER_FLAG: skip 2
	.TIMER_ADD_INDEX: skip 2
	.TIMER_ADD_SSFF: skip 2
	.TIMER_ADD_SCRATCH: skip 2

.timers_start
	.ROOM_TIME_F: skip 2
	.ROOM_TIME_S: skip 2
	.ROOM_TIME_LAG: skip 2
	.ROOM_TIME_IDLE: skip 2

	.SEG_TIME_F: skip 2
	.SEG_TIME_S: skip 2
	.SEG_TIME_M: skip 2

.timers_end
	.ROOM_TIME_F_DISPLAY: skip 2
	.ROOM_TIME_S_DISPLAY: skip 2
	.ROOM_TIME_LAG_DISPLAY: skip 2
	.ROOM_TIME_IDLE_DISPLAY: skip 2

	.SEG_TIME_F_DISPLAY: skip 2
	.SEG_TIME_S_DISPLAY: skip 2
	.SEG_TIME_M_DISPLAY: skip 2

	.SENTRYTEMP: skip 2

	.SNTVAL1: skip 2
	.SNTVAL2: skip 2
	.SNTVAL3: skip 2
	.SNTVAL4: skip 2
	.SNTVAL5: skip 2

	.SNTADD1: skip 2
	.SNTADD2: skip 2
	.SNTADD3: skip 2
	.SNTADD4: skip 2
	.SNTADD5: skip 2

	.CopyOf_12: skip 1
	.CopyOf_1A: skip 1
	.CopyOf_1B: skip 1
	.CopyOf_20: skip 1
	.CopyOf_21: skip 1
	.CopyOf_22: skip 1
	.CopyOf_23: skip 1

	.CopyOf_57: skip 1
	.CopyOf_5B: skip 1
	.CopyOf_6C: skip 1
	.CopyOf_0372: skip 1

	.CopyOf_A0: skip 1
	.CopyOf_A1: skip 1
	.CopyOf_A4: skip 1
	.CopyOf_E2: skip 1

	.CopyOf_7EF36C: skip 1
	.CopyOf_7EF36D: skip 1

	; extra stuff
	.BossCycles: skip 16 ; 16 to be safe

	; not copied, but just moved in rom
	.Moved_0208: skip 1
	.Moved_0209: skip 1
	.Moved_020A: skip 1

.savethis_end

	.SENTRYICON1: skip 2
	.SENTRYICON2: skip 2
	.SENTRYICON3: skip 2
	.SENTRYICON4: skip 2
	.SENTRYICON5: skip 2

	print ""
	print "SA1 dp: $", pc
	print "Saved: ", dec(.savethis_end-.savethis_start), "/640 (acceptable savestate limit)"

warnpc $003100

org $003100

	; ancilla watch
	.LINEVAL: ; +14 = icon
	.LINE1VAL: skip 16
	.LINE2VAL: skip 16
	.LINE3VAL: skip 16
	.LINE4VAL: skip 16

	.SENTRYVECTOR1: skip 2
	.SENTRYVECTOR2: skip 2
	.SENTRYVECTOR3: skip 2
	.SENTRYVECTOR4: skip 2
	.SENTRYVECTOR5: skip 2

	.LINEVECTOR1: skip 2
	.LINEVECTOR2: skip 2
	.LINEVECTOR3: skip 2
	.LINEVECTOR4: skip 2

	.QuickSwapLR: skip 1

	.litestate_act: skip 2
	.litestate_last: skip 2
	.litestate_off: skip 2

	.HUDSIZE: skip 2
	.highestline: skip 2
	.LoadOutScratch: skip 2


	print "SA1 mirroring: $", pc

	org $003600
	.SA1CorruptionBuffer: skip $180

	warnpc $003800

endstruct

org $400000

struct SA1RAM $402000 ; DO NOT CHANGE THIS



	warnpc $4020FF

	org $402100
	.Loadouts
	.CustomLoadout.slot0: skip $30

	.CustomLoadout.slot1: skip $30*!CUSTOM_LOADOUTS

	org $406000 ; DO NOT CHANGE THIS
	.HUD skip $800 ; bg3 HUD
	.MENU skip $800 ; practice menu

	org $407000 ; DO NOT CHANGE THIS
	.SETTINGS: skip $400

	.hex2dec_tmp: skip 2
	.hex2dec_first_digit: skip 2
	.hex2dec_second_digit: skip 2
	.hex2dec_third_digit: skip 2

	.dec_pref: skip 2
	.dec_count: skip 2
	.dec_out: skip 8

	.old_music: skip 1
	.old_music_bank: skip 1

.clearable_sa1ram:
	skip 2

	.disable_beams: skip 2
	.drop_rng: skip 2
	.loadout_to_save: skip 2
	.loadout_to_use: skip 2

	.visible_probes: skip 2
	.light_rooms: skip 2

	.pokey_rng: skip 2
	.agahnim_rng: skip 2
	.helmasaur_rng: skip 2
	.ganon_warp_location_rng: skip 2
	.ganon_warp_rng: skip 2
	.eyegore_rng: skip 2
	.arrghus_rng: skip 2
	.turtles_rng: skip 2
	.framerule: skip 2
	.lanmola_rng: skip 2
	.conveyor_rng: skip 2
	.vitreous_rng: skip 2
	.ganon_bats: skip 2

	.CM_SubMenuIndex: skip 2
	.CM_SubMenuStack: skip 40

	.loadroomid: skip 2
	.loadroomshutters: skip 2
	.loadroomkill: skip 2
	.loadroompegset: skip 2
	.loadroomdungeonset: skip 2
	.loadroomworldset: skip 2
	.loadroomequip: skip 2
	.loadroomdungeon: skip 1
	.loadroompegstate: skip 1
	.loadroomeg: skip 1

	.disabled_layers: skip 2
	.layer_writer: skip 2

	.highestline: skip 2

	.sentry_submodule: skip 2
	.sentry_type: skip 2
	.sentry_category_size: skip 2
	.sentry_id: skip 2
	.sentry_index: skip 2
	.sentry_category: skip 2
	.sentry_category_index: skip 2
	.sentry_item: skip 2

.end_of_clearable_sa1ram:

	.cm_input_timer: skip 2
	.cm_last_input: skip 2

	.extra_sa1_required: skip 2
	.cm_item_bow: skip 1
	.cm_equipment_maxhp: skip 1

	.EasyJMP: skip 2

	.LiteStateDupeOffset: skip 2

	.ArbitraryMVN: skip 4


	.MessageHighScratch: skip 2


	.NMIBonusVector: skip 2

	.LoadoutPopupVRAM: skip 2
	.LoadoutPopupDraw: skip $100



	print "end of sa1 vars: ", pc

	warnpc $407BFF

	org $407C00 ; DO NOT CHANGE THIS

	.coords2: skip 4
	.gamemode2: skip 2
	.world2: skip 2
	.equipment2: skip $30


	warnpc $407FFF
endstruct

;===================================================================================================

macro def_sram(name, default)
	!config_<name> #= !offset+!offsetinc
	!newval := "dw !config_<name>, <default>"

	if defined("PERM_INIT")
		!PERM_INIT := "!PERM_INIT : !newval"
	else
		!PERM_INIT := "!newval"
	endif

	!offsetinc #= !offsetinc+2
	!last_config #= !offsetinc
endmacro

;===================================================================================================

%def_sram("sram_initialized", !SRAM_VERSION)

; permanent SRAM that doesn't reinit across versions
%def_sram("init_sig", !INIT_SIGNATURE)

%def_sram("cm_save_place", 0)

%def_sram("ctrl_load_last_preset", $A020)
%def_sram("ctrl_unused", $0000)
%def_sram("ctrl_save_state", $6010)
%def_sram("ctrl_load_state", $6020)

%def_sram("ctrl_toggle_oob", !OFF)
%def_sram("ctrl_skip_text", !OFF)
%def_sram("ctrl_disable_sprites", !OFF)
%def_sram("ctrl_reset_segment_timer", !OFF)

%def_sram("ctrl_toggle_switch", !OFF)
%def_sram("ctrl_fill_everything", !OFF)
%def_sram("ctrl_fix_vram", !OFF)
%def_sram("ctrl_somaria_pits", !OFF)

%def_sram("preset_category", $0000)

%def_sram("hud_font", 0)

%def_sram("input_display", 1)
%def_sram("heart_display", 0)
%def_sram("feature_music", !ON)

%def_sram("rerandomize", !ON)

%def_sram("hide_lines", !OFF)

%def_sram("qw_toggle", !ON)
%def_sram("hudlag_spinner", !OFF)
%def_sram("boss_cycles", !ON)

%def_sram("skip_triforce", !OFF)
%def_sram("fast_moving_walls", !ON)
%def_sram("somaria_pits", !OFF)

%def_sram("fastrom", !OFF)
%def_sram("vanillaitems", !OFF)


%def_sram("hud_bg", 0)
%def_sram("hud_header_fg", 1)
%def_sram("hud_header_hl", 0)
%def_sram("hud_header_bg", 10)
%def_sram("hud_sel_fg", 8)
%def_sram("hud_sel_bg", 9)
%def_sram("hud_dis_fg", 3)

%def_sram("death_reload", !OFF)
; EVERYTHING ABOVE HERE SHOULD BE CONSIDERED RELATIVELY STABLE AND NOT MOVED

%def_sram("state_icons", !OFF)

%def_sram("sentry1", SENTRY_ROOMTIME)
%def_sram("sentry2", SENTRY_LAGFRAMES)
%def_sram("sentry3", SENTRY_IDLEFRAMES)
%def_sram("sentry4", SENTRY_OFF)
%def_sram("sentry5", SENTRY_COORDINATES)

%def_sram("linesentry1", !OFF)
%def_sram("linesentry2", !OFF)
%def_sram("linesentry3", !OFF)
%def_sram("linesentry4", !OFF)

%def_sram("safeties_nmg_sanc_heart", !OFF)
%def_sram("safeties_nmg_powder", !OFF)
%def_sram("safeties_nmg_gs", !OFF)
%def_sram("safeties_nmg_bottles", !OFF)
%def_sram("safeties_nmg_red_mail", !OFF)

%def_sram("safeties_100nmg_trinexx_boom", !OFF)

%def_sram("safeties_ad2020_silvers", !OFF)

%def_sram("safeties_adold_silvers", !OFF)

%def_sram("safeties_anyrmg_hook", !OFF)

print ""
print "Config end: $", hex(!last_config,3)

if !last_config > $3FF
	error "Too many config settings!"
endif

;===================================================================================================
