import ../feta

var spreadsheet = LOAD:
    HTML:
        "tests/scenarioData/scenario3.html"


echo("Following spreadsheet was loaded from HTML:")  
SHOW spreadsheet


spreadsheet.SAVE:
    CSV:
        "tests/scenarioData/scenario3.CSV"


ONSERVER:
    for ROW in spreadsheet.rows:
        ADDFORM:
            FROM_PROC:
                var x = LOAD:
                    CSV:
                        "tests/scenarioData/scenario3.CSV"
                x = x[x.WHERE("supervisor", "==", ROW[spreadsheet.COLUMNINDEX("supervisor")])]
                return x
            AS:
                ROW[spreadsheet.COLUMNINDEX("supervisor")]
            ALLOWEDIT:
                @["title"]
            ACCEPTIF:
                return true
            ONACCEPT:
                var main = LOAD:
                    CSV:
                        "tests/scenarioData/scenario3.CSV"
                main.UPDATE(COMMIT, "supervisor")
                main.SHOW()
                main.SAVE:
                    CSV:
                        "tests/scenarioData/scenario3.CSV"
                echo("Following spreadsheet was saved after changes:")  
                SHOW main