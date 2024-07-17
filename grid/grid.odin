package grid

import rl "vendor:raylib"
import "core:math/rand"
import "../shape"

// Grid
Grid :: struct {
    width, height: int,
    blockSize: int,
    cells: [][]bool,
    offset: rl.Vector2,

    backgroundColor: rl.Color,
    currentPiece: ^shape.Tetromino,
}

shapeFallSpeed : f32 = 5.0
globalTimeCounter : f32 = 0.0

GridBuilder :: proc(width : int, height : int, blockSize: int, offset: rl.Vector2, backgroundColor: rl.Color) -> Grid {
    result := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset = offset,
        backgroundColor = backgroundColor,
    }
    opt := rand.int_max(len(shape.SHAPES))
    t := shape.TetrominoBuilder(opt, rl.RED, 5, 0)
    cells := make([][]bool, width)
    for i in 0..< width {
        cells[i] = make([]bool, height)
    }

    result.cells = cells
    result.currentPiece = t
    return result
}

createNewPiece :: proc(g : ^Grid) {
    free(g.currentPiece)
    opt := rand.int_max(len(shape.SHAPES))
    t := shape.TetrominoBuilder(opt, rl.RED, 5, 0)
    g.currentPiece = t
}

// Update the grid
Update :: proc(g : ^Grid) {
    t := g.currentPiece
    
    if rl.IsKeyPressed(rl.KeyboardKey.UP) {
        // Rotate the piece
    }
    if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
        // Drop the piece
    }
    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        clear_cells(g)
        nextX := g.currentPiece.x -1
        if check_horizontal_collision(g, nextX, g.currentPiece.y) {
            nextX += 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        clear_cells(g)
        nextX := g.currentPiece.x +1
        if check_horizontal_collision(g, nextX, g.currentPiece.y) {
            nextX -= 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    // Move the piece down
    globalTimeCounter += rl.GetFrameTime()
    if globalTimeCounter >= 1/shapeFallSpeed {
        if g.currentPiece.y + len(t.shape[0]) >= g.height {
            createNewPiece(g)
        }
        clear_cells(g)
        currentY := g.currentPiece.y
        g.currentPiece.y = currentY + 1
        globalTimeCounter = 0.0
        set_cells(g)   
    }
    
}

check_horizontal_collision :: proc(g : ^Grid, x : int, y : int) -> bool {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] {
                if x + i < 0 || x + i >= g.width {
                    return true
                }
                if g.cells[x + i][y + j] {
                    return true
                }
            }
        }
    }
    return false
}

clear_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j]{
                g.cells[i + t.x][j + t.y] = false
            }
        }
    }
}

set_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            g.cells[i + t.x][j + t.y] = t.shape[i][j]
        }
    }
}


// Draw the grid
Draw :: proc(g : ^Grid) {

    for i in 0..<g.width {
        for j in 0..<g.height {
            color := rl.DARKGRAY
            if g.cells[i][j] {
                color = rl.LIGHTGRAY
            }
            rl.DrawRectangle(i32(g.offset.x + f32(i * g.blockSize)), 
            i32(g.offset.y + f32(j * g.blockSize)), 
            i32(g.blockSize -1), 
            i32(g.blockSize -1), 
            color)
        }
    }
}