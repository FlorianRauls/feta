import std/rdstdin
import lists
import strutils
import lexer

type
  Terminal* = object # This is the table Object itself
    commands*: SinglyLinkedList[string] # Column Header
    lastLine* : string

proc getInput*() : string = readLineFromStdin("") # wait for user input from terminal and return it as string

# read string split it after each ' ' and return result as SinglyLinkedList
proc insertInput*(input : string) : SinglyLinkedList[string] =
  for word in split(input):
     var helper = newSinglyLinkedNode[string](word)
     result.append(helper)


proc startEvaluation*(terminal : Terminal) =
  evaluateSentence(terminal.commands)

# constructor for Terminal which reads user input and starts the evaluation
proc newTerminal*() : Terminal =
  result.lastLine = getInput()
  result.commands = insertInput(result.lastLine)
  startEvaluation(result)




