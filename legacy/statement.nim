import lists

type
  Statement* = object
    word* : string # word used to describe the statement
    legalList* :  SinglyLinkedList[string] # list of words which can be used after this word


proc checkLegal*(following : string, this : SinglyLinkedList[string]) : bool =
  if "generic" in this:
    result = true
  else:
    result = following in this
  
#[ Statement Constructor ]#
proc newStatement*(name: string, legals : openArray[string]) : Statement =
    result.word = name
    result.legalList = initSinglyLinkedList[string]()
    for i in 0..len(legals)-1:
      var helper = newSinglyLinkedNode[string](legals[i])
      result.legalList.append(helper)
      
