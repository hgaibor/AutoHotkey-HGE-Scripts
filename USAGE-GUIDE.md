HgeScripts .ini file guide
==========================
The purpose of this AHK script is to automate common tasks as much as possibe, in a simple way (once you set your *ini* file properly.
Despite that goal, initial setup may be complex for some, at least at the beginning. 

This guide will separate explaining from base example.ini file in order to make it as clear and as detailed as possible, with easy-to-read markdown formatting. 

Code will be put in blocks, so after reading the explaining, you can copy-paste the full block into your own *.ini* file

[GeneralSettings] section
-------------------------
Like the name states, it will include values for global variables that will affect other parts of the script, or that are general limits or configuration parameters for the script operation. 

### Variables description
- **WinEnvName=** --> Descriptive name for this script instance, internal logic *may* allow to run several copies of the same script with different `ahk` and its associated `ini` and `ahk_hotkeys` files names. **NOT TESTED**
- **RunScriptAsAdmin=** --> Run script as admin user.- This is needed for the `VPN add route` function to work correctly, if you're not going to use that function, leave the default `no` as value. This ws added to fix an issue #020
- **BrowsersProfiles-MaxBrowserArguments=** --> Use these variable to increase the amount of arguments the `OpenWebSiteWithInput` function loop will read, Default value of 10 should be more than enough for most cases
- **OpenWebSiteWithInput-MaxOpenWebSiteInputs=** --> Use these variable to increase the maximum amount of inputs that the `OpenWebSiteWithInput` function loop will request, set this value equally or higher than the `[OpenWebSiteWithInput]` Website with the most input. Usual cases should require 2-3 inputs, but you can use as much as 10 which is the default value for this file, or increase it if you **really** need more.
- **CreateOpenFolder_X-MaxFolderSlots=100=** --> UNLIMITED FOLDERS SLOTS!! This variable will define how many loop iterations the script will do to read defined folder shortcuts from the `CreateOpenFolder_X` section below. Set this value to be equal or higher than the maximum ID defined on the `[CreateOpenFolder_X]` section.

### AHK related function shortcut example
```
NO RELATED FUNCTION DIRECTLY CALLED
```

### Code example
```
[GeneralSettings]
	WinEnvName="[HgePC]: "
	RunScriptAsAdmin="no"
	BrowsersProfiles-MaxBrowserArguments="10"
	OpenWebSiteWithInput-MaxOpenWebSiteInputs="10"
	CreateOpenFolder_X-MaxFolderSlots=100

```


[VPNSettings] section
-------------------------
Allows the user to set an IP address to be routed through a defined VPN gateway address, tested with OpenVPN so far, but the underlying function uses the `ROUTE ADD` command from Windows. For the moment it allows a singe VPN definition, and script must run in admin mode. 

**Note:** Not all newer functions have been tested running in admin mode, so if really need this function it may be best to set a separate script with this function in standalone. 

### Variables description
- **ClientIP=** --> For the moment, ClientIP is not used 
- **FQDN=** --> For the moment, FQDN is not used
- **Mask=** --> Mask for the IP address that you will add, the function was designed with individual IPs in mind (/32 IPs)
- **Gateway=** --> IP for the VPN gateway or next hop in the VPN connection to route traffic to an IP
- **VpnName=** --> Descriptive name for the VPN (current script accepts single VPN declaration)

### AHK related function shortcut example
Current function accepts one definition
```
+#c::AddIPtoRoute() ; This function will add the IP to use the VPN route
```


### Code example
```
[VPNSettings]
	ClientIP=""
	FQDN=""
	Mask="255.255.255.255"
	Gateway="10.0.0.0"
	VpnName="Super Secret VPN"
```


[BrowsersProfiles] section
-------------------------
Section to define browsers profiles that will be used by `[ShowOrRunWebSite]` and `[OpenWebSiteWithInput]` sections/fucntions to reduce repetitive code. 
`New window` and `new tag` arguments are saved on specific variables to allow more flexibility among different browsers

Define different profiles by changing the first part of the name, before the - character, **DO NOT delete the rest of the variable name**

### Variables description
- **[Default]-DefinedBrowserExe=** --> (Required) Executable file path for your browser, like `C:\Program Files\Google\Chrome\Application\chrome.exe`
- **[Default]-DefinedBrowserPath=** --> (Required) Base folder path for your browser, like `C:\Program Files\Google\Chrome\Application\` be sure to include the last \ character as well.
- **[Default]-DefinedBrowserUserProfile=** --> May be left blank for default profile, **but** check your browser's documentation for detailed commandline launch options, as no validation is done against entered value. 
   Use this if you have multiple user profiles that require launching specific websites.
- **[Default]-DefinedBrowserNewWindowArg=** --> May be left blank, refer to your browser's documentation for detailed usage
- **[Default]-DefinedBrowserNewTabArg=** --> May be left blank, refer to your browser's documentation for detailed usage
- **[Default]-DefinedBrowserArguments1=** --> (Required), if unsure, leave the default value of `""{BASE_URL_REPLACE_HERE}" "` as script will replace this placeholder with the required URL address defined later. 
  Double quotes can be used, as AHK will remove the first quotes on each side when parsing the `ini` file to the function that will run the command
- **[Default]-DefinedBrowserArguments2=** --> May be left blank, advanced users can use this to concatenate values.
  Arguments will be concatenated with no spaces, as: `Arg1+Arg2...+ArgN`. Keep this in mind when customizing the argument list
- **[Default]-DefinedBrowserArguments[N]=** --> NEW: As an enhancement to individual browser settings on previous [ShowOrRunWebSite] function, this will allow N arguments to be declared. 
  By default script will allow for 10 arguments, in numeric, ascending order. 
  Replace [N] with 2-10 or increase the `BrowsersProfiles-MaxBrowserArguments` from `[GeneralSettings]` section

### AHK related function shortcut example
```
NO RELATED FUNCTION DIRECTLY CALLED
```


### Code example
**Default Chrome browser profile**
```
[BrowsersProfiles]
	Default-DefinedBrowserExe="C:\Program Files\Google\Chrome\Application\chrome.exe"
	Default-DefinedBrowserPath="C:\Program Files\Google\Chrome\Application\"
	Default-DefinedBrowserUserProfile="--profile-directory="Default" "
	Default-DefinedBrowserNewWindowArg="--new-window "
	Default-DefinedBrowserNewTabArg=""
	Default-DefinedBrowserArguments1=""{BASE_URL_REPLACE_HERE}" "
	Default-DefinedBrowserArguments2=""
	Default-DefinedBrowserArguments3=""
``` 

**Chrome app-like profile**
```
[BrowsersProfiles]
	SlackApp-DefinedBrowserExe="C:\Program Files\Google\Chrome\Application\chrome.exe"
	SlackApp-DefinedBrowserPath="C:\Program Files\Google\Chrome\Application\"
	SlackApp-DefinedBrowserUserProfile="--profile-directory="Default" "
	SlackApp-DefinedBrowserRunAsAdmin=""
	SlackApp-DefinedBrowserNewWindowArg=""
	SlackApp-DefinedBrowserNewTabArg="--app="{BASE_URL_REPLACE_HERE}" "
	SlackApp-DefinedBrowserArguments1=""
	SlackApp-DefinedBrowserArguments2=""
	SlackApp-DefinedBrowserArguments3=""
```


[CreateOpenFolder] section
-------------------------
Variables listed here will be used by the function `ProcessFolderSlot()` at the ahk script.
This section and the associated function will be left for legacy, and maybe simplicity, but further improvements will be done on the `[CreateOpenFolder_X]` function. *(Megaman fans will relate)*

`ProcessFolderSlot()` script function will wait for a single digit key press defining the slot to use, then it will call `CreateOpenFolder()` function to open predefined folder paths or create new folder inside of them.
No need to create each of the 10 slots, however be sure to fill the three required variables when creating a slot.

**Limitations of this function**
	- Current function supports ten slots with a single digit [0-9]
	- No label to identify and folder slot easily (which `CreateOpenFolder_X` will do)

### Variables description
- **BaseFolderPath1=** --> Base folder path to open or create folders into (no need to end with back slash \)
- **LocationName1=** --> Descriptive name for location (not filling it will show the name as ERROR)
- **FolderOperation1=** --> Current supported operations are
	- *Open_Create*: Will display an input box to enter the name of the folder to create, or open it if already present.
	  No validation against invalid characters is made, so **BE WARNED**.
	- *Open_Folder*: Will open the path defined on the current slot, or if there's an already opened explorer window, it will bring it to the front.

### AHK related function shortcut example
Create one entry on the `.ahk_hotkeys` file. 
You may assign one or more calls to the same function with different key mapping, however the different folder definitions are created on the `.ini` file
```
	>+#e::ProcessFolderSlot() ; Legacy implementation of Folder slots
```


### Code example
```
[CreateOpenFolder]
	BaseFolderPath1="C:\Users\MyDocuments"
	LocationName1="Documents"
	FolderOperation1="Open_Create"

	BaseFolderPath2="C:\Users\User1\Downloads"
	LocationName2="Downloads folder"
	FolderOperation2="Open_Folder"

	# (Enter slots here)

	BaseFolderPath9=
	LocationName9=
	FolderOperation9=

	BaseFolderPath0=
	LocationName0=
	FolderOperation0=
```



[ShowOrRunProgram] section
-------------------------
Variables listed here will be used by the function `ShowOrRunProgram("PogramID")` on the `.ahk` script. PogramID can be any string, remove the brackets and make it unique to be able to map as many programs as you need to tie to key shortcuts

### Variables description
- **[ProgramID]-AhkExeName=**"" --> Program identifier, use the included `ActiveWindowInfo.ahk` script found on the AutoHotkey folder to get information of an opened window app, or refer to https://www.autohotkey.com/docs/misc/WinTitle.htm for further info.
- **[ProgramID]-AhkGroupName=**"" --> String name allowing to group program instances (can be different programs) and switching windows among them.
- **[ProgramID]-ProgramName=**"" --> Descriptive name of the program shortcut being mapped
- **[ProgramID]-CommandExe=**"" --> Path to the `.exe` file of the program
- **[ProgramID]-CommandPath=**"" --> Path to the folder of the program
- **[ProgramID]-CommandArgs=** --> Not used... yet?
- **[ProgramID]-RunAsAdmin=** --> Pending to implement RunAsAdmin option, defaults to "no"

### AHK related function shortcut example
Create one or more entries on the `.ahk_hotkeys` file. You can create one or more shortcuts to different programs and different key mappings, remember to put the same name between the parenthesis as the prefix used at the `.ini` file, like below:
```
	^#n::ShowOrRunProgram("notepad") ; Open notepad
	^#c::ShowOrRunProgram("calc") ; Open calculator
```


### Code example
```
	notepad-AhkExeName="ahk_exe notepad.exe"
	notepad-AhkGroupName="NotepadInstances"
	notepad-ProgramName="Notepad"
	notepad-CommandExe="C:\Windows\system32\notepad.exe"
	notepad-CommandPath="C:\Windows\system32\"
	notepad-CommandArgs=""
	## Pending to implement RunAsAdmin option
	notepad-RunAsAdmin="no"

	calc-AhkExeName=""
	calc-AhkGroupName=""
	calc-ProgramName=""
	calc-CommandExe=""
	calc-CommandPath=""
	calc-CommandArgs=""
	## Who wants to run Calc as admin anyways??
	calc-RunAsAdmin="no"
```


[ShowOrRunWebSite] section
-------------------------
Variables listed here will be used by the function `ShowOrRunWebSite("WebSiteID")` on the `.ahk` script. Similar to `ShowOrRunProgram()`, however it adds functionality to set different arguments for the web browser.
Double quotes can be used, as AHK will remove the first quotes on each side when parsing the ini file to the cmd function that will run the command
Default variables for opening browser windows, tested on Chrome (32/64 bits)

### Variables description
- **[ID_HERE]-BrowserExe=""** --> (Required) Executable file path for your browser, like `C:\Program Files\Google\Chrome\Application\chrome.exe`
- **[ID_HERE]-BrowserPath=""** --> (Required) Base folder path for your browser, like `C:\Program Files\Google\Chrome\Application\` be sure to include the last \ character as well.
- **[ID_HERE]-AhkSearchWindowTitle=""** --> (Required) AHK will search widows containing part of this title
- **[ID_HERE]-AhkGroupName=""** --> (Required) Matched or created windows will be grouped into this GroupName to alternate between them
- **[ID_HERE]-SiteName=""** --> (Required) Descriptive site name for the message prompts that will be displayed when invoking the AHK key shortcut. Not using it will show the word ERROR on prompts.
- **[ID_HERE]-Arguments1=""** --> (Can be empty)
  You can test the command you need to use in cmd.exe and divide it among the argument slots [1-6]
  **At least one argument is required** Arguments will be concatenated as: `Arg1+Arg2...+Arg6`
  Take this into account when setting the variables as spaces may be needed in some of them to   separate arguments while concatenating
- **[ID_HERE]-Arguments2=""** --> (Can be empty)
- **[ID_HERE]-Arguments3=""** --> (Can be empty)
- **[ID_HERE]-Arguments4=""** --> (Can be empty)
- **[ID_HERE]-Arguments5=""** --> (Can be empty)
- **[ID_HERE]-Arguments6=""** --> (Can be empty)
- **[ID_HERE]-RunAsAdmin=""** --> Run as admin (pending to implement...)

### Example values for variables
#### Paths for Chrome (defaults)
**(64 bits)**
```
	[ID_HERE]-BrowserExe="C:\Program Files\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="C:\Program Files\Google\Chrome\Application\"
```

**(32 bits)**
```
	[ID_HERE]-BrowserExe="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="C:\Program Files (x86)\Google\Chrome\Application\"
```


#### CHOOSE PROFILE DIRECTORY
```
	[ID_HERE]-Arguments1="--profile-directory="Default" " 
```
#### OPEN URL IN NEW WINDOW
```
	[ID_HERE]-Arguments1="--new-window "https//www.google.com/""
```

##### OPEN URL WITH NO BROWSER URL NOR TOOLBARS (App-like)
```
	[ID_HERE]-Arguments1="--profile-directory="Default" "
	[ID_HERE]-Arguments2="--app="https://app.website.com/client/" "
```


### AHK related function shortcut example
Create one or more entries on the `.ahk_hotkeys` file. You can create one or more shortcuts to different programs and different key mappings, remember to put the same name between the parenthesis as the prefix used at the `.ini` file, like below
```
	+#w::ShowOrRunWebSite("[ID_HERE]") ; Open website [ID_HERE]
	+#s::ShowOrRunWebSite("WebSlack") ; Slack as an app
```


### Code example
```
[ShowOrRunWebSite]
	[ID_HERE]-BrowserExe="C:\Program Files\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="C:\Program Files\Google\Chrome\Application\"
	[ID_HERE]-AhkSearchWindowTitle="Google"
	[ID_HERE]-AhkGroupName="GoogleInstances"
	[ID_HERE]-SiteName="Google search"
	[ID_HERE]-Arguments1="--profile-directory="Default" "
	[ID_HERE]-Arguments2="--new-window "https://www.google.com/""
	[ID_HERE]-Arguments3=""
	[ID_HERE]-Arguments4=""
	[ID_HERE]-Arguments5=""
	[ID_HERE]-Arguments6=""
	[ID_HERE]-RunAsAdmin="no"
```

Show as an app
```
[ShowOrRunWebSite]
	WebSlack-BrowserExe="C:\Program Files\Google\Chrome\Application\chrome.exe"
	WebSlack-BrowserPath="C:\Program Files\Google\Chrome\Application\"
	WebSlack-AhkSearchWindowTitle="Slack |"
	WebSlack-AhkGroupName="WebSlackInstances"
	WebSlack-SiteName="Slack Web App"
	WebSlack-Arguments1="--profile-directory="Default" "
	WebSlack-Arguments2="--app="https://app.slack.com/client/" "
	WebSlack-Arguments3=""
	WebSlack-Arguments4=""
	WebSlack-Arguments5=""
	WebSlack-Arguments6=""
	WebSlack-RunAsAdmin="no"
```


[OpenWebSiteWithInput] section
-------------------------
To avoid duplicating browser command info, and for simplification, `OpenWebSiteWithInput` function will use one of the declared browser profiles available at the `[Defined browsers]` section

### Variables description
- **MyWebsite-SiteName=** --> Descriptive name for the site that will be opened
- **MyWebsite-BrowserProfile=** --> ID of the Browser defined at `[Defined browsers]`, ID will be the first part entered before the **-** symbol (example, for `Default-DefinedBrowserExe` the ID would be **Default**). 
- **MyWebsite-OpenTarget=** --> Accepted values are `New_Tab` and `New_Window`, those keywords will use the proper command defined on the selected Browser profile which was defined on `[Defined browsers]` as the command would not be the same among different browsers
- **MyWebsite-AhkSearchWindowTitle=** --> Use the `DO_NOT_SEARCH` value to disable searching and focus of current similar existing windows. 
  Search will work only if the WebSite page is on an active tab on a browser window, and its title contains the set of characters defined here. that can allow to search and group pages.
- **MyWebsite-AhkGroupName=** --> Use the `DO_NOT_GROUP` along the `XXXX-AhkSearchWindowTitle` to disable searching and focus of current similar existing windows. 
  If the `MyWebsite-OpenWebSiteOperation` is `Copy_URL` it will search and focus the existing window matching this title before asking for an input and generating the URL.
- **MyWebsite-OpenWebSiteOperation=** --> Available options are `Open_Website` and `Copy_URL`
- **MyWebsite-BaseUrl=** --> URL that will be opened, you define as many placeholders as you require, these will be replaced with the inputs requested on the variables below: 
- **Input folder definition**
  The function related to `[OpenWebSiteWithInput]` will use the three variables below to request an input, then it will remove the unwanted characters defined in the RegEx expresion, and finally replace the resulting text with the placeholder present at `MyWebsite-BaseUrl` parameter which is defined on the last expression below
  
	- **MyWebsite-NameInput1=** --> Descriptive name that will be shown when requesting the input
	- **MyWebsite-RegExDeleteFromInput1=** -->  Sanitize regEx expression to **SEARCH AND DELETE** matching ocurrences from entered input. **Example:** (Case insensitive `i)` ) remove everything not being a digit, and first 0 from the entered input `"i)[^\d]|^0"`
	- **MyWebsite-RegExInsertInput1=** --> RegEx expression to **SEARCH AND REPLACE** the same text as the placeholder entered at `MyWebsite-BaseUrl` parameter. **Example:** RegEx to match the placeholder *{REPLACE_INPUT1}* present at *MyWebsite-BaseUrl* `"i)\{REPLACE_INPUT1\}"`
	  
	  For practical purposes it's named `{REPLACE_INPUTX}`, but you may use any placeholder text, as long as it is not part of the final URL and it has the same name here than on the `MyWebsite-BaseUrl` parameter


### AHK related function shortcut example
Create one or more entries on the `.ahk_hotkeys` file. You can create one or more shortcuts to different web URLs and different key mappings, remember to put the same name between the parenthesis as the prefix used at the `.ini` file, like below
```
	>+#w::OpenWebSiteWithInput("WsSend") ; Ask for mobile number, then incorporate it to WhatsApp sending message URL
```


### Code example
Use this to parse a phone number into WhatsApp send message URL, then copy it to the clipboard.
```
[OpenWebSiteWithInput]
	WsSend-SiteName="New WhatsApp message"
	WsSend-BaseUrl="https://web.whatsapp.com/send?text&app_absent=1&phone=593{REPLACE_INPUT1}"
	WsSend-AhkSearchWindowTitle="WhatsApp"
	WsSend-AhkGroupName="WSInstances"
	WsSend-OpenWebSiteOperation="Copy_URL"
	WsSend-NameInput1="Phone number"
	WsSend-RegExDeleteFromInput1="i)[^\d]|^0"
	WsSend-RegExInsertInput1="i)\{REPLACE_INPUT1\}"
```

[CreateOpenFolder_X] section
-------------------------
New implementation derived from `CreateOpenFolder` function, which will allow for an unlimited number of folder slots definition. Associated to `ProcessFolderSlot_X()` at ahk script.
Given the number of slots that can now be created, remembering the defined folder slots by numeric IDs will be a difficult task; so this function will allow to load folders definitions based on a short, easy to type label of your preference. 
Label can have a maximum length of 30 characters, and include letters, numbers, spaces, and some special characters. There is no validation on which special characters can be entered, but the recommended approach is to stick to most common ones like dashes, hyphens and such.

Pressing the hotkey that calls this function will show a tooltip next to the mouse cursor, where the entered text will be displayed. Once you enter desired ID or label, press [enter], [space], or [tab] keys to confirm the search criteria. 

If you enter a number as the first character, it will trigger the `Search by id` mode, which will load the folder slot data from the definition that has the same numeric ID as entered. If no ID exists on the `.ini` file, it will show an error message. 

If you enter letters or special characters first, it will perform the search based on `label`. This mode will allow [space] to be entered as part of the search criteria, so confirm desired text with either [enter] or [tab].

**Important:** IDs on this function do not need to be continuous, in other words, you can create a group of folder slots with `_10,_11,_12`, other one starting at `_20,_21,_22`, and another one at te 30's range without affecting the searching loop, **as long as** you increase the value of the parameter `CreateOpenFolder_X-MaxFolderSlots=` to be equal or higher than the max numeric ID that you create among all groups. This parameter is present at the `[GeneralSettings]` section.



### Variables description
Replace `XXXX` with the ID that you need, just make sure it's unique among the rest of IDs in the [CreateOpenFolder_X] section
- **BaseFolderPath_XXXX=** --> Full path to desired folder
- **LocationName_XXXX=** --> Descriptive name for folder
- **FolderLabel_XXXX=** --> Short label for quick reference (max 30 chars)
- **FolderOperation_XXXX=** --> Current supported operations are
	- *Open_Create*: Will display an input box to enter the name of the folder to create, or open it if already present
	  No validation against invalid characters is made, so BE WARNED
	- *Open_Folder*: Will open the path defined on the current slot, or if there's an already opened explorer window, it will bring it to the front.

### AHK related function shortcut example
Create one entry on the `.ahk_hotkeys` file. 
You may assign one or more calls to the same function with different key mapping, however the different folder definitions are created on the `.ini` file
```
	+#e::ProcessFolderSlot_X() ; NEW, Mega, unlimited folder slots implementation ^_^
```


### Code example
```
[CreateOpenFolder_X]
	Folder slots for ProcessFolderSlot_X function
	BaseFolderPath_1="C:\Users\superuser\Documents\logs"
	LocationName_1="User logs folder"
	FolderLabel_1="user"
	FolderOperation_1="Open_Create"

	BaseFolderPath_3="C:\Users\superuser\Music"
	LocationName_3="Music folder"
	FolderLabel_3="do re mi"
	FolderOperation_3="Open_Folder"

	BaseFolderPath_14="C:\Users\superuser\Documents"
	LocationName_14="Documents folder"
	FolderLabel_14="Docs"
	FolderOperation_14="Open_Folder"

	BaseFolderPath_25="C:\Users\superuser\Downloads"
	LocationName_25="Downloads folder"
	FolderLabel_25="DWNLDS"
	FolderOperation_25="Open_Folder"
```


Additional functions
-------------------------
Some short functions that provide useful functionality are defined on the `ahk_hotkeys` file directly, please refer to the `HgeScripts.ahk_hotkeys.example.txt` file to see these small functions that are right below the AHK shortcut. 
