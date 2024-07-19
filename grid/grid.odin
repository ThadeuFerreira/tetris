package grid

import rl "vendor:raylib"
import "core:math/rand"
import "core:math"
import "../shape"

// Grid
Grid :: struct {
    width, height: int,
    blockSize: int,
    cells: [][]GridCell,
    offset: rl.Vector2,

    backgroundColor: rl.Color,
    current_piece: ^shape.Tetromino,
    next_piece: ^shape.Tetromino,

    points: int,
    fall_speed: f32,
    level: int,
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

globalTimeCounter : f32 = 0.0

GridBuilder :: proc(width : int, height : int, blockSize: int, offset: rl.Vector2, backgroundColor: rl.Color) -> Grid {
    g := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset = offset,
        backgroundColor = backgroundColor,
    }
    g.current_piece = createNewPiece()
    g.next_piece = createNewPiece()
    cells := make([][]GridCell, width)
    for i in 0..< width {
        cells[i] = make([]GridCell, height)
    }
    g.fall_speed = 2
    g.level = 1

    g.cells = cells
    return g
}

createNewPiece :: proc() -> ^shape.Tetromino {
    colors := COLOR_LIST
    
    opt_shape := rand.int_max(len(shape.SHAPES))

    apply_rotation := rand.int_max(2)==1? true: false
    opt_color := colors[rand.int_max(len(colors))]
    t := shape.TetrominoBuilder(opt_shape, opt_color, 5, -2)
    if apply_rotation {
        shape.Rotate_piece(t.shape)
    }
    return t
}

// Update the grid
Update :: proc(g : ^Grid) {
    t := g.current_piece
    
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
        reset_cells(g)
        for {
            nextY := g.current_piece.y + 1
            if check_collision(g, g.current_piece.x, nextY, nil) {
                break
            }
            g.current_piece.y = nextY
        }
    }
    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        reset_cells(g)
        nextX := g.current_piece.x -1
        if check_collision(g, nextX, g.current_piece.y, nil) {
            nextX += 1
        }
        g.current_piece.x = nextX
        set_cells(g)
    }
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        reset_cells(g)
        nextX := g.current_piece.x +1
        if check_collision(g, nextX, g.current_piece.y, nil) {
            nextX -= 1
        }
        g.current_piece.x = nextX
        set_cells(g)
    }
    // Move the piece down
    globalTimeCounter += rl.GetFrameTime()
    if globalTimeCounter >= 1/g.fall_speed {
        
        if check_collision(g, g.current_piece.x, g.current_piece.y + 1, nil) {
            if !lock_piece(g){
                rl.TraceLog(rl.TraceLogLevel.INFO, "Game Over")
                reset_grid(g)
            }
            g.current_piece = g.next_piece
            g.next_piece = createNewPiece()
        }
        else{
            reset_cells(g)
            currentY := g.current_piece.y
            g.current_piece.y = currentY + 1
            globalTimeCounter = 0.0
            set_cells(g)   
        }
    }
    
}

reset_grid :: proc(g : ^Grid) {
    for i in 0..< g.width {
        for j in 0..< g.height {
            g.cells[i][j] = GridCell{value = 0, color = rl.DARKGRAY}
        }
    }
}

rotate_current_piece :: proc(g: ^Grid) -> bool {
    t := g.current_piece
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


lock_piece :: proc(g : ^Grid) -> bool {
    t := g.current_piece
    for row in 0..< len(t.shape) {
        for col in 0..< len(t.shape[row]) {
            if t.shape[row][col] == 1 {
                newX := t.x + row
                newY := t.y + col
                if newX < 0 || newX >= g.width || newY >= g.height || newY < 0 {
                    return false  // Out of bounds
                }
                g.cells[newX][newY].value = 2
                g.cells[newX][newY].color = t.color
            }
        }
    }
    clear_rows(g)
    return true
}

check_collision :: proc(g: ^Grid, x: int, y: int, piece: ^shape.Tetromino) -> bool {
    t := piece if piece != nil else g.current_piece
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
    t := g.current_piece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                cell_x := i + t.x
                cell_y := j + t.y
                if cell_x >= 0 && cell_x < g.width && cell_y >= 0 && cell_y < g.height {
                    g.cells[cell_x][cell_y].value = 0
                }
            }
        }
    }
}

set_cells :: proc(g : ^Grid) {
    t := g.current_piece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1{
                cell_x := i + t.x
                cell_y := j + t.y
                if cell_x >= 0 && cell_x < g.width && cell_y >= 0 && cell_y < g.height {
                    g.cells[cell_x][cell_y].value = t.shape[i][j]
                }
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
    speed_bonus := int(math.floor(g.fall_speed/2))
    g.points += lines_cleared * 10 * lines_cleared*speed_bonus
    level_trashold := int(math.pow10_f32(f32(g.level + 1)))
    if g.points >= level_trashold {
        g.level += 1
        g.fall_speed += 0.5
    }
}


// Draw the grid
Draw :: proc(g : ^Grid) {

    draw_play_grid(g)
    draw_next_piece(g)
}

draw_play_grid :: proc(g : ^Grid) {
    for col in 0..<g.width {
        for row in 0..<g.height {
            color := rl.DARKGRAY
            if g.cells[col][row].value == 1 {
                color = g.current_piece.color
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

draw_next_piece :: proc(g : ^Grid) {
    t := g.next_piece
    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            if t.shape[i][j] == 1 {
                rl.DrawRectangle(i32(120 + f32((g.width + 2 + i) * g.blockSize)), 
                i32(150 + f32((j + 2) * g.blockSize)), 
                i32(g.blockSize -1), 
                i32(g.blockSize -1), 
                t.color)
            }
        }
    }
}