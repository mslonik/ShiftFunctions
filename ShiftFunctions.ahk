 #SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.
#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.
#KeyHistory, 100

;Testing: Alt+Tab, Asi, asdf Shift+Home

 AppVersion			:= "1.0.2"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/ShiftDiacritic
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
;@Ahk2Exe-ConsoleApp
	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global flag, set when any Shift key (left or right) was pressed.
,	f_ControlPressed	:= false	;global flag, set when any Control key (left or right) was pressed.
,	f_AltPressed		:= false	;global flag, set when any Alt key (left or right) was pressed.
,	f_WinPressed		:= false	;global flag, set when any Windows key (left or right) was pressed.
,	f_AnyOtherKey		:= false	;global flag
,	f_Char			:= false	;global flag, set when printable character was pressed down (and not yet released).
,	f_ShiftFunctions	:= true	;global flag, state of InputHook
,	f_Capital			:= true	;global flag: enable / disable function Shift Capital
,	f_Diacritics		:= true	;global flag: enable / disable function Shift Diacritics
,	f_CapsLock		:= true	;global flag: enable / disable function Shift CapsLock

SetBatchLines, 	-1				; Never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OnKeyUp()

F_InputArguments()
F_InitiateInputHook()
MenuTray()
;end initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sfhelp/::
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . "information", % "Application hotstrings" . "." . A_Space . "All of them are ""immediate execute"" (*)" . "`n"
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
		. "sfcdisable/" . A_Tab .		"disable"	. A_Space . "shift capital"			. "`n"
		. "sfcenable/" . A_Tab .			"enable"	. A_Space . "shift capital"			. "`n"
		. "sfldisable/" . A_Tab .		"disable" . A_Space . "shift CapsLock"			. "`n"
		. "sflenable/" . A_Tab .			"enable"	. A_Space . "shift CapsLock"
return

:*:sfreload/::
:*:sfrestart/::     ;global hotstring
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
	reload
return

:*:sfstop/::
:*:sfquit/::
:*:sfexit/::
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
	v_InputH.Start()
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
return

:*:sfdisable/::
	v_InputH.Stop()
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
return

:*:sfddisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := f_Diacritics, FunctionName := "Shift Diacritics")
return

:*:sfdenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := f_Diacritics, FunctionName := "Shift Diacritics")
return

:*:sfcdisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := f_Capital, FunctionName := "Shift Capital")
return

:*:sfcenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := f_Capital, FunctionName := "Shift Capital")
return

:*:sfldisable/::
	F_sfparamendis(WhatNext := false, WhichVariable := f_CapsLock, FunctionName := "Shift CapsLock")
return

:*:sflenable/::
	F_sfparamendis(WhatNext := true, WhichVariable := f_CapsLock, FunctionName := "Shift CapsLock")
return
; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - DEFINITIONS OF FUNCTIONS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_sfparamendis(WhatNext, ByRef WhichVariable, FunctionName)
{
	global	;assume-globa mode of operation
	local 	OldValue := WhichVariable

	WhichVariable := WhatNext
	Menu, Tray, Rename, % "function" . A_Space . FunctionName . ":" . A_Tab . (OldValue ? "ENABLED" : "DISABLED"), % "function" . A_Space . FunctionName . ":"  . A_Tab . (WhichVariable ? "ENABLED" : "DISABLED")
	MsgBox, 64, % A_ScriptName, % FunctionName . A_Space . "is" . A_Space . (WhichVariable ? "ENABLED" : "DISABLED")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Status()
{
	global	;assume-globa mode of operation
	local 	OldStatus := f_ShiftFunctions
	Menu, Tray, Rename, % A_ScriptName . A_Space . "status:" . A_Space . (OldStatus ? "ENABLED" : "DISABLED"), % A_ScriptName . A_Space . "status:" . A_Space . (f_ShiftFunctions ? "ENABLED" : "DISABLED")
	MsgBox, 64, % A_ScriptName, % "Current status is" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED")
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
	Menu, Tray, Rename, % A_ScriptName . A_Space . "status:" . A_Space . (OldStatus ? "ENABLED" : "DISABLED"), % A_ScriptName . A_Space . "status:" . A_Space . (f_ShiftFunctions ? "ENABLED" : "DISABLED")
	if (f_ShiftFunctions)
	{
		v_InputH.Start()
		f_Capital			:= true
	,	f_Diacritics		:= true
	,	f_CapsLock		:= true
		Menu, Tray, Rename, % "function Shift Capital:" . A_Tab . 		(OldCapital ? "ENABLED" : "DISABLED"),		% "function Shift Capital:" . A_Tab . 		(f_Capital ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift Diacritics:" . A_Tab . 	(OldDiacritics ? "ENABLED" : "DISABLED"),	% "function Shift Diacritics:" . A_Tab . 	(f_Diacritics ? "ENABLED" : "DISABLED")
		Menu, Tray, Rename, % "function Shift CapsLock:" . A_Tab . 		(OldCapslock ? "ENABLED" : "DISABLED"),		% "function Shift CapsLock:" . A_Tab . 		(f_CapsLock ? "ENABLED" : "DISABLED")
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
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
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Capital()
{
	global	;assume-global mode of operation

	SendLevel, 2
	Switch v_Char
	{
		Case "``":
			v_InputH.VisibleText := true
			SendInput, ~
		Case "1":
			v_InputH.VisibleText := true
			SendInput, {!}
		Case "2":
			v_InputH.VisibleText := true
			SendInput, @
		Case "3":
			v_InputH.VisibleText := true
			SendInput, {#}
		Case "4":
			v_InputH.VisibleText := true
			SendInput, $
		Case "5":
			v_InputH.VisibleText := true
			SendInput, `%
		Case "6":
			v_InputH.VisibleText := true
			SendInput, {^}
		Case "7":
			v_InputH.VisibleText := true
			SendInput, &
		Case "8":
			v_InputH.VisibleText := true
			SendInput, *
		Case "9":
			v_InputH.VisibleText := true
			SendInput, (
		Case "0":
			v_InputH.VisibleText := true
			SendInput, )
		Case "-":
			v_InputH.VisibleText := true
			SendInput, _
		Case "=":
			v_InputH.VisibleText := true
			SendInput, {+}
		Case "[":
			v_InputH.VisibleText := true
			SendInput, {{}
		Case "]":
			v_InputH.VisibleText := true
			SendInput, {}}
		Case "\":
			v_InputH.VisibleText := true
			SendInput, |
		Case ";":
			v_InputH.VisibleText := true
			SendInput, :
		Case "'":
			v_InputH.VisibleText := true
			SendInput, "
		Case ",":
			v_InputH.VisibleText := true
			SendInput, <
		Case ".":
			v_InputH.VisibleText := true
			SendInput, >
		Case "/":
			v_InputH.VisibleText := true
			SendInput, ?
		Default:
			v_Char := Format("{:U}", v_Char)
			v_InputH.VisibleText := true
			SendInput, % v_Char
	}
	SendLevel, 0
	f_ShiftPressed 	:= false
,	v_InputH.VisibleText := true
,	f_Char			:= false

}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MenuTray()
{
	global	;assume-global mode of operation
	
	Menu, Tray, Icon, imageres.dll, 123     ; this line will turn the H icon into a small red a letter-looking thing.
    	Menu, Tray, Add, % A_ScriptName . A_Space . "status:" . A_Space . (f_ShiftFunctions ? "ENABLED" : "DISABLED"),	F_Empty
    	Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
	Menu, Tray, Add, % "function Shift Capital:" . A_Tab . 	(f_Capital ? "ENABLED" : "DISABLED"),				F_Empty
	Menu, Tray, Add, % "function Shift Diacritics:" . A_Tab . 	(f_Diacritics ? "ENABLED" : "DISABLED"),			F_Empty
	Menu, Tray, Add, % "function Shift CapsLock:" . A_Tab . 	(f_CapsLock ? "ENABLED" : "DISABLED"),				F_Empty
	Menu, Tray, Add, About…,																			F_About
    	Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
    	Menu, Tray, Default, % A_ScriptName . A_Space . "status:" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED") ; Default: Changes the menu's default item to be the specified menu item and makes its font bold.
    	Menu, Tray, NoStandard
    	Menu, Tray, Standard
    	Menu, Tray, Tip, % SubStr(A_ScriptName, 1, -4) ; Changes the tray icon's tooltip.
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_About()
{}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Empty()
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
,			v_InputH.VisibleText := false
		Case "LControl", "RControl":
			f_ControlPressed 	:= true
		Case "LAlt", "RAlt":
			f_AltPressed 		:= true
		Case "LWin", "RWin":
			f_WinPressed 		:= true
		; Default:
			; f_AnyOtherKey		:= true
	}
	; OutputDebug, % "WWD:" . WhatWasDown . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
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
				f_ControlPressed 	:= false
			,	v_Char 			:= ""
			,	f_Char			:= false
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
			,	f_WinPressed 		:= false
			,	f_AltPressed 		:= false
				return
			Case "LAlt", "RAlt":		;modifiers
				f_AltPressed 		:= false
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return
			Case "LWin", "RWin":		;modifiers
				f_WinPressed 		:= false
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return 
			Case "Insert", "Home", "PageUp", "Delete", "End", "PageDown", "AppsKey"	;NavPad
			,	"Up", "Down", "Left", "Right":	;11
				f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return
			Case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20":	;20
				f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return
			Case "F21", "F22", "F23", "F24":	;4
				f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return
			Case "Backspace":
				v_Char 			:= ""
			,	f_Char 			:= ""
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
			,	f_WinPressed 		:= false
			,	f_AltPressed 		:= false
			,	f_ControlPressed 	:= false
				return
		}
	}
	; OutputDebug, % "WWU:" . WhatWasUp . A_Space "v_Char:" . v_Char . "C:" . f_Char . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . "`n"

	Switch WhatWasUp	;These are chars, so have to be filtered out separately
		{
			Case "Space", "Enter", "Tab": 	;the rest of not alphanumeric keys
				f_Char := false
			,	v_Char := ""
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
				return
			Case "Escape":
				v_Char 			:= ""
			,	f_Char			:= false
			,	f_ShiftPressed		:= false
			,	v_InputH.VisibleText := true
			,	f_WinPressed 		:= false
			,	f_AltPressed 		:= false
			,	f_ControlPressed 	:= false
				return
		}

	if ((f_ShiftPressed) and (f_WinPressed))
		or ((f_ShiftPressed) and (f_AltPressed))
		or ((f_ShiftPressed) and (f_ControlPressed))
		{
			; OutputDebug, % "Two modifiers at the same time" . "`n"
			f_ShiftPressed		:= false
		,	v_InputH.VisibleText := true	
		,	f_WinPressed 		:= false
		,	f_AltPressed 		:= false
		,	f_ControlPressed 	:= false
			return
		}
	;From this moment I know we have character and only Shift

	if (f_Capital) ;and (f_Char)
		and (f_ShiftPressed)
		and (WhatWasUp != "LShift") and (WhatWasUp != "RShift")
			F_Capital()

	if (f_Diacritics)
		and (f_ShiftPressed)
		and ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
			Diacritics()

	if (f_CapsLock)
		F_DoubleShift(WhatWasUp, f_ShiftPressed)

	; f_Char := false
	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
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
		ShiftCounter 			:= 0
	,	f_ShiftPressed 		:= false
	,	v_InputH.VisibleText 	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Diacritics()
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	Switch v_Char
	{
		Case "a":		DiacriticOutput("ą")
		Case "A":		DiacriticOutput("Ą")
		Case "c": 	DiacriticOutput("ć")
		Case "C": 	DiacriticOutput("Ć")
		Case "e": 	DiacriticOutput("ę")
		Case "E": 	DiacriticOutput("Ę")
		Case "l": 	DiacriticOutput("ł")
		Case "L": 	DiacriticOutput("Ł")
		Case "n": 	DiacriticOutput("ń")
		Case "N": 	DiacriticOutput("Ń")
		Case "o": 	DiacriticOutput("ó")
		Case "O": 	DiacriticOutput("Ó")
		Case "s": 	DiacriticOutput("ś")
		Case "S": 	DiacriticOutput("Ś")
		Case "x": 	DiacriticOutput("ź")
		Case "X": 	DiacriticOutput("Ź")
		Case "z": 	DiacriticOutput("ż")
		Case "Z": 	DiacriticOutput("Ż")
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DiacriticOutput(Diacritic)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	SendLevel, 	2
	Send,		% "{BS}" . Diacritic
	SendLevel, 	0
	f_ShiftPressed 		:= false
,	v_InputH.VisibleText 	:= true
,	f_Char 				:= false
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

	for n, param in A_Args
	{
		if (InStr(param, "-h", false)) or (InStr(param, "/h", false))
			FileAppend, 
(
Shift functions, one parameter per function:

Shift Capital:     press <Shift> and release it, next press and release any letter to get capital version of it.
Shift Diacritics:  press and release any diacritic letter, next press and release <Shift> to get diacritic character.
Shift CapsLock:    press and release <Shift> twice to toggle <CapsLock>.

The following list of runtime / startup parameters is available:

-scdisable  disable "ShiftCapital"
-sddisable  disable "Shift Diacritics"
-scdisable  disable "Shift CapsLock"
-h, /h      this help
-v          show application version

Remark: you can always run application hotstrings. For more info just enter "sfhelp/""
), *	;* = stdout, ** = stderr
	if (InStr(param, "-v", false))
		FileAppend, % AppVersion, *

	if (InStr(param, "-scdisable", false))
		f_Capital := false
	
	if (InStr(param, "-sddisable", false))
		f_Diacritics := false

	if (InStr(param, "-scdisable", false))
		f_CapsLock := false
	}
}