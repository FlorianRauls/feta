proc installEmail() =
    var userDataLocation = "files/userData.nim" # location of userData.nim
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

installEmail()