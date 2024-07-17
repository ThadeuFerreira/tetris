package grid

import rl "vendor:raylib"
import "core:math/rand"
import "../shape"

// Grid
Grid :: struct {
    width, height: int,
    blockSize: int,
    cells: [][]int,
    offset: rl.Vector2,

    backgroundColor: rl.Color,
    currentPiece: ^shape.Tetromino,
}

shapeFallSpeed : f32 = 8.0
globalTimeCounter : f32 = 0.0

GridBuilder :: proc(width : int, height : int, blockSize: int, offset: rl.Vector2, backgroundColor: rl.Color) -> Grid {
    result := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset = offset,
        backgroundColor = backgroundColor,
    }
    createNewPiece(&result)
    cells := make([][]int, width)
    for i in 0..< width {
        cells[i] = make([]int, height)
    }

    result.cells = cells
    // result.currentPiece = t
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
        if check_collision(g, nextX, g.currentPiece.y) {
            nextX += 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        clear_cells(g)
        nextX := g.currentPiece.x +1
        if check_collision(g, nextX, g.currentPiece.y) {
            nextX -= 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    // Move the piece down
    globalTimeCounter += rl.GetFrameTime()
    if globalTimeCounter >= 1/shapeFallSpeed {
        
        if check_collision(g, g.currentPiece.x, g.currentPiece.y + 1) {
            lock_piece(g)
            createNewPiece(g)
        }
        else{
            clear_cells(g)
            currentY := g.currentPiece.y
            g.currentPiece.y = currentY + 1
            globalTimeCounter = 0.0
            set_cells(g)   
        }
    }
    
}

lock_piece :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1 {
                g.cells[i + t.x][j + t.y] = 2
            }
        }
    }
}

check_collision :: proc(g : ^Grid, x : int, y : int) -> bool {
    t := g.currentPiece
    cols := len(t.shape)
    checks : int = 0
    for row in 0..< cols{
        rows := len(t.shape[row])
        for col in 0..< rows {
            checks += 1
            rl.TraceLog(rl.TraceLogLevel.INFO, "i: %d, j: %d", row, col)
            cell := t.shape[row][col]
            newX := x + row
            newY := y + col
            // gridCell := -1
            // if newX > 0 && newX < g.width && newY > 0 && newY < g.height {
            //     gridCell = g.cells[newY][newY]
            // }  
            rl.TraceLog(rl.TraceLogLevel.INFO, "cell: %d", cell)
            rl.TraceLog(rl.TraceLogLevel.INFO, "newX: %d, newY %d", newX, newY)         
            if cell == 1 {    
                //gridce
                if newX < 0 || newX >= g.width {
                    return true
                }
                if newY < 0 || newY >= g.height {
                    return true
                }
                if g.cells[newX][newY] == 2 {
                    rl.TraceLog(rl.TraceLogLevel.ERROR, "collision")
                    return true
                }
            }
        }
    }
    rl.TraceLog(rl.TraceLogLevel.INFO, "checks: %d", checks)
    return false
}

clear_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                g.cells[i + t.x][j + t.y] = 0
            }
        }
    }
}

set_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                g.cells[i + t.x][j + t.y] = t.shape[i][j]
            }
        }
    }
}


// Draw the grid
Draw :: proc(g : ^Grid) {

    for col in 0..<g.width {
        for row in 0..<g.height {
            color := rl.DARKGRAY
            if g.cells[col][row] == 1 {
                color = rl.LIGHTGRAY
            }
            if g.cells[col][row] == 2 {
                color = rl.GRAY
            }
            rl.DrawRectangle(i32(g.offset.x + f32(col * g.blockSize)), 
            i32(g.offset.y + f32(row * g.blockSize)), 
            i32(g.blockSize -1), 
            i32(g.blockSize -1), 
            color)
        }
    }
}