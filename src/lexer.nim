import lists
{. warning[UnusedImport]:off .}
import statementMatcher
import statement
import json

type
    Evaluator* = object

#[ This feels like a hack but I cannot find a more efficient way to deal with this problem since
Nim's JSON mechanics are really strange to me.
To check the grammatical legality of a given sentence we go through each word
and check whether or not the following word is inside the legal production rules of this language.
The EBNF is saved as a JSON file and read into the StatementsMatcher type
but since easy casting from JSONArray to SinglyLinkedList is not possible
I iterate over the array, cast each JSONNode to string and save these strings
as nodes in a constructedList to pass it on as the legal context]#
proc legalSentence*(sentence : SinglyLinkedList) : bool =
    # go through the whole sentence
    for word in sentence.nodes():
        # get information about current input
        var statement : JsonNode
        try:
            statement = StatementsMatcher[word.value]
        except:
            var output = word.value & " is an unknown statement."
            raise newException( FieldError, output )

        # get EBNF production rules of current word
        var reference = statement["prodRule"]
        # cast from JSONarray to SinglylinkedList
        var constructedList = initSinglyLinkedList[string]()
        for item in items(reference):
            var helper = newSinglyLinkedNode[string](to(item, string))
            constructedList.append(helper)
        # if current word is not the last word we use the next one
        if word.next != nil:
            # get type of next word
            var typ = to(StatementsMatcher[word.next.value]["type"], string)
            # check if fits the production rules
            result = checkLegal(typ, constructedList)
            # if not break and throw error
            if result != true:
                break
        # we check if our word is a terminalsymbol
        else:
            var typ = "TERMINAL"
            # check if fits the production rules
            result = checkLegal(typ, constructedList)
 

proc evaluateSentence*(sentence : SinglyLinkedList[string]) =
    var check = legalSentence(sentence)
    if  check == true:
        echo "This went right buddy"
    else:
        echo "This went wrong buddy"

