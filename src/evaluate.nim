import lists
import statementMatcher
import statement
import json

type
    Evaluator* = object

#[ This feels like a hack but I cannot find a more efficient way to deal with this problem since
Nim's JSON mechanics are really strange to me.
To check the grammatical legality of a given sentence we go through each word
and check whether or not the following word is inside the legal scope of the current one
aka whether it follows the production rules of this language.
The legal scope is saved as a JSON file and read into the StatementsMatcher type
but since easy casting from JSONArray to SinglyLinkedList is not possible
I iterate over the array, cast each JSONNode to string and save these strings
as nodes in a constructedList to pass it on as the legal context]#
proc legalSentence*(sentence : SinglyLinkedList) : bool =
    for word in sentence.nodes():
        var statement = StatementsMatcher[word.value]
        var reference = statement["legalList"]
        var constructedList = initSinglyLinkedList[string]()
        for item in items(reference):
            var helper = newSinglyLinkedNode[string](to(item, string))
            constructedList.append(helper)
        if word.next != nil:
            result = checkLegal(word.next.value, constructedList)
        else:
            result = true

proc evaluateSentence*(sentence : SinglyLinkedList[string]) =
    var check = legalSentence(sentence)
    if  check == true:
        echo "This went right buddy"
    else:
        echo "This went wrong buddy"

