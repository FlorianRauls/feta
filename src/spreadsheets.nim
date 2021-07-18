import googleapi
import json 
import strutils
import tables
import sequtils
import strformat
import asyncdispatch
import jester
import htmlparser
import xmltree
import parsecsv

from mailFunc import mailBot
from asyncdispatch import waitFor

type
  ## type which is used for internal NaN representation
  Nil* = object
    needsVal : int

var null* : Nil ## Substitute for NaN-Value for internal functions

type CellKind* = enum  ## the different node types
  nkInt,          ## a cell with an integer value
  nkFloat,        ## a cell with a float value
  nkString,        ## a cell with a string value
  nkEmpty         ## an empty cell

#[ Implementation of the generic Cell class
which will be the center and target of most language features]#
type 
  Cell * = ref object
    kind* : CellKind
    intVal*: int
    floatVal*: float
    strVal*: string

proc newCell*(value: string): Cell =
  ## Creates a new String-Cell
  result = Cell(kind: nkString, strVal: value)
proc newCell*(value: int): Cell =
  ## Creates a new Int-Cell
  result = Cell(kind: nkInt, intVal: value, strVal: $value)
proc newCell*(value: float): Cell =
  ## Creates a mew Float-Cell
  result = Cell(kind: nkFloat, floatVal: value, strVal: $value)
proc newCell*(value: Nil): Cell =
  ## Creates a new NaN-Cell
  result = Cell(kind: nkEmpty, strVal: "-")
     
#[ Implementation of the generic Row class
which will be the center and target of most language features]#
type 
  Row * = object ## Generic Row Class
    items* : seq[Cell] ## Holds a sequence of Cells
      
proc newRow*(items: seq[Cell]): Row =
  ## Row constructor
  result = Row(items: items)

proc header * (row : Row) : Row =
  ## Used for syntax clarification
  ## Creates a Row from a Row
  result = row

proc getValues * (row : Row) : seq[string] =
  ## Inputs a Row and returns a seq of strings
  ## from the values of Row
  for v in row.items:
    result.add(v.strVal)

#[ Implementation of the generic SpreadSheet class
which will be the center and target of most language features]#
type
  SpreadSheet * = object ## SpreadSheet Object
    name* : string ## Name of SpreadSheet
    rows* : seq[Row] ## Seq of Rows of SpreadSheet
    hasHeader* : bool ## Clarify whether a Header is present
    header* : Row ## Header Row
    longestItems* : seq[int] ## Holds the length of the longest item in each Column for smoother printing
    longestRow* : int ## Holds the length of the longest Row so all rows can be normalised
    permissions* : Table[string, Table[string, bool]] ## Holds editorial permissions for each user for each Column

proc add*(this : Row, x : int) : Row =
  ## Adds the given integer as integer Cell to the Row
  result = this
  result.items.add(newCell(x))

proc add*(this : Row, x : float) : Row =
  ## Adds the given float as float Cell to the Row
  result = this
  result.items.add(newCell(x))

proc add*(this : Row, x : string) : Row =
  ## Adds the given string as string Cell to the Row
  result = this
  result.items.add(newCell(x))

proc add*(this : Row, x : Nil) : Row =
  ## Adds the given NaN as NaN Cell to the Row
  result = this
  result.items.add(newCell(x))

proc padRow(row : var Row, diff : int)=
  ## Fills row with NaN-cells until diff is reached
  for i in 0..diff-1:
    row = row.add(null)

proc newSpreadSheet*(name: string, rows: seq[Row], header : Row): SpreadSheet =
  ## Create a New SpreadSheet with name, sequence of Rows and Header
  var hasHeader = false
  var lonRow = 0
  # Check if a header is present
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
      # padRow if needed
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


proc pad(input : string, padTo: int) : string =
  ## helper function which takes a string and an integer
  ## and pads the string with Spaces on both sides
  ## until it is as long as the integer
  var goal = padTo 
  result = input
  for i in len(input)..goal:
    result = ' ' &  result 

proc debugSpreadSheet*(SpreadSheet: SpreadSheet) = 
  ## Shows Meta-Information and contents of SpreadSheet
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

proc `|` * (x : int, y : int) : Row = 
  ## Combines two integer tow a Row of Integer Cells
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
  ## Only needed for syntax reasons
  result = SpreadSheet

proc toJSONBody * (SpreadSheet : SpreadSheet) : JsonNode =
    ## take a SpreadSheet Object and create a JSON response from it
    ## This implementation is very specific to the google-sheets api
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
    
proc show*(SpreadSheet:SpreadSheet) =
  ## interface to use debugSpreadSheet
  debugSpreadSheet(SpreadSheet)

proc getColumnIndex(SpreadSheet : SpreadSheet, colName : string) : int =
    ## helper function which returns the column index of a header by name
    var names : seq[string]
    for i in SpreadSheet.header.items:
      names.add(i.strVal)
    if colName in names:
      var found = names.find(colName)
      result = found
    else:
      raise newException(OSError, colName & " is not in Spreadsheet " & SpreadSheet.name)


proc removeColumn * (SpreadSheet : var SpreadSheet, toDelete : string) =
  ## Atomic Action: Delete Column
  var found = getColumnIndex(SpreadSheet, toDelete)
  for i in 0..len(SpreadSheet.rows)-1:
    delete(SpreadSheet.rows[i].items, found)
  SpreadSheet.header.items.delete(found)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

proc `-=` * (SpreadSheet : var SpreadSheet, toDelete : string) =
  ## Atomic ACtion: Delete Column Operator
  removeColumn(SpreadSheet, toDelete)

proc removeRow * (SpreadSheet : var SpreadSheet, toDelete : int) =
  ## Atomic Action: Delete Row
  SpreadSheet.rows.delete(toDelete)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

proc `-=` * (SpreadSheet : var SpreadSheet, toDelete : int) =
  ## Atomic ACtion: Delete Row Operator
  removeRow(SpreadSheet, toDelete)

proc renameSpreadsheet * (SpreadSheet : var SpreadSheet, newName : string) = 
  ## Atomic Action : Rename SpreadSheet
  SpreadSheet.name = newName

proc `:=` * (SpreadSheet : var SpreadSheet, newName : string) = 
  ## Atomic Action : Rename SpreadSheet Operator
  renameSpreadsheet(SpreadSheet, newName)

proc renameColumn * (SpreadSheet : var SpreadSheet, oldName : string, newName : string) =
  ## Atomic Action : Rename Column
  for i in 0..len(SpreadSheet.header.items)-1:
    if SpreadSheet.header.items[i].strVal == oldName:
      SpreadSheet.header.items[i] = newCell(newName)
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

proc `[]` * (SpreadSheet : SpreadSheet, r, c: int): Cell =
  ## Returns Cell at given position
  result = SpreadSheet.rows[r].items[c] 

proc `[]` * (SpreadSheet : SpreadSheet, r : int, c: string): Cell =
  ## Returns Cell at given position
  var colInd = getColumnIndex(SpreadSheet, c)
  result = SpreadSheet.rows[r].items[colInd] 

proc `[]` * (SpreadSheet : SpreadSheet, name : string) : seq[string] =
  ## Returns a seq[string] of strVal of all values in Column named name of SpreadSheet
  var ind = getColumnIndex(SpreadSheet, name)
  for row in SpreadSheet.rows:
    result.add(row.items[ind].strVal)

proc addColumn * (SpreadSheet : var SpreadSheet, name = "NaN", toAdd : Row) =
  ## Atomic Action: Add Column
  SpreadSheet.header.items.add(newCell(name))
  for i, item in pairs(toAdd.items):
    case item.kind:
        of nkInt: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.intVal)
        of nkFloat: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.floatVal)
        of nkString: SpreadSheet.rows[i] = SpreadSheet.rows[i].add(item.strVal) 
        of nkEmpty: SpreadSheet.rows[i] =  SpreadSheet.rows[i].add(null) 
  SpreadSheet = newSpreadSheet(SpreadSheet.name, SpreadSheet.rows, SpreadSheet.header)

proc len * (SpreadSheet : SpreadSheet) : int =
  ## Returns number of rows of SpreadSheet
  result = len(SpreadSheet.rows)

proc colLen * (SpreadSheet : SpreadSheet) : int =
  ## Returns number of columns of SpreadSheet
  result = len(SpreadSheet.header.items)

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


proc toHash * (SpreadSheet : SpreadSheet, on : string) : Table[string, seq[Cell]] =
  ## Helper function which transforms SpreadSheet object to HashSpreadSheet
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
proc setNewPermissions * (sheet : var SpreadSheet, role : string, âllow : seq[string]) =
  sheet.permissions[role] = {"placeholder": true}.toTable
  sheet.permissions[role].del("placeholder")
  for name in âllow:
    sheet.permissions[role][name] = true
  for s in sheet.header.getValues():
    if s notin âllow:
      sheet.permissions[role][s] = false

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
const REPLACETOKEN = " INSERT ROW HERE AT ME "
const REPLACETOKENCELL = " INSERT CELL HERE AT ME "

proc generateTH(cell : Cell, edit: bool) : string =
  ## Generates a HTML <th> from Cell
  if edit:
    result = "<th contenteditable='true' id='cell' bgcolor='#98FFCD'> " & cell.strVal & "</th>" & REPLACETOKENCELL
  else:
    result = "<th bgcolor='#FF8484'> " & cell.strVal & "</th>" & REPLACETOKENCELL

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
                          window.location.reload(true); 
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

# takes a SpreadSheet and a Filename as input
# and writes Spreadsheet to HTML format
proc writeHTML * (table : SpreadSheet, fileName = "output.html") =
  var html = table.generateHTMLView()
  writeFile(fileName, html)

proc fromHTML * (html : string) : SpreadSheet =
  ## takes html string as input
  ## parses it for the first table
  ## and returns it as spreadsheet
  var xml = parseHtml(html)
  # get all table rows
  let query = xml.findAll("tr")
  var outRows : seq[Row]
  for node in query:
    var row : Row
    for x in node:
      try:
        try:
          if x.kind() == xnElement:
            row.items.add(  newCell(  x.innerText()[1..len(x.innerText())-1] ) )
        except FieldDefect:
          continue
      except RangeDefect:
        continue
    outRows.add(row)
  result = newSpreadSheet("", outRows[1..len(outRows)-1], outRows[0])

proc fromHTMLFile * (file : string) : SpreadSheet =
  ## Reads a file from file location and returns
  ## the first included HTML table as SpreadSheet
  var html = readFile(file)
  result = fromHTML(html)

proc fromCSV * (csv : string) : SpreadSheet =
  ## Takes a string which points to a valid .csv file
  ## and reads the file into a SpreadSheet
  var p : CsvParser
  p.open(csv)
  p.readHeaderRow()
  var outRows : seq[Row]
  var head : Row
  for h in p.headers:
    head = head.add(h)
  while p.readRow():
    var row : Row
    for col in items(p.headers):
      row = row.add(p.rowEntry(col))
    outRows.add(row)

  result = newSpreadSheet("", outRows, head)

proc fromJSONString * (j : JsonNode) : SpreadSheet =
  ## Reads SpreadSheet values from
  ## JSONstring
  ## Caution: This function is very specific to Google SpreadSheets
  ## response! This might very likely not work for your case
  var outRows : seq[Row]
  try:
    for entry in j["values"]:
      var row : Row
      for e in entry:
        var s = $e
        row.items.add(newCell(s[1..len(s)-2]))
        
      outRows.add(row)
  except KeyError:
    raise newException(KeyError, "Did you try to import an empty SpreadSheet?")

  result = newSpreadSheet("", outRows[1..len(outRows)-2], outRows[0])

proc fromGoogleSheets * (id : string) : SpreadSheet =
  
  ## Atomic Action read from googlesheets
  var response = openSheet(id)
  result = fromJSONString(response)

proc update * (toUpdate : var SpreadSheet, view : SpreadSheet, on = "index") =
  ## Update a Spreadsheet through one of it's views based on identifying column "on"
  var indexIndex = view.getColumnIndex(on) # Identifies the reference column
  var origIndexIndex = toUpdate.getColumnIndex(on) # Identifies the reference column
  for i, row in pairs(view.rows): # for every row in the view
    for k, origRow in pairs(toUpdate.rows): # for every row in the original
      if row.items[indexIndex].strVal == origRow.items[origIndexIndex].strVal:
        for col in view.header.items:
          var currIndex = view.getColumnIndex(col.strVal)
          var currOrigIndex = toUpdate.getColumnIndex(col.strVal)
          toUpdate.rows[k].items[currOrigIndex] = view.rows[i].items[currIndex]

proc createView * (table : SpreadSheet, indRange : seq[int], colRange : seq[string], newName="") : SpreadSheet =
  ## Takes Spreadsheet, indexRange and Range of names as input
  ## And returns a view of the given SpreadSheet
  ## Giving a newName is optional
  ## Per default the name of original SpreadSheet will be taken and added with "-view"
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
  if newName == "":
    return newSpreadSheet(fmt"{table.name}-View", newRows, newHead)
  else:
    return newSpreadSheet(newName, newRows, newHead)

proc createView * (table : SpreadSheet, indRange : seq[int], newName="") : SpreadSheet =
  ## Row only Approach to Creating a View of a SpreadSheet
  ## Giving a newName is optional
  ## Per default the name of original SpreadSheet will be taken and added with "-view"
  var newRows : seq[Row]

  # create new rows
  for index in indRange:
    var newRow = table.rows[index]
    newRows.add(newRow)
  if newName == "":
    return newSpreadSheet(fmt"{table.name}-View", newRows, table.header)
  else:
    return newSpreadSheet(newName, newRows, table.header)

proc where * (table : SpreadSheet, col : string, op : string, val : string) : seq[int] =
  ## Select Range of Rows from SpreadSheet based on whether condition is met on column col
  ## Currently supported:
  ## ==
  ## !=
  var colInd = table.getColumnIndex(col)
  for index, row in pairs(table.rows):
    case op:
      of "==":
        if row.items[colInd].strVal == val:
          result.add(index)
      of "!=":
        if row.items[colInd].strVal != val:
          result.add(index)       

proc HTML * (s : string) =
  return

proc CSV * (s : string) = 
  return