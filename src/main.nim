import odsl

# RIGHT NOW THIS SECTION IS MORE LIKE A TESTING GROUND 

var row = 1 | 2.5 | "hi" | 2


var test = row and "hello" | "world" and row and "hello" | "world" | 2.4 and "hello" | "world" | 2.4 and "hello" | "world" | 2.4 and "hello" | "world" | 2.4
var name = "bernd"

var z : TableConstructor
z.name = name
z.rows = test

var testTable1 = create newTable with name and test
debugTable(testTable1)
var y = toJSONBody(testTable1)

