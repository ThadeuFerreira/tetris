package grid

import rl "vendor:raylib"
import "core:math/rand"
import "../shape"

// Grid
Grid :: struct {
    width, height: int,
    blockSize: int,
    cells: [][]GridCell,
    offset: rl.Vector2,

    backgroundColor: rl.Color,
    currentPiece: ^shape.Tetromino,
}

GridCell :: struct {
    value: int,
    color: rl.Color,
}

COLOR_LIST :: []rl.Color{
    rl.RED,
    rl.BLUE,
    rl.GREEN,
    rl.ORANGE,
    rl.PURPLE,
    rl.YELLOW,
    rl.MAGENTA,
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
    cells := make([][]GridCell, width)
    for i in 0..< width {
        cells[i] = make([]GridCell, height)
    }

    result.cells = cells
    // result.currentPiece = t
    return result
}

createNewPiece :: proc(g : ^Grid) {
    colors := COLOR_LIST
    free(g.currentPiece)
    opt_shape := rand.int_max(len(shape.SHAPES))

    apply_rotation := rand.int_max(2)==1? true: false
    opt_color := colors[rand.int_max(len(colors))]
    t := shape.TetrominoBuilder(opt_shape, opt_color, 5, 0)
    if apply_rotation {
        shape.Rotate_piece(t.shape)
    }
    g.currentPiece = t
}

// Update the grid
Update :: proc(g : ^Grid) {
    t := g.currentPiece
    
    if rl.IsKeyPressed(rl.KeyboardKey.UP) {
        // Rotate the piece
        reset_cells(g)
        if !rotate_current_piece(g) {
            rl.TraceLog(rl.TraceLogLevel.INFO, "rotation not possible")
        }
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
        // Drop the piece
    }
    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        reset_cells(g)
        nextX := g.currentPiece.x -1
        if check_collision(g, nextX, g.currentPiece.y, nil) {
            nextX += 1
        }
        g.currentPiece.x = nextX
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        reset_cells(g)
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
            reset_cells(g)
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
                g.cells[i + t.x][j + t.y].value = 2
                g.cells[i + t.x][j + t.y].color = t.color
            }
        }
    }
    clear_rows(g)
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
                if newY >= 0 && g.cells[newX][newY].value == 2 {
                    return true  // Collision with locked piece
                }
            }
        }
    }
    return false
}

reset_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                g.cells[i + t.x][j + t.y].value = 0
            }
        }
    }
}

set_cells :: proc(g : ^Grid) {
    t := g.currentPiece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                g.cells[i + t.x][j + t.y].value = t.shape[i][j]
            }
        }
    }
}

clear_rows :: proc(g : ^Grid) {
    lines_to_clear := make([]bool, g.height)
    defer delete(lines_to_clear)
    
    // Identify full rows
    for row in 0..< g.height {
        full := true
        for col in 0..< g.width {
            if g.cells[col][row].value != 2 {
                full = false
                break
            }
        }
        lines_to_clear[row] = full
    }

    // Count how many lines to clear
    lines_cleared := 0
    for row in 0..< g.height {
        if lines_to_clear[row] {
            lines_cleared += 1
        }
    }

    // If no lines to clear, return early
    if lines_cleared == 0 {
        return
    }

    // Create new grid and copy non-cleared lines
    new_cells := make([][]GridCell, g.width)
    for i in 0..< g.width {
        new_cells[i] = make([]GridCell, g.height)
    }

    new_row := g.height - 1
    for row := g.height - 1; row >= 0; row -= 1 {
        if !lines_to_clear[row] {
            for col in 0..< g.width {
                new_cells[col][new_row] = g.cells[col][row]
            }
            new_row -= 1
        }
    }

    // Fill the top rows with empty cells
    for row in 0..< lines_cleared {
        for col in 0..< g.width {
            new_cells[col][row] = GridCell{value = 0, color = rl.DARKGRAY}
        }
    }

    // Replace the old grid with the new one
    for col in 0..< g.width {
        delete(g.cells[col])
    }
    delete(g.cells)
    g.cells = new_cells

    rl.TraceLog(rl.TraceLogLevel.INFO, "Cleared %d lines", lines_cleared)
}


// Draw the grid
Draw :: proc(g : ^Grid) {

    for col in 0..<g.width {
        for row in 0..<g.height {
            color := rl.DARKGRAY
            if g.cells[col][row].value == 1 {
                color = g.currentPiece.color
            }
            if g.cells[col][row].value == 2 {
                color = g.cells[col][row].color
            }
            rl.DrawRectangle(i32(g.offset.x + f32(col * g.blockSize)), 
            i32(g.offset.y + f32(row * g.blockSize)), 
            i32(g.blockSize -1), 
            i32(g.blockSize -1), 
            color)
        }
    }
}