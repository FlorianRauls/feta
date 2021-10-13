import ../feta

var spreadsheet = LOAD:
    CSV:
        "scenarioData/scenario2.csv"

var currentYear = spreadsheet[spreadsheet.WHERE("year", "==", "2021")]
var currentYearNotLeft = currentYear[currentYear.WHERE("leftProperty", "==", "false")]
currentYearNotLeft.REMOVECOLUMN:
    "year"
    "leftProperty"
    "deposit"

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
            
            """ & ROW[currentYearNotLeft.COLUMNINDEX("cleaningdate")] & """
            
            Thank you very much,
            Your landlord
            """
