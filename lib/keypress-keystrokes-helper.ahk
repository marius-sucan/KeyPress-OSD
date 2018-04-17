; KeypressOSD.ahk - file used for alternative hooks
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

; Script based on the tutorials from the AHK documentation
; and TypingAid 2.22 by Maniac.

#SingleInstance force
#Persistent
#NoTrayIcon
#NoEnv
#MaxHotkeysPerInterval 500
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxThreadsBuffer On
SetBatchLines, -1
ListLines, Off
Critical, on

Global IniFile            := "keypress-osd.ini"
 , AltHook2keysUser := 1
 , ScriptelSuspendel := 0
 , isKeystrokesFile := 1
 , AlternativeHook2keys := (AltHook2keysUser=0) ? 0 : 1
 , TargetScriptTitle := "KeyPressOSDwin"

MainLoop()
Return

MainLoop() {
   Loop 
   {
      ; Get one key at a time 
      ; Input, InputChar, L1 B V E I, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
      Input, InputChar, L1 B V E I, {tab}
      EndKey := ErrorLevel
      ; ToolTip, %inputchar%
      If (AlternativeHook2keys=0)
      {
         hasEnded := 1
         Break
      }
      If RegExMatch(InputChar, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
         Send_WM_COPYDATA(InputChar, TargetScriptTitle)
   }
   If (hasEnded!=1)
      MainLoop()
}

; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle) {
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    TimeOutTime := 3000  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    ; Must use SendMessage not PostMessage.
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%,,,, %TimeOutTime% ; 0x4a is WM_COPYDATA.
    Return
}
