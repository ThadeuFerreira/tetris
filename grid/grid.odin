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
        clear_cells(g)
        if !rotate_current_piece(g) {
            rl.TraceLog(rl.TraceLogLevel.INFO, "rotation not possible")
        }
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
        // Drop the piece
    }
    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        clear_cells(g)
        nextX := g.currentPiece.x -1
        if check_collision(g, nextX, g.currentPiece.y, nil) {
            nextX += 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        clear_cells(g)
        nextX := g.currentPiece.x +1
        if check_collision(g, nextX, g.currentPiece.y, nil) {
            nextX -= 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    // Move the piece down
    globalTimeCounter += rl.GetFrameTime()
    if globalTimeCounter >= 1/shapeFallSpeed {
        
        if check_collision(g, g.currentPiece.x, g.currentPiece.y + 1, nil) {
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

rotate_current_piece :: proc(g: ^Grid) -> bool {
    t := g.currentPiece
    rotated_shape := shape.Rotate_piece(t.shape)
    
    // Try rotation in original position
    if !check_collision(g, t.x, t.y, &shape.Tetromino{shape = rotated_shape, x = t.x, y = t.y}) {
        t.shape = rotated_shape
        return true
    }
    
    // Wall kick attempts
    wall_kicks := [4][2]int{
        {-1, 0},  // Try moving left
        {1, 0},   // Try moving right
        {0, -1},  // Try moving up
        {-2, 0},  // Try moving two spaces left (for I piece)
    }
    
    for kick in wall_kicks {
        new_x := t.x + kick[0]
        new_y := t.y + kick[1]
        if !check_collision(g, new_x, new_y, &shape.Tetromino{shape = rotated_shape, x = new_x, y = new_y}) {
            t.shape = rotated_shape
            t.x = new_x
            t.y = new_y
            return true
        }
    }
    
    return false  // Rotation not possible
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

check_collision :: proc(g: ^Grid, x: int, y: int, piece: ^shape.Tetromino) -> bool {
    t := piece if piece != nil else g.currentPiece
    for row in 0..< len(t.shape) {
        for col in 0..< len(t.shape[row]) {
            if t.shape[row][col] == 1 {
                newX := x + row
                newY := y + col
                if newX < 0 || newX >= g.width || newY >= g.height {
                    return true  // Out of bounds
                }
                if newY >= 0 && g.cells[newX][newY] == 2 {
                    return true  // Collision with locked piece
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