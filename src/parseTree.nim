import typetraits
import interpreter
import Nodes

proc buildParseTree*(annotatedSequence : seq[tuple[word: string, typ: string]]) =
  var tree : Node
  var row : Node
  for index, word in annotatedSequence:
    if word[1] == "TABLE":
      tree = Node(kind: nkTable)
    elif word[1] == "SPECIFIER":
      row = Node(kind: nkRow)
    elif word[1] == "ENTRY":
      if word[0].type.name == "string":
        var value = Node(kind: nkString, strVal: word[0])
        row.values.add(value)
    elif word[1] == "TERMINAL":
      tree.rows.add(row)
  interpret(tree)
    


