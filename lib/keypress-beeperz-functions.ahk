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
; others
 , lastKeyUpTime := 0
 , mousekeys := 1
 , lastModPressTimr := 0
 , lastModPressTime := 0
 , LastFiredTime := 0
 , toggleLastState := 0
 , skipAbeep := 0
 , modsSkip := 0
 , IsSoundsFile := 1
 , beepFromRes := 0       ; 1 if compiled and  it looks for the sound files inside the binary
 , ScriptelSuspendel := 0
 , moduleInitialized, ActiveSillySoundHack, PrefOpen := 0
 , MainExe := AhkExported()
 , hMain := MainExe.ahkgetvar.hMain
 , hOSD := MainExe.ahkgetvar.hOSD
 , ShowCaretHalo := MainExe.ahkgetvar.ShowCaretHalo

checkTeamViewerTimer()
SetTimer, checkCurrentWindow, 1500
Return

checkCurrentWindow() {
  Static oldCurrWin, WinList
  If (ScriptelSuspendel="Y" || PrefOpen=1)
  {
     oldCurrWin := ""
     Return
  }

  currWin := WinExist("A")
  If (currWin!=oldCurrWin)
  {
     MainExe.ahkPostFunction("ShellMessageDummy")
     If (ShowCaretHalo=1 && !InStr(WinList, currWin))
     {
        WinList .= currWin "-"
        StringRight, WinList, WinList, 25
        Try WinDead := DllCall("IsHungAppWindow", "UInt", currWin)
        If (WinDead!=1)
           Try DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("user32\GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
     }
  }

  oldCurrWin := currWin
}

CreateHotkey() {
    If (ToggleKeysBeeper=0 && CapslockBeeper=0 && KeyBeeper=0
    && ModBeeper=0 && MouseBeeper=0 && beepFiringKeys=0 && TypingBeepers=0
    && DTMFbeepers=0) || (SilentMode=1)
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

        If (mousekeys=0)
        {
           NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft"
                           . "|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadClear"
           Loop, Parse, NumpadKeysList, |
           {
              Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
              Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
           }
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

        Otherkeys := "XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|NumpadEnter"
                   . "|Left|Right|Down|Up|End|Home|PgUp|PgDn|Space|Del|BackSpace|Insert|CapsLock|ScrollLock|NumLock|Pause|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|sc146|sc123|AppsKey|Tab|Enter|Esc"
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

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear"
                        . "|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
        If (mousekeys=0)
        {
           Loop, Parse, NumpadKeysList, |
               Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel
        }

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
       SetTimer, firedBeeperTimer, -1, -50
}

modsBeeperz() {
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    static listMods, oldListMods
    If (A_TickCount-lastModPressTimr>125)
       oldListMods := ""
    For i, mod in modifiers
    {
        If GetKeyState(mod)
           blistMods .= mod
    }
    listMods := blistMods

    Global lastModPressTimr := A_TickCount
    If (oldListMods!=listMods)
    {
       Global lastModPressTime := A_TickCount
       skipAbeep := 0
       oldListMods := listMods ? listMods : oldListMods
    } Else (skipAbeep := 1)
    Return skipAbeep
}

OnModPressed() {
    Thread, priority, -30
    Critical, off
    If (A_TickCount-lastKeyUpTime<100)
       Return
    SetTimer, modsBeeperTimerUp, -5, 20
    Sleep, 15
    If (SilentMode=0 && BeepFiringKeys=1 && (A_TickCount-lastKeyUpTime>700))
       SetTimer, modfiredBeeper, -20, -20
}

OnModUp() {
   Thread, Priority, -10
   Critical, off
   If (ModBeeper=1 && (A_TickCount-lastModPressTime>950) && (A_TickCount-lastKeyUpTime>700))
      SetTimer, modsBeepMiniTimer, -50, -50
   Global lastKeyUpTime := A_TickCount
   modsSkip := 0
}

modsBeeperTimerUp() {
   Thread, Priority, -10
   Critical, on
   modsBeeperz()
   If (skipAbeep!=1 && (A_TickCount-lastKeyUpTime>100) && modsSkip=0)
   || (skipAbeep!=1 && (A_TickCount-lastKeyUpTime>1500))
   {
      skipOther := 1
      SndPlay("sounds\mods.wav", prioritizeBeepers)
   }

   If (skipAbeep!=1 && modsSkip=1 && skipOther!=1)
      SetTimer, modsBeepMiniTimer, -100, -50
}

modsBeepMiniTimer() {
   Thread, Priority, -50
   Critical, off
   SndPlay("sounds\mods.wav", 0)
   modsSkip := 0
}

modfiredBeeper() {
   Thread, Priority, -20
   Static lastPlayed
   If (A_TickCount-lastPlayed > 200) || !lastPlayed
   {
      lastPlayed := A_TickCount
      SndPlay("sounds\modfiredkey.wav")
   }
}

OnMediaPressed() {
   Thread, priority, -10
   SetTimer, volBeeperTimer, -30, -20
}

OnKeyUp() {
    Global lastKeyUpTime := A_TickCount
    If (keyBeeper=1)
       keysBeeper()
}

OnToggleUp() {
    Global lastKeyUpTime := A_TickCount
    toggleLastState := (toggleLastState=1) ? 0 : 1
    toggleBeeper()
}

OnTypingLeftUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysArrowsL.wav", prioritizeBeepers)
}

OnTypingHomeUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysHome.wav", prioritizeBeepers)
}

OnTypingEndUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysEnd.wav", prioritizeBeepers)
}

OnTypingPgUpUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysPgUp.wav", prioritizeBeepers)
}

OnTypingPgDnUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysPgDn.wav", prioritizeBeepers)
}

OnTypingRightUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\typingkeysArrowsR.wav", prioritizeBeepers)
}

OnFunctionKeyUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\functionKeys.wav", prioritizeBeepers)
}

OnOtherDistinctKeysUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\otherDistinctKeys.wav", prioritizeBeepers)
}

OnNumpadsGeneralUp() {
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\numpads.wav", prioritizeBeepers)
}

OnNumpadsDTMFUp() {
   Global lastKeyUpTime := A_TickCount
   sound2PlayNow := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, "ad")+2, 1)

   If InStr(A_ThisHotkey, "dot")
      sound2PlayNow := "A"

   SndPlay("sounds\num" sound2PlayNow "pad.wav", prioritizeBeepers)
}

OnTypingKeysEnterUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysEnter.wav", prioritizeBeepers)
}

OnTypingKeysDelUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysDel.wav", prioritizeBeepers)
}

OnTypingKeysBkspUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysBksp.wav", prioritizeBeepers)
}

OnTypingKeysSpaceUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysSpace.wav", prioritizeBeepers)
}

OnTypingUpUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsU.wav", prioritizeBeepers)
}

OnTypingDnUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SndPlay("sounds\typingkeysArrowsD.wav", prioritizeBeepers)

}

toggleBeeper() {
   Sleep, 15
   Global lastKeyUpTime := A_TickCount
   If (toggleLastState=1)
      SndPlay("sounds\caps.wav", prioritizeBeepers)
   Else
      SndPlay("sounds\cups.wav", prioritizeBeepers)
}

capsBeeper() {
   Sleep, 15
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\caps.wav", prioritizeBeepers)
}

keysBeeper() {
   Sleep, 15
   Global lastKeyUpTime := A_TickCount
   SndPlay("sounds\keys.wav", prioritizeBeepers)
}

volBeeperTimer() {
   Thread, priority, -10
   If ((A_TickCount-lastKeyUpTime < 700) && keyBeeper=1)
      Return
   Sleep, 15
   SndPlay("sounds\media.wav", prioritizeBeepers)
}

deadKeysBeeper() {
   Critical, on
   SndPlay("sounds\deadkeys.wav", 1)
   Global lastKeyUpTime := A_TickCount
}

firedBeeperTimer() {
   Thread, priority, -10
   Static lastPlayed, keyTicks
   If ((A_TickCount-lastKeyUpTime < 650) && keyBeeper=1)
   {
      keyTicks := 0
      lastPlayed := A_TickCount+10
      Return
   }

   If (A_TickCount-lastPlayed > 50) || !lastPlayed
   {
      keyTicks++
      lastPlayed := A_TickCount
      If (keyTicks>3)
      {
         keyTicks := 0
         SetTimer, firingKeyExtraDummy, -2, -50
      }
   }
}

firingKeyExtraDummy() {
  SndPlay("sounds\firedkey.wav")
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
    Global lastKeyUpTime := A_TickCount
}

OnDeathKeyPressed() {
  Critical, on
  If (ScriptelSuspendel=1 || SilentMode=1)
     Return
  deadKeysBeeper()
}

OnMousePressed(key:=0) {
    Critical, Off
    Thread, Priority, -50
    If (silentMode=1)
       Return

    If !key
       key := A_ThisHotkey

    If (MouseBeeper=1 && (key ~= "i)( Click|Button)"))
    {
       If (TypingBeepers=1 && (key ~= "i)(Right C|RButton)"))
          SndPlay("sounds\clickR.wav")
       Else If (TypingBeepers=1 && (key ~= "i)(Middle C|MButton)"))
          SndPlay("sounds\clickM.wav")
       Else
          SndPlay("sounds\clicks.wav")
    } Else If (MouseBeeper=1 && (key ~= "i)(Wheel)"))
    {
       SndPlay("sounds\firedkey.wav")
       Sleep, 40
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
SndPlay(snd:=0, wait:=0, noSentry:=0) {
  If (ScriptelSuspendel="Y" || SilentMode=1 || PrefOpen=1)
     Return

  If !snd
  {
     If (ActiveSillySoundHack=1)
        SoundBeep, 0, 1
     Return DllCall("winmm\PlaySoundW"
            , "Ptr"  , 0
            , "Ptr"  , 0
            , "Uint", 0x46) ; SND_PURGE|SND_MEMORY|SND_NODEFAULT
  }

  If (A_TickCount-lastKeyUpTime<600)
     SetTimer, modsBeepMiniTimer, off
  If !(snd ~= "i)(fired|mods|holding|modfired)")
     modsSkip := 1

  Static hM := DllCall("kernel32\GetModuleHandleW", "Str", A_ScriptFullPath, "Ptr")
  f := (BeepSentry=1 && noSentry=0) ? "0x80012" : "0x12"     ; SND_SENTRY+ : SND_NOSTOP|SND_NODEFAULT
  w := wait ? 0 : 0x2001     ; SND_NOWAIT|SND_ASYNC
  If (beepFromRes="Y")
  {
    SplitPath, snd, snd
    StringUpper, snd, snd
    hMod:=hM, flags := f|w|0x40004     ; +SND_RESOURCE
	} Else
	{
	  hMod := 0
    flags := f|w|0x20000        ; +SND_FILENAME
	}
  SetTimer, sillySoundHack, -990, 90
  SetTimer, checkTeamViewerTimer, -5000, 90
  Return DllCall("winmm\PlaySoundW"
	  , "Str", snd
	  , "Ptr", hMod
	  , "UInt", flags)	; SND_RESOURCE|SND_NOWAIT|SND_NOSTOP|SND_NODEFAULT|SND_ASYNC
}

sillySoundHack() {   ; this helps mitigate issues caused by apps like Team Viewer
   Sleep, 1
   SndPlay()
}

checkTeamViewerTimer() {
  If (ScriptelSuspendel="Y" || PrefOpen=1)
     Return

  lol := WinGetAll()
  If InStr(lol, "teamviewer")
     ActiveSillySoundHack := 1
  Else
     ActiveSillySoundHack := 0
}

WinGetAll(Which="Title", DetectHidden="Off") {
; function by Heresy from:
; https://autohotkey.com/board/topic/30323-wingetall-get-all-windows-titleclasspidprocess-name/

O_DHW := A_DetectHiddenWindows, O_BL := A_BatchLines ;Save original states
DetectHiddenWindows, % (DetectHidden != "off" && DetectHidden) ? "on" : "off"
SetBatchLines, -1
    WinGet, all, list ;get all hwnd
    If (Which="Title") ;return Window Titles
    {
        Loop, %all%
        {
            WinGetTitle, WTitle, % "ahk_id " all%A_Index%
            If WTitle ;Prevent to get blank titles
                Output .= WTitle "`n"        
        }
    }
    Else If (Which="Process") ;return Process Names
    {
        Loop, %all%
        {
            WinGet, PName, ProcessName, % "ahk_id " all%A_Index%
            Output .= PName "`n"
        }
    }
    Else If (Which="Class") ;return Window Classes
    {
        Loop, %all%
        {
            WinGetClass, WClass, % "ahk_id " all%A_Index%
            Output .= WClass "`n"
        }
    }
    Else If (Which="hwnd") ;return Window Handles (Unique ID)
    {
        Loop, %all%
            Output .= all%A_Index% "`n"
    }
    Else If (Which="PID") ;return Process Identifiers
    {
        Loop, %all%
        {
            WinGet, PID, PID, % "ahk_id " all%A_Index%
            Output .= PID "`n"        
        }
        Sort, Output, U N ;numeric order and remove duplicates
    }
DetectHiddenWindows, %O_DHW% ;back to original state
SetBatchLines, %O_BL% ;back to original state
    Sort, Output, U ;remove duplicates
    Return Output
}
