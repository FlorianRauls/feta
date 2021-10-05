import unittest
import ../src/feta

test "create string cell":
    var testCell = newCell("test")
    check testCell.strVal == "test"
    check testCell.kind == CellKind.nkString

test "create integer cell":
    var testCell = newCell(123)
    check testCell.strVal == "123"
    check testCell.intVal == 123
    check testCell.kind == CellKind.nkInt

test "create float cell":
    var testCell = newCell(123.123)
    check testCell.strVal == "123.123"
    check testCell.floatVal == 123.123
    check testCell.kind == CellKind.nkFloat

test "create empty cell":
    var x : Nil
    var testCell = newCell(x)
    check testCell.kind == CellKind.nkEmpty

test "create new Row":
    var x : seq[Cell]
    var testRow = newRow(x)
    check len(testRow.items) == 0

test "create new Row from values":
    var cellOne : Cell
    var cellTwo : Cell
    var testRow = newRow(@[cellOne, cellTwo])
    check testRow.items[0] == cellOne
    check testRow.items[1] == cellTwo

