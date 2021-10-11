# Package
version     = "0.0.6"
author      = "Florian Rauls"
description = "A domain-specific for general purpose office automation. The language is embedded in Nim and allows for quick and easy integration of different office software environments."
license     = "MIT"
installDirs = @["feta"]

# Deps

requires "nim >= 1.2.0"
requires "mime >= 0.0.3"
requires "jester >= 0.5.0"

# Tasks
var ver = "0.0.6"
echo("\e[1;33m If you wish to setup e-mail functionality run \"nim ~/.nimble/pkgs/feta-" & ver & "/setup.nims\" in.")
