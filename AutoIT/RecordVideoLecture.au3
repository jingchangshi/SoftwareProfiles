#region --- Au3Recorder generated code Start (v3.3.9.5 KeyboardLayout=00000409)  ---

#region --- Internal functions Au3Recorder Start ---
Func _Au3RecordSetup()
Opt('WinWaitDelay',100)
Opt('WinDetectHiddenText',1)
Opt('MouseCoordMode',1)
;~ Local $aResult = DllCall('User32.dll', 'int', 'GetKeyboardLayoutNameW', 'wstr', '')
;~ If $aResult[1] <> '00000409' Then
;~   MsgBox(64, 'Warning', 'Recording has been done under a different Keyboard layout' & @CRLF & '(00000409->' & $aResult[1] & ')')
;~ EndIf

EndFunc

Func _WinWaitActivate($title,$text,$timeout=0)
	WinWait($title,$text,$timeout)
	If Not WinActive($title,$text) Then WinActivate($title,$text)
	WinWaitActive($title,$text,$timeout)
EndFunc

_AU3RecordSetup()
#endregion --- Internal functions Au3Recorder End ---

; Open video conference program
;~ _WinWaitActivate("Program Manager","")
;~ Run("C:\Program Files (x86)\Tencent\WeMeet\wemeetapp.exe", "", @SW_MAXIMIZE)
;~ Sleep(3000)
;~ MouseClick("left",960,300,1)
;~ Sleep(1000)
;~ MouseClick("left",1400,225,1)
;~ Sleep(1000)
; Open XBox Game Bar to do screen recording
Send("#!r")
Sleep(3600000)
Send("#!r")
; Close Tencent meeting
;~ MouseClick("left",1850,1010,1)
;~ MouseClick("left",960,580,1)

; Sleep(3000)
;~ Run("rundll32.exe user32.dll LockWorkStation")
; Hibernate
; Shutdown(64)


#endregion --- Au3Recorder generated code End ---
