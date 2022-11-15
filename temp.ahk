#MaxHotkeysPerInterval, 1000
#InstallKeybdHook
#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; $Shift::
; Input, vText, L1 I
; if (ErrorLevel = "Timeout")
     ; return
; SendInput, +{%vText%}
; return

~$Shift::
     OutputDebug, % "SDown" . "`n"
     SendInput, {Shift Down}
return

~$Shift UP::
     OutputDebug, % "SUp" . "`n"
     SendInput, {Shift Up}
return