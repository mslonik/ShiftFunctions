#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.

	v_Char 		:= ""	;global variable
,	f_ShiftPressed := false	;global variable
StringCaseSense, On			;for Switch in F_OnKeyUp()
F_InitiateInputHook()
;end initialization section of this script

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputH 			:= InputHook("V I3 L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.OnChar 	:= Func("F_OneCharPressed")
,	v_InputH.OnKeyDown	:= Func("F_OnKeyDown")
,	v_InputH.OnKeyUp 	:= Func("F_OnKeyUp")
	v_InputH.KeyOpt("{LShift}{RShift}", "N")
	v_InputH.Start()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyDown(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasDown := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	if (WhatWasDown = "LShift") or (WhatWasDown = "RShift")
		f_ShiftPressed 		:= true
	; OutputDebug, % A_ThisFunc . A_Space . "WhatWasDown:" . WhatWasDown . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyUp(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	; OutputDebug, % A_ThisFunc . A_Space . "WhatWasUp:" . WhatWasUp . A_Space . "LastChar:" . v_Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"

	if (f_ShiftPressed)
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DiacriticOutput(Diacritic)
{
	SendLevel, 2
	SendInput, % "{BS}" . Diacritic
	SendLevel, 0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "v_Char:" . v_Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
	if (f_ShiftPressed)
		f_ShiftPressed := false

	v_Char := Char
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -