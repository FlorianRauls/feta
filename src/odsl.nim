import macros
import spreadsheets
import googleapi
import server
import mailFunc
from mailFunc import mailBot
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
    case $s[0].ident:
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
    case $s[0].ident:
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
    case $s[0].ident:
      of "user":
        user = s
      of "permits":
        permits = s
  result = newCall("setNewPermissions", target, user, permits)

export spreadsheets, server, googleapi