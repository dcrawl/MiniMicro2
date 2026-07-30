// Mini Micro 2 -- main entry point.
//
// The host (raylib-miniscript) runs this file at startup: with no script
// argument it looks for assets/main.ms beside the executable, which is exactly
// where this file sits in a packaged app.
//
// Everything below this file is MiniScript.  lib/ is the engine layer, shared
// with Soda; mm/ is the Mini Micro shell (REPL, editor, file browser); sys/ is
// the /sys disk the user sees from the command line.

// Import search path.  The first entry is the running script's own directory,
// so a user program can import modules sitting next to it.  The other two must
// NOT be written in terms of $MS_SCRIPT_DIR: the host repoints that variable at
// every script it runs, and running user programs is Mini Micro's whole job.
// So pin them to where this file lives, resolved once, right now.
bootDir = env.MS_SCRIPT_DIR
if bootDir[0] != "/" and bootDir[1] != ":" then  // (":" catches "C:\..." on Windows)
	bootDir = file.curdir + "/" + bootDir  // (relative; make it absolute)
end if
env.MS_IMPORT_PATH = "$MS_SCRIPT_DIR" + ":" + bootDir + "/mm" + ":" + bootDir + "/lib"

// The built-in `version` map is frozen, so shadow it with a global of our own,
// carrying the same keys plus our overrides.  Code shared with Soda can switch
// on version.hostName to tell the two environments apart.
globals.version = version + {
	"host": "2.0",
	"hostName": "Mini Micro",
	"hostInfo": "http://miniscript.org/MiniMicro"}

raylib.SetTraceLogLevel raylib.LOG_WARNING
raylib.InitWindow 1024, 768
raylib.SetWindowTitle "Mini Micro 2"
raylib.SetTargetFPS 60

bootupSound = raylib.LoadSound("assets/sounds/startup-chime.wav")
raylib.PlaySound bootupSound

bezelTexture = raylib.LoadTexture("assets/images/3DBezel.png")
bezelColor = [218, 208, 185, 255]
stickerTexture = raylib.LoadTexture("assets/images/MiniMicroSticker.png")
print "sticker: " + stickerTexture

import "importUtil"

ensureImport ["color", "Image", "Sound", "Display", "SolidColorDisplay", "PixelDisplay",
  "SpriteDisplay", "TileDisplay", "TextDisplay", "mouse", "key"]

// Our screen is the 960x640 area framed by the bezel, not the whole window.
// Tell the display layer where that is; everything sizes and centers itself
// against these, and _update below translates rendering to match.  (The bezel
// image is 1024x768, with a thicker band at the bottom for the logo -- so the
// insets are NOT symmetrical, and a plain "center it" would land 64px high.)
Display.screenLeft = 32
Display.screenTop = 34
Display.screenWidth = 960
Display.screenHeight = 640

Display.Initialize

// window: query and control the application window.
// Mini Micro exposes window.width/height/fullScreen as assignable properties,
// but MiniScript 2 has no assignment hook, so the setters are methods here.
globals.window = {}
window.title = "Mini Micro 2"

window.width = function
	return raylib.GetScreenWidth
end function

window.height = function
	return raylib.GetScreenHeight
end function

window.fullScreen = function
	return raylib.IsWindowFullscreen
end function

window.setSize = function(w=960, h=640)
	raylib.SetWindowSize w, h
end function

window.setTitle = function(title="")
	raylib.SetWindowTitle title
	self.title = title
end function

// Raylib only offers a toggle, so compare with the current state first.
window.setFullScreen = function(full=true)
	if (full != 0) == (raylib.IsWindowFullscreen != 0) then return
	raylib.ToggleFullscreen
end function

// updateCallbacks: a list of methods to call on every frame.  This includes standard
// Soda update methods, but you may add your own methods to ensure they are invoked
// at update time as well.
updateCallbacks = [
	@mouse.update,
	@key.update,
	@Sound.UpdateAll,
]

// Slide all display rendering into the bezel's opening.  The displays draw
// themselves at 0,0..960,640; this camera is a pure translation by the screen
// rect's top-left corner.  Keep the bracket tight around RenderAll: anything
// that calls BeginTextureMode inside it (PixelDisplay._beginDraw, ttFonts)
// would bake the camera matrix into the render texture.
screenCamera = {"offsetX": Display.screenLeft, "offsetY": Display.screenTop,
   "targetX": 0, "targetY": 0, "rotation": 0, "zoom": 1}

_update = function(beginEndRaylibDrawing = true)
	if beginEndRaylibDrawing then raylib.BeginDrawing
	raylib.BeginMode2D screenCamera
	Display.RenderAll
	raylib.EndMode2D
	raylib.DrawTexture bezelTexture, 0, 0, bezelColor
	for f in updateCallbacks; f; end for
	raylib.DrawTextureEx stickerTexture, 
	  [window.width - 56 - 32, window.height - 42 - 24],
	  0, 64 / stickerTexture.width, raylib.WHITE
	if beginEndRaylibDrawing then raylib.EndDrawing
end function

// Override (actually, shadow) the `yield` intrinsic to do our standard
// update, so that a tight yield loop does not lock up the app.
globals.yield = function
	outer._update
	intrinsics.yield
end function

// And similar for `wait`.
globals.wait = function(duration=1)
	endTime = time + duration
	while time < endTime
		intrinsics.yield
		outer._update
	end while
end function

gfx.drawRect 0, 0, 960, 640, color.lime
gfx.line 0, 0, 960, 640, color.lime
gfx.line 960, 0, 0, 640, color.lime

text.print "Mini Micro " + version.host
text.print "MiniScript " + version.miniscript + " on " + version.platform
text.print

while not key.pressed("escape")
	yield
end while
