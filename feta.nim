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

proc TO * (statement : string) =
  return

proc TO * (s : string) : string =
  result = s

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
  result = newStmtList()
  for s in statement:
    result.add(newCall("addRow", spreadsheet, s))

macro REMOVEROW * (spreadsheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for removeRow(spreadsheet, integer)
  result = newStmtList()
  for s in statement:
    result.add(newCall("removeRow", spreadsheet, s))

macro INSERT * (row : var Row, statement : untyped) =
  ## DSL interface for add(row, value)
  result = newStmtList()
  for s in statement:
    result.add(newCall("add", row, s))

macro REMOVECOLUMN * (sheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for removeColumn(spreadSheet, column)
  result = newStmtList()
  for s in statement:
    result.add(newCall("removeColumn", sheet, s))

macro RENAMECOLUMN * (sheet : var SpreadSheet, statement : untyped) =
  ## DSL interface for renameColumn(spreadsheet, oldName, newName)
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
  result = statement


proc newSpreadsheetGen*(name : string, rows : seq[Row], header: Row): SpreadSheet = 
  ## Generate new Spreadsheet with given
  ## name
  ## rows
  ## header
  result = newSpreadsheet(name.name, rows, header)

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

macro SENDMAIL * (statement: untyped) =  
  ## Macro for sending Mail
  ## Atomic Action: Send email
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


macro CREATE_SPREADSHEET * (statement : untyped) : SpreadSheet =
  ## Macro for returning spreadsheets from logic
  ## Atomic Action: Create Spreadsheet
  result = newCall("newSpreadsheetGen", statement)

macro FROM_PROC * (statement : untyped) : proc() : SpreadSheet =
  ## Macro for returning spreadsheet from logic
  result = newProc(params=[ident("SpreadSheet")], body = statement)

# Macro for changing permissions
macro setPermissions * (table : untyped, statement: untyped) =  
  var target = table
  var permits : NimNode
  var user : NimNode
  for s in statement:
    case s[0].strVal:
      of "user":
        user = s[1]
      of "permits":
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


macro SAVE * (statement : untyped) : SpreadSheet =
  ## Macro Interface for Meta-API saving
  var iden : NimNode
  var creation : NimNode
  for s in statement:
    case s[0].strVal:
      of "TO":
        iden = s[1][0]
      else:
        creation = s
  result = newCall("saveSpreadSheet", creation, iden)

  
macro ADDVIEW * (statement : untyped) =
  ## Default Macro for adding views to a server execution
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
  result = newCall("addToServer", sheet, name, newStrLitNode("view"))


macro ADDFORM * (statement : untyped) =
  ## Default Macro for adding forms to a server execution
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
      of "FROM_PROC":
        sheet = s
      of "ALLOWEDIT":
        restricEdits = s
      of "ACCEPTIF":
          confirmRequirement = newProc(params=[ident("bool"), newIdentDefs(ident("COMMIT"), ident("SpreadSheet"))], body=s[1]) 
      of "ONACCEPT":
        applyChanges = newProc(params=[newEmptyNode(),newIdentDefs(ident("COMMIT"), ident("SpreadSheet"))], body=s[1])
  result = newCall("addFormToServer", sheet, name, confirmRequirement, applyChanges, errorMessage) # adds form to server
  if restricEdits.kind() == nnkEmpty: # Restric editing rights
    result.add(newCall("setNewPermissions", sheet, name, restricEdits))
   

macro ONSERVER * (statement : untyped) =
  ## Macro which indicates that all codeblocks inside
  ## should be executed on an online ODSL-server
  result = statement
  result.add(newCall("serveServer"))
  discard statement


export spreadsheets, server, googleapi, metaapi
