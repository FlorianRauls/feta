import Nodes

proc interpret*(tree: Node) =
    echo len(tree.rows[0].values)