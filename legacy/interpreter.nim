import Nodes
import deques
import macros 
import table
import algorithm
import strutils

#[Postorder traversal of the syntax tree.
Nodes get saved in the execStack so they can
later be exectued in the right order
]#
var execStack : seq[Node]
proc postorder*(node: Node) =
  if node.isNil: return
  else: 
      execStack.add(node)
      for child in node.children:
        postorder(child)

# result of node visitations will be stored in temporary stacks which will be flushed as soon
# as node values are needed

# cell stack
var cellStack : seq[Cell]
# row stack
var rowStack : seq[Row]
# table stack
var tableStack : seq[Table]
# header indicator
var header = false

# construct cell from node
proc visit_stringNode(node : Node) =
  # stripping quotations from strings
  var cell = Cell(kind : CellKind.nkString, strVal : node.strVal.strip(chars = {'\'','\"'}))
  cellStack.add(cell)

# construct cell from node
proc visit_intNode(node : Node) =
  var cell = Cell(kind : CellKind.nkInt, intVal : node.intVal)
  cellStack.add(cell)

# construct cell from node
proc visit_floatNode(node : Node) =
  var cell = Cell(kind : CellKind.nkFloat, floatVal : node.floatVal)
  cellStack.add(cell)

# construct row from cellStack infomraiton
# and reset it afterwards
proc visit_rowNode(node: Node) =
  cellStack.reverse()
  var row = Row(values : cellStack)
  cellStack = @[]
  rowStack.add(row)

# construct table from header and rowStack information
# and reset them afterwards
proc visit_tableNode(node: Node) =
  rowStack.reverse()
  var table = Table(interpretHeader : header, rows : rowStack)
  rowStack = @[]
  header = false
  tableStack.add(table)

proc visit_headerNode(node: Node) =
  header = true

proc interpret*(tree: Node) =
    # build exec Stack
    postorder(tree)
    # exectute exec Stack
    execStack.reverse()
    for item in execStack:
        case item.kind 
          of NodeKind.nkInt: 
            visit_intNode(item)
          of NodeKind.nkFloat: 
            visit_floatNode(item)
          of NodeKind.nkString: 
            visit_stringNode(item)
          of NodeKind.nkRow:
            visit_rowNode(item)            
          of NodeKind.nkHeader: 
            visit_headerNode(item)
          of NodeKind.nkTable:
            visit_tableNode(item)

    debugTable(tableStack[0])