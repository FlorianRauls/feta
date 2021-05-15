import Nodes

#[Postorder traversal of the syntax tree in the style:
def visit(node):
    # for every child node from left to right
    for child in node.children:
        visit(child)
        <<<Do postorder actions>>>    
    
]#
proc traverse*(node: Node) = 
    if len(node.children) != 0:
        echo type(node.children)
        for child in node.children:
            traverse(child)
    else:
        echo type(node.children)
        return

proc interpret*(tree: Node) =
    traverse(tree)


