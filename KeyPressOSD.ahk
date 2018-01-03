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
 ; Therefore, it has no support for Chinese, Japanese or Cyrillic scripts.
 ; It is too complex for me to implement support for other alphabets or writing systems.
 ;
 ; If other programmers are willing to invest time in this script and to extend it,
 ; are welcomed to do so. Anyone is free to transform it into anything they wish. 
 ;
 ; I offer numerous options/settings in the preferences window such that
 ; everyone can find a way to adapt it to personal needs.
 ;
 ; You can modify/add/remove in the language definitions file
 ; any language you want, to suit your needs, if your layout is not supported.
 ;   - you can define Shift symbols, AltGr and dead keys for any layout
 ;   - to do this and LangRaw_[code] and LangName_[code].
 ;   - at keyboard preferences you can see the code of your layout.
 ; 
 ; Read the messages you get:
 ; - it indicates when your keyboard layout is unsupported or Unrecognized
 ; - it also indicates if it made a partial match;
 ;   - in such cases, KeyPress will not be able to bind all keys
 ;     or it may not have AltGr/Shift support.
 ; 
 ; If the external language definitions file is missing,
 ; the only keyboard layout it works with is English US.
 ;
 ; I am no programmer and the script is still quite quirky, but I am trying to
 ; make it better and better with each version.
 ;
 ; My progresses with the script are possible only thanks to the great help from the people on #ahk (irc.freenode.net).
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
 ;   - [NEW] virtual caret navigation: you can navigate through typed text in the OSD as in any text field
 ; - Dead keys support, with option to turn off displaying such keys
 ; - Support for many non-English keyboards. 30 keyboard layouts. Shift, AltGr and dead keys defined for each.
 ;   - experimental automatic detection of keyboard layouts.
 ;   - option to force of keyboard layouts; with keyboard shortcut to toggle between two layouts 
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
 ; - Option to update to the latest version
 ; 
;----------------------------------------------------------------------------

; Initialization

 #SingleInstance force
 #NoEnv
; #Warn, , OutputDebug
 #MaxHotkeysPerInterval 500
 #MaxThreads 250
 #MaxThreadsPerHotkey 250
 #MaxThreadsBuffer On
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
 , OnlyTypingMode        := 0
 , enableTypingHistory   := 0
 , enterErasesLine       := 1
 , ShowDeadKeys          := 1
 , autoRemDeadKey        := 0
 , SpaceReplacer         := " "   ; how to display space bar in typing mode
 , ShowSingleKey         := 1     ; show only key combinations ; it disables typing mode
 , HideAnnoyingKeys      := 1     ; Left click and PrintScreen can easily get in the way.
 , ShowMouseButton       := 1     ; in the OSD
 , StickyKeys            := 0     ; how modifiers behave; set it to 1 if you use StickyKeys in Windows
 , ShowSingleModifierKey := 1     ; make it display Ctrl, Alt, Shift when pressed alone
 , DifferModifiers       := 0     ; differentiate between left and right modifiers
 , ShowPrevKey           := 1     ; show previously pressed key, if pressed quickly in succession
 , ShowPrevKeyDelay      := 300
 , ShowKeyCount          := 1     ; count how many times a key is pressed
 , ShowKeyCountFired     := 0     ; show only key presses (0) or catch key fires as well (1)
 , NeverDisplayOSD       := 0
 , ReturnToTypingUser    := 15    ; in seconds
 , DisplayTimeTypingUser := 10    ; in seconds
 
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
 , CapsColorHighlight    := "9999ff"
 , OSDautosize           := 1     ; make adjustments to the growth factors to match your font size
 , OSDautosizeFactory    := round(A_ScreenDPI / 1.18)
 
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , deadKeyBeeper         := 1
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , BeepHiddenKeys        := 0     ; [when any beeper enabled] to beep or not when keys are not displayed by OSD/HUD
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall
 , LowVolBeeps           := 1
 , beepFiringKeys        := 0

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
 , version               := "3.58.1"
 , releaseDate := "2017 / 11 / 27"
 
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
 , DisplayTimeTyping := DisplayTimeTypingUser*1000
 , ReturnToTypingDelay := ReturnToTypingUser*1000
 , prefixed := 0 ; hack used to determine if last keypress had a modifier
 , Capture2Text := 0
 , zcSCROL := "SCROLL LOCK"
 , tickcount_start2 := A_TickCount
 , tickcount_start := 0 ; timer to count repeated key presses
 , keyCount := 0
 , modifiers_temp := 0
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , GuiHeight := 50
 , maxAllowedGuiWidth := A_ScreenWidth
 , rightoleft := 0
 , prefOpen := 0
 , MouseClickCounter := 0
 , NumLockForced := 0
 , shiftPressed := 0
 , AltGrPressed := 0
 , enableAltGr := enableAltGrUser
 , backTyped := ""
 , visibleTextField := ""
 , text_width := 60
 , CaretPos := "1"
 , maxTextChars := ""
 , lastTypedSince := 0
 , editingField := "3"
 , editField1 := " "
 , editField2 := " "
 , editField3 := " "
 , CurrentKBD := "Default: English US"
 , loadedLangz := 0
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
 , missingAudios := 1

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
verifyNonCrucialFiles()
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
   Thread, priority, 40
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
      Critical, on

   if (ShowSingleKey=0 || DisableTypingMode=1)
   {
      typed := ""
      Return
   }

   global lastTypedSince := A_TickCount
   AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr \(spe)"
   if ((key ~= AltGrMatcher) && (enableAltGr=1) || (AltGrPressed=1) && (enableAltGr=1) && (StickyKeys=1))
   {
      if (StrLen(key)>2)
      {
         keye := SubStr(key, InStr(key, "+", 0, 0)+2)
         if InStr(key, "{")
            keye := SubStr(key, InStr(key, "{", 0, 0)-2)

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
         SetTimer, returnToTyped, 300
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
   typed := InsertChar2caret(key)

   return typed
}

InsertChar2caret(char) {
  Thread, priority, 40
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  lola := "│"

  if (CaretPos = 2000)
     CaretPos := 1

  if (CaretPos = 3000)
     CaretPos := StrLen(typed)+1

  section := RTrim(typed, lola)
  CaretPos := CaretPos < (StrLen(section)+1) ? CaretPos : StrLen(section)+1
  StringReplace, typed, typed, % lola
  typed := ST_Insert(char lola, typed, CaretPos)
  CaretPos := (char || char=0) ? CaretPos+1 : CaretPos

  CalcVisibleText()

  Return typed, visibleTextField
}

CalcVisibleText() {
   Thread, priority, 10
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
      Critical, on

   visibleTextField := typed

   maxTextLimit := 0
   text_width0 := GetTextExtentPoint(typed, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
   if (text_width0 > maxAllowedGuiWidth) && typed
      maxTextLimit := 1

   if (maxTextLimit>0)
   {
      lola := "│"
      Loop
      {
        StringGetPos, vCaretPos, typed, % lola
        visibleTextFieldLength := A_Index
        Stringmid, NEWvisibleTextField, typed, vCaretPos+4, visibleTextFieldLength, L
        text_width2 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
        if (text_width2 > maxAllowedGuiWidth-30)
           allGood := 1
      }
      Until (allGood=1) || (A_Index=990)
      
      if (allGood!=1)
      {
          Loop
          {
            Stringmid, NEWvisibleTextField, typed, vCaretPos+A_Index, visibleTextFieldLength, L
            text_width3 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
            if (text_width3 > maxAllowedGuiWidth-30)
               stopLoop2 := 1
          }
          Until (stopLoop2 = 1) || (A_Index=990)
      }

      visibleTextField := NEWvisibleTextField
   }
}

ST_Insert(insert,input,pos=1) {
  Thread, priority, 15
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

  Length := StrLen(input)
  ((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
  output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
  If (StrLen(output) > StrLen(input) + StrLen(insert))
    ((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
  return, output
}

caretMover(direction) {
  Thread, priority, 40
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  lola := "│"
  StringGetPos, CaretPos, typed, % lola
  StringReplace, typed, typed, % lola
  CaretPos := CaretPos + direction
  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)

  if (InStr(typed, "⬩" lola))
  {
     StringGetPos, CaretPos, typed, % lola
     StringReplace, typed, typed, % lola
     CaretPos := CaretPos + direction
     typed := ST_Insert(lola, typed, CaretPos)
  }

  CalcVisibleText()
}

caretJumper(direction) {
  lola := "│"
  StringGetPos, CaretPos, typed, % lola
  StringReplace, typed, typed, % lola

  CaretPos := CaretPos+1 ; *direction
  CaretPos := RegExMatch(typed, "i) \b", , CaretPos+1)
  CaretPos := CaretPos ; *direction
  ; CaretPos := RegExMatch(typed, "[A-Z0-9]", , CaretPos+1)

  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)

  CalcVisibleText()
}

st_delete(string, start=1, length=1) {
  Thread, priority, 20
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

   if (abs(start+length) > StrLen(string))
      return string
   if (start>0)
      return substr(string, 1, start-1) . substr(string, start + length)
   else if (start<=0)
      return substr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}

OnMousePressed() {
    if (Visible=1)
       tickcount_start := A_TickCount-500

    shiftPressed := 0
    AltGrPressed := 0

    try {
        key := GetKeyStr()
        if (ShowMouseButton=1)
        {
            typed := (OnlyTypingMode=1) ? typed : "" ; concerning TypedLetter(" ") - it resets the content of the OSD
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        }
    }

    if ((MouseBeeper = 1) && (ShowMouseButton = 1) && (ShowSingleKey = 1) || (MouseBeeper = 1) && (ShowSingleKey = 0) && (BeepHiddenKeys = 1) || (visualMouseClicks=1) && (MouseBeeper = 1) )
       clickyBeeper()

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       ShowMouseClick(mkey)
    }
}

OnRLeftPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && !prefixed && (ShowSingleKey=1)
        {
            deadKeyProcessing()

            if (key ~= "i)^(Left)")
            ;   caretJumper(-1)
               caretMover(0)

            if (key ~= "i)^(Right)")
            ;   caretJumper(-1)
               caretMover(2)

            if !(CaretPos=StrLen(typed)) && (CaretPos!=1)
               global lastTypedSince := A_TickCount

            dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (keyCount>10) ? 1 : 0
            if (CaretPos=StrLen(typed) && (dropOut=1)) || ((CaretPos=1) && (dropOut=1))
               global lastTypedSince := A_TickCount - ReturnToTypingDelay

            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltgrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnHomeEndPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && !prefixed && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            lola := "│"

            StringReplace, typed, typed, % lola
            if (key ~= "i)^(Home)")
               CaretPos := 1

            if (key ~= "i)^(End)")
               CaretPos := StrLen(typed)+1

            typed := ST_Insert(lola, typed, CaretPos)
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) )
        {
           if (keyCount>10)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltgrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnPGupDnPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && !prefixed && (enableTypingHistory=1) && (ShowSingleKey=1) && (keyCount<10)
        {
            if (key ~= "i)^(Page Down)") && !visible && StrLen(typed)<3
            {
               global lastTypedSince := A_TickCount - ReturnToTypingDelay
               if (StrLen(typed)<2)
                  typed := (OnlyTypingMode=1) ? typed : ""
               ShowHotkey(key)
               SetTimer, HideGUI, % -DisplayTime
               Return
            }

            deadKeyProcessing()
            lola := "│"
            StringReplace, typed, typed, % lola
            StringReplace, editField1, editField1, % lola
            StringReplace, editField2, editField2, % lola
            StringReplace, editField3, editField3, % lola

            if (key ~= "i)^(Page Up)")
            {
               if (editingField=3)
                  backTyped := typed
               editingField := (editingField<=1) ? 1 : editingField-1
               typed := editField%editingField%
            }

            if (key ~= "i)^(Page Down)")
            {
               if (editingField=3)
                  backTyped := typed
               editingField := (editingField>=3) ? 3 : editingField+1
               typed := (editingField=3) ? backTyped : editField%editingField%
            }

            CaretPos := (typed=" ") ? StrLen(typed) : StrLen(typed)+1
            typed := ST_Insert(lola, typed, 0)

            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || !typed || (enableTypingHistory=0) || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10)
        {
           if (keyCount>10)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed
           typed := (OnlyTypingMode=1) ? typed : ""

        if (StrLen(typed)>1) && (DisableTypingMode=0) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (keyCount<10)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }
    shiftPressed := 0
    AltgrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnKeyPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try {
        key := GetKeyStr()
        AltGrPressed := 0
        TypingFriendlyKeys := "i)^(Num lo|Scroll lo|Insert|Tab|Up|Down|AppsKey|Volume |Media_|Wheel |◐|unknown)"

        if (key ~= "i)^(.?ctrl \+ )") && (DisableTypingMode=0) && (ShowSingleKey=1)
           backTyped := typed

        if ((key ~= "i)(enter|esc)") && (DisableTypingMode=0) && (ShowSingleKey=1))
        {
            if (enterErasesLine=0) && (OnlyTypingMode=1)
               TypedLetter(" ")

            if (enterErasesLine=0) && (OnlyTypingMode=1) && (key ~= "i)(esc)")
               dontReturn := 1

            if (strlen(typed)>4) && (enableTypingHistory=1)
            {
               lola := "│"
               StringReplace, typed, typed, % lola
               editField1 := editField2
               editField2 := typed
               editingField := 3
            }
            if (enterErasesLine=1)
               typed := ""
        }

        AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr .?|.?ctrl \+ (alt|altgr) \+ )|^(altgr \(spe)"
        if (!(key ~= TypingFriendlyKeys)) && (DisableTypingMode=0)
        {
           if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1)
           {
             test := SubStr(key, InStr(key, "+", 0, 0)+2)
             if (!test) || InStr(key, "special key")
                AltGrPressed := 1
           }
           backTyped := !typed && (AltGrPressed=1) && (enableAltGr=1) ? backTyped : typed
           typed := (OnlyTypingMode=1) ? typed : ""
        } else if ((key ~= "i)^(Tab)") && typed && (DisableTypingMode=0))
        {
            TypedLetter(" ")
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        if (StrLen(typed)>1) && (dontReturn!=1)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       if InStr(mkey, "wheel")
          SetTimer, visualMouseClicksDummy, 10, -10
    }

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20

}

visualMouseClicksDummy() {
    Thread, priority, -10
    mkey := SubStr(A_ThisHotkey, 3)
    ShowMouseClick(mkey)
    SetTimer, , off
}

OnLetterPressed() {
    Thread, priority, 40
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.25) && strlen(typed)<3 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && strlen(typed)>4
       InsertChar2caret(" ")

    try {
        if (typed && DeadKeys=1)
            sleep, 50    ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these

        AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr \(spe)"
        key := GetKeyStr(1)     ; consider it a letter

        if (prefixed || DisableTypingMode=1)
        {
            if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) || ((AltGrPressed=1) && (DisableTypingMode=0) && (StrLen(key)<2) && (ShowSingleKey=1) && (StickyKeys=1)) && (enableAltGr=1)
            {
               typed := (enableAltGr=1) ? TypedLetter(key) : ""
               if ((StrLen(typed)>2) && (OnlyTypingMode=0)) || ((StrLen(typed)>1) && (OnlyTypingMode=1))
               {
                  ShowHotkey(visibleTextField)
                  SetTimer, HideGUI, % -DisplayTimeTyping
               } else
               {
                  typed := (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) ? typed : ""
                  ShowHotkey(key)
               }
            } else
            {
               typed := (OnlyTypingMode=1) ? typed : ""
               ShowHotkey(key)
            }

            if (ShowSingleKey=1) && (DisableTypingMode=0)
            {
                if (key ~= "i)^(.?Shift \+ ((.)$|(.)[\r\n \,]))")
                {
                   keyPosition := RegExMatch(key, "\+ ")
                   lettera := SubStr(key, keyPosition+2, 1)
                   TypedLetter(lettera)
                   if (OnlyTypingMode=1)
                      ShowHotkey(visibleTextField)
                }
            }
            SetTimer, HideGUI, % -DisplayTime

        } else
        {
            TypedLetter(key)
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
            shiftPressed := 0
            AltGrPressed := 0
        }
    }
    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnCtrlV() {
  key := GetKeyStr()
  typed := backTyped
  toPaste := Clipboard
  Stringleft, toPaste, toPaste, 800
  StringReplace, toPaste, toPaste, `r`n, %A_SPACE%, All
  InsertChar2caret(toPaste)
  CaretPos := CaretPos + StrLen(toPaste)
  if (StrLen(typed)>4)
  {
     global lastTypedSince := A_TickCount
     SetTimer, returnToTyped, 2
  } else
  {
    ShowHotkey(key)
    SetTimer, HideGUI, % -DisplayTime
  }
}

OnNumSymbolsPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.25) && strlen(typed)<3 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && strlen(typed)>4
       InsertChar2caret(" ")


    try {
        key := GetKeyStr(1)     ; consider it a letter
        if (prefixed || DisableTypingMode=1)
        {
            typed := (OnlyTypingMode=1) ? typed : ""
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        } else if (ShowSingleKey=1)
        {
            InsertChar2caret(key)
            global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }
    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}


OnSpacePressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try {
          if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1)
          {
             if (typed ~= "i)(⬩│)$")
             {
                typed := SubStr(typed, 1, StrLen(typed) - 2)
                TypedLetter("▪")
             } else
             {
                TypedLetter(SpaceReplacer)
             }
             deadKeyProcessing()
             ShowHotkey(visibleTextField)
             SetTimer, HideGUI, % -DisplayTimeTyping
          }
          key := GetKeyStr()

          if (prefixed || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
          {
             if (StrLen(typed)<2)
                typed := (OnlyTypingMode=1) ? typed : ""
             ShowHotkey(key)
             SetTimer, HideGUI, % -DisplayTime
          }

          if (DisableTypingMode=1) || prefixed
             typed := (OnlyTypingMode=1) ? typed : ""
    }

    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnBspPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (CaretPos = 2000) && (keyCount>10) ? 1 : 0
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (dropOut=0)
        {
            lola := "│"
            deadKeyProcessing()
            StringGetPos, CaretPos, typed, % lola
            CaretPos := (CaretPos < 1) ? 2000 : CaretPos
            if (CaretPos = 2000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }

            global lastTypedSince := A_TickCount
            typedLength := StrLen(typed)
            CaretPosy := (CaretPos = typedLength) ? 0 : CaretPos
            typed := (caretpos<1) ? typed : st_delete(typed, CaretPosy, 1)
            if InStr(typed, "⬩" lola)
            {
               StringGetPos, CaretPos, typed, % lola
               CaretPos := (CaretPos < 1) ? 2000 : CaretPos
               CaretPosy := (CaretPos = typedLength) ? CaretPos-1 : CaretPos
               typed := st_delete(typed, CaretPosy, 1) = typed ? SubStr(typed, 1, StrLen(typed) - 1) : st_delete(typed, CaretPosy, 1)
            }
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }

        if (prefixed || (dropOut=1) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0
    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnDelPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (CaretPos = 3000) && (keyCount>10) ? 1 : 0

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (dropOut=0)
        {
            lola := "│"
            deadKeyProcessing()
            if (CaretPos = 3000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }

            StringGetPos, CaretPos, typed, % lola

            if (CaretPos >= StrLen(typed)-2 )
               endReached := 1

            if InStr(typed, lola "⬩")
               deleteNext := 1

            if (endReached!=1) && InStr(typed, lola)
            {
               global lastTypedSince := A_TickCount
               typed := st_delete(typed, CaretPos+2, 1)
               StringGetPos, CaretPos, typed, % lola
               CaretPos := CaretPos+1
            } else if (CaretPos!=3000)
            {
               StringGetPos, CaretPos, typed, % lola
               if (CaretPos > StrLen(typed)-2 ) 
                  endNow := 1

               CaretPos := 3000
               
               if (endNow!=1)
                   typed := st_delete(typed, CaretPos+1, 1) = typed ? st_delete(typed, 0, 1) : st_delete(typed, CaretPos+1, 1)
            }

            if (deleteNext=1)
            {
               StringGetPos, CaretPos, typed, % lola
               l2 := StrLen(typed)
               typed := st_delete(typed, CaretPos+2, 1)
               l2b := StrLen(typed)
               if (l2b = l2)
                  typed := st_delete(typed, 0, 1)

               CaretPos := CaretPos+1
            }

            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || (dropOut=1) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnCapsPressed() {
    Thread, priority, 20
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        GetKeyState, CapsState, CapsLock, T
        if CapsState = D
        {
            key := prefixed ? key : "CAPS LOCK ON"
            GuiControl, OSD:, CapsDummy, 100  
        } else
        {
            key := prefixed ? key : "Caps Lock off"
            GuiControl, OSD:, CapsDummy, 0  
        }
        
        ShowHotkey(key)

        if (DisableTypingMode=0)
           SetTimer, returnToTyped, % -DisplayTime/4.5

        if (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
        
        SetTimer, HideGUI, % -DisplayTime
    }

    If (CapslockBeeper = 1) && (ShowSingleKey = 1) || (CapslockBeeper = 1) && (BeepHiddenKeys = 1)
       capsBeeper()

    shiftPressed := 0
    AltGrPressed := 0
}

OnNumpadPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.25) && strlen(typed)<3 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && strlen(typed)>4
       InsertChar2caret(" ")

    GetKeyState, NumState, NumLock, T

    if (shiftPressed=1 && NumState="D")
       NumLockForced := 1

    try {
        key := GetKeyStr()
        if NumState != D
        {
            typed := (OnlyTypingMode=1) ? typed : "" ; reset typed content
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
            typed := (OnlyTypingMode=1) ? typed : ""
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
            if (StrLen(key2)=3)
               key2 := SubStr(key2, 2, 1)
            TypedLetter(key2)
            ShowHotkey(visibleTextField)
            wasTyped := 1
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (wasTyped!=1)
           SetTimer, HideGUI, % -DisplayTime
    }

    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnKeyUp() {
    Thread, priority, 10
    if (prioritizeBeepers=1)
    {
       Thread, priority, 100
       Critical, on
    }

    global tickcount_start := A_TickCount

    shiftPressed := 0
    AltGrPressed := 0

    GetKeyState, CapsState, CapsLock, T
    If CapsState = D
       GuiControl, OSD:, CapsDummy, 100

    If CapsState != D
       GuiControl, OSD:, CapsDummy, 0

    if typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
    {
        If CapsState = D
           {
               capsBeeper()
           }
           else if (KeyBeeper = 1) && (ShowSingleKey = 1)
           {
               keysBeeper()
           }
    }

    If (CapslockBeeper = 0) && (KeyBeeper = 1) && (ShowSingleKey = 1)
       {
           keysBeeper()
       }
       else if (CapslockBeeper = 1) && (KeyBeeper = 0)
       {
           Return
       }
       else if !typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
       {
           keysBeeper()
       }

    if (BeepHiddenKeys = 1) && (KeyBeeper = 1) && (ShowSingleKey = 0)
       keysBeeper()
}

capsBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-caps%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, capsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 450, 120
}

capsBeeperTimer() {
   soundbeep, 450, 120
   SetTimer, , off
}

keysBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-keys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, keysBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1900, 45
}

keysBeeperTimer() {
   soundbeep, 1900, 45
   SetTimer, , off
}

volBeeperTimer() {
   Thread, priority, -10
   soundbeep, 150, 40
   SetTimer, , off
}

deadKeysBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-deadkeys%LowVolBeeps%.wav, %prioritizeBeepers%
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
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-mods%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, modsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1000, 65
}

modsBeeperTimer() {
   soundbeep, 1000, 65
   SetTimer, , off
}

shiftBeeperTimer() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-mods%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, modsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1000, 65

   SetTimer, , off
}

clickyBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-clicks%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, clickyBeeperTimer, 15, -20

    if (ErrorLevel=1) && (prioritizeBeepers=1)
       soundbeep, 2500, 70
}

clickyBeeperTimer() {
   soundbeep, 2500, 70
   SetTimer, , off
}

firedBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   SoundPlay, sound-firedkey%LowVolBeeps%.wav
   if (ErrorLevel=1)
      soundbeep, 500, 25

   SetTimer, , off
}

OnModPressed() {
    Thread, priority, 10
    Critical, on

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

       if (ShowKeyCountFired=0) && (ShowKeyCount=1) && (A_TickCount-tickcount_start2 > 150)
          repeatCount := (A_TickCount-tickcount_start2 > 5) ? repeatCount+1 : repeatCount

       if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) && (A_TickCount-tickcount_start2 > 150) || (ModBeeper = 1) && (BeepHiddenKeys = 1) && (A_TickCount-tickcount_start2 > 150)
          SetTimer, shiftBeeperTimer, 15, -10

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }

    if (StickyKeys=0)
       fl_prefix := RTrim(fl_prefix, "+ ")

    fl_prefix := CompactModifiers(fl_prefix)
    
    keya := A_ThisHotkey

    if !fl_prefix
    {
       fl_prefix := instr(keya, "RCtrl") ? "AltGr (special key)" : "Unknown key: " keya
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

    if (ShowKeyCountValid=1) && (StickyKeys=0)
    {
        if !InStr(fl_prefix, "+") {
            modifiers_temp := fl_prefix
            fl_prefix .= " (" round(repeatCount) ")"
        } else
        {
            repeatCount := 1
        }
   }

   if ((strLen(typed)>3) && (fl_prefix ~= "i)^(.?Shift \+)") && (visible=1) && (A_TickCount-lastTypedSince < DisplayTimeTyping)) || (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && visible && !typed && keycount>5 && StickyKeys=1) || (OnlyTypingMode=1)
   {
      sleep, 0
   } else
   {
      ShowHotkey(fl_prefix)
      SetTimer, HideGUI, % -DisplayTime/2
      if !InStr(fl_prefix, " + ")
         SetTimer, returnToTyped, % -DisplayTime/4.5
   }

   if (beepFiringKeys=1) && (StickyKeys=0)
      SetTimer, firedBeeperTimer, 2, -20

}

OnModUp() {
    Thread, priority, 10
    if (prioritizeBeepers=1)
    {
       Thread, priority, 100
       Critical, on
    }

    global tickcount_start := A_TickCount

    if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
       modsBeeper()

    if (StickyKeys=0) && StrLen(typed)>1
       SetTimer, returnToTyped, % -DisplayTime/4.5
}

OnDeadKeyPressed() {
  Thread, priority, 10
  Critical, on

  RmDkSymbol := "▪"
  StringRight, TrueRmDkSymbol, A_ThisHotkey, 1
  RmDkSymbol := TrueRmDkSymbol

  if (autoRemDeadKey=1)
     RmDkSymbol := "⬩"

  if ((ShowDeadKeys=1) && typed && (DisableTypingMode=0) && (ShowSingleKey=1))
  {
       if (typed ~= "i)(⬩│)")
       {
           TypedLetter("▪")
       } else
       {
           TypedLetter(RmDkSymbol)
       }
  }
  if (autoRemDeadKey=1) || (ShowDeadKeys=0)
  {
     lola := "│"
     StringReplace, visibleTextField, visibleTextField, % lola, % TrueRmDkSymbol
     ShowHotkey(visibleTextField)
     CalcVisibleText()
  }
  SetTimer, returnToTyped, 700, -10

  shiftPressed := 0
  AltGrPressed := 0
  keyCount := 0.1

  if !typed && (ShowSingleKey=1)
  {
     if (ShowDeadKeys=1) && (DisableTypingMode=0)
        TypedLetter(RmDkSymbol)
     ShowHotkey(RmDkSymbol)
  }

  if (deadKeyBeeper = 1) && (ShowSingleKey = 1) || (deadKeyBeeper = 1) && (BeepHiddenKeys = 1)
     deadKeysBeeper()

}

deadKeyProcessing() {
  Thread, priority, 10
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  if (ShowDeadKeys=0) || (DisableTypingMode=1) || (autoRemDeadKey=0) || (ShowSingleKey=0) || (DeadKeys=0)
     Return

  Loop, 5
  {
    deadkeyPosition := RegExMatch(typed, "⬩[^[:alpha:]]")
    nextChar := SubStr(typed, deadkeyPosition+1, 1)

    if (nextChar!="⬩") && (deadkeyPosition>=1)
       typed := st_overwrite("▪", typed, deadkeyPosition)
  }
}

OnAltGrDeadKeyPressed() {
  Thread, priority, 10
  Critical, on

  RmDkSymbol := "▪"
  StringRight, TrueRmDkSymbol, A_ThisHotkey, 1
  RmDkSymbol := TrueRmDkSymbol

  if (autoRemDeadKey=1)
     RmDkSymbol := "⬩"

  if (DisableTypingMode=0) && (ShowSingleKey=1)
     typed := backTyped

  if (ShowDeadKeys=1) && (DisableTypingMode=0) && (ShowSingleKey=1)
  {
       typed := backTyped
       if (typed ~= "i)(⬩│)")
       {
           InsertChar2caret("▪")
       } else
       {
           InsertChar2caret(RmDkSymbol)
       }
       SetTimer, returnToTyped, 2, -10
  }

  AltGrPressed := 0
  shiftPressed := 0
  keyCount := 0.1

  if (autoRemDeadKey=1) || (ShowDeadKeys=0)
  {
     lola := "│"
     StringReplace, visibleTextField, visibleTextField, % lola, % TrueRmDkSymbol
     ShowHotkey(visibleTextField)
     CalcVisibleText()
  }
  SetTimer, returnToTyped, 700, -10

  if (deadKeyBeeper = 1) && (ShowSingleKey = 1) || (deadKeyBeeper = 1) && (BeepHiddenKeys = 1)
     deadKeysBeeper()

}

st_overwrite(overwrite, into, pos=1) {
   Thread, priority, 15
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
      Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

   If (abs(pos) > StrLen(into))
      return into
   else If (pos>0)
      return substr(into, 1, pos-1) . overwrite . substr(into, pos+StrLen(overwrite))
   else If (pos<0)
      return SubStr(into, 1, pos) . overwrite . SubStr(into " ",(abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0),abs(pos+StrLen(overwrite)))
   else If (pos=0)
      return into . overwrite
}

returnToTyped() {
    if (StrLen(typed) > 2) && (keycount<10) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (ShowSingleKey=1) && (DisableTypingMode=0) && !A_IsSuspended
    {
        ShowHotkey(visibleTextField)
        SetTimer, HideGUI, % -DisplayTime*2
    }
    SetTimer, , off
}

CreateOSDGUI() {
    global

    CapsDummy := 1
    Gui, OSD: destroy
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow
    Gui, OSD: Margin, 20, 10
    Gui, OSD: Color, %OSDbgrColor%
    Gui, OSD: Font, c%OSDtextColor% s%FontSize% bold, %FontName%, -wrap

    if (A_OSVersion!="WIN_XP")
       Gui, OSD: +E0x20

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

    textAlign := "left"
    widtha := A_ScreenWidth - 50
    positionText := 10

    if ((rightoleft=1) && (NeverRightoLeft=0) && (OSDautosize=1)) || ((rightoleft=1) && (FavorRightoLeft=1))
    {
       textAlign := "right"
       positionText := -10
    }

    if (A_OSVersion!="WIN_XP")
       Gui, OSD: Add, Edit, -E0x200 x%positionText% -multi %textAlign% readonly -WantCtrlA -wrap w%widtha% vHotkeyText, %HotkeyText%

    if (A_OSVersion="WIN_XP")
       Gui, OSD: Add, Text, 0x80 w%widtha% vHotkeyText %textOrientation% %wrappy%

    if (OSDborder=1)
    {
        WinSet, Style, +0xC40000
        WinSet, Style, -0xC00000
        WinSet, Style, +0x800000   ; small border
    }
    progressHeight := FontSize*2.5 < 60 ? 60 : FontSize*2.5
    progressWidth := FontSize/2 < 11 ? 11 : FontSize/2
    Gui, OSD: Add, Progress, x0 y0 w%progressWidth% h%progressHeight% Background%OSDbgrColor% c%CapsColorHighlight% vCapsDummy, 0
}

CreateHotkey() {
    #MaxThreads 250
    #MaxThreadsPerHotkey 250
    #MaxThreadsBuffer On

    if (AutoDetectKBD=1)
       IdentifyKBDlayout()

    static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "!^", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    static mods_list := ["!", "!#", "!#^", "!#^+", "!+", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
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
               if ((n = char2skip) && (DeadKeys=1))
                 continue, 2
             }
           }

           if (IgnoreAdditionalKeys=1)
           {
             for each, char2skip in StrSplit(IgnorekeysList, ".")        ; dead keys to ignore
             {
               if ((n = char2skip) && (IgnoreAdditionalKeys=1))
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
                   Hotkey, % "~+$" A_LoopField, OnLetterPressed, useErrorLevel
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

    Hotkey, % "~*Left", OnRLeftPressed, useErrorLevel
    Hotkey, % "~*Left Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*Right", OnRLeftPressed, useErrorLevel
    Hotkey, % "~*Right Up", OnKeyUp, useErrorLevel

    Hotkey, % "~*Home", OnHomeEndPressed, useErrorLevel
    Hotkey, % "~*Home Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*End", OnHomeEndPressed, useErrorLevel
    Hotkey, % "~*End Up", OnKeyUp, useErrorLevel

    Hotkey, % "~*PgUp", OnPGupDnPressed, useErrorLevel
    Hotkey, % "~*PgUp Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*PgDn", OnPGupDnPressed, useErrorLevel
    Hotkey, % "~*PgDn Up", OnKeyUp, useErrorLevel

    Hotkey, % "~*Del", OnDelPressed, useErrorLevel
    Hotkey, % "~*Del Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*BackSpace", OnBspPressed, useErrorLevel
    Hotkey, % "~*BackSpace Up", OnKeyUp, useErrorLevel

    Hotkey, % "~*Space", OnSpacePressed, useErrorLevel
    Hotkey, % "~*Space Up", OnKeyUp, useErrorLevel
    Hotkey, % "~*CapsLock", OnCapsPressed, useErrorLevel
    Hotkey, % "~*CapsLock Up", OnKeyUp, useErrorLevel

    if (DisableTypingMode=0)
       Hotkey, % "~^v", OnCtrlV, useErrorLevel

    if (OnlyTypingMode!=1)
    {
      Loop, 24 ; F1-F24
      {
          Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
          Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
          if (errorlevel!=0) && (audioAlerts=1)
             soundbeep, 1900, 50
      }
    }

    Loop, 10 ; Numpad0 - Numpad9
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnKeyPressed, UseErrorLevel
        Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    NumpadKeysList := "NumpadDot|sc052|sc04F|sc050|sc051|sc04B|sc04C|sc04D|sc047|sc048|sc049|sc053"

    Loop, parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          soundbeep, 1900, 50
    }

    NumpadLetters := "NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"

    Loop, parse, NumpadLetters, |
    {
       Hotkey, % "~*" A_LoopField, OnNumSymbolsPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          soundbeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|Up|Down|ScrollLock|NumLock|Pause|NumpadEnter|sc145|sc146|sc046|sc123|sc11d"
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

    if typed {
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

    if (StickyKeys=1)
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

    if (HotkeyStr ~= "i)( \+ )$") && !typed && ShowSingleModifierKey=0 && StickyKeys=1 || (NeverDisplayOSD=1) ; || (OnlyTypingMode=1)
       Return

    if (HotkeyStr ~= "i)(Shift \+ )$") && (ShowSingleModifierKey=0) && (StickyKeys=1)
       Return

    if (HotkeyStr ~= "i)( \+ )") && !(typed ~= "i)( \+ )") && (OnlyTypingMode=1)
       Return

    if (OSDautosize=1)
    {
        growthIncrement := (FontSize/2)*(OSDautosizeFactory/150)
        startPoint := GetTextExtentPoint(HotkeyStr, FontName, FontSize, bBold) / (OSDautosizeFactory/100) + 30
        if (startPoint > text_width+growthIncrement) || (startPoint < text_width-growthIncrement)
           text_width := startPoint
        text_width := (text_width > maxAllowedGuiWidth) || (text_width > maxAllowedGuiWidth-growthIncrement) ? maxAllowedGuiWidth : text_width

    } else if (OSDautosize=0)
    {
        text_width := maxAllowedGuiWidth
    }

    dGuiX := GuiX

    GuiControl, OSD: , HotkeyText, %HotkeyStr%

    if (rightoleft=1)
    {
        GuiGetSize(W, H)
        dGuiX := w ? GuiX - w : GuiX
        GuiControl, OSD: Move, HotkeyText, w%text_width% Left
    }

    SetTimer, checkMousePresence, on, 400, -5
    Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%text_width%, KeypressOSD

    if (rightoleft=1)
    {
        GuiGetSize(W, H)
        dGuiX := w ? GuiX - w : GuiX
        Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%text_width%, KeypressOSD
    }
    WinSet, AlwaysOnTop, On, KeypressOSD
    visible := 1
}

ShowLongMsg(stringo) {
   text_width2 := GetTextExtentPoint(stringo, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
   maxAllowedGuiWidth := text_width2 + 30
   ShowHotkey(stringo)
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
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

  nWidth := nSize & 0xFFFFFFFF
  nWidth := (nWidth<35) ? 36 : nWidth
  minHeight := FontSize*1.5
  GuiHeight := nSize >> 32 & 0xFFFFFFFF
  GuiHeight := GuiHeight / (OSDautosizeFactory/100) + (OSDautosizeFactory/10) + 4
  GuiHeight := (GuiHeight<minHeight) ? minHeight+1 : GuiHeight

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
    Thread, priority, 15
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

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
    StringRight, backupKey, key, 1

    key := RegExReplace(key, "i)^(~\+\$.?)$")
    key := RegExReplace(key, "i)^(~\+<!<\^|~\+<!>\^|~<\^>!|~!#\^\+|~<\^<!|~>\^>!|~#!\+|~#!\^|~#\+\^|~\+!\^|~!#\^|~!\+\^|~!#|~\+#|~#\^|~!\+|~!\^|~\+\^|~#!|~\*|~\^|~!|~#|~\+)")
    StringReplace, key, key, ~,
    if (StrLen(key)=2) && (enableAltGr=0)
    {
          if !(key ~= "i)^(up|f[0-9])")
              StringRight, key, key, 1
    }

    if GetKeyState("Shift")
    {
       If (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
          modsBeeper()

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
        backupKey := !key ? backupKey : key
        if (StrLen(key)=1) || InStr(key, " up") && StrLen(key)=4 && typed
        {
            StringLeft, key, key, 1
            key := GetKeyChar(key, "A")
        } else if ( SubStr(key, 1, 2) = "sc" ) {
            key := SpecialSC(key)
        } else if (StrLen(key)<1) && !prefix {
             key := (ShowDeadKeys=1) ? "◐" : "(unknown key)"
             key := backupKey ? backupKey : key
        } else if (key = "Volume_Up") {
            Sleep, 40
            SoundGet, master_volume
            key := "Volume up: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "Volume_Down") {
            Sleep, 40
            SoundGet, master_volume
            key := "Volume down: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "Volume_mute") {
            SoundGet, master_volume
            SoundGet, master_mute, , mute
            if master_mute = on
               key := "Volume mute"
            if master_mute = off
               key := "Volume level: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "PrintScreen") {
            if (HideAnnoyingKeys=1 && !prefix)
                throw
            key := "Print Screen"
        } else if (key = "Media_Play_Pause") {
            key := "Media_Play/Pause"
        } else if (key = "WheelRight") {
            key := "Wheel Right"
        } else if (key = "WheelLeft") {
            key := "Wheel Left"
        } else if (key = "NumpadEnter") {
            key := "[Enter]"
        } else if (key = "NumpadDiv") {
            key := (DisableTypingMode=1) || prefix ? "[ / ]" : "/"
        } else if (key = "NumpadMult") {
            key := (DisableTypingMode=1) || prefix ? "[ * ]" : "*"
        } else if (key = "NumpadAdd") {
            key := (DisableTypingMode=1) || prefix ? "[ + ]" : "+"
        } else if (key = "NumpadSub") {
            key := (DisableTypingMode=1) || prefix ? "[ - ]" : "-"
        } else if (key = "PgUp") {
            key := "Page Up"
        } else if (key = "PgDn") {
            key := "Page Down"
        } else if (key = "WheelUp") {
            if (ShowMouseButton=0)
               throw
            key := "Wheel Up"
        } else if (key = "Del") {
            key := "Delete"
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
                if (!(typed ~= "i)(  │)") && strlen(typed)>3 && (ShowMouseButton=1)) {
                    typed := InsertChar2caret(" ")
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
        if ((ShowPrevKey=1) && (keyCount<2) && (A_TickCount-tickcount_start < ShowPrevKeyDelay) && (!(pre_key ~= "i)^(Media_|Volume|Caps lock|Num lock|Scroll lock)")))
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
        
        if (key=pre_key) && (ShowKeyCountFired=0) && (ShowKeyCount=1) && !(key ~= "i)(volume)")
        {
           trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
           keyCount := (trackingPresses=0 && keycount<2) ? keycount+1 : keycount
           if (trackingPresses=1)
              keyCount := !keycount ? 1 : keyCount+1
           if (trackingPresses=0) && InStr(prefix, "+") && (A_TickCount-tickcount_start < 600) && (tickcount_start2 - tickcount_start < 500)
              keyCount := !keycount ? 1 : keyCount+1
           ShowKeyCountValid := 1
        } else if (key=pre_key) && (ShowKeyCountFired=1) && (ShowKeyCount=1) && !(key ~= "i)(volume)")
        {
           keyCount := !keycount ? 0 : keyCount+1
           ShowKeyCountValid := 1
        } else if (key=pre_key) && (ShowKeyCount=0) && (DisableTypingMode=0)
        {
           keyCount := !keycount ? 0 : keyCount+1
           ShowKeyCountValid := 0
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
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

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
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (AutoDetectKBD=0)
    {
       kbLayoutAltGRpairs := AltGrPairs_0   ; this the default, English US
       enableAltGr := 0
    }

    if kbLayoutAltGRpairs.hasKey(letterina)
    {
       if (StickyKeys=1)
          typed := (AltGrPressed=1) ? backTyped : ""
       letterina := kbLayoutAltGRpairs[letterina]
       return letterina
    } else
    {
       if (StickyKeys=1)
          typed := (AltGrPressed=1) ? backTyped : ""
       letterina := ""
       return letterina
    }
}

CompactModifiers(stringy) {
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

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
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    GetSpecialKeysStates()

    GetKeyState, NumState, NumLock, T
    If (NumState="D" || NumLockForced=1)
    {
       k := {sc11d: "AltGr", sc046: zcSCROL, sc145: "NUM LOCK ON", sc146: "Pause/Break", sc123: "Genius LuxeMate Scroll", sc052: "[0]", sc04F: "[1]", sc050: "[2]", sc051: "[3]", sc04B: "[4]", sc04C: "[5]", sc04D: "[6]", sc047: "[7]", sc048: "[8]", sc049: "[9]", sc053: "[.]"}
    } else
    {
       k := {sc11d: "AltGr", sc046: zcSCROL, sc145: "Num lock off", sc146: "Pause/Break", sc123: "Genius LuxeMate Scroll", sc052: "[Insert]", sc04F: "[End]", sc050: "[Down]", sc051: "[Page Down]", sc04B: "[Left]", sc04C: "[Undefined]", sc04D: "[Right]", sc047: "[Home]", sc048: "[Up]", sc049: "[Page Up]", sc053: "[Delete]"}
    }

    if (!k[sc] && (AutoDetectKBD=1) && InStr(CurrentKBD, "latvian"))
       k := {sc029vkC0: "–"}

    if !k[sc]
       k[sc] := GetKeyName(sc)

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

  if (!FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled) || (FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled)
  {
      soundbeep
      ShowLongMsg("Downloading language definitions file... Please wait.")
      downLangFile()
  }

  if (A_IsCompiled && (loadedLangz!=1))
  {
      ReloadCounter := 1000
      IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
      ForceKBD := 0
      AutoDetectKBD := 0
      SoundBeep
      IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
      IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
      MsgBox, File compiled without language definitions.
  }

  check_kbd := StrLen(LangName_%kbLayout%)>2 ? 1 : 0
  check_kbd_exact := StrLen(LangRaw_%kbLayoutRaw%)>2 ? 1 : 0
  if (check_kbd_exact=0)
      partialKBDmatch = (Partial match)

  if (check_kbd=0) && (loadedLangz=1)
  {
      ShowLongMsg("Unrecognized layout: (kbd " kbLayoutRaw ").")
      SetTimer, HideGUI, % -DisplayTime
      CurrentKBD := kbLayoutRaw ". Layout unrecognized:"
      soundbeep, 500, 900
  }

  StringLeft, kbLayoutSupport, LangName_%kbLayout%, 1
  if (kbLayoutSupport="-") && (check_kbd=1) && (loadedLangz=1)
  {
      ShowLongMsg("Unsupported layout: " LangName_%kbLayout% " (kbd" kbLayout ").")
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

  if (kbLayoutSupport!="-") && (check_kbd=1) && (loadedLangz=1)
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

      identifiedKbdName := (check_kbd_exact=1) ? LangRaw_%kbLayoutRaw% : LangName_%kbLayout%

      if (SilentDetection=0)
      {
          ShowLongMsg("Layout detected: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)
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
       enableAltGr := (enableAltGrUser=1) ? enableAltGrUser : 2
    } else
    {
       enableAltGr := 0
    }

    if (ForceKBD=0) && (AutoDetectKBD=1) && (loadedLangz=1)
    {
       identifiedKbdName := Strlen(identifiedKbdName)>3 ? identifiedKbdName : "unsupported layout"
       StringLeft, clayout, identifiedKbdName, 25
       Menu, tray, add, %clayout%, dummy
       Menu, tray, Disable, %clayout%
       Menu, tray, add

       SetFormat, Integer, H
       ThisInputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
       SetFormat, Integer, d
       IniWrite, %identifiedKbdName%, %IniFile%, Languages, %ThisInputLocaleID%
    }

    IniRead, LangChanged, %inifile%, TempSettings, LangChanged, 0

    VarSetCapacity(kbLayoutRaw2, 32, 0)
    DllCall("GetKeyboardLayoutName", "Str", kbLayoutRaw2)
    IniRead, kbLayoutRaw2, %IniFile%, TempSettings, kbLayoutRaw2
    if (kbLayoutRaw=kbLayoutRaw2) && (LangChanged=1) && (kbLayoutSupport!="-") && (check_kbd=1)
       noConstantMonitor := 1

    LangChanged := 0
    IniWrite, %kbLayoutRaw%, %IniFile%, TempSettings, kbLayoutRaw2
    IniWrite, %LangChanged%, %IniFile%, TempSettings, LangChanged

    if (ConstantAutoDetect=1) && (noConstantMonitor!=1) && (AutoDetectKBD=1) && (loadedLangz=1) && (ForceKBD=0)
       SetTimer, ConstantKBDchecker, 2000, -15
}

ConstantKBDchecker() {
  Thread, priority, -20

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
        LangChanged := 1
        IniWrite, %LangChanged%, %IniFile%, TempSettings, LangChanged

        if (SilentDetection=0)
        {
           InputLocaleName := Strlen(InputLocaleName)>3 && !InStr(InputLocaleName, "unsupported") ? InputLocaleName : lastKBDid
           ShowLongMsg("Layout changed to: " InputLocaleName)
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
   Menu, Tray, Rename, &KeyPress activated,&KeyPress deactivated
   if (ErrorLevel=1)
   {
      Menu, Tray, Rename, &KeyPress deactivated,&KeyPress activated
      Menu, Tray, Check, &KeyPress activated
   }
   Menu, Tray, Uncheck, &KeyPress deactivated

   CreateOSDGUI()
   ShowLongMsg("KeyPress OSD toggled")
   SetTimer, HideGUI, % -DisplayTime/6
   Sleep, DisplayTime/6+15
   Suspend
return

ToggleConstantDetection:
   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   AutoDetectKBD := 1
   ConstantAutoDetect := (ConstantAutoDetect=0) ? 1 : 0
   IniWrite, %ConstantAutoDetect%, %IniFile%, SavedSettings, ConstantAutoDetect
   IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD

   if (ConstantAutoDetect=1)
   {
      SetTimer, ConstantKBDchecker, 2000, -15
      Menu, Tray, Check, &Monitor keyboard layout
   }

   if (ConstantAutoDetect=0)
   {
      Menu, Tray, Uncheck, &Monitor keyboard layout
      SetTimer, ConstantKBDchecker, off
   }

   Sleep, 500
return

ToggleNeverDisplay:
   NeverDisplayOSD := (NeverDisplayOSD=0) ? 1 : 0
   IniWrite, %NeverDisplayOSD%, %IniFile%, SavedSettings, NeverDisplayOSD

   if (NeverDisplayOSD=1)
      Menu, SubSetMenu, Check, &Never show the OSD

   if (NeverDisplayOSD=0)
      Menu, SubSetMenu, unCheck, &Never show the OSD

   Sleep, 300
return

ToggleShowSingleKey:
    ShowSingleKey := (!ShowSingleKey) ? 1 : 0
    if (ShowSingleKey=0)
       OnlyTypingMode := 0

    if (ShowSingleKey=1)
       IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%

    CreateOSDGUI()
    IniWrite, %ShowSingleKey%, %IniFile%, SavedSettings, ShowSingleKey

    ShowLongMsg("Show single keys = " ShowSingleKey)
    SetTimer, HideGUI, % -DisplayTime/2
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
        ShowLongMsg("OSD position changed")
        sleep, 450
        ShowLongMsg("OSD position changed")
        SetTimer, HideGUI, % -DisplayTime/3
        Gui, OSD: Destroy
        sleep, 20
        CreateOSDGUI()
        sleep, 20 
    }
return

ToggleForcedLanguage:
    ForceKBD := 1
    AutoDetectKBD := 1
    ForcedKBDlayout := (ForcedKBDlayout = 0) ? 1 : 0
    CreateOSDGUI()
    ShowLongMsg("Forced keyboard layout changed to" ForcedKBDlayout ". Please wait...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    sleep, 1100
    Reload
return

EnableCustomKeys:
    CustomRegionalKeys := CustomRegionalKeys = 1 ? 0 : 1
    IniWrite, %CustomRegionalKeys%, %IniFile%, SavedSettings, CustomRegionalKeys
    ShowLongMsg("Bind additional keys = " RegionalKeys)
    sleep, 1100
    Reload
return

DetectLangNow:
    CreateOSDGUI()
    ForceKBD := 0
    AutoDetectKBD := 1
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    ShowLongMsg("Detecting keyboard layout...")
    sleep, 1100
    Reload
return

ReloadScript:
    CreateOSDGUI()
    ShowLongMsg("Reinitializing...")
    sleep, 1100
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
        if (ClipMonitor=0)
        {
           ClipMonitor := 1
           OnClipboardChange("ClipChanged")
        }
        SetTimer, MouseHalo, off
        Gui, MouseH: Hide
        SetTimer, capturetext, 1500, -10
        ShowLongMsg("Enabled automatic Capture 2 Text")
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
        Gui, OSD: Destroy
        sleep, 50
        CreateOSDGUI()
        sleep, 50
        IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
        IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
        SetTimer, capturetext, off
        Capture2Text := (Capture2Text=1) ? 0 : 1
        ShowLongMsg("Disabled automatic Capture 2 Text")
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
    if ((type=1) && (ClipMonitor=1) && !A_IsSuspended)
    {
       troll := clipboard
       Stringleft, troll, troll, 150
       StringReplace, troll, troll, `r`n, %A_SPACE%, All
       StringReplace, troll, troll, %A_TAB%, %A_SPACE%, All
       StringReplace, troll, troll, %A_SPACE%%A_SPACE%, , All
       ShowLongMsg(troll)
       SetTimer, HideGUI, % -DisplayTime*2
    } else if (type=2 && ClipMonitor=1 && !A_IsSuspended)
    {
       ShowLongMsg("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

CreateMouseGUI() {
    global

    Gui, Mouser: +AlwaysOnTop -Caption +ToolWindow
    Gui, Mouser: Margin, 0, 0

    if (A_OSVersion!="WIN_XP")
       Gui, Mouser: +E0x20
}

ShowMouseClick(clicky) {
    Thread, priority, -10
    SetTimer, HideMouseClickGUI, 900, -22
    SetTimer, ShowMouseIdleLocation, off
    Sleep, 150
    Gui, Mouser: Destroy
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

    Gui, Mouser: Color, %OuterColor%  ; outer rectangle
    Gui, Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
    Gui, Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
    WinSet, Transparent, %TransparencyLevel%, MousarWin
    Sleep, 250
    WinSet, AlwaysOnTop, On, MousarWin
}

HideMouseClickGUI() {
    Thread, priority, -10
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
          Gui, Mouser: Hide
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
    Thread, priority, -10
    If (A_TimeIdlePhysical > (MouseIdleAfter*1000)) && !A_IsSuspended
    {
       Gui, Mouser: Destroy
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
       Gui, Mouser: Color, %OuterColor%  ; outer rectangle
       Gui, Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
       Gui, Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
       WinSet, Transparent, %IdleMouseAlpha%, MousarWin
       WinSet, AlwaysOnTop, On, MousarWin
    } else
    {
        Gui, Mouser: Hide
    }
}

MouseHalo() {
    Thread, priority, -10
    If (ShowMouseHalo=1) && !A_IsSuspended
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       mX := mX - BoxW
       mY := mY - BoxH
       Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow
       Gui, MouseH: Margin, 0, 0
       Gui, MouseH: Color, %MouseHaloColor%
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
       WinSet, Transparent, %MouseHaloAlpha%, MousarHallo
       WinSet, AlwaysOnTop, On, MousarHallo

       if (A_OSVersion!="WIN_XP")
          Gui, MouseH: +E0x20
    }
}

InitializeTray() {

    Menu, SubSetMenu, add, &Keyboard, ShowKBDsettings
    Menu, SubSetMenu, add, &Mouse, ShowMouseSettings
    Menu, SubSetMenu, add, &Sounds, ShowSoundsSettings
    Menu, SubSetMenu, add, &Typing mode, ShowTypeSettings
    Menu, SubSetMenu, add, &OSD appearances, ShowOSDsettings
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, &Never show the OSD, ToggleNeverDisplay
    if (NeverDisplayOSD=1)
       Menu, SubSetMenu, Check, &Never show the OSD
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, Restore defaults, DeleteSettings
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, Key &history, KeyHistoryWindow
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, &Update now, updateNow
    Menu, tray, tip, KeyPress OSD v%version%
    Menu, tray, NoStandard
    if (AutoDetectKBD=1) && (ForceKBD=0) && (loadedLangz=1)
    {
       Menu, tray, add, &Monitor keyboard layout, ToggleConstantDetection
       Menu, tray, check, &Monitor keyboard layout
       if (ConstantAutoDetect=0)
          Menu, tray, uncheck, &Monitor keyboard layout
    }

    if (ConstantAutoDetect=0) && (ForceKBD=0) && (loadedLangz=1)
    {
       Menu, tray, add, &Detect keyboard layout now, DetectLangNow
       Menu, tray, add, &Monitor keyboard layout, ToggleConstantDetection
    }
    Menu, tray, add
    Menu, tray, add, &Preferences, :SubSetMenu
    Menu, tray, add

    if (ForceKBD=1) && (loadedLangz=1)
    {
       StringRight, clayout, ForcedKBDlayout, 4
       Menu, tray, add, Toggle &forced layout (%clayout%), ToggleForcedLanguage
       Menu, tray, add
    }

    if (loadedLangz=1) && (ConstantAutoDetect=0)
       Menu, tray, add, &Detect keyboard layout now, DetectLangNow

    Menu, tray, add, &Toggle OSD positions, TogglePosition
    Menu, tray, add, &Capture2Text enable, ToggleCapture2Text
    Menu, tray, add
    Menu, tray, add, &KeyPress activated, SuspendScript
    Menu, tray, Check, &KeyPress activated
    Menu, tray, add, &Restart, ReloadScript
    Menu, tray, add
    Menu, tray, add, &Help, dummy
    Menu, tray, add, &About, AboutWindow
    Menu, tray, add
    Menu, tray, add, E&xit, KillScript
}

OnExit, KillScript

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

ShowTypeSettings() {
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

    global editF1, editF2    
    deadKstatus := (DeadKeys=1) ? "Dead keys present." : "No dead keys defined."
    altGrStatus := (enableAltGr=1) && (AutoDetectKBD=1) || (enableAltGr=2) && (AutoDetectKBD=1) ? "AltGr keys present." : "No AltGr keys defined."
    if !InStr(CurrentKBD, "unsupported") && !InStr(CurrentKBD, "unrecognized")
       ShiftStatus := (kbLayoutSymbols=0) && (AutoDetectKBD=1) ? "WARNING: no keys with Shift defined." : ""

    Gui, SettingsGUIA: font, bold
    Gui, SettingsGUIA: Add, text, x15 y15, Keyboard layout status: %ShiftStatus%
    Gui, SettingsGUIA: font, normal
    Gui, Add, text, xp+0 yp+15, %CurrentKBD%. %kbLayoutRaw%
    if !InStr(CurrentKBD, "unsupported") && !InStr(CurrentKBD, "unrecognized")
       Gui, Add, text, xp+0 yp+15, %deadKstatus% %altGrStatus%
    Gui, Add, Checkbox, xp+0 yp+30 gVerifyTypeOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys in the OSD, not just key combinations
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%DisableTypingMode% vDisableTypingMode, Disable typing mode
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only
    Gui, Add, Checkbox, xp+0 yp+30 gVerifyTypeOptions Checked%enterErasesLine% venterErasesLine, Enter and Escape keys erase texts from the OSD
    Gui, Add, Checkbox, xp+0 yp+20 Checked%enableAltGrUser% venableAltGrUser, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%enableTypingHistory% venableTypingHistory, Typed text history (Page Up/Down)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%ShowDeadKeys% vShowDeadKeys, Insert the dead key symbol in the OSD when typing
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%autoRemDeadKey% vautoRemDeadKey, Do not treat dead keys as a different character (generic symbol)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%CapslockBeeper% vCapslockBeeper, Make beeps when typing with CapsLock turned on
    Gui, Add, text, xp+0 yp+30, Display time when typing (in seconds)
    Gui, Add, Edit, xp+270 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser Range2-99, %DisplayTimeTypingUser%
    Gui, Add, text, xp-270 yp+20, Timer to resume typing with text related keys (in sec.)
    Gui, Add, Edit, xp+270 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %ReturnToTypingUser%
    Gui, Add, UpDown, vReturnToTypingUser Range2-99, %ReturnToTypingUser%
    Gui, SettingsGUIA: add, Button, xp-270 yp+40 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+62 yp+0 w60 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Typing mode settings: KeyPress OSD
    VerifyTypeOptions()
}

VerifyTypeOptions() {
    GuiControlGet, DisableTypingMode
    GuiControlGet, ShowSingleKey
    GuiControlGet, enableAltGrUser
    GuiControlGet, enableTypingHistory
    GuiControlGet, ShowDeadKeys
    GuiControlGet, autoRemDeadKey
    GuiControlGet, DisplayTimeTypingUser
    GuiControlGet, ReturnToTypingUser
    GuiControlGet, OnlyTypingMode
    GuiControlGet, enterErasesLine
    GuiControlGet, editF1
    GuiControlGet, editF2

    if (ShowSingleKey=0)
    {
       GuiControl, Disable, DisableTypingMode
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, DisableTypingMode
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, autoRemDeadKey
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }
  
    if (DisableTypingMode=1)
    {
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else if (ShowSingleKey!=0)
    {
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, autoRemDeadKey
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    if (ShowDeadKeys=0)
    {
       GuiControl, Disable, autoRemDeadKey
    } else if ((DisableTypingMode!=1) || (ShowSingleKey!=1))
    {
       GuiControl, Enable, autoRemDeadKey
    }

    if (ShowSingleKey!=1)
       GuiControl, Disable, autoRemDeadKey

    if ((ForceKBD=0) && (AutoDetectKBD=0))
    {
       GuiControl, Disable, enableAltGrUser
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
    }

    if (OnlyTypingMode=0)
       GuiControl, Disable, enterErasesLine
}

ShowSoundsSettings() {
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

    Gui, SettingsGUIA: add, text, x15 y15, Make a beep when the following keys are released:
    Gui, Add, Checkbox, gVerifySoundsOptions xp+15 yp+20 Checked%KeyBeeper% vKeyBeeper, All bound keys
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%deadKeyBeeper% vdeadKeyBeeper, Recognized dead keys
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%ModBeeper% vModBeeper, Modifiers (Ctrl, Alt, WinKey, Shift)
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, On mouse clicks
    Gui, Add, Checkbox, xp+0 yp+20 Checked%BeepHiddenKeys% vBeepHiddenKeys, Even if such keys are not displayed in the OSD

    Gui, Add, Checkbox, gVerifySoundsOptions xp-15 yp+30 Checked%CapslockBeeper% vCapslockBeeper, Beep distinctively when typing with CapsLock turned on
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%beepFiringKeys% vbeepFiringKeys, Generic beep for every key fire
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%audioAlerts% vaudioAlerts, At start, beep for every failed key binding
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+30 Checked%LowVolBeeps% vLowVolBeeps, Play beeps at reduced volume
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%prioritizeBeepers% vprioritizeBeepers, Prioritize beeps (may interfere with typing mode)
    if (missingAudios=1)
    {
       Gui, font, bold
       Gui, add, text, xp+0 yp+30, WARNING. Sound files are missing.
       Gui, add, text, xp+0 yp+30, The attempts to download them seem to have failed.
       Gui, add, text, xp+0 yp+30, The beeps will be synthesized at a high volume.
       Gui, font, normal
    }

    Gui, SettingsGUIA: add, Button, xp+0 yp+40 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+62 yp+0 w60 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Sounds settings: KeyPress OSD
    VerifySoundsOptions()

    verifyNonCrucialFilesRan := 2
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

    verifyNonCrucialFiles()
}

VerifySoundsOptions() {

    if (ShowMouseButton=0 && VisualMouseClicks=0)
    {
       GuiControl, Disable, MouseBeeper
    } else 
    {
       GuiControl, Enable, MouseBeeper
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0))
       GuiControl, Disable, deadKeyBeeper

    if (DisableTypingMode=1)
       GuiControl, Disable, CapslockBeeper

    if (missingAudios=1)
    {
       GuiControl, Disable, LowVolBeeps
       GuiControl, , LowVolBeeps, 0
    }
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
    Gui, SettingsGUIA: add, text, xp+0 yp+40, Settings regarding keyboard layouts:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continuously detect layout changes
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

    Gui, SettingsGUIA: add, text, x260 y15, Display behavior:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys
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

    Gui, SettingsGUIA: add, text, xp-190 yp+35, Other options:
    Gui, Add, Checkbox, xp+10 yp+20 Checked%KeyboardShortcuts% vKeyboardShortcuts, Global keyboard shortcuts
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ClipMonitor% vClipMonitor, Monitor clipboard changes

    Gui, SettingsGUIA: add, Button, xp+0 yp+40 w60 h30 Default gApplySettings, A&pply
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
    GuiControlGet, ShowSingleKey
    GuiControlGet, HideAnnoyingKeys
    GuiControlGet, SilentDetection
    GuiControlGet, ShowSingleModifierKey
    GuiControlGet, ShowKeyCount
    GuiControlGet, ShowKeyCountFired
    GuiControlGet, ShowPrevKey
    GuiControlGet, enableAltGrUser

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
       GuiControl, Disable, HideAnnoyingKeys
       GuiControl, Disable, ShowSingleModifierKey
    } else
    {
       GuiControl, Enable, HideAnnoyingKeys
       GuiControl, Enable, ShowSingleModifierKey
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
    global editF1, editF2, editF3, editF4, editF5, editF6, editF7, btn1

    Gui, Add, Checkbox, gVerifyMouseOptions x15 x15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%FlashIdleMouse% vFlashIdleMouse, Flash idle mouse to locate it
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, Beep on mouse clicks
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%VisualMouseClicks% vVisualMouseClicks, Visual mouse clicks (scale, alpha)
    Gui, Add, Edit, xp+16 yp+20 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %ClickScaleUser%
    Gui, Add, UpDown, vClickScaleUser Range3-90, %ClickScaleUser%
    Gui, Add, Edit, xp+50 yp+0 w45 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %MouseVclickAlpha%
    Gui, Add, UpDown, vMouseVclickAlpha Range10-240, %MouseVclickAlpha%

    Gui, Add, Edit, x335 y15 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %MouseHaloRadius%
    Gui, Add, UpDown, vMouseHaloRadius Range5-950, %MouseHaloRadius%
    Gui, Add, Progress, xp+0 yp+25 w35 h20 BackgroundBlack c%MouseHaloColor% vMouseHaloColor, 100
    Gui, Add, Button, xp+36 yp+0 w25 h20 gChooseColorHalo vBtn1, P
    Gui, Add, Edit, xp-36 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %MouseHaloAlpha%
    Gui, Add, UpDown, vMouseHaloAlpha Range10-240, %MouseHaloAlpha%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %MouseIdleAfter%
    Gui, Add, UpDown, vMouseIdleAfter Range3-950, %MouseIdleAfter%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %MouseIdleRadius%
    Gui, Add, UpDown, vMouseIdleRadius Range5-950, %MouseIdleRadius%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %IdleMouseAlpha%
    Gui, Add, UpDown, vIdleMouseAlpha Range10-240, %IdleMouseAlpha%

    Gui, Add, text, x210 y15, Halo radius:
    Gui, Add, text, xp+0 yp+25, Halo color:
    Gui, Add, text, xp+0 yp+25, Halo alpha:
    Gui, Add, text, xp+0 yp+25, Mouse idle after (in sec.)
    Gui, Add, text, xp+0 yp+25, Idle halo radius:
    Gui, Add, text, xp+0 yp+25, Idle halo alpha:

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
    {
       GuiControl, Disable, MouseBeeper
    } else 
    {
       GuiControl, Enable, MouseBeeper
    }

    if (VisualMouseClicks=0)
    {
       GuiControl, Disable, ClickScaleUser
       GuiControl, Disable, MouseVclickAlpha
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, ClickScaleUser
       GuiControl, Enable, MouseVclickAlpha
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    if (FlashIdleMouse=0)
    {
       GuiControl, Disable, MouseIdleAfter
       GuiControl, Disable, MouseIdleRadius
       GuiControl, Disable, IdleMouseAlpha
       GuiControl, Disable, editF5
       GuiControl, Disable, editF6
       GuiControl, Disable, editF7
    } else
    {
       GuiControl, Enable, MouseIdleAfter
       GuiControl, Enable, MouseIdleRadius
       GuiControl, Enable, IdleMouseAlpha
       GuiControl, Enable, editF5
       GuiControl, Enable, editF6
       GuiControl, Enable, editF7
    }

    disabledColor := "cccccc"
    if (ShowMouseHalo=0)
    {
       GuiControl, Disable, MouseHaloRadius
       GuiControl, +c%disabledColor%, MouseHaloColor
       GuiControl, Disable, MouseHaloAlpha
       GuiControl, Disable, btn1
       GuiControl, Disable, editF3
       GuiControl, Disable, editF4
    } else
    {
       GuiControl, Enable, MouseHaloRadius
       GuiControl, +c%MouseHaloColor%, MouseHaloColor
       GuiControl, Enable, MouseHaloAlpha
       GuiControl, Enable, btn1
       GuiControl, Enable, editF3
       GuiControl, Enable, editF4
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
    global editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, btn1, btn2, btn3, btn4
    GUIposition := GUIposition + 1

    Gui, SettingsGUIA: Add, Radio, x15 y35 gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, xp+0 yp+25 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, Button, xp+145 yp-25 w25 h20 gLocatePositionA vBtn1, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %GuiXa%
    Gui, Add, UpDown, vGuiXa 0x80 Range-9995-9998, %GuiXa%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %GuiYa%
    Gui, Add, UpDown, vGuiYa 0x80 Range-9995-9998, %GuiYa%
    Gui, Add, Button, xp-86 yp+25 w25 h20 gLocatePositionB vBtn2, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %GuiXb%
    Gui, Add, UpDown, vGuiXb 0x80 Range-9995-9998, %GuiXb%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %GuiYb%
    Gui, Add, UpDown, vGuiYb 0x80 Range-9995-9998, %GuiYb%
    Gui, Add, DropDownList, xp-150 yp+25 w145 Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+150 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %FontSize%
    Gui, Add, UpDown, vFontSize Range7-295, %FontSize%
    Gui, Add, Progress, xp-60 yp+25 w55 h20 BackgroundBlack c%OSDtextColor% vOSDtextColor, 100
    Gui, Add, Button, xp+60 yp+0 w55 h20 gChooseColorTEXT vBtn3, Pick
    Gui, Add, Progress, xp-60 yp+25 w55 h20 BackgroundBlack c%OSDbgrColor% vOSDbgrColor, 100
    Gui, Add, Button, xp+60 yp+0 w55 h20 gChooseColorBGR vBtn4, Pick
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %DisplayTimeUser%
    Gui, Add, UpDown, vDisplayTimeUser Range2-99, %DisplayTimeUser%
    Gui, Add, Edit, xp+0 yp+25 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %GuiWidth%
    Gui, Add, UpDown, vGuiWidth Range55-990, %GuiWidth%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %maxGuiWidth%
    Gui, Add, UpDown, vmaxGuiWidth Range55-995, %maxGuiWidth%
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %OSDautosizeFactory%
    Gui, Add, UpDown, vOSDautosizeFactory Range10-400, %OSDautosizeFactory%

    Gui, Add, text, x15 y15, OSD location presets. Click L to define each.
    Gui, Add, text, xp+0 yp+72, Font
    Gui, Add, text, xp+0 yp+25, Text color
    Gui, Add, text, xp+0 yp+25, Background color
    Gui, Add, text, xp+0 yp+25, Display time (in seconds)
    Gui, Add, text, xp+0 yp+25, Width (fixed size / dynamic max,)
    Gui, Add, text, xp+0 yp+25, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (screen DPI: %A_ScreenDPI%)
    Gui, Add, Checkbox, xp+0 yp+25 Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%FavorRightoLeft% vFavorRightoLeft, Favor right alignment
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%NeverRightoLeft% vNeverRightoLeft, Never align to the right
    Gui, Add, text, xp+15 yp+15 w250, Recommended if you want to place the OSD on a secondary screen
    Gui, Add, Checkbox, xp-15 yp+35 Checked%JumpHover% vJumpHover, Toggle OSD positions when mouse runs over it

    Loop, % FontList.MaxIndex() {
      GuiControl, , FontName, % FontList[A_Index]
    }

    Gui, SettingsGUIA: add, Button, xp+0 yp+40 w60 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+65 yp+0 w60 h30 gCloseSettings, C&ancel
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
        GuiControl, Disable, btn1
        GuiControl, Disable, editF1
        GuiControl, Disable, editF2
        GuiControl, Enable, GuiXb
        GuiControl, Enable, GuiYb
        GuiControl, Enable, btn2
        GuiControl, Enable, editF3
        GuiControl, Enable, editF4
    } else
    {
        GuiControl, Enable, GuiXa
        GuiControl, Enable, GuiYa
        GuiControl, Enable, btn1
        GuiControl, Enable, editF1
        GuiControl, Enable, editF2
        GuiControl, Disable, GuiXb
        GuiControl, Disable, GuiYb
        GuiControl, Disable, btn2
        GuiControl, Disable, editF3
        GuiControl, Disable, editF4
    }

    if (OSDautosize=0)
    {
        GuiControl, Enable, GuiWidth
        GuiControl, Enable, editF7
        GuiControl, Disable, maxGuiWidth
        GuiControl, Disable, editF8
    } else
    {
        GuiControl, Disable, GuiWidth
        GuiControl, Disable, editF7
        GuiControl, Enable, maxGuiWidth
        GuiControl, Enable, editF8
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
    Sleep, 20
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
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Sean (GetTextExtentPoint), Tidbit and Lexikos.
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
                SoundBeep
                MsgBox, 4,, Corrupt file: keypress-osd-changelog.txt. The attempt to download it seems to have failed. To try again file must be deleted. Do you agree?
                IfMsgBox Yes
                {
                   FileDelete, %historyFile%
                }
             }
         }
     } else 
     {
         SoundBeep
         MsgBox, Missing file: %historyFile%. The attempt to download it seems to have failed.
     }
}

downLangFile() {

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     langyFile := "keypress-osd-languages.ini"
     langyFileURL := baseURL langyFile
     IniRead, ReloadCounter, %IniFile%, TempSettings, ReloadCounter, 0

     if (!FileExist(langyFile) || (ForceDownloadExternalFiles=1))
     {
         UrlDownloadToFile, %langyFileURL%, %langyFile%
         Sleep, 5000
     }

     if FileExist(langyFile)
     {
         FileRead, Contents, %langyFile%
         if !ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - language definitions")
             {
                langFileDownloaded := 1
                Sleep, 300
             } Else
             {
                langFileDownloaded := 0
                SoundBeep
                FileDelete, %langyFile%
                MsgBox, Incorrect contents for the downloaded file: %langyFile%. File deleted. Automatic keyboard detection is now disabled.
             }
         }
     } else 
     {
         langFileDownloaded := 0
         SoundBeep
         MsgBox, Missing file: %langyFile%. The attempt to download it seems to have failed. Automatic keyboard detection is now disabled.
     }

     if (langFileDownloaded!=1)
     {
        ForceKBD := 0
        AutoDetectKBD := 0
        IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
        IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
        Sleep, 200
        if (ReloadCounter<3)
        {
           ReloadCounter := 1
           IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
           Reload
        }
     }

     if (langFileDownloaded=1) && (ReloadCounter<3)
     {
        ReloadCounter := ReloadCounter+1
        IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
        Reload
     }
}

updateNow() {
     if (A_IsSuspended!=1)
        Gosub, SuspendScript

     if A_IsCompiled
        MsgBox, This is a compiled version. The update procedure yields to nothing. In the future this will be fixed. :-)

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
     mainFileTmp := A_IsCompiled ? "source-keypress-osd.ahk" : "temp-keypress-osd.ahk"
     mainFile := "keypress-osd.ahk"
     mainFileURL := baseURL mainFile
     thisFile := A_ScriptName

     ShowLongMsg("Updating files: 1 / 3. Please wait...")
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
                ShowLongMsg("Updating files: Version history. OK")
                Sleep, 1350
                changelogDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Version history: CORRUPT")
                Sleep, 1350
                changelogCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Version history: FAIL")
         Sleep, 1350
         changelogDownloaded := 0
     }

     ShowLongMsg("Updating files: 2 / 3. Please wait...")
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
                ShowLongMsg("Updating files: Language definitions: OK")
                Sleep, 1350
                langsDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Language definitions: CORRUPT")
                Sleep, 1350
                langsCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Language definitions: FAIL")
         Sleep, 1350
         langsDownloaded := 0
     }

     ShowLongMsg("Updating files: 3 / 3. Please wait...")
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
                ShowLongMsg("Updating files: Main code: OK")
                Sleep, 1350
                ahkDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Main code: CORRUPT")
                Sleep, 1350
                ahkCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Main code: FAIL")
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

verifyNonCrucialFiles() {

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileTmp := "temp-keypress-osd-changelog.txt"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile

     soundFile1 := "sound-firedkey1.wav"
     soundFile2 := "sound-firedkey0.wav"
     soundFile3 := "sound-deadkeys1.wav"
     soundFile4 := "sound-mods1.wav"
     soundFile5 := "sound-clicks1.wav"
     soundFile6 := "sound-caps1.wav"
     soundFile7 := "sound-keys1.wav"
     soundFile8 := "sound-clicks0.wav"
     soundFile9 := "sound-mods0.wav"
     soundFile10 := "sound-deadkeys0.wav"
     soundFile11 := "sound-keys0.wav"
     soundFile12 := "sound-caps0.wav"
     soundFile1url := baseURL soundFile1
     soundFile2url := baseURL soundFile2
     soundFile3url := baseURL soundFile3
     soundFile4url := baseURL soundFile4
     soundFile5url := baseURL soundFile5
     soundFile6url := baseURL soundFile6
     soundFile7url := baseURL soundFile7
     soundFile8url := baseURL soundFile8
     soundFile9url := baseURL soundFile9
     soundFile10url := baseURL soundFile10
     soundFile11url := baseURL soundFile11
     soundFile12url := baseURL soundFile12

     IniRead, verifyNonCrucialFilesRan, %inifile%, TempSettings, verifyNonCrucialFilesRan, 0

     if (verifyNonCrucialFilesRan>3)
     {
        if FileExist(soundFile1) && FileExist(soundFile2) && FileExist(soundFile3) && FileExist(soundFile4) && FileExist(soundFile5) && FileExist(soundFile6) && FileExist(soundFile7) && FileExist(soundFile8) && FileExist(soundFile9) && FileExist(soundFile10) && FileExist(soundFile11) && FileExist(soundFile12)
           missingAudios := 0

        Return
     }

     if !FileExist(soundFile1)
        UrlDownloadToFile, %soundFile1url%, %soundFile1%
     if !FileExist(soundFile2)
        UrlDownloadToFile, %soundFile2url%, %soundFile2%
     if !FileExist(soundFile3)
        UrlDownloadToFile, %soundFile3url%, %soundFile3%
     if !FileExist(soundFile4)
        UrlDownloadToFile, %soundFile4url%, %soundFile4%
     if !FileExist(soundFile5)
        UrlDownloadToFile, %soundFile5url%, %soundFile5%
     if !FileExist(soundFile6)
        UrlDownloadToFile, %soundFile6url%, %soundFile6%
     if !FileExist(soundFile7)
        UrlDownloadToFile, %soundFile7url%, %soundFile7%
     if !FileExist(soundFile8)
        UrlDownloadToFile, %soundFile8url%, %soundFile8%
     if !FileExist(soundFile9)
        UrlDownloadToFile, %soundFile9url%, %soundFile9%
     if !FileExist(soundFile10)
        UrlDownloadToFile, %soundFile10url%, %soundFile10%
     if !FileExist(soundFile11)
        UrlDownloadToFile, %soundFile10url%, %soundFile11%
     if !FileExist(soundFile12)
        UrlDownloadToFile, %soundFile10url%, %soundFile12%

     if !FileExist(historyFile)
        UrlDownloadToFile, %historyFileURL%, %historyFileTmp%

     if FileExist(historyFileTmp)
     {
         FileRead, Contents, %historyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                FileMove, %historyFileTmp%, %historyFile%, 1
             } Else
             {
                FileDelete, historyFileTmp
             }
         }
     } else 
     {
         changelogDownloaded := 0
     }

    static filesz := ["sound-firedkey1.wav", "sound-firedkey0.wav", "sound-clicks1.wav", "sound-clicks0.wav", "sound-caps1.wav", "sound-caps0.wav", "sound-keys1.wav", "sound-keys0.wav", "sound-mods0.wav", "sound-mods1.wav", "sound-deadkeys0.wav", "sound-deadkeys1.wav"]
    Sleep, 500
    for i, audioz in filesz
    {
      Sleep, 100
      if FileExist(audioz)
      {
          FileRead, Contents, %audioz%
          if not ErrorLevel
          {
              StringLeft, Contents, Contents, 50
              if InStr(contents, "RIFF")
              {
                 audioDownloadFailed := 0
              } Else
              {
                 audioDownloadFailed := 1
                 FileDelete, %audioz%
              }
          }
      }
    }

    Sleep, 500

    verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

    if FileExist(soundFile1) && FileExist(soundFile2) && FileExist(soundFile3) && FileExist(soundFile4) && FileExist(soundFile5) && FileExist(soundFile6) && FileExist(soundFile7) && FileExist(soundFile8) && FileExist(soundFile9) && FileExist(soundFile10) && FileExist(soundFile11) && FileExist(soundFile12) && (audioDownloadFailed=0)
       missingAudios := 0
}

ShaveSettings() {
  firstRun := 0
  IniWrite, %firstRun%, %inifile%, SavedSettings, firstRun
  IniWrite, %audioAlerts%, %inifile%, SavedSettings, audioAlerts
  IniWrite, %autoRemDeadKey%, %inifile%, SavedSettings, autoRemDeadKey
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
  IniWrite, %DisplayTimeTypingUser%, %inifile%, SavedSettings, DisplayTimeTypingUser
  IniWrite, %ReturnToTypingUser%, %inifile%, SavedSettings, ReturnToTypingUser
  IniWrite, %enableTypingHistory%, %inifile%, SavedSettings, enableTypingHistory
  IniWrite, %enableAltGrUser%, %inifile%, SavedSettings, enableAltGrUser
  IniWrite, %enterErasesLine%, %inifile%, SavedSettings, enterErasesLine
  IniWrite, %FavorRightoLeft%, %inifile%, SavedSettings, FavorRightoLeft
  IniWrite, %FlashIdleMouse%, %inifile%, SavedSettings, FlashIdleMouse
  IniWrite, %FontName%, %inifile%, SavedSettings, FontName
  IniWrite, %FontSize%, %inifile%, SavedSettings, FontSize
  IniWrite, %ForcedKBDlayout%, %inifile%, SavedSettings, ForcedKBDlayout
  IniWrite, %ForcedKBDlayout1%, %inifile%, SavedSettings, ForcedKBDlayout1
  IniWrite, %ForcedKBDlayout2%, %inifile%, SavedSettings, ForcedKBDlayout2
  IniWrite, %ForceKBD%, %inifile%, SavedSettings, ForceKBD
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
  IniWrite, %beepFiringKeys%, %inifile%, SavedSettings, beepFiringKeys
  IniWrite, %deadKeyBeeper%, %inifile%, SavedSettings, deadKeyBeeper
  IniWrite, %LowVolBeeps%, %inifile%, SavedSettings, LowVolBeeps
  IniWrite, %KeyboardShortcuts%, %inifile%, SavedSettings, KeyboardShortcuts
  IniWrite, %ModBeeper%, %inifile%, SavedSettings, ModBeeper
  IniWrite, %MouseBeeper%, %inifile%, SavedSettings, MouseBeeper
  IniWrite, %MouseHaloAlpha%, %inifile%, SavedSettings, MouseHaloAlpha
  IniWrite, %MouseHaloColor%, %inifile%, SavedSettings, MouseHaloColor
  IniWrite, %MouseHaloRadius%, %inifile%, SavedSettings, MouseHaloRadius
  IniWrite, %MouseIdleAfter%, %inifile%, SavedSettings, MouseIdleAfter
  IniWrite, %MouseIdleRadius%, %inifile%, SavedSettings, MouseIdleRadius
  IniWrite, %MouseVclickAlpha%, %inifile%, SavedSettings, MouseVclickAlpha
  IniWrite, %NeverDisplayOSD%, %inifile%, SavedSettings, NeverDisplayOSD
  IniWrite, %NeverRightoLeft%, %inifile%, SavedSettings, NeverRightoLeft
  IniWrite, %OnlyTypingMode%, %inifile%, SavedSettings, OnlyTypingMode
  IniWrite, %OSDborder%, %inifile%, SavedSettings, OSDborder
  IniWrite, %OSDautosize%, %inifile%, SavedSettings, OSDautosize
  IniWrite, %OSDautosizeFactory%, %inifile%, SavedSettings, OSDautosizeFactory
  IniWrite, %OSDbgrColor%, %inifile%, SavedSettings, OSDbgrColor
  IniWrite, %OSDtextColor%, %inifile%, SavedSettings, OSDtextColor
  IniWrite, %prioritizeBeepers%, %inifile%, SavedSettings, prioritizeBeepers
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
  IniWrite, %StickyKeys%, %inifile%, SavedSettings, StickyKeys
  IniWrite, %version%, %inifile%, SavedSettings, version
  IniWrite, %VisualMouseClicks%, %inifile%, SavedSettings, VisualMouseClicks
}

LoadSettings() {
  firstRun := 0
  defOSDautosizeFactory := round(A_ScreenDPI / 1.18)
  IniRead, audioAlerts, %inifile%, SavedSettings, audioAlerts, %audioAlerts%
  IniRead, autoRemDeadKey, %inifile%, SavedSettings, autoRemDeadKey, %autoRemDeadKey%
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
  IniRead, DisplayTimeTypingUser, %inifile%, SavedSettings, DisplayTimeTypingUser, %DisplayTimeTypingUser%
  IniRead, ReturnToTypingUser, %inifile%, SavedSettings, ReturnToTypingUser, %ReturnToTypingUser%
  IniRead, enableTypingHistory, %inifile%, SavedSettings, enableTypingHistory, %enableTypingHistory%
  IniRead, enableAltGrUser, %inifile%, SavedSettings, enableAltGrUser, %enableAltGrUser%
  IniRead, enterErasesLine, %inifile%, SavedSettings, enterErasesLine, %enterErasesLine%
  IniRead, FavorRightoLeft, %inifile%, SavedSettings, FavorRightoLeft, %FavorRightoLeft%
  IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
  IniRead, FontName, %inifile%, SavedSettings, FontName, %FontName%
  IniRead, FontSize, %inifile%, SavedSettings, FontSize, %FontSize%
  IniRead, ForcedKBDlayout, %inifile%, SavedSettings, ForcedKBDlayout, %ForcedKBDlayout%
  IniRead, ForcedKBDlayout1, %inifile%, SavedSettings, ForcedKBDlayout1, %ForcedKBDlayout1%
  IniRead, ForcedKBDlayout2, %inifile%, SavedSettings, ForcedKBDlayout2, %ForcedKBDlayout2%
  IniRead, ForceKBD, %inifile%, SavedSettings, ForceKBD, %ForceKBD%
  IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
  IniRead, GuiWidth, %inifile%, SavedSettings, GuiWidth, %GuiWidth%
  IniRead, maxGuiWidth, %inifile%, SavedSettings, maxGuiWidth, %maxGuiWidth%
  IniRead, GuiXa, %inifile%, SavedSettings, GuiXa, %GuiXa%
  IniRead, GuiXb, %inifile%, SavedSettings, GuiXb, %GuiXb%
  IniRead, GuiYa, %inifile%, SavedSettings, GuiYa, %GuiYa%
  IniRead, GuiYb, %inifile%, SavedSettings, GuiYb, %GuiYb%
  IniRead, HideAnnoyingKeys, %inifile%, SavedSettings, HideAnnoyingKeys, %HideAnnoyingKeys%
  IniRead, IdleMouseAlpha, %inifile%, SavedSettings, IdleMouseAlpha, %IdleMouseAlpha%
  IniRead, LowVolBeeps, %inifile%, SavedSettings, LowVolBeeps, %LowVolBeeps%
  IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, beepFiringKeys, %inifile%, SavedSettings, beepFiringKeys, %beepFiringKeys%
  IniRead, deadKeyBeeper, %inifile%, SavedSettings, deadKeyBeeper, %deadKeyBeeper%
  IniRead, KeyboardShortcuts, %inifile%, SavedSettings, KeyboardShortcuts, %KeyboardShortcuts%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, MouseHaloAlpha, %inifile%, SavedSettings, MouseHaloAlpha, %MouseHaloAlpha%
  IniRead, MouseHaloColor, %inifile%, SavedSettings, MouseHaloColor, %MouseHaloColor%
  IniRead, MouseHaloRadius, %inifile%, SavedSettings, MouseHaloRadius, %MouseHaloRadius%
  IniRead, MouseIdleAfter, %inifile%, SavedSettings, MouseIdleAfter, %MouseIdleAfter%
  IniRead, MouseIdleRadius, %inifile%, SavedSettings, MouseIdleRadius, %MouseIdleRadius%
  IniRead, MouseVclickAlpha, %inifile%, SavedSettings, MouseVclickAlpha, %MouseVclickAlpha%
  IniRead, NeverDisplayOSD, %inifile%, SavedSettings, NeverDisplayOSD, %NeverDisplayOSD%
  IniRead, NeverRightoLeft, %inifile%, SavedSettings, NeverRightoLeft, %NeverRightoLeft%
  IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%
  IniRead, OSDautosize, %inifile%, SavedSettings, OSDautosize, %OSDautosize%
  IniRead, OSDautosizeFactory, %inifile%, SavedSettings, OSDautosizeFactory, %OSDautosizeFactory%
  IniRead, OSDbgrColor, %inifile%, SavedSettings, OSDbgrColor, %OSDbgrColor%
  IniRead, OSDborder, %inifile%, SavedSettings, OSDborder, %OSDborder%
  IniRead, OSDtextColor, %inifile%, SavedSettings, OSDtextColor, %OSDtextColor%
  IniRead, prioritizeBeepers, %inifile%, SavedSettings, prioritizeBeepers, %prioritizeBeepers%
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
    autoRemDeadKey := (autoRemDeadKey=0 || autoRemDeadKey=1) ? autoRemDeadKey : 0
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
    enableTypingHistory := (enableTypingHistory=0 || enableTypingHistory=1) ? enableTypingHistory : 0
    enableAltGrUser := (enableAltGrUser=0 || enableAltGrUser=1) ? enableAltGrUser : 1
    GUIposition := (GUIposition=0 || GUIposition=1) ? GUIposition : 1
    HideAnnoyingKeys := (HideAnnoyingKeys=0 || HideAnnoyingKeys=1) ? HideAnnoyingKeys : 1
    JumpHover := (JumpHover=0 || JumpHover=1) ? JumpHover : 0
    LowVolBeeps := (LowVolBeeps=0 || LowVolBeeps=1) ? LowVolBeeps : 1
    KeyBeeper := (KeyBeeper=0 || KeyBeeper=1) ? KeyBeeper : 0
    beepFiringKeys := (beepFiringKeys=0 || beepFiringKeys=1) ? beepFiringKeys : 0
    deadKeyBeeper := (deadKeyBeeper=0 || deadKeyBeeper=1) ? deadKeyBeeper : 1
    KeyboardShortcuts := (KeyboardShortcuts=0 || KeyboardShortcuts=1) ? KeyboardShortcuts : 1
    ModBeeper := (ModBeeper=0 || ModBeeper=1) ? ModBeeper : 0
    MouseBeeper := (MouseBeeper=0 || MouseBeeper=1) ? MouseBeeper : 0
    NeverDisplayOSD := (NeverDisplayOSD=0 || NeverDisplayOSD=1) ? NeverDisplayOSD : 0
    NeverRightoLeft := (NeverRightoLeft=0 || NeverRightoLeft=1) ? NeverRightoLeft : 0
    OSDautosize := (OSDautosize=0 || OSDautosize=1) ? OSDautosize : 1
    OSDborder := (OSDborder=0 || OSDborder=1) ? OSDborder : 0
    prioritizeBeepers := (prioritizeBeepers=0 || prioritizeBeepers=1) ? prioritizeBeepers : 0
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

    if (ShowSingleKey=0)
       DisableTypingMode := 1

    if (DisableTypingMode=1)
       OnlyTypingMode := 0

    if (ForceKBD=1)
       AutoDetectKBD := 1

    if (ForceKBD=1) || (AutoDetectKBD=0)
       ConstantAutoDetect := 0

; verify if numeric values, otherwise, defaults
  if ClickScaleUser is not digit
     ClickScaleUser := 10

  if DisplayTimeUser is not digit
     DisplayTimeUser := 3

  if DisplayTimeTypingUser is not digit
     DisplayTimeTypingUser := 10

  if ReturnToTypingUser is not digit
     ReturnToTypingUser := 15

  if FontSize is not digit
     FontSize := 20

  if GuiWidth is not digit
     GuiWidth := 350

  if maxGuiWidth is not digit
     maxGuiWidth := 500

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
    DisplayTimeTypingUser := (DisplayTimeTypingUser < 3) ? 3 : round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser < DisplayTimeTypingUser) ? DisplayTimeTypingUser+1 : round(ReturnToTypingUser)
    FontSize := (FontSize < 6) ? 7 : round(FontSize)
    GuiWidth := (GuiWidth < 50) ? 52 : round(GuiWidth)
    GuiWidth := (GuiWidth < FontSize) ? round(FontSize*3.5) : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth < 50) ? 52 : round(maxGuiWidth)
    maxGuiWidth := (maxGuiWidth < FontSize) ? round(FontSize*3.5) : round(maxGuiWidth)
    GuiXa := (GuiXa < -9999) ? -9998 : round(GuiXa)
    GuiXb := (GuiXb < -9999) ? -9998 : round(GuiXb)
    GuiYa := (GuiYa < -9999) ? -9998 : round(GuiYa)
    GuiYb := (GuiYb < -9999) ? -9998 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha < 10) ? 11 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha < 10) ? 11 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius < 5) ? 6 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter < 3) ? 3 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius < 5) ? 6 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha < 10) ? 11 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory < 10) ? 11 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay < 100) ? 101 : round(ShowPrevKeyDelay)

    if (GuiXa<0 || GuiXb<0 || GuiYa<0 || GuiYb<0)
       NeverRightoLeft := 0

; verify maximum numeric values
    ClickScaleUser := (ClickScaleUser > 91) ? 90 : round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser > 99) ? 98 : round(DisplayTimeUser)
    DisplayTimeTypingUser := (DisplayTimeTypingUser > 99) ? 98 : round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser > 99) ? 99 : round(ReturnToTypingUser)
    FontSize := (FontSize > 300) ? 290 : round(FontSize)
    GuiWidth := (GuiWidth > 999) ? 999 : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth > 999) ? 999 : round(maxGuiWidth)
    GuiXa := (GuiXa > 9999) ? 9998 : round(GuiXa)
    GuiXb := (GuiXb > 9999) ? 9998 : round(GuiXb)
    GuiYa := (GuiYa > 9999) ? 9998 : round(GuiYa)
    GuiYb := (GuiYb > 9999) ? 9998 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha > 240) ? 240 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha > 240) ? 240 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius > 999) ? 900 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter > 999) ? 900 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius > 999) ? 900 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha > 240) ? 240 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory > 402) ? 401 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay > 999) ? 900 : round(ShowPrevKeyDelay)

; verify HEX values

   if (forcedKBDlayout1 ~= "[^[:xdigit:]]") || (strLen(forcedKBDlayout1) < 8) || (strLen(forcedKBDlayout1) > 8)
      ForcedKBDlayout1 := "00010418"

   if (forcedKBDlayout2 ~= "[^[:xdigit:]]") || (strLen(forcedKBDlayout2) < 8) || (strLen(forcedKBDlayout12) > 8)
      ForcedKBDlayout2 := "0000040c"

   if (OSDbgrColor ~= "[^[:xdigit:]]") || (strLen(OSDbgrColor) < 6) || (strLen(OSDbgrColor) > 6)
      OSDbgrColor := "111111"

   if (MouseHaloColor ~= "[^[:xdigit:]]") || (strLen(MouseHaloColor) < 6) || (strLen(MouseHaloColor) > 6)
      MouseHaloColor := "eedd00"
;
   if (OSDtextColor ~= "[^[:xdigit:]]") || (strLen(OSDtextColor) < 6) || (strLen(OSDtextColor) > 6)
      OSDtextColor := "ffffff"

   FontName := StrLen(FontName)>2 ? FontName : "Arial"

}

dummy() {
    MsgBox, This feature is not yet available. It might be implemented soon. Thank you.
}

; !+SPACE::  Winset, Alwaysontop, , A
