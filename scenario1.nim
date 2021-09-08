import src/odsl

###################### FINISHED FUNCTIONALITY DEMO ####################################

#[
# Pull a Spreadsheetfrom Google Sheets
var slots = loadSpreadSheet:
    GoogleSheets:
        "1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c"

proc getEmptySlots * () : SpreadSheet =
    ## Returns a view from the original SpreadSheet with condition:
    ## E-Mail must be empty (not filled out yet)
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

]#


###################### UNFINISHED DSL DEMO ####################################

ONSERVER:
    ADDVIEW:
        LOAD:
            GoogleSheets:
                "1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c"
        AS:
            "400"
    ADDFORM:
        LOAD:
            GoogleSheets:
                "1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c"
        AS:
            "401"
        ALLOWEDIT:
            @["Date", "Time", "E-Mail"]
        ACCEPTIF:
            if (len(COMMIT.WHERE("E-Mail", "!=", "-")) == 1):
                return true
            else:
                return false
        ONACCEPT:
            UPDATE 400 with COMMIT  


SHOW odslServer["401"]
serveServer()
