import src/odsl

#[
An editor creates a table "slots" visible only to him/her, with time slots and columns for additional infos, e.g. email 
    There is a dynamic view "free_slots": 
        Each instance shows only certain columns (e.g. "Private_notes" is hidden) 
        Only rows with empty name (and/or email?) are shown 

    There is a dynamically generated web form "user_input", partially editable 
        It has the same entries as view "free_slots" 
        Only columns "Name" and "Email" are editable 

There is a submit button with attached "action script" 
    After submit  
        Simple version: 
            Update "slots" with data from the filled-out row 

        Advanced version: 
            Check that only one row was edited 

            Not: redisplay with a text "Please use only one slot"  

            Verify whether the name and/or email already exist in the table 

            if yes, redisplay with previous data, and additional button "delete" 

            # This can be also shown after a link "update" is clicked [**] 

            Verify whether an entry is no longer free (to avoid conflicts from concurrent editing) 

            If already used, show a text "Slot already taken" and show a button to re-try 

            If all is ok, update "slots" with this data 

            Optional: show a link to update later; this leads to scenario [**] 

]#


var slots = fromGoogleSheets("1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c")
slots.show()

proc getEmptySlots * () : SpreadSheet =
    ## Returns a view from the original SpreadSheet
    ## Based on Empty values
    result = odslServer["400"].where("E-Mail", "==", "-")
    result.show()

proc confirmRequirement * () : bool =
    result = false

proc applyChanges * () =
    echo "VIVA LA REVOLUCION"

initServer(5000)
addToServer(slots, "400", "view")
addToServer(getEmptySlots, "401", confirmRequirement, applyChanges, "Oopsie Whoopsie")
serveServer()