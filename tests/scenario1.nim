import feta

ONSERVER:
    ADDVIEW:
        LOAD:
            GoogleSheets:
                "1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c"
        AS:
            "400"
    ADDFORM:
        FROM_PROC:
            odslServer["400"][odslServer["400"].WHERE("E-Mail", "==", "-")]         
        AS:
            "401"       
        ACCEPTIF:
            if (len(COMMIT.WHERE("E-Mail", "!=", "-")) == 1):
                return true
            else:
                return false
        ALLOWEDIT:
            @["E-Mail"]
        ONACCEPT:
            var x = odslServer["400"]  
            x.UPDATE(COMMIT, "Date")
            odslServer["400"] = x


SHOW "401"
