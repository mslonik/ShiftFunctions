#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.
#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.
#KeyHistory, 100

 AppVersion				:= "1.0.2"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/ShiftDiacritic
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global variable
,	f_ControlPressed	:= false	;global variable
,	f_AltPressed		:= false	;global variable
,	f_WinPressed		:= false	;global variable
,	f_AnyOtherKey		:= false	;global variable
,	f_Capital			:= true	;global variable
,	f_Diacritics		:= true	;global variable
,	f_CapsLock		:= true	;global variable
,	f_Char			:= false

SetBatchLines, 	-1				; Never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OnKeyUp()

Menu, Tray, Icon, imageres.dll, 123     ; this line will turn the H icon into a small red a letter-looking thing.
F_InitiateInputHook()
;end initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sfhelp/::
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . "information", % "Application hotstrings" . "." . A_Space . "All of them are ""immediate execute"" (*)" . "`n"
		. "and active anywhere in operating system (any window)"						. "`n"
		. "`n`n"
		. "sfhelp/" . A_Tab . A_Tab . 	"shows this message"					 	. "`n"
		. "sfrestart/" . A_Tab . A_Tab	"reload" 	. A_Space . "application"		 	. "`n"
		. "sfreload/" . A_Tab . A_Tab	 	"reload" 	. A_Space . "application"		 	. "`n"
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
		. "sfcenable/" . A_Tab .			"enable"	. A_Space . "shift capital"
return

:*:sfreload/::
:*:sfrestart/::     ;global hotstring
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
	reload
return

:*:sfquit/::
:*:sfexit/::
	ExitApp, 0
return

:*:sfswitch/::
:*:sftoggle/::
	if (v_InputH.InProgress)
	{
		v_InputH.Stop()
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
	}
	else
	{
		v_InputH.Start()
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
	}
return

:*:sfstatus/::
:*:sfstate/::
	MsgBox, 64, % A_ScriptName, % "Current status is" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED")
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
	f_Diacritics := false
	MsgBox, 64, % A_ScriptName, % "Shift diacritics is DISABLED."
return

:*:sfdenable/::
	f_Diacritics := true
	MsgBox, 64, % A_ScriptName, % "Shift diacritics is ENABLED."
return

:*:sfcdisable/::
	f_Capital := false
	MsgBox, 64, % A_ScriptName, % "Shift capital is DISABLED."
return

:*:sfcenable/::
	f_Capital := true
	MsgBox, 64, % A_ScriptName, % "Shift capital is ENABLED."
return
; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - DEFINITIONS OF FUNCTIONS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputH 			:= InputHook("V I3 L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.OnChar 	:= Func("F_OneCharPressed")
,	v_InputH.OnKeyDown	:= Func("F_OnKeyDown")
,	v_InputH.OnKeyUp 	:= Func("F_OnKeyUp")
	v_InputH.KeyOpt("{All}", "N")
	v_InputH.Start()
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
		Default:
			f_AnyOtherKey		:= true
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
	; OutputDebug, % "WWUb:" . WhatWasUp . A_Space "v_Char:" . v_Char . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	Switch WhatWasUp
	{
		Case "LControl", "RControl":	;modifiers
			f_ControlPressed := false
			return
		Case "LAlt", "RAlt":		;modifiers
			f_AltPressed := false
			return
		Case "Lwin", "RWin":		;modifiers
			f_WinPressed := false
			return 
		Case "Backspace", "Space", "Escape", "Enter", "Tab", "Insert", "Home", "PageUp", "Delete", "End", "PageDown", "AppsKey"	;the rest of not alphanumeric keys
			, "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"
			, "Up", "Down", "Left", "Right":
			return
	}

	if (f_Capital) ;and (f_Char)
		and (v_Char)
		and (f_ShiftPressed)
		and (WhatWasUp != "LShift") and (WhatWasUp != "RShift")
		and !(f_ControlPressed) and !(f_AltPressed) and !(f_WinPressed) 
		; and !(f_AnyOtherKey)
		{
			SendLevel, 2
			Switch v_Char
			{
				Case "``": 	SendInput, {BS}~
				Case "1":		SendInput, {BS}{!}
				Case "2":		SendInput, {BS}@
				Case "3":		SendInput, {BS}{#}
				Case "4":		SendInput, {BS}$
				Case "5":		SendInput, {BS}`%
				Case "6":		SendInput, {BS}{^}
				Case "7":		SendInput, {BS}&
				Case "8":		SendInput, {BS}*
				Case "9":		SendInput, {BS}(
				Case "0":		SendInput, {BS})
				Case "-":		SendInput, {BS}_
				Case "=":		SendInput, {BS}{+}
				Case "[":		SendInput, {BS}{{}
				Case "]":		SendInput, {BS}{}}
				Case "\":		SendInput, {BS}|
				Case ";":		SendInput, {BS}:
				Case "'":		SendInput, {BS}"
				Case ",":		SendInput, {BS}<
				Case ".":		SendInput, {BS}>
				Case "/":		SendInput, {BS}?
				Default:
					v_Char := Format("{:U}", v_Char)
					SendInput, % "{BS}" . v_Char
			}
			SendLevel, 0
			f_ShiftPressed 	:= false
			; v_Char			:= ""
; ,			f_Char			:= false
; ,			v_Char 			:= WhatWasUp
		}

	if (f_Diacritics) ;and (f_Char)
		and (v_Char) and (f_ShiftPressed)
		and ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
		and (f_ShiftPressed) and !(f_ControlPressed) and !(f_AltPressed) and !(f_WinPressed) 
		; and !(f_AnyOtherKey)
			Diacritics()

	if (f_CapsLock)
		F_DoubleShift(WhatWasUp, f_ShiftPressed)

	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DoubleShift(WhatWasUp, f_ShiftPressed)
{
	static	ShiftCounter := 0
	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift")) and (f_ShiftPressed)
		ShiftCounter++
	else
		ShiftCounter = 0
	
	; OutputDebug, % "ShiftCounter:" . A_Space . ShiftCounter . "`n"
	if (ShiftCounter = 2)
	{
		SetCapsLockState % !GetKeyState("CapsLock", "T") 
		ShiftCounter = 0
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
	; f_Char 		:= false
; ,	f_ShiftPressed := false
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DiacriticOutput(Diacritic)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; f_ShiftPressed := false
	SendLevel, 	2
	Send,		% "{BS}" . Diacritic
	SendLevel, 	0
	; f_Char 		:= false
	f_ShiftPressed := false
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{
	global	;assume-global mode of operation

	f_Char := true
,	v_Char := Char
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
; 	f_ControlPressed 	:= false
; ,	f_AltPressed		:= false
; ,	f_WinPressed		:= false
; ,	f_AnyOtherKey		:= false
	; OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
	; OutputDebug, % "Char:" . Char . "`n"

	; OutputDebug, % "v_Char:" . v_Char . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
