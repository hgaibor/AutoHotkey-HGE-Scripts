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
; *		2021-02-10	 Added more functionalities and multiple parameter-based calls 
; *		2021-02-05	 Added .ini file processing for ease of management and sharing 
; *		2021-02-01	 Refactored code for reuse optimization
; *
; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****

#NoEnv
#Persistent

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
	Global MaxOpenCreateFolderAndFileInputs
	

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

; BEGIN Script-Wide special placeholder variables replacement function ReplacePlaceholderStrings, user can add new placeholders,
; which will be replaced on all functions that hase this line:
; <== {PLACEHOLDER VARIABLE ENABLED} ==>

ReplacePlaceholderStrings(BaseString){
	; Function to dynamically generate values based on common AHK expressions, this will allow you to use these placeholders 
	; at the ini file to set names based on AHk variables. 
	; Note: Not all of these placeholders are standard AHK variables

	SanitizedString := BaseString

	; Custom placeholders not default for  AHK variables
	FormatTime, FormattedVar, , yyyy-MM-dd
	SanitizedString := StrReplace(SanitizedString, "{A_DATE_NOW}", FormattedVar)

	FormatTime, FormattedVar, , HH.mm.ss
	SanitizedString := StrReplace(SanitizedString, "{A_TIME_NOW}", FormattedVar)
	
	FormatTime, FormattedVar, , hh.mm.ss tt
	SanitizedString := StrReplace(SanitizedString, "{A_12HourAM_PM}", FormattedVar)

	FormatTime, FormattedVar, , YDay0
	SanitizedString := StrReplace(SanitizedString, "{A_YDay0}", FormattedVar)

	FormattedVar := SubStr(A_YWeek, -1)
	SanitizedString := StrReplace(SanitizedString, "{A_Week_of_year}", FormattedVar)

	; Placeholders for standard AHK variables
	SanitizedString := StrReplace(SanitizedString, "{A_YYYY}", A_YYYY)
	SanitizedString := StrReplace(SanitizedString, "{A_Year}", A_year)
	SanitizedString := StrReplace(SanitizedString, "{A_MM}", A_MM)
	SanitizedString := StrReplace(SanitizedString, "{A_Mon}", A_Mon)
	SanitizedString := StrReplace(SanitizedString, "{A_DD}", A_DD)
	SanitizedString := StrReplace(SanitizedString, "{A_MDay}", A_MDay)
	SanitizedString := StrReplace(SanitizedString, "{A_MMMM}", A_MMMM)
	SanitizedString := StrReplace(SanitizedString, "{A_MMM}", A_MMM)
	SanitizedString := StrReplace(SanitizedString, "{A_DDDD}", A_DDDD)
	SanitizedString := StrReplace(SanitizedString, "{A_DDD}", A_DDD)
	SanitizedString := StrReplace(SanitizedString, "{A_WDay}", A_WDay)
	SanitizedString := StrReplace(SanitizedString, "{A_YDay}", A_YDay)
	SanitizedString := StrReplace(SanitizedString, "{A_YWeek}", A_YWeek)
	SanitizedString := StrReplace(SanitizedString, "{A_Hour}", A_Hour)
	SanitizedString := StrReplace(SanitizedString, "{A_Min}", A_Min)
	SanitizedString := StrReplace(SanitizedString, "{A_Sec}", A_Sec)
	SanitizedString := StrReplace(SanitizedString, "{A_MSec}", A_MSec)
	SanitizedString := StrReplace(SanitizedString, "{A_Now}", A_Now)

	; Placeholders for user-defined paths
	; UserDefinedPathVar := CleanUpPathString(BaseString, LeftTrim:=true, RightTrim:=true, SanitizeChar:="\")
	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_MyDocuments_Path
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_MyDocuments_Path}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_Downloads_Path
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_Downloads_Path}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_ProgramFiles_Path
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_ProgramFiles_Path}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_ProgramFiles_x86_Path
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_ProgramFiles_x86_Path}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_UserFolder_Path
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_UserFolder_Path}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_1
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_1}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_2
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_2}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_3
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_3}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_4
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_4}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_5
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_5}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_6
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_6}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_7
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_7}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_8
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_8}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_9
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_9}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_10
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_10}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_11
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_11}", UserDefinedPathVar)

	IniRead, UserDefinedPathVar, %IniSettingsFilePath%, UserDefinedPaths, A_User_Defined_Path_12
	UserDefinedPathVar := CleanUpPathString(UserDefinedPathVar)
	SanitizedString := StrReplace(SanitizedString, "{A_User_Defined_Path_12}", UserDefinedPathVar)

	; MsgBox %SanitizedString% ; [HGE] (DEBUG) Uncomment_for_tests
	return SanitizedString
}
; END Script-Wide special placeholder variables replacement function ReplacePlaceholderStrings


; BEGIN Functions to process input hooks, which are used by slot-based functions
global ProcessSlotInputHook, FolderSlotSearchById := false

ProcessSlotInputHook_Char(ih, char){
    InputFirstChar := SubStr(ih.input, 1,1)

    if InputFirstChar is integer 
    		FolderSlotSearchById := true
  	else
  		FolderSlotSearchById := false

    if (GetKeyVK(char) = 27 )
    {
		ToolTip, % "ABORTED"
		ProcessSlotInputHook.Stop()
    }
    else if (FolderSlotSearchById)
    {
    	ToolTip, % "FolderSlot ID: " ih.input
    	ih.KeyOpt("{Space}", "E") 
    }	
    else
    {
    	ToolTip, % "FolderSlot label: " ih.input
    	ih.KeyOpt("{Space}", "-E") 
    }
}

ProcessSlotInputHook_KeyDown(ih, vk, sc){
  if (vk = 8){ ; {Backspace}
    ProcessSlotInputHook_Char(ih, "")
  }

  else if (vk = 32){ ; {Space}
		if (FolderSlotSearchById = true)
		{
			ProcessSlotInputHook.Stop()
		}
	}

	else if (vk = 27){ ; {Esc}
		ProcessSlotInputHook.Stop()
	}

  else if (vk = 9){ ; Tab
  	ProcessSlotInputHook.Stop()
  }

  return
	RemoveProcessSlotInputHook_KeyDownToolTip:
	ToolTip
	return
}

ProcessSlotInputHook_End(){
	SetTimer, RemoveProcessSlotInputHook_EndToolTip, -500

	return
	RemoveProcessSlotInputHook_EndToolTip:
	ToolTip
	return
}
; END Functions to process input hooks, which are used by slot-based functions

; BEGIN Functions to process dynamic input variables, will be used by several functions to process a list of inputs and replace them over a base string
ProcessVariableInputString(MaxLoopCount, IniFileSection, IniFileKeyPreffix, IniFileKeySuffix, NameDescription, BaseString){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	; To keep maximum compatibility, IniFileKeyPreffix and IniFileKeySuffix will be used optionally, since there are INI file sections with the format
	; Variable_numID  and also PROGRAM-Varaible (with no numeric ID)
	; This function will receive loop count, an INI file section to go through variables, and then it will replace and sanitize the base string provided
	; Also, this function will error out with the string FUNCTION_EXITED_WITH_ERROR:%ErrorLevel% (Error level will be 1 on CANCEL, or 2 on TIMEOUT)
	; if the user pressed one of these buttons, code that use this function should validate this error string so it stops executing any other code afterwards 

	; NameInput%a_index% will be MANDATORY, even if it does not contains any RegExDeleteFromInput or RegExInsertInput with values, 
	; and EVEN if it use a special reserved word like DATE_NOW() or TIME_NOW().
	; IniRead, MaxFolderSlots, %IniSettingsFilePath%, GeneralSettings, %IniFileKeyPreffix%-MaxFolderSlots

	; MsgBox, %MaxLoopCount% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, %IniFileSection% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, %IniFileKeyPreffix% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, %IniFileKeySuffix% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, %BaseString% ; [HGE] (DEBUG) Uncomment_for_tests
	SanitizedString := BaseString

	Loop %MaxLoopCount%
	{
		; This function will take arguments from ini file, sequentially starting from 1, 
		;  until it finds no continuous N argument or until %MaxLoopCount%
		IniRead, NameInput%a_index%, %IniSettingsFilePath%, %IniFileSection%, %IniFileKeyPreffix%NameInput%a_index%%IniFileKeySuffix%
		IniRead, RegExDeleteFromInput%a_index%, %IniSettingsFilePath%, %IniFileSection%, %IniFileKeyPreffix%RegExDeleteFromInput%a_index%%IniFileKeySuffix%
		IniRead, RegExInsertInput%a_index%, %IniSettingsFilePath%, %IniFileSection%, %IniFileKeyPreffix%RegExInsertInput%a_index%%IniFileKeySuffix%
		
		; msgNameInput := NameInput%a_index% ; [HGE] (DEBUG) Uncomment_for_tests
		; msgRegExDeleteFromInput := RegExDeleteFromInput%a_index% ; [HGE] (DEBUG) Uncomment_for_tests
		; msgRegExInsertInput := RegExInsertInput%a_index% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, %msgNameInput% %msgRegExDeleteFromInput% %msgRegExInsertInput% ; [HGE] (DEBUG) Uncomment_for_tests

		SanitizedString := ReplacePlaceholderStrings(SanitizedString)

		if (NameInput%a_index% == "ERROR") 
			break
		
		NameInput := % NameInput%a_index%
		InputBox, VariableInput%a_index%, %WinEnvName%,Enter %NameInput% for %NameDescription%
		if (ErrorLevel > 0)
		{
			SanitizedString := "FUNCTION_EXITED_WITH_ERROR:" ErrorLevel
			return %SanitizedString%
		} 
		
		RegExCleanedInput%a_index% := % RegExReplace(VariableInput%a_index%, RegExDeleteFromInput%a_index%)
		SanitizedString := RegExReplace(SanitizedString, RegExInsertInput%a_index%, RegExCleanedInput%a_index%)
	}
	; MsgBox, %SanitizedString% ; [HGE] (DEBUG) Uncomment_for_tests
	return %SanitizedString%
}

CleanUpPathString(BaseString, LeftTrim:=true, RightTrim:=true, SanitizeChar:="\"){
	; This function will remove left and rigt white spaces and tabs, also it will remove a single leading and trailing SanitizeChar from the BaseString declared 
	BaseString_StartChar := ""
	BaseString_EndChar := ""
	SanitizedString := ""

	BaseString := Trim(BaseString)

	if (BaseString<>"")
	{
		; Getting first and last characters from the BaseString to validate single \ will be always present
		BaseString_StartChar := SubStr(BaseString, 1, 1)
		BaseString_EndChar := SubStr(BaseString, 0)

		; Validating just in case BaseString contains a leading \, we will remove this one in case it matches
		if ((BaseString_StartChar==SanitizeChar) && LeftTrim)
			BaseString := SubStr(BaseString, 2)
			; MsgBox, %BaseString_StartChar% ; [HGE] (DEBUG) Uncomment_for_tests

		if ((BaseString_EndChar==SanitizeChar)  && RightTrim)
			BaseString := SubStr(BaseString, 1, -1)
			; MsgBox, %BaseString_EndChar% ; [HGE] (DEBUG) Uncomment_for_tests
	}

	return BaseString
}

; END Functions to process dynamic input variables, will be used by several functions to process a list of inputs and replace them over a base string


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

SearchAndClose(WindowTitle,CloseCommand){
	; MsgBox test start 
	; testCounter := 0
	Loop 
	{
	    if (WinExist(WindowTitle))
	    {   
	        WinActivate, %WindowTitle%
	        WinWaitActive, %WindowTitle%,,3
	        if ErrorLevel
	        {
	            ; MsgBox, No windows found
				MsgBox, 64, %WinEnvName%No more windows, No more windows with the tittle: `n"%WindowTitle%"
				return
	        }
	        else
	        {
		       	; Send, {Alt}{f4}
		       	Switch CloseCommand
		       	{
					Case "Alt+F4":
					Send, !{f4}
					Case "Control+Q":
					Send, ^q
					; Default:
					;	Statements3
		       	}
		        Sleep, 100
	        }

	    }
	    else
	    {
			MsgBox, 64, %WinEnvName%No more windows, No more windows with the tittle: `n"%WindowTitle%"
			Return
	    }
	}
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


ShowOrRunProgram(ProgramNameId){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>	
	; Unified all functions for individual programs into sigle re-usable function, taking the parameters from SCRIPT.INI file	
	; ShowOrRunProgram(command,arguments, path){
	IniRead, AhkExeName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-AhkExeName
	; Sanitize string with ReplacePlaceholderStrings()
	AhkExeName := ReplacePlaceholderStrings(AhkExeName)

	IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-AhkGroupName
	; Sanitize string with ReplacePlaceholderStrings()
	AhkGroupName := ReplacePlaceholderStrings(AhkGroupName)

	IniRead, ProgramName, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-ProgramName
	; Sanitize string with ReplacePlaceholderStrings()
	ProgramName := ReplacePlaceholderStrings(ProgramName)

	IniRead, CommandExe, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandExe
	; Sanitize string with ReplacePlaceholderStrings()
	CommandExe := ReplacePlaceholderStrings(CommandExe)

	IniRead, CommandPath, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandPath
	; Sanitize string with ReplacePlaceholderStrings()
	CommandPath := ReplacePlaceholderStrings(CommandPath)

	IniRead, CommandArgs, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-CommandArgs
	; Sanitize string with ReplacePlaceholderStrings()
	CommandArgs := ReplacePlaceholderStrings(CommandArgs)


	If ((AhkExeName == "ERROR") || (AhkGroupName == "ERROR") || (ProgramName == "ERROR") || (CommandExe == "ERROR") || (CommandPath == "ERROR") || (CommandArgs == "ERROR"))
	{
		MsgBox, ERROR... Missing parameters for ShowOrRunProgram function check the "%IniSettingsFileName%" file
		return 
	}
	; [PENDING]: to implement
	; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-RunAsAdmin

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

ShowOpenWebSiteWithInput(WebSiteWithInputNameId){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>	
	IniRead, AhkSearchWindowTitle, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-AhkSearchWindowTitle
	AhkSearchWindowTitle := ReplacePlaceholderStrings(AhkSearchWindowTitle)

	IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-AhkGroupName
	AhkGroupName := ReplacePlaceholderStrings(AhkGroupName)

	IniRead, SiteName, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-SiteName
	SiteName := ReplacePlaceholderStrings(SiteName)

	; Not necessary since it will be a fixed value that script will then process
	IniRead, OpenWebSiteOperation, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-OpenWebSiteOperation

	
	; Main URL to insert input parameters
	IniRead, BaseUrl, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-BaseUrl
	BaseUrl := ReplacePlaceholderStrings(BaseUrl)

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
				; Sanitize string with ReplacePlaceholderStrings()
				BrowserProfile := ReplacePlaceholderStrings(BrowserProfile)


				IniRead, OpenTarget, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-OpenTarget
			; [END] Set browser profile in [ShowOpenWebSiteWithInput] this will indicate fields to load from [BrowsersProfiles]

			; [BEGIN] Load web browser profile from [BrowsersProfiles], this is determined by particular profile under [ShowOpenWebSiteWithInput]
				IniRead, BrowserExe, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserExe
				; Sanitize string with ReplacePlaceholderStrings()
				BrowserExe := ReplacePlaceholderStrings(BrowserExe)

				IniRead, BrowserPath, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserPath
				; Sanitize string with ReplacePlaceholderStrings()
				BrowserPath := ReplacePlaceholderStrings(BrowserPath)

				IniRead, BrowserUserProfile, %IniSettingsFilePath%, BrowsersProfiles, %BrowserProfile%-DefinedBrowserUserProfile
				; Sanitize string with ReplacePlaceholderStrings()
				BrowserUserProfile := ReplacePlaceholderStrings(BrowserUserProfile)

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
				; Sanitize string with ReplacePlaceholderStrings()
				Arguments%a_index% := ReplacePlaceholderStrings(Arguments%a_index%)
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
				; Sanitize string with ReplacePlaceholderStrings()
				NameInput%a_index% := ReplacePlaceholderStrings(NameInput%a_index%)

				IniRead, RegExDeleteFromInput%a_index%, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-RegExDeleteFromInput%a_index%
				IniRead, RegExInsertInput%a_index%, %IniSettingsFilePath%, ShowOpenWebSiteWithInput, %WebSiteWithInputNameId%-RegExInsertInput%a_index%

				
				if (NameInput%a_index% == "ERROR") 
					break
				
				NameInput := % NameInput%a_index%
				InputBox, UrlInput%a_index%, %WinEnvName%,Enter %NameInput% for %SiteName% URL
				if ErrorLevel
					Return
				UrlInput%a_index% := ReplacePlaceholderStrings(UrlInput%a_index%)
				
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

ProcessFolderSlot_X(IdOrLabel:=""){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	FolderSlotLabelFound := false
	IniRead, MaxFolderSlots, %IniSettingsFilePath%, GeneralSettings, CreateOpenFolder_X-MaxFolderSlots
	If (MaxFolderSlots == "ERROR")
	{
		MaxFolderSlots := 20
	}

	; BEGIN code to call slot directly is defined via hotkey
	if (IdOrLabel != "")
	{
		if IdOrLabel is integer 
			FolderSlotSearchById := true
		else
			FolderSlotSearchById := false

		FolderSlot := Trim(IdOrLabel)
		Gosub, FolderSlot_IdOrLabel_DirectGoTo
		return ; safe return to prevent declaring input handler
	}
	; END code to call slot directly is defined via hotkey

	FolderSlotCounter := 0
	ToolTip, % "Type FolderSlot ID or label: "
	FolderSlotSearchById := false

	ProcessSlotInputHook := InputHook("L30T20", "{Enter}{Tab}")
	ProcessSlotInputHook.OnChar := Func("ProcessSlotInputHook_Char")
	ProcessSlotInputHook.OnKeyDown := Func("ProcessSlotInputHook_KeyDown")
	ProcessSlotInputHook.OnEnd := Func("ProcessSlotInputHook_End")
	ProcessSlotInputHook.KeyOpt("{Backspace}{esc}{space}{tab}", "N")
	ProcessSlotInputHook.Start()

	ErrorLevel := ProcessSlotInputHook.Wait()
	if (ErrorLevel = "EndKey"){
    ErrorLevel .= ":" ProcessSlotInputHook.EndKey	
    ToolTip ; Visual improvement to remove ToolTip before confirmation
		FolderSlot := ProcessSlotInputHook.Input
	}

	if (ErrorLevel = "Stopped"){
		FolderSlot := ""
		return
	}

	; BEGIN code to call slot directly is defined via hotkey
	FolderSlot_IdOrLabel_DirectGoTo:
	; END code to call slot directly is defined via hotkey

	FolderSlot := Trim(FolderSlot)
	FolderSlotIndex := 

	if (FolderSlot = "e")
	{
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
		FolderSlotID := FolderSlot
		IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder_X, BaseFolderPath_%FolderSlot%
		BaseFolderPath := CleanUpPathString(BaseFolderPath)
		BaseFolderPath := ReplacePlaceholderStrings(BaseFolderPath)
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
				FolderSlotID := A_Index
				; MsgBox %FolderSlotID% ; [HGE] (DEBUG) Uncomment_for_tests

				IniRead, BaseFolderPath, %IniSettingsFilePath%, CreateOpenFolder_X, BaseFolderPath_%FolderSlotIndex%
				BaseFolderPath := CleanUpPathString(BaseFolderPath)
				BaseFolderPath := ReplacePlaceholderStrings(BaseFolderPath)
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
		FolderString := ""
		FileNameString := ""
		If ((BaseFolderPath == "ERROR"))
		{
			MsgBox, ERROR... SLOT "%FolderSlot%" base folder path not defined, check the "%IniSettingsFileName%" file under `n[CreateOpenFolder_X] --> BaseFolderPath_xx
			return 
		}
		
		if (!FileExist(BaseFolderPath))
		{
			MsgBox, ERROR... SLOT "%FolderSlot%" `n%BaseFolderPath%`nBase folder directory not found, check the "%IniSettingsFileName%" file under `n[CreateOpenFolder_X] --> BaseFolderPath_xx
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
		else if (FolderOperation =="Open_Create_Folder_And_File")
		{
			; MsgBox, CREATING FILE AND FOLDER ; [HGE] (DEBUG) Uncomment_for_tests

			IniRead, MaxOpenCreateFolderAndFileInputs, %IniSettingsFilePath%, GeneralSettings, CreateOpenFolder_X-MaxOpenCreateFolderAndFileInputs
			If (MaxOpenCreateFolderAndFileInputs == "ERROR")
			{
				MaxOpenCreateFolderAndFileInputs := 10
			}

			IniRead, VariableFolderPath, %IniSettingsFilePath%, CreateOpenFolder_X, Folder-VariableFolderPath_%FolderSlotID%
			IniRead, VariableFileName, %IniSettingsFilePath%, CreateOpenFolder_X, File-CreateWithName_%FolderSlotID%

			FolderString := ProcessVariableInputString(MaxOpenCreateFolderAndFileInputs, "CreateOpenFolder_X", "Folder-", "_"FolderSlotID, LocationName, VariableFolderPath)
			if (FolderString == "FUNCTION_EXITED_WITH_ERROR:1") ; User pressed CANCEL or ESC key at one of the input boxes
			{
				; MsgBox, User pressed CANCEL
				return
			}

			if (VariableFileName == "ERROR") ; Filename not set on .ini file
				FileNameString := "ERROR"
			else
			{
				FileNameString := ProcessVariableInputString(MaxOpenCreateFolderAndFileInputs, "CreateOpenFolder_X", "File-", "_"FolderSlotID, LocationName, VariableFileName)
				if (FileNameString == "FUNCTION_EXITED_WITH_ERROR:1") ; User pressed CANCEL or ESC key at one of the input boxes
				{
					; MsgBox, User pressed CANCEL
					return
				}
			}
		}
		
		CreateOpenFolder(BaseFolderPath, LocationName, FolderOperation, FolderString, FileNameString, FolderSlotID)
	; Label safe exit point: ProcessFolderSlot_X_ValidateData
	return
}

CreateOpenFolder(BaseFolderPath, LocationName, FolderOperation, Folder_VariableFolderPath:="", File_CreateWithName:="", FolderSlotID:=""){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	VariableFolderPath_StartChar := ""
	VariableFolderPath_EndChar := ""

	; Folder_VariableFolderPath := Trim(Folder_VariableFolderPath)
	BaseFolderPath := CleanUpPathString(BaseFolderPath)
	BaseFolderPath := ReplacePlaceholderStrings(BaseFolderPath)
	Folder_VariableFolderPath := CleanUpPathString(Folder_VariableFolderPath)
	Folder_VariableFolderPath := ReplacePlaceholderStrings(Folder_VariableFolderPath)
	File_CreateWithName := CleanUpPathString(File_CreateWithName)
	File_CreateWithName := ReplacePlaceholderStrings(File_CreateWithName)
	; MsgBox, %File_CreateWithName% ; [HGE] (DEBUG) Uncomment_for_tests

	; File_CreateWithName := Trim(File_CreateWithName)

	if (FolderOperation =="Open_Create")
	{
		InputBox, FolderName, %WinEnvName%Enter name for %LocationName%, Folder will be created or opened`, if it does not exist it will be created at `n`n %BaseFolderPath%
		if ErrorLevel
			return 

		FolderName := Trim(FolderName)

		if (FolderName=="")
			return 

		FolderFullPath = %BaseFolderPath%\%FolderName%


		; if (BaseFolderPath_EndChar<>"\")
			; BaseFolderPath = %BaseFolderPath%\

	}
	else if (FolderOperation =="Open_Folder")
	{
		PathArray := StrSplit(BaseFolderPath, "\")
		FolderName := PathArray[(PathArray.MaxIndex())]
		FolderFullPath = %BaseFolderPath%
		ErrorLevel := false 

		; MsgBox, OPEN FOLDER ONLY ; [HGE] (DEBUG) Uncomment_for_tests
		; if (BaseFolderPath_EndChar=="\")
		; {
		; 	BaseFolderPath := SubStr(BaseFolderPath, 1, -1)
		; MsgBox, END CHAR BAD %BaseFolderPath% ; [HGE] (DEBUG) Uncomment_for_tests

		; }
			; Extract the base folder path to open folder (last backslash not needed here)

		; Break path into array by backslash character 
		; MsgBox, Folder name %FolderName% ; [HGE] (DEBUG) Uncomment_for_tests
		; MsgBox, Full path %FolderFullPath% ; [HGE] (DEBUG) Uncomment_for_tests
	}

	else if (FolderOperation =="Open_Create_Folder_And_File")
	{
		if ((Folder_VariableFolderPath<>"") && (Folder_VariableFolderPath<>"ERROR"))
			TempFolderFullPath = %BaseFolderPath%\%Folder_VariableFolderPath%
		; 		BaseFolderPath = %BaseFolderPath%\
		else
			TempFolderFullPath = %BaseFolderPath%
		
		PathArray := StrSplit(TempFolderFullPath, "\")
		FolderName := PathArray[(PathArray.MaxIndex())]
		; Need to define FolderFullPath without leading \ to allow to create directories and paths
		FolderFullPath = %TempFolderFullPath%
		ErrorLevel := false 

	}
	
	; ABORT all below operations if user canceled input

	if InStr(FileExist(FolderFullPath), "D")
	{
		; MsgBox, Directory exists ; [HGE] (DEBUG) Uncomment_for_tests
		; Copy text to Clipboard
		clipboard = %FolderFullPath%
		; SetTitleMatchMode, 2
		WinWait ,%FolderName% ahk_exe explorer.exe, , 0.5 
		If !ErrorLevel ; test 1
		{
			; MsgBox, Window exists ; [HGE] (DEBUG) Uncomment_for_tests
			WinActivate
			if (FolderOperation == "Open_Create_Folder_And_File")
			{
				; MsgBox, test win activate ; [HGE] (DEBUG) Uncomment_for_tests
				if (File_CreateWithName <> "ERROR") ; Filename not set on .ini file
					CheckCreateOpenFile(FolderFullPath, File_CreateWithName, LocationName, false,  false, FolderSlotID)
			}
		}
		else
		{
			if (FolderOperation == "Open_Folder")
			{
				MsgBox, 36, %WinEnvName%Open Folder, Open [%LocationName%] `nPath: %FolderFullPath% `nNo window with that title found, open? 
				IfMsgBox Yes
				{
					; NOTE: Check RunWithNoElevation() warnings if this ever gets implemented
					; RunWithNoElevation("explorer.exe",FolderFullPath, A_WinDir)
					Run, explorer.exe "%FolderFullPath%"
				}
			}
			else if (FolderOperation == "Open_Create")
			{
				; Since already asked for the folder name makes sense to open automatically 
				; MsgBox, Opening requested window ; [HGE] (DEBUG) Uncomment_for_tests
				Run, explorer.exe "%FolderFullPath%"
			}
			else if (FolderOperation == "Open_Create_Folder_And_File")
			{
				; Since already asked for the folder name makes sense to open automatically 
				; MsgBox, Opening requested window ; [HGE] (DEBUG) Uncomment_for_tests
				Run, explorer.exe "%FolderFullPath%"
				Sleep, 1200
				if (File_CreateWithName <> "ERROR") ; Filename not set on .ini file
					CheckCreateOpenFile(FolderFullPath, File_CreateWithName, LocationName, false,  false, FolderSlotID)

			}
		}
	}
	else if (FolderOperation == "Open_Create")
	{
		; Message box options:
		; Yes/No	--> 4 
		; Icon Question	--> 32
		; InputBox, FolderName, %WinEnvName%Enter name for %LocationName%, Folder will be created or opened`, if it does not exist it will be created at `n`n %BaseFolderPath%
		; IfMsgBox Yes
		; {
			FileCreateDir, %FolderFullPath%
			Run, explorer.exe "%FolderFullPath%"
			; Copy text to Clipboard
			clipboard = %FolderFullPath%
		; }
	}

	else if (FolderOperation == "Open_Create_Folder_And_File")
	{
		; MsgBox, %File_CreateWithName% ; [HGE] (DEBUG) Uncomment_for_tests
		if (File_CreateWithName == "ERROR") ; Filename not set on .ini file
			OpenCreateMessage = Directory path does not exists: `n%FolderFullPath% `nProceed?
		else
			OpenCreateMessage = Directory path does not exists: `n%FolderFullPath% `n`nAlso new file '%File_CreateWithName%' will be created`nProceed?
	
		MsgBox, 36, %WinEnvName%Create new directory?, %OpenCreateMessage% 
		IfMsgBox Yes
		{
			FileCreateDir, %FolderFullPath%
			Run, explorer.exe "%FolderFullPath%"
			; Copy text to Clipboard
			clipboard = %FolderFullPath%
			Sleep, 1200
		
			if (File_CreateWithName <> "ERROR") ; Filename not set on .ini file
				CheckCreateOpenFile(FolderFullPath, File_CreateWithName, LocationName, false,  false, FolderSlotID)
		}
	}
}

CheckCreateOpenFile(FolderPath, CreatedFileName, LocationName:="", ConfirmFileCreation:=false,  ConfirmFileOpening:=false, FolderSlotID:=""){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	FolderPath := CleanUpPathString(FolderPath)
	FolderPath := ReplacePlaceholderStrings(FolderPath)
	CreatedFileName := CleanUpPathString(CreatedFileName)
	CreatedFileName := ReplacePlaceholderStrings(CreatedFileName)
	FullFileName = %FolderPath%\%CreatedFileName%

	if (LocationName=="")
		LocationName := "No name"

	if (FileExist(FullFileName))
	{
		if (ConfirmFileOpening)
		{
			MsgBox, 36, %WinEnvName%Open file?, %CreatedFileName% already exists at: `n%FolderPath% `nProceed? 
			IfMsgBox No
				Return 
		}
	}
	else
	{
		if (ConfirmFileCreation)
		{
			MsgBox, 36, %WinEnvName%Create new file?, %CreatedFileName% does not exists at: `n%FolderPath% `nProceed? 
			IfMsgBox No
				Return 
		}

		FileContents := ""
		Loop
		{
			; This function will take arguments from ini file, sequentially starting from 1, File-CreateWithContents{loop_index}_{FolderSlotID}
			;  until it finds no continuous N argument
			IniRead, FileCurrentLine, %IniSettingsFilePath%, CreateOpenFolder_X, File-CreateWithContents%a_index%_%FolderSlotID%
			if (FileCurrentLine == "ERROR") 
				break
			
			FileCurrentLine := StrReplace(FileCurrentLine, "\n", "`n")
			FileCurrentLine := ReplacePlaceholderStrings(FileCurrentLine)
			FileCurrentLine := FileCurrentLine "`n"
			FileContents := FileContents FileCurrentLine
		}

		FileAppend, %FileContents%, %FullFileName%

		if (ConfirmFileOpening)
		{
			MsgBox, 36, %WinEnvName%Open created file?, %CreatedFileName% was created at: `n%FolderPath% `nProceed? 
			IfMsgBox No
				Return
		}
	}

	Run, %FullFileName%
}

ProcessRegExReplaceText_X(IdOrLabel:=""){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	; Placeholder replace done at nested function RunRegExReplaceText()
	ReplaceTextSlotLabelFound := false
	IniRead, MaxReplaceTextSlots, %IniSettingsFilePath%, GeneralSettings, RegExReplaceText_X-MaxReplaceTextSlots
	If (MaxReplaceTextSlots == "ERROR")
	{
		MaxReplaceTextSlots := 20
	}

	; BEGIN code to call slot directly is defined via hotkey
	if (IdOrLabel != "")
	{
		if IdOrLabel is integer 
			FolderSlotSearchById := true
		else
			FolderSlotSearchById := false

		ReplaceTextSlot := Trim(IdOrLabel)
		Gosub, ReplaceText_IdOrLabel_DirectGoTo
		return ; safe return to prevent declaring input handler
	}
	; END code to call slot directly is defined via hotkey

	ReplaceTextSlotCounter := 0
	ToolTip, % "Type ReplaceTextSlot ID or label: "
	FolderSlotSearchById := false

	ProcessSlotInputHook := InputHook("L30T20", "{Enter}{Tab}")
	ProcessSlotInputHook.OnChar := Func("ProcessSlotInputHook_Char")
	ProcessSlotInputHook.OnKeyDown := Func("ProcessSlotInputHook_KeyDown")
	ProcessSlotInputHook.OnEnd := Func("ProcessSlotInputHook_End")
	ProcessSlotInputHook.KeyOpt("{Backspace}{esc}{space}{tab}", "N")
	ProcessSlotInputHook.Start()

	ErrorLevel := ProcessSlotInputHook.Wait()
	if (ErrorLevel = "EndKey"){
	ErrorLevel .= ":" ProcessSlotInputHook.EndKey	
	ToolTip ; Visual improvement to remove ToolTip before confirmation
		ReplaceTextSlot := ProcessSlotInputHook.Input
	}

	if (ErrorLevel = "Stopped"){
		ReplaceTextSlot := ""
		return
	}
	; BEGIN code to call slot directly is defined via hotkey
	ReplaceText_IdOrLabel_DirectGoTo:
	; END code to call slot directly is defined via hotkey

	ReplaceTextSlot := Trim(ReplaceTextSlot)
	ReplaceTextSlotIndex := 

	if (ReplaceTextSlot = "e"){
		ReplaceTextSlotsDescription := "=== Currently set ReplaceText Slots === `n`n"
		Loop, %MaxReplaceTextSlots%
		{
			ReplaceTextSlotIndex := A_Index
			if (A_Index == MaxReplaceTextSlots)
			{
				ReplaceTextSlotIndex := 0 
			}
			; Not including "ReplaceTextReplaceString" nor "ReplaceTextRegExString" since they have no informational purpose in this function
			IniRead, ReplaceTextLabel, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextLabel_%ReplaceTextSlotIndex%
			IniRead, ReplaceTextName, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextName_%ReplaceTextSlotIndex%
			IniRead, ReplaceTextDescription, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextDescription_%ReplaceTextSlotIndex%
			IniRead, ReplaceTextOperation, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextOperation_%ReplaceTextSlotIndex%

			if (ReplaceTextName != "ERROR")
			{
				ReplaceTextSlotCounter += 1
				ReplaceTextSlotsDescription .= " - Slot: [" ReplaceTextSlotIndex "] -- Label: [" ReplaceTextLabel "]`n    Name: " ReplaceTextName " -- Description: " ReplaceTextDescription "`n"
			}
		}

		ReplaceTextSlotsDescription .= "`nTotal slots: (" ReplaceTextSlotCounter ")"

		if (ReplaceTextSlotCounter < 20)
		{
			MsgBox,32,%WinEnvName%List of set up folder slots, %ReplaceTextSlotsDescription%
		}
		else
		{
			MsgBox,32,%WinEnvName%,List of set up ReplaceText slots is too long, full list was copied to clipboard
				clipboard = % ReplaceTextSlotsDescription
		}
		
		return

	}

	if (FolderSlotSearchById)
	{
		IniRead, ReplaceTextName, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextName_%ReplaceTextSlot%
		IniRead, ReplaceTextDescription, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextDescription_%ReplaceTextSlot%
		IniRead, ReplaceTextRegExString, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextRegExString_%ReplaceTextSlot%
		IniRead, ReplaceTextReplaceString, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextReplaceString_%ReplaceTextSlot%
		IniRead, ReplaceTextOperation, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextOperation_%ReplaceTextSlot%

		; MsgBox, "%ReplaceTextName% %ReplaceTextDescription% %ReplaceTextRegExString% %ReplaceTextReplaceString% %ReplaceTextOperation%" ; [HGE] (DEBUG) Uncomment_for_tests

		Gosub, ProcessReplaceTextSlot_X_ValidateData
	}
	else 
	{
		Loop, %MaxReplaceTextSlots%
		{
			ReplaceTextSlotIndex := A_Index
			if (A_Index == MaxReplaceTextSlots)
			{
				ReplaceTextSlotIndex := 0 
			}
			IniRead, ReplaceTextLabel, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextLabel_%ReplaceTextSlotIndex%

			if (ReplaceTextLabel = ReplaceTextSlot)
			{
				IniRead, ReplaceTextName, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextName_%ReplaceTextSlotIndex%
				IniRead, ReplaceTextDescription, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextDescription_%ReplaceTextSlotIndex%
				IniRead, ReplaceTextRegExString, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextRegExString_%ReplaceTextSlotIndex%
				IniRead, ReplaceTextReplaceString, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextReplaceString_%ReplaceTextSlotIndex%
				IniRead, ReplaceTextOperation, %IniSettingsFilePath%, RegExReplaceText_X, ReplaceTextOperation_%ReplaceTextSlotIndex%

				ReplaceTextSlotLabelFound := true

				; MsgBox, "%ReplaceTextName% %ReplaceTextDescription% %ReplaceTextRegExString% %ReplaceTextReplaceString% %ReplaceTextOperation%" ; [HGE] (DEBUG) Uncomment_for_tests

				Gosub, ProcessReplaceTextSlot_X_ValidateData
				break
			}
		}

		if (!ReplaceTextSlotLabelFound)
		{
			MsgBox, 48, %WinEnvName%Not found, ReplaceText slot not found, please check spelling or enter 'e' to show list of all ReplaceText slots.
		}

	}
	return
	
	ProcessReplaceTextSlot_X_ValidateData:
		If (ReplaceTextName == "ERROR")
		{
			MsgBox, SLOT ReplaceTextName is empty, set it on the "%IniSettingsFileName%" file, `nor confirm if entered ID exists at the "%IniSettingsFileName%" file file under `n[RegExReplaceText_X] --> ReplaceTextName_xx
			return
		}

		If (ReplaceTextDescription == "ERROR")
		{
			ReplaceTextDescription := "Not defined"
		}

		If (ReplaceTextRegExString == "")
		{
			MsgBox, SLOT ReplaceTextRegExString is empty, set it on the "%IniSettingsFileName%" file
			return
		}

		; If (ReplaceTextReplaceString == "")
		; {
			; MsgBox, SLOT ReplaceTextReplaceString is empty, set it on the "%IniSettingsFileName%" file
			; return
		; }

		If (ReplaceTextOperation == "")
		{
			ReplaceTextOperation := "Copy_to_clipboard"
		}
		
		; MsgBox, "%ReplaceTextName% %ReplaceTextDescription% %ReplaceTextRegExString% %ReplaceTextReplaceString% %ReplaceTextOperation%" ; [HGE] (DEBUG) Uncomment_for_tests
		
		RunRegExReplaceText(ReplaceTextName, ReplaceTextDescription, ReplaceTextRegExString, ReplaceTextReplaceString, ReplaceTextOperation)

	; Label safe exit point: ProcessReplaceTextSlot_X_ValidateData
	return
}

RunRegExReplaceText(ReplaceTextName, ReplaceTextDescription, RegExString, ReplaceString, ReplaceTextOperation){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>

	InputBox, BaseText, %WinEnvName%Enter text for %ReplaceTextName% text replace:,Description: %ReplaceTextDescription%

	if ErrorLevel
	{		
		; MsgBox, "ErrorLevel due to cancel" ; [HGE] (DEBUG) Uncomment_for_tests
		Return
	}

	ReplaceString := ReplacePlaceholderStrings(ReplaceString)
	ReplacedText := RegExReplace(BaseText,RegExString,ReplaceString)

	if ErrorLevel
	{		
		MsgBox, %ErrorLevel% 
		Return
	}
	
	if (ReplaceTextOperation =="Copy_to_clipboard")
	{
		Clipboard := ReplacedText
	}
	else if (ReplaceTextOperation =="Simulate_Typing")
	{
		SendInput, {Raw}%ReplacedText%
	}
}

