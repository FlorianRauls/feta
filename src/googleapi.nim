import googleapi/connection
import googleapi/sheets
import googleapi/drive
import asyncdispatch, json
import strutils
import json
from files/userData import userMail

# location of odsl-service worker json for google authorization
var name = "src/files/odsl-316010-9ac42c4cd821.json"

echo ""
echo "Initalizing your Google Account..."
echo "This may take a short while..."
echo ""
# initalized Google Sheets API worker
var conn = waitFor newConnection(name)
echo "Google Worker Initalized!"
echo ""

# API URLs
const sheetApiURL = "https://sheets.googleapis.com/v4/spreadsheets"
const driveApiURL = "https://www.googleapis.com/drive/v3"

# given a certain filde id request said file from google API
# TO-DO implement error message!
proc openSheet * (name : string) : JsonNode =
    result = waitFor(getValues(conn, name, "A1:BZ1000"))

# given a certain body json send said json to google API
# TO-DO implement error message!
proc writeGoogleSheet * (sheet : JsonNode, id : string) =
    echo sheet
    var cut = len($sheet["range"])-2
    var ran = $sheet["range"]
    var x = waitFor setValues(conn, id, ran[1..cut], sheet)
    x = x

# given a file id and a mail address share corresponding file with given mail
# TO-DO implement error message!
proc shareGoogleSheet * (id : string, mail : string, permission : string) : Future[JsonNode] {.async.}  =
    var formatId = id[1..len(id)-2]
    formatId = formatId.strip(leading=true, trailing=true)
    var exactUrl = driveApiURL & "/files/" & formatId & "/permissions"
    var body = %*{"type": "user", "role": permission,"emailAddress": mail}
    return await conn.post(exactUrl, body= body)

# given a title create a new GoogleSheet on your service worker
# TO-DO implement error message!
proc createNewGoogleSheet * (title : string) : Future[JsonNode] {.async.}  =
    var body = %* {"properties" : {"title": title} }
    var response = await conn.post(sheetApiURL, body= body)
    return response
