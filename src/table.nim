import lists

#[ Implementation of the generic Cell class
which will be the center and target of most language features]#
type
  CellKind* = enum  # the different node types
    nkInt,          # a cell with an integer value
    nkFloat,        # a cell with a float value
    nkString        # a cell with a string value

  Cell* = object
    case kind*: CellKind  # the ``kind`` field is the discriminator
      of nkInt: intVal*: int
      of nkFloat: floatVal*: float
      of nkString: strVal*: string
      

#[ Implementation of the generic Row class
which will be the center and target of most language features]#
type
  Row* = object
    values*: seq[Cell]


#[ Implementation of the generic Table class
which will be the center and target of most language features]#
type
  Table* = object # This is the table Object itself
    columnNames*: seq[string] # Column Header
    rows*: seq[Row]
    interpretHeader* : bool


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

# Debugging proc for printing out table information
proc debugTable*(table: Table) = 
  echo "Interpret Header:"
  echo table.interpretHeader
  echo "Get values:"
  for row in table.rows:
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo row.values

