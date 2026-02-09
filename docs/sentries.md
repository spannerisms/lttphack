---
layout: practicehack
title: "Sentry list - ALTTP Practice Hack"
ogdesc: "List of available sentries, with description, in the current version of the practice hack."
---

## Basic sentries
- Off
  - Disable this sentry
- Timers
  - **Room time** - Time spent on the current screen, starting from the beginning of the last transition.
  - **Room time (live)** - Room time with continuous updates.
  - **Lag frames** - Count of lag frames on the current screen, starting from the beginning of the last transition.
  - **Lag frames (live)** - Lag frames with continuous updates.
  - **Idle frames** - Count of menu and text frames with no relevant input, starting from the beginning of the last transition.
  - **Segment time** - Time spent since the beginning of the last segment timer reset.
  - **Text timer** - Time remaining until text can be advanced.
- Link
  - **Coordinates** - Absolute position of Link (X,Y).
  - **Velocity** - Link's displacement along each axis from the previous frame of movement.
  - **Subpixel velocity** - Link's subpixel velocity on each axis.
  - **Spin attack timer** - Number of frames the spin attack has been charging.
- Enemies
  - **Boss HP** - Health of enemy in slot 0.
  - **Arc variable** - Overlord value used by Armos Knights, Ganon, et al. for circles.
  - **Slot 0 altitude** - Altitude of sprite in slot 0.
- Underworld
  - **Room ID** - Current room ID, corrected room ID (based on coordinates), and sync. Sync not displayed on overworld.
  - **Quadrant** - Current quadrant, corrected quadrant (based on coordinates), and sync. Not displayed on overworld.
  - **Link tile** - Tile type Link is standing on (bottom right; only works in underworld).
  - **Pit behavior** - Current pit destination/damage flag. Not displayed on overworld.
- Minor glitches
  - **Spooky action** - Altitude of ancilla in slot 4.
  - **Hovering** - Number of frames A has been held, up to 29.
- Major glitches
  - **WEST SOMARIA** - West somaria door timer.
  - **Ancilla search index** - Ancilla overload search index.
  - **Hookslot** - Hookshot slot index.
  - **Plaid tile index** - WRAM address in bank 7F of the tile Link is standing on.

## Line sentries
- Off
  - Disable this sentry
- Underworld
  - **Room flags** - Boss heart, key, chest, door, and quadrant flags for current room.
  - **Underworld camera X** - Camera scroll and boundaries for X-axis.
  - **Underworld camera Y** - Camera scroll and boundaries for Y-axis.
- Overworld
  - **OW transition X** - Transition triggers and target screen IDs for horizontal overworld transitions.
  - **OW transition Y** - Transition triggers and target screen IDs for vertical overworld transitions.
- Major glitches
  - **Hookslot props** - Hookslot plus the properties of X, Y, Direction, Extension for hookslot index.
  - **Map16 Cache Overflow** - Position of map16 cache overflow writes and corresponding tilemap/tile locations.
  - **Map16 Cache Indices** - Last 4 tilemap indices written by map16 cacher.
  - **Map16 Cache Objects** - Last 4 map16 object IDs written by map16 cacher.
- Ancilla [front/back/indexed] slots *(differentiated with [AncF/AncB/AncX] respectively)*
  - **ID** - Ancilla ID; address: $7E03C4,X (includes coloring for 00 and replacable particles).
  - **X coordinate** - Ancilla X-Coordinate; address: $7E0C04,X
  - **Y coordinate** - Ancilla Y-Coordinate; address: $7E0BFA,X
  - **Altitude** - Ancilla Z-Coordinate; address: $7E029E,X
  - **Layer** - Ancilla layer; address: $7E0C7C,X
  - **Extension** - Used both for hookshot length and item receipt ID, among other less interesting properties; address: $7E0C5E,X
  - **Tile type** - Tile type interaction; address: $7E03E4,X
  - **EG check** - Something; address: $7E03A4,X
  - **Direction** - Generally used for direction of ancilla; address: $7E0C72,X
  - **Decay** - Timer for lodged arrows before disappearing; address: $7E03B1,X

