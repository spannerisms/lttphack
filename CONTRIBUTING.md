The general development workflow looks like

1. Make your changes to the assembly
1. Build the prachack.
    1. Install [asar](https://github.com/RPGHacker/asar/releases)
    1. Install [flips](https://www.romhacking.net/utilities/1040/) and put them on your path.
    1. run `build.bat`. this is windows-only and doesn't do a great job of setting stuff up for you. in particular, you'll need a copy of the jp1.0 ROM named `alttp.sfc` inside the `target` directory.
1. Test it

If you're doing a release, the things you need to update are:

1. The version number in `build.bat`
1. The actual `.bps` patch files in `docs/patcher/files`. These get created automatically by `build.bat`
1. The update history in `docs/history.md`
1. The version number in `docs/patcher/manifest.json`