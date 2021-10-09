import unittest
import ../feta

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
    check testCell.strVal == "-"

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

test "create new Row from values via Operator: int | string":
    var cellOne = 5
    var cellTwo = "5"
    var testRow = cellOne | cellTwo

    check testRow.items[0].intVal == 5
    check testRow.items[1].strVal == "5"

test "create new Row from values via Operator: string | int":
    var cellOne = "5"
    var cellTwo = 5
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "5"
    check testRow.items[1].intVal == 5


test "create new Row from values via Operator: string | string":
    var cellOne = "5"
    var cellTwo = "5"
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "5"
    check testRow.items[1].strVal == "5"

test "create new Row from values via Operator: int | int":
    var cellOne = 5
    var cellTwo = 5
    var testRow = cellOne | cellTwo

    check testRow.items[0].intVal == 5
    check testRow.items[1].intVal == 5


test "create new Row from values via Operator: int | float":
    var cellOne = 5
    var cellTwo = 5.5
    var testRow = cellOne | cellTwo

    check testRow.items[0].intVal == 5
    check testRow.items[1].floatVal == 5.5

test "create new Row from values via Operator: float | int":
    var cellOne = 5.5
    var cellTwo = 5
    var testRow = cellOne | cellTwo

    check testRow.items[0].floatVal == 5.5
    check testRow.items[1].intVal == 5


test "create new Row from values via Operator: float | float":
    var cellOne = 5.5
    var cellTwo = 5.5
    var testRow = cellOne | cellTwo

    check testRow.items[0].floatVal == 5.5
    check testRow.items[1].floatVal == 5.5


test "create new Row from values via Operator: str | float":
    var cellOne = 5
    var cellTwo = 5.5
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "5"
    check testRow.items[1].floatVal == 5.5

test "create new Row from values via Operator: float | str":
    var cellOne = 5.5
    var cellTwo = 5
    var testRow = cellOne | cellTwo

    check testRow.items[0].floatVal == 5.5
    check testRow.items[1].strVal == "5"

test "create new Row from values via Operator: null | null":
    var cellOne = null
    var cellTwo = null
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "-"
    check testRow.items[1].strVal == "-"


test "create new Row from values via Operator: str | null":
    var cellOne = 5
    var cellTwo = null
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "5"
    check testRow.items[1].strVal == "-"

test "create new Row from values via Operator: null | str":
    var cellOne = null
    var cellTwo = 5
    var testRow = cellOne | cellTwo

    check testRow.items[0].strVal == "-"
    check testRow.items[1].strVal == "5"

test "get values from Row":
    var cellOne = null
    var cellTwo = 5
    var testRow = cellOne | cellTwo
    var testSeq = getValues(testRow)

    check testSeq[0] == "-"
    check testSeq[1] == "5"

test "create new spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check testSpreadsheet.name == "TestName"
    check testSpreadsheet.header == header
    check testSpreadsheet.rows == rows

test "add column to spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.addColumn("Fourth" | 4)

    check testSpreadsheet.header.items[3].strVal == "Fourth"
    check testSpreadsheet.rows[0].items[3].strVal == "4"

test "remove column from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.removeColumn("Second")

    check testSpreadsheet.header.items[1].strVal == "Third"
    check testSpreadsheet.rows[0].items[1].strVal == "3"


test "add row to spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.addRow(4 | 5 | 6)

    check testSpreadsheet.rows[1].items[0].strVal == "4"
    check testSpreadsheet.rows[1].items[1].strVal == "5"
    check testSpreadsheet.rows[1].items[2].strVal == "6"

test "remove row from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.removeRow(0)

    check len(testSpreadsheet) == 0