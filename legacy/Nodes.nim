# abstract class of Nodes which will be used in the parse tree
type
  NodeKind* = enum  # the different node types
    nkInt,          # a leaf with an integer value
    nkFloat,        # a leaf with a float value
    nkString,       # a leaf with a string value
    nkRow,          # a row node
    nkHeader,       # a header node
    nkTable         # a table node
  Node* = ref object
    parent*: Node
    children*: seq[Node]
    case kind*: NodeKind  # the ``kind`` field is the discriminator
      of nkInt: intVal*: int
      of nkFloat: floatVal*: float
      of nkString: strVal*: string
      of nkRow:
        values*: seq[Node]
      of nkHeader: boolVal*: bool
      of nkTable:
        rows*: seq[Node]
        header*: Node

# corrsesponds to nkString
proc stringNode*(node : Node) : string =
  result= node.strVal

# corrsesponds to nkInt
proc intNode*(node : Node) : int =
  result= node.intVal

# corrsesponds to nkFloat
proc floatNode*(node : Node) : float =
  result= node.floatVal

# corrsesponds to nkRow
proc nkRowNode*(node : Node) : seq[Node] =
  result= node.values

# corrsesponds to nkHeaeder
proc headerNode*(node : Node) : bool =
  result= node.boolVal

# corrsesponds to nkTable
proc tableNode*(node : Node) : Node =
  result= node