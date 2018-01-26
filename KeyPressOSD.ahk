; KeypressOSD.ahk - main file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.
;
; Script written for AHK_H v1.1.27 Unicode.
;--------------------------------------------------------------------------------------------------------------------------
;
; Keyboard language definitions file:
;   keypress-osd-languages.ini
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-languages.ini
;   File required for AutoDetectKBD = 1, to detect keyboard layouts.
;   File must be placed in the keypress-files folder by the script.
;   It adds support for around 110 keyboard layouts covering about 55 languages.;
;
; Change log file:
;   keypress-osd-changelog.txt
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-changelog.txt
;
;----------------------------------------------------------------------------

; Initialization

 #SingleInstance Force
 #NoEnv
 #MaxHotkeysPerInterval 500
 #MaxThreads 255
 #MaxThreadsPerHotkey 255
 #MaxThreadsBuffer On
 SetTitleMatchMode, 2
 SetBatchLines, -1
 ListLines, Off
 SetWorkingDir, %A_ScriptDir%
 Critical, on

; Default Settings / Customize:

 Global IgnoreAdditionalKeys  := 0
 , IgnorekeysList        := "a.b.c"
 , DoNotBindDeadKeys     := 0
 , DoNotBindAltGrDeadKeys := 0
 , AutoDetectKBD         := 1     ; at start, detect keyboard layout
 , ConstantAutoDetect    := 1     ; continuously check if the keyboard layout changed; if AutoDetectKBD=0, this is ignored
 , SilentDetection       := 0     ; do not display information about language switching
 , audioAlerts           := 0     ; generate beeps when key bindings fail
 , ForceKBD              := 0     ; force detection of a specific keyboard layout ; AutoDetectKBD must be set to 1
 , ForcedKBDlayout1      := "00010418" ; enter here the HEX code of your desired keyboards
 , ForcedKBDlayout2      := "0000040c"
 , ForcedKBDlayout       := 0
 , enableAltGr           := 1
 , AltHook2keysUser      := 1
 , typingDelaysScaleUser := 7
 
 , lola                  := "│"
 , lola2                 := "║"
 , DisableTypingMode     := 0     ; do not echo what you write
 , OnlyTypingMode        := 0
 , alternateTypingMode   := 1
 , enableTypingHistory   := 0
 , enterErasesLine       := 1
 , pgUDasHE              := 0    ; page up/down behaves like home/end
 , UpDownAsHE            := 0    ; up/down behaves like home/End
 , UpDownAsLR            := 0    ; up/down behaves like Left/Right
 , ShowDeadKeys          := 0
 , ShowSingleKey         := 1     ; show only key combinations ; it disables typing mode
 , HideAnnoyingKeys      := 1     ; Left click and PrintScreen can easily get in the way.
 , ShowMouseButton       := 1     ; in the OSD
 , ShowSingleModifierKey := 1     ; make it display Ctrl, Alt, Shift when pressed alone
 , DifferModifiers       := 0     ; differentiate between left and right modifiers
 , ShowPrevKey           := 1     ; show previously pressed key, if pressed quickly in succession
 , ShowPrevKeyDelay      := 300
 , ShowKeyCount          := 1     ; count how many times a key is pressed
 , ShowKeyCountFired     := 0     ; show only key presses (0) or catch key fires as well (1)
 , NeverDisplayOSD       := 0
 , ReturnToTypingUser    := 20    ; in seconds
 , DisplayTimeTypingUser := 10    ; in seconds
 , synchronizeMode       := 0
 , alternativeJumps      := 0
 , sendJumpKeys          := 0
 , MediateNavKeys        := 0
 , pasteOSDcontent       := 1
 , pasteOnClick          := 1
 , sendKeysRealTime      := 0
 , CaretHaloAlpha        := 130   ; from 0 to 255
 , CaretHaloColor        := "bbaa99"  ; HEX format also accepted
 , CaretHaloRadius       := 70
 , hostCaretHighlight    := 0
 , DisplayTimeUser       := 3     ; in seconds
 , DragOSDmode           := 0
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
 , OSDalignment1          := 1     ; 1 = left ; 2 = center ; 3 = right
 , OSDalignment2          := 3     ; 1 = left ; 2 = center ; 3 = right
 , OSDbgrColor           := "131209"
 , OSDtextColor          := "FFFEFA"
 , CapsColorHighlight    := "88AAff"
 , TypingColorHighlight  := "12E217"
 , OSDautosize           := 1     ; make adjustments to the growth factors to match your font size
 , OSDautosizeFactory    := Round(A_ScreenDPI / 1.1)
 
 , CapslockBeeper        := 1     ; only when the key is released
 , ToggleKeysBeeper      := 1
 , KeyBeeper             := 0     ; only when the key is released
 , deadKeyBeeper         := 1
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and VisualMouseClicks are disabled, mouse click beeps will never occur
 , TypingBeepers         := 0
 , DTMFbeepers           := 0
 , beepFiringKeys        := 0
 , LowVolBeeps           := 1
 , SilentMode            := 0
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall

 , KeyboardShortcuts     := 1     ; system-wide shortcuts
 , ClipMonitor           := 1     ; show clipboard changes
 , ShiftDisableCaps      := 1

 , VisualMouseClicks     := 0     ; shows visual indicators for different mouse clicks
 , MouseClickRipples     := 0
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , ClickScaleUser        := 10
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , MouseHaloRadius       := 85
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , MouseIdleRadius       := 130
 , MouseIdleAfter        := 10    ; in seconds
 , IdleMouseAlpha        := 70    ; from 0 to 255
 , MouseRippleMaxSize    := 155
 , MouseRippleThickness  := 10

 , KBDaltTypeMode        := "^CapsLock"
 , KBDpasteOSDcnt1       := "^+Insert"
 , KBDpasteOSDcnt2       := "^!Insert"
 , KBDsynchApp1          := "#Insert"
 , KBDsynchApp2          := "#!Insert"
 , KBDTglCap2Text        := "!Pause"
 , KBDsuspend            := "+Pause"
 , KBDTglForceLang       := "!+^F7"
 , KBDTglNeverOSD        := "!+^F8"
 , KBDTglPosition        := "!+^F9"
 , KBDidLangNow          := "!+^F11"
 , KBDReload             := "!+^F12"

 , UseINIfile            := 1
 , IniFile               := "keypress-osd.ini"
 , version               := "4.16"
 , releaseDate := "2018 / 01 / 26"

; Initialization variables. Altering these may lead to undesired results.

    checkIfRunning()
    Sleep, 50
    IniRead, firstRun, %IniFile%, SavedSettings, firstRun, 1
    if (firstRun=0) && (UseINIfile=1)
    {
        LoadSettings()
    } else if (UseINIfile=1)
    {
        CheckSettings()
        ShaveSettings()
    }

Global typed := "" ; hack used to determine if user is writing
 , OSDvisible := 0
 , ClickScale := ClickScaleUser/10
 , DisplayTime := DisplayTimeUser*1000
 , DisplayTimeTyping := DisplayTimeTypingUser*1000
 , ReturnToTypingDelay := ReturnToTypingUser*1000
 , prefixed := 0                      ; hack used to determine if last keypress had a modifier
 , Capture2Text := 0
 , tickcount_start2 := A_TickCount    ; timer to keep track of OSD redraws
 , tickcount_start := 0               ; timer to count repeated key presses
 , keyCount := 0
 , modifiers_temp := 0
 , OSDalignment := (GUIposition=1) ? OSDalignment2 : OSDalignment1
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , GuiHeight := 50                    ; a default, later overriden
 , maxAllowedGuiWidth := A_ScreenWidth
 , prefOpen := 0
 , externalKeyStrokeReceived := ""    ; for alternative hooks
 , visibleTextField := ""
 , text_width := 60
 , CaretPos := "1"
 , SecondaryTypingMode := 0
 , maxTextChars := "4"
 , lastTypedSince := 0
 , editingField := "3"
 , editField1 := " "
 , editField2 := " "
 , editField3 := " "
 , backTypeCtrl := ""
 , backTypdUndo := ""
 , CurrentKBD := "Default: English US"
 , loadedLangz := A_IsCompiled ? 1 : 0
 , kbLayoutRaw := 0
 , DeadKeys := 0
 , DKnotShifted_list := ""
 , DKshift_list := ""
 , DKaltGR_list := ""
 , AlternativeHook2keys := (AltHook2keysUser=0) ? 0 : 1
 , typingDelaysScale := typingDelaysScaleUser / 10
 , OnMSGchar := ""
 , OnMSGdeadChar := ""
 , Window2Activate := " "
 , SCnames2 := "▪"
 , FontList := []
 , missingAudios := 1
 , globalPrefix := ""
 , deadKeyPressed := "9950"
 , TrueRmDkSymbol := ""
 , showPreview := 0
 , previewWindowText := "Preview window..."
 , MainModsList := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
 , hOSD, OSDhandles, nowDraggable
 , cclvo := "-E0x200 +Border -Hdr -Multi +ReadOnly Report -Hidden AltSubmit gsetColors"

   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
   ScriptelSuspendel := 0
   IniWrite, %ScriptelSuspendel%, %IniFile%, TempSettings, ScriptelSuspendel
   IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen

CreateOSDGUI()
verifyNonCrucialFiles()
Sleep, 250

if ((VisualMouseClicks=1) || (FlashIdleMouse=1) || (ShowMouseHalo=1) || (hostCaretHighlight=1))
   Global mouseFonctiones := ahkThread(" #Include *i keypress-files\keypress-mouse-functions.ahk ")

if (MouseClickRipples=1)
   Global mouseRipplesThread := ahkThread(" #Include *i keypress-files\keypress-mouse-ripples-functions.ahk ")

Global beeperzDefunctions := ahkThread(" #Include *i keypress-files\keypress-beeperz-functions.ahk ")

CreateGlobalShortcuts()
CreateHotkey()
CheckInstalledLangs()
InitializeTray()
if (ClipMonitor=1)
   OnClipboardChange("ClipChanged")

hCursM := DllCall("LoadCursor", "Ptr", NULL, "Int", 32646, "Ptr")  ; IDC_SIZEALL
hCursH := DllCall("LoadCursor", "Ptr", NULL, "Int", 32649, "Ptr")  ; IDC_HAND
OnMessage(0x200, "MouseMove")    ; WM_MOUSEMOVE

if (AlternativeHook2keys=1) && (DisableTypingMode=0) && (ShowSingleKey=1)
{
   Global keyStrokesThread := ahkThread(" #Include *i keypress-files\keypress-keystrokes-helper.ahk")
   OnMessage(0x4a, "KeyStrokeReceiver")  ; 0x4a is WM_COPYDATA
}
Return

;================================================================
; The script
;================================================================
TypedLetter(key) {
; Sleep, 50 ; megatest

   if (ShowSingleKey=0 || DisableTypingMode=1 || NeverDisplayOSD=1)
   {
      typed := ""
      Return
   }

   if (SecondaryTypingMode=0)
   {
      if InStr(A_ThisHotkey, "+")
         shiftPressed := 1

      if InStr(A_ThisHotkey, "^!") && (enableAltGr=1) || InStr(A_ThisHotkey, "<^>") && (enableAltGr=1)
         AltGrPressed := 1

      if (AlternativeHook2keys=1) && (DeadKeys=0)
         Sleep, 30

      vk := "0x0" SubStr(key, InStr(key, "vk", 0, 0)+2)
      sc := "0x0" GetKeySc("vk" vk)
      key := toUnicodeExtended(vk, sc, shiftPressed, AltGrPressed)

      if (AlternativeHook2keys=1) && TrueRmDkSymbol && (A_TickCount-deadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DeadKeys=0) && (A_TickCount-deadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DoNotBindDeadKeys=1) && (A_TickCount - lastTypedSince > 200)
      {
         Sleep, 30
         if (externalKeyStrokeReceived=TrueRmDkSymbol) && (DoNotBindDeadKeys=0)
            externalKeyStrokeReceived .= key
         typed := externalKeyStrokeReceived && (AlternativeHook2keys=1) ? InsertChar2caret(externalKeyStrokeReceived) : InsertChar2caret(key)
         externalKeyStrokeReceived := ""
         if (DeadKeys=0) && (A_TickCount-deadKeyPressed > 1000)
            Global deadKeyPressed := 15000
      } else
      {
         typed := InsertChar2caret(key)
      }
      externalKeyStrokeReceived := ""
      TrueRmDkSymbol := ""
      Global lastTypedSince := A_TickCount
   }
   return typed
}

replaceSelection(copy2clip:=0,EraseSelection:=1) {
  backTypdUndo := typed
  StringGetPos, CaretPos, typed, %lola%
  StringGetPos, CaretPos2, typed, %lola2%
  brr := RegExMatch(typed, "i)((│|║).*?=?(│|║))", loca)
  if (EraseSelection=1)
  {
     StringReplace, typed, typed, %loca%, %lola%
     StringReplace, typed, typed, %lola2%
     StringReplace, typed, typed, %lola%
     CaretBoss := (CaretPos2 > CaretPos) ? CaretPos+1 : CaretPos2+1
     typed := ST_Insert(lola, typed, CaretBoss)
  }

  if (copy2clip=1) && (SecondaryTypingMode=1)
  {
     StringReplace, loca, loca, %lola2%
     StringReplace, loca, loca, %lola%
     Clipboard := loca
  }
}

InsertChar2caret(char) {
; Sleep, 150 ; megatest
  if (NeverDisplayOSD=1)
     Return
  if (st_count(typed, lola2)>0)
     replaceSelection()

  if (CaretPos = 2000)
     CaretPos := 1

  if (CaretPos = 3000)
     CaretPos := StrLen(typed)+1

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%
  CaretPos := CaretPos+1
  typed := ST_Insert(char lola, typed, CaretPos)
  if (A_TickCount-deadKeyPressed>150)
      CalcVisibleText()
  else
      SetTimer, CalcVisibleTextFieldDummy, 200, 50
  Return typed
}

CalcVisibleTextFieldDummy() {
    CalcVisibleText()
    if (StrLen(visibleTextField)>0)
       ShowHotkey(visibleTextField)
    SetTimer, HideGUI, % -DisplayTimeTyping
    SetTimer,, off
}

CalcVisibleText() {
; Sleep, 30 ; megatest

   visibleTextField := typed
   maxTextLimit := 0
   text_width0 := GetTextExtentPoint(typed, FontName, FontSize) / (OSDautosizeFactory/100)
   if (text_width0 > maxAllowedGuiWidth) && typed
      maxTextLimit := 1

   if (maxTextLimit>0)
   {
      cola := lola
      maxA_Index := (maxTextChars<6) ? StrLen(typed) : Round(maxTextChars*1.3)

      if (st_count(typed, lola2)>0)
      {
         StringGetPos, RealCaretPos, typed, %lola%
         StringGetPos, SelCaretPos, typed, %lola2%
         addSelMarker := 1
         addSelMarkerLocation := (SelCaretPos < RealCaretPos) ? 1 : 2
         cola := lola2
      }
      LoopJumpStart := (maxTextChars > StrLen(typed)-5) ? 1 : Round(maxTextChars/2)

      Loop
      {
        StringGetPos, vCaretPos, typed, %cola%
        Stringmid, NEWvisibleTextField, typed, vCaretPos+1+Round(maxTextChars/3.5), LoopJumpStart+A_Index, L
        text_width2 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize) / (OSDautosizeFactory/100)
        if (text_width2 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
           allGood := 1
      }
      Until (allGood=1) || (A_Index=Round(maxA_Index)) || (A_Index>=5000)

      if (allGood!=1)
      {
          Loop
          {
            Stringmid, NEWvisibleTextField, typed, vCaretPos+A_Index, , L
            text_width3 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize) / (OSDautosizeFactory/100)
            if (text_width3 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
               stopLoop2 := 1
          }
          Until (stopLoop2 = 1) || (A_Index=Round(maxA_Index/1.25)) || (A_Index>=5000)
      }

      if (addSelMarker=1)
         NEWvisibleTextField := (addSelMarkerLocation=2) ? "├ " NEWvisibleTextField : NEWvisibleTextField " ┤" 

      visibleTextField := NEWvisibleTextField
      maxTextChars := maxTextChars<3 ? maxTextChars : StrLen(visibleTextField)+3
   }
}


caretMover(direction) {
  StringGetPos, CaretPos, typed, %lola%
  direction2check := (direction=2) ? CaretPos+3 : CaretPos
  testChar := SubStr(typed, direction2check, 1)
  if RegExMatch(testChar, "[\p{Mn}\p{Cc}\p{Cf}\p{Co}]")
     mustRepeat := 1

  if (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos2, typed, %lola2%
     if ((CaretPos2 > CaretPos) && (direction=2)) || ((CaretPos2 < CaretPos) && (direction=0))
     {
        CaretPos := CaretPos2
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     } else
     {
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     }
  }
  StringReplace, typed, typed, %lola%
  StringReplace, typed, typed, %lola2%
  CaretPos := CaretPos + direction
  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)

  if (InStr(typed, "▫" lola))
  {
     StringGetPos, CaretPos, typed, %lola%
     StringReplace, typed, typed, %lola%
     CaretPos := CaretPos + direction
     typed := ST_Insert(lola, typed, CaretPos)
  }
  CalcVisibleText()
  if (mustRepeat=1)
  {
     if (CaretPos=1) && (direction=0)
        Return
     caretMover(direction)
  }
}

caretMoverSel(direction) {
  cola := lola2
  cola2 := lola
  StringGetPos, CaretPos, typed, %cola2%
  if (st_count(typed, cola)>0)
  {
     StringGetPos, CaretPos, typed, %cola%
     direction2check := (direction=1) ? CaretPos+3 : CaretPos
     testChar := SubStr(typed, direction2check, 1)
     if RegExMatch(testChar, "[\p{Mn}\p{Cc}\p{Cf}\p{Co}]")
        mustRepeat := 1
  } else
  {
     StringGetPos, CaretPos, typed, %cola2%
     CaretPos := (direction=1) ? CaretPos + 1 : CaretPos
  }

  StringReplace, typed, typed, %cola%
  CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(cola, typed, CaretPos)
  if (InStr(typed, "▫" cola))
  {
     StringGetPos, CaretPos, typed, %cola%
     StringReplace, typed, typed, %cola%
     CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
     typed := ST_Insert(cola, typed, CaretPos)
  }

  if (InStr(typed, cola cola2) || InStr(typed, cola2 cola))
     StringReplace, typed, typed, %cola%

  CalcVisibleText()
  if (mustRepeat=1)
     caretMoverSel(direction)
}

caretJumpMain(direction) {
  if (CaretPos<=1)
     CaretPos := 1.5

  theRegEx := "i)((?=[[:space:]│!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~])[\p{L}\p{M}\p{Z}\p{N}\p{P}\p{S}]\b(?=\S)|\s(?!\s)(?=\p{L}))"
  alternativeRegEx := "i)(((\p{L}|\p{N}|\w)(?=\S))([\p{M}\p{Z}!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~\p{S}\p{C}])|\s+[[:punct:]])"
  if (direction=1)
  {
     CaretuPos := RegExMatch(typed, theRegEx, , CaretPos+1) + 1
     if (alternativeJumps=1)
     {
        CaretuPosa := RegExMatch(typed, alternativeRegEx, , CaretPos+1) + 1
        if (CaretuPosa>CaretPos)
           CaretuPos := CaretuPosa < CaretuPos ? CaretuPosa : CaretuPos
     }
     CaretPos := CaretuPos < CaretPos ? StrLen(typed)+1 : CaretuPos
  }

  if (direction=0)
  {
     typed := ST_Insert(" z.", typed, StrLen(typed)+1)
     if (CaretPos<=1)
        skipLoop := 1

     Loop
     {
       CaretuPos := CaretPos - A_Index
       CaretelPos := RegExMatch(typed, theRegEx, , CaretuPos)+1
       if (alternativeJumps=1)
       {
          CaretelPosa := RegExMatch(typed, alternativeRegEx, , CaretuPos)+1
          CaretelPos := CaretelPosa < CaretelPos ? CaretelPosa : CaretelPos
       }
       CaretelPos := CaretelPos < CaretuPos ? StrLen(typed)+1 : CaretelPos
       if (CaretelPos < CaretPos+1)
       {
          CaretPos := CaretelPos > CaretPos ? 1 : CaretelPos
          allGood := 1
       }
       if (CaretelPos < CaretuPos+1) || (A_Index>CaretPos+5)
          skipLoop := 1
     } Until (skipLoop=1 || allGood=1 || A_Index=300)

     StringTrimRight, typed, typed, 3
  }

  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1
}

caretJumper(direction) {
  if (st_count(typed, lola2)>0)
     caretMover(direction*2)

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%
  caretJumpMain(direction)
  typed := ST_Insert(lola, typed, CaretPos)
}

caretJumpSelector(direction) {
  if (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos, typed, %lola2%
     StringReplace, typed, typed, %lola2%
  } else
  {
     StringGetPos, CaretPos, typed, %lola%
     CaretPos := (direction=1) ? CaretPos+1 : CaretPos
  }

  caretJumpMain(direction)
  typed := ST_Insert(lola2, typed, CaretPos)
  if (InStr(typed, lola lola2) || InStr(typed, lola2 lola))
     StringReplace, typed, typed, %lola2%

}


toUnicodeExtended(uVirtKey,uScanCode,shiftPressed:=0,AltGrPressed:=0,wFlags:=0) {
; Many thanks to Helgef for helping me with this function:
; https://autohotkey.com/boards/viewtopic.php?f=5&t=41065&p=187582#p187582

  nsa := DllCall("MapVirtualKey", "UInt", uVirtKey, "UInt", 2)
  if (nsa<=0) && (DeadKeys=0) && (SecondaryTypingMode=1)
      Return

  if (nsa<=0) && (DeadKeys=0) && (SecondaryTypingMode=0)
  {
     Global deadKeyPressed := A_TickCount
     if (deadKeyBeeper = 1) && (ShowSingleKey = 1)
        beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]

     RmDkSymbol := "▪"
     StringReplace, visibleTextField, visibleTextField, %lola%, %RmDkSymbol%
     ShowHotkey(visibleTextField)
     if (AlternativeHook2keys=0)
        Sleep, % 250 * typingDelaysScale

     if (StrLen(typed)<2)
     {
        ShowHotkey("[dead key]")
        Sleep, 400
     }
     Return
  }

  thread := DllCall("GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0)
  hkl := DllCall("GetKeyboardLayout", "UInt", thread, "Ptr")
  cchBuff := 3            ; number of characters the buffer can hold
  VarSetCapacity(lpKeyState,256,0)
  VarSetCapacity(pwszBuff, (cchBuff+1) * (A_IsUnicode ? 2 : 1), 0)  ; this will hold cchBuff (3) characters and the null terminator on both unicode and ansi builds.

  if (shiftPressed=1)
     NumPut(128*shiftPressed, lpKeyState, 0x10, "UChar")

  if (AltGrPressed=1)
  {
     NumPut(128*AltGrPressed, lpKeyState, 0x12, "UChar")
     NumPut(128*AltGrPressed, lpKeyState, 0x11, "UChar")
  }

  NumPut(GetKeyState("CapsLock", "T") , &lpKeyState+0, 0x14, "UChar")
  n := DllCall("ToUnicodeEx", "UInt", uVirtKey, "UInt", uScanCode, "UPtr", &lpKeyState, "Ptr", &pwszBuff, "Int", cchBuff, "UInt", wFlags, "Ptr", hkl)
  n := DllCall("ToUnicodeEx", "UInt", uVirtKey, "UInt", uScanCode, "UPtr", &lpKeyState, "Ptr", &pwszBuff, "Int", cchBuff, "UInt", wFlags, "Ptr", hkl)
  Return StrGet(&pwszBuff, n, "utf-16")
}

OnMousePressed() {
    Thread, Priority, -20
    Critical, off
    if (OnlyTypingMode=1 || NeverDisplayOSD=1 )
       Return

    if (OSDvisible=1)
       tickcount_start := A_TickCount-500

    try {
        key := GetKeyStr()
        if (ShowMouseButton=1)
        {
            typed := (OnlyTypingMode=1) ? typed : "" ; concerning TypedLetter(" ") - it resets the content of the OSD
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        }
    }
}

OnRLeftPressed() {
    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Left|Right))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            if (!(CaretPos=StrLen(typed)) && (CaretPos!=1))
               keycount := 1

            if ((key ~= "i)^(Left)"))
            {
               caretMover(0)
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, , {Left}, %Window2Activate%
            }

            if ((key ~= "i)^(Right)"))
            {
               caretMover(2)
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, , {Right}, %Window2Activate%
            }


            if ((key ~= "i)^(.?Shift \+ Left)"))
            {
               caretMoverSel(-1)
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,+{Left}, %Window2Activate%
            }

            if ((key ~= "i)^(.?Shift \+ Right)"))
            {
               caretMoverSel(1)
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,+{Right}, %Window2Activate%
            }

            Global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           if (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
}

OnUpDownPressed() {
    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Up|Down))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            if (!(CaretPos=StrLen(typed)) && (CaretPos!=1))
               keycount := (UpDownAsHE=0) && (UpDownAsLR=0) ? keycount : 1

            if (UpDownAsHE=0) && (UpDownAsLR=0) && !InStr(key, "shift")
            {
               StringReplace, typed, typed, %lola2%
               CalcVisibleText()
            }

            if (UpDownAsHE=1) && (UpDownAsLR=0)
            {
                StringGetPos, CaretPos3, typed, %lola%
                StringGetPos, CaretPos4, typed, %lola2%
                if (key ~= "i)^(Up)") && (CaretPos3!=0) || (key ~= "i)^(Up)") && (CaretPos4!=-1)
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
                }

                if (key ~= "i)^(Down)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := StrLen(typed)+1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := StrLen(typed)+2
                }

                if (key ~= "i)^(.?Shift \+ Down)")
                   SelectHomeEnd(1)

                if (key ~= "i)^(.?Shift \+ Up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
            }

            if (UpDownAsLR=1) && (UpDownAsHE=0)
            {
                if ((key ~= "i)^(Up)"))
                   caretMover(0)

                if ((key ~= "i)^(Down)"))
                   caretMover(2)

                if ((key ~= "i)^(.?Shift \+ Up)"))
                   caretMoverSel(-1)

                if ((key ~= "i)^(.?Shift \+ Down)"))
                   caretMoverSel(1)

            }
            Global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
}

OnHomeEndPressed() {
    StringGetPos, exKaretPos, typed, %lola%
    StringGetPos, exKaretPosSelly, typed, %lola2%
    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>0 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Home|End))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            if (key ~= "i)^(.?Shift \+ End)") || InStr(A_ThisHotkey, "~+End")
            {
               SelectHomeEnd(1)
               skipRest := 1
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,+{End}, %Window2Activate%
            }

            if (key ~= "i)^(.?Shift \+ Home)") || InStr(A_ThisHotkey, "~+Home")
            {
               SelectHomeEnd(0)
               if StrLen(typed)<3
                  selectAllText()
               skipRest := 1
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,+{Home}, %Window2Activate%
            }

            if (key ~= "i)^(Home)") && (skipRest!=1)
            {
               if (CaretPos3!=0) || (CaretPos4!=-1)
               {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
               }
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,{Home}, %Window2Activate%
            }

            if (key ~= "i)^(End)") && (skipRest!=1)
            {
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               CaretPos := StrLen(typed)+1
               typed := ST_Insert(lola, typed, CaretPos)
               maxTextChars := StrLen(typed)+2
               if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                  ControlSend, ,{End}, %Window2Activate%
            }
            Global lastTypedSince := A_TickCount
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && OnlyTypingMode=0 )
        {
           if (OnlyTypingMode!=1)
           {
              if (keyCount>10)
                 Global lastTypedSince := A_TickCount - ReturnToTypingDelay
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }

    if (MediateNavKeys=1) && (SecondaryTypingMode=0)
    {
      StringGetPos, exKaretPos2, typed, %lola%
      StringGetPos, exKaretPosSelly2, typed, %lola2%
      times2pressKey := (exKaretPos2 > exKaretPos) ? (exKaretPos2 - exKaretPos) : (exKaretPos - exKaretPos2)
      managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      if (exKaretPosSelly<0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPos2) ? (exKaretPosSelly2 - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly2 - 1)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      if (exKaretPosSelly2<0 && exKaretPosSelly>=0)
      {
         if (A_ThisHotkey="End")
            times2pressKey := (exKaretPosSelly > exKaretPos) ? (exKaretPos2 - exKaretPosSelly + 2) : (exKaretPos2 - exKaretPos + 2)
         if (A_ThisHotkey="Home")
            times2pressKey := (exKaretPosSelly > exKaretPos) ? (exKaretPos - exKaretPos2 + 1) : (exKaretPosSelly - exKaretPos2 + 1)
         managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      }
      if (exKaretPosSelly>=0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPosSelly) ? (exKaretPosSelly2 - exKaretPosSelly) : (exKaretPosSelly - exKaretPosSelly2)
         if (key ~= "i)^(.?Shift \+ Home)") && (exKaretPosSelly>exKaretPos) || (key ~= "i)^(.?Shift \+ End)") && (exKaretPosSelly<exKaretPos)
         times2pressKey := times2pressKey - 1
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }

      if (managedMode=1)
      {
         if (A_ThisHotkey="Home")
            SendInput, {Left %times2pressKey% }

         if (A_ThisHotkey="End")
            SendInput, {Right %times2pressKey% }

         if (A_ThisHotkey="+Home") || (key ~= "i)^(.?Shift \+ Home)")
            SendInput, {Shift Down}{Left %times2pressKey% }{Shift up}

         if (A_ThisHotkey="+End") || (key ~= "i)^(.?Shift \+ End)")
            SendInput, {Shift Down}{Right %times2pressKey% }{Shift up}
      }
    }

    if (MediateNavKeys=1) && (managedMode!=1) ; && (ShowSingleKey=1) || (MediateNavKeys=1) && (ShowSingleKey=0)
    {
       if (A_ThisHotkey="Home")
          SendInput, {Home}
       if (A_ThisHotkey="End")
          SendInput, {End}
       if (A_ThisHotkey="+Home") || (key ~= "i)^(.?Shift \+ Home)")
          SendInput, +{Home}
       if (A_ThisHotkey="+End") || (key ~= "i)^(.?Shift \+ End)")
          SendInput, +{End}
    }
}

SelectHomeEnd(direction) {
  StringGetPos, CaretPos3, typed, %lola%
  if ((CaretPos3 >= StrLen(typed)-1) && (direction=1)) || ((CaretPos3<=1) && (direction=0))
  {
     StringReplace, typed, typed, %lola2%
     Return
  }
  if (typed ~= "i)^(║)") && (direction=0) || (typed ~= "i)(║)$") && (direction=1) || (CaretPos<=1) && (direction!=1) || (CaretPos >= StrLen(typed)) && (direction=1)
     Return

  StringReplace, typed, typed, %lola2%
  CaretPos2 := (direction=0) ? 1 : StrLen(typed)+1
  typed := ST_Insert(lola2, typed, CaretPos2)
  maxTextChars := maxTextChars*2
}

OnPGupDnPressed() {
    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?Page )") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            if (pgUDasHE=1) && (key ~= "i)^(.?Shift \+ )")
            {
                if (key ~= "i)^(.?Shift \+ Page down)")
                   SelectHomeEnd(1)

                if (key ~= "i)^(.?Shift \+ Page up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
                ShowHotkey(visibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }

            if (enableTypingHistory=1)
            {
                if (key ~= "i)^(Page Down)") && (OSDvisible=0) && StrLen(typed)<3
                {
                   Global lastTypedSince := A_TickCount - ReturnToTypingDelay
                   if (StrLen(typed)<2)
                      typed := (OnlyTypingMode=1) ? typed : ""
                   ShowHotkey(key)
                   SetTimer, HideGUI, % -DisplayTime
                   Return
                }

                StringReplace, typed, typed, %lola%,, All
                StringReplace, typed, typed, %lola2%,, All

                if (key ~= "i)^(Page Up)")
                {
                   if (editingField=3)
                      backTypeCtrl := typed
                   editingField := (editingField<=1) ? 1 : editingField-1
                   typed := editField%editingField%
                }

                if (key ~= "i)^(Page Down)")
                {
                   if (editingField=3)
                      backTypeCtrl := typed
                   editingField := (editingField>=3) ? 3 : editingField+1
                   typed := (editingField=3) ? backTypeCtrl : editField%editingField%
                }
                StringReplace, typed, typed, %lola%,, All
                StringReplace, typed, typed, %lola2%,, All
                CaretPos := (typed=" ") ? StrLen(typed) : StrLen(typed)+1
                typed := ST_Insert(lola, typed, 0)
            }

            if (enableTypingHistory=0) && (pgUDasHE=1)
            {
                StringGetPos, CaretPos3, typed, %lola%
                StringGetPos, CaretPos4, typed, %lola2%
                if (key ~= "i)^(Page up)") && (CaretPos3!=0) || (key ~= "i)^(Page up)") && (CaretPos4!=-1)
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
                }

                if (key ~= "i)^(Page down)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := StrLen(typed)+1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := StrLen(typed)+2
                }
            }
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || !typed || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10) && (OnlyTypingMode=0)
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           if (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""

        if (StrLen(typed)>1) && (DisableTypingMode=0) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (keyCount<10)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }
}

OnKeyPressed() {
; Sleep, 30 ; megatest

    try {
        backTypeCtrl := typed || (A_TickCount-lastTypedSince > DisplayTimeTyping) ? typed : backTypeCtrl
        key := GetKeyStr()
        TypingFriendlyKeys := "i)^((.?shift \+ )?(Num|Caps|Scroll|Insert|Tab)|\{|AppsKey|Volume |Media_|Wheel |◐)"

        if (enterErasesLine=1) && (SecondaryTypingMode=1) && (key ~= "i)(enter|esc)")
        {
           DetectHiddenWindows, on
           SwitchSecondaryTypingMode()
           Sleep, 20
           WinActivate, %Window2Activate%
           Sleep, 40
           if InStr(key, "enter") && (sendKeysRealTime=0)
           {
              sendOSDcontent()
              skipRest := 1
           }
           DetectHiddenWindows, off
        }

        if ((key ~= "i)(enter|esc)") && (DisableTypingMode=0) && (ShowSingleKey=1))
        {
            if (enterErasesLine=0) && (OnlyTypingMode=1)
               InsertChar2caret(" ")

            if (enterErasesLine=0) && (OnlyTypingMode=1) && (key ~= "i)(esc)")
               dontReturn := 1

            backTypdUndo := typed
            backTypeCtrl := ""
            externalKeyStrokeReceived := ""
            if (key ~= "i)(esc)")
               Global lastTypedSince := A_TickCount - ReturnToTypingDelay

            if (StrLen(typed)>4) && (enableTypingHistory=1)
            {
               StringGetPos, CaretPos4, typed, %lola%
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               editField1 := editField2
               editField2 := typed
               editingField := 3
               if (OnlyTypingMode=1)
                  typed := ST_Insert(lola, typed, CaretPos4+1)
            }
            if (enterErasesLine=1)
               typed := (skipRest=1) ? typed : ""
        }

        if (!(key ~= TypingFriendlyKeys)) && (DisableTypingMode=0)
        {
            typed := (OnlyTypingMode=1 || skipRest=1) ? typed : ""
        } else if ((key ~= "i)^((.?Shift \+ )?Tab)") && typed && (DisableTypingMode=0))
        {
            if (typed ~= "i)(▫│)") && (SecondaryTypingMode=0)
            {
                StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%A_Space%%lola%
                TrueRmDkSymbol := ""
                CalcVisibleText()
            } else
            {
                InsertChar2caret(TrueRmDkSymbol " ")
            }
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        if (StrLen(typed)>1) && (dontReturn!=1)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }
}

OnLetterPressed() {
; Sleep, 60 ; megatest

    if (A_TickCount-lastTypedSince > 2000*StrLen(typed)) && StrLen(typed)<5 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && StrLen(typed)>4
       InsertChar2caret(" ")

    try {
        if (DeadKeys=1 && (A_TickCount-deadKeyPressed < 1100))      ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these
        {
            Sleep, % 70 * typingDelaysScale
        } else if (typed && DeadKeys=1)
        {
            Sleep, % 20 * typingDelaysScale
        }
        if (typed && DeadKeys=1 && DoNotBindDeadKeys=1)
            Sleep, % 20 * typingDelaysScale

        AltGrMatcher := "i)^((AltGr|.?Alt \+ .?Ctrl|.?Ctrl \+ .?Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))"
        ShiftMatcher := "i)^(.?Shift \+ ((.)$|(.)[\r\n \,]))"
        key := GetKeyStr()

        if (prefixed || DisableTypingMode=1)
        {
            typingValidation := (SecondaryTypingMode=0) && (DisableTypingMode=0) ? 1 : 0
            if ((key ~= AltGrMatcher) && (typingValidation=1) && (enableAltGr=1)) || ((key ~= ShiftMatcher) && (typingValidation=1))
            {
               (enableAltGr=1) && (key ~= AltGrMatcher) ? typed := TypedLetter(A_ThisHotkey)
               (key ~= ShiftMatcher) ? typed := TypedLetter(A_ThisHotkey)
               hasTypedNow := 1
               if (StrLen(typed)>1)
               {
                  ShowHotkey(visibleTextField)
                  SetTimer, HideGUI, % -DisplayTimeTyping
               } else
               {
                  typed := (hasTypedNow=1) ? typed : ""
                  ShowHotkey(key)
               }
            } else
            {
               typed := (OnlyTypingMode=1) ? typed : ""
               ShowHotkey(key)
            }
            SetTimer, HideGUI, % -DisplayTime
        } else if (SecondaryTypingMode=0)
        {
            TypedLetter(A_ThisHotkey)
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }

    if (beepFiringKeys=1) && (SilentMode=0) && (A_TickCount-tickcount_start > 600) && (keyBeeper=1) || (beepFiringKeys=1) && (SilentMode=0) && (keyBeeper=0)
    {
       if (SecondaryTypingMode=0)
          beeperzDefunctions.ahkPostFunction["OnKeyPressed", ""]
    }
}

selectAllText() {
    StringReplace, typed, typed, %lola%
    StringReplace, typed, typed, %lola2%
    CaretPos := StrLen(typed)+1
    typed := ST_Insert(lola2, typed, CaretPos)
    CaretPos := 1
    typed := ST_Insert(lola, typed, CaretPos)
}

OnCtrlAup() {
  if !InStr(A_PriorHotkey, "*vk41") && InStr(A_thisHotkey, "^vk41")
     allGood := 1

  if (allGood=1) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (ShowSingleKey=1) && (StrLen(typed)>1)
  {
     if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
        ControlSend, , ^{a}, %Window2Activate%
     selectAllText()
     CalcVisibleText()
     Global lastTypedSince := A_TickCount
     ShowHotkey(visibleTextField)
     SetTimer, HideGUI, % -DisplayTimeTyping
  } else if (OnlyTypingMode=0)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlRLeft() {
  Try {
      key := GetKeyStr()
  }

  StringGetPos, exKaretPos, typed, %lola%
  StringGetPos, exKaretPosSelly, typed, %lola2%
  if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10) && StrLen(typed)>1
  {
      if InStr(A_ThisHotkey, "+^Left")
      {
         caretJumpSelector(0)
         skipRest := 1
         if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
            ControlSend, , +{Left %times2pressKey% }, %Window2Activate%
      }

      if InStr(A_ThisHotkey, "+^Right")
      {
         caretJumpSelector(1)
         skipRest := 1
         if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
            ControlSend, , +{Right %times2pressKey% }, %Window2Activate%
      }

      if (skipRest!=1) && InStr(A_ThisHotkey, "^Left")
      {
         if (exKaretPosSelly > exKaretPos) && (exKaretPosSelly>=0)
         {
            StringReplace, typed, typed, %lola%
            StringReplace, typed, typed, %lola2%
            CaretPos := exKaretPosSelly
            typed := ST_Insert(lola, typed, CaretPos)            
            droppedSelection := 1
         } else caretJumper(0)

         if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
            ControlSend, , {Left %times2pressKey% }, %Window2Activate%
      }

      if (skipRest!=1) && InStr(A_ThisHotkey, "^Right")
      {
         if (exKaretPosSelly < exKaretPos) && (exKaretPosSelly>=0)
         {
            StringReplace, typed, typed, %lola%
            StringReplace, typed, typed, %lola2%
            CaretPos := exKaretPosSelly + 1
            typed := ST_Insert(lola, typed, CaretPos)
            droppedSelection := 1
         } else caretJumper(1)

         if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
            ControlSend, , {Right %times2pressKey% }, %Window2Activate%
      }
      CalcVisibleText()
      Global lastTypedSince := A_TickCount
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0)
  {
      if (keyCount>=10) && (OnlyTypingMode=0)
         Global lastTypedSince := A_TickCount - ReturnToTypingDelay
      if (StrLen(typed)<2)
         typed := (OnlyTypingMode=1) ? typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }

  StringGetPos, exKaretPos2, typed, %lola%
  StringGetPos, exKaretPosSelly2, typed, %lola2%
  keyCount := (exKaretPos!=exKaretPos2) && (exKaretPosSelly)<0 && (exKaretPosSelly2<0) || (exKaretPos=exKaretPos2) && (exKaretPosSelly!=exKaretPosSelly2) ? 1 : keyCount
  if (sendJumpKeys=1) && (SecondaryTypingMode=0) && (droppedSelection!=1)
  {
      times2pressKey := (exKaretPos2 > exKaretPos) ? (exKaretPos2 - exKaretPos) : (exKaretPos - exKaretPos2)
      managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      if (exKaretPosSelly<0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPos2) ? (exKaretPosSelly2 - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly2 - 1)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      if (exKaretPosSelly2<0 && exKaretPosSelly>=0)
      {
         times2pressKey := (exKaretPosSelly > exKaretPos2) ? (exKaretPosSelly - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly)
         if (A_ThisHotkey="^Right") || (A_ThisHotkey="^Left")
            times2pressKey := times2pressKey + 2
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      if (exKaretPosSelly>=0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPosSelly) ? (exKaretPosSelly2 - exKaretPosSelly) : (exKaretPosSelly - exKaretPosSelly2)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }

      if (managedMode=1)
      {
         if (A_ThisHotkey="^Left")
            SendInput, {Left %times2pressKey% }

         if (A_ThisHotkey="^Right")
            SendInput, {Right %times2pressKey% }

         if (A_ThisHotkey="+^Left")
            SendInput, {Shift Down}{Left %times2pressKey% }{Shift up}

         if (A_ThisHotkey="+^Right")
            SendInput, {Shift Down}{Right %times2pressKey% }{Shift up}
      }
  } else if (droppedSelection=1)
  {
      if (A_ThisHotkey="^Left")
         SendInput, {Right}
      if (A_ThisHotkey="^Right")
         SendInput, {Left}
      managedMode := 1
  }

  if (sendJumpKeys=1) && (managedMode!=1) ;  && (mustSendJumpKeys=1) || (sendJumpKeys=1) && (keyCount>10) && (OnlyTypingMode=1)
  {
     if (A_ThisHotkey="^Left")
        SendInput, ^{Left}
     if (A_ThisHotkey="^Right")
        SendInput, ^{Right}
     if (A_ThisHotkey="+^Left")
        SendInput, +^{Left}
     if (A_ThisHotkey="+^Right")
        SendInput, +^{Right}
  }
}

OnCtrlDelBack() {
  Try {
      key := GetKeyStr()
  }

  InitialTextLength := StrLen(typed)
  if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10) && (StrLen(typed)>=2)
  {
      backTypdUndo := typed
      StringGetPos, CaretzoiPos, typed, %lola%
      StringGetPos, exKaretPosSelly, typed, %lola2%
      if ((key ~= "i)^(.?Ctrl \+ Backspace)")) || InStr(A_ThisHotkey, "^Back")
      {
         if (exKaretPosSelly>=0)
         {
             replaceSelection()
             droppedSelection := 1
             if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                ControlSend, , {BackSpace}, %Window2Activate%
         } else
         {
             caretJumper(0)
             if (CaretzoiPos >= StrLen(typed)-1)
             {
                typed := typed "zzz"
                removeEnd := 3
             }
             StringGetPos, CaretzoaiaPos, typed, %lola%
             typed := st_delete(typed, CaretzoaiaPos+1, CaretzoiPos - CaretzoaiaPos+1)
             if (removeEnd>1)
                 StringTrimRight, typed, typed, 3

             if (st_count(typed, lola)<1)
                typed := ST_Insert(lola, typed, CaretzoaiaPos+1)
             BkspPressed := 1
             if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                ControlSend, , {BackSpace %times2pressKey% }, %Window2Activate%
         }
      }

      if ((key ~= "i)^(.?Ctrl \+ Delete)")) || InStr(A_ThisHotkey, "^Del")
      {
         if (exKaretPosSelly>=0)
         {
             replaceSelection()
             droppedSelection := 1
             if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                ControlSend, , {Del}, %Window2Activate%
         } else
         {
             caretJumper(1)
             StringGetPos, CaretzoaiaPos, typed, %lola%
             typed := st_delete(typed, CaretzoiPos+1, CaretzoaiaPos - CaretzoiPos)
             if (st_count(typed, lola)<1)
                typed := ST_Insert(lola, typed, CaretzoaiaPos)
             DelPressed := 1
             if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
                ControlSend, , {Del %times2pressKey% }, %Window2Activate%
         }
      }
      Global lastTypedSince := A_TickCount
      CalcVisibleText()
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if (StrLen(typed)<2) || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0)
  {
      if (keyCount>10) && (OnlyTypingMode=0)
         Global lastTypedSince := A_TickCount - ReturnToTypingDelay
      if (StrLen(typed)<2)
         typed := (OnlyTypingMode=1) ? typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }
  TextLengthAfter := StrLen(typed)
  times2pressKey := InitialTextLength - TextLengthAfter
  if (times2pressKey>1)
     keyCount := 1
  if (sendJumpKeys=1) && (SecondaryTypingMode=0)
  {
         StringGetPos, exKaretPos2, typed, %lola%
         if (exKaretPos2<0)
           times2pressKey := times2pressKey - 1

         if (times2pressKey>0) && (BkspPressed=1) && (droppedSelection!=1)
            SendInput, {BackSpace %times2pressKey% }

         if (times2pressKey>0) && (DelPressed=1) && (droppedSelection!=1)
            SendInput, {Del %times2pressKey% }

         if (droppedSelection=1)
            SendInput, {Del}
  }

  if (sendJumpKeys=1) && (times2pressKey<=0) && (droppedSelection!=1)
  {
      if (A_ThisHotkey="^BackSpace")
         SendInput, ^{BackSpace}
      if (A_ThisHotkey="^Del")
         SendInput, ^{Del}
  }
}

OnCtrlVup() {
  if (NeverDisplayOSD=1)
     Return

  if !InStr(A_PriorHotkey, "*vk56") && InStr(A_thisHotkey, "^vk56")
     allGood := 1

  toPaste := Clipboard
  if (allGood=1) && (DisableTypingMode=0) && (ShowSingleKey=1) && (StrLen(toPaste)>0)
  {
    backTypdUndo := typed
    Stringleft, toPaste, toPaste, 950
    StringReplace, toPaste, toPaste, `r`n, %A_SPACE%, All
    StringReplace, toPaste, toPaste, %A_TAB%, %A_SPACE%, All
    InsertChar2caret(toPaste)
    CaretPos := CaretPos + StrLen(toPaste)
    maxTextChars := StrLen(typed)+2
    if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
       ControlSend, ,^{v}, %Window2Activate%
    CalcVisibleText()
    ShowHotkey(visibleTextField)
    Global lastTypedSince := A_TickCount
    SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if (allGood!=1) || (ShowSingleKey=0) || (StrLen(toPaste)<1)
  {
      if (OnlyTypingMode=1)
         Return
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlCup() {
  if !InStr(A_PriorHotkey, "*vk43") && InStr(A_thisHotkey, "^vk43")
     allGood := 1

  if (allGood=1) && (StrLen(typed)>1) && (SecondaryTypingMode=1) && (A_TickCount-lastTypedSince < ReturnToTypingDelay)
  {
     if (ShowSingleKey=1) && (DisableTypingMode=0) && (st_count(typed, lola2)>0)
     {
        replaceSelection(1, 0)
        CalcVisibleText()
     }
     if (sendKeysRealTime=1)
        ControlSend, , ^{c}, %Window2Activate%
     ShowHotkey(visibleTextField)
     Global lastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if (StrLen(typed)<2) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlXup() {

  if !InStr(A_PriorHotkey, "*vk58") && InStr(A_thisHotkey, "^vk58")
     allGood := 1

  if (StrLen(typed)>1) && (allGood=1) && (A_TickCount-lastTypedSince < ReturnToTypingDelay)
  {
     if (ShowSingleKey=1) && (DisableTypingMode=0) && (st_count(typed, lola2)>0)
     {
        replaceSelection(1,1)
        CalcVisibleText()
     }
     if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
        ControlSend, , ^{x}, %Window2Activate%
     ShowHotkey(visibleTextField)
     Global lastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if (StrLen(typed)<2) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlZup() {
  if (NeverDisplayOSD=1)
     Return

  if !InStr(A_PriorHotkey, "*vk5a") && InStr(A_thisHotkey, "^vk5a")
     allGood := 1

  if (allGood=1) && (StrLen(typed)>0) && (ShowSingleKey=1) && (DisableTypingMode=0) && (A_TickCount-lastTypedSince < ReturnToTypingDelay)
  {
      blahBlah := typed
      typed := (StrLen(backTypdUndo)>1) ? backTypdUndo : typed
      backTypdUndo := (StrLen(blahBlah)>1) ? blahBlah : backTypdUndo
      Global lastTypedSince := A_TickCount
      if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
         ControlSend, , ^{z}, %Window2Activate%
      CalcVisibleText()
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  } else if (StrLen(typed)<1) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (OnlyTypingMode=0) || (DisableTypingMode=1)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnSpacePressed() {
    if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
       ControlSend, , {Space}, %Window2Activate%

    try {
          if (DoNotBindDeadKeys=1) && (AlternativeHook2keys=1) && (SecondaryTypingMode=0) && (DisableTypingMode=0) && (DeadKeys=1)
             Sleep, 35

          key := GetKeyStr()
          if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>0 && (DisableTypingMode=0) && (ShowSingleKey=1)
          {
             if (typed ~= "i)(▫│)") && (SecondaryTypingMode=0)
             {
                  StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%lola%
             } else if (SecondaryTypingMode=0)
             {
                 if TrueRmDkSymbol
                 {
                     InsertChar2caret(TrueRmDkSymbol)
                 } else if externalKeyStrokeReceived && (DoNotBindDeadKeys=1) && (AlternativeHook2keys=1) && (SecondaryTypingMode=0) && (DisableTypingMode=0) && (DeadKeys=1)
                 {
                     InsertChar2caret(externalKeyStrokeReceived)
                 } else
                 {
                     InsertChar2caret(" ")
                 }
             }

             if (SecondaryTypingMode=1)
             {
                if !OnMSGdeadChar
                   char2insert := OnMSGchar ? OnMSGchar : " "
                if (sendKeysRealTime=1)
                   char2insert := OnMSGdeadChar && !OnMSGchar ? OnMSGdeadChar : " "
                InsertChar2caret(char2insert)
             }
             Global lastTypedSince := A_TickCount
             deadKeyProcessing()
             CalcVisibleText()
             ShowHotkey(visibleTextField)
             SetTimer, HideGUI, % -DisplayTimeTyping
          }

          if (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
          {
             if (StrLen(typed)<2)
                typed := (OnlyTypingMode=1) ? typed : ""
             if (OnlyTypingMode!=1)
             {
                ShowHotkey(key)
                SetTimer, HideGUI, % -DisplayTime
             }
          }

          if (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
             typed := (OnlyTypingMode=1) ? typed : ""
    }

    if TrueRmDkSymbol && (StrLen(typed)<2) && (SecondaryTypingMode=0) && (DisableTypingMode=0) && (DoNotBindDeadKeys=0)
    { 
       Global lastTypedSince := A_TickCount
       InsertChar2caret(TrueRmDkSymbol)
       ShowHotkey(visibleTextField)
       SetTimer, HideGUI, % -DisplayTimeTyping
    }
    OnMSGchar := ""
    OnMSGdeadChar := ""
    TrueRmDkSymbol := ""
    externalKeyStrokeReceived := ""
}

OnBspPressed() {
    if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
       ControlSend, , {BackSpace}, %Window2Activate%

    try
    {
        key := GetKeyStr()
        if TrueRmDkSymbol && (AlternativeHook2keys=1) && (SecondaryTypingMode=0) && (DisableTypingMode=0) || OnMSGdeadChar && (SecondaryTypingMode=1) && (DisableTypingMode=0) || TrueRmDkSymbol && (AlternativeHook2keys=0) && (SecondaryTypingMode=0) && (DisableTypingMode=0) && (ShowDeadKeys=0)
        {
           TrueRmDkSymbol := ¨¨
           OnMSGdeadChar := ""
           Return
        } else if (typed ~= "i)(▫│)") && TrueRmDkSymbol && (AlternativeHook2keys=0) && (SecondaryTypingMode=0) && (DisableTypingMode=0)
        {
           StringReplace, typed, typed,▫%lola%, %lola%
           TrueRmDkSymbol := ¨¨
           CalcVisibleText()
           ShowHotkey(visibleTextField)
           SetTimer, HideGUI, % -DisplayTimeTyping
           keycount := 1
           Global lastTypedSince := A_TickCount
           Return
        }

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10)
        {

            if (st_count(typed, lola2)>0)
            {
               replaceSelection()
               CalcVisibleText()
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }

            deadKeyProcessing()
            StringGetPos, CaretPos, typed, % lola
            CaretPos := (CaretPos < 1) ? 2000 : CaretPos
            if (CaretPos = 2000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }
            keycount := 1
            Global lastTypedSince := A_TickCount
            typedLength := StrLen(typed)
            CaretPosy := (CaretPos = typedLength) ? 0 : CaretPos
            typed := (caretpos<1) ? typed : st_delete(typed, CaretPosy, 1)
            if InStr(typed, "▫" lola)
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

        if (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           if (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }
        if (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    OnMSGchar := ""
}

OnDelPressed() {
    if (sendKeysRealTime=1) && (SecondaryTypingMode=1)
       ControlSend, , {Del}, %Window2Activate%

    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10)
        {
            if (st_count(typed, lola2)>0)
            {
               replaceSelection()
               CalcVisibleText()
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }

            deadKeyProcessing()
            if (CaretPos = 3000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }
            keycount := 1
            StringGetPos, CaretPos, typed, %lola%
            testChar := SubStr(typed, CaretPos+3, 1)

            if (CaretPos >= StrLen(typed)-2 )
               endReached := 1

            if InStr(typed, lola "▫") || RegExMatch(testChar, "[\p{Mn}\p{Cc}\p{Cf}\p{Co}]")
               deleteNext := 1

            if (endReached!=1) && InStr(typed, lola)
            {
               Global lastTypedSince := A_TickCount
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
               StringGetPos, CaretPos, typed, %lola%
               l2 := StrLen(typed)
               typed := st_delete(typed, CaretPos+2, 1)
               l2b := StrLen(typed)
               CaretPos := CaretPos+1
               if (l2b = l2)
                  typed := st_delete(typed, 0, 1)
            }
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10) && (OnlyTypingMode=0)
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           if (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        if (DisableTypingMode=1) ||  (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
}

OnNumpadsPressed() {
    if (A_TickCount-lastTypedSince > 1000*StrLen(typed)) && StrLen(typed)<5 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && StrLen(typed)>4
       InsertChar2caret(" ")

    try {
        key := GetKeyStr()
        if ((prefixed && !(key ~= "i)^(.?Shift \+ )")) || DisableTypingMode=1)
        {
            typed := (OnlyTypingMode=1) ? typed : ""
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        } else if (ShowSingleKey=1) && (SecondaryTypingMode!=1)
        {
            key := SubStr(key, 3, 1)
            InsertChar2caret(TrueRmDkSymbol key)
            Global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }
    TrueRmDkSymbol := ¨¨
}

OnKeyUp() {
    Global tickcount_start := A_TickCount
    SetTimer, capsHighlightDummy, 100, -20
}

OnLetterUp() {
    OnKeyUp()

    if (KeyBeeper=1) && (SecondaryTypingMode=0) || (CapslockBeeper=1) && (SecondaryTypingMode=0)
       beeperzDefunctions.ahkPostFunction["OnLetterPressed", ""]
}

capsHighlightDummy() {
    GetKeyState, CapsState, CapsLock, T
    GuiControl, OSD:, CapsDummy, % (CapsState = "D") ? 100 : 0
    SetTimer,, off
}

OnMudPressed() {
    if (NeverDisplayOSD=1)
       Return
    static repeatCount := 1
    static modPressedTimer
    backTypeCtrl := typed
    for i, mod in MainModsList
    {
        if GetKeyState(mod)
           fl_prefix .= mod "+"
    }
    StringReplace, keya, A_ThisHotkey, ~*,
    fl_prefix .= keya "+"
    fl_prefix := CompactModifiers(fl_prefix)
    Sort, fl_prefix, U D+
    fl_prefix := RTrim(fl_prefix, "+")
    StringReplace, fl_prefix, fl_prefix, +, %A_Space%+%A_Space%, All

    if (A_TickCount-tickcount_start2 < 35)
       Return

    if InStr(fl_prefix, "Shift")
    {
       if (StrLen(typed)>1) && (DisableTypingMode=0)
          GuiControl, OSD:, CapsDummy, 60

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }
    if (ModBeeper=1) && (SilentMode=0) && (A_TickCount-modPressedTimer > 200) && (A_TickCount-tickcount_start > 500)
       beeperzDefunctions.ahkPostFunction["modsBeeper", ""]

    if (StrLen(typed)>1) && (OSDvisible=1) && (A_TickCount-lastTypedSince < 4000) && (A_TickCount-modPressedTimer > 100)
    {
       StringReplace, visibleTextField, visibleTextField, %lola%, ▒
       ShowHotkey(visibleTextField)
       StringReplace, visibleTextField, visibleTextField, ▒, %lola%
       SetTimer, CalcVisibleTextFieldDummy, 1350, 50
    }

    modPressedTimer := A_TickCount
    SetTimer, modsTimer, 125, -50
    if (ShowSingleModifierKey=0)
       Return

    if InStr(fl_prefix, modifiers_temp) && !typed && (ShowKeyCount=1)
    {
        valid_count := 1
        if (repeatCount>1)
           keyCount := 0.1
    } else
    {
        valid_count := 0
        modifiers_temp := fl_prefix
        if !prefixed
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

    if (ShowKeyCountValid=1)
    {
        if !InStr(fl_prefix, "+") {
            modifiers_temp := fl_prefix
            fl_prefix .= " (" Round(repeatCount) ")"
        } else
        {
            repeatCount := 1
        }
   }

   if ((StrLen(typed)>1) && (OSDvisible=1) && (A_TickCount-lastTypedSince < 4000)) || (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && (OSDvisible=1) && !typed && keycount>7) || (OnlyTypingMode=1)
   {
      Sleep, 0
   } else
   {
      if (ShowSingleModifierKey=1)
      {
         ShowHotkey(fl_prefix)
         SetTimer, HideGUI, % -DisplayTime/2
      }
      SetTimer, returnToTyped, % -DisplayTime/4
   }
}

OnMudUp() {
    Global tickcount_start := A_TickCount
    if (StrLen(typed)>1)
       SetTimer, returnToTyped, % -DisplayTime/4.5
}

OnDeadKeyPressed() {

  if (SecondaryTypingMode=1)
     Return

  if (AlternativeHook2keys=0)
     Sleep, % 85 * typingDelaysScale

  RmDkSymbol := "▫"
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  if (AlternativeHook2keys=1) && (A_TickCount-deadKeyPressed<800) && (A_TickCount-lastTypedSince>600) && TrueRmDkSymbol && (DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     externalKeyStrokeReceived := ""
     TrueRmDkSymbol := ""
  }
  Global deadKeyPressed := A_TickCount

  if ((ShowDeadKeys=1) && typed && (DisableTypingMode=0) && (ShowSingleKey=1) && AlternativeHook2keys=0)
  {
       if (typed ~= "i)(▫│)")
       {
           StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%TrueRmDkSymbol%%lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } else
       {
           InsertChar2caret(RmDkSymbol)
       }
  }
  
  if ((StrLen(typed)>1) && (DisableTypingMode=0) && TrueRmDkSymbol )
  {
     StringReplace, visibleTextField, visibleTextField, %lola%, %TrueRmDkSymbol%
     ShowHotkey(visibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, 850, 50
  }
  SetTimer, returnToTyped, 950, -10
  keyCount := 0.1

  if (StrLen(typed)<2)
  {
     if (ShowDeadKeys=1) && (DisableTypingMode=0) && (AlternativeHook2keys=0)
        InsertChar2caret(RmDkSymbol)

     if (A_ThisHotkey ~= "i)^(~\+)")
     {
        DeadKeyMod := "Shift + " TrueRmDkSymbol2
        ShowHotkey(DeadKeyMod " [dead key]")
     } else if (ShowSingleKey=1)
     {
        ShowHotkey(TrueRmDkSymbol2 " [dead key]")
     }
     SetTimer, HideGUI, % -DisplayTime
  }
  if (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
}

deadKeyProcessing() {

  if (ShowDeadKeys=0) || (DisableTypingMode=1) || (ShowSingleKey=0) || (DeadKeys=0) || (SecondaryTypingMode=1) || (AlternativeHook2keys=1)
     Return

  Loop, 5
  {
    deadkeyPosition := RegExMatch(typed, "▫[^[:alpha:]]")
    nextChar := SubStr(typed, deadkeyPosition+1, 1)

    if (nextChar!="▫") && (deadkeyPosition>=1)
       typed := st_overwrite("▪", typed, deadkeyPosition)
  }
}

OnAltGrDeadKeyPressed() {
  if (SecondaryTypingMode=1)
     Return

  if (AlternativeHook2keys=0)
     Sleep, % 85 * typingDelaysScale
  RmDkSymbol := "▫"
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  if (AlternativeHook2keys=1) && (A_TickCount-deadKeyPressed<800) && (A_TickCount-lastTypedSince>600) && TrueRmDkSymbol && (DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     externalKeyStrokeReceived := ""
     TrueRmDkSymbol := ""
  }

  Global deadKeyPressed := A_TickCount
  if (AlternativeHook2keys=0)
     Global lastTypedSince := A_TickCount

  if ((ShowDeadKeys=1) && typed && (DisableTypingMode=0) && (ShowSingleKey=1) && AlternativeHook2keys=0)
  {
       if (typed ~= "i)(▫│)")
       {
           StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%TrueRmDkSymbol%%lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } else
       {
           InsertChar2caret(RmDkSymbol)
       }
       SetTimer, returnToTyped, 800, -10
  }

  keyCount := 0.1
  if ((StrLen(typed)>1) && (DisableTypingMode=0) && TrueRmDkSymbol2 )
  {
     StringReplace, visibleTextField, visibleTextField, %lola%, %TrueRmDkSymbol2%
     ShowHotkey(visibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, 850, 50
     SetTimer, returnToTyped, 800, -10
  }

  if (StrLen(typed)<2)
  {
     if (ShowDeadKeys=1) && (DisableTypingMode=0) && (AlternativeHook2keys=0)
        InsertChar2caret(RmDkSymbol)

     if (A_ThisHotkey ~= "i)^(~\^!)")
        DeadKeyMods := "Ctrl + Alt + " TrueRmDkSymbol2

     if (A_ThisHotkey ~= "i)^(~\+\^!)")
        DeadKeyMods := "Ctrl + Alt + Shift + " TrueRmDkSymbol2

     if (A_ThisHotkey ~= "i)^(~<\^>!)")
        DeadKeyMods := "AltGr + " TrueRmDkSymbol2

     ShowHotkey(DeadKeyMods " [dead key]")
     SetTimer, HideGUI, % -DisplayTime
  }
  if (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
}

returnToTyped() {
    if (StrLen(typed) > 2) && (keycount<10) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (ShowSingleKey=1) && (DisableTypingMode=0) && !A_IsSuspended
    {
        ShowHotkey(visibleTextField)
        SetTimer, HideGUI, % -DisplayTimeTyping
    }
    SetTimer, , off
}

CreateOSDGUI() {
    Global
    CapsDummy := 1
    Gui, OSD: Destroy
    Sleep, 10
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow +HwndhOSD
    Gui, OSD: Margin, 20, 10
    Gui, OSD: Color, %OSDbgrColor%
    if (showPreview=0)
       Gui, OSD: Font, c%OSDtextColor% s%FontSize% bold, %FontName%, -wrap
    else
       Gui, OSD: Font, c%OSDtextColor%, -wrap

    textAlign := "left"
    widtha := A_ScreenWidth - 50
    positionText := 12

    if (OSDalignment>1)
    {
       textAlign := (OSDalignment=2) ? "Center" : "Right"
       positionText := (OSDalignment=2) ? 0 : -12
    }

    if (A_OSVersion="WIN_XP")
       Gui, OSD: Add, Text, 0x80 w%widtha% vHotkeyText %textOrientation% %wrappy% hwndhOSDctrl
    else 
       Gui, OSD: Add, Edit, -E0x200 x%positionText% -multi %textAlign% readonly -WantCtrlA -WantReturn -wrap w%widtha% vHotkeyText hwndhOSDctrl, %HotkeyText%

    if (OSDborder=1)
    {
        WinSet, Style, +0xC40000
        WinSet, Style, -0xC00000
        WinSet, Style, +0x800000   ; small border
    }
    progressHeight := GuiHeight + FontSize
    progressWidth := FontSize/2 < 11 ? 11 : FontSize/2
    Gui, OSD: Add, Progress, x0 y0 w%progressWidth% h%progressHeight% Background%OSDbgrColor% c%CapsColorHighlight% vCapsDummy hwndhOSDind, 0
    Gui, OSD: Show, NoActivate Hide x%GuiX% y%GuiY%, KeyPressOSDwin  ; required for initialization when Drag2Move is active
    OSDhandles := hOSD "," hOSDctrl "," hOSDind
    if (OSDalignment>1)
       CreateOSDGUIghost()
}

CreateOSDGUIghost() {
    Global
    Gui, OSDghost: Destroy
    Gui, OSDghost: -Caption +Owner +ToolWindow
    Gui, OSDghost: Margin, 20, 10
    Gui, OSDghost: Color, %OSDbgrColor%
    Gui, OSDghost: Show, NoActivate x%GuiX% y%GuiY% w50 h50, KeyPressOSDghost
    WinSet, Transparent, 10, KeyPressOSDghost
}

CreateHotkey() {
    #MaxThreads 255
    #MaxThreadsPerHotkey 255
    #MaxThreadsBuffer On

    if (AutoDetectKBD=1)
       IdentifyKBDlayout()

    Static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "^!", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    Static mods_list := ["!", "!#", "!#^", "!#^+", "!+", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    Static megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list

    Hotkey, ~*Left, OnRLeftPressed, useErrorLevel
    Hotkey, ~*Left Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Right, OnRLeftPressed, useErrorLevel
    Hotkey, ~*Right Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Up, OnUpDownPressed, useErrorLevel
    Hotkey, ~*Up Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Down, OnUpDownPressed, useErrorLevel
    Hotkey, ~*Down Up, OnKeyUp, useErrorLevel
    Hotkey, ~*PgUp, OnPGupDnPressed, useErrorLevel
    Hotkey, ~*PgUp Up, OnKeyUp, useErrorLevel
    Hotkey, ~*PgDn, OnPGupDnPressed, useErrorLevel
    Hotkey, ~*PgDn Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Del, OnDelPressed, useErrorLevel
    Hotkey, ~*Del Up, OnKeyUp, useErrorLevel
    Hotkey, ~*BackSpace, OnBspPressed, useErrorLevel
    Hotkey, ~*BackSpace Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Space, OnSpacePressed, useErrorLevel
    Hotkey, ~*Space Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Home, OnHomeEndPressed, useErrorLevel
    Hotkey, ~+Home, OnHomeEndPressed, useErrorLevel
    Hotkey, ~*Home Up, OnKeyUp, useErrorLevel
    Hotkey, ~*End, OnHomeEndPressed, useErrorLevel
    Hotkey, ~+End, OnHomeEndPressed, useErrorLevel
    Hotkey, ~*End Up, OnKeyUp, useErrorLevel
    Hotkey, ~^vk41, OnCtrlAup, useErrorLevel
    Hotkey, ~^vk43, OnCtrlCup, useErrorLevel
    Hotkey, ~^vk56, OnCtrlVup, useErrorLevel
    Hotkey, ~^vk58, OnCtrlXup, useErrorLevel
    Hotkey, ~^vk5A, OnCtrlZup, useErrorLevel

    if (MediateNavKeys=1) && (DisableTypingMode=0)
    {
        Hotkey, Home, OnHomeEndPressed, useErrorLevel
        Hotkey, +Home, OnHomeEndPressed, useErrorLevel
        Hotkey, End, OnHomeEndPressed, useErrorLevel
        Hotkey, +End, OnHomeEndPressed, useErrorLevel
    }

    if (sendJumpKeys=0)
    {
       Hotkey, ~^BackSpace, OnCtrlDelBack, useErrorLevel
       Hotkey, ~^Del, OnCtrlDelBack, useErrorLevel
       Hotkey, ~^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, ~^Right, OnCtrlRLeft, useErrorLevel
       Hotkey, ~+^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, ~+^Right, OnCtrlRLeft, useErrorLevel
    } else
    {
       Hotkey, ^BackSpace, OnCtrlDelBack, useErrorLevel
       Hotkey, ^Del, OnCtrlDelBack, useErrorLevel
       Hotkey, ^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, ^Right, OnCtrlRLeft, useErrorLevel
       Hotkey, +^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, +^Right, OnCtrlRLeft, useErrorLevel
    }

; bind to the list of possible letters/chars
    Loop, 256
    {
        k := A_Index
        code := Format("{:x}", k)
        n := GetKeyName("vk" code)

        if (n = "")
           n := GetKeyChar("vk" code)

        if (n = " ") || (n = "") || (StrLen(n)>1)
           continue

        if (DeadKeys=1)
        {
          for each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
          {
            if (InStr(char2skip, "vk" code) || (n = char2skip))
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

        Hotkey, % "~*vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~+vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~^!vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~<^>!vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~+^!vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~+<^>!vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~*vk" code " Up", OnLetterUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           SoundBeep, 1900, 50
    }

; bind to dead keys to show the proper symbol when such a key is pressed

    if ((DeadKeys=1) && (DoNotBindAltGrDeadKeys=0)) || ((DeadKeys=1) && (DoNotBindDeadKeys=0))
    {
        Loop, Parse, DKaltGR_list, .
        {
            for i, mod in mods_list
            {
                if (enableAltGr=1)
                {
                  Hotkey, % "~^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                }

                if (enableAltGr=0)
                {
                  Hotkey, % "~^!" A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~^!" A_LoopField " Up", OnLetterUp, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField , OnLetterPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField " Up", OnLetterUp, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField , OnLetterPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField " Up", OnLetterUp, useErrorLevel
                }

                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel

                if !InStr(DKshift_list, A_LoopField)
                {
                   Hotkey, % "~+" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnLetterUp, useErrorLevel
                }

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnLetterUp, useErrorLevel
                }
            }
        }
    }

    if (DeadKeys=1) && (DoNotBindDeadKeys=0)
    {
        Loop, Parse, DKshift_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~+" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnLetterUp, useErrorLevel
                }

            }
        }

        Loop, Parse, DKnotShifted_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel

                if !InStr(DKShift_list, A_LoopField)
                {
                   Hotkey, % "~+$" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnLetterUp, useErrorLevel
                }
            }
        }

        ShiftRelatedDKlist := DKshift_list "." DKnotShifted_list
        Loop, Parse, ShiftRelatedDKlist, .
        {
            for i, mod in mods_noShift
            {
               if !InStr(DKaltGR_list, A_LoopField) && (enableAltGr=1)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel
               }

               if (enableAltGr=0)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel
               }
            }
        }
    }  ; dead keys parser

; get dead key symbols

    if (DeadKeys=1) && (DoNotBindDeadKeys=0)
    {
       Loop, Parse, DKnotShifted_list, .
       {
               backupSymbol := SubStr(A_LoopField, InStr(A_LoopField, "vk")+2, 2)
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc)
               {
                  SCnames2 .= toUnicodeExtended(vk, sc) "~" A_LoopField
               } else if GetKeyName("vk" backupSymbol)
               {
                  SCnames2 .= GetKeyName("vk" backupSymbol) "~" A_LoopField
               }
       }

       Loop, Parse, DKShift_list, .
       {
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc, 1)
                  SCnames2 .= toUnicodeExtended(vk, sc, 1) "~+" A_LoopField
       }
       Loop, Parse, DKaltGR_list, .
       {
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc, 0, 1)
               {
                  SCnames2 .= toUnicodeExtended(vk, sc, 0, 1) "~^!" A_LoopField
                  SCnames2 .= toUnicodeExtended(vk, sc, 0, 1) "~+^!" A_LoopField
                  SCnames2 .= toUnicodeExtended(vk, sc, 0, 1) "~<^>!" A_LoopField
               }
       }
    }

    if (OnlyTypingMode!=1)
    {
      Loop, 24 ; F1-F24
      {
          Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
          Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
          if (errorlevel!=0) && (audioAlerts=1)
             SoundBeep, 1900, 50
      }
    }

    NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
    Loop, Parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          SoundBeep, 1900, 50
    }

    Loop, 10 ; Numpad0 - Numpad9 ; numlock on
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnNumpadsPressed, UseErrorLevel
        Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           SoundBeep, 1900, 50
    }

    NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
    Loop, Parse, NumpadSymbols, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadsPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          SoundBeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|CapsLock|ScrollLock|NumLock|Pause|sc146|sc123"
    Loop, Parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           SoundBeep, 1900, 50
    }

    if (ShowMouseButton=1) || (visualMouseClicks=1)
    {
        Loop, Parse, % "LButton|MButton|RButton", |
        Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           SoundBeep, 1900, 50
    }

    for i, mod in MainModsList
    {
       Hotkey, % "~*" mod, OnMudPressed, useErrorLevel
       Hotkey, % "~*" mod " Up", OnMudUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          SoundBeep, 1900, 50
    }
}

ShowHotkey(HotkeyStr) {
; Sleep, 70 ; megatest

    if (HotkeyStr ~= "i)^(\s+)$") || (NeverDisplayOSD=1)
       Return

    if (HotkeyStr ~= "i)( \+ )") && !(typed ~= "i)( \+ )") && (OnlyTypingMode=1)
       Return

    Global tickcount_start2 := A_TickCount
    Static oldText_width, Wid, Heig
    if (OSDautosize=1)
    {
        if (StrLen(HotkeyStr)!=oldText_width) || (showPreview=1)
        {
           growthIncrement := (FontSize/2)*(OSDautosizeFactory/150)
           startPoint := GetTextExtentPoint(HotkeyStr, FontName, FontSize) / (OSDautosizeFactory/100) + 35
           if (startPoint > text_width+growthIncrement) || (startPoint < text_width-growthIncrement)
              text_width := Round(startPoint)
           text_width := (text_width > maxAllowedGuiWidth-growthIncrement*2) ? Round(maxAllowedGuiWidth) : Round(text_width)
        }
        oldText_width := StrLen(HotkeyStr)
    } else if (OSDautosize=0)
    {
        text_width := maxAllowedGuiWidth
    }
    dGuiX := Round(GuiX)
    GuiControl, OSD: , HotkeyText, %HotkeyStr%
    if (OSDalignment>1)
    {
        Gui, OSDghost: Show, NoActivate Hide x%dGuiX% y%GuiY% w%text_width%, KeyPressOSDghost
        GuiGetSize(Wid, Heig, 0)
        if (OSDalignment=3)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid) : Round(dGuiX)
        if (OSDalignment=2)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid)/2 : Round(dGuiX)
        GuiControl, OSD: Move, HotkeyText, w%text_width% Left
    }
    SetTimer, checkMousePresence, on, 950, -15
    if (OSDalignment>1)
       Gui, OSDghost: Show, NoActivate Hide x%dGuiX% y%GuiY% w%text_width%, KeyPressOSDghost
    Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%text_width%, KeyPressOSDwin
    WinSet, AlwaysOnTop, On, KeyPressOSDwin
    OSDvisible := 1
}

ShowLongMsg(stringo) {
   NeverDisplayOSD := 0
   text_width2 := GetTextExtentPoint(stringo, FontName, FontSize) / (OSDautosizeFactory/100)
   maxAllowedGuiWidth := text_width2 + 30
   ShowHotkey(stringo)
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
   IniRead, NeverDisplayOSD, %inifile%, SavedSettings, NeverDisplayOSD, %NeverDisplayOSD%
}

GetTextExtentPoint(sString, sFaceName, nHeight, initialStart := 0) {
; by Sean from https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363
; Sleep, 60 ; megatest

  hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
  nHeight := -DllCall("MulDiv", "Int", nHeight, "Int", DllCall("GetDeviceCaps", "Ptr", hDC, "Int", 90), "Int", 72)

  hFont := DllCall("CreateFont"
    , "Int", nHeight
    , "Int", 0    ; nWidth
    , "Int", 0    ; nEscapement
    , "Int", 0    ; nOrientation
    , "Int", 700  ; fnWeight
    , "UInt", 0   ; fdwItalic
    , "UInt", 0   ; fdwUnderline
    , "UInt", 0   ; fdwStrikeOut
    , "UInt", 0   ; fdwCharSet
    , "UInt", 0   ; fdwOutputPrecision
    , "UInt", 0   ; fdwClipPrecision
    , "UInt", 0   ; fdwQuality
    , "UInt", 0   ; fdwPitchAndFamily
    , "Str", sFaceName
    , "Ptr")
  hFold := DllCall("SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr")

  DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", sString, "Int", StrLen(sString), "Int64P", nSize)
  DllCall("SelectObject", "Ptr", hDC, "Ptr", hFold)
  DllCall("DeleteObject", "Ptr", hFont)
  DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
  SetFormat, Integer, D

  nWidth := nSize & 0xFFFFFFFF
  nWidth := (nWidth<35) ? 36 : Round(nWidth)

  if ((initialStart=1) || A_IsSuspended)
  {
    minHeight := Round(FontSize*1.55)
    maxHeight := Round(FontSize*3.1)
    GuiHeight := nSize >> 32 & 0xFFFFFFFF
    GuiHeight := GuiHeight / (OSDautosizeFactory/100) + (OSDautosizeFactory/10) + 4
    GuiHeight := (GuiHeight<minHeight) ? minHeight+1 : Round(GuiHeight)
    GuiHeight := (GuiHeight>maxHeight) ? maxHeight-1 : Round(GuiHeight)
  }
  Return nWidth
}

GuiGetSize(ByRef W, ByRef H, vindov) {          ; function by VxE from https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
; Sleep, 60 ; megatest

  if (vindov=0)
     Gui, OSDghost: +LastFoundExist
  if (vindov=1)
     Gui, OSD: +LastFoundExist
  if (vindov=2)
     Gui, MouseH: +LastFoundExist
  if (vindov=3)
     Gui, MouseIdlah: +LastFoundExist
  if (vindov=4)
     Gui, Mouser: +LastFoundExist
  VarSetCapacity(rect, 16, 0)
  DllCall("GetClientRect", "Ptr", MyGuiHWND := WinExist(), "Ptr", &rect)
  W := NumGet(rect, 8, "UInt")
  H := NumGet(rect, 12, "UInt")
}

modsTimer() {
    Critical, Off
    Thread, Priority, -50

    globalPrefix := ""
    for i, mod in MainModsList
    {
        if GetKeyState(mod)
           profix .= mod "+"
    }
    globalPrefix := profix
}

GetKeyStr() {
; Sleep, 40 ; megatest
    if (NeverDisplayOSD=1)
       Return

    modifiers_temp := 0
    Static FriendlyKeyNames := {NumpadDot:"[ . ]", NumpadDiv:"[ / ]", NumpadMult:"[ * ]", NumpadAdd:"[ + ]", NumpadSub:"[ - ]", numpad0:"[ 0 ]", numpad1:"[ 1 ]", numpad2:"[ 2 ]", numpad3:"[ 3 ]", numpad4:"[ 4 ]", numpad5:"[ 5 ]", numpad6:"[ 6 ]", numpad7:"[ 7 ]", numpad8:"[ 8 ]", numpad9:"[ 9 ]", NumpadEnter:"[Enter]", NumpadDel:"[Delete]", NumpadIns:"[Insert]", NumpadHome:"[Home]", NumpadEnd:"[End]", NumpadUp:"[Up]", NumpadDown:"[Down]", NumpadPgdn:"[Page Down]", NumpadPgup:"[Page Up]", NumpadLeft:"[Left]", NumpadRight:"[Right]", NumpadClear:"[Clear]", Media_Play_Pause:"Media_Play/Pause", MButton:"Middle Click", RButton:"Right Click", Del:"Delete", PgUp:"Page Up", PgDn:"Page Down"}
    for i, mod in MainModsList
    {
        if GetKeyState(mod)
           prefix .= mod "+"
    }

    if !prefix && globalPrefix
       prefix := globalPrefix
    globalPrefix := ""
    SetTimer, modsTimer, Off
    if (!prefix && !ShowSingleKey)
        throw

    key := A_ThisHotkey
    StringRight, backupKey, key, 1
    key := RegExReplace(key, "i)^(~\+\$vk)", "vk")
    key := RegExReplace(key, "i)^(~\+\^!|~\+<!<\^|~\+<!>\^|~\+<\^>!|~<\^>!|~!#\^\+|~<\^<!|~>\^>!|~\^!|~#!\+|~#!\^|~#\+\^|~\+!\^|~!#\^|~!\+\^|~!#|~\+#|~#\^|~!\+|~!\^|~\+\^|~#!|~\*|~\^|~!|~#|~\+)")
    StringReplace, key, key, ~,
    if (sendJumpKeys=1)
    {
        StringReplace, key, key, +^Left, Left
        StringReplace, key, key, +^Right, Right
        StringReplace, key, key, ^Left, Left
        StringReplace, key, key, ^Right, Right
        StringReplace, key, key, ^Del, Del
        StringReplace, key, key, ^Back, Back
        StringReplace, key, key, +Left, Left
        StringReplace, key, key, +Right, Right
    }
    backupKey := !key ? backupKey : key

    if (StrLen(key)=1)
    {
        StringLeft, key, key, 2
        key := GetKeyChar(key)
    } else if (SubStr(key, 1, 2) = "sc") && (key != "ScrollLock") && StrLen(typed)<2 || (SubStr(key, 1, 2) = "vk") && StrLen(typed)<2 || (SubStr(key, 1, 2) = "vk") && prefix {
        key := (GetSpecialSC(key) || GetSpecialSC(key)=0) ? GetSpecialSC(key) : key
    } else if (StrLen(key)<1) && !prefix {
        key := (ShowDeadKeys=1) ? "◐" : "(unknown key)"
        key := backupKey ? backupKey : key
    } else if FriendlyKeyNames.hasKey(key) {
        key := FriendlyKeyNames[key]
    } else if (key = "Volume_Up") {
        Sleep, 40
        SoundGet, master_volume
        key := "Volume up: " Round(master_volume)
    } else if (key = "Volume_Down") {
        Sleep, 40
        SoundGet, master_volume
        key := "Volume down: " Round(master_volume)
    } else if (key = "Volume_mute") {
        SoundGet, master_volume
        SoundGet, master_mute, , mute
        if master_mute = on
           key := "Volume mute"
        if master_mute = off
           key := "Volume level: " Round(master_volume)
    } else if (key = "PrintScreen") {
        if (HideAnnoyingKeys=1 && !prefix) || (OnlyTypingMode=1)
            throw
        key := "Print Screen"
    } else if (key ~= "i)(wheel)") {
        if (ShowMouseButton=0 || OnlyTypingMode=1)
           throw
        else
           StringReplace, key, key, wheel, wheel%A_Space%
    } else if (key = "LButton") && IsDoubleClick() {
        key := "Double Click"
    } else if (key ~= "i)(lock)") && !prefixed {
        key := GetCrayCrayState(key)
    } else if (key = "LButton") {
        if (HideAnnoyingKeys=1 && !prefix)
        {
            if (!(typed ~= "i)(  │)") && strlen(typed)>3 && (ShowMouseButton=1) && (A_TickCount - lastTypedSince > 2000)) {
                if !InStr(typed, lola2)
                   InsertChar2caret(" ")
            }
            throw
        }
        key := "Left Click"
    }
    _key := key        ; what's this for? :)
    prefix := CompactModifiers(prefix)
    Sort, prefix, U D+
    StringReplace, prefix, prefix, +, %A_Space%+%A_Space%, All
    Static pre_prefix, pre_key
    if (OnlyTypingMode=1)
       keyCount := 0
    StringUpper, key, key, T
    if InStr(key, "lock on")
       StringUpper, key, key
    StringUpper, pre_key, pre_key, T
    keyCount := (key=pre_key) && (prefix = pre_prefix) && (repeatCount<1.5) ? keyCount : 1
    if ((ShowPrevKey=1) && (keyCount<2) && (A_TickCount-tickcount_start < ShowPrevKeyDelay) && (!(pre_key ~= "i)^(vk|Media_|Volume|Caps lock|Num lock|Scroll lock)")))
    {
        ShowPrevKeyValid := 0
        if ((prefix != pre_prefix && key=pre_key) || (key!=pre_key && !prefix) || (key!=pre_key && pre_prefix))
        {
           ShowPrevKeyValid := (OnlyTypingMode=1) ? 0 : 1
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
    
    if (prefix != pre_prefix)
    {
        result := (ShowPrevKeyValid=1) ? prefix key " {" pre_prefix pre_key "}" : prefix key
        keyCount := 1
    } else if (ShowPrevKeyValid=1)
    {
        key := (Round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" Round(keyCount) ")") : (key ", " pre_key)
    } else if (ShowPrevKeyValid=0)
    {
        key := (Round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" Round(keyCount) ")") : (key)
    } else
    {
        keyCount := 1
    }
    pre_prefix := prefix
    pre_key := _key
    prefixed := prefix ? 1 : 0
    Return result ? result : prefix . key
}

CompactModifiers(ztr) {
    CompactPattern := {"LCtrl":"Ctrl", "RCtrl":"Ctrl", "LShift":"Shift", "RShift":"Shift", "LAlt":"Alt", "LWin":"WinKey", "RWin":"WinKey", "RAlt":"AltGr"}
    if (DifferModifiers=0)
    {
        StringReplace, ztr, ztr, LCtrl+RAlt, AltGr, All
        StringReplace, ztr, ztr, AltGr+RAlt, AltGr, All
        StringReplace, ztr, ztr, AltGr+LCtrl, AltGr, All
        for k, v in CompactPattern
            StringReplace, ztr, ztr, %k%, %v%, All
    }
    Return ztr
}

GetCrayCrayState(key) {

    GetKeyState, keyState, %key%, T
    shtate := GetKeyState(key, "T")
    if (SecondaryTypingMode=1)
       shtate := !shtate
    if (shtate=1)
    {
       tehResult := key " ON"
    } else
    {
       tehResult := key " off"
    }
    StringReplace, tehResult, tehResult, lock, %A_SPACE%lock
    Return tehResult
}

GetSpecialSC(sc) {

    k := {sc11d: "(special key)", sc146: "Pause/Break", sc123: "Genius LuxeMate Scroll"}

    if !k[sc]
    {
       brr := GetKeyChar(sc)
       StringLeft, brr, brr, 1
       k[sc] := brr
    }

    if !k[sc]
       k[sc] := GetKeyName(sc)

    Return k[sc]
}

GetDeadKeySymbol(hotkeya) {
   lenghty := InStr(SCnames2, hotkeya)
   lenghty := (lenghty=0) ? 2 : lenghty
   symbol := SubStr(SCnames2, lenghty-1, 1)
   symbol := (symbol="") || (symbol="v") || (symbol="k") ? "▪" : symbol
   Return symbol
}

; <tmplinshi>: thanks to Lexikos: https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236

GetKeyChar(Key) {
; Sleep, 30 ; megatest

    if (key ~= "i)^(vk)")
    {
       sc := "0x0" GetKeySC(Key)
       sc := sc + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 3)
    } else if (StrLen(key)>7)
    {
       sc := SubStr(key, InStr(key, "sc")+2, 3) + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 2)
       vk := vk + 0
    } else
    {
       sc := GetKeySC(Key)
       vk := GetKeyVK(Key)
    }

    nsa := DllCall("MapVirtualKey", "UInt", vk, "UInt", 2)
    if (nsa<=0) && (DeadKeys=0)
       Return

    thread := DllCall("GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "UInt", thread, "UInt")

    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)

    n := DllCall("ToUnicodeEx", "UInt", vk, "UInt", sc, "Ptr", &state, "Ptr", &char, "Int", 2, "UInt", 0, "Ptr", hkl)
    n := DllCall("ToUnicodeEx", "UInt", vk, "UInt", sc, "Ptr", &state, "Ptr", &char, "Int", 2, "UInt", 0, "Ptr", hkl)
    Return StrGet(&char, n, "utf-16")
}

IdentifyKBDlayout() {
  if (AutoDetectKBD=1) && (ForceKBD=0)
    kbLayoutRaw := checkWindowKBD()

  if (ForceKBD=1)
     kbLayoutRaw := (ForcedKBDlayout = 0) ? ForcedKBDlayout1 : ForcedKBDlayout2

  #Include *i %A_Scriptdir%\keypress-files\keypress-osd-languages.ini
  if (!FileExist("keypress-files\keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled) || (FileExist("keypress-files\keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled)
  {
      SoundBeep
      ShowLongMsg("Downloading language definitions file... Please wait.")
      downLangFile()
      SetTimer, HideGUI, % -DisplayTime*2
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

  check_kbd_exact := StrLen(LangRaw_%kbLayoutRaw%)>2 ? 1 : 0
  langFriendlySysName := GetLayoutDisplayName(kbLayoutRaw)
  StringRight, kbLayoutRawShort, kbLayoutRaw, 5
  if (check_kbd_exact=0) && (loadedLangz=1)
  {
      if (StrLen(langFriendlySysName)<2)
      {
         ShowLongMsg("Unrecognized layout: (" kbLayoutRaw ")")
         CurrentKBD := kbLayoutRaw ". Layout unrecognized."
      } else
      {
         ShowLongMsg("Unsupported: " langFriendlySysName " (" kbLayoutRawShort ")")
         CurrentKBD := langFriendlySysName " ("  kbLayoutRawShort "). Layout unsupported."
      }
      SetTimer, HideGUI, % -DisplayTime
      SoundBeep, 500, 900
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
  } else if (check_kbd_exact=1)
  {
      AlternativeHook2keys := 0
  }

  if (check_kbd_exact=1) && (loadedLangz=1)
  {
      identifiedKbdName := LangRaw_%kbLayoutRaw%
      CurrentKBD := "Auto-detected: " identifiedKbdName ". " kbLayoutRaw
      if (ForceKBD=1)
         CurrentKBD := "Enforced: " identifiedKbdName ". " kbLayoutRaw

      if (SilentDetection=0)
      {
          if (ForceKBD!=1)
             ShowLongMsg("Layout detected: " identifiedKbdName)
          else
             ShowLongMsg("Enforced layout: " identifiedKbdName)
          SetTimer, HideGUI, % -DisplayTime/2
      }
  }

    if (AutoDetectKBD=1) && (loadedLangz=1)
    {
       identifiedKbdName := (check_kbd_exact=0) ? "! " langFriendlySysName : LangRaw_%kbLayoutRaw%
       StringLeft, clayout, identifiedKbdName, 25
       Menu, Tray, Add, %clayout%, dummy
       Menu, Tray, Disable, %clayout%
       Menu, Tray, Add
    }

    if (ConstantAutoDetect=1) && (AutoDetectKBD=1) && (loadedLangz=1) && (ForceKBD=0)
       SetTimer, dummyDelayer, 5000, 915
}

checkInstalledLangs() {
  #IncludeAgain *i %A_Scriptdir%\keypress-files\keypress-osd-languages.ini

  Loop, 30
  {
    RegRead, langInstalled, HKEY_CURRENT_USER, Keyboard Layout\Preload, %A_Index%
    if (ErrorLevel=1)
       stopNow := 1

    RegRead, langRealInstalled, HKEY_CURRENT_USER, Keyboard Layout\Substitutes, %langInstalled%
    if (ErrorLevel=1)
       langRealInstalled := langInstalled
    langFriendlySysName := GetLayoutDisplayName(langRealInstalled)
    ; RegRead, langFriendlySysName, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%langRealInstalled%, Layout Text
    StringRight, ShortKBDcode, langRealInstalled, 5
    StringUpper, ShortKBDcode, ShortKBDcode

    if (LangRaw_%langRealInstalled%)
    {
       niceMenuName := LangRaw_%langRealInstalled%
       Menu, kbdList, add, %ShortKBDcode%: %niceMenuName%, ForceSpecificLanguage
       if (langRealInstalled = kbLayoutRaw) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %ShortKBDcode%: %niceMenuName%
    } else if StrLen(langFriendlySysName)>1
    {
       niceMenuName := langFriendlySysName
       Menu, kbdList, add, %ShortKBDcode%: %niceMenuName%, dummy
       Menu, kbdList, Disable, %ShortKBDcode%: %niceMenuName%
       if (langRealInstalled = kbLayoutRaw) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %ShortKBDcode%: %niceMenuName%
    } else if (langRealInstalled)
    {
       Menu, kbdList, add, %ShortKBDcode% unrecognized layout, dummy
       Menu, kbdList, Disable, %ShortKBDcode%: unrecognized layout
       if (langRealInstalled = kbLayoutRaw) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %ShortKBDcode%: unrecognized layout
    }
  } Until (stopNow=1)
}

ForceSpecificLanguage() {
    ForceKBD := 1
    AutoDetectKBD := 1
    StringLeft, MenuSelected, A_ThisMenuItem, 5
    if (ForcedKBDlayout=0)
       ForcedKBDlayout1 := "000" MenuSelected
    if (ForcedKBDlayout=1)
       ForcedKBDlayout2 := "000" MenuSelected
    CreateOSDGUI()
    ShowLongMsg("Switching keyboard layout...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    IniWrite, %ForcedKBDlayout1%, %IniFile%, SavedSettings, ForcedKBDlayout1
    IniWrite, %ForcedKBDlayout2%, %IniFile%, SavedSettings, ForcedKBDlayout2
    Sleep, 1100
    ReloadScript()
}

dummyDelayer() {
  Thread, Priority, -20
  Critical, off

  kbdList_count := DllCall("GetMenuItemCount", "Ptr", MenuGetHandle("kbdList"))
  if (kbdList_count>1)
     SetTimer, ConstantKBDtimer, 950, -25

  SetTimer,, off
}

ConstantKBDtimer() {
    if (A_TimeIdle > 5000)
       Return

    if A_IsSuspended || (SecondaryTypingMode=1) || (A_TickCount - lastTypedSince < 1000) || (A_TickCount - deadKeyPressed < 6900)
       Return

    Critical, off
    newLayout := checkWindowKBD()
    if (newLayout!=kbLayoutRaw)
    {
       if (SilentDetection=0) && (SilentMode=0)
          beeperzDefunctions.ahkPostFunction["firingKeys", ""]
       if (A_TickCount - lastTypedSince > 2000) && (A_TickCount - tickcount_start > 1000)
          ReloadScript()
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
    Thread, Priority, -20
    Critical, off
    if (SecondaryTypingMode=1)
       Return
    OSDvisible := 0
    Gui, OSD: Hide
    SetTimer, checkMousePresence, off
}

checkMousePresence() {
    if (A_TickCount - lastTypedSince < 1500) || (A_TickCount - deadKeyPressed < 2000)
       Return

    Thread, Priority, -20
    Critical, off

    WinGetTitle, activeWindow, A
    if (activeWindow ~= "i)^(KeyPressOSDwin)") && (DragOSDmode=0) && (SecondaryTypingMode=0)
       HideGUI()

    if (JumpHover=1) && !A_IsSuspended && (DragOSDmode=0) && (prefOpen=0)
    {
        MouseGetPos, , , id, control
        WinGetTitle, title, ahk_id %id%
        if (title = "KeyPressOSDwin")
           TogglePosition()
    }
}

RegisterGlobalShortcuts(HotKate,destination,apriori) {
   if InStr(hotkate, "disable")
      Return HotKate

   Hotkey, %HotKate%, %destination%, UseErrorLevel
   if (ErrorLevel!=0)
   {
      Hotkey, %apriori%, %destination%
      Return apriori
   }
   Return HotKate
}

CreateGlobalShortcuts() {

    KBDsuspend := RegisterGlobalShortcuts(KBDsuspend,"SuspendScript", "+Pause")
    if (alternateTypingMode=1)
       KBDaltTypeMode := RegisterGlobalShortcuts(KBDaltTypeMode,"SwitchSecondaryTypingMode", "^CapsLock")

    if (pasteOSDcontent=1) && (DisableTypingMode=0)
    {
       KBDpasteOSDcnt1 := RegisterGlobalShortcuts(KBDpasteOSDcnt1,"sendOSDcontent", "^+Insert")
       KBDpasteOSDcnt2 := RegisterGlobalShortcuts(KBDpasteOSDcnt2,"sendOSDcontent2", "^+!Insert")
    }

    if (DisableTypingMode=0) && (KeyboardShortcuts=1)
    {
       KBDsynchApp1 := RegisterGlobalShortcuts(KBDsynchApp1,"SynchronizeApp", "#Insert")
       KBDsynchApp2 := RegisterGlobalShortcuts(KBDsynchApp2,"SynchronizeApp2", "#!Insert")
    }

    if (KeyboardShortcuts=1)
    {
       KBDTglForceLang := RegisterGlobalShortcuts(KBDTglForceLang,"ToggleForcedLanguage", "!+^F7")
       KBDTglNeverOSD := RegisterGlobalShortcuts(KBDTglNeverOSD,"ToggleNeverDisplay", "!+^F8")
       KBDTglPosition := RegisterGlobalShortcuts(KBDTglPosition,"TogglePosition", "!+^F9")
       KBDidLangNow := RegisterGlobalShortcuts(KBDidLangNow,"DetectLangNow", "!+^F11")
       KBDReload := RegisterGlobalShortcuts(KBDReload,"ReloadScriptNow", "!+^F12")
       KBDTglCap2Text := RegisterGlobalShortcuts(KBDTglCap2Text,"ToggleCapture2Text", "!Pause")
     }
}

SynchronizeApp() {
  if (A_IsSuspended=1 || NeverDisplayOSD=1 || SecondaryTypingMode=1)
     Return
  clipBackup := ClipboardAll
  Clipboard := ""
  if (synchronizeMode=0)
  {
      Sleep, 15
      Sendinput {LCtrl Down}
      Sleep, 15
      Sendinput {vk41}
      Sleep, 15
      Sendinput {vk43}
      Sleep, 15
      Sendinput {LCtrl Up}
      Sleep, 15
      Sendinput {Right}
      Sleep, 15
      Sendinput {End 2}
  } else if (synchronizeMode=1)
  {
      Sleep, 15
      Sendinput {LShift Down}
      Sleep, 15
      Sendinput {Up 2}
      Sleep, 15
      Sendinput {Home 2}
      Sleep, 15
      Sendinput {LShift Up}
      Sleep, 15
      Sendinput ^{vk43}
      Sleep, 15
      Sendinput {Right}
  } else
  {
      Sleep, 15
      Sendinput {End 2}
      Sleep, 15
      Sendinput {LShift Down}
      Sleep, 15
      Sendinput {Home 2}
      Sleep, 15
      Sendinput {LShift Up}
      Sleep, 15
      Sendinput ^{vk43}
      Sleep, 15
      Sendinput {Left}
      Sleep, 15
      Sendinput {Right}
      Sleep, 15
      Sendinput {End 2}
  }
  Sleep, 25
  if (StrLen(Clipboard)<1)
     ClipWait, 1

  if (StrLen(Clipboard)>0)
  {
     StringRight, typed, Clipboard, 950
     StringReplace, typed, typed, %A_TAB%, %A_SPACE%, All
     StringReplace, typed, typed, `r`n, %A_SPACE%, All
     CaretPos := StrLen(typed)+1
     typed := ST_Insert(lola, typed, CaretPos)
  }
  Global lastTypedSince := A_TickCount
  keyCount := 1
  CalcVisibleText()
  ShowHotkey(visibleTextField)
  SetTimer, HideGUI, % -DisplayTimeTyping
  Clipboard := clipBackup
  clipBackup := " "
}

SynchronizeApp2() {
  if (SecondaryTypingMode=1) || (A_IsSuspended=1)
     Return
  synchronizeMode := 5
  SynchronizeApp()
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
}

sendOSDcontent2() {
  if (SecondaryTypingMode=1) || (A_IsSuspended=1)
     Return
  synchronizeMode := 10
  sendOSDcontent()
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
}

sendOSDcontent() {
  if (A_IsSuspended=1 || NeverDisplayOSD=1)
     Return
  typed := backtypeCtrl
  if (StrLen(typed)>2)
  {
     StringReplace, typed, typed, %lola%
     StringReplace, typed, typed, %lola2%
     Sleep, 25
     if (synchronizeMode=10)
     {
        Sendinput ^{vk41}
        Sleep, 25
     }
     Sendinput {text}%typed%
     Sleep, 25
     CaretPos := StrLen(typed)+1
     typed := ST_Insert(lola, typed, CaretPos)
     Global lastTypedSince := A_TickCount
     CalcVisibleText()
     ShowHotkey(visibleTextField)
     SetTimer, HideGUI, % -DisplayTimeTyping
  }
}

SuspendScript() {        ; Shift+Pause/Break
   Suspend, Permit
   Thread, Priority, 50
   Critical, On

   if (SecondaryTypingMode=1)
      Return

   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }
 
   ScriptelSuspendel := A_IsSuspended ? 0 : 1
   IniWrite, %ScriptelSuspendel%, %IniFile%, TempSettings, ScriptelSuspendel
   if (Capture2Text=1)
      ToggleCapture2Text()
   Sleep, 50
   Menu, Tray, UseErrorLevel
   Menu, Tray, Rename, &KeyPress activated,&KeyPress deactivated
   if (ErrorLevel=1)
   {
      Menu, Tray, Rename, &KeyPress deactivated,&KeyPress activated
      Menu, Tray, Check, &KeyPress activated
   }
   Menu, Tray, Uncheck, &KeyPress deactivated
   CreateOSDGUI()
   typed := ""
   backTypeCtrl := ""
   backTypdUndo := ""
   ShowLongMsg("KeyPress OSD toggled")
   mouseFonctiones.ahkReload[]
   beeperzDefunctions.ahkReload[]
   mouseRipplesThread.ahkReload[]
   SetTimer, HideGUI, % -DisplayTime/6
   Sleep, DisplayTime/6+15
   Suspend
}

ToggleConstantDetection() {
   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   AutoDetectKBD := 1
   ConstantAutoDetect := !ConstantAutoDetect
   IniWrite, %ConstantAutoDetect%, %IniFile%, SavedSettings, ConstantAutoDetect
   IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
   Menu, Tray, % (ConstantAutoDetect=0 ? "Uncheck" : "Check"), &Monitor keyboard layout
   if (ConstantAutoDetect=1)
      SetTimer, ConstantKBDtimer, 950, -25
   else
      SetTimer, ConstantKBDtimer, off
   Sleep, 500
}

ToggleNeverDisplay() {
   if (SecondaryTypingMode=1)
      Return

   typed := ""
   backTypeCtrl := ""
   backTypdUndo := ""
   NeverDisplayOSD := !NeverDisplayOSD
   IniWrite, %NeverDisplayOSD%, %IniFile%, SavedSettings, NeverDisplayOSD
   Menu, Tray, % (NeverDisplayOSD=0 ? "Uncheck" : "Check"), &Never show the OSD
   ShowLongMsg("Never display OSD = " NeverDisplayOSD)
   SetTimer, HideGUI, % -DisplayTime/2
}

TogglePosition() {
    if (A_IsSuspended=1 || NeverDisplayOSD=1)
    {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
    }
    if (SecondaryTypingMode=1)
       Return

    if (DragOSDmode=1)
    {
      IniRead, GuiXa, %inifile%, SavedSettings, GuiXa, %GuiXa%
      IniRead, GuiXb, %inifile%, SavedSettings, GuiXb, %GuiXb%
      IniRead, GuiYa, %inifile%, SavedSettings, GuiYa, %GuiYa%
      IniRead, GuiYb, %inifile%, SavedSettings, GuiYb, %GuiYb%
    }

    GUIposition := !GUIposition
    Gui, OSD: hide
    GuiX := (GUIposition=1) ? GuiXa : GuiXb
    GuiY := (GUIposition=1) ? GuiYa : GuiYb
    OSDalignment := (GUIposition=1) ? OSDalignment2 : OSDalignment1
    niceNaming := (GUIposition = 1) ? "A" : "B"
    Gui, OSD: Destroy
    Sleep, 20
    CreateOSDGUI()
    Sleep, 20

    if (Capture2Text!=1)
    {
        IniWrite, %GUIposition%, %IniFile%, SavedSettings, GUIposition
        ShowLongMsg("OSD position: " niceNaming )
        Sleep, 450
        ShowLongMsg("OSD position: " niceNaming )
        SetTimer, HideGUI, % -DisplayTime/3
        Gui, OSD: Destroy
        Sleep, 20
        CreateOSDGUI()
        Sleep, 20 
    }
}

ToggleForcedLanguage() {
    ReloadCounter := 1
    IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    ForceKBD := 1
    AutoDetectKBD := 1
    ForcedKBDlayout := !ForcedKBDlayout
    niceNaming := (ForcedKBDlayout = 0) ? "A" : "B"
    CreateOSDGUI()
    ShowLongMsg("Switching layout to preset " niceNaming "...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    Sleep, 1100
    ReloadScript()
}

ToggleSilence() {
    SilentMode := !SilentMode
    IniWrite, %SilentMode%, %IniFile%, SavedSettings, SilentMode
    mouseFonctiones.ahkReload[]
    beeperzDefunctions.ahkReload[]
    Menu, SubSetMenu, % (SilentMode=0 ? "Uncheck" : "Check"), S&ilent mode
    Sleep, 400
}

DetectLangNow() {
    ReloadCounter := 1
    IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    CreateOSDGUI()
    ForceKBD := 0
    AutoDetectKBD := 1
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    ShowLongMsg("Detecting keyboard layout...")
    Sleep, 1100
    ReloadScript()
}

ReloadScriptNow() {
    ReloadScript(0)
}

ReloadScript(silent:=1) {
    Thread, Priority, 50
    Critical, on
    CreateOSDGUI()
    mouseFonctiones.ahkTerminate[]
    beeperzDefunctions.ahkTerminate[]
    mouseRipplesThread.ahkTerminate[]
    thisFile := A_ScriptName
    if FileExist(thisFile)
    {
        if (silent!=1)
        {
           ShowLongMsg("Restarting...")
           Sleep, 1100
        }
        prefOpen := 0
        IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
        Reload
    } else
    {
        ShowLongMsg("FATAL ERROR: Main file missing. Execution terminated.")
        SoundBeep
        Sleep, 1000
        MsgBox, 4,, Do you want to choose another file to execute?
        IfMsgBox Yes
        {
            FileSelectFile, i, 2, %A_ScriptDir%\%A_ScriptName%, Select a different script to load, AutoHotkey script (*.ahk; *.ah1u)
            if !InStr(FileExist(i), "D")  ; we can't run a folder, we need to run a script
               Run, %i%
        } else
        {
            Sleep, 500
        }
        ExitApp
    }
}

ToggleCapture2Text() {
    if (A_IsSuspended=1 || NeverDisplayOSD=1 || SecondaryTypingMode=1)
    {
       SoundBeep, 300, 900
       Return
    }
    Critical, off
    Thread, Priority, -20
    featureValidated := 1
    DetectHiddenWindows, on
    IfWinNotExist, Capture2Text
    {
        if (Capture2Text!=1)
        {
            SoundBeep, 1900
            MsgBox, 4,, Capture2Text was not detected. Do you want to continue?
            IfMsgBox, Yes
                featureValidated := 1
            else
                featureValidated := 0
        }
    }

    if (featureValidated=1)
    {
        Menu, Tray, Check, &Capture2Text mode
        Sleep, 300
        Capture2Text := !Capture2Text
    }

    if (Capture2Text=1) && (featureValidated=1)
    {
        JumpHover := 1
        if (ClipMonitor=0)
        {
           ClipMonitor := 1
           OnClipboardChange("ClipChanged")
        }
        DragOSDmode := 0
        SetTimer, capturetext, 1500, -20
        mouseFonctiones.ahkTerminate[]
        mouseRipplesThread.ahkTerminate[]
        ShowLongMsg("Enabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime/7
    } else if (featureValidated=1)
    {
        Capture2Text := !Capture2Text
        IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
        GuiX := (GUIposition=1) ? GuiXa : GuiXb
        GuiY := (GUIposition=1) ? GuiYa : GuiYb
        IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
        IniRead, DragOSDmode, %inifile%, SavedSettings, DragOSDmode, %DragOSDmode%
        Gui, OSD: Destroy
        Sleep, 50
        CreateOSDGUI()
        Sleep, 50
        IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
        Menu, Tray, Uncheck, &Capture2Text mode
        mouseFonctiones.ahkReload[]
        mouseRipplesThread.ahkReload[]
        SetTimer, capturetext, off
        Capture2Text := !Capture2Text
        ShowLongMsg("Disabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
    }
    Sleep, 15
    Pause, off
    DetectHiddenWindows, off
}

capturetext() {
    Critical, off
    Thread, Priority, -50
    if ((A_TimeIdlePhysical < 3000) && !A_IsSuspended && (A_TickCount-lastTypedSince > 1500))
       SendInput, {Pause}             ; set here the keyboard shortcut configured in Capture2Text
    Sleep, 1
}

ClipChanged(Type) {
    if (A_IsSuspended=1 || NeverDisplayOSD=1)
        Return
    Thread, Priority, -20
    Critical, off
    Sleep, 25
    if ((type=1) && (ClipMonitor=1) && (A_TickCount-lastTypedSince > DisplayTimeTyping/2))
    {
       troll := clipboard
       Stringleft, troll, troll, 150
       StringReplace, troll, troll, `r`n, %A_SPACE%, All
       StringReplace, troll, troll, %A_SPACE%%A_SPACE%, %A_SPACE%, All
       StringReplace, troll, troll, %A_TAB%, %A_SPACE%%A_SPACE%, All
       ShowLongMsg(troll)
       SetTimer, HideGUI, % -DisplayTime*2
    } else if (type=2 && ClipMonitor=1 && (A_TickCount-lastTypedSince > DisplayTimeTyping))
    {
       ShowLongMsg("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

InitializeTray() {
    Menu, SubSetMenu, Add, &Keyboard, ShowKBDsettings
    Menu, SubSetMenu, Add, &Typing mode, ShowTypeSettings
    Menu, SubSetMenu, Add, &Sounds, ShowSoundsSettings
    Menu, SubSetMenu, Add, &Mouse, ShowMouseSettings
    Menu, SubSetMenu, Add, &OSD appearances, ShowOSDsettings
    Menu, SubSetMenu, Add, &Global shortcuts, ShowShortCutsSettings
    Menu, SubSetMenu, Add
    Menu, SubSetMenu, Add, S&ilent mode, ToggleSilence
    Menu, SubSetMenu, Add, Start at boot, SetStartUp
    Menu, SubSetMenu, Add
    Menu, SubSetMenu, Add, Restore defaults, DeleteSettings
    Menu, SubSetMenu, Add
    Menu, SubSetMenu, Add, Key &history, KeyHistoryWindow
    Menu, SubSetMenu, Add
    Menu, SubSetMenu, Add, &Check for updates, updateNow

    regEntry := """" A_ScriptFullPath """"
    RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
    if (currentReg=regEntry)
       Menu, SubSetMenu, Check, Start at boot

    if (SilentMode=1)
       Menu, SubSetMenu, Check, S&ilent mode

    if !FileExist("keypress-files\keypress-beeperz-functions.ahk")
    {
       Menu, SubSetMenu, Disable, S&ilent mode
       Menu, SubSetMenu, Disable, &Sounds
    }
    if !FileExist("keypress-files\keypress-mouse-functions.ahk")
       Menu, SubSetMenu, Disable, &Mouse

    Menu, tray, tip, KeyPress OSD v%version%
    Menu, tray, NoStandard

    kbdList_count := DllCall("GetMenuItemCount", "Ptr", MenuGetHandle("kbdList"))
    if (AutoDetectKBD=1) && (ForceKBD=0) && (loadedLangz=1) && (kbdList_count>1)
    {
       Menu, Tray, Add, &Monitor keyboard layout, ToggleConstantDetection
       Menu, tray, check, &Monitor keyboard layout
       if (ConstantAutoDetect=0)
          Menu, tray, uncheck, &Monitor keyboard layout
    }

    if (loadedLangz=1) && (kbdList_count>1)
       Menu, Tray, Add, &Installed keyboard layouts, :kbdList

    if (ConstantAutoDetect=0) && (ForceKBD=0) && (loadedLangz=1)
    {
       Menu, Tray, Add, &Detect keyboard layout now, DetectLangNow
       if (kbdList_count>1)
          Menu, Tray, Add, &Monitor keyboard layout, ToggleConstantDetection
    }
    Menu, Tray, Add
    Menu, Tray, Add, &Preferences, :SubSetMenu
    Menu, Tray, Add

    if (ForceKBD=1) && (loadedLangz=1)
    {
       niceNaming := (ForcedKBDlayout = 0) ? "A" : "B"
       Menu, Tray, Add, Toggle &forced layout (%niceNaming%), ToggleForcedLanguage
       Menu, Tray, Add
    }

    if (ConstantAutoDetect=0) && (loadedLangz=1)
       Menu, Tray, Add, &Detect keyboard layout now, DetectLangNow

    Menu, Tray, Add, &Toggle OSD positions, TogglePosition
    Menu, Tray, Add, &Never show the OSD, ToggleNeverDisplay
    Menu, Tray, Add, &Capture2Text mode, ToggleCapture2Text
    Menu, Tray, Add
    Menu, Tray, Add, &KeyPress activated, SuspendScript
    Menu, tray, Check, &KeyPress activated
    Menu, Tray, Add, &Restart, ReloadScriptNow
    Menu, Tray, Add
    Menu, Tray, Add, &Troubleshooting, HelpFAQstarter
    Menu, Tray, Add, &Help, HelpStarter
    Menu, Tray, Add, &About, AboutWindow
    Menu, Tray, Add
    Menu, Tray, Add, E&xit, KillScript

    if (NeverDisplayOSD=1)
       Menu, tray, Check, &Never show the OSD

    presentationHtml := "keypress-files\help\presentation.html"
    faqHtml := "keypress-files\help\faq.html"
    if !FileExist(presentationHtml)
       Menu, tray, Disable, &Help
       
    if !FileExist(faqHtml)
       Menu, tray, Disable, &Troubleshooting
}

KeyHistoryWindow() {
  KeyHistory
}

HelpStarter() {
  Run, %A_WorkingDir%\keypress-files\help\presentation.html
}

HelpFaqStarter() {
  Run, %A_WorkingDir%\keypress-files\help\faq.html
}

DeleteSettings() {
    MsgBox, 4,, Are you sure you want to delete the stored settings?
    IfMsgBox Yes
    {
       FileSetAttrib, -R, %IniFile%
       FileDelete, %IniFile%
       verifyNonCrucialFilesRan := 2
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
       ReloadScriptNow()
    }
}

KillScript() {
   Thread, Priority, 50
   Critical, on
   thisFile := A_ScriptName
   mouseFonctiones.ahkTerminate[]
   beeperzDefunctions.ahkTerminate[]
   mouseRipplesThread.ahkTerminate[]

   if FileExist(thisFile)
   {
      ShaveSettings()
      ShowLongMsg("Bye byeee :-)")
      Sleep, 350
   } else
   {
      ShowLongMsg("Adiiooosss :-(((")
      Sleep, 1550
      SoundBeep, 600, 200
      Sleep, 150
      SoundBeep, 500, 100
      Sleep, 150
      SoundBeep, 400, 50
      Sleep, 150
      SoundBeep, 300, 25
      Sleep, 150
      SoundBeep, 200, 25
      Sleep, 150
      SoundBeep, 100, 25
   }
   ExitApp
}

SettingsGUI() {
   Global
   Gui, SettingsGUIA: Destroy
   Sleep, 15
   Gui, SettingsGUIA: Default
   Gui, SettingsGUIA: -SysMenu
   Gui, SettingsGUIA: Margin, 15, 15
}

initSettingsWindow() {
    Global ApplySettingsBTN
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        doNotOpen := 1
        Return doNotOpen
    }

    if (A_IsSuspended!=1)
       SuspendScript()

    prefOpen := 1
    IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
    Sleep, 50
    SettingsGUI()
}

ShowTypeSettings() {
    Global reopen
    if !reopen
    {
        doNotOpen := initSettingsWindow()
        if (doNotOpen=1)
           Return

        Global editF1, editF2, editF3
        Global showHelp := 0
    }
    deadKstatus := (DeadKeys=1) ? "Dead keys present." : "."

    Gui, Add, Tab3,, General|Dead keys|Behavior
    Gui, Tab, 1 ; general
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys in the OSD (mandatory for the main typing mode)
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%enableAltGr% venableAltGr, Enable {Ctrl + Alt} / {AltGr} support
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%DisableTypingMode% vDisableTypingMode, Disable main typing mode
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%MediateNavKeys% vMediateNavKeys, Mediate {Home} / {End} keys presses
    if (showHelp=1)
    {
       Gui, Add, Text, xp+15 y+5 w350, This can ensure a stricter synchronization with the host app when typing in short multi-line text fields. Key strokes will be sent to the host app that attempt to reproduce the caret location from the OSD.
       Gui, Add, Checkbox, xp-15 y+10 gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only
    } else
    {
       Gui, Add, Checkbox, y+10 gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only
    }

    if (showHelp=1)
    {
       Gui, Add, Text, xp+15 y+5 w350, The main typing mode works by attempting to shadow the host app. KeyPress will attempt to reproduce text cursor actions to mimmick text fields.
       Gui, Add, Checkbox, xp-15 y+10 gVerifyTypeOptions Checked%alternateTypingMode% valternateTypingMode, Enable global keyboard shortcut to enter in alternate typing mode
       Gui, Add, Text, xp+15 y+5 w350, Default shortcut: {Ctrl + CapsLock}. Type through KeyPress and send text on {Enter}. This ensures full support for dead keys and full predictability. In other words, what you see is what you typed - once you sent it to the host app. However, in Windows 7 or below, the keyboard layout of the host app might not match with the one of the OSD.
       Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%pasteOnClick% vpasteOnClick, Paste on click what you typed
    } else
    {
       Gui, Add, Checkbox, y+12 gVerifyTypeOptions Checked%alternateTypingMode% valternateTypingMode, Enable global keyboard shortcut to enter in alternate typing mode
       Gui, Add, Text, xp+15 y+5 w350, Type through KeyPress OSD and send text on {Enter}. Full support for dead keys and predictable results.
       Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%pasteOnClick% vpasteOnClick, Paste on click what you typed
    }
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%sendKeysRealTime% vsendKeysRealTime, Send keystrokes in realtime to the host app
    if (showHelp=1)
       Gui, Add, Text, xp+15 y+5 w350, This does not work with all appllications.

    Gui, Tab, 3  ; behavior
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%enableTypingHistory% venableTypingHistory, Typed text history (with {Page Up} / {Page Down})
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%pgUDasHE% vpgUDasHE, {Page Up} / {Page Down} should behave as {Home} / {End}
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%UpDownAsHE% vUpDownAsHE, {Up} / {Down} arrow keys should behave as {Home} / {End}
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%UpDownAsLR% vUpDownAsLR, ... or as the {Left} / {Right} keys
    if (showHelp=1)
       Gui, Add, Checkbox, xp-15 y+12 w350 gVerifyTypeOptions Checked%pasteOSDcontent% vpasteOSDcontent, Enable global shortcuts to paste the OSD content into the active text area. The default global keyboard shortcuts are {Ctrl + Shift + Insert} and {Ctrl + Alt + Insert}.
    else
       Gui, Add, Checkbox, xp-15 y+12 gVerifyTypeOptions Checked%pasteOSDcontent% vpasteOSDcontent, Enable global shortcuts to paste the OSD content into the active text area
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%synchronizeMode% vsynchronizeMode, Synchronize using {Shift + Up} && {Shift + Home} key sequence
    if (showHelp=1)
    {
        Gui, Add, Text, xp+15 y+5 w350, By default, {Ctrl + A}, select all, is used to capture the text from the host app. The default global keyboard shortcuts to synchronize are: {Winkey + Insert} and {Winkey + Alt + Insert}.
        Gui, Add, Checkbox, xp-15 y+10 gVerifyTypeOptions Checked%enterErasesLine% venterErasesLine, In "only typing" mode, {Enter} and {Escape} erase text from KeyPress
    } else Gui, Add, Checkbox, y+10 gVerifyTypeOptions Checked%enterErasesLine% venterErasesLine, In "only typing" mode, {Enter} and {Escape} erase text from KeyPress

    Gui, Add, Checkbox, y+10 gVerifyTypeOptions Checked%alternativeJumps% valternativeJumps, Alternative rules to jump between words with {Ctrl + Bksp / Del / Left / Right}
    if (showHelp=1)
    {
        Gui, Add, Text, xp+15 y+5, Please note, applications have inconsistent rules for this.
        Gui, Add, Checkbox, y+7 w350 gVerifyTypeOptions Checked%sendJumpKeys% vsendJumpKeys, Mediate the key strokes for caret jumps
        Gui, Add, Text, y+5 w350, This ensure higher predictability and chances of staying in synch. Key strokes that attempt to reproduce the actions you see in the OSD will be sent to the host app.
    } else Gui, Add, Checkbox, xp+15 y+7 w350 gVerifyTypeOptions Checked%sendJumpKeys% vsendJumpKeys, Mediate the key strokes for caret jumps

    Gui, Add, Text, xp-15 y+12, Display time when typing (in seconds)
    Gui, Add, Edit, xp+270 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyTypeOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Text, xp-270 yp+20, Time to resume typing with text related keys (in sec.)
    Gui, Add, Edit, xp+270 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %ReturnToTypingUser%
    Gui, Add, UpDown, vReturnToTypingUser gVerifyTypeOptions Range2-99, %ReturnToTypingUser%

    Gui, Tab, 2 ; dead keys
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%ShowDeadKeys% vShowDeadKeys, Insert generic dead key symbol when using such a key and typing
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%AltHook2keysUser% vAltHook2keysUser, Alternative hook to keys (applies to the main typing mode)
    if (showHelp=1)
    {
        Gui, Add, Text, xp+15 y+5 w350, This enables full support for dead keys. However, please note that some applications can interfere with this, e.g., Wox launcher.
        Gui, Font, Bold
        Gui, Add, Text, xp-15 y+10, Troubleshooting:
        Gui, Font, Normal
        Gui, Add, Text, xp+15 y+5 w350, if you cannot use dead keys on supported layouts in host apps, Increase the multiplier progressively until dead keys work. Apply settings and then test dead keys in the host app. if you cannot identify the right delay, activate "Do not bind".
        Gui, Add, Text, xp-15 y+10, Typing delays scale (1 = no delays)
    } else
    {
        Gui, Font, bold
        Gui, Add, Text, y+10 w350, if dead keys do not work, change these options:
        Gui, Font, normal
        Gui, Add, Text, y+10, Typing delays scale (1 = no delays)
    }
    Gui, Add, Edit, xp+190 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %typingDelaysScaleUser%
    Gui, Add, UpDown, vtypingDelaysScaleUser gVerifyTypeOptions Range1-40, %typingDelaysScaleUser%
    Gui, Add, Checkbox, xp-190 y+12 gVerifyTypeOptions Checked%DoNotBindDeadKeys% vDoNotBindDeadKeys, Do not bind (ignore) known dead keys
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%DoNotBindAltGrDeadKeys% vDoNotBindAltGrDeadKeys, Ignore dead keys associated with AltGr as well

    Gui, Font, Bold
    Gui, Add, Text, xp-15 y+15, Keyboard layout status: %deadKstatus%
    Gui, Font, Normal
    Gui, Add, Text, y+10 w350, %CurrentKBD%.
    Gui, Tab
    Gui, Add, Button, xm+10 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Add, Checkbox, x+15 yp+7 gTypeOptionsShowHelp Checked%showHelp% vShowHelp, Show contextual help

    Gui, Show, AutoSize, Typing mode settings: KeyPress OSD
    if !reopen
       VerifyTypeOptions(0)
}

TypeOptionsShowHelp() {
    GuiControlGet, ApplySettingsBTN, Enabled
    Gui, Submit
    Global reopen := 1
    Gui, SettingsGUIA: Destroy
    Sleep, 15
    ShowTypeSettings()
    VerifyTypeOptions(ApplySettingsBTN)
    Global reopen := 0
}

VerifyTypeOptions(enableApply:=1) {
    GuiControlGet, DisableTypingMode
    GuiControlGet, ShowSingleKey
    GuiControlGet, enableAltGr
    GuiControlGet, enableTypingHistory
    GuiControlGet, ShowDeadKeys
    GuiControlGet, DisplayTimeTypingUser
    GuiControlGet, ReturnToTypingUser
    GuiControlGet, OnlyTypingMode
    GuiControlGet, enterErasesLine
    GuiControlGet, pgUDasHE
    GuiControlGet, UpDownAsHE
    GuiControlGet, UpDownAsLR
    GuiControlGet, editF1
    GuiControlGet, editF2
    GuiControlGet, DoNotBindDeadKeys
    GuiControlGet, DoNotBindAltGrDeadKeys
    GuiControlGet, alternateTypingMode
    GuiControlGet, AltHook2keysUser
    GuiControlGet, pasteOnClick
    GuiControlGet, sendKeysRealTime
    GuiControlGet, sendJumpKeys
    GuiControlGet, MediateNavKeys
    GuiControlGet, showHelp

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    if (ShowSingleKey=0)
    {
       GuiControl, Disable, DisableTypingMode
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, UpDownAsHE
       GuiControl, Disable, UpDownAsLR
       GuiControl, Disable, alternativeJumps
       GuiControl, Disable, sendJumpKeys
       GuiControl, Disable, pasteOSDcontent
       GuiControl, Disable, synchronizeMode
       GuiControl, Disable, pgUDasHE
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, AltHook2keysUser
       GuiControl, Disable, MediateNavKeys
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, DisableTypingMode
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, pasteOSDcontent
       GuiControl, Enable, synchronizeMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, pgUDasHE
       GuiControl, Enable, UpDownAsHE
       GuiControl, Enable, alternativeJumps
       GuiControl, Enable, sendJumpKeys
       GuiControl, Enable, MediateNavKeys
       GuiControl, Enable, AltHook2keysUser
       GuiControl, Enable, UpDownAsLR
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }
  
    if (DisableTypingMode=1)
    {
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, pgUDasHE
       GuiControl, Disable, UpDownAsHE
       GuiControl, Disable, UpDownAsLR
       GuiControl, Disable, alternativeJumps
       GuiControl, Disable, sendJumpKeys
       GuiControl, Disable, pasteOSDcontent
       GuiControl, Disable, synchronizeMode
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, AltHook2keysUser
       GuiControl, Disable, MediateNavKeys
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else if (ShowSingleKey!=0)
    {
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, alternativeJumps
       GuiControl, Enable, sendJumpKeys
       GuiControl, Enable, synchronizeMode
       GuiControl, Enable, pasteOSDcontent
       GuiControl, Enable, MediateNavKeys
       GuiControl, Enable, pgUDasHE
       GuiControl, Enable, UpDownAsHE
       GuiControl, Enable, UpDownAsLR
       GuiControl, Enable, AltHook2keysUser
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0))
    {
       GuiControl, Disable, enableAltGr
       GuiControl, Disable, ShowDeadKeys
    }

    if (OnlyTypingMode=0)
       GuiControl, Disable, enterErasesLine
    
    if (DoNotBindDeadKeys=1)
          GuiControl, Disable, ShowDeadKeys
    else if (DisableTypingMode=0) && (ShowSingleKey!=0)
          GuiControl, Enable, ShowDeadKeys

    if (AltHook2keysUser=1)
       GuiControl, Disable, ShowDeadKeys

    GuiControl, % (DoNotBindDeadKeys=1 ? "Enable" : "Disable"), DoNotBindAltGrDeadKeys

    if (UpDownAsHE=1)
       GuiControl, , UpDownAsLR, 0

    if (UpDownAsLR=1)
       GuiControl, , UpDownAsHE, 0

    if (enableTypingHistory=1)
       GuiControl, Disable, pgUDasHE

    if (alternateTypingMode=0)
    {
       GuiControl, Disable, pasteOnClick
       GuiControl, Disable, sendKeysRealTime
    } else
    {
       GuiControl, Enable, pasteOnClick
       GuiControl, Enable, sendKeysRealTime     
    }

    if (enterErasesLine=0 && OnlyTypingMode=1)
    {
       GuiControl, Disable, sendJumpKeys
       GuiControl, Disable, MediateNavKeys
       GuiControl, Disable, enableTypingHistory
       GuiControl, Enable, pgUDasHE
    }
}

ShowShortCutsSettings() {
    doNotOpen := initSettingsWindow()
    if (doNotOpen=1)
       Return

    Gui, SettingsGUIA: Add, Checkbox, x96 y35 gVerifyShortcutOptions Checked%alternateTypingMode% valternateTypingMode, Enter alternate typing mode
    if (DisableTypingMode=0)
    {
       Gui, Add, Checkbox, y+12 gVerifyShortcutOptions Checked%pasteOSDcontent% vpasteOSDcontent, Send/paste the OSD content into the active window/text field
       Gui, Add, Text, xp+15 y+13, Replace entire text from the host app with the OSD content
       Gui, Add, Text, xp-15 y+43, Capture text from the active text area (preffered choice)
       Gui, Add, Text, y+10, Capture text from the active text area [only the current line]
       Gui, Add, Text, y+10, Switch forced keyboard layout (A / B)
    } else Gui, Add, Text, y+43, Switch forced keyboard layout (A / B)
    Gui, Add, Text, y+10, Toggle never display OSD
    Gui, Add, Text, y+10, Toggle OSD positions (A / B)
    Gui, Add, Text, y+10, Toggle Capture2Text
    Gui, Add, Text, y+10, Detect keyboard layout
    Gui, Add, Text, y+10, Restart / reload KeyPress OSD
    Gui, Add, Text, y+10, Suspend / deactivate KeyPress OSD

    Gui, Add, Text, x15 y15, All the shortcuts listed in this panel are available globally, in any application.
    Gui, Add, Edit, y+4 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDaltTypeMode, %KBDaltTypeMode%
    if (DisableTypingMode=0)
    {
       Gui, Add, Edit, y+4 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDpasteOSDcnt1, %KBDpasteOSDcnt1%
       Gui, Add, Edit, y+4 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDpasteOSDcnt2, %KBDpasteOSDcnt2%
    }
    Gui, Add, Checkbox, y+15 gVerifyShortcutOptions Checked%KeyboardShortcuts% vKeyboardShortcuts, Other global keyboard shortcuts
    if (DisableTypingMode=0)
    {
       Gui, Add, Edit, y+6 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDsynchApp1, %KBDsynchApp1%
       Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDsynchApp2, %KBDsynchApp2%
       Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDTglForceLang, %KBDTglForceLang%
    } else Gui, Add, Edit, y+6 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDTglForceLang, %KBDTglForceLang%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDTglNeverOSD, %KBDTglNeverOSD%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDTglPosition, %KBDTglPosition%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDTglCap2Text, %KBDTglCap2Text%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDidLangNow, %KBDidLangNow%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDReload, %KBDReload%
    Gui, Add, Edit, y+2 w75 gVerifyShortcutOptions r1 limit20 -multi -wantReturn -wantTab -wrap vKBDsuspend, %KBDsuspend%
    Gui, Add, Text, y+15, To individually disable a shortcut, type Disable in the text field.
    Gui, Add, Text, y+6, Available modifiers:   ^ Control  ||  ! Alt  ||  + Shift  ||  # WinKey
    Gui, Add, DropDownList, y+6 Choose1 , Available keys|[[ 0-9 / numbers ]]|[[ A-Z / letters ]]|AppsKey|Backspace|Break|Browser_Back|Browser_Favorites|Browser_Forward|Browser_Home|Browser_Refresh|Browser_Search|Browser_Stop|CapsLock|CtrlBreak|Delete|Down|End|Enter|Escape|Help|Home|Insert|Launch_App1|Launch_App2|Launch_Mail|Launch_Media|LButton|Left|MButton|Media_Next|Media_Play_Pause|Media_Prev|Media_Stop|NumLock|Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|NumpadAdd|NumpadClear|NumpadDel|NumpadDiv|NumpadDot|NumpadDown|NumpadEnd|NumpadEnter|NumpadHome|NumpadIns|NumpadLeft|NumpadMult|NumpadPgDn|NumpadPgUp|NumpadRight|NumpadSub|NumpadUp|Pause|PgDn|PgUp|PrintScreen|RButton|Right|ScrollLock|Sleep|Space|Tab|Up|Volume_Down|Volume_Mute|Volume_Up|WheelDown|WheelLeft|WheelRight|WheelUp|[[ VK nnn ]]|[[ SC nnn ]]
    Gui, Add, Button, y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 w70 h30 gCloseSettings, C&ancel
    Gui, Show, AutoSize, Global shortcuts: KeyPress OSD
    VerifyShortcutOptions(0)
}

VerifyShortcutOptions(enableApply:=1) {
    GuiControlGet, alternateTypingMode
    GuiControlGet, pasteOSDcontent
    GuiControlGet, KeyboardShortcuts

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (alternateTypingMode=0 ? "Disable" : "Enable"), KBDaltTypeMode
    
    if (pasteOSDcontent=0)
    {
       GuiControl, Disable, KBDpasteOSDcnt1
       GuiControl, Disable, KBDpasteOSDcnt2
    } else
    {
      GuiControl, Enable, KBDpasteOSDcnt1
      GuiControl, Enable, KBDpasteOSDcnt2
    }

    if (KeyboardShortcuts=0)
    {
       GuiControl, Disable, KBDsynchApp1
       GuiControl, Disable, KBDsynchApp2
       GuiControl, Disable, KBDTglCap2Text
       GuiControl, Disable, KBDTglForceLang
       GuiControl, Disable, KBDTglNeverOSD
       GuiControl, Disable, KBDTglPosition
       GuiControl, Disable, KBDidLangNow
       GuiControl, Disable, KBDReload
    } else
    {
       if (DisableTypingMode=0)
       {
          GuiControl, Enable, KBDsynchApp1
          GuiControl, Enable, KBDsynchApp2
       }
       GuiControl, Enable, KBDTglCap2Text
       GuiControl, Enable, KBDTglForceLang
       GuiControl, Enable, KBDTglNeverOSD
       GuiControl, Enable, KBDTglPosition
       GuiControl, Enable, KBDidLangNow
       GuiControl, Enable, KBDReload
    }

    if (DisableTypingMode=1)
    {
       GuiControl, Disable, KBDsynchApp1
       GuiControl, Disable, KBDsynchApp2
       GuiControl, Disable, KBDpasteOSDcnt1
       GuiControl, Disable, KBDpasteOSDcnt2
    }
}

ShowSoundsSettings() {
    doNotOpen := initSettingsWindow()
    if (doNotOpen=1)
       Return

    verifyNonCrucialFilesRan := 2
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
    verifyNonCrucialFiles()

    Global ApplySettingsBTN
    Gui, Add, Checkbox, gVerifySoundsOptions x15 y15 Checked%SilentMode% vSilentMode, Silent mode - make no sounds
    Gui, Add, text, y+10, Make a beep when the following keys are released:
    Gui, Add, Checkbox, gVerifySoundsOptions xp+15 y+7 Checked%KeyBeeper% vKeyBeeper, All bound keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%deadKeyBeeper% vdeadKeyBeeper, Recognized dead keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%ModBeeper% vModBeeper, Modifiers (Ctrl, Alt, WinKey, Shift)
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%ToggleKeysBeeper% vToggleKeysBeeper, Toggle keys (Caps / Num / Scroll lock)
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%MouseBeeper% vMouseBeeper, On mouse clicks
    Gui, Add, Checkbox, gVerifySoundsOptions xp-15 y+14 Checked%CapslockBeeper% vCapslockBeeper, Beep distinctively when typing and CapsLock is on
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%TypingBeepers% vTypingBeepers, Distinct beeps for different key groups
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%DTMFbeepers% vDTMFbeepers, DTMF beeps for numpad keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%beepFiringKeys% vbeepFiringKeys, Generic beep for every key fire
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%audioAlerts% vaudioAlerts, At start, beep for every failed key binding
    Gui, Add, Checkbox, gVerifySoundsOptions y+14 Checked%LowVolBeeps% vLowVolBeeps, Play beeps at reduced volume
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%prioritizeBeepers% vprioritizeBeepers, Attempt to play every beep (may interfere with typing mode)
    if (missingAudios=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, y+14 w250, WARNING. Sound files are missing. The attempts to download them seem to have failed. The beeps will be synthesized at a high volume.
       Gui, Font, Normal
    }

    Gui, Add, Button, y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+0 w70 h30 gCloseSettings, C&ancel
    Gui, Show, AutoSize, Sounds settings: KeyPress OSD
    VerifySoundsOptions(0)
}

VerifySoundsOptions(enableApply:=1) {
    GuiControlGet, keyBeeper
    GuiControlGet, TypingBeepers
    GuiControlGet, SilentMode

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    if (SilentMode=1)
    {
       GuiControl, Disable, LowVolBeeps
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, deadKeyBeeper
       GuiControl, Disable, TypingBeepers
       GuiControl, Disable, MouseBeeper
       GuiControl, Disable, DTMFbeepers
       GuiControl, Disable, prioritizeBeepers
       GuiControl, Disable, KeyBeeper
       GuiControl, Disable, ModBeeper
       GuiControl, Disable, ToggleKeysBeeper
       GuiControl, Disable, beepFiringKeys
       GuiControl, Disable, audioAlerts
    } else
    {
       GuiControl, Enable, LowVolBeeps
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, deadKeyBeeper
       GuiControl, Enable, TypingBeepers
       GuiControl, Enable, MouseBeeper
       GuiControl, Enable, DTMFbeepers
       GuiControl, Enable, prioritizeBeepers
       GuiControl, Enable, KeyBeeper
       GuiControl, Enable, ModBeeper
       GuiControl, Enable, ToggleKeysBeeper
       GuiControl, Enable, beepFiringKeys
       GuiControl, Enable, audioAlerts
    }

    if (SilentMode=0)
    {
       GuiControl, % (keyBeeper=0 ? "Disable" : "Enable"), TypingBeepers
       GuiControl, % (ShowMouseButton=0 && VisualMouseClicks=0 ? "Disable" : "Enable"), MouseBeeper
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0)) || (DoNotBindDeadKeys=1)
       GuiControl, Disable, deadKeyBeeper

    if (DisableTypingMode=1)
       GuiControl, Disable, CapslockBeeper

    if (missingAudios=1)
    {
       GuiControl, Disable, LowVolBeeps
       GuiControl, Disable, DTMFbeepers
       GuiControl, , LowVolBeeps, 0
       GuiControl, , DTMFbeepers, 0
    }
}

ShowKBDsettings() {
    doNotOpen := initSettingsWindow()
    if (doNotOpen=1)
       Return

    Gui, Add, Text, x15 y15 w220, Status: %CurrentKBD%
    Gui, Add, Text, xp+0 yp+40, Settings regarding keyboard layouts:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continuously detect layout changes
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%SilentDetection% vSilentDetection, Silent detection (no messages)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%audioAlerts% vaudioAlerts, Beep for failed key bindings
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%enableAltGr% venableAltGr, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xp+0 yp+20 gForceKbdInfo Checked%ForceKBD% vForceKBD, Force detected keyboard layout (A / B)
    Gui, Add, Edit, xp+20 yp+20 gVerifyKeybdOptions w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout1, %ForcedKBDlayout1%
    Gui, Add, Edit, xp+73 yp+0 gVerifyKeybdOptions w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout2, %ForcedKBDlayout2%
    Gui, Add, Checkbox, xp-93 yp+30 gVerifyKeybdOptions Checked%IgnoreAdditionalKeys% vIgnoreAdditionalKeys, Ignore specific keys (dot separated)
    Gui, Add, Edit, xp+20 yp+20 gVerifyKeybdOptions w140 r1 -multi -wantReturn -wantTab -wrap vIgnorekeysList, %IgnorekeysList%

    Gui, Add, Text, x260 y15, Display behavior:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys
    if (OnlyTypingMode=1)
       Gui, Add, Checkbox, yp+0 yp+20 gVerifyKeybdOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%HideAnnoyingKeys% vHideAnnoyingKeys, Hide Left Click and PrintScreen
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowSingleModifierKey% vShowSingleModifierKey, Display modifiers
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%DifferModifiers% vDifferModifiers, Differ left and right modifiers
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCount% vShowKeyCount, Show key count
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCountFired% vShowKeyCountFired, Count number of key fires
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowPrevKey% vShowPrevKey, Show previous key (delay in ms)
    Gui, Add, Edit, xp+180 yp+0 gVerifyKeybdOptions w24 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vShowPrevKeyDelay, %ShowPrevKeyDelay%

    Gui, Add, Text, xp-190 yp+35, Other options:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ClipMonitor% vClipMonitor, Monitor clipboard changes
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions w190 Checked%hostCaretHighlight% vhostCaretHighlight, Highlight text cursor in host app (if detectable)

    Gui, Add, Button, x15 yp+35 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Show, AutoSize, Keyboard settings: KeyPress OSD
    VerifyKeybdOptions(0)
}

VerifyKeybdOptions(enableApply:=1) {
    GuiControlGet, AutoDetectKBD
    GuiControlGet, ConstantAutoDetect
    GuiControlGet, IgnoreAdditionalKeys
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
    GuiControlGet, enableAltGr
    GuiControlGet, OnlyTypingMode

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (ShowSingleModifierKey=0 ? "Disable" : "Enable"), DifferModifiers
    GuiControl, % (ShowPrevKey=0 ? "Disable" : "Enable"), ShowPrevKeyDelay
    GuiControl, % (ShowKeyCount=0 ? "Disable" : "Enable"), ShowKeyCountFired

    if (OnlyTypingMode=1)
    {
        GuiControl, Disable, ShowSingleModifierKey
        GuiControl, Disable, ShowKeyCount
        GuiControl, Disable, ShowKeyCountFired
        GuiControl, Disable, ShowPrevKey 
        GuiControl, Disable, ShowPrevKeyDelay
        GuiControl, Disable, HideAnnoyingKeys
        GuiControl, Disable, DifferModifiers
    } else 
    {
        GuiControl, Enable, ShowSingleModifierKey
        GuiControl, Enable, ShowKeyCount
        GuiControl, Enable, HideAnnoyingKeys
        GuiControl, Enable, ShowPrevKey
        if (ShowKeyCount=1)
           GuiControl, Enable, ShowKeyCountFired
        if (ShowPrevKey=1)
           GuiControl, Enable, ShowPrevKeyDelay
        if (ShowSingleModifierKey=1) && (ShowSingleKey=1)
           GuiControl, Enable, DifferModifiers
    }

    if (ShowSingleKey=0)
    {
       GuiControl, Disable, HideAnnoyingKeys
       GuiControl, Disable, ShowSingleModifierKey
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, DifferModifiers
       GuiControl, , OnlyTypingMode, 0
    } else if (OnlyTypingMode!=1)
    {
       GuiControl, Enable, HideAnnoyingKeys
       GuiControl, Enable, ShowSingleModifierKey
       GuiControl, Enable, OnlyTypingMode
    } else
    {
       if (ShowSingleModifierKey=1) && (OnlyTypingMode=0)
          GuiControl, Enable, DifferModifiers
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
       GuiControl, Disable, enableAltGr
    } else
    {
       GuiControl, Enable, SilentDetection
       GuiControl, Enable, enableAltGr
    }

    GuiControl, % (IgnoreAdditionalKeys=0 ? "Disable" : "Enable"), IgnorekeysList
}

ForceKbdInfo() {
    GuiControlGet, ForceKBD
    if (ForceKBD=1)
       MsgBox, , About Force Keyboard Layout, Please enter the keyboard layout codes you want to enforce. You can use the "Installed keyboard layouts" menu to easily define these. You can toggle between the two layouts with Ctrl+Alt+Shift+F7 [default shortcut].

    VerifyKeybdOptions()
}

ShowMouseSettings() {
    doNotOpen := initSettingsWindow()
    if (doNotOpen=1)
       Return

    Global editF1, editF2, editF3, editF4, editF5, editF6, editF7, btn1
    Gui, Add, Checkbox, gVerifyMouseOptions x15 y15 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, Beep on mouse clicks
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%VisualMouseClicks% vVisualMouseClicks, Visual mouse clicks (scale, alpha)
    Gui, Add, Edit, xp+16 yp+20 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %ClickScaleUser%
    Gui, Add, UpDown, vClickScaleUser gVerifyMouseOptions Range3-90, %ClickScaleUser%
    Gui, Add, Edit, xp+50 yp+0 w45 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %MouseVclickAlpha%
    Gui, Add, UpDown, vMouseVclickAlpha gVerifyMouseOptions Range10-240, %MouseVclickAlpha%
    Gui, Add, Checkbox, gVerifyMouseOptions xp-65 yp+35 Checked%MouseClickRipples% vMouseClickRipples, Show ripples on clicks (size, thickness)
    Gui, Add, Edit, xp+16 yp+20 w45 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %MouseRippleMaxSize%
    Gui, Add, UpDown, vMouseRippleMaxSize gVerifyMouseOptions Range90-400, %MouseRippleMaxSize%
    Gui, Add, Edit, xp+50 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %MouseRippleThickness%
    Gui, Add, UpDown, vMouseRippleThickness gVerifyMouseOptions Range5-50, %MouseRippleThickness%

    Gui, Add, Edit, x345 y40 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %MouseHaloRadius%
    Gui, Add, UpDown, vMouseHaloRadius gVerifyMouseOptions Range5-950, %MouseHaloRadius%
    Gui, Add, ListView, xp+0 yp+25 w60 h20 %cclvo% Background%MouseHaloColor% vMouseHaloColor hwndhLV4, 1
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %MouseHaloAlpha%
    Gui, Add, UpDown, vMouseHaloAlpha gVerifyMouseOptions Range10-240, %MouseHaloAlpha%
    Gui, Add, Edit, xp+0 yp+55 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %MouseIdleAfter%
    Gui, Add, UpDown, vMouseIdleAfter gVerifyMouseOptions Range3-950, %MouseIdleAfter%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %MouseIdleRadius%
    Gui, Add, UpDown, vMouseIdleRadius gVerifyMouseOptions Range5-950, %MouseIdleRadius%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %IdleMouseAlpha%
    Gui, Add, UpDown, vIdleMouseAlpha gVerifyMouseOptions Range10-240, %IdleMouseAlpha%

    Gui, Add, Checkbox, gVerifyMouseOptions x230 y15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Text, xp+15 yp+25, Radius:
    Gui, Add, Text, xp+0 yp+25, Color:
    Gui, Add, Text, xp+0 yp+25, Alpha:
    Gui, Add, Checkbox, gVerifyMouseOptions xp-15 yp+33 Checked%FlashIdleMouse% vFlashIdleMouse, Flash idle mouse to locate it
    Gui, Add, Text, xp+15 yp+25, Idle after (in sec.)
    Gui, Add, Text, xp+0 yp+25, Halo radius:
    Gui, Add, Text, xp+0 yp+25, Alpha:

    Gui, Add, Button, x15 yp-20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Show, AutoSize, Mouse settings: KeyPress OSD
    VerifyMouseOptions(0)
}

hexRGB(c) {
  r := ((c&255)<<16)+(c&65280)+((c&0xFF0000)>>16)
  c := "000000"
  DllCall("msvcrt\sprintf", "AStr", c, "AStr", "%06X", "UInt", r, "CDecl")
  Return c
}

Dlg_Color(Color,hwnd) {
  Static
  if !cpdInit {
     VarSetCapacity(CUSTOM,64,0), cpdInit:=1, size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
  }

  Color := "0x" hexRGB(InStr(Color, "0x") ? Color : Color ? "0x" Color : 0x0)
  NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr")
  ,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
  ,NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
  if !ret := DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")
     Exit

  setformat, IntegerFast, H
  Color := NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
  SetFormat, IntegerFast, D
  Return Color
}

VerifyMouseOptions(enableApply:=1) {
    GuiControlGet, FlashIdleMouse
    GuiControlGet, ShowMouseHalo
    GuiControlGet, ShowMouseButton
    GuiControlGet, VisualMouseClicks
    GuiControlGet, MouseClickRipples

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (ShowMouseButton=0 && VisualMouseClicks=0 ? "Disable" : "Enable"), MouseBeeper

    if (VisualMouseClicks=0)
    {
       GuiControl, Disable, ClickScaleUser
       GuiControl, Disable, MouseVclickAlpha
       GuiControl, Enable, MouseClickRipples
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, ClickScaleUser
       GuiControl, Enable, MouseVclickAlpha
       GuiControl, Disable, MouseClickRipples
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

    if (ShowMouseHalo=0)
    {
       GuiControl, Disable, MouseHaloRadius
       GuiControl, Disable, MouseHaloColor
       GuiControl, Disable, MouseHaloAlpha
       GuiControl, Disable, btn1
       GuiControl, Disable, editF3
       GuiControl, Disable, editF4
    } else
    {
       GuiControl, Enable, MouseHaloRadius
       GuiControl, Enable, MouseHaloColor
       GuiControl, Enable, MouseHaloAlpha
       GuiControl, Enable, btn1
       GuiControl, Enable, editF3
       GuiControl, Enable, editF4
    }

    if (MouseClickRipples=0)
    {
       GuiControl, Disable, MouseRippleThickness
       GuiControl, Disable, MouseRippleMaxSize
       GuiControl, Enable, VisualMouseClicks
       GuiControl, Disable, editF8
       GuiControl, Disable, editF9
    } else
    {
       GuiControl, Enable, MouseRippleThickness
       GuiControl, Enable, MouseRippleMaxSize
       GuiControl, Disable, VisualMouseClicks
       GuiControl, Enable, editF8
       GuiControl, Enable, editF9
    }
    if (OnlyTypingMode=1)
       GuiControl, Disable, ShowMouseButton
}

UpdateFntNow() {
  Global
  Fnt_DeleteFont(hfont)
  fntNamus := FontName
  fntOptions := "s" FontSize " bold"
  hFont := Fnt_CreateFont(fntNamus,fntOptions)
  Fnt_SetFont(hOSDctrl,hfont,true)
}

OSDpreview() {
    Gui, SettingsGUIA: Submit, NoHide
    if (A_TickCount-tickcount_start2 < 150)
       Return

    if (showPreview=0)
    {
       Gui, OSD: hide
       Return
    }
    SetTimer, checkMousePresence, on, 950, -15
    Sleep, 10
    DragOSDmode := 1
    NeverDisplayOSD := 0
    maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
    GuiX := (GUIposition=1) ? GuiXa : GuiXb
    GuiY := (GUIposition=1) ? GuiYa : GuiYb
    OSDalignment := (GUIposition=1) ? OSDalignment2 : OSDalignment1
    GuiX := (GuiX!="") ? GuiX : GuiXa
    GuiY := (GuiY!="") ? GuiY : GuiYa
    CreateOSDGUI()
    UpdateFntNow()
    GuiControl, OSD:, CapsDummy, 100
    TextHeight := FontSize*2
    GuiControl, OSD: Move, HotkeyText, h%TextHeight%
    ShowHotkey(previewWindowText)
}

ShowOSDsettings() {
    doNotOpen := initSettingsWindow()
    if (doNotOpen=1)
       Return

    Global positionB, editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, editF10, Btn1, Btn2
    GUIposition := GUIposition + 1
    Gui, SettingsGUIA: Add, Radio, x15 y35 gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, xp+0 yp+25 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, Button, xp+145 yp-25 w25 h20 gLocatePositionA vBtn1, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %GuiXa%
    Gui, Add, UpDown, vGuiXa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXa%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %GuiYa%
    Gui, Add, UpDown, vGuiYa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYa%
    Gui, Add, Button, xp-86 yp+25 w25 h20 gLocatePositionB vBtn2, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %GuiXb%
    Gui, Add, UpDown, vGuiXb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXb%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %GuiYb%
    Gui, Add, UpDown, vGuiYb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYb%
    Gui, Add, DropDownList, xp-60 yp+25 w55 gVerifyOsdOptions AltSubmit choose%OSDalignment2% vOSDalignment2, Left|Center|Right|
    Gui, Add, DropDownList, xp+60 yp+0 w55 gVerifyOsdOptions AltSubmit choose%OSDalignment1% vOSDalignment1, Left|Center|Right|
    Gui, Add, DropDownList, xp-150 yp+25 w145 gVerifyOsdOptions Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+150 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %FontSize%
    Gui, Add, UpDown, gVerifyOsdOptions vFontSize Range7-295, %FontSize%
    Gui, Add, ListView, xp-60 yp+25 w55 h20 %cclvo% Background%OSDtextColor% vOSDtextColor hwndhLV1,
    Gui, Add, ListView, xp+60 yp+0 w55 h20 %cclvo% Background%OSDbgrColor% vOSDbgrColor hwndhLV2,
    Gui, Add, ListView, xp-60 yp+25 w55 h20 %cclvo% Background%CapsColorHighlight% vCapsColorHighlight hwndhLV3,
    Gui, Add, ListView, xp+60 yp+0 w55 h20 %cclvo% Background%TypingColorHighlight% vTypingColorHighlight hwndhLV5,
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %DisplayTimeUser%
    Gui, Add, UpDown, vDisplayTimeUser gVerifyOsdOptions Range1-99, %DisplayTimeUser%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF10, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyOsdOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %GuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vGuiWidth Range55-2900, %GuiWidth%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %maxGuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vmaxGuiWidth Range55-2900, %maxGuiWidth%
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %OSDautosizeFactory%
    Gui, Add, UpDown, gVerifyOsdOptions vOSDautosizeFactory Range10-400, %OSDautosizeFactory%

    Gui, Add, Text, x15 y15, OSD location presets. Click L to define each.
    Gui, Add, Text, xp+0 yp+72, OSD alignment (A / B)
    Gui, Add, Text, xp+0 yp+25, Font / size
    Gui, Add, Text, xp+0 yp+25, Text / background
    Gui, Add, Text, xp+0 yp+25, Caps lock / alt. typing mode
    Gui, Add, Text, xp+0 yp+25, Display time / when typing (in sec.)
    Gui, Add, Text, xp+0 yp+25, Width (fixed size / dynamic max,)
    Gui, Add, Text, xp+0 yp+25, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (screen DPI: %A_ScreenDPI%)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyOsdOptions Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyOsdOptions Checked%JumpHover% vJumpHover, Toggle OSD positions when mouse runs over it
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyOsdOptions Checked%DragOSDmode% vDragOSDmode, Allow easy OSD repositioning (click to drag it)
    Gui, Font, Bold
    if (NeverDisplayOSD=1)
       Gui, Add, Text, xp+0 yp+25, WARNING: Never display OSD is activated.
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyOsdOptions Checked%showPreview% vshowPreview, Show preview window
    Gui, Add, Edit, xp+170 yp+0 gVerifyOsdOptions w115 limit30 r1 -multi -wantReturn -wantTab -wrap vpreviewWindowText, %previewWindowText%
    Gui, Font, Normal

    if !FontList._NewEnum()[k, v]
    {
        Fnt_GetListOfFonts()
        FontList := trimArray(FontList)
    }
    Loop, % FontList.MaxIndex() {
        fontNameInstalled := FontList[A_Index]
        if (fontNameInstalled ~= "i)(@|oem|extb|symbol|marlett|wst_|glyph|reference specialty|system|terminal|mt extra|small fonts|cambria math|fixedsys|emoji|hksc| mdl|wingdings|webdings)")
           Continue
        GuiControl, , FontName, %fontNameInstalled%
    }

    Gui, Add, Button, xp-170 yp+30 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Show, AutoSize, OSD appearances: KeyPress OSD
    VerifyOsdOptions(0)
}

VerifyOsdOptions(enableApply:=1) {
    GuiControlGet, OSDautosize
    GuiControlGet, GUIposition
    GuiControlGet, showPreview
    GuiControlGet, JumpHover
    GuiControlGet, DragOSDmode

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (DragOSDmode=1 ? "Disable" : "Enable"), JumpHover
    GuiControl, % (showPreview=1 ? "Enable" : "Disable"), previewWindowText

    if (GUIposition=0)
    {
        GuiControl, Disable, GuiXa
        GuiControl, Disable, GuiYa
        GuiControl, Disable, btn1
        GuiControl, Disable, editF1
        GuiControl, Disable, editF2
        GuiControl, Disable, OSDalignment2
        GuiControl, Enable, OSDalignment1
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
        GuiControl, Enable, OSDalignment2
        GuiControl, Disable, OSDalignment1
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
    OSDpreview()
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

trimArray(arr) { ; Hash O(n) 
; by errorseven from https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
    hash := {}, newArr := []
    for e, v in arr
        if (!hash.Haskey(v))
            hash[(v)] := 1, newArr.push(v)
    Return newArr
}

ApplySettings() {
    Gui, SettingsGUIA: Submit, NoHide

    CheckSettings()
    if (ForceKBD=1) || (AutoDetectKBD=1)
    {
       ReloadCounter := 1
       IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    }
    Sleep, 20
    ShaveSettings()
    Sleep, 20
    ReloadScript()
}

AboutWindow() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
    }

    SettingsGUI()
    Gui, Add, Link, x16 y45, Script developed by <a href="http://marius.sucan.ro">Marius Șucan</a> for AHK_H v1.1.27.
    Gui, Add, Link, xp+0 yp+20, Based on KeyPressOSD v2.2 by Tmplinshi. <a href="mailto:marius.sucan@gmail.com">Send me feedback</a>..
    Gui, Add, Text, xp+0 yp+20, Freeware. Open source. For Windows XP, Vista, 7, 8, and 10.
    Gui, Add, Text, xp+0 yp+35, Many thanks to the great people from #ahk (irc.freenode.net), 
    Gui, Add, Text, xp+0 yp+20, ... in particular to Phaleth, Drugwash, Tidbit and Saiapatsu.
    Gui, Add, Text, xp+0 yp+20, Special mentions: Burque505 / Winter and Neuromancer.
    Gui, Add, Text, xp+0 yp+35, This contains code also from: Maestrith (color picker),
    Gui, Add, Text, xp+0 yp+20, Alguimist (font list generator), VxE (GuiGetSize),
    Gui, Add, Text, xp+0 yp+20, Sean (GetTextExtentPoint), Helgef (toUnicodeEx),
    Gui, Add, Text, xp+0 yp+20, Jess Harpur (Extract2Folder), Tidbit and Lexikos.
    Gui, Add, Button, xp+0 yp+35 w75 Default gCloseWindow, &Close
    Gui, Add, Button, xp+80 yp+0 w85 gChangeLog, Version &history
    Gui, Add, Text, xp+90 yp+1, Released: %releaseDate%
    Gui, Font, s20 bold, Arial, -wrap
    Gui, Add, Text, x15 y10, KeyPress OSD v%version%
    Gui, Show, AutoSize, About KeyPress OSD v%version%
}

CloseWindow() {
    Gui, SettingsGUIA: Destroy
}

CloseSettings() {
   GuiControlGet, ApplySettingsBTN, Enabled
   if (ApplySettingsBTN=0)
   {
      prefOpen := 0
      IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
      CloseWindow()
      SuspendScript()
      Return
   }
   ReloadScript()
}

changelog() {
     Gui, SettingsGUIA: Destroy
     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileName := "keypress-osd-changelog.txt"
     historyFile := "keypress-files\" historyFileName
     historyFileURL := baseURL historyFileName

     if (!FileExist(historyFile) || (ForceDownloadExternalFiles=1))
     {
         SoundBeep
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

                 if (timeNow > 10)
                    MsgBox, Version history seems too old. Please use the Update now option from the tray menu. The file will be opened now.

                Run, %historyFile%
             } else
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
     langyFileName := "keypress-osd-languages.ini"
     langyFile := "keypress-files\" langyFileName
     langyFileURL := baseURL langyFileName
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
             } else
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
           ReloadCounter := ReloadCounter+1
           IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
           ReloadScript()
        }
     }

     if (langFileDownloaded=1) && (ReloadCounter<3)
     {
        ReloadCounter := ReloadCounter+1
        IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
        ReloadScript()
     }
}

Is64BitExe(path) {
  DllCall("GetBinaryType", "astr", path, "uint*", type)
  return 6 = type
}

updateNow() {
     if (prefOpen=1)
     {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
     }

     binaryUpdater := "updater.bat"
     if !FileExist(binaryUpdater) && A_IsCompiled
     {
        MsgBox, Updater is missing updater.bat. Unable to proceed further.
        Return
     }

     MsgBox, 4, Question, Do you want to abort updating?
     IfMsgBox, Yes
     {
       verifyNonCrucialFilesRan := 1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
       Return
     }
     if (A_IsSuspended!=1)
        SuspendScript()
     Sleep, 150
     prefOpen := 1
     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     mainFileBinary := (Is64BitExe(A_ScriptName)=1) ? "keypress-osd-x64.exe" : "keypress-osd-x32.exe"
     mainFileTmp := A_IsCompiled ? "new-keypress-osd.exe" : "temp-keypress-osd.ahk"
     mainFile := A_IsCompiled ? mainFileBinary : "keypress-osd.ahk"
     mainFileURL := baseURL mainFile
     thisFile := A_ScriptName
     zipFile := "keypress-files.zip"
     zipFileTmp := zipFile
     zipUrl := baseURL zipFile

     ShowLongMsg("Updating files: 1 / 2. Please wait...")
     UrlDownloadToFile, %mainFileURL%, %mainFileTmp%
     Sleep, 3000

     if FileExist(mainFileTmp)
     {
         FileRead, Contents, %mainFileTmp%
         if not ErrorLevel
         {

             StringLeft, Contents, Contents, 31
             if InStr(contents, "; KeypressOSD.ahk - main file") || InStr(contents, "MZ")
             {
                ShowLongMsg("Updating files: Main code: OK")
                if !A_IsCompiled
                   FileMove, %mainFileTmp%, %thisFile%, 1
                Sleep, 1350
                ahkDownloaded := 1
             } else
             {
                ShowLongMsg("Updating files: Main code: CORRUPT")
                Sleep, 1350
                ahkDownloaded := 0
                FileDelete, %mainFileTmp%
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Main code: FAIL")
         Sleep, 1350
         ahkDownloaded := 0
     }

     ShowLongMsg("Updating files: 2 / 2. Please wait...")
     UrlDownloadToFile, %zipUrl%, %zipFileTmp%
     Sleep, 3000

     if FileExist(zipFileTmp)
     {
         FileRead, Contents, %zipFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 50
             if InStr(contents, "PK")
             {
                ShowLongMsg("Auxiliary files: OK")
                Extract2Folder(zipFileTmp)
                Sleep, 1350
                FileDelete, %zipFileTmp%
                zipDownloaded := 1
             } else
             {
                ShowLongMsg("Auxiliary files: FAIL")
                Sleep, 1350
                FileDelete, %zipFileTmp%
                zipDownloaded := 0
             }
         }
     } else 
     {
         ShowLongMsg("Auxiliary files: FAIL")
         Sleep, 1350
         zipDownloaded := 0
     }

     if (zipDownloaded=0 || ahkDownloaded=0)
        someErrors := 1

     if (zipDownloaded=0 && ahkDownloaded=0)
        completeFailure := 1

     if (zipDownloaded=1 && ahkDownloaded=1)
        completeSucces := 1

     if (completeFailure=1)
     {
        MsgBox, 4, Error, Unable to download any file. Server is offline or no Internet connection. Do you want to try again?
        IfMsgBox, Yes
           updateNow()
     }

     if (completeSucces=1)
     {
        MsgBox, Update seems to be succesful. No errors detected. The script will now reload.
        verifyNonCrucialFilesRan := 1
        IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
        if A_IsCompiled && (ahkDownloaded=1)
        {
           Run, %binaryUpdater% %thisFile%,, hide
           ExitApp
        } else ReloadScript()
     }

     if (someErrors=1)
     {
        MsgBox, Errors occured during the update. The script will now reload.
        verifyNonCrucialFilesRan := 1
        IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
        if A_IsCompiled && (ahkDownloaded=1)
        {
           Run, %binaryUpdater% %thisFile%,, hide
           ExitApp
        } else ReloadScript()
     }
}

verifyNonCrucialFiles() {
     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     binaryUpdater := "updater.bat"
     binaryUpdaterURL := baseURL binaryUpdater

     if !FileExist(binaryUpdater) && A_IsCompiled
     {
        UrlDownloadToFile, %binaryUpdaterURL%, %binaryUpdater%
        StringLeft, Contents, Contents, 50
        if !InStr(contents, "TIMEOUT /T")
           FileDelete, %binaryUpdater%
     }

    zipFile := "keypress-files.zip"
    zipFileTmp := zipFile
    zipUrl := baseURL zipFile
    SoundsZipFile := "keypress-sounds.zip"
    SoundsZipFileTmp := SoundsZipFile
    SoundsZipUrl := baseURL SoundsZipFile
    historyFile := "keypress-files\keypress-osd-changelog.txt"
    beepersFile := "keypress-files\keypress-beeperz-functions.ahk"
    ripplesFile := "keypress-files\keypress-mouse-ripples-functions.ahk"
    mouseFile := "keypress-files\keypress-mouse-functions.ahk"

    faqHtml := "keypress-files\help\faq.html"
    presentationHtml := "keypress-files\help\presentation.html"
    shortcutsHtml := "keypress-files\help\shortcuts.html"
    featuresHtml := "keypress-files\help\features.html"
    soundFile1 := "sounds\firedkey1.wav"
    soundFile2 := "sounds\firedkey0.wav"
    soundFile3 := "sounds\deadkeys1.wav"
    soundFile4 := "sounds\mods1.wav"
    soundFile5 := "sounds\clicks1.wav"
    soundFile6 := "sounds\caps1.wav"
    soundFile7 := "sounds\keys1.wav"
    soundFile8 := "sounds\clicks0.wav"
    soundFile9 := "sounds\mods0.wav"
    soundFile10 := "sounds\deadkeys0.wav"
    soundFile11 := "sounds\keys0.wav"
    soundFile12 := "sounds\caps0.wav"
    FilePack := "beepersFile,ripplesFile,mouseFile,historyFile,faqHtml,presentationHtml,shortcutsHtml,featuresHtml"

    IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
    if (ScriptelSuspendel!=1) {
       GetTextExtentPoint("Initializing", FontName, FontSize, 1)
       Sleep, 50
       ShowLongMsg("Initializing...")
       SetTimer, HideGUI, % -DisplayTime*2
    }

    IniRead, verifyNonCrucialFilesRan, %inifile%, TempSettings, verifyNonCrucialFilesRan, 0
    IniRead, checkVersion, %IniFile%, SavedSettings, version, 0
    if (version!=checkVersion)
       verifyNonCrucialFilesRan := 0

    missingAudios := 0
    Loop, 12
        if !FileExist(soundFile%A_Index%)
            downloadSoundPackNow := missingAudios := 1

    Loop, Parse, FilePack, CSV
        if !FileExist(%A_LoopField%)
            downloadPackNow := 1

    FileGetTime, fileDate, %historyFile%
    timeNow := %A_Now%
    EnvSub, timeNow, %fileDate%, Days

    if (timeNow > 25)
    {
      verifyNonCrucialFilesRan := 2
      IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
    }

    if (downloadPackNow=1) && (verifyNonCrucialFilesRan>3)
       Return

    if (downloadPackNow=1) && (verifyNonCrucialFilesRan<4)
    {
       verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2
       UrlDownloadToFile, %zipUrl%, %zipFileTmp%
       Sleep, 1500

       if FileExist(zipFileTmp)
       {
           FileRead, Contents, %zipFileTmp%
           if not ErrorLevel
           {
               StringLeft, Contents, Contents, 50
               if InStr(contents, "PK")
               {
                  Extract2Folder(zipFileTmp)
                  Sleep, 1500
                  FileDelete, %zipFileTmp%
                  reloadRequired := 1
               } else
               {
                  FileDelete, %zipFileTmp%
               }
           }
       }
    }

    if (downloadSoundPackNow=1) && (verifyNonCrucialFilesRan<4)
    {
       verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2

       UrlDownloadToFile, %SoundsZipUrl%, %SoundsZipFileTmp%
       Sleep, 1500

       if FileExist(SoundsZipFileTmp)
       {
           FileRead, Contents, %SoundsZipFileTmp%
           if not ErrorLevel
           {
               StringLeft, Contents, Contents, 50
               if InStr(contents, "PK")
               {
                  Extract2Folder(SoundsZipFileTmp, "sounds")
                  Sleep, 1500
                  FileDelete, %SoundsZipFileTmp%
               } else
               {
                  FileDelete, %SoundsZipFileTmp%
               }
           }
       }
    }
    if (reloadRequired=1)
    {
        MsgBox, 4,, Important files were downloaded. Do you want to restart this app?
        IfMsgBox Yes
        {
           IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
           IniWrite, %version%, %inifile%, SavedSettings, version
           ReloadScript()
        }
    }
    missingAudios := 0
    Loop, 12
        if !FileExist(soundFile%A_Index%)
            downloadSoundPackNow := missingAudios := 1

}

Extract2Folder(Zip, Dest="", Filename="") {
; function by Jess Harpur [2013]
; Based on code by shajul
; https://autohotkey.com/board/topic/60706-native-zip-and-unzip-xpvista7-ahk-l/page-2

    SplitPath, Zip,, SourceFolder
    if !SourceFolder
        Zip := A_ScriptDir . "\" . Zip
    
    if !Dest {
        SplitPath, Zip,, DestFolder,, Dest
        Dest := DestFolder . "\" . Dest . "\"
    }
    if SubStr(Dest, 0, 1) <> "\"
        Dest .= "\"
    SplitPath, Dest,,,,,DestDrive
    if !DestDrive
        Dest := A_ScriptDir . "\" . Dest
    
    fso := ComObjCreate("Scripting.FileSystemObject")
    if Not fso.FolderExists(Dest)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fso.CreateFolder(Dest)
       
    AppObj := ComObjCreate("Shell.Application")
    FolderObj := AppObj.Namespace(Zip)
    if Filename {
        FileObj := FolderObj.ParseName(Filename)
        AppObj.Namespace(Dest).CopyHere(FileObj, 4|16)
    } else
    {
        FolderItemsObj := FolderObj.Items()
        AppObj.Namespace(Dest).CopyHere(FolderItemsObj, 4|16)
    }
}

SetStartUp() {
  regEntry := """" A_ScriptFullPath """"
  RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
  if (ErrorLevel=1) || (currentReg!=regEntry)
  {
     Menu, SubSetMenu, Check, Start at boot
     RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD, %regEntry%
  } else
  {
     RegDelete, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
     Menu, SubSetMenu, unCheck, Start at boot
  }
}

ShaveSettings() {
  firstRun := 0
  IniWrite, %alternativeJumps%, %inifile%, SavedSettings, alternativeJumps
  IniWrite, %audioAlerts%, %inifile%, SavedSettings, audioAlerts
  IniWrite, %AutoDetectKBD%, %inifile%, SavedSettings, AutoDetectKBD
  IniWrite, %beepFiringKeys%, %inifile%, SavedSettings, beepFiringKeys
  IniWrite, %CapsColorHighlight%, %inifile%, SavedSettings, CapsColorHighlight
  IniWrite, %CapslockBeeper%, %inifile%, SavedSettings, CapslockBeeper
  IniWrite, %ClickScaleUser%, %inifile%, SavedSettings, ClickScaleUser
  IniWrite, %ClipMonitor%, %inifile%, SavedSettings, ClipMonitor
  IniWrite, %ConstantAutoDetect%, %inifile%, SavedSettings, ConstantAutoDetect
  IniWrite, %deadKeyBeeper%, %inifile%, SavedSettings, deadKeyBeeper
  IniWrite, %DifferModifiers%, %inifile%, SavedSettings, DifferModifiers
  IniWrite, %DisableTypingMode%, %inifile%, SavedSettings, DisableTypingMode
  IniWrite, %DisplayTimeTypingUser%, %inifile%, SavedSettings, DisplayTimeTypingUser
  IniWrite, %DisplayTimeUser%, %inifile%, SavedSettings, DisplayTimeUser
  IniWrite, %enableAltGr%, %inifile%, SavedSettings, enableAltGr
  IniWrite, %enableTypingHistory%, %inifile%, SavedSettings, enableTypingHistory
  IniWrite, %enterErasesLine%, %inifile%, SavedSettings, enterErasesLine
  IniWrite, %firstRun%, %inifile%, SavedSettings, firstRun
  IniWrite, %FlashIdleMouse%, %inifile%, SavedSettings, FlashIdleMouse
  IniWrite, %FontName%, %inifile%, SavedSettings, FontName
  IniWrite, %FontSize%, %inifile%, SavedSettings, FontSize
  IniWrite, %ForcedKBDlayout%, %inifile%, SavedSettings, ForcedKBDlayout
  IniWrite, %ForcedKBDlayout1%, %inifile%, SavedSettings, ForcedKBDlayout1
  IniWrite, %ForcedKBDlayout2%, %inifile%, SavedSettings, ForcedKBDlayout2
  IniWrite, %ForceKBD%, %inifile%, SavedSettings, ForceKBD
  IniWrite, %GUIposition%, %inifile%, SavedSettings, GUIposition
  IniWrite, %GuiWidth%, %inifile%, SavedSettings, GuiWidth
  IniWrite, %GuiXa%, %inifile%, SavedSettings, GuiXa
  IniWrite, %GuiXb%, %inifile%, SavedSettings, GuiXb
  IniWrite, %GuiYa%, %inifile%, SavedSettings, GuiYa
  IniWrite, %GuiYb%, %inifile%, SavedSettings, GuiYb
  IniWrite, %HideAnnoyingKeys%, %inifile%, SavedSettings, HideAnnoyingKeys
  IniWrite, %IdleMouseAlpha%, %inifile%, SavedSettings, IdleMouseAlpha
  IniWrite, %IgnoreAdditionalKeys%, %inifile%, SavedSettings, IgnoreAdditionalKeys
  IniWrite, %IgnorekeysList%, %inifile%, SavedSettings, IgnorekeysList
  IniWrite, %JumpHover%, %inifile%, SavedSettings, JumpHover
  IniWrite, %KeyBeeper%, %inifile%, SavedSettings, KeyBeeper
  IniWrite, %KeyboardShortcuts%, %inifile%, SavedSettings, KeyboardShortcuts
  IniWrite, %LowVolBeeps%, %inifile%, SavedSettings, LowVolBeeps
  IniWrite, %maxGuiWidth%, %inifile%, SavedSettings, maxGuiWidth
  IniWrite, %ModBeeper%, %inifile%, SavedSettings, ModBeeper
  IniWrite, %MouseBeeper%, %inifile%, SavedSettings, MouseBeeper
  IniWrite, %MouseHaloAlpha%, %inifile%, SavedSettings, MouseHaloAlpha
  IniWrite, %MouseHaloColor%, %inifile%, SavedSettings, MouseHaloColor
  IniWrite, %MouseHaloRadius%, %inifile%, SavedSettings, MouseHaloRadius
  IniWrite, %MouseIdleAfter%, %inifile%, SavedSettings, MouseIdleAfter
  IniWrite, %MouseIdleRadius%, %inifile%, SavedSettings, MouseIdleRadius
  IniWrite, %MouseVclickAlpha%, %inifile%, SavedSettings, MouseVclickAlpha
  IniWrite, %NeverDisplayOSD%, %inifile%, SavedSettings, NeverDisplayOSD
  IniWrite, %OSDalignment1%, %inifile%, SavedSettings, OSDalignment1
  IniWrite, %OSDalignment2%, %inifile%, SavedSettings, OSDalignment2
  IniWrite, %DoNotBindAltGrDeadKeys%, %inifile%, SavedSettings, DoNotBindAltGrDeadKeys
  IniWrite, %DoNotBindDeadKeys%, %inifile%, SavedSettings, DoNotBindDeadKeys
  IniWrite, %OnlyTypingMode%, %inifile%, SavedSettings, OnlyTypingMode
  IniWrite, %OSDautosize%, %inifile%, SavedSettings, OSDautosize
  IniWrite, %OSDautosizeFactory%, %inifile%, SavedSettings, OSDautosizeFactory
  IniWrite, %OSDbgrColor%, %inifile%, SavedSettings, OSDbgrColor
  IniWrite, %OSDborder%, %inifile%, SavedSettings, OSDborder
  IniWrite, %OSDtextColor%, %inifile%, SavedSettings, OSDtextColor
  IniWrite, %pasteOSDcontent%, %inifile%, SavedSettings, pasteOSDcontent
  IniWrite, %pgUDasHE%, %inifile%, SavedSettings, pgUDasHE
  IniWrite, %prioritizeBeepers%, %inifile%, SavedSettings, prioritizeBeepers
  IniWrite, %releaseDate%, %inifile%, SavedSettings, releaseDate
  IniWrite, %ReturnToTypingUser%, %inifile%, SavedSettings, ReturnToTypingUser
  IniWrite, %ShiftDisableCaps%, %inifile%, SavedSettings, ShiftDisableCaps
  IniWrite, %ShowDeadKeys%, %inifile%, SavedSettings, ShowDeadKeys
  IniWrite, %ShowKeyCount%, %inifile%, SavedSettings, ShowKeyCount
  IniWrite, %ShowKeyCountFired%, %inifile%, SavedSettings, ShowKeyCountFired
  IniWrite, %ShowMouseButton%, %inifile%, SavedSettings, ShowMouseButton
  IniWrite, %ShowMouseHalo%, %inifile%, SavedSettings, ShowMouseHalo
  IniWrite, %ShowPrevKey%, %inifile%, SavedSettings, ShowPrevKey
  IniWrite, %ShowPrevKeyDelay%, %inifile%, SavedSettings, ShowPrevKeyDelay
  IniWrite, %ShowSingleKey%, %inifile%, SavedSettings, ShowSingleKey
  IniWrite, %ShowSingleModifierKey%, %inifile%, SavedSettings, ShowSingleModifierKey
  IniWrite, %SilentDetection%, %inifile%, SavedSettings, SilentDetection
  IniWrite, %synchronizeMode%, %inifile%, SavedSettings, synchronizeMode
  IniWrite, %UpDownAsHE%, %inifile%, SavedSettings, UpDownAsHE
  IniWrite, %UpDownAsLR%, %inifile%, SavedSettings, UpDownAsLR
  IniWrite, %version%, %inifile%, SavedSettings, version
  IniWrite, %VisualMouseClicks%, %inifile%, SavedSettings, VisualMouseClicks
  IniWrite, %ToggleKeysBeeper%, %inifile%, SavedSettings, ToggleKeysBeeper
  IniWrite, %SilentMode%, %inifile%, SavedSettings, SilentMode
  IniWrite, %TypingBeepers%, %inifile%, SavedSettings, TypingBeepers
  IniWrite, %DTMFbeepers%, %inifile%, SavedSettings, DTMFbeepers
  IniWrite, %MouseClickRipples%, %inifile%, SavedSettings, MouseClickRipples
  IniWrite, %MouseRippleThickness%, %inifile%, SavedSettings, MouseRippleThickness
  IniWrite, %MouseRippleMaxSize%, %inifile%, SavedSettings, MouseRippleMaxSize
  IniWrite, %pasteOnClick%, %inifile%, SavedSettings, pasteOnClick
  IniWrite, %alternateTypingMode%, %inifile%, SavedSettings, alternateTypingMode
  IniWrite, %DragOSDmode%, %inifile%, SavedSettings, DragOSDmode
  IniWrite, %TypingColorHighlight%, %inifile%, SavedSettings, TypingColorHighlight
  IniWrite, %hostCaretHighlight%, %inifile%, SavedSettings, hostCaretHighlight
  IniWrite, %AltHook2keysUser%, %inifile%, SavedSettings, AltHook2keysUser
  IniWrite, %sendKeysRealTime%, %inifile%, SavedSettings, sendKeysRealTime
  IniWrite, %typingDelaysScaleUser%, %inifile%, SavedSettings, typingDelaysScaleUser
  IniWrite, %sendJumpKeys%, %inifile%, SavedSettings, sendJumpKeys
  IniWrite, %MediateNavKeys%, %inifile%, SavedSettings, MediateNavKeys
  IniWrite, %KBDaltTypeMode%, %inifile%, SavedSettings, KBDaltTypeMode
  IniWrite, %KBDpasteOSDcnt1%, %inifile%, SavedSettings, KBDpasteOSDcnt1
  IniWrite, %KBDpasteOSDcnt2%, %inifile%, SavedSettings, KBDpasteOSDcnt2
  IniWrite, %KBDsynchApp1%, %inifile%, SavedSettings, KBDsynchApp1
  IniWrite, %KBDsynchApp2%, %inifile%, SavedSettings, KBDsynchApp2
  IniWrite, %KBDTglCap2Text%, %inifile%, SavedSettings, KBDTglCap2Text
  IniWrite, %KBDsuspend%, %inifile%, SavedSettings, KBDsuspend
  IniWrite, %KBDTglForceLang%, %inifile%, SavedSettings, KBDTglForceLang
  IniWrite, %KBDTglNeverOSD%, %inifile%, SavedSettings, KBDTglNeverOSD
  IniWrite, %KBDTglPosition%, %inifile%, SavedSettings, KBDTglPosition
  IniWrite, %KBDidLangNow%, %inifile%, SavedSettings, KBDidLangNow
  IniWrite, %KBDReload%, %inifile%, SavedSettings, KBDReload
}

LoadSettings() {
  firstRun := 0
  defOSDautosizeFactory := Round(A_ScreenDPI / 1.18)
  IniRead, alternativeJumps, %inifile%, SavedSettings, alternativeJumps, %alternativeJumps%
  IniRead, audioAlerts, %inifile%, SavedSettings, audioAlerts, %audioAlerts%
  IniRead, AutoDetectKBD, %inifile%, SavedSettings, AutoDetectKBD, %AutoDetectKBD%
  IniRead, beepFiringKeys, %inifile%, SavedSettings, beepFiringKeys, %beepFiringKeys%
  IniRead, CapsColorHighlight, %inifile%, SavedSettings, CapsColorHighlight, %CapsColorHighlight%
  IniRead, CapslockBeeper, %inifile%, SavedSettings, CapslockBeeper, %CapslockBeeper%
  IniRead, ClickScaleUser, %inifile%, SavedSettings, ClickScaleUser, %ClickScaleUser%
  IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
  IniRead, ConstantAutoDetect, %inifile%, SavedSettings, ConstantAutoDetect, %ConstantAutoDetect%
  IniRead, deadKeyBeeper, %inifile%, SavedSettings, deadKeyBeeper, %deadKeyBeeper%
  IniRead, DifferModifiers, %inifile%, SavedSettings, DifferModifiers, %DifferModifiers%
  IniRead, DisableTypingMode, %inifile%, SavedSettings, DisableTypingMode, %DisableTypingMode%
  IniRead, DisplayTimeTypingUser, %inifile%, SavedSettings, DisplayTimeTypingUser, %DisplayTimeTypingUser%
  IniRead, DisplayTimeUser, %inifile%, SavedSettings, DisplayTimeUser, %DisplayTimeUser%
  IniRead, enableAltGr, %inifile%, SavedSettings, enableAltGr, %enableAltGr%
  IniRead, enableTypingHistory, %inifile%, SavedSettings, enableTypingHistory, %enableTypingHistory%
  IniRead, enterErasesLine, %inifile%, SavedSettings, enterErasesLine, %enterErasesLine%
  IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
  IniRead, FontName, %inifile%, SavedSettings, FontName, %FontName%
  IniRead, FontSize, %inifile%, SavedSettings, FontSize, %FontSize%
  IniRead, ForcedKBDlayout, %inifile%, SavedSettings, ForcedKBDlayout, %ForcedKBDlayout%
  IniRead, ForcedKBDlayout1, %inifile%, SavedSettings, ForcedKBDlayout1, %ForcedKBDlayout1%
  IniRead, ForcedKBDlayout2, %inifile%, SavedSettings, ForcedKBDlayout2, %ForcedKBDlayout2%
  IniRead, ForceKBD, %inifile%, SavedSettings, ForceKBD, %ForceKBD%
  IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
  IniRead, GuiWidth, %inifile%, SavedSettings, GuiWidth, %GuiWidth%
  IniRead, GuiXa, %inifile%, SavedSettings, GuiXa, %GuiXa%
  IniRead, GuiXb, %inifile%, SavedSettings, GuiXb, %GuiXb%
  IniRead, GuiYa, %inifile%, SavedSettings, GuiYa, %GuiYa%
  IniRead, GuiYb, %inifile%, SavedSettings, GuiYb, %GuiYb%
  IniRead, HideAnnoyingKeys, %inifile%, SavedSettings, HideAnnoyingKeys, %HideAnnoyingKeys%
  IniRead, IdleMouseAlpha, %inifile%, SavedSettings, IdleMouseAlpha, %IdleMouseAlpha%
  IniRead, IgnoreAdditionalKeys, %inifile%, SavedSettings, IgnoreAdditionalKeys, %IgnoreAdditionalKeys%
  IniRead, IgnorekeysList, %inifile%, SavedSettings, IgnorekeysList, %IgnorekeysList%
  IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, KeyboardShortcuts, %inifile%, SavedSettings, KeyboardShortcuts, %KeyboardShortcuts%
  IniRead, LowVolBeeps, %inifile%, SavedSettings, LowVolBeeps, %LowVolBeeps%
  IniRead, maxGuiWidth, %inifile%, SavedSettings, maxGuiWidth, %maxGuiWidth%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, MouseHaloAlpha, %inifile%, SavedSettings, MouseHaloAlpha, %MouseHaloAlpha%
  IniRead, MouseHaloColor, %inifile%, SavedSettings, MouseHaloColor, %MouseHaloColor%
  IniRead, MouseHaloRadius, %inifile%, SavedSettings, MouseHaloRadius, %MouseHaloRadius%
  IniRead, MouseIdleAfter, %inifile%, SavedSettings, MouseIdleAfter, %MouseIdleAfter%
  IniRead, MouseIdleRadius, %inifile%, SavedSettings, MouseIdleRadius, %MouseIdleRadius%
  IniRead, MouseVclickAlpha, %inifile%, SavedSettings, MouseVclickAlpha, %MouseVclickAlpha%
  IniRead, NeverDisplayOSD, %inifile%, SavedSettings, NeverDisplayOSD, %NeverDisplayOSD%
  IniRead, OSDalignment1, %inifile%, SavedSettings, OSDalignment1, %OSDalignment1%
  IniRead, OSDalignment2, %inifile%, SavedSettings, OSDalignment2, %OSDalignment2%
  IniRead, DoNotBindAltGrDeadKeys, %inifile%, SavedSettings, DoNotBindAltGrDeadKeys, %DoNotBindAltGrDeadKeys%
  IniRead, DoNotBindDeadKeys, %inifile%, SavedSettings, DoNotBindDeadKeys, %DoNotBindDeadKeys%
  IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%
  IniRead, OSDautosize, %inifile%, SavedSettings, OSDautosize, %OSDautosize%
  IniRead, OSDautosizeFactory, %inifile%, SavedSettings, OSDautosizeFactory, %OSDautosizeFactory%
  IniRead, OSDbgrColor, %inifile%, SavedSettings, OSDbgrColor, %OSDbgrColor%
  IniRead, OSDborder, %inifile%, SavedSettings, OSDborder, %OSDborder%
  IniRead, OSDtextColor, %inifile%, SavedSettings, OSDtextColor, %OSDtextColor%
  IniRead, pasteOSDcontent, %inifile%, SavedSettings, pasteOSDcontent, %pasteOSDcontent%
  IniRead, pgUDasHE, %inifile%, SavedSettings, pgUDasHE, %pgUDasHE%
  IniRead, prioritizeBeepers, %inifile%, SavedSettings, prioritizeBeepers, %prioritizeBeepers%
  IniRead, ReturnToTypingUser, %inifile%, SavedSettings, ReturnToTypingUser, %ReturnToTypingUser%
  IniRead, ShiftDisableCaps, %inifile%, SavedSettings, ShiftDisableCaps, %ShiftDisableCaps%
  IniRead, ShowDeadKeys, %inifile%, SavedSettings, ShowDeadKeys, %ShowDeadKeys%
  IniRead, ShowKeyCount, %inifile%, SavedSettings, ShowKeyCount, %ShowKeyCount%
  IniRead, ShowKeyCountFired, %inifile%, SavedSettings, ShowKeyCountFired, %ShowKeyCountFired%
  IniRead, ShowMouseButton, %inifile%, SavedSettings, ShowMouseButton, %ShowMouseButton%
  IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
  IniRead, ShowPrevKey, %inifile%, SavedSettings, ShowPrevKey, %ShowPrevKey%
  IniRead, ShowPrevKeyDelay, %inifile%, SavedSettings, ShowPrevKeyDelay, %ShowPrevKeyDelay%
  IniRead, ShowSingleKey, %inifile%, SavedSettings, ShowSingleKey, %ShowSingleKey%
  IniRead, ShowSingleModifierKey, %inifile%, SavedSettings, ShowSingleModifierKey, %ShowSingleModifierKey%
  IniRead, SilentDetection, %inifile%, SavedSettings, SilentDetection, %SilentDetection%
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
  IniRead, UpDownAsHE, %inifile%, SavedSettings, UpDownAsHE, %UpDownAsHE%
  IniRead, UpDownAsLR, %inifile%, SavedSettings, UpDownAsLR, %UpDownAsLR%
  IniRead, VisualMouseClicks, %inifile%, SavedSettings, VisualMouseClicks, %VisualMouseClicks%
  IniRead, ToggleKeysBeeper, %inifile%, SavedSettings, ToggleKeysBeeper, %ToggleKeysBeeper%
  IniRead, SilentMode, %inifile%, SavedSettings, SilentMode, %SilentMode%
  IniRead, TypingBeepers, %inifile%, SavedSettings, TypingBeepers, %TypingBeepers%
  IniRead, DTMFbeepers, %inifile%, SavedSettings, DTMFbeepers, %DTMFbeepers%
  IniRead, MouseClickRipples, %inifile%, SavedSettings, MouseClickRipples, %MouseClickRipples%
  IniRead, MouseRippleMaxSize, %inifile%, SavedSettings, MouseRippleMaxSize, %MouseRippleMaxSize%
  IniRead, MouseRippleThickness, %inifile%, SavedSettings, MouseRippleThickness, %MouseRippleThickness%
  IniRead, alternateTypingMode, %inifile%, SavedSettings, alternateTypingMode, %alternateTypingMode%
  IniRead, pasteOnClick, %inifile%, SavedSettings, pasteOnClick, %pasteOnClick%
  IniRead, DragOSDmode, %inifile%, SavedSettings, DragOSDmode, %DragOSDmode%
  IniRead, TypingColorHighlight, %inifile%, SavedSettings, TypingColorHighlight, %TypingColorHighlight%
  IniRead, hostCaretHighlight, %inifile%, SavedSettings, hostCaretHighlight, %hostCaretHighlight%
  IniRead, sendKeysRealTime, %inifile%, SavedSettings, sendKeysRealTime, %sendKeysRealTime%
  IniRead, AltHook2keysUser, %inifile%, SavedSettings, AltHook2keysUser, %AltHook2keysUser%
  IniRead, typingDelaysScaleUser, %inifile%, SavedSettings, typingDelaysScaleUser, %typingDelaysScaleUser%
  IniRead, sendJumpKeys, %inifile%, SavedSettings, sendJumpKeys, %sendJumpKeys%
  IniRead, MediateNavKeys, %inifile%, SavedSettings, MediateNavKeys, %MediateNavKeys%
  IniRead, KBDaltTypeMode, %inifile%, SavedSettings, KBDaltTypeMode, %KBDaltTypeMode%
  IniRead, KBDpasteOSDcnt1, %inifile%, SavedSettings, KBDpasteOSDcnt1, %KBDpasteOSDcnt1%
  IniRead, KBDpasteOSDcnt2, %inifile%, SavedSettings, KBDpasteOSDcnt2, %KBDpasteOSDcnt2%
  IniRead, KBDsynchApp1, %inifile%, SavedSettings, KBDsynchApp1, %KBDsynchApp1%
  IniRead, KBDsynchApp2, %inifile%, SavedSettings, KBDsynchApp2, %KBDsynchApp2%
  IniRead, KBDTglCap2Text, %inifile%, SavedSettings, KBDTglCap2Text, %KBDTglCap2Text%
  IniRead, KBDsuspend, %inifile%, SavedSettings, KBDsuspend, %KBDsuspend%
  IniRead, KBDTglForceLang, %inifile%, SavedSettings, KBDTglForceLang, %KBDTglForceLang%
  IniRead, KBDTglNeverOSD, %inifile%, SavedSettings, KBDTglNeverOSD, %KBDTglNeverOSD%
  IniRead, KBDTglPosition, %inifile%, SavedSettings, KBDTglPosition, %KBDTglPosition%
  IniRead, KBDidLangNow, %inifile%, SavedSettings, KBDidLangNow, %KBDidLangNow%
  IniRead, KBDReload, %inifile%, SavedSettings, KBDReload, %KBDReload%

  CheckSettings()
  GuiX := GUIposition=1 ? GuiXa : GuiXb
  GuiY := GUIposition=1 ? GuiYa : GuiYb
}

CheckSettings() {

; verify check boxes
    alternativeJumps := (alternativeJumps=0 || alternativeJumps=1) ? alternativeJumps : 0
    audioAlerts := (audioAlerts=0 || audioAlerts=1) ? audioAlerts : 0
    AutoDetectKBD := (AutoDetectKBD=0 || AutoDetectKBD=1) ? AutoDetectKBD : 1
    beepFiringKeys := (beepFiringKeys=0 || beepFiringKeys=1) ? beepFiringKeys : 0
    SilentMode := (SilentMode=0 || SilentMode=1) ? SilentMode : 0
    ToggleKeysBeeper := (ToggleKeysBeeper=0 || ToggleKeysBeeper=1) ? ToggleKeysBeeper : 1
    CapslockBeeper := (CapslockBeeper=0 || CapslockBeeper=1) ? CapslockBeeper : 1
    ClipMonitor := (ClipMonitor=0 || ClipMonitor=1) ? ClipMonitor : 1
    ConstantAutoDetect := (ConstantAutoDetect=0 || ConstantAutoDetect=1) ? ConstantAutoDetect : 1
    deadKeyBeeper := (deadKeyBeeper=0 || deadKeyBeeper=1) ? deadKeyBeeper : 1
    DifferModifiers := (DifferModifiers=0 || DifferModifiers=1) ? DifferModifiers : 0
    DisableTypingMode := (DisableTypingMode=0 || DisableTypingMode=1) ? DisableTypingMode : 1
    enableAltGr := (enableAltGr=0 || enableAltGr=1) ? enableAltGr : 1
    enableTypingHistory := (enableTypingHistory=0 || enableTypingHistory=1) ? enableTypingHistory : 0
    OSDalignment1 := (OSDalignment1=1 || OSDalignment1=2 || OSDalignment1=3) ? OSDalignment1 : 3
    OSDalignment2 := (OSDalignment2=1 || OSDalignment2=2 || OSDalignment2=3) ? OSDalignment2 : 1
    FlashIdleMouse := (FlashIdleMouse=0 || FlashIdleMouse=1) ? FlashIdleMouse : 0
    ForcedKBDlayout := (ForcedKBDlayout=0 || ForcedKBDlayout=1) ? ForcedKBDlayout : 0
    ForceKBD := (ForceKBD=0 || ForceKBD=1) ? ForceKBD : 0
    GUIposition := (GUIposition=0 || GUIposition=1) ? GUIposition : 1
    HideAnnoyingKeys := (HideAnnoyingKeys=0 || HideAnnoyingKeys=1) ? HideAnnoyingKeys : 1
    IgnoreAdditionalKeys := (IgnoreAdditionalKeys=0 || IgnoreAdditionalKeys=1) ? IgnoreAdditionalKeys : 0
    JumpHover := (JumpHover=0 || JumpHover=1) ? JumpHover : 0
    KeyBeeper := (KeyBeeper=0 || KeyBeeper=1) ? KeyBeeper : 0
    KeyboardShortcuts := (KeyboardShortcuts=0 || KeyboardShortcuts=1) ? KeyboardShortcuts : 1
    LowVolBeeps := (LowVolBeeps=0 || LowVolBeeps=1) ? LowVolBeeps : 1
    ModBeeper := (ModBeeper=0 || ModBeeper=1) ? ModBeeper : 0
    MouseBeeper := (MouseBeeper=0 || MouseBeeper=1) ? MouseBeeper : 0
    NeverDisplayOSD := (NeverDisplayOSD=0 || NeverDisplayOSD=1) ? NeverDisplayOSD : 0
    DoNotBindAltGrDeadKeys := (DoNotBindAltGrDeadKeys=0 || DoNotBindAltGrDeadKeys=1) ? DoNotBindAltGrDeadKeys : 0
    DoNotBindDeadKeys := (DoNotBindDeadKeys=0 || DoNotBindDeadKeys=1) ? DoNotBindDeadKeys : 0
    OSDautosize := (OSDautosize=0 || OSDautosize=1) ? OSDautosize : 1
    OSDborder := (OSDborder=0 || OSDborder=1) ? OSDborder : 0
    pasteOSDcontent := (pasteOSDcontent=0 || pasteOSDcontent=1) ? pasteOSDcontent : 1  
    pgUDasHE := (pgUDasHE=0 || pgUDasHE=1) ? pgUDasHE : 0
    prioritizeBeepers := (prioritizeBeepers=0 || prioritizeBeepers=1) ? prioritizeBeepers : 0
    ShiftDisableCaps := (ShiftDisableCaps=0 || ShiftDisableCaps=1) ? ShiftDisableCaps : 1
    ShowDeadKeys := (ShowDeadKeys=0 || ShowDeadKeys=1) ? ShowDeadKeys : 0
    ShowKeyCount := (ShowKeyCount=0 || ShowKeyCount=1) ? ShowKeyCount : 1
    ShowKeyCountFired := (ShowKeyCountFired=0 || ShowKeyCountFired=1) ? ShowKeyCountFired : 1
    ShowMouseButton := (ShowMouseButton=0 || ShowMouseButton=1) ? ShowMouseButton : 1
    ShowMouseHalo := (ShowMouseHalo=0 || ShowMouseHalo=1) ? ShowMouseHalo : 0
    ShowPrevKey := (ShowPrevKey=0 || ShowPrevKey=1) ? ShowPrevKey : 1
    ShowSingleKey := (ShowSingleKey=0 || ShowSingleKey=1) ? ShowSingleKey : 1
    ShowSingleModifierKey := (ShowSingleModifierKey=0 || ShowSingleModifierKey=1) ? ShowSingleModifierKey : 1
    SilentDetection := (SilentDetection=0 || SilentDetection=1) ? SilentDetection : 1
    synchronizeMode := (synchronizeMode=0 || synchronizeMode=1) ? synchronizeMode : 0
    UpDownAsHE := (UpDownAsHE=0 || UpDownAsHE=1) ? UpDownAsHE : 0
    UpDownAsLR := (UpDownAsLR=0 || UpDownAsLR=1) ? UpDownAsLR : 0
    VisualMouseClicks := (VisualMouseClicks=0 || VisualMouseClicks=1) ? VisualMouseClicks : 0
    TypingBeepers := (TypingBeepers=0 || TypingBeepers=1) ? TypingBeepers : 0
    DTMFbeepers := (DTMFbeepers=0 || DTMFbeepers=1) ? DTMFbeepers : 0
    MouseClickRipples := (MouseClickRipples=0 || MouseClickRipples=1) ? MouseClickRipples : 0
    pasteOnClick := (pasteOnClick=0 || pasteOnClick=1) ? pasteOnClick : 1
    alternateTypingMode := (alternateTypingMode=0 || alternateTypingMode=1) ? alternateTypingMode : 1
    DragOSDmode := (DragOSDmode=0 || DragOSDmode=1) ? DragOSDmode : 0
    hostCaretHighlight := (hostCaretHighlight=0 || hostCaretHighlight=1) ? hostCaretHighlight : 0
    sendKeysRealTime := (sendKeysRealTime=0 || sendKeysRealTime=1) ? sendKeysRealTime : 0
    AltHook2keysUser := (AltHook2keysUser=0 || AltHook2keysUser=1) ? AltHook2keysUser : 1
    sendJumpKeys := (sendJumpKeys=0 || sendJumpKeys=1) ? sendJumpKeys : 0
    MediateNavKeys := (MediateNavKeys=0 || MediateNavKeys=1) ? MediateNavKeys : 0

    if (UpDownAsHE=1) && (UpDownAsLR=1)
       UpDownAsLR := 0

    if (VisualMouseClicks=1) && (MouseClickRipples=1)
       VisualMouseClicks := 0

    if (ShowSingleKey=0)
       DisableTypingMode := 1

    if (DisableTypingMode=1)
    {
       OnlyTypingMode := 0
       MediateNavKeys := 0
       sendJumpKeys := 0
    }

    if (OnlyTypingMode=1) && (enterErasesLine=0)
    {
       sendJumpKeys := 0
       MediateNavKeys := 0
       enableTypingHistory := 0
    }

    if (DisableTypingMode=0) && (OnlyTypingMode=0)
       enterErasesLine := 1

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
     ReturnToTypingUser := 20

  if typingDelaysScaleUser is not digit
     typingDelaysScaleUser := 7

  if FontSize is not digit
     FontSize := 20

  if GuiWidth is not digit
     GuiWidth := 350

  if maxGuiWidth is not digit
     maxGuiWidth := 500

  if IdleMouseAlpha is not digit
     IdleMouseAlpha := 70

  if MouseHaloAlpha is not digit
     MouseHaloAlpha := 130

  if MouseHaloRadius is not digit
     MouseHaloRadius := 85

  if MouseIdleAfter is not digit
     MouseIdleAfter := 10

  if MouseIdleRadius is not digit
     MouseIdleRadius := 130

  if MouseVclickAlpha is not digit
     MouseVclickAlpha := 150

     defOSDautosizeFactory := Round(A_ScreenDPI / 1.18)
  if OSDautosizeFactory is not digit
     OSDautosizeFactory := defOSDautosizeFactory

  if ShowPrevKeyDelay is not digit
     ShowPrevKeyDelay := 300

  if MouseRippleMaxSize is not digit
     MouseRippleMaxSize := 155

  if MouseRippleThickness is not digit
     MouseRippleThickness := 10

; verify minimum numeric values
    ClickScaleUser := (ClickScaleUser < 3) ? 3 : Round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser < 1) ? 1 : Round(DisplayTimeUser)
    DisplayTimeTypingUser := (DisplayTimeTypingUser < 3) ? 3 : Round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser < DisplayTimeTypingUser) ? DisplayTimeTypingUser+1 : Round(ReturnToTypingUser)
    FontSize := (FontSize < 6) ? 7 : Round(FontSize)
    GuiWidth := (GuiWidth < 70) ? 72 : Round(GuiWidth)
    GuiWidth := (GuiWidth < FontSize*2) ? Round(FontSize*5) : Round(GuiWidth)
    maxGuiWidth := (maxGuiWidth < 80) ? 82 : Round(maxGuiWidth)
    maxGuiWidth := (maxGuiWidth < FontSize*2) ? Round(FontSize*6) : Round(maxGuiWidth)
    GuiXa := (GuiXa < -9999) ? -9998 : Round(GuiXa)
    GuiXb := (GuiXb < -9999) ? -9998 : Round(GuiXb)
    GuiYa := (GuiYa < -9999) ? -9998 : Round(GuiYa)
    GuiYb := (GuiYb < -9999) ? -9998 : Round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha < 10) ? 11 : Round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha < 10) ? 11 : Round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius < 5) ? 6 : Round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter < 3) ? 3 : Round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius < 5) ? 6 : Round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha < 10) ? 11 : Round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory < 10) ? 11 : Round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay < 100) ? 101 : Round(ShowPrevKeyDelay)
    MouseRippleThickness := (MouseRippleThickness < 5) ? 5 : Round(MouseRippleThickness)
    MouseRippleMaxSize := (MouseRippleMaxSize < 90) ? 91 : Round(MouseRippleMaxSize)
    typingDelaysScaleUser := (typingDelaysScaleUser < 2) ? 1 : Round(typingDelaysScaleUser)

; verify maximum numeric values
    ClickScaleUser := (ClickScaleUser > 91) ? 90 : Round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser > 99) ? 98 : Round(DisplayTimeUser)
    DisplayTimeTypingUser := (DisplayTimeTypingUser > 99) ? 98 : Round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser > 99) ? 99 : Round(ReturnToTypingUser)
    FontSize := (FontSize > 300) ? 290 : Round(FontSize)
    GuiWidth := (GuiWidth > 2995) ? 2990 : Round(GuiWidth)
    maxGuiWidth := (maxGuiWidth > 2995) ? 2990 : Round(maxGuiWidth)
    GuiXa := (GuiXa > 9999) ? 9998 : Round(GuiXa)
    GuiXb := (GuiXb > 9999) ? 9998 : Round(GuiXb)
    GuiYa := (GuiYa > 9999) ? 9998 : Round(GuiYa)
    GuiYb := (GuiYb > 9999) ? 9998 : Round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha > 240) ? 240 : Round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha > 240) ? 240 : Round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius > 999) ? 900 : Round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter > 999) ? 900 : Round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius > 999) ? 900 : Round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha > 240) ? 240 : Round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory > 402) ? 401 : Round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay > 999) ? 900 : Round(ShowPrevKeyDelay)
    MouseRippleMaxSize := (MouseRippleMaxSize > 401) ? 400 : Round(MouseRippleMaxSize)
    MouseRippleThickness := (MouseRippleThickness > 51) ? 50 : Round(MouseRippleThickness)
    typingDelaysScaleUser := (typingDelaysScaleUser > 39) ? 40 : Round(typingDelaysScaleUser)

; verify HEX values

   if (forcedKBDlayout1 ~= "[^[:xdigit:]]") || (StrLen(forcedKBDlayout1)!=8)
      ForcedKBDlayout1 := "00010418"

   if (forcedKBDlayout2 ~= "[^[:xdigit:]]") || (StrLen(forcedKBDlayout2)!=8)
      ForcedKBDlayout2 := "0000040c"

   if (OSDbgrColor ~= "[^[:xdigit:]]") || (StrLen(OSDbgrColor)!=6)
      OSDbgrColor := "131209"

   if (CapsColorHighlight ~= "[^[:xdigit:]]") || (StrLen(CapsColorHighlight)!=6)
      CapsColorHighlight := "88AAff"

   if (MouseHaloColor ~= "[^[:xdigit:]]") || (StrLen(MouseHaloColor)!=6)
      MouseHaloColor := "eedd00"

   if (TypingColorHighlight ~= "[^[:xdigit:]]") || (StrLen(TypingColorHighlight)!=6)
      TypingColorHighlight := "12E217"
;
   if (OSDtextColor ~= "[^[:xdigit:]]") || (StrLen(OSDtextColor)!=6)
      OSDtextColor := "FFFEFA"

   FontName := (StrLen(FontName)>2) ? FontName : "Arial"
}

createTypingWindow() {
    Global

    Gui, TypingWindow: Destroy
    Gui, TypingWindow: Margin, 20, 10
    Gui, TypingWindow: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow
    Gui, TypingWindow: Color, %TypingColorHighlight%
    WinSet, Transparent, 155
}

SwitchSecondaryTypingMode() {
   if (Capture2Text=1) || (prefOpen=1)
   {
      SoundBeep, 300, 900
      Return
   }

   Sleep, 10
   checkWindowKBD()
   Sleep, 10
   createTypingWindow()
   SecondaryTypingMode := !SecondaryTypingMode

   if (SecondaryTypingMode=1)
   {
       Sleep, 25
       checkWindowKBD()
       Sleep, 25
       WinGetTitle, Window2Activate, A
       toggleWidth := FontSize/2 < 11 ? 11 : FontSize/2 + 40
       typeGuiX := GuiX - toggleWidth/2 - 15
       Gui, TypingWindow: Show, x%typeGuiX% y%GuiY% h%GuiHeight% w%toggleWidth%, KeyPressOSDtyping
       WinSet, AlwaysOnTop, On, KeyPressOSDtyping
       ShowDeadKeys := 0
       ShowSingleKey := 1
       NeverDisplayOSD := 0
       DisableTypingMode := 0
       OnlyTypingMode := 1
       typed := (sendKeysRealTime=1) ? backTypeCtrl : ""
       if (sendKeysRealTime=0)
           backTypeCtrl := ""
       CalcVisibleText()
       OnMSGchar := ""
       SetTimer, checkTypingWindow, on, 700, -10
   } else
   {
       OnMSGchar := ""
       OnMSGdeadChar := ""
       Gui, TypingWindow: Destroy
       IniRead, ShowDeadKeys, %inifile%, SavedSettings, ShowDeadKeys, %ShowDeadKeys%
       IniRead, ShowSingleKey, %inifile%, SavedSettings, ShowSingleKey, %ShowSingleKey%
       IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%
       IniRead, DisableTypingMode, %inifile%, SavedSettings, DisableTypingMode, %DisableTypingMode%
       IniRead, NeverDisplayOSD, %inifile%, SavedSettings, NeverDisplayOSD, %NeverDisplayOSD%
       CalcVisibleText()
       SetTimer, checkTypingWindow, off
   }
   if (NeverDisplayOSD=0)
   {
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
   } else
   {
      Sleep, 300
      HideGUI()
   }
   OnMessage(0x102, "CharMSG", 2)
   OnMessage(0x103, "deadCharMSG", 2)
   Return
}

checkTypingWindow() {
   IfWinNotActive, KeyPressOSDtyping
   {
       backTypeCtrl := typed || (A_TickCount-lastTypedSince > DisplayTimeTyping) ? typed : backTypeCtrl
       Sleep, 200
       if (pasteOnClick=1) && (sendKeysRealTime=0)
          sendOSDcontent()
       Sleep, 45
       SwitchSecondaryTypingMode()
   }
}

CharMSG(wParam, lParam) {
    if (SecondaryTypingMode=0)
       Return

    OnMSGchar := chr(wParam)
    if RegExMatch(OnMSGchar, "[\p{L}\p{Mn}\p{Mc}\p{N}\p{P}\p{S}]")
    {
       InsertChar2caret(OnMSGchar)
       if (sendKeysRealTime=1)
          ControlSend, , {raw}%OnMSGchar%, %Window2Activate%
    }
    Global deadKeyPressed := 9900
    Global lastTypedSince := A_TickCount
    OnMSGchar := ""
    OnMSGdeadChar := ""
    CalcVisibleText()
    ShowHotkey(visibleTextField)
    if (KeyBeeper=1) || (CapslockBeeper=1)
       SetTimer, charMSGbeeper, 40
}

charMSGbeeper() {
    beeperzDefunctions.ahkPostFunction["OnLetterPressed", ""]
    SetTimer,, off
}

deadCharMSG(wParam, lParam) {
  if (SecondaryTypingMode=0)
     Return

  Sleep, 50
  OnMSGdeadChar := chr(wParam) ; & 0xFFFF
  StringReplace, visibleTextField, visibleTextField, %lola%, %OnMSGdeadChar%
  ShowHotkey(visibleTextField)
  Global deadKeyPressed := A_TickCount
  if (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
  SetTimer, returnToTyped, 800, -10
}

saveGuiPositions() {
  if (prefOpen=0)
     SetTimer, HideGUI, 1500

  if (GUIposition=1)
  {
     GuiYa := GuiY
     GuiXa := GuiX
     if (prefOpen=0)
     {
        IniWrite, %GuiXa%, %inifile%, SavedSettings, GuiXa
        IniWrite, %GuiYa%, %inifile%, SavedSettings, GuiYa
     }

     if (prefOpen=1)
     {
       GuiControl, SettingsGUIA:, GuiXa, %GuiX%
       GuiControl, SettingsGUIA:, GuiYa, %GuiY%
     }
  } else
  {
     GuiYb := GuiY
     GuiXb := GuiX
     if (prefOpen=0)
     {
        IniWrite, %GuiXb%, %inifile%, SavedSettings, GuiXb
        IniWrite, %GuiYb%, %inifile%, SavedSettings, GuiYb
     }

     if (prefOpen=1)
     {
       GuiControl, SettingsGUIA:, GuiXb, %GuiX%
       GuiControl, SettingsGUIA:, GuiYb, %GuiY%
     }
  }

  if (OSDalignment>1)
    {
      GuiGetSize(Wid, Heig, 1)
      if (OSDalignment=3)
         dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid) : Round(dGuiX)
      if (OSDalignment=2)
         dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid)/2 : Round(dGuiX)
      Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY%
  }
}

checkifRunningWindow() {
  DetectHiddenWindows, on
  Sleep, 10
  WinGet, otherKP, id, KeyPressOSDwin
  if otherKP not in %OSDhandles%
    ExitApp
  DetectHiddenWindows, off
  SetTimer, , off
}

checkIfRunning() {
    IniRead, prefOpen, %IniFile%, TempSettings, prefOpen, 0
    SetTimer, checkifRunningWindow, 2000, 500
    if (prefOpen=1)
    {
        Sleep, 15
        SoundBeep
        MsgBox, 4,, The app seems to be running. Continue?
        IfMsgBox, Yes
          Return
        else
          ExitApp
    }
}

KeyStrokeReceiver(wParam, lParam) {
    if (NeverDisplayOSD=1) || (SecondaryTypingMode=1) || (prefOpen=1)
       return true

    if TrueRmDkSymbol && (A_TickCount-deadKeyPressed < 9000) || (DeadKeys=0) && (A_TickCount-deadKeyPressed < 9000) || (DoNotBindDeadKeys=1)
    {
       StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
       testKey := StrGet(StringAddress)  ; Copy the string out of the structure.
       if RegExMatch(testKey, "[\p{L}\p{Mn}\p{Mc}\p{N}\p{P}\p{S}]")
          externalKeyStrokeReceived := testKey
    }
    return true
}

;================================================================
; functions by Drugwash. Direct contribuitor to this script. Many thanks!
; ===============================================================
SHLoadIndirectString(in) {
    ; uses WStr for both in and out
    VarSetCapacity(out, 2*(sz:=128), 0)
    DllCall("shlwapi\SHLoadIndirectString", "Str", in, "Str", out, "UInt", sz, "Ptr", 0)
    return out
}

GetLayoutDisplayName(subkey) {
    Static key := "SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    RegRead, mui, HKLM, %key%\%subkey%, Layout Display Name
    if !mui
      RegRead, Dname, HKLM, %key%\%subkey%, Layout Text
    else
      Dname := SHLoadIndirectString(mui)
    Return Dname
}

checkWindowKBD() {
    threadID := GetFocusedThread(hwnd := WinExist("A"))
    hkl := DllCall("GetKeyboardLayout", "UInt", threadID)        ; 0 for current thread
    SetFormat, Integer, H
    hkl+=0
    SetFormat, Integer, D
    if !DllCall("ActivateKeyboardLayout", "UInt", hkl, "UInt", 0x100)  ; hkl: 1=next, 0=previous | flags: 0x100=KLF_SETFORPROCESS
    {
      SetFormat, IntegerFast, H
      l := SubStr(hkl & 0xFFFF, 3), klid := SubStr("00000000" l, -7)
      SetFormat, IntegerFast, D
      DllCall("LoadKeyboardLayout", "Str", klid, "UInt", 0x103)    ; AW, flags: 0x100=KLF_SETFORPROCESS 0x1=KLF_ACTIVATE 0x2=KLF_SUBSTITUTE_OK
    }
    VarSetCapacity(klid, 9*2, 0)  ; 9 Unicode chars
    DllCall("GetKeyboardLayoutName", "Str", klid)  ; AW
;    ToolTip, hwndA=%hwnd% -- hkl=%hkl% -- klid=%klid%
    Return klid
}

GetFocusedThread(hwnd := 0) {
    if !hwnd
       Return 0  ; current thread
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", NULL)
    VarSetCapacity(GTI, sz := 24+6*A_PtrSize, 0)      ; GUITHREADINFO struct
    NumPut(sz, GTI, 0, "UInt")  ; cbSize
    if DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", &GTI)
       if hF := NumGet(GTI, 8+A_PtrSize, "Ptr")
          return DllCall("GetWindowThreadProcessId", "Ptr", hF, "Ptr", NULL)
    Return 0  ; current thread (actually it's an error but we couldn't care less)
}

setColors(hC, event, c, err=0) {
  ; Critical MUST be disabled below! if that's not done, script will enter a deadlock !
  Static
  oc := A_IsCritical
  Critical, Off
  if (event != "Normal")
    Return
  g := A_Gui, ctrl := A_GuiControl
  r := %ctrl% := hexRGB(Dlg_Color(%ctrl%, hC))
  Critical, %oc%
  GuiControl, %g%:+Background%r%, %ctrl%
  GuiControl, Enable, ApplySettingsBTN
  Sleep, 100
  if ctrl not in MouseHaloColor
     OSDpreview()
}

MouseMove(wP, lP, msg, hwnd) {
  Global
  Local A
  SetFormat, IntegerFast, H
  hwnd+=0, A := WinExist("A")
  SetFormat, IntegerFast, D
  if hwnd in %OSDhandles%
  {
    if (DragOSDmode=0 && JumpHover=0 && prefOpen=0) && (A_TickCount - lastTypedSince > 1000)
        HideGUI()
    else if (DragOSDmode=1 || prefOpen=1)
    {
        DllCall("SetCursor", "Ptr", hCursM)
        if !(wP&0x13)    ; no LMR mouse button is down, we hover
        {
          if A not in %OSDhandles%
             hAWin := A
        } else if (wP&0x1)  ; L mouse button is down, we're dragging
        {
          SetTimer, HideGUI, Off
          SetTimer, returnToTyped, Off
          GuiControl, OSD:Disable, Edit1  ; it won't drag if it's not disabled
          While GetKeyState("LButton", "P")
          {
              PostMessage, 0xA1, 2,,, ahk_id %hOSD%
              DllCall("SetCursor", "Ptr", hCursM)
     ;         Sleep, 1
          }
          GuiControl, OSD:Enable, Edit1
          SetTimer, trackMouseDragging, -1
          Sleep, 0
        }
    }
  }
}

trackMouseDragging() {
  Global
  DetectHiddenWindows, On
  WinGetPos, NewX, NewY,,, ahk_id %hOSD%
  if (OSDalignment>1)
  {
     CoordMode Mouse, Screen
     MouseGetPos, NewX, NewY
  }
  GuiX := !NewX ? "2" : NewX
  GuiY := !NewY ? "2" : NewY

  if hAWin
     if hAWin not in %OSDhandles%
        WinActivate, ahk_id %hAWin%

  GuiControl, OSD: Enable, Edit1
  saveGuiPositions()
}
;================================================================
; The following functions were extracted from Font Library 3.0 for AHK
; ===============================================================
Fnt_SetFont(hControl,hFont:="",p_Redraw:=False) {
    Static Dummy30050039
          ,DEFAULT_GUI_FONT:= 17
          ,OBJ_FONT        := 6
          ,WM_SETFONT      := 0x30

    ;-- if needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Set font
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hControl%
    DetectHiddenWindows %l_DetectHiddenWindows%
}

Fnt_CreateFont(p_Name:="",p_Options:="") {
    Static Dummy34361446

          ;-- Misc. font constants
          ,LOGPIXELSY:=90
          ,CLIP_DEFAULT_PRECIS:=0
          ,DEFAULT_CHARSET    :=1
          ,DEFAULT_GUI_FONT   :=17
          ,OUT_TT_PRECIS      :=4

          ;-- Font family
          ,FF_DONTCARE  :=0x0
          ,FF_ROMAN     :=0x1
          ,FF_SWISS     :=0x2
          ,FF_MODERN    :=0x3
          ,FF_SCRIPT    :=0x4
          ,FF_DECORATIVE:=0x5

          ;-- Font pitch
          ,DEFAULT_PITCH :=0
          ,FIXED_PITCH   :=1
          ,VARIABLE_PITCH:=2

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Font weight
          ,FW_DONTCARE:=0
          ,FW_NORMAL  :=400
          ,FW_BOLD    :=700

    ;-- Parameters
    ;   Remove all leading/trailing white space
    p_Name   :=Trim(p_Name," `f`n`r`t`v")
    p_Options:=Trim(p_Options," `f`n`r`t`v")

    ;-- if both parameters are null or unspecified, return the handle to the
    ;   default GUI font.
    if (p_Name="" and p_Options="")
        Return DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Initialize options
    o_Height   :=""             ;-- Undefined
    o_Italic   :=False
    o_Quality  :=PROOF_QUALITY  ;-- AutoHotkey default
    o_Size     :=""             ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=FW_DONTCARE

    ;-- Extract options (if any) from p_Options
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        if (SubStr(A_LoopField,1,4)="bold")
            o_Weight:=FW_BOLD
        else if (SubStr(A_LoopField,1,6)="italic")
            o_Italic:=True
        else if (SubStr(A_LoopField,1,4)="norm")
            {
            o_Italic   :=False
            o_Strikeout:=False
            o_Underline:=False
            o_Weight   :=FW_DONTCARE
            }
        else if (A_LoopField="-s")
            o_Size:=0
        else if (SubStr(A_LoopField,1,6)="strike")
            o_Strikeout:=True
        else if (SubStr(A_LoopField,1,9)="underline")
            o_Underline:=True
        else if (SubStr(A_LoopField,1,1)="h")
            {
            o_Height:=SubStr(A_LoopField,2)
            o_Size  :=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="q")
            o_Quality:=SubStr(A_LoopField,2)
        else if (SubStr(A_LoopField,1,1)="s")
            {
            o_Size  :=SubStr(A_LoopField,2)
            o_Height:=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="w")
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- Convert/Fix invalid or
    ;-- unspecified parameters/options
    if p_Name is Space
        p_Name:=Fnt_GetFontName()   ;-- Font name of the default GUI font

    if o_Height is not Integer
        o_Height:=""                ;-- Undefined

    if o_Quality is not Integer
        o_Quality:=PROOF_QUALITY    ;-- AutoHotkey default

    if o_Size is Space              ;-- Undefined
        o_Size:=Fnt_GetFontSize()   ;-- Font size of the default GUI font
     else
        if o_Size is not Integer
            o_Size:=""              ;-- Undefined
         else
            if (o_Size=0)
                o_Size:=""          ;-- Undefined

    if o_Weight is not Integer
        o_Weight:=FW_DONTCARE       ;-- A font with a default weight is created

    ;-- if needed, convert point size to em height
    if o_Height is Space        ;-- Undefined
        if o_Size is Integer    ;-- Allows for a negative size (emulates AutoHotkey)
            {
            hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
            o_Height:=-Round(o_Size*DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)/72)
            DllCall("DeleteDC","Ptr",hDC)
            }

    if o_Height is not Integer
        o_Height:=0                 ;-- A font with a default height is created

    ;-- Create font
    hFont:=DllCall("CreateFont"
        ,"Int",o_Height                                 ;-- nHeight
        ,"Int",0                                        ;-- nWidth
        ,"Int",0                                        ;-- nEscapement (0=normal horizontal)
        ,"Int",0                                        ;-- nOrientation
        ,"Int",o_Weight                                 ;-- fnWeight
        ,"UInt",o_Italic                                ;-- fdwItalic
        ,"UInt",o_Underline                             ;-- fdwUnderline
        ,"UInt",o_Strikeout                             ;-- fdwStrikeOut
        ,"UInt",DEFAULT_CHARSET                         ;-- fdwCharSet
        ,"UInt",OUT_TT_PRECIS                           ;-- fdwOutputPrecision
        ,"UInt",CLIP_DEFAULT_PRECIS                     ;-- fdwClipPrecision
        ,"UInt",o_Quality                               ;-- fdwQuality
        ,"UInt",(FF_DONTCARE<<4)|DEFAULT_PITCH          ;-- fdwPitchAndFamily
        ,"Str",SubStr(p_Name,1,31))                     ;-- lpszFace

    Return hFont
}

Fnt_DeleteFont(hFont) {
    if not hFont  ;-- Zero or null
        Return True

    Return DllCall("DeleteObject","Ptr",hFont) ? True:False
}

Fnt_GetFontName(hFont:="") {
    Static Dummy87890484
          ,DEFAULT_GUI_FONT    :=17
          ,HWND_DESKTOP        :=0
          ,OBJ_FONT            :=6
          ,MAX_FONT_NAME_LENGTH:=32     ;-- In TCHARS

    ;-- if needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the font name
    VarSetCapacity(l_FontName,MAX_FONT_NAME_LENGTH*(A_IsUnicode ? 2:1))
    DllCall("GetTextFace","Ptr",hDC,"Int",MAX_FONT_NAME_LENGTH,"Str",l_FontName)

    ;-- Release the objects needed by the GetTextFace function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
    Return l_FontName
}

Fnt_GetFontSize(hFont:="") {
    Static Dummy64998752

          ;-- Device constants
          ,HWND_DESKTOP:=0
          ,LOGPIXELSY  :=90

          ;-- Misc.
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6

    ;-- if needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Collect the number of pixels per logical inch along the screen height
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)

    ;-- Get text metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("GetTextMetrics","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Convert em height to point size
    l_Size:=Round((NumGet(TEXTMETRIC,0,"Int")-NumGet(TEXTMETRIC,12,"Int"))*72/l_LogPixelsY)
        ;-- (Height - Internal Leading) * 72 / LogPixelsY

    ;-- Release the objects needed by the GetTextMetrics function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
    Return l_Size
}

Fnt_GetListOfFonts() {
; function stripped down from Font Library 3.0 by jballi
; from https://autohotkey.com/boards/viewtopic.php?t=4379

    Static Dummy65612414
          ,HWND_DESKTOP := 0  ;-- Device constants
          ,LF_FACESIZE := 32  ;-- In TCHARS - LOGFONT constants

    ;-- Initialize and populate LOGFONT structure
    Fnt_EnumFontFamExProc_List := ""
    p_CharSet := 1
    p_Flags := 0x800
    VarSetCapacity(LOGFONT,A_IsUnicode ? 92:60,0)
    NumPut(p_CharSet,LOGFONT,23,"UChar")                ;-- lfCharSet

    ;-- Enumerate fonts
    hDC := DllCall("GetDC","Ptr",HWND_DESKTOP)
    DllCall("EnumFontFamiliesEx"
        ,"Ptr",hDC                                      ;-- hdc
        ,"Ptr",&LOGFONT                                 ;-- lpLogfont
        ,"Ptr",RegisterCallback("Fnt_EnumFontFamExProc","Fast")
            ;-- lpEnumFontFamExProc
        ,"Ptr",p_Flags                                  ;-- lParam
        ,"UInt",0)                                      ;-- dwFlags (must be 0)

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
    Return Fnt_EnumFontFamExProc_List
}

Fnt_EnumFontFamExProc(lpelfe,lpntme,FontType,p_Flags) {
    Fnt_EnumFontFamExProc_List := 0
    Static Dummy62479817
           ,LF_FACESIZE := 32  ;-- In TCHARS - LOGFONT constants

    l_FaceName := StrGet(lpelfe+28,LF_FACESIZE)
    FontList.Push(l_FaceName)    ;-- Append the font name to the list
    Return True  ;-- Continue enumeration
}
; ------------------------------------------------------------- ; Font Library

; String Things - Common String & Array Functions, 2014
; by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/
; ============================================================================================================================
ST_Insert(insert,input,pos=1) {
  Length := StrLen(input)
  ((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
  output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
  if (StrLen(output) > StrLen(input) + StrLen(insert))
    ((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
  return, output
}

st_count(string, searchFor="`n") {
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}

st_delete(string, start=1, length=1) {
   if (abs(start+length) > StrLen(string))
      return string
   if (start>0)
      return SubStr(string, 1, start-1) . SubStr(string, start + length)
   else if (start<=0)
      return SubStr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}

st_overwrite(overwrite, into, pos=1) {
   if (abs(pos) > StrLen(into))
      return into
   else if (pos>0)
      return SubStr(into, 1, pos-1) . overwrite . SubStr(into, pos+StrLen(overwrite))
   else if (pos<0)
      return SubStr(into, 1, pos) . overwrite . SubStr(into " ",(abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0),abs(pos+StrLen(overwrite)))
   else if (pos=0)
      return into . overwrite
}
;============================================================ String Things by tidbit

dummy() {
    MsgBox, This feature is not yet available. It might be implemented soon. Thank you.
}

#SPACE::
Return
