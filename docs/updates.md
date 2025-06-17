---
layout: practicehack
title: Change log - ALTTP Practice Hack
---

## Latest update

### [v14.4.0](https://github.com/spannerisms/lttphack/releases/tag/14.4.0) &mdash; 16 June 2025

**This version has breaking changes with the save file. Older versions' saves will be deleted automatically. If you have problems loading the hack, try holding START+SELECT on boot.**

- Presets:
  - The NMG Firesnakes preset item has been changed from boomerang to bow. Just kidding. It was changed to hookshot.
  - Removed ice rod from the Mire shopping preset.
  - Adjusted where NMG spooky values are set to better align with the actual run.
- Equipment:
  - "Fill rupees" has been replaced with a "Rupees" numfield. (I hope this didn't break everything else)
- HUD extras:
  - Made the SA1 draw to the HUD earlier and vastly optimized some of it. Hopefully nothing is messed up.
  - Complete overhaul of sentry pickers into submenus for easier navigation and better organization.
  - Removed the per-line ancilla properties in favor of the more navigable menus.
  - The sentries documentation has been moved to a new page: <a href="sentries">/sentries</a>.
  - Moved the floor indicator a little further left so that it can be handled by vanilla code entirely.
- Bug fixes:
  - Crystal Maiden lag
  - Fixed a miscalculation with a line sentry no one uses
  - OW Lite States should no longer break entrances
  - Changed fast walls compensation a little more just to preempt possible issues
- Configuration:
  - Reworded the Music options to be more direct.
- Other:
  - This page is now markdown for my sanity.
  - Did some menu cleanup. Tell me if anything is screwy.
  - "Rerandomize" now uses a new source of random numbers, just for fun.
  - <span class="snesButton snesA">A</span> can no longer be used to advance lists in the menu. It's kind of unintuitive, less dynamic than the d-pad, and I might have future plans for special types of lists that will utilize this button.
  - Added some memory caching for FXPak visibility to $7C00 in BWRAM.

----

## Older updates

----

### [v14.3.5](https://github.com/spannerisms/lttphack/releases/tag/14.3.5) &mdash; 19 October 2024

- Presets:
  - Added a "Late powder" option for NMG that gives powder at catfish.
  - Added 100 rupees to bottles safeties.
  - Fixed boomerang chest always being flagged with the NMG Hundo safety.
- Equipment:
  - Sword FF now says "turned in".
- HUD extras:
  - Added a live timer option for room time and lag frames.
  - Fixed vanilla hearts (hopefully)
- Configuration:
  - "Vanilla items" (rando only)
- Other:
  - Redid the lag compensation calculations and changed the code a bit. Lag should be closer than ever before. There should also be no more risk of crashing old consoles from the HDMA bug.
  - Fixed extra phantom second from moving walls (I think). (Better timer code)
  - Timers now update upon opening a key door or performing a hop.
  - Fixed stagnant room flags on preset load.
  - Fixed initialization bug that affected pokeys RNG.
  - Made the blue screen of death not broken.




----

### [v14.3.4](https://github.com/spannerisms/lttphack/releases/tag/14.3.4) &mdash; 1 March 2023

- Presets:
  - Allowed FoxLisk to fix the magic for the presets at the end of Misery Mire.
- Configuration:
  - Added "Pocky and Rocky 2".
  - Added "Loopz" font to honor my new favorite NES game.
  - Added "Futaba green" as a color option.
- Other:
  - Fixed Load Last Preset crashes.
  - Fixed overlay corruption misbehavior.


----

### [v14.3.3](https://github.com/spannerisms/lttphack/releases/tag/14.3.3) &mdash; 2 March 2022

- HUD extras:
  - Added "Tile index" for plaid.
- Other:
  - Fixed Trinexx crystal.
  - Fixed line sentry 4 ancilla prop.


----

### [v14.3.2](https://github.com/spannerisms/lttphack/releases/tag/14.3.2) &mdash; 2 February 2022

- HUD extras:
  - Added a fourth line sentry.
  - Added "Hide lines".
- Other:
  - Added a "Caveats" section to the documentation.
  - Crash the game when somaria goes bad.
  - Fixed input on fairy item toss.
  - Fixed a very minor lag bug with menu.
  - Added a block of sentinels to catch heavy corruption and prevent it from hanging forever.
  - Added ancilla index to Lite States.
  - Spooky edit.



----

### [v14.3.1](https://github.com/spannerisms/lttphack/releases/tag/14.3.1) &mdash; 2 December 2021

- Nevermind. I hate this font and so does everyone else.
- Fixed shortcut button display.
- Added arrow decay timer for Sirius.


----

### [v14.3.0](https://github.com/spannerisms/lttphack/releases/tag/14.3.0) &mdash; 29 November 2021

- Added a system and ROM info submenu to the configurations menu.
- Added idle frames to more textbox things.
- Adjusted savestates to make room for the sword and shield graphics in WRAM.
- Prevented Link from being invisible when loading a preset during stairs animation.
- Fixed shutters always being open.
- Fixed small bug with spawn points and presets.
- Fixed a display error with extra gnarly stack traces on BSOD.
- Fixed Vitreous eye prize drops.
- Tinkered with the menu font.
- Added guard probes back. Oops.
- Unlock castle doors even when Agahnim is defeated in randomizer version.
- Removed no magic message in randomizer version.
- Moved the throne room mantle to allow sewers access when rain state is over in randomizer version.


----

### [v14.2.2](https://github.com/spannerisms/lttphack/releases/tag/14.2.2) &mdash; 26 September 2021

- Fixed a VRAM issue when saving states on overworld transitions.
- Fixed enemy drops when loading presets and rooms.
- Fixed a crash with crystals in the randomizer version.



----

### [v14.2.1](https://github.com/spannerisms/lttphack/releases/tag/14.2.1) &mdash; 25 September 2021

- Fixed an issue with timers and floor numbers on the HUD.
- Fixed the naming of the Tazmania and Black Bass fonts.
- Banned savestates on specific frames that the underworld is loaded on to prevent VRAM issues.
- Banned lite states in special overworld and specific underworld load frames.
- Thickened the menu header.



----

### [v14.2.0](https://github.com/spannerisms/lttphack/releases/tag/14.2.0) &mdash; 22 September 2021

- Presets:
  - Added the rest of the Boss RTA Presets (courtesy of sirius).
  - Added "Double Reddies" preset for NMG categories.
  - Added bastard door behavior to several presets.
  - Fixed shutter doors on lower layers.
  - Randomized ice palace conveyor in presets.
  - Compressed preset data a little more (hopefully no problems).
  - Updated preset scraping script.
- Gameplay:
  - Added an option to always show somaria pits after corruptions.
- Other:
  - Introduced a beta for custom presets with the <a href="index#menuLiteStates">Lite states</a> menu. See that section for how to use them.
  - Fixed a savestate issue. Savestates from previous versions should not be loaded after updating.
  - Improved music load logic for Link's house.
  - Reversed the stack printing in the blue screen of death so that it's actually readable.
  - Added a color for BluntBunny since he asked nicely.


----

### [v14.1.0](https://github.com/spannerisms/lttphack/releases/tag/14.1.0) &mdash; 12 September 2021

- Fixed an issue that made presets remove too much lag.
- Added a new "Room master" submenu that includes the ability to view and set flags for underworld rooms, and load arbitrary rooms.
- Presets:
  - Proper 100% NMG presets (thanks to Sirius)
  - Changed various preset names.
  - Added "Bumper Skip" for NMG presets.
  - Fixed some data issues with Swamp lobby.
  - Fixed 10,000,000,000 errors with the preset scraping script.
- Game state:
  - Added a submenu for controlling drops and such.
  - Fixed boss deaths menu.
- RNG Control:
  - Fixed pokeys
- HUD Extras:
  - Rebranded counters as "sentries".
  - Added an icon for the ancilla search index, spooky, UW tile, boss HP, hookslot, and WEST SOMARIA sentries.
  - Added an icon for every ancilla property as well as an icon for which set of slots is being watched.
  - Renamed "Heart lag" to "HUD lag" and moved the indicator to the left of the magic bar.
  - Added a state icons feature that displays along the left side of the HUD.
  - Removed door state from the subpixels sentry in favor of the state icon.
  - Added cycle counter for Agahnim 2.
- Other:
  - Implemented a blue screen of death for catching BRK and COP software interrupts. This will hopefully protect configuration settings more often.
  - Improved behavior for finding the currently equipped item after modifying items.
  - Changed the numfield icon to something more cool and abstract and less ugly.
  - Filling equipment will update the rest of the menu.
  - Fixed a bug with saving HDMA channels during savestates.
  - Fixed a bug with overworld sprite deaths during savestates.
  - Link no longer slides around if a preset is loaded during death.
  - Loading last preset should no longer bring up the select menu (unless you hold select for too long).
  - Rerandomization works properly again.
  - Rerebranded the default font again.
  - Segment timer now resets on preset load.
  - Removed file 3 BAGE functionality, since no one uses it and there are existing functions for max equipment.



----

### [v14.0.0](https://github.com/spannerisms/lttphack/releases/tag/14.0.0) &mdash; 1 September 2021

#### FULL SA-1 REFACTOR</h4>
Version fourteen point zero point zero is finally here. This represents the biggest and most dramatic update since the inclusion of presets. From here on, the accessibility of the practice hack has been tightened a bit, now requiring decent SA-1 emulation. Fortunately, support is fairly widespread. Anyone without access to a supported system will be able to download v13.6.0 from this page; however, support for these non-SA-1 versions has been officially discontinued.

The SA-1's on-board RAM allows every system to include large save files, so fully fledged savestates are now available to everyone, eliminating the need for a separate SDSNES version. And while we're at it, the vanilla HUD variants are being nixed too (the option still exists, but it is no longer a separate ROM).

Anyone without access to a supported system will be unable to use this version or any future version. I know not everyone who plays on console can afford the more powerful flash carts, and that there are various other reasons people may stick with their current set up. Regardless, this hack is intended for vanilla practice, making accuracy for lag very important. Without a coprocessor, I have to put an aggressive filter on what features I add and count cycles meticulously everywhere. This inhibits improvement while <em>still</em> being too laggy. With the SA-1, I have so much more leeway. And with other cool features of the chip, I've vastly improved the backend of the practice menu to the point where it doesn't interfere with vanilla memory whatsoever. At the very least, I'm confident that this doesn't affect a majority audience. Many people who run on original hardware own an FXPak, and I can't name anyone who plays on the unsupported emulator cores. And, again, for those who can't or won't upgrade, v13.6 will always be available.


#### Changes

- Y-Items:
  - Unraveled the child and shoved it into its parent. The child being the bottle submenu.
- Equipment:
  - Removed the Fill HP and Fill Magic options and replaced them with numfields.
  - Max arrows is now 50
  - Added a small key editor
- Game state:
  - Follower option
  - Removed crystal switch color in lieu of the shortcut (it was causing problems).
  - Removed the room reset function, as it didn't work quite right.
  - Added some more progress bits to the game flag submenu.
- HUD extras:
  - Vanilla hearts is now here for those who want it for whatever reason.
  - Added "Classic Gray" input display.
  - Condensed the timers and RAM watches into a single system.
  - Replaced super watches with line counters and expanded their functionality.
  - Enemy HP has been replaced with a "Boss HP" watch and now only looks at the sprite in slot 0.
  - Added some more RAM watches:
    - Room ID
    - Quadrant
    - Overworld screen ID
    - Tile prop
    - West somaria timer
    - Ancilla index (no longer found in general ancilla watch)
    - Hookslot (no longer found in general ancilla watch)
    - Pit destination
    - Boss HP (to replace enemy HP)
    - Hover coach (politely stolen from Wulfy83)
    - Overworld transition triggers
  - The quick warp icon is now gray when you will not quick warp. Also changed the graphics.
- Shortcuts:
  - Setting a shortcut will abort after 1 second of no input.
  - Toggle crystal switch state (only works when you're in control)
- Preset config:
  - Added various safeties, with separate submenus for each category
  - Added "Randomize Ganon Bats" option
  - Added preset loadout override
  - Added Lanmo RTA presets
- Configuration:
  - Added a <i>Crayon Shin-chan</i> font.
  - Added a <i>Super Black Bass 3</i> font.
  - Updated the default font and renamed it from "Normal" to "Shop".
  - Removed the italic and classic fonts.
  - Added a choice for where the menu opens to.
  - Menu colors can now be customized.
- Other:
  - New website design!
  - Completely new backend for menu and presets. Shoutouts to Siriuscord for debugging bad preset data.
  - Pressing select in the practice menu now brings you to the tippy top.
  - Pressing Y in the practice menu now enables options and sets numfields to their max.
  - Created a new "Preset config" menu that includes some new stuff and some old stuff.
  - Practice menu will restore BG3 properties under heavy VRAM corruption (unavoidable utility fix).
  - The higher position for text boxes has been moved down 1 tile to make room for additional HUD features.
  - Included safeguards for SA-1 registers against overlay corruption. Note that this will prevent the practice hack from crashing where the vanilla game would.
  - Removed the intro screens on initial boot. A boss roar will be played for my amusement as memory is initialized.
  - Added a room time trigger for post-Aga castle warp.
  - Added a room time trigger for Ganon death and Triforce door.
  - Changed a few preset names.
  - Created a page detailing the submission process for presets at <a href="presetbuilding">presetbuilding</a>.
  - The 100% NMG presets are too out of date. They will be operational, but fairly inaccurate. A call for a new movie file has been added to its menu.
  - Moved all these updates to this new page. Anyone who asks about new features should contact their local ISP to ban them from this webpage.
- Bug fixes:
  - Accidentally fixed the bug that prevented input display from updating during text.


----

### [v13.6.0](https://github.com/spannerisms/lttphack/releases/tag/13.6.0) &mdash; 9 April 2021

- Lui fixed music


----

### [v13.5.0](https://github.com/spannerisms/lttphack/releases/tag/13.5.0) &mdash; 5 October 2020

- Lui cannot be stopped


----

### [v13.4.0](https://github.com/spannerisms/lttphack/releases/tag/13.4.0) &mdash; 4 October 2020

- Lui added low% presets. Can no one stop this mad man?


----

### [v13.3.0](https://github.com/spannerisms/lttphack/releases/tag/13.3.0) &mdash; 24 September 2020

- Lui added any% RMG presets.
- Added some cool fonts.
- Added "fill everything" to equipment menu.


----

### [v13.2.0](https://github.com/spannerisms/lttphack/releases/tag/13.2.0) &mdash; 15 September 2020

- Link state:
  - Added ancillae search index editor
- RNG control:
  - Added an option for forcing the frame counter to a specific value for frame rule testing.
  - Removed cannonball and soldier settings in favor of forced frames.
- HUD extras:
  - Merged misslots- and DG-watch into a single feature under the name "Super Watch".
- Ancillae watch has been revamped to be more readable and expandable.
- Bug fixes:
  - The ancillae watch revamp means the quickwarp indicator is no longer overwritten.
  - Menu sound effects no longer cause problems when changing certain options.
  - Fixed mastersword LSD effect.


----

### [v13.1.1](https://github.com/spannerisms/lttphack/releases/tag/13.1.1) &mdash; 23 April 2020

- Added an in-browser JavaScript-based patcher (thanks total).
- More efficient music muting, accomplished by adjust ADSR (sorry Myramong).
- Fixed invisible timers caused by MVN.


----

### [v13.1.0](https://github.com/spannerisms/lttphack/releases/tag/13.1.0) &mdash; 8 Feb 2020

- Old versions of the practice hack are no longer archived on GDrive. All future versions will point to the same file, without the version in its name.
- Added versioning and custom title to the file select screen.
- Added an explanation of Cycle Control to the site.
- Input display has been made to be persistent across multiple versions.
- The input display can now be shut off or changed to the old version. When off, it will still use its normal CPU time, as it is a core feature and part of Cycle Control. The old input display is laggier, and that will not be fixed. Nor can it be.
- The segment timer has been downgraded to an optional feature and is no longer part of Cycle Control.
- Added Icebreaker to RAM watch. It's just subpixels with an icon for being in a door.
- Fill rupees now applies immediately. No more ching cha ching.
- Experimenting with a background on input display for more visibility in certain places.
- Lui fixed weird savestate on death behavior.
- Lui also fixed the dumb bow stuff in AD presets.
- Fluting now resets the timer.
- Moved some code so that Vanilla HUD variants can enjoy cleaner menu characters.


----

### [v13.0.1](https://github.com/spannerisms/lttphack/releases/tag/13.0.1) &mdash; 2 Feb 2020

- Bug fixes:
  - Setting health works properly again.
  - Health refills no longer flash the HUD.
  - Fixed Lanmo cycles. Probably
  - Fixed file select E.
  - Fixed segment timer.


----

### [v13](https://github.com/spannerisms/lttphack/releases/tag/13.0.0) &mdash; 22 Jan 2020

- Several features have been adjusted to persist across practice hack updates (assuming you use the same file name). Please hold <span class="snesButton snesStart">Start</span>+<span class="snesButton snesSelect">Select</span> on power-on the first time you use this update.
- Cycle Control™ - made a number of features' lag contribution consistent, even when they're disabled.The following features have Cycle Control™:
  - Input display
  - Room timer
  - Lag timer
  - Idle frames
  - Segment timer
  - Coordinates
  - Quick warp indicator
- HUD Extras:
  - New arbitrary RAM watch with the following options:
    - Subpixels
    - Spooky altitude
    - Arc variable
  - Deleted subpixels in favor of the above
  - Heart lag spinner. If it's animated, there's heart lag.
- RNG control:
  - First Vitreous eyeball charge (slot positions shown in image with the option's description above)
- Timer improvements:
  - The lag counter is now red, to distinguish it from idle frames and to make it scary looking.
  - Fast moving walls will now add in the difference they saved to room times.New triggers:
  - Getting keys
  - Bonking
  - Chest appearing
  - Bombing stuff
  - Moving walls start/end
- Sleek new input display that looks like a controller. Also way more efficient.
- Digging game and Super Bomb timers are added back, just below the input display.
- Bonking, etc. no longer leave weird camera offsets after preset loading.
- Enemy HP display is more efficient in finding enemies, but also less picky.
- Saved a few cycles on health display.
- New icons for things in the practice menu.
- When dealing with number field options, the d-pad now changes all values by 1. <span class="snesButton snesL">L</span> and <span class="snesButton snesR">R</span> can be used to cycle through larger amounts.
- Removed the debug lag setting, since no one bothered with it.
- Temporarily removed decimal coordinates.
- Added SD2SNES debug version to site.



----

### [v12.1.0](https://github.com/spannerisms/lttphack/releases/tag/12.1.0) &mdash; 26 Oct 2019

- Updated the Emerald font.
- Menu improvements
  - Added icons to menu items indicating what they do.
  - You can now use <span class="snesButton snesX">X</span> to clear menu options.
  - Documented all these features on the site.
- Bug fixes
  - Fixed graphical/memory issue with the Mirror toggle.


----

### [v12.0.0](https://github.com/spannerisms/lttphack/releases/tag/12.0.0) &mdash; 24 Oct 2019

- Gameplay
  - Fast moving walls - thanks Pinkus
- Link state - New menu
  - Waterwalk
  - Activate superbunny
  - Activate Lonk
  - Finish mirror door
  - Statue drag
  - Armed EG
  - EG strength
- HUD extras
  - DG watch - fully explained <b><s>here</s></b>
- Configuration
  - HUD font - I probably won't add more than 16
- Added sound effects to the practice menu to help indicate responsiveness.
- Updated the Practice menu font a little.
- Removed the Japanese text for "Pendants" and "Crystals", mostly to make room for new graphics.
- Removed the red gloves and put boots back.
- Lag changes:
  - **Heart lag compensation has been lowered and may be *slightly* too little, giving 1 less lag frame than vanilla on occasion.** *Please help calibrate lag by reporting numbers in places.*
  - Crystal cutscenes should no longer be extremely slow, thanks to Pinkus.
  - Slightly optimized input display. Hopefully lag when mashing text is a little closer to vanilla.
  - The floor number indicator on the HUD has had its cycles added back in, matching vanilla perfectly without writing to BG3.
- Fixed some HUD bugs:
  - Lanmolas cycle toggle no longer messes with graphics.
  - Removed heart refill animation without affecting lag.



----

### [v11.0.0](https://github.com/spannerisms/lttphack/releases/tag/11.0.0) &mdash; 12 Oct 2019

- Under new management. General maintaining of the practice hack has been outsourced to the Americas.
- A handful of menu items were moved around to keep similar options together.
- Presets
  - All Dungeons preset (thanks to JoshRTA)
- Game state
  - Full dungeon room resets
  - World state toggle
  - Crystal switch toggle
  - EG strength - renamed and added EG 0
- Gameplay
  - Skip Triforce
  - Sanc heart
  - Disable beams
  - Visible probes
  - Lit rooms - also improved to work on current room
  - See bonk items
  - Disable BG1
  - Disable BG2
  - OoB Mode
- RNG control
  - Prize packs
- Shortcuts
  - LTTPHack menu is now set in stone
  - VRAM repair
  - Somaria pits
- HUD extras - renamed from "Counters"
  - Input display
  - Room time
  - Lag counter
  - Idle frames
  - Segment time
  - Lanmolas cycles
  - Lagometer
  - Enemy HP
  - Misslots RAM watch
- Renamed "Features" menu to "Configuration"
- Holding START+SELECT on boot will now reset the practice hack configuration as intended.
- Various features are now disabled during map screens.
- Fixed a bug that somehow only prevented the GT Wizzrobes 2 preset from loading.
- Replaced broken graphics in the item menu with placeholder tiles.
- General refactoring. Practice hack control should be smoother now.


----

### v10
<p class="warped"><span>This version was lost in a time </span><span class="morewarped">paradox.</span></p>


----

### v9 &mdash; 8 February 2018

- Presets
  - Added "Bosses" menu at the bottom.
  - Added "Ganon (full magic)" preset.
  - Fixed crystal state for Pokey 1.
  - Misspellings.
- Item/Equipment
  - Better control over each bottle and its contents.
  - Set which big keys you have.
- Game state
  - Skip text
  - Remove sprites
  - Boss defeated
  - Pendants and crystals
  - Game flags, Progress, Map indicator
  - Toggle armed/strong EG
- RNG control
- Configurable controller shortcuts
- Features
  - Music
  - Idle frames
  - Lagometer
  - Made it possible to toggle on/off any of the counters.
  - Disabled the "Show enemy HP" by default.
- Persist some things through console power-off/on, resets or load state.
- Comes in VanillaHUD and NoSaveState versions.
- Fixed bug that set game phase to "Agahnim killed" when upgrading sword manually
- Fixed bug that didn't update frame counters on mirror or underworld warps.
- Set the SNES header ROM size to 2mb. This fixes an issue where the ROM would not load properly on some platforms (everdrive).
- Show version in lttphack menu.
- Instant lttphack menu (no waiting for menu to go up/down).
- Improved transition detection (triggers on mirror/warp, reset counters when you start a new file)




----

### v8 &mdash; 24 October 2016

- Complete rewrite.
- Presets.
- I don't even remember anymore. This is the same version that's been around for a while, I just arbitrarily decided to remove "beta2" from the version.


----

### v7 &mdash; 15 December 2015

- Made save/load state code more robust. Screen should not get messed up anymore by loading during mirror warp. Big thanks to total for this fix.
- Added a toggle for "always lit rooms".


----

### v6 &mdash; 9 December 2015

- Fixed a bug that made the game crash when resetting segment counter.


----

### v5 &mdash; 8 December 2015

- Made Link get full equipment when using 3rd filename slot before starting a game.
- Added controller inputs for:
  - Upgrading sword, armor and shield.
  - Filling HP, magic, rupees and stuff.
  - Pause game and frame advance.
  - Displaying Link's coordinates.

----

### v4 &mdash; 05 December 2015

- Fixed a bug where saving or loading would add a frame to your attempts in a room.
- Added a "Full HP indicator".


----

### v3 &mdash; 02 December 2015

- Removed a bunch of lag. Should be less laggy than original ROM now.
- Added "Quick Warp Indicator".
- Better enemy detection.
- Removed per-room Game Time counter.
- Better B. Thanks, Audity.


----

### v2 &mdash; 30 November 2015

- Fixed issue where parts of segment timer was erased.
- Fixed issue where counters didn't run during maiden crystal sequence.
- Added better transition detection for boss victory &rarr; overworld.

----

### v1 &mdash; 29 November 2015

- Initial release
