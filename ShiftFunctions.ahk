/* 
 	Author:      	Maciej Słojewski (🐘, mslonik, http://mslonik.pl)
 	Purpose:     	Use Shift key(s) for various purposes.
 	Description: 	3 functions:
				Shift: Diacritics, when Shift key is pressed and released after character which has diacritic representation, that letter is replaced with diacritic character.
				Shift: Capital, when Shift is pressed and released before character, that character is replaced with capital character.
				Shift: CapsLock, when Shift is pressed and release twice, CapsLock is toggled.
 	License:     	GNU GPL v.3
	Notes:		Run this script as the first one, before any Hotstring definition (static or dynamic).
				Save this file as UTF-8 with BOM.
				To cancel Shift behaviour press either Control, Esc or even Backspace.
*/
#SingleInstance, 	force			; Only one instance of this script may run at a time!
#NoEnv  							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     					; Enable warnings to assist with detecting common errors.
#Requires, AutoHotkey v1.1.34+ 		; Displays an error and quits if a version requirement is not met.
#KeyHistory, 		150				; For debugging purposes.
#LTrim							; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.

FileEncoding, 		UTF-8			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
SetBatchLines, 	-1				; -1 = never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OKU()

;Testing: Alt+Tab, , asdf Shift+Home

; - - - - - - - - - - - - - - - - Executable section, beginning - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AppVersion			:= "1.3.2"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/ShiftDiacritic
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%

FileInstall, LICENSE, 			LICENSE, 			true
FileInstall, ShiftFunctions.ahk, 	ShiftFunctions.ahk, true
FileInstall, Czech.ini, 			Czech.ini,		true
FileInstall, German1.ini, 		German1.ini,		true
FileInstall, German2.ini, 		German2.ini,		true
FileInstall, Norwegian.ini,		Norwegian.ini,		true
FileInstall, Polish.ini, 		Polish.ini, 		true
FileInstall, Slovakian1.ini,		Slovakian1.ini,	true
FileInstall, Slovakian2.ini,		Slovakian2.ini,	true
FileInstall, README.md, 			README.md,		true
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
,	c_IconAsteriskInfo	:= 64	;global constant: used for MessageBox functions to show Info icon with single sound
,	a_BaseKey 		:= []	;global array: ordinary letters and capital ordinary letters
,	a_Diacritic		:= []	;global array: diacritic letters and capital diacritic letters
,	v_ConfigIni		:= ""	;global variable, stores filename of current Config.ini.
,	v_Undo			:= ""	;global variable, stores last character pressed by user before F_Diacritic or F_Capital were in action
,	f_DUndo			:= false	;global variable, set if F_Diacritics or F_Capital were in action
,	v_CLCounter 		:= 0		;global variable, CapsLock counter
,	c_CLReset			:= 0		;global constant: CapsLock counter reset 
,	c_OutputSL		:= 1		;global constant: value for SendLevel, which is feedback for other scripts
,	c_NominalSL		:= 0		;global constant: nominal / default value for SendLevel
,	f_LShift			:= false	;global flag, set when Left Shift is pressed down
,	f_RShift			:= false	;global flag, set when Right Shift is pressed down
,	c_InputSL			:= 2		;global constant: default value for InputHook (MinSendLevel)
,	f_SDCD			:= false	;global flag: Shift (S) is down (D) and Character (C) is down (D)
,	f_ASDCD			:= false	;global flag: Artificial (hook generated) Shift (S) is down (D) and artificial Character (C) is down (D)
,	f_ALShift			:= false	;global flag: Artificial (hook generated) Left Shift
,	f_ARShift			:= false	;global flag: Artificial (hook generated) Right Shift

F_InitiateInputHook()
F_InputArguments()
F_MenuTray()
;end initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sfhelp/::		;stands for: Shift functions help
	F_Help()
return

:*:sfsave/::
	F_Save()
return

:*:sfreload/::		;stands for: Shift functions reload (synonym of restart)
:*:sfrestart/::     ;stands for: Shift functions restart (synonym of reload)
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
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
return
; - - - - - - - - - - - - - - GLOBAL HOTKEYS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - DEFINITIONS OF FUNCTIONS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Save()
{
	global	;assume-globa mode of operation

	; OutputDebug, % "v_ConfigIni:" . A_Space . v_ConfigIni . A_Space . "f_ShiftFunctions:" . A_Space . f_ShiftFunctions .  "`n"
	IniWrite, % f_ShiftFunctions, 	% A_ScriptDir . "\" . v_ConfigIni, Global, OverallStatus
	if (ErrorLevel)
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "overall status" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_Capital, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapital
	if (ErrorLevel)
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift capital" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_Diacritics, 		% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftDiacritics
	if (ErrorLevel)
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift diacritics" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni
	IniWrite, % f_CapsLock, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapsLock
	if (ErrorLevel)
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with saving parameter" . A_Space . "shift capslock" . A_Space . "to the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni

	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Your settings is saved to" . "`n`n"
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
	MsgBox, % c_IconAsteriskInfo, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . "information", % "Application hotstrings" . "." . A_Space . "All of them are ""immediate execute"" (*)" . "`n"
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

	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is" . A_Space . (WhatToDo ? "ENABLED" : "DISABLED") . "."
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
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "Capital" . ":"  . A_Tab . (f_Capital ? "ENABLED" : "DISABLED")
		Case 4:
			f_Diacritics := !f_Diacritics
			Menu, Tray, Rename, % A_ThisMenuItem, % "function Shift" . A_Space . "Diacritics" . ":"  . A_Tab . (f_Diacritics ? "ENABLED" : "DISABLED")
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "Diacritics" . ":"  . A_Tab . (f_Diacritics ? "ENABLED" : "DISABLED")
		Case 5:
			f_CapsLock := !f_CapsLock
			Menu, Tray, Rename, % A_ThisMenuItem, % "function Shift" . A_Space . "CapsLock" . ":"  . A_Tab . (f_CapsLock ? "ENABLED" : "DISABLED")
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "function Shift" . A_Space . "CapsLock" . ":"  . A_Tab . (f_CapsLock ? "ENABLED" : "DISABLED")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamToggleH(WhichVariable, FunctionName)
{
	global	;assume-globa mode of operation
	local 	OldValue := %WhichVariable%

	%WhichVariable% := !OldValue
	Menu, Tray, Rename, % "function Shift" . A_Space . FunctionName . ":" . A_Tab . (OldValue ? "ENABLED" : "DISABLED"), % "function Shift" . A_Space . FunctionName . ":"  . A_Tab . (%WhichVariable% ? "ENABLED" : "DISABLED")
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % FunctionName . A_Space . "is" . A_Space . (%WhichVariable% ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamendis(WhatNext, WhichVariable, FunctionName)
{
	global	;assume-globa mode of operation
	local 	OldValue := %WhichVariable%

	%WhichVariable% := WhatNext
	Menu, Tray, Rename, % "function Shift" . A_Space . FunctionName . ":" . A_Tab . (OldValue ? "ENABLED" : "DISABLED"), % "function Shift" . A_Space . FunctionName . ":"  . A_Tab . (WhichVariable ? "ENABLED" : "DISABLED")
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % FunctionName . A_Space . "is" . A_Space . (%WhichVariable% ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Status()
{
	global	;assume-globa mode of operation
	local 	OldStatus := f_ShiftFunctions
	Menu, Tray, Rename, % A_ScriptName . A_Space . "status:" . A_Tab . (OldStatus ? "ENABLED" : "DISABLED"), % A_ScriptName . A_Space . "status:" . A_Tab . (f_ShiftFunctions ? "ENABLED" : "DISABLED")
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Current status is" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED")
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
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
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
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Capital(ByRef v_Char)
{
	global	;assume-global mode of operation

	SendLevel, % c_OutputSL
	Switch v_Char
	{
		Case "``":
			Send, {BS}~
		Case "1":
			Send, {BS}{!}
		Case "2":
			Send, {BS}@
		Case "3":
			Send, {BS}{#}
		Case "4":
			Send, {BS}$
		Case "5":
			Send, {BS}`%
		Case "6":
			Send, {BS}{^}
		Case "7":
			Send, {BS}&
		Case "8":
			Send, {BS}*
		Case "9":
			Send, {BS}(
		Case "0":
			Send, {BS})
		Case "-":
			Send, {BS}_
		Case "=":
			Send, {BS}{+}
		Case "[":
			Send, {BS}{{}
		Case "]":
			Send, {BS}{}}
		Case "\":
			Send, {BS}|
		Case ";":
			Send, {BS}:
		Case "'":
			Send, {BS}"
		Case ",":
			Send, {BS}<
		Case ".":
			Send, {BS}>
		Case "/":
			Send, {BS}?
		Case "!":		;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			SendLevel, % c_NominalSL
			Send, {!}
		Case "{":		;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			SendLevel, % c_NominalSL
			Send, {{}
		Case "}":		;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			SendLevel, % c_NominalSL
			Send, {}}
		Case "#":		;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			SendLevel, % c_NominalSL
			Send, {#}
		Case "^":		;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			SendLevel, % c_NominalSL
			Send, {^}	;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
			OutputDebug, % "Tu jestem" . "`n"
		Case "+":
			SendLevel, % c_NominalSL
			Send, {+}	;when other AutoHotkey script (e.g. Hotstrings) sends out any special character where Shift is applied (e.g. # = Shift + 3), it have to be also send out, but without bouncing.
		Case "`t":	;by try and error method
		Case "`n":
		Default:
			; OutputDebug, % "v_Char:" . v_Char . "|" . "`n"
			v_Char := Format("{:U}", v_Char)
			Send, % "{BS}" . v_Char
	}
	SendLevel, % c_NominalSL
	f_SPA 		:= false
,	f_RShift 		:= false
,	f_LShift 		:= false
,	f_Char		:= false
,	f_AOK_Down	:= false
,	v_CLCounter 	:= c_CLReset
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
	Menu, Tray, Add,		% "loaded .ini file" . A_Tab .				v_ConfigIni,							F_SelectConfig
	Menu, Tray, Add,		Hotstrings,																	F_Help
	Menu, Tray, Add,		Save configuration to current .ini file,											F_Save
	Menu, Tray, Add, 		About…,																		F_About
    	Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
    	Menu, Tray, NoStandard
    	Menu, Tray, Standard
    	Menu, Tray, Tip, % A_ScriptName ; Changes the tray icon's tooltip.
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectConfig()
{
	global	;assume-global mode of operation

	FileSelectFile, v_ConfigIni, , % A_ScriptDir, % A_ScriptName . A_Space . "Select one *.ini file:", *.ini
	if (v_ConfigIni = "")
		{
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Exiting with error code 1 (no .ini file specified or found)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "1", 5, 1
			ExitApp, 1
		}
	F_ReadIni(v_ConfigIni)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_About()
{
	global	;assume-global mode of operation
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName
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

	v_InputH 				:= InputHook("V L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.MinSendLevel 	:= c_InputSL	
,	v_InputH.OnChar 		:= Func("F_OCD")
,	v_InputH.OnKeyDown		:= Func("F_OKD")
,	v_InputH.OnKeyUp 		:= Func("F_OKU")
	v_InputH.KeyOpt("{All}", "N")
	if (f_ShiftFunctions)
		v_InputH.Start()
	else
		v_InputH.Stop()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShiftReset()
{
	global	;assume-global mode of operation
	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OKD(ih, VK, SC)	;On Key Down
{
	global		;assume-global mode of operation
	Critical, On	;This function starts as the first one (prior to "On Character Down"), but unfortunately can be interrupted by it. To prevent it Critical command is applied.
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	local	WhatWasDown 	:= GetKeyName(Format("vk{:x}sc{:x}", VK, SC)) 
		,	f_Phys		:= false

	Sleep, 30		;sleep is required by function GetKeyState to correctly update: "Systems with unusual keyboard drivers might be slow to update the state of their keys".
	f_Phys 		:= GetKeyState(WhatWasDown, "P")	;if character comes from keyboard hook (is artificial) or is physically pressed by user
	; OutputDebug, % "WhatWasDown:" . WhatWasDown . A_Space . "f_Phys:" . f_Phys . A_Space . GetKeyState(WhatWasDown, "P") . "`n"
	Switch WhatWasDown
	{
		Case "LShift":
			if (f_Phys)
			{
				f_LShift		:= true
			,	f_ALShift		:= false
				KeyWait, RShift, D T0.05
				if (!ErrorLevel)
				{
					; ToolTip, % "Concurrent" . A_Space . v_CLCounter
					F_FlagReset()
					v_CLCounter := c_CLReset
					return
				}
				; else
					; ToolTip, Not concurrent
			}
			else
			{
				f_LShift		:= false
			,	f_ALShift		:= true
			}
		Case "RShift":
			if (f_Phys)
			{
				f_RShift		:= true
			,	f_ARShift		:= false
				KeyWait, LShift, D T0.05
				if (!ErrorLevel)
				{
					; ToolTip, % "Concurrent" . A_Space . v_CLCounter
					F_FlagReset()
					v_CLCounter := c_CLReset
					return
				}
				; else
					; ToolTip, Not concurrent
			}
			else
			{
				f_RShift		:= false
			,	f_ARShift		:= true
			}
		Case "LControl", "RControl":
			f_ControlPressed 	:= true
		,	f_AOK_Down		:= true	;Any Other Key	
		Case "LAlt", "RAlt":
			f_AltPressed 		:= true
		,	f_AOK_Down		:= true	;Any Other Key	
		Case "LWin", "RWin":
			f_WinPressed 		:= true
		,	f_AOK_Down		:= true	;Any Other KeJ	
		Default:
			f_AOK_Down		:= true	;Any Other Key
			if (f_Phys)
			{
				f_AChar	:= false
			,	f_Char 	:= true
			}
			else
			{
				f_AChar	:= true
			,	f_Char 	:= false
			}
	}
	; OutputDebug, % A_ThisFunc . A_Space . "WWD:" . A_Space . WhatWasDown . "|" . A_Space 
	; 	. "f_Phys:" . f_Phys . A_Space . "f_Char:" . f_Char . A_Space . "f_AChar:" . f_AChar . A_Space
	; 	. "PS:" . f_RShift 	. f_LShift 
	; 	. A_Space 
	; 	. "AS:" . f_ALShift . f_ARShift 
	; 	. "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OCD(ih, Char)	;On Character Down; this function can interrupt "On Key Down"
{	;This function detects only "characters" according to AutoHotkey rules, what means: not modifiers (Shifts, Controls, Alts, Windows), function keys, ; yes: Esc, Space, Enter, Tab and all other main keys.
	global	;assume-global mode of operation
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"

	v_Char := Char
,	f_DUndo := false

	if (f_RShift or f_LShift) and f_Char
		f_SDCD := true	;Shift (S) is down (D) and Character (C) is down (D)
	else
		f_SDCD := false

	if (f_ARShift or f_ALShift) and f_AChar
		f_ASDCD := true ;Artificial (A) Shift (S) is down (D) and artificial Character (C) is down (D)
	else
		f_ASDCD := false

	; OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . "|" . A_Space 
	; 	. "f_Char:" 	. f_Char 	. A_Space . "PS:" . f_LShift . f_RShift 	. A_Space . "f_SDCD:" 	. f_SDCD 	
	; 	. A_Space 
	; 	. "f_AChar:" 	. f_AChar . A_Space . "AS:" . f_ALShift . f_ARShift 	. A_Space . "f_ASDCD:" 	. f_ASDCD 
	; 	. "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . "|" . A_Space . "f_SPA:" . f_SPA . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OKU(ih, VK, SC)	;On Key Up
{
	global	;assume-global mode of operation
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
	
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; OutputDebug, % "WWUb:" . WhatWasUp . "|" . A_Space "v_Char:" . v_Char . A_Space . "f_SDCD:" . f_SDCD . A_Space . "f_ASDCD:" . f_ASDCD . "`n"
	; "C:" . f_Char . A_Space . "S:" . f_SPA . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"

	; Filtering section
	Switch WhatWasUp	;only Shifts are not included ;According to AutoHotkey documentation each case may list up to 20 values
	{
		Case "LAlt", "RAlt", "LWin", "RWin", "LControl", "RControl":		;modifiers
			f_Char 		:= false
			if (!f_RShift) and (!f_LShift)
				f_AOK_Down := false
			return
		Case "Insert", "Home", "PageUp", "Delete", "End", "PageDown", "AppsKey"	;NavPad
		,	"Up", "Down", "Left", "Right":	;11
			f_Char 		:= false
		,	v_Char		:= ""
			if (!f_RShift) and (!f_LShift)
				f_AOK_Down 	:= false	
			return
		Case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20":	;20
			f_Char := false
			return
		Case "F21", "F22", "F23", "F24":	;4
			f_Char := false
			return
		Case "Backspace", "Escape":
			f_Char 		:= false
		,	f_AOK_Down 	:= false	
		,	v_Char		:= ""
			return
		Case "LShift", "RShift":
			; OutputDebug, % A_ThisFunc . A_Space . "f_SPA:" . f_SPA . A_Space . "WhatWasUp:" . WhatWasUp . A_Space . "f_SDCD:" . f_SDCD . A_Space . "f_ASDCD:" . f_ASDCD . "`n"
			if (!f_RShift) and (!f_LShift)	;after F_FlagReset()
				return
			f_RShift 	:= false
		,	f_LShift 	:= false
		,	f_ARShift := false
		,	f_ALShift := false
			if (f_SDCD)	;Shift (S) is down (D) and Character (C) is down (D)
			{
				f_SDCD := false
				return
			}
			if (f_ASDCD)
			{
				v_Char 	:= Format("{:U}", v_Char)
			,	f_ASDCD 	:= false
				OutputDebug, % "v_Char:" . v_Char . "|" . "`n"
			}
			if (!f_Char) and (!f_AOK_Down)
				f_SPA 	:= true	;Shift key (left or right) was Pressed Alone.
		Default:
			f_Char 		:= false
		,	f_AOK_Down 	:= false
	}
	; OutputDebug, % A_ThisFunc . A_Space . "f_SPA:" . f_SPA . A_Space . "WhatWasUp:" . WhatWasUp . A_Space . "f_SDCD:" . f_SDCD . A_Space . "f_ASDCD:" . f_ASDCD . "`n"
	; OutputDebug, % "WWU :" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_SPA . A_Space . "A:" . f_AOK_Down . "`n"
	; OutputDebug, % "WWU :" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_SPA . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"
	if (f_Capital) 
		; and (f_Char)
		and (f_SPA)
		and (WhatWasUp != "LShift") and (WhatWasUp != "RShift")
			F_Capital(v_Char)

	if (f_Diacritics)
		and (f_SPA)
		and ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
			F_Diacritics(v_Char)

	F_ShiftUndo(WhatWasUp, f_SPA)

	if (f_CapsLock)
		and (f_SPA)
			F_CapsLock(WhatWasUp, f_SPA)

	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_SPA . A_Space . "A:" . f_AOK_Down . "`n"
	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_SPA . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FlagReset()
{
	global	;assume-global mode of operation
	v_Char 			:= ""
,	f_Char			:= false
,	f_ControlPressed 	:= false
,	f_SPA			:= false
,	f_RShift 			:= false
,	f_LShift 			:= false
,	f_WinPressed 		:= false
,	f_AltPressed 		:= false
,	f_AOK_Down		:= false
	}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShiftUndo(WhatWasUp, ByRef f_SPA)	;future: undo of previous action (Diacritics or CapsLock)
{
	global	;assume-global mode of operation
	static	SRCounter	:= 0
	local	SRLimit	:= 2
		,	SRReset	:= 0	

	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift")) and (f_SPA)
		SRCounter++
	else
	{
		SRCounter := SRReset
		; return
	}
	
	; OutputDebug, % "SRCounter:" . A_Space . SRCounter . "`n"
	if (SRCounter = SRLimit)
	{
		SRCounter		:= SRReset
		if (f_DUndo)
			{
				SendLevel, % c_OutputSL
				Send, % "{BS}" . v_Undo
				SendLevel, % c_NominalSL
				v_Undo 		:= ""
			,	f_DUndo 		:= false
			,	v_CLCounter 	:= c_CLReset
			,	f_SPA 		:= false
			,	f_RShift 		:= false
			,	f_LShift 		:= false

			}
		; OutputDebug, % "Undo" . "`n"
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CapsLock(WhatWasUp, ByRef f_SPA)
{
	global	;assume-global mode of operation
	local	CLLimit 	:= 3
		,	CapsLockState := false

	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift")) and (f_SPA)
		v_CLCounter++
	else
	{
		v_CLCounter := c_CLReset
		return
	}
	OutputDebug, % "CLCounter:" . A_Space . v_CLCounter . "`n"
	if (v_CLCounter = CLLimit)
	{
		CapsLockState	:= GetKeyState("CapsLock", "T")
		; Sleep, 30		;sleep is required by function GetKeyState to correctly update: "Systems with unusual keyboard drivers might be slow to update the state of their keys".
		SetCapsLockState, % !CapsLockState
		; SetCapsLockState, % !GetKeyState("CapsLock", "T")
		Sleep, 30		;sleep is required by function GetKeyState to correctly update: "Systems with unusual keyboard drivers might be slow to update the state of their keys".
		; OutputDebug, % "GetKeyState(CapsLock, T):" . A_Space . GetKeyState("CapsLock", "T") . "`n"
		if (GetKeyState("CapsLock", "T"))
			SoundPlay, *48		;standard system sound, exclamation
		else
			SoundPlay, *16		;standard system sound, hand (stop/error)
		v_CLCounter	:= c_CLReset
	,	f_SPA 		:= false	;Shift Pressed Alone
	,	f_RShift 		:= false
	,	f_LShift 		:= false
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Diacritics(v_Char)
{
	global	;assume-global mode of operation
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	local	index := % c_NominalSL
		,	value := ""

	for index, value in a_BaseKey
		if (value == v_Char)	;Case sensitive comparison
		{
			F_DiacriticOutput(a_Diacritic[index])
			v_Undo := v_Char
,			f_DUndo := true
			OutputDebug, % "f_DUndo:" . A_Space . f_DUndo . A_Space . "v_Undo:" . v_Undo . "`n"
		}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DiacriticOutput(Diacritic)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	SendLevel, 	% c_OutputSL
	Send,		% "{BS}" . Diacritic
	SendLevel, 	% c_NominalSL
	f_SPA 		:= false	;Shift Pressed Alone
,	f_RShift 		:= false
,	f_LShift 		:= false
,	f_Char 		:= false
,	v_Char		:= ""
,	f_AOK_Down	:= false
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
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
				MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "No .ini file is specified and no .ini files are found within application directory."
					. "`n`n"
					. "Exiting with error code 1 (no .ini file specified or found)."
				TrayTip, % A_ScriptName, % "exits with code" . A_Space . "1", 5, 1
				ExitApp, 1
			}
			if (Counter = 1)
			{
				v_ConfigIni := FileTemp
				MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Only one .ini file was found and application will read in configuration from that file:"
				. "`n`n"
				. v_ConfigIni
				F_ReadIni(v_ConfigIni)
				return
			}
			if (Counter > 1)
			{
				MsgBox, % c_IconAsteriskInfo + 4, % A_ScriptName, % "More than one .ini file was found in the following folder:"
					. "`n`n"
					. A_ScriptDir
					. "`n`n"
					. "Would you like to choose one of the .ini files manually now?"
				IfMsgBox, No
				{
					MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Exiting with error code 1 (no .ini file specified or found)."
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
			F_ReadIni(v_ConfigIni)
		}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReadIni(param)
{
	global	;assume-global mode of operation
	local 	DiacriticSectionCounter 	:= 0
		,	Temp 				:= ""
		,	ErrorString			:= "Error"

	IniRead, f_ShiftFunctions, 	% v_ConfigIni, Global, OverallStatus, 	% ErrorString
	if (f_ShiftFunctions = ErrorString)
	{
		f_ShiftFunctions := true
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with reading parameter" . A_Space . "overall status" . A_Space . "from the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni . "`n`n"
			. "Default value will be applied now:" . "`n"
			. "ENABLE" . "."
	}

	IniRead, f_Capital, 		% v_ConfigIni, Global, ShiftCapital,	% ErrorString
	if (f_Capital = ErrorString)
	{
		f_Capital := true
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with reading parameter" . A_Space . "Shift capital" . A_Space . "from the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni . "`n`n"
			. "Default value will be applied now:" . "`n"
			. "ENABLE" . "."
	}

	IniRead, f_Diacritics, 		% v_ConfigIni, Global, ShiftDiacritics,	% ErrorString
	if (f_Diacritics = ErrorString)
	{
		f_Diacritics := true
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with reading parameter" . A_Space . "Shift diacritics" . A_Space . "from the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni . "`n`n"
			. "Default value will be applied now:" . "`n"
			. "ENABLE" . "."
	}
	
	IniRead, f_CapsLock, 		% v_ConfigIni, Global, ShiftCapsLock,	% ErrorString
	if (f_CapsLock = ErrorString)
	{
		f_CapsLock := true
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "Problem with reading parameter" . A_Space . "Shift capslock" . A_Space . "from the file" . "`n"
			. A_ScriptDir . "\" . v_ConfigIni . "`n`n"
			. "Default value will be applied now:" . "`n"
			. "ENABLE" . "."
	}

	Loop, Read, % param
	    if (InStr(A_LoopReadLine, "[Diacritic"))
	        DiacriticSectionCounter++
	
	if (DiacriticSectionCounter = 0)
	{
		MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "The" . A_Space . param . A_Space . "do not contain any valid section. Exiting with error code 2 (no recognized .ini file section)."
		TrayTip, % A_ScriptName, % "exits with code" . A_Space . "2", 5, 1
		ExitApp, 2
	}
	
	Loop, %DiacriticSectionCounter%
    	{
		IniRead,  Temp,          	% param, % "Diacritic"	. A_Index, BaseKey,			Error
		if (Temp != "Error")
			a_BaseKey.Push(Temp)
		else
		{
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "The" . A_Space . param . A_Space . "section:" . A_Space . "`n`n"
			. "[Diacritic" . A_Index . "]" . A_Space . "do not contain valid parameter" . "`n"
			. "BaseKey" . "`n`n"
			. "Exiting with error code 3 (no recognized parameter)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "3", 5, 1
			ExitApp, 3
		}
 
    		IniRead,  Temp,     		% param, % "Diacritic"	. A_Index, Diacritic,		Error
		if (Temp != "Error")
			a_Diacritic.Push(Temp)
		else
		{
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "The" . A_Space . param . A_Space . "section:" . A_Space . "`n`n"
			. "[Diacritic" . A_Index . "]" . A_Space . "do not contain valid parameter" . "`n"
			. "Diacritic" . "`n`n"
			. "Exiting with error code 3 (no recognized parameter)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "3", 5, 1
			ExitApp, 3
		}

		IniRead, Temp, 			% param, % "Diacritic"	. A_Index, ShiftBaseKey, 	Error
		if (Temp != "Error")
			a_BaseKey.Push(Temp)
		else
		{
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "The" . A_Space . param . A_Space . "section:" . A_Space . "`n`n"
			. "[Diacritic" . A_Index . "]" . A_Space . "do not contain valid parameter" . "`n"
			. "ShiftBaseKey" . "`n`n"
			. "Exiting with error code 3 (no recognized parameter)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "3", 5, 1
			ExitApp, 3
		}

		IniRead, Temp, 			% param, % "Diacritic"	. A_Index, ShiftDiacritic, 	Error
		if (Temp != "Error")
			a_Diacritic.Push(Temp)
		else
		{
			MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % "The" . A_Space . param . A_Space . "section:" . A_Space . "`n`n"
			. "[Diacritic" . A_Index . "]" . A_Space . "do not contain valid parameter" . "`n"
			. "ShiftDiacritic" . "`n`n"
			. "Exiting with error code 3 (no recognized parameter)."
			TrayTip, % A_ScriptName, % "exits with code" . A_Space . "3", 5, 1
			ExitApp, 3
		}
	}
	F_FlagReset()
	SplitPath, v_ConfigIni, Temp
	TrayTip, % A_ScriptName, % "is starting with" . A_Space . Temp, 5, 1
}