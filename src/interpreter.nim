import Nodes
import deques

#[Postorder traversal of the syntax tree in the style:
def visit(node):
    # for every child node from left to right
    for child in node.children:
        visit(child)  
Nodes get saved in the execStack so they can later be exectued in the right order
]#
var execStack : seq[Node]
proc postorder*(node: Node) =
  if node.isNil: return
  else: 
      execStack.add(node)
      for child in node.children:
        postorder(child)

proc interpret*(tree: Node) =
    # build exec Stack
    postorder(tree)
    # exectute exec Stack
    for item in execStack:
        echo item.kind


