import json

# proc to load JSON file from given location
proc readJSON(location : string): JsonNode =
    var js: JsonNode
    js = parseFile(location)
    result = js

# loads EBNF form from JSON file @path
var path = "files/ebnf.json"
var StatementsMatcher* = readJSON(path)

