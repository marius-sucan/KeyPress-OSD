; KeypressOSD.ahk - file used for alternative hooks
; The role of this thread is to capture characters
; [using the Input command in a Loop]; resulted from
; combinations with dead keys. Each char is sent to
; the main thread using SendMessage.
;
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
DetectHiddenWindows, On
SetBatchLines, -1
ListLines, Off
Critical, on

Global IniFile := "keypress-osd.ini"
 , ScriptelSuspendel := 0
 , isKeystrokesFile := 1
 , AlternativeHook2keys := (AltHook2keysUser=0) ? 0 : 1
 , MainExe := AhkExported()
 , DoNotBindDeadKeys := MainExe.ahkgetvar.DoNotBindDeadKeys
 , AltHook2keysUser := MainExe.ahkgetvar.AltHook2keysUser

If (DoNotBindDeadKeys=0 && AltHook2keysUser=1)
   MainLoop()
Return

MainLoop() {
   Loop 
   {
      Input, InputChar, L1 B V E I, {tab}
      EndKey := ErrorLevel
;      SoundBeep
      If (AlternativeHook2keys=0 || AltHook2keysUser=0
      || DoNotBindDeadKeys=1)
      {
         hasEnded := 1
         Break
      }
;      ToolTip, %InputChar%
      If RegExMatch(InputChar, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
         MainExe.ahkassign("ExternalKeyStrokeRecvd", InputChar)
   }

   If (hasEnded!=1)
      MainLoop()
}

