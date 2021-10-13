import unittest
import ../feta
import tables
import json 
import strutils

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

test "rename column from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.renameColumn("First", "AlsoFirst")

    check testSpreadsheet.header.items[0].strVal == "AlsoFirst"

test "get Cell from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check testSpreadsheet[0, 0].strVal == "1"

test "get Cell from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check testSpreadsheet["First", 0].strVal == "1"

test "get Cell from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check testSpreadsheet[0, "First"].strVal == "1"

test "get Column from spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check testSpreadsheet["First"][0] == "1"

test "get length of spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check len(testSpreadsheet) == 1

test "get column length of spreadsheet":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    check colLen(testSpreadsheet) == 3

test "set new value":
    var name = "TestName"
    var header = "First" | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)
    testSpreadsheet.setNewValue(0, "First", "11")

    check testSpreadsheet[0, "First"].strVal == "11"

test "join two tables":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)
    
    var name2 = "TestName2"
    var header2 = "Index" | "Second2" | "Third2"
    var rows2 = @[1 | "Two" | "Three"]

    var testSpreadsheet2 = newSpreadSheet(name2, rows2, header2)

    testSpreadsheet.joinSpreadsheets(testSpreadsheet2, "Index")

    check testSpreadsheet[0, "Second2"].strVal == "Two"
    check testSpreadsheet[0, "Third2"].strVal == "Three"
    check testSpreadsheet[0, "Second"].strVal == "2"
    check testSpreadsheet[0, "Third"].strVal == "3"
    check testSpreadsheet[0, "Index"].strVal == "1"


test "set permissions on table":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.setNewPermissions("testRole", @["Index", "Third"])
    
    check testSpreadsheet.permissions["testRole"]["Index"]  == testSpreadsheet.permissions["testRole"]["Third"] == true
    check testSpreadsheet.permissions["testRole"]["Second"] == false

test "set permissions on table DSL":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    testSpreadsheet.SET_PERMISSIONS:
        USER:
            "testRole"
        PERMIT:
            @["Index", "Third"]
            
    check testSpreadsheet.permissions["testRole"]["Index"]  == testSpreadsheet.permissions["testRole"]["Third"] == true
    check testSpreadsheet.permissions["testRole"]["Second"] == false

test "convert to JSON":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    var testJson = testSpreadsheet.toJSON()
    
    check $testJson["name"] == "\"TestName\""
    check $testJson["values"][0][0] == "\"Index\""
    check $testJson["values"][0][1] == "\"Second\""
    check $testJson["values"][0][2] == "\"Third\""
    check $testJson["values"][1][0] == "\"1\""
    check $testJson["values"][1][1] == "\"2\""
    check $testJson["values"][1][2] == "\"3\""

test "convert to htmlform":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    var testHTML = testSpreadsheet.generateHTMLForm()
    check testHTML.strip() == """<html>
                <head>
                  <style>
                    table, th, td {
                      border: 1px solid black;
                      border-collapse: collapse;
                    }
                    th, td {
                      padding: 15px;
                      text-align: left;
                    }
                  </style>

                  <script src=
                    "https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js">
                  </script>
                  <script src="https://cdn.jsdelivr.net/npm/table-to-json@1.0.0/lib/jquery.tabletojson.min.js" integrity="sha256-H8xrCe0tZFi/C2CgxkmiGksqVaxhW0PFcUKZJZo1yNU=" crossorigin="anonymous"></script>

                </head> 

                <body>
                  <table style="width:100%" id="table">
                          <tr id="row">
        <th bgcolor='#FF8484'> Index</th><th bgcolor='#FF8484'> Second</th><th bgcolor='#FF8484'> Third</th>      </tr>
            <tr id="row">
        <th bgcolor='#FF8484'> 1</th><th bgcolor='#FF8484'> 2</th><th bgcolor='#FF8484'> 3</th>      </tr>
                        </table>
                  <button id="save">Save Changes</button>

                  <script type="text/javascript">

                $('#save').on('click', function(){

                  var table = JSON.stringify($('#table').tableToJSON())
                  let ws = new WebSocket("ws://localhost:5000/ws");
                  ws.onmessage = function(evnt) {
                    console.log(evnt.data);
                  }
                  var url_string = window.location.href
                  var url = new URL(url_string);
                  var c = url.searchParams.get("id");
                  var message = c.concat(" ", table)
                  console.log(message);
                  ws.onopen = function(evnt) {
                    ws.send(message);
                    ws.onmessage = function(msg){
                      console.log(msg.data);
                        if(msg.data != "success")
                          alert(msg.data);
                          window.location.reload(true); 
                      }
                  return true;
                }
                  });
                  </script>
                </body>
                </html>"""

test "convert to htmlview":
    
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    var testHTML = testSpreadsheet.generateHTMLView()
    check testHTML.strip() == """<html>
                <head>
                  <style>
                    table, th, td {
                      border: 1px solid black;
                      border-collapse: collapse;
                    }
                    th, td {
                      padding: 15px;
                      text-align: left;
                    }
                  </style>

                  <script src=
                    "https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js">
                  </script>
                </head> 

                <body>
                  <table style="width:100%">
                          <tr id="row">
        <th bgcolor='#FF8484'> Index</th><th bgcolor='#FF8484'> Second</th><th bgcolor='#FF8484'> Third</th>      </tr>
            <tr id="row">
        <th bgcolor='#FF8484'> 1</th><th bgcolor='#FF8484'> 2</th><th bgcolor='#FF8484'> 3</th>      </tr>
                        </table>
                </body>
                </html>"""

test "convert to JSON":
    var name = "TestName"
    var header = "Index"  | "Second" | "Third"
    var rows = @[1 | 2 | 3]

    var testSpreadsheet = newSpreadSheet(name, rows, header)

    var testJson = testSpreadsheet.toJSON()
    
    check $testJson["name"] == "\"TestName\""
    check $testJson["values"][0][0] == "\"Index\""
    check $testJson["values"][0][1] == "\"Second\""
    check $testJson["values"][0][2] == "\"Third\""
    check $testJson["values"][1][0] == "\"1\""
    check $testJson["values"][1][1] == "\"2\""
    check $testJson["values"][1][2] == "\"3\""