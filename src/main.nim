import odsl

var row = 1 | 2.5 | "hi" | 2


var test = row and row and row
var name = "bernd"

var z : TableConstructor
z.name = name
z.rows = test

var testTable1 = create newTable with name and test
debugTable(testTable1)


var testTable2 = create newTable with test and row and row and 1.2 | 2.5 | "hi" | 2


debugTable(testTable2)

var testTable3 = create newTable with 1.2 | 2.5 | "hi" | 2
debugTable(testTable3)