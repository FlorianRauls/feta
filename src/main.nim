import statement
import table
import lists
import std/rdstdin
import window

var
 exampleNames = initDoublyLinkedList[string]()
 a = newDoublyLinkedNode[string]("a")
 c = newDoublyLinkedNode[string]("c")
exampleNames.append(a)
exampleNames.append(c)

var example = newTable(exampleNames)

echo example