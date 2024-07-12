package shape

import rl "vendor:raylib"

//Tetromino shapes
// Define the Tetromino structure
Tetromino :: struct {
    shape: [][]bool,
    color: rl.Color,
    x, y: int,
}

// Define the shapes
SHAPES :: [][][]bool{
    {{true, true, true, true}},
    {{true, true}, {true, true}},
    {{true, true, true}, {false, true, false}},
    {{true, true, true}, {true, false, false}},
    {{true, true, true}, {false, false, true}},
    {{true, true, false}, {false, true, true}},
    {{false, true, true}, {true, true, false}},
}

TetrominoBuilder :: proc(shapeIndex: int, color: rl.Color, x: int, y: int) -> Tetromino {
    shapes := SHAPES
    s := make([][]bool, len(shapes[shapeIndex]))
    for i in 0..< len(shapes[shapeIndex]) {
        s[i] = make([]bool, len(shapes[shapeIndex][i]))
        for j in 0..< len(shapes[shapeIndex][i]) {
            s[i][j] = shapes[shapeIndex][i][j]
        }
    }
    result := Tetromino{
        shape = s,
        color = color,
        x = x,
        y = y,
    }
    for i in 0..< len(s) {
        for j in 0..< len(s[i]) {
            row := s[i]
            rl.TraceLog(rl.TraceLogLevel.INFO, "cell: %b", row[j])
        }
    }
    return result
}