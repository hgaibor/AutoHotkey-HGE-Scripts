
# AutoHotkey misc applications command tweaks
Created by: Hugo Gaibor
Date: 2019-Jan-25
License: GNU/GPL3+

Github: https://github.com/hgaibor/AutoHotkey-HGE-Scripts

Check the [usage guide](USAGE-GUIDE.md) for detailed script usage documentation.

Check https://www.autohotkey.com/ for AutoHotKey documentation.

## Description
This script will allow you to improve your daily tasks by assigning custom key mappings to common tasks like: 
- Launch programs or web pages, assign as many programs or sites as keys on your keyboard, by mapping them into the .ini file 
- Quick jump existing windows of programs or and many more! Check the example list on the 
- Create or open folders, currently up to 10 slots for custom assignable directories (this can be extended by modifying the AHK code) 
- Add routes to VPN connections 
- Toggle always on top for program windows
- Send clipboard entry as independent key strokes (useful for VM connections where copy/paste is not an option)
- Custom mouse buttons 
- Custom key shortcuts for KiTTY 
- Check `HgeScript.ini.example.txt` for usage information and function descriptions
- Check `HgeScripts.ahk_hotkeys.example.txt` for some possible shortcuts that can be created using this tool

## History:
 
 ### 2022-05-12
 - NEW: Created new implementation of ProcessFolderSlot() function: ProcessFolderSlot_X(). It will allow unlimited folder slots and the ability to call folder slots by short, quick to remember, user-defined labels. Folders for this function will be defined at the `[CreateOpenFolder_X] section`
 - Refactored `HgeScript.ini.example.txt` to include just plain configuration, and created **USAGE-GUIDE.md** file to detail the information on how to set up each section for the script
 - Code cleaning and minor corrections
 
 ### 2022-04-27
 - NEW: Created additional shortcuts for Kitty and new Putty-based accept prompt for SSH sessions
 - New: Refactored code to separate hotkeys into an `.ahk_hotkeys` file, so it is easier to separate shorcuts from essential code, check the `HgeScripts.ahk_hotkeys.example.txt` for more details
 - NEW: Created logic to reuse browser profiles, allowing easier URL description on `.ini` files
 - NEW: `OpenWebSiteWithInput` function, allowing to open URLs with some variable input
 - NEW: Defined N-based logic to allow more user inputs on above function as well as N-based arguments for browsers

 ### 2021-09-29
 - Imported Gist from https://gist.github.com/hgaibor/ced4f817e229f441ae95b75314b9a5be to a repo for ease of tracking and adding more features(?)

 ### 2021-02-10
 - Added more features and multiple parameter-based calls to functions

 ### 2021-02-05
 - Added .ini file processing for ease of management and sharing 

 ### 2021-02-01
 - Refactored code for reuse optimization


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
