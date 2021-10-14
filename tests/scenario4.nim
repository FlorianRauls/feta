import ../feta

var departments = LOAD: #load departments from website
    HTML:
        "scenarioData/scenario4.html"

departments.RENAMECOLUMN:  #rename for later join
    FROM:
        "Manager"
    TO:
        "Name"

var staff = LOAD: #load staff from csv
    CSV:
        "./pathtofile/file.csv"

var managers = departments.JOIN: # join
    WITH:
        staff
    ON:
        "Name"

var surveyform = CREATE_SPREADSHEET: # survey we want to send out
    "Happiness Rating" | "Private Note"
    null               | null
    
var acceptable = ["1","2","3","4","5","6","7","8","9","10"] #acceptable submission values

ONSERVER: # start server
    for ROW in managers.rows: #add for every row in managers a new form to server
        ADDFORM:
            FROM_SPREADSHEET:
                surveyform
            AS:
                ROW[managers.COLUMNINDEX("Name")] #forms are individualized per person
            ACCEPTIF: # check if submission has acceptable length and values
                if COMMIT.AT(1, "Happiness Rating") in acceptable:
                    if len(COMMIT.AT(1, "Private Note")) < 150:
                        return true
            ONACCEPT:
                COMMIT.SAVE:
                    CSV:
                        "survey.csv"
        SENDMAIL: # send survey out to each manager
            TO:
                ROW[managers.COLUMNINDEX("E-Mail")]
            SUBJECT:
                "New manager happiness survey"
            TEXT:
                "www.intranet.intern/?id=" & ROW[managers.COLUMNINDEX("Name")]