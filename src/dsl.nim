import macros
import odsl

type 
  Name* = object
    name* : string
#[
# macro which reads multiline row statements
# and constructs seq[Row] from them
# Necessary to prevent syntax like:

values:
    "Max Maxson" | 35 | "example@mail-address.de" and
    "Jennifer Jennifson" | 22 | "also@mail-address.de" and 
    "Christine Christensen" | 45 | "beispiel@mail-address.de" and 
    "Karl Karlson" | 27 | "definitiv_eine_mail_adresse@mail-address.de" 

]# 
macro values * (statement : untyped): seq[Row] =
    var start = statement[0]
    for index, row in pairs(statement[0..len(statement)-2]):
        start = newCall("and", start, statement[index+1])
    result = start

# constructs Name type
proc setName * (name : string) : Name =
  result.name = name

# proc which generates new table
proc newSpreadsheet*(name : Name, rows : seq[Row], header: Row): Table = 
  result = newTable(name.name, rows, header)

# central macro which user can use
macro spreadsheet * (statement: untyped): Table =  
  result = newCall("newSpreadsheet", statement[0], statement[2], statement[1])