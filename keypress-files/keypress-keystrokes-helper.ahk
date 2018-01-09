; Script based on the tutorials from the AHK documentation
; and TypingAid 2.22 by Maniac

#SingleInstance force
#Persistent
#NoTrayIcon
Critical, on
global AlternativeHook2keys  := 1
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0

  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, AlternativeHook2keys, %inifile%, SavedSettings, AlternativeHook2keys, %AlternativeHook2keys%

if (ScriptelSuspendel=1) || (AlternativeHook2keys=0)
   Return

MainLoop()

MainLoop() {
   global TargetScriptTitle := "KeypressOSDwin"
   Loop 
   { 
      ;Get one key at a time 
      Input, InputChar, L1 B V E I, {Tab}{Space}{BackSpace}{Enter}{esc}
      EndKey := ErrorLevel
      Send_WM_COPYDATA(InputChar, TargetScriptTitle)
      if result = FAIL
          Sleep, 1
      else if result = 0
          Sleep, 0
   }
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)  ; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime = 900  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    ; Must use SendMessage not PostMessage.
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%,,,, %TimeOutTime% ; 0x4a is WM_COPYDATA.
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
    return
}
