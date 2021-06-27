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
        "Christine Christensen" | 45 | 250000
        "Karl Karlson" | 27 | null

# Showw AddColumn
sheet.addColumn("E-Mail", "a" | "b" | null | null)

# Show Spreadsheet
sheet.show()

# show indexed Spreadsheet
sheet["Name", 1].show()

# Remove Column "Salary"
sheet -= "Salary"

# Show Spreadsheet
sheet.show()

# Remove Column "Age" to "New Column Name"
sheet.renameColumn("Age", "New Column Name")

# Show Spreadsheet
sheet.show()

# Rename Spreadspeet
sheet := "New Spreadsheet Name"

# Show Spreadsheet
sheet.show()

# Try to remove column "Does Not Exist" which does not exist
try:    
    sheet -= "Does Not Exist"
except OSError:
    echo "Did throw expected error!"

# Save Spreadsheet to Google Sheets by given id
sheet.toJSONBody().writeGoogleSheet("1HOyMTEX4amGp_Kn6O_vsJKchFsSIwGyRC4VsQLzY1MA")

##################################################################################

