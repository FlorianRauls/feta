import src/odsl

###################### DSL DEMO ####################################

ONSERVER:
    ADDVIEW:
        CREATE_SPREADSHEET:
            "Name" | "E-Mail" | "ID" and
            "Hans Hansen" | "hansen@hans.hans" | "h4nS"
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
            SHOW COMMIT 


SHOW "401"
