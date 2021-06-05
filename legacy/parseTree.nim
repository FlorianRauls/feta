import typetraits
import interpreter
import Nodes
import strutils

proc buildParseTree*(annotatedSequence : seq[tuple[word: string, typ: string]]) =
  var tree : Node
  var row : Node
  var last : Node
  for index, word in annotatedSequence:
    case word[1]:
    of "TABLE":
      tree = Node(kind: nkTable)
      tree.parent = tree
      last = tree
    of "SPECIFIER":
      row = Node(kind: nkRow)
      last.children.add(row)
      last = row
    of "HEADER":
      var header = Node(kind: nkHeader, boolVal: true)
      last.children.add(header)
      last = header
    of "STRING_ENTRY":
      if word[0].type.name == "string":
        var value = Node(kind: nkString, strVal: word[0])
        last.children.add(value)
    of "INT_ENTRY":
      if word[0].type.name == "string":
        var value = Node(kind: nkInt, intVal: parseInt(word[0]))
        last.children.add(value)
    of "FLOAT_ENTRY":
      if word[0].type.name == "string":
        var value = Node(kind: nkFloat, floatVal: parseFloat(word[0]))
        last.children.add(value)
    of "TERMINAL":
      tree.rows.add(row)
  interpret(tree)
    


