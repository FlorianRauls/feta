# abstract class of Nodes which will be used in the parse tree
type
  NodeKind* = enum  # the different node types
    nkInt,          # a leaf with an integer value
    nkFloat,        # a leaf with a float value
    nkString,       # a leaf with a string value
    nkRow,          # a row node
    nkTable         # a table node
  Node* = ref object
    case kind*: NodeKind  # the ``kind`` field is the discriminator
      of nkInt: intVal*: int
      of nkFloat: floatVal*: float
      of nkString: strVal*: string
      of nkRow:
        values*: seq[Node]
      of nkTable:
        rows*: seq[Node]
    