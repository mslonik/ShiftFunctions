#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.
#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.

 AppVersion				:= "1.0.0"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/PolishDiacritic
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
,	ApplicationName     := "PolishDiacritic"	;global variable
,	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global variable
,	f_ControlPressed	:= false	;global variable
,	f_AltPressed		:= false	;global variable
,	f_WinPressed		:= false	;global variable
,	f_AnyOtherKey		:= false	;global variable

SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OnKeyUp()

Menu, Tray, Icon, imageres.dll, 123     ; this line will turn the H icon into a small red a letter-looking thing.
F_InitiateInputHook()
;end initialization section

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputH 			:= InputHook("V I2 L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyUp(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	; OutputDebug, % "WWUb:" . WhatWasUp . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	if ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
		and (f_ShiftPressed) and !(f_ControlPressed) and !(f_AltPressed) and !(f_WinPressed) and !(f_AnyOtherKey)
	{
		Switch v_Char
		{
			Case "a":	DiacriticOutput("ą")
			Case "A":	DiacriticOutput("Ą")
			Case "c": DiacriticOutput("ć")
			Case "C": DiacriticOutput("Ć")
			Case "e": DiacriticOutput("ę")
			Case "E": DiacriticOutput("Ę")
			Case "l": DiacriticOutput("ł")
			Case "L": DiacriticOutput("Ł")
			Case "n": DiacriticOutput("ń")
			Case "N": DiacriticOutput("Ń")
			Case "o": DiacriticOutput("ó")
			Case "O": DiacriticOutput("Ó")
			Case "s": DiacriticOutput("ś")
			Case "S": DiacriticOutput("Ś")
			Case "x": DiacriticOutput("ź")
			Case "X": DiacriticOutput("Ź")
			Case "z": DiacriticOutput("ż")
			Case "Z": DiacriticOutput("Ż")
		}
		f_ShiftPressed := false
	}
	if ((WhatWasUp != "LShift") and (WhatWasUp != "RShift"))
		and (!f_ShiftPressed)
		; or (!f_ShiftPressed) or (f_ControlPressed) or (f_AltPressed) or (f_WinPressed) or (f_AnyOtherKey)
	{
		f_ControlPressed 	:= false
,		f_AltPressed		:= false
,		f_WinPressed		:= false
,		f_AnyOtherKey		:= false
	}
	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DiacriticOutput(Diacritic)
{
	SendLevel, 	2
	Send, 		% "{BS}" . Diacritic
	SendLevel, 	0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{
	global	;assume-global mode of operation

	f_ShiftPressed 	:= false
,	f_ControlPressed 	:= false
,	f_AltPressed		:= false
,	f_WinPressed		:= false
,	f_AnyOtherKey		:= false
,	v_Char 			:= Char
	; OutputDebug, % A_ThisFunc . A_Space . "v_Char:" . v_Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -