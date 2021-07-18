import src/odsl

# Pull a Spreadsheetfrom Google Sheets
var slots = loadSpreadSheet:
    GoogleSheets:
        "1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c"

# Define a proc which we will use for faster selection
proc getEmptySlots * () : SpreadSheet =
    ## Returns a view from the original SpreadSheet
    ## Based on Empty values
    result = view:
        source:
            odslServer["400"]
        keep:
            odslServer["400"].where("E-Mail", "==", "-")
        columns:
            @["Date", "Time", "E-Mail"]

    result.setPermissions:
        user:
            "UNIVERSAL"
        permits:
            @["E-Mail"]
        
    

# Define a proc which handles the confirmation of allowed commits
proc confirmRequirement * (passed : SpreadSheet) : bool =
    var filter = view:
        source:
            passed
        keep:
            passed.where("E-Mail", "!=", "-")

    if len(filter) == 1:
        if filter[0, "E-Mail"].strVal notin odslServer["400"]["E-Mail"]:
            result = true
    else:
        result = false

# Define a proc which handles everything that happens after a legal commit
proc applyChanges * (passed : SpreadSheet) =
    var copy = odslServer["400"]

    var relevant = view:
        source:
            passed
        keep:
            passed.where("E-Mail", "!=", "-")
        columns:
            passed.header.getValues()

    copy.update(relevant, "Date")
    odslServer["400"] = copy



# add an example main view to the server
addToServer(slots, "400", "view")
# add an example editor view to the server
addToServer(getEmptySlots, "401", confirmRequirement, applyChanges, "Please fill out only one row and commit your answer one time!")
# run the server
serveServer()