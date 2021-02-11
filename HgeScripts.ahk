; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
; *	Misc applications command tweaks 
; *	Created by: Hugo Gaibor
; *	Date: 2019-Jan-25
; * License: GNU/GPL3+
; *
; * Latest version: https://gist.github.com/hgaibor/ced4f817e229f441ae95b75314b9a5be
; * History:
; *		
;	*		2021-02-10	 Added more functionalities and multiple parameter-based calls 
;	*		2021-02-05	 Added .ini file processing for ease of management and sharing 
; *		2021-02-01	 Refactored code for reuse optimization
; *
; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****


; Attempt to load INI file, if not successful, exit app
Global IniSettingsFileName
IniSettingsFileName :=SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", False, -1) -1)".ini"

Global IniSettingsFilePath
IniSettingsFilePath :=SubStr(A_ScriptFullPath, 1, InStr(A_ScriptFullPath, ".", False, -1) -1)".ini"

if (IniFileSetting = "ERROR") 
{
	MsgBox, Error loading file, create an .ini file and make sure the name matches the .ahk file
	ExitApp
}

; Validate the script has admin rights, as it is necessary for the route_add commands to work 
full_command_line := DllCall("GetCommandLine", "str")
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


; GeneralSettings Section	
	Global WinEnvName
	IniRead, WinEnvName, %IniSettingsFilePath%, GeneralSettings, WinEnvName
	; MsgBox, %WinEnvName% ; [HGE] (DEBUG) Uncomment_for_tests
	If (WinEnvName == "ERROR")
	{
		WinEnvName := ""
	}

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
	MsgBox Running %A_ScriptName% Script as admin: %A_IsAdmin%`nEnvironment: %WinEnvName%`nScript Source: %full_command_line%


; KEY special characters definition 
	; # --> Windows key
	; ^ --> Control key
	; ! --> Alt key
	; <!> --> AltGr key
	; + --> Shift key
	; < --> Left key pair (for control, shift and alt keys)
	; > --> Right key pair (for control, shift and alt keys)
	; SPACE --> Space bar key
	; Numpad0 --> Number pad 0 


; Hot Keys definition 
	; ^!r::Reload  ; Assign Ctrl-Alt-R as a hotkey to restart the script.
	>+#r::Reload  ; Assign Shift-Windows-R as a hotkey to restart the script.
	+#c::AddIPtoRoute()
	+#w::ShowOrRunWebSite("WebSvoxPhone")
	+#q::ShowOrRunWebSite("WebSvoxQ")
	+#s::ShowOrRunWebSite("WebSlack")
	+#m::ShowOrRunWebSite("SngMeet")
	;+#s::ShowOrRunProgram("SlackDesktop")
	
	^#s::ShowOrRunProgram("St3")
	+#z::ShowOrRunProgram("ZimWiki")
	+#r::ShowOrRunProgram("WinRDP")
	+#k::ShowOrRunProgram("Kitty")
	+#t::ShowOrRunProgram("TaskCoach")
	
	; +#p::FQDN_to_IP() ; [HGE] (DEBUG) Uncomment_for_tests 
	#MButton:: ToggleAlwaysOnTop() ; [HGE] Browser forward

; [HGE] Workaround for lack of additional mouse buttons and really crappy and expensive mice with them
	^MButton:: Send {Browser_Back} ; [HGE] Browser forward
	!MButton:: Send {Browser_Forward} ; [HGE] Browser forward
	^!Insert::WrittenPaste()

	;Slot implementation of CreateOpenFolder() function
	+#e::ProcessFolderSlot()
		
#IfWinActive ahk_class PuTTYConfigBox  ; Putty Config window 
	; Validation to enable  start button quick key press on Putty, very convenient 
	; Putty Window info
	; KiTTY Configuration
	; ahk_class PuTTYConfigBox
	; ahk_exe KITTY_~1.EXE
	
	; Control for start button
	; ClassNN:	Button2
	; Text:	Start
	; Color:	C5F1FB (Red=C5 Green=F1 Blue=FB)
	; 	x: 12	y: 436	w: 83	h: 23
	; Client:	x: 9	y: 410	w: 83	h: 23
	!s:: PuttyStartSession()  ; Start session rather than opening one 
#IfWinActive

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
	;Send clipboard contents as keystrokes, useful when you can't paste into browsers or remote consoles 
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
	; Pending to implement
	; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunProgram, %ProgramNameId%-RunAsAdmin

	; MsgBox, AhkExeName--> %AhkExeName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, AhkGroupName--> %AhkGroupName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, ProgramName--> %ProgramName% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandExe--> %CommandExe% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandPath--> %CommandPath% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, CommandArgs--> %CommandArgs% ; [HGE] (DEBUG) Uncomment_for_tests
	; MsgBox, RunAsAdmin--> %RunAsAdmin% ; [HGE] (DEBUG) Uncomment_for_tests

	if WinExist(AhkExeName)
	{   
		SetTitleMatchMode, 2
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
			RunWithNoElevation(CommandExe,CommandArgs, CommandPath)
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
		; Pending to implement
		; IniRead, RunAsAdmin, %IniSettingsFilePath%, ShowOrRunWebSite, %ProgramNameId%-RunAsAdmin

		if WinExist(AhkSearchWindowTitle)
		{   
			SetTitleMatchMode, 2
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
				RunWithNoElevation(BrowserExe,BrowserArgs, BrowserPath)
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
				; If it's and IP address, add it directly
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


ProcessFolderSlot(){
	FolderSlot := 
		Input, FolderSlot, "L1 T2", {Enter}, 1,2,3,4,5,6,7,8,9,0
		if (ErrorLevel = "Max")
		{
		    MsgBox, %WinEnvName%Select a valid folder slot, only numbers [1-9]+0 can be entered, set the slots on "%IniSettingsFileName%" file
		    return
		}
		if (ErrorLevel = "Timeout")
		{
		    MsgBox, %WinEnvName%Select a valid folder slot, [1-9]+0 slots can be set up upon the "%IniSettingsFileName%" file
		    return
		}
		if (ErrorLevel = "NewInput")
		    return
		If InStr(ErrorLevel, "EndKey:")
		{
		    MsgBox, %WinEnvName%Select a valid folder slot, only numbers [1-9]+0 can be entered, set the slots on "%IniSettingsFileName%" file
		    return
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
			FolderFullPath := BaseFolderPath FolderName
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
			IfWinExist, %FolderName%
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
						; RunWithNoElevation("explorer.exe",FolderFullPath, A_WinDir)
						Run, explorer.exe "%FolderFullPath%"
					}
				}
			}

		}
		else 
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


PuttyStartSession(){
	; MsgBox, Putty window 
	ControlFocus , Button2
	ControlSend , Button2, {space}
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