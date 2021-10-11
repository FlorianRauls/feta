# Package

version     = "0.0.5"
author      = "Florian Rauls"
description = "A domain-specific for general purpose office automation. The language is embedded in Nim and allows for quick and easy integration of different office software environments."
license     = "MIT"
installDirs = @["feta"]

# Deps

requires "nim >= 1.2.0"
requires "mime >= 0.0.3"
requires "jester >= 0.5.0"

proc installEmail() =
    echo("\e[1;33m Do you wish to use email functionality?  \e[1;34m[\e[1;32my\e[1;34m/\e[1;31mN\e[1;34m]")
    var email_check = readLineFromStdin()
    var userDataLocation = "feta/files/userData.nim" # location of userData.nim
    if email_check == "y":
        if fileExists(userDataLocation):
            echo("\e[1;31m Warning: Your following answers will be saved as plain text!")
            var file = readFile(userDataLocation) # read file

            # get email
            var x_file = file.find("\"\"") # finds spot to fill out
            echo("\e[1;33m Insert the email address you want to use:")
            var new_mail = readLineFromStdin()
            if new_mail == "":
                installEmail()
            file[x_file..x_file+1] = "\"" & new_mail & "\""

            # get password
            x_file = file.find("\"\"") # finds spot to fill out
            echo("\e[1;33m Insert the email password you want to use:")
            var new_word = readLineFromStdin()
            if new_word == "":
                installEmail()
            file[x_file..x_file+1] = "\"" & new_word & "\""

            # getsmtpserver
            x_file = file.find("\"\"") # finds spot to fill out
            echo("\e[1;33m Insert the address of the smtp-server you want to use:")
            var new_server = readLineFromStdin()
            if new_server == "":
                installEmail()
            file[x_file..x_file+1] = "\"" & new_server & "\""

            # getsmtpserver port
            x_file = file.find("\"\"") # finds spot to fill out
            echo("\e[1;33m Insert port of the smtp-server you want to use:")
            var new_port = readLineFromStdin()
            if new_port == "":
                installEmail()
            file[x_file..x_file+1] = "\"" & new_port & "\""

            writeFile(userDataLocation, file)
            echo("\e[1;31m If you want to make any changes, go to the following file: " & userDataLocation)
            echo file
        else:
            echo userDataLocation & " does not exist. Continuing installation."
    elif email_check == "N":
        return
    else:
        installEmail()


# Tasks
installEmail()
