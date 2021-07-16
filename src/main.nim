import odsl
import dsl       
import api

############################ ODSL Sytax Showcase #################################

# create new Spreadsheet
var sheet = spreadsheet:
    setName:
        "Organization"

    header:
        "Name" | "Age" | "Salary"
    
    values:
        "Max Maxson" | 35 | 3500.99
        "Jennifer Jennifson" | null | 12.75
        "Christine Christensen" | 45 
        "Karl Karlson" | 27 | null

sheet.writeHTML("try.html")

var testFileIntegrity = readFile("try.html")

var newSheet = fromHtml(testFileIntegrity)
newSheet.show()
newSheet.setNewValue(2, "Name", "Neues Name")
newSheet.addColumn("index", 1 | 0 | 2 | 3)
sheet.show()
sheet.update(newSheet)
sheet.show()


#[

# Show AddColumn
sheet.addColumn("E-Mail", "thisis@an-email.com" | "hi_iam_an_email@email.email" | null )
sheet += "Jens Jensen" | 72 | 3400 | null 

# Show Spreadsheet
sheet.show()

# show indexed Spreadsheet
sheet.setValue:
    index:
        1
    column:
        "Name"
    newValue:
        "Peter Zwegat"

# Remove Column "Salary"
sheet -= "Salary"

# Show Spreadsheet
sheet.show()

# Show Spreadsheet
sheet.show()

# Create second sheet for join:
var sheet2 = spreadsheet:
    setName:
        "Budget Team"

    header:
        "Name" | "Social Security Number" 
    
    values:
        "Max Maxson" | 3235325 
        "Jennifer Jennifson" | null
        "Neuer Name" | 3487832
        "Christine Christensen" | 4235235 
        "Karl Karlson" | 273434 
        "Neuer Name" | 5438745


# Show Spreadsheet
sheet.show()
sheet2.show()

# join tables
sheet.joinSpreadSheets(sheet2, "Name")
sheet.show()

# try to change permissions: Allow user "faculty" to not edit "Name" and "Social Security Number"
sheet.setPermissions("faculty", @["Name", "Social Security Number"])

sheet.show()

# Save Spreadsheet to Google Sheets by given id
sheet.toJSONBody().writeGoogleSheet("1HOyMTEX4amGp_Kn6O_vsJKchFsSIwGyRC4VsQLzY1MA")

]#
#[

var message = table.formatText:
    tokens:
        [Column1, Column2, Column3]

    format:
        """Hey there {Column1},

        we are contacting you because of the complaint you have opened in
        File No. {Column2}.
        Your complaint read as follows:
            {Column3}
        Is this issue still open?

        Your team at,
        Soulless Inc."""
]#

##################################################################################

