;===================================================================================================

if !BUILD?
	!VERSION = "15.0.1"
	!VERSIONTEXT = "v!VERSION"
else
	!VERSION ?= "ALEPH1"
	!VERSIONTEXT = "!VERSION"
endif

!RANDO ?= 0

;===================================================================================================

encoder MenuEncoding = "resources/menuencoding.txt"
encoder FileSelectTop = "resources/fileselecttop.txt"
encoder FileSelectBot = "resources/fileselectbot.txt"

encoder MenuEncoding

;===================================================================================================

org $208000 ; TODO move all these to just always be fastrom
piling ConfigInitTable :: $0400

incsrc "variables.asm"
incsrc "memory.asm"
incsrc "hexedits.asm"

;---------------------------------------------------------------------------------------------------

org jlong($208400)
incsrc "init.asm"
incsrc "sa1main.asm"
incsrc "nmi.asm"
incsrc "timers.asm"
incsrc "gamemode.asm"
incsrc "misc.asm"
incsrc "rng.asm"
incsrc "presets.asm"
incsrc "roomload.asm"
incsrc "linkstuff.asm"

printf "Bank end: {0:A}", !:pc

;---------------------------------------------------------------------------------------------------

org jlong($218000)
incsrc "tiles.asm"

printf "Bank end: {0:A}", !:pc

;---------------------------------------------------------------------------------------------------

org jlong($228000)
incsrc "cm_macros.asm"
incsrc "cm_main.asm"
incsrc "cm_draw.asm"
incsrc "cm_func.asm"
incsrc "cm_items.asm"
incsrc "cm_equipment.asm"
incsrc "cm_gamestate.asm"
incsrc "cm_linkstate.asm"
incsrc "cm_gameplay.asm"
incsrc "cm_rng.asm"
incsrc "cm_hud.asm"
incsrc "cm_roomload.asm"
incsrc "cm_lite_states.asm"
incsrc "cm_shortcuts.asm"
incsrc "cm_config.asm"
incsrc "cm_presetconfig.asm"
incsrc "cm_sentry_picker.asm"
incsrc "hudextras.asm"
incsrc "sentries.asm"

printf "Menu bank end: {0:A}", !:pc

;---------------------------------------------------------------------------------------------------

org jlong($238000)

org jlong($268000)

;===================================================================================================
; GREP FOR "PRESET LIST" WHEN ADDING NEW PRESETS
;===================================================================================================

print
print bar
print bar
print "-- Preset data"
print bar
print bar

macro PresetBank(n)
	print
	print bar
	printf "-- Bank {n} : {0:A}", !:pc
	print bar
endmacro

macro PresetBankEnd(n)
	printf "-- Bank {n} end: {0:A}", !:pc
endmacro

;---------------------------------------------------------------------------------------------------

org jlong($308000)
%PresetBank(1)
incsrc "presets/cm_presets_nmg.asm"
incsrc "presets/cm_presets_100nmg.asm"
incsrc "presets/cm_presets_defeatlanmolas.asm"
incsrc "presets/cm_presets_defeatarmos.asm"
incsrc "presets/cm_presets_defeatmoldorm.asm"
incsrc "presets/cm_presets_defeatagahnim.asm"
incsrc "presets/cm_presets_defeathelmasaur.asm"
incsrc "presets/cm_presets_defeatarrghus.asm"
incsrc "presets/cm_presets_defeatagahnim2.asm"
%PresetBankEnd(1)

;---------------------------------------------------------------------------------------------------

org jlong($318000)
%PresetBank(2)
incsrc "presets/cm_presets_lownmg.asm"
incsrc "presets/cm_presets_lowleg.asm"
incsrc "presets/cm_presets_defeatkholdstare.asm"
incsrc "presets/cm_presets_defeatvitreous.asm"
incsrc "presets/cm_presets_defeattrinexx.asm"
incsrc "presets/cm_presets_defeatmothula.asm"
%PresetBankEnd(2)

;---------------------------------------------------------------------------------------------------

org jlong($328000)
%PresetBank(3)
incsrc "presets/cm_presets_adold.asm"
incsrc "presets/cm_presets_ad2020.asm"
incsrc "presets/cm_presets_anyrmg.asm"
incsrc "presets/cm_presets_reversebossorder.asm"
incsrc "presets/cm_presets_defeatblind.asm"
%PresetBankEnd(3)

;---------------------------------------------------------------------------------------------------

org jlong($338000)
%PresetBank(4)
incsrc "presets/cm_presets_alldungeonsmg.asm"
%PresetBankEnd(4)

;===================================================================================================

print
print bar

org jlong($3E8000)
incsrc "bsod.asm"

;===================================================================================================
