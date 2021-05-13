
# abstract class of Nodes which will be used in the parse tree
type
  Node = ref object of RootObj
    parent* : Node # parent of current node
    children*: seq[Node] # sequence of children of current node
    identifier* : string

  Creation = ref object of Node
  Table = ref object of Node
  Specifier = ref object of Node
  StringEntry = ref object of Node
    value : string
  EntrySeperator = ref object of Node 
    

proc buildParseTree*(annotatedSequence : seq[tuple[word: string, typ: string]]) =
    for word in items(annotatedSequence):
      echo word[1]
