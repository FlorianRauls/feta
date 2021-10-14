import feta

var scen_path = "tests/scenarioData/"

var scenario2_data = CREATE_SPREADSHEET:
    "name" | "year" | "leftProperty" | "deposit" | "E-Mail"
    "Fredericke Maier" | "2021" | "true" | 5000 | "f.maier@trash-mail.com"
    "Felicia Möhrenfeld" | "2020" | "true" | 5000 | "f.moehrenfeld@trash-mail.com"
    "Manfred Esel" | "2021" | "false" | 7000 | "m.esel@trash-mail.com"
    "Ali Franken" | "2021" | "false" | 6000 | "a.franken@trash-mail.com"
    "Alex Maier" | "2012" | "true" | 5000 | "f.maier@trash-mail.com"
    "Frank Möhrenfeld" | "2005" | "true" | 5000 | "f.moehrenfeld@trash-mail.com"
    "Manueala Esel" | "2021" | "false" | 7000 | "m.esel@trash-mail.com"
    "Alina Franken" | "2021" | "false" | 6000 | "a.franken@trash-mail.com"

scenario2_data.SAVE:
    CSV:
        scen_path & "scenario2.csv"

var scenario3_data = CREATE_SPREADSHEET:
    "supervisor" | "author" | "title"
    "Prof.D.Systems" | "Lorian Auls" | "Creation of a DSL that can do like office and stuff."
    "ProfRAndom" | "Senior Ipsum" | "Looking at a rock for a very long time"
    "Prof.Eggman" | "Sonic Hedge Hog" | "Planets and Partys"
    "Prof.White" | "Jessy Pink" | "Tasty crytals"
    "Prof.White" | "Jordan Yellow" | "Not so tasty crytals"
    "Prof.Lang" | "Gram Mar" | "The Duden but like in blue"

scenario3_data.SAVE:
    HTML:
        scen_path & "scenario3.html"

var scenario4_1_data = CREATE_SPREADSHEET:
    "Manager" | "E-Mail" 
    "Felix Krull" | "krull@intern.com"
    "Melanie Melsen" | "melsen@intern.com"
    "Thomas Buddenbrook" | "buddenbrook@intern.com"
    "Madame Chauchat" | "chauchat@intern.com"

scenario4_1_data .SAVE:
    HTML:
        scen_path & "scenario4.html"


var scenario4_2_data = CREATE_SPREADSHEET:
    "Name" | "Department"
    "Felix Krull" | "Geldverdiener Department"
    "Melanie Melsen" | "Entwicklungs DEpartment"
    "Thomas Buddenbrook" | "Pausen Department"
    "Madame Chauchat" | "Pfefferlager Department"
    "Felix Not-Krull" | "Geldverdiener Department"
    "Melanie Not-Melsen" | "Entwicklungs DEpartment"
    "Thomas Not-Buddenbrook" | "Pausen Department"
    "Madame Not-Chauchat" | "Pfefferlager Department"
scenario4_2_data.SAVE:
    CSV:
        scen_path & "scenario4.csv"