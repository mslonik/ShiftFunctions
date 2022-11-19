#MaxHotkeysPerInterval, 1000
#InstallKeybdHook
#NoEnv
#SingleInstance, Force
SendMode, Input
; SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global flag, set when any Shift key (left or right) was pressed.
,	v_InputH := {}


F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
; v_InputH.VisibleText := false
; Input, OutputVar, "B I3 L0"
return

~$Shift::
     OutputDebug, % "SDown" . "`n"
return

~$Shift UP::
     OutputDebug, % "SUp" . "`n"
return


F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputH 			:= InputHook("B I3 L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
	; v_InputH.OnChar 	:= Func("F_OneCharPressed")
}

F_OneCharPressed(ih, Char)
{	;This function detects only "characters" according to AutoHotkey rules, what means: not modifiers (Shifts, Controls, Alts, Windows), function keys, ; yes: Esc, Space, Enter, Tab and all other main keys.
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	f_Char := true
,	v_Char := Char
	; ih.VisibleText := true
	OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
	if (f_ShiftPressed)
		SendInput, 	% "+" . Char
	else
		SendInput, 	% Char
	f_ShiftPressed := false
	; ih.VisibleText := false
	OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
