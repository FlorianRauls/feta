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
type 
  Cell * = object
    kind* : CellKind
    intVal*: int
    floatVal*: float
    strVal*: string

proc newCell*(value: string): Cell =
    result = Cell(kind: nkString, strVal: value)
proc newCell*(value: int): Cell =
    result = Cell(kind: nkInt, intVal: value)
proc newCell*(value: float): Cell =
    result = Cell(kind: nkFloat, floatVal: value)
     
#[ Implementation of the generic Row class
which will be the center and target of most language features]#
type 
  Row * = object
    items* : seq[Cell]

proc newRow*(items: seq[Cell]): Row =
    result = Row(items: items)

#[ Implementation of the generic TableConstructer type
    will be used as a stand in for tables when needed]#
type 
  TableConstructor* = object
    name* : string
    rows* : seq[Row]

# just for sytnax reasons here
proc header * (row : Row) : Row =
  result = row


#[ Implementation of the generic Table class
which will be the center and target of most language features]#
type
  Table * = object
    name* : string
    rows* : seq[Row]
    hasHeader* : bool
    header* : Row
    longestItems* : seq[int]

# Table Constructor
# TO-DO: Debloat this function such that the pretty-debug functionality happens
# in a seperate function!
proc newTable*(name: string, rows: seq[Row], header : Row): Table =
  var hasHeader = false
  if len(header.items) > 0:
    hasHeader = true
  #################this section happens to ensure readable debug screens####################
  var candidates : seq[int]
  for row in rows:
    for i, item in pairs(row.items):
      var current = 0
      if len(candidates) < i+1:
        candidates.add(0)
      case item.kind:
        of nkInt: current = len($item.intVal)
        of nkFloat: current = len($item.floatVal)
        of nkString: current = len($item.strVal)
      if current > candidates[i]:
        candidates[i] = current

  if hasHeader:
    for i, item in pairs(header.items):
      var current = 0
      case item.kind:
        of nkInt: current = len($item.intVal)
        of nkFloat: current = len($item.floatVal)
        of nkString: current = len($item.strVal)
      if current > candidates[i]:
        candidates[i] = current
        # READABLE DEBUGS END #############################
    result = Table(name: name, rows: rows, longestItems: candidates, hasHeader: hasHeader, header: header)  
  else:
    result = Table(name: name, rows: rows[1..len(rows)-1], longestItems: candidates, hasHeader: hasHeader, header: rows[0])

proc pad(input : string, padTo: int) : string =
  var goal = padTo 
  result = input
  for i in len(input)..goal:
    result = ' ' &  result 



# Debugging proc for printing out table information
# TO-DO: DO THIS BETTER!
proc debugTable*(table: Table) = 
  echo ""
  echo "Name:    ", table.name
  if len(table.rows)  == 0:
    return

  # First Delimiter
  for i in table.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  echo ""
  # Header Section
  write(stdout, "|   ")
  for i, item in pairs(table.header.items):
    case item.kind:
      of nkInt: write(stdout, pad($item.intVal, table.longestItems[i]))
      of nkFloat: write(stdout, pad($item.floatVal, table.longestItems[i]))
      of nkString: write(stdout, pad(item.strVal, table.longestItems[i]))
    write(stdout, "   |   ")
  echo ""
  # Second Delimiter
  for i in table.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  # Table Entries Section
  
  for row in table.rows:
    echo " "
    write(stdout, "|   ")
    for i, item in pairs(row.items):
      case item.kind:
        of nkInt: write(stdout, pad($item.intVal, table.longestItems[i]))
        of nkFloat: write(stdout, pad($item.floatVal, table.longestItems[i]))
        of nkString: write(stdout, pad(item.strVal, table.longestItems[i]))
      write(stdout, "   |   ")
  echo ""
  # Last Delimiter
  for i in table.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  echo ""
  echo ""
  echo ""

#################### OVERLOADING SECTION ###############################
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

proc `|` * (x : int, y : string) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : string, y : int) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

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

#################### OVERLOADING SECTION END ###########################

# take a Table Object and create a JSON response from it
# TO-DO: This implementation is not generic enough and has to be changed in the future!
proc toJSONBody * (table : Table) : JsonNode =
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
    

# interface to use debugTable
proc show*(table:Table) =
  debugTable(table)

# Atomic Action: Delete Column
proc removeColumn * (table : var Table, toDelete : string) =
  var names : seq[string]
  for i in table.header.items:
    names.add(i.strVal)
  if toDelete in names:
    var found = names.find(toDelete)
    for i in 0..len(table.rows)-1:
      delete(table.rows[i].items, found)
    table.header.items.delete(found)
    table = newTable(table.name, table.rows, table.header)
  else:
    echo "\"" & toDelete & "\"" & " is not a valid column in Spreadsheet " &  "\"" & table.name & "\"" 

# Atomic ACtion: Delete Column Operator
proc `-=` * (table : var Table, toDelete : string) =
  removeColumn(table, toDelete)


# Atomic Action : Rename Table
proc renameSpreadsheet * (table : var Table, newName : string) = 
  table.name = newName

# Atomic Action : Rename Table Operator
proc `:=` * (table : var Table, newName : string) = 
  renameSpreadsheet(table, newName)


# Atomic Action : Rename Column
proc renameColumn * (table : var Table, oldName : string, newName : string) =
  for i in 0..len(table.header.items)-1:
    if table.header.items[i].strVal == oldName:
      table.header.items[i] = newCell(newName)
  table = newTable(table.name, table.rows, table.header)
