
# Auto Hotkey misc applications command tweaks 
Created by: Hugo Gaibor
Date: 2019-Jan-25
License: GNU/GPL3+
Github: https://gist.github.com/hgaibor/ced4f817e229f441ae95b75314b9a5be

## Description 
This script will allow you to improve your daily tasks by assigning custom key mappings to common tasks like: 
- Launch programs or web pages, assign as many programs or sites as keys on your keyboard, by mapping them into the .ini file 
- Quick jump existing windows of programs or and many more! Check the example list on the 
- Create or open folders, currently up to 10 slots for custom assignable directories (this can be extended by modifying the AHK code) 
- Add routes to VPN connections 
- Toggle always on top for program windows
- Send clipboard entry as independent key strokes (useful for VM connections where copy/paste is not an option)
- Custom mouse buttons 
- Custom key shortcut for KiTTY 

## History:
 
 - 2021-02-10   Added more features and multiple parameter-based calls to functions
 - 2021-02-05   Added .ini file processing for ease of management and sharing 
 - 2021-02-01   Refactored code for reuse optimization

## Issues fixes
This is just a number, I don't have the exact number of issues experienced during the creation of this script LOL, so keeping it as simple as possible here.. 

### \#023 False positive virus alert when RunWithNoElevation() was used
Some antivirus threw an error when svchost.exe attempted to start the process that RunWithNoElevation function requested, reported alert mentioned below alerts: 
- Trojan.Multi.GenAutorunTask.b
- PDM:Trojan.Win32.GenAutorunSchedulerTaskRun.b

Since *RunScriptAsAdmin* parameter was created, now non-admin script will not use RunWithNoElevation() function.


### \#022 Glitch with SetTitleMatchMode on ShowOrRunWebSite() ShowOrRunProgram()
SetTitleMatchMode was not set correctly, causing pages or programs with titles not beginning with the search text to be omitted. 

### \#021 Minor glitch with CreateOpenFolder()
Folders were not being opened if folder slot had if *Open_Create* as an option and folder existed previously. Added **RunScriptAsAdmin** .ini parameter to allow the script to run as non-admin user in case routing functions are not needed.

### \#020 CreateOpenFolder() function fails to find network mapped drives
Issue occurs because user that creates the folder is not admin user (Try entering that same path via CMD as admin and you'll see sae error) 
Adding  toggle to run script as admin so if you do not need VPN functions, you're able to open network mapped locations
