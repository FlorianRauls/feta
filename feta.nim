import macros
import feta/spreadsheets
import feta/googleapi
import feta/server
import feta/mailFunc
from feta/mailFunc import mailBot
import feta/metaapi

## The following statements are all used to create valid FETA-language constructs.
## They do however not have any functional use.
macro ONACCEPT * (statement : untyped) =
  return

macro ACCEPTIF * (statement : untyped) =
  return

macro ONSEND * (statement : untyped) =
  return

macro ALLOWEDIT * (statement : untyped) =
  return

proc AS * (statement : string) =
  return

proc TO * (statement : string) : string =
  return statement

proc ATTACHEMENT * (s : string) : string =
  result = s

proc TEXT * (s : string) : string =
  result = s

proc SUBJECT * (s : string) : string =
  result = s

macro ROW * (statement : untyped) =
  return

proc LENGTH * (sheet : SpreadSheet) : int =
  ## DSL interface of len(spreadsheet) function
  ## Returns the number of rows in `sheet`
  result = len(sheet)

proc SHOW * (sheet : SpreadSheet) =
  ## DSL wrapper of show(spreadsheet) function
  ## `sheet` is the SpreadSheet-object, whichshould
  ## be pretty-printed.
  show(sheet)

proc SHOW * (id : string) =
  ## DSL wrapper of show(spreadsheet) function
  ## Pretty prints the SpreadSheet which is at
  ## position `id` on the SERVER-object
  show(odslServer[id])

proc WHERE * (spreadsheet : SpreadSheet, column : string, operator : string, condition : string) : seq[int] =
  ## DSL wrapper of where(spreadsheet) function
  ## Returns a seq of indices, which denote the rows
  ## in `spreadsheet`, which meet that the value in
  ## column `column` `operator` to `condition`
  result = where(spreadsheet, column, operator, condition)

macro ADDROW * (spreadsheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for addRow(spreadsheet, row)
  ## Adds all Row-objects, which are lying
  ## in the indented logic block after ADDROW
  ## to `spreadsheet`
  result = newStmtList()
  for s in statement:
    result.add(newCall("addRow", spreadsheet, s))

macro REMOVEROW * (spreadsheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for removeow(spreadsheet, index)
  ## Removes all Row-objects, which are represented
  ## in the indented logic block, by integers, after REMOVEROW
  ## from `spreadsheet`
  result = newStmtList()
  for s in statement:
    result.add(newCall("removeRow", spreadsheet, s))

macro INSERT * (row : var Row, statement : untyped) =
  ## DSL interface for add(row, value)+
  ## Interprets all values as Cells and appends
  ## these Cells at the end of `row`
  result = newStmtList()
  for s in statement:
    result.add(newCall("addVarRow", row, s))

macro REMOVECOLUMN * (sheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for removeColumn(spreadSheet, column)
  ## Interprets all values in `statement` as
  ## strings and removes headers from
  ## `sheet`, which match these names
  result = newStmtList()
  for s in statement:
    result.add(newCall("removeColumn", sheet, s))

macro RENAMECOLUMN * (sheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for renameColumn(spreadsheet, oldName, newName)
  ## Sytnax:
  ## sheet.RENAMECOLUMN:
  ##  FROM:
  ##    oldName
  ##  TO:
  ##    newName
  ## Renames the column given by `oldName`
  ## to `newName`
  var oldName : NimNode
  var newName : NimNode

  for s in statement:
    case s[0].strVal:
      of "FROM":
        oldName = s[1]
      of "TO":
        newName = s[1]
      else:
        raise newException(KeyError, "Unknown keyword")
  result = newCall("renameColumn", sheet, oldName, newName)

macro ADDCOLUMN * (sheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for addColumn(spreadsheet, name, row)
  ## Interprets all entries in `statement` as `Row`-obects
  ## and adds them as columns to `sheet`
  result = newStmtList()
  for s in statement:
    result.add(newCall("addColumn", sheet, s))

proc newSpreadsheetGen*(name : string, rows : seq[Row], header: Row): SpreadSheet = 
  ## Generate new Spreadsheet with given
  ## name
  ## rows
  ## header
  result = newSpreadsheet(name, rows, header)

proc newSpreadsheetGen*(rows : seq[Row]): SpreadSheet = 
  ## Generate new Spreadsheet with given
  ## name
  ## rows
  ## header
  result = newSpreadsheet("", rows[1..len(rows)-1], rows[0])

proc newSpreadsheetGen*(rows : Row): SpreadSheet = 
  ## Generate new Spreadsheet with given
  ## name
  ## row
  ## header
  var x : seq[Row]
  result = newSpreadsheet("", x, rows)

proc newSpreadsheetGenFromRows*(rows : seq[Row]): SpreadSheet = 
  ## Generate new Spreadsheet with given
  ## name
  ## rows
  ## header
  result = newSpreadsheet("", rows[1..len(rows)-1], rows[0])

macro SENDMAIL * (statement: untyped) =  
  ## Macro for sending Mail
  ## Atomic Action: Send email
  ## Syntax:
  ## SENDMAIL:
  ##  TO:
  ##    toAddress
  ##  TEXT:
  ##    text
  ##  SUBJECT:
  ##    subjectText
  ##  ATTACHEMENT:  # Attachement is optional!
  ##    attachementFile
  var target : NimNode
  var text : NimNode
  var subject : NimNode
  var attachement : NimNode
  var hasAttach = false
  for s in statement:
    case s[0].strVal:
      of "TO":
        target = s
      of "TEXT":
        text = s
      of "SUBJECT":
        subject = s
      of "ATTACHEMENT":
        hasAttach = true
        attachement = s
  if hasAttach:
    result = newCall("sendNewFile", target, subject, text, attachement)
  else:
    result = newCall("sendNewMail", target, subject, text)

proc interimAddrow*(sheet : SpreadSheet, row : Row) : SpreadSheet =
  var x = sheet
  x.addRow(row)
  return x

macro CREATE_SPREADSHEET * (statement : untyped) : SpreadSheet =
  ## Macro for returning spreadsheets from logic
  ## Atomic Action: Create Spreadsheet
  ## `statement` should be a statementList of Rows
  ## Syntax:
  ## var sheet = CREATE_SPREADSHEET.
  ##  row1
  ##  row2
  ##  ...
  var toReturn = newCall("newSpreadsheetGen", statement[0])
  for s in statement[1..len(statement)-1]:
    toReturn = newCall("interimAddrow", toReturn, s)

  result = toReturn

macro FROM_PROC * (statement : untyped) : proc() : SpreadSheet =
  ## Macro for returning spreadsheet from logic
  ## Returns a function, which returns a SpreadSheet
  ## `statement` can be:
  ## * reference to a function
  ## * function body, which returns a SpreadSheet
  result = newProc(params=[ident("SpreadSheet")], body = statement)

macro SET_PERMISSIONS * (table : var SpreadSheet, statement: untyped) =  
  ## Macro for changing edit permissions on a SpreadSheet object
  ## Spreadsheet needs to be var
  ## `statement` needs to contain statements in the form of:
  ## USER:
  ##  name : String
  ## PERMIT:
  ##  columns : seq[String]
  var target = table
  var permits : NimNode
  var user : NimNode
  for s in statement:
    case s[0].strVal:
      of "USER":
        user = s[1]
      of "PERMIT":
        permits = s[1]
  newCall("setNewPermissions", target, user, permits)


macro view * (statement : untyped) : SpreadSheet =
  ## Defines the Syntax for a call of createView
  var source : NimNode
  var keep : NimNode
  var columns : NimNode
  var gotColumns = false
  for s in statement:
    case $s[0]:
      of "source":
        source = s[1]
      of "keep":
        keep = s[1]
      of "columns":
        columns = s[1]
        gotColumns = true
  if gotColumns:
    result = newCall("createView", source, keep, columns)
  else:
    result = newCall("createView", source, keep)


proc UPDATE * (toUpdate : var SpreadSheet, view : SpreadSheet, on = "index") =
  ## DSL Interface for the host-API call update(toUpdate : var SpreadSheet, view : SpreadSheet, on = "index")
  ## Will be reworked in the future, to better match our syntax vision of no brackets
  toUpdate.update(view, on)

macro LOAD * (statement : untyped) : SpreadSheet =
  ## Macro Interface for Meta-API loading
  var iden : NimNode
  var creation : NimNode
  for s in statement:
    case s[0].strVal:
      of "AS":
        iden = s[1][0]
      else:
        creation = s
  result = newCall("loadSpreadSheet", creation)


macro SAVE * (sheet : SpreadSheet, statement : untyped) =
  ## Macro Interface for Meta-API saving
  var name = newStrLitNode($statement[0][0])
  result = newCall("saveSpreadSheet", sheet, name, statement[0][1][0])

  
macro ADDVIEW * (statement : untyped) =
  ## Default Macro for adding views to a server execution
  ## Syntax:
  ## ADDVIEW:
  ##  AS:
  ##    id
  ##  LOAD/FROM_PROC/SPREADSHEET:
  ##    anyKindOfSpreadsheetGeneration
  var name = newStrLitNode("")
  var sheet : NimNode
  for s in statement:
    case s[0].strVal:
      of "AS":
        name = s[1]
      of "LOAD":
        sheet = s
      of "CREATE_SPREADSHEET":
        sheet = s
      of "SPREADSHEET":
        sheet = newProc(params=[ident("SpreadSheet")], body=s)
      of "FROM_PROC":
        sheet = s
  result = newCall("addToServer", sheet, name, newStrLitNode("view"))


macro ADDFORM * (statement : untyped) =
  ## Default Macro for adding forms to a server execution
  ## Syntax:
  ## ADDFORM:
  ##  AS:
  ##    id
  ##  LOAD/FROM_PROC/SPREADSHEET:
  ##    anyKindOfSpreadsheetGeneration
  ##  ALLOWEDIT:
  ##    namesOfEditableColumns
  ##  ACCCEPTIF:
  ##    proc(COMMIT : SpreadSheet) : bool
  ##  ONACCEPT:
  ##    proc(COMMIT : SpreadSheet)
  var name = newStrLitNode("")
  var sheet = newProc(params=[ident("SpreadSheet")]) # Defaul proc which returns just an empty spreadsheet
  var errorMessage = newStrLitNode("An error has occured. Please contact the host for further information") # Default Error Message
  var restricEdits = newEmptyNode()
  var confirmRequirement = newProc(params=[ident("bool"),newIdentDefs(ident("s"), ident("SpreadSheet"))]) # Default proc which triggers, to check valid forms
  var applyChanges = newProc(params=[newEmptyNode(),newIdentDefs(ident("s"), ident("SpreadSheet"))]) # Default proc which triggers, when valid form is submitted
  for s in statement:
    case s[0].strVal:
      of "AS":
        name = s[1]
      of "LOAD":
        sheet = newProc(params=[ident("SpreadSheet")], body=s)
      of "SPREADSHEET":
        sheet = newProc(params=[ident("SpreadSheet")], body=s)
      of "CREATE_SPREADSHEET":
        sheet = newProc(params=[ident("SpreadSheet")], body=s)
      of "FROM_PROC":
        sheet = newProc(params=[ident("SpreadSheet")], body=s[1])
      of "ALLOWEDIT":
        restricEdits = s[1]
      of "ACCEPTIF":
          confirmRequirement = newProc(params=[ident("bool"), newIdentDefs(ident("COMMIT"), ident("SpreadSheet"))], body=s[1]) 
      of "ONACCEPT":
        applyChanges = newProc(params=[newEmptyNode(),newIdentDefs(ident("COMMIT"), ident("SpreadSheet"))], body=s[1])
  
  if restricEdits.kind() != nnkEmpty: # Restricting editing rights
    result = newStmtList()
    result.add(newCall("setNewPermissions", sheet, newStrLitNode("UNIVERSAL"), restricEdits))
    result = newCall("addFormToServer", sheet, name, confirmRequirement, applyChanges, restricEdits, errorMessage) # adds form to server
  else:
    result = newCall("addFormToServer", sheet, name, confirmRequirement, applyChanges, errorMessage) # adds form to server
   

macro ONSERVER * (statement : untyped) =
  ## Macro which indicates that all codeblocks inside
  ## should be executed on an online ODSL-server
  ## After the `statement` code block is finished executing
  ## the SERVER object is started locally
  result = statement
  result.add(newCall("serveServer"))
  discard statement

proc WITH*(sheet : SpreadSheet) =
  return

proc ON*(sheet : string) =
  return

macro JOIN *(sheet : SpreadSheet, statement : untyped) : SpreadSheet =
  ## Macro Interface for `joinSpreadsheets()`
  var other : NimNode
  var on : NimNode
  for s in statement:
    case s[0].strVal:
      of "WITH":
        other = s[1]
      of "ON":
        on = s[1]
  var copy = sheet
  result = newCall("joinSpreadSheetsStatic", copy, other, on)


proc COLUMNINDEX * (sheet : SpreadSheet, column : string) : int =
  ## Takes `sheet : SpreadSheet` and `column : string`
  ## as inputs and returns the integer index of
  ## the respective column in the header
  ## of `sheet`
  result = sheet.getColumnIndex(column)

proc `[]`*(row : Row, index : int) : string =
  result = row.items[index].strVal

proc AT * (sheet : SpreadSheet, ind : int, col : string) : string =
  result = sheet[ind, col].strVal

export spreadsheets, server, googleapi, metaapi


