#include "raylib.h"

Texture2D LoadTextureOrFail(const char* path) {
	Texture2D tex = LoadTexture(path);
	if (tex.id == 0) {
		TraceLog(LOG_ERROR, "Failed to load %s", path);
	}
	return tex;
}

int main() {
    // Window configuration
    const int windowWidth = 1024;
    const int windowHeight = 768;
	const Color bezelColor = { 218, 209, 185, 255 };
	
    // Initialize window and other Raylib systems
    InitWindow(windowWidth, windowHeight, "Mini Micro 2");
    SetTargetFPS(60);
	InitAudioDevice();

    // Load textures and sounds
	Texture2D bezelTexture = LoadTextureOrFail("resources/images/3DBezel.png");
	Texture2D stickerTexture = LoadTextureOrFail("resources/images/MiniMicroSticker.png");
	Sound bootupSound = LoadSound("resources/sounds/startup-chime.wav");
	//Sound beepSound = LoadSound("resources/sounds/beep-single.wav");
	
	PlaySound(bootupSound);

    // Main game loop
    while (!WindowShouldClose()) {
        // Update
        // (Nothing to update yet)

        // Draw
        BeginDrawing();

        // Clear background to black
        ClearBackground(BLACK);

		DrawTexture(bezelTexture, 0, 0, bezelColor);
		DrawTextureEx(stickerTexture,
					  (Vector2){windowWidth - 56 - 32, windowHeight - 42 - 24},
					  0,
					  64.0f / stickerTexture.width,
					  WHITE);

        EndDrawing();
    }

    // Cleanup
	UnloadTexture(bezelTexture);
	UnloadTexture(stickerTexture);

	CloseWindow();

    return 0;
}
