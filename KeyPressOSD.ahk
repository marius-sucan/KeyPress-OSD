; KeypressOSD.ahk - main file
; Latest version at:
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.
;
;--------------------------------------------------------------------------------------------------------------------------
;
; Keyboard language definitions file:
;   keypress-osd-languages.ini
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-languages.ini
;   File required for AutoDetectKBD = 1, to detect keyboard layouts.
;   File must be placed in the same folder with the script.
;   It adds support for around 50 keyboard layouts covering about 31 languages.
;
; Change log file:
;   keypress-osd-changelog.txt
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-changelog.txt
;
; AVAILABLE SHORTCUTS:
 ; Ctrl+Alt+Shift+F7  - Toggles forced keyboard layouts A/B
 ; Ctrl+Alt+Shift+F8  - Toggles "Show single key" option. Useful when you type passwords or must reliably use dead keys.
 ; Ctrl+Alt+Shift+F9  - Toggles between two OSD positions
 ; Ctrl+Alt+Shift+F10 - Toggles personal/regional keys support.
 ; Ctrl+Alt+Shift+F11 - Detect keyboard language.
 ; Ctrl+Alt+Shift+F12 - Reinitialize OSD. Useful when it no longer appears on top. To have it appear on top of elevated apps, run it in administrator mode.
 ; Shift+Pause/Break  - Suspends the script and all its shortcuts.
;
; NOTES:
 ;
 ; I invest time in this script for people like me, with poor eye sight
 ; or low vision. It is meant to aid desktop computer usage.
 ;
 ; This script was made for, and on Windows 10.
 ; The keyboard layouts have changed since Win XP or Win 98.
 ; Windows 10 also no longer switches keyboard layouts based
 ; on the currently active app. As such, automatic keyboard
 ; layout detection may not work for you.
 ; 
 ; I do not intend to offer support for older Windows versions.
 ; 
 ; This script has support only for Latin-based keyboards.
 ; Thus, it has no support for Chinese, Japanese, chirilic, 
 ; It is too complex for me to implement support for other alphabets or writing systems.
 ; If other programmers willing to invest the time in this script,
 ; are welcomed to do so, and even to transform it into anything they wish. 
 ;
 ; I offer numerous options/settings in the script such that
 ; everyone can find a way to adapt it to personal needs.
 ; - you can edit, in the code, what are the dead keys
 ;   - see Loop, 95, char2skip from CreateHotkey() function
 ; - you can also define personal regional keys, while autodetect is disabled
 ; - disable dead keys if you do not have such keys
 ; 
 ; Read the messages you get:
 ; - it indicates when your keyboard layout is unsupported or Unrecognized
 ; - it also indicates if it made a partial match;
 ;   - in such cases, you will likely not have all the keys
 ;   - or simply AHK will give errors trying to bind to inexistent keys
 ; - if the external file is missing, languages.ini, it will always report
 ; that it did not detect your keyboard.
 ;
 ; Default/built in language support is for English International.
 ;
 ; For the layouts I added support, I avoided binding to dead keys
 ; such that you no longer have to add them manually, as indicated previously.
 ; 
 ; If you rely only on the "vanilla" version, you will likely 
 ; not be able to use it. You can easily add language support,
 ; by editing the files of the script.
 ;
 ; I am no programmer and the script is still quite quirky, but I am trying to
 ; make it better and better with each version.
 ; My progresses with the script are thanks to the great help from the people on #ahk (irc.freenode.net).
 ;
;
; FEATURES:
 ; - Show previously pressed key if fired quickly.
 ; - Count key presses or key fires and mouse clicks.
 ; - Automatic resizing of OSD/HUD or fixed size.
 ; - Hides automatically when mouse runs over it.
 ; - Visual mouse clicks and idle mouse highlighter/locator
 ; - Generate beeps for key presses, modifiers, mouse clicks or just when typing with Capslock.
 ; - Clipboard monitor. It displays briefly texts copied to clipboard.
 ; - Live text capture with Capture2Text.
 ;   - you must have Capture2Text running and Pause/Break set as a shortcut for "text line capture" and copy to clipboard option enabled.
 ;   - this way KeypressOSD will display continously the texts detected by Capture2Text
 ; - Indicators for CapsLock, NumLock and ScrollLock states.
 ; - Typing mode. It shows what you are typing in an expanding text area.
 ; - Partial dead keys support, option to turn it off or to define your own dead keys to ignore
 ; - Support for many non-English keyboards. 50 keyboard layouts defined for over 30 languages.
 ;   - experimental automatic detection of keyboard layouts.
 ;   - option to force of keyboard layouts; toggle by shortcut between two layouts 
 ;   - option to define custom/regional keys to bind
 ; - Easy to configure with many options in Settings windows:
 ;   - to toggle features: visual mouse clicks, key beepers, key counting or previous key;
 ;   - to hide modifiers, mouse clicks or single key presses (which disables typing mode);
 ;   - or hide keys that usually get in the way: Left Click and Print Screen;
 ;   - differ between left and right modifiers;
 ;   - OSD/HUD position, size and display time;
 ;   - beep key presses even if keys are not displayed;
 ;   - colors and sizes
 ; - Portable. Files stored in an easy to read INI file
 ; 
;----------------------------------------------------------------------------

; Initialization
 #SingleInstance force
 #NoEnv
; #Warn, , OutputDebug
 #MaxHotkeysPerInterval 500
 SetTitleMatchMode, 2
 SetBatchLines, -1
 ListLines, Off
 SetWorkingDir, %A_ScriptDir%

; Default Settings / Customize:

 global IgnoreAdditionalKeys  := 0
 , IgnorekeysList        := "a.b.c"
 , CustomRegionalKeys    := 0     ; if you want to add support to a regional keyboard
 , RegionalKeysList      := "a.b.c"  ; add the characters in this list, separated by , [comma]
 , AutoDetectKBD         := 1     ; at start, detect keyboard layout
 , ConstantAutoDetect    := 1     ; continously check if the keyboard layout changed; if AutoDetectKBD=0, this is ignored
 , SilentDetection       := 0     ; do not display information about language switching
 , audioAlerts           := 0     ; generate beeps when key bindings fail
 , ForceKBD              := 0     ; force detection of a specific keyboard layout ; AutoDetectKBD must be set to 1
 , ForcedKBDlayout1      := "00010418" ; enter here the HEX code of your desired keyboards
 , ForcedKBDlayout2      := "0000040c"
 , ForcedKBDlayout       := 0
 , enableAltGrUser       := 1
 
 , DisableTypingMode     := 0     ; do not echo what you write
 , ShowDeadKeys          := 1
 , autoRemDeadKey        := 1
 , NavKeysFriendly       := 0
 , SpaceReplacer         := " "   ; how to display space bar in typing mode
 , ShowSingleKey         := 1     ; show only key combinations ; it disables typing mode
 , HideAnnoyingKeys      := 0     ; Left click and PrintScreen can easily get in the way.
 , ShowMouseButton       := 1     ; in the OSD
 , StickyKeys            := 0     ; how modifiers behave; set it to 1 if you use StickyKeys in Windows
 , ShowSingleModifierKey := 1     ; make it display Ctrl, Alt, Shift when pressed alone
 , DifferModifiers       := 0     ; differentiate between left and right modifiers
 , ShowPrevKey           := 1     ; show previously pressed key, if pressed quickly in succession
 , ShowPrevKeyDelay      := 300
 , ShowKeyCount          := 1     ; count how many times a key is pressed
 , ShowKeyCountFired     := 0     ; show only key presses (0) or catch key fires as well (1)
 
 , DisplayTimeUser       := 3     ; in seconds
 , JumpHover             := 0
 , OSDborder             := 0
 , GUIposition           := 1     ; toggle between positions with Ctrl + Alt + Shift + F9
 , GuiXa                 := 40
 , GuiYa                 := 250
 , GuiXb                 := 60
 , GuiYb                 := 800
 , GuiWidth              := 350
 , maxGuiWidth           := 500
 , FontName              := "Arial"
 , FontSize              := 19
 , FavorRightoLeft       := 0
 , NeverRightoLeft       := 0
 , OSDbgrColor           := "111111"
 , OSDtextColor          := "ffffff"
 , OSDautosize           := 1     ; make adjustments to the growth factors to match your font size
 , OSDautosizeFactory    := round(A_ScreenDPI / 1.18)
 
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , BeepHiddenKeys        := 0     ; [when any beeper enabled] to beep or not when keys are not displayed by OSD/HUD

 , KeyboardShortcuts     := 1     ; system-wide shortcuts
 , ClipMonitor           := 1     ; show clipboard changes
 , ShiftDisableCaps      := 1

 , VisualMouseClicks     := 0     ; shows visual indicators for different mouse clicks
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , ClickScaleUser        := 10
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , MouseHaloRadius       := 35
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloAlpha        := 150   ; from 0 to 255
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , MouseIdleRadius       := 40
 , MouseIdleAfter        := 10    ; in seconds
 , IdleMouseAlpha        := 130   ; from 0 to 255
 , UseINIfile            := 1
 , IniFile               := "keypress-osd.ini"
 , version               := "3.37"
 , releaseDate := "2017 / 11 / 10"
 
; Initialization variables. Altering these may lead to undesired results.

    IniRead, firstRun, %IniFile%, SavedSettings, firstRun
    if (firstRun=0) && (UseINIfile=1)
    {
        LoadSettings()
    } else if (UseINIfile=1)
    {
        CheckSettings()
        ShaveSettings()
    }

 global typed := "" ; hack used to determine if user is writing
 , visible := 0
 , ClickScale := ClickScaleUser/10
 , DisplayTime := DisplayTimeUser*1000
 , prefixed := 0 ; hack used to determine if last keypress had a modifier
 , Capture2Text := 0
 , zcSCROL := "SCROLL LOCK"
 , tickcount_start2 := A_TickCount
 , tickcount_start := 0 ; timer to count repeated key presses
 , keyCount := 0
 , ShowKeyCountDelay := (ShowKeyCountFired = 0) ? 700 : 6000
 , text_width := 60
 , modifiers_temp := 0
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , maxAllowedGuiWidth := A_ScreenWidth
 , rightoleft := 0
 , prefOpen := 0
 , MouseClickCounter := 0
 , NumLockForced := 0
 , shiftPressed := 0
 , AltGrPressed := 0
 , enableAltGr := enableAltGrUser
 , backTyped := ""
 , lastTypedSince := 0
 , CurrentKBD := "Default: English US"
 , kbLayoutSymbols := "0"
 , kbLayoutAltGRpairs := "0"
 , CapsEqualsShift := 0
 , noCapsAllowed := ""
 , InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
 , DeadKeys := 0
 , DKnotShifted_list := ""
 , DKshift_list := ""
 , DKaltGR_list := ""
 , FontList := []

   Thread, priority, 10
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth

if (visualMouseClicks=1)
{
    CoordMode Mouse, Screen
    CreateMouseGUI()
}

if (FlashIdleMouse=1)
{
    CoordMode Mouse, Screen
    SetTimer, ShowMouseIdleLocation, 1000, -5
}

if (ShowMouseHalo=1)
{
    CoordMode Mouse, Screen
    SetTimer, MouseHalo, 60, -2
}

CreateOSDGUI()
CreateGlobalShortcuts()
CreateHotkey()
InitializeTray()
if (ClipMonitor=1)
    OnClipboardChange("ClipChanged")
return

; The script

GetSpecialKeysStates() {
    GetKeyState, ScrollState, ScrollLock, T   
    If ScrollState = D
    {
       global zcSCROL := "SCROLL LOCK ON"
    }
    else {
       global zcSCROL := "Scroll lock off"
    }
}

TypedLetter(key) {
   Thread, priority, 10

   if (ShowSingleKey=0 || DisableTypingMode=1)
   {
      typed := ""
      Return
   }

   global lastTypedSince := A_TickCount
   AltGrMatcher := "i)^(AltGr \(s|AltGr \+ |.{0,1}Ctrl \+ Alt \+ |.{0,1}Ctrl \+ AltGr \+ )"
   if ((key ~= AltGrMatcher) && (enableAltGr=1) || (AltGrPressed=1) && (enableAltGr=1) && (StickyKeys=1))
   {
      if (StrLen(key)>2)
      {
         keye := SubStr(key, InStr(key, "+", 0, 0)+2)
         StringLeft, keye, keye, 1
         if !keye
         {
             StringRight, key, key, 1
         } else
         {
            key := keye
         }
      }
      key := GetAltGrSymbol(key)
      AltGrMagic := 1
      if (key && StrLen(typed)>1)
         SetTimer, returnToTyped, % -DisplayTime/6
   }

   if (StrLen(key)<2) && (AltGrPressed=1) && (enableAltGr=1) && (StickyKeys=0) && (AltGrMagic!=1)
      key := GetAltGrSymbol(key)

   StringLeft, key, key, 1
   if (AltGrMagic!=1)
      Stringlower, key, key
      
   GetKeyState, CapsState, CapsLock, T

   If (CapsState != "D")
   {
       if GetKeyState("Shift") || (shiftPressed=1) && (StickyKeys=1)
       {
          StringUpper, key, key
          key := GetShiftedSymbol(key)
       }
   } else
   {
       if (CapsEqualsShift=1) 
       {
         if (key ~= noCapsAllowed)
             StringUpper, key, key

          key := GetKeyState("Shift") ? key : GetShiftedSymbol(key)
       }
       
       noCapsAllowed := noCapsAllowed ? noCapsAllowed : 0

       if !(key ~= noCapsAllowed)
          StringUpper, key, key

       if GetKeyState("Shift") || ((shiftPressed=1) && (StickyKeys=1))
       {
         if (key ~= noCapsAllowed)
             StringUpper, key, key

         key := (CapsEqualsShift=1) ? key : GetShiftedSymbol(key)
         Stringlower, key, key
       }
   }

    AltGrPressed := 0

    NumLetters := StrLen(typed)+1

    maxTextLimit := 0
    bbold := 1
    text_width := GetTextExtentPoint(typed, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
    if (text_width > maxAllowedGuiWidth) && typed
    {
       maxTextLimit := 1
       if (text_width > maxAllowedGuiWidth + 15)
          maxTextLimit := 2
       if (text_width > maxAllowedGuiWidth + 25)
          maxTextLimit := 3
    }

   if (maxTextLimit>0)
      NumLetters := StrLen(typed) - maxTextLimit

   return typed := SubStr(typed key, -NumLetters)
}

OnMousePressed() {
    if Visible=1
       tickcount_start := A_TickCount-500

    shiftPressed := 0
    AltGrPressed := 0

    try {
        key := GetKeyStr()
        if (ShowMouseButton=1)
        {
            typed := "" ; concerning TypedLetter(" ") - it resets the content of the OSD
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        }
    }

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       ShowMouseClick(mkey)
    }

    if ((MouseBeeper = 1) && (ShowMouseButton = 1) && (ShowSingleKey = 1) || (MouseBeeper = 1) && (ShowSingleKey = 0) && (BeepHiddenKeys = 1) || (visualMouseClicks=1) && (MouseBeeper = 1) )
       soundbeep, 2500, 70
}

OnKeyPressed() {
    try {
        key := GetKeyStr()
        AltGrPressed := 0
        AltGrMatcher := "i)^(AltGr \(s|AltGr \+ |.{0,1}Ctrl \+ Alt \+ |.{0,1}Ctrl \+ AltGr \+ )"
        TypingFriendlyKeys := "i)^(Num lo|Scroll lo|Insert|Tab|Volume |Media_|Wheel )"
        if (NavKeysFriendly=1)
           TypingFriendlyKeys := "i)^(Num lo|Scroll lo|Insert|Tab|Volume |Media_|Wheel |Left|Right|Page Up|Page Down|Home|End|Up|Down)"

        if (!(key ~= TypingFriendlyKeys)) && (DisableTypingMode=0)
        {
           if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1)
           {
             test := SubStr(key, InStr(key, "+", 0, 0)+2)
             if !test && !InStr(key, "Win")
                AltGrPressed := 1
             if InStr(key, "AltGr (special")
                AltGrPressed := 1
           }
           backTyped := !typed && (AltGrPressed=1) && (enableAltGr=1) ? backTyped : typed
           typed := ""
        } else if ((key ~= "i)^(Tab)") && typed && (DisableTypingMode=0))
        {
            TypedLetter(" ")
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        if (StrLen(typed)>1)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       if InStr(mkey, "wheel")
          ShowMouseClick(mkey)
    }
}

OnLetterPressed() {
    Thread, priority, 10
    Critical, on
    try {
        if (typed && DeadKeys=1)
            sleep, 25    ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these

        AltGrMatcher := "i)^(AltGr \(s|AltGr \+ |.{0,1}Ctrl \+ Alt \+ |.{0,1}Ctrl \+ AltGr \+ )"
        key := GetKeyStr(1)     ; consider it a letter

        if (prefixed || DisableTypingMode=1)
        {
            if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) || ((AltGrPressed=1) && (DisableTypingMode=0) && (StrLen(key)<2) && (ShowSingleKey=1) && (StickyKeys=1)) && (enableAltGr=1)
            {
               typed := (enableAltGr=1) ? TypedLetter(key) : ""
               if (StrLen(typed)>1)
               {
                  ShowHotkey(typed)
               } else
               {
                  typed := (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) ? typed : ""
                  ShowHotkey(key)
               }
            } else
            {
               typed := ""
               ShowHotkey(key)
            }

            if ((key ~= "i)^(.{0,1}Shift \+ )") && StrLen(key)<11 && (ShowSingleKey=1) && (DisableTypingMode=0))
            {
                StringRight, lettera, key, 1
                TypedLetter(lettera)
            }
            SetTimer, HideGUI, % -DisplayTime

        } else
        {
            TypedLetter(key)
            ShowHotkey(typed "|")
            SetTimer, HideGUI, % -DisplayTime*3
            shiftPressed := 0
            AltGrPressed := 0
        }
    }
}

OnSpacePressed() {
    Thread, priority, 10
    try {
          if (typed && (DisableTypingMode=0))
          {
             if (typed ~= "i)(·)$")
             {
                typed := SubStr(typed, 1, StrLen(typed) - 1)
                TypedLetter("▪")
             } else
             {
                TypedLetter(SpaceReplacer)
             }
             ShowHotkey(typed "|")
          }
          key := GetKeyStr()
          if (prefixed || !typed)
             ShowHotkey(key)

          if (DisableTypingMode=1) || prefixed
             typed := ""
          SetTimer, HideGUI, % -DisplayTime
    }
}

OnBspPressed() {
    Thread, priority, 10
    try
    {
        if typed && (DisableTypingMode=0)
        {
            typed := SubStr(typed, 1, StrLen(typed) - 1)
            if (typed ~= "i)(·)$") && (autoRemDeadKey=1)
               typed := SubStr(typed, 1, StrLen(typed) - 1)
            ShowHotkey(typed "|")
        }
        key := GetKeyStr()
        if (prefixed || !typed)
           ShowHotkey(key)

        if (DisableTypingMode=1) || prefixed
           typed := ""
        SetTimer, HideGUI, % -DisplayTime
    }
    shiftPressed := 0
}

OnCapsPressed() {
    try
    {
        key := GetKeyStr()
        GetKeyState, CapsState, CapsLock, T
        if CapsState = D
        {
            key := prefixed ? key : "CAPS LOCK ON"
        } else
        {
            key := prefixed ? key : "Caps Lock off"
        }
        
        ShowHotkey(key)

        if (DisableTypingMode=0)
           SetTimer, returnToTyped, % -DisplayTime/4.5

        if (DisableTypingMode=1) || prefixed
           typed := ""
        
        SetTimer, HideGUI, % -DisplayTime
    }

    If (CapslockBeeper = 1) && (ShowSingleKey = 1) || (CapslockBeeper = 1) && (BeepHiddenKeys = 1)
       {
        soundbeep, 450, 200
       }
}

OnNumpadPressed() {
    Thread, priority, 10
    GetKeyState, NumState, NumLock, T

    if (shiftPressed=1 && NumState="D")
       NumLockForced := 1

    try {
        key := GetKeyStr()
        if NumState != D
        {
            typed := "" ; reset typed content
            if (shiftPressed=1 && !InStr(key, "Shift") && StickyKeys=1)
            {
                ShowHotkey("Shift + " key)
            } else
            {
                ShowHotkey(key)
            }
            NumLockForced := 0
        } else if prefixed || (NumLockForced=1) || (DisableTypingMode=1)
        {
            typed := ""
            sleep, 30           ; stupid hack
            if (shiftPressed=1 && !InStr(key, "Shift") && StickyKeys=1)
            {
                ShowHotkey("Shift + " key)
            } else
            {
                ShowHotkey(key)
            }
                if (NumLockForced=1)
                   NumLockForced := 0
        } else if NumState = D
        {
            key2 := GetKeyStr(1)
            sleep, 30           ; stupid hack
            if (StrLen(key2)=5)
            {
              StringLeft, key2, key2, 3
              StringRight, key2, key2, 1
            }
            TypedLetter(key2)
            ShowHotkey(typed "|")
        }
        SetTimer, HideGUI, % -DisplayTime
    }
}

OnKeyUp() {
    global tickcount_start := A_TickCount

    shiftPressed := 0
    AltGrPressed := 0

    if typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
    {
        GetKeyState, CapsState, CapsLock, T
        If CapsState = D
           {
               SetTimer, capsBeeper, 15, -10
           }
           else if (KeyBeeper = 1) && (ShowSingleKey = 1)
           {
               SetTimer, keyBeeper, 15, -10
           }
    }

    If (CapslockBeeper = 0) && (KeyBeeper = 1) && (ShowSingleKey = 1)
       {
           SetTimer, keyBeeper, 15, -10
       }
       else if (CapslockBeeper = 1) && (KeyBeeper = 0)
       {
           Return
       }
       else if !typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
       {
           SetTimer, keyBeeper, 15, -10
       }

    if (BeepHiddenKeys = 1) && (KeyBeeper = 1) && (ShowSingleKey = 0)
    {
           SetTimer, keyBeeper, 15, -10
    }
}

capsBeeper() {
      Thread, priority, -10
      soundbeep, 450, 120
      SetTimer, , off
}

keyBeeper() {
      Thread, priority, -10
      soundbeep, 1900, 45
      SetTimer, , off
}

modBeeper() {
      soundbeep, 1000, 65
      SetTimer, , off
}

OnModPressed() {
    static modifierz := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    static repeatCount := 1

    for i, mod in modifierz
    {
        if GetKeyState(mod)
           fl_prefix .= mod " + "
    }

    if GetKeyState("Shift")
    {
       shiftPressed := 1

       if (ShowKeyCountFired=0) (ShowKeyCount=1) && (A_TickCount-tickcount_start2 > 150)
          repeatCount := (A_TickCount-tickcount_start2 > 5) ? repeatCount+1 : repeatCount

       if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) && (A_TickCount-tickcount_start2 > 150) || (ModBeeper = 1) && (BeepHiddenKeys = 1) && (A_TickCount-tickcount_start2 > 150)
          SetTimer, modBeeper, 15, -10

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }

    if (StickyKeys=0)
       fl_prefix := RTrim(fl_prefix, "+ ")

    fl_prefix := CompactModifiers(fl_prefix)
    
    keya := A_ThisHotkey

    if !fl_prefix
    {
       fl_prefix := instr(keya, "RCtrl") ? "AltGr (special key)" : "Unknown key"
       keyCount := 0.1
       shiftPressed := 0
       AltGrPressed := 1
    }

    if InStr(fl_prefix, modifiers_temp)
    {
        valid_count := 1
        if (repeatCount>1)
           keyCount := 0.1
    } else
    {
        valid_count := 0
        modifiers_temp := fl_prefix
        if (StickyKeys=0 && !prefixed)
           keyCount := 0.1
    }

        if (valid_count=1) && (ShowKeyCountFired=0) && (ShowKeyCount=1) && !InStr(fl_prefix, "AltGr")
        {
           trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
           repeatCount := (trackingPresses=0 && repeatCount<2) ? repeatCount+1 : repeatCount
           if (trackingPresses=1)
              repeatCount := !repeatCount ? 1 : repeatCount+1
           ShowKeyCountValid := 1
        } else if (valid_count=1) && (ShowKeyCountFired=1) && (ShowKeyCount=1)
        {
           repeatCount := !repeatCount ? 0 : repeatCount+1
           if InStr(fl_prefix, "AltGr") && repeatCount>3
              repeatCount := repeatCount-1+0.49
           ShowKeyCountValid := 1
        } else
        {
           repeatCount := 1
           ShowKeyCountValid := 0
        }

    if (ShowKeyCountValid=1) && (StickyKeys=0) {
        if !InStr(fl_prefix, "+") {
            modifiers_temp := fl_prefix
            fl_prefix .= " (" round(repeatCount) ")"
        } else {
            repeatCount := 1
        }
   }

   if (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && visible && !typed && keycount>5 && StickyKeys=1)
   {
      sleep, 0
   } else
   {
      ShowHotkey(fl_prefix)
      SetTimer, HideGUI, % -DisplayTime/2
      if !InStr(fl_prefix, " + ")
         SetTimer, returnToTyped, % -DisplayTime/4.5
   }
}

OnModUp() {
    global tickcount_start := A_TickCount

    if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
       SetTimer, modBeeper, 15, -10

    if (StickyKeys=0) && StrLen(typed)>1
       SetTimer, returnToTyped, % -DisplayTime/4.5
}

OnDeadKeyPressed() {
  if (ShowDeadKeys=1) && typed && (DisableTypingMode=0)
  {
       if (typed ~= "i)(·)$")
       {
           typed := SubStr(typed, 1, StrLen(typed) - 1)
           TypedLetter("▪")
           Sleep, 100
           TypedLetter("▪")
       } else
       {
           TypedLetter("·")
       }
  }

  SetTimer, returnToTyped, % -DisplayTime/6, -10

  shiftPressed := 0
  AltGrPressed := 0
  keyCount := 0.1

  if !typed
     ShowHotkey("·")

  if (KeyBeeper = 1) && (ShowSingleKey = 1) || (KeyBeeper = 1) && (BeepHiddenKeys = 1)
     SetTimer, keyBeeper, 15, -10
}

OnAltGrDeadKeyPressed() {
  if (DisableTypingMode=0)
     typed := backTyped

  if (ShowDeadKeys=1) && (DisableTypingMode=0)
  {
       typed := backTyped
       if (typed ~= "i)(·)$")
       {
           typed := SubStr(typed, 1, StrLen(typed) - 1)
           typed := typed "▪"
           Sleep, 100
           typed := typed "▪"
       } else
       {
           typed := typed "·"
       }
       SetTimer, returnToTyped, % -DisplayTime/6, -10
  }


  AltGrPressed := 0
  shiftPressed := 0
  keyCount := 0.1

  SetTimer, returnToTyped, % -DisplayTime/6, -10

  if (KeyBeeper = 1) && (ShowSingleKey = 1) || (KeyBeeper = 1) && (BeepHiddenKeys = 1)
     SetTimer, keyBeeper, 15, -10
}

CreateOSDGUI() {
    global

    Gui, OSD: destroy
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow +E0x20
    Gui, OSD: Margin, 15, 10
    Gui, OSD: Color, %OSDbgrColor%
    Gui, OSD: Font, c%OSDtextColor% s%FontSize% bold, %FontName%, -wrap

    if (OSDautosize=0)
    {
        widthDelimitator := FavorRightoLeft=1 ? 1.25 : 1.05+FontSize/450
        rightoleft := (GuiWidth > A_ScreenWidth - GuiX*1.1) ? 1 : 0
    } else
    {
        widthDelimitator := FavorRightoLeft=1 ? 1.85 : 1.4+FontSize/250
        rightoleft := (GuiX > A_ScreenWidth/widthDelimitator) ? 1 : 0
    }

    if (NeverRightoLeft=1)
       rightoleft := 0

    textOrientation := "left"
    wrappy := "-wrap"

    if ((rightoleft=1) && (NeverRightoLeft=0) && (OSDautosize=1)) || ((rightoleft=1) && (FavorRightoLeft=1))
    {
       textOrientation := "right"
       wrappy := ""
    }

    Gui, OSD: Add, Text, vHotkeyText %textOrientation% %wrappy%

    if (OSDborder=1)
    {
        WinSet, Style, +0xC40000
        WinSet, Style, -0xC00000
        WinSet, Style, +0x800000   ; small border
    }
}

CreateHotkey() {

    if (AutoDetectKBD=1)
       IdentifyKBDlayout()

    static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "!^", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    static mods_list := ["!", "!#", "!#^", "!#^+", "!+",              "#", "#!", "#!+", "#!^", "#+^", "#^",        "+#", "+^", "^"]
    megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list


    Loop, 256
    {
        k := A_Index
        code := Format("{:x}", k)

        n := GetKeyName("vk" code)

        if (n = "")
          continue

        if (StrLen(n)<2)
        {
           if (DeadKeys=1)
           {
             for each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
             {
               if (n = char2skip && DeadKeys=1)
                 continue, 2
             }
           }

           if (IgnoreAdditionalKeys=1)
           {
             for each, char2skip in StrSplit(IgnorekeysList, ".")        ; dead keys to ignore
             {
               if (n = char2skip && IgnoreAdditionalKeys=1)
                 continue, 2
             }
           }
           Hotkey, % "~*" n, OnLetterPressed, useErrorLevel
           Hotkey, % "~*" n " Up", OnKeyUp, useErrorLevel
           if (errorlevel!=0) && (audioAlerts=1)
              soundbeep, 1900, 50
        }
    }

    if (DeadKeys=1)
    {
        Loop, parse, DKaltGR_list, .
        {
            for i, mod in mods_list
            {
                if (enableAltGr=1)
                {
                  Hotkey, % "~^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                }

                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKshift_list, A_LoopField)
                {
                   Hotkey, % "~+" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnKeyUp, useErrorLevel
                }

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnKeyUp, useErrorLevel
                }
            }
        }

        Loop, parse, DKshift_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~+" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnKeyUp, useErrorLevel
                }

            }
        }

        Loop, parse, DKnotShifted_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKShift_list, A_LoopField)
                {
                   Hotkey, % "~+" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnKeyUp, useErrorLevel
                }
            }
        }

        ShiftRelatedDKlist := DKshift_list "." DKnotShifted_list

        Loop, parse, ShiftRelatedDKlist, .
        {
            for i, mod in mods_noShift
            {
               if !InStr(DKaltGR_list, A_LoopField) && (enableAltGr=1)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel
               }

               if (enableAltGr=0)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel
               }
            }
        }
    }  ; dead keys parser

    if (CustomRegionalKeys=1)
    {
        Loop, parse, RegionalKeysList, .
        {
           Hotkey, % "~*" A_LoopField, OnLetterPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
           if (errorlevel!=0) && (audioAlerts=1)
              soundbeep, 1900, 50
        }
    }

    Hotkey, % "~*Space", OnSpacePressed, useErrorLevel
    Hotkey, % "~*Space Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*Backspace", OnBspPressed, useErrorLevel
    Hotkey, % "~*Backspace Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*CapsLock", OnCapsPressed, useErrorLevel
    Hotkey, % "~*CapsLock Up", OnKeyUp, useErrorLevel

    Loop, 24 ; F1-F24
    {
        Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
        Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    NumpadKeysList := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|sc04E|sc04A|sc052|sc04F|sc050|sc051|sc04B|sc04C|sc04D|sc047|sc048|sc049|sc053|sc037|sc135"

    Loop, parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          soundbeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|Home|End|Up|Down|Left|Right|ScrollLock|NumLock|Pause|sc145|sc146|sc046|sc123|sc11C|sc149|sc151|sc122|sc153|sc11d"
    Loop, parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    if (ShowMouseButton=1) || (visualMouseClicks=1)
    {
        Loop, Parse, % "LButton|MButton|RButton", |
        Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    for i, mod in ["LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
    {
        Hotkey, % "~*" mod, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    If typed {
    for i, mod in ["LShift", "RShift"]
        Hotkey, % "~*" mod, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    If (ShowSingleModifierKey=1) && (StickyKeys=0)
    {
      for i, mod in ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        Hotkey, % "~*" mod, OnModPressed, useErrorLevel
        Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    If (StickyKeys=1)
    {
      for i, mod in ["LShift", "RShift"]
        Hotkey, % "~*" mod, OnModPressed, useErrorLevel
        Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }
}

ShowHotkey(HotkeyStr) {

    global tickcount_start2 := A_TickCount

    if (HotkeyStr ~= "i)( \+ )$") && !typed && ShowSingleModifierKey=0 && StickyKeys=1
       Return

    if (HotkeyStr ~= "i)(Shift \+ )$") && ShowSingleModifierKey=0 && StickyKeys=1
       Return

    if (OSDautosize=1)
    {
        bbold := 1
        text_width := GetTextExtentPoint(HotkeyStr, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
        text_width := text_width > maxAllowedGuiWidth ? maxAllowedGuiWidth : text_width
    } else if (OSDautosize=0)
    {
        text_width := maxAllowedGuiWidth
    }

    dGuiX := GuiX
    if (rightoleft=1)
    {
        GuiGetSize(W, H)
        dGuiX := w ? GuiX - w : GuiX
    }

    GuiControl, OSD: , HotkeyText, %HotkeyStr%
    GuiControl, OSD: Move, HotkeyText, w%text_width% Left
    Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% AutoSize, KeypressOSD
    if (rightoleft=1)
    {
        GuiGetSize(W, H)
        dGuiX := w ? GuiX - w : GuiX
        Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% AutoSize, KeypressOSD
    }
    WinSet, AlwaysOnTop, On, KeypressOSD
    visible := 1
    SetTimer, checkMousePresence, on, 400, -3
}

GetTextExtentPoint(sString, sFaceName, nHeight, bBold = 1, bItalic = False, bUnderline = False, bStrikeOut = False, nCharSet = 0) {   ; by Sean from https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363
  hDC := DllCall("GetDC", "Uint", 0)
  nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

  hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 10 + 1 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
  hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

  DllCall("GetTextExtentPoint32", "Uint", hDC, "str", sString, "int", StrLen(sString), "int64P", nSize)

  DllCall("SelectObject", "Uint", hDC, "Uint", hFold)
  DllCall("DeleteObject", "Uint", hFont)
  DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

  nWidth  := nSize & 0xFFFFFFFF
  nHeight := nSize >> 32 & 0xFFFFFFFF

  Return nWidth
}

GuiGetSize( ByRef W, ByRef H) {          ; function by VxE from https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
  Gui, OSD: +LastFoundExist
  VarSetCapacity( rect, 16, 0 )
  DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
  W := NumGet( rect, 8, "int" )
  H := NumGet( rect, 12, "int" )
}

GetKeyStr(letter := 0) {
    modifiers_temp := 0
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]

    ; If any mod but Shift, go ; If shift, check if not letter

    for i, mod in modifiers
    {
        if (mod = "LShift" && typed || mod = "RShift" && typed ? (!letter && GetKeyState(mod)) : GetKeyState(mod))
    ;    if GetKeyState(mod)
            prefix .= mod " + "
    }

    if (!prefix && !ShowSingleKey)
        throw

    key := A_ThisHotkey
    key := RegExReplace(key, "^(~\+<!<\^|~\+<!>\^|~<\^>!|~!#\^\+|~<\^<!|~>\^>!|~#!\+|~#!\^|~#\+\^|~\+!\^|~!#\^|~!\+\^|~!#|~\+#|~#\^|~!\+|~!\^|~\+\^|~#!|~\*|~\^|~!|~#|~\+)")
    StringReplace, key, key, ~,
    if (StrLen(key)=2) && (enableAltGr=0)
    {
          if !(key ~= "i)^(up|f[0-9])")
           StringRight, key, key, 1
    }

    if GetKeyState("Shift")
    {
       If (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
          SetTimer, modBeeper, 5, -10

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }

    if (key ~= "i)^(LCtrl|RCtrl|LShift|RShift|LAlt|RAlt|LWin|RWin)$")
    {
        if (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && visible && !typed && keycount>5)
        {
            throw
        } else
        {
            backupKey := key
            key := ""
            if (StickyKeys=0)
               throw
        }

        prefix := CompactModifiers(prefix)
        if (!prefix && !key)
        {
           if backupKey
           {
              prefix := backupKey="RCtrl" ? "AltGr (special key)" : backupKey
           } else
           {
              prefix := backupKey="RCtrl" ? "AltGr (special key)" : "Unknown key"
           }
           keyCount := 0.1
           shiftPressed := 0
        }
    } else
    {
        backupKey := key
        if (StrLen(key)=1) || InStr(key, " up") && StrLen(key)=4 && typed
        {
            StringLeft, key, key, 1
            key := GetKeyChar(key, "A")
        } else if ( SubStr(key, 1, 2) = "sc" ) {
            key := SpecialSC(key)
        } else if (StrLen(key)<1) && !prefix {
            key := ShowDeadKeys=1 ? "◐" : "(unknown key)"
            key := backupKey ? backupKey : key
        } else if (key = "Volume_Up") {
            SoundGet, master_volume
            key := "Volume up: " round(master_volume)
            soundbeep, 150, 40
        } else if (key = "Volume_Down") {
            SoundGet, master_volume
            key := "Volume down: " round(master_volume)
            soundbeep, 150, 40
        } else if (key = "Volume_mute") {
            SoundGet, master_volume
            SoundGet, master_mute, , mute
            if master_mute = on
               key := "Volume mute"
            if master_mute = off
               key := "Volume level: " round(master_volume)
            soundbeep, 150, 40
        } else if (key = "PrintScreen") {
            if (HideAnnoyingKeys=1 && !prefix)
                throw
            key := "Print Screen"
        } else if (key = "WheelUp") {
            if (ShowMouseButton=0)
               throw
            key := "Wheel Up"
        } else if (key = "WheelDown") {
            if (ShowMouseButton=0)
               throw
            key := "Wheel Down"
        } else if (key = "MButton") {
            key := "Middle Click"
        } else if (key = "RButton") {
            key := "Right Click"
        } else if (key = "LButton") && IsDoubleClick() {
            key := "Double Click"
        } else if (key = "LButton") {
            if (HideAnnoyingKeys=1 && !prefix)
            {
                if (!(substr(typed, 0)=" ") && typed && (ShowMouseButton=1)) {
                    TypedLetter(" ")
                }
                throw
            }
            key := "Left Click"
        }

        _key := key        ; what's this for? :)

        prefix := CompactModifiers(prefix)

        static pre_prefix, pre_key
        StringUpper, key, key, T
        StringUpper, pre_key, pre_key, T
        keyCount := (key=pre_key) && (prefix = pre_prefix) && (repeatCount<1.5) ? keyCount : 1
        if ((ShowPrevKey=1) && keyCount<2 && (A_TickCount-tickcount_start < ShowPrevKeyDelay) && (!(pre_key ~= "i)^(Volume|Caps lock|Num lock|Scroll lock)")))
        {
            ShowPrevKeyValid := 0
            if ((prefix != pre_prefix && key=pre_key) || (key!=pre_key && !prefix) || (key!=pre_key && pre_prefix))
            {
               ShowPrevKeyValid := 1
               if (InStr(pre_key, " up") && StrLen(pre_key)=4)
                   StringLeft, pre_key, pre_key, 1
            }
        } else
        {
            ShowPrevKeyValid := 0
        }
        
        if (key=pre_key) && (ShowKeyCountFired=0) && (ShowKeyCount=1)
        {
           trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
           keyCount := (trackingPresses=0 && keycount<2) ? keycount+1 : keycount
           if (trackingPresses=1)
              keyCount := !keycount ? 1 : keyCount+1
           if (trackingPresses=0) && InStr(prefix, "+") && (A_TickCount-tickcount_start < 600) && (tickcount_start2 - tickcount_start < 500)
              keyCount := !keycount ? 1 : keyCount+1
           ShowKeyCountValid := 1
        } else if (key=pre_key) && (ShowKeyCountFired=1) && (ShowKeyCount=1)
        {
           keyCount := !keycount ? 0 : keyCount+1
           ShowKeyCountValid := 1
        } else
        {
           keyCount := 1
           ShowKeyCountValid := 0
        }
        
        if (InStr(prefix, "+")) || ((!letter) && DisableTypingMode=0) || (DisableTypingMode=1)
        {
            if (prefix != pre_prefix)
            {
                result := (ShowPrevKeyValid=1) ? prefix key " {" pre_prefix pre_key "}" : prefix key
                keyCount := 1
            } else if (ShowPrevKeyValid=1)
            {
                key := (round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" round(keyCount) ")") : (key ", " pre_key)
            } else if (ShowPrevKeyValid=0)
            {
                key := (round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" round(keyCount) ")") : (key)
            }
        } else {
            keyCount := 1
        }
        pre_prefix := prefix
        pre_key := _key
    }

    prefixed := prefix ? 1 : 0
    return result ? result : prefix . key
}

GetShiftedSymbol(symbol) {
    symbolPairs_1 := {1:"!", 2:"@", 3:"#", 4:"$", 5:"%", 6:"^", 7:"&", 8:"*", 9:"(", 0:")", "-":"_", "=":"+", "[":"{", "]":"}", "\":"|", ";":":", "'":"""", ",":"<", ".":">", "/":"?", "``":"~"}

    if (AutoDetectKBD=0)
       kbLayoutSymbols := symbolPairs_1   ; this the default, English US

    StringLower, symbol1, symbol
    StringUpper, symbol2, symbol1

    if kbLayoutSymbols.hasKey(symbol) {
       symbol := kbLayoutSymbols[symbol]
       foundSymbol := 1
    } else if (AltGrPressed=1) && (symbol2==symbol1) && (foundSymbol!=1)
    {
       symbol := ""
    }

    return symbol
}

GetAltGrSymbol(letterina) {
    if (AutoDetectKBD=0)
       kbLayoutAltGRpairs := AltGrPairs_0   ; this the default, English US

    if kbLayoutAltGRpairs.hasKey(letterina)
    {
       if (StickyKeys=1)
          typed := AltGrPressed=1 ? backTyped : ""
       letterina := kbLayoutAltGRpairs[letterina]
       return letterina
    } else
    {
       if (StickyKeys=1)
          typed := AltGrPressed=1 ? backTyped : ""
       letterina := ""
       return letterina
    }
}

CompactModifiers(stringy) {
    if (DifferModifiers = 1)
    {
        StringReplace, stringy, stringy, LCtrl + RAlt, AltGr, All
        StringReplace, stringy, stringy, LCtrl + RCtrl + RAlt, RCtrl + AltGr, All
        StringReplace, stringy, stringy, RAlt, AltGr, All
        StringReplace, stringy, stringy, LAlt, Alt, All
    } else if (DifferModifiers = 0)
    {
        StringReplace, stringy, stringy, LCtrl + RAlt, AltGr, All
        ; StringReplace, stringy, stringy, LCtrl + RCtrl + RAlt, RCtrl + AltGr, All
        StringReplace, stringy, stringy, LCtrl, Ctrl, All
        StringReplace, stringy, stringy, RCtrl, Ctrl, All
        StringReplace, stringy, stringy, LShift, Shift, All
        StringReplace, stringy, stringy, RShift, Shift, All
        StringReplace, stringy, stringy, LAlt, Alt, All
        StringReplace, stringy, stringy, LWin, WinKey, All
        StringReplace, stringy, stringy, RWin, WinKey, All
        StringReplace, stringy, stringy, Ctrl + Ctrl, Ctrl, All
        StringReplace, stringy, stringy, Shift + Shift, Shift, All
        StringReplace, stringy, stringy, WinKey + WinKey, WinKey, All
        StringReplace, stringy, stringy, RAlt, AltGr, All
    }
    return stringy
}

SpecialSC(sc) {
    GetSpecialKeysStates()

    GetKeyState, NumState, NumLock, T
    If (NumState="D" || NumLockForced=1)
    {
       k := {sc11d: "AltGr", sc046: zcSCROL, sc145: "NUM LOCK ON", sc146: "Pause", sc123: "Genius LuxeMate Scroll", sc04E: "[ + ]", sc04A: "[ - ]", sc052: "[ 0 ]", sc04F: "[ 1 ]", sc050: "[ 2 ]", sc051: "[ 3 ]", sc04B: "[ 4 ]", sc04C: "[ 5 ]", sc04D: "[ 6 ]", sc047: "[ 7 ]", sc048: "[ 8 ]", sc049: "[ 9 ]", sc053: "[ . ]", sc037: "[ * ]", sc135: "[ / ]", sc11C: "[Enter]", sc149: "Page Up", sc151: "Page Down", sc153: "Delete", sc122: "Media_Play/Pause"}
    } else
    {
       k := {sc11d: "AltGr", sc046: zcSCROL, sc145: "Num lock off", sc146: "Pause", sc123: "Genius LuxeMate Scroll", sc04E: "[ + ]", sc04A: "[ - ]", sc052: "[Insert]", sc04F: "[End]", sc050: "[Down]", sc051: "[Page Down]", sc04B: "[Left]", sc04C: "[Undefined]", sc04D: "[Right]", sc047: "[Home]", sc048: "[Up]", sc049: "[Page Up]", sc053: "[Delete]", sc037: "[ * ]", sc135: "[ / ]", sc11C: "[Enter]", sc149: "Page Up", sc151: "Page Down", sc153: "Delete", sc122: "Media_Play/Pause"}
    }

    if (!k[sc] && AutoDetectKBD=1 && InStr(CurrentKBD, "czech"))
       k := {sc02BvkDC: "¨", sc01BvkDD:"]", sc00CvkBD:"-"}

    if (k[sc]="¨" && (AutoDetectKBD=1) && InStr(CurrentKBD, "czech (prog"))
       k[sc] := "\"

    if (!k[sc] && AutoDetectKBD=1)
       k := {sc01AvkBB:"+", sc02BvkDE: "#", sc02BvkDC: "\", sc029vkDF: "``", sc029vkBF: "§", sc028vkC0: "'", sc028vkDE: "·", sc00DvkDD: "`", sc00DvkBF: "´", sc01BvkDD:")", sc00CvkBD:"=", sc035vkBF:"/", sc027vkBA:";"}

    return k[sc]
}

; <tmplinshi>: thanks to Lexikos: https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236
; This enables partial support for non-English keyboard layouts.
; If the script initializes with the English keyboard layout, but then used with another one, this function gets proper key names,

GetKeyChar(Key, WinTitle:=0) {
    thread := WinTitle=0 ? 0
        : DllCall("GetWindowThreadProcessId", "ptr", WinExist(WinTitle), "ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")
    vk := GetKeyVK(Key), sc := GetKeySC(Key)
    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)
    n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc
        , "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", hkl)
    return StrGet(&char, n, "utf-16")
}

IdentifyKBDlayout() {
  if (AutoDetectKBD=1) && (ForceKBD=0)
  {
    VarSetCapacity(kbLayoutRaw, 32, 0)
    DllCall("GetKeyboardLayoutName", "Str", kbLayoutRaw)
  }

  if (ForceKBD=1)
     kbLayoutRaw := (ForcedKBDlayout = 0) ? ForcedKBDlayout1 : ForcedKBDlayout2

  StringRight, kbLayout, kbLayoutRaw, 4

  #Include *i keypress-osd-languages.ini

  if (!FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1)) || (FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1))
  {
      soundbeep
      UrlDownloadToFile, http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-languages.ini, keypress-osd-languages.ini
      ShowHotkey("Please wait. Downloading languages file.")
      langFileDownloading := 1
      IniWrite, %langFileDownloading%, %IniFile%, TempSettings, langFileDownloading
      Sleep, 5000
  }

  if (AutoDetectKBD=1)
  {
      IniRead, langFileDownloading, %IniFile%, TempSettings, langFileDownloading
      IniRead, ReloadCounter, %IniFile%, TempSettings, ReloadCounter, 0
  }

  if ((loadedLangz!=1) && (AutoDetectKBD=1))
  {
     if (FileExist("keypress-osd-languages.ini") && (ReloadCounter>2))
     {
         ReloadCounter := 0
         IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
         MsgBox, Corrupt or old file: keypress-osd-languages.ini. The attempt to download it seems to have failed. See script file for a link to download it. Support for non-English keyboards is unavailable.
         ReloadError := 1
     } else if (FileExist("keypress-osd-languages.ini") && (langFileDownloading=1) && (ReloadError!=1))
     {
         langFileDownloading := 0
         ReloadCounter := ReloadCounter+1
         IniWrite, %langFileDownloading%, %IniFile%, TempSettings, langFileDownloading
         IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
         Sleep, 500
         Reload
     } else
     {
        MsgBox, Missing or corrupt file: keypress-osd-languages.ini. The attempt to download it seems to have failed. See script file for a link to download it. Support for non-English keyboards is now deactivated.
     }
  }
  
  if ((loadedLangz=1) && (AutoDetectKBD=1))
  {
      IniRead, ReloadCounter, %IniFile%, TempSettings, ReloadCounter
      if (ReloadCounter > 0.1)
      {
         ReloadCounter := 0
         IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
      }
  }

  check_kbd := StrLen(LangName_%kbLayout%)>2 ? 1 : 0
  check_kbd_exact := StrLen(LangRaw_%kbLayoutRaw%)>2 ? 1 : 0
  if (check_kbd_exact=0)
      partialKBDmatch = (Partial match)

  if (check_kbd=0)
  {
      ShowHotkey("Unrecognized layout: (kbd " kbLayoutRaw ").")
      SetTimer, HideGUI, % -DisplayTime
      CurrentKBD := "Layout" %kbLayoutRaw% " unrecognized"
      soundbeep, 500, 900
  }

  StringLeft, kbLayoutSupport, LangName_%kbLayout%, 1
  if (kbLayoutSupport="-") && (check_kbd=1)
  {
      ShowHotkey("Unsupported layout: " LangName_%kbLayout% " (kbd" kbLayout ").")
      SetTimer, HideGUI, % -DisplayTime
      soundbeep, 500, 900
      CurrentKBD := LangName_%kbLayout% " unsupported. " kbLayoutRaw
  }

  if (DeadKeysPresent_%kbLayoutRaw%=1)
  {
      DeadKeys := 1
      if DKaltGR_%kbLayoutRaw%
         DKaltGR_list := DKaltGR_%kbLayoutRaw%
      if DKshift_%kbLayoutRaw%
         DKshift_list := DKshift_%kbLayoutRaw%
      if DKnotShifted_%kbLayoutRaw%
         DKnotShifted_list := DKnotShifted_%kbLayoutRaw%
  }

  if (kbLayoutSupport!="-") && (check_kbd=1)
  {
      megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list

      Loop, parse, LangChars_%kbLayout%, |
      {
         if (DeadKeys=1)
         {
             for each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
             {
                 if (A_LoopField = char2skip && DeadKeys=1)
                    continue, 2
             }
         }

         Hotkey, % "~*" A_LoopField, OnLetterPressed, useErrorLevel
         Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
         if (errorlevel!=0) && (audioAlerts=1)
             soundbeep, 1900, 50
      }

      identifiedKbdName := check_kbd_exact=1 ? LangRaw_%kbLayoutRaw% : LangName_%kbLayout%

      if (SilentDetection=0)
      {
          ShowHotkey("Layout detected: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)
          SetTimer, HideGUI, % -DisplayTime/2
          CurrentKBD := "Auto-detected: " identifiedKbdName ". " kbLayoutRaw

          If (ForceKBD=1)
             CurrentKBD := "Forced: " identifiedKbdName ". " kbLayoutRaw
      }
  }

    if (!symbolPairs_%kbLayoutRaw%)
    {
        RawNotMatch := 1
    } else
    {
        kbLayoutSymbols := symbolPairs_%kbLayoutRaw%
    }

    if (!symbolPairs_%kbLayout% && RawNotMatch=1)
    {
       kbLayoutSymbols := 0           ; undefined layout
    } else if (RawNotMatch=1)
    {
       kbLayoutSymbols := symbolPairs_%kbLayout%
    }

    if noCaps_%kbLayoutRaw%
       noCapsAllowed := noCaps_%kbLayoutRaw%

    if AltGrPairs_%kbLayoutRaw%
    {
       kbLayoutAltGRpairs := AltGrPairs_%kbLayoutRaw%
    } else
    {
      enableAltGr := 0
    }

    if (ForceKBD=0) && (AutoDetectKBD=1) && (loadedLangz=1)
    {
       identifiedKbdName := Strlen(identifiedKbdName)>3 ? identifiedKbdName : "unsupported layout"
       StringLeft, clayout, identifiedKbdName, 20
       Menu, tray, add, (%clayout%), dummy
       Menu, tray, Disable, (%clayout%)
       Menu, tray, add

       SetFormat, Integer, H
       ThisInputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
       SetFormat, Integer, d
       IniWrite, %identifiedKbdName%, %IniFile%, Languages, %ThisInputLocaleID%
    }

    if (ConstantAutoDetect=1) && (AutoDetectKBD=1) && (loadedLangz=1) && (ForceKBD=0)
       SetTimer, ConstantKBDchecker, 2000, -15
}

ConstantKBDchecker() {
  if A_IsSuspended
     Return

  SetFormat, Integer, H
  WinGet, WinID,, A
  ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
  NewInputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
    if (InputLocaleID != NewInputLocaleID && NewInputLocaleID!="0x0")
    {
        InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
        lastKBDid := InputLocaleID
        IniRead, InputLocaleName, %inifile%, Languages, %InputLocaleID%, %InputLocaleID%
        if (SilentDetection=0)
        {
           InputLocaleName := Strlen(InputLocaleName)>3 && !InStr(InputLocaleName, "unsupported") ? InputLocaleName : lastKBDid
           ShowHotkey("Layout changed to: " InputLocaleName)
           sleep, 1250
        }
      
        sleep, 250
        Reload
    }
}

IsDoubleClick(MSec = 300) {
    Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < MSec)
}

IsDoubleClickEx(MSec = 300) {
    preHotkey := RegExReplace(A_PriorHotkey, "i) Up$")
    Return (A_ThisHotKey = preHotkey) && (A_TimeSincePriorHotkey < MSec)
}

HideGUI() {
    visible := 0
    Gui, OSD: Hide
    SetTimer, checkMousePresence, off
}

returnToTyped() {
    if (StrLen(typed) > 1) && (A_TickCount-lastTypedSince < (DisplayTime*2+5000)) && ShowSingleKey=1 && !A_IsSuspended
    {
           ShowHotkey(typed "|")
           SetTimer, HideGUI, % -DisplayTime
    }
}

checkMousePresence() {
    id := mouseIsOver()
    title := getWinTitleFromID(id)
    if (title = "KeypressOSD") && (JumpHover=0)
    {
       HideGUI()
    } else if (title = "KeypressOSD") && (JumpHover=1)
    {
       Gosub, TogglePosition
    }
}

mouseIsOver() {
    MouseGetPos,,, id
    return id
}

getWinTitleFromID(id) {
    WinGetTitle, title, % "ahk_id " id
    return title
}

CreateGlobalShortcuts() {
   if (KeyboardShortcuts=1) {
      Hotkey, !+^F7, ToggleForcedLanguage
      Hotkey, !+^F8, ToggleShowSingleKey
      Hotkey, !+^F9, TogglePosition
      Hotkey, !+^F10, EnableCustomKeys
      Hotkey, !+^F11, DetectLangNow
      Hotkey, !+^F12, ReloadScript
      Hotkey, !Pause, ToggleCapture2Text   ; Alt+Pause/Break
      Hotkey, +Pause, SuspendScript   ; shift+Pause/Break
    }
}

SuspendScript:         ; Shift+Pause/Break
   Suspend, Permit

   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   Menu, Tray, UseErrorLevel
   Menu, Tray, Rename, &OSD activated,&OSD deactivated
   if (ErrorLevel=1)
   {
      Menu, Tray, Rename, &OSD deactivated,&OSD activated
      Menu, Tray, Check, &OSD activated
   }
   Menu, Tray, Uncheck, &OSD deactivated

   CreateOSDGUI()
   ShowHotkey("KeyPress OSD toggled")
   SetTimer, HideGUI, % -DisplayTime/6
   Sleep, DisplayTime/6+15
   Suspend
return

ToggleShowSingleKey:
    ShowSingleKey := (!ShowSingleKey) ? 1 : 0
    CreateOSDGUI()
    IniWrite, %ShowSingleKey%, %IniFile%, SavedSettings, ShowSingleKey
    ShowHotkey("Show single keys = " ShowSingleKey)
    SetTimer, HideGUI, % -DisplayTime
return

TogglePosition:

    if (A_IsSuspended=1)
    {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
    }
 
    GUIposition := (GUIposition=1) ? 0 : 1
    Gui, OSD: hide

    if (GUIposition=1)
    {
       GuiY := GuiYa
       GuiX := GuiXa
    } else
    {
       GuiY := GuiYb
       GuiX := GuiXb
    }

    Gui, OSD: Destroy
    sleep, 20
    CreateOSDGUI()
    sleep, 20

    if (Capture2Text!=1)
    {
        IniWrite, %GUIposition%, %IniFile%, SavedSettings, GUIposition
        ShowHotkey("OSD position changed")
        sleep, 250
        ShowHotkey("OSD position changed")
        SetTimer, HideGUI, % -DisplayTime/3
    }
return

ToggleForcedLanguage:
    ForceKBD := 1
    AutoDetectKBD := 1
    ForcedKBDlayout := (ForcedKBDlayout = 0) ? 1 : 0
    CreateOSDGUI()
    ShowHotkey("Forced keyboard layout changed. Please wait...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    sleep, 400
    Reload
return

EnableCustomKeys:
    CustomRegionalKeys := CustomRegionalKeys = 1 ? 0 : 1
    IniWrite, %CustomRegionalKeys%, %IniFile%, SavedSettings, CustomRegionalKeys
    ShowHotkey("Custom Regional keys = " RegionalKeys)
    sleep, 1000
    Reload
return

DetectLangNow:
    CreateOSDGUI()
    ForceKBD := 0
    AutoDetectKBD := 1
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    ShowHotkey("Detecting keyboard layout...")
    sleep, 800
    Reload
return

ReloadScript:
    CreateOSDGUI()
    ShowHotkey("OSD reinitializing...")
    sleep, 1500
    Reload
return

ToggleCapture2Text:        ; Alt+Pause/Break
   if (A_IsSuspended=1)
   {
      SoundBeep, 300, 900
      Return
   }

   DetectHiddenWindows, on

   IfWinNotExist, Capture2Text
   {
        if (Capture2Text!=1)
        {
            SoundBeep, 1900
            MsgBox, 4,, Capture2Text was not detected. Do you want to continue?
            IfMsgBox Yes
            {
                featureValidated := 1
            } else
            {
                featureValidated := 0
            }
        }
   }

    featureValidated := featureValidated=0 ? 0 : 1

    if (featureValidated=1)
    {
        Menu, Tray, UseErrorLevel
        Menu, Tray, Rename, &Capture2Text enable, &Capture2Text enabled
        if (ErrorLevel=1)
           Menu, Tray, Rename, &Capture2Text enabled, &Capture2Text enable
        Menu, Tray, Uncheck, &Capture2Text enable
        Menu, Tray, Check, &Capture2Text enabled

        Sleep, 300
        Capture2Text := (Capture2Text=1) ? 0 : 1
    }

    if (Capture2Text=1) && (featureValidated=1)
    {
        JumpHover := 1
        OSDautosize := 1
        maxAllowedGuiWidth := A_ScreenWidth
        if (ClipMonitor=0)
        {
           ClipMonitor := 1
           OnClipboardChange("ClipChanged")
        }
        SetTimer, MouseHalo, off
        Gui, MouseH: Hide
        SetTimer, capturetext, 1500, -10
        ShowHotkey("Enabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime/7
    } else if (featureValidated=1)
    {
        Capture2Text := (Capture2Text=1) ? 0 : 1
        IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
        if (GUIposition=1)
        {
           GuiY := GuiYa
           GuiX := GuiXa
        } else
        {
           GuiY := GuiYb
           GuiX := GuiXb
        }
        IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
        IniRead, OSDautosize, %inifile%, SavedSettings, OSDautosize, %OSDautosize%
        maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
        Gui, OSD: Destroy
        sleep, 50
        CreateOSDGUI()
        sleep, 50
        IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
        IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
        SetTimer, capturetext, off
        Capture2Text := (Capture2Text=1) ? 0 : 1
        ShowHotkey("Disabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
        if (ShowMouseHalo=1)
           SetTimer, MouseHalo, on
    }

   DetectHiddenWindows, off
Return

capturetext() {
    if ((A_TimeIdlePhysical < 2000) && !A_IsSuspended)
       Send, {Pause}             ; set here the keyboard shortcut configured in Capture2Text
}

ClipChanged(Type) {
    sleep, 300
    if (type=1 && ClipMonitor=1 && !A_IsSuspended)
    {
       maxAllowedGuiWidth := A_ScreenWidth*2
       troll := clipboard
       Stringleft, troll, troll, 130
       StringReplace, troll, troll, `r`n, %A_SPACE%, All
       StringReplace, troll, troll, %A_TAB%, %A_SPACE%, All
       StringReplace, troll, troll, %A_SPACE%%A_SPACE%, , All
       ShowHotkey(troll)
       SetTimer, HideGUI, % -DisplayTime*2
       maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
    } else if (type=2 && ClipMonitor=1 && !A_IsSuspended)
    {
       ShowHotkey("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

CreateMouseGUI() {
    global

    Gui Mouser: +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui Mouser: Margin, 0, 0
}

ShowMouseClick(clicky) {
    SetTimer, HideMouseClickGUI, 900, -2
    SetTimer, ShowMouseIdleLocation, off
    Gui Mouser: Destroy
    MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
    TransparencyLevel := MouseVclickAlpha - MouseClickCounter*4
    BoxW := (16 + MouseClickCounter/3)*ClickScale
    BoxH := 40*ClickScale
    MouseDistance := 15*ClickScale
    MouseGetPos, mX, mY
    mY := mY - BoxH
    if InStr(clicky, "LButton")
    {
       mX := mX - BoxW*2 - MouseDistance
    } else if InStr(clicky, "MButton")
    {
       BoxW := (45 + MouseClickCounter)*ClickScale
       mX := mX - BoxW
    } else if InStr(clicky, "RButton")
    {
       mX := mX + MouseDistance
    } else if InStr(clicky, "Wheelup")
    {
       BoxW := (50 + MouseClickCounter)*ClickScale
       BoxH := 15*ClickScale
       mX := mX - BoxW
       mY := mY - MouseDistance
    } else if InStr(clicky, "Wheeldown")
    {
       BoxW := (50 + MouseClickCounter)*ClickScale
       BoxH := 15*ClickScale
       mX := mX - BoxW
       mY := mY + BoxH*2 + MouseDistance*2
    }

    InnerColor := "555555"
    OuterColor := "aaaaaa"
    BorderSize := 4
    RectW := BoxW - BorderSize*2
    RectH := BoxH - BorderSize*2

    CreateMouseGUI()

    Gui Mouser: Color, %OuterColor%  ; outer rectangle
    Gui Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
    Gui Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
    WinSet, Transparent, %TransparencyLevel%, MousarWin
    Sleep, 200
    WinSet, AlwaysOnTop, On, MousarWin
}

HideMouseClickGUI() {
    Loop, {
       MouseDown := 0
       if GetKeyState("LButton","P")
          MouseDown := 1
       if GetKeyState("RButton","P")
          MouseDown := 1
       if GetKeyState("MButton","P")
          MouseDown := 1

       If (MouseDown=0)
       {
          Sleep, 250
          Gui Mouser: Hide
          MouseClickCounter := 20
          SetTimer, HideMouseClickGUI, off
          if (FlashIdleMouse=1)
             SetTimer, ShowMouseIdleLocation, on
          Break
       } else
       {
          WinSet, Transparent, 55, MousarWin
       }
    }
}

ShowMouseIdleLocation() {
    If (A_TimeIdlePhysical > (MouseIdleAfter*1000)) && !A_IsSuspended
    {
       Gui Mouser: Destroy
       Sleep, 300
       MouseGetPos, mX, mY
       BoxW := MouseIdleRadius
       BoxH := BoxW
       mX := mX - BoxW
       mY := mY - BoxH
       BorderSize := 4
       RectW := BoxW - BorderSize*2
       RectH := BoxH - BorderSize*2
       InnerColor := "111111"
       OuterColor := "eeeeee"
       CreateMouseGUI()
       Gui Mouser: Color, %OuterColor%  ; outer rectangle
       Gui Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
       Gui Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
       WinSet, Transparent, %IdleMouseAlpha%, MousarWin
       WinSet, AlwaysOnTop, On, MousarWin
    } else
    {
        Gui Mouser: Hide
    }
}

MouseHalo() {
    If (ShowMouseHalo=1) && !A_IsSuspended
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       mX := mX - BoxW
       mY := mY - BoxH
       Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow +E0x20
       Gui, MouseH: Margin, 0, 0
       Gui, MouseH: Color, %MouseHaloColor%
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
       WinSet, Transparent, %MouseHaloAlpha%, MousarHallo
       WinSet, AlwaysOnTop, On, MousarHallo
    }
}

InitializeTray() {

    Menu, SubSetMenu, add, &Keyboard, ShowKBDsettings
    Menu, SubSetMenu, add, &Mouse, ShowMouseSettings
    Menu, SubSetMenu, add, &OSD appearances, ShowOSDsettings
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, Restore defaults, DeleteSettings
    Menu, SubSetMenu, add, Key &history, KeyHistoryWindow
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, &Update now, updateNow
    Menu, tray, tip, KeyPress OSD v%version%
    Menu, tray, NoStandard
    Menu, tray, add, &Preferences, :SubSetMenu
    Menu, tray, add
    Menu, tray, add, &Detect keyboard layout, DetectLangNow
    if (ForceKBD=1)
    {
       StringRight, clayout, ForcedKBDlayout, 4
       Menu, tray, add, Toggle &forced layout (%clayout%), ToggleForcedLanguage
       Menu, tray, add
    }
    Menu, tray, add, &Toggle OSD positions, TogglePosition
    Menu, tray, add, &Capture2Text enable, ToggleCapture2Text
    Menu, tray, add, &OSD activated, SuspendScript
    Menu, tray, Check, &OSD activated
    Menu, tray, add
    Menu, tray, add, &Restart, ReloadScript
    Menu, tray, add
    Menu, tray, add, &Help, dummy
    Menu, tray, add, &About, AboutWindow
    Menu, tray, add
    Menu, tray, add, E&xit, KillScript
}

KeyHistoryWindow() {
  KeyHistory
}

DeleteSettings() {
    MsgBox, 4,, Are you sure you want to delete the stored settings?
    IfMsgBox Yes
    {
       FileSetAttrib, -R, %IniFile%
       FileDelete, %IniFile%
       Reload
    }
}

KillScript:
   ShaveSettings()
   ShowHotkey("Bye byeee :-)")
   SoundBeep, 300,200
   SoundBeep, 480,100
   SoundBeep, 200,50
   SoundBeep, 600,200
   SoundBeep, 480,100
   SoundBeep, 200,150
   Sleep, 250
ExitApp

SettingsGUI() {
   Global
   Gui, SettingsGUIA: destroy
   Gui, SettingsGUIA: Default
   Gui, SettingsGUIA: -sysmenu
   Gui, SettingsGUIA: margin, 15, 15
}

ShowKBDsettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()

    Gui, Add, text, x15 y15 w220, Status: %CurrentKBD%. %kbLayoutRaw%
    Gui, SettingsGUIA: add, text, xp+0 yp+40, Settings regarding keyboard layouts
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continously detect layout changes
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%SilentDetection% vSilentDetection, Silent detection (no messages)
    Gui, Add, Checkbox, xp+0 yp+20 Checked%audioAlerts% vaudioAlerts, Beep for failed key bindings
    Gui, Add, Checkbox, xp+0 yp+20 Checked%enableAltGrUser% venableAltGrUser, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xp+0 yp+20 gForceKbdInfo Checked%ForceKBD% vForceKBD, Force detected keyboard layout (A / B)
    Gui, Add, Edit, xp+20 yp+20 w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout1, %ForcedKBDlayout1%
    Gui, Add, Edit, xp+73 yp+0 w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout2, %ForcedKBDlayout2%
    Gui, Add, Checkbox, xp-93 yp+25 gVerifyKeybdOptions Checked%CustomRegionalKeys% vCustomRegionalKeys, Bind additional keys (dot separated)
    Gui, Add, Edit, xp+20 yp+20 w140 r1 -multi -wantReturn -wantTab -wrap vRegionalKeysList, %RegionalKeysList%
    Gui, Add, Checkbox, xp-20 yp+25 gVerifyKeybdOptions Checked%IgnoreAdditionalKeys% vIgnoreAdditionalKeys, Ignore specific keys (dot separated)
    Gui, Add, Edit, xp+20 yp+20 w140 r1 -multi -wantReturn -wantTab -wrap vIgnorekeysList, %IgnorekeysList%

    Gui, SettingsGUIA: add, text, xp-30 yp+35, Make beeps when keys are released
    Gui, Add, Checkbox, xp+10 yp+20 Checked%CapslockBeeper% vCapslockBeeper, While CapsLock is ON
    Gui, Add, Checkbox, gVerifyKeybdOptions xp+0 yp+20 Checked%KeyBeeper% vKeyBeeper, Binded keys
    Gui, Add, Checkbox, gVerifyKeybdOptions xp+0 yp+20 Checked%ModBeeper% vModBeeper, Modifiers (Ctrl, Alt, WinKey, Shift)
    Gui, Add, Checkbox, xp+0 yp+20 Checked%BeepHiddenKeys% vBeepHiddenKeys, Even if keys are not displayed in the OSD

    Gui, SettingsGUIA: add, text, x260 y15, Display behavior
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%DisableTypingMode% vDisableTypingMode, Disable typing mode
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%NavKeysFriendly% vNavKeysFriendly, Navigation keys do not erase text
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys, not just combinations
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowDeadKeys% vShowDeadKeys, Display a generic symbol for dead keys
    Gui, Add, Checkbox, xp+0 yp+20 Checked%HideAnnoyingKeys% vHideAnnoyingKeys, Hide Left Click and PrintScreen
    Gui, Font, Bold
    Gui, Add, Checkbox, xp+0 yp+20 Checked%StickyKeys% vStickyKeys, Sticky keys mode
    Gui, Font, Normal
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowSingleModifierKey% vShowSingleModifierKey, Display modifiers
    Gui, Add, Checkbox, xp+0 yp+20 Checked%DifferModifiers% vDifferModifiers, Differ left and right modifiers
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCount% vShowKeyCount, Show key count
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCountFired% vShowKeyCountFired, Count number of key fires
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowPrevKey% vShowPrevKey, Show previous key (delay in ms)
    Gui, Add, Edit, xp+180 yp+0 w24 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vShowPrevKeyDelay, %ShowPrevKeyDelay%
    Gui, Add, text, xp-180 yp+25, When typing, display Space bar as
    Gui, Add, Edit, xp+180 yp+0 w24 r1 limit1 -multi -wantCtrlA -wantReturn -wantTab -wrap vSpaceReplacer, %SpaceReplacer%

    Gui, SettingsGUIA: add, text, xp-180 yp+35, Other options
    Gui, Add, Checkbox, xp+10 yp+20 Checked%KeyboardShortcuts% vKeyboardShortcuts, Global keyboard shortcuts
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ClipMonitor% vClipMonitor, Monitor clipboard changes
    Gui, Add, Checkbox, xp+0 yp+20 w180 Checked%JumpHover% vJumpHover, Toggle OSD positions when mouse runs over it
    Gui, SettingsGUIA: add, Button, xp+0 yp+55 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+62 yp+0 w60 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Keyboard settings: KeyPress OSD
    VerifyKeybdOptions()
}

VerifyKeybdOptions() {
    GuiControlGet, AutoDetectKBD
    GuiControlGet, ConstantAutoDetect
    GuiControlGet, IgnoreAdditionalKeys
    GuiControlGet, CustomRegionalKeys
    GuiControlGet, ForceKBD
    GuiControlGet, ForcedKBDlayout1
    GuiControlGet, ForcedKBDlayout2
    GuiControlGet, DisableTypingMode
    GuiControlGet, NavKeysFriendly
    GuiControlGet, ShowSingleKey
    GuiControlGet, HideAnnoyingKeys
    GuiControlGet, SilentDetection
    GuiControlGet, ShowSingleModifierKey
    GuiControlGet, ShowKeyCount
    GuiControlGet, ShowKeyCountFired
    GuiControlGet, ShowPrevKey
    GuiControlGet, keyBeeper
    GuiControlGet, modBeeper
    GuiControlGet, enableAltGrUser
    GuiControlGet, ShowDeadKeys


    if ((keyBeeper=1) || (modBeeper=1))
    {
       GuiControl, Enable, BeepHiddenKeys
    } else
    {
       GuiControl, Disable, BeepHiddenKeys
    }

    if (ShowSingleModifierKey=0)
    {
       GuiControl, Disable, DifferModifiers
    } else
    {
       GuiControl, Enable, DifferModifiers
    }

    if (ShowPrevKey=0)
    {
       GuiControl, Disable, ShowPrevKeyDelay
    } else
    {
       GuiControl, Enable, ShowPrevKeyDelay
    }

    if (ShowKeyCount=0)
    {
       GuiControl, Disable, ShowKeyCountFired
    } else
    {
       GuiControl, Enable, ShowKeyCountFired
    }

    if (ShowSingleKey=0)
    {
       GuiControl, Disable, DisableTypingMode
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, NavKeysFriendly
       GuiControl, Disable, HideAnnoyingKeys
       GuiControl, Disable, ShowSingleModifierKey
       GuiControl, Disable, SpaceReplacer
       GuiControl, Disable, CapslockBeeper
    } else
    {
       GuiControl, Enable, DisableTypingMode
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, NavKeysFriendly
       GuiControl, Enable, HideAnnoyingKeys
       GuiControl, Enable, ShowSingleModifierKey
       GuiControl, Enable, SpaceReplacer
       GuiControl, Enable, CapslockBeeper
    }
  
    if (DisableTypingMode=1)
    {
       GuiControl, Disable, SpaceReplacer
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, NavKeysFriendly
    } else if (ShowSingleKey!=0)
    {
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, SpaceReplacer
       GuiControl, Enable, NavKeysFriendly
    }

    if (AutoDetectKBD=1)
    {
       GuiControl, Enable, ConstantAutoDetect
       GuiControl, Enable, ForceKBD
    } else 
    {
       GuiControl, Disable, ConstantAutoDetect
       GuiControl, , ForceKBD, 0
       GuiControl, Disable, ForceKBD
       GuiControl, Disable, ForcedKBDlayout1
       GuiControl, Disable, ForcedKBDlayout2
    }

    if (ForceKBD=1) && (AutoDetectKBD=1)
    {
       GuiControl, Enable, ForcedKBDlayout1
       GuiControl, Enable, ForcedKBDlayout2
       GuiControl, Disable, ConstantAutoDetect
    } else
    {
       GuiControl, Disable, ForcedKBDlayout1
       GuiControl, Disable, ForcedKBDlayout2
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0))
    {
       GuiControl, Disable, SilentDetection
       GuiControl, Disable, enableAltGrUser
    } else
    {
       GuiControl, Enable, SilentDetection
       GuiControl, Enable, enableAltGrUser
    }

    if (CustomRegionalKeys=1)
    {
       GuiControl, Enable, RegionalKeysList
    } else
    {
       GuiControl, Disable, RegionalKeysList
    }

    if (IgnoreAdditionalKeys=1)
    {
       GuiControl, Enable, IgnorekeysList
    } else
    {
       GuiControl, Disable, IgnorekeysList
    }

}

ForceKbdInfo() {
    GuiControlGet, ForceKBD
    if (ForceKBD=1)
       MsgBox, , About Force Keyboard Layout, Please enter the keyboard layout codes you want to enforce. You can toggle between the two layouts with Ctrl+Alt+Shift+F7. See Help for more details.

    VerifyKeybdOptions()
}

ShowMouseSettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }
    
    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()

    Gui, Add, Checkbox, gVerifyMouseOptions x15 x15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%FlashIdleMouse% vFlashIdleMouse, Flash idle mouse to locate it
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, Beep for mouse clicks
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%VisualMouseClicks% vVisualMouseClicks, Visual mouse clicks (scale, alpha)
    Gui, Add, Edit, xp+16 yp+20 w30 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap vClickScaleUser, %ClickScaleUser%
    Gui, Add, Edit, xp+36 yp+0 w30 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMouseVclickAlpha, %MouseVclickAlpha%

    Gui, Add, Edit, x335 y15 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMouseHaloRadius, %MouseHaloRadius%
    Gui, Add, Progress, xp+0 yp+25 w35 h20 BackgroundBlack c%MouseHaloColor% vMouseHaloColor, 100
    Gui, Add, Button, xp+36 yp+0 w25 h20 gChooseColorHalo, E
    Gui, Add, Edit, xp-36 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMouseHaloAlpha, %MouseHaloAlpha%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMouseIdleAfter, %MouseIdleAfter%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMouseIdleRadius, %MouseIdleRadius%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vIdleMouseAlpha, %IdleMouseAlpha%

    Gui, Add, text, x210 y15, Halo radius:
    Gui, Add, text, xp+0 yp+25, Halo color:
    Gui, Add, text, xp+0 yp+25, Halo alpha (0 - 255):
    Gui, Add, text, xp+0 yp+25, Mouse idle after (in sec.)
    Gui, Add, text, xp+0 yp+25, Idle halo radius:
    Gui, Add, text, xp+0 yp+25, Idle halo alpha (0 - 255):

    Gui, SettingsGUIA: add, Button, x15 y160 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+62 yp+0 w60 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Mouse settings: KeyPress OSD

    VerifyMouseOptions()
}

ChooseColorHalo() {
    if (ShowMouseHalo=0)
       Return

    cc := 0
    cc := dlg_color(cc,hwnd)
    MouseHaloColor := hexRGB(cc)
    StringRight, MouseHaloColor, MouseHaloColor, 6
    GuiControl, +c%MouseHaloColor%, MouseHaloColor
}

hexRGB(c) {
  setformat, IntegerFast, H
  c := (c&255)<<16|(c&65280)|(c>>16),c:=SubStr(c,1)
  SetFormat, IntegerFast, D
  return c
}

Dlg_Color(Color,hwnd) {
  static
  if !cc {
    VarSetCapacity(CUSTOM,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
    Loop, 16 {
      NumPut(col,CUSTOM,(A_Index-1)*4,"UInt")
    }
  }

  NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr")
  ,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
  ,NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
  ret := DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")

  if !ret
     exit

  Loop,16
    NumGet(custom,(A_Index-1)*4,"UInt")

  Color := NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
  return Color
}

VerifyMouseOptions() {
    GuiControlGet, FlashIdleMouse
    GuiControlGet, ShowMouseHalo
    GuiControlGet, ShowMouseButton
    GuiControlGet, VisualMouseClicks

    if (ShowMouseButton=0 && VisualMouseClicks=0)
       GuiControl, Disable, MouseBeeper
    else 
       GuiControl, Enable, MouseBeeper

    if VisualMouseClicks=0
    {
       GuiControl, Disable, ClickScaleUser
       GuiControl, Disable, MouseVclickAlpha
    } else
    {
       GuiControl, Enable, ClickScaleUser
       GuiControl, Enable, MouseVclickAlpha
    }

    if (FlashIdleMouse=0)
    {
       GuiControl, Disable, MouseIdleAfter
       GuiControl, Disable, MouseIdleRadius
       GuiControl, Disable, IdleMouseAlpha
    } else
    {
       GuiControl, Enable, MouseIdleAfter
       GuiControl, Enable, MouseIdleRadius
       GuiControl, Enable, IdleMouseAlpha
    }

    disabledColor := "cccccc"
    if (ShowMouseHalo=0)
    {
       GuiControl, Disable, MouseHaloRadius
       GuiControl, +c%disabledColor%, MouseHaloColor
       GuiControl, Disable, MouseHaloAlpha
    } else
    {
       GuiControl, Enable, MouseHaloRadius
       GuiControl, +c%MouseHaloColor%, MouseHaloColor
       GuiControl, Enable, MouseHaloAlpha
    }
}

ShowOSDsettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()
    EnumFonts()

    static positionB
    GUIposition := GUIposition + 1

    Gui, Add, Radio, x15 y35 gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, xp+0 yp+25 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, Button, xp+145 yp-25 w25 h20 gLocatePositionA, L
    Gui, Add, Edit, xp+27 yp+0 w30 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap vGuiXa, %GuiXa%
    Gui, Add, Edit, xp+33 yp+0 w30 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap vGuiYa, %GuiYa%
    Gui, Add, Button, xp-60 yp+25 w25 h20 gLocatePositionB, L
    Gui, Add, Edit, xp+27 yp+0 w30 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap vGuiXb, %GuiXb%
    Gui, Add, Edit, xp+33 yp+0 w30 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap vGuiYb, %GuiYb%
    Gui, Add, DropDownList, xp-100 yp+25 w130 Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+66 yp+25 w62 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vFontSize, %FontSize%
    Gui, Add, Progress, xp+0 yp+25 w30 h20 BackgroundBlack c%OSDtextColor% vOSDtextColor, 100
    Gui, Add, Button, xp+35 yp+0 w30 h20 gChooseColorTEXT, E
    Gui, Add, Progress, xp-35 yp+25 w30 h20 BackgroundBlack c%OSDbgrColor% vOSDbgrColor, 100
    Gui, Add, Button, xp+35 yp+0 w30 h20 gChooseColorBGR, E
    Gui, Add, Edit, xp-35 yp+25 w62 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap vDisplayTimeUser, %DisplayTimeUser%
    Gui, Add, Edit, xp+0 yp+25 w30 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vGuiWidth, %GuiWidth%
    Gui, Add, Edit, xp+33 yp+0 w30 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vmaxGuiWidth, %maxGuiWidth%
    Gui, Add, Edit, xp-33 yp+25 w62 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vOSDautosizeFactory, %OSDautosizeFactory%

    Gui, Add, text, x15 y15, OSD location presets. Click L to define each.
    Gui, Add, text, xp+0 yp+72, Font name
    Gui, Add, text, xp+0 yp+25, Font size
    Gui, Add, text, xp+0 yp+25, Text color
    Gui, Add, text, xp+0 yp+25, Background color
    Gui, Add, text, xp+0 yp+25, Display time (in seconds)
    Gui, Add, text, xp+0 yp+25, Width (fixed size / dynamic max,)
    Gui, Add, text, xp+0 yp+25, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (screen DPI: %A_ScreenDPI%)
    Gui, Add, Checkbox, xp+0 yp+25 Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%FavorRightoLeft% vFavorRightoLeft, Favor right alignment
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%NeverRightoLeft% vNeverRightoLeft, Never align to the right
    Gui, Add, text, xp+15 yp+15 w200, Recommended if you want to place the OSD on a secondary screen
    Gui, Add, Checkbox, xp-15 yp+35 w200 Checked%JumpHover% vJumpHover, Toggle OSD positions when mouse runs over it

    Loop, % FontList.MaxIndex() {
      GuiControl, , FontName, % FontList[A_Index]
    }

    Gui, SettingsGUIA: add, Button, xp+0 yp+50 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+62 yp+0 w60 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, OSD appearances: KeyPress OSD

    VerifyOsdOptions()
}

VerifyOsdOptions() {
    GuiControlGet, OSDautosize
    GuiControlGet, NeverRightoLeft
    GuiControlGet, FavorRightoLeft
    GuiControlGet, GUIposition

    if (NeverRightoLeft=1)
    {
        GuiControl, Disable, FavorRightoLeft
    } else
    {
        GuiControl, Enable, FavorRightoLeft
    }

    if (FavorRightoLeft=1)
    {
        GuiControl, Disable, NeverRightoLeft
        GuiControl, , NeverRightoLeft, 0
    } else
    {
        GuiControl, Enable, NeverRightoLeft
    }

    if (GUIposition=0)
    {
        GuiControl, Disable, GuiXa
        GuiControl, Disable, GuiYa
        GuiControl, Enable, GuiXb
        GuiControl, Enable, GuiYb
    } else
    {
        GuiControl, Enable, GuiXa
        GuiControl, Enable, GuiYa
        GuiControl, Disable, GuiXb
        GuiControl, Disable, GuiYb
    }

    if (OSDautosize=0)
    {
        GuiControl, Enable, GuiWidth
        GuiControl, Disable, maxGuiWidth
    } else
    {
        GuiControl, Disable, GuiWidth
        GuiControl, Enable, maxGuiWidth
    }
}

LocatePositionA() {
    GuiControlGet, GUIposition

    if (GUIposition=0)
       Return

    ToolTip, Move mouse to desired location and click
    CoordMode Mouse, Screen
    KeyWait, LButton, D, T10
    MouseGetPos, x, y
    ToolTip
    GuiControl, , GuiXa, %x%
    GuiControl, , GuiYa, %y%
}

LocatePositionB() {
    GuiControlGet, GUIposition

    if (GUIposition=0)
    {
        ToolTip, Move mouse to desired location and click
        CoordMode Mouse, Screen
        KeyWait, LButton, D, T10
        ToolTip
        MouseGetPos, x, y
        GuiControl, , GuiXb, %x%
        GuiControl, , GuiYb, %y%
    } else
    {
        Return
    }
}

EnumFonts() {
    hDC := DllCall("GetDC", "UInt", DllCall("GetDesktopWindow"))
    Callback := RegisterCallback("EnumFontsCallback", "F")
    DllCall("EnumFontFamilies", "UInt", hDC, "UInt", 0, "Ptr", Callback, "UInt", lParam := 0)
    DllCall("ReleaseDC", "UInt", hDC)
}

EnumFontsCallback(lpelf) {
    FontList.Push(StrGet(lpelf + 28, 32))
    Return True
}

ChooseColorBGR() {
    cc := 0
    cc := dlg_color(cc,hwnd)
    OSDbgrColor := hexRGB(cc)
    StringRight, OSDbgrColor, OSDbgrColor, 6
    GuiControl, +c%OSDbgrColor%, OSDbgrColor
}

ChooseColorTEXT() {
    cc := 0
    cc := dlg_color(cc,hwnd)
    OSDtextColor := hexRGB(cc)
    StringRight, OSDtextColor, OSDtextColor, 6
    GuiControl, +c%OSDtextColor%, OSDtextColor
}

ApplySettings() {
    Gui, SettingsGUIA: Submit, NoHide
    CheckSettings()
    Sleep, 10
    ShaveSettings()
    Sleep, 20
    Reload
}

AboutWindow() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    SettingsGUI()

    Gui, SettingsGUIA: add, link, x16 y50, AHK script developed by <a href="http://marius.sucan.ro">Marius Șucan</a>. Send <a href="mailto:marius.sucan@gmail.com">feedback</a>.
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Based on KeypressOSD v2.22 by Tmplinshi.
    Gui, SettingsGUIA: add, text, xp+0 yp+35, Many thanks to the great people from #ahk (irc.freenode.net), 
    Gui, SettingsGUIA: add, text, xp+0 yp+20, ... in particular to Neuromancer, Phaleth, Tidbit, Saiapatsu.
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Special mentions: Drugwash and Neuromancer.
    Gui, SettingsGUIA: add, text, xp+0 yp+35, This contains code also from: Maestrith (color picker),
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Alguimist (font list generator), VxE (GuiGetSize),
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Sean (GetTextExtentPoint) and Lexikos.
    Gui, SettingsGUIA: add, Button, xp+0 yp+35 w75 Default gCloseWindow, &Close
    Gui, SettingsGUIA: add, Button, xp+80 yp+0 w85 gChangeLog, Version &history
    Gui, SettingsGUIA: add, text, xp+90 yp+1, Released: %releaseDate%
    Gui, Font, s20 bold, Arial, -wrap
    Gui, SettingsGUIA: add, text, x15 y15, KeyPress OSD v%version%
    Gui, SettingsGUIA: show, autoSize, About KeyPress OSD v%version%
}

CloseWindow() {
    Gui, SettingsGUIA: Destroy
}

CloseSettings() {
    Reload
}

changelog() {
     Gui, SettingsGUIA: Destroy

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileTmp := "temp-keypress-osd-changelog.txt"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile

     if (!FileExist(historyFile) || (ForceDownloadExternalFiles=1))
     {
         soundbeep
         UrlDownloadToFile, %historyFileURL%, %historyFile%
         Sleep, 4000
     }

     if FileExist(historyFile)
     {
         FileRead, Contents, %historyFile%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                 FileGetTime, fileDate, %historyFile%
                 timeNow := %A_Now%
                 EnvSub, timeNow, %fileDate%, Days

                 if timeNow > 10
                    MsgBox, Version history seems too old. Please use the Update now option from the tray menu. The file will be opened now.

                Run, %historyFile%
             } Else
             {
                MsgBox, 4,, Corrupt file: keypress-osd-changelog.txt. The attempt to download it seems to have failed. To try again file must be deleted. Do you agree?
                IfMsgBox Yes
                {
                   FileDelete, %historyFile%
                }
             }
         }
     } else 
     {
         MsgBox, Missing file: %historyFile%. The attempt to download it seems to have failed.
     }
       
}


updateNow() {
     if (A_IsSuspended!=1)
        Gosub, SuspendScript

     MsgBox, 4, Question, Do you want to abort updating?
     IfMsgBox Yes
     {
       Gosub, SuspendScript
       Return
     }

     Sleep, 150
     prefOpen := 1

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileTmp := "temp-keypress-osd-changelog.txt"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile
     langyFileTmp := "temp-keypress-osd-languages.ini"
     langyFile := "keypress-osd-languages.ini"
     langyFileURL := baseURL langyFile
     mainFileTmp := "temp-keypress-osd.ahk"
     mainFile := "keypress-osd.ahk"
     mainFileURL := baseURL mainFile
     thisFile := A_ScriptName

     ShowHotkey("Updating files: 1 / 3. Please wait...")
     UrlDownloadToFile, %historyFileURL%, %historyFileTmp%
     Sleep, 4000

     if FileExist(historyFileTmp)
     {
         FileRead, Contents, %historyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                ShowHotkey("Updating files: Version history. OK")
                Sleep, 1350
                changelogDownloaded := 1
             } Else
             {
                ShowHotkey("Updating files: Version history: CORRUPT")
                Sleep, 1350
                changelogCorrupted := 1
             }
         }
     } else 
     {
         ShowHotkey("Updating files: Version history: FAIL")
         Sleep, 1350
         changelogDownloaded := 0
     }

     ShowHotkey("Updating files: 2 / 3. Please wait...")
     UrlDownloadToFile, %langyFileURL%, %langyFileTmp%
     Sleep, 4000

     if FileExist(langyFileTmp)
     {
         FileRead, Contents, %langyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "; // KeyPress OSD - language definitions")
             {
                ShowHotkey("Updating files: Language definitions: OK")
                Sleep, 1350
                langsDownloaded := 1
             } Else
             {
                ShowHotkey("Updating files: Language definitions: CORRUPT")
                Sleep, 1350
                langsCorrupted := 1
             }
         }
     } else 
     {
         ShowHotkey("Updating files: Language definitions: FAIL")
         Sleep, 1350
         langsDownloaded := 0
     }

     ShowHotkey("Updating files: 3 / 3. Please wait...")
     UrlDownloadToFile, %mainFileURL%, %mainFileTmp%
     Sleep, 4000

     if FileExist(mainFileTmp)
     {
         FileRead, Contents, %mainFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "; KeypressOSD.ahk - main file")
             {
                ShowHotkey("Updating files: Main code: OK")
                Sleep, 1350
                ahkDownloaded := 1
             } Else
             {
                ShowHotkey("Updating files: Main code: CORRUPT")
                Sleep, 1350
                ahkCorrupted := 1
             }
         }
     } else 
     {
         ShowHotkey("Updating files: Main code: FAIL")
         Sleep, 1350
         ahkDownloaded := 0
     }

     if (changelogCorrupted=1 || changelogDownloaded=0 || langsCorrupted=1 || langsDownloaded=0 || ahkCorrupted=1 || ahkDownloaded=0)
        someErrors := 1

     if (changelogDownloaded=0 && langsDownloaded=0 && ahkDownloaded=0)
        completeFailure := 1

     if (changelogDownloaded=1 && langsDownloaded=1 && ahkDownloaded=1)
        completeSucces := 1

     if (completeFailure=1)
     {
        MsgBox, 4, Error, Unable to download any file. Server is offline or no Internet connection. Do you want to try again?
        IfMsgBox Yes
        {
           updateNow()
        } else
        {
            FileDelete, mainFileTmp
            FileDelete, historyFileTmp
            FileDelete, langyFileTmp
        }
     }

     if (completeSucces=1)
     {
        FileMove, %mainFileTmp%, %thisFile%, 1
        FileMove, %historyFileTmp%, %historyFile%, 1
        FileMove, %langyFileTmp%, %langyFile%, 1
        MsgBox, Update seems to be succesful. No errors detected. The script will now reload.
        Reload
     }

     if (someErrors=1)
     {
        MsgBox, Errors occured during the update. The script will now reload.
        if changelogDownloaded=1
           FileMove, %historyFileTmp%, %historyFile%, 1

        if langsDownloaded=1
           FileMove, %langyFileTmp%, %langyFile%, 1

        if ahkDownloaded=1
           FileMove, %mainFileTmp%, %thisFile%, 1

        if ahkCorrupted=1
           FileDelete, %mainFileTmp%

        if changelogCorrupted=1
           FileDelete, %historyFileTmp%

        if langsCorrupted=1
           FileDelete, %langyFileTmp%

        Reload
     }
}

ShaveSettings() {
  firstRun := 0
  IniWrite, %firstRun%, %inifile%, SavedSettings, firstRun
  IniWrite, %audioAlerts%, %inifile%, SavedSettings, audioAlerts
  IniWrite, %AutoDetectKBD%, %inifile%, SavedSettings, AutoDetectKBD
  IniWrite, %BeepHiddenKeys%, %inifile%, SavedSettings, BeepHiddenKeys
  IniWrite, %CapslockBeeper%, %inifile%, SavedSettings, CapslockBeeper
  IniWrite, %ClickScaleUser%, %inifile%, SavedSettings, ClickScaleUser
  IniWrite, %ClipMonitor%, %inifile%, SavedSettings, ClipMonitor
  IniWrite, %ConstantAutoDetect%, %inifile%, SavedSettings, ConstantAutoDetect
  IniWrite, %CustomRegionalKeys%, %inifile%, SavedSettings, CustomRegionalKeys
  IniWrite, %IgnoreAdditionalKeys%, %inifile%, SavedSettings, IgnoreAdditionalKeys
  IniWrite, %IgnorekeysList%, %inifile%, SavedSettings, IgnorekeysList
  IniWrite, %DifferModifiers%, %inifile%, SavedSettings, DifferModifiers
  IniWrite, %DisableTypingMode%, %inifile%, SavedSettings, DisableTypingMode
  IniWrite, %DisplayTimeUser%, %inifile%, SavedSettings, DisplayTimeUser
  IniWrite, %FavorRightoLeft%, %inifile%, SavedSettings, FavorRightoLeft
  IniWrite, %FlashIdleMouse%, %inifile%, SavedSettings, FlashIdleMouse
  IniWrite, %FontName%, %inifile%, SavedSettings, FontName
  IniWrite, %FontSize%, %inifile%, SavedSettings, FontSize
  IniWrite, %ForcedKBDlayout%, %inifile%, SavedSettings, ForcedKBDlayout
  IniWrite, %ForcedKBDlayout1%, %inifile%, SavedSettings, ForcedKBDlayout1
  IniWrite, %ForcedKBDlayout2%, %inifile%, SavedSettings, ForcedKBDlayout2
  IniWrite, %ForceKBD%, %inifile%, SavedSettings, ForceKBD
  IniWrite, %enableAltGrUser%, %inifile%, SavedSettings, enableAltGrUser
  IniWrite, %GuiWidth%, %inifile%, SavedSettings, GuiWidth
  IniWrite, %maxGuiWidth%, %inifile%, SavedSettings, maxGuiWidth
  IniWrite, %GUIposition%, %inifile%, SavedSettings, GUIposition
  IniWrite, %GuiXa%, %inifile%, SavedSettings, GuiXa
  IniWrite, %GuiXb%, %inifile%, SavedSettings, GuiXb
  IniWrite, %GuiYa%, %inifile%, SavedSettings, GuiYa
  IniWrite, %GuiYb%, %inifile%, SavedSettings, GuiYb
  IniWrite, %HideAnnoyingKeys%, %inifile%, SavedSettings, HideAnnoyingKeys
  IniWrite, %IdleMouseAlpha%, %inifile%, SavedSettings, IdleMouseAlpha
  IniWrite, %JumpHover%, %inifile%, SavedSettings, JumpHover
  IniWrite, %KeyBeeper%, %inifile%, SavedSettings, KeyBeeper
  IniWrite, %KeyboardShortcuts%, %inifile%, SavedSettings, KeyboardShortcuts
  IniWrite, %ModBeeper%, %inifile%, SavedSettings, ModBeeper
  IniWrite, %MouseBeeper%, %inifile%, SavedSettings, MouseBeeper
  IniWrite, %MouseHaloAlpha%, %inifile%, SavedSettings, MouseHaloAlpha
  IniWrite, %MouseHaloColor%, %inifile%, SavedSettings, MouseHaloColor
  IniWrite, %MouseHaloRadius%, %inifile%, SavedSettings, MouseHaloRadius
  IniWrite, %MouseIdleAfter%, %inifile%, SavedSettings, MouseIdleAfter
  IniWrite, %MouseIdleRadius%, %inifile%, SavedSettings, MouseIdleRadius
  IniWrite, %MouseVclickAlpha%, %inifile%, SavedSettings, MouseVclickAlpha
  IniWrite, %NavKeysFriendly%, %inifile%, SavedSettings, NavKeysFriendly
  IniWrite, %NeverRightoLeft%, %inifile%, SavedSettings, NeverRightoLeft
  IniWrite, %OSDborder%, %inifile%, SavedSettings, OSDborder
  IniWrite, %OSDautosize%, %inifile%, SavedSettings, OSDautosize
  IniWrite, %OSDautosizeFactory%, %inifile%, SavedSettings, OSDautosizeFactory
  IniWrite, %OSDbgrColor%, %inifile%, SavedSettings, OSDbgrColor
  IniWrite, %OSDtextColor%, %inifile%, SavedSettings, OSDtextColor
  IniWrite, %RegionalKeysList%, %inifile%, SavedSettings, RegionalKeysList
  IniWrite, %releaseDate%, %inifile%, SavedSettings, releaseDate
  IniWrite, %ShowKeyCount%, %inifile%, SavedSettings, ShowKeyCount
  IniWrite, %ShowKeyCountFired%, %inifile%, SavedSettings, ShowKeyCountFired
  IniWrite, %ShowMouseButton%, %inifile%, SavedSettings, ShowMouseButton
  IniWrite, %ShowMouseHalo%, %inifile%, SavedSettings, ShowMouseHalo
  IniWrite, %ShowPrevKey%, %inifile%, SavedSettings, ShowPrevKey
  IniWrite, %ShowPrevKeyDelay%, %inifile%, SavedSettings, ShowPrevKeyDelay
  IniWrite, %ShowSingleKey%, %inifile%, SavedSettings, ShowSingleKey
  IniWrite, %ShowSingleModifierKey%, %inifile%, SavedSettings, ShowSingleModifierKey
  IniWrite, %ShowDeadKeys%, %inifile%, SavedSettings, ShowDeadKeys
  IniWrite, %ShiftDisableCaps%, %inifile%, SavedSettings, ShiftDisableCaps
  IniWrite, %SilentDetection%, %inifile%, SavedSettings, SilentDetection
  IniWrite, %SpaceReplacer%, %inifile%, SavedSettings, SpaceReplacer
  IniWrite, %StickyKeys%, %inifile%, SavedSettings, StickyKeys
  IniWrite, %version%, %inifile%, SavedSettings, version
  IniWrite, %VisualMouseClicks%, %inifile%, SavedSettings, VisualMouseClicks
}

LoadSettings() {
  firstRun := 0
  defOSDautosizeFactory := round(A_ScreenDPI / 1.18)
  IniRead, audioAlerts, %inifile%, SavedSettings, audioAlerts, %audioAlerts%
  IniRead, AutoDetectKBD, %inifile%, SavedSettings, AutoDetectKBD, %AutoDetectKBD%
  IniRead, BeepHiddenKeys, %inifile%, SavedSettings, BeepHiddenKeys, %BeepHiddenKeys%
  IniRead, CapslockBeeper, %inifile%, SavedSettings, CapslockBeeper, %CapslockBeeper%
  IniRead, ClickScaleUser, %inifile%, SavedSettings, ClickScaleUser, %ClickScaleUser%
  IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
  IniRead, ConstantAutoDetect, %inifile%, SavedSettings, ConstantAutoDetect, %ConstantAutoDetect%
  IniRead, CustomRegionalKeys, %inifile%, SavedSettings, CustomRegionalKeys, %CustomRegionalKeys%
  IniRead, RegionalKeysList, %inifile%, SavedSettings, RegionalKeysList, %RegionalKeysList%
  IniRead, IgnoreAdditionalKeys, %inifile%, SavedSettings, IgnoreAdditionalKeys, %IgnoreAdditionalKeys%
  IniRead, IgnorekeysList, %inifile%, SavedSettings, IgnorekeysList, %IgnorekeysList%
  IniRead, DifferModifiers, %inifile%, SavedSettings, DifferModifiers, %DifferModifiers%
  IniRead, DisableTypingMode, %inifile%, SavedSettings, DisableTypingMode, %DisableTypingMode%
  IniRead, DisplayTimeUser, %inifile%, SavedSettings, DisplayTimeUser, %DisplayTimeUser%
  IniRead, FavorRightoLeft, %inifile%, SavedSettings, FavorRightoLeft, %FavorRightoLeft%
  IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
  IniRead, FontName, %inifile%, SavedSettings, FontName, %FontName%
  IniRead, FontSize, %inifile%, SavedSettings, FontSize, %FontSize%
  IniRead, ForcedKBDlayout, %inifile%, SavedSettings, ForcedKBDlayout, %ForcedKBDlayout%
  IniRead, ForcedKBDlayout1, %inifile%, SavedSettings, ForcedKBDlayout1, %ForcedKBDlayout1%
  IniRead, ForcedKBDlayout2, %inifile%, SavedSettings, ForcedKBDlayout2, %ForcedKBDlayout2%
  IniRead, ForceKBD, %inifile%, SavedSettings, ForceKBD, %ForceKBD%
  IniRead, enableAltGrUser, %inifile%, SavedSettings, enableAltGrUser, %enableAltGrUser%
  IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
  IniRead, GuiWidth, %inifile%, SavedSettings, GuiWidth, %GuiWidth%
  IniRead, maxGuiWidth, %inifile%, SavedSettings, maxGuiWidth, %maxGuiWidth%
  IniRead, GuiXa, %inifile%, SavedSettings, GuiXa, %GuiXa%
  IniRead, GuiXb, %inifile%, SavedSettings, GuiXb, %GuiXb%
  IniRead, GuiYa, %inifile%, SavedSettings, GuiYa, %GuiYa%
  IniRead, GuiYb, %inifile%, SavedSettings, GuiYb, %GuiYb%
  IniRead, HideAnnoyingKeys, %inifile%, SavedSettings, HideAnnoyingKeys, %HideAnnoyingKeys%
  IniRead, IdleMouseAlpha, %inifile%, SavedSettings, IdleMouseAlpha, %IdleMouseAlpha%
  IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, KeyboardShortcuts, %inifile%, SavedSettings, KeyboardShortcuts, %KeyboardShortcuts%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, MouseHaloAlpha, %inifile%, SavedSettings, MouseHaloAlpha, %MouseHaloAlpha%
  IniRead, MouseHaloColor, %inifile%, SavedSettings, MouseHaloColor, %MouseHaloColor%
  IniRead, MouseHaloRadius, %inifile%, SavedSettings, MouseHaloRadius, %MouseHaloRadius%
  IniRead, MouseIdleAfter, %inifile%, SavedSettings, MouseIdleAfter, %MouseIdleAfter%
  IniRead, MouseIdleRadius, %inifile%, SavedSettings, MouseIdleRadius, %MouseIdleRadius%
  IniRead, MouseVclickAlpha, %inifile%, SavedSettings, MouseVclickAlpha, %MouseVclickAlpha%
  IniRead, NavKeysFriendly, %inifile%, SavedSettings, NavKeysFriendly, %NavKeysFriendly%
  IniRead, NeverRightoLeft, %inifile%, SavedSettings, NeverRightoLeft, %NeverRightoLeft%
  IniRead, OSDautosize, %inifile%, SavedSettings, OSDautosize, %OSDautosize%
  IniRead, OSDautosizeFactory, %inifile%, SavedSettings, OSDautosizeFactory, %OSDautosizeFactory%
  IniRead, OSDbgrColor, %inifile%, SavedSettings, OSDbgrColor, %OSDbgrColor%
  IniRead, OSDborder, %inifile%, SavedSettings, OSDborder, %OSDborder%
  IniRead, OSDtextColor, %inifile%, SavedSettings, OSDtextColor, %OSDtextColor%
  IniRead, ShiftDisableCaps, %inifile%, SavedSettings, ShiftDisableCaps, %ShiftDisableCaps%
  IniRead, ShowKeyCount, %inifile%, SavedSettings, ShowKeyCount, %ShowKeyCount%
  IniRead, ShowKeyCountFired, %inifile%, SavedSettings, ShowKeyCountFired, %ShowKeyCountFired%
  IniRead, ShowMouseButton, %inifile%, SavedSettings, ShowMouseButton, %ShowMouseButton%
  IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
  IniRead, ShowPrevKey, %inifile%, SavedSettings, ShowPrevKey, %ShowPrevKey%
  IniRead, ShowPrevKeyDelay, %inifile%, SavedSettings, ShowPrevKeyDelay, %ShowPrevKeyDelay%
  IniRead, ShowSingleKey, %inifile%, SavedSettings, ShowSingleKey, %ShowSingleKey%
  IniRead, ShowDeadKeys, %inifile%, SavedSettings, ShowDeadKeys, %ShowDeadKeys%
  IniRead, ShowSingleModifierKey, %inifile%, SavedSettings, ShowSingleModifierKey, %ShowSingleModifierKey%
  IniRead, SilentDetection, %inifile%, SavedSettings, SilentDetection, %SilentDetection%
  IniRead, SpaceReplacer, %inifile%, SavedSettings, SpaceReplacer, %SpaceReplacer%
  IniRead, StickyKeys, %inifile%, SavedSettings, StickyKeys, %StickyKeys%
  IniRead, VisualMouseClicks, %inifile%, SavedSettings, VisualMouseClicks, %VisualMouseClicks%

  CheckSettings()

  if (GUIposition=1)
  {
     GuiY := GuiYa
     GuiX := GuiXa
  } else
  {
     GuiY := GuiYb
     GuiX := GuiXb
  }
}

CheckSettings() {

; verify check boxes
    audioAlerts := (audioAlerts=0 || audioAlerts=1) ? audioAlerts : 0
    AutoDetectKBD := (AutoDetectKBD=0 || AutoDetectKBD=1) ? AutoDetectKBD : 1
    BeepHiddenKeys := (BeepHiddenKeys=0 || BeepHiddenKeys=1) ? BeepHiddenKeys : 0
    CapslockBeeper := (CapslockBeeper=0 || CapslockBeeper=1) ? CapslockBeeper : 1
    ClipMonitor := (ClipMonitor=0 || ClipMonitor=1) ? ClipMonitor : 1
    ConstantAutoDetect := (ConstantAutoDetect=0 || ConstantAutoDetect=1) ? ConstantAutoDetect : 1
    CustomRegionalKeys := (CustomRegionalKeys=0 || CustomRegionalKeys=1) ? CustomRegionalKeys : 0
    IgnoreAdditionalKeys := (IgnoreAdditionalKeys=0 || IgnoreAdditionalKeys=1) ? IgnoreAdditionalKeys : 0
    DifferModifiers := (DifferModifiers=0 || DifferModifiers=1) ? DifferModifiers : 0
    DisableTypingMode := (DisableTypingMode=0 || DisableTypingMode=1) ? DisableTypingMode : 1
    FavorRightoLeft := (FavorRightoLeft=0 || FavorRightoLeft=1) ? FavorRightoLeft : 0
    FlashIdleMouse := (FlashIdleMouse=0 || FlashIdleMouse=1) ? FlashIdleMouse : 0
    ForceKBD := (ForceKBD=0 || ForceKBD=1) ? ForceKBD : 0
    ForcedKBDlayout := (ForcedKBDlayout=0 || ForcedKBDlayout=1) ? ForcedKBDlayout : 0
    enableAltGrUser := (enableAltGrUser=0 || enableAltGrUser=1) ? enableAltGrUser : 1
    GUIposition := (GUIposition=0 || GUIposition=1) ? GUIposition : 1
    HideAnnoyingKeys := (HideAnnoyingKeys=0 || HideAnnoyingKeys=1) ? HideAnnoyingKeys : 0
    JumpHover := (JumpHover=0 || JumpHover=1) ? JumpHover : 0
    KeyBeeper := (KeyBeeper=0 || KeyBeeper=1) ? KeyBeeper : 0
    KeyboardShortcuts := (KeyboardShortcuts=0 || KeyboardShortcuts=1) ? KeyboardShortcuts : 1
    ModBeeper := (ModBeeper=0 || ModBeeper=1) ? ModBeeper : 0
    MouseBeeper := (MouseBeeper=0 || MouseBeeper=1) ? MouseBeeper : 0
    NavKeysFriendly := (NavKeysFriendly=0 || NavKeysFriendly=1) ? NavKeysFriendly : 0
    NeverRightoLeft := (NeverRightoLeft=0 || NeverRightoLeft=1) ? NeverRightoLeft : 0
    OSDautosize := (OSDautosize=0 || OSDautosize=1) ? OSDautosize : 1
    OSDborder := (OSDborder=0 || OSDborder=1) ? OSDborder : 0
    ShowKeyCount := (ShowKeyCount=0 || ShowKeyCount=1) ? ShowKeyCount : 1
    ShowKeyCountFired := (ShowKeyCountFired=0 || ShowKeyCountFired=1) ? ShowKeyCountFired : 1
    ShowMouseButton := (ShowMouseButton=0 || ShowMouseButton=1) ? ShowMouseButton : 1
    ShowMouseHalo := (ShowMouseHalo=0 || ShowMouseHalo=1) ? ShowMouseHalo : 0
    ShowPrevKey := (ShowPrevKey=0 || ShowPrevKey=1) ? ShowPrevKey : 1
    ShowSingleKey := (ShowSingleKey=0 || ShowSingleKey=1) ? ShowSingleKey : 1
    ShowSingleModifierKey := (ShowSingleModifierKey=0 || ShowSingleModifierKey=1) ? ShowSingleModifierKey : 1
    ShowDeadKeys := (ShowDeadKeys=0 || ShowDeadKeys=1) ? ShowDeadKeys : 1
    ShiftDisableCaps := (ShiftDisableCaps=0 || ShiftDisableCaps=1) ? ShiftDisableCaps : 1
    SilentDetection := (SilentDetection=0 || SilentDetection=1) ? SilentDetection : 1
    StickyKeys := (StickyKeys=0 || StickyKeys=1) ? StickyKeys : 0
    VisualMouseClicks := (VisualMouseClicks=0 || VisualMouseClicks=1) ? VisualMouseClicks : 0

    if (ForceKBD=1)
       AutoDetectKBD := 1

; verify if numeric values, otherwise, defaults
  if ClickScaleUser is not digit
     ClickScaleUser := 10

  if DisplayTimeUser is not digit
     DisplayTimeUser := 3

  if FontSize is not digit
     FontSize := 20

  if GuiWidth is not digit
     GuiWidth := 350

  if maxGuiWidth is not digit
     maxGuiWidth := 500

  if GuiXa is not digit
     GuiXa := 40

  if GuiXb is not digit
     GuiXb := 60

  if GuiYa is not digit
     GuiYa := 250

  if GuiYb is not digit
     GuiYb := 800

  if IdleMouseAlpha is not digit
     IdleMouseAlpha := 130

  if MouseHaloAlpha is not digit
     MouseHaloAlpha := 150

  if MouseHaloRadius is not digit
     MouseHaloRadius := 35

  if MouseIdleAfter is not digit
     MouseIdleAfter := 10

  if MouseIdleRadius is not digit
     MouseIdleRadius := 40

  if MouseVclickAlpha is not digit
     MouseVclickAlpha := 150

     defOSDautosizeFactory := round(A_ScreenDPI / 1.18)
  if OSDautosizeFactory is not digit
     OSDautosizeFactory := defOSDautosizeFactory

  if ShowPrevKeyDelay is not digit
     ShowPrevKeyDelay := 300

; verify minimum numeric values
    ClickScaleUser := (ClickScaleUser < 3) ? 3 : round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser < 2) ? 2 : round(DisplayTimeUser)
    FontSize := (FontSize < 7) ? 8 : round(FontSize)
    GuiWidth := (GuiWidth < 20) ? 21 : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth < 20) ? 21 : round(maxGuiWidth)
    GuiXa := (GuiXa < 5) ? 6 : round(GuiXa)
    GuiXb := (GuiXb < 5) ? 6 : round(GuiXb)
    GuiYa := (GuiYa < 5) ? 6 : round(GuiYa)
    GuiYb := (GuiYb < 5) ? 6 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha < 5) ? 6 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha < 5) ? 6 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius < 5) ? 6 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter < 3) ? 3 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius < 5) ? 6 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha < 5) ? 6 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory < 10) ? 11 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay < 100) ? 101 : round(ShowPrevKeyDelay)

; verify maximum numeric values
    ClickScaleUser := (ClickScaleUser > 99) ? 98 : round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser > 99) ? 98 : round(DisplayTimeUser)
    FontSize := (FontSize > 300) ? 290 : round(FontSize)
    GuiWidth := (GuiWidth > 999) ? 999 : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth > 999) ? 999 : round(maxGuiWidth)
    GuiXa := (GuiXa > 9999) ? 9998 : round(GuiXa)
    GuiXb := (GuiXb > 9999) ? 9998 : round(GuiXb)
    GuiYa := (GuiYa > 9999) ? 9998 : round(GuiYa)
    GuiYb := (GuiYb > 9999) ? 9998 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha > 253) ? 252 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha > 253) ? 252 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius > 999) ? 900 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter > 999) ? 900 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius > 999) ? 900 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha > 253) ? 252 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory > 402) ? 401 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay > 999) ? 900 : round(ShowPrevKeyDelay)

; verify HEX values

   if (!(forcedKBDlayout1 ~= "^[0-9a-f]+$") || (strLen(forcedKBDlayout1) < 8) || (strLen(forcedKBDlayout1) > 8))
      ForcedKBDlayout1 := "00010418"

   if (!(forcedKBDlayout2 ~= "^[0-9a-f]+$") || (strLen(forcedKBDlayout2) < 8) || (strLen(forcedKBDlayout12) > 8))
      ForcedKBDlayout2 := "0000040c"

   if (!(OSDbgrColor ~= "^[0-9a-f]+$") || (strLen(OSDbgrColor) < 6) || (strLen(OSDbgrColor) > 6))
      OSDbgrColor := "111111"

   if (!(MouseHaloColor ~= "^[0-9a-f]+$") || (strLen(MouseHaloColor) < 6) || (strLen(MouseHaloColor) > 6))
      MouseHaloColor := "eedd00"
;
   if (!(OSDtextColor ~= "^[0-9a-f]+$") || (strLen(OSDtextColor) < 6) || (strLen(OSDtextColor) > 6))
      OSDtextColor := "ffffff"

   if (SpaceReplacer="")
      SpaceReplacer :=" "
   SpaceReplacer := StrLen(SpaceReplacer)<2 ? SpaceReplacer : " "
   FontName := StrLen(FontName)>2 ? FontName : "Arial"

}

dummy() {
    MsgBox, This feature is not yet available. It might be implemented soon. Thank you.
}

; !+SPACE::  Winset, Alwaysontop, , A

