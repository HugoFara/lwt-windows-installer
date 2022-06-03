# LWT Installer
* **WARNING:** This software is not finished yet! You can download it and play around, but we provide no guarranty about his stability or final effect!

This is the installer for LWT Standalone version on Windows. It is aimed to create a running LWT server on your computer only. For more complex use cases (e. g.: web server) please follow the official documentation.

## Install
Just download the latest release that ships a .exe file (LWT Installer.exe). Launch it and follow the guide!

## Contribute
This installer uses [nullsoft scriptble software (NSIS)](https://nsis.sourceforge.io/). If you want to help fork this repository and do your magic!

You can easily test the installer using C:\"Program Files (x86)"\NSIS\makensis.exe .\"LWT Installer.nsi"; .\'LWT Installer.exe'

## Features
* Automatically download the latest ZIP version of LWT, community fork

## External dependencies
* INetC for downloading files from the network.
* nsJSON to parse JSON files.
