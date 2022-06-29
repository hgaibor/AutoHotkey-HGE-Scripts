; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
; *	Misc applications command tweaks 
; *	Created by: Hugo Gaibor
; *	Date: 2019-Jan-25
; * License: GNU/GPL3+
; *
; * Latest version: https://github.com/hgaibor/AutoHotkey-HGE-Scripts
; * History:
; *		
; *		2021-09-29   Imported Gist to a repository for better tracking and updating, 
; *								 this history won't be updated anymore..
;	*		2021-02-10	 Added more functionalities and multiple parameter-based calls 
;	*		2021-02-05	 Added .ini file processing for ease of management and sharing 
; *		2021-02-01	 Refactored code for reuse optimization
; *
; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****

#NoEnv
#Persistent

; Menu definition
; Menu, Tray, Standard
; Menu, Tray, Add, Item1
Menu, Tray, Add, 
Menu, Tray, Add, Show hotkeys, +#F1
Menu, Tray, Add, Open ini File, open_ini_file
; Menu, Tray, Add, Get custom ENV vars, get_current_env_vars
; Menu, Tray, Add, Set custom ENV vars, set_env_vars

; Menu, Tray, Add, This menu item is a submenu, :MySubmenu

; Attempt to load INI file, if not successful, exit app
Global IniSettingsFileName
IniSettingsFileName :=SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", False, -1) -1)".ini"

Global IniSettingsFilePath
IniSettingsFilePath :=SubStr(A_ScriptFullPath, 1, InStr(A_ScriptFullPath, ".", False, -1) -1)".ini"

Global HotkeysFilePath
; HotkeysFilePath :=SubStr(A_ScriptFullPath, 1, InStr(A_ScriptFullPath, ".", False, -1) -1)"_hotkeys"
HotkeysFilePath := A_ScriptFullPath . "_hotkeys"

if !FileExist(IniSettingsFilePath)
{
	MsgBox,16,ERROR: Script .ini settings not found,
		(LTrim Join
			Please make sure there is an file named %IniSettingsFileName% in the same folder as this .ahk file.`n
			If file is not present get the example .ini file at:`n https://github.com/hgaibor/AutoHotkey-HGE-Scripts
			`nPress CONTROL+C to copy this dialog text with the URL.
			`nScript will exit now
		)
	ExitApp
}

if !FileExist(HotkeysFilePath)
{
	MsgBox,16,ERROR: Script .ahk_hotkeys file not found,
		(LTrim Join
			Please make sure there is an file named %A_ScriptName%_hotkeys in the same folder as this .ahk file.`n
			If file is not present get the example .ini file at:`n https://github.com/hgaibor/AutoHotkey-HGE-Scripts
			`nPress CONTROL+C to copy this dialog text with the URL.
			`nScript will exit now
		)
	ExitApp
}

Global RunScriptAsAdmin
IniRead, RunScriptAsAdmin, %IniSettingsFilePath%, GeneralSettings, RunScriptAsAdmin
if (RunScriptAsAdmin = "ERROR") 
{
	RunScriptAsAdmin:="no"
}

; Get full path for script
full_command_line := DllCall("GetCommandLine", "str")

if (RunScriptAsAdmin = "yes") 
{	
	; Validate the script has admin rights, as it is necessary for the route_add commands to work 
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
			try
			{
					if A_IsCompiled
							Run *RunAs "%A_ScriptFullPath%" /restart
					else
							Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
			ExitApp
	}
}


; GeneralSettings Section	
	Global WinEnvName
	IniRead, WinEnvName, %IniSettingsFilePath%, GeneralSettings, WinEnvName
	; MsgBox, %WinEnvName% ; [HGE] (DEBUG) Uncomment_for_tests
	If (WinEnvName == "ERROR")
	{
		WinEnvName := ""
	}

	Global MaxBrowserArguments
	IniRead, MaxBrowserArguments, %IniSettingsFilePath%, GeneralSettings, BrowsersProfiles-MaxBrowserArguments
	; MsgBox, %MaxBrowserArguments% ; [HGE] (DEBUG) Uncomment_for_tests
	If (MaxBrowserArguments == "ERROR")
	{
		MaxBrowserArguments := 10
	}

	Global MaxOpenWebSiteInputs
	IniRead, MaxOpenWebSiteInputs, %IniSettingsFilePath%, GeneralSettings, ShowOpenWebSiteWithInput-MaxOpenWebSiteInputs
	If (MaxOpenWebSiteInputs == "ERROR")
	{
		MaxOpenWebSiteInputs := 10
	}

	Global MaxFolderSlots
	

; VPN config variables, used inside functions and stuff:
; VARIABLES FOR AddIPtoRoute()
	Global ClientIP
	IniRead, ClientIP, %IniSettingsFilePath%, VPNSettings, ClientIP
	; MsgBox, %ClientIP% ; [HGE] (DEBUG) Uncomment_for_tests

	Global FQDN
	IniRead, FQDN, %IniSettingsFilePath%, VPNSettings, FQDN
	; MsgBox, %FQDN% ; [HGE] (DEBUG) Uncomment_for_tests

	Global Mask
	IniRead, Mask, %IniSettingsFilePath%, VPNSettings, Mask
	; MsgBox, %Mask% ; [HGE] (DEBUG) Uncomment_for_tests

	Global Gateway
	IniRead, Gateway, %IniSettingsFilePath%, VPNSettings, Gateway
	; MsgBox, %Gateway% ; [HGE] (DEBUG) Uncomment_for_tests

; General init message
	MsgBox,64,Running %A_ScriptName% script,
		(LTrim Join
			Run as admin: %A_IsAdmin%`n
			Environment: %WinEnvName%`n
			Script Source: `n%full_command_line%
		)

; Including Hotkeys shortcut on remote file for ease of code and git maintaining
#Include %A_ScriptDir%
#Include %A_ScriptName%_hotkeys 
; #Include %HotkeysFileName% 


open_ini_file:
	run %IniSettingsFilePath%
return 


ToggleAlwaysOnTop(){
	MouseGetPos,,,AppWin,VarControl
	WinGet,AppWinstatus,ExStyle,ahk_id %AppWin%
	Transform,WinResult,BitAnd,%AppWinStatus%,0x8
	WinSet,AlwaysOnTop,Toggle,ahk_id %AppWin%
	If WinResult = 0
	{
		WinActivate,ahk_id %AppWin%
		ToolTip, Always on top enabled
		SetTimer, RemoveToolTip, -500
	}
	Else
	{
		ToolTip, Always on top disabled
		SetTimer, RemoveToolTip, -500
	}

	return
	RemoveToolTip:
	ToolTip
	return
}


WrittenPaste(){
	; Send clipboard contents as keystrokes, useful when you can't paste into browsers or remote consoles 
	SendInput, {Raw}%Clipboard%
}


ShowOrRunProgram(ProgramNameId){
	; Unified all functions for individual programs into sigle re-usable function, taking the parameters from SCRIPT.INI file	
	; ShowOrRunProgram(command,arguments, path){
	IniRead, AhkExeName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-AhkExeName
	IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-AhkGroupName
	IniRead, ProgramName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-ProgramName
	IniRead, CommandExe, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandExe
	IniRead, CommandPath, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandPath
	IniRead, CommandArgs, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandArgs

	If ((AhkExeName == "ERROR") || (AhkGroupName == "ERROR") || (ProgramName == "ERROR") || (CommandExe == "ERROR") || (CommandPath == "ERROR") || (CommandArgs == "ERROR"))
	{
		MsgBox, ERROR... Missing parameters for ShowOrRunProgram function check the "%IniSettingsFileName%" file
		return 
	}
	; [PENDING]: to implement
	; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-RunAsAdmin

	; MsgBox, AhkExeName--> %AhkExeName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, AhkGroupName--> %AhkGroupName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, ProgramName--> %ProgramName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandExe--> %CommandExe% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandPath--> %CommandPath% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandArgs--> %CommandArgs% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, RunAsAdmin--> %RunAsAdmin% ; [HGE] (DEBUG) Uncomment_for_tests

	SetTitleMatchMode, 2
	if WinExist(AhkExeName)
	{   
		; Multi-window approach
		GroupAdd, %AhkGroupName%, %AhkExeName%
		GroupActivate %AhkGroupName%
	}
	else
	{
		MsgBox, 36, %WinEnvName%Launch %ProgramName%?, No window with that title found, open new instance? 
		IfMsgBox Yes
		{
			; Work-around not to run tasks as administrator since the Script itself needs to be run like that for other tasks 
			; WARNING: RunWithNoElevation() may trigger alerts on some Antivirus software flagging it as:
			; 	- Trojan.Multi.GenAutorunTask.b
			; 	- PDM:Trojan.Win32.GenAutorunSchedulerTaskRun.b
			; This is due to the function using svchost.exe to "program" the task to start the desired application or process.
			if (RunScriptAsAdmin = "yes") 
			{	
				RunWithNoElevation(CommandExe,CommandArgs, CommandPath)
			}
			else
			{
				Run %CommandExe% %CommandArgs%
			}
		}
	}
}


ShowOrRunWebSite(WebSiteNameId){
	; Unified all functions for individual programs into sigle re-usable function, taking the parameters from SCRIPT.INI file	
	; ShowOrRunWebSite(command,arguments, path){
		IniRead, BrowserExe, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-BrowserExe
		IniRead, BrowserPath, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-BrowserPath
		IniRead, AhkSearchWindowTitle, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-AhkSearchWindowTitle
		IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-AhkGroupName
		IniRead, SiteName, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-SiteName
		IniRead, Arguments1, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments1
		IniRead, Arguments2, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments2
		IniRead, Arguments3, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments3
		IniRead, Arguments4, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments4


		; MsgBox, BrowserExe --> %BrowserExe% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, BrowserPath --> %BrowserPath% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, AhkSearchWindowTitle --> %AhkSearchWindowTitle% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, AhkGroupName --> %AhkGroupName% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, SiteName --> %SiteName% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments1 --> %Arguments1% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments2 --> %Arguments2% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments3 --> %Arguments3% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments4 --> %Arguments4% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments5 --> %Arguments5% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Arguments6 --> %Arguments6% ; [HGE] (DEBUG) Uncomment_for_tests

		if ((BrowserExe == "ERROR") || (BrowserPath == "ERROR") || (AhkSearchWindowTitle == "ERROR") || (AhkGroupName == "ERROR") || (SiteName == "ERROR") || (Arguments1 == "ERROR") || (Arguments2 == "ERROR") || (Arguments3 == "ERROR") || (Arguments4 == "ERROR") || (Arguments5 == "ERROR") || (Arguments6 == "ERROR"))
		{
			MsgBox, ERROR... Missing parameters for ShowOrRunWebSite function check the "%IniSettingsFileName%" file
			return 
		}
		; [PENDING]: implement Run as admin
		; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunWebSite, %ProgramNameId%-RunAsAdmin

		SetTitleMatchMode, 2
		if WinExist(AhkSearchWindowTitle)
		{   
			; Multi-window approach
			GroupAdd, %AhkGroupName%, %AhkSearchWindowTitle%
			GroupActivate %AhkGroupName%
		}
		else
		{
			MsgBox, 36, %WinEnvName%Open %SiteName%?, No window with that title found, open new instance? 
			IfMsgBox Yes
			{

				BrowserArgs := Arguments1 . Arguments2 . Arguments3 . Arguments4 . Arguments5 . Arguments6
				
				; Work-around not to run tasks as administrator since the Script itself needs to be run like that for other tasks 
				; WARNING: RunWithNoElevation() may trigger alerts on some Antivirus software flagging it as:
				; 	- Trojan.Multi.GenAutorunTask.b
				; 	- PDM:Trojan.Win32.GenAutorunSchedulerTaskRun.b
				; This is due to the function using svchost.exe to "program" the task to start the desired application or process.
				if (RunScriptAsAdmin = "yes") 
				{	
					RunWithNoElevation(BrowserExe,BrowserArgs, BrowserPath)
				}
				else
				{
						Run %BrowserExe% %BrowserArgs%
				}
			}
		}
}

ShowOpenWebSiteWithInput(WebSiteWithInputNameId){
	IniRead, AhkSearchWindowTitle, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-AhkSearchWindowTitle
	IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-AhkGroupName
	IniRead, SiteName, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-SiteName
	IniRead, BaseUrl, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-BaseUrl
	IniRead, OpenWebSiteOperation, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-OpenWebSiteOperation
	
	; Main URL to insert input parameters
	IniRead, BaseUrl, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-BaseUrl

	ErrorCounter := 0
	ErrorString := ""

	; [BEGIN] Error variables validation and message implementation
		; [BEGIN] Error validation for both types of OpenWebSiteOperation
			if (SiteName == "ERROR")
			{
				ErrorCounter += 1
				ErrorString .= "- SiteName not defined on ini file `n"
			}

			if (BaseUrl == "ERROR")
			{
				ErrorCounter += 1
				ErrorString .= "- BaseUrl not defined on ini file `n"
			}

			if (AhkSearchWindowTitle == "ERROR")
			{
				AhkSearchWindowTitle := "DO_NOT_SEARCH"
			}

			if (AhkGroupName == "ERROR")
			{
				AhkSearchWindowTitle := "DO_NOT_SEARCH"
				AhkGroupName := "DO_NOT_GROUP"
			}
			
			if (OpenWebSiteOperation == "ERROR")
			{
				ErrorCounter += 1
				ErrorString .= "- OpenWebSiteOperation not defined on ini file `n"
			}
		; [END] Error validation for both types of OpenWebSiteOperation

		if (OpenWebSiteOperation = "Open_Website")
		{
			; [BEGIN] Set browser profile in [ShowOpenWebSiteWithInput] this will indicate fields to load from [BrowsersProfiles]
				IniRead, BrowserProfile, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-BrowserProfile
				if (BrowserProfile == "ERROR")
				{
					; Attempt to load default profile defined at [GeneralSettings] before finally declaring error
					IniRead, BrowserProfile, %IniSettingsFilePath%, GeneralSettings, BrowsersProfile-DefaultProfile
					if (BrowserProfile == "ERROR")
					{
						ErrorCounter += 1
						ErrorString .= "- Default BrowserProfile not defined on [GeneralSettings] section or at [BrowsersProfiles] section `n"
						ErrorString .= "- Or declared BrowserProfile %BrowserProfile% on current WebSiteWithInputNameId does not match a valid BrowserProfile at [BrowsersProfiles] section `n"
					}
				}


				IniRead, OpenTarget, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-OpenTarget
			; [END] Set browser profile in [ShowOpenWebSiteWithInput] this will indicate fields to load from [BrowsersProfiles]

			; [BEGIN] Load web browser profile from [BrowsersProfiles], this is determined by particular profile under [ShowOpenWebSiteWithInput]
				IniRead, BrowserExe, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserExe
				IniRead, BrowserPath, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserPath
				IniRead, BrowserUserProfile, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserUserProfile
				IniRead, NewWindowArg, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserNewWindowArg
				IniRead, NewTabArg, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserNewTabArg
			; [END] Load web browser profile from [BrowsersProfiles], this is determined by particular profile under [ShowOpenWebSiteWithInput]

			; [BEGIN] Error validation for "Open_Website" OpenWebSiteOperation
				if (NewWindowArg == "ERROR")
				{
					NewWindowArg := ""
				}

				if (NewTabArg == "ERROR")
				{
					NewTabArg := ""
				}

				if (OpenTarget == "ERROR")
				{
					OpenTarget := "New_Tab"
					; ErrorCounter += 1
					; ErrorString .= "- OpenTarget not defined on [ShowOpenWebSiteWithInput] section or on current WebSiteWithInputNameId at ini file `n"
				}

				if (BrowserExe == "ERROR")
				{
					ErrorCounter += 1
					ErrorString .= "- BrowserExe from BrowserProfile *" . BrowserProfile . "* not defined on [BrowsersProfiles] section at ini file `n"
				}

				if (BrowserUserProfile == "ERROR")
				{
					BrowserUserProfile := ""
				}

				if (BrowserPath == "ERROR")
				{
					ErrorCounter += 1
					ErrorString .= "- BrowserPath from BrowserProfile *" . BrowserProfile . "* not defined on [BrowsersProfiles] section at ini file `n"
				}

				if (NewWindowArg == "ERROR")
				{
					ErrorCounter += 1
					ErrorString .= "- Browser *" . BrowserProfile . "* NewWindowArg not defined on [BrowsersProfiles] section at ini file `n"
				}

				if (NewTabArg == "ERROR")
				{
					ErrorCounter += 1
					ErrorString .= "- Browser *" . BrowserProfile . "* NewTabArg not defined on [BrowsersProfiles] section at ini file `n"
				}

				if (Arguments1 == "ERROR")
				{
					ErrorCounter += 1
					ErrorString .= "- Browser *" . BrowserProfile . "* Arguments1 not defined, define at least 1 Argument on [BrowsersProfiles] section at ini file `n"
				}
			; [END] Error validation for "Open_Website" OpenWebSiteOperation

		}

		If ( ErrorCounter > 0 )
		{
			MsgBox, 48, %WinEnvName%Please check ini file, Function aborted, .ini file contains the following errors: `n%ErrorString%
			return
		}
	; [END] Error variables validation and message implementation

	if (OpenWebSiteOperation = "Open_Website")
	{
		BrowserRawArgs := % BrowserRawArgs . BrowserUserProfile

			Loop %MaxBrowserArguments%
			{
				IniRead, Arguments%a_index%, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserArguments%a_index%
				if ((Arguments%a_index% == "ERROR") || (Arguments%a_index% == "")) 
					break
				
				BrowserRawArgs := % BrowserRawArgs . Arguments%a_index%
			}
			; MsgBox % BrowserRawArgs ; [HGE] (DEBUG) Uncomment_for_tests
			; return  ; [HGE] (DEBUG) Uncomment_for_tests

		; Set page to open in new tab or new window
			if (OpenTarget == "New_Window")
			{
				BrowserRawArgs := % BrowserRawArgs . NewWindowArg
			}
			else if (OpenTarget == "New_Tab")
			{
				BrowserRawArgs := % BrowserRawArgs . NewTabArg
			}

	}

		; Pending to implement
		; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunWebSite, %ProgramNameId%-RunAsAdmin

		; Adding optional DO NOT GROUP OR SEARCH existing windows
		SetTitleMatchMode, 2
		if ((WinExist(AhkSearchWindowTitle)) && (AhkSearchWindowTitle != "DO_NOT_SEARCH") )
		{   
			; Multi-window approach
			GroupAdd, %AhkGroupName%, %AhkSearchWindowTitle%
			GroupActivate %AhkGroupName%

			; Focus existing window, then asking for input data to generate URL
			if (OpenWebSiteOperation = "Copy_URL")
			{
				Gosub, AskWebSiteWithInput
			}
		}
		else
		{	
			if (AhkSearchWindowTitle = "DO_NOT_SEARCH")
			{
				Gosub, AskWebSiteWithInput
			}
			else
			{
				MsgBoxMessage := "No window with that title found, open new instance?"
				MsgBox, 36, %WinEnvName%Open %SiteName%?, %MsgBoxMessage% 
				IfMsgBox Yes
				{
					Gosub, AskWebSiteWithInput
				}
			}
		}
		; return before running this label below: AskWebSiteWithInput
		return

		AskWebSiteWithInput:
			BrowserURL := BaseUrl
			Loop %MaxOpenWebSiteInputs%
			{
				; This function will take arguments from ini file, sequentially starting from 1, 
				;  until it finds no continuous N argument or until %MaxOpenWebSiteInputs%
				IniRead, NameInput%a_index%, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-NameInput%a_index%
				IniRead, RegExDeleteFromInput%a_index%, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-RegExDeleteFromInput%a_index%
				IniRead, RegExInsertInput%a_index%, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-RegExInsertInput%a_index%
				
				if (NameInput%a_index% == "ERROR") 
					break
				
				NameInput := % NameInput%a_index%
				InputBox, UrlInput%a_index%, %WinEnvName%,Enter %NameInput% for %SiteName% URL
				if ErrorLevel
						Return
				
				CleanUrlInput%a_index% := % RegExReplace(UrlInput%a_index%, RegExDeleteFromInput%a_index%)
				BrowserURL := RegExReplace(BrowserURL, RegExInsertInput%a_index%, CleanUrlInput%a_index%)
			}


			if (OpenWebSiteOperation = "Copy_URL")
			{
				clipboard = %BrowserURL%
				MsgBox,64,%WinEnvName%, formatted URL copied to clipboard
			}

			if (OpenWebSiteOperation = "Open_Website")
			{
				; By default this will replace the placeholder {BASE_URL_REPLACE_HERE} at the ini file, make sure you put the same placeholder or modify the code if you prefer
				BrowserArgs := RegExReplace(BrowserRawArgs, "i)\{BASE_URL_REPLACE_HERE\}", BrowserURL)

				; Work-around not to run tasks as administrator since the Script itself needs to be run like that for other tasks 
				; WARNING: RunWithNoElevation() may trigger alerts on some Antivirus software flagging it as:
				; 	- Trojan.Multi.GenAutorunTask.b
				; 	- PDM:Trojan.Win32.GenAutorunSchedulerTaskRun.b
				; This is due to the function using svchost.exe to "program" the task to start the desired application or process.
				if (RunScriptAsAdmin = "yes") 
				{	
					RunWithNoElevation(BrowserExe,BrowserArgs, BrowserPath)
				}
				else
				{
						Run %BrowserExe% %BrowserArgs%
				}

			}
		; Label safe exit point: AskWebSiteWithInput
		return
}

AddIPtoRoute() {
	IniRead, VpnName, %IniSettingsFilePath%, VPNSettings, VpnName
	InputBox, ClientServer, %WinEnvName%Enter the client's IP or FQDN, This will add the IP to the IP route for the %VpnName% 
	if ErrorLevel
			; MsgBox, CANCEL was pressed. ; [HGE] (DEBUG) Uncomment_for_tests 
			Return
	else
		{
			; MsgBox, You entered "%UserInput%"
			if (ValidateIP(Trim(ClientServer)))
			{
				; If it's an IP address, add it directly
				ClientIP := ClientServer
				RunAddCommand(ClientIP, Mask, Gateway)
			}	
			else
			{
				; If not an IP, attempt to determine FQDN and add it 
				; UNCOMMENT AFTER TESTS 
				ClientIP := FQDN_to_IP(Trim(ClientServer)) ; [HGE] Comment_for_tests 
				; MsgBox, Attempting to get FQDN ; [HGE] (DEBUG) Uncomment_for_tests 
				PingResult := FQDN_to_IP(ClientServer)
				if (PingResult == "NO_ERROR")
				{
					; MsgBox, %ClientIP% ; [HGE] (DEBUG) Uncomment_for_tests 
					RunAddCommand(ClientIP, Mask, Gateway)
					clipboard = %ClientIP%
				}
				else 
				MsgBox, 0, %WinEnvName%Invalid IP or FQDN, %PingResult%
					
			}
		}
}


RunAddCommand(IP, Mask, Gateway) {
	; route ADD [customer_IP] MASK 255.255.255.255 10.224.50.1
	RunWait, *runas %ComSpec% /c "route add %IP% MASK %Mask% %Gateway% > route_add.result" , , hide UseErrorLevel
	fileread , IPAddResult, route_add.result
	FileDelete, route_add.result 
	; MsgBox, %WinEnvName%%IPAddResult%
	If (IPAddResult = "")
		MsgBox, %WinEnvName%IP could not be added, probably it's already in Route Table
	Else
		MsgBox, %WinEnvName%IP address added %IPAddResult% 
}


ValidateIP(ByRef IPAddress) {
	if (StrLen(IPAddress) > 15)
		Valid=0

	IfInString, IPAddress, %A_Space%
		Valid=0

	StringSplit, Octets, IPAddress, .
	if (Octets0 <> 4)
		Valid=0
	else if (Octets1 < 1 || Octets1 > 255)
		Valid=0
	else if (Octets2 < 0 || Octets2 > 255)
		Valid=0
	else if (Octets3 < 0 || Octets3 > 255)
		Valid=0
	else if (Octets4 < 0 || Octets4 > 255)
		Valid=0
	else Valid=1

	Oct1:=Octets1*0
	Oct2:=Octets2*0
	Oct3:=Octets3*0
	Oct4:=Octets4*0

	if (Oct1 <> 0 || Oct2 <> 0 || Oct3 <> 0 || Oct4 <> 0)
		Valid=0

	return %Valid%
}


FQDN_to_IP(ByRef FQDN) { 
	; Convert FQDN to IP (may work almost always...)
	; FQDN=http://www.google.com
	; FQDN=192.168.122.1
	; FQDN=HeaderGarble http://www.yahoo.co.uk/forum/posting.php?mode=newtopic&f=1EndingGarbleEtc 

	; Reference: https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm
	http_remove = i)^.*https?\:?\/\/
	FQDN := RegExReplace(FQDN, http_remove, "")
	
	url_clean = i)\:.*|\/.*|\?.*
	FQDN := RegExReplace(FQDN, url_clean, "")

	; MsgBox, %FQDN% ; [HGE] (DEBUG) Uncomment_for_tests 
	; Attempting to obtain the IP from FQDN >>>> 
	RunWait, *runas %ComSpec% /c "ping %FQDN% -n 1 -w 300> ping.result" , , hide UseErrorLevel
	fileread , PingResult, ping.result
	FileDelete,ping.result

	PingError := RegExMatch(txt,"Request timed out.")
	if PingError
	{
		; MsgBox, Request timed out.
		PingError = Request timed out.
		return %PingError%
	}
	else
	{
		PingError := RegExMatch(PingResult,"Ping request could not find host")
		if PingError
		{
			; MsgBox, Request could not find host.
			PingError = Request could not find host.
			return %PingError%
		}
		else
		{
			PingError := RegExMatch(PingResult,"Reply from")
			if PingError
			{
				; RegExMatch(PingResult, "Pinging (.*?) ", Url)
				RegExMatch(PingResult, "Ping statistics for (.*?):", Ip)
				; RegExMatch(PingResult, "(Minimum = .*?), (Maximum = .*?), (Average = .*?$)", triptimes)
				PingError = NO_ERROR
				ClientIP := Ip1
				; MsgBox, %ClientIP%
				; MsgBox, % PingResult
				return %PingError%
			}
			else 
			{
				PingError = OTHER_ERROR
				return %PingError%
			}
		}
	}
}

global FolderSlotIH, FolderSlotSearchById := false

FolderSlotIH_Char(ih, char){
    InputFirstChar := SubStr(ih.input, 1,1)

    if InputFirstChar is integer 
    		FolderSlotSearchById := true
  	else
  		FolderSlotSearchById := false

    if (GetKeyVK(char) = 27 )
    {
			ToolTip, % "ABORTED"
			FolderSlotIH.Stop()
    }
    else if (FolderSlotSearchById) {
    	ToolTip, % "FolderSlot ID: " ih.input
    	ih.KeyOpt("{Space}", "E") 
    }	
    else {
    	ToolTip, % "FolderSlot label: " ih.input
    	ih.KeyOpt("{Space}", "-E") 
    }
}

FolderSlotIH_KeyDown(ih, vk, sc){
  if (vk = 8){ ; {Backspace}
    FolderSlotIH_Char(ih, "")
  }

  else if (vk = 32){ ; {Space}
		if (FolderSlotSearchById = true)
		{
			FolderSlotIH.Stop()
		}
	}

	else if (vk = 27){ ; {Esc}
		FolderSlotIH.Stop()
	}

  else if (vk = 9){ ; Tab
  	FolderSlotIH.Stop()
  }

  return
	RemoveFolderSlotIH_KeyDownToolTip:
	ToolTip
	return
}

FolderSlotIH_End(){
	SetTimer, RemoveFolderSlotIH_EndToolTip, -500

	return
	RemoveFolderSlotIH_EndToolTip:
	ToolTip
	return
}

ProcessFolderSlot_X(){
	FolderSlotLabelFound := false
	IniRead, MaxFolderSlots, %IniSettingsFilePath%, GeneralSettings, CreateOpenFolder_X-MaxFolderSlots
	If (MaxFolderSlots == "ERROR")
	{
		MaxFolderSlots := 20
	}

	FolderSlotCounter := 0
	ToolTip, % "Type FolderSlot ID or label: "
	FolderSlotSearchById := false

	FolderSlotIH := InputHook("L30T20", "{Enter}{Tab}")
	FolderSlotIH.OnChar := Func("FolderSlotIH_Char")
	FolderSlotIH.OnKeyDown := Func("FolderSlotIH_KeyDown")
	FolderSlotIH.OnEnd := Func("FolderSlotIH_End")
	FolderSlotIH.KeyOpt("{Backspace}{esc}{space}{tab}", "N")
	FolderSlotIH.Start()

	ErrorLevel := FolderSlotIH.Wait()
	if (ErrorLevel = "EndKey"){
    ErrorLevel .= ":" FolderSlotIH.EndKey	
    ToolTip ; Visual improvement to remove ToolTip before confirmation
		FolderSlot := FolderSlotIH.Input
	}

  if (ErrorLevel = "Stopped"){
		FolderSlot := ""
		return
  }

  FolderSlot := Trim(FolderSlot)
	FolderSlotIndex := 

	if (FolderSlot = "e"){
		FolderSlotsDescription := "=== Currently set folder Slots === `n`n"
		Loop, %MaxFolderSlots%
		{
			FolderSlotIndex := A_Index
			if (A_Index == MaxFolderSlots)
			{
				FolderSlotIndex := 0 
			}
			IniRead, FolderSlotLabel, %IniSettingsFilePath%, CreateOpenFolder_X, FolderLabel_%FolderSlotIndex%
			IniRead, LocationName, %IniSettingsFilePath%, CreateOpenFolder_X, LocationName_%FolderSlotIndex%
			IniRead, FolderSlotOperation, %IniSettingsFilePath%, CreateOpenFolder_X, FolderOperation_%FolderSlotIndex%

			if (LocationName != "ERROR")
			{
				FolderSlotCounter += 1
				FolderSlotsDescription .= " - Slot: [" FolderSlotIndex "] -- Label: [" FolderSlotLabel "]`n    Name: " LocationName " -- Operation: " FolderSlotOperation "`n"
			}
		}

		FolderSlotsDescription .= "`nTotal folders: (" FolderSlotCounter ")"

		if (FolderSlotCounter < 20)
		{
			MsgBox,32,%WinEnvName%List of set up folder slots, %FolderSlotsDescription%
		}
		else
		{
			MsgBox,32,%WinEnvName%,List of set up folder slots is too long full list was copied to clipboard
				clipboard = % FolderSlotsDescription
		}
		
		return

	}

	if (FolderSlotSearchById)
	{
		IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder_X, BaseFolderPath_%FolderSlot%
		IniRead, LocationName, %IniSettingsFilePath%, CreateOpenFolder_X, LocationName_%FolderSlot%
		IniRead, FolderOperation, %IniSettingsFilePath%, CreateOpenFolder_X, FolderOperation_%FolderSlot%

		Gosub, ProcessFolderSlot_X_ValidateData
	}
	else 
	{
		Loop, %MaxFolderSlots%
		{
			FolderSlotIndex := A_Index
			if (A_Index == MaxFolderSlots)
			{
				FolderSlotIndex := 0 
			}
			IniRead, FolderSlotLabel, %IniSettingsFilePath%, CreateOpenFolder_X, FolderLabel_%FolderSlotIndex%

			if (FolderSlotLabel = FolderSlot)
			{
				IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder_X, BaseFolderPath_%FolderSlotIndex%
				IniRead, LocationName, %IniSettingsFilePath%, CreateOpenFolder_X, LocationName_%FolderSlotIndex%
				IniRead, FolderOperation, %IniSettingsFilePath%, CreateOpenFolder_X, FolderOperation_%FolderSlotIndex%

				FolderSlotLabelFound := true

				Gosub, ProcessFolderSlot_X_ValidateData
				break
			}
		}

		if (!FolderSlotLabelFound)
		{
			MsgBox, 48, %WinEnvName%Not found, Folder slot not found, please check spelling or enter 'e' to show list of all folder slots.
		}

	}
	return
	
	ProcessFolderSlot_X_ValidateData:
		If ((BaseFolderPath == "ERROR"))
		{
			MsgBox, ERROR... SLOT %FolderSlot% not found, check the "%IniSettingsFileName%" file under [CreateOpenFolder_X]
			return 
		}

		If (BaseFolderPath == "")
		{
			MsgBox, SLOT %FolderSlot% is empty, set it on the "%IniSettingsFileName%" file
			return
		}

		If (LocationName == "")
		{
			LocationName = %FolderSlot%
		}

		If (FolderOperation == "")
		{
			FolderOperation := "Open_Folder"
		}
		
		CreateOpenFolder(BaseFolderPath, LocationName, FolderOperation)
	; Label safe exit point: ProcessFolderSlot_X_ValidateData
	return
}

ProcessFolderSlot(){
	FolderSlot := 
		Input, FolderSlot, "L1 T2", {Enter}, 1,2,3,4,5,6,7,8,9,0,E,e ;E and e will be used to list the folders currently mapped on ini file
		if (ErrorLevel = "Max")
		{
				MsgBox,,%WinEnvName%Select a valid folder slot,
					(LTrim Join
						Only numbers [1-9]+0 can be entered, set the slots on "%IniSettingsFileName%" file.`n
						Or press 'e' for the list of available slots
					)
				return
		}
		if (ErrorLevel = "Timeout")
		{
				MsgBox,,%WinEnvName%Select a valid folder slot,
					(LTrim Join
						Slots [1-9]+0 can be set up upon the "%IniSettingsFileName%" file.`n
						Or press 'e' for the list of available slots
					)
				return
		}
		if (ErrorLevel = "NewInput")
				return
		If InStr(ErrorLevel, "EndKey:")
		{
				MsgBox,,%WinEnvName%Select a valid folder slot,
					(LTrim Join
						Only numbers [1-9]+0 can be entered, set the slots on "%IniSettingsFileName%" file.`n
						Or press 'e' for the list of available slots
					)
				return
		}

		if (FolderSlot == "E" || FolderSlot == "e"){
			; MsgBox, You pressed %FolderSlot%
			FolderSlotIndex := 
			FolderSlotsDescription := "=== Currently set folder Slots === `n`n"
			Loop, 10
			{
				FolderSlotIndex := A_Index
				if (A_Index == 10)
				{
					FolderSlotIndex := 0 
				}
				IniRead, LocationName, %IniSettingsFilePath%, CreateOpenFolder, LocationName%FolderSlotIndex%
				FolderSlotsDescription .= " - Slot " FolderSlotIndex ": " LocationName "`n"
				; Sleep, 100
			}
			MsgBox,32,%WinEnvName%List of set up folder slots,
				( ;LTrim Join
					%FolderSlotsDescription%
				)
			
			return
		;	for window in ComObjCreate("Shell.Application").Windows
		;	windows .= window.LocationName " :: " window.LocationURL "`n"
		; MsgBox % windows
		}

		IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder, BaseFolderPath%FolderSlot%
		IniRead, LocationName, %IniSettingsFilePath%, CreateOpenFolder, LocationName%FolderSlot%
		IniRead, FolderOperation, %IniSettingsFilePath%, CreateOpenFolder, FolderOperation%FolderSlot%

		
		If ((BaseFolderPath == "ERROR") || (LocationName == "ERROR") || (FolderOperation == "ERROR"))
		{
			MsgBox, ERROR... SLOT %FolderSlot% variable not found, check the "%IniSettingsFileName%" file
		}
		If (BaseFolderPath == "")
		{
			MsgBox, SLOT %FolderSlot% is empty, set it on the "%IniSettingsFileName%" file
			return
		}

		If (LocationName == "")
		{
			LocationName = %FolderSlot%
		}

		If (FolderOperation == "")
		{
			FolderOperation := "Open_Folder"
		}
		
		; MsgBox, SLOT %FolderSlot% --> %BaseFolderPath% -- %LocationName% -- %FolderOperation%
		CreateOpenFolder(BaseFolderPath, LocationName, FolderOperation)
}


CreateOpenFolder(BaseFolderPath, LocationName, FolderOperation){
	; IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder, BaseFolderPath
	StringRight, CheckFolderPath, BaseFolderPath, 1
	; MsgBox, %CheckFolderPath% ; [HGE] (DEBUG) Uncomment_for_tests


	if (FolderOperation =="Open_Create")
	{
		InputBox, FolderName, %WinEnvName%Enter name for %LocationName%, Folder will be created or opened`, if it does not exist it will be created at `n`n %BaseFolderPath%
		if (CheckFolderPath<>"\")
		{
			BaseFolderPath = %BaseFolderPath%\
			; MsgBox, %BaseFolderPath% ; [HGE] (DEBUG) Uncomment_for_tests
		}
	}
	else if (FolderOperation =="Open_Folder")
	{
		; MsgBox, OPEN FOLDER ONLY ; [HGE] (DEBUG) Uncomment_for_tests

		if (CheckFolderPath=="\")
			{
				; Extract the base folder path to open folder (last backslash not needed here)
				StringTrimRight, BaseFolderPath, BaseFolderPath, 1
				; MsgBox, %BaseFolderPath% ; [HGE] (DEBUG) Uncomment_for_tests

			}
			; Break path into array by backslash character 
			PathArray := StrSplit(BaseFolderPath, "\")
			FolderName := PathArray[(PathArray.MaxIndex())]
			; MsgBox, %FolderName% ; [HGE] (DEBUG) Uncomment_for_tests

		; MsgBox, %FolderName% ; [HGE] (DEBUG) Uncomment_for_tests
		ErrorLevel := false 
	}

	if ErrorLevel
	{		
		; MsgBox, "ErrorLevel due to cancel" ; [HGE] (DEBUG) Uncomment_for_tests
		Return
	}

	else
		{
		if ((Trim(FolderName) == "") && (FolderOperation <> "Open_Folder") )
		{
			; MsgBox, FOLDER NOT EMPTY ; [HGE] (DEBUG) Uncomment_for_tests
			Return 
		}

		else if (FolderOperation == "Open_Folder")
		{
			; MsgBox, OPEN FOLDER ONLY ; [HGE] (DEBUG) Uncomment_for_tests
			FolderFullPath := BaseFolderPath
		}

		else if (FolderOperation == "Open_Create")
		{
			; MsgBox, OPEN CREATE FOLDER ; [HGE] (DEBUG) Uncomment_for_tests
			FolderFullPath := BaseFolderPath (Trim(FolderName))
		}

		else 
		{
			; MsgBox, ELSE_MET ; [HGE] (DEBUG) Uncomment_for_tests
		}
		; MsgBox, %FolderFullPath% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, %FolderName% ; [HGE] (DEBUG) Uncomment_for_tests
		
		if InStr(FileExist(FolderFullPath), "D")
		{
			; MsgBox, Directory exists
			; WinShow, FolderName
			; GroupAdd, GroupName, WinTitle [, WinText, Label, ExcludeTitle, ExcludeText]
			; GroupAdd, TicketExplorer, FolderName

			
			; Copy text to Clipboard
			clipboard = %FolderFullPath%
			If WinExist(FolderName)
			{
				; MsgBox, Window exists
				WinActivate, %FolderName%
			}
			else
			{
				if (FolderOperation == "Open_Folder")
				{
					MsgBox, 36, %WinEnvName%Open Folder, Open %FolderFullPath%?`nNo window with that title found, open? 
					IfMsgBox Yes
					{
						; Work-around not to run tasks as administrator since the Script itself needs to be run like that for other tasks 
						; WARNING: RunWithNoElevation() may trigger alerts on some Antivirus software flagging it as:
						; 	- Trojan.Multi.GenAutorunTask.b
						; 	- PDM:Trojan.Win32.GenAutorunSchedulerTaskRun.b
						; This is due to the function using svchost.exe to "program" the task to start the desired application or process.
						; RunWithNoElevation("explorer.exe",FolderFullPath, A_WinDir)
						; Run, explorer.exe "%FolderFullPath%"
						Run, explorer.exe "%FolderFullPath%"
					}
				}
				else if (FolderOperation == "Open_Create")
				{
					; Since already asked for the folder name makes sense to open automatically 
					Run, explorer.exe "%FolderFullPath%"
				}
			}

		}
		else if (FolderOperation == "Open_Create")
		{
			; Message box options:
			; Yes/No	--> 4 
			; Icon Question	--> 32
			MsgBox, 36, %WinEnvName%Create new directory?, Directory %FolderName% does not exists at `n%BaseFolderPath% `nCreate new? 
			IfMsgBox Yes
			{
				FileCreateDir, %FolderFullPath%
				Run, explorer.exe "%FolderFullPath%"
				; Copy text to Clipboard
				clipboard = %FolderFullPath%
			}
			; else
					; MsgBox Nope
		}
		}
}







RunWithNoElevation(Target, Arguments, WorkingDirectory){
	; Taken from: https://autohotkey.com/board/topic/79136-run-as-normal-user-not-as-admin-when-user-is-admin/
	static TASK_TRIGGER_REGISTRATION := 7   ; trigger on registration. 
	static TASK_ACTION_EXEC := 0  ; specifies an executable action. 
	static TASK_CREATE := 2
	static TASK_RUNLEVEL_LUA := 0
	static TASK_LOGON_INTERACTIVE_TOKEN := 3
	objService := ComObjCreate("Schedule.Service") 
	objService.Connect() 

	objFolder := objService.GetFolder("") 
	objTaskDefinition := objService.NewTask(0) 

	principal := objTaskDefinition.Principal 
	principal.LogonType := TASK_LOGON_INTERACTIVE_TOKEN    ; Set the logon type to TASK_LOGON_PASSWORD 
	principal.RunLevel := TASK_RUNLEVEL_LUA  ; Tasks will be run with the least privileges. 

	colTasks := objTaskDefinition.Triggers
	objTrigger := colTasks.Create(TASK_TRIGGER_REGISTRATION) 
	endTime += 1, Minutes  ;end time = 1 minutes from now 
	FormatTime,endTime,%endTime%,yyyy-MM-ddTHH`:mm`:ss
	objTrigger.EndBoundary := endTime
	colActions := objTaskDefinition.Actions 
	objAction := colActions.Create(TASK_ACTION_EXEC) 
	objAction.ID := "7plus run" 
	objAction.Path := Target
	objAction.Arguments := Arguments
	objAction.WorkingDirectory := WorkingDirectory ? WorkingDirectory : A_WorkingDir
	objInfo := objTaskDefinition.RegistrationInfo
	objInfo.Author := "7plus" 
	objInfo.Description := "Runs a program as non-elevated user" 
	objSettings := objTaskDefinition.Settings 
	objSettings.Enabled := True 
	objSettings.Hidden := False 
	objSettings.DeleteExpiredTaskAfter := "PT0S"
	objSettings.StartWhenAvailable := True 
	objSettings.ExecutionTimeLimit := "PT0S"
	objSettings.DisallowStartIfOnBatteries := False
	objSettings.StopIfGoingOnBatteries := False
	objFolder.RegisterTaskDefinition("", objTaskDefinition, TASK_CREATE , "", "", TASK_LOGON_INTERACTIVE_TOKEN ) 
}