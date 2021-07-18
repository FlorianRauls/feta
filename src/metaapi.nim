import spreadsheets
import macros


macro loadSpreadSheet * (statement : untyped) : SpreadSheet =
    ## Meta-Interface for the loading of SpreadSheets
    ## Simply add the new method you want to implement to it
    ## for easier interfacing
    for s in statement:
        case $s[0].ident:
            of "GoogleSheets":
                result = newCall("fromGoogleSheets", s[1])
            of "HTML":
                result = newCall("fromHTMLFile", s[1])
            of "CSV":
                result = newCall("fromCSV", s[1])
    