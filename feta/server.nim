import asynchttpserver, asyncdispatch, tables, httpcore, spreadsheets, jester, os, asyncdispatch,  asyncfile, asyncstreams, streams
import jester/private/utils
import ws, ws/jester_extra
import json
import strutils

type 
  ## DataType which holds all necessary information for the SERVER
  CustomServer = object
    route : Table[string, SpreadSheet] ## Routes from an id to a SpreadSheet
    procRoute : Table[string, proc (): SpreadSheet] ## Routes from an id to a function which returns a SpreadSheet
    methods : Table[string, string] ## Routes from an id to the kind of SpreadSheet
    allowance : Table[string, seq[string]] ## Routes from an id to a sequence of booleans
    confirmRoute : Table[string, proc(s : SpreadSheet) : bool] ## Routes from an id to the confirmation function
    applyRoute : Table[string, proc(s : SpreadSheet)] ## Routes from an it to the proc which should be applied after confirmation
    errorMessage : Table[string, string] ## Routes from id to error message which should be thrown for user
    jester : Jester ## The Jester server object
    settings : Settings ## Settings for Jester server

var SERVER * : CustomServer ## SERVER-singleton which has to be reachable through FETA-code
SERVER.settings = newSettings(port=5000.Port) ## default port is 5000

proc parseResult * (received : JsonNode) : SpreadSheet =
  ## Receives the JsonNode, which was sent through a Websocket
  ## and parses it into s legit SpreadSheet
  var head = Row()
  var outRows : seq[Row]
  for x in received[0].keys():
    head = head.add(x)
  for item in received.items():
    var outRow = Row()
    for i in head.items:
      var s = $item[i.strVal]
      s = s[1..len(s)-2]
      outRow = outRow.add(s)
    outRows.add(outRow)
  result = newSpreadSheet("", outRows, head)


proc `[]=` * (server : var CustomServer, id : string, spread : SpreadSheet) =
  ## Gets the id of desired SpreadSheet on server
  ## and returns the SpreadSheet
  server.route[id] = spread

proc `[]` * (server : var CustomServer, id : string) : SpreadSheet =
  ## Gets the id of desired SpreadSheet on server
  ## and returns the SpreadSheet
  try:
    return server.route[id]
  except KeyError:
    return server.procRoute[id]()

## Jester router which configures routing automaticall
## Each added form/view is available through
## http://localhost:PORT/?id=ID
## where `ID` is the name the spreadsheet was given with
## `AS`

router myrouter:
  get "/":
    try:
      case request.reqMeth:
        of HttpGet:
          case SERVER.methods[request.params["id"]]:
            of "view":
              resp SERVER.route[request.params["id"]].generateHTMLView()
            of "form":
              resp SERVER.route[request.params["id"]].generateHTMLForm()
            of "function":
              var x = SERVER.allowance[request.params["id"]]
              resp SERVER.procRoute[request.params["id"]]().generateHTMLForm(x)
            else:
              resp "Unknown method!"
        else:
          resp "Unauthorized Method!"
    except Exception:
      resp getCurrentExceptionMsg()
  get "/ws":
    try:
      # Receives new request via Websocket
      var wsconn = await newWebSocket(request)
      var received = await wsconn.receiveStrPacket()
      var id : string

      # seperate id from json part
      var seperate : seq[string]

      for s in received.split("[", 1):
        seperate.add(s)
      echo seperate
      id = seperate[0]
      id = id[0..len(id)-2]

      # parse request to json
      seperate[1] = "[" & seperate[1] 
      var jso = parseJSON(seperate[1])
    
      # parse json to SpreadSheet
      var parsed = jso.parseResult()

      ###### Check if parsed result is valid############
      if SERVER.confirmRoute[id](parsed):
        SERVER.applyRoute[id](parsed)
        var mess = wsconn.send("success")
        ws.close(wsconn)
      else:
        var mess = wsconn.send(SERVER.errorMessage[id])
  
    except:
      echo "websocket close: ", getCurrentExceptionMsg()
    resp Http200, "file uploaded"

proc setPort * (port : int) =
  ## Takes a port number as input and initiates the HTTP-Server
  SERVER.settings = newSettings(port=port.Port)

proc addFormToServer*(p : proc (): SpreadSheet, id : string, confirm : proc (s : SpreadSheet) : bool,  apply : proc(s2 : SpreadSheet), permits : seq[string], error = "something went wrong") =
  ## Adds the given SpreadSheet to the given ID with
  ## desired kind
  SERVER.procRoute[id] = p
  SERVER.allowance[id] = permits
  SERVER.methods[id] = "function"
  SERVER.confirmRoute[id] = confirm
  SERVER.applyRoute[id] = apply
  SERVER.errorMessage[id] = error

proc addFormToServer*(p : proc (): SpreadSheet, id : string, confirm : proc (s : SpreadSheet) : bool,  apply : proc(s2 : SpreadSheet), error = "something went wrong") =
  ## Adds the given SpreadSheet to the given ID with
  ## desired kind
  SERVER.procRoute[id] = p
  SERVER.allowance[id] = @[]
  SERVER.methods[id] = "function"
  SERVER.confirmRoute[id] = confirm
  SERVER.applyRoute[id] = apply
  SERVER.errorMessage[id] = error
  
proc addToServer*(table : SpreadSheet, id : string, typ = "function") =
  ## Adds the given SpreadSheet to the given ID with
  ## desired kind
  SERVER.route[id] = table
  SERVER.methods[id] = typ

proc startServer () {.async.} =
  ## Starts serving the HTTP-Server
  SERVER.jester = initJester(myrouter, settings=SERVER.settings)
  SERVER.jester.serve()

proc serveServer * () =
  ## Initiates the Jester Server
  waitFor(startServer())
