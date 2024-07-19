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
        grid.Update(&gridI)
        grid.Draw(&gridI)
        

        rl.DrawText(rl.TextFormat("SCORE: %i", gridI.points), 520, 100, 40, rl.MAROON);
        rl.DrawText(rl.TextFormat("HIGH SCORE: %i", gridI.high_score), 520, 150, 20, rl.MAROON);
        rl.DrawText(rl.TextFormat("NEXT PIECE"), 520, 400, 40, rl.MAROON);
        rl.DrawText(rl.TextFormat("LEVEL"), 520, 600, 40, rl.MAROON);
        rl.DrawText(rl.TextFormat("%d", gridI.level), 520, 650, 40, rl.MAROON);
        rl.EndDrawing()
    }

    // De-Initialization
    rl.CloseWindow()
}