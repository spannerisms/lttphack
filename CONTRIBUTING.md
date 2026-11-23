## Building

The general development workflow looks like:

1. Make your changes to the assembly
1. Build the practice hack in the `target` directory (`futaba build _test.futaba`)
1. Test it

For contributing to this repository, please only include changes to the assembly. Avoid changes to the site or manifest.

Prerequisites for building:
- [Futaba](https://github.com/spannerisms/Futaba/releases) (recommended to have run `futaba register`)
- Clean dump of JP1.0 named `alttp.sfc` inside the `target` directory

## Releases

In general, contributors shouldn't do these steps, and leave the release process to kan.

These are the things that need to be changed for a new release:

1. The version number in `main.asm`
1. The version number in `docs/patcher/manifest.json`
1. The `.bps` patch files in `docs/patcher/files`. These get created automatically by `_build.bat`
1. The change log in `docs/updates.md`
1. The version tag on latest commit

Prerequisites for releases:
- Building prerequisites
- [flips](https://www.romhacking.net/utilities/1040/) (recommended to make this file accessible from PATH)

For Windows users, `_build.bat` can be run to execute the full compilation workflow.
