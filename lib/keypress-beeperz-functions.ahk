; KeypressOSD.ahk - beepers functions file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
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
#MaxThreadsBuffer On
#MaxHotkeysPerInterval 500
Critical, on
SetWorkingDir, %A_ScriptDir%

Global IniFile           := "keypress-osd.ini"
 , ToggleKeysBeeper      := 1
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , beepFiringKeys        := 0
 , TypingBeepers         := 0
 , DTMFbeepers           := 0
 , BeepSentry            := 0
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall
 , SilentMode            := 0

 , lastKeyUpTime := 0
 , lastModPressTime := 0
 , lastModPressTime2 := 0
 , LastFiredTime := 0
 , toggleLastState := 0
 , skipAbeep := 0
 , IsSoundsFile := 1
 , beepFromRes := 0       ; 1 if compiled and  it looks for the sound files inside the binary
 , ScriptelSuspendel := 0
 , moduleInitialized

Return

CreateHotkey() {
    If (ToggleKeysBeeper=0 && CapslockBeeper=0 && KeyBeeper=0 && ModBeeper=0 && MouseBeeper=0 && beepFiringKeys=0 && TypingBeepers=0 && DTMFbeepers=0) || (SilentMode=1)
       Return

    moduleInitialized := 1
    If (MouseBeeper=1)
    {
       Loop, Parse, % "LButton|MButton|RButton|WheelDown|WheelUp|WheelLeft|WheelRight", |
             Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
    }

    If (keyBeeper=1 || beepFiringKeys=1)
    {
        Loop, 24 ; F1-F24
        {
           Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
           Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
        }

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        Loop, Parse, NumpadKeysList, |
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
        Loop, Parse, NumpadSymbols, |
        {
           Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }

        Otherkeys := "XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
                   . "|Left|Right|Down|Up|End|Home|PgUp|PgDn|Space|Del|BackSpace|Insert|CapsLock|ScrollLock|NumLock|Pause|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|sc146|sc123"
        Loop, Parse, Otherkeys, |
        {
            Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
            Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }
    }

    If (ToggleKeysBeeper=1)
    {
        ToggleKeys := "CapsLock|ScrollLock|NumLock"
        Loop, Parse, ToggleKeys, |
              Hotkey, % "~*" A_LoopField " Up", OnToggleUp, useErrorLevel
    }

    If (TypingBeepers=1 && keyBeeper=1)
    {

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
        Loop, Parse, NumpadKeysList, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, Parse, NumpadSymbols, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsGeneralUp, UseErrorLevel

        Loop, 24 ; F1-F24
              Hotkey, % "~*F" A_Index " Up", OnFunctionKeyUp, useErrorLevel

        Enterz := "NumpadEnter|Enter"
        OtherTypingKeysz := "Tab|Esc|PrintScreen|CtrlBreak|AppsKey|Insert"
        Hotkey, ~*Del Up, OnTypingKeysDelUp, useErrorLevel
        Hotkey, ~*BackSpace Up, OnTypingKeysBkspUp, useErrorLevel
        Hotkey, ~*Space Up, OnTypingKeysSpaceUp, useErrorLevel
        Hotkey, ~*Left Up, OnTypingLeftUp, useErrorLevel
        Hotkey, ~*Right Up, OnTypingRightUp, useErrorLevel
        Hotkey, ~*Home Up, OnTypingHomeUp, useErrorLevel
        Hotkey, ~*End Up, OnTypingEndUp, useErrorLevel
        Hotkey, ~*PgUp Up, OnTypingPgUpUp, useErrorLevel
        Hotkey, ~*PgDn Up, OnTypingPgDnUp, useErrorLevel
        Hotkey, ~*Up Up, OnTypingUpUp, useErrorLevel
        Hotkey, ~*Down Up, OnTypingDnUp, useErrorLevel
        Loop, Parse, Enterz, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeysEnterUp, useErrorLevel
        Loop, Parse, OtherTypingKeysz, |
            Hotkey, % "~*" A_LoopField " Up", OnOtherDistinctKeysUp, useErrorLevel

        MediaKeys := "Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause"
        Loop, Parse, MediaKeys, |
            Hotkey, % "~*" A_LoopField, OnMediaPressed, useErrorLevel
    }

    If (modBeeper=1 || beepFiringKeys=1)
    {
        For i, mod in ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        {
          Hotkey, % "~*" mod, OnModPressed, useErrorLevel
          Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        }
    }

    If (DTMFbeepers=1)
    {
        Hotkey, ~*NumpadDot Up, OnNumpadsDTMFUp, useErrorLevel
        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsDTMFUp, UseErrorLevel
    }
}

OnKeyPressed() {
    Thread, priority, -30
    If (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 20, -20
}

OnModPressed() {
    Thread, priority, -30
    Critical, off

    If (beepFiringKeys=1 && (A_TickCount-lastModPressTime < 350))
       SetTimer, modfiredBeeperTimer, 20, -20

    If ((A_TickCount-lastModPressTime < 350) || skipAbeep=1)
    {
       skipAbeep := 0
       Global lastModPressTime := A_TickCount
       Return
    }

    If (ModBeeper=1 && (A_TickCount-LastKeyUpTime > 100) && (A_TickCount-LastModPressTime2 > 350))
       modsBeeper()

    Global lastModPressTime2 := A_TickCount
}

OnMediaPressed() {
   Thread, priority, -10
   SetTimer, volBeeperTimer, 30, -20
}

OnKeyUp() {
    Global lastKeyUpTime := A_TickCount
    If (keyBeeper=1)
       keysBeeper()
    checkIfSkipAbeep()
}

OnToggleUp() {
    Global lastKeyUpTime := A_TickCount
    toggleLastState := (toggleLastState=1) ? 0 : 1
    toggleBeeper()
    checkIfSkipAbeep()
}

OnTypingLeftUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsL.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingHomeUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysHome.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingEndUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysEnd.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingPgUpUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysPgUp.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingPgDnUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysPgDn.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingRightUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsR.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnFunctionKeyUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\functionKeys.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnOtherDistinctKeysUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\otherDistinctKeys.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnNumpadsGeneralUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\numpads.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnNumpadsDTMFUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   sound2PlayNow := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, "ad")+2, 1)

   If InStr(A_ThisHotkey, "dot")
      sound2PlayNow := "A"

   SndPlay("sounds\num" sound2PlayNow "pad.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysEnterUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysEnter.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysDelUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysDel.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysBkspUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysBksp.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysSpaceUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysSpace.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingUpUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsU.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingDnUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsD.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnModUp() {
   Thread, Priority, -10
   Critical, off

   If (ModBeeper=1 && (A_TickCount-LastModPressTime > 250) && (A_TickCount-LastModPressTime2 > 450))
      modsBeeper()
}

toggleBeeper() {
   Sleep, 15
   If (toggleLastState=1)
      SndPlay("sounds\caps.wav", prioritizeBeepers)
   Else
      SndPlay("sounds\cups.wav", prioritizeBeepers)
}

capsBeeper() {
   Sleep, 15
   SndPlay("sounds\caps.wav", prioritizeBeepers)
}

keysBeeper() {
   Sleep, 15
   SndPlay("sounds\keys.wav", prioritizeBeepers)
}

volBeeperTimer() {
   Thread, priority, -10
   If ((A_TickCount-lastKeyUpTime < 700) && keyBeeper=1)
   {
      SetTimer, , off
      Return
   }
   Sleep, 15
   SndPlay("sounds\media.wav", prioritizeBeepers)
   SetTimer, , off
}

deadKeysBeeper() {
   Critical, on
   SndPlay("sounds\deadkeys.wav", 1)
}

modsBeeper() {
   Thread, Priority, -10
   Critical, off

   Global lastModPressTime := A_TickCount
   SndPlay("sounds\mods.wav", prioritizeBeepers)
}

firedBeeperTimer() {
   Critical, on

   If ((A_TickCount-lastKeyUpTime < 600) && keyBeeper=1)
   {
      SetTimer, , off
      Return
   }

   If ((A_TickCount-LastFiredTime > 100) && keyBeeper=1)
   {
      Sleep, 10
      Global LastFiredTime := A_TickCount
      SetTimer, , off
      Return
   }
   Static lastPlayed
   If (A_TickCount-lastPlayed > 125) || !lastPlayed
   {
      SndPlay("sounds\firedkey.wav")
      lastPlayed := A_TickCount
      Sleep, 5
   }
   Global LastFiredTime := A_TickCount
   SetTimer, , off
}

modfiredBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   If ((A_TickCount-LastFiredTime < 200) && keyBeeper=1)
   {
      Sleep, 20
      SetTimer, , off
      Return
   }
   SndPlay("sounds\modfiredkey.wav")
   Sleep, 40
   Global LastFiredTime := A_TickCount

   SetTimer, , off
}

OnLetterPressed() {
    If (ScriptelSuspendel=1 || SilentMode=1)
       Return

    GetKeyState, CapsState, CapsLock, T
    If (CapslockBeeper = 1)
    {
        If (CapsState = "D")
           capsBeeper()
        Else If (KeyBeeper = 1)
           keysBeeper()
    }

    If (CapslockBeeper=0 && KeyBeeper=1 && SilentMode=0)
        keysBeeper()
    checkIfSkipAbeep()
}

OnDeathKeyPressed() {
  Critical, on
  If (ScriptelSuspendel=1 || SilentMode=1)
     Return
  deadKeysBeeper()
  checkIfSkipAbeep()
}

OnMousePressed() {
    Critical, Off
    Thread, Priority, -50
    If (silentMode=1)
       Return

    If (MouseBeeper=1 && (A_ThisHotkey ~= "i)(LButton|MButton|RButton)"))
    {
       If (TypingBeepers=1 && InStr(A_ThisHotkey, "RButton"))
          SndPlay("sounds\clickR.wav")
       Else If (TypingBeepers=1 && InStr(A_ThisHotkey, "MButton"))
          SndPlay("sounds\clickM.wav")
       Else
          SndPlay("sounds\clicks.wav")
    } Else If (MouseBeeper=1 && (A_ThisHotkey ~= "i)(WheelDown|WheelUp|WheelLeft|WheelRight)"))
    {
       SndPlay("sounds\firedkey.wav")
       Sleep, 40
    }

}

checkIfSkipAbeep() {
    skipAbeep := 0
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    For i, mod in modifiers
    {
        If GetKeyState(mod)
           skipAbeep := 1
    }
}

firingKeys() {
   Critical, on
   Static lastPlayed
   If (A_TickCount-lastPlayed > 250) || !lastPlayed
   {
      SndPlay("sounds\modfiredkey.wav")
      lastPlayed := A_TickCount
   }
}

holdingKeys() {
   Critical, on
   Static lastPlayed
   If (A_TickCount-lastPlayed > 250) || !lastPlayed
   {
      SndPlay("sounds\holdingKeys.wav")
      lastPlayed := A_TickCount
   }
}

PlaySoundTest() {
   Thread, Priority, -20
   Critical, off
   Sleep, 50
   SndPlay("sounds\keys.wav")
   Sleep, 50
}

checkInit() {
  If !moduleInitialized
     CreateHotkey()
}

; function by Drugwash:
; ===============================
SndPlay(snd, wait:=0, noSentry:=0) {
  If (ScriptelSuspendel="Y" || SilentMode=1)
     Return

  Static hM := DllCall("kernel32\GetModuleHandleW", "Str", A_ScriptFullPath, "Ptr")
  f := (BeepSentry=1 && noSentry=0) ? "0x80012" : "0x12"
  w := wait ? 0 : 0x2001
  If (beepFromRes="Y")
  {
	  SplitPath, snd, snd
	  StringUpper, snd, snd
	  hMod:=hM, flags := f|w|0x40004
	} Else
	{
	  hMod := 0, flags := f|w|0x20000
	}
  SetTimer, sillySoundHack, 1900, 90
  Return DllCall("winmm\PlaySoundW"
	  , "Str", snd
	  , "Ptr", hMod
	  , "UInt", flags)	; SND_RESOURCE|SND_NOWAIT|SND_NOSTOP|SND_NODEFAULT|SND_ASYNC
}

sillySoundHack() {   ; this helps mitigate issues caused by apps like Team Viewer
   Sleep, 1
   SndPlay("sounds\silence.wav", 0, 1)
   SetTimer,, off
}
