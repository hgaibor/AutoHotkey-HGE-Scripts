; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
; *	Deprecated functions for HgeScripts.ahk 
; *	Created by: Hugo Gaibor
; *	Date: 2023-Oct-14
; * License: GNU/GPL3+
; *
; * Latest version: https://github.com/hgaibor/AutoHotkey-HGE-Scripts
; * Creating this file to move functions that are deprecated and leave them here for
; *	back reference in case is needed.
; *
; ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****


ShowOrRunWebSite(WebSiteNameId){
	; <== {PLACEHOLDER VARIABLE ENABLED} ==>
	; Unified all functions for individual programs into sigle re-usable function, taking the parameters from SCRIPT.INI file	
	IniRead, BrowserExe, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-BrowserExe
	; Sanitize string with ReplacePlaceholderStrings()
	BrowserExe := ReplacePlaceholderStrings(BrowserExe)

	IniRead, BrowserPath, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-BrowserPath
	; Sanitize string with ReplacePlaceholderStrings()
	BrowserPath := ReplacePlaceholderStrings(BrowserPath)

	IniRead, AhkSearchWindowTitle, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-AhkSearchWindowTitle
	; Sanitize string with ReplacePlaceholderStrings()
	AhkSearchWindowTitle := ReplacePlaceholderStrings(AhkSearchWindowTitle)

	IniRead, AhkGroupName, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-AhkGroupName
	; Sanitize string with ReplacePlaceholderStrings()
	AhkGroupName := ReplacePlaceholderStrings(AhkGroupName)

	IniRead, SiteName, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-SiteName
	; Sanitize string with ReplacePlaceholderStrings()
	SiteName := ReplacePlaceholderStrings(SiteName)

	IniRead, Arguments1, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments1
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments1 := ReplacePlaceholderStrings(Arguments1)

	IniRead, Arguments2, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments2
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments2 := ReplacePlaceholderStrings(Arguments2)

	IniRead, Arguments3, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments3
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments3 := ReplacePlaceholderStrings(Arguments3)

	IniRead, Arguments4, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments4
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments4 := ReplacePlaceholderStrings(Arguments4)

	IniRead, Arguments5, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments5
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments5 := ReplacePlaceholderStrings(Arguments5)

	IniRead, Arguments6, %IniSettingsFilePath%, ShowOrRunWebSite, %WebSiteNameId%-Arguments6
	; Sanitize string with ReplacePlaceholderStrings()
	Arguments6 := ReplacePlaceholderStrings(Arguments6)


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