import odsl
import dsl       


#[
# OPEN SYNTAX IDEAS:

################################## Clean Human Code #############################################

var sheet = spreadsheet:
    setName:
        "Organization"

    header:
        "Name" | "Age" | "E-Mail" | "Salary"
    
    values:
        "Max Maxson" | 35 | "example@mail-address.de" | 3782.35
        "Jennifer Jennifson" | 22 | "also@mail-address.de" | 10783.00
        "Christine Christensen" | 45 | "beispiel@mail-address.de" | 35.89
        "Karl Karlson" | 27 | "definitiv_eine_mail_adresse@mail-address.de" | 6472.91


+ Close to native Nim which is good for people already using it
+ Readable
+ Nim Macros can make this quite effective

- Mimicing Programming Language might not be a good basis for all domain experts
- Adding Domain Elements might become cluncky


################################# Operator Opera #############################################

Spreadsheet from Empty
Spreadsheet := "Organization"
Spreadsheet.header += "Name" | "Age" | "E-Mail" | "Salary" 
Spreadsheet += "Max Maxson" | 35 | "example@mail-address.de" | 3782.35
Spreadsheet += "Jennifer Jennifson" | 22 | "also@mail-address.de" | 10783.00
Spreadsheet += "Christine Christensen" | 45 | "beispiel@mail-address.de" | 35.89
Spreadsheet += "Karl Karlson" | 27 | "definitiv_eine_mail_adresse@mail-address.de" | 6472.91

+ Easiest to implement
+ Concise

- Not all operations have to or can be implemented intuitively with operators
- Not the easiest on the eye
- Does not really play into Nim's strengths

############################### Natural Language Impostor ################################

Create mySpreadsheet: 
    - named "Organization"
    - values:
        - "Max Maxson" | 35 | "example@mail-address.de" | 3782.35
        - "Jennifer Jennifson" | 22 | "also@mail-address.de" | 10783.00
        - "Christine Christensen" | 45 | "beispiel@mail-address.de" | 35.89
        - "Karl Karlson" | 27 | "definitiv_eine_mail_adresse@mail-address.de" | 6472.91


+ Readable
+ Close to domain elements
+ Nim Macros can make this quite effective

- Natural language can become a false friend for the user
- Rather difficult on the implementation site

###############################
]#