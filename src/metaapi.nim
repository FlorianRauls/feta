import spreadsheets
import macros


macro loadSpreadSheet * (statement : untyped) : SpreadSheet =
    ## Meta-Interface for the loading of SpreadSheets
    ## Simply add the new method you want to implement to it
    ## for easier interfacing
    case $statement[0].ident:
        of "GoogleSheets":
            result = newCall("fromGoogleSheets", statement[1][0])
        of "HTML":
            result = newCall("fromHTMLFile", statement[1][0])
        of "CSV":
            result = newCall("fromCSV", statement[1][0])


macro saveSpreadSheet * (statement : untyped) : SpreadSheet =
    ## Meta-Interface for the saving of SpreadSheets
    ## Simply add the new method you want to implement to it
    ## for easier interfacing
    case $statement[0].ident:
        of "GoogleSheets":
            result = newCall("toGoogleSheets", statement[1][0])
        of "HTML":
            result = newCall("toHTMLFile", statement[1][0])
        of "CSV":
            result = newCall("toCSV", statement[1][0])