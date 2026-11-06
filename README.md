# MissingButtons

Nine free utility plug-ins by [John Crosby](https://john-crosby.com): the buttons your mixer is missing.
No user interface, no parameters, no latency. Built with [iPlug2](https://github.com/iPlug2/iPlug2).

| Plug-in | Does |
|---|---|
| Flip | polarity (phase) inverter, every channel |
| FlipRight | inverts the right channel; mono in -> L = x, R = -x |
| Left | left channel on both outputs |
| Right | right channel on both outputs |
| Mono | (L + R) / 2 on both outputs |
| MidSide | mid/side encoder and decoder, (L ± R) * 0.707 |
| Side | (L - R) / 2 left, its inverse right |
| Swap | swaps left and right |
| SideChainer | outputs the sidechain input in place of the main input |

Formats: AU, VST3, CLAP, AAX. macOS 10.13+ (universal), Windows x64.

## Layout

```
common/config-common.h   version and settings shared by all nine (the only place to bump the version)
<Plugin>/config.h        name, IDs, channel layouts of one plug-in
<Plugin>/<Plugin>.cpp    the whole plug-in
cmake/                   mb_add_plugin() and the Info.plist templates
scripts/                 makedist-mac.sh, makedist-win.bat
installer/               EULA, changelog, Inno Setup script
```

This folder lives inside an iPlug2 checkout (`iPlug2/MissingButtons`); `IPLUG2_DIR` defaults to `..`.

## Build

macOS (CMake 3.21+, Xcode 26 for the 10.13 minimum; Xcode 27 starts at macOS 12):

```sh
cmake -S . -B build-mac -G Xcode                 # Xcode project for development
cmake --build build-mac --config Release
scripts/makedist-mac.sh                          # release build, signed + notarized installer
```

Windows (Visual Studio 2022, Inno Setup 6):

```bat
scripts\makedist-win.bat          :: VST3 + CLAP
scripts\makedist-win.bat aax      :: + AAX
```

`-DIPLUG_DEPLOY_PLUGINS=ON` copies every build into the user plug-in folders for testing.
