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
#SingleInstance, 	force		; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.
#Requires, AutoHotkey v1.1.35+ 	; Displays an error and quits if a version requirement is not met.
#KeyHistory, 		100			; For debugging purposes.
#LTrim						; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.

FileEncoding, 		UTF-8			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
SetBatchLines, 	-1				; Never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OnKeyUp()

;Testing: Alt+Tab, , asdf Shift+Home

; - - - - - - - - - - - - - - - - Executable section, beginning - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AppVersion			:= "1.0.3"
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

	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global flag, set when any Shift key (left or right) was pressed.
,	f_ControlPressed	:= false	;global flag, set when any Control key (left or right) was pressed.
,	f_AltPressed		:= false	;global flag, set when any Alt key (left or right) was pressed.
,	f_WinPressed		:= false	;global flag, set when any Windows key (left or right) was pressed.
; ,	f_AnyOtherKey		:= false	;global flag
,	f_Char			:= false	;global flag, set when printable character was pressed down (and not yet released).
,	f_ShiftFunctions	:= true	;global flag, state of InputHook
,	f_Capital			:= true	;global flag: enable / disable function Shift Capital
,	f_Diacritics		:= true	;global flag: enable / disable function Shift Diacritics
,	f_CapsLock		:= true	;global flag: enable / disable function Shift CapsLock
,	c_IconAsteriskInfo	:= 64	;global constant: used for MessageBox functions to show Info icon with single sound
,	a_BaseKey 		:= []	;global array: ordinary letters and capital ordinary letters
,	a_Diacritic		:= []	;global array: diacritic letters and capital diacritic letters
,	v_ConfigIni		:= ""	;global variable, stores filename of current Config.ini.

F_InitiateInputHook()
F_InputArguments()
F_MenuTray()
;end initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sfhelp/::
	F_Help()
return

:*:sfsave/::
	F_Save()
return

:*:sfreload/::
:*:sfrestart/::     ;global hotstring
	MsgBox, % c_IconAsteriskInfo, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
	reload
return

:*:sfstop/::
:*:sfquit/::
:*:sfexit/::
	TrayTip, % A_ScriptName, % "exits with code" . A_Space . "0", 5, 1
	ExitApp, 0
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

	IniWrite, % f_ShiftFunctions, 	% A_ScriptDir . "\" . v_ConfigIni, Global, OverallStatus
	IniWrite, % f_Capital, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapital
	IniWrite, % f_Diacritics, 		% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftDiacritics
	IniWrite, % f_CapsLock, 			% A_ScriptDir . "\" . v_ConfigIni, Global, ShiftCapsLock

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

	SendLevel, 2
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
		Case "`t":
			Send, {Shift Down}{Tab 2}{Shift Up}
		Case "`n":
			Send, {BS}+{Enter}
		Default:
			v_Char := Format("{:U}", v_Char)
			Send, % "{BS}" . v_Char
	}
	SendLevel, 0
	f_ShiftPressed 	:= false
,	f_Char			:= false
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
	v_InputH 			:= InputHook("I3 V L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.OnChar 	:= Func("F_OneCharPressed")
,	v_InputH.OnKeyDown	:= Func("F_OnKeyDown")
,	v_InputH.OnKeyUp 	:= Func("F_OnKeyUp")
	v_InputH.KeyOpt("{All}", "N")
	if (f_ShiftFunctions)
		v_InputH.Start()
	else
		v_InputH.Stop()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyDown(ih, VK, SC)
{
	global	;assume-global mode of operation
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	local	WhatWasDown := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	Switch WhatWasDown
	{
		Case "LShift", "RShift":
			f_ShiftPressed 	:= true
		Case "LControl", "RControl":
			f_ControlPressed 	:= true
		Case "LAlt", "RAlt":
			f_AltPressed 		:= true
		Case "LWin", "RWin":
			f_WinPressed 		:= true
		; Default:
			; f_AnyOtherKey		:= true
	}
	; OutputDebug, % "WWD:" . WhatWasDown . A_Space . "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FlagReset()
{
	global	;assume-global mode of operation
	v_Char 			:= ""
,	f_Char			:= false
,	f_ControlPressed 	:= false
,	f_ShiftPressed		:= false
,	f_WinPressed 		:= false
,	f_AltPressed 		:= false
	}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyUp(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
	
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; OutputDebug, % "WWUb:" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"

	; Filtering section
	if (!f_Char)
	{
		Switch WhatWasUp	;only Shifts are not included ;According to AutoHotkey documentation each case may list up to 20 values
		{
			Case "LControl", "RControl":	;modifiers
				F_FlagReset()
				return
			Case "LAlt", "RAlt", "LWin", "RWin":		;modifiers
				f_AltPressed 		:= false
			,	f_WinPressed		:= false	
			,	f_ShiftPressed		:= false
				return
			Case "Insert", "Home", "PageUp", "Delete", "End", "PageDown", "AppsKey"	;NavPad
			,	"Up", "Down", "Left", "Right":	;11
				f_ShiftPressed		:= false
				return
			Case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20":	;20
				f_ShiftPressed		:= false
				return
			Case "F21", "F22", "F23", "F24":	;4
				f_ShiftPressed		:= false
				return
			Case "Backspace":
				F_FlagReset()
				return
		}
	}
	; OutputDebug, % "WWU :" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"

	Switch WhatWasUp	;These are chars, so have to be filtered out separately
		{
			Case "Escape":
				F_FlagReset()
				return
		}

	if ((f_ShiftPressed) and (f_WinPressed))
		or ((f_ShiftPressed) and (f_AltPressed))
		or ((f_ShiftPressed) and (f_ControlPressed))
		{
			; OutputDebug, % "Two modifiers at the same time" . "`n"
			F_FlagReset()
			return
		}
	;From this moment I know we have character and only Shift

	if (f_Capital) 
		and (f_Char)
		and (f_ShiftPressed)
		and (WhatWasUp != "LShift") and (WhatWasUp != "RShift")
			F_Capital(v_Char)

	if (f_Diacritics)
		and (f_ShiftPressed)
		and ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
			F_Diacritics(v_Char)

	; OutputDebug, % "WWU :" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"
	if (f_CapsLock)
		F_DoubleShift(WhatWasUp, f_ShiftPressed)

	f_Char := false
	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DoubleShift(WhatWasUp, ByRef f_ShiftPressed)
{
	global	;assume-global mode of operation
	static	ShiftCounter := 0
	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift")) and (f_ShiftPressed)
		ShiftCounter++
	else
	{
		ShiftCounter := 0
		return
	}
	
	; OutputDebug, % "ShiftCounter:" . A_Space . ShiftCounter . "`n"
	if (ShiftCounter = 2)
	{
		SetCapsLockState % !GetKeyState("CapsLock", "T")
		OutputDebug, % "GetKeyState(CapsLock, T):" . A_Space . GetKeyState("CapsLock", "T") . "`n"
		if (GetKeyState("CapsLock", "T"))
			SoundPlay, *48		;standard system sound, exclamation
		else
			SoundPlay, *16		;standard system sound, hand (stop/error)
		ShiftCounter 			:= 0
	,	f_ShiftPressed 		:= false
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Diacritics(v_Char)
{
	global	;assume-global mode of operation
; 		,	a_BaseKey 		:= []
; 		,	a_Diacritic		:= []
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	local	index := 0
		,	value := ""

	for index, value in a_BaseKey
		if (value == v_Char)	;Case sensitive comparison
			F_DiacriticOutput(a_Diacritic[index])
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DiacriticOutput(Diacritic)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	SendLevel, 	2
	Send,		% "{BS}" . Diacritic
	SendLevel, 	0
	f_ShiftPressed 		:= false
,	f_Char 				:= false
,	v_Char				:= ""
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{	;This function detects only "characters" according to AutoHotkey rules, what means: not modifiers (Shifts, Controls, Alts, Windows), function keys, ; yes: Esc, Space, Enter, Tab and all other main keys.
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
	f_Char := true
,	v_Char := Char
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

	IniRead, f_ShiftFunctions, 	% v_ConfigIni, Global, OverallStatus
	IniRead, f_Capital, 		% v_ConfigIni, Global, ShiftCapital
	IniRead, f_Diacritics, 		% v_ConfigIni, Global, ShiftDiacritics
	IniRead, f_CapsLock, 		% v_ConfigIni, Global, ShiftCapsLock

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