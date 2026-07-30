# Archived C++ Implementation

This is the original C++/Raylib implementation of Mini Micro 2, kept here for
reference while it is rewritten as MiniScript running on
[raylib-miniscript](https://github.com/JoeStrout/raylib-miniscript), sharing its
engine layer with [Soda](https://github.com/JoeStrout/soda).

**It no longer builds** — the `external/raylib` and `external/miniscript`
submodules it depended on have been removed (they live upstream, and remain in
this repo's git history if ever needed). Nothing here is part of the current
Mini Micro.

This directory is a temporary holding pen. Once the rewrite covers everything
the C++ version did, it will be deleted; git history is the permanent archive.

## What was where

`Machine` owned eight `Display` layers and rendered them 7→0, with 0 on top.
`Display` was the abstract base; only `SolidColorDisplay` and `TextDisplay`
were ever finished. `TextDisplay` drew a 68×26 character grid through
`ScreenFont`, which used a custom shader (`shaders/screenfont.vs/fs`, also
archived here) to separate foreground from background by texture alpha.
`Console` handled line editing and keyboard input, including the layout-aware
key mapping needed for non-QWERTY layouts. `ResourcePath` resolved resource
files for both development and app-bundle layouts.

`ARCHITECTURE.md` describes that design in full. `BUILDING.md` covers the CMake
and Xcode setup. `CPP_STL.md` records which parts of the STL the C++ version
allowed itself, given a macOS 10.13 deployment target.

The MiniScript rewrite reimplements all of this: displays and the screen font
live in the shared engine layer (`assets/lib`, symlinked to Soda's `lib/`),
and the shader source is now built into `ScreenFont.ms` rather than read from
files.
