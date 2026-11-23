---
layout: practicehack
title: "Caveats of Usage - ALTTP Practice Hack"
ogdesc: "This page details known caveats that should be taken into consideration by practice hack users."
---

# Caveats

It's impossible to modify anything this much without sacrificing some behavior. This page details known caveats that should be taken into consideration by the user.

## Overlay corruption and the SA-1

The memory layout of the SA-1 puts important hardware registers and on-board memory in an area potentially affected by overlay corruption. To prevent corruption to the SA-1, the star tile holes routine will be intercepted if it is about to write too far. This will have some effect on the timing of longer corruptions.

When cut short, the practice hack will continue reading without writing to see how far the writes would have gone. If they reach too far (`$4200`), then a blue screen of death will be displayed to explain the intentional lock.

In addition to the writing, this type of corruption may also read too far. This does not have the potential to corrupt the SA-1, but it does throw the behavior out of sync from vanilla. Normally, corruption that reaches this far is dependent on open bus behavior; however, the SA-1 places registers and memory in this region, effecting a less deterministic sea of values. To coax corruptions into resolving, a large block of memory from `$3680` to `$37FF` has been filled with the required terminator value. This solution necessarily means that far-reaching corruption may end much sooner than it normally would, making timings unreliable.
