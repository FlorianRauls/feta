import ../feta

var spreadsheet = LOAD:
    CSV:
        "./tests/scenarioData/scenario2.csv"


echo("Loaded spreadsheet:")
SHOW spreadsheet


var currentYear = spreadsheet[spreadsheet.WHERE("year", "==", "2021")]

echo("Spreadsheet after conditional view was created:")
SHOW currentYear

var currentYearNotLeft = currentYear[currentYear.WHERE("leftProperty", "==", "false")]

echo("Spreadsheet after second conditional view was created:")
SHOW currentYearNotLeft

currentYearNotLeft.REMOVECOLUMN:
    "year"
    "leftProperty"
    "deposit"

echo("Spreadsheet after colums year, leftProperty and deposit were dropped:")
SHOW currentYearNotLeft

currentYearNotLeft.ADDCOLUMN:
    "cleaningDate" | "11.11.21" | "10.10.21" | "09.09.21" | "08.08.21"


echo("Spreadsheet after cleaningDate was added:")
SHOW currentYearNotLeft


try:
    for ROW in currentYearNotLeft.rows:
        SENDMAIL:
            TO:
                ROW[currentYearNotLeft.COLUMNINDEX("E-Mail")]
            SUBJECT:
                "Your cleaning date"
            TEXT:
                """
                Hello there,
                
                I wanted to inform you about your cleaning responsibilities.
                You are responsible for cleaning the property on the following date:
                
                """ & ROW[currentYearNotLeft.COLUMNINDEX("cleaningDate")] & """
                
                Thank you very much,
                Your landlord
                """
except OSError:
    echo "You need to enter your E-Mail information to run the rest of scenario2. Further information: https://github.com/FlorianRauls/feta/wiki/Quick-Start-Guide"