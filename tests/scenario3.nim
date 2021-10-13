import feta

var spreadsheet = LOAD:
    Webcrawl:
        "www.addresofwebsite.com"
        
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
                x = x.WHERE("supervisor", "==", ROW["supervisor"])
                return x
            AS:
                ROW["supervisor"]
            ONACCEPT:
                var main = LOAD:
                    GoogleSheets:
                        "idforgooglesheets"
                main.UPDATE(COMMIT, "Title")
                main.SAVE:
                    GoogleSheets:
                        "idforgooglesheets"