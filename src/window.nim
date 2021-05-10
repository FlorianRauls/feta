import std/rdstdin
import lists

# var input = readLineFromStdin("Is Nim awesome? (Y/n):")

type
  Terminal* = object # This is the table Object itself
    commands*: SinglyLinkedList[string] # Column Header
        
    