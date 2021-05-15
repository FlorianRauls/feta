import lists

#[ Implementation of the generic Table class
which will be the center and target of most language features]#
type
  Table* = object # This is the table Object itself
    columnNames*: seq[string] # Column Header
    rows*: seq[seq[string]]

#[ Table Constructor ]#
proc newTable*(names: DoublyLinkedList, rows: seq[seq[string]]) : Table =
    result.columnNames = names
    result.rows = rows

# [Append a new row to the table]#
proc initTable*() : Table =
  result = Table()
  
# [Rename Table]#
proc setColumnNames*(table: var Table, names : var seq[string]) : Table = 
  table.columnNames = names
  result = table


