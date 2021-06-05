# import window
import table

# var terminal = newTerminal()

var test : seq[Row]
var row = 1 | 2 | 4 | 2
test.add(row)
test.add(row)
test.add(row)
var testTable = newTable("bernd", test)

debugTable(testTable)


