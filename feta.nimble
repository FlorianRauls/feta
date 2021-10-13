# Package
version     = "0.0.9"
author      = "Florian Rauls"
description = "A domain-specific language for general purpose office automation. The language is embedded in Nim and allows for quick and easy integration of different office software environments."
license     = "MIT"
installDirs = @["feta"]

# Deps

requires "nim >= 1.2.0"
requires "mime >= 0.0.3"
requires "jester >= 0.5.0"
requires "googleapi"
requires "ws"

task test, "Runs the test suite":
  exec "nim c -r -d:ssl tests/tests.nim"
