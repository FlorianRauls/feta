import tables
import lists

#[ Implementation of the generic Table class
which will be the center and target of most language features]#
type
  Table* = object # This is the table Object itself
    columnNames*: DoublyLinkedList[string] # Column Header

#[ Table Constructor ]#
proc newTable*(names: DoublyLinkedList) : Table =
    result.columnNames = names

