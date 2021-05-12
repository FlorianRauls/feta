import json

proc readJSON(location : string): JsonNode =
    var js: JsonNode
    js = parseFile(location)
    result = js

var path = "files/statements.json"
var StatementsMatcher* = readJSON(path)

