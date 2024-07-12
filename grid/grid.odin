package grid

import rl "vendor:raylib"
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

GridBuilder :: proc(width : int, height : int, blockSize: int, offset: rl.Vector2, backgroundColor: rl.Color) -> Grid {
    result := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset = offset,
        backgroundColor = backgroundColor,
    }
    t := shape.TetrominoBuilder(0, rl.RED, 0, 0)
    cells := make([][]bool, width)
    for i in 0..< width {
        cells[i] = make([]bool, height)
    }

    for i in 0..< len(t.shape) {
        for j in 0..< len(t.shape[i]) {
            cells[i + t.x][j + t.y] = t.shape[i][j]
        }
    }
    result.cells = cells
    return result
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