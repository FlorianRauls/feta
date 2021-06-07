import googleapi/connection
import googleapi/sheets
import googleapi/drive
import asyncdispatch, json, os, streams, strformat
import strutils
import json
import odsl
import httpclient
import files/userData

var name = "files/odsl-316010-9ac42c4cd821.json"
var conn = waitFor newConnection(name)
var id = "1HOyMTEX4amGp_Kn6O_vsJKchFsSIwGyRC4VsQLzY1MA"
const sheetApiURL = "https://sheets.googleapis.com/v4/spreadsheets"
const driveApiURL = "https://www.googleapis.com/drive/v3"

proc openSheet * (name : string) {.async} =
    var sheet = await getValues(conn, name, "A1:B10")
    echo $sheet

proc writeSheet * (sheet : JsonNode) =
    echo sheet
    var cut = len($sheet["range"])-2
    var ran = $sheet["range"]
    var x = waitFor setValues(conn, id, ran[1..cut], sheet)
    echo x

proc shareGoogleSheet (id : string, mail : string) : Future[JsonNode] {.async.}  =
    var formatId = id[1..len(id)-2]
    formatId = formatId.strip(leading=true, trailing=true)
    var exactUrl = driveApiURL & "/files/" & formatId & "/permissions"
    var body = %*{"type": "user", "role": "writer","emailAddress": mail}
    return await conn.post(exactUrl, body= body)

proc createNewGoogleSheet * (title : string) : Future[JsonNode] {.async.}  =
    var body = %* {"properties" : {"title": title} }
    var response = await conn.post(sheetApiURL, body= body)
    return response


var x = waitFor createNewGoogleSheet("postTest")

var newId = $ x["spreadsheetId"]
var shareResp = waitFor shareGoogleSheet(newId, userMail)
echo $shareResp