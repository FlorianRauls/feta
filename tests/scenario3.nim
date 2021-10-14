import ../feta

var spreadsheet = LOAD:
    HTML:
        "website.html"
        
spreadsheet.SAVE:
    GoogleSheets:
        "idforgooglesheets"

ONSERVER:
    for ROW in spreadsheet.rows:
        ADDFORM:
            FROM_PROC:
                var x = LOAD:
                    GoogleSheets:
                        "idforgooglesheets"
                x = x[x.WHERE("supervisor", "==", ROW[spreadsheet.COLUMNINDEX("supervisor")])]
                return x
            AS:
                ROW[spreadsheet.COLUMNINDEX("supervisor")]
            ONACCEPT:
                var main = LOAD:
                    GoogleSheets:
                        "idforgooglesheets"
                main.UPDATE(COMMIT, "Title")
                main.SAVE:
                    GoogleSheets:
                        "idforgooglesheets"