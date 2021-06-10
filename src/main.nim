import odsl
import dsl
import macros

        

var sheet = spreadsheet:
    name:
        "Organization"
    values:
        "Max Maxson" | 35 | "example@mail-address.de" 
        "Jennifer Jennifson" | 22 | "also@mail-address.de" 
        "Christine Christensen" | 45 | "beispiel@mail-address.de" 
        "Karl Karlson" | 27 | "definitiv_eine_mail_adresse@mail-address.de" 

debugTable(sheet)

#[
# OPEN SYNTAX GOALS:
Table:
    name | date | e-mail from 'real_file.xlsx'

Table:
    for name | date | e-mail in table   
]#