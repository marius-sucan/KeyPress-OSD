; KeypressOSD.ahk - main file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.
;
; Script written for AHK_H / AHK_L v1.1.27 Unicode.
;--------------------------------------------------------------------------------------------------------------------------
;
; Change log file:
;   keypress-osd-changelog.txt
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-changelog.txt
/*
<p>How it works:</p>
<p>When the script initializes, it goes through all the Virtual Key codes and tests with ToUnicodeEx() and GetKeyName() if there is something to bind to (a key name). </p>
<p>At init, it also identifies dead keys and makes a list of them and their names. These lists, for each installed layout, are saved in an INI file, a language file. They are used to bind to dead keys in a disctintive manner and to display their symbols. One cannot use ToUnicodeEx() each time such a key is pressed, because they no longer function properly in host apps.</p>

<p>The main typing mode hooks to each key using the Hotkey command from AHK, by Virtual Key (vk) and different modifiers. For the Shift and AltGr key combinations, the script binds distinctively, because it must be able to catch these keys orderly and always be able to determine what key name to display using ToUnicodeEx(). If it would bind simply with the (*) wildcard, dead keys cease to function and on slow systems, modifiers detection becomes unreliable. By binding specifically to each modifier and key, based on the prefixes from the built-in variable %A_THISHOTKEY%, it can always determine what to display.</p>

<p>When alternative hooks are enabled, a different thread runs with a Loop for an Input command limited to one character. This input command is able to capture dead keys combinations (accented letters). For each key pressed, I use SendMessage to the main thread of the script, that uses OnMessage for WM_COPYDATA. The function associated processes the incoming messages / keys. What this secondary thread sends is used only after a dead key was pressed. Thus, it all still relies on the Hotkey command to get all keys and ToUnicodeEx(), except for the accented letters (keys resulted from using dead keys). When the layout is supported, but it has no dead keys , this secondary thread is never initiated.</p>

<p>When alternate typing mode is invoked, I create a new window and focus it, to capture keys with two OnMessages hooked to WM_CHAR and WM_DEADCHAR. I no longer rely on the Hotkey bindings or Input command from the secondary thread. When the user hits Enter, I use SendInput, {text}.</p>
*/
; Compilation directives; include files in binary and set file properties ----------------------------------------------------------------------------
;@Ahk2Exe-AddResource WAVE sounds\caps.wav
;@Ahk2Exe-AddResource WAVE sounds\clickM.wav
;@Ahk2Exe-AddResource WAVE sounds\clickR.wav
;@Ahk2Exe-AddResource WAVE sounds\clicks.wav
;@Ahk2Exe-AddResource WAVE sounds\cups.wav
;@Ahk2Exe-AddResource WAVE sounds\deadkeys.wav
;@Ahk2Exe-AddResource WAVE sounds\firedkey.wav
;@Ahk2Exe-AddResource WAVE sounds\functionKeys.wav
;@Ahk2Exe-AddResource WAVE sounds\holdingKeys.wav
;@Ahk2Exe-AddResource WAVE sounds\keys.wav
;@Ahk2Exe-AddResource WAVE sounds\media.wav
;@Ahk2Exe-AddResource WAVE sounds\modfiredkey.wav
;@Ahk2Exe-AddResource WAVE sounds\mods.wav
;@Ahk2Exe-AddResource WAVE sounds\num0pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num1pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num2pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num3pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num4pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num5pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num6pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num7pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num8pad.wav
;@Ahk2Exe-AddResource WAVE sounds\num9pad.wav
;@Ahk2Exe-AddResource WAVE sounds\numApad.wav
;@Ahk2Exe-AddResource WAVE sounds\numpads.wav
;@Ahk2Exe-AddResource WAVE sounds\otherDistinctKeys.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysArrowsD.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysArrowsL.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysArrowsR.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysArrowsU.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysBksp.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysDel.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysEnd.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysEnter.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysHome.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysPgDn.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysPgUp.wav
;@Ahk2Exe-AddResource WAVE sounds\typingkeysSpace.wav
;@Ahk2Exe-AddResource LIB Lib\keypress-mouse-functions.ahk
;@Ahk2Exe-AddResource LIB Lib\keypress-mouse-ripples-functions.ahk
;@Ahk2Exe-AddResource LIB Lib\keypress-beeperz-functions.ahk
;@Ahk2Exe-AddResource LIB Lib\keypress-keystrokes-helper.ahk
;@Ahk2Exe-AddResource Lib\paypal.bmp, 100
;@Ahk2Exe-SetMainIcon Lib\keypress.ico
;@Ahk2Exe-SetName KeyPress OSD v4
;@Ahk2Exe-SetDescription KeyPress OSD v4
;@Ahk2Exe-SetVersion 4.22.5
;@Ahk2Exe-SetCopyright Marius Şucan (2017-2018)
;@Ahk2Exe-SetCompanyName ROBO Design.ro
;@Ahk2Exe-SetOrigFilename keypress-osd.ahk

; Script Initialization

 #SingleInstance Force
 #NoEnv
 #MaxHotkeysPerInterval 500
 #MaxThreads 255
 #MaxThreadsPerHotkey 255
 #MaxThreadsBuffer On
 #WinActivateForce
 ComObjError(false)
 SetTitleMatchMode, 2
 SetBatchLines, -1
 ListLines, Off
 SetWorkingDir, %A_ScriptDir%
 Critical, on

 Menu, Tray, UseErrorLevel
 Menu, Tray, NoStandard
 Menu, Tray, Add, E&xit, KillScript
 Menu, Tray, Add, 
 Menu, Tray, Add, Initializing..., dummy
 Menu, Tray, Disable, Initializing...
 Menu, Tray, Tip, KeyPress OSD: Initializing...
 If !A_IsCompiled
    Menu, Tray, Icon, Lib\keypress.ico

; Default Settings / Customize:

 Global IgnoreAdditionalKeys  := 0
 , IgnorekeysList        := "a.b.c"
 , DoNotBindDeadKeys     := 0
 , DoNotBindAltGrDeadKeys := 0
 , AutoDetectKBD         := 1     ; at start, detect keyboard layout
 , ConstantAutoDetect    := 1     ; continuously check if the keyboard layout changed; if AutoDetectKBD=0, this is ignored
 , SilentDetection       := 0     ; do not display information about language switching
 , audioAlerts           := 0     ; generate beeps when key bindings fail
 , EnforceSluggishSynch  := 0
 , enableAltGr           := 1
 , AltHook2keysUser      := 1
 , typingDelaysScaleUser := 7
 , UseMUInames           := 1
 , maximumTextClips      := 10
 , enableClipManager     := 0
 
 , lola                  := "│"
 , lola2                 := "║"
 , DisableTypingMode     := 0     ; do not echo what you write
 , OnlyTypingMode        := 0
 , alternateTypingMode   := 1
 , enableTypingHistory   := 0
 , expandWords           := 0
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
 , mouseOSDbehavior      := 1
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
 , GuiXb                 := 700
 , GuiYb                 := 500
 , GuiWidth              := 350
 , maxGuiWidth           := 550
 , FontName              := "Arial"
 , FontSize              := 19
 , prefsLargeFonts       := 0
 , OSDalignment1         := 3     ; 1 = left ; 2 = center ; 3 = right
 , OSDalignment2         := 1     ; 1 = left ; 2 = center ; 3 = right
 , OSDbgrColor           := "131209"
 , OSDtextColor          := "FFFEFA"
 , CapsColorHighlight    := "88AAff"
 , TypingColorHighlight  := "12E217"
 , OSDshowLEDs           := 1
 , OSDautosize           := 1     ; make adjustments to the growth factors to match your font size
 , OSDautosizeFactory    := Round(A_ScreenDPI / 1.1)
 , outputOSDtoToolTip    := 0
 
 , CapslockBeeper        := 1     ; only when the key is released
 , ToggleKeysBeeper      := 1
 , KeyBeeper             := 0     ; only when the key is released
 , deadKeyBeeper         := 1
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and VisualMouseClicks are disabled, mouse click beeps will never occur
 , TypingBeepers         := 0
 , DTMFbeepers           := 0
 , beepFiringKeys        := 0
 , BeepSentry            := 0
 , BeepsVolume           := 60
 , SilentMode            := 0
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall

 , KeyboardShortcuts     := 1     ; system-wide shortcuts
 , ClipMonitor           := 1     ; show clipboard changes
 , ShiftDisableCaps      := 1

 , VisualMouseClicks     := 0     ; shows visual indicators for different mouse clicks
 , MouseClickRipples     := 0
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , MouseVclickColor      := "555555"
 , ClickScaleUser        := 10
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , MouseHaloRadius       := 85
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , MouseIdleRadius       := 130
 , MouseIdleColor        := "333333"
 , MouseIdleAfter        := 10    ; in seconds
 , IdleMouseAlpha        := 70    ; from 0 to 255
 , MouseRippleMaxSize    := 155
 , MouseRippleThickness  := 10

 , KBDaltTypeMode        := "^+CapsLock"
 , KBDpasteOSDcnt1       := "^+Insert"
 , KBDpasteOSDcnt2       := "^!Insert"
 , KBDsynchApp1          := "#Insert"
 , KBDsynchApp2          := "#!Insert"
 , KBDsuspend            := "+Pause"
 , KBDTglNeverOSD        := "!+^F8"
 , KBDTglPosition        := "!+^F9"
 , KBDTglSilence         := "!+^F10"
 , KBDidLangNow          := "!+^F11"
 , KBDReload             := "!+^F12"
 , KBDCapText            := "Disabled"
 , KBDclippyMenu         := "#v"

 , doBackup              := 0    ; if enabled, each update will backup previous files to a separate folder
 , TextZoomer            := 0
 , thisFile              := A_ScriptName
 , UseINIfile            := 1
 , IniFile               := "keypress-osd.ini"
 , version               := "4.23"
 , releaseDate := "2018 / 03 / 06"

; Initialization variables. Altering these may lead to undesired results.

    checkIfRunning()
    Sleep, 5
    IniRead, firstRun, %IniFile%, SavedSettings, firstRun, 1
    If (firstRun=0 && UseINIfile=1)
    {
        LoadSettings()
    } Else If (UseINIfile=1)
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
 , pressKeyRecorded := 1
 , typedKeysHistory := ""
 , keyCount := 0
 , ExpandWordsList := []
 , ExpandWordsListEdit := ""
 , lastMatchedExpandPair := ""
 , modifiers_temp := 0
 , doNotRepeatTimer := 0
 , OSDalignment := (GUIposition=1) ? OSDalignment2 : OSDalignment1
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , GuiHeight := 50                    ; a default, later overriden
 , maxAllowedGuiWidth := A_ScreenWidth
 , prefOpen := 0
 , externalKeyStrokeReceived := ""    ; for alternative hooks
 , visibleTextField := ""
 , text_width := 60
 , langfile := "keypress-osd-languages.ini"
 , CaretPos := "1"
 , SecondaryTypingMode := 0
 , maxTextChars := "4"
 , lastTypedSince := 0
 , editingField := "3"
 , editField0 := ""
 , editField1 := " "
 , editField2 := " "
 , editField3 := " "
 , editField4 := ""
 , backTypeCtrl := ""
 , backTypdUndo := ""
 , CurrentKBD := "KeyPress OSD default: English US."
 , loadedLangz := 0
 , globalNewKBD := "{Empty}"
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
 , isLangRTL := 0
 , DKnamez := "▪"
 , FontList := []
 , CurrentPrefWindow := ""
 , missingAudios := 1
 , globalPrefix := ""
 , deadKeyPressed := "9950"
 , TrueRmDkSymbol := ""
 , LargeUIfontValue := 13
 , showPreview := 0
 , OSDcontentOutput := ""
 , anyWindowOpen := 0
 , previewWindowText := "Preview │window... ║"
 , MainModsList := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
 , hOSD, OSDhandles, colorPickerHandles, nowDraggable, mouseFonctiones, beeperzDefunctions, mouseRipplesThread, keyStrokesThread, NOahkH
 , cclvo := "-E0x200 +Border -Hdr -Multi +ReadOnly Report -Hidden AltSubmit gsetColors"
 , Emojis := "(😝|😐|👄|😭|👋|💯|👽|👶|👙|😎|😋|🙈|🙊|👼|💏|😃|😴|💁|💃|👏|💤|⛄|🌙|👳|😳|😛|🎄|😢|😮|😜|😡|😉|😞|😗|🌜|😙|♥|😩|😆|😚|👍|💋|️|🌸|💖|😈|🌛|☀|💕|😄|😊|😂|😕|🌷|💓|💗|🙏|😍|😔|❤|☹|💞|🙁|🙂|😀|😇|☺|😘)"
 , isMouseFile, isRipplesFile, isBeeperzFile, isKeystrokesFile, isAcc1File, isAcc2File
 , baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
 , hWinMM := DllCall("kernel32\LoadLibraryW", "Str", "winmm.dll", "Ptr")
 , VolR := GetMyVolume(VolL)
 , clipDataMD5s, currentClippyCount
 , ScriptelSuspendel := 0
 , RunningCompiled := A_IsCompiled ? "Y" : 0
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth

CreateOSDGUI()
verifyNonCrucialFiles()
Sleep, 5
CreateGlobalShortcuts()
CreateHotkey()
initAHKhThreads()
GoSub CheckAcc
InitializeTray()
SetMyVolume()
If (ClipMonitor=1)
   OnClipboardChange("ClipChanged")

hCursM := DllCall("user32\LoadCursorW", "Ptr", NULL, "Int", 32646, "Ptr")  ; IDC_SIZEALL
hCursH := DllCall("user32\LoadCursorW", "Ptr", NULL, "Int", 32649, "Ptr")  ; IDC_HAND
OnMessage(0x200, "MouseMove")    ; WM_MOUSEMOVE
If (expandWords=1 && DisableTypingMode=0)
   InitExpandableWords()
If (enableClipManager=1)
   initClipboardManager()
ModsLEDsIndicatorsManager(1)
Return

;================================================================
; The script
;================================================================

initAHKhThreads() {
    Static func2exec := "ahkThread"
    If IsFunc(func2exec)
    {
      If A_IsCompiled
      {
         If FindRes(0, "KEYPRESS-MOUSE-FUNCTIONS.AHK", "LIB")
         {
            GetRes(data, 0, "KEYPRESS-MOUSE-FUNCTIONS.AHK", "LIB"), sTxt := StrGet(&data)
            Global mouseFonctiones := %func2exec%(sTxt)
            Sleep, 50
            isMouseFile := mouseFonctiones.ahkgetvar.isMouseFile
         }
         If FindRes(0, "KEYPRESS-MOUSE-RIPPLES-FUNCTIONS.AHK", "LIB")
         {
            GetRes(data, 0, "KEYPRESS-MOUSE-RIPPLES-FUNCTIONS.AHK", "LIB"), sTxt := StrGet(&data)
            Global mouseRipplesThread := %func2exec%(sTxt)
            Sleep, 50
            isRipplesFile := mouseRipplesThread.ahkgetvar.isRipplesFile
         }
         If FindRes(0, "KEYPRESS-BEEPERZ-FUNCTIONS.AHK", "LIB")
         {
            GetRes(data, 0, "KEYPRESS-BEEPERZ-FUNCTIONS.AHK", "LIB"), sTxt := StrGet(&data)
            Global beeperzDefunctions := %func2exec%(sTxt)
            Sleep, 50
            isBeeperzFile := beeperzDefunctions.ahkgetvar.isBeeperzFile
            beeperzDefunctions.ahkassign("RunningCompiled", RunningCompiled)
         }

         If (DisableTypingMode=0 && ShowSingleKey=1)
         {
            If FindRes(0, "KEYPRESS-KEYSTROKES-HELPER.AHK", "LIB")
            {
              isKeystrokesFile := 1
              If AlternativeHook2keys=1
              {
                  GetRes(data, 0, "KEYPRESS-KEYSTROKES-HELPER.AHK", "LIB"), sTxt := StrGet(&data)
                  Global keyStrokesThread := %func2exec%(sTxt)
                  Sleep, 50
                  isKeystrokesFile := keyStrokesThread.ahkgetvar.isKeystrokesFile
                  OnMessage(0x4a, "KeyStrokeReceiver")  ; 0x4a is WM_COPYDATA
              }
            }
         }
         VarSetCapacity(data, 0), VarSetCapacity(sTxt, 0)
      } Else
      {
          isMouseFile := FileExist("Lib\keypress-mouse-functions.ahk")
          isRipplesFile := FileExist("Lib\keypress-mouse-ripples-functions.ahk")
          isBeeperzFile := FileExist("Lib\keypress-beeperz-functions.ahk")
          isKeystrokesFile := FileExist("Lib\keypress-keystrokes-helper.ahk")
          Global mouseFonctiones := %func2exec%(" #Include *i Lib\keypress-mouse-functions.ahk ")
          Global mouseRipplesThread := %func2exec%(" #Include *i Lib\keypress-mouse-ripples-functions.ahk ")
          Global beeperzDefunctions := %func2exec%(" #Include *i Lib\keypress-beeperz-functions.ahk ")
          If (AlternativeHook2keys=1 && DisableTypingMode=0 && ShowSingleKey=1 && isKeystrokesFile)
          {
              Global keyStrokesThread := %func2exec%(" #Include *i Lib\keypress-keystrokes-helper.ahk ")
              OnMessage(0x4a, "KeyStrokeReceiver")  ; 0x4a is WM_COPYDATA
          }
      }
    } Else (NOahkH := 1)
}

TypedLetter(key,onLatterUp:=0) {
;  Sleep, 50 ; megatest

   If (ShowSingleKey=0 || DisableTypingMode=1)
   {
      typed := ""
      Return
   }
   If (outputOSDtoToolTip=0 && NeverDisplayOSD=1)
   {
      typed := ""
      Return
   }

   If (SecondaryTypingMode=0)
   {
      If (onLatterUp=0)
         typedKeysHistory .= key
      StringRight, typedKeysHistory, typedKeysHistory, 30

      If InStr(A_ThisHotkey, "+")
         shiftPressed := 1

      If (enableAltGr=1 && (InStr(A_ThisHotkey, "^!") || InStr(A_ThisHotkey, "<^>")))
         AltGrPressed := 1

      If (AlternativeHook2keys=1 && DeadKeys=0)
         Sleep, 30

      vk := "0x0" SubStr(key, InStr(key, "vk", 0, 0)+2)
      sc := "0x0" GetKeySc("vk" vk)
      key := toUnicodeExtended(vk, sc, shiftPressed, AltGrPressed,0,onLatterUp)

      If (AlternativeHook2keys=1) && TrueRmDkSymbol && (A_TickCount-deadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DeadKeys=0) && (A_TickCount-deadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DoNotBindDeadKeys=1) && (A_TickCount - lastTypedSince > 200)
      {
         Sleep, 30
         If (externalKeyStrokeReceived=TrueRmDkSymbol && DoNotBindDeadKeys=0)
            externalKeyStrokeReceived .= key
         typed := (externalKeyStrokeReceived && AlternativeHook2keys=1) ? InsertChar2caret(externalKeyStrokeReceived) : InsertChar2caret(key)
         externalKeyStrokeReceived := ""
         If (DeadKeys=0) && (A_TickCount-deadKeyPressed > 1000)
            Global deadKeyPressed := 15000
      } Else (typed := InsertChar2caret(key))

      externalKeyStrokeReceived := ""
      TrueRmDkSymbol := ""
      Global lastTypedSince := A_TickCount
   }
   Return typed
}

replaceSelection(copy2clip:=0,EraseSelection:=1) {
  backTypdUndo := typed
  StringGetPos, CaretPos, typed, %lola%
  StringGetPos, CaretPos2, typed, %lola2%
  brr := RegExMatch(typed, "i)((│|║).*?=?(│|║))", loca)
  If (EraseSelection=1)
  {
     StringReplace, typed, typed, %loca%, %lola%
     StringReplace, typed, typed, %lola2%
     StringReplace, typed, typed, %lola%
     CaretBoss := (CaretPos2 > CaretPos) ? CaretPos+1 : CaretPos2+1
     typed := ST_Insert(lola, typed, CaretBoss)
  }

  If (copy2clip=1 && SecondaryTypingMode=1)
  {
     StringReplace, loca, loca, %lola2%
     StringReplace, loca, loca, %lola%
     Clipboard := loca
  }
}

InsertChar2caret(char) {
;  Sleep, 150 ; megatest
  If (NeverDisplayOSD=1 && outputOSDtoToolTip=0)
     Return
  If (st_count(typed, lola2)>0)
     replaceSelection()

  If (CaretPos = 2000)
     CaretPos := 1

  If (CaretPos = 3000)
     CaretPos := StrLen(typed)+1

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%

  CaretPos := (isLangRTL=1) ? StrLen(typed)+1 : CaretPos+1
  typed := ST_Insert(char lola, typed, CaretPos)
  If (A_TickCount-deadKeyPressed>150)
      CalcVisibleText()
  Else
      SetTimer, CalcVisibleTextFieldDummy, 200, 50
  Return typed
}

CalcVisibleTextFieldDummy() {
    CalcVisibleText()
    If (StrLen(visibleTextField)>0)
    {
       ShowHotkey(visibleTextField)
       SetTimer, HideGUI, % -DisplayTimeTyping
    }
    SetTimer,, off
}

CalcVisibleText() {
;  Sleep, 30 ; megatest
   maxTextLimit := 0
   If (isLangRTL=1)
   {
      StringReplace, visibleTextField, typed, %lola%, %A_Space%
   } Else
   {
      visibleTextField := typed
      text_width0 := GetTextExtentPoint(typed, FontName, FontSize) / (OSDautosizeFactory/100)
      If (text_width0 > maxAllowedGuiWidth) && typed
         maxTextLimit := 1
   }

   If (maxTextLimit>0 && isLangRTL=0)
   {
      cola := lola
      maxA_Index := (maxTextChars<6) ? StrLen(typed) : Round(maxTextChars*1.3)

      If (st_count(typed, lola2)>0)
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
        If (text_width2 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
           allGood := 1
      }
      Until (allGood=1) || (A_Index=Round(maxA_Index)) || (A_Index>=5000)

      If (allGood!=1)
      {
          Loop
          {
            Stringmid, NEWvisibleTextField, typed, vCaretPos+A_Index, , L
            text_width3 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize) / (OSDautosizeFactory/100)
            If (text_width3 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
               stopLoop2 := 1
          }
          Until (stopLoop2 = 1) || (A_Index=Round(maxA_Index/1.25)) || (A_Index>=5000)
      }

      If (addSelMarker=1 && (st_count(NEWvisibleTextField, lola)<1))
         NEWvisibleTextField := (addSelMarkerLocation=2) ? "▪ " NEWvisibleTextField : NEWvisibleTextField " ▪"
      If (isLangRTL=1)
         StringReplace, NEWvisibleTextField, NEWvisibleTextField, %lola%
      visibleTextField := NEWvisibleTextField
      maxTextChars := maxTextChars<3 ? maxTextChars : StrLen(visibleTextField)+3
   }
}

caretMover(direction,inLoop:=0) {
  If (isLangRTL=1)
     Return

  StringGetPos, CaretPos, typed, %lola%
  StringGetPos, CaretPosSelly, typed, %lola2%
  direction2check := (direction=2) ? CaretPos+3 : CaretPos
  testChar := SubStr(typed, direction2check, 1)
  If RegExMatch(testChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<4) && (CaretPosSelly<0)
     mustRepeat := 1

  If (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos2, typed, %lola2%
     If ((CaretPos2 > CaretPos && direction=2) || (CaretPos2 < CaretPos && direction=0))
     {
        CaretPos := CaretPos2
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     } Else (CaretPos := (direction=2) ? (CaretPos - 2) : (CaretPos + 1))
  }
  StringReplace, typed, typed, %lola%
  StringReplace, typed, typed, %lola2%
  CaretPos := CaretPos + direction
  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(typed)+1))
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)
  If (InStr(typed, "▫" lola))
  {
     StringGetPos, CaretPos, typed, %lola%
     StringReplace, typed, typed, %lola%
     CaretPos := CaretPos + direction
     typed := ST_Insert(lola, typed, CaretPos)
  }
  CalcVisibleText()
  If (mustRepeat=1)
  {
     inLoop := inLoop + 1
     If (CaretPos=1 && direction=0)
        Return
     caretMover(direction,inLoop)
  }
}

caretMoverSel(direction,inLoop:=0) {
  If (isLangRTL=1)
     Return

  cola := lola2
  cola2 := lola
  StringGetPos, CaretPos, typed, %cola2%
  If (st_count(typed, cola)>0)
  {
     StringGetPos, CaretPos, typed, %cola%
     direction2check := (direction=1) ? CaretPos+3 : CaretPos
     testChar := SubStr(typed, direction2check, 1)
     If RegExMatch(testChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<4)
        mustRepeat := 1
  } Else
  {
     StringGetPos, CaretPos, typed, %cola2%
     direction2check := (direction=1) ? CaretPos+3 : CaretPos
     testChar := SubStr(typed, direction2check, 1)
     If RegExMatch(testChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<4)
        mustRepeat := 1
     CaretPos := (direction=1) ? CaretPos + 1 : CaretPos
  }

  StringReplace, typed, typed, %cola%
  CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(typed)+1))
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(cola, typed, CaretPos)
  If (InStr(typed, "▫" cola))
  {
     StringGetPos, CaretPos, typed, %cola%
     StringReplace, typed, typed, %cola%
     CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
     typed := ST_Insert(cola, typed, CaretPos)
  }

  If (InStr(typed, cola cola2) || InStr(typed, cola2 cola))
     StringReplace, typed, typed, %cola%

  CalcVisibleText()
  If (mustRepeat=1)
  {
     inLoop := inLoop + 1
     caretMoverSel(direction,inLoop)
  }
}

caretJumpMain(direction) {
  If (CaretPos<=1)
     CaretPos := 1.5

  theRegEx := "i)((?=[[:space:]|│!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~])[\p{L}\p{Z}\p{N}\p{P}\p{S}]\b(?=\S)|\s(?!\s)(?=\p{L})|\p{So}(?=\S))"
  alternativeRegEx := "i)(((\p{Sc}|\p{So}|\p{L}|\p{N}|\w)(?=\S))([\p{Z}!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~\p{S}\p{C}])|\s\B[[:punct:]]|[[:punct:][:digit:][:alpha:]]\s\B)"
  If (direction=1)
  {
     CaretuPos := RegExMatch(typed, theRegEx, , CaretPos+1) + 1
     If (alternativeJumps=1)
     {
        CaretuPosa := RegExMatch(typed, alternativeRegEx, , CaretPos+1) + 1
        If (CaretuPosa>CaretPos)
           CaretuPos := CaretuPosa < CaretuPos ? CaretuPosa : CaretuPos
     }
     CaretPos := CaretuPos < CaretPos ? StrLen(typed)+1 : CaretuPos
  }

  If (direction=0)
  {
     typed := typed " z."
     If (CaretPos<=1)
        skipLoop := 1

     Loop
     {
       CaretuPos := CaretPos - A_Index
       CaretelPos := RegExMatch(typed, theRegEx, , CaretuPos)+1
       If (alternativeJumps=1)
       {
          CaretelPosa := RegExMatch(typed, alternativeRegEx, , CaretuPos)+1
          CaretelPos := CaretelPosa < CaretelPos ? CaretelPosa : CaretelPos
       }
       CaretelPos := CaretelPos < CaretuPos ? StrLen(typed)+1 : CaretelPos
       If (CaretelPos < CaretPos+1)
       {
          CaretPos := CaretelPos > CaretPos ? 1 : CaretelPos
          allGood := 1
       }
       If (CaretelPos < CaretuPos+1) || (A_Index>CaretPos+5)
          skipLoop := 1
     } Until (skipLoop=1 || allGood=1 || A_Index=300)

     StringTrimRight, typed, typed, 3
  }

  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(typed)+1))
     CaretPos := StrLen(typed)+1
}

caretJumper(direction) {
  If (isLangRTL=1)
     Return

  If (st_count(typed, lola2)>0)
     caretMover(direction*2)

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%
  caretJumpMain(direction)
  typed := ST_Insert(lola, typed, CaretPos)

  StringGetPos, CaretPoza, typed, %lola%
  direction2check := CaretPoza+2
  testChar := SubStr(typed, direction2check, 1)
  If RegExMatch(testChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]")
     caretMover(direction*2,1)
}

caretJumpSelector(direction) {
  If (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos, typed, %lola2%
     StringReplace, typed, typed, %lola2%
  } Else
  {
     StringGetPos, CaretPos, typed, %lola%
     CaretPos := (direction=1) ? CaretPos+1 : CaretPos
  }

  caretJumpMain(direction)
  typed := ST_Insert(lola2, typed, CaretPos)
  If (InStr(typed, lola lola2) || InStr(typed, lola2 lola))
     StringReplace, typed, typed, %lola2%

  StringGetPos, CaretPoza, typed, %lola2%
  direction2check := CaretPoza+2
  testChar := SubStr(typed, direction2check, 1)
  If RegExMatch(testChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]")
     caretMoverSel(direction,1)
}

toUnicodeExtended(uVirtKey,uScanCode,shiftPressed:=0,AltGrPressed:=0,wFlags:=0,onLatterUp:=0) {
; Many thanks to Helgef for helping me with this function:
; https://autohotkey.com/boards/viewtopic.php?f=5&t=41065&p=187582#p187582
  pressKeyRecorded := 1
  nsa := DllCall("user32\MapVirtualKeyW", "UInt", uVirtKey, "UInt", 2)
  If (nsa<=0 && DeadKeys=0 && SecondaryTypingMode=1)
      Return

  If (nsa<=0 && DeadKeys=0 && SecondaryTypingMode=0)
  {
     Global deadKeyPressed := A_TickCount
     If (deadKeyBeeper = 1 && ShowSingleKey = 1)
        beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]

     RmDkSymbol := "▪"
     StringReplace, visibleTextField, visibleTextField, %lola%, %RmDkSymbol%
     ShowHotkey(visibleTextField)
     If (AlternativeHook2keys=0)
        Sleep, % 250 * typingDelaysScale

     If (StrLen(typed)<2)
     {
        ShowHotkey("[dead key]")
        Sleep, 400
     }
     Return
  }

  thread := DllCall("user32\GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0)
  hkl := DllCall("user32\GetKeyboardLayout", "UInt", thread, "Ptr")
  cchBuff := 3            ; number of characters the buffer can hold
  VarSetCapacity(lpKeyState,256,0)
  VarSetCapacity(pwszBuff, (cchBuff+1) * (A_IsUnicode ? 2 : 1), 0)  ; this will hold cchBuff (3) characters and the null terminator on both unicode and ansi builds.

  If (onLatterUp=1)
  {
     for modifier, vk in {Shift:0x10, Control:0x11, Alt:0x12}
         NumPut(128*(GetKeyState("L" modifier) || GetKeyState("R" modifier)) , lpKeyState, vk, "Uchar")
  }

  If (shiftPressed=1)
     NumPut(128*shiftPressed, lpKeyState, 0x10, "UChar")

  If (AltGrPressed=1)
  {
     NumPut(128*AltGrPressed, lpKeyState, 0x12, "UChar")
     NumPut(128*AltGrPressed, lpKeyState, 0x11, "UChar")
  }

  NumPut(GetKeyState("CapsLock", "T") , &lpKeyState+0, 0x14, "UChar")
  n := DllCall("user32\ToUnicodeEx", "UInt", uVirtKey, "UInt", uScanCode, "UPtr", &lpKeyState, "Ptr", &pwszBuff, "Int", cchBuff, "UInt", wFlags, "Ptr", hkl)
  n := DllCall("user32\ToUnicodeEx", "UInt", uVirtKey, "UInt", uScanCode, "UPtr", &lpKeyState, "Ptr", &pwszBuff, "Int", cchBuff, "UInt", wFlags, "Ptr", hkl)
  Return StrGet(&pwszBuff, n, "utf-16")
}

OnMousePressed() {
    Thread, Priority, -20
    Critical, off
    If (OnlyTypingMode=1)
       Return

    If (outputOSDtoToolTip=0 && NeverDisplayOSD=1)
       Return
    SetTimer, ClicksTimer, 400, 50
    If (OSDvisible=1)
       tickcount_start := A_TickCount-500

    try {
        key := GetKeyStr()
        If (ShowMouseButton=1)
        {
            If (enableTypingHistory=1)
               editField4 := StrLen(typed)>5 ? typed : editField4
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
        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Left|Right))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            If (key ~= "i)^(Left)")
            {
               caretMover(0)
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, , {Left}, %Window2Activate%
            }

            If (key ~= "i)^(Right)")
            {
               caretMover(2)
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, , {Right}, %Window2Activate%
            }


            If (key ~= "i)^(.?Shift \+ Left)")
            {
               caretMoverSel(-1)
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,+{Left}, %Window2Activate%
            }

            If (key ~= "i)^(.?Shift \+ Right)")
            {
               caretMoverSel(1)
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,+{Right}, %Window2Activate%
            }

            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
            If (CaretPos!=StrLen(typed) && CaretPos!=1)
            {
               Global lastTypedSince := A_TickCount
               keycount := 1
            } Else If (keyCount>1)
            {
               If InStr(key, "left")
                  caretSymbolChangeIndicator("▌",300)
               If InStr(key, "right")
                  caretSymbolChangeIndicator("▐",300)
            }
        }
        If (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           If (keyCount>10 && OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay

           If (enableTypingHistory=1 && prefixed && OnlyTypingMode=0)
              editField4 := StrLen(typed)>5 ? typed : editField4

           If (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""

           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }

    If (EnforceSluggishSynch=1 && SecondaryTypingMode=0)
    {
       If (A_ThisHotkey="Left")
          SendInput, {Left}
       If (A_ThisHotkey="Right")
          SendInput, {Right}
       If (A_ThisHotkey="+Left")
          SendInput, +{Left}
       If (A_ThisHotkey="+Right")
          SendInput, +{Right}
    }
}

OnUpDownPressed() {
    try
    {
        key := GetKeyStr()
        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Up|Down))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            If (CaretPos!=StrLen(typed) && CaretPos!=1)
               keycount := (UpDownAsHE=0) && (UpDownAsLR=0) ? keycount : 1

            If (UpDownAsHE=0 && UpDownAsLR=0 && !InStr(key, "shift"))
            {
               StringReplace, typed, typed, %lola2%
               CalcVisibleText()
            }

            If (UpDownAsHE=1 && UpDownAsLR=0)
            {
                StringGetPos, CaretPos3, typed, %lola%
                StringGetPos, CaretPos4, typed, %lola2%
                If (key ~= "i)^(Up)") && (CaretPos3!=0) || (key ~= "i)^(Up)") && (CaretPos4!=-1)
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
                }

                If (key ~= "i)^(Down)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := StrLen(typed)+1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := StrLen(typed)+2
                }

                If (key ~= "i)^(.?Shift \+ Down)")
                   SelectHomeEnd(1)

                If (key ~= "i)^(.?Shift \+ Up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
            }

            If (UpDownAsLR=1 && UpDownAsHE=0)
            {
                If ((key ~= "i)^(Up)"))
                   caretMover(0)

                If ((key ~= "i)^(Down)"))
                   caretMover(2)

                If ((key ~= "i)^(.?Shift \+ Up)"))
                   caretMoverSel(-1)

                If ((key ~= "i)^(.?Shift \+ Down)"))
                   caretMoverSel(1)

            }
            Global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            If (CaretPos=StrLen(typed)) || (CaretPos=1) || (UpDownAsHE=0) && (UpDownAsLR=0)
            {
               If InStr(key, "up") && (keyCount>1)
                  caretSymbolChangeIndicator("▀",300)
               If InStr(key, "down") && (keyCount>1)
                  caretSymbolChangeIndicator("▄",300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           If (keyCount>10 && OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
}

OnHomeEndPressed() {
    taiped := typed
    taiped := RegExReplace(taiped, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}]")
    taiped := RegExReplace(taiped, Emojis, "1")
    StringGetPos, exKaretPos, taiped, %lola%
    StringGetPos, exKaretPosSelly, taiped, %lola2%
    try
    {
        key := GetKeyStr()
        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>0 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Home|End))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            If (key ~= "i)^(.?Shift \+ End)") || InStr(A_ThisHotkey, "~+End")
            {
               SelectHomeEnd(1)
               skipRest := 1
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,+{End}, %Window2Activate%
            }

            If (key ~= "i)^(.?Shift \+ Home)") || InStr(A_ThisHotkey, "~+Home")
            {
               SelectHomeEnd(0)
               If StrLen(typed)<3
                  selectAllText()
               skipRest := 1
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,+{Home}, %Window2Activate%
            }

            If ((key ~= "i)^(Home)") && skipRest!=1 && isLangRTL=0)
            {
               If (CaretPos3!=0 || CaretPos4!=-1)
               {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
               }
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,{Home}, %Window2Activate%
            }

            If ((key ~= "i)^(End)") && skipRest!=1 && isLangRTL=0)
            {
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               CaretPos := StrLen(typed)+1
               typed := ST_Insert(lola, typed, CaretPos)
               maxTextChars := StrLen(typed)+2
               If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                  ControlSend, ,{End}, %Window2Activate%
            }

            Global lastTypedSince := A_TickCount
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            If (CaretPos=StrLen(typed) || CaretPos=1)
            {
               If (InStr(key, "Home") && keyCount>1)
                  caretSymbolChangeIndicator("▌",300)
               If (InStr(key, "End") && keyCount>1)
                  caretSymbolChangeIndicator("▐",300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping

        }
        If (prefixed && !((key ~= "i)^(.?Shift \+)")) || StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && OnlyTypingMode=0 )
        {
           If (OnlyTypingMode!=1)
           {
              If (keyCount>10)
                 Global lastTypedSince := A_TickCount - ReturnToTypingDelay
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }

    If (MediateNavKeys=1 && SecondaryTypingMode=0)
    {
      taiped := typed
      taiped := RegExReplace(taiped, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}]")
      taiped := RegExReplace(taiped, Emojis, "1")
      StringGetPos, exKaretPos2, taiped, %lola%
      StringGetPos, exKaretPosSelly2, taiped, %lola2%
      times2pressKey := (exKaretPos2 > exKaretPos) ? (exKaretPos2 - exKaretPos) : (exKaretPos - exKaretPos2)
      managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      If (exKaretPosSelly<0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPos2) ? (exKaretPosSelly2 - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly2 - 1)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      If (exKaretPosSelly2<0 && exKaretPosSelly>=0)
      {
         If (A_ThisHotkey="End")
            times2pressKey := (exKaretPosSelly > exKaretPos) ? (exKaretPos2 - exKaretPosSelly + 2) : (exKaretPos2 - exKaretPos + 2)
         If (A_ThisHotkey="Home")
            times2pressKey := (exKaretPosSelly > exKaretPos) ? (exKaretPos - exKaretPos2 + 1) : (exKaretPosSelly - exKaretPos2 + 1)
         managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      }
      If (exKaretPosSelly>=0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPosSelly) ? (exKaretPosSelly2 - exKaretPosSelly) : (exKaretPosSelly - exKaretPosSelly2)
         If (key ~= "i)^(.?Shift \+ Home)") && (exKaretPosSelly>exKaretPos) || (key ~= "i)^(.?Shift \+ End)") && (exKaretPosSelly<exKaretPos)
            times2pressKey := times2pressKey - 1
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }

      If (managedMode=1)
      {
         If (A_ThisHotkey="Home")
            SendInput, {Left %times2pressKey% }

         If (A_ThisHotkey="End")
            SendInput, {Right %times2pressKey% }

         If (A_ThisHotkey="+Home") || (key ~= "i)^(.?Shift \+ Home)")
            SendInput, {Shift Down}{Left %times2pressKey% }{Shift up}

         If (A_ThisHotkey="+End") || (key ~= "i)^(.?Shift \+ End)")
            SendInput, {Shift Down}{Right %times2pressKey% }{Shift up}
      }
    }

    If (MediateNavKeys=1 && managedMode!=1) 
    {
       If (A_ThisHotkey="Home")
          SendInput, {Home}
       If (A_ThisHotkey="End")
          SendInput, {End}
       If (A_ThisHotkey="~+Home") || (key ~= "i)^(.?Shift \+ Home)")
          SendInput, +{Home}
       If (A_ThisHotkey="~+End") || (key ~= "i)^(.?Shift \+ End)")
          SendInput, +{End}
    }
}

SelectHomeEnd(direction) {
  StringGetPos, CaretPos3, typed, %lola%
  If ((CaretPos3 >= StrLen(typed)-1) && (direction=1)) || ((CaretPos3<=1) && (direction=0))
  {
     StringReplace, typed, typed, %lola2%
     Return
  }
  If (typed ~= "i)^(║)") && (direction=0) || (typed ~= "i)(║)$") && (direction=1) || (CaretPos<=1) && (direction!=1) || (CaretPos >= StrLen(typed)) && (direction=1)
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
        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?Page )") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            If (pgUDasHE=1) && (key ~= "i)^(.?Shift \+ )")
            {
                If (key ~= "i)^(.?Shift \+ Page down)")
                   SelectHomeEnd(1)

                If (key ~= "i)^(.?Shift \+ Page up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
                ShowHotkey(visibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }

            If (enableTypingHistory=1)
            {
                If ((key ~= "i)^(Page Down)") && OSDvisible=0 && StrLen(typed)<3)
                {
                   Global lastTypedSince := A_TickCount - ReturnToTypingDelay
                   If (StrLen(typed)<2)
                      typed := (OnlyTypingMode=1) ? typed : ""
                   ShowHotkey(key)
                   SetTimer, HideGUI, % -DisplayTime
                   Return
                }

                StringReplace, typed, typed, %lola%,, All
                StringReplace, typed, typed, %lola2%,, All

                If (key ~= "i)^(Page Up)")
                {
                   If (editingField=3)
                      backTypeCtrl := typed
                   editingField := (editingField<=1) ? 1 : editingField-1
                   typed := editField%editingField%
                }

                If (key ~= "i)^(Page Down)")
                {
                   If (editingField=3)
                      backTypeCtrl := typed
                   editingField := (editingField>=3) ? 3 : editingField+1
                   typed := (editingField=3) ? backTypeCtrl : editField%editingField%
                }
                StringReplace, typed, typed, %lola%,, All
                StringReplace, typed, typed, %lola2%,, All
                CaretPos := (typed=" ") ? StrLen(typed) : StrLen(typed)+1
                typed := ST_Insert(lola, typed, 0)
            }

            If (enableTypingHistory=0 && pgUDasHE=1)
            {
                StringGetPos, CaretPos3, typed, %lola%
                StringGetPos, CaretPos4, typed, %lola2%
                If (key ~= "i)^(Page up)") && (CaretPos3!=0) || (key ~= "i)^(Page up)") && (CaretPos4!=-1)
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := maxTextChars*2
                }

                If (key ~= "i)^(Page down)")
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

            If (CaretPos=StrLen(typed)) || (CaretPos=1)
            {
               If (InStr(key, "page up") && keyCount>1)
                  caretSymbolChangeIndicator("▀",300)
               If (InStr(key, "page down") && keyCount>1)
                  caretSymbolChangeIndicator("▄",300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (prefixed && !((key ~= "i)^(.?Shift \+)")) || !typed || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10) && (OnlyTypingMode=0)
        {
           If (keyCount>10 && OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""

        If (StrLen(typed)>1 && DisableTypingMode=0 && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && keyCount<10)
           SetTimer, returnToTyped, % -DisplayTime/4
    }
}

OnKeyPressed() {
;  Sleep, 30 ; megatest
    pressKeyRecorded := 1
    try {
        backTypeCtrl := typed || (A_TickCount-lastTypedSince > DisplayTimeTyping) ? typed : backTypeCtrl
        key := GetKeyStr()
        TypingFriendlyKeys := "i)^((.?shift \+ )?(Num|Caps|Scroll|Insert|Tab)|\{|AppsKey|Volume |Media_|Wheel |◐)"

        If (enterErasesLine=1 && SecondaryTypingMode=1 && (key ~= "i)(enter|esc)"))
        {
           DetectHiddenWindows, On
           hwnd2Activate := SwitchSecondaryTypingMode()
           Sleep, 20
           WinActivate, ahk_id %hwnd2Activate%
           Sleep, 40
           If (InStr(key, "enter") && sendKeysRealTime=0)
           {
              sendOSDcontent(1)
              skipRest := 1
           }
           DetectHiddenWindows, off
        }

        If ((key ~= "i)(enter|esc)") && DisableTypingMode=0 && ShowSingleKey=1)
        {
            If (enterErasesLine=0 && OnlyTypingMode=1)
               InsertChar2caret(" ")

            If (enterErasesLine=0 && OnlyTypingMode=1 && (key ~= "i)(esc)"))
               dontReturn := 1

            backTypdUndo := typed
            backTypeCtrl := ""
            externalKeyStrokeReceived := ""
            If (key ~= "i)(esc)")
               Global lastTypedSince := A_TickCount - ReturnToTypingDelay

            If (StrLen(typed)>3 && enableTypingHistory=1)
            {
               StringGetPos, CaretPos4, typed, %lola%
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               editField1 := editField2
               editField2 := typed
               editingField := 3
               If (OnlyTypingMode=1)
                  typed := ST_Insert(lola, typed, CaretPos4+1)
            }
            If (enterErasesLine=1)
               typed := (skipRest=1) ? typed : ""
        } Else If (DisableTypingMode=0 && enableTypingHistory=1)
               editField4 := StrLen(typed)>5 ? typed : editField4

        If (!(key ~= TypingFriendlyKeys) && DisableTypingMode=0)
        {
            typed := (OnlyTypingMode=1 || skipRest=1) ? typed : ""
        } Else If ((key ~= "i)^((.?Shift \+ )?Tab)") && typed && DisableTypingMode=0)
        {
            If ((typed ~= "i)(▫│)") && SecondaryTypingMode=0)
            {
                StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%A_Space%%lola%
                TrueRmDkSymbol := ""
                CalcVisibleText()
            } Else InsertChar2caret(TrueRmDkSymbol " ")
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        If (StrLen(typed)>1 && dontReturn!=1)
           SetTimer, returnToTyped, % -DisplayTime/4
    }
}

OnLetterPressed(onLatterUp:=0) {
;  Sleep, 60 ; megatest
    pressKeyRecorded := 1
    If (A_TickCount-lastTypedSince > 2000*StrLen(typed)) && StrLen(typed)<5 && (OnlyTypingMode=0)
       typed := ""

    If (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && StrLen(typed)>4
       InsertChar2caret(" ")

    try {
        If (DeadKeys=1 && (A_TickCount-deadKeyPressed < 1100))      ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these
        {
            Sleep, % 70 * typingDelaysScale
        } Else If (typed && DeadKeys=1)
        {
            Sleep, % 20 * typingDelaysScale
        }
        If (typed && DeadKeys=1 && DoNotBindDeadKeys=1)
            Sleep, % 20 * typingDelaysScale

        AltGrMatcher := "i)^((AltGr|.?Alt \+ .?Ctrl|.?Ctrl \+ .?Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))"
        ShiftMatcher := "i)^(.?Shift \+ ((.)$|(.)[\r\n \,]))"
        key := GetKeyStr()

        If (prefixed || DisableTypingMode=1)
        {
            typingValidation := (SecondaryTypingMode=0) && (DisableTypingMode=0) ? 1 : 0
            If ((key ~= AltGrMatcher) && (typingValidation=1) && (enableAltGr=1)) || ((key ~= ShiftMatcher) && (typingValidation=1))
            {
               (enableAltGr=1) && (key ~= AltGrMatcher) ? typed := TypedLetter(A_ThisHotkey)
               (key ~= ShiftMatcher) ? typed := TypedLetter(A_ThisHotkey)
               hasTypedNow := 1
               If (StrLen(typed)>1)
               {
                  ShowHotkey(visibleTextField)
                  SetTimer, HideGUI, % -DisplayTimeTyping
               } Else
               {
                  If (enableTypingHistory=1)
                     editField0 := StrLen(typed)>5 ? typed : editField0

                  typed := (hasTypedNow=1) ? typed : ""
                  ShowHotkey(key)
               }
            } Else
            {
               If (enableTypingHistory=1)
                  editField0 := StrLen(typed)>5 ? typed : editField0
               typed := (OnlyTypingMode=1) ? typed : ""
               ShowHotkey(key)
            }
            SetTimer, HideGUI, % -DisplayTime
        } Else If (SecondaryTypingMode=0)
        {
            TypedLetter(A_ThisHotkey, onLatterUp)
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }

    If (beepFiringKeys=1) && (A_TickCount-tickcount_start > 600) && (keyBeeper=1) || (beepFiringKeys=1) && (keyBeeper=0)
    {
       If (SecondaryTypingMode=0 && SilentMode=0) 
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
  If !InStr(A_PriorHotkey, "*vk41") && InStr(A_ThisHotkey, "^vk41")
     allGood := 1
  pressKeyRecorded := 1
  If (allGood=1 && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && StrLen(typed)>1)
  {
     If (sendKeysRealTime=1 && SecondaryTypingMode=1)
        ControlSend, , ^{a}, %Window2Activate%
     selectAllText()
     CalcVisibleText()
     Global lastTypedSince := A_TickCount
     ShowHotkey(visibleTextField)
     SetTimer, HideGUI, % -DisplayTimeTyping
  } Else If (OnlyTypingMode=0)
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
  pressKeyRecorded := 1
  taiped := typed
  taiped := RegExReplace(taiped, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}]")
  taiped := RegExReplace(taiped, Emojis, "1")
  StringGetPos, exKaretPos, taiped, %lola%
  StringGetPos, exKaretPosSelly, taiped, %lola2%
  If ((A_TickCount-lastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && keyCount<10 && StrLen(typed)>1)
  {
      If InStr(A_ThisHotkey, "+^Left")
      {
         caretJumpSelector(0)
         skipRest := 1
         If (sendKeysRealTime=1 && SecondaryTypingMode=1)
            ControlSend, , +{Left %times2pressKey% }, %Window2Activate%
      }

      If InStr(A_ThisHotkey, "+^Right")
      {
         caretJumpSelector(1)
         skipRest := 1
         If (sendKeysRealTime=1 && SecondaryTypingMode=1)
            ControlSend, , +{Right %times2pressKey% }, %Window2Activate%
      }

      If (skipRest!=1 && InStr(A_ThisHotkey, "^Left"))
      {
         If (exKaretPosSelly > exKaretPos) && (exKaretPosSelly>=0)
         {
            StringReplace, typed, typed, %lola%
            StringReplace, typed, typed, %lola2%
            CaretPos := exKaretPosSelly
            typed := ST_Insert(lola, typed, CaretPos)            
            droppedSelection := 1
         } Else caretJumper(0)

         If (sendKeysRealTime=1 && SecondaryTypingMode=1)
            ControlSend, , {Left %times2pressKey% }, %Window2Activate%
      }

      If (skipRest!=1 && InStr(A_ThisHotkey, "^Right"))
      {
         If (exKaretPosSelly < exKaretPos && exKaretPosSelly>=0)
         {
            StringReplace, typed, typed, %lola%
            StringReplace, typed, typed, %lola2%
            CaretPos := exKaretPosSelly + 1
            typed := ST_Insert(lola, typed, CaretPos)
            droppedSelection := 1
         } Else caretJumper(1)

         If (sendKeysRealTime=1 && SecondaryTypingMode=1)
            ControlSend, , {Right %times2pressKey% }, %Window2Activate%
      }
      CalcVisibleText()
      Global lastTypedSince := A_TickCount
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If StrLen(typed)<1 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0)
  {
      If (keyCount>=10 && OnlyTypingMode=0)
         Global lastTypedSince := A_TickCount - ReturnToTypingDelay
      If (StrLen(typed)<2)
         typed := (OnlyTypingMode=1) ? typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }
  taiped := typed
  taiped := RegExReplace(taiped, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}]")
  taiped := RegExReplace(taiped, Emojis, "1")
  StringGetPos, exKaretPos2, taiped, %lola%
  StringGetPos, exKaretPosSelly2, taiped, %lola2%
  keyCount := (exKaretPos!=exKaretPos2) && (exKaretPosSelly)<0 && (exKaretPosSelly2<0) || (exKaretPos=exKaretPos2) && (exKaretPosSelly!=exKaretPosSelly2) ? 1 : keyCount
  If (sendJumpKeys=1 && SecondaryTypingMode=0 && droppedSelection!=1)
  {
      times2pressKey := (exKaretPos2 > exKaretPos) ? (exKaretPos2 - exKaretPos) : (exKaretPos - exKaretPos2)
      managedMode := (exKaretPos=exKaretPos2) || (times2pressKey<1) ? 0 : 1
      If (exKaretPosSelly<0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPos2) ? (exKaretPosSelly2 - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly2 - 1)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      If (exKaretPosSelly2<0 && exKaretPosSelly>=0)
      {
         times2pressKey := (exKaretPosSelly > exKaretPos2) ? (exKaretPosSelly - exKaretPos2 - 1) : (exKaretPos2 - exKaretPosSelly)
         If (A_ThisHotkey="^Right") || (A_ThisHotkey="^Left")
            times2pressKey := times2pressKey + 2
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }
      If (exKaretPosSelly>=0 && exKaretPosSelly2>=0)
      {
         times2pressKey := (exKaretPosSelly2 > exKaretPosSelly) ? (exKaretPosSelly2 - exKaretPosSelly) : (exKaretPosSelly - exKaretPosSelly2)
         managedMode := (exKaretPosSelly=exKaretPosSelly2) || (times2pressKey<1) ? 0 : 1
      }

      If (managedMode=1)
      {
         If (A_ThisHotkey="^Left")
            SendInput, {Left %times2pressKey% }

         If (A_ThisHotkey="^Right")
            SendInput, {Right %times2pressKey% }

         If (A_ThisHotkey="+^Left")
            SendInput, {Shift Down}{Left %times2pressKey% }{Shift up}

         If (A_ThisHotkey="+^Right")
            SendInput, {Shift Down}{Right %times2pressKey% }{Shift up}
      }
  } Else If (droppedSelection=1)
  {
      If (A_ThisHotkey="^Left")
         SendInput, {Right}
      If (A_ThisHotkey="^Right")
         SendInput, {Left}
      managedMode := 1
  }

  If (sendJumpKeys=1 && managedMode!=1) ;  && (mustSendJumpKeys=1) || (sendJumpKeys=1) && (keyCount>10) && (OnlyTypingMode=1)
  {
     If (A_ThisHotkey="^Left")
        SendInput, ^{Left}
     If (A_ThisHotkey="^Right")
        SendInput, ^{Right}
     If (A_ThisHotkey="+^Left")
        SendInput, +^{Left}
     If (A_ThisHotkey="+^Right")
        SendInput, +^{Right}
  }
}

OnCtrlDelBack() {
  Try {
      key := GetKeyStr()
  }
  pressKeyRecorded := 1
  InitialTextLength := StrLen(typed)
  If ((A_TickCount-lastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && keyCount<10 && StrLen(typed)>=2)
  {
      backTypdUndo := typed
      StringGetPos, CaretzoiPos, typed, %lola%
      StringGetPos, exKaretPosSelly, typed, %lola2%
      If ((key ~= "i)^(.?Ctrl \+ Backspace)")) || InStr(A_ThisHotkey, "^Back")
      {
         If (exKaretPosSelly>=0)
         {
             replaceSelection()
             droppedSelection := 1
             If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                ControlSend, , {BackSpace}, %Window2Activate%
         } Else
         {
             typed := typed "zz z"
             caretJumper(0)
             StringGetPos, CaretzoaiaPos, typed, %lola%
             typed := st_delete(typed, CaretzoaiaPos+1, CaretzoiPos - CaretzoaiaPos+1)
             StringTrimRight, typed, typed, 4
             If (st_count(typed, lola)<1)
                typed := ST_Insert(lola, typed, CaretzoaiaPos+1)
             BkspPressed := 1
             If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                ControlSend, , {BackSpace %times2pressKey% }, %Window2Activate%
         }
      }

      If ((key ~= "i)^(.?Ctrl \+ Delete)")) || InStr(A_ThisHotkey, "^Del")
      {
         If (exKaretPosSelly>=0)
         {
             replaceSelection()
             droppedSelection := 1
             If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                ControlSend, , {Del}, %Window2Activate%
         } Else
         {
             caretJumper(1)
             StringGetPos, CaretzoaiaPos, typed, %lola%
             typed := st_delete(typed, CaretzoiPos+1, CaretzoaiaPos - CaretzoiPos)
             If (st_count(typed, lola)<1)
                typed := ST_Insert(lola, typed, CaretzoaiaPos)
             DelPressed := 1
             If (sendKeysRealTime=1 && SecondaryTypingMode=1)
                ControlSend, , {Del %times2pressKey% }, %Window2Activate%
         }
      }
      Global lastTypedSince := A_TickCount
      CalcVisibleText()
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(typed)<2) || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0)
  {
      If (keyCount>10 && OnlyTypingMode=0)
         Global lastTypedSince := A_TickCount - ReturnToTypingDelay
      If (StrLen(typed)<2)
         typed := (OnlyTypingMode=1) ? typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }
  TextLengthAfter := StrLen(typed)
  times2pressKey := InitialTextLength - TextLengthAfter
  If (times2pressKey>1)
     keyCount := 1
  If (sendJumpKeys=1 && SecondaryTypingMode=0)
  {
         StringGetPos, exKaretPos2, typed, %lola%
         If (exKaretPos2<0)
           times2pressKey := times2pressKey - 1

         If (times2pressKey>0 && BkspPressed=1 && droppedSelection!=1)
            SendInput, {BackSpace %times2pressKey% }

         If (times2pressKey>0 && DelPressed=1 && droppedSelection!=1)
            SendInput, {Del %times2pressKey% }

         If (droppedSelection=1)
            SendInput, {Del}
  }

  If (sendJumpKeys=1 && times2pressKey<=0 && droppedSelection!=1)
  {
      If (A_ThisHotkey="^BackSpace")
         SendInput, ^{BackSpace}
      If (A_ThisHotkey="^Del")
         SendInput, ^{Del}
  }
}

OnCtrlVup() {
  If (NeverDisplayOSD=1 && outputOSDtoToolTip=0)
     Return

  pressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk56") && InStr(A_thisHotkey, "^vk56")
     allGood := 1
  Sleep, 25
  toPaste := Clipboard
  If ((toPaste ~= "i)^(.?\:\\.?.?)") && StrLen(toPaste)>4 && StrLen(typed)<3)
     allGood := 0

  If (allGood=1 && DisableTypingMode=0 && ShowSingleKey=1 && StrLen(toPaste)>0)
  {
    textClipboard2OSD(toPaste)
    Sleep, 15
    If (sendKeysRealTime=1 && SecondaryTypingMode=1)
       ControlSend, ,^{v}, %Window2Activate%
  }

  If (allGood!=1 || ShowSingleKey=0 || StrLen(toPaste)<1)
  {
      If (OnlyTypingMode=1)
         Return
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlCup() {
  If !InStr(A_PriorHotkey, "*vk43") && InStr(A_thisHotkey, "^vk43")
     allGood := 1
  pressKeyRecorded := 1
  If (allGood=1 && StrLen(typed)>1 && SecondaryTypingMode=1 && (A_TickCount-lastTypedSince < ReturnToTypingDelay))
  {
     If (ShowSingleKey=1 && DisableTypingMode=0 && st_count(typed, lola2)>0)
     {
        replaceSelection(1, 0)
        CalcVisibleText()
     }
     If (sendKeysRealTime=1)
        ControlSend, , ^{c}, %Window2Activate%
     ShowHotkey(visibleTextField)
     Global lastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(typed)<2) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlXup() {
  pressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk58") && InStr(A_thisHotkey, "^vk58")
     allGood := 1

  If (StrLen(typed)>1 && allGood=1 && (A_TickCount-lastTypedSince < ReturnToTypingDelay))
  {
     If (ShowSingleKey=1 && DisableTypingMode=0 && st_count(typed, lola2)>0)
     {
        replaceSelection(1,1)
        CalcVisibleText()
     }
     If (sendKeysRealTime=1 && SecondaryTypingMode=1)
        ControlSend, , ^{x}, %Window2Activate%
     ShowHotkey(visibleTextField)
     Global lastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(typed)<2) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlZup() {
  If (NeverDisplayOSD=1 && outputOSDtoToolTip=0)
     Return
  pressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk5a") && InStr(A_thisHotkey, "^vk5a")
     allGood := 1

  If (allGood=1 && StrLen(typed)>0 && ShowSingleKey=1 && DisableTypingMode=0 && (A_TickCount-lastTypedSince < ReturnToTypingDelay))
  {
      blahBlah := typed
      typed := (StrLen(backTypdUndo)>1) ? backTypdUndo : typed
      backTypdUndo := (StrLen(blahBlah)>1) ? blahBlah : backTypdUndo
      Global lastTypedSince := A_TickCount
      If (sendKeysRealTime=1 && SecondaryTypingMode=1)
         ControlSend, , ^{z}, %Window2Activate%
      CalcVisibleText()
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  } Else If (StrLen(typed)<1) && (OnlyTypingMode=0) || (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (OnlyTypingMode=0) || (DisableTypingMode=1)
  {
      Try {
            key := GetKeyStr()
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnSpacePressed() {
    If (sendKeysRealTime=1 && SecondaryTypingMode=1)
       ControlSend, , {Space}, %Window2Activate%

    try {
          If (DoNotBindDeadKeys=1 && AlternativeHook2keys=1 && SecondaryTypingMode=0 && DisableTypingMode=0 && DeadKeys=1)
             Sleep, 35

          key := GetKeyStr()
          If ((A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>0 && DisableTypingMode=0 && ShowSingleKey=1)
          {
             If (typed ~= "i)(▫│)") && (SecondaryTypingMode=0)
             {
                  StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%lola%
             } Else If (SecondaryTypingMode=0)
             {
                 If TrueRmDkSymbol
                 {
                     InsertChar2caret(TrueRmDkSymbol)
                 } Else If externalKeyStrokeReceived && (DoNotBindDeadKeys=1) && (AlternativeHook2keys=1) && (SecondaryTypingMode=0) && (DisableTypingMode=0) && (DeadKeys=1)
                 {
                     InsertChar2caret(externalKeyStrokeReceived)
                 } Else InsertChar2caret(" ")
             }

             If (SecondaryTypingMode=1)
             {
                If !OnMSGdeadChar
                   char2insert := OnMSGchar ? OnMSGchar : " "
                If (sendKeysRealTime=1)
                   char2insert := OnMSGdeadChar && !OnMSGchar ? OnMSGdeadChar : " "
                InsertChar2caret(char2insert)
             }
             deadKeyProcessing()
             If (expandWords=1)
                ExpandFeatureFunction()
             Global lastTypedSince := A_TickCount
             CalcVisibleText()
             ShowHotkey(visibleTextField)
             SetTimer, HideGUI, % -DisplayTimeTyping
          }

          If (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
          {
             If (StrLen(typed)<2)
                typed := (OnlyTypingMode=1) ? typed : ""
             If (OnlyTypingMode!=1)
             {
                ShowHotkey(key)
                SetTimer, HideGUI, % -DisplayTime
             }
          }

          If (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
             typed := (OnlyTypingMode=1) ? typed : ""
    }

    If (TrueRmDkSymbol && StrLen(typed)<2 && SecondaryTypingMode=0 && DisableTypingMode=0 && DoNotBindDeadKeys=0)
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
    If (sendKeysRealTime=1 && SecondaryTypingMode=1)
       ControlSend, , {BackSpace}, %Window2Activate%

    try
    {
        key := GetKeyStr()
        If (TrueRmDkSymbol && AlternativeHook2keys=1 && SecondaryTypingMode=0 && DisableTypingMode=0) || (OnMSGdeadChar && SecondaryTypingMode=1 && DisableTypingMode=0) || (TrueRmDkSymbol && AlternativeHook2keys=0 && SecondaryTypingMode=0 && DisableTypingMode=0 && ShowDeadKeys=0)
        {
           TrueRmDkSymbol := ¨¨
           OnMSGdeadChar := ""
           Return
        } Else If ((typed ~= "i)(▫│)") && TrueRmDkSymbol && AlternativeHook2keys=0 && SecondaryTypingMode=0 && DisableTypingMode=0)
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

        If (expandWords=1 && StrLen(lastMatchedExpandPair)>1 && (A_TickCount-lastTypedSince < 3500))
        {
           searchThis := SubStr(lastMatchedExpandPair, InStr(lastMatchedExpandPair, "// ")+3)
           StringReplace, replaceWith, lastMatchedExpandPair, %searchThis%
           StringReplace, replaceWith, replaceWith, %A_Space%//%A_Space%
           StringReplace, typed, typed, %searchThis%%lola%, % replaceWith A_Space lola, UseErrorLevel
           If (ErrorLevel>0)
           {
             StringGetPos, CaretPos, typed, %lola%
             times2pressKey := StrLen(searchThis)-1
             SendInput, {BackSpace %times2pressKey% }
             If (SecondaryTypingMode!=1)
             {
                Sleep, 25
                SendInput, {text}%replaceWith%
             }
           }
           lastMatchedExpandPair := "!"
        }

        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10)
        {

            If (st_count(typed, lola2)>0)
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
            If (CaretPos = 2000)
            {
               caretSymbolChangeIndicator("▓",300)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }
            keycount := 1
            Global lastTypedSince := A_TickCount
            StringGetPos, CaretPos, typed, %lola%
            testChar := SubStr(typed, CaretPos, 1)
            If RegExMatch(testChar, "[\p{Cs}]")
            {
                typed := st_delete(typed, CaretPos-1, 2)
                CalcVisibleText()
                ShowHotkey(visibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }
            typedLength := StrLen(typed)
            CaretPosy := (CaretPos = typedLength) ? 0 : CaretPos
            typed := (caretpos<1) ? typed : st_delete(typed, CaretPosy, 1)
            If InStr(typed, "▫" lola)
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

        If (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && (OnlyTypingMode=0))
        {
           If (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }
        If (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    OnMSGchar := ""
}
CreateWordPairsFile(wordPairsFile) {
      ExpandPairs =
      (LTrim
          afaik // as far as I know
          aka // also known as
          asap // as soon as possible
          awol // absent without official leave
          bbl // be back later
          brb // be right back
          btw // by the way
          diy // do it yourself
          dnd // do not disturb
          eta // estimated time of arrival
          faq // frequently asked questions
          fyi // for your information
          gmo // genetically modified organism
          imho // in my humble opinion
          nsfw // not safe for work
          ocd // obsessive compulsive disorder
          omg // oh my God
          pls // please
          tba // to be announced
          tbd // to be decided
          thx // thanks
          tldr // too long, did not read
          ttyl // talk to you later
          wtf // what the f*ck
          yolo // you only live once
      )
      FileAppend, %ExpandPairs%, %wordPairsFile%, UTF-16
      Return ExpandPairs
}

RestoreExpandableWordsFile() {
  wordPairsFile := "keypress-osd-pairs.ini"
  FileDelete, %wordPairsFile%
  Sleep, 25
  ExpandPairs := CreateWordPairsFile(wordPairsFile)
  GuiControl, Disable, SaveWordPairsBTN
  GuiControl, Disable, DefaultWordPairsBTN
  GuiControl, , ExpandWordsListEdit, %ExpandPairs%
  VerifyTypeOptions()
}

SaveWordPairsNow() {
  wordPairsFile := "keypress-osd-pairs.ini"
  FileDelete, %wordPairsFile%
  Sleep, 25
  ExpandWordsListEdit := ""
  GuiControlGet, ExpandWordsListEdit
  FileAppend, %ExpandWordsListEdit%, %wordPairsFile%, UTF-16
  GuiControl, Disable, SaveWordPairsBTN
  VerifyTypeOptions()
}

InitExpandableWords() {
  wordPairsFile := "keypress-osd-pairs.ini"
  If FileExist(wordPairsFile)
      FileRead, ExpandPairs, %wordPairsFile%
  Else
      ExpandPairs := CreateWordPairsFile(wordPairsFile)

  If StrLen(ExpandPairs)<10
      ExpandPairs := CreateWordPairsFile(wordPairsFile)

  For each, line in StrSplit(ExpandPairs, "`n", "`r")
  {
    If !line
       Continue
    lineArr := StrSplit(line, " // ")
    key := lineArr[1]
    value := lineArr[2]
    If (StrLen(key)<2 || StrLen(value)<2)
       Continue
    ExpandWordsList[key] := value
    ExpandWordsListEdit .= key " // " value "`n"
  }
}

ExpandFeatureFunction() {
  If (lastMatchedExpandPair="!")
  {
     lastMatchedExpandPair := ""
     Return
  }
  lastMatchedExpandPair := ""
  typedTrim := SubStr(typed, CaretPos)
  StringReplace, typedTrim2, typed, %typedTrim%
  If InStr(typedTrim2, A_Space)
  {
     typedTrim3 := SubStr(typedTrim2, InStr(typedTrim2, A_Space,, -1))
     StringReplace, typedTrim3, typedTrim3, %A_Space%
  } Else (typedTrim3 := typedTrim2)

  If ExpandWordsList[typedTrim3] && (A_TickCount-lastTypedSince < 3500)
  {
     StringReplace, typed, typed, %typedTrim3%%A_Space%%lola%, % ExpandWordsList[typedTrim3] lola
     StringGetPos, CaretPos, typed, %lola%
     times2pressKey := StrLen(typedTrim3) + 1
     SendInput, {BackSpace %times2pressKey% }
     If (SecondaryTypingMode!=1)
     {
        Sleep, 25
        Text2Send := ExpandWordsList[typedTrim3]
        SendInput, {text}%Text2Send%
     }
     lastMatchedExpandPair := typedTrim3 " // " ExpandWordsList[typedTrim3]
  }
}

OnDelPressed() {
    If (sendKeysRealTime=1) && (SecondaryTypingMode=1)
       ControlSend, , {Del}, %Window2Activate%

    If (EnforceSluggishSynch=1) && (SecondaryTypingMode=0) && (A_ThisHotkey="Del")
       SendInput, {Del}

    try
    {
        key := GetKeyStr()
        If (A_TickCount-lastTypedSince < ReturnToTypingDelay) && StrLen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (keyCount<10)
        {
            If (st_count(typed, lola2)>0)
            {
               replaceSelection()
               If (isLangRTL=1)
                  typed := ""
               CalcVisibleText()
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }
            If (isLangRTL=1)
               Return

            deadKeyProcessing()
            InitialTextLength := StrLen(typed)
            Global lastTypedSince := A_TickCount
            caretMoverSel(1)
            replaceSelection()
            TextLengthAfter := StrLen(typed)
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            If (TextLengthAfter!=InitialTextLength)
               keycount := 1
            Else
               caretSymbolChangeIndicator("▓",300)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (prefixed || StrLen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10) && (OnlyTypingMode=0)
        {
           If (keyCount>10) && (OnlyTypingMode=0)
              Global lastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) ||  (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
}

OnNumpadsPressed() {
    If (A_TickCount-lastTypedSince > 1000*StrLen(typed)) && StrLen(typed)<5 && (OnlyTypingMode=0)
       typed := ""

    If (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && StrLen(typed)>4
       InsertChar2caret(" ")

    try {
        key := GetKeyStr()
        If ((prefixed && !(key ~= "i)^(.?Shift \+ )")) || DisableTypingMode=1)
        {
            If (enableTypingHistory=1)
               editField4 := StrLen(typed)>5 ? typed : editField4
            typed := (OnlyTypingMode=1) ? typed : ""
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        } Else If (ShowSingleKey=1) && (SecondaryTypingMode!=1)
        {
            key := SubStr(key, InStr(key, "[ ")+2, 1)
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
}

OnLetterUp() {
    a1 := A_ThisHotkey
    StringReplace, a2, A_ThisHotkey, %A_Space%up
    StringRight, a2, a2, 4
    b1 := A_PriorHotKey

    If (pressKeyRecorded=0) && (DisableTypingMode=0) && (SecondaryTypingMode=0) && InStr(b1, "vk") && (A_TickCount-deadKeyPressed>400) && (A_TickCount-lastTypedSince>15)
    {
       If !InStr(typedKeysHistory, a2)
       {
          typedKeysHistory := 0
          OnLetterPressed(1)
       }
    }

    OnKeyUp()
    pressKeyRecorded := 0
    If (KeyBeeper=1) && (SecondaryTypingMode=0) || (CapslockBeeper=1) && (SecondaryTypingMode=0)
       beeperzDefunctions.ahkPostFunction["OnLetterPressed", ""]
}

LEDsIndicatorsManager(checkNow:=0) {
    If (OSDshowLEDs=0)
       Return
    GetKeyState, CapsState, CapsLock, T
    GetKeyState, NumState, NumLock, T
    GetKeyState, ScrolState, ScrollLock, T
    GuiControl, OSD:, CapsLED, % (CapsState = "D") ? 100 : 0
    GuiControl, OSD:, NumLED, % (NumState = "D") ? 100 : 0
    GuiControl, OSD:, ScrolLED, % (ScrolState = "D") ? 100 : 0
    If (checkNow=0)
       SetTimer,, off
}

ModsLEDsIndicatorsManager(checkNow:=0) {
    For i, mod in MainModsList
    {
        If GetKeyState(mod)
           profix .= mod "+"
    }
    GuiControl, OSD:, ModsLED, % profix ? 100 : 0
    If profix
       SetTimer, modsTimer, 100, 50
    If (checkNow=0)
       SetTimer,, off
}

caretSymbolChangeIndicator(NewSymbol,timerz:=1300) {
   StringReplace, visibleTextField, visibleTextField, %lola%, %NewSymbol%
   ShowHotkey(visibleTextField)
   StringReplace, visibleTextField, visibleTextField, %NewSymbol%, %lola%
   SetTimer, CalcVisibleTextFieldDummy, %timerz%, 50
}

OnMudPressed() {
    If (NeverDisplayOSD=1) && (outputOSDtoToolTip=0)
       Return
    Static repeatCount := 1
    Static modPressedTimer
    backTypeCtrl := typed
    For i, mod in MainModsList
    {
        If GetKeyState(mod)
           fl_prefix .= mod "+"
    }
    StringReplace, keya, A_ThisHotkey, ~*,
    fl_prefix .= keya "+"
    fl_prefix := CompactModifiers(fl_prefix)
    Sort, fl_prefix, U D+
    fl_prefix := RTrim(fl_prefix, "+")
    StringReplace, fl_prefix, fl_prefix, +, %A_Space%+%A_Space%, All

    If (A_TickCount-tickcount_start2 < 35)
       Return

    If InStr(fl_prefix, "Shift") && (ShiftDisableCaps=1)
    {
       SetCapsLockState, off
       If (OSDshowLEDs=1)
          GuiControl, OSD:, CapsLED, 0
    }

    If (ModBeeper=1) && (SilentMode=0) && (A_TickCount-modPressedTimer > 200) && (A_TickCount-tickcount_start > 500)
       beeperzDefunctions.ahkPostFunction["modsBeeper", ""]

    If (StrLen(typed)>1) && (OSDvisible=1) && (A_TickCount-lastTypedSince < 4000) && (A_TickCount-modPressedTimer > 70)
       caretSymbolChangeIndicator("▒")

    If (A_TickCount-modPressedTimer > 150) && (OSDshowLEDs=1)
       GuiControl, OSD:, ModsLED, 100
    modPressedTimer := A_TickCount
    SetTimer, ModsLEDsIndicatorsManager, 370, 20
    SetTimer, modsTimer, 100, 50
    If (ShowSingleModifierKey=0)
       Return

    If InStr(fl_prefix, modifiers_temp) && !typed && (ShowKeyCount=1)
    {
        valid_count := 1
        If (repeatCount>1)
           keyCount := 0.1
    } Else
    {
        valid_count := 0
        modifiers_temp := fl_prefix
        If !prefixed
           keyCount := 0.1
    }

    If (valid_count=1) && (ShowKeyCountFired=0) && (ShowKeyCount=1) && !InStr(fl_prefix, "AltGr")
    {
       trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
       repeatCount := (trackingPresses=0 && repeatCount<2) ? repeatCount+1 : repeatCount
       If (trackingPresses=1)
          repeatCount := !repeatCount ? 1 : repeatCount+1
       ShowKeyCountValid := 1
    } Else If (valid_count=1) && (ShowKeyCountFired=1) && (ShowKeyCount=1)
    {
       repeatCount := !repeatCount ? 0 : repeatCount+1
       If InStr(fl_prefix, "AltGr") && repeatCount>3
          repeatCount := repeatCount-1+0.49
       ShowKeyCountValid := 1
    } Else
    {
       repeatCount := 1
       ShowKeyCountValid := 0
    }

    If (ShowKeyCountValid=1)
    {
        If !InStr(fl_prefix, "+") {
            modifiers_temp := fl_prefix
            fl_prefix .= " (" Round(repeatCount) ")"
        } Else (repeatCount := 1)
   }

   If ((StrLen(typed)>1) && (OSDvisible=1) && (A_TickCount-lastTypedSince < 4000)) || (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && (OSDvisible=1) && !typed && keycount>7) || (OnlyTypingMode=1)
   {
      Sleep, 1
   } Else
   {
      If (ShowSingleModifierKey=1)
      {
         ShowHotkey(fl_prefix)
         SetTimer, HideGUI, % -DisplayTime
      }
      SetTimer, returnToTyped, % -DisplayTime/4
   }
}

OnMudUp() {
    Global tickcount_start := A_TickCount
    If (OSDshowLEDs=1)
       SetTimer, ModsLEDsIndicatorsManager, 370, 20
    If (StrLen(typed)>1)
       SetTimer, returnToTyped, % -DisplayTime/4
}

OnDeadKeyPressed() {

  If (SecondaryTypingMode=1)
     Return

  If (AlternativeHook2keys=0)
     Sleep, % 85 * typingDelaysScale

  RmDkSymbol := "▫"
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  If (AlternativeHook2keys=1) && (A_TickCount-deadKeyPressed<800) && (A_TickCount-lastTypedSince>600) && TrueRmDkSymbol && (DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     externalKeyStrokeReceived := ""
     TrueRmDkSymbol := ""
  }
  Global deadKeyPressed := A_TickCount

  If ((ShowDeadKeys=1) && typed && (DisableTypingMode=0) && (ShowSingleKey=1) && AlternativeHook2keys=0)
  {
       If (typed ~= "i)(▫│)")
       {
           StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%TrueRmDkSymbol%%lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } Else InsertChar2caret(RmDkSymbol)
  }
  
  If ((StrLen(typed)>1) && (DisableTypingMode=0) && TrueRmDkSymbol )
  {
     StringReplace, visibleTextField, visibleTextField, %lola%, %TrueRmDkSymbol%
     ShowHotkey(visibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, 950, 50
  }

  keyCount := 0.1
  If (StrLen(typed)<2)
  {
     If (ShowDeadKeys=1) && (DisableTypingMode=0) && (AlternativeHook2keys=0)
        InsertChar2caret(RmDkSymbol)

     If (A_ThisHotkey ~= "i)^(~\+)")
     {
        DeadKeyMod := "Shift + " TrueRmDkSymbol2
        ShowHotkey(DeadKeyMod " [dead key]")
     } Else If (ShowSingleKey=1)
     {
        ShowHotkey(TrueRmDkSymbol2 " [dead key]")
     }
     SetTimer, HideGUI, % -DisplayTime
  }
  If (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
}

deadKeyProcessing() {

  If (ShowDeadKeys=0) || (DisableTypingMode=1) || (ShowSingleKey=0) || (DeadKeys=0) || (SecondaryTypingMode=1) || (AlternativeHook2keys=1)
     Return

  Loop, 5
  {
    deadkeyPosition := RegExMatch(typed, "▫[^[:alpha:]]")
    nextChar := SubStr(typed, deadkeyPosition+1, 1)

    If (nextChar!="▫") && (deadkeyPosition>=1)
       typed := st_overwrite("▪", typed, deadkeyPosition)
  }
}

OnAltGrDeadKeyPressed() {
  If (SecondaryTypingMode=1)
     Return

  If (AlternativeHook2keys=0)
     Sleep, % 85 * typingDelaysScale
  RmDkSymbol := "▫"
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  If (AlternativeHook2keys=1 && (A_TickCount-deadKeyPressed<800) && (A_TickCount-lastTypedSince>600) && TrueRmDkSymbol && DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     externalKeyStrokeReceived := ""
     TrueRmDkSymbol := ""
  }

  Global deadKeyPressed := A_TickCount
  If (AlternativeHook2keys=0)
     Global lastTypedSince := A_TickCount

  If (ShowDeadKeys=1 && typed && DisableTypingMode=0 && ShowSingleKey=1 && AlternativeHook2keys=0)
  {
       If (typed ~= "i)(▫│)")
       {
           StringReplace, typed, typed,▫%lola%, %TrueRmDkSymbol%%TrueRmDkSymbol%%lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } Else InsertChar2caret(RmDkSymbol)
       SetTimer, returnToTyped, 850, -10
  }

  keyCount := 0.1
  If (StrLen(typed)>1 && DisableTypingMode=0 && TrueRmDkSymbol2)
  {
     StringReplace, visibleTextField, visibleTextField, %lola%, %TrueRmDkSymbol%
     ShowHotkey(visibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, 950, 50
  }

  If (StrLen(typed)<2)
  {
     If (ShowDeadKeys=1 && DisableTypingMode=0 && AlternativeHook2keys=0)
        InsertChar2caret(RmDkSymbol)

     If (A_ThisHotkey ~= "i)^(~\^!)")
        DeadKeyMods := "Ctrl + Alt + " TrueRmDkSymbol2

     If (A_ThisHotkey ~= "i)^(~\+\^!)")
        DeadKeyMods := "Ctrl + Alt + Shift + " TrueRmDkSymbol2

     If (A_ThisHotkey ~= "i)^(~<\^>!)")
        DeadKeyMods := "AltGr + " TrueRmDkSymbol2

     ShowHotkey(DeadKeyMods " [dead key]")
     SetTimer, HideGUI, % -DisplayTime
  }
  If (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
}

returnToTyped() {
    If (StrLen(typed)>2 && keycount<10 && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && ShowSingleKey=1 && DisableTypingMode=0 && !A_IsSuspended)
    {
        ShowHotkey(visibleTextField)
        SetTimer, HideGUI, % -DisplayTimeTyping
    }
    SetTimer, , off
}

CreateOSDGUI() {
    Global
    smallLEDheight := 10
    Gui, OSD: Destroy
    Sleep, 25
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow +HwndhOSD
    Gui, OSD: Margin, 20, %smallLEDheight%
    Gui, OSD: Color, %OSDbgrColor%
    If (showPreview=0)
       Gui, OSD: Font, c%OSDtextColor% s%FontSize% Bold, %FontName%, -wrap
    Else
       Gui, OSD: Font, c%OSDtextColor%, -wrap

    textAlign := "left"
    widtha := A_ScreenWidth - 50
    positionText := smallLEDheight + 2

    If (OSDalignment>1)
    {
       textAlign := (OSDalignment=2) ? "Center" : "Right"
       positionText := (OSDalignment=2) ? 0 : 0 - smallLEDheight -2
    }

    Gui, OSD: Add, Edit, -E0x200 x%positionText% -multi %textAlign% readonly -WantCtrlA -WantReturn -wrap w%widtha% vHotkeyText hwndhOSDctrl, %HotkeyText%
    If (OSDborder=1)
    {
        WinSet, Style, +0xC40000
        WinSet, Style, -0xC00000
        WinSet, Style, +0x800000   ; small border
    }
    If (OSDshowLEDs=1)
    {
        capsLEDheight := GuiHeight + FontSize
        capsLEDwidth := FontSize/2 < 11 ? 11 : FontSize/2
        smallLEDwidth := capsLEDwidth + smallLEDheight
        ScrolColorLED := "EE2200"
        Gui, OSD: Add, Progress, x0 y0 w%capsLEDwidth% h%capsLEDheight% Background%OSDbgrColor% c%CapsColorHighlight% vCapsLED hwndhOSDind1, 1
        Gui, OSD: Add, Progress, x+0 w%smallLEDwidth% h%smallLEDheight% Background%OSDbgrColor% c%TypingColorHighlight% vNumLED hwndhOSDind2, 1
        Gui, OSD: Add, Progress, x+0 w%smallLEDwidth% h%smallLEDheight% Background%OSDbgrColor% c%OSDtextColor% vModsLED hwndhOSDind3, 100
        Gui, OSD: Add, Progress, x+0 w%smallLEDwidth% h%smallLEDheight% Background%OSDbgrColor% c%ScrolColorLED% vScrolLED hwndhOSDind4, 1
    }
    Gui, OSD: Show, NoActivate Hide x%GuiX% y%GuiY%, KeyPressOSDwin  ; required for initialization when Drag2Move is active
    OSDhandles := hOSD "," hOSDctrl "," hOSDind1 "," hOSDind2 "," hOSDind3 "," hOSDind4
    If (OSDalignment>1)
       CreateOSDGUIghost()
    LEDsIndicatorsManager(1)
    SetTimer, modsTimer, 600, 90
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

    If (AutoDetectKBD=1)
       IdentifyKBDlayout()
    Sleep, 20
    Static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "^!", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    Static mods_list := ["!", "!#", "!#^", "!#^+", "!+", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list

; bind keys relevant to the typing mode
    If (DisableTypingMode=0)
    {
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

        If (MediateNavKeys=1 && DisableTypingMode=0)
        {
            Hotkey, Home, OnHomeEndPressed, useErrorLevel
            Hotkey, +Home, OnHomeEndPressed, useErrorLevel
            Hotkey, End, OnHomeEndPressed, useErrorLevel
            Hotkey, +End, OnHomeEndPressed, useErrorLevel
        }

        If (sendJumpKeys=0 && isLangRTL=0)
        {
           Hotkey, ~^BackSpace, OnCtrlDelBack, useErrorLevel
           Hotkey, ~^Del, OnCtrlDelBack, useErrorLevel
           Hotkey, ~^Left, OnCtrlRLeft, useErrorLevel
           Hotkey, ~^Right, OnCtrlRLeft, useErrorLevel
           Hotkey, ~+^Left, OnCtrlRLeft, useErrorLevel
           Hotkey, ~+^Right, OnCtrlRLeft, useErrorLevel
        } Else
        {
           Hotkey, ^BackSpace, OnCtrlDelBack, useErrorLevel
           Hotkey, ^Del, OnCtrlDelBack, useErrorLevel
           Hotkey, ^Left, OnCtrlRLeft, useErrorLevel
           Hotkey, ^Right, OnCtrlRLeft, useErrorLevel
           Hotkey, +^Left, OnCtrlRLeft, useErrorLevel
           Hotkey, +^Right, OnCtrlRLeft, useErrorLevel
        }

        If (EnforceSluggishSynch=1)
        {
           Hotkey, Del, OnDelPressed, useErrorLevel
           Hotkey, Left, OnRLeftPressed, useErrorLevel
           Hotkey, Right, OnRLeftPressed, useErrorLevel
           Hotkey, +Left, OnRLeftPressed, useErrorLevel
           Hotkey, +Right, OnRLeftPressed, useErrorLevel
        }
    }

; bind to the list of possible letters/chars
    Loop, 256
    {
        k := A_Index
        code := Format("{:x}", k)
        n := GetKeyName("vk" code)

        If (n = "")
           n := GetKeyChar("vk" code)

        If (n = " ") || (n = "") || (StrLen(n)>1)
           continue

        If (DeadKeys=1)
        {
          For each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
          {
            If (InStr(char2skip, "vk" code) || n=char2skip)
              continue, 2
          }
        }
 
        If (IgnoreAdditionalKeys=1)
        {
          For each, char2skip in StrSplit(IgnorekeysList, ".")        ; dead keys to ignore
          {
            If (n=char2skip && IgnoreAdditionalKeys=1)
               continue, 2
          }
        }

        Hotkey, % "~*vk" code, OnLetterPressed, useErrorLevel
        If (DisableTypingMode=0)
        {
            Hotkey, % "~+vk" code, OnLetterPressed, useErrorLevel
            Hotkey, % "~^!vk" code, OnLetterPressed, useErrorLevel
            Hotkey, % "~<^>!vk" code, OnLetterPressed, useErrorLevel
            Hotkey, % "~+^!vk" code, OnLetterPressed, useErrorLevel
            Hotkey, % "~+<^>!vk" code, OnLetterPressed, useErrorLevel
        }
        Hotkey, % "~*vk" code " Up", OnLetterUp, useErrorLevel
        If (ErrorLevel!=0 && audioAlerts=1)
           SoundBeep, 1900, 50
    }

; bind to dead keys to show the proper symbol when such a key is pressed

    If ((DeadKeys=1) && (DoNotBindAltGrDeadKeys=0)) || ((DeadKeys=1) && (DoNotBindDeadKeys=0))
    {
        Loop, Parse, DKaltGR_list, .
        {
            For i, mod in mods_list
            {
                If (enableAltGr=1)
                {
                  Hotkey, % "~^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                }

                If (enableAltGr=0)
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

                If !InStr(DKshift_list, A_LoopField)
                {
                   Hotkey, % "~+" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnLetterUp, useErrorLevel
                }

                If !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnLetterUp, useErrorLevel
                }
            }
        }
    }

    If (DeadKeys=1 && DoNotBindDeadKeys=0)
    {
        Loop, Parse, DKshift_list, .
        {
            For i, mod in mods_list
            {
                Hotkey, % "~+" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel

                If !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnLetterUp, useErrorLevel
                }

            }
        }

        Loop, Parse, DKnotShifted_list, .
        {
            For i, mod in mods_list
            {
                Hotkey, % "~" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel

                If !InStr(DKShift_list, A_LoopField)
                {
                   Hotkey, % "~+$" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnLetterUp, useErrorLevel
                }
            }
        }

        ShiftRelatedDKlist := DKshift_list "." DKnotShifted_list
        Loop, Parse, ShiftRelatedDKlist, .
        {
            For i, mod in mods_noShift
            {
               If (!InStr(DKaltGR_list, A_LoopField) && enableAltGr=1)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel
               }

               If (enableAltGr=0)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel
               }
            }
        }
    }  ; dead keys parser

    Loop, 24 ; F1-F24
    {
        Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
        Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
        If (ErrorLevel!=0 && audioAlerts=1)
           SoundBeep, 1900, 50
    }

    NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
    Loop, Parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       If (ErrorLevel!=0 && audioAlerts=1)
          SoundBeep, 1900, 50
    }

    Loop, 10 ; Numpad0 - Numpad9 ; numlock on
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnNumpadsPressed, UseErrorLevel
        Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        If (ErrorLevel!=0 && audioAlerts=1)
           SoundBeep, 1900, 50
    }

    NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
    Loop, Parse, NumpadSymbols, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadsPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       If (ErrorLevel!=0 && audioAlerts=1)
          SoundBeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|CapsLock|ScrollLock|NumLock|Pause|sc146|sc123"
    If (DisableTypingMode=1)           
       Otherkeys .= "|Left|Right|Up|Down|BackSpace|Del|Home|End|PgUp|PgDn|space"
    Loop, Parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        If (ErrorLevel!=0 && audioAlerts=1)
           SoundBeep, 1900, 50
    }

    If (ShowMouseButton=1 || visualMouseClicks=1)
    {
        Loop, Parse, % "LButton|MButton|RButton", |
        Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
        If (ErrorLevel!=0 && audioAlerts=1)
           SoundBeep, 1900, 50
    }

    For i, mod in MainModsList
    {
       Hotkey, % "~*" mod, OnMudPressed, useErrorLevel
       Hotkey, % "~*" mod " Up", OnMudUp, useErrorLevel
       If (ErrorLevel!=0 && audioAlerts=1)
          SoundBeep, 1900, 50
    }
}

OSDoutputToolTip() {
   MouseGetPos, px, py
   ToolTip, %OSDcontentOutput%, px+10, py+10
   If (OSDvisible=0)
   {
      ToolTip
      SetTimer,, off
   }
}

ShowHotkey(HotkeyStr) {
;  Sleep, 70 ; megatest
    If (outputOSDtoToolTip=1)
    {
       OSDcontentOutput := HotkeyStr
       SetTimer, OSDoutputToolTip, 70
       OSDvisible := 1
    }

    If ((HotkeyStr ~= "i)^(\s+)$") || NeverDisplayOSD=1)
       Return

    If ((HotkeyStr ~= "i)( \+ )") && !(typed ~= "i)( \+ )") && OnlyTypingMode=1)
       Return

    Global tickcount_start2 := A_TickCount
    Static oldText_width, Wid, Heig
    If (OSDautosize=1)
    {
        If (StrLen(HotkeyStr)!=oldText_width || showPreview=1 || StrLen(typed)<2)
        {
           growthIncrement := (FontSize/2)*(OSDautosizeFactory/150)
           startPoint := GetTextExtentPoint(HotkeyStr, FontName, FontSize) / (OSDautosizeFactory/100) + 35
           If ((startPoint > text_width+growthIncrement) || (startPoint < text_width-growthIncrement) || StrLen(typed)<2)
              text_width := Round(startPoint)
           text_width := (text_width > maxAllowedGuiWidth-growthIncrement*2) ? Round(maxAllowedGuiWidth) : Round(text_width)
        }
        oldText_width := StrLen(HotkeyStr)
    } Else If (OSDautosize=0)
    {
        text_width := maxAllowedGuiWidth
    }
    dGuiX := Round(GuiX)
    GuiControl, OSD: , HotkeyText, %HotkeyStr%
    If (OSDalignment>1)
    {
        Gui, OSDghost: Show, NoActivate Hide x%dGuiX% y%GuiY% w%text_width%, KeyPressOSDghost
        GuiGetSize(Wid, Heig, 0)
        If (OSDalignment=3)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid) : Round(dGuiX)
        If (OSDalignment=2)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid)/2 : Round(dGuiX)
        GuiControl, OSD: Move, HotkeyText, w%text_width% Left
    }
    SetTimer, checkMousePresence, on, 950, -15
    If (OSDalignment>1)
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
;  Sleep, 60 ; megatest

  hDC := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
  nHeight := -DllCall("kernel32\MulDiv", "Int", nHeight, "Int", DllCall("gdi32\GetDeviceCaps", "Ptr", hDC, "Int", 90), "Int", 72)

  hFont := DllCall("gdi32\CreateFontW"
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
  hFold := DllCall("gdi32\SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr")

  DllCall("gdi32\GetTextExtentPoint32W", "Ptr", hDC, "Str", sString, "Int", StrLen(sString), "Int64P", nSize)
  DllCall("gdi32\SelectObject", "Ptr", hDC, "Ptr", hFold)
  DllCall("gdi32\DeleteObject", "Ptr", hFont)
  DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", hDC)
  SetFormat, Integer, D

  nWidth := nSize & 0xFFFFFFFF
  nWidth := (nWidth<35) ? 36 : Round(nWidth)

  If (initialStart=1 || A_IsSuspended)
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
;  Sleep, 60 ; megatest

  If (vindov=0)
     Gui, OSDghost: +LastFoundExist
  If (vindov=1)
     Gui, OSD: +LastFoundExist
  If (vindov=2)
     Gui, MouseH: +LastFoundExist
  If (vindov=3)
     Gui, MouseIdlah: +LastFoundExist
  If (vindov=4)
     Gui, Mouser: +LastFoundExist
  If (vindov=5)
     Gui, SettingsGUIA: +LastFoundExist
  VarSetCapacity(rect, 16, 0)
  DllCall("user32\GetClientRect", "Ptr", MyGuiHWND := WinExist(), "Ptr", &rect)
  W := NumGet(rect, 8, "UInt")
  H := NumGet(rect, 12, "UInt")
}

modsTimer() {
    Critical, Off
    Thread, Priority, -50

    globalPrefix := profix := ""
    For i, mod in MainModsList
    {
        If GetKeyState(mod)
           profix .= mod "+"
    }
    globalPrefix := profix
    If (OSDshowLEDs=1)
    {
       GuiControl, OSD:, ModsLED, % profix ? 100 : 0
       SetTimer, ModsLEDsIndicatorsManager, 370, 20
    }
    If profix
    {
       If (SilentMode=0 && beepFiringKeys=1 && (A_TickCount-tickcount_start>850))
       {
          beeperzDefunctions.ahkPostFunction["holdingKeys", ""]
          Sleep, 200
       }
       If (OSDvisible!=1 && ShowSingleModifierKey=1 && OnlyTypingMode=0)
       {
          showThis := CompactModifiers(profix)
          Sort, showThis, U D+
          showThis := RTrim(showThis, "+")
          StringReplace, showThis, showThis, +, %A_Space%+%A_Space%, All
          ShowHotkey(showThis)
       }
       SetTimer, HideGUI, % -DisplayTime
    }
    If !profix
    {
       globalPrefix := profix
       SetTimer,, off
    }
}

ClicksTimer() {
    Critical, Off
    Thread, Priority, -50
    ClicksList := ["LButton", "RButton", "MButton"]    
    For i, clicky in ClicksList
    {
        If GetKeyState(clicky)
           profix .= mod "+"
    }

    If profix
    {
       If (SilentMode=0 && beepFiringKeys=1 && (A_TickCount-tickcount_start>850))
          beeperzDefunctions.ahkPostFunction["holdingKeys", ""]

       SetTimer, HideGUI, % -DisplayTime
    }
    If !profix
       SetTimer,, off
}
GetKeyStr() {
;  Sleep, 40 ; megatest
    If (outputOSDtoToolTip=0 && NeverDisplayOSD=1)
       Return

    modifiers_temp := 0
    Static FriendlyKeyNames := {NumpadDot:"[ . ]", NumpadDiv:"[ / ]", NumpadMult:"[ * ]", NumpadAdd:"[ + ]", NumpadSub:"[ - ]", numpad0:"[ 0 ]", numpad1:"[ 1 ]", numpad2:"[ 2 ]", numpad3:"[ 3 ]", numpad4:"[ 4 ]", numpad5:"[ 5 ]", numpad6:"[ 6 ]", numpad7:"[ 7 ]", numpad8:"[ 8 ]", numpad9:"[ 9 ]", NumpadEnter:"[Enter]", NumpadDel:"[Delete]", NumpadIns:"[Insert]", NumpadHome:"[Home]", NumpadEnd:"[End]", NumpadUp:"[Up]", NumpadDown:"[Down]", NumpadPgdn:"[Page Down]", NumpadPgup:"[Page Up]", NumpadLeft:"[Left]", NumpadRight:"[Right]", NumpadClear:"[Clear]", Media_Play_Pause:"Media_Play/Pause", MButton:"Middle Click", RButton:"Right Click", Del:"Delete", PgUp:"Page Up", PgDn:"Page Down"}
    For i, mod in MainModsList
    {
        If GetKeyState(mod)
           prefix .= mod "+"
    }

    If !prefix && globalPrefix
       prefix := globalPrefix
    globalPrefix := ""
    SetTimer, modsTimer, Off
    If (!prefix && !ShowSingleKey)
        throw

    key := A_ThisHotkey
    StringReplace, key, key, %A_Space%up,
    StringRight, backupKey, key, 1
    key := RegExReplace(key, "i)^(~\+\$vk)", "vk")
    key := RegExReplace(key, "i)^(~\+\^!|~\+<!<\^|~\+<!>\^|~\+<\^>!|~<\^>!|~!#\^\+|~<\^<!|~>\^>!|~\^!|~#!\+|~#!\^|~#\+\^|~\+!\^|~!#\^|~!\+\^|~!#|~\+#|~#\^|~!\+|~!\^|~\+\^|~#!|~\*|~\^|~!|~#|~\+)")
    StringReplace, key, key, ~,
    If (sendJumpKeys=1)
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

    If (StrLen(key)=1)
    {
        StringLeft, key, key, 2
        key := GetKeyChar(key)
    } Else If (SubStr(key, 1, 2) = "sc") && (key != "ScrollLock") && StrLen(typed)<2 || (SubStr(key, 1, 2) = "vk") && StrLen(typed)<2 || (SubStr(key, 1, 2) = "vk") && prefix {
        key := (GetSpecialSC(key) || GetSpecialSC(key)=0) ? GetSpecialSC(key) : key
    } Else If (StrLen(key)<1) && !prefix {
        key := (ShowDeadKeys=1) ? "◐" : "(unknown key)"
        key := backupKey ? backupKey : key
    } Else If FriendlyKeyNames.hasKey(key) {
        key := FriendlyKeyNames[key]
    } Else If (key = "Volume_Up") {
        Sleep, 40
        SoundGet, master_volume
        key := "Volume up: " Round(master_volume)
        SetMyVolume()
    } Else If (key = "Volume_Down") {
        Sleep, 40
        SoundGet, master_volume
        key := "Volume down: " Round(master_volume)
        SetMyVolume()
    } Else If (key = "Volume_mute") {
        SoundGet, master_volume
        SoundGet, master_mute, , mute
        If (master_mute="on")
           key := "Volume: MUTE"
        If (master_mute="off")
           key := "Volume level: " Round(master_volume)
    } Else If (key = "PrintScreen") {
        If (HideAnnoyingKeys=1 || OnlyTypingMode=1)
            throw
        key := "Print Screen"
    } Else If InStr(key, "lock") {
        key := GetCrayCrayState(key)
    } Else If InStr(key, "wheel") {
        If (ShowMouseButton=0 || OnlyTypingMode=1)
           throw
        Else
           StringReplace, key, key, wheel, wheel%A_Space%
    } Else If (key = "LButton" && IsDoubleClick()) {
        key := "Double Click"
    } Else If (key = "LButton") {
        If (HideAnnoyingKeys=1 && !prefix)
        {
            If (!(typed ~= "i)(  │)") && StrLen(typed)>3 && ShowMouseButton=1 && (A_TickCount - lastTypedSince > 2000)) {
               If !InStr(typed, lola2)
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
    If (OnlyTypingMode=1)
       keyCount := (StrLen(typed)>1) ? 1 : 0
    StringUpper, key, key, T
    If InStr(key, "lock on")
       StringUpper, key, key
    StringUpper, pre_key, pre_key, T
    keyCount := (key=pre_key) && (prefix = pre_prefix) && (repeatCount<1.5) ? keyCount : 1
    filteredPrevKeys := "i)^(vk|Media_|Volume|.*lock)"
    If (ShowPrevKey=1 && keyCount<2 && (A_TickCount-tickcount_start < ShowPrevKeyDelay) && !(pre_key ~= filteredPrevKeys) && !(key ~= filteredPrevKeys))
    {
        ShowPrevKeyValid := 0
        If ((prefix != pre_prefix && key=pre_key) || (key!=pre_key && !prefix) || (key!=pre_key && pre_prefix))
        {
           ShowPrevKeyValid := (OnlyTypingMode=1) ? 0 : 1
           If (InStr(pre_key, " up") && StrLen(pre_key)=4)
               StringLeft, pre_key, pre_key, 1
        }
    } Else (ShowPrevKeyValid := 0)

    If (key=pre_key && ShowKeyCountFired=0 && ShowKeyCount=1 && !(key ~= "i)(volume)"))
    {
       trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
       keyCount := (trackingPresses=0 && keycount<2) ? keycount+1 : keycount
       If (trackingPresses=1)
          keyCount := !keycount ? 1 : keyCount+1
       If (trackingPresses=0 && InStr(prefix, "+") && (A_TickCount-tickcount_start < 600) && (tickcount_start2 - tickcount_start < 500))
          keyCount := !keycount ? 1 : keyCount+1
       ShowKeyCountValid := 1
    } Else If (key=pre_key && ShowKeyCountFired=1 && ShowKeyCount=1 && !(key ~= "i)(volume)"))
    {
       keyCount := !keycount ? 0 : keyCount+1
       ShowKeyCountValid := 1
    } Else If (key=pre_key && ShowKeyCount=0 && DisableTypingMode=0)
    {
       keyCount := !keycount ? 0 : keyCount+1
       ShowKeyCountValid := 0
    } Else
    {
       keyCount := 1
       ShowKeyCountValid := 0
    }

    If (prefix != pre_prefix)
    {
        result := (ShowPrevKeyValid=1) ? prefix key " {" pre_prefix pre_key "}" : prefix key
        keyCount := 1
    } Else If (ShowPrevKeyValid=1)
    {
        key := (Round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" Round(keyCount) ")") : (key ", " pre_key)
    } Else If (ShowPrevKeyValid=0)
    {
        key := (Round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" Round(keyCount) ")") : (key)
    } Else (keyCount := 1)

    pre_prefix := prefix
    pre_key := _key
    prefixed := prefix ? 1 : 0
    Return result ? result : prefix . key
}

CompactModifiers(ztr) {
    CompactPattern := {"LCtrl":"Ctrl", "RCtrl":"Ctrl", "LShift":"Shift", "RShift":"Shift", "LAlt":"Alt", "LWin":"WinKey", "RWin":"WinKey", "RAlt":"AltGr"}
    If (DifferModifiers=0)
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
    If (SecondaryTypingMode=1)
       shtate := !shtate

    tehResult := (shtate=1) ? key " ON" : key " off"
    StringReplace, tehResult, tehResult, lock, %A_SPACE%lock
    If (OSDshowLEDs=1)
    {
        If InStr(tehResult, "caps lock on")
           GuiControl, OSD:, CapsLED, 100
        If InStr(tehResult, "num lock on")
           GuiControl, OSD:, NumLED, 100
        If InStr(tehResult, "scroll lock on")
           GuiControl, OSD:, ScrolLED, 100

        SetTimer, LEDsIndicatorsManager, 300, 20
    }
    Return tehResult
}

GetSpecialSC(sc) {

    k := {sc11d: "(special key)", sc146: "Pause/Break", sc123: "Genius LuxeMate Scroll"}
    If !k[sc]
    {
       brr := GetKeyChar(sc)
       StringLeft, brr, brr, 1
       k[sc] := brr
    }

    If !k[sc]
       k[sc] := GetKeyName(sc)

    Return k[sc]
}

GetDeadKeySymbol(hotkeya) {
   lenghty := InStr(DKnamez, hotkeya)
   lenghty := (lenghty=0) ? 2 : lenghty
   symbol := SubStr(DKnamez, lenghty-1, 1)
   symbol := (symbol="") || (symbol="v") || (symbol="k") ? "▪" : symbol
   Return symbol
}

; <tmplinshi>: thanks to Lexikos: https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236

GetKeyChar(Key) {
;  Sleep, 30 ; megatest

    If (key ~= "i)^(vk)")
    {
       sc := "0x0" GetKeySC(Key)
       sc := sc + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 3)
    } Else If (StrLen(key)>7)
    {
       sc := SubStr(key, InStr(key, "sc")+2, 3) + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 2)
       vk := vk + 0
    } Else
    {
       sc := GetKeySC(Key)
       vk := GetKeyVK(Key)
    }

    nsa := DllCall("user32\MapVirtualKeyW", "UInt", vk, "UInt", 2)
    If (nsa<=0 && DeadKeys=0)
       Return

    thread := DllCall("user32\GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0)
    hkl := DllCall("user32\GetKeyboardLayout", "UInt", thread, "Ptr")

    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)

    n := DllCall("user32\ToUnicodeEx", "UInt", vk, "UInt", sc, "Ptr", &state, "Ptr", &char, "Int", 2, "UInt", 0, "Ptr", hkl)
    n := DllCall("user32\ToUnicodeEx", "UInt", vk, "UInt", sc, "Ptr", &state, "Ptr", &char, "Int", 2, "UInt", 0, "Ptr", hkl)
    Return StrGet(&char, n, "utf-16")
}

GenerateDKnames() {
     Loop, Parse, DKnotShifted_list, .
     {
           backupSymbol := SubStr(A_LoopField, InStr(A_LoopField, "vk")+2, 2)
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc)
           {
              DKnamez .= toUnicodeExtended(vk, sc) "~" A_LoopField
           } Else If GetKeyName("vk" backupSymbol)
           {
              DKnamez .= GetKeyName("vk" backupSymbol) "~" A_LoopField
           }
     }

     Loop, Parse, DKShift_list, .
     {
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc, 1)
              DKnamez .= toUnicodeExtended(vk, sc, 1) "~+" A_LoopField
     }
     Loop, Parse, DKaltGR_list, .
     {
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc, 0, 1)
           {
              DKnamez .= toUnicodeExtended(vk, sc, 0, 1) "~^!" A_LoopField
              DKnamez .= toUnicodeExtended(vk, sc, 0, 1) "~<^>!" A_LoopField
           }
     }

     IniRead, DKshAltGR_list, %langFile%, %kbLayoutRaw%, DKshAltGr, %A_Space%
     Loop, Parse, DKshAltGR_list, .
     {
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc, 1, 1)
              DKnamez .= toUnicodeExtended(vk, sc, 1, 1) "~+^!" A_LoopField
     }
}

tehDKcollector() {
  StringRight, shortKBDtest2, kbLayoutRaw, 6
  IniRead, IMEtest, %langFile%, IMEs, % "00" shortKBDtest2, 0
  If IMEtest
     Return

  IniRead, hasDKs, %langFile%, %kbLayoutRaw%, hasDKs
  If (hasDKs=1)
  {
      DeadKeys := 1
      IniRead, DKnotShifted_list, %langFile%, %kbLayoutRaw%, DK, %A_Space%
      IniRead, DKshift_list, %langFile%, %kbLayoutRaw%, DKshift, %A_Space%
      IniRead, DKaltGR_list, %langFile%, %kbLayoutRaw%, DKaltGr, %A_Space%
      IniRead, DKshAltGR_list, %langFile%, %kbLayoutRaw%, DKshAltGr, %A_Space%
      IniRead, DKnamez, %langFile%, %kbLayoutRaw%, DKnamez, %A_Space%

      Loop, Parse, DKshAltGR_list, .
      {
           If StrLen(DKshAltGR_list)<3
              Break
           If !InStr(DKaltGR_list, A_LoopField)
              DKaltGR_list .= "." A_LoopField
      }

      If (StrLen(DKnamez)<2)
      {
         GenerateDKnames()
         Sleep, 25
         IniWrite, %DKnamez%, %langFile%, %kbLayoutRaw%, DKnamez
      }
  } Else If (hasDKs=0)
      AlternativeHook2keys := DeadKeys := 0
    Else If (hasDKs="ERROR")
      troubledWaterz := 10
  Return troubledWaterz
}

initLangFile(forceIT:=0) {
  IniRead, KLIDlist, %langFile%, Options, KLIDlist, -
  IniRead, UseMUInames2, %langFile%, Options, UseMUInames, -
  If (!InStr(KLIDlist, kbLayoutRaw) || UseMUInames2!=UseMUInames)
     FileDelete, %langFile%

  If (!FileExist(langfile) || forceIT=1)
  {
      dbg := GetLayoutsInfo()
      FileAppend, %dbg%, %langfile%, UTF-16
      Sleep, 50
      checkInstalledLangs()
      Sleep, 50
      listIMEs()
      Sleep, 50
      IniRead, KLIDlist, %langFile%, Options, KLIDlist, %A_Space%
      IniRead, KLIDlist2, %langFile%, Options, KLIDlist2, %A_Space%
      KLIDlist := KLIDlist "," KLIDlist2
      Sort, KLIDlist, U D,
      Sleep, 50
      IniWrite, %KLIDlist%, %langFile%, Options, KLIDlist
      IniWrite, %UseMUInames%, %langFile%, Options, UseMUInames
      Sleep, 25
      IniDelete, %langFile%, Options, KLIDlist2
      Sleep, 50
  } Else (loadedLangz := 1)
}

dumpRegLangData() {
    Loop
    {
      RegRead, kbdPreInstalled, HKEY_CURRENT_USER, Keyboard Layout\Preload, %A_Index%
      If !kbdPreInstalled
         Break
      PreloadList .= kbdPreInstalled ","
      RegRead, kbdRealInstalled, HKEY_CURRENT_USER, Keyboard Layout\Substitutes, %kbdPreInstalled%
      If !kbdRealInstalled
         Continue
      kbdSubsInstList .= kbdPreInstalled "-" kbdRealInstalled ","
      SubsOnlyList .= kbdRealInstalled ","
    }
    IniWrite, %PreloadList%, %langFile%, REGdumpData, PreloadList
    IniWrite, %kbdSubsInstList%, %langFile%, REGdumpData, SubstitutesList
    REGdump := SubsOnlyList "," PreloadList
    Return REGdump
}

IdentifyKBDlayout() {
  kbLayoutRaw := checkWindowKBD()
  langFriendlySysName := ISOcodeCulture(kbLayoutRaw) GetLayoutDisplayName(kbLayoutRaw)
  langFriendlySysName := RegExReplace(langFriendlySysName, "i)^(\s)", "")
  perWindowKbLayout := DllCall("user32\GetKeyboardLayout", "UInt", DllCall("user32\GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr",0), "Ptr")
  perWindowKbLayout := Hex2Str(perWindowKbLayout, 8, 0, 1)
  If InStr(perWindowKbLayout, "FFFFF")
     perWindowKbLayout := ""

  If (StrLen(langFriendlySysName)<2 && StrLen(perWindowKbLayout)>2)
     langFriendlySysName := ISOcodeCulture(kbLayoutRaw) GetLayoutDisplayName(perWindowKbLayout)

  initLangFile()
  testLangExist := tehDKcollector()
  Sleep, 25
  If (testLangExist=10)
  {
      hkl := GetInputHKL()
      Sleep, 50
      IniDelete, %langFile%, %kbLayoutRaw%
      dbg := GetLayoutInfo(kbLayoutRaw, hkl)
      FileAppend, %dbg%, %langfile%, UTF-16
      Sleep, 50
      tehDKcollector()
      Sleep, 50
  }
  IniRead, isLangRTL, %langFile%, %kbLayoutRaw%, isRTL
  IniRead, isVertUp, %langFile%, %kbLayoutRaw%, isVertUp
  If (isVertUp=1)
     KBDisUnsupported := 1

  StringRight, shortKBDtest0, kbLayoutRaw, 4
  If (StrLen(perWindowKbLayout)>2 && InStr(perWindowKbLayout, shortKBDtest0))
  {
     StringLeft, shortKBDtest1, perWindowKbLayout, 4
     shortKBDtest1 := "0000" shortKBDtest1
     StringRight, shortKBDtest2, perWindowKbLayout, 4
     shortKBDtest2 := "0000" shortKBDtest2
     IniRead, IMEtest, %langFile%, IMEs, %shortKBDtest2%, 0
     If (IMEtest && shortKBDtest1=IMEtest)
     {
        IMEname := findIMEname(shortKBDtest2)
        langFriendlySysName := IMEname " " langFriendlySysName
        KBDisUnsupported := 1
     }
  }

  If (StrLen(langFriendlySysName)<2)
  {
     langFriendlySysName := "Unrecognized"
     KBDisUnsupported := 1
  }

  CurrentKBD := "Detected: " langFriendlySysName ". " kbLayoutRaw " " perWindowKbLayout
  If (isLangRTL=1)
     CurrentKBD := "Partial support: " langFriendlySysName " ( " kbLayoutRaw " " perWindowKbLayout " )"

  If (KBDisUnsupported=1)
     CurrentKBD := "Unsupported: " langFriendlySysName " ( " kbLayoutRaw " " perWindowKbLayout " )"

  If (SilentDetection=0)
  {
      ShowLongMsg("Detected: " langFriendlySysName)
      If (KBDisUnsupported=1 || isLangRTL=1)
      {
         ShowLongMsg(CurrentKBD)
         SoundBeep, 300, 900
      }
      SetTimer, HideGUI, % -DisplayTime/2
  }

  StringLeft, clayout, langFriendlySysName, 25
  Menu, Tray, Add, %clayout%, dummy
  Menu, Tray, Disable, %clayout%
  Menu, Tray, Add

  If (ConstantAutoDetect=1 && AutoDetectKBD=1)
     SetTimer, INITkbdDummyDelay, 5000, 915
}

INITkbdDummyDelay() {
  Thread, Priority, -20
  Critical, off
  IniRead, KBDsDetected, %langFile%, Options, KBDsDetected
  If (KBDsDetected<2)
  {
     ConstantAutoDetect := 0
     Menu, Tray, % (ConstantAutoDetect=0 ? "Uncheck" : "Check"), &Monitor keyboard layout
     Return
  }
  SetTimer, ConstantKBDtimer, 950, -25
  SetTimer,, off
}

ConstantKBDtimer() {
    If (A_TimeIdle > 5000)
       Return

    If A_IsSuspended || (SecondaryTypingMode=1) || (A_TickCount - lastTypedSince < 1000) || (A_TickCount - deadKeyPressed < 6900) || (anyWindowOpen=1)
       Return

    Critical, off
    newLayout := checkWindowKBD()
    If (newLayout!=kbLayoutRaw)
    {
       If (SilentDetection=0 && SilentMode=0)
          beeperzDefunctions.ahkPostFunction["firingKeys", ""]
       If (A_TickCount - lastTypedSince > 1500) && (A_TickCount - tickcount_start > 700)
          ReloadScript()
    }
}

IsDoubleClick() {
    DCT := DllCall("user32\GetDoubleClickTime")
    Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < DCT)
}

HideGUI() {
    If (SecondaryTypingMode=1 || (A_TimeIdle > DisplayTimeTyping+2000))
       Return
    Thread, Priority, -20
    Critical, off
    OSDvisible := 0
    Gui, OSD: Hide
    Gui, capTxt: Hide
    SetTimer, checkMousePresence, off
}

checkMousePresence() {
    If (A_TickCount - lastTypedSince < 1500) || (A_TickCount - deadKeyPressed < 2000)
       Return

    Thread, Priority, -20
    Critical, off

    WinGetTitle, activeWindow, A
    If ((activeWindow ~= "i)^(KeyPressOSDwin)") && DragOSDmode=0 && SecondaryTypingMode=0)
       HideGUI()

    If (JumpHover=1 && !A_IsSuspended && DragOSDmode=0 && prefOpen=0)
    {
        MouseGetPos, , , id, control
        WinGetTitle, title, ahk_id %id%
        If (title = "KeyPressOSDwin")
           TogglePosition()
    }
}

RegisterGlobalShortcuts(HotKate,destination,apriori) {
   testHotKate := RegExReplace(HotKate, "i)^(\!|\^|\#|\+)$", "")
   If (InStr(hotkate, "disa") || StrLen(HotKate)<1)
   {
      HotKate := "(Disabled)"
      Return HotKate
   }

   Hotkey, %HotKate%, %destination%, UseErrorLevel
   If (ErrorLevel!=0)
   {
      Hotkey, %apriori%, %destination%, UseErrorLevel
      Return apriori
   }
   Return HotKate
}

CreateGlobalShortcuts() {

    KBDsuspend := RegisterGlobalShortcuts(KBDsuspend,"SuspendScript", "+Pause")
    If (alternateTypingMode=1)
       KBDaltTypeMode := RegisterGlobalShortcuts(KBDaltTypeMode,"SwitchSecondaryTypingMode", "^+CapsLock")

    If (pasteOSDcontent=1 && DisableTypingMode=0)
    {
       KBDpasteOSDcnt1 := RegisterGlobalShortcuts(KBDpasteOSDcnt1,"sendOSDcontent", "^+Insert")
       KBDpasteOSDcnt2 := RegisterGlobalShortcuts(KBDpasteOSDcnt2,"sendOSDcontent2", "^+!Insert")
    }

    If (DisableTypingMode=0 && KeyboardShortcuts=1)
    {
       KBDsynchApp1 := RegisterGlobalShortcuts(KBDsynchApp1,"SynchronizeApp", "#Insert")
       KBDsynchApp2 := RegisterGlobalShortcuts(KBDsynchApp2,"SynchronizeApp2", "#!Insert")
    }
    If (enableClipManager=1)
       KBDclippyMenu := RegisterGlobalShortcuts(KBDclippyMenu,"InvokeClippyMenu", "#v")

    If (KeyboardShortcuts=1)
    {
       KBDTglNeverOSD := RegisterGlobalShortcuts(KBDTglNeverOSD,"ToggleNeverDisplay", "!+^F8")
       KBDTglPosition := RegisterGlobalShortcuts(KBDTglPosition,"TogglePosition", "!+^F9")
       KBDTglSilence := RegisterGlobalShortcuts(KBDTglSilence,"ToggleSilence", "!+^F10")
       KBDidLangNow := RegisterGlobalShortcuts(KBDidLangNow,"DetectLangNow", "!+^F11")
       KBDReload := RegisterGlobalShortcuts(KBDReload,"ReloadScriptNow", "!+^F12")
       KBDCapText := RegisterGlobalShortcuts(KBDCapText,"CaptureTextNow", "Disabled")
    }
}

SynchronizeApp() {
  If (A_IsSuspended=1 || SecondaryTypingMode=1)
     Return
  If (outputOSDtoToolTip=0 && NeverDisplayOSD=1)
     Return
  enableClipManager := 0
  clipBackup := ClipboardAll
  Clipboard := ""
  WinGetTitle, Window2ActivateNow, A
  hwndStart := WinExist("A")
  If (synchronizeMode=0)
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
  } Else If (synchronizeMode=1)
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
      Sendinput {LCtrl Down}
      Sleep, 15
      Sendinput {vk43}
      Sleep, 15
      Sendinput {LCtrl Up}
      Sleep, 15
      Sendinput {Right}
  } Else
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
      Sendinput {LCtrl Down}
      Sleep, 15
      Sendinput {vk43}
      Sleep, 15
      Sendinput {LCtrl Up}
      Sleep, 15
      Sendinput {Left}
      Sleep, 15
      Sendinput {Right}
      Sleep, 15
      Sendinput {End 2}
  }
  ForceReleaseMODs()
  Sleep, 25
  If (StrLen(Clipboard)<1)
     ClipWait, 1
  
  If (StrLen(Clipboard)>0)
  {
     StringRight, typed, Clipboard, 950
     StringReplace, typed, typed, %A_TAB%, %A_SPACE%, All
     StringReplace, typed, typed, `r`n, %A_SPACE%, All
     CaretPos := StrLen(typed)+1
     typed := ST_Insert(lola, typed, CaretPos)
     keyCount := 1
     CalcVisibleText()
     ShowHotkey(visibleTextField)
     SetTimer, HideGUI, % -DisplayTimeTyping
  } Else
  {
     Sleep, 25
     ShowLongMsg("No text found...")
     SetTimer, HideGUI, % -DisplayTime
  }
  IfWinNotActive, %Window2ActivateNow%
     WinActivate, ahk_id %hwndStart%
  Clipboard := clipBackup
  clipBackup := " "
  Global lastTypedSince := A_TickCount
  IniRead, enableClipManager, %inifile%, SavedSettings, enableClipManager, %enableClipManager%
}

ForceReleaseMODs() {
   Loop
   {
       If GetKeyState("Ctrl")
       {
           Sleep, 5
           Sendinput, {Ctrl up}
       } Else CtrlhasUpped := 1
       If GetKeyState("Alt")
       {
           Sleep, 5
           Sendinput, {Alt up}
       } Else AlthasUpped := 1
       If GetKeyState("Shift")
       {
           Sleep, 5
           Sendinput, {Shift up}
       } Else ShifthasUpped := 1
       If GetKeyState("LWin")
       {
           Sleep, 5
           Sendinput, {LWin up}
       } Else LWinhasUpped := 1
       If GetKeyState("RWin")
       {
           Sleep, 5
           Sendinput, {RWin up}
       } Else RWinhasUpped := 1

       if (ShifthasUpped=1 && CtrlhasUpped=1 && AlthasUpped=1 && RWinhasUpped=1 && LWinhasUpped=1)
          hasUpped := 1
   } Until (hasUpped=1 || A_Index>200)
}

SynchronizeApp2() {
  If (SecondaryTypingMode=1 || A_IsSuspended=1)
     Return
  synchronizeMode := 5
  SynchronizeApp()
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
}

sendOSDcontent2() {
  If (SecondaryTypingMode=1 || A_IsSuspended=1)
     Return
  synchronizeMode := 10
  sendOSDcontent()
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
}

sendOSDcontent(forceIT:=0) {
  If (forceIT=0)
  {
     If (A_IsSuspended=1 || NeverDisplayOSD=1)
        Return
  }
  typed := backtypeCtrl
  If (StrLen(typed)<2 && (A_TickCount-lastTypedSince < ReturnToTypingDelay/2))
     typed := editField2
  If (StrLen(typed)>1)
  {
     StringReplace, typed, typed, %lola%
     StringReplace, typed, typed, %lola2%
     Sleep, 25
     If (synchronizeMode=10)
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
  } Else
  {
     ShowLongMsg("Nothing to paste...")
     SetTimer, HideGUI, % -DisplayTime
  }
}

SuspendScriptNow() {
  SuspendScript(0)
}

SuspendScript(partially:=0) {
   Suspend, Permit
   Thread, Priority, 50
   Critical, On

   If (SecondaryTypingMode=1)
      Return

   If (prefOpen=1 && A_IsSuspended=1)
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }
 
   If (Capture2Text=1)
      ToggleCapture2Text()
   If (TextZoomer=1)
      ToggleCaptureText()
   Sleep, 50
   Menu, Tray, UseErrorLevel
   Menu, Tray, Rename, &KeyPress activated,&KeyPress deactivated
   If (ErrorLevel=1)
   {
      Menu, Tray, Rename, &KeyPress deactivated,&KeyPress activated
      Menu, Tray, Check, &KeyPress activated
   }
   Menu, Tray, Uncheck, &KeyPress deactivated
   CreateOSDGUI()
   typed := ""
   backTypeCtrl := ""
   backTypdUndo := ""
   friendlyName := A_IsSuspended ? "activated" : "deactivated"
   ShowLongMsg("KeyPress OSD " friendlyName)
   SetTimer, HideGUI, % -DisplayTime/2
   If (NOahkH!=1 && partially=0)
   {
      ScriptelSuspendel := A_IsSuspended ? 0 : "Y"
      mouseFonctiones.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
      Sleep, 25
      mouseFonctiones.ahkPostFunction["ToggleMouseTimerz", ""]
      beeperzDefunctions.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
      mouseRipplesThread.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
   }
   Sleep, 50
   Suspend
}

ToggleConstantDetection() {
   If (prefOpen=1 && A_IsSuspended=1)
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
   If (ConstantAutoDetect=1)
      SetTimer, ConstantKBDtimer, 950, -25
   Else
      SetTimer, ConstantKBDtimer, off
   Sleep, 500
}

ToggleNeverDisplay() {
   If (SecondaryTypingMode=1)
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
    If (A_IsSuspended=1 || NeverDisplayOSD=1)
    {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
    }
    If (SecondaryTypingMode=1)
       Return

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

    If (Capture2Text!=1)
    {
        IniWrite, %GUIposition%, %IniFile%, SavedSettings, GUIposition
        ShowLongMsg("OSD position: " niceNaming )
        Sleep, 450
        ShowLongMsg("OSD position: " niceNaming )
        SetTimer, HideGUI, % -DisplayTime
        Gui, OSD: Destroy
        Sleep, 20
        CreateOSDGUI()
        Sleep, 20 
    }
}

ToggleSilence() {
    SilentMode := !SilentMode
    IniWrite, %SilentMode%, %IniFile%, SavedSettings, SilentMode
    Sleep, 50
    mouseFonctiones.ahkReload[]
    beeperzDefunctions.ahkReload[]
    Menu, PrefsMenu, % (SilentMode=0 ? "Uncheck" : "Check"), S&ilent mode
    ShowLongMsg("Silent mode = " SilentMode)
    SetTimer, HideGUI, % -DisplayTime
}

ToggleTypingHistory() {
    enableTypingHistory := !enableTypingHistory
    IniWrite, %enableTypingHistory%, %IniFile%, SavedSettings, enableTypingHistory
}

ToggleCaptureText() {
    If (!IsFunc("Acc_Init") OR !IsFunc("UIA_Interface")) ; keypress-acc-viewer-functions.ahk / UIA_Interface.ahk
    {
      ShowLongMsg("ERROR: Missing files...")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    TextZoomer := !TextZoomer
    Menu, Tray, % (TextZoomer=0 ? "Uncheck" : "Check"), Mouse text collector
    gay := "GetAccInfo"
    If IsFunc(gay)
    {
        If (TextZoomer=1)
          SetTimer, %gay%, 120, 50
        Else
          SetTimer, %gay%, off
    }
    Sleep, 400
}

CaptureTextNow() {
    If (!IsFunc("Acc_Init") OR !IsFunc("UIA_Interface")) ; keypress-acc-viewer-functions.ahk / UIA_Interface.ahk
    {
      ShowLongMsg("ERROR: Missing files...")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    gay := "GetAccInfo"
    If IsFunc(gay)
    {
       Global doNotRepeatTimer := A_TickCount
       %gay%(1)
    }
    Else SoundBeep, 300, 900
}

ToggleLargeFonts() {
    prefsLargeFonts := !prefsLargeFonts
    IniWrite, %prefsLargeFonts%, %IniFile%, SavedSettings, prefsLargeFonts
    Menu, PrefsMenu, % (prefsLargeFonts=0 ? "Uncheck" : "Check"), L&arge UI fonts
    Sleep, 200
}

DetectLangNow() {
    ReloadCounter := 1
    IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    CreateOSDGUI()
    AutoDetectKBD := 1
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
    If FileExist(thisFile)
    {
        If (silent!=1)
           ShowLongMsg("Restarting...")
        Cleanup()
        Sleep, 10
  ;      If (A_OSVersion!="WIN_XP")
 ;       {
           Reload             ; This one is fucked up! Replacing it with the Run + ExitApp below stopped restart crashes.
;        } else
;        {
;          sleep, 10
;          run, %thisfile%,, useerrorlevel
;          exitapp
;        }
    } Else
    {
        ShowLongMsg("FATAL ERROR: Main file missing. Execution terminated.")
        SoundBeep
        Sleep, 1000
        MsgBox, 4,, Do you want to choose another file to execute?
        IfMsgBox, Yes
        {
            FileSelectFile, i, 2, %A_ScriptDir%\%A_ScriptName%, Select a different script to load, AutoHotkey script (*.ahk; *.ah1u)
            If !InStr(FileExist(i), "D")  ; we can't run a folder, we need to run a script
               Run, %i%
        } Else (Sleep, 500)
        Cleanup()
        Sleep, 100
        ExitApp
    }
}

ToggleCapture2Text() {
    If (A_IsSuspended=1 || NeverDisplayOSD=1 || SecondaryTypingMode=1)
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
        If (Capture2Text!=1)
        {
            SoundBeep, 1900
            MsgBox, 4,, Capture2Text was not detected. Do you want to continue?
            IfMsgBox, Yes
                featureValidated := 1
            Else
                featureValidated := 0
        }
    }

    If (featureValidated=1)
    {
        Menu, Tray, Check, &Capture2Text mode (OCR)
        Sleep, 300
        Capture2Text := !Capture2Text
    }

    If (Capture2Text=1 && featureValidated=1)
    {
        JumpHover := 1
        If (ClipMonitor=0)
        {
           ClipMonitor := 1
           OnClipboardChange("ClipChanged")
        }
        enableClipManager := 0
        DragOSDmode := 0
        SetTimer, capturetext, 1500, -20
        mouseFonctiones.ahkassign("ScriptelSuspendel", "Y")
        Sleep, 25
        mouseFonctiones.ahkPostFunction["ToggleMouseTimerz", ""]
        mouseRipplesThread.ahkassign("ScriptelSuspendel", "Y")
        ShowLongMsg("Enabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
    } Else If (featureValidated=1)
    {
        Capture2Text := !Capture2Text
        IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
        GuiX := (GUIposition=1) ? GuiXa : GuiXb
        GuiY := (GUIposition=1) ? GuiYa : GuiYb
        IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
        IniRead, DragOSDmode, %inifile%, SavedSettings, DragOSDmode, %DragOSDmode%
        IniRead, enableClipManager, %inifile%, SavedSettings, enableClipManager, %enableClipManager%
        Gui, OSD: Destroy
        Sleep, 50
        CreateOSDGUI()
        Sleep, 50
        IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
        Menu, Tray, Uncheck, &Capture2Text mode (OCR)
        mouseFonctiones.ahkassign("ScriptelSuspendel", "N")
        Sleep, 25
        mouseFonctiones.ahkPostFunction["ToggleMouseTimerz", ""]
        mouseRipplesThread.ahkassign("ScriptelSuspendel", "N")
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
    If (A_TimeIdlePhysical<3000 && !A_IsSuspended && (A_TickCount-lastTypedSince > 1500))
       SendInput, {Pause}             ; set here the keyboard shortcut configured in Capture2Text
    Sleep, 1
}

processClippy(troll, clippyMode:=1) {
   Stringleft, troll, troll, 170
   StringReplace, troll, troll, %A_TAB%, %A_Space%, All
   StringReplace, troll, troll, %lola%,, All
   StringReplace, troll, troll, %lola2%,, All
   StringReplace, troll, troll, `n, %A_Space%, All
   StringReplace, troll, troll, `r, %A_Space%, All
   troll := RegExReplace(troll, "(\S.*?)\R(.*?\S)", "$1 $2")
   troll := RegExReplace(troll, "\s+", A_Space)

   If (clippyMode=1 && StrLen(troll)>40)
   {
      StringLeft, troll, troll, 40
      troll .= " [...]"
   }
   Return troll
}

ClipChanged(Type) {
    Sleep, 25
    Thread, Priority, -20
    Critical, off
    If (enableClipManager=1 && A_IsSuspended=0 && StrLen(clipboard)>0)
       ClipboardManager()

    If (A_IsSuspended=1 || (outputOSDtoToolTip=0 && NeverDisplayOSD=1))
        Return

    If (type=1 && ClipMonitor=1 && (A_TickCount-lastTypedSince > DisplayTimeTyping/2))
    {
       troll := processClippy(clipboard, 0)
       If (NeverDisplayOSD=0)
          ShowLongMsg(troll)
       Else
          ShowHotkey(troll)
       SetTimer, HideGUI, % -DisplayTime*2
    } Else If (type=2 && ClipMonitor=1 && (A_TickCount-lastTypedSince > DisplayTimeTyping))
    {
       If (NeverDisplayOSD=0)
          ShowLongMsg("Clipboard data changed")
       Else
          ShowHotkey("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

initClipboardManager() {
    IniRead, clipDataMD5s, %IniFile%, ClipboardManager, clipDataMD5s, -
    IniRead, currentClippyCount, %IniFile%, ClipboardManager, currentClippyCount, 0
    If !FileExist(A_ScriptDir "\ClipsSaved")
    {
        FileCreateDir, ClipsSaved
        clipDataMD5s := ""
        currentClippyCount := 0
    }
}

ClipboardManager() {
    clipData := Clipboard
    If (clipData ~= "i)^(.?\:\\.?.?)") && StrLen(clipData)>5
       Return
    md5check := varMD5(clipData)
    If InStr(clipDataMD5s, md5check)
       Return
    clipDataMD5s .= md5check ","
    maxLengthMD5s := StrLen(md5check)*maximumTextClips + maximumTextClips
    StringRight, clipDataMD5s, clipDataMD5s, maxLengthMD5s
    currentClippyCount++
    If (currentClippyCount>maximumTextClips)
       currentClippyCount := 1
    addZero := currentClippyCount<10 ? "0" : ""
    FileDelete, ClipsSaved\clip%addZero%%currentClippyCount%.clp
    Sleep, 25
    ClipTXT := processClippy(clipData)
    FileAppend, %ClipboardAll%, ClipsSaved\clip%addZero%%currentClippyCount%.clp
    Sleep, 25
    IniWrite, %ClipTXT%, %IniFile%, ClipboardManager, ClipTXT%currentClippyCount%
    IniWrite, %currentClippyCount%, %IniFile%, ClipboardManager, currentClippyCount
    IniWrite, %clipDataMD5s%, %IniFile%, ClipboardManager, clipDataMD5s
}

DeleteAllClippy() {
    MsgBox, 4,, Are you sure you want to delete all the stored text clips?
    IfMsgBox, Yes
    {
        currentClippyCount := 0
        clipDataMD5s := ""
        IniDelete, %inifile%, ClipboardManager
        FileDelete, ClipsSaved\clip*.clp
        GuiControl, Disable, DeleteAllClippyBTN
    }
}

GenerateClippyMenu() {
    Sleep, 25
    Loop, Files, ClipsSaved\clip*.clp
    {
        If (A_Index>maximumTextClips)
           Break
        IniRead, ClipTXT, %inifile%, ClipboardManager, ClipTXT%A_Index%, -
        StringReplace, FillName, A_LoopFileName, clip
        StringReplace, FillName, FillName, .clp
        TheClippyList .= A_LoopFileTimeModified "|-[-|" FillName ". " ClipTXT "`n"
    }
    troll := processClippy(clipboard)
    StringLeft, troll, troll, 45
    Sort, TheClippyList, R
    Menu, ClippyMenu, Delete
    If (StrLen(troll)>0 && A_IsSuspended=0)
    {
        md5checkTest := varMD5(clipboard)
        md5checkList .= "," varMD5(clipboard)
        If !InStr(clipDataMD5s, md5checkTest)
           ClipboardManager()
        Menu, ClippyMenu, Add, { %troll% }, PasteCurrentClippy
        Menu, ClippyMenu, Add
    }
    Loop, Parse, TheClippyList, `n
    {
        If !A_LoopField
           Continue
        menuEntry := SubStr(A_LoopField, InStr(A_LoopField, "|-[-|"))
        StringReplace, menuEntry, menuEntry, |-[-|
        If StrLen(menuEntry)<5
           Continue
        Menu, ClippyMenu, Add, %menuEntry%, PasteSelectedClippy
    }
    Menu, ClippyMenu, Add
    If (prefOpen=0)
    {
       If (enableTypingHistory=1 && DisableTypingMode=0)
       {
          md5checkTest := varMD5(editField0)
          If !InStr(md5checkList, md5checkTest)
          {
              md5checkList .= "," md5checkTest
              troll0 := processClippy(editField0)
              If StrLen(troll0)>1
                 Menu, ClippyMenu, Add, H0. %troll0%, PasteSelectedHistory
          }
          md5checkTest := varMD5(editField1)
          If !InStr(md5checkList, md5checkTest)
          {
              md5checkList .= "," md5checkTest
              troll1 := processClippy(editField1)
              If StrLen(troll1)>1
                 Menu, ClippyMenu, Add, H1. %troll1%, PasteSelectedHistory
          }
          md5checkTest := varMD5(editField2)
          If !InStr(md5checkList, md5checkTest)
          {
              md5checkList .= "," md5checkTest
              troll2 := processClippy(editField2)
              If StrLen(troll2)>1
                 Menu, ClippyMenu, Add, H2. %troll2%, PasteSelectedHistory
          }
          md5checkTest := varMD5(editField4)
          If !InStr(md5checkList, md5checkTest)
          {
              md5checkList .= "," md5checkTest
              troll4 := processClippy(editField4)
              If StrLen(troll4)>1
                 Menu, ClippyMenu, Add, H4. %troll4%, PasteSelectedHistory
          }
       } Else If (DisableTypingMode=0)
          Menu, ClippyMenu, Add, Activate typing history, ToggleTypingHistory

       If (DisableTypingMode=0)
       {
          Menu, ClippyMenu, Add
          Menu, ClippyMenu, Add, Capture text from host app, SynchronizeApp
          Menu, ClippyMenu, Add, Capture current line of text from host app, SynchronizeApp2
       }
    } Else Menu, ClippyMenu, Add, { Delete All }, DeleteAllClippy
}

PasteCurrentClippy() {
  Sleep, 70
  Sendinput ^{vk56}
  If (DisableTypingMode=0)
     textClipboard2OSD(Clipboard)
}

textClipboard2OSD(toPaste) {
    backTypdUndo := typed
    Stringleft, toPaste, toPaste, 950
    StringReplace, toPaste, toPaste, `r`n, %A_Space%, All
    StringReplace, toPaste, toPaste, `n, %A_Space%, All
    StringReplace, toPaste, toPaste, `r, %A_Space%, All
    StringReplace, toPaste, toPaste, `f, %A_Space%, All
    StringReplace, toPaste, toPaste, %A_TAB%, %A_SPACE%, All
    StringReplace, toPaste, toPaste, %lola%,, All
    StringReplace, toPaste, toPaste, %lola2%,, All
    InsertChar2caret(toPaste)
    CaretPos := CaretPos + StrLen(toPaste)
    maxTextChars := StrLen(typed)+2
    CalcVisibleText()
    ShowHotkey(visibleTextField)
    Global lastTypedSince := A_TickCount
    SetTimer, HideGUI, % -DisplayTimeTyping
}

PasteSelectedClippy() {
  StringLeft, readThisFile, A_ThisMenuItem, 2
  If (prefOpen=1)
     Return
  enableClipManager := 0
  Sleep, 50
  FileRead, Clipboard, *c ClipsSaved\clip%readThisFile%.clp
  Sleep, 25
  ClipWait, 2
  Sendinput ^{vk56}
  Sleep, 25
  enableClipManager := 1
  If (DisableTypingMode=0)
     textClipboard2OSD(Clipboard)
}

PasteSelectedHistory() {
  StringLeft, ThisField, A_ThisMenuItem, 2
  StringReplace, ThisField, ThisField, h
  content := editField%ThisField%
  StringReplace, content, content, %lola%,, All
  StringReplace, content, content, %lola2%,, All
  Sleep, 150
  SendInput, {text}%content%
  textClipboard2OSD(content)
}

InvokeClippyMenu() {
  ShowLongMsg("Clipboard history menu...")
  SetTimer, HideGUI, % -DisplayTime
  GenerateClippyMenu()
  Menu, ClippyMenu, Show
}

varMD5(V) {
; function from: www.autohotkey.com/forum/viewtopic.php?p=275910#275910
   StringReplace, v, v, %lola%,, All
   StringReplace, v, v, %lola2%,, All
   L := StrLen(V)
   VarSetCapacity( MD5_CTX,104,0 )
   DllCall( "advapi32\MD5Init", Str,MD5_CTX )
   DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,V, UInt,L ? L : StrLen(V) )
   DllCall( "advapi32\MD5Final", Str,MD5_CTX )
   Loop % StrLen( Hex:="123456789ABCDEF0" )
        N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
   Return MD5
}

InitializeTray() {
    Menu, PrefsMenu, Add, &Keyboard, ShowKBDsettings
    Menu, PrefsMenu, Add, &Typing mode, ShowTypeSettings
    Menu, PrefsMenu, Add, &Sounds, ShowSoundsSettings
    Menu, PrefsMenu, Add, &Mouse, ShowMouseSettings
    Menu, PrefsMenu, Add, &OSD appearance, ShowOSDsettings
    Menu, PrefsMenu, Add, &Global shortcuts, ShowShortCutsSettings
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, S&ilent mode, ToggleSilence
    Menu, PrefsMenu, Add, L&arge UI fonts, ToggleLargeFonts
    Menu, PrefsMenu, Add, Sta&rt at boot, SetStartUp
    Menu, PrefsMenu, Add, R&un in admin mode, RunAdminMode
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, R&estore defaults, DeleteSettings
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, Key &history, KeyHistoryWindow
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, &Check for updates, updateNow

    If A_IsAdmin
    {
       Menu, PrefsMenu, Check, R&un in admin mode
       Menu, PrefsMenu, Disable, R&un in admin mode
    }
    
    RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
    If StrLen(currentReg)>5
       Menu, PrefsMenu, Check, Sta&rt at boot

    If (SilentMode=1)
       Menu, PrefsMenu, Check, S&ilent mode

    If (prefsLargeFonts=1)
       Menu, PrefsMenu, Check, L&arge UI fonts

    If (!isBeeperzFile || missingAudios=1)     ; keypress-beeperz-functions.ahk
    {
       Menu, PrefsMenu, Disable, S&ilent mode
       Menu, PrefsMenu, Disable, &Sounds
    }
    If !isMouseFile ; keypress-mouse-functions.ahk
       Menu, PrefsMenu, Disable, &Mouse

    Menu, Tray, NoStandard
    If (AutoDetectKBD=1)
    {
       Menu, Tray, Add, &Monitor keyboard layout, ToggleConstantDetection
       Menu, Tray, check, &Monitor keyboard layout
       If (ConstantAutoDetect=0)
          Menu, Tray, uncheck, &Monitor keyboard layout
    }

    Menu, Tray, Add, &Installed keyboard layouts, InstalledKBDsWindow
    If (ConstantAutoDetect=0)
    {
       Menu, Tray, Add, &Detect keyboard layout now, DetectLangNow
       Menu, Tray, Add, &Monitor keyboard layout, ToggleConstantDetection
    }
    Menu, Tray, Add

    Menu, Tray, Add, &Quick start presets, PresetsWindow
    Menu, Tray, Add, &Preferences, :PrefsMenu
    Menu, Tray, Add

    If (ConstantAutoDetect=0 && loadedLangz=1)
       Menu, Tray, Add, &Detect keyboard layout now, DetectLangNow

    Menu, Tray, Add, &Toggle OSD positions, TogglePosition
    Menu, Tray, Add, &Never show the OSD, ToggleNeverDisplay
    Menu, Tray, Add, &Capture2Text mode (OCR), ToggleCapture2Text
    Menu, Tray, Add, Mouse text collector, ToggleCaptureText
    Menu, Tray, Add
    Menu, Tray, Add, &KeyPress activated, SuspendScriptNow
    Menu, tray, Check, &KeyPress activated
    Menu, Tray, Add, &Restart, ReloadScriptNow
    Menu, Tray, Add
    Menu, Tray, Add, &Help / Troubleshoot, HelpFAQstarter
    Menu, Tray, Add, &About, AboutWindow
    Menu, Tray, Add
    Menu, Tray, Delete, E&xit
    Menu, Tray, Delete, Initializing...
    Menu, Tray, Add, E&xit, KillScript
    Menu, Tray, Default, &Installed keyboard layouts
    Menu, Tray, Tip, KeyPress OSD v%version%

    If (NeverDisplayOSD=1)
       Menu, Tray, Check, &Never show the OSD

    If (!IsFunc("GetAccInfo") || A_OSVersion="WIN_XP") ; keypress-acc-viewer-functions.ahk
       Menu, Tray, Disable, Mouse text collector

    faqHtml := "Lib\help\presentation.html"
    If !FileExist(faqHtml)
       Menu, Tray, Disable, &Help / Troubleshoot
}

KeyHistoryWindow() {
  KeyHistory
}

HelpFaqStarter() {
  Run, %A_WorkingDir%\Lib\help\presentation.html
}

RunAdminMode() {
  If !A_IsAdmin
  {
      Try
      {
          If A_IsCompiled
              Run *RunAs "%A_ScriptFullPath%" /restart
          Else
              Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
          ExitApp
      }
  }
}

DeleteSettings() {
    MsgBox, 4,, Are you sure you want to delete the stored settings?
    IfMsgBox, Yes
    {
       FileSetAttrib, -R, %IniFile%
       FileSetAttrib, -R, %langfile%
       FileDelete, %IniFile%
       FileDelete, %langfile%
       verifyNonCrucialFilesRan := 2
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
       ReloadScriptNow()
    }
}

KillScript(showMSG:=1) {
   Thread, Priority, 50
   Critical, on
   If FileExist(thisFile) && showMSG
   {
      ShaveSettings()
      ShowLongMsg("Bye byeee :-)")
      Sleep, 350
   } Else If showMSG
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
   Cleanup()
   ExitApp
}

SettingsGUI() {
   Global
   Gui, SettingsGUIA: Destroy
   Sleep, 15
   Gui, SettingsGUIA: Default
   Gui, SettingsGUIA: -MaximizeBox
   Gui, SettingsGUIA: -MinimizeBox
   Gui, SettingsGUIA: Margin, 15, 15
}

initSettingsWindow() {
    Global ApplySettingsBTN
    If (prefOpen=1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        doNotOpen := 1
        Return doNotOpen
    }

    If (A_IsSuspended!=1)
       SuspendScript(1)

    prefOpen := 1
    IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
    Sleep, 30
    SettingsGUI()
}

wordPairsEditing() {
    GuiControl, Enable, SaveWordPairsBTN
    GuiControl, Enable, DefaultWordPairsBTN
}

ShowTypeSettings() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return

        Global editF1, editF2, editF3
        Global showHelp := 0
    }
    deadKstatus := (DeadKeys=1) ? "Dead keys present." : "No dead keys detected."
    Global CurrentPrefWindow := 2
    Global SaveWordPairsBTN, DefaultWordPairsBTN
    txtWid := 350
    If (prefsLargeFonts=1)
    {
       txtWid := 570
       Gui, Font, s%LargeUIfontValue%
    }
    editWid := txtWid-50
    InitExpandableWords()
    Gui, Add, Tab3,, General|Dead keys|Behavior|Text expand
    Gui, Tab, 4 ; text expand
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%expandWords% vexpandWords, Automatically expand typed words or abbreviations
    Gui, Add, Text, y+10, When {Space} is pressed... string to match // string to replace with
    Gui, Add, Edit, y+10 r10 w%editWid% gwordPairsEditing vExpandWordsListEdit, %ExpandWordsListEdit%
    Gui, Add, Button, xp+0 y+15 w90 h30 gSaveWordPairsNow vSaveWordPairsBTN, Save li&st
    Gui, Add, Button, x+10 yp+0 w150 h30 gRestoreExpandableWordsFile vDefaultWordPairsBTN, Restore d&efaults

    Gui, Tab, 1 ; general
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys in the OSD (mandatory for the main typing mode)
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%enableAltGr% venableAltGr, Enable {Ctrl + Alt} / {AltGr} support
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%DisableTypingMode% vDisableTypingMode, Disable main typing mode
    Gui, Add, Checkbox, y+7 Section gVerifyTypeOptions Checked%EnforceSluggishSynch% vEnforceSluggishSynch, Attempt to synchronize with sluggish host apps (for slow PCs only)
    If (showHelp=1)
       Gui, Add, Text, xp+15 y+5 w%txtWid%, It applies only for Left, Right and Delete keys. If the caret positions do not stay in synch when pressing repetitively these keys, this option can help.
    Gui, Add, Checkbox, xs+0 y+7 gVerifyTypeOptions Checked%MediateNavKeys% vMediateNavKeys, Mediate {Home} / {End} keys presses
    If (showHelp=1)
       Gui, Add, Text, xp+15 y+5 w%txtWid%, This can ensure a stricter synchronization with the host app when typing in short multi-line text fields. Key strokes will be sent to the host app that attempt to reproduce the caret location from the OSD.
    Gui, Add, Checkbox, xs+0 y+10 gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only

    If (showHelp=1)
    {
       Gui, Add, Text, xp+15 y+5 w%txtWid%, The main typing mode works by attempting to shadow the host app. KeyPress will attempt to reproduce text cursor actions to mimmick text fields.
       Gui, Add, Checkbox, xp-15 y+10 gVerifyTypeOptions Checked%alternateTypingMode% valternateTypingMode, Enable global keyboard shortcut to enter in alternate typing mode
       Gui, Add, Text, xp+15 y+5 w%txtWid%, Default shortcut: {Ctrl + CapsLock}. Type through KeyPress and send text on {Enter}. This ensures full support for dead keys and full predictability. In other words, what you see is what you typed - once you sent it to the host app. However, in Windows 7 or below, the keyboard layout of the host app might not match with the one of the OSD.
    } Else
    {
       Gui, Add, Checkbox, y+12 gVerifyTypeOptions Checked%alternateTypingMode% valternateTypingMode, Enable global keyboard shortcut to enter in alternate typing mode
       Gui, Add, Text, xp+15 y+5 w%txtWid%, Type through KeyPress OSD and send text on {Enter}. Full support for dead keys and predictable results.
    }
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%pasteOnClick% vpasteOnClick, Paste on click what you typed
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%sendKeysRealTime% vsendKeysRealTime, Send keystrokes in realtime to the host app
    Gui, Add, Text, xp+15 y+5 w%txtWid%, This does not work with all appllications.

    Gui, Tab, 3  ; behavior
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%enableTypingHistory% venableTypingHistory, Typed text history with {Page Up} / {Page Down}
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%pgUDasHE% vpgUDasHE, {Page Up} / {Page Down} should behave as {Home} / {End}
    Gui, Add, Checkbox, y+7 Section gVerifyTypeOptions Checked%UpDownAsHE% vUpDownAsHE, {Up} / {Down} arrow keys should behave as {Home} / {End}
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%UpDownAsLR% vUpDownAsLR, ... or as the {Left} / {Right} keys
    Gui, Add, Checkbox, xp-15 y+12 gVerifyTypeOptions Checked%pasteOSDcontent% vpasteOSDcontent, Enable global shortcuts to paste the OSD content into the active text area
    If (showHelp=1)
       Gui, Add, Text, xp+15 y+5 w%txtWid%, The default keyboard shortcuts are {Ctrl + Shift + Insert} and {Ctrl + Alt + Insert}.
    Gui, Add, Checkbox, xs+0 y+7 Section gVerifyTypeOptions Checked%synchronizeMode% vsynchronizeMode, Synchronize using {Shift + Up} && {Shift + Home} key sequence
    If (showHelp=1)
        Gui, Add, Text, xp+15 y+5 w%txtWid%, By default, {Ctrl + A}, select all, is used to capture the text from the host app. The default global keyboard shortcuts to synchronize are: {Winkey + Insert} and {Winkey + Alt + Insert}.
    Gui, Add, Checkbox, xs+0 y+10 gVerifyTypeOptions Checked%enterErasesLine% venterErasesLine, In "only typing" mode, {Enter} and {Escape} erase text from KeyPress

    Gui, Add, Checkbox, y+10 Section gVerifyTypeOptions Checked%alternativeJumps% valternativeJumps, Alternative rules to jump between words with {Ctrl + Bksp / Del / Left / Right}
    If (showHelp=1)
    {
        Gui, Add, Text, xp+15 y+5, Please note, applications have inconsistent rules for this.
        Gui, Add, Checkbox, y+7 w%txtWid% gVerifyTypeOptions Checked%sendJumpKeys% vsendJumpKeys, Mediate the key strokes for caret jumps
        Gui, Add, Text, y+5 w%txtWid%, This ensure higher predictability and chances of staying in synch. Key strokes that attempt to reproduce the actions you see in the OSD will be sent to the host app.
    } Else Gui, Add, Checkbox, xp+15 y+7 w350 gVerifyTypeOptions Checked%sendJumpKeys% vsendJumpKeys, Mediate the key strokes for caret jumps

    Gui, Add, Text, xs+0 y+12, Display time when typing (in seconds)
    Gui, Add, Edit, x+15 w60 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyTypeOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Text, xs+0 y+7, Time to resume typing with text related keys (in sec.)
    Gui, Add, Edit, x+15 w60 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %ReturnToTypingUser%
    Gui, Add, UpDown, vReturnToTypingUser gVerifyTypeOptions Range2-99, %ReturnToTypingUser%

    Gui, Tab, 2 ; dead keys
    Gui, Add, Checkbox, x+15 y+15 section gVerifyTypeOptions Checked%ShowDeadKeys% vShowDeadKeys, Insert generic dead key symbol when using such a key and typing
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%AltHook2keysUser% vAltHook2keysUser, Alternative hook to keys (applies to the main typing mode)
    If (showHelp=1)
    {
        Gui, Add, Text, xp+15 y+5 w%txtWid%, This enables full support for dead keys. However, please note that some applications can interfere with this, e.g., Wox launcher.
        Gui, Font, Bold
        Gui, Add, Text, xp-15 y+10, Troubleshooting:
        Gui, Font, Normal
        Gui, Add, Text, xp+15 y+5 w%txtWid%, If you cannot use dead keys on supported layouts in host apps, Increase the multiplier progressively until dead keys work. Apply settings and then test dead keys in the host app. If you cannot identify the right delay, activate "Do not bind".
        Gui, Add, Text, xp-15 y+10, Typing delays scale (1 = no delays)
    } Else
    {
        Gui, Font, Bold
        Gui, Add, Text, y+10 w%txtWid%, If dead keys do not work, change these options:
        Gui, Font, Normal
        Gui, Add, Text, y+10, Typing delays scale (1 = no delays)
    }
    Gui, Add, Edit, x+15 w60 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %typingDelaysScaleUser%
    Gui, Add, UpDown, vtypingDelaysScaleUser gVerifyTypeOptions Range1-40, %typingDelaysScaleUser%
    Gui, Add, Checkbox, xs+0 y+12 gVerifyTypeOptions Checked%DoNotBindDeadKeys% vDoNotBindDeadKeys, Do not bind (ignore) known dead keys
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%DoNotBindAltGrDeadKeys% vDoNotBindAltGrDeadKeys, Ignore dead keys associated with AltGr as well

    Gui, Font, Bold
    Gui, Add, Text, xp-15 y+15, Keyboard layout status: %deadKstatus%
    Gui, Add, Text, y+8 w%txtWid%, %CurrentKBD%.
    If (loadedLangz!=1) && (AutoDetectKBD=1)
       Gui, Add, Text, y+9 w%txtWid%, WARNING: Language definitions file is missing. Support for dead keys is limited.
    If !isKeystrokesFile ; keypress-keystrokes-helper.ahk
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Some option(s) are disabled because files are missing.
    If (AutoDetectKBD=0)
    {
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Automatic keyboard layout detection is deactivated. For dead keys support, please enable it.
       Gui, Add, Checkbox, xp+15 y+8 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    }
    Gui, Font, Normal
    Gui, Tab
    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+5 yp+0 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Add, Checkbox, x+10 yp+0 gTypeOptionsShowHelp Checked%showHelp% vShowHelp, Show contextual help
    Gui, Show, AutoSize, Typing mode settings: KeyPress OSD
    verifySettingsWindowSize()
    If !reopen
       VerifyTypeOptions(0)
}

verifySettingsWindowSize() {
    If (prefsLargeFonts=0) || (A_TickCount-doNotRepeatTimer<40000)
       Return
    GuiGetSize(Wid, Heig, 5)
    SysGet, SM_CXMAXIMIZED, 61
    SysGet, SM_CYMAXIMIZED, 62
    If (Heig>SM_CYMAXIMIZED-75) || (Wid>SM_CXMAXIMIZED-50)
    {
       Global doNotRepeatTimer := A_TickCount
       SoundBeep, 300, 900
       MsgBox, 4,, The option "Large UI fonts" is enabled. The window seems to exceed your screen resolution. `nDo you want to disable Large UI fonts?
       IfMsgBox, Yes
       {
           ToggleLargeFonts()
           SwitchPreferences(1)
       }
    }
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

SwitchPreferences(forceReopenSame:=0) {
    testPrefWind := (forceReopenSame=1) ? "lol" : CurrentPrefWindow
    GuiControlGet, CurrentPrefWindow
    If (testPrefWind=CurrentPrefWindow)
       Return

    If (NOahkH=1) && (CurrentPrefWindow=4) || (NOahkH=1) && (CurrentPrefWindow=3)
    {
      ShowLongMsg("ERROR: AHK_L detected. Features unavailable.")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    If ((!isBeeperzFile || missingAudios=1 || NOahkH=1) && CurrentPrefWindow=3) || ((!isMouseFile || NOahkH=1) && CurrentPrefWindow=4) ; keypress-beeperz-functions.ahk / keypress-mouse-functions.ahk
    {
      ShowLongMsg("ERROR: Missing files...")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    GuiControlGet, ApplySettingsBTN, Enabled
    Gui, Submit
    Global showHelp := 0
    Global reopen := 1
    Gui, SettingsGUIA: Destroy
    Sleep, 25
    SettingsGUI()
    CheckSettings()
    If (CurrentPrefWindow=1)
    {
       ShowKBDsettings()
       VerifyKeybdOptions(ApplySettingsBTN)
    } Else If (CurrentPrefWindow=2)
    {
       ShowTypeSettings()
       VerifyTypeOptions(ApplySettingsBTN)    
    } Else If (CurrentPrefWindow=3)
    {
       ShowSoundsSettings()
       VerifySoundsOptions(ApplySettingsBTN)    
    } Else If (CurrentPrefWindow=4)
    {
       ShowMouseSettings()
       VerifyMouseOptions(ApplySettingsBTN)    
    } Else If (CurrentPrefWindow=5)
    {
       ShowOSDsettings()
       VerifyOsdOptions(ApplySettingsBTN)    
    } Else If (CurrentPrefWindow=6)
    {
       ShowShortCutsSettings()
       VerifyShortcutOptions(ApplySettingsBTN)    
    }
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
    GuiControlGet, expandWords

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (ShowSingleKey=0)
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
       GuiControl, Disable, EnforceSluggishSynch
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
       GuiControl, Disable, ExpandWordsListEdit
       GuiControl, Disable, expandWords
       GuiControl, Disable, SaveWordPairsBTN
       GuiControl, Disable, DefaultWordPairsBTN
    } Else
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
       GuiControl, Enable, EnforceSluggishSynch
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
       GuiControl, Enable, ExpandWordsListEdit
       GuiControl, Enable, expandWords
       GuiControl, Enable, DefaultWordPairsBTN
    }
  
    If (DisableTypingMode=1)
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
       GuiControl, Disable, EnforceSluggishSynch
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
       GuiControl, Disable, ExpandWordsListEdit
       GuiControl, Disable, expandWords
       GuiControl, Disable, SaveWordPairsBTN
       GuiControl, Disable, DefaultWordPairsBTN
    } Else If (ShowSingleKey!=0)
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
       GuiControl, Enable, EnforceSluggishSynch
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
       GuiControl, Enable, expandWords
       GuiControl, Enable, ExpandWordsListEdit
       GuiControl, Enable, DefaultWordPairsBTN
    }

    If (OnlyTypingMode=0)
       GuiControl, Disable, enterErasesLine
    
    If (DoNotBindDeadKeys=1)
          GuiControl, Disable, ShowDeadKeys
    Else If (DisableTypingMode=0) && (ShowSingleKey!=0)
          GuiControl, Enable, ShowDeadKeys

    If (AltHook2keysUser=1)
       GuiControl, Disable, ShowDeadKeys

    GuiControl, % (DoNotBindDeadKeys=1 ? "Enable" : "Disable"), DoNotBindAltGrDeadKeys
    If (UpDownAsHE=1)
       GuiControl, , UpDownAsLR, 0

    If (UpDownAsLR=1)
       GuiControl, , UpDownAsHE, 0

    If (enableTypingHistory=1)
       GuiControl, Disable, pgUDasHE

    If (alternateTypingMode=0)
    {
       GuiControl, Disable, pasteOnClick
       GuiControl, Disable, sendKeysRealTime
    } Else
    {
       GuiControl, Enable, pasteOnClick
       GuiControl, Enable, sendKeysRealTime     
    }

    If (enterErasesLine=0 && OnlyTypingMode=1)
    {
       GuiControl, Disable, sendJumpKeys
       GuiControl, Disable, MediateNavKeys
       GuiControl, Disable, enableTypingHistory
       GuiControl, Enable, pgUDasHE
    }

    If (!isKeystrokesFile || NOahkH=1) ; keypress-keystrokes-helper.ahk
    {
       GuiControl, Disable, AltHook2keysUser
       GuiControl, , AltHook2keysUser, 0
       GuiControl, Enable, ShowDeadKeys
    }

   If (expandWords=0)
   {
      GuiControl, Disable, SaveWordPairsBTN
      GuiControl, Disable, DefaultWordPairsBTN
      GuiControl, Disable, ExpandWordsListEdit
   }
   If (enableApply=0)
      GuiControl, Disable, SaveWordPairsBTN

}

ShowShortCutsSettings() {
    Global
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }

    ComboList := "(Disabled)|(Restore Default)|[[ 0-9 / Digits ]]|[[ Letters ]]|Right|Left|Up|Down|Home|End|Page_Down|Page_Up|Backspace|Space|Tab|Delete|Enter|Escape|Insert|CapsLock|NumLock|ScrollLock|L_Click|M_Click|R_Click|PrintScreen|Pause|Break|CtrlBreak|AppsKey|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Nav_Back|Nav_Favorites|Nav_Forward|Nav_Home|Nav_Refresh|Nav_Search|Nav_Stop|Help|Launch_App1|Launch_App2|Launch_Mail|Launch_Media|Media_Next|Media_Play_Pause|Media_Prev|Media_Stop|Pad0|Pad1|Pad2|Pad3|Pad4|Pad5|Pad6|Pad7|Pad8|Pad9|PadClear|PadDel|PadDiv|PadDot|PadHome|PadEnd|PadEnter|PadIns|PadLeft|PadRight|PadAdd|PadSub|PadMult|PadPage_Down|PadPage_Up|PadUp|PadDown|Sleep|Volume_Mute|Volume_Up|Volume_Down|WheelUp|WheelDown|WheelLeft|WheelRight|[[ VK nnn ]]|[[ SC nnn ]]"
    CurrentPrefWindow := 6
    CBchoKBDaltTypeMode := ProcessChoiceKBD(KBDaltTypeMode)
    CBchoKBDpasteOSDcnt1 := ProcessChoiceKBD(KBDpasteOSDcnt1)
    CBchoKBDpasteOSDcnt2 := ProcessChoiceKBD(KBDpasteOSDcnt2)
    CBchoKBDsynchApp1 := ProcessChoiceKBD(KBDsynchApp1)
    CBchoKBDsynchApp2 := ProcessChoiceKBD(KBDsynchApp2)
    CBchoKBDTglNeverOSD := ProcessChoiceKBD(KBDTglNeverOSD)
    CBchoKBDTglPosition := ProcessChoiceKBD(KBDTglPosition)
    CBchoKBDTglSilence := ProcessChoiceKBD(KBDTglSilence)
    CBchoKBDidLangNow := ProcessChoiceKBD(KBDidLangNow)
    CBchoKBDCapText := ProcessChoiceKBD(KBDCapText)
    CBchoKBDReload := ProcessChoiceKBD(KBDReload)
    CBchoKBDsuspend := ProcessChoiceKBD(KBDsuspend)
    CBchoKBDclippyMenu := ProcessChoiceKBD(KBDclippyMenu)

    CtrlKBDaltTypeMode := InStr(KBDaltTypeMode, "^")
    ShiftKBDaltTypeMode := InStr(KBDaltTypeMode, "+")
    AltKBDaltTypeMode := InStr(KBDaltTypeMode, "!")
    WinKBDaltTypeMode := InStr(KBDaltTypeMode, "#")
    CtrlKBDpasteOSDcnt1 := InStr(KBDpasteOSDcnt1, "^")
    ShiftKBDpasteOSDcnt1 := InStr(KBDpasteOSDcnt1, "+")
    AltKBDpasteOSDcnt1 := InStr(KBDpasteOSDcnt1, "!")
    WinKBDpasteOSDcnt1 := InStr(KBDpasteOSDcnt1, "#")
    CtrlKBDpasteOSDcnt2 := InStr(KBDpasteOSDcnt2, "^")
    ShiftKBDpasteOSDcnt2 := InStr(KBDpasteOSDcnt2, "+")
    AltKBDpasteOSDcnt2 := InStr(KBDpasteOSDcnt2, "!")
    WinKBDpasteOSDcnt2 := InStr(KBDpasteOSDcnt2, "#")
    CtrlKBDsynchApp1 := InStr(KBDsynchApp1, "^")
    ShiftKBDsynchApp1 := InStr(KBDsynchApp1, "+")
    AltKBDsynchApp1 := InStr(KBDsynchApp1, "!")
    WinKBDsynchApp1 := InStr(KBDsynchApp1, "#")
    CtrlKBDsynchApp2 := InStr(KBDsynchApp2, "^")
    ShiftKBDsynchApp2 := InStr(KBDsynchApp2, "+")
    AltKBDsynchApp2 := InStr(KBDsynchApp2, "!")
    WinKBDsynchApp2 := InStr(KBDsynchApp2, "#")
    CtrlKBDTglNeverOSD := InStr(KBDTglNeverOSD, "^")
    ShiftKBDTglNeverOSD := InStr(KBDTglNeverOSD, "+")
    AltKBDTglNeverOSD := InStr(KBDTglNeverOSD, "!")
    WinKBDTglNeverOSD := InStr(KBDTglNeverOSD, "#")
    CtrlKBDTglPosition := InStr(KBDTglPosition, "^")
    ShiftKBDTglPosition := InStr(KBDTglPosition, "+")
    AltKBDTglPosition := InStr(KBDTglPosition, "!")
    WinKBDTglPosition := InStr(KBDTglPosition, "#")
    CtrlKBDTglSilence := InStr(KBDTglSilence, "^")
    ShiftKBDTglSilence := InStr(KBDTglSilence, "+")
    AltKBDTglSilence := InStr(KBDTglSilence, "!")
    WinKBDTglSilence := InStr(KBDTglSilence, "#")
    CtrlKBDidLangNow := InStr(KBDidLangNow, "^")
    ShiftKBDidLangNow := InStr(KBDidLangNow, "+")
    AltKBDidLangNow := InStr(KBDidLangNow, "!")
    WinKBDidLangNow := InStr(KBDidLangNow, "#")
    CtrlKBDCapText := InStr(KBDCapText, "^")
    ShiftKBDCapText := InStr(KBDCapText, "+")
    AltKBDCapText := InStr(KBDCapText, "!")
    WinKBDCapText := InStr(KBDCapText, "#")
    CtrlKBDReload := InStr(KBDReload, "^")
    ShiftKBDReload := InStr(KBDReload, "+")
    AltKBDReload := InStr(KBDReload, "!")
    WinKBDReload := InStr(KBDReload, "#")
    CtrlKBDsuspend := InStr(KBDsuspend, "^")
    ShiftKBDsuspend := InStr(KBDsuspend, "+")
    AltKBDsuspend := InStr(KBDsuspend, "!")
    WinKBDsuspend := InStr(KBDsuspend, "#")
    CtrlKBDclippyMenu := InStr(KBDclippyMenu, "^")
    ShiftKBDclippyMenu := InStr(KBDclippyMenu, "+")
    AltKBDclippyMenu := InStr(KBDclippyMenu, "!")
    WinKBDclippyMenu := InStr(KBDclippyMenu, "#")

    col1width := 290
    col2width := 90
    modBtnWidth := 32
    If (prefsLargeFonts=1)
    {
       modBtnWidth := 45
       col1width := 430
       col2width := 140
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Text, x15 y15 Section, All the shortcuts listed in this panel are available globally, in any application.

    Gui, Add, Checkbox, xs+0 y+10 w%col1width% gVerifyShortcutOptions Checked%alternateTypingMode% valternateTypingMode, Enter alternate typing mode
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDaltTypeMode, %ComboList%|%CBchoKBDaltTypeMode%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDaltTypeMode% gGenerateHotkeyStrS vCtrlKBDaltTypeMode, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDaltTypeMode% gGenerateHotkeyStrS vShiftKBDaltTypeMode, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDaltTypeMode% gGenerateHotkeyStrS vAltKBDaltTypeMode, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDaltTypeMode% gGenerateHotkeyStrS vWinKBDaltTypeMode, Win

    Gui, Add, Checkbox, xs+0 y+1 w%col1width% gVerifyShortcutOptions Checked%enableClipManager% venableClipManager, Invoke the Clipboard History menu
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDclippyMenu, %ComboList%|%CBchoKBDclippyMenu%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDclippyMenu% gGenerateHotkeyStrS vCtrlKBDclippyMenu, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDclippyMenu% gGenerateHotkeyStrS vShiftKBDclippyMenu, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDclippyMenu% gGenerateHotkeyStrS vAltKBDclippyMenu, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDclippyMenu% gGenerateHotkeyStrS vWinKBDclippyMenu, Win

    Gui, Add, Checkbox, xs+0 y+1 w%col1width% gVerifyShortcutOptions Checked%pasteOSDcontent% vpasteOSDcontent, Paste the OSD content in the active text area
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDpasteOSDcnt1, %ComboList%|%CBchoKBDpasteOSDcnt1%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDpasteOSDcnt1% gGenerateHotkeyStrS vCtrlKBDpasteOSDcnt1, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDpasteOSDcnt1% gGenerateHotkeyStrS vShiftKBDpasteOSDcnt1, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDpasteOSDcnt1% gGenerateHotkeyStrS vAltKBDpasteOSDcnt1, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDpasteOSDcnt1% gGenerateHotkeyStrS vWinKBDpasteOSDcnt1, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, %A_Space%Replace entire text from the active text area with the OSD content
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDpasteOSDcnt2, %ComboList%|%CBchoKBDpasteOSDcnt2%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDpasteOSDcnt2% gGenerateHotkeyStrS vCtrlKBDpasteOSDcnt2, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDpasteOSDcnt2% gGenerateHotkeyStrS vShiftKBDpasteOSDcnt2, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDpasteOSDcnt2% gGenerateHotkeyStrS vAltKBDpasteOSDcnt2, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDpasteOSDcnt2% gGenerateHotkeyStrS vWinKBDpasteOSDcnt2, Win

    Gui, Add, Checkbox, xs+0 y+25 w%col1width% gVerifyShortcutOptions Checked%KeyboardShortcuts% vKeyboardShortcuts, Other global keyboard shortcuts
    Gui, Add, Text, xs+0 y+10 w%col1width%, Capture text from active text area (preferred choice)
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDsynchApp1, %ComboList%|%CBchoKBDsynchApp1%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDsynchApp1% gGenerateHotkeyStrS vCtrlKBDsynchApp1, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDsynchApp1% gGenerateHotkeyStrS vShiftKBDsynchApp1, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDsynchApp1% gGenerateHotkeyStrS vAltKBDsynchApp1, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDsynchApp1% gGenerateHotkeyStrS vWinKBDsynchApp1, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Capture text from active text area [only the current line]
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDsynchApp2, %ComboList%|%CBchoKBDsynchApp2%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDsynchApp2% gGenerateHotkeyStrS vCtrlKBDsynchApp2, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDsynchApp2% gGenerateHotkeyStrS vShiftKBDsynchApp2, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDsynchApp2% gGenerateHotkeyStrS vAltKBDsynchApp2, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDsynchApp2% gGenerateHotkeyStrS vWinKBDsynchApp2, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle never display OSD
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDTglNeverOSD, %ComboList%|%CBchoKBDTglNeverOSD%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDTglNeverOSD% gGenerateHotkeyStrS vCtrlKBDTglNeverOSD, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDTglNeverOSD% gGenerateHotkeyStrS vShiftKBDTglNeverOSD, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDTglNeverOSD% gGenerateHotkeyStrS vAltKBDTglNeverOSD, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDTglNeverOSD% gGenerateHotkeyStrS vWinKBDTglNeverOSD, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle OSD positions (A / B)
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDTglPosition, %ComboList%|%CBchoKBDTglPosition%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDTglPosition% gGenerateHotkeyStrS vCtrlKBDTglPosition, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDTglPosition% gGenerateHotkeyStrS vShiftKBDTglPosition, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDTglPosition% gGenerateHotkeyStrS vAltKBDTglPosition, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDTglPosition% gGenerateHotkeyStrS vWinKBDTglPosition, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle silent mode
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDTglSilence, %ComboList%|%CBchoKBDTglSilence%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDTglSilence% gGenerateHotkeyStrS vCtrlKBDTglSilence, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDTglSilence% gGenerateHotkeyStrS vShiftKBDTglSilence, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDTglSilence% gGenerateHotkeyStrS vAltKBDTglSilence, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDTglSilence% gGenerateHotkeyStrS vWinKBDTglSilence, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Detect keyboard layout
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDidLangNow, %ComboList%|%CBchoKBDidLangNow%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDidLangNow% gGenerateHotkeyStrS vCtrlKBDidLangNow, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDidLangNow% gGenerateHotkeyStrS vShiftKBDidLangNow, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDidLangNow% gGenerateHotkeyStrS vAltKBDidLangNow, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDidLangNow% gGenerateHotkeyStrS vWinKBDidLangNow, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Capture text underneath the mouse
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDCapText, %ComboList%|%CBchoKBDCapText%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDCapText% gGenerateHotkeyStrS vCtrlKBDCapText, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDCapText% gGenerateHotkeyStrS vShiftKBDCapText, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDCapText% gGenerateHotkeyStrS vAltKBDCapText, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDCapText% gGenerateHotkeyStrS vWinKBDCapText, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Restart / reload KeyPress OSD
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDReload, %ComboList%|%CBchoKBDReload%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDReload% gGenerateHotkeyStrS vCtrlKBDReload, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDReload% gGenerateHotkeyStrS vShiftKBDReload, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDReload% gGenerateHotkeyStrS vAltKBDReload, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDReload% gGenerateHotkeyStrS vWinKBDReload, Win

    Gui, Add, Text, xs+0 y+1 w%col1width%, Suspend / deactivate KeyPress OSD
    Gui, Add, ComboBox, x+0 w%col2width% gProcessComboKBD vComboKBDsuspend, %ComboList%|%CBchoKBDsuspend%||
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%CtrlKBDsuspend% gGenerateHotkeyStrS vCtrlKBDsuspend, Ctrl
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%ShiftKBDsuspend% gGenerateHotkeyStrS vShiftKBDsuspend, Shift
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%AltKBDsuspend% gGenerateHotkeyStrS vAltKBDsuspend, Alt
    Gui, Add, Checkbox, x+0 +0x1000 w%modBtnWidth% hp Checked%WinKBDsuspend% gGenerateHotkeyStrS vWinKBDsuspend, Win

    Gui, Add, Button, xs+0 y+15 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 wp hp gCloseSettings vCancelBTN, C&ancel
    Gui, Add, DropDownList, x+5 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Global shortcuts: KeyPress OSD
    GenerateHotkeyStrS()
    verifySettingsWindowSize()
    VerifyShortcutOptions(0)
}

GenerateHotkeyStrS() {
  GuiControlGet, ComboKBDaltTypeMode
  GuiControlGet, ComboKBDpasteOSDcnt1
  GuiControlGet, ComboKBDpasteOSDcnt2
  GuiControlGet, ComboKBDsynchApp1
  GuiControlGet, ComboKBDsynchApp2
  GuiControlGet, ComboKBDTglNeverOSD
  GuiControlGet, ComboKBDTglPosition
  GuiControlGet, ComboKBDTglSilence
  GuiControlGet, ComboKBDidLangNow
  GuiControlGet, ComboKBDCapText
  GuiControlGet, ComboKBDReload
  GuiControlGet, ComboKBDsuspend
  GuiControlGet, ComboKBDclippyMenu

  GuiControlGet, CtrlKBDaltTypeMode
  GuiControlGet, ShiftKBDaltTypeMode
  GuiControlGet, AltKBDaltTypeMode
  GuiControlGet, WinKBDaltTypeMode
  GuiControlGet, CtrlKBDpasteOSDcnt1
  GuiControlGet, ShiftKBDpasteOSDcnt1
  GuiControlGet, AltKBDpasteOSDcnt1
  GuiControlGet, WinKBDpasteOSDcnt1
  GuiControlGet, CtrlKBDpasteOSDcnt2
  GuiControlGet, ShiftKBDpasteOSDcnt2
  GuiControlGet, AltKBDpasteOSDcnt2
  GuiControlGet, WinKBDpasteOSDcnt2
  GuiControlGet, CtrlKBDsynchApp1
  GuiControlGet, ShiftKBDsynchApp1
  GuiControlGet, AltKBDsynchApp1
  GuiControlGet, WinKBDsynchApp1
  GuiControlGet, CtrlKBDsynchApp2
  GuiControlGet, ShiftKBDsynchApp2
  GuiControlGet, AltKBDsynchApp2
  GuiControlGet, WinKBDsynchApp2
  GuiControlGet, CtrlKBDTglNeverOSD
  GuiControlGet, ShiftKBDTglNeverOSD
  GuiControlGet, AltKBDTglNeverOSD
  GuiControlGet, WinKBDTglNeverOSD
  GuiControlGet, CtrlKBDTglPosition
  GuiControlGet, ShiftKBDTglPosition
  GuiControlGet, AltKBDTglPosition
  GuiControlGet, WinKBDTglPosition
  GuiControlGet, CtrlKBDTglSilence
  GuiControlGet, ShiftKBDTglSilence
  GuiControlGet, AltKBDTglSilence
  GuiControlGet, WinKBDTglSilence
  GuiControlGet, CtrlKBDidLangNow
  GuiControlGet, ShiftKBDidLangNow
  GuiControlGet, AltKBDidLangNow
  GuiControlGet, WinKBDidLangNow
  GuiControlGet, CtrlKBDCapText
  GuiControlGet, ShiftKBDCapText
  GuiControlGet, AltKBDCapText
  GuiControlGet, WinKBDCapText
  GuiControlGet, CtrlKBDReload
  GuiControlGet, ShiftKBDReload
  GuiControlGet, AltKBDReload
  GuiControlGet, WinKBDReload
  GuiControlGet, CtrlKBDsuspend
  GuiControlGet, ShiftKBDsuspend
  GuiControlGet, AltKBDsuspend
  GuiControlGet, WinKBDsuspend
  GuiControlGet, CtrlKBDclippyMenu
  GuiControlGet, ShiftKBDclippyMenu
  GuiControlGet, AltKBDclippyMenu
  GuiControlGet, WinKBDclippyMenu
  GuiControlGet, ApplySettingsBTN

  KBDaltTypeMode := ""
  KBDpasteOSDcnt1 := ""
  KBDpasteOSDcnt2 := ""
  KBDsynchApp1 := ""
  KBDsynchApp2 := ""
  KBDTglNeverOSD := ""
  KBDTglPosition := ""
  KBDTglSilence := ""
  KBDidLangNow := ""
  KBDCapText := ""
  KBDReload := ""
  KBDsuspend := ""
  KBDclippyMenu := ""
  KBDaltTypeMode .= CtrlKBDaltTypeMode=1 ? "^" : ""
  KBDaltTypeMode .= ShiftKBDaltTypeMode=1 ? "+" : ""
  KBDaltTypeMode .= AltKBDaltTypeMode=1 ? "!" : ""
  KBDaltTypeMode .= WinKBDaltTypeMode=1 ? "#" : ""
  KBDpasteOSDcnt1 .= CtrlKBDpasteOSDcnt1=1 ? "^" : ""
  KBDpasteOSDcnt1 .= ShiftKBDpasteOSDcnt1=1 ? "+" : ""
  KBDpasteOSDcnt1 .= AltKBDpasteOSDcnt1=1 ? "!" : ""
  KBDpasteOSDcnt1 .= WinKBDpasteOSDcnt1=1 ? "#" : ""
  KBDpasteOSDcnt2 .= CtrlKBDpasteOSDcnt2=1 ? "^" : ""
  KBDpasteOSDcnt2 .= ShiftKBDpasteOSDcnt2=1 ? "+" : ""
  KBDpasteOSDcnt2 .= AltKBDpasteOSDcnt2=1 ? "!" : ""
  KBDpasteOSDcnt2 .= WinKBDpasteOSDcnt2=1 ? "#" : ""
  KBDsynchApp1 .= CtrlKBDsynchApp1=1 ? "^" : ""
  KBDsynchApp1 .= ShiftKBDsynchApp1=1 ? "+" : ""
  KBDsynchApp1 .= AltKBDsynchApp1=1 ? "!" : ""
  KBDsynchApp1 .= WinKBDsynchApp1=1 ? "#" : ""
  KBDsynchApp2 .= CtrlKBDsynchApp2=1 ? "^" : ""
  KBDsynchApp2 .= ShiftKBDsynchApp2=1 ? "+" : ""
  KBDsynchApp2 .= AltKBDsynchApp2=1 ? "!" : ""
  KBDsynchApp2 .= WinKBDsynchApp2=1 ? "#" : ""
  KBDTglNeverOSD .= CtrlKBDTglNeverOSD=1 ? "^" : ""
  KBDTglNeverOSD .= ShiftKBDTglNeverOSD=1 ? "+" : ""
  KBDTglNeverOSD .= AltKBDTglNeverOSD=1 ? "!" : ""
  KBDTglNeverOSD .= WinKBDTglNeverOSD=1 ? "#" : ""
  KBDTglPosition .= CtrlKBDTglPosition=1 ? "^" : ""
  KBDTglPosition .= ShiftKBDTglPosition=1 ? "+" : ""
  KBDTglPosition .= AltKBDTglPosition=1 ? "!" : ""
  KBDTglPosition .= WinKBDTglPosition=1 ? "#" : ""
  KBDTglSilence .= CtrlKBDTglSilence=1 ? "^" : ""
  KBDTglSilence .= ShiftKBDTglSilence=1 ? "+" : ""
  KBDTglSilence .= AltKBDTglSilence=1 ? "!" : ""
  KBDTglSilence .= WinKBDTglSilence=1 ? "#" : ""
  KBDidLangNow .= CtrlKBDidLangNow=1 ? "^" : ""
  KBDidLangNow .= ShiftKBDidLangNow=1 ? "+" : ""
  KBDidLangNow .= AltKBDidLangNow=1 ? "!" : ""
  KBDidLangNow .= WinKBDidLangNow=1 ? "#" : ""
  KBDCapText .= CtrlKBDCapText=1 ? "^" : ""
  KBDCapText .= ShiftKBDCapText=1 ? "+" : ""
  KBDCapText .= AltKBDCapText=1 ? "!" : ""
  KBDCapText .= WinKBDCapText=1 ? "#" : ""
  KBDReload .= CtrlKBDReload=1 ? "^" : ""
  KBDReload .= ShiftKBDReload=1 ? "+" : ""
  KBDReload .= AltKBDReload=1 ? "!" : ""
  KBDReload .= WinKBDReload=1 ? "#" : ""
  KBDsuspend .= CtrlKBDsuspend=1 ? "^" : ""
  KBDsuspend .= ShiftKBDsuspend=1 ? "+" : ""
  KBDsuspend .= AltKBDsuspend=1 ? "!" : ""
  KBDsuspend .= WinKBDsuspend=1 ? "#" : ""
  KBDclippyMenu .= CtrlKBDclippyMenu=1 ? "^" : ""
  KBDclippyMenu .= ShiftKBDclippyMenu=1 ? "+" : ""
  KBDclippyMenu .= AltKBDclippyMenu=1 ? "!" : ""
  KBDclippyMenu .= WinKBDclippyMenu=1 ? "#" : ""

  KBDaltTypeMode .= ProcessChoiceKBD2(ComboKBDaltTypeMode)
  KBDpasteOSDcnt1 .= ProcessChoiceKBD2(ComboKBDpasteOSDcnt1)
  KBDpasteOSDcnt2 .= ProcessChoiceKBD2(ComboKBDpasteOSDcnt2)
  KBDsynchApp1 .= ProcessChoiceKBD2(ComboKBDsynchApp1)
  KBDsynchApp2 .= ProcessChoiceKBD2(ComboKBDsynchApp2)
  KBDTglNeverOSD .= ProcessChoiceKBD2(ComboKBDTglNeverOSD)
  KBDTglPosition .= ProcessChoiceKBD2(ComboKBDTglPosition)
  KBDTglSilence .= ProcessChoiceKBD2(ComboKBDTglSilence)
  KBDidLangNow .= ProcessChoiceKBD2(ComboKBDidLangNow)
  KBDCapText .= ProcessChoiceKBD2(ComboKBDCapText)
  KBDReload .= ProcessChoiceKBD2(ComboKBDReload)
  KBDsuspend .= ProcessChoiceKBD2(ComboKBDsuspend)
  KBDclippyMenu .= ProcessChoiceKBD2(ComboKBDclippyMenu)

  If InStr(ComboKBDaltTypeMode, "disable")
     KBDaltTypeMode := "(Disabled)"
  If InStr(ComboKBDpasteOSDcnt1, "disable")
     KBDpasteOSDcnt1 := "(Disabled)"
  If InStr(ComboKBDpasteOSDcnt2, "disable")
     KBDpasteOSDcnt2 := "(Disabled)"
  If InStr(ComboKBDsynchApp1, "disable")
     KBDsynchApp1 := "(Disabled)"
  If InStr(ComboKBDsynchApp2, "disable")
     KBDsynchApp2 := "(Disabled)"
  If InStr(ComboKBDTglNeverOSD, "disable")
     KBDTglNeverOSD := "(Disabled)"
  If InStr(ComboKBDTglPosition, "disable")
     KBDTglPosition := "(Disabled)"
  If InStr(ComboKBDTglSilence, "disable")
     KBDTglSilence := "(Disabled)"
  If InStr(ComboKBDidLangNow, "disable")
     KBDidLangNow := "(Disabled)"
  If InStr(ComboKBDCapText, "disable")
     KBDCapText := "(Disabled)"
  If InStr(ComboKBDReload, "disable")
     KBDReload := "(Disabled)"
  If InStr(ComboKBDsuspend, "disable")
     KBDsuspend := "(Disabled)"
  If InStr(ComboKBDclippyMenu, "disable")
     KBDclippyMenu := "(Disabled)"

  If InStr(ComboKBDaltTypeMode, "restore")
     KBDaltTypeMode := "(Restore Default)"
  If InStr(ComboKBDpasteOSDcnt1, "restore")
     KBDpasteOSDcnt1 := "(Restore Default)"
  If InStr(ComboKBDpasteOSDcnt2, "restore")
     KBDpasteOSDcnt2 := "(Restore Default)"
  If InStr(ComboKBDsynchApp1, "restore")
     KBDsynchApp1 := "(Restore Default)"
  If InStr(ComboKBDsynchApp2, "restore")
     KBDsynchApp2 := "(Restore Default)"
  If InStr(ComboKBDTglNeverOSD, "restore")
     KBDTglNeverOSD := "(Restore Default)"
  If InStr(ComboKBDTglPosition, "restore")
     KBDTglPosition := "(Restore Default)"
  If InStr(ComboKBDTglSilence, "restore")
     KBDTglSilence := "(Restore Default)"
  If InStr(ComboKBDidLangNow, "restore")
     KBDidLangNow := "(Restore Default)"
  If InStr(ComboKBDCapText, "restore")
     KBDCapText := "(Restore Default)"
  If InStr(ComboKBDReload, "restore")
     KBDReload := "(Restore Default)"
  If InStr(ComboKBDsuspend, "restore")
     KBDsuspend := "(Restore Default)"
  If InStr(ComboKBDclippyMenu, "restore")
     KBDclippyMenu := "(Restore Default)"

  KBDsTestDuplicate := KBDaltTypeMode "&" KBDpasteOSDcnt1 "&" KBDpasteOSDcnt2 "&" KBDsynchApp1 "&" KBDsynchApp2 "&" KBDTglNeverOSD "&" KBDTglPosition "&" KBDTglSilence "&" KBDidLangNow "&" KBDCapText "&" KBDReload "&" KBDsuspend "&" KBDclippyMenu
  disableds := st_count(KBDsTestDuplicate, "disable")>0 ? st_count(KBDsTestDuplicate, "disable") - 1 : 0
  restores := st_count(KBDsTestDuplicate, "restore")>0 ? st_count(KBDsTestDuplicate, "restore") - 1 : 0
  expectedNumerber := 13 - disableds - restores
  Sort, KBDsTestDuplicate, U D&
  Loop, Parse, KBDsTestDuplicate, &
      countKBDs++
  If (countKBDs<expectedNumerber)
  {
     SoundBeep
     GuiControl, Disable, ApplySettingsBTN
     GuiControl, Disable, CurrentPrefWindow
     GuiControl, Disable, CancelBTN
  } Else
  {
     GuiControl, Enable, ApplySettingsBTN
     GuiControl, Enable, CurrentPrefWindow
     GuiControl, Enable, CancelBTN
  }
}

ProcessComboKBD() {
  ComboList := "(Disabled)|(Restore Default)|[[ 0-9 / Digits ]]|[[ Letters ]]|Right|Left|Up|Down|Home|End|Page_Down|Page_Up|Backspace|Space|Tab|Delete|Enter|Escape|Insert|CapsLock|NumLock|ScrollLock|L_Click|M_Click|R_Click|PrintScreen|Pause|Break|CtrlBreak|AppsKey|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Nav_Back|Nav_Favorites|Nav_Forward|Nav_Home|Nav_Refresh|Nav_Search|Nav_Stop|Help|Launch_App1|Launch_App2|Launch_Mail|Launch_Media|Media_Next|Media_Play_Pause|Media_Prev|Media_Stop|Pad0|Pad1|Pad2|Pad3|Pad4|Pad5|Pad6|Pad7|Pad8|Pad9|PadClear|PadDel|PadDiv|PadDot|PadHome|PadEnd|PadEnter|PadIns|PadLeft|PadRight|PadAdd|PadSub|PadMult|PadPage_Down|PadPage_Up|PadUp|PadDown|Sleep|Volume_Mute|Volume_Up|Volume_Down|WheelUp|WheelDown|WheelLeft|WheelRight|[[ VK nnn ]]|[[ SC nnn ]]"
  forbiddenChars := "(\~|\!|\+|\^|\#|\$|\<|\>|\&)"

  GuiControlGet, CbEditKBDaltTypeMode,, ComboKBDaltTypeMode
  GuiControlGet, CbEditKBDpasteOSDcnt1,, ComboKBDpasteOSDcnt1
  GuiControlGet, CbEditKBDpasteOSDcnt2,, ComboKBDpasteOSDcnt2
  GuiControlGet, CbEditKBDsynchApp1,, ComboKBDsynchApp1
  GuiControlGet, CbEditKBDsynchApp2,, ComboKBDsynchApp2
  GuiControlGet, CbEditKBDTglNeverOSD,, ComboKBDTglNeverOSD
  GuiControlGet, CbEditKBDTglPosition,, ComboKBDTglPosition
  GuiControlGet, CbEditKBDTglSilence,, ComboKBDTglSilence
  GuiControlGet, CbEditKBDidLangNow,, ComboKBDidLangNow
  GuiControlGet, CbEditKBDCapText,, ComboKBDCapText
  GuiControlGet, CbEditKBDReload,, ComboKBDReload
  GuiControlGet, CbEditKBDsuspend,, ComboKBDsuspend
  GuiControlGet, CbEditKBDclippyMenu,, ComboKBDclippyMenu

  If RegExMatch(CbEditKBDaltTypeMode, forbiddenChars)
     GuiControl,, ComboKBDaltTypeMode, | %ComboList%
  If RegExMatch(CbEditKBDpasteOSDcnt1, forbiddenChars)
     GuiControl,, ComboKBDpasteOSDcnt1, | %ComboList%
  If RegExMatch(CbEditKBDpasteOSDcnt2, forbiddenChars)
     GuiControl,, ComboKBDpasteOSDcnt2, | %ComboList%
  If RegExMatch(CbEditKBDsynchApp1, forbiddenChars)
     GuiControl,, ComboKBDsynchApp1, | %ComboList%
  If RegExMatch(CbEditKBDsynchApp2, forbiddenChars)
     GuiControl,, ComboKBDsynchApp2, | %ComboList%
  If RegExMatch(CbEditKBDTglNeverOSD, forbiddenChars)
     GuiControl,, ComboKBDTglNeverOSD, | %ComboList%
  If RegExMatch(CbEditKBDTglPosition, forbiddenChars)
     GuiControl,, ComboKBDTglPosition, | %ComboList%
  If RegExMatch(CbEditKBDTglSilence, forbiddenChars)
     GuiControl,, ComboKBDTglSilence, | %ComboList%
  If RegExMatch(CbEditKBDidLangNow, forbiddenChars)
     GuiControl,, ComboKBDidLangNow, | %ComboList%
  If RegExMatch(CbEditKBDCapText, forbiddenChars)
     GuiControl,, ComboKBDCapText, | %ComboList%
  If RegExMatch(CbEditKBDReload, forbiddenChars)
     GuiControl,, ComboKBDReload, | %ComboList%
  If RegExMatch(CbEditKBDsuspend, forbiddenChars)
     GuiControl,, ComboKBDsuspend, | %ComboList%
  If RegExMatch(CbEditKBDclippyMenu, forbiddenChars)
     GuiControl,, ComboKBDclippyMenu, | %ComboList%
  GuiControl, Enable, ApplySettingsBTN
  GenerateHotkeyStrS()
}

ProcessChoiceKBD(strg) {
     StringReplace, strg, strg,~,
     StringReplace, strg, strg,!,
     StringReplace, strg, strg,+,
     StringReplace, strg, strg,^,
     StringReplace, strg, strg,#,
     StringReplace, strg, strg,$,
     StringReplace, strg, strg,<,
     StringReplace, strg, strg,>,
     StringReplace, strg, strg,&,
     If !strg
        strg := "(Disabled)"
     Return strg
}

ProcessChoiceKBD2(strg) {
     StringReplace, strg, strg,Pad,Numpad
     StringReplace, strg, strg,Page_Up,PgUp
     StringReplace, strg, strg,Page_Down,PgDn
     StringReplace, strg, strg,Nav_,Browser_
     StringReplace, strg, strg,_Click,Button
     StringReplace, strg, strg,numnumpad,Numpad
     Return strg
}

VerifyShortcutOptions(enableApply:=1) {
    GuiControlGet, alternateTypingMode
    GuiControlGet, pasteOSDcontent
    GuiControlGet, KeyboardShortcuts
    GuiControlGet, enableClipManager

    GuiControl, % (!enableApply ? "Disable" : "Enable"), ApplySettingsBTN
    If (alternateTypingMode=0)
    {
        GuiControl, Disable, ComboKBDaltTypeMode
        GuiControl, Disable, CtrlKBDaltTypeMode
        GuiControl, Disable, ShiftKBDaltTypeMode
        GuiControl, Disable, AltKBDaltTypeMode
        GuiControl, Disable, WinKBDaltTypeMode
    } Else
    {
        GuiControl, Enable, ComboKBDaltTypeMode
        GuiControl, Enable, CtrlKBDaltTypeMode
        GuiControl, Enable, ShiftKBDaltTypeMode
        GuiControl, Enable, AltKBDaltTypeMode
        GuiControl, Enable, WinKBDaltTypeMode
    }

    If (enableClipManager=0)
    {
        GuiControl, Disable, ComboKBDclippyMenu
        GuiControl, Disable, CtrlKBDclippyMenu
        GuiControl, Disable, ShiftKBDclippyMenu
        GuiControl, Disable, AltKBDclippyMenu
        GuiControl, Disable, WinKBDclippyMenu
    } Else
    {
        GuiControl, Enable, ComboKBDclippyMenu
        GuiControl, Enable, CtrlKBDclippyMenu
        GuiControl, Enable, ShiftKBDclippyMenu
        GuiControl, Enable, AltKBDclippyMenu
        GuiControl, Enable, WinKBDclippyMenu
    }

    If (pasteOSDcontent=0)
    {
        GuiControl, Disable, ComboKBDpasteOSDcnt1
        GuiControl, Disable, CtrlKBDpasteOSDcnt1
        GuiControl, Disable, ShiftKBDpasteOSDcnt1
        GuiControl, Disable, AltKBDpasteOSDcnt1
        GuiControl, Disable, WinKBDpasteOSDcnt1
        GuiControl, Disable, ComboKBDpasteOSDcnt2
        GuiControl, Disable, CtrlKBDpasteOSDcnt2
        GuiControl, Disable, ShiftKBDpasteOSDcnt2
        GuiControl, Disable, AltKBDpasteOSDcnt2
        GuiControl, Disable, WinKBDpasteOSDcnt2
    } Else
    {
        GuiControl, Enable, ComboKBDpasteOSDcnt1
        GuiControl, Enable, CtrlKBDpasteOSDcnt1
        GuiControl, Enable, ShiftKBDpasteOSDcnt1
        GuiControl, Enable, AltKBDpasteOSDcnt1
        GuiControl, Enable, WinKBDpasteOSDcnt1
        GuiControl, Enable, ComboKBDpasteOSDcnt2
        GuiControl, Enable, CtrlKBDpasteOSDcnt2
        GuiControl, Enable, ShiftKBDpasteOSDcnt2
        GuiControl, Enable, AltKBDpasteOSDcnt2
        GuiControl, Enable, WinKBDpasteOSDcnt2
    }

    If (KeyboardShortcuts=0)
    {
        GuiControl, Disable, ComboKBDsynchApp1
        GuiControl, Disable, CtrlKBDsynchApp1
        GuiControl, Disable, ShiftKBDsynchApp1
        GuiControl, Disable, AltKBDsynchApp1
        GuiControl, Disable, WinKBDsynchApp1
        GuiControl, Disable, ComboKBDsynchApp2
        GuiControl, Disable, CtrlKBDsynchApp2
        GuiControl, Disable, ShiftKBDsynchApp2
        GuiControl, Disable, AltKBDsynchApp2
        GuiControl, Disable, WinKBDsynchApp2
        GuiControl, Disable, ComboKBDTglNeverOSD
        GuiControl, Disable, CtrlKBDTglNeverOSD
        GuiControl, Disable, ShiftKBDTglNeverOSD
        GuiControl, Disable, AltKBDTglNeverOSD
        GuiControl, Disable, WinKBDTglNeverOSD
        GuiControl, Disable, ComboKBDTglPosition
        GuiControl, Disable, CtrlKBDTglPosition
        GuiControl, Disable, ShiftKBDTglPosition
        GuiControl, Disable, AltKBDTglPosition
        GuiControl, Disable, WinKBDTglPosition
        GuiControl, Disable, CtrlKBDTglSilence
        GuiControl, Disable, ComboKBDTglSilence
        GuiControl, Disable, ShiftKBDTglSilence
        GuiControl, Disable, AltKBDTglSilence
        GuiControl, Disable, WinKBDTglSilence
        GuiControl, Disable, ComboKBDidLangNow
        GuiControl, Disable, CtrlKBDidLangNow
        GuiControl, Disable, ShiftKBDidLangNow
        GuiControl, Disable, AltKBDidLangNow
        GuiControl, Disable, WinKBDidLangNow
        GuiControl, Disable, ComboKBDCapText
        GuiControl, Disable, CtrlKBDCapText
        GuiControl, Disable, ShiftKBDCapText
        GuiControl, Disable, AltKBDCapText
        GuiControl, Disable, WinKBDCapText
        GuiControl, Disable, ComboKBDReload
        GuiControl, Disable, CtrlKBDReload
        GuiControl, Disable, ShiftKBDReload
        GuiControl, Disable, AltKBDReload
        GuiControl, Disable, WinKBDReload
        GuiControl, Disable, ComboKBDsuspend
        GuiControl, Disable, CtrlKBDsuspend
        GuiControl, Disable, ShiftKBDsuspend
        GuiControl, Disable, AltKBDsuspend
        GuiControl, Disable, WinKBDsuspend
    } Else
    {
       If (DisableTypingMode=0)
       {
           GuiControl, Enable, ComboKBDsynchApp1
           GuiControl, Enable, CtrlKBDsynchApp1
           GuiControl, Enable, ShiftKBDsynchApp1
           GuiControl, Enable, AltKBDsynchApp1
           GuiControl, Enable, WinKBDsynchApp1
           GuiControl, Enable, ComboKBDsynchApp2
           GuiControl, Enable, CtrlKBDsynchApp2
           GuiControl, Enable, ShiftKBDsynchApp2
           GuiControl, Enable, AltKBDsynchApp2
           GuiControl, Enable, WinKBDsynchApp2
       }
        GuiControl, Enable, CtrlKBDTglNeverOSD
        GuiControl, Enable, ShiftKBDTglNeverOSD
        GuiControl, Enable, AltKBDTglNeverOSD
        GuiControl, Enable, WinKBDTglNeverOSD
        GuiControl, Enable, CtrlKBDTglPosition
        GuiControl, Enable, ShiftKBDTglPosition
        GuiControl, Enable, AltKBDTglPosition
        GuiControl, Enable, WinKBDTglPosition
        GuiControl, Enable, CtrlKBDTglSilence
        GuiControl, Enable, ShiftKBDTglSilence
        GuiControl, Enable, AltKBDTglSilence
        GuiControl, Enable, WinKBDTglSilence
        GuiControl, Enable, CtrlKBDidLangNow
        GuiControl, Enable, ShiftKBDidLangNow
        GuiControl, Enable, AltKBDidLangNow
        GuiControl, Enable, WinKBDidLangNow
        GuiControl, Enable, CtrlKBDCapText
        GuiControl, Enable, ShiftKBDCapText
        GuiControl, Enable, AltKBDCapText
        GuiControl, Enable, WinKBDCapText
        GuiControl, Enable, CtrlKBDReload
        GuiControl, Enable, ShiftKBDReload
        GuiControl, Enable, AltKBDReload
        GuiControl, Enable, WinKBDReload
        GuiControl, Enable, CtrlKBDsuspend
        GuiControl, Enable, ShiftKBDsuspend
        GuiControl, Enable, AltKBDsuspend
        GuiControl, Enable, WinKBDsuspend
        GuiControl, Enable, ComboKBDTglNeverOSD
        GuiControl, Enable, ComboKBDTglPosition
        GuiControl, Enable, ComboKBDTglSilence
        GuiControl, Enable, ComboKBDidLangNow
        GuiControl, Enable, ComboKBDCapText
        GuiControl, Enable, ComboKBDReload
        GuiControl, Enable, ComboKBDsuspend
    }

    If (DisableTypingMode=1)
    {
        GuiControl, Disable, ComboKBDpasteOSDcnt1
        GuiControl, Disable, CtrlKBDpasteOSDcnt1
        GuiControl, Disable, ShiftKBDpasteOSDcnt1
        GuiControl, Disable, AltKBDpasteOSDcnt1
        GuiControl, Disable, WinKBDpasteOSDcnt1
        GuiControl, Disable, ComboKBDpasteOSDcnt2
        GuiControl, Disable, CtrlKBDpasteOSDcnt2
        GuiControl, Disable, ShiftKBDpasteOSDcnt2
        GuiControl, Disable, AltKBDpasteOSDcnt2
        GuiControl, Disable, WinKBDpasteOSDcnt2
        GuiControl, Disable, ComboKBDsynchApp1
        GuiControl, Disable, CtrlKBDsynchApp1
        GuiControl, Disable, ShiftKBDsynchApp1
        GuiControl, Disable, AltKBDsynchApp1
        GuiControl, Disable, WinKBDsynchApp1
        GuiControl, Disable, ComboKBDsynchApp2
        GuiControl, Disable, CtrlKBDsynchApp2
        GuiControl, Disable, ShiftKBDsynchApp2
        GuiControl, Disable, AltKBDsynchApp2
        GuiControl, Disable, WinKBDsynchApp2
    }
}

PresetsWindow() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }

    Global ApplySettingsBTN, presetChosen, enableBeeperzPresets, MediateKeysFeatures
    enableBeeperzPresets := 0
    MediateKeysFeatures := 0

    If (prefsLargeFonts=1)
       Gui, Font, s%LargeUIfontValue%
    Gui, Add, Text, x15 y15, Choose the preset based on `nwhat you would like to use KeyPress for.
    Gui, Add, DropDownList, y+7 wp+110 gVerifyPresetOptions AltSubmit vpresetChosen, [ Presets list ] ||Screen casts / presentations|Typing mode only|Mixed mode|Only beep on key presses [anything else deactivated]|Mouse features only [anything else deactivated]
    Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%outputOSDtoToolTip% voutputOSDtoToolTip, Show the OSD as a mouse tooltip
    Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%enableBeeperzPresets% venableBeeperzPresets, Sounds on key presses
    Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%MediateKeysFeatures% vMediateKeysFeatures, Mediate navigation keys when typing `n[this helps to enforce consistency across applications]
    Gui, Add, Button, y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 w70 h30 gCloseSettings, C&ancel
    Gui, Add, Button, x+35 w150 h30 gDeleteSettings, Restore de&faults
    Gui, Show, AutoSize, Quick start presets: KeyPress OSD
    VerifyPresetOptions(0)
    verifySettingsWindowSize()
}

VerifyPresetOptions(enableApply:=1) {
    GuiControlGet, presetChosen
    GuiControlGet, enableBeeperzPresets
    GuiControlGet, MediateKeysFeatures

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (presetChosen=1)
    {
        GuiControl, Disable, enableBeeperzPresets
        GuiControl, Disable, MediateKeysFeatures
        GuiControl, Disable, outputOSDtoToolTip
    } Else
    {
        GuiControl, Enable, enableBeeperzPresets
        GuiControl, Enable, MediateKeysFeatures
    }

    If (enableApply=0)
       Return

    If (presetChosen=2)
    {
        GuiControl, Enable, enableBeeperzPresets
        GuiControl, Enable, outputOSDtoToolTip
        GuiControl, Disable, MediateKeysFeatures
        AutoDetectKBD := 1
        ClipMonitor := 0
        ConstantAutoDetect := 1
        DisableTypingMode := 1
        enableTypingHistory := 0
        FlashIdleMouse := 0
        MouseClickRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 0
        outputOSDtoToolTip := 0
        ShiftDisableCaps := 0
        ShowKeyCount = 1
        ShowKeyCountFired := 1
        ShowMouseHalo := 1
        ShowSingleKey = 1
        ShowSingleModifierKey := 1
        SilentMode := 1
        visualMouseClicks := 1
    }

    If (presetChosen=3)
    {
        GuiControl, Enable, enableBeeperzPresets
        GuiControl, Disable, outputOSDtoToolTip
        GuiControl, Enable, MediateKeysFeatures
        GuiControl, , outputOSDtoToolTip, 0
        alternateTypingMode := 1
        AutoDetectKBD := 1
        ClipMonitor := 0
        ConstantAutoDetect := 1
        DisableTypingMode := 0
        enableAltGr := 1
        enableTypingHistory := 1
        enterErasesLine := 1
        FlashIdleMouse := 0
        ImmediateAltTypeMode := 0
        MouseClickRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 1
        outputOSDtoToolTip := 0
        pasteOnClick := 1
        pasteOSDcontent := 1
        ShiftDisableCaps := 1
        ShowKeyCount = 0
        ShowKeyCountFired := 0
        ShowMouseHalo := 0
        ShowSingleKey = 1
        ShowSingleModifierKey := 0
        SilentMode := 1
        visualMouseClicks := 0
    }

    If (presetChosen=4)
    {
        GuiControl, , outputOSDtoToolTip, 0
        alternateTypingMode := 1
        AutoDetectKBD := 1
        ClipMonitor := 1
        ConstantAutoDetect := 1
        DisableTypingMode := 0
        enableAltGr := 1
        enableTypingHistory := 0
        FlashIdleMouse := 0
        ImmediateAltTypeMode := 0
        MouseClickRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 0
        outputOSDtoToolTip := 0
        pasteOnClick := 1
        pasteOSDcontent := 1
        ShiftDisableCaps := 1
        ShowKeyCount = 1
        ShowKeyCountFired := 1
        ShowMouseHalo := 0
        ShowSingleKey = 1
        ShowSingleModifierKey := 1
        SilentMode := 0
        visualMouseClicks := 0
    }

    If (presetChosen>4)
    {
        GuiControl, Disable, enableBeeperzPresets
        GuiControl, Disable, MediateKeysFeatures
        GuiControl, Disable, outputOSDtoToolTip
        ClipMonitor := 0
        ShiftDisableCaps := 0
        DisableTypingMode := 1
        NeverDisplayOSD := 1
        outputOSDtoToolTip := 0
        ConstantAutoDetect := 0
        AutoDetectKBD := 0
    }

    If (enableBeeperzPresets=1)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        deadKeyBeeper := 1
        KeyBeeper := 1
        MouseBeeper := 0
        ModBeeper := 1
        beepFiringKeys := 0
        TypingBeepers := 0
        DTMFbeepers := 0
    } Else (SilentMode := 1)

    If (presetChosen=4)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        deadKeyBeeper := 1
        If (enableBeeperzPresets=0)
        {
            KeyBeeper := 0
            ModBeeper := 0
            MouseBeeper := 0
            beepFiringKeys := 0
            TypingBeepers := 0
            DTMFbeepers := 0
        }
    }

    If (presetChosen=5)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        deadKeyBeeper := 1
        KeyBeeper := 1
        ModBeeper := 1
        MouseBeeper := 1
        beepFiringKeys := 1
        TypingBeepers := 1
        DTMFbeepers := 1
        ShowMouseHalo := 0
        visualMouseClicks := 0
        MouseClickRipples := 0
        FlashIdleMouse := 0
    }

    If (presetChosen=6)
    {
        SilentMode := 1
        ShowMouseHalo := 1
        FlashIdleMouse := 1
        visualMouseClicks := 0
        MouseClickRipples := 1
    }

    If (MediateKeysFeatures=1)
    {
        sendJumpKeys := 1
        MediateNavKeys := 1
    } Else
    {
        sendJumpKeys := 0
        MediateNavKeys := 0
    }

    If (missingAudios=1)
       GuiControl, Disable, enableBeeperzPresets
}

volSlider() {
    GuiControlGet, result , , BeepsVolume, 
    GuiControl, , volLevel, % "Volume: " result " %"
    BeepsVolume := result
    SetMyVolume()
    beeperzDefunctions.ahkPostFunction["PlaySoundTest", ""]
    VerifySoundsOptions()
}

ShowSoundsSettings() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }

    verifyNonCrucialFilesRan := 2
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
    verifyNonCrucialFiles()

    Global ApplySettingsBTN, volLevel
    Global CurrentPrefWindow := 3
    txtWid := 285
    If (prefsLargeFonts=1)
    {
       txtWid := 470
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Checkbox, gVerifySoundsOptions x15 y15 Checked%SilentMode% vSilentMode, Silent mode - make no sounds
    Gui, Add, Text, y+10, Make a beep when the following keys are released:
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
    Gui, Add, Checkbox, gVerifySoundsOptions y+14 Checked%BeepSentry% vBeepSentry, Generate visual sound event [for Windows Accessibility]
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%prioritizeBeepers% vprioritizeBeepers, Attempt to play every beep (may interfere with typing mode)
    Gui, Add, Text, y+7 Section vvolLevel, % "Volume: " BeepsVolume " %"
    Gui, Add, Slider, x+5 yp+0 gVolSlider w200 vBeepsVolume Range5-99 TickInterval5, %BeepsVolume%

    If (DisableTypingMode=1)
       Gui, Add, Text, xs+0 y+15 w%txtWid%, Some options are disabled, because typing mode is not activated

    If (missingAudios=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, xs+0 y+15 w%txtWid%, WARNING. Sound files are missing. The attempts to download them seem to have failed. The beeps will be synthesized at a high volume.
       Gui, Font, Normal
    }
    Gui, Add, Button, xs+0 y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 w70 h30 gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+5 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Sounds settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifySoundsOptions(0)
}

VerifySoundsOptions(enableApply:=1) {
    GuiControlGet, keyBeeper
    GuiControlGet, TypingBeepers
    GuiControlGet, SilentMode

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (SilentMode=1 || missingAudios=1)
    {
       GuiControl, Disable, BeepSentry
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
       GuiControl, Disable, BeepSentry
       GuiControl, Disable, BeepsVolume
       GuiControl, Disable, volLevel
    } Else
    {
       GuiControl, Enable, BeepSentry
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
       GuiControl, Enable, BeepSentry
       GuiControl, Enable, BeepsVolume
       GuiControl, Enable, volLevel
    }

    If (SilentMode=0)
       GuiControl, % (keyBeeper=0 ? "Disable" : "Enable"), TypingBeepers

    If (AutoDetectKBD=0) || (DoNotBindDeadKeys=1)
       GuiControl, Disable, deadKeyBeeper

    If (DisableTypingMode=1)
       GuiControl, Disable, CapslockBeeper
}

Switch2KBDsList() {
  GenerateKBDlistMenu()
  Sleep, 25
  Menu, kbdLista, Show
}

ShowKBDsettings() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }
    Global CurrentPrefWindow := 1
    Global EditF22, EditF23, DeleteAllClippyBTN
    txtWid := 250
    btnWid := 130
    If (prefsLargeFonts=1)
    {
       txtWid := 370
       btnWid := 180
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Tab3,, Keyboard layouts|Behavior|Clipboard
    Gui, Tab, 3 ; clipboard
    Gui, Add, Checkbox, x+15 y+15 gVerifyKeybdOptions Checked%ClipMonitor% vClipMonitor, Show clipboard changes in the OSD
    Gui, Add, Checkbox, y+10 Section gVerifyKeybdOptions Checked%enableClipManager% venableClipManager, Enable Clipboard History (only for text)
    Gui, Add, Text, xp+15 y+7, Maximum text clips to store
    Gui, Add, Edit, x+5 w60 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap vEditF23, %maximumTextClips%
    Gui, Add, UpDown, vmaximumTextClips gVerifyKeybdOptions Range3-30, %maximumTextClips%
    Gui, Add, Text, xs+0 y+7 w%txtWid%, To access the stored clipboard history from any application, press WinKey + V (default keyboard shortcut).
    IniRead, clipDataMD5s, %IniFile%, ClipboardManager, clipDataMD5s, -
    If StrLen(clipDataMD5s)>5
       Gui, Add, Button, y+10 w170 h30 gInvokeClippyMenu vDeleteAllClippyBTN, List stored entries

    Gui, Tab, 1 ; layouts
    Gui, Add, Checkbox, x+15 y+15 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continuously detect layout changes
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%UseMUInames% vUseMUInames, Use system default language names for layouts
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%SilentDetection% vSilentDetection, Silent detection (no messages)
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%audioAlerts% vaudioAlerts, Beep for failed key bindings
    Gui, Add, Checkbox, y+7 Section gVerifyKeybdOptions Checked%enableAltGr% venableAltGr, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xs+0 y+7 gVerifyKeybdOptions Checked%IgnoreAdditionalKeys% vIgnoreAdditionalKeys, Ignore specific keys (dot separated)
    Gui, Add, Edit, xp+20 y+5 gVerifyKeybdOptions w180 r1 -multi -wantReturn -wantTab -wrap vIgnorekeysList, %IgnorekeysList%
    Gui, Font, Bold
    Gui, Add, Text, xp-20 y+7, Current keyboard layout:
    Gui, Add, Text, y+7 w%txtWid%, %CurrentKBD%
    IniRead, KBDsDetected, %langFile%, Options, KBDsDetected, -
    If (KBDsDetected>0)
       Gui, Add, Text, y+7, Total layouts detected: %KBDsDetected%

    If (loadedLangz!=1 && AutoDetectKBD=1)
       Gui, Add, Text, y+7 w%txtWid%, WARNING: Language definitions file is missing. Support for dead keys is limited. Otherwise, everything should be fine.
    Gui, Font, Normal
    If (KBDsDetected>1)
       Gui, Add, Button, y+10 w%btnWid% h30 gSwitch2KBDsList, List detected layouts

    Gui, Tab, 2 ; behavior
    Gui, Add, Checkbox, x+15 y+15 gVerifyKeybdOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys
    Gui, Add, Checkbox, y+10 gVerifyKeybdOptions Checked%HideAnnoyingKeys% vHideAnnoyingKeys, Hide Left Click and PrintScreen
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%ShowSingleModifierKey% vShowSingleModifierKey, Display modifiers
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%DifferModifiers% vDifferModifiers, Differ left and right modifiers
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%ShowKeyCount% vShowKeyCount, Show key count
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%ShowKeyCountFired% vShowKeyCountFired, Count number of key fires
    Gui, Add, Checkbox, y+7 section gVerifyKeybdOptions Checked%ShowPrevKey% vShowPrevKey, Show previous key (delay in ms)
    Gui, Add, Edit, x+5 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vEditF22, %ShowPrevKeyDelay%
    Gui, Add, UpDown, vShowPrevKeyDelay gVerifyKeybdOptions Range100-990, %ShowPrevKeyDelay%
    Gui, Add, Checkbox, xs+0 y+2 gVerifyKeybdOptions Checked%OSDshowLEDs% vOSDshowLEDs, Show LEDs to indicate key states
    Gui, Add, text, xp+15 y+5 w%txtWid%, This applies for Alt, Ctrl, Shift, Winkey and `nCaps / Num / Scroll lock.

    Gui, Add, Checkbox, xs+0 y+7 gVerifyKeybdOptions Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions w%txtWid% Checked%hostCaretHighlight% vhostCaretHighlight, Highlight text cursor in host app `n(when detectable)
    If (OnlyTypingMode=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, y+7 w%txtWid%, Some options are disabled because Only Typing mode is activated.
       Gui, Font, Normal
    }

    Gui, Tab
    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+5 yp+0 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Keyboard settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifyKeybdOptions(0)
}

VerifyKeybdOptions(enableApply:=1) {
    GuiControlGet, AutoDetectKBD
    GuiControlGet, ConstantAutoDetect
    GuiControlGet, IgnoreAdditionalKeys
    GuiControlGet, ShowSingleKey
    GuiControlGet, HideAnnoyingKeys
    GuiControlGet, SilentDetection
    GuiControlGet, ShowSingleModifierKey
    GuiControlGet, ShowKeyCount
    GuiControlGet, ShowKeyCountFired
    GuiControlGet, ShowPrevKey
    GuiControlGet, enableAltGr
    GuiControlGet, enableClipManager

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (ShowSingleModifierKey=0 ? "Disable" : "Enable"), DifferModifiers
    GuiControl, % (ShowPrevKey=0 ? "Disable" : "Enable"), ShowPrevKeyDelay
    GuiControl, % (ShowPrevKey=0 ? "Disable" : "Enable"), editF22
    GuiControl, % (ShowKeyCount=0 ? "Disable" : "Enable"), ShowKeyCountFired

    If (ShowSingleKey=0)
    {
       GuiControl, Disable, HideAnnoyingKeys
       GuiControl, Disable, ShowSingleModifierKey
       GuiControl, Disable, OnlyTypingMode
       If (DisableTypingMode=0)
          OnlyTypingMode := 0
    } Else If (OnlyTypingMode!=1)
    {
       GuiControl, Enable, HideAnnoyingKeys
       GuiControl, Enable, ShowSingleModifierKey
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, DifferModifiers
       GuiControl, Enable, ShowKeyCount
       GuiControl, Enable, ShowPrevKey
       If (ShowPrevKey=1)
       {
          GuiControl, Enable, ShowPrevKeyDelay
          GuiControl, Enable, EditF22
       }
    }

    If (AutoDetectKBD=1)
       GuiControl, Enable, ConstantAutoDetect
    Else 
       GuiControl, Disable, ConstantAutoDetect

    If (AutoDetectKBD=0)
       GuiControl, Disable, SilentDetection
    Else
       GuiControl, Enable, SilentDetection

    GuiControl, % (IgnoreAdditionalKeys=0 ? "Disable" : "Enable"), IgnorekeysList
    If (OnlyTypingMode=1)
    {
        GuiControl, Disable, ShowSingleModifierKey
        GuiControl, Disable, ShowKeyCount
        GuiControl, Disable, ShowKeyCountFired
        GuiControl, Disable, ShowPrevKey 
        GuiControl, Disable, ShowPrevKeyDelay
        GuiControl, Disable, EditF22
        GuiControl, Disable, HideAnnoyingKeys
        GuiControl, Disable, DifferModifiers
    }
    GuiControl, % (enableClipManager=0 ? "Disable" : "Enable"), EditF23
}

ShowMouseSettings() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }
    Global RealTimeUpdates := 0
    Global CurrentPrefWindow := 4
    Global editF1, editF2, editF3, editF4, editF5, editF6, editF7, btn1

    If (prefsLargeFonts=1)
       Gui, Font, s%LargeUIfontValue%
    Gui, Add, Tab3,, Mouse clicks|Mouse location
    Gui, Tab, 1 ; clicks
    Gui, Add, Checkbox, gVerifyMouseOptions x+15 y+15 w250 Checked%MouseBeeper% vMouseBeeper, Beep on mouse clicks
    If (OnlyTypingMode!=1)
       Gui, Add, Checkbox, gVerifyMouseOptions y+5 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Checkbox, gVerifyMouseOptions section y+7 Checked%VisualMouseClicks% vVisualMouseClicks, Visual mouse clicks (scale, alpha, color)
    Gui, Add, Edit, xp+16 y+5 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %ClickScaleUser%
    Gui, Add, UpDown, vClickScaleUser gVerifyMouseOptions Range5-70, %ClickScaleUser%
    Gui, Add, Edit, x+5 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %MouseVclickAlpha%
    Gui, Add, UpDown, vMouseVclickAlpha gVerifyMouseOptions Range20-240, %MouseVclickAlpha%
    Gui, Add, ListView, x+5 w50 h22 %cclvo% Background%MouseVclickColor% vMouseVclickColor hwndhLV6,
    Gui, Add, Checkbox, gVerifyMouseOptions xs+0 y+10 Checked%MouseClickRipples% vMouseClickRipples, Show ripples on clicks (size, thickness)
    Gui, Add, Edit, xp+16 y+10 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %MouseRippleMaxSize%
    Gui, Add, UpDown, vMouseRippleMaxSize gVerifyMouseOptions Range90-400, %MouseRippleMaxSize%
    Gui, Add, Edit, x+5 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %MouseRippleThickness%
    Gui, Add, UpDown, vMouseRippleThickness gVerifyMouseOptions Range5-50, %MouseRippleThickness%
    If (!isBeeperzFile || !isRipplesFile) ; keypress-beeperz-functions.ahk / keypress-mouse-ripples-functions.ahk
    {
       Gui, Font, Bold
       Gui, Add, Text, y+7, Some option(s) are disabled because files are missing.
       Gui, Font, Normal
    }

    Gui, Tab, 2 ; location
    Gui, Add, Checkbox, gVerifyMouseOptions section x+15 y+15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Edit, xs+16 y+10 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %MouseHaloRadius%
    Gui, Add, UpDown, vMouseHaloRadius gVerifyMouseOptions Range15-950, %MouseHaloRadius%
    Gui, Add, Text, x+5, radius
    Gui, Add, Edit, xs+16 y+10 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %MouseHaloAlpha%
    Gui, Add, UpDown, vMouseHaloAlpha gVerifyMouseOptions Range20-240, %MouseHaloAlpha%
    Gui, Add, Text, x+5, alpha, color
    Gui, Add, ListView, x+5 w55 h20 %cclvo% Background%MouseHaloColor% vMouseHaloColor hwndhLV4,

    Gui, Add, Checkbox, gVerifyMouseOptions xs+0 y+15 Checked%FlashIdleMouse% vFlashIdleMouse, Flash idle mouse to locate it
    Gui, Add, Edit, xs+16 y+10 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %MouseIdleAfter%
    Gui, Add, UpDown, vMouseIdleAfter gVerifyMouseOptions Range3-950, %MouseIdleAfter%
    Gui, Add, Text, x+5, idle after (in seconds)
    Gui, Add, Edit, xs+16 y+10 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %MouseIdleRadius%
    Gui, Add, UpDown, vMouseIdleRadius gVerifyMouseOptions Range15-950, %MouseIdleRadius%
    Gui, Add, Text, x+5, halo radius
    Gui, Add, Edit, xs+16 y+10 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %IdleMouseAlpha%
    Gui, Add, UpDown, vIdleMouseAlpha gVerifyMouseOptions Range20-240, %IdleMouseAlpha%
    Gui, Add, Text, x+5, alpha, color
    Gui, Add, ListView, x+5 w55 h20 %cclvo% Background%MouseIdleColor% vMouseIdleColor hwndhLV7,

    Gui, Tab
    Gui, Add, Checkbox, gVerifyMouseOptions y+10 Checked%RealTimeUpdates% vRealTimeUpdates, Save and update settings in real time
    Gui, Add, Button, xm+0 y+15 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+5 yp+0 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts

    Gui, Show, AutoSize, Mouse settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifyMouseOptions(0)
    colorPickerHandles := hLV4 "," hLV6 "," hLV7
}

hexRGB(c) {
  r := ((c&255)<<16)+(c&65280)+((c&0xFF0000)>>16)
  c := "000000"
  DllCall("msvcrt\sprintf", "AStr", c, "AStr", "%06X", "UInt", r, "CDecl")
  Return c
}

Dlg_Color(Color,hwnd) {
  Static
  If !cpdInit {
     VarSetCapacity(CUSTOM,64,0), cpdInit:=1, size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
  }

  Color := "0x" hexRGB(InStr(Color, "0x") ? Color : Color ? "0x" Color : 0x0)
  NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"Ptr")
  ,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
  ,NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"Ptr")
  If !ret := DllCall("comdlg32\ChooseColorW","Ptr",&CHOOSECOLOR,"UInt")
     Exit

  SetFormat, IntegerFast, H
  Color := NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
  SetFormat, IntegerFast, D
  GuiControlGet, RealTimeUpdates
  If (RealTimeUpdates=1)
     SetTimer, updateRealTimeSettings, 400, -50

  Return Color
}

VerifyMouseOptions(enableApply:=1) {
    GuiControlGet, FlashIdleMouse
    GuiControlGet, ShowMouseHalo
    GuiControlGet, ShowMouseButton
    GuiControlGet, VisualMouseClicks
    GuiControlGet, MouseClickRipples
    GuiControlGet, RealTimeUpdates

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (VisualMouseClicks=0)
    {
       GuiControl, Disable, ClickScaleUser
       GuiControl, Disable, MouseVclickAlpha
       GuiControl, Disable, MouseVclickColor
       GuiControl, Enable, MouseClickRipples
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } Else
    {
       GuiControl, Enable, ClickScaleUser
       GuiControl, Enable, MouseVclickAlpha
       GuiControl, Enable, MouseVclickColor
       GuiControl, Disable, MouseClickRipples
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    If (FlashIdleMouse=0)
    {
       GuiControl, Disable, MouseIdleAfter
       GuiControl, Disable, MouseIdleRadius
       GuiControl, Disable, MouseIdleColor
       GuiControl, Disable, IdleMouseAlpha
       GuiControl, Disable, editF5
       GuiControl, Disable, editF6
       GuiControl, Disable, editF7
    } Else
    {
       GuiControl, Enable, MouseIdleAfter
       GuiControl, Enable, MouseIdleRadius
       GuiControl, Enable, MouseIdleColor
       GuiControl, Enable, IdleMouseAlpha
       GuiControl, Enable, editF5
       GuiControl, Enable, editF6
       GuiControl, Enable, editF7
    }

    If (ShowMouseHalo=0)
    {
       GuiControl, Disable, MouseHaloRadius
       GuiControl, Disable, MouseHaloColor
       GuiControl, Disable, MouseHaloAlpha
       GuiControl, Disable, btn1
       GuiControl, Disable, editF3
       GuiControl, Disable, editF4
    } Else
    {
       GuiControl, Enable, MouseHaloRadius
       GuiControl, Enable, MouseHaloColor
       GuiControl, Enable, MouseHaloAlpha
       GuiControl, Enable, btn1
       GuiControl, Enable, editF3
       GuiControl, Enable, editF4
    }

    If (MouseClickRipples=0)
    {
       GuiControl, Disable, MouseRippleThickness
       GuiControl, Disable, MouseRippleMaxSize
       GuiControl, Enable, VisualMouseClicks
       GuiControl, Disable, editF8
       GuiControl, Disable, editF9
    } Else
    {
       GuiControl, Enable, MouseRippleThickness
       GuiControl, Enable, MouseRippleMaxSize
       GuiControl, Disable, VisualMouseClicks
       GuiControl, Enable, editF8
       GuiControl, Enable, editF9
    }

    If !isBeeperzFile ; keypress-beeperz-functions.ahk
       GuiControl, Disable, MouseBeeper

    If !isRipplesFile ; keypress-mouse-ripples-functions.ahk
       GuiControl, Disable, MouseClickRipples
    If (RealTimeUpdates=1)
       SetTimer, updateRealTimeSettings, 400, -50
}

updateRealTimeSettings() {
  Gui, Submit, NoHide
  CheckSettings()
  ShaveSettings()
  Sleep, 25
  mouseFonctiones.ahkReload[]
  mouseRipplesThread.ahkReload[]
  Sleep, 25
  SetTimer, , off
}

UpdateFntNow() {
  Global
  Fnt_DeleteFont(hfont)
  fntOptions := "s" FontSize " Bold Q5"
  hFont := Fnt_CreateFont(FontName,fntOptions)
  Fnt_SetFont(hOSDctrl,hfont,true)
}

OSDpreview() {
    Gui, SettingsGUIA: Submit, NoHide
    If (A_TickCount-tickcount_start2 < 150)
       Return

    If (showPreview=0)
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
    If (OSDshowLEDs=1)
       GuiControl, OSD:, CapsLED, 100
    TextHeight := FontSize*2
    GuiControl, OSD: Move, HotkeyText, h%TextHeight%
    ShowHotkey(previewWindowText)
}

ShowOSDsettings() {
    Global reopen
    If !reopen
    {
        doNotOpen := initSettingsWindow()
        If (doNotOpen=1)
           Return
    }
    Global CurrentPrefWindow := 5
    Global positionB, editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, editF10, Btn1, Btn2
    GUIposition := GUIposition + 1
    columnBpos1 := 125
    columnBpos2 := 120
    If (prefsLargeFonts=1)
    {
       Gui, Font, s%LargeUIfontValue%
       columnBpos1 := 250
       columnBpos2 := 250
    }
    columnBpos1b := columnBpos1 + 70

    Gui, Add, Tab3,, Size and position|Style and colors
    Gui, Tab, 1 ; size/position
    Gui, Add, Checkbox, x+15 y+15 gVerifyOsdOptions Checked%outputOSDtoToolTip% voutputOSDtoToolTip, Display OSD as a mouse tooltip
    Gui, Add, Text, y+10 section, OSD location presets:
    Gui, Add, Radio, y+7 Group Section gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, yp+30 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, DropDownList, xs+%columnBpos1% ys+0 w65 gVerifyOsdOptions AltSubmit choose%OSDalignment2% vOSDalignment2, Left|Center|Right|
    Gui, Add, Edit, x+5 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %GuiXa%
    Gui, Add, UpDown, vGuiXa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXa%
    Gui, Add, Edit, x+5 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %GuiYa%
    Gui, Add, UpDown, vGuiYa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYa%
    Gui, Add, Button, x+5 w25 h20 gLocatePositionA vBtn1, L
    Gui, Add, DropDownList, xs+%columnBpos1% ys+30 Section w65 gVerifyOsdOptions AltSubmit choose%OSDalignment1% vOSDalignment1, Left|Center|Right|
    Gui, Add, Edit, x+5 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %GuiXb%
    Gui, Add, UpDown, vGuiXb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXb%
    Gui, Add, Edit, x+5 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %GuiYb%
    Gui, Add, UpDown, vGuiYb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYb%
    Gui, Add, Button, x+5 w25 h20 gLocatePositionB vBtn2, L

    Gui, Add, Text, xm+15 ys+30 Section, Width (fixed size)
    Gui, Add, Text, xp+0 yp+30, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+30 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (max. width)
    Gui, Add, Text, xp+0 yp+30, When mouse cursor hovers the OSD

    Gui, Add, Edit, xs+%columnBpos1b% ys+0 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %GuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vGuiWidth Range55-2900, %GuiWidth%
    Gui, Add, Edit, xp+0 yp+30 w65 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %OSDautosizeFactory%
    Gui, Add, UpDown, gVerifyOsdOptions vOSDautosizeFactory Range10-400, %OSDautosizeFactory%
    Gui, Add, Edit, xp+0 yp+30 w65 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %maxGuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vmaxGuiWidth Range55-2900, %maxGuiWidth%
    Gui, Add, DropDownList, xp+0 yp+30 w160 gVerifyOsdOptions AltSubmit choose%mouseOSDbehavior% vmouseOSDbehavior, Immediately hide|Toggle positions (A/B)|Allow drag to reposition

    Gui, Tab, 2 ; style
    Gui, Add, Text, x+15 y+15 Section, Font name and size
    Gui, Add, Text, xp+0 yp+30, Text and background colors
    Gui, Add, Text, xp+0 yp+30, Caps lock highlight color
    Gui, Add, Text, xp+0 yp+30, Alternative typing mode highlight color
    Gui, Add, Text, xp+0 yp+30, Display time / when typing (in sec.)
    Gui, Add, Checkbox, y+9 gVerifyOsdOptions Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, y+7 gVerifyOsdOptions Checked%OSDshowLEDs% vOSDshowLEDs, Show LEDs to indicate key states
    Gui, Add, text, xp+15 y+5 w310, This applies for Alt, Ctrl, Shift, Winkey `nand Caps / Num / Scroll lock.

    Gui, Add, DropDownList, xs+%columnBpos2% ys+0 section w145 gVerifyOsdOptions Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+150 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %FontSize%
    Gui, Add, UpDown, gVerifyOsdOptions vFontSize Range7-295, %FontSize%
    Gui, Add, ListView, xp-60 yp+30 w55 h20 %cclvo% Background%OSDtextColor% vOSDtextColor hwndhLV1,
    Gui, Add, ListView, xp+60 yp+0 w55 h20 %cclvo% Background%OSDbgrColor% vOSDbgrColor hwndhLV2,
    Gui, Add, ListView, xp-60 yp+30 w55 h20 %cclvo% Background%CapsColorHighlight% vCapsColorHighlight hwndhLV3,
    Gui, Add, ListView, xp+0 yp+30 w55 h20 %cclvo% Background%TypingColorHighlight% vTypingColorHighlight hwndhLV5,
    Gui, Add, Edit, xp+60 yp+30 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF10, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyOsdOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Edit, xp-60 yp+0 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %DisplayTimeUser%
    Gui, Add, UpDown, vDisplayTimeUser gVerifyOsdOptions Range1-99, %DisplayTimeUser%

    If !FontList._NewEnum()[k, v]
    {
        Fnt_GetListOfFonts()
        FontList := trimArray(FontList)
    }
    Loop, % FontList.MaxIndex() {
        fontNameInstalled := FontList[A_Index]
        If (fontNameInstalled ~= "i)(@|oem|extb|symbol|marlett|wst_|glyph|reference specialty|system|terminal|mt extra|small fonts|cambria math|this font is not|fixedsys|emoji|hksc| mdl|wingdings|webdings)") || (fontNameInstalled=FontName)
           Continue
        GuiControl, , FontName, %fontNameInstalled%
    }

    Gui, Tab
    Gui, Font, Bold
    If (NeverDisplayOSD=1)
       Gui, Add, Text, y+5, WARNING: Never display OSD is activated.
    Gui, Add, Checkbox, y+8 gVerifyOsdOptions Checked%showPreview% vshowPreview, Show preview window
    Gui, Add, Edit, x+7 gVerifyOsdOptions w165 limit30 r1 -multi -wantReturn -wantTab -wrap vpreviewWindowText, %previewWindowText%
    Gui, Font, Normal

    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+5 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+5 yp+0 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, OSD appearance: KeyPress OSD
    verifySettingsWindowSize()
    VerifyOsdOptions(0)
    colorPickerHandles := hLV1 "," hLV2 "," hLV3 "," hLV5
}

VerifyOsdOptions(enableApply:=1) {
    GuiControlGet, OSDautosize
    GuiControlGet, GUIposition
    GuiControlGet, showPreview
    GuiControlGet, DragOSDmode
    GuiControlGet, OSDshowLEDs

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (showPreview=1 ? "Enable" : "Disable"), previewWindowText
    GuiControl, % (OSDshowLEDs=1 ? "Enable" : "Disable"), CapsColorHighlight

    If (GUIposition=0)
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
    } Else
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

    If (OSDautosize=0)
    {
        GuiControl, Enable, GuiWidth
        GuiControl, Enable, editF7
        GuiControl, Disable, maxGuiWidth
        GuiControl, Disable, editF8
    } Else
    {
        GuiControl, Disable, GuiWidth
        GuiControl, Disable, editF7
        GuiControl, Enable, maxGuiWidth
        GuiControl, Enable, editF8
    }

    If (DisableTypingMode=1)
    {
        GuiControl, Disable, editF10
        GuiControl, Disable, DisplayTimeTypingUser
    }
    OSDpreview()
}

LocatePositionA() {
    GuiControlGet, GUIposition
    If (GUIposition=0)
       Return

    ToolTip, Move mouse to desired location and click
    CoordMode Mouse, Screen
    KeyWait, LButton, D, T10
    MouseGetPos, x, y
    ToolTip
    GuiControl, , GuiXa, %x%
    GuiControl, , GuiYa, %y%
    OSDpreview()
}

LocatePositionB() {
    GuiControlGet, GUIposition
    If (GUIposition=0)
    {
        ToolTip, Move mouse to desired location and click
        CoordMode Mouse, Screen
        KeyWait, LButton, D, T10
        ToolTip
        MouseGetPos, x, y
        GuiControl, , GuiXb, %x%
        GuiControl, , GuiYb, %y%
    } Else Return
    OSDpreview()
}

trimArray(arr) { ; Hash O(n) 
; by errorseven from https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
    hash := {}, newArr := []
    for e, v in arr
        If (!hash.Haskey(v))
            hash[(v)] := 1, newArr.push(v)
    Return newArr
}

ApplySettings() {
    Gui, SettingsGUIA: Submit, NoHide
    CheckSettings()
    If (AutoDetectKBD=1)
    {
       ReloadCounter := 1
       IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    }
    prefOpen := 0
    IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
    Sleep, 25
    ShaveSettings()
    Sleep, 100
    ReloadScript()
}

DonateNow() {
   Run, https://www.paypal.me/MariusSucan/15
}

AboutWindow() {
    If (prefOpen=1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
    }

    SettingsGUI()
    IniWrite, %releaseDate%, %inifile%, SavedSettings, releaseDate
    IniWrite, %version%, %inifile%, SavedSettings, version
    hPaypalImg := LoadImage(A_IsCompiled ? A_ScriptFullPath : "Lib\paypal.bmp", "B", 100)
    hIconImg := LoadImage(A_IsCompiled ? A_ScriptFullPath : "Lib\keypress.ico", "I", 159, 128)
    anyWindowOpen := 1
    txtWid := 360
    btnWid := 100
    Gui, Font, s20 Bold, Arial, -wrap
    Gui, Add, Picture, x15 y15 w66 h-1 +0x3, HICON:%hIconImg%
    Gui, Add, Text, x+7 y10, KeyPress OSD v%version%
    Gui, Font
    Gui, Add, Text, y+2, Based on KeyPressOSD v2.2 by Tmplinshi.
    If (prefsLargeFonts=1)
    {
       btnWid := 150
       txtWid := 465
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Link, y+4, Script developed by <a href="http://marius.sucan.ro">Marius Şucan</a> on AHK_H v1.1.27.
    Gui, Add, Text, x15 y+9, Freeware. Open source. For Windows XP, 7, 8, and 10.
    Gui, Add, Text, y+10 w%txtWid%, My gratitude to Drugwash for directly contributing with considerable improvements and code to this project.
    Gui, Add, Text, y+10 w%txtWid%, Many thanks to the great people from #ahk (irc.freenode.net), in particular to Phaleth, Tidbit and Saiapatsu. Special mentions to: Burque505 / Winter (for continued feedback) and Neuromancer.
    Gui, Add, Text, y+10 w%txtWid% Section, This contains code also from: Maestrith (color picker), Alguimist (font list generator), VxE (GuiGetSize), Sean (GetTextExtentPoint), Helgef (toUnicodeEx), Jess Harpur (Extract2Folder), Tidbit (String Things), jballi (Font Library 3) and Lexikos.
    Gui, Font, Bold
    Gui, Add, Link, xp+25 y+10, To keep the development going, `n<a href="https://www.paypal.me/MariusSucan/15">please donate</a> or <a href="mailto:marius.sucan@gmail.com">send me feedback</a>.
    Gui, Add, Picture, x+5 yp+0 gDonateNow hp w-1 +0xE hwndhDonateBTN, HBITMAP:%hPaypalImg%
    UpdateInfo := checkUpdateExistsAbout()
    If UpdateInfo
       Gui, Add, Text, xs+0 y+20, %UpdateInfo%
    Gui, Font, Normal
    Gui, Add, Button, xs+0 y+20 w75 Default gCloseWindow, &Close
    Gui, Add, Button, x+5 w%btnWid% gChangeLog, Version &history
    Gui, Add, Text, x+8 hp +0x200, Released: %releaseDate%
    Gui, Show, AutoSize, About KeyPress OSD v%version%
    verifySettingsWindowSize()
    colorPickerHandles := hDonateBTN
    miniUpdateChecker()
}

listIMEs() {
    If (A_OSVersion ~= "i)(WIN_XP|WIN_2000)")
       Return

    IniRead, KBDsDetected, %langFile%, Options, KBDsDetected, -
    IniRead, PreloadList, %langFile%, REGdumpData, PreloadList, -
    skey := "Software\Microsoft\CTF\SortOrder\AssemblyItem"
    Loop, HKCU, %skey%, 2
    {
      s1 := A_LoopRegName
      StringReplace, s1s, s1, 0x,
      StringRight, s1end, s1s, 4
      Loop, HKCU, %skey%\%s1%, 2
      {
         s2 := A_LoopRegName
         Loop, HKCU, %skey%\%s1%\%s2%, 2
         {
             s3 := A_LoopRegName
             RegRead, CLSID, HKCU, %skey%\%s1%\%s2%\%s3%, CLSID
             SetFormat, Integer, H
             RegRead, KeyboardLayout, HKCU, %skey%\%s1%\%s2%\%s3%, KeyboardLayout
             SetFormat, Integer, D
             ; debug data
             /*
             If !InStr(CLSID, "0000")
                CLSIDlist .= s1end "-" CLSID ","
             If (KeyboardLayout!=0)
                TehBigList .= s1end "-" KeyboardLayout ","
             */
             StringReplace, KeyboardLayout2, KeyboardLayout, 0x, |0
             RegRead, ProfileCLSID, HKCU, %skey%\%s1%\%s2%\%s3%, Profile
             KeyboardLayoutsList .= "|" KeyboardLayout2
             imeName := GetIMEName(CLSID "\LanguageProfile\" s1 "\" ProfileCLSID)
             If (StrLen(imeName)>1 && InStr(PreloadList, s1s))
             {
               Sleep, 25
               countedIMEs++
               description := ISOcodeCulture(s1, 1) imeName ; " [" s1end "]"
               RegRead, s1ss, HKCU, Keyboard Layout\Substitutes, %s1s%
               If StrLen(s1ss)<3
                  s1ss := s1s
               IniWrite, %s1ss%, %langFile%, IMEs, %s1s%
               IniWrite, %description%, %langFile%, IMEs, name%countedIMEs%
               Sleep, 50
               If s1ss
               {
                  StringRight, TeHstart, s1ss, 4
                  testS1nonIME := TeHstart s1end
                  StringReplace, kbdList, KeyboardLayoutsList, 0x, 0
               }
             }
         }
         If !InStr(KeyboardLayoutsList, testS1nonIME) && testS1nonIME
         {
            IniRead, kbdName, %langFile%, %s1s%, name, -
            IniRead, testIMEz, %langFile%, IMEs, %s1s%, -
            Sleep, 25
            If (StrLen(kbdName)>1 && StrLen(testIMEz)>2)
               IniWrite, 1, %langFile%, %s1s%, doNotList
         }
      }
    }
    Loop, Reg, HKEY_CURRENT_USER\Software\Microsoft\CTF\HiddenDummyLayouts, KV
    {
         RegRead, value
         IniWrite, %value%, %langFile%, IMEs, %a_LoopRegName%
    }
    KBDsDetected := KBDsDetected + countedIMEs
    IniWrite, %KBDsDetected%, %langFile%, Options, KBDsDetected
;    IniWrite, %TehBigList%, %langFile%, REGdumpData, Assemblies
;    IniWrite, %CLSIDlist%, %langFile%, REGdumpData, CLSIDlist
}

GenerateKBDlistMenu() {
    Static ListGenerated
    If (ListGenerated=1)
       Return
    initLangFile()
    Sleep, 25
    IniRead, KLIDlist, %langFile%, Options, KLIDlist, -
    Loop, Parse, KLIDlist, CSV
    {
      IniRead, doNotList, %langFile%, %A_LoopField%, doNotList, -
      If (StrLen(A_LoopField)<2 || doNotList=1)
         Continue
      IniRead, langFriendlySysName, %langFile%, %A_LoopField%, name, -
      IniRead, isRTL, %langFile%, %A_LoopField%, isRTL, -
      IniRead, KBDisUnsupported, %langFile%, %A_LoopField%, KBDisUnsupported, -

      If (StrLen(langFriendlySysName)<2 && A_LoopField ~= "i)^(d00)")
      {
         StringReplace, newKLID, A_LoopField, d00, 000
         If InStr(loadedKLIDs, newKLID)
            Continue
         langFriendlySysName := GetLayoutDisplayName(newKLID)
         Sleep, 25
         If StrLen(langFriendlySysName)>1
            IniWrite, %langFriendlySysName%, %langFile%, %A_LoopField%, name
      }
      loadedKLIDs .= "." A_LoopField "." newKLID
      If StrLen(langFriendlySysName)<2
      {
         langFriendlySysName := A_LoopField " (unrecognized) ³"
         KBDisUnsupported := 1
      }

      If (KBDisUnsupported=1)
         KBDisSupported := "(unsupported)"
      If (KBDisUnsupported=0)
         KBDisSupported := ""
      If (isRTL=1)
         KBDisSupported := "(partial support)"
      Menu, kbdLista, Add, %langFriendlySysName% %KBDisSupported%, dummy
      If (KBDisUnsupported=1)
         Menu, kbdLista, Disable, %langFriendlySysName% %KBDisSupported%
    }

    Loop
    {
      IniRead, IMEname, %langFile%, IMEs, name%A_Index%, --
      If (IMEname="--")
         Break
      StringReplace, IMEname, IMEname, version, ver.
      StringReplace, IMEname, IMEname, Microsoft, MS.
      StringReplace, IMEname, IMEname, traditional, trad.
      Menu, kbdLista, Add, %IMEname% (unsupported), dummy
      Menu, kbdLista, Disable, %IMEname% (unsupported)
    }
    ListGenerated := 1
}

ActionListViewKBDs() {
  If (A_GuiEvent = "DoubleClick")
  {
      LV_GetText(KLIDselected, A_EventInfo, 5)  ; Get the text from the row's first field.
      IniRead, HKL, %langFile%, %KLIDselected%, HKL, !
      If !InStr(HKL, "!")
      {
          CloseWindow()
          Sleep, 50
          Global lastTypedSince := 6000
          Global tickcount_start := 6000
          Sleep, 150
          ChangeGlobal(HKL)
          Sleep, 150
          SetTimer, ConstantKBDtimer, 250, 50
          Sleep, 150
      } Else SoundBeep, 300, 100
  }
}

InstalledKBDsWindow() {
    If (prefOpen=1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
    }
    kbLayoutRaw := checkWindowKBD()
    Sleep, 25
    initLangFile()
    Sleep, 25
    IniRead, KBDsDetected, %langFile%, Options, KBDsDetected, 1
    DLC := KBDsDetected>11 ? 12 : StrLen(KBDsDetected)>0 ? KBDsDetected+1 : 5 ; I have 11 layouts, there's one extra just in case, so leave it as is
    IniWrite, %releaseDate%, %inifile%, SavedSettings, releaseDate
    IniWrite, %version%, %inifile%, SavedSettings, version
    SettingsGUI()
    Global ListViewKBDs, btn100, RefreshBTN
    countList := 0
    anyWindowOpen := 1
    txtWid := 370
    If (prefsLargeFonts=1)
    {
       txtWid := 570
       Gui, Font, s%LargeUIfontValue%
    }
    kbdCode := SubStr(CurrentKBD, InStr(CurrentKBD, ". ")+2, 100)
    StringReplace, kbdDescript, CurrentKBD, %kbdCode%
    Gui, Font, Bold
    Gui, Add, Text, x15 y10, Current keyboard layout: %kbdCode%
    Gui, Add, Text, y+5 w%txtWid%, %kbdDescript%
    Gui, Font, Normal
    Gui, Add, ListView, y+10 w%txtWid% r%DLC% Grid Sort gActionListViewKBDs vListViewKBDs, Layout name|RTL|Dead keys|Support|KLID

    IniRead, KLIDlist, %langFile%, Options, KLIDlist, -
    Loop, Parse, KLIDlist, CSV
    {
      IniRead, doNotList, %langFile%, %A_LoopField%, doNotList, -
      If (StrLen(A_LoopField)<2 || doNotList=1)
         Continue
      IniRead, langFriendlySysName, %langFile%, %A_LoopField%, name, -
      IniRead, isRTL, %langFile%, %A_LoopField%, isRTL, -
      IniRead, hasDKs, %langFile%, %A_LoopField%, hasDKs, -
      IniRead, hasThisIME, %langFile%, %A_LoopField%, hasIME, -
      IniRead, isVertUp, %langFile%, %A_LoopField%, isVertUp, -
      IniRead, KBDisUnsupported, %langFile%, %A_LoopField%, KBDisUnsupported, -
      If (isVertUp=1)
         note0 := 1
      If (isRTL=1)
         note1 := 1
      If (KBDisUnsupported=1)
         note2 := 1

      If (StrLen(langFriendlySysName)<2 && A_LoopField ~= "i)^(d00)")
      {
         StringReplace, newKLID, A_LoopField, d00, 000
         If InStr(loadedKLIDs, newKLID)
            Continue
         langFriendlySysName := GetLayoutDisplayName(newKLID)
         If StrLen(langFriendlySysName)>1
            IniWrite, %langFriendlySysName%, %langFile%, %A_LoopField%, name
      }
      loadedKLIDs .= "." A_LoopField "." newKLID
      If StrLen(langFriendlySysName)<2
      {
         langFriendlySysName := A_LoopField " (unrecognized) ³"
         note3 := 1
      }
      KBDisSupported := KBDisUnsupported=0 ? "Yes" : KBDisUnsupported=1 ? "No" : "?"
      KBDisSupported := isVertUp=1 ? "No *" : KBDisSupported
      KBDisSupported := hasThisIME=1 ? "No ²" : KBDisSupported
      KBDisSupported := isRTL=1 ? "Partial ¹" : KBDisSupported

      isRTL := isRTL=1 ? "Yes" : isRTL=0 ? "No" : isRTL
      hasDKs := hasDKs=1 ? "Yes" : hasDKs=0 ? "No" : hasDKs
      countList++
      LV_Add("", langFriendlySysName, isRTL, hasDKs, KBDisSupported, A_LoopField)
    }

    Loop
    {
      IniRead, IMEname, %langFile%, IMEs, name%A_Index%, --
      If (IMEname="--")
         Break
      StringReplace, IMEname, IMEname, version, ver.
      StringReplace, IMEname, IMEname, Microsoft, MS.
      StringReplace, IMEname, IMEname, traditional, trad.
      LV_Add("", IMEname, "-", "-", "No ²")
      note2 := 1
      countList++
    }
    If (countList<1)
       LV_Add("", "No layouts detected...", "-", "-", "-")
    Loop, 5
        LV_ModifyCol(A_Index, "AutoHdr Center")
    LV_ModifyCol(1, "Left")
    LV_ModifyCol(5, 0)
    If note0
       Gui, Add, Text, y+5 w%txtWid%, * Layouts meant for vertical writing are unsupported.
    If note1
       Gui, Add, Text, y+5 w%txtWid%, ¹ Caret navigation is disabled for Right-to-Left (RTL) layouts.
    Else
       LV_ModifyCol(2, 0)
    If note2
       Gui, Add, Text, y+5 w%txtWid%, ² Layouts using Input Method Editors (IME) are unsupported.
    If note3
       Gui, Add, Text, y+5 w%txtWid%, ³ Layout is likely unsupported.

    If (AutoDetectKBD=0)
    {
      Gui, Font, Bold
      Gui, Add, Text, y+10 w%txtWid%, WARNING: Automatic keyboard layout detection is disabled.
      Gui, Font, Normal
    }
    Gui, Add, Button, y+15 w75 Default gCloseWindow, &Close
    If FileExist(langfile)
       Gui, Add, Button, x+3 w120 gDeleteLangFile vRefreshBTN, &Refresh list
    Gui, Add, Text, x+10 hp +0x200, Total layouts detected: %countList%
    Gui, Show, AutoSize, KeyPress OSD: Installed keyboard layouts
    IniWrite, %countList%, %langFile%, Options, KBDsDetected
    verifySettingsWindowSize()
    miniUpdateChecker()
}

ISOcodeCulture(KLID, IME:=0) {
   If (IME=0)
      GetLocaleInfo(codel, 0x3, "0x" KLID) 
   Else
      GetLocaleInfo(codel, 0x3, KLID)
   Return "[" codel "] "
}

checkInstalledLangs() {
    Loop
    {
      RegRead, langInstalled, HKEY_CURRENT_USER, Keyboard Layout\Preload, %A_Index%
      If !langInstalled
         Break

      RegRead, langRealInstalled, HKEY_CURRENT_USER, Keyboard Layout\Substitutes, %langInstalled%
      If !langRealInstalled
         langRealInstalled := langInstalled

      If InStr(langRealInstList, langRealInstalled) OR StrLen(langRealInstalled)<3
         Continue

      langRealInstList .= langRealInstalled ","
      langFriendlySysName := ISOcodeCulture(langRealInstalled) GetLayoutDisplayName(langRealInstalled)
      GetLocaleTextDir(langRealInstalled, isRTL, isVert, isUp)
      isVertUp := 0
      If (isVert=1 || isUp=1)
         isVertUp := 1
      IniRead, hasThisIME, %langFile%, %A_LoopField%, hasIME, 0
      IniRead, KBDisUnsupported, %langFile%, %langRealInstalled%, KBDisUnsupported, 0
      If (isVertUp=1 || hasThisIME=1)
         KBDisUnsupported := 1

      If StrLen(langFriendlySysName)<2
      {
         langFriendlySysName := "Unrecognized"
         KBDisUnsupported := 1
      }
      IniWrite, %langFriendlySysName%, %langFile%, %langRealInstalled%, name
      IniWrite, %isRTL%, %langFile%, %langRealInstalled%, isRTL
      IniWrite, %hasThisIME%, %langFile%, %langRealInstalled%, hasIME
      IniWrite, %isVertUp%, %langFile%, %langRealInstalled%, isVertUp
      IniWrite, %KBDisUnsupported%, %langFile%, %langRealInstalled%, KBDisUnsupported
      countedLayouts++
    }
    StringTrimRight, langRealInstList, langRealInstList, 1
    IniWrite, %countedLayouts%, %langFile%, Options, KBDsDetected
    IniWrite, %langRealInstList%, %langFile%, Options, KLIDlist2
}

DeleteLangFile() {
  GuiControl, Disable, RefreshBTN
  FileDelete, %langFile%
  Sleep, 10
  initLangFile()
  Sleep, 50
  InstalledKBDsWindow()
  Sleep, 10
}

CloseWindow() {
    If hPaypalImg
       DllCall("gdi32\DeleteObject", "Ptr", hPaypalImg)
    If hIconImg
       DllCall("gdi32\DestroyIcon", "Ptr", hIconImg)
    anyWindowOpen := 0
    Gui, SettingsGUIA: Destroy
}

CloseSettings() {
   GuiControlGet, ApplySettingsBTN, Enabled
   If (ApplySettingsBTN=0)
   {
      prefOpen := 0
      IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
      Sleep, 25
      CloseWindow()
      SuspendScript()
      Return
   }
   prefOpen := 0
   IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
   Sleep, 100
   CloseWindow()
   ReloadScript()
}

changelog() {
     Gui, SettingsGUIA: Destroy
     historyFileName := "keypress-osd-changelog.txt"
     historyFile := "Lib\" historyFileName
     historyFileURL := baseURL historyFileName

     If (!FileExist(historyFile) || ForceDownloadExternalFiles=1)
     {
         SoundBeep
         UrlDownloadToFile, %historyFileURL%, %historyFile%
         Sleep, 4000
     }

     If FileExist(historyFile)
     {
         FileRead, Contents, %historyFile%
         If not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             If InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                 FileGetTime, fileDate, %historyFile%
                 timeNow := %A_Now%
                 EnvSub, timeNow, %fileDate%, Days

                 If (timeNow > 10)
                    MsgBox, Version history seems too old. Please use the Update now option from the tray menu. The file will be opened now.

                Run, %historyFile%
             } Else
             {
                SoundBeep
                MsgBox, 4,, Corrupt file: keypress-osd-changelog.txt. The attempt to download it seems to have failed. To try again file must be deleted. Do you agree?
                IfMsgBox, Yes
                   FileDelete, %historyFile%
             }
         }
     } Else 
     {
         SoundBeep
         MsgBox, Missing file: %historyFile%. The attempt to download it seems to have failed.
     }
}

Is64BitExe(path) {
  DllCall("kernel32\GetBinaryType", "AStr", path, "UInt*", type)
  Return (6 = type)
}

miniUpdateChecker() {
   iniURL := baseURL IniFile
   iniTMP := "updateInfo.ini"
   UrlDownloadToFile, %iniURL%, %iniTmp%
   Sleep, 700
   If FileExist(iniTmp)
   {
      IniRead, checkVersion, %iniTmp%, SavedSettings, version
      IniRead, newDate, %iniTmp%, SavedSettings, releaseDate
      Sleep, 70
      IniDelete, %iniTmp%, SavedSettings
      IniDelete, %iniTmp%, TempSettings
      Sleep, 70
      IniWrite, %checkVersion%, %iniTmp%, SavedSettings, version
      IniWrite, %newDate%, %iniTmp%, SavedSettings, releaseDate 
   }
}

checkUpdateExistsAbout() {
  iniTMP := "updateInfo.ini"
  If FileExist(iniTMP)
  {
      IniRead, checkVersion, %iniTmp%, SavedSettings, version
      IniRead, newDate, %iniTmp%, SavedSettings, releaseDate
  } Else Return 0

  If (checkVersion="ERROR")
  {
      Return 0
  } Else If (version!=checkVersion)
  {
      msgReturn := "Version available online: "checkVersion ". Released: " newDate
      Return msgReturn
  } Else If (version=checkVersion)
  {
      Return 0
  } Else Return 0
}

checkUpdateExists() {
  Static uknUpd := "Unable to determine if`na new version is available."
  Static noUpd := "No new version is available."
       , forceUpd := "`n`nForce an update attempt?"
  iniURL := baseURL IniFile
  iniTMP := "externINI.ini"
  UrlDownloadToFile, %iniURL%, %iniTmp%
  Sleep, 900
  Global lastTypedSince := A_TickCount
  If FileExist(iniTMP)
  {
     IniRead, checkVersion, %iniTmp%, SavedSettings, version
     IniRead, newDate, %iniTmp%, SavedSettings, releaseDate
     Sleep, 25
     FileDelete, %iniTMP%
  } Else
  {
     Sleep, 25
     MsgBox, 4,, %uknUpd%%forceUpd%
     IfMsgBox, Yes
        Return 1
  }
  If (checkVersion="ERROR")
  {
     MsgBox, 4,, %uknUpd%%forceUpd%
     IfMsgBox, Yes
        Return 1
  } Else If (version!=checkVersion)
  {
     ShowLongMsg("Version available online: v" checkVersion " - " newDate)
     Sleep, 1500
     Return 1
  } Else If (version=checkVersion)
  {
     MsgBox, 4,, %noUpd%%forceUpd%
     IfMsgBox, Yes
        Return 1
  }
  Return 0
}

updateNow() {
     If (prefOpen=1)
     {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
     }
     continueExec := checkUpdateExists()
     If (continueExec=0)
        Return

     binaryUpdater := "updater.bat"
     If (!FileExist(binaryUpdater) && A_IsCompiled)
     {
;        MsgBox, Updater is missing updater.bat. Unable to proceed further.
;        Return
         FileInstall, updater.bat, updater.bat
     }

     MsgBox, 4, Question, Do you want to abort updating?
     IfMsgBox, Yes
     {
       verifyNonCrucialFilesRan := 1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
       Return
     }
     If (A_IsSuspended!=1)
        SuspendScript()
     Sleep, 150
     prefOpen := 1
     mainFileBinary := (Is64BitExe(A_ScriptName)=1) ? "keypress-osd-x64.exe" : "keypress-osd-x32.exe"
     mainFileTmp := A_IsCompiled ? "new-keypress-osd.exe" : "temp-keypress-osd.ahk"
     mainFile := A_IsCompiled ? mainFileBinary : "keypress-osd.ahk"
     mainFileURL := baseURL mainFile
     zipFile := "lib.zip"
     zipFileTmp := zipFile
     zipUrl := baseURL zipFile

     ShowLongMsg("Updating files: 1 / 2. Please wait...")
     UrlDownloadToFile, %mainFileURL%, %mainFileTmp%
     Sleep, 3000

     If FileExist(mainFileTmp)
     {
         FileRead, Contents, %mainFileTmp%
         If not ErrorLevel
         {

             StringLeft, Contents, Contents, 31
             If InStr(contents, "; KeypressOSD.ahk - main file") || (InStr(contents, "MZ")=1)
             {
                ShowLongMsg("Updating files: Main code: OK")
                If doBackup
                {
                   bkpDir := A_ScriptDir "\bkp-" A_Now
                   FileCreateDir, %bkpDir%
                   FileCopy, %thisFile%, %bkpDir%
                }
                If !A_IsCompiled
                   FileMove, %mainFileTmp%, %thisFile%, 1
                Sleep, 1350
                ahkDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Main code: CORRUPT")
                Sleep, 1350
                ahkDownloaded := 0
                FileDelete, %mainFileTmp%
             }
         }
     } Else 
     {
         ShowLongMsg("Updating files: Main code: FAIL")
         Sleep, 1350
         ahkDownloaded := 0
     }

     ShowLongMsg("Updating files: 2 / 2. Please wait...")
     UrlDownloadToFile, %zipUrl%, %zipFileTmp%
     Sleep, 3000

     If FileExist(zipFileTmp)
     {
         FileRead, Contents, %zipFileTmp%
         If not ErrorLevel
         {
             StringLeft, Contents, Contents, 50
             If InStr(contents, "PK")
             {
                ShowLongMsg("Auxiliary files: OK")
                Extract2Folder(zipFileTmp,,, (doBackup ? bkpDir : ""))
                Sleep, 1350
                FileDelete, %zipFileTmp%
                zipDownloaded := 1
             } Else
             {
                ShowLongMsg("Auxiliary files: FAIL")
                Sleep, 1350
                FileDelete, %zipFileTmp%
                zipDownloaded := 0
             }
         }
     } Else 
     {
         ShowLongMsg("Auxiliary files: FAIL")
         Sleep, 1350
         zipDownloaded := 0
     }

     If (zipDownloaded=0 || ahkDownloaded=0)
        someErrors := 1

     If (zipDownloaded=0 && ahkDownloaded=0)
        completeFailure := 1

     If (zipDownloaded=1 && ahkDownloaded=1)
        completeSucces := 1
     If (completeFailure=1)
     {
        MsgBox, 4, Error, Unable to download any file. `n Server is offline or no Internet connection. `n`nDo you want to try again?
        IfMsgBox, Yes
           updateNow()
     }

; delete temporary files and folders in Temp [by Drugwash]
     Loop
     {
        If FileExist(tmpDir := A_Temp "\Temporary Directory " A_Index " for " zipFile)
        {
           FileSetAttrib, -RH, %tmpDir%, 2
           FileRemoveDir, %tmpDir%, 1
        } Else Break
     }

     FileDelete, UpdateInfo.ini
     If (completeSucces=1)
     {
        MsgBox, Update seems to be succesful. No errors detected. `nThe script will now reload.
        verifyNonCrucialFilesRan := 1
        IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
        If (A_IsCompiled && ahkDownloaded=1)
        {
           Run, %binaryUpdater% %thisFile%,, hide
           ExitApp
        } Else ReloadScript()
     }

     If (someErrors=1)
     {
        MsgBox, Errors occured during the update. `nThe script will now reload.
        verifyNonCrucialFilesRan := 1
        IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
        If (A_IsCompiled && ahkDownloaded=1)
        {
           Run, %binaryUpdater% %thisFile%,, Hide
           ExitApp
        } Else ReloadScript()
     }
}

MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = true) {
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires [v1.0.38+]
; because it uses FileMoveDir's mode 2.
    if (DoOverwrite = 1)
        DoOverwrite = 2  ; See FileMoveDir for description of mode 2 vs. 1.
    ; First move all the files (but not the folders):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now move all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
    }
    return ErrorCount
}

verifyNonCrucialFiles() {
     If (A_IsSuspended!=1)
     {
        GetTextExtentPoint("Initializing", FontName, FontSize, 1)
        ShowLongMsg("Initializing...")
        SetTimer, HideGUI, % -DisplayTime
     }

     If StrLen(A_GlobalStruct)<4   ; testing for AHK_H presence
        Return

     binaryUpdater := "updater.bat"
     binaryUpdaterURL := baseURL binaryUpdater
     If (!FileExist(binaryUpdater) && A_IsCompiled)
     {
;        UrlDownloadToFile, %binaryUpdaterURL%, %binaryUpdater%
        FileInstall, updater.bat, updater.bat
        StringLeft, Contents, Contents, 50
        If !InStr(contents, "TIMEOUT /T")
           FileDelete, %binaryUpdater%
     }

    zipFile := "lib.zip"
    zipFileTmp := zipFile
    zipUrl := baseURL zipFile
    SoundsZipFile := "keypress-sounds.zip"
    SoundsZipFileTmp := SoundsZipFile
    SoundsZipUrl := baseURL SoundsZipFile
    historyFile := "Lib\keypress-osd-changelog.txt"
    beepersFile := "Lib\keypress-beeperz-functions.ahk"
    DeadKeysAidFile := "Lib\keypress-keystrokes-helper.ahk"
    ripplesFile := "Lib\keypress-mouse-ripples-functions.ahk"
    mouseFile := "Lib\keypress-mouse-functions.ahk"

    faqHtml := "Lib\help\faq.html"
    presentationHtml := "Lib\help\presentation.html"
    shortcutsHtml := "Lib\help\shortcuts.html"
    featuresHtml := "Lib\help\features.html"
    soundFile1 := "sounds\caps.wav"
    soundFile2 := "sounds\clickM.wav"
    soundFile3 := "sounds\clickR.wav"
    soundFile4 := "sounds\clicks.wav"
    soundFile5 := "sounds\cups.wav"
    soundFile6 := "sounds\deadkeys.wav"
    soundFile7 := "sounds\firedkey.wav"
    soundFile8 := "sounds\functionKeys.wav"
    soundFile9 := "sounds\holdingKeys.wav"
    soundFile10 := "sounds\keys.wav"
    soundFile11 := "sounds\media.wav"
    soundFile12 := "sounds\modfiredkey.wav"
    soundFile13 := "sounds\mods.wav"
    soundFile14 := "sounds\num0pad.wav"
    soundFile15 := "sounds\num1pad.wav"
    soundFile16 := "sounds\num2pad.wav"
    soundFile17 := "sounds\num3pad.wav"
    soundFile18 := "sounds\num4pad.wav"
    soundFile19 := "sounds\num5pad.wav"
    soundFile20 := "sounds\num6pad.wav"
    soundFile21 := "sounds\num7pad.wav"
    soundFile22 := "sounds\num8pad.wav"
    soundFile23 := "sounds\num9pad.wav"
    soundFile24 := "sounds\numApad.wav"
    soundFile25 := "sounds\numpads.wav"
    soundFile26 := "sounds\otherDistinctKeys.wav"
    soundFile27 := "sounds\typingkeysArrowsD.wav"
    soundFile28 := "sounds\typingkeysArrowsL.wav"
    soundFile29 := "sounds\typingkeysArrowsR.wav"
    soundFile30 := "sounds\typingkeysArrowsU.wav"
    soundFile31 := "sounds\typingkeysBksp.wav"
    soundFile32 := "sounds\typingkeysDel.wav"
    soundFile33 := "sounds\typingkeysEnd.wav"
    soundFile34 := "sounds\typingkeysEnter.wav"
    soundFile35 := "sounds\typingkeysHome.wav"
    soundFile36 := "sounds\typingkeysPgDn.wav"
    soundFile37 := "sounds\typingkeysPgUp.wav"
    soundFile38 := "sounds\typingkeysSpace.wav"

    FilePack := "DeadKeysAidFile,beepersFile,ripplesFile,mouseFile,historyFile,faqHtml,presentationHtml,shortcutsHtml,featuresHtml"
    IniRead, verifyNonCrucialFilesRan, %inifile%, TempSettings, verifyNonCrucialFilesRan, 0
    IniRead, checkVersion, %IniFile%, SavedSettings, version, 0
    If !FileExist(A_ScriptDir "\Lib")
    {
        FileCreateDir, Lib
        If FileExist(A_ScriptDir "\keypress-files")
        {
          ErrorCount := MoveFilesAndFolders(A_ScriptDir "\keypress-files\*.*", A_ScriptDir "\Lib\")
          If (ErrorCount <> 0)
             MsgBox, The KeyPress files could not be moved to \Lib.
        }
        FileCreateDir, Lib\Help
        If A_IsCompiled
        {
            FileInstall, Lib\Help\faq.html, %faqHtml%
            FileInstall, Lib\Help\presentation.html, %presentationHtml%
            FileInstall, Lib\Help\shortcuts.html, %shortcutsHtml%
            FileInstall, Lib\Help\features.html, %featuresHtml%
        } Else (reloadRequired := 1)
    }

    If (version!=checkVersion)
       verifyNonCrucialFilesRan := 0

    missingAudios := 0
    If !A_IsCompiled
    {
      Loop, 38
      {
        If !FileExist(soundFile%A_Index%)
           downloadSoundPackNow := missingAudios := 1
      } Until (missingAudios=1)

      Loop, Parse, FilePack, CSV
      {
        If !FileExist(%A_LoopField%)
           downloadPackNow := 1
      } Until (downloadPackNow=1)
    }

    FileGetTime, fileDate, %historyFile%
    timeNow := %A_Now%
    EnvSub, timeNow, %fileDate%, Days

    If (timeNow > 25)
    {
      verifyNonCrucialFilesRan := 2
      IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
    }

    If (downloadPackNow=1 && verifyNonCrucialFilesRan>2)
       Return

    If (downloadPackNow=1 && verifyNonCrucialFilesRan<3 && !A_IsCompiled)
    {
       verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2
       UrlDownloadToFile, %zipUrl%, %zipFileTmp%
       Sleep, 1500

       If FileExist(zipFileTmp)
       {
           FileRead, Contents, %zipFileTmp%
           If not ErrorLevel
           {
               StringLeft, Contents, Contents, 50
               If InStr(contents, "PK")
               {
                  Extract2Folder(zipFileTmp,,, (doBackup ? bkpDir : ""))
                  Sleep, 1500
                  FileDelete, %zipFileTmp%
                  reloadRequired := 1
               } Else FileDelete, %zipFileTmp%
           }
       }
    }

    If (downloadSoundPackNow=1 && verifyNonCrucialFilesRan<4)
    {
       verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
       IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2

       UrlDownloadToFile, %SoundsZipUrl%, %SoundsZipFileTmp%
       Sleep, 1500

       If FileExist(SoundsZipFileTmp)
       {
           FileRead, Contents, %SoundsZipFileTmp%
           If not ErrorLevel
           {
               StringLeft, Contents, Contents, 50
               If InStr(contents, "PK")
               {
                  Extract2Folder(SoundsZipFileTmp, "sounds",, (doBackup ? bkpDir : ""))
                  Sleep, 1500
                  FileDelete, %SoundsZipFileTmp%
               } Else FileDelete, %SoundsZipFileTmp%
           }
       }
    }
    If (reloadRequired=1)
    {
        MsgBox, 4,, Important files were downloaded. Do you want to restart this app?
        IfMsgBox Yes
        {
           IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan
           IniWrite, %version%, %inifile%, SavedSettings, version
           ReloadScript()
        }
    }
    missingAudios := 0  ; why is this still here?????
    If !A_isCompiled
       Loop, 38
       {
         If !FileExist(soundFile%A_Index%)
            downloadSoundPackNow := missingAudios := 1
       } Until (missingAudios=1)
}

Extract2Folder(Zip, Dest="", Filename="", bkp:="") {
; function by Jess Harpur [2013] based on code by shajul (backup by Drugwash)
; https://autohotkey.com/board/topic/60706-native-zip-and-unzip-xpvista7-ahk-l/page-2

    SplitPath, Zip,, SourceFolder
    If !SourceFolder
        Zip := A_ScriptDir . "\" . Zip
    
    If !Dest {
        SplitPath, Zip,, DestFolder,, Dest
        Dest := DestFolder . "\" . Dest . "\"
    }
    If SubStr(Dest, 0, 1) <> "\"
        Dest .= "\"
    SplitPath, Dest,,,,,DestDrive
    If !DestDrive
        Dest := A_ScriptDir . "\" . Dest
    StringTrimRight, MoveDest, Dest, 1
    StringSplit, d, MoveDest, \
    dName := d%d0%

    fso := ComObjCreate("Scripting.FileSystemObject")
    If (doBackup && FileExist(bkp) && fso.FolderExists(Dest))
     {
     FileMoveDir, %MoveDest%, %bkp%\%dName%
     fso.CreateFolder(Dest)
     }
    Else If Not fso.FolderExists(Dest)   ;  http://www.autohotkey.com/forum/viewtopic.php?p=402574
     fso.CreateFolder(Dest)
       
    AppObj := ComObjCreate("Shell.Application")
    FolderObj := AppObj.Namespace(Zip)
    If Filename {
        FileObj := FolderObj.ParseName(Filename)
        AppObj.Namespace(Dest).CopyHere(FileObj, 4|16)
    } Else
    {
        FolderItemsObj := FolderObj.Items()
        AppObj.Namespace(Dest).CopyHere(FolderItemsObj, 4|16)
    }
}

SetStartUp() {
  regEntry := """" A_ScriptFullPath """"
  StringReplace, regEntry, regEntry, .ahk", .exe"
  RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
  If (ErrorLevel=1 || currentReg!=regEntry)
  {
     StringReplace, TestThisFile, thisFile, .ahk, .exe
     If !FileExist(TestThisFile)
        MsgBox, This option works only in the compiled edition of this script.
     Menu, PrefsMenu, Check, Sta&rt at boot
     RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD, %regEntry%
  } Else
  {
     RegDelete, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
     Menu, PrefsMenu, unCheck, Sta&rt at boot
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
  IniWrite, %BeepSentry%, %inifile%, SavedSettings, BeepSentry
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
  IniWrite, %KBDCapText%, %inifile%, SavedSettings, KBDCapText
  IniWrite, %KBDsuspend%, %inifile%, SavedSettings, KBDsuspend
  IniWrite, %KBDTglNeverOSD%, %inifile%, SavedSettings, KBDTglNeverOSD
  IniWrite, %KBDTglSilence%, %inifile%, SavedSettings, KBDTglSilence
  IniWrite, %KBDTglPosition%, %inifile%, SavedSettings, KBDTglPosition
  IniWrite, %KBDidLangNow%, %inifile%, SavedSettings, KBDidLangNow
  IniWrite, %KBDReload%, %inifile%, SavedSettings, KBDReload
  IniWrite, %MouseVclickColor%, %inifile%, SavedSettings, MouseVclickColor
  IniWrite, %MouseIdleColor%, %inifile%, SavedSettings, MouseIdleColor
  IniWrite, %mouseOSDbehavior%, %inifile%, SavedSettings, mouseOSDbehavior
  IniWrite, %prefsLargeFonts%, %IniFile%, SavedSettings, prefsLargeFonts
  IniWrite, %OSDshowLEDs%, %IniFile%, SavedSettings, OSDshowLEDs
  IniWrite, %EnforceSluggishSynch%, %IniFile%, SavedSettings, EnforceSluggishSynch
  IniWrite, %doBackup%, %inifile%, SavedSettings, BackupOldFiles
  IniWrite, %UseMUInames%, %inifile%, SavedSettings, UseMUInames
  IniWrite, %outputOSDtoToolTip%, %inifile%, SavedSettings, outputOSDtoToolTip
  IniWrite, %BeepsVolume%, %inifile%, SavedSettings, BeepsVolume
  IniWrite, %expandWords%, %inifile%, SavedSettings, expandWords
  IniWrite, %enableClipManager%, %inifile%, SavedSettings, enableClipManager
  IniWrite, %maximumTextClips%, %inifile%, SavedSettings, maximumTextClips
  IniWrite, %KBDclippyMenu%, %inifile%, SavedSettings, KBDclippyMenu
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
  IniRead, BeepSentry, %inifile%, SavedSettings, BeepSentry, %BeepSentry%
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
  IniRead, KBDCapText, %inifile%, SavedSettings, KBDCapText, %KBDCapText%
  IniRead, KBDsuspend, %inifile%, SavedSettings, KBDsuspend, %KBDsuspend%
  IniRead, KBDTglNeverOSD, %inifile%, SavedSettings, KBDTglNeverOSD, %KBDTglNeverOSD%
  IniRead, KBDTglSilence, %inifile%, SavedSettings, KBDTglSilence, %KBDTglSilence%
  IniRead, KBDTglPosition, %inifile%, SavedSettings, KBDTglPosition, %KBDTglPosition%
  IniRead, KBDidLangNow, %inifile%, SavedSettings, KBDidLangNow, %KBDidLangNow%
  IniRead, KBDReload, %inifile%, SavedSettings, KBDReload, %KBDReload%
  IniRead, KBDclippyMenu, %inifile%, SavedSettings, KBDclippyMenu, %KBDclippyMenu%
  IniRead, MouseVclickColor, %inifile%, SavedSettings, MouseVclickColor, %MouseVclickColor%
  IniRead, MouseIdleColor, %inifile%, SavedSettings, MouseIdleColor, %MouseIdleColor%
  IniRead, mouseOSDbehavior, %inifile%, SavedSettings, mouseOSDbehavior, %mouseOSDbehavior%
  IniRead, prefsLargeFonts, %inifile%, SavedSettings, prefsLargeFonts, %prefsLargeFonts%
  IniRead, OSDshowLEDs, %inifile%, SavedSettings, OSDshowLEDs, %OSDshowLEDs%
  IniRead, EnforceSluggishSynch, %inifile%, SavedSettings, EnforceSluggishSynch, %EnforceSluggishSynch%
  IniRead, doBackup, %inifile%, SavedSettings, BackupOldFiles, %doBackup%
  IniRead, UseMUInames, %inifile%, SavedSettings, UseMUInames, %UseMUInames%
  IniRead, outputOSDtoToolTip, %inifile%, SavedSettings, outputOSDtoToolTip, %outputOSDtoToolTip%
  IniRead, BeepsVolume, %inifile%, SavedSettings, BeepsVolume, %BeepsVolume%
  IniRead, expandWords, %inifile%, SavedSettings, expandWords, %expandWords%
  IniRead, enableClipManager, %inifile%, SavedSettings, enableClipManager, %enableClipManager%
  IniRead, maximumTextClips, %inifile%, SavedSettings, maximumTextClips, %maximumTextClips%

  CheckSettings()
  GuiX := (GUIposition=1) ? GuiXa : GuiXb
  GuiY := (GUIposition=1) ? GuiYa : GuiYb
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
    OSDalignment1 := (OSDalignment1=1 || OSDalignment1=2 || OSDalignment1=3) ? OSDalignment1 : 1
    OSDalignment2 := (OSDalignment2=1 || OSDalignment2=2 || OSDalignment2=3) ? OSDalignment2 : 3
    mouseOSDbehavior := (mouseOSDbehavior=1 || mouseOSDbehavior=2 || mouseOSDbehavior=3) ? mouseOSDbehavior : 1
    FlashIdleMouse := (FlashIdleMouse=0 || FlashIdleMouse=1) ? FlashIdleMouse : 0
    GUIposition := (GUIposition=0 || GUIposition=1) ? GUIposition : 1
    HideAnnoyingKeys := (HideAnnoyingKeys=0 || HideAnnoyingKeys=1) ? HideAnnoyingKeys : 1
    IgnoreAdditionalKeys := (IgnoreAdditionalKeys=0 || IgnoreAdditionalKeys=1) ? IgnoreAdditionalKeys : 0
    JumpHover := (JumpHover=0 || JumpHover=1) ? JumpHover : 0
    KeyBeeper := (KeyBeeper=0 || KeyBeeper=1) ? KeyBeeper : 0
    KeyboardShortcuts := (KeyboardShortcuts=0 || KeyboardShortcuts=1) ? KeyboardShortcuts : 1
    BeepSentry := (BeepSentry=0 || BeepSentry=1) ? BeepSentry : 0
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
    prefsLargeFonts := (prefsLargeFonts=0 || prefsLargeFonts=1) ? prefsLargeFonts : 0
    OSDshowLEDs := (OSDshowLEDs=0 || OSDshowLEDs=1) ? OSDshowLEDs : 1
    EnforceSluggishSynch := (EnforceSluggishSynch=0 || EnforceSluggishSynch=1) ? EnforceSluggishSynch : 0
    doBackup := (doBackup=0 || doBackup=1) ? doBackup : 0
    UseMUInames := (UseMUInames=0 || UseMUInames=1) ? UseMUInames : 1
    outputOSDtoToolTip := (outputOSDtoToolTip=0 || outputOSDtoToolTip=1) ? outputOSDtoToolTip : 0
    expandWords := (expandWords=0 || expandWords=1) ? expandWords : 0
    enableClipManager := (enableClipManager=0 || enableClipManager=1) ? enableClipManager : 0

    If (mouseOSDbehavior=1)
    {
        DragOSDmode := 0
        JumpHover := 0
    } Else If (mouseOSDbehavior=2)
    {
        DragOSDmode := 0
        JumpHover := 1
    } Else If (mouseOSDbehavior=3)
    {
        DragOSDmode := 1
        JumpHover := 0
    }

    If (UpDownAsHE=1 && UpDownAsLR=1)
       UpDownAsLR := 0

    If (VisualMouseClicks=1 && MouseClickRipples=1)
       VisualMouseClicks := 0

    If (ShowSingleKey=0)
       DisableTypingMode := 1

    If (DisableTypingMode=1)
    {
       OnlyTypingMode := 0
       MediateNavKeys := 0
       sendJumpKeys := 0
       EnforceSluggishSynch := 0
    }

    If (OnlyTypingMode=1 && enterErasesLine=0)
    {
       sendJumpKeys := 0
       MediateNavKeys := 0
       enableTypingHistory := 0
    }

    If (DisableTypingMode=0 && OnlyTypingMode=0)
       enterErasesLine := 1

    If (AutoDetectKBD=0)
       ConstantAutoDetect := 0

; verify if numeric values, otherwise, defaults
  If ClickScaleUser is not digit
     ClickScaleUser := 10

  If DisplayTimeUser is not digit
     DisplayTimeUser := 3

  If DisplayTimeTypingUser is not digit
     DisplayTimeTypingUser := 10

  If ReturnToTypingUser is not digit
     ReturnToTypingUser := 20

  If maximumTextClips is not digit
     maximumTextClips := 10

  If typingDelaysScaleUser is not digit
     typingDelaysScaleUser := 7

  If BeepsVolume is not digit
     BeepsVolume := 60

  If FontSize is not digit
     FontSize := 20

  If GuiWidth is not digit
     GuiWidth := 350

  If maxGuiWidth is not digit
     maxGuiWidth := 500

  If IdleMouseAlpha is not digit
     IdleMouseAlpha := 70

  If MouseHaloAlpha is not digit
     MouseHaloAlpha := 130

  If MouseHaloRadius is not digit
     MouseHaloRadius := 85

  If MouseIdleAfter is not digit
     MouseIdleAfter := 10

  If MouseIdleRadius is not digit
     MouseIdleRadius := 130

  If MouseVclickAlpha is not digit
     MouseVclickAlpha := 150

     defOSDautosizeFactory := Round(A_ScreenDPI / 1.18)
  If OSDautosizeFactory is not digit
     OSDautosizeFactory := defOSDautosizeFactory

  If ShowPrevKeyDelay is not digit
     ShowPrevKeyDelay := 300

  If MouseRippleMaxSize is not digit
     MouseRippleMaxSize := 155

  If MouseRippleThickness is not digit
     MouseRippleThickness := 10

; verify minimum numeric values
    ClickScaleUser := (ClickScaleUser < 6) ? 5 : Round(ClickScaleUser)
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
    IdleMouseAlpha := (IdleMouseAlpha < 20) ? 21 : Round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha < 20) ? 21 : Round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius < 15) ? 16 : Round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter < 3) ? 3 : Round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius < 15) ? 16 : Round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha < 20) ? 21 : Round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory < 20) ? 21 : Round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay < 100) ? 101 : Round(ShowPrevKeyDelay)
    MouseRippleThickness := (MouseRippleThickness < 5) ? 5 : Round(MouseRippleThickness)
    MouseRippleMaxSize := (MouseRippleMaxSize < 90) ? 91 : Round(MouseRippleMaxSize)
    typingDelaysScaleUser := (typingDelaysScaleUser < 2) ? 1 : Round(typingDelaysScaleUser)
    BeepsVolume := (BeepsVolume < 5) ? 6 : Round(BeepsVolume)
    maximumTextClips := (maximumTextClips < 3) ? 3 : Round(maximumTextClips)

; verify maximum numeric values
    ClickScaleUser := (ClickScaleUser > 71) ? 70 : Round(ClickScaleUser)
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
    BeepsVolume := (BeepsVolume > 99) ? 99 : Round(BeepsVolume)
    maximumTextClips := (maximumTextClips > 31) ? 30 : Round(maximumTextClips)

; verify HEX values

   If (OSDbgrColor ~= "[^[:xdigit:]]") || (StrLen(OSDbgrColor)!=6)
      OSDbgrColor := "131209"

   If (CapsColorHighlight ~= "[^[:xdigit:]]") || (StrLen(CapsColorHighlight)!=6)
      CapsColorHighlight := "88AAff"

   If (MouseHaloColor ~= "[^[:xdigit:]]") || (StrLen(MouseHaloColor)!=6)
      MouseHaloColor := "eedd00"

   If (MouseVclickColor ~= "[^[:xdigit:]]") || (StrLen(MouseVclickColor)!=6)
      MouseVclickColor := "555555"

   If (MouseIdleColor ~= "[^[:xdigit:]]") || (StrLen(MouseIdleColor)!=6)
      MouseIdleColor := "333333"

   If (TypingColorHighlight ~= "[^[:xdigit:]]") || (StrLen(TypingColorHighlight)!=6)
      TypingColorHighlight := "12E217"
;
   If (OSDtextColor ~= "[^[:xdigit:]]") || (StrLen(OSDtextColor)!=6)
      OSDtextColor := "FFFEFA"

   FontName := (StrLen(FontName)>2) ? FontName
            : (A_OSVersion!="WIN_XP") ? "Arial"
            : FileExist(A_WinDir "\Fonts\ARIALUNI.TTF") ? "Arial Unicode MS" : "Arial"
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
   If (Capture2Text=1 || prefOpen=1)
   {
      SoundBeep, 300, 900
      Return
   }
   Sleep, 10
   checkWindowKBD()
   Sleep, 10
   createTypingWindow()
   SecondaryTypingMode := !SecondaryTypingMode

   If (SecondaryTypingMode=1)
   {
       Window2ActivateHwnd := WinExist("A")
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
       If (sendKeysRealTime=0)
           backTypeCtrl := ""
       CalcVisibleText()
       OnMSGchar := ""
       SetTimer, checkTypingWindow, on, 700, -10
   } Else
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
   If (NeverDisplayOSD=0)
   {
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
   } Else
   {
      Sleep, 300
      HideGUI()
   }
   OnMessage(0x102, "CharMSG", 2)
   OnMessage(0x103, "deadCharMSG", 2)
   Return Window2ActivateHwnd
}

checkTypingWindow() {
   IfWinNotActive, KeyPressOSDtyping
   {
       backTypeCtrl := (typed || A_TickCount-lastTypedSince > DisplayTimeTyping) ? typed : backTypeCtrl
       Sleep, 200
       If (pasteOnClick=1 && sendKeysRealTime=0)
          sendOSDcontent()
       Sleep, 45
       SwitchSecondaryTypingMode()
   }
}

CharMSG(wParam, lParam) {
    If (SecondaryTypingMode=0)
       Return

    OnMSGchar := chr(wParam)
    If RegExMatch(OnMSGchar, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
    {
       InsertChar2caret(OnMSGchar)
       If (sendKeysRealTime=1)
          ControlSend, , {raw}%OnMSGchar%, %Window2Activate%
    }
    Global deadKeyPressed := 9900
    Global lastTypedSince := A_TickCount
    OnMSGchar := ""
    OnMSGdeadChar := ""
    CalcVisibleText()
    ShowHotkey(visibleTextField)
    If (KeyBeeper=1 || CapslockBeeper=1)
       SetTimer, charMSGbeeper, 40
}

charMSGbeeper() {
    beeperzDefunctions.ahkPostFunction["OnLetterPressed", ""]
    SetTimer,, off
}

deadCharMSG(wParam, lParam) {
  If (SecondaryTypingMode=0)
     Return

  Sleep, 50
  OnMSGdeadChar := chr(wParam) ; & 0xFFFF
  StringReplace, visibleTextField, visibleTextField, %lola%, %OnMSGdeadChar%
  ShowHotkey(visibleTextField)
  Global deadKeyPressed := A_TickCount
  If (deadKeyBeeper=1)
     beeperzDefunctions.ahkPostFunction["OnDeathKeyPressed", ""]
  SetTimer, returnToTyped, 850, -10
}

saveGuiPositions() {
  If (prefOpen=0)
     SetTimer, HideGUI, 1500

  If (GUIposition=1)
  {
     GuiYa := GuiY
     GuiXa := GuiX
     If (prefOpen=0)
     {
        IniWrite, %GuiXa%, %inifile%, SavedSettings, GuiXa
        IniWrite, %GuiYa%, %inifile%, SavedSettings, GuiYa
     }

     If (prefOpen=1)
     {
       GuiControl, SettingsGUIA:, GuiXa, %GuiX%
       GuiControl, SettingsGUIA:, GuiYa, %GuiY%
     }
  } Else
  {
     GuiYb := GuiY
     GuiXb := GuiX
     If (prefOpen=0)
     {
        IniWrite, %GuiXb%, %inifile%, SavedSettings, GuiXb
        IniWrite, %GuiYb%, %inifile%, SavedSettings, GuiYb
     }

     If (prefOpen=1)
     {
       GuiControl, SettingsGUIA:, GuiXb, %GuiX%
       GuiControl, SettingsGUIA:, GuiYb, %GuiY%
     }
  }

  If (OSDalignment>1)
    {
      GuiGetSize(Wid, Heig, 1)
      If (OSDalignment=3)
         dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid) : Round(dGuiX)
      If (OSDalignment=2)
         dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid)/2 : Round(dGuiX)
      Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY%
  }
}

checkifRunningWindow() {
  DetectHiddenWindows, on
  Sleep, 10
  WinGet, otherKP, id, KeyPressOSDwin
;  If otherKP not in %OSDhandles%
;     KillScript(0)
  DetectHiddenWindows, off
  SetTimer, , off
}

checkIfRunning() {
    IniRead, prefOpen2, %IniFile%, TempSettings, prefOpen, -
    If (prefOpen2=1)
    {
        Sleep, 15
        SoundBeep
        prefOpen := 0
        IniWrite, %prefOpen%, %inifile%, TempSettings, prefOpen
        MsgBox, 4,, The app seems to be running `nor did not close properly. Continue?
        IfMsgBox, Yes
          Return
        ExitApp
    } Else SetTimer, checkifRunningWindow, 2000, 500
}

KeyStrokeReceiver(wParam, lParam) {
    If (NeverDisplayOSD=1 || SecondaryTypingMode=1 || prefOpen=1)
       Return true

    If TrueRmDkSymbol && (A_TickCount-deadKeyPressed < 9000) || (DeadKeys=0) && (A_TickCount-deadKeyPressed < 9000) || (DoNotBindDeadKeys=1)
    {
       StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
       testKey := StrGet(StringAddress)  ; Copy the string out of the structure.
       If RegExMatch(testKey, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
          externalKeyStrokeReceived := testKey
    }
    Return true
}

;==========================================================
; functions from [CLASS] Lyt - Keyboard layout (language) operation
; by Stealzy: https://autohotkey.com/boards/viewtopic.php?t=28258
;==========================================================

ChangeGlobal(HKL, INPUTLANGCHANGE:=0) { ; in all windows
    IfNotEqual A_DetectHiddenWindows, On, DetectHiddenWindows % (prevDHW := "Off") ? "On" : ""
    WinGet List, List
    Loop % List
         Change(HKL, INPUTLANGCHANGE, List%A_Index%)
    DetectHiddenWindows % prevDHW
}

Change(HKL, INPUTLANGCHANGE, hWnd) {
    PostMessage, 0x0050, % HKL ? "" : INPUTLANGCHANGE, % HKL ? HKL : "",
    , % "ahk_id" ((hWndOwn := DllCall("GetWindow", Ptr,hWnd, UInt,GW_OWNER:=4, Ptr)) ? hWndOwn : hWnd)
}

GetInputHKL(win := "") {

  If (win = 0)
     Return,, ErrorLevel := "Window not found"
  hWnd := (win = "")
          ? WinExist("A")
          : win + 0
            ? WinExist("ahk_id" win)
            : WinExist(win)
  If (hWnd = 0)
      Return,, ErrorLevel := "Window " win " not found"

  WinGetClass, class
  If (class == "ConsoleWindowClass") {
      WinGet, consolePID, PID
      DllCall("kernel32\AttachConsole", "Ptr", consolePID)
      DllCall("kernel32\GetConsoleKeyboardLayoutNameW", "Str", KLID:="00000000")
      DllCall("kernel32\FreeConsole")
      Return, ("0x" KLID)  ; this is not right but we better return something than nothing, it may work
  } Else {
    ; Don't truncate HKL even on x86!
    Return DllCall("user32\GetKeyboardLayout", "Ptr", DllCall("user32\GetWindowThreadProcessId", "Ptr", hWnd, "UInt", 0, "Ptr"), "Ptr")
  }
}
calcNewVolume() {
  SoundGet, master_volume
  If (master_volume>50 && BeepsVolume>50)
  {
     val := BeepsVolume - master_volume/3
  } Else If (master_volume<49 && BeepsVolume>50)
  {
     val := BeepsVolume + round(master_volume/6)
  } Else If (master_volume<50 && BeepsVolume<50)
     val := BeepsVolume + master_volume/4
  Else
     val := BeepsVolume
  If (val>99)
     val := 99
  Return val 
}

;================================================================
; functions by Drugwash. Direct contribuitor to this script. Many thanks!
; ===============================================================

SetMyVolume(val:=100, r:="", egzit:=0) {
  If (egzit=0)
     val := calcNewVolume()

  v := Round(val*655.35), vr := r="" ? v : Round(r*655.35)
  DllCall("winmm\waveOutSetVolume", "UInt", 0, "UInt", (v|vr<<16))
}

GetMyVolume(ByRef vl) {
  DllCall("winmm\waveOutGetVolume", "UInt", 0, "UIntP", vol)
  vl := Round(100*(vol&0xFFFF)/0xFFFF)
  Return Round(100*(vol>>16)/0xFFFF)
}

GetLocaleInfo(ByRef strg, loc, HKL:=0) {
; LOCALE_SLANGUAGE=0x2, LOCALE_SABBREVLANGNAME=0x3
; LOCALE_SISO639LANGNAME=0x59, LOCALE_SISO3166CTRYNAME=0x5A
Static A_CharSize := A_IsUnicode ? 2 : 1
LCID := HKL & 0xFFFF
If sz := DllCall("GetLocaleInfo"
       , "UInt" , LCID
       , "UInt" , loc
       , "Ptr"  , 0
       , "UInt" , 0)
     {
       VarSetCapacity(strg, sz*A_CharSize, 0)
       DllCall("GetLocaleInfo"
       , "UInt" , LCID
       , "UInt" , loc
       , "Str"  , strg
       , "UInt" , sz)
     }
Else strg := "Error " A_LastError " LCID: " LCID
Return sz
}

LoadImage(fpath, t, idx:=0, sz:=0) {
    Static type := "BIC"
    Loop, Parse, type
      If (t=A_LoopField)
        it := A_Index-1
    Loop, %fpath%
      {
      fullpath := A_LoopFileLongPath
      ext := A_LoopFileExt
      }
    If ext=exe
      {
        hM := DllCall("kernel32\LoadLibraryW", "Str", fullPath, "Ptr")
        hImg := DllCall("user32\LoadImageW", "Ptr", hM, "UInt", idx, "UInt", it, "Int", sz, "Int", sz, "UInt", 0x8000, "Ptr")
        DllCall("kernel32\FreeLibrary", "Ptr", hM)
      }
    Else If ext in bmp,ico,cur,ani
        hImg := DllCall("user32\LoadImageW", "Ptr", 0, "Str", fullPath, "UInt", it, "Int", sz, "Int", sz, "UInt", 0x2010, "Ptr")
return hImg
}

HasIME(HKL, bool:=1) {
  If (A_OSVersion!="WIN_XP")
     Return False
  If bool
     Return ((HKL>>28)&0xF=0xE) ? 1 : 0
  Return ((HKL>>28)&0xF=0xE) ? "Yes" : "No"
}

findIMEname(givenKLID) {
  Static skey := "Software\Microsoft\CTF\TIP"
  s2 := "0x" givenKLID
  Loop, HKLM, %skey%, 2
  {
  s1 := A_LoopRegName
  Loop, HKLM, %skey%\%s1%\LanguageProfile\%s2%, 2
   {
    s3 := A_LoopRegName
    desc := GetIMEName(s1 "\LanguageProfile\" s2 "\" s3)
    RegRead, sub, HKLM, %skey%\%s1%\LanguageProfile\%s2%\%s3%, SubstituteLayout
    If !desc
       continue
    layout := Hex2Str(s2, 8, 0, 1)  ; this is a KLID
    subst := Hex2Str(sub, 8, 0, 1)  ; this is also a KLID
    If (givenKLID = layout OR givenKLID = subst)
       Return desc
   }
  }
}

KLID2LCID(KLID) {
    r := "0x" KLID
    Return (r & 0xFFFF)
}

GetLocaleTextDir(KLID, ByRef rtl, ByRef vh, ByRef vbt, bool:=1) {
; inspired by Michael S. Kaplan: http://archives.miloush.net/michkap/archive/2006/03/03/542963.html
    Static A_CharSize := A_IsUnicode ? 2 : 1
    LCID := KLID2LCID(KLID)
    If !sz := DllCall("kernel32\GetLocaleInfoW"
      , "UInt"  , LCID
      , "UInt"  , 0x58          ; LOCALE_FONTSIGNATURE
      , "Ptr"    , 0
      , "UInt"  , 0)
      Return False
    VarSetCapacity(ls, sz*A_CharSize, 0)
    If !DllCall("kernel32\GetLocaleInfoW"
      , "UInt"  , LCID
      , "UInt"  , 0x58          ; LOCALE_FONTSIGNATURE
      , "Ptr"    , &ls            ; LOCALESIGNATURE struct
      , "UInt"  , sz)
      Return False
    r := NumGet(ls, 12, "UInt")
    If bool
        {
        rtl := (r>>27) &1, vh := (r>>28) &1, vbt := (r>>29) &1
        }
    Else
        {
        rtl := (r>>27) &1 ? "Yes" : "No", vh := (r>>28) &1 ? "Yes" : "No", vbt := (r>>29) &1 ? "Yes" : "No"
        }
    Return True
}

GetLayoutInfo(KLID, hkl) {
    Global dbg
    Static MODei := ",shift,altGr,shAltGr"

    loadedLangz := 1
    IniWrite, %loadedLangz%, %langFile%, Options, loadedLangz
    StringUpper, KLID, KLID
    dbg .= "[" KLID "]`n"
    dbg .= "name=" ISOcodeCulture(KLID) GetLayoutDisplayName(KLID) "`n"
    GetLocaleTextDir(KLID, isRTL, isVert, isUp)
    dbg .= "isRTL=" isRTL  "`n"
    hasThisIME := HasIME(HKL)
    dbg .= "hasIME=" hasThisIME "`n"
    isVertUp := 0
    If (isVert=1 || isUp=1)
       isVertUp := 1
    dbg .= "isVertUp=" isVertUp "`n"
    KBDisUnsupported := 0
    If (hasThisIME=1 || isVertUp=1)
       KBDisUnsupported := 1
    dbg .= "KBDisUnsupported=" KBDisUnsupported "`n"
    cl := ""
    Loop, Parse, MODei, CSV
    {
      If DK := GetDeadKeys(HKL, A_Index)
         cl .= "DK" A_LoopField "=" DK "`n"
    }
    dbg .= (cl ? "hasDKs=1`n" cl :"hasDKs=0`n")
    Return dbg
}

GetLayoutsInfo() {
    Global dbg
    Static mod := ",shift,altGr,shAltGr"

    REGentireList := dumpRegLangData()
    Sleep, 50
    currHKL := DllCall("user32\GetKeyboardLayout", "UInt", 0, "Ptr")  ; Get layout for current thread
    While DllCall("msvcrt\_kbhit", "CDecl")
          DllCall("msvcrt\_getche", "CDecl")      ; Clear keyboard buffer
    dbg := "`n"

    If count := DllCall("user32\GetKeyboardLayoutList", "UInt", 0, "Ptr", 0)
    {
      VarSetCapacity(hklbuf, (++count)*A_PtrSize, 0)
      If count := DllCall("user32\GetKeyboardLayoutList", "UInt", count, "Ptr", &hklbuf)
      {
        loadedLangz := 1, KBDsCount := 0
        IniWrite, %loadedLangz%, %langFile%, Options, loadedLangz
        Loop, %count%
        {
          HKL := NumGet(hklbuf, A_PtrSize*(A_Index-1), "Ptr")
          If DllCall("user32\ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0)  ; 0x100=KLF_SETFORPROCESS
             If DllCall("user32\GetKeyboardLayoutNameW", "Str", KLID:="00000000")
             {
               If (InStr(KLIDlist, KLID) || !InStr(REGentireList, KLID))
                  Continue
               KBDsCount++
               StringUpper, KLID, KLID
               KLIDlist .= KLID ","
               dbg .= "[" KLID "]`n"
               dbg .= "HKL=" HKL "`n"
               dbg .= "name=" GetLayoutDisplayName(KLID) "`n"
               GetLocaleTextDir(KLID, isRTL, isVert, isUp)
               dbg .= "isRTL=" isRTL  "`n"
               hasThisIME := HasIME(HKL)
               dbg .= "hasIME=" hasThisIME "`n"
               isVertUp := 0
               If (isVert=1 || isUp=1)
                  isVertUp := 1
               dbg .= "isVertUp=" isVertUp "`n"
               KBDisUnsupported := 0
               If (hasThisIME=1 || isVertUp=1)
                  KBDisUnsupported := 1
               dbg .= "KBDisUnsupported=" KBDisUnsupported "`n"
               cl := ""
               Loop, Parse, mod, CSV
               {
                 If DK := GetDeadKeys(HKL, A_Index)
                   cl .= "DK" A_LoopField "=" DK "`n"
               }
               dbg .= (cl ? "hasDKs=1`n" cl :"hasDKs=0`n")
               dbg .= "`n"
             }
        }
        StringTrimRight, KLIDlist, KLIDlist, 1
        IniWrite, %KLIDlist%, %langFile%, Options, KLIDlist
        IniWrite, %KBDsCount%, %langFile%, Options, KBDsDetected
      }
      VarSetCapacity(hklbuf, 0)
    }
    While DllCall("msvcrt\_kbhit", "CDecl")
          DllCall("msvcrt\_getche", "CDecl")      ; Clear keyboard buffer
    DllCall("user32\ActivateKeyboardLayout", "Ptr", currHKL, "UInt", 0)  ; Restore layout for current thread
    Return dbg
}

GetDeadKeys(hkl, i, c:=0) {
Static A_CharSize := A_IsUnicode ? 2 : 1
  VarSetCapacity(lpKeyState,256,0)
  If i=2
    NumPut(0x80, lpKeyState, 0x10, "UChar")  ; VK_SHIFT
  Else If i=3
    {
    NumPut(0x80, lpKeyState, 0x11, "UChar")  ; VK_CONTROL
    NumPut(0x80, lpKeyState, 0x12, "UChar")  ; VK_MENU
    }
  Else If i=4
    {
    NumPut(0x80, lpKeyState, 0x10, "UChar")  ; VK_SHIFT
    NumPut(0x80, lpKeyState, 0x11, "UChar")  ; VK_CONTROL
    NumPut(0x80, lpKeyState, 0x12, "UChar")  ; VK_MENU
    }
Loop, 256
  {
  uScanCode := A_Index-1
  VarSetCapacity(pwszBuff, A_CharSize*(cchBuff:=5), 0)
  uVirtKey := DllCall("MapVirtualKeyEx"
    , "UInt"  , uScanCode
    , "UInt"  , 3               ; MAPVK_VSC_TO_VK_EX=3
    , "Ptr"    , hkl)
  If !n := DllCall("ToUnicodeEx"    ; -1=dead key, 0=no trans, 1=1 char, 2+=uncombined dead char+char
    , "UInt"  , uVirtKey
    , "UInt"  , uScanCode
    , "Ptr"    , &lpKeyState
    , "Ptr"    , &pwszBuff
    , "Int"    , cchBuff
    , "UInt"  , 0
    , "Ptr"    , hkl)
    continue
  If n<0
    {
    n := DllCall("ToUnicodeEx"
    , "UInt"  , uVirtKey        ; VK_SPACE 0x20
    , "UInt"  , uScanCode    ; 0x39
    , "Ptr"    , &lpKeyState
    , "Ptr"    , &pwszBuff
    , "Int"    , cchBuff
    , "UInt"  , 0
    , "Ptr"    , hkl)//2
    If c
       kstr .= StrGet(&pwszBuff, n, "UTF-16")
    Else kstr .= "vk" Hex2Str(uVirtKey, 2, 0, 1) "."
    }
  }
If !c
   StringTrimRight, kstr, kstr, 1
Return kstr
}

Hex2Str(val, len, x:=false, caps:=true) {
    VarSetCapacity(out, len*2, 32), c := caps ? "X" : "x"
    DllCall("msvcrt\sprintf", "AStr", out, "AStr", "%0" len "I64" c, "UInt64", val, "CDecl")
    Return x ? "0x" out : out
}

SHLoadIndirectString(in) {
    ; uses WStr for both in and out
    VarSetCapacity(out, 2*(sz:=256), 0)
    DllCall("shlwapi\SHLoadIndirectString", "Str", in, "Str", out, "UInt", sz, "Ptr", 0)
    Return out
}

GetLayoutDisplayName(subkey) {
    Static key := "SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    RegRead, mui, HKLM, %key%\%subkey%, Layout Display Name
    If (StrLen(mui)<4 || UseMUInames=0)
       RegRead, Dname, HKLM, %key%\%subkey%, Layout Text
    Else
       Dname := SHLoadIndirectString(mui)
    Return Dname
}

GetIMEName(subkey, usemui := 1) {
    Static key := "Software\Microsoft\CTF\TIP"
    RegRead, mui, HKLM, %key%\%subkey%, Display Description
    If (!mui OR !usemui)
      RegRead, Dname, HKLM, %key%\%subkey%, Description
    Else
      Dname := SHLoadIndirectString(mui)
    Return Dname
}

checkWindowKBD() {
    threadID := GetFocusedThread(hwnd := WinExist("A"))
    hkl := DllCall("user32\GetKeyboardLayout", "UInt", threadID)        ; 0 for current thread
    If !DllCall("user32\ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0x100)  ; hkl: 1=next, 0=previous | flags: 0x100=KLF_SETFORPROCESS
    {
      SetFormat, IntegerFast, H
      l := SubStr(hkl & 0xFFFF, 3), klid := SubStr("00000000" l, -7)
      SetFormat, IntegerFast, D
      DllCall("user32\LoadKeyboardLayoutW", "Str", klid, "UInt", 0x103)    ; AW, flags: 0x100=KLF_SETFORPROCESS 0x1=KLF_ACTIVATE 0x2=KLF_SUBSTITUTE_OK
    }
    DllCall("user32\GetKeyboardLayoutNameW", "Str", klid:="00000000")  ; AW
;    ToolTip, hwndA=%hwnd% -- hkl=%hkl% -- klid=%klid%
    Return klid
}

GetFocusedThread(hwnd := 0) {
    If !hwnd
       Return 0  ; current thread
    tid := DllCall("user32\GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", NULL)
    VarSetCapacity(GTI, sz := 24+6*A_PtrSize, 0)      ; GUITHREADINFO struct
    NumPut(sz, GTI, 0, "UInt")  ; cbSize
    If DllCall("user32\GetGUIThreadInfo", "UInt", tid, "Ptr", &GTI)
       If hF := NumGet(GTI, 8+A_PtrSize, "Ptr")
          Return DllCall("user32\GetWindowThreadProcessId", "Ptr", hF, "Ptr", NULL)
    Return 0  ; current thread (actually it's an error but we couldn't care less)
}

setColors(hC, event, c, err=0) {
  ; Critical MUST be disabled below! If that's not done, script will enter a deadlock !
  Static
  oc := A_IsCritical
  Critical, Off
  If (event != "Normal")
    Return
  g := A_Gui, ctrl := A_GuiControl
  r := %ctrl% := hexRGB(Dlg_Color(%ctrl%, hC))
  Critical, %oc%
  GuiControl, %g%:+Background%r%, %ctrl%
  GuiControl, Enable, ApplySettingsBTN
  Sleep, 100
  If ctrl not in MouseHaloColor
     OSDpreview()
}

MouseMove(wP, lP, msg, hwnd) {
  Global
  Local A
  SetFormat, IntegerFast, H
  hwnd+=0, A := WinExist("A")
  SetFormat, IntegerFast, D

  If hwnd in %OSDhandles%
  {
    If (DragOSDmode=0 && JumpHover=0 && prefOpen=0 && (A_TickCount - lastTypedSince > 1000) && (A_TickCount - doNotRepeatTimer > 1000))
        HideGUI()
    Else If (DragOSDmode=1 || prefOpen=1)
    {
        DllCall("user32\SetCursor", "Ptr", hCursM)
        If !(wP&0x13)    ; no LMR mouse button is down, we hover
        {
          If A not in %OSDhandles%
             hAWin := A
        } Else If (wP&0x1)  ; L mouse button is down, we're dragging
        {
          SetTimer, HideGUI, Off
          SetTimer, returnToTyped, Off
          GuiControl, OSD:Disable, Edit1  ; it won't drag if it's not disabled
          While GetKeyState("LButton", "P")
          {
              PostMessage, 0xA1, 2,,, ahk_id %hOSD%
              DllCall("user32\SetCursor", "Ptr", hCursM)
          }
          GuiControl, OSD:Enable, Edit1
          SetTimer, trackMouseDragging, -1
          Sleep, 0
        }
    }
  }
  Else If colorPickerHandles
     If hwnd in %colorPickerHandles%
        DllCall("user32\SetCursor", "Ptr", hCursH)
}

trackMouseDragging() {
  Global
  DetectHiddenWindows, On
  WinGetPos, NewX, NewY,,, ahk_id %hOSD%
  If (OSDalignment>1)
  {
     CoordMode Mouse, Screen
     MouseGetPos, NewX, NewY
  }
  GuiX := !NewX ? "2" : NewX
  GuiY := !NewY ? "2" : NewY

  If hAWin
     If hAWin not in %OSDhandles%
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

    ;-- If needed, get the handle to the default GUI font
    If (DllCall("gdi32\GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("gdi32\GetStockObject","Int",DEFAULT_GUI_FONT)

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

    ;-- If both parameters are null or unspecified, return the handle to the
    ;   default GUI font.
    If (p_Name="" and p_Options="")
        Return DllCall("gdi32\GetStockObject","Int",DEFAULT_GUI_FONT)

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
        If A_LoopField is Space
            Continue

        If (SubStr(A_LoopField,1,4)="bold")
            o_Weight:=FW_BOLD
        Else If (SubStr(A_LoopField,1,6)="italic")
            o_Italic:=True
        Else If (SubStr(A_LoopField,1,4)="norm")
            {
            o_Italic   :=False
            o_Strikeout:=False
            o_Underline:=False
            o_Weight   :=FW_DONTCARE
            }
        Else If (A_LoopField="-s")
            o_Size:=0
        Else If (SubStr(A_LoopField,1,6)="strike")
            o_Strikeout:=True
        Else If (SubStr(A_LoopField,1,9)="underline")
            o_Underline:=True
        Else If (SubStr(A_LoopField,1,1)="h")
            {
            o_Height:=SubStr(A_LoopField,2)
            o_Size  :=""  ;-- Undefined
            }
        Else If (SubStr(A_LoopField,1,1)="q")
            o_Quality:=SubStr(A_LoopField,2)
        Else If (SubStr(A_LoopField,1,1)="s")
            {
            o_Size  :=SubStr(A_LoopField,2)
            o_Height:=""  ;-- Undefined
            }
        Else If (SubStr(A_LoopField,1,1)="w")
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- Convert/Fix invalid or
    ;-- unspecified parameters/options
    If p_Name is Space
        p_Name:=Fnt_GetFontName()   ;-- Font name of the default GUI font

    If o_Height is not Integer
        o_Height:=""                ;-- Undefined

    If o_Quality is not Integer
        o_Quality:=PROOF_QUALITY    ;-- AutoHotkey default

    If o_Size is Space              ;-- Undefined
        o_Size:=Fnt_GetFontSize()   ;-- Font size of the default GUI font
     Else
        If o_Size is not Integer
            o_Size:=""              ;-- Undefined
         Else
            If (o_Size=0)
                o_Size:=""          ;-- Undefined

    If o_Weight is not Integer
        o_Weight:=FW_DONTCARE       ;-- A font with a default weight is created

    ;-- If needed, convert point size to em height
    If o_Height is Space        ;-- Undefined
        If o_Size is Integer    ;-- Allows for a negative size (emulates AutoHotkey)
            {
            hDC:=DllCall("gdi32\CreateDCW","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
            o_Height:=-Round(o_Size*DllCall("gdi32\GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)/72)
            DllCall("gdi32\DeleteDC","Ptr",hDC)
            }

    If o_Height is not Integer
        o_Height:=0                 ;-- A font with a default height is created

    ;-- Create font
    hFont:=DllCall("gdi32\CreateFontW"
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
    If not hFont  ;-- Zero or null
        Return True

    Return DllCall("gdi32\DeleteObject","Ptr",hFont) ? True:False
}

Fnt_GetFontName(hFont:="") {
    Static Dummy87890484
          ,DEFAULT_GUI_FONT    :=17
          ,HWND_DESKTOP        :=0
          ,OBJ_FONT            :=6
          ,MAX_FONT_NAME_LENGTH:=32     ;-- In TCHARS

    ;-- If needed, get the handle to the default GUI font
    If (DllCall("gdi32\GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("gdi32\GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("user32\GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("gdi32\SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the font name
    VarSetCapacity(l_FontName,MAX_FONT_NAME_LENGTH*(A_IsUnicode ? 2:1))
    DllCall("gdi32\GetTextFaceW","Ptr",hDC,"Int",MAX_FONT_NAME_LENGTH,"Str",l_FontName)

    ;-- Release the objects needed by the GetTextFace function
    DllCall("gdi32\SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("user32\ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
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

    ;-- If needed, get the handle to the default GUI font
    If (DllCall("gdi32\GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("gdi32\GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("user32\GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("gdi32\SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Collect the number of pixels per logical inch along the screen height
    l_LogPixelsY:=DllCall("gdi32\GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)

    ;-- Get text metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("gdi32\GetTextMetricsW","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Convert em height to point size
    l_Size:=Round((NumGet(TEXTMETRIC,0,"Int")-NumGet(TEXTMETRIC,12,"Int"))*72/l_LogPixelsY)
        ;-- (Height - Internal Leading) * 72 / LogPixelsY

    ;-- Release the objects needed by the GetTextMetrics function
    DllCall("gdi32\SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("user32\ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
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
    hDC := DllCall("user32\GetDC","Ptr",HWND_DESKTOP)
    DllCall("gdi32\EnumFontFamiliesExW"
        ,"Ptr",hDC                                      ;-- hdc
        ,"Ptr",&LOGFONT                                 ;-- lpLogfont
        ,"Ptr",RegisterCallback("Fnt_EnumFontFamExProc","Fast") ;-- lpEnumFontFamExProc
        ,"Ptr",p_Flags                                  ;-- lParam
        ,"UInt",0)                                      ;-- dwFlags (must be 0)

    DllCall("user32\ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)
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
  If (StrLen(output) > StrLen(input) + StrLen(insert))
    ((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
  return, output
}

st_count(string, searchFor="`n") {
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   Return ErrorLevel
}

st_delete(string, start=1, length=1) {
   If (Abs(start+length) > StrLen(string))
      Return string
   If (start>0)
      Return SubStr(string, 1, start-1) . SubStr(string, start + length)
   Else If (start<=0)
      Return SubStr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}

st_overwrite(overwrite, into, pos=1) {
   If (Abs(pos) > StrLen(into))
      Return into
   Else If (pos>0)
      Return SubStr(into, 1, pos-1) . overwrite . SubStr(into, pos+StrLen(overwrite))
   Else If (pos<0)
      Return SubStr(into, 1, pos) . overwrite . SubStr(into " ",(Abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0),Abs(pos+StrLen(overwrite)))
   Else If (pos=0)
      Return into . overwrite
}
;============================================================ String Things by tidbit

Cleanup() {
    SetMyVolume(VolL, VolR, 1)
    OnMessage(0x4a, "")
    OnMessage(0x200, "")
    OnMessage(0x102, "")
    OnMessage(0x103, "")
    Fnt_DeleteFont(hFont)
    func2exec := "ahkThread_Free"
    If (NOahkH!=1)
    {
       If isMouseFile
       {
        mouseFonctiones.ahkPostFunction["ToggleMouseTimerz", "Y"] ; force all timers off
        Sleep, 10
        mouseFonctiones.ahkTerminate[-100]
        %func2exec%(mouseFonctiones)
        mouseFonctiones := ""
       }

       If isRipplesFile
       {
        mouseRipplesThread.ahkPostFunction["MouseRippleClose"]
        mouseRipplesThread.ahkTerminate[-100]
        %func2exec%(mouseRipplesThread)
        mouseRipplesThread := ""
       }

       If isBeeperzFile
       {
        beeperzDefunctions.ahkTerminate[-100]
        %func2exec%(beeperzDefunctions)
        beeperzDefunctions := ""
       }

       If isKeystrokesFile
       {
        keyStrokesThread.ahkTerminate[-100]
        %func2exec%(keyStrokesThread)
        keyStrokesThread := ""
       }
    }
    Sleep, 10
    a := "Acc_Init"
    If IsFunc(a)
       %a%(1)
    DllCall("kernel32\FreeLibrary", "Ptr", hWinMM)
}

SettingsGUIAGuiEscape:
   If (A_TickCount-tickcount_start < 1000)
      Return
   If (prefOpen=1)
      CloseSettings()
   Else
      Gui, SettingsGUIA: Destroy
Return

SettingsGUIAGuiClose:
   If (prefOpen=1)
      CloseSettings()
   Else
      Gui, SettingsGUIA: Destroy
Return

CheckAcc:
#Include *i %A_ScriptDir%\Lib\keypress-acc-viewer-functions.ahk
#Include *i %A_ScriptDir%\Lib\UIA_Interface.ahk
Return

; based on AHK_H ResGet.ahk script and MSDN info [from Drugwash]
;================================================================
FindRes(lib, res, type, lang:="") {
  if !lib
    hM := 0  ; current module
  else if !hM := DllCall("kernel32\GetModuleHandleW", "Str", lib, "Ptr")
    if !hL := hM := DllCall("kernel32\LoadLibraryW", "Str", lib, "Ptr")
      Return
  if !hR := DllCall("kernel32\FindResourceW"
    , "Ptr" , hM
    , "Str" , res
    , "Str" , type
    , "Ptr")
  OutputDebug, % FormatMessage(A_ThisFunc "(" lib ", " res ", " type ", " l ")", A_LastError)
  if hL
    DllCall("kernel32\FreeLibrary", "Ptr", hL)
  Return hR
}

GetRes(ByRef bin, lib, res, type, lang:="") {
  if !lib
    hM := 0  ; current module
  else if !hM := DllCall("kernel32\GetModuleHandleW", "Str", lib, "Ptr")
    if !hL := hM := DllCall("kernel32\LoadLibraryW", "Str", lib, "Ptr")
      Return
  if !hR := DllCall("kernel32\FindResourceW"
    , "Ptr" , hM
    , "Str" , res
    , "Str" , type
    , "Ptr")
  {
  OutputDebug, % FormatMessage(A_ThisFunc "(" lib ", " res ", " type ", " l ")", A_LastError)
  Return
  }
  hD := DllCall("kernel32\LoadResource"
    , "Ptr" , hM
    , "Ptr" , hR
    , "Ptr")
  hB := DllCall("kernel32\LockResource"
    , "Ptr" , hD
    , "Ptr")
  If !sz := DllCall("kernel32\SizeofResource"
    , "Ptr" , hM
    , "Ptr" , hR
    , "UInt")
  {
  OutputDebug, Error: resource size 0 in %A_ThisFunc%(%lib%, %res%, %type%)
  Return
  }
  VarSetCapacity(bin, 0), VarSetCapacity(bin, sz, 0), 
  DllCall("ntdll\RtlMoveMemory", "Ptr", &bin, "Ptr", hB, "UInt", sz)
  DllCall("kernel32\FreeResource", "Ptr" , hD)
  if hL
    DllCall("kernel32\FreeLibrary", "Ptr", hL)
  ;outputdebug, hM=%hM% hR=%hR% hD=%hD% hB=%hB% sz=%sz% hL=%hL%
  Return sz
}

FormatMessage(ctx, msg, arg="") {
  Global
  Local txt, buf
  SetFormat, Integer, H
  msg+=0
  SetFormat, Integer, D
  DllCall("kernel32\FormatMessageW"
    , "UInt" , 0x1100 ; FORMAT_MESSAGE_FROM_SYSTEM/ALLOCATE_BUFFER
    , "Ptr"  , 0      ; lpSource
    , "UInt" , msg    ; dwMessageId
    , "UInt" , 0      ; dwLanguageId (0x0418=RO)
    , "PtrP" , buf    ; lpBuffer
    , "UInt" , 0      ; nSize
    , "Str"  , arg)   ; Arguments
  txt := StrGet(&buf, "UTF-16")
  DllCall("kernel32\LocalFree", "Ptr", buf)
  return "Error " msg " in " ctx ":`n" txt
}
;============================================================

dummy() {
    Return
    ahkThread_Free(deleteME)   ; comment/delete this line to execute this script with AHK_L
}

#SPACE::
Return

