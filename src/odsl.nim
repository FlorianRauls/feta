import macros
import spreadsheets
import googleapi
import server
import mailFunc
from mailFunc import mailBot
import metaapi
type 
  Name* = object
    name* : string
## macro which reads multiline row statements
## and constructs seq[Row] from them


macro values * (statement : untyped): seq[Row] =
    var start = statement[0]
    for index, row in pairs(statement[0..len(statement)-2]):
        start = newCall("and", start, statement[index+1])
    result = start

# constructs Name type
proc setName * (name : string) : Name =
  result.name = name

proc to * (s : string) : string =
  result = s

proc attachement * (s : string) : string =
  result = s

proc text * (s : string) : string =
  result = s

proc subject * (s : string) : string =
  result = s

proc index * (i : int) : int =
  result = i

proc column * (s : string) : string =
  result = s

proc newValue * (s : string) : string =
  result = s

proc newValue * (s : int) : int =
  result = s

proc newValue * (s : float) : float =
  result = s

proc newValue * (s : Nil) : Nil =
  result = s
  
proc source*(s : SpreadSheet)=
  return

proc keep*(s : seq[int]) =
  return 

proc keep*(s : SpreadSheet)=
  return

proc columns*(s : seq[string]) =
  return

proc permits * (s : seq[string]) =
  return

proc user * (s : string) =
  return

# proc which generates new SpreadSheet
proc newSpreadsheetGen*(name : Name, rows : seq[Row], header: Row): SpreadSheet = 
  result = newSpreadsheet(name.name, rows, header)

# central macro which user can use
macro spreadsheet * (statement: untyped): SpreadSheet =  
  result = newCall("newSpreadsheetGen", statement[0], statement[2], statement[1])
  
# Macro for making Sending Mail more accessible
macro SendMail * (statement: untyped) =  
  var target : NimNode
  var text : NimNode
  var subject : NimNode
  var attachement : NimNode
  var hasAttach = false
  for s in statement:
    case s[0].strVal:
      of "to":
        target = s
      of "text":
        text = s
      of "subject":
        subject = s
      of "attachement":
        hasAttach = true
        attachement = s
  if hasAttach:
    result = newCall("sendNewFile", target, subject, text, attachement)
  else:
    result = newCall("sendNewMail", target, subject, text)


## Macro for making Sending Mail more accessible
macro setValue * (table : untyped, statement: untyped) =  
  var target = table
  var index : NimNode
  var column : NimNode
  var newValue : NimNode
  for s in statement:
    case s[0].strVal:
      of "index":
        index = s
      of "column":
        column = s
      of "newValue":
        newValue = s
  result = newCall("setNewValue", target, index, column, newValue)


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

macro LOAD * (statement : untyped) : SpreadSheet =
  var iden : NimNode
  var kind : NimNode
  var creation : NimNode
  for s in statement:
    case s[0].strVal:
      of "AS":
        iden = s[1][0]
      else:
        creation = s
  result = newCall("loadSpreadSheet", creation)
  
macro ADDVIEW * (statement : untyped) =
  var name = newStrLitNode("")
  var sheet : NimNode
  for s in statement:
    case s[0].strVal:
      of "AS":
        name = s[1]
      of "LOAD":
        sheet = s
  result = newCall("addToServer", sheet, name, newStrLitNode("view"))


macro ADDFORM * (statement : untyped) =
  var name = newStrLitNode("")
  var sheet : NimNode
  for s in statement:
    case s[0].strVal:
      of "AS":
        name = s[1]
      of "LOAD":
        sheet = s
  result = newCall("addToServer", sheet, name, newStrLitNode("view"))
   
macro ONSERVER * (statement : untyped) =
  ## Macro which indicates that all codeblocks inside
  ## should be executed on an online ODSL-server
  result = statement
  discard statement


export spreadsheets, server, googleapi, metaapi