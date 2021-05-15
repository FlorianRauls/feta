import typetraits
import interpreter
import Nodes

proc buildParseTree*(annotatedSequence : seq[tuple[word: string, typ: string]]) =
  var tree : Node
  var row : Node
  var last : Node
  for index, word in annotatedSequence:
    if word[1] == "TABLE":
      tree = Node(kind: nkTable)
      tree.parent = tree
      last = tree
    elif word[1] == "SPECIFIER":
      row = Node(kind: nkRow)
      last.children.add(row)
      last = row
    elif word[1] == "HEADER":
      var header = Node(kind: nkHeader, boolVal: true)
      last.children.add(header)
      last = header
    elif word[1] == "ENTRY":
      if word[0].type.name == "string":
        var value = Node(kind: nkString, strVal: word[0])
        last.children.add(value)
    elif word[1] == "TERMINAL":
      tree.rows.add(row)
  interpret(tree)
    


