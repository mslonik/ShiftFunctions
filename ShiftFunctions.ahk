/* 
 	Author:      	Maciej Słojewski (🐘, mslonik, http://mslonik.pl)
 	Purpose:     	Use Shift key(s) for various purposes.
 	Description: 	3 functions:
				Shift: Diacritics, when Shift key is pressed and released after character which has diacritic representation, that letter is replaced with diacritic character.
				Shift: Capital, when Shift is pressed and released before character, that character is replaced with capital character.
				Shift: CapsLock, when Shift is pressed and release twice, CapsLock is toggled.
 	License:     	GNU GPL v.3
	Notes:		Run this script as the first one, before any Hotstring definition (static or dynamic). Thanks to that the on InputHook stack the `ShiftFunction` will be the last one which processes any characters entered by user.
				Save this file as UTF-8 with BOM.
				To cancel Shift behaviour press either Control, Esc, Backspace or both Shift keys at once.
*/
#SingleInstance, 	force			; Only one instance of this script may run at a time!
#NoEnv  							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     					; Enable warnings to assist with detecting common errors.
#Requires, 		AutoHotkey v1.1.34+ ; Displays an error and quits if a version requirement is not met.
#KeyHistory, 		150				; For debugging purposes.
#LTrim							; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.

FileEncoding, 		UTF-8			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
SetBatchLines, 	-1				; -1 = never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
;Testing: Alt+Tab, , asdf Shift+Home, Ąsi

; - - - - - - - - - - - - - - - - Executable section, beginning - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AppVersion			:= "1.3.17"
;@Ahk2Exe-Let 				U_AppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright 		GNU GPL 3.x
;@Ahk2Exe-SetDescription 	Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName 	Original script name: %A_ScriptName%
;@Ahk2Exe-SetCompanyName  	http://mslonik.pl
;@Ahk2Exe-SetFileVersion 	%U_AppVersion%
;@Ahk2Exe-SetVersion 		%U_AppVersion%
;@Ahk2Exe-SetMainIcon		imageres_122.ico 		;c:\Windows\System32\imageres.dll 

FileInstall, LICENSE, 			LICENSE, 			false	;false = not overwrite if already exists	
FileInstall, ShiftFunctions.ahk, 	ShiftFunctions.ahk, false	;false = not overwrite if already exists
FileInstall, Czech.ini, 			Czech.ini,		false	;false = not overwrite if already exists
FileInstall, German1.ini, 		German1.ini,		false	;false = not overwrite if already exists
FileInstall, German2.ini, 		German2.ini,		false	;false = not overwrite if already exists
FileInstall, Norwegian.ini,		Norwegian.ini,		false	;false = not overwrite if already exists
FileInstall, Polish.ini, 		Polish.ini, 		false	;false = not overwrite if already exists
FileInstall, Slovakian1.ini,		Slovakian1.ini,	false	;false = not overwrite if already exists
FileInstall, Slovakian2.ini,		Slovakian2.ini,	false	;false = not overwrite if already exists
FileInstall, README.md, 			README.md,		false	;false = not overwrite if already exists
; - - - - - - - - - - - - - - - - Executable section, end - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	v_Char 			:= ""	;global variable, character pressed (main area of keyboard)
,	f_Char			:= false	;global flag, set when printable character was pressed down (and not yet released).
,	f_AChar			:= false	;global flag, set when artificial (hook) key is pressed down (and not yet released).
,	f_SPA 			:= false	;global flag, set when any Shift key (left or right) was Pressed Alone.
,	f_ShiftDown		:= false	;global flag, set by F_OKD when any Shift key is pressed
,	f_ControlPressed	:= false	;global flag, set when any Control key (left or right) was pressed.
,	f_AltPressed		:= false	;global flag, set when any Alt key (left or right) was pressed.
,	f_WinPressed		:= false	;global flag, set when any Windows key (left or right) was pressed.
,	f_AOK_Down		:= false	;global flag AOK = Any Other Key
,	f_ShiftFunctions	:= true	;global flag, state of InputHook
,	f_Capital			:= true	;global flag: enable / disable function Shift Capital
,	f_Diacritics		:= true	;global flag: enable / disable function Shift Diacritics
,	f_CapsLock		:= true	;global flag: enable / disable function Shift CapsLock
,	c_MB_I_AsteriskInfo	:= 64	;global constant: used for MessageBox functions to show Info icon with single sound
,	c_MB_I_Exclamation	:= 48	;global constant: MsgBox icon
,	c_MB_B_YesNo		:= 4		;global constant: MsgBox button, Yes / No
,	a_BaseKey 		:= []	;global array: ordinary letters and capital ordinary letters
,	a_Diacritic		:= []	;global array: diacritic letters and capital diacritic letters
,	v_ConfigIni		:= ""	;global variable, stores filename of current Config.ini, e.g. Polish.ini.
,	v_Undo			:= ""	;global variable, stores last character pressed by user before F_Diacritic or F_Capital were in action
,	v_CLCounter 		:= 0		;global variable, CapsLock counter
,	c_CLReset			:= 0		;global constant: CapsLock counter reset 
,	c_OutputSL		:= 1		;global constant: value for SendLevel, which is feedback for other scripts
,	c_NominalSL		:= 0		;global constant: nominal / default value for SendLevel
,	f_LShift			:= false	;global flag, set when Left Shift is pressed down
,	f_RShift			:= false	;global flag, set when Right Shift is pressed down
,	c_InputSL			:= 2		;global constant: default value for InputHook (MinSendLevel)
,	f_SDCD			:= false	;global flag: Shift (S) is down (D) and Character (C) is down (D)
,	v_WhatWasDown		:= ""	;global variable, name of key which was pressed down
,	f_WasReset		:= false	;global flag: Shift key memory reset (to reset v_CLCounter)
,	f_ShiftTimeout		:= false	;global flag: timer is running
,	c_Buffer			:= {}	;global character object buffer
,	v_SleepValue		:= 0		;global value for sleep in F_OCD
,	c_TimeDS			:= 100	;global time to elapse before double shift in miliseconds

F_CheckDuplicates()		;check if there are running .ahk or .exe copies of this script in paraller
F_InitiateInputHook()	;at first initialize InputHook with the default values
F_MenuTray()			;initialize Tray menu
F_InputArguments()		;process and apply global variables of Config.ini
F_ReadIni()			;read config.ini
;end of initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sfhelp/::		;stands for: Shift functions help
	F_Help()
return

:*:sfsave/::
	F_Save()
return

:*:sfreload/::		;stands for: Shift functions reload (synonym of restart)
:*:sfrestart/::     ;stands for: Shift functions restart (synonym of reload)
	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
	Reload
return

:*:sfstop/::
:*:sfquit/::
:*:sfexit/::
	TrayTip, % A_ScriptName, % "exits with code" . A_Space . "0", 5, 1	ExitApp, 0
return

:*:sfswitch/::
:*:sftoggle/:: 
	F_Toggle()
return

:*:sfstatus/::
:*:sfstate/::
	F_Status()
return

:*:sfenable/::
	F_sfendis(WhatToDo := true)
return

:*:sfdisable/::
	F_sfendis(WhatToDo := false)
return

:*:sfdtoggle/::
	F_sfparamToggleH(WhichVariable := "f_Diacritics", FunctionName := "Diacritics")
return

:*:sfddisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := "f_Diacritics", FunctionName := "Diacritics")
return

:*:sfdenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := "f_Diacritics", FunctionName := "Diacritics")
return

:*:sfctoggle/::
	F_sfparamToggleH(WhichVariable := "f_Capital", FunctionName := "Capital")
return

:*:sfcdisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := "f_Capital", FunctionName := "Capital")
return

:*:sfcenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := "f_Capital", FunctionName := "Capital")
return

:*:sfltoggle/::
	F_sfparamToggleH(WhichVariable := "f_CapsLock", FunctionName := "CapsLock")
return

:*:sfldisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := "f_CapsLock", FunctionName := "CapsLock")
return

:*:sflenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := "f_CapsLock", FunctionName := "CapsLock")
return
; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - GLOBAL HOTKEYS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~LButton::	;not sure if this is necessary, but is should also not spoil anything
~RButton::
~MButton::
	F_FlagReset()
	v_Char := ""	;necessary for the scenario: user's text string is finished with potential diacritic letter, user clicks somewhere and then <shift d><shift u> produces diacritic. It should not.
return

~+WheelUp::	;scrolling with shift pressed down, e.g. in draw.io application; unfortunatelly I don't know how to make it possible with touchpad and "two fingers" scrolling on ThinkPad laptops.
~+WheelDown::
	v_CLCounter := -1	;it will be incremented by +1 to 0 by function F_CapsLock
return
; - - - - - - - - - - - - - - GLOBAL HOTKEYS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - DEFINITIONS OF FUNCTIONS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckDuplicates()	;Checks if second instance of script or executable isn't running
{
	global	;assume-global mode of operation
	local	IfExistSF_exe 	:= false
		,	IfExistSF_ahk 	:= false
		,	ScriptNoExt	:= SubStr(A_ScriptName, 1, -4)
		,	PID			:= DllCall("GetCurrentProcessId")

	Process, Exist, ShiftFunctions.exe	
	if (ErrorLevel != 0) and (ErrorLevel != PID)	;name of the process is returned in ErrorLevel variable if it is different than 0
		IfExistSF_exe := true
	Process, Exist, ShiftFunctions.ahk
	if (ErrorLevel != 0) and (ErrorLevel != PID)	;name of the process is returned in ErrorLevel variable if it is different than 0
		IfExistSF_ahk := true

	if (IfExistSF_exe) or (IfExistSF_ahk)
	{
		MsgBox, % c_MB_I_Exclamation, % A_ScriptName
			, % "Second running instance of " . A_Space . ScriptNoExt . " detected:" . "`n"
			. (IfExistSF_exe ? ScriptNoExt . ".exe" : ScriptNoExt . ".ahk") 
	}	
	; OutputDebug, % "IfExistSF_exe:" . IfExistSF_exe . A_Space . "IfExistSF_ahk:" . IfExistSF_ahk . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Save()
{
	global	;assume-globa mode of operation

	; OutputDebug, % "v_ConfigIni:" . A_Space . v_ConfigIni . A_Space . "f_ShiftFunctions:" . A_Space . f_ShiftFunctions .  "`n"
	IniWrite, % f_ShiftFunctions, 	% A_ScriptDir . "\" . v_ConfigIni, Global, OverallStatus
	if (ErrorLevel)
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "overall status" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_Capital, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapital
	if (ErrorLevel)
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift capital" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_Diacritics, 		% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftDiacritics
	if (ErrorLevel)
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift diacritics" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_CapsLock, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapsLock
	if (ErrorLevel)
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift capslock" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni

	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Your settings is saved to" . "`n`n"
		. A_ScriptDir . "\" . v_ConfigIni . "`n`n"
		. "Overall status:"		. A_Tab . (f_ShiftFunctions 	? "enabled" : "disabled") . "`n"
		. "Shift Capital:"		. A_Tab . (f_Capital		? "enabled" : "disabled") . "`n"
		. "Shift Diacritics"	. A_Tab . (f_Diacritics		? "enabled" : "disabled") . "`n"
		. "Shift CapsLock"		. A_Tab . (f_CapsLock		? "enabled" : "disabled") . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Help()
{
	global	;assume-globa mode of operation
	MsgBox, % c_MB_I_AsteriskInfo, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . "information", % "Application hotstrings" . "." . A_Space . "All of them are ""immediate execute"" (*)" . "`n"
		. "and active anywhere in operating system (any window)"						. "`n"
		. "`n`n"
		. "sfhelp/" . A_Tab . A_Tab . 	"shows this message"					 	. "`n"
		. "sfrestart/" . A_Tab . A_Tab .	"reload" 	. A_Space . "application"		 	. "`n"
		. "sfreload/" . A_Tab . A_Tab	. 	"reload" 	. A_Space . "application"		 	. "`n"
		. "sfstop/" . A_Tab . A_Tab .		"exit"	. A_Space . "application"			. "`n"
		. "sfquit/" . A_Tab . A_Tab .		"exit" 	. A_Space . "application"			. "`n"
		. "sfexit/" . A_Tab . A_Tab .		"exit" 	. A_Space . "application"			. "`n"
		. "sfswitch/" . A_Tab . A_Tab .	"toggle"	. A_Space . "shift standalone"		. "`n"
		. "sftoggle/" . A_Tab . A_Tab .	"toggle"	. A_Space . "shift standalone"		. "`n"
		. "sfstatus/" . A_Tab . A_Tab .	"status"	. A_Space . "application"			. "`n"
		. "sfstate/" . A_Tab . A_Tab .	"status"	. A_Space . "application"			. "`n"
		. "sfenable/" . A_Tab . A_Tab .	"enable"	. A_Space . "application"			. "`n"
		. "sfdisable/" . A_Tab . 		"disable"	. A_Space . "application"			. "`n"
		. "sfddisable/" . A_Tab .		"disable" . A_Space . "shift diacritic"			. "`n"
		. "sfdenable/" . A_Tab .			"enable"	. A_Space . "shift diacritic"			. "`n"
		. "sfdtoggle/" . A_Tab .			"toggle"	. A_Space . "shift diacritic"			. "`n"
		. "sfcdisable/" . A_Tab .		"disable"	. A_Space . "shift capital"			. "`n"
		. "sfcenable/" . A_Tab .			"enable"	. A_Space . "shift capital"			. "`n"
		. "sfctoggle/" . A_Tab .			"toggle" 	. A_Space . "shift capital"			. "`n"
		. "sfldisable/" . A_Tab .		"disable" . A_Space . "shift CapsLock"			. "`n"
		. "sflenable/" . A_Tab .			"enable"	. A_Space . "shift CapsLock"			. "`n"
		. "sfltoggle/" . A_Tab .			"toggle"	. A_Space . "shift CapsLock"			. "`n"
		. "sfsave/"	. A_Tab .			"save"	. A_Space . "configuratio to file"		. "`n"
		. "`n`n"
		. "To cancel immediately Shift behaviour just hit either Control, Esc, Backspace."
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfendis(WhatToDo)
{
	global	;assume-globa mode of operation

	if (WhatToDo)
		v_InputH.Start()
	else
		v_InputH.Stop()

	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is" . A_Space . (WhatToDo ? "ENABLED" : "DISABLED") . "."
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamToggle(ItemName, ItemPos, MenuName)
{
	global	;assume-globa mode of operation

	Switch ItemPos
	{
		Case 3:
			f_Capital := !f_Capital
			Menu, Tray, Rename, % A_ThisMenuItem, % "function Shift" . A_Space . "Capital" . ":"  . A_Tab . (f_Capital ? "ENABLED" : "DISABLED")
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "Capital" . ":"  . A_Tab . (f_Capital ? "ENABLED" : "DISABLED")
		Case 4:
			f_Diacritics := !f_Diacritics
			Menu, Tray, Rename, % A_ThisMenuItem, % "function Shift" . A_Space . "Diacritics" . ":"  . A_Tab . (f_Diacritics ? "ENABLED" : "DISABLED")
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "Diacritics" . ":"  . A_Tab . (f_Diacritics ? "ENABLED" : "DISABLED")
		Case 5:
			f_CapsLock := !f_CapsLock
			Menu, Tray, Rename, % A_ThisMenuItem, % "function Shift" . A_Space . "CapsLock" . ":"  . A_Tab . (f_CapsLock ? "ENABLED" : "DISABLED")
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "CapsLock" . ":"  . A_Tab . (f_CapsLock ? "ENABLED" : "DISABLED")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamToggleH(WhichVariable, FunctionName)
{
	global	;assume-globa mode of operation
	local 	OldValue := %WhichVariable%

	%WhichVariable% := !OldValue
	Menu, Tray, Rename, % "function Shift" . A_Space . FunctionName . ":" . A_Tab . (OldValue ? "ENABLED" : "DISABLED"), % "function Shift" . A_Space . FunctionName . ":"  . A_Tab . (%WhichVariable% ? "ENABLED" : "DISABLED")
	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % FunctionName . A_Space . "is" . A_Space . (%WhichVariable% ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamendis(WhatNext, WhichVariable, FunctionName)
{
	global	;assume-globa mode of operation
	local 	OldValue := %WhichVariable%

	%WhichVariable% := WhatNext
	Menu, Tray, Rename, % "function Shift" . A_Space . FunctionName . ":" . A_Tab . (OldValue ? "ENABLED" : "DISABLED"), % "function Shift" . A_Space . FunctionName . ":"  . A_Tab . (WhichVariable ? "ENABLED" : "DISABLED")
	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % FunctionName . A_Space . "is" . A_Space . (%WhichVariable% ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Status()
{
	global	;assume-globa mode of operation
	local 	OldStatus := f_ShiftFunctions
	Menu, Tray, Rename, % A_ScriptName . A_Space . "status:" . A_Tab . (OldStatus ? "ENABLED" : "DISABLED"), % A_ScriptName . A_Space . "status:" . A_Tab . (f_ShiftFunctions ? "ENABLED" : "DISABLED")
	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Current status is" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED")
		. "`n`n"
		. "function Shift Capital:" . A_Tab . 		(f_Capital ? "ENABLED" : "DISABLED") 		. "`n"
		. "function Shift Diacritics:" . A_Tab . 	(f_Diacritics ? "ENABLED" : "DISABLED") 	. "`n"
		. "function Shift CapsLock:" . A_Tab . 		(f_CapsLock ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Toggle()
{
	global	;assume-globa mode of operation
	local 	OldStatus 	:= f_ShiftFunctions
	, 		OldCapital 	:= f_Capital
	, 		OldDiacritics 	:= f_Diacritics
	, 		OldCapslock 	:= f_CapsLock
	
	f_ShiftFunctions := !f_ShiftFunctions
	Menu, Tray, Rename, % A_ScriptName . A_Space . "status:" . A_Tab . (OldStatus ? "ENABLED" : "DISABLED"), % A_ScriptName . A_Space . "status:" . A_Tab . (f_ShiftFunctions ? "ENABLED" : "DISABLED")
	if (f_ShiftFunctions)
	{
		v_InputH.Start()
		f_Capital			:= true
	,	f_Diacritics		:= true
	,	f_CapsLock		:= true
		Menu, Tray, Rename, % "function Shift Capital:" . A_Tab . 		(OldCapital ? "ENABLED" : "DISABLED"),		% "function Shift Capital:" . A_Tab . 		(f_Capital ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift Diacritics:" . A_Tab . 	(OldDiacritics ? "ENABLED" : "DISABLED"),	% "function Shift Diacritics:" . A_Tab . 	(f_Diacritics ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift CapsLock:" . A_Tab . 		(OldCapslock ? "ENABLED" : "DISABLED"),		% "function Shift CapsLock:" . A_Tab . 		(f_CapsLock ? "ENABLED" : "DISABLED")
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
	}
	else
	{
		v_InputH.Stop()
		f_Capital			:= false
	,	f_Diacritics		:= false
	,	f_CapsLock		:= false
		Menu, Tray, Rename, % "function Shift Capital:" . A_Tab . 		(OldCapital ? "ENABLED" : "DISABLED"),		% "function Shift Capital:" . A_Tab . 		(f_Capital ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift Diacritics:" . A_Tab . 	(OldDiacritics ? "ENABLED" : "DISABLED"),	% "function Shift Diacritics:" . A_Tab . 	(f_Diacritics ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift CapsLock:" . A_Tab . 		(OldCapslock ? "ENABLED" : "DISABLED"),		% "function Shift CapsLock:" . A_Tab . 		(f_CapsLock ? "ENABLED" : "DISABLED")
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Capital()
; F_Capital(ByRef v_Char)
{
	global	;assume-global mode of operation
	; OutputDebug, % A_ThisFunc . A_Space . "B" . A_Space . "v_Char:" . v_Char . "`n"
	Switch v_Char
	{
		Case "``":
			Send, ~
		Case "1":
			Send, {!}
		Case "2":
			Send, @
		Case "3":
			Send, {#}
		Case "4":
			Send, $
		Case "5":
			Send, `%
		Case "6":
			Send, {^}
		Case "7":
			Send, &
		Case "8":
			Send, *
		Case "9":
			Send, (
		Case "0":
			Send, )
		Case "-":
			Send, _
		Case "=":
			Send, {+}
		Case "[":
			Send, {{}	;alternative: SendRaw, `b{
		Case "]":
			Send, {}}	;alternative: SendRaw, `b}
		Case "\":
			Send, |
		Case ";":
			Send, :
		Case "'":
			Send, "
		Case ",":
			Send, <
		Case ".":
			Send, >
		Case "/":
			Send, ?
		Default:
			; OutputDebug, % "v_Char:" . v_Char . "|" . "`n"
			v_Char := Format("{:U}", v_Char)
			Send, % v_Char
	}
	F_FlagReset()
	v_CLCounter 	:= c_CLReset
	; OutputDebug, % A_ThisFunc . A_Space . "v_Char:" . v_Char .  "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MenuTray()
{
	global	;assume-global mode of operation
	
	Menu, Tray, Icon, imageres.dll, 123     ; this line will turn the H icon into a small red a letter-looking thing.
    	Menu, Tray, Add, 		% A_ScriptName . A_Space . "status:" . A_Tab . 	(f_ShiftFunctions ? "ENABLED" : "DISABLED"), F_Toggle
    	Menu, Tray, Default, 	% A_ScriptName . A_Space . "status:" . A_Tab . 	(f_ShiftFunctions ? "ENABLED" : "DISABLED")
    	Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
	Menu, Tray, Add, 		% "function Shift Capital:" . A_Tab . 			(f_Capital ? "ENABLED" : "DISABLED"),		F_sfparamToggle
	Menu, Tray, Add, 		% "function Shift Diacritics:" . A_Tab . 		(f_Diacritics ? "ENABLED" : "DISABLED"),	F_sfparamToggle
	Menu, Tray, Add, 		% "function Shift CapsLock:" . A_Tab . 			(f_CapsLock ? "ENABLED" : "DISABLED"),		F_sfparamToggle
	Menu, Tray, Add
	Menu, MinSendLevelSubm,	Add, 0,																		F_SetMinSendLevel
	Menu, MinSendLevelSubm,	Add, 1,																		F_SetMinSendLevel
	Menu, MinSendLevelSubm,	Add, 2,																		F_SetMinSendLevel
	Menu, MinSendLevelSubm,	Add, 3,																		F_SetMinSendLevel
	Menu, Tray, Add,		% "MinSendLevel value",															:MinSendLevelSubm
	Menu, MinSendLevelSubm, 	Check, 	% c_InputSL
	Menu, SendLevelSumbmenu,	Add, 0,																		F_SetSendLevel
	Menu, SendLevelSumbmenu,	Add, 1,																		F_SetSendLevel
	Menu, SendLevelSumbmenu,	Add, 2,																		F_SetSendLevel
	Menu, SendLevelSumbmenu,	Add, 3,																		F_SetSendLevel
	Menu, Tray,		 	Add, % "SendLevel value",														:SendLevelSumbmenu
	Menu, SendLevelSumbmenu, Check, 	% c_OutputSL
	Menu, Tray, Add
	Menu, Tray, Add,		% "loaded .ini file" . A_Tab .				v_ConfigIni,							F_SelectConfig
	Menu, Tray, Add,		Hotstrings,																	F_Help
	Menu, Tray, Add,		Save configuration to current .ini file,											F_Save
	Menu, Tray, Add, 		About…,																		F_About
    	Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
    	Menu, Tray, NoStandard
    	Menu, Tray, Standard
	Menu, Tray, Add,		Reload,																		F_Reload
    	Menu, Tray, Tip, % A_ScriptName ; Changes the tray icon's tooltip.
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetSendLevel()
{
	global	;assume-global mode of operation
	
	Loop, 4		;number of positions within the SendLevelSumbmenu
	{
		if (A_Index - 1 = A_ThisMenuItem)
		{
			Menu, SendLevelSumbmenu, Check, 	% A_Index - 1
			c_OutputSL := A_Index - 1
			IniWrite, % c_OutputSL, 	% A_ScriptDir . "\" . v_ConfigIni, Global, SendLevel
		}
		else
			Menu, SendLevelSumbmenu, UnCheck, 	% A_Index - 1
	}
	SendLevel, % c_OutputSL
	; OutputDebug, % "c_OutputSL:" . c_OutputSL . A_Space . "SendLevel:" . A_SendLevel . "`n"

	if (c_OutputSL >= c_InputSL)
		F_OutputEqualInputWarn()
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetMinSendLevel()
{
	global	;assume-global mode of operation

	Loop, 4		;number of positions within the SendLevelSumbmenu
	{
		if (A_Index - 1 = A_ThisMenuItem)
		{
			Menu, MinSendLevelSubm, Check, 	% A_Index - 1
			c_InputSL 			:= A_Index - 1
		,	v_InputH.MinSendLevel 	:= c_InputSL
			IniWrite, % c_InputSL, 	% A_ScriptDir . "\" . v_ConfigIni, Global, MinSendLevel
		}
		else
			Menu, MinSendLevelSubm, UnCheck, 	% A_Index - 1
	}
	v_InputH.MinSendLevel 	:= c_InputSL	
	; OutputDebug, % "c_InputSL:" . c_InputSL . A_Space . "MinSendLevel:" . v_InputH.MinSendLevel . "`n"
	
	if (c_OutputSL >= c_InputSL)
		F_OutputEqualInputWarn()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectConfig()
{
	global	;assume-global mode of operation

	FileSelectFile, v_ConfigIni, , % A_ScriptDir, % A_ScriptName . A_Space . "Select one *.ini file:", *.ini
	if (v_ConfigIni = "")
		{
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Exiting with error code 1 (no .ini file specified or found)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "1", 5, 1
			ExitApp, 1
		}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_About()
{
	global	;assume-global mode of operation
	MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName
		, % "`n`n"
		. "
	( RTrim0 ; Turns off the omission of spaces and tabs from the end of each line.
	Author:      	Maciej Słojewski (🐘, mslonik, http://mslonik.pl)
	Purpose:     	Use Shift key(s) for various purposes.
	Version:		
	)" . AppVersion . "`n`n"
	. "
	(
	Description: 	3 functions:

	Shift: Diacritics, when Shift key is pressed and released after character which has diacritic representation, that letter is replaced with diacritic character.

	Shift: Capital, when Shift is pressed and released before character, that character is replaced with capital character.

	Shift: CapsLock, when Shift is pressed and release twice, CapsLock is toggled.

	License:     	GNU GPL v.3
	Notes:		Run this script as the first one, before any Hotstring definition (static or dynamic). Save this file as UTF-8 with BOM. To cancel Shift behaviour press either Control, Esc or even Backspace.
	)"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Empty()	;dummy function useful for test purposes
{}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation

	; OutputDebug, % "c_InputSL:" . c_InputSL . "`n"
	v_InputH 				:= InputHook("L0 E")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.MinSendLevel 	:= c_InputSL
,	v_InputH.OnChar 		:= Func("F_OCD")
,	v_InputH.OnKeyDown		:= Func("F_OKD")
,	v_InputH.OnKeyUp 		:= Func("F_OKU")
,	v_InputH.VisibleText 	:= false				;all 3x parameters: VisibleText (true), VisibleNonText (true), BackspaceIsUndo(true) are equal to InputHook("V"); it means there is no suppression at all
,	v_InputH.VisibleNonText	:= true				;VisibleNonText is passed on to the active window. For example: ->, <-, end, home etc.
,	v_InputH.BackspaceIsUndo	:= false				;by default it is true
	v_InputH.KeyOpt("{All}", "N")
	if (f_ShiftFunctions)
		v_InputH.Start()
	else
		v_InputH.Stop()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShiftTimeout()
{
	global		;assume-global mode of operation

	f_ShiftTimeout 	:= false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckIfTimeElapsed(TtElapse)	;argument in miliseconds
{
	global		;assume-global mode of operation

	if (f_ShiftTimeout)	and (f_RShift) and (f_LShift) ;if timer is running and both shifts are down
	{
		F_FlagReset()
		SetTimer, F_ShiftTimeout, Off
		f_ShiftTimeout := false
	,	f_WasReset	:= true
	,	v_Char		:= ""
		SoundPlay, *16	;future: add option to choose behavior (play sound or not, how long to play sound, what sound) and to define time to wait for reset scenario
		; OutputDebug, % "concurrent" . "`n"
	}
	else
	{
		; OutputDebug, % "Before SetTimer" . "`n"
		SetTimer, F_ShiftTimeout, % "-" . TtElapse	;start timer, one time only
		f_ShiftTimeout := true					;timer is running
		; OutputDebug, % "After SetTimer" . A_Space . "f_ShiftTimeout:" . f_ShiftTimeout . "`n"
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OKD(ih, VK, SC)	;On Key Down
{
	global		;assume-global mode of operation
	Critical, On	;This function starts as the first one (prior to "On Character Down"), but unfortunately can be interrupted by it. To prevent it Critical command is applied.

	v_WhatWasDown 	:= GetKeyName(Format("vk{:x}sc{:x}", VK, SC)) 
	; OutputDebug, % A_ThisFunc . A_Space . "v_WhatWasDown:" . v_WhatWasDown . A_Space . "B" . "`n"
	
	if (f_WinPressed) and (A_PriorKey = "l")	;This condition is valid only after unlocking of Windows (# + L to lock). There is phenomena that after unlocking F_OCD is inactive untill mouse is clicked or Windows key is pressed. Don't know why it is so, but this conditions solves the issue.
	{
		v_Char 		:= A_PriorKey		;OutputDebug, % "Exception!" . "`n"
		F_FlagReset()
	}	

	Switch v_WhatWasDown
	{
		Case "LShift":
			; OutputDebug, % "f_LShift:" . f_LShift . "`n"
			f_LShift		:= true
			F_CheckIfTimeElapsed(c_TimeDS)	;by default: 100 ms
			; OutputDebug, % "f_LShift:" . f_LShift . "`n"
		Case "RShift":
			; OutputDebug, % "f_RShift:" . f_RShift . "`n"
			f_RShift		:= true
			F_CheckIfTimeElapsed(c_TimeDS)	;by default: 100 ms
			; OutputDebug, % "f_RShift:" . f_RShift . "`n"
		Case "LControl", "RControl":
			f_ControlPressed 	:= true
		,	f_AOK_Down		:= true	;Any Other Key	
		Case "LAlt", "RAlt":
			f_AltPressed 		:= true
		,	f_AOK_Down		:= true	;Any Other Key	
		Case "LWin", "RWin":
			f_WinPressed 		:= true
		,	f_AOK_Down		:= true	;Any Other Key
		Case "Esc", "Up", "Down", "Left", "Right", "Enter", "Backspace", "PgUp", "PgDn", "Ins", "Home", "Del", "End":	;13x , max. 20. This line is necessary to prohibit the following scenario: <shell><BS><BS><shift d><shift u> -> shł
			v_Char := ""
		Case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12":	;12x, max. 20. This line is necessary to prohibit the following scenario: <shell><BS><BS><shift d><shift u> -> shł
			v_Char := ""
		Default:
			f_Char 		:= true
		,	f_ShiftDown 	:= false
		,	f_ShiftUp		:= false	
	}
	; OutputDebug, % A_ThisFunc . A_Space . v_WhatWasDown . A_Space . "E" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OCD(ih, Char)	;On Character Down; this function can interrupt "On Key Down"
{	;This function detects only "characters" according to AutoHotkey rules, no: modifiers (Shifts, Controls, Alts, Windows), function keys, Backspace, PgUp, PgDn, Ins, Home, Del, End ; yes: Esc, Space, Enter, Tab and all aphanumeric keys. How keyboard works: some keys have two layer meaning, where Shift is used to call another character from another layer. Example: basic layer 3, shift layer #. Another example: Ins and Shift+Ins do not produce character, but act differently; Shift + Ins must be preserved.
	global	;assume-global mode of operation
	Critical, On
	local 	f_IfShiftDown	:= GetKeyState("Shift","P")			;if <shift> is down only logically
		,	f_IfCapsLock	:= GetKeyState("CapsLock", "T")	;if CapsLock is "on"
		,	IsAlpha 		:= true

	Sleep, % v_SleepValue	; sleep is always required after GetKeyState if there is more than one script running which touches keyboard hooks.
	v_Char := Char	;local variable to global variable
	; OutputDebug, % A_ThisFunc . A_Space . "v_Char:" . v_Char . "`n"
	if v_Char is Alpha
		IsAlpha := true
	else
		IsAlpha := false

	if (f_IfCapsLock)	;if CapsLock is "on"
	{
		if v_Char is Alpha	;alphabetic character
		{
			if (!f_IfShiftDown) and (!f_SPA)	;SPA = Shift Pressed Alone
			{
				F_CapitalUnicode()
				Critical, Off
				return
			}	

			if (f_IfShiftDown)	;logic must be reversed if Shift key is pressed.
			{
				Send, % "+" . v_Char
				Critical, Off
				return
			}	

			if (f_Capital) 
				and (f_SPA)	;SPA = Shift Pressed Alone
			{
				Send, % "+" . v_Char
				f_SPA := false
			,	v_Char := Format("{:l}", v_Char)	;convert v_Char to small letter
				Critical, Off
				return
			}
		}
		else	;not alphabetic character
		{
			F_SendNotAlphaChar(f_IfShiftDown)
			Critical, Off
			return
		}	
		
	}
	else	;CapsLock is off
	{
		; OutputDebug, % "CapsLock is off" . "`n"
		if v_Char is Alpha
		{
			if (!f_IfShiftDown) and (!f_SPA)	;SPA = Shift Pressed Alone
			{
				Send, % v_Char
				; OutputDebug, % "(!f_IfShiftDown) and (!f_SPA):" . v_Char . "`n"
				Critical, Off
				return
			}	
			if (f_IfShiftDown)	;logic must be reversed if Shift key is pressed.
			{
				Send, % "+" . v_Char
				; OutputDebug, % "f_IfShiftDown:" . v_Char . "`n"
				Critical, Off
				return
			}	
			if (f_Capital) 
				and (f_SPA)	;SPA = Shift Pressed Alone
			{
				Send, % "+" . v_Char
				f_SPA := false
			,	v_Char := Format("{:U}", v_Char)	;convert v_Char to capital letter
				; OutputDebug, % "f_Capital:" . v_Char . "`n"
				Critical, Off
				return
			}
		}	
		else	;not alphabetic character
		{
			F_SendNotAlphaChar(f_IfShiftDown)
			Critical, Off
			return
		}	  
	}
	; OutputDebug, % A_ThisFunc . A_Space . v_Char . A_Space . "E" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CapitalUnicode()
{
	global	;assume-global mode of operation

	Switch v_Char				;This is the only way which I know to get rid of blinking CapsLock
	{	;Blind: •SetStoreCapsLockMode is ignored; that is, the state of CapsLock is not changed.
		Case "A":	Send, {Blind}{U+0041}	;A
		Case "B":	Send, {Blind}{U+0042}	;B
		Case "C":	Send, {Blind}{U+0043}	;C
		Case "D":	Send, {Blind}{U+0044}	;D
		Case "E":	Send, {Blind}{U+0045}	;E
		Case "F":	Send, {Blind}{U+0046}	;F
		Case "G":	Send, {Blind}{U+0047}	;G
		Case "H":	Send, {Blind}{U+0048}	;H
		Case "I":	Send, {Blind}{U+0049}	;I
		Case "J":	Send, {Blind}{U+004a}	;J
		Case "K":	Send, {Blind}{U+004b}	;K
		Case "L":	Send, {Blind}{U+004c}	;L
		Case "M":	Send, {Blind}{U+004d}	;M
		Case "N":	Send, {Blind}{U+004e}	;N
		Case "O":	Send, {Blind}{U+004f}	;O
		Case "P":	Send, {Blind}{U+0050}	;P
		Case "Q":	Send, {Blind}{U+0051}	;Q
		Case "R":	Send, {Blind}{U+0052}	;R
		Case "S":	Send, {Blind}{U+0053}	;S
		Case "T":	Send, {Blind}{U+0054}	;T
		Case "U":	Send, {Blind}{U+0055}	;U
		Case "V":	Send, {Blind}{U+0056}	;V
		Case "W":	Send, {Blind}{U+0057}	;W
		Case "X":	Send, {Blind}{U+0058}	;X
		Case "Y":	Send, {Blind}{U+0059}	;Y
		Case "Z":	Send, {Blind}{U+005a}	;Z
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SendNotAlphaChar(f_IfShiftDown)
{ 
	global	;assume-global mode of operation

	if (f_IfShiftDown)
	{
		if (v_Char = "{") or (v_Char = "}") or (v_Char = "^") or (v_Char = "!") or (v_Char = "+") or (v_Char = "#")
			Send, % "{Blind}" . "{" . v_Char . "}"	;Blind: •SetStoreCapsLockMode is ignored; that is, the state of CapsLock is not changed.
		else
			Send, % "{Blind}" . "+" . v_Char		;Blind: •SetStoreCapsLockMode is ignored; that is, the state of CapsLock is not changed.
	}

	if (!f_IfShiftDown) and (!f_SPA)
		Send, % "{Blind}" . v_Char				;Blind: •SetStoreCapsLockMode is ignored; that is, the state of CapsLock is not changed.

	if (!f_IfShiftDown) and (f_SPA)
	{
		Send, % "{Blind}" . "+" . v_Char			;Blind: •SetStoreCapsLockMode is ignored; that is, the state of CapsLock is not changed.
		f_SPA := false
	,	v_CLCounter 	:= c_CLReset
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OKU(ih, VK, SC)	;On Key Up
{

	global	;assume-global mode of operation
	Critical, On	;in order to protect against situation when after diacritic capital letter is entered from nowhere.
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
	
	if (f_WasReset)
	{
		if (WhatWasUp = "LShift") or (WhatWasUp = "RShift")
		{
			v_WhatWasDown 	:= ""	
		,	f_WasReset 	:= false
		}
	}

	; OutputDebug, % A_ThisFunc . A_Space . "f_AOK_Down:" . f_AOK_Down . "`n"
	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
		and (WhatWasUp = v_WhatWasDown)
		and (!f_AOK_Down)	;Any Other Key
	{
		f_SPA 	:= true	;Shift key (left or right) was Pressed Alone. When set, can be used together with next key press. Therefore it cannot be cleared before next key is pressed.
		if (WhatWasUp = "LShift")
			f_LShift := false
		if (WhatWasUp = "RShift")
			f_RShift := false
		; OutputDebug, % "f_SPA:" . f_SPA . A_Space . "v_Char:" . v_Char . "`n"
	}
	else
	{
		f_SPA 		:= false
	,	v_CLCounter 	:= c_CLReset
	}	

	if (f_Diacritics)
		and (f_SPA)
		and (v_Char)
		{
			; OutputDebug, % "v_Char:" . v_Char . "`n"
			F_Diacritics()
		}

	if (f_CapsLock)
		and (f_SPA)	;Shift key (left or right) was Pressed Alone.
			F_CapsLock(WhatWasUp)
	
	if (WhatWasUp = "LControl") or (WhatWasUp =  "RControl")
		or (WhatWasUp = "LAlt") or (WhatWasUp = "RAlt")
		or (WhatWasUp = "LWin") or (WhatWasUp = "RWin")
			f_AOK_Down		:= false	;Any Other Key
		
	; OutputDebug, % A_ThisFunc . A_Space . WhatWasUp .  A_Space . "E" . "`n"
	Critical, Off		
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FlagReset()
{
	global	;assume-global mode of operation
	f_Char			:= false
,	f_ControlPressed 	:= false
,	f_SPA			:= false
,	f_RShift 			:= false
,	f_LShift 			:= false
,	f_WinPressed 		:= false
,	f_AltPressed 		:= false
,	f_AOK_Down		:= false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CapsLock(WhatWasUp)
; F_CapsLock(WhatWasUp, ByRef f_SPA)
{
	global	;assume-global mode of operation
	local	CLLimit 	:= 3
		,	CapsLockState := false
	; OutputDebug, % A_ThisFunc .  "`n"
	if (WhatWasUp = "LShift") or (WhatWasUp = "RShift")
	{
		if (WhatWasUp = "LShift") and (f_RShift)	;concurrent pressing of both shifts is not recorder as single shift press
			return
		if (WhatWasUp = "RShift") and (f_LShift)
			return
		v_CLCounter++
	}
	else
	{
		v_CLCounter := c_CLReset
		return
	}
	; OutputDebug, % "CLCounter:" . A_Space . v_CLCounter . "`n"
	if (v_CLCounter = CLLimit)
	{
		SetCapsLockState, % !GetKeyState("CapsLock", "T") 
		Sleep, % v_SleepValue		;sleep is required by function GetKeyState to correctly update: "Systems with unusual keyboard drivers might be slow to update the state of their keys". Surprisingly 1 ms seems to be ok.
		SoundPlay, *48		;standard system sound, exclamation
		v_CLCounter	:= c_CLReset
	,	f_SPA 		:= false	;Shift Pressed Alone
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Diacritics()
; F_Diacritics(ByRef v_Char)
{
	global	;assume-global mode of operation
	; OutputDebug, % A_ThisFunc . A_Space . "v_Char:" . v_Char . A_Space . "B" . "`n"
	local	index := 0
		,	value := ""

	for index, value in a_BaseKey
		if (value == v_Char)	;Case sensitive comparison
		{
			Send,	% "{BS}" . a_Diacritic[index]
			; F_DiacriticOutput(a_Diacritic[index])
			v_Undo 	:= v_Char
		,	f_SPA 	:= false	;Shift Pressed Alone
		,	v_Char 	:= ""
			; OutputDebug, % A_ThisFunc . A_Space . "a_Diacritic[index]:" . a_Diacritic[index] . A_Space . "E" . "`n"
			break
		}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InputArguments()
{
	global	;assume-global mode of operation
	local	n := 0, param := "", Counter := 0, FileTemp := ""

	for n, param in A_Args
	{
		if (InStr(param, "-scdisable", false))
			f_Capital := false

		if (InStr(param, "-sddisable", false))
			f_Diacritics := false

		if (InStr(param, "-scdisable", false))
			f_CapsLock := false
	}
	if (!InStr(param, ".ini", false))
	{
		if (FileExist("*.ini"))
			Loop, Files, *.ini
			{
				Counter++
				if (Counter = 1)
					FileTemp := A_LoopFileName
			}
		if (Counter = 0)
		{
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "No .ini file is specified and no .ini files are found within application directory."
				. "`n`n"
				. "Exiting with error code 1 (no .ini file specified or found)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "1", 5, 1
			ExitApp, 1
		}
		if (Counter = 1)
		{
			v_ConfigIni := FileTemp
			MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Only one .ini file was found and application will read in configuration from that file:"
			. "`n`n"
			. v_ConfigIni
			return
		}
		if (Counter > 1)
		{
			MsgBox, % c_MB_I_AsteriskInfo + 4, % A_ScriptName, % "More than one .ini file was found in the following folder:"
				. "`n`n"
				. A_ScriptDir
				. "`n`n"
				. "Would you like to choose one of the .ini files manually now?"
			IfMsgBox, No
			{
				MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "Exiting with error code 1 (no .ini file specified or found)."
				TrayTip, % A_ScriptName, % "exits with code" . A_Space . "1", 5, 1
				ExitApp, 1
			}
			IfMsgBox, Yes
				F_SelectConfig()
		}
	}	
	else
	{
		v_ConfigIni := param
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OutputEqualInputWarn()
{
	global	;assume-global mode of operation

	MsgBox, % c_MB_I_Exclamation, % A_ScriptName, % "The output level (SendLevel) is equal or higher than input level (MinSendLevel)." . "`n"
	. "As a consequence this script will process characters in never ending self-loop." . "`n"
	. "No characters will be displayed on screen." . "`n"
	. "The input level (MinSendlevel) should be at least 1 level higher than output level (SendLevel)" . "`n"
	. "Change configuration settings from Tray menu." . "`n`n"
	. "You have been warned." . "`n`n"
	. "Output level (SendLevel)" . ":" . A_Space . c_OutputSL . "`n"
	. "Input level (MinSendLevel)" . ":" . A_Space . c_InputSL 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReadIni()		;process Config.ini parameters
{
	global	;assume-global mode of operation
	local 	DiacriticSectionCounter 	:= 0
		,	Temp 				:= ""
		,	ErrorString			:= "Error"
		,	Temp2				:= ""

	F_Validate_IniParam(c_OutputSL, 		v_ConfigIni, "Global", "SendLevel")
	SendLevel, % c_OutputSL
	Loop, 4		;number of positions within the SendLevelSumbmenu
	{
		if (A_Index - 1 = c_OutputSL)
			Menu, SendLevelSumbmenu, Check, 	% A_Index - 1
		else
			Menu, SendLevelSumbmenu, UnCheck, 	% A_Index - 1
	}

	F_Validate_IniParam(c_InputSL, 		v_ConfigIni, "Global", "MinSendLevel")
	v_InputH.MinSendLevel := c_InputSL
	Loop, 4		;number of positions within the MinSendLevelSubm
	{
		if (A_Index - 1 = c_InputSL)
			Menu, MinSendLevelSubm, Check, 	% A_Index - 1
		else
			Menu, MinSendLevelSubm, UnCheck, 	% A_Index - 1
	}
	
	if (c_OutputSL >= c_InputSL)
		F_OutputEqualInputWarn()

	F_Validate_IniParam(f_ShiftFunctions, 	v_ConfigIni, "Global", "OverallStatus")
	F_Validate_IniParam(f_Capital, 		v_ConfigIni, "Global", "ShiftCapital")
	F_Validate_IniParam(f_Diacritics, 		v_ConfigIni, "Global", "ShiftDiacritics")
	F_Validate_IniParam(f_CapsLock, 		v_ConfigIni, "Global", "ShiftCapsLock")

	Loop, Read, % v_ConfigIni
	    if (InStr(A_LoopReadLine, "[Diacritic"))
	        DiacriticSectionCounter++
	
	if (DiacriticSectionCounter = 0)
	{
		MsgBox, % c_MB_I_AsteriskInfo, % A_ScriptName, % "The" . A_Space . v_ConfigIni . A_Space . "do not contain any valid section. Exiting with error code 2 (no recognized .ini file section)."
		TrayTip, % A_ScriptName, % "exits with code" . A_Space . "2", 5, 1
		ExitApp, 2
	}
	
	Loop, %DiacriticSectionCounter%
    	{
		F_Validate_IniParam(Temp, v_ConfigIni, "Diacritic" . A_Index, "BaseKey")
		a_BaseKey.Push(Temp)
		F_Validate_IniParam(Temp, v_ConfigIni, "Diacritic" . A_Index, "Diacritic")
		a_Diacritic.Push(Temp)
    		F_Validate_IniParam(Temp, v_ConfigIni, "Diacritic" . A_Index, "ShiftBaseKey")
		a_BaseKey.Push(Temp)
		F_Validate_IniParam(Temp, v_ConfigIni, "Diacritic" . A_Index, "ShiftDiacritic")
		a_Diacritic.Push(Temp)
	}
	F_FlagReset()
	SplitPath, v_ConfigIni, Temp
	TrayTip, % A_ScriptName, % "is starting with" . A_Space . Temp, 5, 1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Reload()
{
	if A_IsCompiled
	    Run "%A_ScriptFullPath%" /force
	else
	    Run "%A_AhkPath%" /force "%A_ScriptFullPath%"
	ExitApp
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Read_IniParam(ByRef IniParam, IniFilename, Section, Parameter)
{
	global	;assume-global mode
	local	temp := ""

	IniRead, temp, % IniFilename, % Section, % Parameter
	if (temp != "ERROR") and (temp != "")
	{
		IniParam := temp
		return "correct"
	}	

	if (temp = "ERROR")
	{
		MsgBox, % c_MB_I_Exclamation, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
			, % TransA["Problem with reading parameter"] . A_Space . Parameter . A_Space . TransA["from the file"] . "`n"
			. IniFilename . "`n`n"
			. TransA["ERROR was read"] . "`n"
			. TransA["Parameter is missing within Config.ini or file is corrupted."]
		return "ERROR"
	}
	if (temp = "")
	{
		MsgBox, % c_MB_I_Exclamation, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
			, % TransA["Problem with reading parameter"] . A_Space . Parameter . A_Space . TransA["from the file"] . "`n"
			. IniFilename . "`n`n"
			. TransA["Parameter has no value."]
		return ""
	}	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Validate_IniParam(ByRef IniParam, IniFilename, Section, Parameter)
{
	global	;assume-global mode of operation
	local	temp := ""

	temp := F_Read_IniParam(IniParam, IniFilename, Section, Parameter)
	if (temp = "ERROR") or (temp = "")
	{
		IniWrite, % IniParam, % IniFilename, % Section, % Parameter
		if (ErrorLevel)
		{
			MsgBox, % c_MB_I_Exclamation, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"]
				, % TransA["Problem with writing parameter"] . A_Space . Parameter . A_Space . TransA["to the file"] . "`n"
				. IniFilename . "`n`n"
				. TransA["Non-existing or corrupted file."]
				. TransA["The following default value"] . "`n`n"
				. IniParam . "`n"
				. TransA["will be used."]
		}
		else
			MsgBox, % c_MB_I_Info, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
				, % TransA["Default value of"] . A_Space . Parameter . A_Space . TransA["was written to the file"] . "`n"
				. IniFilename . "`n`n"
				. TransA["The following default value"] . "`n`n"
				. IniParam . "`n"
				. TransA["will be used."]
	}
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -