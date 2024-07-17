package shape

import rl "vendor:raylib"

//Tetromino shapes
// Define the Tetromino structure
Tetromino :: struct {
    shape: [][]int,
    color: rl.Color,
    x, y: int,
}

// Define the shapes
SHAPES :: [][][]int{
    {{1, 1, 1, 1}}, // I
    {{1, 1}, {1, 1}},
    {{1, 1, 1}, {0, 1, 0}},
    {{1, 1, 1}, {1, 0, 0}},
    {{1, 1, 1}, {0, 0, 1}},
    {{1, 1, 0}, {0, 1, 1}},
    {{0, 1, 1}, {1, 1, 0}},
}

TetrominoBuilder :: proc(shapeIndex: int, color: rl.Color, x: int, y: int) -> ^Tetromino {
    shapes := SHAPES
    s := make([][]int, len(shapes[shapeIndex]))
    for i in 0..< len(shapes[shapeIndex]) {
        s[i] = make([]int, len(shapes[shapeIndex][i]))
        for j in 0..< len(shapes[shapeIndex][i]) {
            s[i][j] = shapes[shapeIndex][i][j]
        }
    }
    t := new(Tetromino)
    t.shape = s
    t.color = color
    t.x = x
    t.y = y
    // t := &Tetromino{
    //     shape = s,
    //     color = color,
    //     x = x,
    //     y = y,
    // }
    for i in 0..< len(s) {
        for j in 0..< len(s[i]) {
            row := s[i]
            rl.TraceLog(rl.TraceLogLevel.INFO, "cell: %b", row[j])
        }
    }
    return t
}

Rotate_piece :: proc(shape: [][]int) -> [][]int {
    rows := len(shape)
    cols := len(shape[0])
    
    // Create a new shape with swapped dimensions
    new_shape := make([][]int, cols)
    for i in 0..<cols {
        new_shape[i] = make([]int, rows)
    }
    
    // Perform the rotation
    for i in 0..<rows {
        for j in 0..<cols {
            new_shape[j][rows-1-i] = shape[i][j]
        }
    }
    
    return new_shape
}

