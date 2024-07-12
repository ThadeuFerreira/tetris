package main

import rl "vendor:raylib"
import "grid/"


// Global variables
screenWidth  :: 800
screenHeight :: 1000
CELL_SIZE :: 40
CELL_COUNT_X :: 10
CELL_COUNT_Y :: 20

main :: proc()
{
    // Initialization
    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")

    rl.SetTargetFPS(60) // Set our game to run at 60 frames-per-second
    rl.SetTraceLogLevel(rl.TraceLogLevel.ALL) // Show trace log messages (LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_DEBUG)
    
    offset := rl.Vector2{100, 100}
    gridI := grid.GridBuilder(CELL_COUNT_X, CELL_COUNT_Y, CELL_SIZE, offset, rl.DARKGRAY)
    
    // Main game loop
    for !rl.WindowShouldClose() {
        // Draw
        rl.BeginDrawing()

        rl.ClearBackground(rl.RAYWHITE)

        rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
        grid.Draw(&gridI)
        rl.EndDrawing()
    }

    // De-Initialization
    rl.CloseWindow()
}