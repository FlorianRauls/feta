import macros

macro class*(head, body: untyped): untyped =
  # The macro is immediate, since all its parameters are untyped.
  # This means, it doesn't resolve identifiers passed to it.

  var typeName, baseName: NimNode

  # flag if object should be exported
  var isExported: bool

  if head.kind == nnkInfix and eqIdent(head[0], "of"):
    # `head` is expression `typeName of baseClass`
    # echo head.treeRepr
    # --------------------
    # Infix
    #   Ident !"of"
    #   Ident !"Animal"
    #   Ident !"RootObj"
    typeName = head[1]
    baseName = head[2]

  elif head.kind == nnkInfix and eqIdent(head[0], "*") and
       head[2].kind == nnkPrefix and eqIdent(head[2][0], "of"):
    # `head` is expression `typeName* of baseClass`
    # echo head.treeRepr
    # --------------------
    # Infix
    #   Ident !"*"
    #   Ident !"Animal"
    #   Prefix
    #     Ident !"of"
    #     Ident !"RootObj"
    typeName = head[1]
    baseName = head[2][1]
    isExported = true

  else:
    error "Invalid node: " & head.lispRepr


  # create a new stmtList for the result
  result = newStmtList()

  # create a type section in the result
  template typeDecl(a, b): untyped =
    type a = ref object of b

  template typeDeclPub(a, b): untyped =
    type a* = ref object of b

  if isExported:
    result.add getAst(typeDeclPub(typeName, baseName))
  else:
    result.add getAst(typeDecl(typeName, baseName))


  # var declarations will be turned into object fields
  var recList = newNimNode(nnkRecList)

  # expected name of constructor
  let ctorName = newIdentNode("new" & $typeName)

  # Iterate over the statements, adding `self: T`
  # to the parameters of functions, unless the
  # function is a constructor
  for node in body.children:
    case node.kind:

    of nnkMethodDef, nnkProcDef:
      # check if it is the ctor proc
      if node.name.kind != nnkAccQuoted and node.name.basename == ctorName:
        # specify the return type of the ctor proc
        node.params[0] = typeName
      else:
        # inject `self: T` into the arguments
        node.params.insert(1, newIdentDefs(ident("self"), typeName))
      result.add(node)

    of nnkVarSection:
      # variables get turned into fields of the type.
      for n in node.children:
        recList.add(n)

    else:
      result.add(node)

  result[0][0][2][0][2] = recList
