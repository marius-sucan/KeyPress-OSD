; KeypressOSD.ahk - typing aid file
; This thread binds to letters, numbers and symbols
; It is reloaded each time the keyboard layout changes.
; This helps to avoid the complete reload of the
; main thread and consequently, all its other threads.
; The thread only calls functions found in the main thread.
;
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

#SingleInstance force
#MaxHotkeysPerInterval 500
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxThreadsBuffer On
#NoTrayIcon
#NoEnv
#Persistent
SetKeyDelay, -1
SetMouseDelay, -1

Global IsTypingAidFile    := 1
 , DoNotBindDeadKeys      := 0
 , DoNotBindAltGrDeadKeys := 0
 , AudioAlerts            := 0     ; generate beeps when key bindings fail
 , EnableAltGr            := 1
 , DisableTypingMode      := 0
 , HideAnnoyingKeys       := 1
 , SafeModeExec           := 0
 , NoRestartLangChange    := 0

, DeadKeys := 1
, DKaltGR_list
, DKnotShifted_list
, DKshift_list
, AllDKsList := ""
, moduleInitialized := 0
, ScriptelSuspendel, PrefOpen := 0
, moduleLoaded := 1
, MainExe := AhkExported()
, mainScriptHasInit := 0
, regedKBDhotkeys := ""


Return

TypingKeysFullInit() {
   AudioAlerts := MainExe.ahkgetvar.AudioAlerts
   DeadKeys := MainExe.ahkgetvar.DeadKeys
   DisableTypingMode := MainExe.ahkgetvar.DisableTypingMode
   DKaltGR_list := MainExe.ahkgetvar.DKaltGR_list
   DKnotShifted_list := MainExe.ahkgetvar.DKnotShifted_list
   DKshift_list := MainExe.ahkgetvar.DKshift_list
   DoNotBindAltGrDeadKeys := MainExe.ahkgetvar.DoNotBindAltGrDeadKeys
   DoNotBindDeadKeys := MainExe.ahkgetvar.DoNotBindDeadKeys
   EnableAltGr := MainExe.ahkgetvar.EnableAltGr
   HideAnnoyingKeys := MainExe.ahkgetvar.HideAnnoyingKeys
   SafeModeExec := MainExe.ahkgetvar.SafeModeExec
   NoRestartLangChange := MainExe.ahkgetvar.NoRestartLangChange
   Sleep, 50
   If (SafeModeExec=0 && NoRestartLangChange=1)
      TypingKeysInit()
}

TypingKeysInit() {

     Static AllMods_list := ["!", "!#", "!#^", "!#^+", "!+", "#!+", "#!^", "#", "#+", "#+^", "#^", "+", "+<^>!", "+^!", "+^", "<^>!", "^!", "^"]
     AllDKsList := DKaltGR_list "." DKshift_list "." DKnotShifted_list
     If (EnableAltGr=0)
        AllDKsList := DKshift_list "." DKnotShifted_list

    Loop, 256
    {
        k := A_Index
        code := Format("{:x}", k)
        n := GetKeyName("vk" code)

        If (n = "")
           n := GetKeyChar("vk" code)

        If (n = " ") || (n = "") || (StrLen(n)>1)
           Continue

        If (DeadKeys=1)
        {
           For each, char2skip in StrSplit(AllDKsList, ".")        ; dead keys to ignore
           {
               If (InStr(char2skip, "vk" code) && DoNotBindDeadKeys=0)
               || (InStr(char2skip, "vk" code) && DoNotBindDeadKeys=1
               && DoNotBindAltGrDeadKeys=0 && InStr(DKaltGR_list, "vk" code))
               {
                  For i, mod in AllMods_list
                  {
                      Hotkey, % "~vk" code, OnLetterPressed, useErrorLevel
                      Hotkey, % "~vk" code " Up", OnLetterUp, useErrorLevel
                      Hotkey, % "~" mod "vk" code, OnLetterPressed, useErrorLevel
               ;      If ((mod ~= "i)^(\#|^|\!|\+\^\!|\+\^)$") && code>29 && code<40)
                         Hotkey, % "~" mod "vk" code " Up", OnLetterUp, useErrorLevel
                  }
                  Continue, 2
               }
               If InStr(char2skip, "vk" code)
                  Continue, 2
           }
        }
 
        Hotkey, % "~*vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~*vk" code " Up", OnLetterUp, useErrorLevel
        If (DisableTypingMode=0)
        {
           Hotkey, % "~+vk" code, OnLetterPressed, useErrorLevel
           Hotkey, % "~^!vk" code, OnLetterPressed, useErrorLevel
           Hotkey, % "~<^>!vk" code, OnLetterPressed, useErrorLevel
           Hotkey, % "~+^!vk" code, OnLetterPressed, useErrorLevel
           Hotkey, % "~+<^>!vk" code, OnLetterPressed, useErrorLevel
        }
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

; bind to dead keys to show the proper symbol when such a key is pressed
    If (DeadKeys=1 && DoNotBindDeadKeys=0)
    {
       For each, char2bind in StrSplit(DKshift_list, ".")
           Hotkey, % "~+" char2bind, OnDeadKeyPressed, useErrorLevel

       For each, char2bind in StrSplit(DKnotShifted_list, ".")
           Hotkey, % "~" char2bind, OnDeadKeyPressed, useErrorLevel
    }

    If (EnableAltGr=1 && DeadKeys=1
    && (DoNotBindDeadKeys=0 || DoNotBindAltGrDeadKeys=0))
    {
       For each, char2bind in StrSplit(DKaltGR_list, ".")
       {
           Hotkey, % "~^!" char2bind, OnAltGrDeadKeyPressed, useErrorLevel
           Hotkey, % "~+^!" char2bind, OnAltGrDeadKeyPressed, useErrorLevel
           Hotkey, % "~<^>!" char2bind, OnAltGrDeadKeyPressed, useErrorLevel
       }
       If (ErrorLevel!=0 && AudioAlerts=1)
          SoundBeep, 1900, 50
    }

    If (DisableTypingMode=0)   ; do not mess with Ctrl + A / C / V / X / Z
    {
       Hotkey, ~^vk41, dummy, useErrorLevel
       Hotkey, ~^vk43, dummy, useErrorLevel
       Hotkey, ~^vk56, dummy, useErrorLevel
       Hotkey, ~^vk58, dummy, useErrorLevel
       Hotkey, ~^vk5A, dummy, useErrorLevel
       Hotkey, ~^vk53, dummy, useErrorLevel
       Hotkey, ~Space, OnSpacePushed, useErrorLevel
    }

    If (HideAnnoyingKeys=1) ; do not mess with screenshot in Win 10
      Hotkey, ~#+s, hideMainOSD, useErrorLevel

    moduleInitialized := 1
}

registerDummyHotkeys() {
   For each, HotKate in StrSplit(regedKBDhotkeys, "²")
   {
       If StrLen(HotKate)<1
          Continue
       lineArr := StrSplit(HotKate, "¹")
       ; MsgBox, % HotKate "`n" lineArr[1]
       Hotkey, % lineArr[1], MainHotkeysCaller, UseErrorLevel
   }
}

MainHotkeysCaller() {
   If (ScriptelSuspendel="Y" || PrefOpen=1)
      Return

   For each, HotKate in StrSplit(regedKBDhotkeys, "²")
   {
       If StrLen(HotKate)<1
          Continue
       lineArr := StrSplit(HotKate, "¹")
       ; MsgBox, % A_ThisHotkey "=" lineArr[1]
       If (A_ThisHotkey=lineArr[1])
       {
          callThis := lineArr[2]
          MainExe.ahkPostFunction[callThis]
       }
   } 
}

GetKeyChar(key) {
; <tmplinshi>: thanks to Lexikos:
; https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236

    If (key ~= "i)^(vk)")
    {
       vk := "0x0" SubStr(key, InStr(key, "vk", 0, 0)+2)
       sc := "0x0" GetKeySc("vk" vk)
    } Else If (StrLen(key)>7)
    {
       sc := SubStr(key, InStr(key, "sc")+2, 3) + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 2)
       vk := vk + 0
    } Else
    {
       sc := GetKeySC(key)
       vk := GetKeyVK(key)
    }
    nsa := DllCall("user32\MapVirtualKeyW", "UInt", vk, "UInt", 2)
    If (nsa<=0 && DeadKeys=0)
       Return

    thread := DllCall("user32\GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0)
    hkl := DllCall("user32\GetKeyboardLayout", "UInt", thread, "Ptr")
    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)
    Loop, 2
        n := DllCall("user32\ToUnicodeEx"
          , "UInt", vk
          , "UInt", sc
          , "Ptr", &state
          , "Ptr", &char
          , "Int", 2
          , "UInt", 0
          , "Ptr", hkl)

    Return StrGet(&char, n, "utf-16")
}

hideMainOSD() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkPostFunction("HideGUI")
}

OnLetterPressed() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkFunction("OnLetterPressed", 0, A_ThisHotkey)
}

OnLetterUp() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkFunction("OnLetterUp", A_ThisHotkey, A_PriorHotkey)
}

OnAltGrDeadKeyPressed() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkFunction("OnAltGrDeadKeyPressed", A_ThisHotkey)
}

OnSpacePushed() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkFunction("OnSpacePressed", A_ThisHotkey)
}

OnDeadKeyPressed() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return
  MainExe.ahkFunction("OnDeadKeyPressed", A_ThisHotkey)
}

dummy() {
  Return
}
