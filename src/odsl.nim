import class
import api
import json 
import strutils
# kind of possible cells
type CellKind* = enum  # the different node types
  nkInt,          # a cell with an integer value
  nkFloat,        # a cell with a float value
  nkString        # a cell with a string value

  
#[ Implementation of the generic Cell class
which will be the center and target of most language features]#
class Cell * of RootObj:
  var kind* : CellKind
  var intVal*: int
  var floatVal*: float
  var strVal*: string
  proc newCell*(value: string):
      result = Cell(kind: nkString, strVal: value)
  proc newCell*(value: int):
      result = Cell(kind: nkInt, intVal: value)
  proc newCell*(value: float):
      result = Cell(kind: nkFloat, floatVal: value)
     

class Row * of RootObj:
    var items* : seq[Cell]
    proc newRow*(items: seq[Cell]):
        result = Row(items: items)


type 
  TableConstructor* = object
    name* : string
    rows* : seq[Row]

class Table * of RootObj:
    var name* : string
    var rows* : seq[Row]
    proc newTable*(name: string, rows: seq[Row]):
        result = Table(name: name, rows: rows)
    proc newTable*(constructor: TableConstructor):
      result = Table(name: constructor.name, rows: constructor.rows)   
    
# Debugging proc for printing out table information
proc debugTable*(table: Table) = 
  echo ""
  echo "Name:    ", table.name
  echo ""
  echo "Get values:"
  if len(table.rows)  == 0:
    return
  for item in table.rows[0].items:
    write(stdout, "--------")
  write(stdout, "-")
  
  for row in table.rows:
    echo " "
    write(stdout, "|   ")
    for item in row.items:
      case item.kind:
        of nkInt: write(stdout, item.intVal)
        of nkFloat: write(stdout, item.floatVal)
        of nkString: write(stdout, item.strVal)
      write(stdout, "   |   ")
  echo ""
  for item in table.rows[0].items:
    write(stdout, "--------")
  write(stdout, "-")
  echo ""

proc add*(this : Row, x : int) : Row =
  result = this
  result.items.add(newCell(x))

proc add*(this : Row, x : float) : Row =
  result = this
  result.items.add(newCell(x))

proc add*(this : Row, x : string) : Row =
  result = this
  result.items.add(newCell(x))

proc `|` * (x : int, y : int) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : Row, y : int) : Row = 
  result = x.add(y)

proc `|` * (x : int, y : Row) : Row = 
  result = y.add(x)

proc `|` * (x : string, y : string) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : Row, y : string) : Row = 
  result = x.add(y)

proc `|` * (x : string, y : Row) : Row = 
  result = y.add(x)

proc `|` * (x : float, y : float) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : Row, y : float) : Row = 
  result = x.add(y)

proc `|` * (x : float, y : Row) : Row = 
  result = y.add(x)

proc name * (name : string) : string =
  result = name

proc `and` * (x : seq[Row], y : Row) : seq[Row] =
  result = x & @[y]

proc `and` * (x : string, y : seq[Row]) : TableConstructor =
  result.name = x
  result.rows = y

proc `and` * (x : Row, y : Row) : seq[Row] =
  result = @[x, y]

proc with * (constructor : TableConstructor) : TableConstructor =
  result = constructor

proc with * (rows : seq[Row]) : TableConstructor =
  result.name = "Default Name"
  result.rows = rows

proc with * (rows : Row) : TableConstructor =
  result.name = "Default Name"
  result.rows = @[rows]

proc with * (name : string, row : Row) : TableConstructor =
  result.name = name
  result.rows = @[row]

proc create * (table : Table) : Table =
  result = table

proc toSheet * (table : Table) : JsonNode =
    var output : seq[seq[string]]
    # count no of rows
    var rowDepth = 0
    # count no of max items in a single row
    var maxColDepth = 0
    # go through all rows
    for row in table.rows:
        # temporary storage for row
        var outRow : seq[string]
        # increment rows
        rowDepth = rowDepth + 1 
        # temporary item counter
        var colDepth = 0
        for item in row.items:
            case item.kind:
                of nkInt: outRow.add($item.intVal)
                of nkFloat: outRow.add($item.floatVal)
                of nkString: outRow.add(item.strVal)  
            colDepth = colDepth + 1 
        # if temporary counter is the new max it is the new standard
        if colDepth > maxColDepth:
          maxColDepth = colDepth
        
        output.add(outRow)
    # write result json which will be posted
    var col = toUpperAscii(char(maxColDepth+96))
    var ro = $rowDepth
    var rangeString ="testSheet!A1:"
    rangeString.add(col)
    rangeString.add(ro)
    result = %* {"range": rangeString,"majorDimension":"ROWS", "values" : %* output }
    # post json
    writeSheet(result)
    echo result
