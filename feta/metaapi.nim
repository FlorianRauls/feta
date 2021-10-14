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
        of "Webcrawl":
            result = newCall("fromWebsite", statement[1][0])


macro saveSpreadSheet * (sheet : SpreadSheet, avenue : string, parameter : string) =
    ## Meta-Interface for the saving of SpreadSheets
    ## Simply add the new method you want to implement to it
    ## for easier interfacing
    echo avenue.kind
    case $avenue:
        of "GoogleSheets":
            result = newCall("toGoogleSheets", sheet, parameter)
        of "HTML":
            result = newCall("writeHTML", sheet, parameter)
        of "CSV":
            result = newCall("toCSV", sheet, parameter)