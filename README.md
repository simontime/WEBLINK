# Tiger Web Link disassembly

Disassembly of Tiger Web Link for the Tiger game.com; builds a matching ROM.

Still quite a work-in-progress! `(OL)` in source code = known/inferred original label from various SDK code snippets.

## Prerequisites
### For tools directory
- [gcimagetool](https://github.com/simontime/gcimagetool) (gcimagetool.exe - **included**)
- [MS-DOS Player](https://takeda-toshiya.my.coocan.jp/msdos/index.html) (msdos.exe)
- `ASM8521.EXE`, `HEX2BIN.EXE`, `HEX8521.EXE`, `LINK8521.EXE`, `REG8521.CFG`, `STUFF.EXE` and `SM85.TYP` from the SDK

## Building
To build, run `build.bat`.

Generates a ROM to `output/WEBLINK.BIN`.
