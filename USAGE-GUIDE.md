HgeScripts .ini file guide
==========================
The purpose of this AHK script is to automate common tasks as much as possible, in a simple way (once you set your *ini* file properly, that is).
Despite that goal, initial setup may be complex for some, at least at the beginning. 

This guide will separate explaining from base example.ini file in order to make it as clear and as detailed as possible, with easy-to-read markdown formatting. 

Code will be put in blocks, so after reading the explaining, you can copy-paste the full block into your own *.ini* file


Additional functions
-------------------------
Some short functions that provide useful functionality are defined on the `ahk_hotkeys` file directly, please refer to the `HgeScripts.ahk_hotkeys.example.txt` file to see these small functions that are right below the AHK shortcut. 

## Script-Wide special placeholder variables
With the purpose of adding more flexibility and reduce `.ini` file parameter modification, dynamic variables have been define which can be used on the .ini files, the script will replace these special placeholder variables with the values they represent, allowing functions to be even more versatile! 

**Note:** Dynamic placeholder variables is a relatively implementation on this AHK script, so not all functions are yet refactored to make use of them. Once a function or their respective set of ini parameters accept dynamic placeholders, it will contain the wording `; <== {PLACEHOLDER VARIABLE ENABLED} ==>`. 
This document will also be updated to reflect such enhancement.
### List of custom placeholder variables
These variables are named similarly to the AHK standard ones, to keep consistency among them, newer script updates may include more variables to improve parameter reuse among ini files. 
- `{A_Week_of_year}` Week of the year, equals A_Week_of_year := SubStr(A_YWeek, -1). According to AHK: If the week containing January 1st has four or more days in the new year, A_YWeek is considered week 1. Otherwise, A_YWeek is the last week of the previous year, and the next week is week 1.
- `{A_DATE_NOW}` --> Current date formatted like YYYY-MM-DD
- `{A_TIME_NOW}` --> Current 2-digit HH.mm.ss (00-23) in 24-hour time (for example, 17:00:01), since this will be used for file creation, : was replaced by a dot .
- `{A_12HourAM_PM}` --> Current 2-digit HH.mm.ss (00-12) in 12-hour time (for example, 05:00:01 pm). Since this may be used for file creation, : was replaced by a dot .
- `{A_YDay0}` --> A_YDay value but zero-padded, e.g. 9 is retrieved as 009.
### List of AHK-equivalent placeholder variables
For more information of how AutohotKey treats these variables refer to this link: https://www.autohotkey.com/docs/v1/Variables.htm#date
- `{A_YYYY}` or `{A_Year}` --> Current 4-digit year (e.g. 2004)
- `{A_MM}` or `{A_Mon}` --> Current 2-digit month (01-12)
- `{A_DD}` or `{A_MDay}` --> Current 2-digit day of the month (01-31)
- `{A_MMMM}` --> Current month's full name in the current user's language, e.g. July
- `{A_MMM}` --> Current month's abbreviation in the current user's language, e.g. Jul
- `{A_DDDD}` --> Current day of the week's full name in the current user's language, e.g. Sunday
- `{A_DDD}` --> Current day of the week's abbreviation in the current user's language, e.g. Sun
- `{A_WDay}` --> Current 1-digit day of the week (1-7). 1 is Sunday in all locales.
- `{A_YDay}` --> Current day of the year (1-366) withoud zero-padding. 
- `{A_YWeek}` --> Current year and week number (e.g. 200453) according to ISO 8601.
- `{A_Hour}` --> Current 2-digit hour (00-23) in 24-hour time (for example, 17 is 5pm).
- `{A_Min}` Current 2-digit minute (00-59).
- `{A_Sec}` --> Current 2-digit second (00-59).
- `{A_MSec}` --> Current 3-digit millisecond (000-999). To remove the leading zeros, follow this example: Milliseconds := A_MSec + 0.
- `{A_Now}` --> The current local time in YYYYMMDDHH24MISS format.

### Path placeholder variables
After all the script functions accepted placeholder variables, these path placeholders were added to make the `.ini` file setup easier, by replacing just a single occurrence of a repetitive path and this will be used by every other parameter that contains one of these placeholder variables. 

AHK won't recognize `\\network-mapped\paths` directly, so if you need to open a network share, set it first as a local network mapped unit

Created placeholders for this purpose are: 
- `A_MyDocuments_Path` --> Path to MyDocuments folder, or any folder you save your documents to
- `A_Downloads_Path` --> Path to Downloads folder, can be set to custom path if needed
- `A_ProgramFiles_Path` --> Path to Program files folder for 64 bit programs
- `A_ProgramFiles_x86_Path` --> Path to program files for 32 bit programs
- `A_UserFolder_Path` --> Path to the local user directory
- `A_User_Defined_Path_1` to `A_User_Defined_Path_12` --> Custom paths that can be defined with frequent used directories

If needed script user can create more paths under the `ReplacePlaceholderStrings()` function by following the same logic as path placeholder variables above. 

[GeneralSettings] section
-------------------------
Like the name states, it will include values for global variables that will affect other parts of the script, or that are general limits or configuration parameters for the script operation. 

### Variables description
- **WinEnvName=** --> Descriptive name for this script instance, internal logic *may* allow to run several copies of the same script with different `ahk` and its associated `ini` and `ahk_hotkeys` files names. **NOT TESTED
  **
- **RunScriptAsAdmin=** --> Run script as admin user.- This is needed for the `VPN add route` function to work correctly, if you're not going to use that function, leave the default `no` as value. This ws added to fix an issue #020
  
- **BrowsersProfiles-MaxBrowserArguments=** --> Use these variable to increase the amount of arguments the `ShowOpenWebSiteWithInput` function loop will read, Default value of 10 should be more than enough for most cases
  
- **ShowOpenWebSiteWithInput-MaxOpenWebSiteInputs=** --> Use these variable to increase the maximum amount of inputs that the `ShowOpenWebSiteWithInput` function loop will request, set this value equally or higher than the `[ShowOpenWebSiteWithInput]` Website with the most input. Usual cases should require 2-3 inputs, but you can use as much as 10 which is the default value for this file, or increase it if you **really** need more.
  
- **CreateOpenFolder_X-MaxFolderSlots=100** --> UNLIMITED FOLDERS SLOTS!! This variable will define how many loop iterations the script will do to read defined folder shortcuts from the `CreateOpenFolder_X` section below. Set this value to be equal or higher than the maximum ID defined on the `[CreateOpenFolder_X]` section.
  
- **CreateOpenFolder_X-MaxOpenCreateFolderAndFileInputs=10** --> This variable will define the loop iterations that the new `Open_Create_Folder_And_File` mode of the `ProcessFolderSlot_X()` function will do. If you need to accept more than 10 inputs for either filename or folder path under this mode, increase this number. Unlike folder slots, the numeric ID for the inputs, need to be sequential, since they are related to a particular folder slot. More on how to use this under the specific function, later on this document. 
  
- **RegExReplaceText_X-MaxReplaceTextSlots=100** --> Unlimited slots as well! Similarly to the folder slots, this variable will define how many loop iterations the script will do to read defined folder shortcuts from the `RegExReplaceText_X` section below. Set this value to be equal or higher than the maximum ID defined on the `[RegExReplaceText_X]` section.
  
- **BrowsersProfile-DefaultProfile="Default"** --> This variable will be used to determine the default browser that the `ShowOpenWebSiteWithInput()` will use if not defined on that section. Define as many required browser profiles as needed under the `[BrowsersProfiles]` section on the `ini` file.

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
	ShowOpenWebSiteWithInput-MaxOpenWebSiteInputs="10"
	CreateOpenFolder_X-MaxFolderSlots=100
	CreateOpenFolder_X-MaxOpenCreateFolderAndFileInputs="10"
	RegExReplaceText_X-MaxReplaceTextSlots=100
	BrowsersProfile-DefaultProfile="Hge"
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
<== {PLACEHOLDER VARIABLE ENABLED} ==>
Section to define browsers profiles that will be used by `[ShowOrRunWebSite]` and `[ShowOpenWebSiteWithInput]` sections/fucntions to reduce repetitive code. 
`New window` and `new tag` arguments are saved on specific variables to allow more flexibility among different browsers

Define different profiles by changing the first part of the name, before the `-` character, **Remove [] brackets and DO NOT delete the rest of the variable name**

### Variables description
Now this function is . 

- **[Default]-DefinedBrowserExe=** (Required) --> Executable file path for your browser, like `C:\Program Files\Google\Chrome\Application\chrome.exe` 
   This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[Default]-DefinedBrowserPath=** (Required) --> Base folder path for your browser, like `C:\Program Files\Google\Chrome\Application\` be sure to include the last \ character as well.
   This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[Default]-DefinedBrowserUserProfile=** --> May be left blank for default profile, **but** check your browser's documentation for detailed commandline launch options, as no validation is done against entered value. 
   Use this if you have multiple user profiles that require launching specific websites.
   
- **[Default]-DefinedBrowserNewWindowArg=** --> May be left blank, refer to your browser's documentation for detailed usage
  
- **[Default]-DefinedBrowserNewTabArg=** --> May be left blank, refer to your browser's documentation for detailed usage
  
- **[Default]-DefinedBrowserArguments1=** (Required),-->  if unsure, leave the default value of `""{BASE_URL_REPLACE_HERE}" "` as script will replace this placeholder with the required URL address defined later. 
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
	Default-DefinedBrowserExe="{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe"
	Default-DefinedBrowserPath="{A_ProgramFiles_Path}\Google\Chrome\Application\"
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
	SlackApp-DefinedBrowserExe="{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe"
	SlackApp-DefinedBrowserPath="{A_ProgramFiles_Path}\Google\Chrome\Application\"
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
**Update:** This function is deprecated and remains for legacy usage, use the [CreateOpenFolder_X] function that is defined later on this guide.

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
<== {PLACEHOLDER VARIABLE ENABLED} ==>
Variables listed here will be used by the function `ShowOrRunProgram("PogramID")` on the `.ahk` script. PogramID can be any string, remove the brackets and make it unique to be able to map as many programs as you need to tie to key shortcuts. 

You can also specify a full document or file path to open a specific file under the OS default defined program for that file extension. Hotkey will focus this program based on the `AhkExeName` criteria defined. 

### Variables description
- **[ProgramID]-AhkExeName=**"" --> Program identifier, use the included `ActiveWindowInfo.ahk` script found on the AutoHotkey folder to get information of an opened window app, or refer to https://www.autohotkey.com/docs/misc/WinTitle.htm for further info.
 This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
     
- **[ProgramID]-AhkGroupName=**"" --> String name allowing to group program instances (can be different programs) and switching windows among them.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[ProgramID]-ProgramName=**"" --> Descriptive name of the program shortcut being mapped
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[ProgramID]-CommandExe=**"" --> Path to the `.exe` file of the program
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[ProgramID]-CommandPath=**"" --> Path to the folder of the program
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`
  
- **[ProgramID]-CommandArgs=** --> Not used... yet?
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`. However not practical usage scenario has been needed yet.
  
- **[ProgramID]-RunAsAdmin=** --> Pending to implement RunAsAdmin option, defaults to "no"

### AHK related function shortcut example
Create one or more entries on the `.ahk_hotkeys` file. You can create one or more shortcuts to different programs and different key mappings, remember to put the same name between the parenthesis as the prefix used at the `.ini` file, like below:
```
	^#n::ShowOrRunProgram("notepad") ; Open notepad
	^#c::ShowOrRunProgram("calc") ; Open calculator
```


### Code example
Use `##` or `;` for comments on ini files 
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
<== {PLACEHOLDER VARIABLE ENABLED} ==>
**UPDATE:** This function will get deprecated, and is being replaced by the `ShowOpenWebSiteWithInput()` function and sections. 
Eventually this function and its related documentation will get removed from this guide.

Variables listed here will be used by the function `ShowOrRunWebSite("WebSiteID")` on the `.ahk` script. Similar to `ShowOrRunProgram()`, however it adds functionality to set different arguments for the web browser.
Double quotes can be used, as AHK will remove the first quotes on each side when parsing the ini file to the cmd function that will run the command
Default variables for opening browser windows, tested on Chrome (32/64 bits)

### Variables description
- **[ID_HERE]-BrowserExe=""** (Required) --> Executable file path for your browser, like `C:\Program Files\Google\Chrome\Application\chrome.exe` 
  or a placeholder variable like `{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe`
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-BrowserPath=""** (Required) --> Base folder path for your browser, like `C:\Program Files\Google\Chrome\Application\` be sure to include the last \ character as well.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-AhkSearchWindowTitle=""** (Required) --> AHK will search widows containing part of this title, you can also specify an `ahk app.exe` search pattern, though usage scenarios may be limited to opening a new browser if no window is present 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-AhkGroupName=""** (Required) --> Matched or created windows will be grouped into this GroupName to alternate between them
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-SiteName=""** (Required) --> Descriptive site name for the message prompts that will be displayed when invoking the AHK key shortcut. Not using it will show the word ERROR on prompts.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-Arguments1=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

  You can test the command you need to use in cmd.exe and divide it among the argument slots [1-6]
  **At least one argument is required** Arguments will be concatenated as: `Arg1+Arg2...+Arg6`
  Take this into account when setting the variables as spaces may be needed in some of them to   separate arguments while concatenating
- **[ID_HERE]-Arguments2=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-Arguments3=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-Arguments4=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-Arguments5=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-Arguments6=""** (Can be empty) --> 
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **[ID_HERE]-RunAsAdmin=""** --> Run as admin (pending to implement...)
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`


### Example values for variables
#### Paths for Chrome (defaults)
**(64 bits)**
```
	[ID_HERE]-BrowserExe="{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="{A_ProgramFiles_Path}\Google\Chrome\Application\"
```

**(32 bits)**
```
	[ID_HERE]-BrowserExe="{A_ProgramFiles_x86_Path}\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="{A_ProgramFiles_x86_Path}\Google\Chrome\Application\"
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
	[ID_HERE]-BrowserExe="{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe"
	[ID_HERE]-BrowserPath="{A_ProgramFiles_Path}\Google\Chrome\Application\"
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
	WebSlack-BrowserExe="{A_ProgramFiles_Path}\Google\Chrome\Application\chrome.exe"
	WebSlack-BrowserPath="{A_ProgramFiles_Path}\Google\Chrome\Application\"
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


[ShowOpenWebSiteWithInput] section
-------------------------
<== {PLACEHOLDER VARIABLE ENABLED} ==>
This function is an enhancement of previous `ShowOrRunWebSite()` function, which allows to enter inputs in order to incorporate them in the final website URL. 
It was refactored to avoid duplicating browser command info; for simplification, `ShowOpenWebSiteWithInput` function will use one of the declared browser profiles available at the `[Defined browsers]` section. 

If you do not need to open a WebSite requesting inputs, just omit those entries at the `.ini` file entry and it will open the website with the defined BaseUrl

### Variables description
- **MyWebsite-SiteName=** (required) --> Descriptive name for the site that will be opened
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **MyWebsite-BrowserProfile=** (optional) --> ID of the Browser defined at `[Defined browsers]`, ID will be the first part entered before the **-** symbol (example, for `Default-DefinedBrowserExe` the ID would be **Default**). If this parameter is not set here, it will use the value from the parameter `BrowsersProfile-DefaultProfile` defined at the `[GeneralSettings]` section.
	
- **MyWebsite-OpenTarget=** (optional) --> Accepted values are `New_Tab` and `New_Window`, those keywords will use the proper command defined on the selected Browser profile which was defined on `[Defined browsers]` as the command would not be the same among different browsers. If not set, it will take the default value of `New_Tab`.

- **MyWebsite-AhkSearchWindowTitle=** (optional) --> If not defined it will take the default value of `DO_NOT_SEARCH` which will disable searching and focus of current similar existing windows. 
  Search will work only if the WebSite page is on an active tab on a browser window, and its title contains the set of characters defined here. that can allow to search and group pages.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **MyWebsite-AhkGroupName=** (optional) --> If not defined it will take the default value of `DO_NOT_GROUP`. This default value along the `XXXX-AhkSearchWindowTitle` will disable searching and focus of current similar existing windows.
  If the `MyWebsite-OpenWebSiteOperation` is `Copy_URL` it will search and focus the existing window matching this title before asking for an input and generating the URL.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **MyWebsite-OpenWebSiteOperation=** (required) --> Available options are `Open_Website` and `Copy_URL`

- **MyWebsite-BaseUrl=** (required) --> URL that will be opened, you define as many placeholders as you require, these will be replaced with the inputs requested on the variables below: 

- **Input variables definition**
  The function related to `[ShowOpenWebSiteWithInput]` will use the three variables below to request an input, then it will remove the unwanted characters defined in the RegEx expression, and finally replace the resulting text with the placeholder present at `MyWebsite-BaseUrl` parameter which is defined on the last expression below
  You can declare a WebSite with no inputs, but if you need to request 1 or more input, each of them requires to have the 3 parameters listed below, replace 1 with an increasing, continuous number.

	- **MyWebsite-NameInput1=** --> Descriptive name that will be shown when requesting the input
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

	- **MyWebsite-RegExDeleteFromInput1=** -->  Sanitize regEx expression to **SEARCH AND DELETE** matching ocurrences from entered input. **Example:** (Case insensitive `i)` ) remove everything not being a digit, and first 0 from the entered input `"i)[^\d]|^0"`

	- **MyWebsite-RegExInsertInput1=** --> RegEx expression to **SEARCH AND REPLACE** the same text as the placeholder entered at `MyWebsite-BaseUrl` parameter. **Example:** RegEx to match the placeholder *{REPLACE_INPUT1}* present at *MyWebsite-BaseUrl* `"i)\{REPLACE_INPUT1\}"`
	  
	  For practical purposes it's named `{REPLACE_INPUTX}`, but you may use any placeholder text, as long as it is not part of the final URL and it has the same name here than on the `MyWebsite-BaseUrl` parameter


### AHK related function shortcut example
Create one or more entries on the `.ahk_hotkeys` file. You can create one or more shortcuts to different web URLs and different key mappings, remember to put the same name between the parenthesis as the prefix used at the `.ini` file, like below
```
	>+#w::ShowOpenWebSiteWithInput("WsSend") ; Ask for mobile number, then incorporate it to WhatsApp sending message URL
```


### Code example
Use this to parse a phone number into WhatsApp send message URL, then copy it to the clipboard.
```
[ShowOpenWebSiteWithInput]
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
<== {PLACEHOLDER VARIABLE ENABLED} ==>
New implementation derived from `CreateOpenFolder()` function, which will allow for an unlimited number of folder slots definition. Associated to `ProcessFolderSlot_X()` at ahk script.

Given the number of slots that can now be created, remembering the defined folder slots by numeric IDs will be a difficult task; so this function will allow to load folders definitions based on a short, easy to type *label* of your preference.  A *label* can have a maximum length of 30 characters, and include letters, numbers, spaces, and some special characters. There is no validation on which special characters can be entered, but the recommended approach is to stick to most common ones like dashes, hyphens and such.

Pressing the hotkey that calls this function will show a tooltip next to the mouse cursor, where the entered text will be displayed. Once you enter desired ID or label, press [enter], [space], or [tab] keys to confirm the search criteria. 

**NEW:** Optionally you can create a hotkey shortcut with the ID or label to call a specific slot directly, like this: `ProcessFolderSlot_X(numeric_ID)` or with the label, `ProcessFolderSlot_X("Label")`

**NEW:** Additional operation mode `Open_Create_Folder_And_File` was created and new custom parameters will allow to create a file inside the folder

If you enter a number as the first character, it will trigger the `Search by id` mode, which will load the folder slot data from the definition that has the same numeric ID as entered. If no ID exists on the `.ini` file, it will show an error message. 

If you enter letters or special characters first, it will perform the search based on `label`. This mode will allow [space] to be entered as part of the search criteria, so confirm desired text with either [enter] or [tab].

**Important:** IDs on this function do not need to be continuous, but they need to start with a number greater than 0, in other words, you can create a group of folder slots with `_10,_11,_12`, other one starting at `_20,_21,_22`, and another one at te 30's range without affecting the searching loop, **as long as** you increase the value of the parameter `CreateOpenFolder_X-MaxFolderSlots=` to be equal or higher than the max numeric ID that you create among all groups. This parameter is present at the `[GeneralSettings]` section.


### Variables description
Replace `XXXX` with the ID that you need, just make sure it's unique among the rest of IDs in the [CreateOpenFolder_X] section
- **BaseFolderPath_XXXX=** --> Full path to desired folder. AHK won't recognize `\\network-mapped\paths` directly, so if you need to open a network share, set it first as a local network mapped unit
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **LocationName_XXXX=** --> Descriptive name for folder

- **FolderLabel_XXXX=** --> Short label for quick reference (max 30 chars)

- **FolderOperation_XXXX=** --> Current supported operations are
	- *Open_Create*: Will display an input box to enter the name of the folder to create, or open it if already present
	  No validation against invalid characters is made, so BE WARNED

	- *Open_Folder*: Will open the path defined on the current slot, or if there's an already opened explorer window, it will bring it to the front.

#### Variables used under `Open_Create_Folder_And_File` mode
In addition to the .ini file parameters used above, this mode will allow you to request as many input fields as required and place them in placeholder variables to create more flexible file names and paths as desired. 

Before listing all the possible variables, we'll describe the **NEW: variable input parameters** approach for this operation mode, this may be implemented on other functions as well. 

For now, the `Open_Create_Folder_And_File` mode will allow you to request any number of inputs to assign them to placeholder values on the *VariableFolderPath_XXXX* or the filename to be used. 

Dynamic input parameters will use the following parameters, the three of them need to be created altogether for each input you need to request:
  1. Request the inputs named with the `ZZZZZZ-NameInputY_XXXX` parameter

  2. Then perform a RegEX deletion rule determined by `ZZZZZZ-RegExDeleteFromInputY_XXXX` 

  3. And finally insert the sanitized text based on the RegEx insertion rule set up by `ZZZZZZ-RegExInsertInputY_XXXX` which is the rule to replace the {Placeholder_X} variable or variables on the *VariableFolderPath_XXXX* parameter


On the three parameters mentioned above, the **NameInput**, **RegExDeleteFromInput**, and **RegExInsertInput** text need to remain equal on every input, to keep compliance with the logic of the AHK script. The variable portions of the names are described by the following parts: 
- **ZZZZZ-** is the `Folder-` or `File-` prefix to tell the script to parse the input and their rules for the folder path or filename parts. 

- **Y** is a sequential integer number that the script will use for the loop. It needs to begin in 1 and you can create as many continuous entries for each input that you need. Just remember that the three parameters **NameInput**, **RegExDeleteFromInput**, and **RegExInsertInput** need to have the same number for the script logic to work. 

- **\_XXXX** is the *FolderSlotID* that `CreateOpenFolder_X` uses to differentiate each slot.

If no inputs are needed, don't declare any of the following three parameters listed above, but if you need to request an input, create a new set of the three parameters above replacing the `Y` before `_XXXX` by 1, 2, 3, 4 and so on.

In this example we'll be using `"{REPLACE_INPUT1}"` as the *VariablePath* placeholder and the RegEx rule `"i)\{REPLACE_INPUT1\}"` which will replace the placeholder with the requested input. The `i)` is AutoHotkey way to tell RegEx to be case insensitive, the rest is perl-base RegEx

For convenience we use `{REPLACE_INPUTxxx}` but as long as you keep your RegExs in check, you can use virtually any place holders, just make sure you set different placeholders for the different inputs that you create. 

**The variables needed are listed below**
- **Folder-VariableFolderPath_XXXX=** --> Add the rest of the path on this parameter, you can use special placeholders like `{REPLACE_INPUT1}` to generate more dynamic folder paths, the script will create all the parent directories that are needed by the combination of the *BaseFolderPath_XXXX* parameter and this *Folder-VariableFolderPath_XXXX* folder path parameter
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **Folder-NameInput1_XXXX=** --> Name that the input field will show when requested. If you need that the script requests additional inputs, create another entry and replace the 1 before the `_XXXX` by 2, and so on.

- **Folder-RegExDeleteFromInput1_XXXX=** --> May be empty, but parameter line needs to be present. 
  Perl-based RegEx rule to delete unwanted characters from the input, for example, you paste a text in the input field with a format like 123-456-7890 but you need only the numbers, this rule can take care of that for you, optimizing your input time. 
  This parameter is tied to the NameInput1 above, so if you create a 2nd input, create a new line like this one replacing the 1_ before `_XXXX` by 2. Also remember that `_XXXX` belongs to the **numeric ID** of the FolderSlot

- **Folder-RegExInsertInput1_XXXX=** --> This Perl-based RegEx rule will tell the script where to place the entered input along the Folder-VariableFolderPath. 
  This parameter is tied to the NameInput1 above as well.

Similar to **Folder-** dynamic inputs, you can request inputs to use for the filename under the `Open_Create_Folder_And_File` mode. Just use the `File-` prefix to tell the AHK script that this part will be used for the filename portion. These parameters follow the same logic of they **Folder-** counterparts
- **File-CreateWithName_XXXX=** --> Name of the created file, it can be a fixed name or you can place dynamic placeholders like `{REPLACE_INPUT1}` and request inputs similarly to the folder path variables above.
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **File-NameInput1_XXXX=** --> Name that the input field will show when requested. Works similar to the *Folder-* counterpart.

- **File-RegExDeleteFromInput1_XXXX=** --> May be empty. , but parameter line needs to be present. 
  Perl-based RegEx rule to delete unwanted characters from the input, or insert them, optimizing your input time. This parameter is tied to the NameInput1 above. Remember that `_XXXX` belongs to the numeric ID of the FolderSlot

- **File-RegExInsertInput1_XXXX=** --> This Perl-based RegEx rule will tell the script where to place the entered input along the `File-CreateWithName`. 

**Optional base file content adding**
You can also add some base content to the file at the moment ot its creation. Similarly to the looped index values above, you can create as many lines as needed, as long as they have a continuous numeric sequence. Each parameter line will insert a line break, however you can place additional line breaks within each parameter by using the placeholder `\n`.  Markdown will treat single backslash like invisible character, but the `.ini` file won't so please use one.

These parameters are `<== {PLACEHOLDER VARIABLE ENABLED} ==>`, they will be detailed at the [Script-Wide special placeholder variables] section on the USAGE-GUIDE document 

- **File-CreateWithContents1_XXXX=** --> "File created at: {A_DATE_NOW}"
- **File-CreateWithContents2_XXXX=** --> "# CASE: "
- **File-CreateWithContents3_XXXX=** --> ""
- **File-CreateWithContents4_XXXX=** --> "Document ID:"
- **File-CreateWithContents5_XXXX=** --> "Credits:"
- **File-CreateWithContents6_XXXX=** --> "Public name:"
- **File-CreateWithContents7_XXXX=** --> "\n\n\n"
- **File-CreateWithContents8_XXXX=** --> "Other info:"
- **File-CreateWithContents9_XXXX=** --> ""

### AHK related function shortcut example
Create one entry on the `.ahk_hotkeys` file. 
You may assign one or more calls to the same function with different key mapping, however the different folder definitions are created on the `.ini` file
```
+#e::ProcessFolderSlot_X()
; Label direct call for folderSlot
+#e::ProcessFolderSlot_X("SNG")
; Numeric ID direct call for folderSlot
+#e::ProcessFolderSlot(11)
```


### Code example
```
[CreateOpenFolder_X]
	Folder slots for ProcessFolderSlot_X function
	BaseFolderPath_1="{A_MyDocuments_Path}\logs"
	LocationName_1="User logs folder"
	FolderLabel_1="user"
	FolderOperation_1="Open_Create"

	BaseFolderPath_3="{A_UserFolder_Path}\Music"
	LocationName_3="Music folder"
	FolderLabel_3="do re mi"
	FolderOperation_3="Open_Folder"

	BaseFolderPath_14="{A_MyDocuments_Path}"
	LocationName_14="Documents folder"
	FolderLabel_14="Docs"
	FolderOperation_14="Open_Folder"

	BaseFolderPath_25="{A_Downloads_Path}"
	LocationName_25="Downloads folder"
	FolderLabel_25="DWNLDS"
	FolderOperation_25="Open_Folder"
```


### Code example with new `Open_Create_Folder_And_File` mode
```
[CreateOpenFolder_X]
	BaseFolderPath_1="C:\Documents"
	LocationName_1="Personal documents folder"
	FolderLabel_1="docs"
	FolderOperation_1="Open_Create_Folder_And_File"
	
; This convention may be a little different, create as many inputs as needed in the following format and without [] brackets
; Folder-NameInput[input_loop_index]_[FolderSlot ID]

; VariableFolderPath_XXXX will contain the placeholders that RegEX rules will replace, or the wide placeholders defined under the 
; [Script-Wide placeholder variables] section 
	VariableFolderPath_1="Tickets\test{REPLACE_INPUT1}\{REPLACE_INPUT2}"

; Folder Input 1 and its RegEx rules, if not needed, comment thre lines below
Folder-NameInput1_1="Document number"
Folder-RegExDeleteFromInput1_1="i)[^\d]|^0"
Folder-RegExInsertInput1_1="i)\{REPLACE_INPUT1\}"

; Folder Input 2 and its RegEx rules, if not needed, comment thre lines below
Folder-NameInput2_1="Second number"
Folder-RegExDeleteFromInput2_1="i)[^\d]|^0"
Folder-RegExInsertInput2_1="i)\{REPLACE_INPUT2\}"
	
; Same approach for FileName, create as many inputs as desired with the three fields
; File-CreateWithName_XXXX will contain the placeholders that RegEX rules will replace, or the wide placeholders defined under the 
; [Script-Wide special placeholder variables] section on the USAGE-GUIDE document
File-CreateWithName_1="{FILE_REPLACE_INPUT1}-{FILE_REPLACE_INPUT2}Case notes.md"
; File-NameInput[input_loop_index]_[SLOT ID]

; File Input 1 and its RegEx rules
	File-NameInput1_1="File number"
	File-RegExDeleteFromInput1_1="i)[^\d]|^0"
	File-RegExInsertInput1_1="i)\{FILE_REPLACE_INPUT1\}"

; File Input 2 and its RegEx rules
	File-NameInput2_1="File number"
	File-RegExDeleteFromInput2_1="i)[^\d]|^0"
	File-RegExInsertInput2_1="i)\{FILE_REPLACE_INPUT2\}"
	
; (OPTIONAL) Create contents for this file, this will allow to create virtually unlimited lines in a file, 
; each line goes in a variable with the format File-CreateWithContents[loop_index]_[SLOT ID]
	File-CreateWithContents1_1="File created at: {A_DATE_NOW}"
	File-CreateWithContents2_1="# CASE: "
	File-CreateWithContents3_1=""
	File-CreateWithContents4_1="Deployment ID:"
	File-CreateWithContents5_1="Support credits:"
	File-CreateWithContents6_1="Public IP:"
	File-CreateWithContents7_1=""
	File-CreateWithContents8_1="VPN IP:"
	File-CreateWithContents9_1=""
```

[RegExReplaceText_X] section
-------------------------
New implementation to allow to create several slots to replace text. 
Similar in mechanics to the `ProcessFolderSlot_X()` function at ahk script.

The numeric ID of the entries that you define under the `ini` file can be used, or the short text label of your preference. 
Label can have a maximum length of 30 characters, and include letters, numbers, spaces, and some special characters. There is no validation on which special characters can be entered, but the recommended approach is to stick to most common ones like dashes, hyphens and such.

Pressing the hotkey defined on the `ahk_hotkeys` file will show a tooltip next to the mouse cursor, where the entered text will be displayed. Once you enter desired ID or label, press [enter], [space], or [tab] keys to confirm the search criteria. 

NEW: Optionally you can create a hotkey shortcut with the ID or label to call a specific slot directly, like this: `RegExReplaceText_X(numeric_ID)` or with the label, `RegExReplaceText_X("Label")`

Similarly to `ProcessFolderSlot_X()` function, if you enter a number as the first character, it will trigger the `Search by id` mode, which will load the ReplaceText slot data from the definition that has the same numeric ID as entered. If no ID exists on the `.ini` file, it will show an error message. 

If you enter letters or special characters first, it will perform the search based on `label`. This mode will allow `[space]` to be entered as part of the search criteria, so confirm desired text with either `[enter]` or `[tab]`.

**Important:** IDs on this function do not need to be continuous, however they need to start with a digit greater than 0; in other words, you can create a group of slots with `_10,_11,_12`, other one starting at `_20,_21,_22`, and another one at the 30's range without affecting the searching loop, **as long as** you increase the value of the parameter `RegExReplaceText_X-MaxReplaceTextSlots=` to be equal or higher than the max numeric ID that you create among all groups. This parameter is present at the `[GeneralSettings]` section.


### Variables description
Replace `XXXX` with the ID that you need, just make sure it's unique among the rest of IDs in the [RegExReplaceText_X] section
- **ReplaceTextName_XXXX=** --> Required, short name for this RegEx expresion, maybe use something that reminds you what text this slot will replace

- **ReplaceTextDescription_XXXX=** --> Full description of what this RegEx will do, this is optional, but this will be shown on the prompt for entering the value, so enter something useful

- **ReplaceTextLabel_XXXX=** --> Short label for quick reference (max 30 chars)

- **ReplaceTextRegExString_XXXX=** --> Perl-compatible regular expression to search text on the string that will be prompted via input box, for additional reference view the documentation of the used function at https://www.autohotkey.com/docs/v1/lib/RegExMatch.htm

- **ReplaceTextReplaceString_XXXX=** --> RegEx replace mode syntax, it can empty ("") and it will remove matching text, or you can use PERL-like variables for search groups like $1 $n
	  All validation against invalid characters is done via RegEx, so test this before on a site like https://regexr.com/ making sure it works correctly
  This parameter is `<== {PLACEHOLDER VARIABLE ENABLED} ==>`

- **ReplaceTextOperation_XXXX=** --> Current supported operations are
	- *Copy_to_clipboard*: Will send the RegEx sanitized text to the clipboard. 
	- *Simulate_Typing*: As soon as the input box dissapears, it will simulate key typing into the last focused window, there may not really be too many usage cases for this particular mode.


### AHK related function shortcut example
Create one entry on the `.ahk_hotkeys` file. 
You may assign one or more calls to the same function with different key mapping, however the different folder definitions are created on the `.ini` file
```
	+#r::RegExReplaceText_X() ; RegEx-based ReplaceText slots
	+#r::RegExReplaceText_X(10) ; Call a direct ReplaceText slot by it's numeric ID
	+#r::RegExReplaceText_X("MAC") ; Call a direct ReplaceText slot by it's ReplaceTextLabel_ field
```


### Code example
```
[RegExReplaceText_X]
	ReplaceTextName_10="MAC with colons"
	ReplaceTextDescription_10="MAC format replace, xxxxx to xx:xx:xx"
	ReplaceTextLabel_10="MAC"
	# ReplaceTextRegExString_10 is a RegEx string to search, THIS IS REQUIRED
	ReplaceTextRegExString_10="(?<!^.)(..)(?=[^$])"
	# ReplaceTextReplaceString can be EMPTY, it will remove matched characters
	ReplaceTextReplaceString_10="$1:"
	# SELECT ONE OPTION BELOW, ONLY USE THESE TWO VALUES
	ReplaceTextOperation_10="Copy_to_clipboard"
	ReplaceTextOperation_10="Simulate_Typing"


	ReplaceTextName_11="MAC with NO colons"
	ReplaceTextDescription_11="MAC format replace, xx:xx:xx to xxxxx"
	ReplaceTextLabel_11="ALPHA"
	ReplaceTextRegExString_11="[:.\s\-]"
	ReplaceTextReplaceString_11=""
	ReplaceTextOperation_11="Copy_to_clipboard"
```

