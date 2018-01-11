; Script based on the tutorials from the AHK documentation
; and TypingAid 2.22 by Maniac

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
DetectHiddenWindows On
SetTitleMatchMode 2
Critical, on

global AltHook2keysUser  := 1
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0

  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, AltHook2keysUser, %inifile%, SavedSettings, AltHook2keysUser, %AltHook2keysUser%

if (ScriptelSuspendel=1) || (AlternativeHook2keys=0)
   Return

MainLoop()

MainLoop() {
   global TargetScriptTitle := "KeypressOSDwin"
   Loop 
   { 
;      Get one key at a time 
;      Input, InputChar, L1 B V E I, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
      Input, InputChar, L1 B V E I, {tab}
      EndKey := ErrorLevel

      Send_WM_COPYDATA(InputChar, TargetScriptTitle)
      if result = FAIL
          Sleep, 1
      else if result = 0
          Sleep, 0
   }
}

; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle) {
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    TimeOutTime = 900  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    ; Must use SendMessage not PostMessage.
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%,,,, %TimeOutTime% ; 0x4a is WM_COPYDATA.
    return
}
