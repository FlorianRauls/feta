import googleapi
import json 
import strutils
import tables
import sequtils
from mailFunc import mailBot
import strformat

# Custom Made NaN type for internal representation
type
  Nil* = object
    needsVal : int

var null* : Nil

# kind of possible cells
type CellKind* = enum  # the different node types
  nkInt,          # a cell with an integer value
  nkFloat,        # a cell with a float value
  nkString,        # a cell with a string value
  nkEmpty         # an empty cell

  
#[ Implementation of the generic Cell class
which will be the center and target of most language features]#
type 
  Cell * = ref object
    kind* : CellKind
    intVal*: int
    floatVal*: float
    strVal*: string

proc newCell*(value: string): Cell =
    result = Cell(kind: nkString, strVal: value)
proc newCell*(value: int): Cell =
    result = Cell(kind: nkInt, intVal: value, strVal: $value)
proc newCell*(value: float): Cell =
    result = Cell(kind: nkFloat, floatVal: value, strVal: $value)
proc newCell*(value: Nil): Cell =
    result = Cell(kind: nkEmpty, strVal: "-")
     
#[ Implementation of the generic Row class
which will be the center and target of most language features]#
type 
  Row * = object
    items* : seq[Cell]
      
proc newRow*(items: seq[Cell]): Row =
    result = Row(items: items)

# just for sytnax reasons here
proc header * (row : Row) : Row =
  result = row


#[ Implementation of the generic SpreadSheet class
which will be the center and target of most language features]#
type
  SpreadSheet * = object
    name* : string
    rows* : seq[Row]
    hasHeader* : bool
    header* : Row
    longestItems* : seq[int]
    longestRow* : int 
    permissions* : Table[string, Table[string, bool]]

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

proc add*(this : Row, x : Nil) : Row =
  result = this
  result.items.add(newCell(x))

#################### OVERLOADING SECTION END ###############################

# pad row with NaN-Cells
proc padRow(row : var Row, diff : int)=
  for i in 0..diff-1:
    row = row.add(null)

# SpreadSheet Constructor
# TO-DO: Debloat this function such that the pretty-debug functionality happens
# in a seperate function!
# TO-DO: Ensure SpreadSheet Integrity via security checks!
# --> This should be done via Empty Cell Entries
proc newSpreadSheet*(name: string, rows: seq[Row], header : Row): SpreadSheet =
  var hasHeader = false
  var lonRow = 0
  if len(header.items) > 0:
    hasHeader = true

    # search for longest row to ensure integrity
    if len(header.items) > lonRow:
      lonRow = len(header.items)

  #################this section happens to ensure readable debug screens####################
  var candidates : seq[int]
  for row in rows:
    # search for longest row to ensure integrity
    if len(row.items) > lonRow: lonRow = len(row.items)

    for i, item in pairs(row.items):
      var current = 0
      if len(candidates) < i+1:
        candidates.add(0)
      case item.kind:
        of nkInt: current = len($item.intVal)
        of nkFloat: current = len($item.floatVal)
        of nkString: current = len($item.strVal)
        of nkEmpty: current = len("-")
      if current > candidates[i]:
        candidates[i] = current

  # ensure same length of rows
  var copyRows = rows
  for i, row in pairs(rows):
    # if the row is not the same lenght as the longest row
    if len(row.items) < lonRow:
      # padRow
      padRow(copyRows[i], lonRow-len(row.items))

  if hasHeader:
    for i, item in pairs(header.items):
      var current = 0
      if len(candidates) < i+1:
        candidates.add(0)
      case item.kind:
        of nkInt: current = len($item.intVal)
        of nkFloat: current = len($item.floatVal)
        of nkString: current = len($item.strVal)
        of nkEmpty: current = len("-")
      if current > candidates[i]:
        candidates[i] = current
        # READABLE DEBUGS END #############################

    var copyHeader = header
    if len(header.items) < lonRow:
      copyHeader.padRow(lonRow-len(header.items))
   
    result = SpreadSheet(name: name, rows: copyRows, longestItems: candidates, hasHeader: hasHeader, header: copyHeader, longestRow: lonRow)  
  else:
    result = SpreadSheet(name: name, rows: copyRows[1..len(rows)-1], longestItems: candidates, hasHeader: hasHeader, header: rows[0], longestRow: lonRow)
    
  # set Universal permissions from the start
  result.permissions["UNIVERSAL"] = {"placeholder": true}.toTable
  result.permissions["UNIVERSAL"].del("placeholder")
  for entry in result.header.items:
    result.permissions["UNIVERSAL"][entry.strVal] = true



# helper function which takes a string and an integer
# and pads the string with Spaces on both sides
# until it is as long as the integer
proc pad(input : string, padTo: int) : string =
  var goal = padTo 
  result = input
  for i in len(input)..goal:
    result = ' ' &  result 



# Debugging proc for printing out SpreadSheet information
# TO-DO: DO THIS BETTER!
proc debugSpreadSheet*(SpreadSheet: SpreadSheet) = 
  echo ""
  echo "Name:    ", SpreadSheet.name
  if len(SpreadSheet.rows)  == 0:
    return

  # First Delimiter
  for i in SpreadSheet.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  echo ""
  # Header Section
  write(stdout, "|   ")
  for i, item in pairs(SpreadSheet.header.items):
    case item.kind:
      of nkInt: write(stdout, pad($item.intVal, SpreadSheet.longestItems[i]))
      of nkFloat: write(stdout, pad($item.floatVal, SpreadSheet.longestItems[i]))
      of nkString: write(stdout, pad(item.strVal, SpreadSheet.longestItems[i]))
      of nkEmpty: write(stdout, pad("-", SpreadSheet.longestItems[i]))
    write(stdout, "   |   ")
  echo ""
  # Second Delimiter
  for i in SpreadSheet.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  # SpreadSheet Entries Section
  
  for row in SpreadSheet.rows:
    echo " "
    write(stdout, "|   ")
    for i, item in pairs(row.items):
      case item.kind:
        of nkInt: write(stdout, pad($item.intVal, SpreadSheet.longestItems[i]))
        of nkFloat: write(stdout, pad($item.floatVal, SpreadSheet.longestItems[i]))
        of nkString: write(stdout, pad(item.strVal, SpreadSheet.longestItems[i]))
        of nkEmpty: write(stdout, pad("-", SpreadSheet.longestItems[i]))
      write(stdout, "   |   ")
  echo ""
  # Last Delimiter
  for i in SpreadSheet.longestItems:
    for z in 0..i+7:
      write(stdout, "-")
  write(stdout, "-")
  echo ""
  echo ""
  echo ""


######################### OVERLOADING SECTION ################################

proc `|` * (x : int, y : int) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : string, y : string) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : float, y : float) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : int, y : string) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : string, y : int) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : Nil, y : int) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : string, y : Nil) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : int, y : Nil) : Row = 
  result = newRow(@[newCell(x), newCell(y)])

proc `|` * (x : Nil, y : string) : Row = 
  result = newRow(@[newCell(x), newCell(y)])


proc `|` * (x : Row, y : int) : Row = 
  result = x.add(y)

proc `|` * (x : int, y : Row) : Row = 
  result = y.add(x)


proc `|` * (x : Row, y : string) : Row = 
  result = x.add(y)

proc `|` * (x : string, y : Row) : Row = 
  result = y.add(x)

proc `|` * (x : Row, y : float) : Row = 
  result = x.add(y)

proc `|` * (x : float, y : Row) : Row = 
  result = y.add(x)

proc `|` * (x : Nil, y : Row) : Row = 
  result = y.add(x)

proc `|` * (x : Row, y : Nil) : Row = 
  result = x.add(y)

proc `|` * (x : Row, y : Row) : Row = 
  result.items = x.items.concat(y.items)

proc `and` * (x : seq[Row], y : Row) : seq[Row] =
  result = x & @[y]

proc `and` * (x : Row, y : Row) : seq[Row] =
  result = @[x, y]

proc create * (SpreadSheet : SpreadSheet) : SpreadSheet =
  result = SpreadSheet

#################### OVERLOADING SECTION END ###########################

# take a SpreadSheet Object and create a JSON response from it
# TO-DO: This implementation is not generic enough and has to be changed in the future!
proc toJSONBody * (SpreadSheet : SpreadSheet) : JsonNode =
    var output : seq[seq[string]]
    # count no of rows
    var rowDepth = 0
    # count no of max items in a single row
    var maxColDepth = 0
    # go through all rows
    for row in SpreadSheet.rows:
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
                of nkEmpty: outRow.add("-") 
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
    

# interface to use debugSpreadSheet
proc show*(SpreadSheet:SpreadSheet) =
  debugSpreadSheet(SpreadSheet)

# helper function which returns the integer index of a header by name
proc getColumnIndex(SpreadSheet : SpreadSheet, colName : string) : int =
    var names : seq[string]
    for i in SpreadSheet.header.items:
      names.add(i.strVal)
    if colName in names:
      var found = names.find(colName)
      result = found
    else:
      raise newException(OSError, colName & " is not in Spreadsheet " & SpreadSheet.name)

# Atomic Action: Delete Column
proc removeColumn * (SpreadSheet : var SpreadSheet, toDelete : string) =
  var found = getColumnIndex(SpreadSheet, toDelete)
  for i in 0..len(SpreadSheet.rows)-1:
    delete(SpreadSheet.rows[i].items, found)
  SpreadSheet.header.items.delete(found)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

# Atomic ACtion: Delete Column Operator
proc `-=` * (SpreadSheet : var SpreadSheet, toDelete : string) =
  removeColumn(SpreadSheet, toDelete)

# Atomic Action: Delete Column
proc removeRow * (SpreadSheet : var SpreadSheet, toDelete : int) =
  SpreadSheet.rows.delete(toDelete)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)


# Atomic ACtion: Delete Row Operator
proc `-=` * (SpreadSheet : var SpreadSheet, toDelete : int) =
  removeRow(SpreadSheet, toDelete)


# Atomic Action : Rename SpreadSheet
proc renameSpreadsheet * (SpreadSheet : var SpreadSheet, newName : string) = 
  SpreadSheet.name = newName

# Atomic Action : Rename SpreadSheet Operator
proc `:=` * (SpreadSheet : var SpreadSheet, newName : string) = 
  renameSpreadsheet(SpreadSheet, newName)


# Atomic Action : Rename Column
proc renameColumn * (SpreadSheet : var SpreadSheet, oldName : string, newName : string) =
  for i in 0..len(SpreadSheet.header.items)-1:
    if SpreadSheet.header.items[i].strVal == oldName:
      SpreadSheet.header.items[i] = newCell(newName)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

# index SpreadSheet
proc `[]` * (SpreadSheet : SpreadSheet, r, c: int): Cell =
  result = SpreadSheet.rows[r].items[c] 


# index SpreadSheet
proc `[]` * (SpreadSheet : SpreadSheet, r : int, c: string): Cell =
  var colInd = getColumnIndex(SpreadSheet, c)
  result = SpreadSheet.rows[r].items[colInd] 



# Atomic Action: Add Column
proc addColumn * (SpreadSheet : var SpreadSheet, name = "NaN", toAdd : Row) =
  SpreadSheet.header.items.add(newCell(name))
  for i, item in pairs(toAdd.items):
    case item.kind:
        of nkInt: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.intVal)
        of nkFloat: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.floatVal)
        of nkString: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.strVal) 
        of nkEmpty: SpreadSheet.rows[i] =  SpreadSheet.rows[i].add(null) 
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

# Atomic Action: Add Row
proc addRow * (SpreadSheet: var SpreadSheet, row : Row) =
  SpreadSheet.rows.add(row)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

proc `+=` * (SpreadSheet: var SpreadSheet, row : Row) =
  SpreadSheet.addRow(row)

# Atomic Action : Update Value Operator
proc `:=` * (cell : var Cell, newEntry : string) = 
  cell.strVal = newEntry
 # cell = newCell(newEntry)

# Atomic Action : Update Value
proc setNewValue * (SpreadSheet : var SpreadSheet,  r : int, c: string, newValue : string ) =
  var colInd = getColumnIndex(SpreadSheet, c)
  SpreadSheet.rows[r].items[colInd] = newCell(newValue)

# Helper function which transforms SpreadSheet object to HashSpreadSheet
proc toHash * (SpreadSheet : SpreadSheet, on : string) : Table[string, seq[Cell]] =
  var ind = getColumnIndex(SpreadSheet, on)
  for i, row in pairs(SpreadSheet.rows):
    result[row.items[ind].strVal] = row.items



proc joinSpreadSheets * (SpreadSheet1 : var SpreadSheet, SpreadSheet2 : SpreadSheet, on : string) =
  ## Atomic Action : Join SpreadSheets (INNER JOIN)
  # First: Built Hash Table of first SpreadSheet
  var hash = toHash(SpreadSheet1, on)

  var ind = getColumnIndex(SpreadSheet2, on)
  var outRows : seq[Row]

  # Second: Match through lookups
  for i, row in pairs(SpreadSheet2.rows):
    var row_i : Row
    try:
      row_i = Row(items: hash[row.items[ind].strVal])
      outRows.add(row_i | row)
    except KeyError:
      continue
  SpreadSheet1 = newSpreadSheet(SpreadSheet1.name, outRows, SpreadSheet1.header | SpreadSheet2.header)
  SpreadSheet1.removeColumn(on)

# Atomic Actions: Set Permission for column in table
proc setNewPermissions * (sheet : var SpreadSheet, role : string, forbid : seq[string]) =
  sheet.permissions[role] = {"placeholder": true}.toTable
  sheet.permissions[role].del("placeholder")
  for name in forbid:
    sheet.permissions[role][name] = false

  
from asyncdispatch import waitFor

# Atomic Actions: Send Mail
proc sendNewMail * (to : string, subject : string, content : string) =
  waitFor( mailFunc.sendNewMail(mailBot, to, "John Doe", subject, content) )

# Atomic Actions: Send Mail with File
proc sendNewFile * (to : string, subject : string, content : string, file : string) =
  waitFor( mailFunc.sendNewFile(mailBot, to, "John Doe", subject, content, file) )


# Atomic Actions: Append Spreadsheet
proc appendSheet * (sheet1 : var Spreadsheet, sheet2 : Spreadsheet) =
  for row in sheet2.rows:
    sheet1.addRow(row)

# Atomic Actions: Create Webview
import jester
const REPLACETOKEN = " INSERT ROW HERE AT ME "
const REPLACETOKENCELL = " INSERT CELL HERE AT ME "


proc generateTH(cell : Cell, edit: bool) : string =
  ## Generates a HTML <th> from Cell
  if edit:
    result = "<th contenteditable='true' id='cell'> " & cell.strVal & "</th>" & REPLACETOKENCELL
  else:
    result = "<th> " & cell.strVal & "</th>" & REPLACETOKENCELL


proc generateTR(row : Row, permissions : seq[bool]) : string =
  ## Generates a HTML <tr> from Row
  result = """
      <tr id="row">
        """ & REPLACETOKENCELL &   """
      </tr>
      """ & REPLACETOKEN

  for index, cell in pairs(row.items):
    assert len(permissions) == len(row.items)
    result = result.replace(REPLACETOKENCELL, generateTH(cell, permissions[index]))
    
  result = result.replace(REPLACETOKENCELL, "")


proc generateHTMLForm * (table : SpreadSheet, user : var = "UNIVERSAL") : string =
  ## takes a SpreadSheet object as input, parses it
  ## and returns a HTML string with table from SpreadSheet 
  ## Form version holds a button which can POST data to a given server
  result =  """ <html>
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
                    """ & generateTR(table.header, newSeqWith(len(table.header.items), false)) & """
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
                      }
                  return true;
                }
                  });
                  </script>
                </body>
                </html>
          """
  var permissions : seq[bool]
  for item in table.header.items:
    permissions.add(table.permissions[user][item.strVal])
  for row in table.rows:
    result = result.replace(REPLACETOKEN, generateTR(row, permissions))
  result = result.replace(REPLACETOKEN, "")


proc generateHTMLView * (table : SpreadSheet, user : var = "UNIVERSAL") : string =
  ## takes a SpreadSheet object as input, parses it
  ## and returns a HTML string with table from SpreadSheet
  ## View Version - No Submits possible
  result =  """ <html>
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
                    """ & generateTR(table.header, newSeqWith(len(table.header.items), false)) & """
                  </table>
                </body>
                </html>
          """
  var permissions : seq[bool]
  for item in table.header.items:
    permissions.add(table.permissions[user][item.strVal])
  for row in table.rows:
    result = result.replace(REPLACETOKEN, generateTR(row, permissions))
  result = result.replace(REPLACETOKEN, "")



import asyncdispatch, jester, os, strutils
# returns a WebView of the Spreadsheet
proc createNewWebView * (table : SpreadSheet, r : string) =
  routes:
    get "/":
      var html = generateHTMLView(table)
      resp html




# takes a SpreadSheet and a Filename as input
# and writes Spreadsheet to HTML format
proc writeHTML * (table : SpreadSheet, fileName = "output.html") =
  var html = table.generateHTMLView()
  writeFile(fileName, html)

import htmlparser
import xmltree
# takes html string as input
# parses it for the first table
# and returns it as spreadsheet
proc fromHTML * (html : string) : SpreadSheet =
  var xml = parseHtml(html)
  # get all table rows
  let query = xml.findAll("tr")
  var outRows : seq[Row]
  for node in query:
    var row : Row
    for x in node:
      try:
        if x.kind() == xnElement:
          row.items.add(  newCell(  x.innerText()[1..len(x.innerText())-1] ) )
      except FieldDefect:
        continue
    outRows.add(row)
  result = newSpreadSheet("", outRows[1..len(outRows)-1], outRows[0])


proc fromJSONString * (j : JsonNode) : SpreadSheet =
  var outRows : seq[Row]
  for entry in j["values"]:
    var row : Row
    for e in entry:
      var s = $e
      row.items.add(newCell(s[1..len(s)-2]))
      
    outRows.add(row)

  result = newSpreadSheet("", outRows[1..len(outRows)-2], outRows[0])

# Atomic Action read from googlesheets
proc fromGoogleSheets * (id : string) : SpreadSheet =
  var response = openSheet(id)
  result = fromJSONString(response)


# Update a Spreadsheet through one of it's views
proc update * (toUpdate : var SpreadSheet, view : SpreadSheet) =
  var indexIndex = view.getColumnIndex("index")
  for row in view.rows:
    for col in view.header.items:
      var viewInd = view.getColumnIndex(col.strVal)
      if viewInd != indexIndex:
        var origInd = toUpdate.getColumnIndex(col.strVal)
        if toUpdate[parseInt(row.items[indexIndex].strVal), origInd].strVal != row.items[viewInd].strVal:
          toUpdate.setNewValue(parseInt(row.items[indexIndex].strVal), col.strVal, row.items[viewInd].strVal)


# Get View of Table
proc view * (table : SpreadSheet, indRange : seq[int], colRange : seq[string]) : SpreadSheet =
  var colInd : seq[int]
  var newHead : Row
  var newRows : seq[Row]
  # translate names of columns into index
  for c in colRange:
    colInd.add(getColumnIndex(table, c))
  # create new header
  for h in colInd:
    newHead.items.add(  table.header.items[h] )

  # create new rows
  for index in indRange:
    var newRow : Row
    for c in colInd:
      newRow.items.add(table.rows[index].items[c])
    newRows.add(newRow)
  return newSpreadSheet(fmt"{table.name}-View", newRows, newHead)


# Get View of Table only row selection
proc view * (table : SpreadSheet, indRange : seq[int]) : SpreadSheet =
  var newRows : seq[Row]

  # create new rows
  for index in indRange:
    var newRow = table.rows[index]
    newRows.add(newRow)
  return newSpreadSheet(fmt"{table.name}-View", newRows, table.header)


# Conditional view of table
proc where * (table : SpreadSheet, col : string, op : string, val : string) : SpreadSheet =
  var colInd = table.getColumnIndex(col)
  var newRowsIndex : seq[int]
  for index, row in pairs(table.rows):
    case op:
      of "==":
        if row.items[colInd].strVal == val:
          newRowsIndex.add(index)

  result = table.view(newRowsIndex)


