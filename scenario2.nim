import src/odsl

var overView = fromGoogleSheets("1bVAbIYJx7ZGpi5IvhW9h1OfNhyP6jnHFnCxSPLuVG7c")


var relevant = view:
    source:
        overView
    keep:
        overView.where("E-Mail", "==", "-")
    columns:
        overView.header.getValues()

relevant.show()