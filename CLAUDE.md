# Notes for Claude

## Project Context
This is MiniMicro2 — **Mini Micro 2**, a rewrite of Mini Micro (originally
Unity/C#).  The user (Joe Strout) is the original author of Mini Micro and
MiniScript.

Mini Micro 2 is written in MiniScript, running on the **raylib-miniscript**
host.  There is nothing here to compile.  An earlier C++/Raylib implementation
lived in `src/` and `include/`; it is now in `archive/` and no longer builds.
Don't reach for it except as a reference for how something used to work.

**Reference sources:**
- Unity original: `/Users/jstrout/Documents/svnrepo/stroutandsons/MiniScript/MiniMicro/`
- The C++ attempt: `archive/` in this repo
- Soda (shares our engine layer): `../soda`
- The host: `../raylib-miniscript` (see its `API_DOC.md` for intrinsics)

## Layout

```
assets/
  main.ms      entry point; the host runs this at startup
  lib/         -> ../../soda/lib   (symlink; engine layer, SHARED WITH SODA)
  mm/          the Mini Micro shell: REPL, editor, file browser
  hw/          the /hw disk: images/ sounds/ fonts/ -- our own resources
  sys/         -> ../../minimicro-sysdisk/sys  (symlink; the /sys disk)
archive/       the old C++ implementation; dead
raylib-miniscript -> ../raylib-miniscript/build/raylib-miniscript  (symlink)
```

`lib`, `sys`, and `raylib-miniscript` are gitignored — the right target differs
per machine.

## Running it

```bash
./raylib-miniscript          # no argument: runs assets/main.ms
```

The host resolves a missing script argument as `assets/main.ms` in the working
directory first, then beside the executable (which is how a packaged app
works).  It opens a window, so run it in the background and kill it rather than
blocking a tool call; `sleep` then check the log for errors.

## Important Technical Details

### The shared engine layer
`assets/lib` is a symlink to Soda's `lib/`.  **Editing anything there changes
Soda too.**  Keep changes no-ops for Soda (sensible defaults that preserve its
current behavior), and put Mini Micro-specific code in `assets/mm/` instead
where you can.  Code that must differ at runtime switches on
`version.hostName` — `"Mini Micro"` here, `"Soda"` there.

### The version map
The host's built-in `version` map is **frozen**, so `main.ms` shadows it with a
global built by merging: `globals.version = version + {...}`.  Soda does the
same in `soda.ms`, guarded so the host application wins if it got there first.

### The file system and the sandbox
Paths are virtual and always `/`-separated.  The host mounts two disks before
running `main.ms`:

- `/hw` — the hardware disk: `assets/hw`, read-only.  Our own resources (bezel,
  sticker, screen font, boot chime) load from `/hw/...`.  It is **hidden**: it
  will not appear in a listing of `/`.  Undocumented, not secret.
- `/sys` — `assets/sys`, read-only.  Ships from the minimicro-sysdisk repo on
  its own release cycle, which is why it is not merged into `/hw`.

Each disk is its own subdirectory of `assets/`, and the host mounts only those
named subdirectories — never `assets/` itself.  That keeps `main.ms`, `mm/`,
and `lib/` off every disk, so a user program cannot read the shell's own source.
Anything put directly in `assets/` is invisible to script; anything dropped in
`assets/hw/` is readable by any program, so put resources there and nothing else.

`/usr` and `/usr2` start unmounted; mounting one will be the user's choice,
through a file picker, never a program's.

`main.ms` calls `file.enterSandbox` as its last act of setup.  That is a
**one-way latch** — there is no intrinsic to leave, and there must never be
one.  Before it, host paths work normally (boot needs that: the import path is
built from real directories).  After it, only mounted disks exist, and any
other path simply does not exist — no distinguishable "permission denied",
because that would let a program map the host file system by probing.

So anything that must touch a real host path has to happen **above** the
`file.enterSandbox` line in `main.ms`.  Rejections are logged to stderr as
`[fs] rejected ...`; check there first when a path mysteriously fails.

Still to come on the host side: the `file` module and the remaining raylib
loaders are not yet routed through the resolver, so they still see real host
paths after the latch.  Don't rely on that — it is a gap being closed, not a
feature.

### Import path
`main.ms` sets `MS_IMPORT_PATH` to `$MS_SCRIPT_DIR : <assets>/mm : <assets>/lib`.
The last two are absolute paths resolved once at boot, deliberately: the host
repoints `MS_SCRIPT_DIR` at every script it runs, and running user programs is
Mini Micro's whole job.  The first entry stays a live variable so a user program
can import modules sitting next to it.

Watch for shadowing: `$MS_SCRIPT_DIR` comes first, so a file named after an
engine module overrides it, and the failure surfaces somewhere unrelated.

### The screen rect and the bezel
The window is 1024x768; the Mini Micro screen is the 960x640 area inside the
bezel image, at (32, 34).  `Display.screenLeft/screenTop/screenWidth/screenHeight`
carry that; displays size and position themselves against those, never against
`GetScreenWidth`/`GetScreenHeight`.  `_update` wraps `Display.RenderAll` in a
`BeginMode2D` camera that translates by the rect's top-left, and `mouse.update`
applies the inverse.  The bezel's insets are not symmetrical (thicker at the
bottom, for the logo), so anything that centers itself must center on the rect.

Keep the `BeginMode2D` bracket tight around `RenderAll`: `PixelDisplay._beginDraw`
and `ttFonts` call `BeginTextureMode`, which would bake the camera matrix into a
render texture.

### Display conventions (unchanged from Mini Micro)
- **Bottom-up coordinates**: row 0 / y=0 at the bottom
- **68x26 character grid**, 14px column spacing, 24px row spacing
- **Layers 7→0 rendered**, so 0 is on top
- Cell `backColor` defaults to transparent, not black

### MiniScript 2 gotchas
No assignment hooks, so Mini Micro properties that were assignable are setter
methods here: `Display.setMode`, `text.setCursor`, `TileDisplay.setExtent`.
Assigning to `.mode`, `.row`, `.column`, `.extent` silently does nothing.

## Code Style
- Tabs for indentation
- Concise; minimal comments, and comments say *why*, not *what*
- Don't add emojis unless requested

## Current Status
- ✅ Host boots `assets/main.ms`; window, bezel, screen rect, camera offset
- ✅ Displays, screen font, input via the shared engine layer
- ⏳ The Mini Micro shell (`assets/mm/`): REPL, editor, file browser — not started
- ✅ File system: `/hw` and `/sys` mounted read-only at boot; `file.enterSandbox`
  latched at the end of `main.ms`
- ⏳ File system: `/usr` and `/usr2` (writable, user-mounted through a picker)
- ⏳ Packaging: per-platform app bundles

## Reference Files to Check
When implementing a Mini Micro feature, check the Unity version first:
`.../MiniMicro/Assets/Scripts/` — `Shell.cs`, `Console.cs`, `TextDisplay.cs`,
`ScreenFont.cs`.
