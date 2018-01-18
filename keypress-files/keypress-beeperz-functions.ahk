; KeypressOSD.ahk - beepers functions file
; Latest version at:
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

#Persistent
#NoTrayIcon
#SingleInstance force
#NoEnv
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxHotkeysPerInterval 500
SetWorkingDir, %A_ScriptDir%

global LowVolBeeps           := 1
 , ToggleKeysBeeper      := 1
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , beepFiringKeys        := 0
 , TypingBeepers         := 0
 , DTMFbeepers           := 0
 , LowVolBeeps           := 1
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0
 , SilentMode     := 0
 , lastKeyUpTime := 0
 , lastModPressTime := 0
 , lastModPressTime2 := 0
 , LastFiredTime := 0
 , toggleLastState := 0
 , skipAbeep := 0

  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, SilentMode, %inifile%, SavedSettings, SilentMode, %SilentMode%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, beepFiringKeys, %inifile%, SavedSettings, beepFiringKeys, %beepFiringKeys%
  IniRead, CapslockBeeper, %inifile%, SavedSettings, CapslockBeeper, %CapslockBeeper%
  IniRead, TypingBeepers, %inifile%, SavedSettings, TypingBeepers, %TypingBeepers%
  IniRead, DTMFbeepers, %inifile%, SavedSettings, DTMFbeepers, %DTMFbeepers%
  IniRead, ToggleKeysBeeper, %inifile%, SavedSettings, ToggleKeysBeeper, %ToggleKeysBeeper%
  IniRead, LowVolBeeps, %inifile%, SavedSettings, LowVolBeeps, %LowVolBeeps%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, prioritizeBeepers, %inifile%, SavedSettings, prioritizeBeepers, %prioritizeBeepers%

if (ScriptelSuspendel=1) || (SilentMode=1)
   Return

CreateHotkey()

CreateHotkey() {
    #MaxThreads 255
    #MaxThreadsPerHotkey 255
    #MaxThreadsBuffer On

    if (MouseBeeper=1)
    {
       Loop, Parse, % "LButton|MButton|RButton|WheelDown|WheelUp|WheelLeft|WheelRight", |
             Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
    }

    if ((keyBeeper=1) || (beepFiringKeys=1))
    {
        Loop, 24 ; F1-F24
        {
           Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
           Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
        }

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        Loop, parse, NumpadKeysList, |
        {
           Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }

        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
        {
            Hotkey, % "~*Numpad" A_Index - 1, OnKeyPressed, UseErrorLevel
            Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        }

        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"

        Loop, parse, NumpadSymbols, |
        {
           Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }

        Otherkeys := "XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
                   . "|Left|Right|Down|Up|End|Home|PgUp|PgDn|Space|Del|BackSpace|Insert|CapsLock|ScrollLock|NumLock|Pause|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pausesc146|sc123"
        Loop, parse, Otherkeys, |
        {
            Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
            Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }
    }

    if (ToggleKeysBeeper=1)
    {
        ToggleKeys := "CapsLock|ScrollLock|NumLock"
        Loop, parse, ToggleKeys, |
              Hotkey, % "~*" A_LoopField " Up", OnToggleUp, useErrorLevel
    }

    if (TypingBeepers=1) && (keyBeeper=1)
    {

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
        Loop, parse, NumpadKeysList, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, parse, NumpadSymbols, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsGeneralUp, UseErrorLevel

        Loop, 24 ; F1-F24
              Hotkey, % "~*F" A_Index " Up", OnFunctionKeyUp, useErrorLevel

        TypingKeys := "Right|Up|Home|PgUp|Insert"
        TypingKeys2 := "NumpadEnter|Enter"
        TypingKeys3 := "Esc|PrintScreen|CtrlBreak|AppsKey"
        TypingKeys4 := "Tab|Space"
        TypingKeys5 := "Left|Down|End|PgDn"
        Hotkey, ~*Del Up, OnTypingKeysDelUp, useErrorLevel
        Hotkey, ~*BackSpace Up, OnTypingKeysBkspUp, useErrorLevel
        Loop, parse, TypingKeys, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeysUp, useErrorLevel
        Loop, parse, TypingKeys2, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeysEnterUp, useErrorLevel
        Loop, parse, TypingKeys3, |
            Hotkey, % "~*" A_LoopField " Up", OnFunctionKeyUp, useErrorLevel
        Loop, parse, TypingKeys4, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeysSpaceUp, useErrorLevel
        Loop, parse, TypingKeys5, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeys5Up, useErrorLevel

        MediaKeys := "Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause"
        Loop, parse, MediaKeys, |
            Hotkey, % "~*" A_LoopField, OnMediaPressed, useErrorLevel

    }

    If ((modBeeper=1) || (beepFiringKeys=1))
    {
        for i, mod in ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        {
          Hotkey, % "~*" mod, OnModPressed, useErrorLevel
          Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        }
    }

    if (DTMFbeepers=1)
    {
        Hotkey, ~*NumpadDot Up, OnNumpadsDTMFUp, useErrorLevel
        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsDTMFUp, UseErrorLevel
    }
}

OnKeyPressed() {
    Thread, priority, -30

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 20, -20
}

OnModPressed() {
    Thread, priority, -30

    if (beepFiringKeys=1) && (A_TickCount-lastModPressTime < 350)
       SetTimer, modfiredBeeperTimer, 20, -20

    if (A_TickCount-lastModPressTime < 350) || (skipAbeep=1)
    {
       skipAbeep := 0
       global lastModPressTime := A_TickCount
       Return
    }

    if (ModBeeper = 1) && (A_TickCount-lastKeyUpTime > 100) && (A_TickCount-lastModPressTime2 > 350)
       modsBeeper()

    global lastModPressTime2 := A_TickCount
}

OnMediaPressed() {
   Thread, priority, -10
   SetTimer, volBeeperTimer, 30, -20
}

OnKeyUp() {
    Critical, on
    global lastKeyUpTime := A_TickCount
    if (keyBeeper=1)
       keysBeeper()
    checkIfSkipAbeep()
}

OnToggleUp() {
    Critical, on
    global lastKeyUpTime := A_TickCount
    toggleLastState := (toggleLastState=1) ? 0 : 1
    toggleBeeper()
    checkIfSkipAbeep()
}

OnTypingKeysUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysA%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 800, 45
   checkIfSkipAbeep()
}

OnFunctionKeyUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\functionKeys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 750, 65
   checkIfSkipAbeep()
}

OnNumpadsGeneralUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\numpads%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 950, 95
   checkIfSkipAbeep()
}

OnNumpadsDTMFUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   sound2PlayNow := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, "ad")+2, 1)

   if InStr(A_ThisHotkey, "dot")
      sound2PlayNow := "A"

   SoundPlay, sounds\num%sound2PlayNow%pad%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 950, 95
   checkIfSkipAbeep()
}

OnTypingKeysEnterUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysEnter%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 350, 75
   checkIfSkipAbeep()
}
OnTypingKeysDelUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysDel%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 700, 75
   checkIfSkipAbeep()
}
OnTypingKeysBkspUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysBksp%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 770, 45
   checkIfSkipAbeep()
}

OnTypingKeysSpaceUp() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysSpace%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 750, 60
   checkIfSkipAbeep()
}

OnTypingKeys5Up() {
   Critical, on
   global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay, sounds\typingkeysE%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 850, 65

   checkIfSkipAbeep()
}

OnModUp() {
   Thread, Priority, -10
   Critical, off

   if (ModBeeper = 1) && (A_TickCount-lastModPressTime > 250) && (A_TickCount-lastModPressTime2 > 450)
      modsBeeper()
}

toggleBeeper() {
   Sleep, 15
   if (toggleLastState=1)
   {
      SoundPlay, sounds\caps%LowVolBeeps%.wav, %prioritizeBeepers%
   } else
   {
      SoundPlay, sounds\cups%LowVolBeeps%.wav, %prioritizeBeepers%
   }

   if (ErrorLevel=1) && (toggleLastState=0)
      soundbeep, 490, 100

   if (ErrorLevel=1) && (toggleLastState=1)
      soundbeep, 450, 120
}

capsBeeper() {
   Sleep, 15
   SoundPlay, sounds\caps%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, capsBeeperTimer, 60, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 450, 120
}

capsBeeperTimer() {
   soundbeep, 450, 120
   SetTimer, , off
}

keysBeeper() {
   Sleep, 15
   SoundPlay, sounds\keys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, keysBeeperTimer, 60, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1900, 45
}

keysBeeperTimer() {
   soundbeep, 1900, 45
   SetTimer, , off
}

volBeeperTimer() {
   Thread, priority, -10
   if (A_TickCount-lastKeyUpTime < 700) && (keyBeeper=1)
   {
      SetTimer, , off
      Return
   }

   Sleep, 15
   SoundPlay, sounds\media%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1)
      soundbeep, 150, 40
   SetTimer, , off
}

deadKeysBeeper() {
   SoundPlay, sounds\deadkeys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, deadKeysBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 600, 40
}

deadKeysBeeperTimer() {
   soundbeep, 600, 40
   SetTimer, , off
}

modsBeeper() {
   Thread, Priority, -10
   Critical, off

   global lastModPressTime := A_TickCount
   SoundPlay, sounds\mods%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, modsBeeperTimer, 100, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1000, 65
}

modsBeeperTimer() {
   if (A_TickCount-lastModPressTime < 200)
   {
      SetTimer, , off
      Return
   }

   soundbeep, 1000, 65
   SetTimer, , off
}

firedBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   if (A_TickCount-lastKeyUpTime < 600) && (keyBeeper=1)
   {
      SetTimer, , off
      Return
   }

   if (A_TickCount-LastFiredTime > 100) && (keyBeeper=1)
   {
      Sleep, 20
      global LastFiredTime := A_TickCount
      SetTimer, , off
      Return
   }
   SoundPlay, sounds\firedkey%LowVolBeeps%.wav
   Sleep, 40
   if (ErrorLevel=1)
      soundbeep, 500, 25
   global LastFiredTime := A_TickCount

   SetTimer, , off
}

modfiredBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   if (A_TickCount-LastFiredTime < 200) && (keyBeeper=1)
   {
      Sleep, 20
      SetTimer, , off
      Return
   }
   SoundPlay, sounds\modfiredkey%LowVolBeeps%.wav
   Sleep, 40
   if (ErrorLevel=1)
      soundbeep, 500, 25
   global LastFiredTime := A_TickCount

   SetTimer, , off
}

OnLetterPressed() {
    Critical, on
    if (ScriptelSuspendel=1) || (SilentMode=1)
       Return

    GetKeyState, CapsState, CapsLock, T
    if (CapslockBeeper = 1)
    {
        If (CapsState = "D")
           {
               capsBeeper()
           }
           else if (KeyBeeper = 1)
           {
               keysBeeper()
           }
    }

    If (CapslockBeeper = 0) && (KeyBeeper = 1) && (SilentMode=0)
        keysBeeper()

    checkIfSkipAbeep()
}

OnDeathKeyPressed() {
  if (ScriptelSuspendel=1) || (SilentMode=1)
     Return
  Critical, on
  deadKeysBeeper()
  checkIfSkipAbeep()
}

clickyBeeperTimer() {
   soundbeep, 2500, 70
   SetTimer, , off
}

OnMousePressed() {
    Critical, Off
    Thread, Priority, -50
    if (silentMode=1)
       Return

    if (MouseBeeper = 1) && (A_ThisHotkey ~= "i)(LButton|MButton|RButton)")
    {
       SoundPlay, sounds\clicks%LowVolBeeps%.wav
       if (ErrorLevel=1)
          SetTimer, clickyBeeperTimer, 15, -20
    } else if (MouseBeeper = 1) && (A_ThisHotkey ~= "i)(WheelDown|WheelUp|WheelLeft|WheelRight)")
    {
       SoundPlay, sounds\firedkey%LowVolBeeps%.wav
       if (ErrorLevel=1)
          SetTimer, firedBeeperTimer, 20, -20
       Sleep, 40
    }

}

checkIfSkipAbeep() {
    skipAbeep := 0
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]

    for i, mod in modifiers
    {
        if GetKeyState(mod)
           skipAbeep := 1
    }
}

firingKeys() {
   Thread, Priority, -20
   Critical, off

   SoundPlay, sounds\modfiredkey%LowVolBeeps%.wav
   Sleep, 20
}
