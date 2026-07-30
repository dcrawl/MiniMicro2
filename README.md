# MiniMicro2

A complete rewrite of [Mini Micro](https://miniscript.org/MiniMicro/), moving off Unity.  This will be **Mini Micro 2**.

Mini Micro 2 is written in MiniScript, running on [raylib-miniscript](https://github.com/JoeStrout/raylib-miniscript) -- the same host [Soda](https://github.com/JoeStrout/soda) uses.  There is no C++ here to compile: an executable is the raylib-miniscript binary paired with the contents of `assets/`.  (The earlier C++/Raylib implementation is in `archive/`, and no longer builds.)

## Layout

```
assets/
  main.ms      entry point; the host runs this at startup
  lib/         engine layer -- displays, sound, input.  Shared with Soda.
  mm/          the Mini Micro shell: REPL, editor, file browser
  sys/         the /sys disk, as seen from the Mini Micro command line
  images/ sounds/ fonts/
```

`lib` and `sys` are symlinks during development, into sibling checkouts of [soda](https://github.com/JoeStrout/soda) and [minimicro-sysdisk](https://github.com/JoeStrout/minimicro-sysdisk).  They are gitignored, since the right target differs per machine; packaging replaces them with real directories.

## Running it

Link the host, then run it with no arguments:

```bash
ln -s /path/to/raylib-miniscript/build/raylib-miniscript raylib-miniscript
./raylib-miniscript
```

With no script argument the host looks for `assets/main.ms`, so that single command boots Mini Micro.  That is also how a packaged app works: the payload ships beside the executable (inside `Contents/MacOS/` on macOS), and the host finds it there regardless of the working directory.

## Development Plan

I intend to keep this project mostly on the back burner, just occasionally pushing it forward, until MiniScript 2.0 is complete.  Then we will move this project up to the front and complete it.

## Platform Support

One reason for moving off Unity is to make it possible to run on more platforms -- including Raspberry Pi.  Also with 2.0, mobile platforms (Android and iOS) are going to be a high priority, particularly for tablets (I'm not sure how practical it is to really use Mini Micro on a phone, though we'll support if if we can).  Target platforms:

- macOS
- Linux
- Windows
- Raspberry Pi
- Mobile (iOS/Android)

## License

TBD
