; KeypressOSD.ahk - main file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.
;
; Script written for AHK_H / AHK_L v1.1.28 Unicode.
; For compatibility with AHK_L remove the call to
; the function addScript().
;--------------------------------------------------------------------------------------------------------------------------
;
; Change log file:
;   keypress-osd-changelog.txt
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-changelog.txt
;
; Disclaimer: this script is provided "as is", without any kind of warranty.
; The author(s) shall not be liable for any damage caused by using
; this script or its derivatives,  et cetera.
;
; =====================
; GENERAL OVERVIEW
; =====================
;
; I learned coding with this project. Therefore, throughout 
; the code you'll probably notice the lack of programming skills
; and good coding practices. However, I did my best to do it 
; as intelligble as possible.
;
; The script is organized into sections, grouped mainly by
; functionality. Some functions borrowed from other people are all 
; grouped into Section 9. In each section you can find
; additional details. Beyond this, I have been told the code
; is poorly structured, lacks a consistent coding style, and others .

; The script runs on both, AHK_H and AHK_L. To enable compatibility
; with AHK_L, the line with addScript("ahkThread_Free(deleteME)",0) 
; must be deleted or commented. When it runs with AHK_L, 
; many features will deactivated, because it has no support for
; threads.
;
; The ANSI versions of AHK are unsupported due to the nature and
; intended use of this script.
;
; This script file can be executed alone, without any additional files.
; It will attempt to download the auxiliary files. To avoid this, please
; set DownloadExternalFiles to 0.
;
; When the script first initializes, it saves the default 
; settings in an INI file, then it attempts to identify all 
; the keyboard layouts installed and gather details about 
; each: name, ID, list of dead keys, and others. See 
; function initLangFile().
; 
; At every start, KP goes through all the Virtual Key codes 
; and tests with ToUnicodeEx() and GetKeyName() if there is 
; something to bind to (a key name) - this happens in 
; CreateHotkey(). Afterwards, it loads from the 
; language file the list of dead keys and their names 
; according to the current detected keyboard layout [if 
; this is enabled]. See function IdentifyKBDlayout(). The 
; list of VKs for dead keys is used to distinctively bind
; to these and to display their symbols. One cannot use 
; ToUnicodeEx() to display the name each time such a key is 
; pressed, because it renders unusable the dead key in host apps.
; 
; The main typing mode hooks to each key using the Hotkey, 
; by Virtual Key (VK) and different modifiers. For the 
; Shift and AltGr key combinations, the script binds 
; distinctively, because it must be able to catch these 
; keys orderly and always be able to determine what key 
; name to display using ToUnicodeEx(). If it would bind 
; simply with the (*) wildcard, dead keys cease to function 
; and on slow systems, modifier detection becomes 
; unreliable. By binding specifically to each modifier and 
; key, based on the prefixes from the built-in variable 
; %A_THISHOTKEY%, the script can properly determine what to display.
; 
; When alternative hooks are enabled, a different thread 
; runs with a Loop for an Input command limited to one 
; character. The Input command is able to capture dead keys 
; combinations (accented letters). For each key pressed, I 
; use SendMessage directed to the main thread of the 
; script, which uses OnMessage for WM_COPYDATA. The 
; function KeyStrokeReceiver() associated, processes the incoming
; messages / keys. What this secondary thread sends is used
; only after a dead key was pressed. Therefore,
; the script still relies on the Hotkey commands and 
; ToUnicodeEx(). When the layout is supported, but it has 
; no dead keys, this secondary thread is never initialized.
; 
; When alternate typing mode is invoked, A new 
; window is created and focused in SwitchSecondaryTypingMode(),
; to capture keys with two OnMessages hooked to WM_CHAR and 
; WM_DEADCHAR. KP no longer relies on the Hotkey and Input 
; commands from the secondary thread. When the user hits 
; Enter, the script attempts to focus the previously active 
; window [by ID] and using SendInput, the text is sent.
;
; Compilation directives; include files in binary and set file properties
; ===========================================================
;
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
;@Ahk2Exe-SetDescription KeyPress OSD v4 [mirror keyboard and mouse usage]
;@Ahk2Exe-SetVersion 4.28.1
;@Ahk2Exe-SetCopyright Marius Şucan (2017-2018)
;@Ahk2Exe-SetCompanyName ROBODesign.ro
;@Ahk2Exe-SetOrigFilename keypress-osd.ahk

;================================================================
; Section 0. Auto-exec.
;================================================================

; Script Initialization

 #SingleInstance Force
 #NoEnv
 #MaxMem 128
 #ClipboardTimeout 3000
 #MaxHotkeysPerInterval 500
 #MaxThreads 255
 #MaxThreadsPerHotkey 255
 #MaxThreadsBuffer On
 DetectHiddenWindows, On
 ; #WinActivateForce
 ; #Warn deebug
 ComObjError(false)
 SetTitleMatchMode, 2
 SetBatchLines, -1
 ListLines, Off
 SetWorkingDir, %A_ScriptDir%
 Critical, On

 Menu, Tray, UseErrorLevel
 Menu, Tray, NoStandard
 Menu, Tray, Add, E&xit, KillScript
 Menu, Tray, Add, 
 Menu, Tray, Add, Initializing..., dummy
 Menu, Tray, Disable, Initializing...
 Menu, Tray, Tip, KeyPress OSD: Initializing...
 If !A_IsCompiled
    Menu, Tray, Icon, Lib\keypress.ico

; Default Settings

 Global IniFile           := "keypress-osd.ini"
 , LangFile               := "keypress-osd-languages.ini"
 , WordPairsFile          := "keypress-osd-pairs.ini"
 , IgnoreAdditionalKeys   := 0
 , IgnorekeysList         := "a.b.c"
 , DoNotBindDeadKeys      := 0
 , DoNotBindAltGrDeadKeys := 0
 , AutoDetectKBD          := 1     ; at start, detect keyboard layout
 , ConstantAutoDetect     := 1     ; continuously check if the keyboard layout changed; if AutoDetectKBD=0, this is ignored
 , SilentDetection        := 0     ; do not display information about language switching
 , AudioAlerts            := 0     ; generate beeps when key bindings fail
 , EnforceSluggishSynch   := 0
 , EnableAltGr            := 1
 , AltHook2keysUser       := 1
 , TypingDelaysScaleUser  := 7
 , UseMUInames            := 1
 , EnableClipManager      := 0
 , MaximumTextClips       := 10
 , MaxRTFtextClipLen      := 60000
 , DoNotPasteClippy       := 0
 
 , DisableTypingMode      := 0     ; do not echo what you write
 , OnlyTypingMode         := 0
 , AlternateTypingMode    := 1
 , EnableTypingHistory    := 0
 , ExpandWords            := 0
 , NoExpandAfterTuser     := 4    ; in seconds
 , EnterErasesLine        := 1
 , PgUDasHE               := 0     ; page up/down behaves like home/end
 , UpDownAsHE             := 0     ; up/down behaves like home/End
 , UpDownAsLR             := 0     ; up/down behaves like Left/Right
 , ShowDeadKeys           := 0
 , ShowSingleKey          := 1     ; show only key combinations ; it disables typing mode
 , HideAnnoyingKeys       := 1     ; Left click and PrintScreen can easily get in the way.
 , ShowMouseButton        := 1     ; in the OSD
 , ShowSingleModifierKey  := 1     ; make it display Ctrl, Alt, Shift when pressed alone
 , DifferModifiers        := 0     ; differentiate between left and right modifiers
 , ShowPrevKey            := 1     ; show previously pressed key, if pressed quickly in succession
 , ShowPrevKeyDelay       := 300
 , ShowKeyCount           := 1     ; count how many times a key is pressed
 , ShowKeyCountFired      := 0     ; show only key presses (0) or catch key fires as well (1)
 , NeverDisplayOSD        := 0
 , MouseOSDbehavior       := 1
 , ReturnToTypingUser     := 20    ; in seconds
 , DisplayTimeTypingUser  := 10    ; in seconds
 , AlternativeJumps       := 0
 , SendJumpKeys           := 0
 , MediateNavKeys         := 0
 , PasteOSDcontent        := 1
 , EraseTextWinChange     := 0
 , PasteOnClick           := 1
 , DisplayTimeUser        := 3     ; in seconds
 , DragOSDmode            := 0
 , JumpHover              := 0
 , OSDborder              := 0
 , GUIposition            := 1     ; toggle between positions with Ctrl + Alt + Shift + F9
 , GuiXa                  := 40
 , GuiYa                  := 250
 , GuiXb                  := 700
 , GuiYb                  := 500
 , GuiWidth               := 350
 , MaxGuiWidth            := 550
 , FontName               := (A_OSVersion="WIN_XP" && FileExist(A_WinDir "\Fonts\ARIALUNI.TF")) ? "Arial Unicode MS" : "Arial"
 , FontSize               := 19
 , PrefsLargeFonts        := 0
 , OSDalignment1          := 3     ; 1 = left ; 2 = center ; 3 = right
 , OSDalignment2          := 1     ; 1 = left ; 2 = center ; 3 = right
 , OSDbgrColor            := "131209"
 , OSDtextColor           := "FFFEFA"
 , CapsColorHighlight     := "88AAff"
 , TypingColorHighlight   := "12E217"
 , OSDshowLEDs            := 1
 , OSDautosize            := 1     ; make adjustments to the growth factors to match your font size
 , OSDsizingFactor        := calcOSDresizeFactor()
 , OutputOSDtoToolTip     := 0

; Sound-related settings

 , CapslockBeeper         := 1     ; only when the key is released
 , ToggleKeysBeeper       := 1
 , KeyBeeper              := 0     ; only when the key is released
 , DeadKeyBeeper          := 1
 , ModBeeper              := 0     ; beeps for every modifier, when released
 , MouseBeeper            := 0     ; if both, ShowMouseButton and ShowMouseVclick are disabled, mouse click beeps will never occur
 , TypingBeepers          := 0
 , DTMFbeepers            := 0
 , BeepFiringKeys         := 0
 , BeepSentry             := 0
 , BeepsVolume            := 60
 , SilentMode             := 0
 , PrioritizeBeepers      := 0     ; this will probably make the OSD stall

 , ClipMonitor            := 1     ; show clipboard changes
 , ShiftDisableCaps       := 1

; Cursor and caret settings
 , ShowMouseHalo          := 0     ; constantly highlight mouse cursor
 , ShowMouseIdle          := 0     ; locate an idling mouse with a flashing box
 , ShowMouseVclick        := 0     ; shows visual indicators for different mouse clicks
 , ShowMouseRipples       := 0
 , ShowCaretHalo          := 0
 , MouseHaloAlpha         := 130   ; from 0 to 255
 , MouseHaloColor         := "EEDD00"  ; HEX format also accepted
 , MouseHaloRadius        := 85
 , MouseIdleAfter         := 10    ; in seconds
 , MouseIdleAlpha         := 70    ; from 0 to 255
 , MouseIdleColor         := "333333"
 , MouseIdleRadius        := 130
 , MouseIdleFlash         := 1
 , MouseVclickAlpha       := 150   ; from 0 to 255
 , MouseVclickColor       := "555555"
 , MouseVclickScaleUser   := 10
 , MouseRippleMaxSize     := 180
 , MouseRippleThickness   := 10
 , MouseRippleFrequency   := 20
 , MouseRippleLbtnColor   := "ff2211"
 , MouseRippleMbtnColor   := "33cc33"
 , MouseRippleRbtnColor   := "4499ff"
 , MouseRippleWbtnColor   := "888888"
 , MouseRippleOpacity     := 160
 , CaretHaloAlpha         := 175   ; from 0 to 255
 , CaretHaloColor         := "BBAA99"  ; HEX format also accepted
 , CaretHaloHeight        := 70
 , CaretHaloWidth         := 15
 , CaretHaloShape         := 2
 , CaretHaloThick         := 0
 , CaretHaloFlash         := 1

; Script's own global shortcuts (hotkeys)
 , GlobalKBDhotkeys       := 1     ; Enable system-wide shortcuts (hotkeys)
 , KBDaltTypeMode         := "!^CapsLock"
 , KBDpasteOSDcnt1        := "^+Insert"
 , KBDpasteOSDcnt2        := "^!Insert"
 , KBDsynchApp1           := "#Insert"
 , KBDsynchApp2           := "#!Insert"
 , KBDsuspend             := "+Pause"
 , KBDTglNeverOSD         := "!+^F8"
 , KBDTglPosition         := "!+^F9"
 , KBDTglSilence          := "!+^F10"
 , KBDidLangNow           := "!+^F11"
 , KBDReload              := "!+^F12"
 , KBDCapText             := "(Disabled)"
 , KBDclippyMenu          := "#v"

 , DoBackup               := 0     ; if enabled, each update will backup previous files to a separate folder
 , ShowPreview            := 0     ; let it be a persistent setting
 , ThisFile               := A_ScriptName
 , SafeModeExec           := 0
 , DownloadExternalFiles  := 1

; Release info
 , Version                := "4.28.1"
 , ReleaseDate            := "2018 / 03 / 31"
 , hMutex, ScriptInitialized, FirstRun := 1
 , KPregEntry := "HKEY_CURRENT_USER\SOFTWARE\KeyPressOSD\v4"

; Possible caret symbols; all are WStr chars
 , Lola        := "│"   ; Main caret
 , Lola2       := "║"   ; Caret [selection mode]
 , CSmo        := "▒"   ; When a modifier is pressed

 ; symbols that appear when the caret position
 ; does not change on different key presses
 , CSle        := "▌"   ; Left
 , CSri        := "▐"   ; Right
 , CSup        := "▀"   ; Up
 , CSdo        := "▄"   ; Down
 , CSho        := CSle  ; Home
 , CSen        := CSri  ; End
 , CSpu        := CSup  ; PageUp
 , Cspd        := CSdo  ; PageDown
 , CSba        := "▓"   ; Backspace
 , CSde        := CSba  ; Delete

 ; dead keys related
 , CSx1        := "▫"   ; place-holder
 , CSx2        := "▫│"
 , CSx3        := "▪"   ; place-holder
 , CSx4        := "◐"
 , REx1        := "i)(▫│)"  ; RegEx with WStr

; Check if INIT previously failed or if KP is running and then load settings.
; These functions are in Section 8.

    RegRead, InitCheckReg, %KPregEntry%, Initializing
    If (InitCheckReg="Yes")
    {
        RegWrite, REG_SZ, %KPregEntry%, Initializing, No
        SafeModeExec := 1
        AutoDetectKBD := 0
        ConstantAutoDetect := 0
        ClipMonitor := 0
        EnableClipManager := 0
        TrayTip, KeyPress OSD, Started in Safe mode due to crashes, 5
    } Else RegWrite, REG_SZ, %KPregEntry%, Initializing, Yes

    CheckIfRunning()
    If A_IsCompiled ; If you don't condition this you'll get bogus 'app running' for each running instance of Autohotkey.exe regardless of it running this script or any other, or even being AHK_H or AHK_L
    {
       If DllCall("kernel32\OpenMutexW", "UInt", 0x100000, "UInt", False, "Str", ThisFile)
          CheckIfRunning(1)
       hMutex := DllCall("kernel32\CreateMutexW", "Ptr", NULL, "UInt", False, "Str", ThisFile)
       Sleep, 5
    }
    INIaction(0, "FirstRun", "SavedSettings")
    If (FirstRun=0)
    {
        INIsettings(0)
    } Else
    {
        CheckSettings()
        INIsettings(1)
    }

; Initialization variables. Altering these may lead to undesired results.

Global Debug := 0    ; for testing purposes
 , MouseVclickScale := MouseVclickScaleUser/10
 , DisplayTime := DisplayTimeUser*1000
 , DisplayTimeTyping := DisplayTimeTypingUser*1000
 , ReturnToTypingDelay := ReturnToTypingUser*1000
 , OSDalignment := (GUIposition=1) ? OSDalignment2 : OSDalignment1
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , GuiHeight := 50                    ; a default, later overriden
 , MaxAllowedGuiWidth := (OSDautosize=1) ? MaxGuiWidth : GuiWidth
 , OSDvisible := 0
 , OSDcontentOutput := ""
 , Capture2Text := 0
 , AccTextCaptureActive := 0
 , Prefixed := 0                      ; hack used to determine if last keypress had a modifier
 , KeyCount := 0
 , lastClickTimer := 0
 , Tickcount_start2 := A_TickCount    ; timer to keep track of OSD redraws
 , Tickcount_start := 0               ; timer to count repeated key presses
 , Typed := ""                        ; hack used to determine if user is writing
 , BackTypeCtrl := ""
 , BackTypdUndo := ""
 , TypedKeysHistory := ""
 , LastTypedSince := 0
 , EditingField := "3"
 , EditField0 := ""
 , EditField1 := " "
 , EditField2 := " "
 , EditField3 := " "
 , EditField4 := ""
 , VisibleTextField := ""
 , MaxTextChars := "4"          ; max. chars visible in the OSD in typing mode; default value, later overriden
 , Text_width := 60             ; default value, later overriden using GetTextExtentPoint()
 , CaretPos := "1"
 , PressKeyRecorded := 1
 , ExpandWordsList := []
 , ExpandWordsListEdit := ""
 , NoExpandAfter := NoExpandAfterTuser*1000
 , LastMatchedExpandPair := ""
 , ExternalKeyStrokeRecvd := "" ; for alternative hooks
 , SecondaryTypingMode := 0
 , OnMSGchar := ""
 , OnMSGdeadChar := ""
 , AlternativeHook2keys := (AltHook2keysUser=0) ? 0 : 1
 , TypingDelaysScale := TypingDelaysScaleUser / 10
 , CurrentKBD := "KeyPress OSD default: English US."
 , LoadedLangz := 0
 , KbLayoutRaw := 0
 , IsLangRTL := 0
 , DKnamez := CSx3
 , DeadKeys := 0
 , DeadKeyPressed := "9950"
 , TrueRmDkSymbol := ""
 , DKnotShifted_list := ""
 , DKshift_list := ""
 , DKaltGR_list := ""
 , Modifiers_temp := 0
 , DoNotRepeatTimer := 0
 , Window2Activate := " "
 , Window2ActivateHwnd := ""
 , FontList := []
 , CurrentPrefWindow := ""
 , PrefOpen := 0
 , MissingAudios := 0
 , GlobalPrefix := ""
 , LargeUIfontValue := 13
 , InstKBDsWinOpen, CurrentTab, AnyWindowOpen := 0
 , PreviewWindowText := "Preview │window... ║"
 , MainModsList := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
 , GlobalKBDsList := "KBDaltTypeMode,KBDpasteOSDcnt1,KBDpasteOSDcnt2,KBDsynchApp1,KBDsynchApp2,KBDTglNeverOSD,KBDTglPosition,KBDTglSilence,KBDidLangNow,KBDCapText,KBDReload,KBDsuspend,KBDclippyMenu"
 , KeysComboList := "(Disabled)|(Restore Default)|[[ 0-9 / Digits ]]|[[ Letters ]]|Right|Left|Up|Down|Home|End|Page_Down|Page_Up|Backspace|Space|Tab|Delete|Enter|Escape|Insert|CapsLock|NumLock|ScrollLock|L_Click|M_Click|R_Click|PrintScreen|Pause|Break|CtrlBreak|AppsKey|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Nav_Back|Nav_Favorites|Nav_Forward|Nav_Home|Nav_Refresh|Nav_Search|Nav_Stop|Help|Launch_App1|Launch_App2|Launch_Mail|Launch_Media|Media_Next|Media_Play_Pause|Media_Prev|Media_Stop|Pad0|Pad1|Pad2|Pad3|Pad4|Pad5|Pad6|Pad7|Pad8|Pad9|PadClear|PadDel|PadDiv|PadDot|PadHome|PadEnd|PadEnter|PadIns|PadLeft|PadRight|PadAdd|PadSub|PadMult|PadPage_Down|PadPage_Up|PadUp|PadDown|Sleep|Volume_Mute|Volume_Up|Volume_Down|WheelUp|WheelDown|WheelLeft|WheelRight|[[ VK nnn ]]|[[ SC nnn ]]"
 , hOSD, OSDhandles, dragOSDhandles, ColorPickerHandles
 , CCLVO := "-E0x200 +Border -Hdr -Multi +ReadOnly Report -Hidden AltSubmit gsetColors"
 , Emojis := "(☀|☹|☺|♥|⛄|❤|️|🌙|🌛|🌜|🌷|🌸|🎄|👄|👋|👍|👏|👙|👳|👶|👼|👽|💁|💃|💋|💏|💓|💕|💖|💗|💞|💤|💯|😀|😁|😂|😃|😄|😆|😇|😈|😉|😊|😋|😌|😍|😎|😐|😓|😔|😕|😗|😘|😙|😚|😛|😜|😝|😞|😡|😢|😥|😩|😫|😭|😮|😲|😳|😴|😶|🙁|🙂|🙃|🙈|🙊|🙏|🤔|🤢)"
 , MouseFuncThread, MouseRipplesThread, SoundsThread, KeyStrokesThread
 , IsMouseFile, IsRipplesFile, IsSoundsFile, IsKeystrokesFile, IsAcc1File, IsAcc2File, NoAhkH
 , ClipDataMD5s, CurrentClippyCount := 0
 , BaseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
 , hWinMM := DllCall("kernel32\LoadLibraryW", "Str", "winmm.dll", "Ptr")
 , volL, VolR := GetVolume(VolL)
 , ScriptelSuspendel := 0
 , ForceUpdate := 0     ; this will be used when major changes require full update

; Initializations of the core components and functionality

CreateOSDGUI()
VerifyNonCrucialFiles()
Sleep, 5
GoSub CheckAcc
Sleep, 5
If (SafeModeExec!=1)
{
   InitAHKhThreads()
   SetMyVolume()
}
Sleep, 5
CreateGlobalShortcuts()
CreateHotkey()
InitializeTray()
If (ClipMonitor=1 || EnableClipManager=1)
   OnClipboardChange("ClipChanged")

hCursM := DllCall("user32\LoadCursorW", "Ptr", NULL, "Int", 32646, "Ptr")  ; IDC_SIZEALL
hCursH := DllCall("user32\LoadCursorW", "Ptr", NULL, "Int", 32649, "Ptr")  ; IDC_HAND
OnMessage(0x200, "MouseMove")    ; WM_MOUSEMOVE
If (ExpandWords=1 && DisableTypingMode=0)
   InitExpandableWords()
If (EnableClipManager=1)
   InitClipboardManager()

If (EraseTextWinChange=1 && DisableTypingMode=0)
{
   DllCall("RegisterShellHookWindow", "UInt", hOSD)
   MsgNum := DllCall("RegisterWindowMessage", "Str","SHELLHOOK")
   OnMessage(MsgNum, "ShellMessage")
}
ModsLEDsIndicatorsManager()
Sleep, 5

ScriptInitialized := 1      ; the end of the autoexec section and INIT
RegWrite, REG_SZ, %KPregEntry%, Initializing, No
Return

;================================================================
; Section 1. Functions called by Hotkey command bindings created
; by CreateHotkey() from Section 4.
; - The functions here call typing mode related functions from Section 2.
;   In particular TypedLetter().
; - If typing mode is disabled, almost every function from here calls
;   GetKeyStr() to get its name and then display it in the OSD with
;   ShowHotkey().
; - The two mentioned functions are in Section 3.
;================================================================

OnMudPressed() {
    SetTimer, modsTimer, 100, 50
    If (NeverDisplayOSD=1 && OutputOSDtoToolTip=0)
       Return
    Static repeatCount := 1
    Static modPressedTimer
    BackTypeCtrl := Typed
    fl_prefix := checkIfModsHeld(0)
    StringReplace, keya, A_ThisHotkey, ~*,
    fl_prefix .= keya "+"
    fl_prefix := CompactModifiers(fl_prefix)
    Sort, fl_prefix, U D+
    fl_prefix := RTrim(fl_prefix, "+")
    StringReplace, fl_prefix, fl_prefix, +, %A_Space%+%A_Space%, All

    If (A_TickCount-Tickcount_start2 < 35)
       Return

    If (InStr(fl_prefix, "Shift") && ShiftDisableCaps=1)
    {
       SetCapsLockState, off
       If (OSDshowLEDs=1)
          GuiControl, OSD:, CapsLED, 0
    }

    If (StrLen(Typed)>1 && OSDvisible=1 && (A_TickCount-LastTypedSince < 4000) && (A_TickCount-modPressedTimer > 70))
       caretSymbolChangeIndicator(CSmo)

    If (A_TickCount-modPressedTimer > 150) && (OSDshowLEDs=1)
       GuiControl, OSD:, ModsLED, 100
    modPressedTimer := A_TickCount
    SetTimer, ModsLEDsIndicatorsManager, -370, 50
    If (ShowSingleModifierKey=0)
       Return

    If (InStr(fl_prefix, Modifiers_temp) && !Typed && ShowKeyCount=1 && (A_TickCount - lastClickTimer > ShowPrevKeyDelay*3))
    {
        valid_count := 1
        If (repeatCount>1)
           KeyCount := 0.1
    } Else
    {
        valid_count := 0
        Modifiers_temp := fl_prefix
        If !Prefixed
           KeyCount := 0.1
    }

    If (valid_count=1 && ShowKeyCountFired=0 && ShowKeyCount=1 && !InStr(fl_prefix, "AltGr"))
    {
       trackingPresses := (Tickcount_start2 - Tickcount_start < 50) ? 1 : 0
       repeatCount := (trackingPresses=0 && repeatCount<1) ? repeatCount+1 : repeatCount
       If (trackingPresses=1)
          repeatCount := !repeatCount ? 1 : repeatCount+1
       ShowKeyCountValid := 1
    } Else If (valid_count=1 && ShowKeyCountFired=1 && ShowKeyCount=1)
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
            Modifiers_temp := fl_prefix
            If Round(repeatCount)>1
               fl_prefix .= " (" Round(repeatCount) ")"
        } Else (repeatCount := 1)
   }

   If (StrLen(Typed)>1 && OSDvisible=1 && (A_TickCount-LastTypedSince < 4000)) || (ShowSingleKey = 0) || ((A_TickCount-Tickcount_start > 1800) && OSDvisible=1 && !Typed && KeyCount>7) || (OnlyTypingMode=1) || (A_TickCount - lastClickTimer < ShowPrevKeyDelay*3)
   {
      Sleep, 1
   } Else
   {
      If (ShowSingleModifierKey=1)
      {
         ShowHotkey(fl_prefix)
         SetTimer, HideGUI, % -DisplayTime
      }
      SetTimer, ReturnToTyped, % -DisplayTime/4
   }
}

OnMousePressed() {
    Thread, Priority, -20
    Critical, off
    SetTimer, ClicksTimer, 400, 50

    If (OnlyTypingMode=1)
       Return

    If (OutputOSDtoToolTip=0 && NeverDisplayOSD=1)
       Return

    Global lastClickTimer := A_TickCount
    Try {
        key := GetKeyStr()
        If (ShowMouseButton=1)
        {
           If (EnableTypingHistory=1)
              EditField4 := StrLen(Typed)>5 ? Typed : EditField4
           Typed := (OnlyTypingMode=1) ? Typed : "" ; concerning TypedLetter(" ") - it resets the content of the OSD
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }
    }
    LastMatchedExpandPair := ""
}

OnRLeftPressed() {
    LastMatchedExpandPair := ""
    Try {
        key := GetKeyStr()
        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Left|Right))") && (ShowSingleKey=1) && (KeyCount<10)
        {
           deadKeyProcessing()
           If (key ~= "i)^(Left)")
              CaretMover(0)
           If (key ~= "i)^(Right)")
              CaretMover(2)
           If (key ~= "i)^(.?Shift \+ Left)")
              CaretMoverSel(-1)
           If (key ~= "i)^(.?Shift \+ Right)")
              CaretMoverSel(1)

           ShowHotkey(VisibleTextField)
           SetTimer, HideGUI, % -DisplayTimeTyping
           If (CaretPos!=StrLen(Typed) && CaretPos!=1)
           {
              Global LastTypedSince := A_TickCount
              KeyCount := 1
           } Else If (KeyCount>1)
           {
              If InStr(key, "left")
                 CaretSymbolChangeIndicator(CSle, 300)
              If InStr(key, "right")
                 CaretSymbolChangeIndicator(CSri, 300)
           }
        }
        If (Prefixed && !(key ~= "i)^(.?Shift \+)")) || StrLen(Typed)<2 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0)
        {
           If (KeyCount>10 && OnlyTypingMode=0)
              Global LastTypedSince := A_TickCount - ReturnToTypingDelay

           If (EnableTypingHistory=1 && Prefixed && OnlyTypingMode=0)
              EditField4 := StrLen(Typed)>5 ? Typed : EditField4

           If (StrLen(Typed)<2)
              Typed := (OnlyTypingMode=1) ? Typed : ""

           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+)"))
           Typed := (OnlyTypingMode=1) ? Typed : ""
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
    LastMatchedExpandPair := ""
    Try {
        key := GetKeyStr()
        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Up|Down))") && (ShowSingleKey=1) && (KeyCount<10)
        {
            deadKeyProcessing()
            If (CaretPos!=StrLen(Typed) && CaretPos!=1)
               KeyCount := (UpDownAsHE=0 && UpDownAsLR=0) ? KeyCount : 1

            If (UpDownAsHE=0 && UpDownAsLR=0 && !InStr(key, "shift"))
            {
               StringReplace, Typed, Typed, %Lola2%
               CalcVisibleText()
            }

            If (UpDownAsHE=1 && UpDownAsLR=0)
            {
                StringGetPos, CaretPos3, Typed, %Lola%
                StringGetPos, CaretPos4, Typed, %Lola2%
                If (key ~= "i)^(Up)") && (CaretPos3!=0) || (key ~= "i)^(Up)") && (CaretPos4!=-1)
                {
                   StringReplace, Typed, Typed, %Lola%
                   StringReplace, Typed, Typed, %Lola2%
                   CaretPos := 1
                   Typed := ST_Insert(Lola, Typed, CaretPos)
                   MaxTextChars := MaxTextChars*2
                }

                If (key ~= "i)^(Down)")
                {
                   StringReplace, Typed, Typed, %Lola%
                   StringReplace, Typed, Typed, %Lola2%
                   CaretPos := StrLen(Typed)+1
                   Typed := ST_Insert(Lola, Typed, CaretPos)
                   MaxTextChars := StrLen(Typed)+2
                }

                If (key ~= "i)^(.?Shift \+ Down)")
                   SelectHomeEnd(1)

                If (key ~= "i)^(.?Shift \+ Up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
            }

            If (UpDownAsLR=1 && UpDownAsHE=0)
            {
                If (key ~= "i)^(Up)")
                   CaretMover(0)

                If (key ~= "i)^(Down)")
                   CaretMover(2)

                If (key ~= "i)^(.?Shift \+ Up)")
                   CaretMoverSel(-1)

                If (key ~= "i)^(.?Shift \+ Down)")
                   CaretMoverSel(1)

            }
            Global LastTypedSince := A_TickCount
            ShowHotkey(VisibleTextField)
            If (CaretPos=StrLen(Typed) || CaretPos=1 || (UpDownAsHE=0 && UpDownAsLR=0))
            {
               If (InStr(key, "up") && KeyCount>1)
                  caretSymbolChangeIndicator(CSup, 300)
               If (InStr(key, "down") && KeyCount>1)
                  caretSymbolChangeIndicator(CSdo, 300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (Prefixed && !(key ~= "i)^(.?Shift \+)") || StrLen(Typed)<1 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0))
        {
           If (KeyCount>10 && OnlyTypingMode=0)
              Global LastTypedSince := A_TickCount - ReturnToTypingDelay
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+)"))
           Typed := (OnlyTypingMode=1) ? Typed : ""
    }
}

FilterText(invsChars:=1, ByRef KaretPoz:=0, ByRef KaretPozSel:=0, ByRef TxtLength:=0, textus:=0) {
; Function required to increase compatibility with Indic
; and other languages; it skips over invisible chars and
; and converts two-part Emojis defined at the top of this file.
    invisibleChars := "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}]"
    If (textus=0)
       StringReplace, Taiped, Typed, %CSx1%,, All
    Else
       StringReplace, Taiped, textus, %CSx1%,, All
    Taiped := RegExReplace(Taiped, Emojis, "1")
    If (invsChars=1)
       Taiped := RegExReplace(Taiped, invisibleChars)
    StringGetPos, KaretPoz, Taiped, %Lola%
    StringGetPos, KaretPozSel, Taiped, %Lola2%
    TxtLength := StrLen(Taiped)
}

OnHomeEndPressed() {
    LastMatchedExpandPair := ""
    FilterText(1, exKaretPos, exKaretPosSelly, InitialTxtLength)
    Try {
        key := GetKeyStr()
        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>0 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Home|End))") && (ShowSingleKey=1) && (KeyCount<10)
        {
            deadKeyProcessing()
            If (key ~= "i)^(.?Shift \+ End)") || InStr(A_ThisHotkey, "~+End")
            {
               SelectHomeEnd(1)
               skipRest := 1
            }

            If (key ~= "i)^(.?Shift \+ Home)") || InStr(A_ThisHotkey, "~+Home")
            {
               SelectHomeEnd(0)
               If StrLen(Typed)<3
                  selectAllText()
               skipRest := 1
            }

            If ((key ~= "i)^(Home)") && skipRest!=1 && IsLangRTL=0)
            {
               If (CaretPos3!=0 || CaretPos4!=-1)
               {
                   StringReplace, Typed, Typed, %Lola%
                   StringReplace, Typed, Typed, %Lola2%
                   CaretPos := 1
                   Typed := ST_Insert(Lola, Typed, CaretPos)
                   MaxTextChars := MaxTextChars*2
               }
            }

            If ((key ~= "i)^(End)") && skipRest!=1 && IsLangRTL=0)
            {
               StringReplace, Typed, Typed, %Lola%
               StringReplace, Typed, Typed, %Lola2%
               CaretPos := StrLen(Typed)+1
               Typed := ST_Insert(Lola, Typed, CaretPos)
               MaxTextChars := StrLen(Typed)+2
            }

            Global LastTypedSince := A_TickCount
            CalcVisibleText()
            ShowHotkey(VisibleTextField)
            If (CaretPos=StrLen(Typed) || CaretPos=1)
            {
               If (InStr(key, "Home") && KeyCount>1)
                  caretSymbolChangeIndicator(CSho, 300)
               If (InStr(key, "End") && KeyCount>1)
                  caretSymbolChangeIndicator(CSen, 300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping

        }
        If (Prefixed && !(key ~= "i)^(.?Shift \+)") || StrLen(Typed)<1 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0))
        {
           If (OnlyTypingMode!=1)
           {
              If (KeyCount>10)
                 Global LastTypedSince := A_TickCount - ReturnToTypingDelay
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+)"))
           Typed := (OnlyTypingMode=1) ? Typed : ""
    }

    If (MediateNavKeys=1 && SecondaryTypingMode=0)
    {
      FilterText(1, exKaretPos2, exKaretPosSelly2, InitialTxtLength2)
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

OnPGupDnPressed() {
    LastMatchedExpandPair := ""
    Try {
        key := GetKeyStr()
        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?Page )") && (ShowSingleKey=1) && (KeyCount<10)
        {
            deadKeyProcessing()
            If (PgUDasHE=1) && (key ~= "i)^(.?Shift \+ )")
            {
                If (key ~= "i)^(.?Shift \+ Page down)")
                   SelectHomeEnd(1)

                If (key ~= "i)^(.?Shift \+ Page up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
                ShowHotkey(VisibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }

            If (EnableTypingHistory=1)
            {
                If ((key ~= "i)^(Page Down)") && OSDvisible=0 && StrLen(Typed)<3)
                {
                   Global LastTypedSince := A_TickCount - ReturnToTypingDelay
                   If (StrLen(Typed)<2)
                      Typed := (OnlyTypingMode=1) ? Typed : ""
                   ShowHotkey(key)
                   SetTimer, HideGUI, % -DisplayTime
                   Return
                }

                StringReplace, Typed, Typed, %Lola%,, All
                StringReplace, Typed, Typed, %Lola2%,, All

                If (key ~= "i)^(Page Up)")
                {
                   If (EditingField=3)
                      BackTypeCtrl := Typed
                   EditingField := (EditingField<=1) ? 1 : EditingField-1
                   Typed := editField%EditingField%
                }

                If (key ~= "i)^(Page Down)")
                {
                   If (EditingField=3)
                      BackTypeCtrl := Typed
                   EditingField := (EditingField>=3) ? 3 : EditingField+1
                   Typed := (EditingField=3) ? BackTypeCtrl : editField%EditingField%
                }
                StringReplace, Typed, Typed, %Lola%,, All
                StringReplace, Typed, Typed, %Lola2%,, All
                CaretPos := (Typed=" ") ? StrLen(Typed) : StrLen(Typed)+1
                Typed := ST_Insert(Lola, Typed, 0)
            }

            If (EnableTypingHistory=0 && PgUDasHE=1)
            {
                StringGetPos, CaretPos3, Typed, %Lola%
                StringGetPos, CaretPos4, Typed, %Lola2%
                If (key ~= "i)^(Page up)") && (CaretPos3!=0) || (key ~= "i)^(Page up)") && (CaretPos4!=-1)
                {
                   StringReplace, Typed, Typed, %Lola%
                   StringReplace, Typed, Typed, %Lola2%
                   CaretPos := 1
                   Typed := ST_Insert(Lola, Typed, CaretPos)
                   MaxTextChars := MaxTextChars*2
                }

                If (key ~= "i)^(Page down)")
                {
                   StringReplace, Typed, Typed, %Lola%
                   StringReplace, Typed, Typed, %Lola2%
                   CaretPos := StrLen(Typed)+1
                   Typed := ST_Insert(Lola, Typed, CaretPos)
                   MaxTextChars := StrLen(Typed)+2
                }
            }
            CalcVisibleText()
            ShowHotkey(VisibleTextField)

            If (CaretPos=StrLen(Typed) || CaretPos=1)
            {
               If (InStr(key, "page up") && KeyCount>1)
                  caretSymbolChangeIndicator(CSpu, 300)
               If (InStr(key, "page down") && KeyCount>1)
                  caretSymbolChangeIndicator(CSpd, 300)
            }
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (Prefixed && !(key ~= "i)^(.?Shift \+)") || !Typed || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0))
        {
           If (KeyCount>10 && OnlyTypingMode=0)
              Global LastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(Typed)<2)
              Typed := (OnlyTypingMode=1) ? Typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+)"))
           Typed := (OnlyTypingMode=1) ? Typed : ""

        If (StrLen(Typed)>1 && DisableTypingMode=0 && (A_TickCount-LastTypedSince < ReturnToTypingDelay) && KeyCount<10)
           SetTimer, ReturnToTyped, % -DisplayTime/4
    }
}

OnSpacePressed() {
    Try {
          If (DoNotBindDeadKeys=1 && AlternativeHook2keys=1 && SecondaryTypingMode=0 && DisableTypingMode=0 && DeadKeys=1)
             Sleep, 35

          key := GetKeyStr()
          If ((A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>0 && DisableTypingMode=0 && ShowSingleKey=1)
          {
             If (Typed ~= REx1) && (SecondaryTypingMode=0)
             {
                  StringReplace, Typed, Typed, %CSx2%, %TrueRmDkSymbol%%Lola%
             } Else If (SecondaryTypingMode=0)
             {
                 If TrueRmDkSymbol
                 {
                     InsertChar2caret(TrueRmDkSymbol)
                 } Else If (ExternalKeyStrokeRecvd && DoNotBindDeadKeys=1 && AlternativeHook2keys=1 && SecondaryTypingMode=0 && DisableTypingMode=0 && DeadKeys=1)
                 {
                     InsertChar2caret(ExternalKeyStrokeRecvd)
                 } Else InsertChar2caret(" ")
             }

             If (SecondaryTypingMode=1)
             {
                If (ExpandWords=1)
                   InitExpandableWords()
                If !OnMSGdeadChar
                   char2insert := OnMSGchar ? OnMSGchar : " "
                InsertChar2caret(char2insert)
             }
             deadKeyProcessing()
             If (ExpandWords=1)
                ExpandFeatureFunction()
             Global LastTypedSince := A_TickCount
             CalcVisibleText()
             ShowHotkey(VisibleTextField)
             SetTimer, HideGUI, % -DisplayTimeTyping
          }

          If (Prefixed || StrLen(Typed)<2 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)))
          {
             If (StrLen(Typed)<2)
                Typed := (OnlyTypingMode=1) ? Typed : ""
             If (OnlyTypingMode!=1)
             {
                ShowHotkey(key)
                SetTimer, HideGUI, % -DisplayTime
             }
          }

          If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+ )"))
             Typed := (OnlyTypingMode=1) ? Typed : ""
    }

    If (TrueRmDkSymbol && StrLen(Typed)<2 && SecondaryTypingMode=0 && DisableTypingMode=0 && DoNotBindDeadKeys=0)
    { 
       Global LastTypedSince := A_TickCount
       InsertChar2caret(TrueRmDkSymbol)
       ShowHotkey(VisibleTextField)
       SetTimer, HideGUI, % -DisplayTimeTyping
    }
    OnMSGchar := ""
    OnMSGdeadChar := ""
    TrueRmDkSymbol := ""
    ExternalKeyStrokeRecvd := ""
}

OnBspPressed() {
    Try {
        key := GetKeyStr()
        If (TrueRmDkSymbol && AlternativeHook2keys=1 && SecondaryTypingMode=0 && DisableTypingMode=0) || (OnMSGdeadChar && SecondaryTypingMode=1 && DisableTypingMode=0) || (TrueRmDkSymbol && AlternativeHook2keys=0 && SecondaryTypingMode=0 && DisableTypingMode=0 && ShowDeadKeys=0)
        {
           TrueRmDkSymbol := ""
           OnMSGdeadChar := ""
           Return
        } Else If ((Typed ~= REx1) && TrueRmDkSymbol && AlternativeHook2keys=0 && SecondaryTypingMode=0 && DisableTypingMode=0)
        {
           StringReplace, Typed, Typed, %CSx2%, %Lola%
           TrueRmDkSymbol := ""
           CalcVisibleText()
           ShowHotkey(VisibleTextField)
           SetTimer, HideGUI, % -DisplayTimeTyping
           KeyCount := 1
           Global LastTypedSince := A_TickCount
           Return
        }

        If (ExpandWords=1 && StrLen(LastMatchedExpandPair)>1 && (A_TickCount-LastTypedSince < NoExpandAfter))
        {
           searchThis := SubStr(LastMatchedExpandPair, InStr(LastMatchedExpandPair, "// ")+3)
           FilterText(0, abz, zba, TxtLen, searchThis)
           StringReplace, replaceWith, LastMatchedExpandPair, %searchThis%
           StringReplace, replaceWith, replaceWith, %A_Space%//%A_Space%
           StringReplace, Typed, Typed, %searchThis%%Lola%, % replaceWith A_Space Lola, UseErrorLevel
           If (ErrorLevel>0)
           {
             StringGetPos, CaretPos, Typed, %Lola%
             times2pressKey := TxtLen - 1
             SendInput, {BackSpace %times2pressKey% }
             If (SecondaryTypingMode!=1)
             {
                Sleep, 25
                SendInput, {text}%replaceWith%
             }
           }
           LastMatchedExpandPair := "!"
        }

        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (KeyCount<10)
        {

            If (st_count(Typed, Lola2)>0)
            {
               ReplaceSelection()
               CalcVisibleText()
               ShowHotkey(VisibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }
            deadKeyProcessing()
            StringGetPos, CaretPos, Typed, %Lola%
            CaretPos := (CaretPos<1) ? 2000 : CaretPos
            If (CaretPos = 2000)
            {
               caretSymbolChangeIndicator(CSba, 300)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }
            KeyCount := 1
            Global LastTypedSince := A_TickCount
            StringGetPos, CaretPos, Typed, %Lola%
            testChar := SubStr(Typed, CaretPos, 1)
            If RegExMatch(testChar, "[\p{Cs}]")
            {
                Typed := st_delete(Typed, CaretPos-1, 2)
                CalcVisibleText()
                ShowHotkey(VisibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }
            TypedLength := StrLen(Typed)
            CaretPosy := (CaretPos = TypedLength) ? 0 : CaretPos
            Typed := (caretpos<1) ? Typed : st_delete(Typed, CaretPosy, 1)
            If InStr(Typed, CSx1 Lola)
            {
               StringGetPos, CaretPos, Typed, %Lola%
               CaretPos := (CaretPos < 1) ? 2000 : CaretPos
               CaretPosy := (CaretPos = TypedLength) ? CaretPos-1 : CaretPos
               Typed := st_delete(Typed, CaretPosy, 1) = Typed ? SubStr(Typed, 1, StrLen(Typed) - 1) : st_delete(Typed, CaretPosy, 1)
            }
            CalcVisibleText()
            ShowHotkey(VisibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }

        If (Prefixed || StrLen(Typed)<2 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0))
        {
           If (KeyCount>10 && OnlyTypingMode=0)
              Global LastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(Typed)<2)
              Typed := (OnlyTypingMode=1) ? Typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }
        If (DisableTypingMode=1) || (Prefixed && !(key ~= "i)^(.?Shift \+ )"))
           Typed := (OnlyTypingMode=1) ? Typed : ""
    }
    OnMSGchar := ""
}

OnDelPressed() {
    If (EnforceSluggishSynch=1 && SecondaryTypingMode=0 && A_ThisHotkey="Del")
       SendInput, {Del}
    LastMatchedExpandPair := ""
    Try {
        key := GetKeyStr()
        If (A_TickCount-LastTypedSince < ReturnToTypingDelay) && StrLen(Typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (KeyCount<10)
        {
            If (st_count(Typed, Lola2)>0)
            {
               ReplaceSelection()
               If (IsLangRTL=1)
                  Typed := ""
               CalcVisibleText()
               ShowHotkey(VisibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }
            If (IsLangRTL=1)
               Return

            deadKeyProcessing()
            InitialTextLength := StrLen(Typed)
            Global LastTypedSince := A_TickCount
            CaretMoverSel(1)
            ReplaceSelection()
            TextLengthAfter := StrLen(Typed)
            CalcVisibleText()
            ShowHotkey(VisibleTextField)
            If (TextLengthAfter!=InitialTextLength)
               KeyCount := 1
            Else
               caretSymbolChangeIndicator(CSde, 300)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        If (Prefixed || StrLen(Typed)<2 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0))
        {
           If (KeyCount>10 && OnlyTypingMode=0)
              Global LastTypedSince := A_TickCount - ReturnToTypingDelay
           If (StrLen(Typed)<2)
              Typed := (OnlyTypingMode=1) ? Typed : ""
           If (OnlyTypingMode!=1)
           {
              ShowHotkey(key)
              SetTimer, HideGUI, % -DisplayTime
           }
        }

        If (DisableTypingMode=1) ||  (Prefixed && !(key ~= "i)^(.?Shift \+ )"))
           Typed := (OnlyTypingMode=1) ? Typed : ""
    }
}

OnEscPressed() {
   If (StrLen(Typed)>1 && DisableTypingMode=0 && SecondaryTypingMode=0)
   {
      OnKeyPressed()
   } Else
   {
      Send, {Esc}
      OnKeyPressed()
;      Menu, ClippyMenu, DeleteAll
;      Menu, ClippyMenu, Show
      WinGetTitle, activeWindow, A
      If (InStr(activeWindow, "KeyPress OSD") && AnyWindowOpen>0)
         CloseWindow()
   }
}
OnKeyPressed() {
;  Sleep, 30 ; megatest
    PressKeyRecorded := 1
    Try {
        BackTypeCtrl := Typed || (A_TickCount-LastTypedSince > DisplayTimeTyping) ? Typed : BackTypeCtrl
        key := GetKeyStr()
        TypingFriendlyKeys := "i)^((.?shift \+ )?(Num|Caps|Scroll|Insert|Tab)|\{|AppsKey|Volume |Media_|Wheel |◐)"

        If (EnterErasesLine=1 && SecondaryTypingMode=1 && (key ~= "i)(enter|esc)"))
        {
           SwitchSecondaryTypingMode()
           If (StrLen(Typed)>3 && EnableTypingHistory=1)
              recordTypedHistory()
           Sleep, 20
           WinActivate, ahk_id %Window2ActivateHwnd%
           Sleep, 40
           WinWaitActive, ahk_id %Window2ActivateHwnd%, , 5
           If InStr(key, "enter")
           {
              SendOSDcontent(1)
              SkipRest := 1
           }
           If (DisableTypingMode=1)
              cleanTypeSlate()
        }

        If ((key ~= "i)(enter|esc)") && DisableTypingMode=0 && ShowSingleKey=1)
        {
            If (EnterErasesLine=0 && OnlyTypingMode=1)
               InsertChar2caret(" ")

            If (EnterErasesLine=0 && OnlyTypingMode=1 && (key ~= "i)(esc)"))
               DontReturn := 1

            BackTypdUndo := Typed
            BackTypeCtrl := ""
            ExternalKeyStrokeRecvd := ""
            If (key ~= "i)(esc)")
               Global LastTypedSince := A_TickCount - ReturnToTypingDelay

            If (StrLen(Typed)>3 && EnableTypingHistory=1)
               recordTypedHistory()

            If (EnterErasesLine=1)
               Typed := (SkipRest=1) ? Typed : ""
        } Else If (DisableTypingMode=0 && EnableTypingHistory=1)
            EditField4 := StrLen(Typed)>5 ? Typed : EditField4

        If (!(key ~= TypingFriendlyKeys) && DisableTypingMode=0)
        {
            Typed := (OnlyTypingMode=1 || SkipRest=1) ? Typed : ""
        } Else If ((key ~= "i)^((.?Shift \+ )?Tab)") && Typed && DisableTypingMode=0)
        {
            If ((Typed ~= REx1) && SecondaryTypingMode=0)
            {
                StringReplace, Typed, Typed,%CSx2%, %TrueRmDkSymbol%%A_Space%%Lola%
                TrueRmDkSymbol := ""
                CalcVisibleText()
            } Else InsertChar2caret(TrueRmDkSymbol " ")
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        If (StrLen(Typed)>1 && DontReturn!=1)
           SetTimer, ReturnToTyped, % -DisplayTime/4
    }
}

OnLetterPressed(onLatterUp:=0) {
;  Sleep, 60 ; megatest
    PressKeyRecorded := 1
    If (A_TickCount-LastTypedSince > 2000*StrLen(Typed)) && StrLen(Typed)<5 && (OnlyTypingMode=0)
       Typed := ""

    If (A_TickCount-LastTypedSince > ReturnToTypingDelay*1.75) && StrLen(Typed)>4
       InsertChar2caret(" ")

    Try {
        If (DeadKeys=1 && (A_TickCount-DeadKeyPressed < 1100))      ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these
           Sleep, % 70 * TypingDelaysScale
        Else If (Typed && DeadKeys=1)
           Sleep, % 20 * TypingDelaysScale

        If (Typed && DeadKeys=1 && DoNotBindDeadKeys=1)
           Sleep, % 20 * TypingDelaysScale

        AltGrMatcher := "i)^((AltGr|.?Alt \+ .?Ctrl|.?Ctrl \+ .?Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))"
        ShiftMatcher := "i)^(.?Shift \+ ((.)$|(.)[\r\n \,]))"
        key := GetKeyStr()

        If (Prefixed || DisableTypingMode=1)
        {
            TypingValidation := (SecondaryTypingMode=0 && DisableTypingMode=0) ? 1 : 0
            If ((key ~= AltGrMatcher) && (TypingValidation=1) && (EnableAltGr=1)) || ((key ~= ShiftMatcher) && (TypingValidation=1))
            {
               (EnableAltGr=1) && (key ~= AltGrMatcher) ? Typed := TypedLetter(A_ThisHotkey)
               (key ~= ShiftMatcher) ? Typed := TypedLetter(A_ThisHotkey)
               hasTypedNow := 1
               If (StrLen(Typed)>1)
               {
                  ShowHotkey(VisibleTextField)
                  SetTimer, HideGUI, % -DisplayTimeTyping
               } Else
               {
                  If (EnableTypingHistory=1)
                     EditField0 := StrLen(Typed)>5 ? Typed : EditField0

                  Typed := (hasTypedNow=1) ? Typed : ""
                  ShowHotkey(key)
               }
            } Else
            {
               If (EnableTypingHistory=1)
                  EditField0 := StrLen(Typed)>5 ? Typed : EditField0
               Typed := (OnlyTypingMode=1) ? Typed : ""
               ShowHotkey(key)
            }
            SetTimer, HideGUI, % -DisplayTime
        } Else If (SecondaryTypingMode=0)
        {
            TypedLetter(A_ThisHotkey, onLatterUp)
            ShowHotkey(VisibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }

    If (BeepFiringKeys=1) && (A_TickCount-Tickcount_start > 600) && (keyBeeper=1) || (BeepFiringKeys=1 && KeyBeeper=0)
    {
       If (SecondaryTypingMode=0 && SilentMode=0) 
          SoundsThread.ahkPostFunction["OnKeyPressed", ""]
    }
}

OnNumpadsPressed() {
    If (A_TickCount-LastTypedSince > 1000*StrLen(Typed)) && StrLen(Typed)<5 && (OnlyTypingMode=0)
       Typed := ""

    If (A_TickCount-LastTypedSince > ReturnToTypingDelay*1.75) && StrLen(Typed)>4
       InsertChar2caret(" ")

    Try {
        key := GetKeyStr()
        If ((Prefixed && !(key ~= "i)^(.?Shift \+ )")) || DisableTypingMode=1)
        {
            If (EnableTypingHistory=1)
               EditField4 := StrLen(Typed)>5 ? Typed : EditField4
            Typed := (OnlyTypingMode=1) ? Typed : ""
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        } Else If (ShowSingleKey=1 && SecondaryTypingMode!=1)
        {
            key := SubStr(key, InStr(key, "[ ")+2, 1)
            InsertChar2caret(TrueRmDkSymbol key)
            Global LastTypedSince := A_TickCount
            ShowHotkey(VisibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }
    TrueRmDkSymbol := ""
    LastMatchedExpandPair := ""
}

OnDeadKeyPressed() {

  If (SecondaryTypingMode=1)
     Return

  If (AlternativeHook2keys=0)
     Sleep, % 85 * TypingDelaysScale

  RmDkSymbol := CSx1
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  If (AlternativeHook2keys=1) && (A_TickCount-DeadKeyPressed<800) && (A_TickCount-LastTypedSince>600) && TrueRmDkSymbol && (DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     ExternalKeyStrokeRecvd := ""
     TrueRmDkSymbol := ""
  }
  Global DeadKeyPressed := A_TickCount

  If (ShowDeadKeys=1 && Typed && DisableTypingMode=0 && ShowSingleKey=1 && AlternativeHook2keys=0)
  {
       If (Typed ~= REx1)
       {
           StringReplace, Typed, Typed, %CSx2%, %TrueRmDkSymbol%%TrueRmDkSymbol%%Lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } Else InsertChar2caret(RmDkSymbol)
  }
  
  If (StrLen(Typed)>1 && DisableTypingMode=0 && TrueRmDkSymbol)
  {
     StringReplace, VisibleTextField, VisibleTextField, %Lola%, %TrueRmDkSymbol%
     ShowHotkey(VisibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, -950, 50
  }

  KeyCount := 0.1
  If (StrLen(Typed)<2)
  {
     If (ShowDeadKeys=1 && DisableTypingMode=0 && AlternativeHook2keys=0)
        InsertChar2caret(RmDkSymbol)

     If (A_ThisHotkey ~= "i)^(~\+)")
     {
        DeadKeyMod := "Shift + " TrueRmDkSymbol2
        ShowHotkey(DeadKeyMod " [dead key]")
     } Else If (ShowSingleKey=1)
        ShowHotkey(TrueRmDkSymbol2 " [dead key]")
     SetTimer, HideGUI, % -DisplayTime
  }
  If (DeadKeyBeeper=1)
     SoundsThread.ahkPostFunction["OnDeathKeyPressed", ""]
}

OnAltGrDeadKeyPressed() {
  If (SecondaryTypingMode=1)
     Return

  If (AlternativeHook2keys=0)
     Sleep, % 85 * TypingDelaysScale
  RmDkSymbol := CSx1
  TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  TrueRmDkSymbol2 := TrueRmDkSymbol

  If (AlternativeHook2keys=1 && (A_TickCount-DeadKeyPressed<800) && (A_TickCount-LastTypedSince>600) && TrueRmDkSymbol && DoNotBindDeadKeys=0)
  {
     Sleep, 10
     InsertChar2caret(TrueRmDkSymbol TrueRmDkSymbol)
     Sleep, 10
     ExternalKeyStrokeRecvd := ""
     TrueRmDkSymbol := ""
  }

  Global DeadKeyPressed := A_TickCount
  If (AlternativeHook2keys=0)
     Global LastTypedSince := A_TickCount

  If (ShowDeadKeys=1 && Typed && DisableTypingMode=0 && ShowSingleKey=1 && AlternativeHook2keys=0)
  {
       If (Typed ~= REx1)
       {
           StringReplace, Typed, Typed, %CSx2%, %TrueRmDkSymbol%%TrueRmDkSymbol%%Lola%
           CalcVisibleText()
           TrueRmDkSymbol := ""
       } Else InsertChar2caret(RmDkSymbol)
       SetTimer, ReturnToTyped, -850, -10
  }

  KeyCount := 0.1
  If (StrLen(Typed)>1 && DisableTypingMode=0 && TrueRmDkSymbol2)
  {
     StringReplace, VisibleTextField, VisibleTextField, %Lola%, %TrueRmDkSymbol%
     ShowHotkey(VisibleTextField)
     SetTimer, CalcVisibleTextFieldDummy, -950, 50
  }

  If (StrLen(Typed)<2)
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
  If (DeadKeyBeeper=1)
     SoundsThread.ahkPostFunction["OnDeathKeyPressed", ""]
}

OnCtrlRLeft() {
; Taiped is required to increase compatibility with Indic
; and other languages; it skips over invisible chars and
; two-part Emojis defined at the top of this file.

  Try {
      key := GetKeyStr()
  }
  PressKeyRecorded := 1
  LastMatchedExpandPair := ""
  FilterText(1, exKaretPos, exKaretPosSelly, InitialTxtLength)

  If ((A_TickCount-LastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && KeyCount<10 && StrLen(Typed)>1)
  {
      If InStr(A_ThisHotkey, "+^Left")
      {
         CaretJumpSelector(0)
         SkipRest := 1
      }

      If InStr(A_ThisHotkey, "+^Right")
      {
         CaretJumpSelector(1)
         SkipRest := 1
      }

      If (SkipRest!=1 && InStr(A_ThisHotkey, "^Left"))
      {
         If (exKaretPosSelly>exKaretPos && exKaretPosSelly>=0)
         {
            StringReplace, Typed, Typed, %Lola%
            StringReplace, Typed, Typed, %Lola2%
            CaretPos := exKaretPosSelly
            Typed := ST_Insert(Lola, Typed, CaretPos)            
            DroppedSelection := 1
         } Else CaretJumper(0)
      }

      If (SkipRest!=1 && InStr(A_ThisHotkey, "^Right"))
      {
         If (exKaretPosSelly < exKaretPos && exKaretPosSelly>=0)
         {
            StringReplace, Typed, Typed, %Lola%
            StringReplace, Typed, Typed, %Lola2%
            CaretPos := exKaretPosSelly + 1
            Typed := ST_Insert(Lola, Typed, CaretPos)
            DroppedSelection := 1
         } Else CaretJumper(1)
      }
      CalcVisibleText()
      Global LastTypedSince := A_TickCount
      ShowHotkey(VisibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If StrLen(Typed)<1 || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0)
  {
      If (KeyCount>=10 && OnlyTypingMode=0)
         Global LastTypedSince := A_TickCount - ReturnToTypingDelay
      If (StrLen(Typed)<2)
         Typed := (OnlyTypingMode=1) ? Typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }
  FilterText(1, exKaretPos2, exKaretPosSelly2, InitialTxtLength2)
  KeyCount := (exKaretPos!=exKaretPos2 && exKaretPosSelly<0 && exKaretPosSelly2<0) || (exKaretPos=exKaretPos2 && exKaretPosSelly!=exKaretPosSelly2) ? 1 : KeyCount
  If (SendJumpKeys=1 && SecondaryTypingMode=0 && DroppedSelection!=1)
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

  If (SendJumpKeys=1 && managedMode!=1) ;  && (mustSendJumpKeys=1) || (SendJumpKeys=1) && (KeyCount>10) && (OnlyTypingMode=1)
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
  PressKeyRecorded := 1
  LastMatchedExpandPair := ""
  doThis2 := 0
  If (key ~= "i)^(.?Ctrl \+ Delete)") || InStr(A_ThisHotkey, "^Del")
     doThis2 := 1
  FilterText(doThis2, abz, zba, InitialTxtLen)

  If ((A_TickCount-LastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && KeyCount<10 && StrLen(Typed)>=2)
  {
      BackTypdUndo := Typed
      StringGetPos, CaretzoiPos, Typed, %Lola%
      StringGetPos, exKaretPosSelly, Typed, %Lola2%
      If (key ~= "i)^(.?Ctrl \+ Backspace)") || InStr(A_ThisHotkey, "^Back")
      {
         If (exKaretPosSelly>=0)
         {
             ReplaceSelection()
             DroppedSelection := 1
         } Else
         {
             Typed := Typed "zz z"
             CaretJumper(0)
             StringGetPos, CaretzoaiaPos, Typed, %Lola%
             Typed := st_delete(Typed, CaretzoaiaPos+1, CaretzoiPos - CaretzoaiaPos+1)
             StringTrimRight, Typed, Typed, 4
             If (st_count(Typed, Lola)<1)
                Typed := ST_Insert(Lola, Typed, CaretzoaiaPos+1)
             BkspPressed := 1
         }
      }

      If (key ~= "i)^(.?Ctrl \+ Delete)") || InStr(A_ThisHotkey, "^Del")
      {
         If (exKaretPosSelly>=0)
         {
             ReplaceSelection()
             DroppedSelection := 1
         } Else
         {
             CaretJumper(1)
             StringGetPos, CaretzoaiaPos, Typed, %Lola%
             Typed := st_delete(Typed, CaretzoiPos+1, CaretzoaiaPos - CaretzoiPos)
             If (st_count(Typed, Lola)<1)
                Typed := ST_Insert(Lola, Typed, CaretzoaiaPos)
             DelPressed := 1
         }
      }
      Global LastTypedSince := A_TickCount
      CalcVisibleText()
      ShowHotkey(VisibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(Typed)<2) || (A_TickCount-LastTypedSince > (ReturnToTypingDelay+50)) || (KeyCount>10 && OnlyTypingMode=0)
  {
      If (KeyCount>10 && OnlyTypingMode=0)
         Global LastTypedSince := A_TickCount - ReturnToTypingDelay
      If StrLen(Typed)<2
         Typed := (OnlyTypingMode=1) ? Typed : ""
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  }

  doThis2 := 0
  If (DelPressed=1)
     doThis2 := 1
  FilterText(doThis2, abz, zba, TxtLenAfter)
  times2pressKey := InitialTxtLen - TxtLenAfter
  If (times2pressKey>1)
     KeyCount := 1
  If (SendJumpKeys=1 && SecondaryTypingMode=0)
  {
         StringGetPos, exKaretPos2, Typed, %Lola%
         If (exKaretPos2<0)
           times2pressKey := times2pressKey - 1

         If (times2pressKey>0 && BkspPressed=1 && DroppedSelection!=1)
            SendInput, {BackSpace %times2pressKey% }

         If (times2pressKey>0 && DelPressed=1 && DroppedSelection!=1)
            SendInput, {Del %times2pressKey% }

         If (DroppedSelection=1)
            SendInput, {Del}
  }

  If (SendJumpKeys=1 && times2pressKey<=0 && DroppedSelection!=1)
  {
      If (A_ThisHotkey="^BackSpace")
         SendInput, ^{BackSpace}
      If (A_ThisHotkey="^Del")
         SendInput, ^{Del}
  }
}

OnCtrlA() {
  If !InStr(A_PriorHotkey, "*vk41") && InStr(A_ThisHotkey, "^vk41")
     allGood := 1
  PressKeyRecorded := 1
  If (allGood=1 && (A_TickCount-LastTypedSince < ReturnToTypingDelay) && DisableTypingMode=0 && ShowSingleKey=1 && StrLen(Typed)>1)
  {
     selectAllText()
     CalcVisibleText()
     Global LastTypedSince := A_TickCount
     ShowHotkey(VisibleTextField)
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

OnCtrlV() {
  If (NeverDisplayOSD=1 && OutputOSDtoToolTip=0)
     Return

  PressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk56") && InStr(A_thisHotkey, "^vk56")
     allGood := 1
  Sleep, 25
  toPaste := Clipboard
  If ((toPaste ~= "i)^(.?\:\\.?.?)") && StrLen(toPaste)>4 && StrLen(Typed)<3)
     allGood := 0

  If (allGood=1 && DisableTypingMode=0 && ShowSingleKey=1 && StrLen(toPaste)>0)
     textClipboard2OSD(toPaste)

  If (allGood!=1 || (SecondaryTypingMode=0 && DisableTypingMode=1) || ShowSingleKey=0 || StrLen(toPaste)<1)
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

OnCtrlC() {
  If !InStr(A_PriorHotkey, "*vk43") && InStr(A_thisHotkey, "^vk43")
     allGood := 1
  PressKeyRecorded := 1
  If (allGood=1 && StrLen(Typed)>1 && SecondaryTypingMode=1 && (A_TickCount-LastTypedSince < ReturnToTypingDelay))
  {
     If (ShowSingleKey=1 && DisableTypingMode=0 && st_count(Typed, Lola2)>0)
     {
        ReplaceSelection(1, 0)
        CalcVisibleText()
     }
     ShowHotkey(VisibleTextField)
     Global LastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(Typed)<2 && OnlyTypingMode=0) || (A_TickCount-LastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
         key := GetKeyStr()
         ShowHotkey(key)
         SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlX() {
  PressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk58") && InStr(A_thisHotkey, "^vk58")
     allGood := 1

  If (StrLen(Typed)>1 && allGood=1 && (A_TickCount-LastTypedSince < ReturnToTypingDelay))
  {
     If (ShowSingleKey=1 && DisableTypingMode=0 && st_count(Typed, Lola2)>0)
     {
        ReplaceSelection(1,1)
        CalcVisibleText()
     }
     ShowHotkey(VisibleTextField)
     Global LastTypedSince := A_TickCount
     SetTimer, HideGUI, % -DisplayTimeTyping
  }

  If (StrLen(Typed)<2 && OnlyTypingMode=0) || (A_TickCount-LastTypedSince > ReturnToTypingDelay) && (OnlyTypingMode=0)
  {
      Try {
         key := GetKeyStr()
         ShowHotkey(key)
         SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnCtrlZ() {
  If (NeverDisplayOSD=1 && OutputOSDtoToolTip=0)
     Return
  PressKeyRecorded := 1
  If !InStr(A_PriorHotkey, "*vk5a") && InStr(A_thisHotkey, "^vk5a")
     allGood := 1

  If (allGood=1 && StrLen(Typed)>0 && ShowSingleKey=1 && DisableTypingMode=0 && (A_TickCount-LastTypedSince < ReturnToTypingDelay))
  {
      blahBlah := Typed
      Typed := (StrLen(BackTypdUndo)>1 || BackTypdUndo=CSx4) ? BackTypdUndo : Typed
      StringReplace, Typed, Typed, %CSx4%,
      BackTypdUndo := (StrLen(blahBlah)>1) ? blahBlah : BackTypdUndo
      Global LastTypedSince := A_TickCount
      CalcVisibleText()
      ShowHotkey(VisibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  } Else If (StrLen(Typed)<1 && OnlyTypingMode=0) || (A_TickCount-LastTypedSince < ReturnToTypingDelay) && (OnlyTypingMode=0) || (DisableTypingMode=1)
  {
      Try {
         key := GetKeyStr()
         ShowHotkey(key)
         SetTimer, HideGUI, % -DisplayTime
      }
  }
}

OnKeyUp() {
    Global Tickcount_start := A_TickCount
}

OnLetterUp() {
    LastMatchedExpandPair := ""
    a1 := A_ThisHotkey
    StringReplace, a2, A_ThisHotkey, %A_Space%up
    StringRight, a2, a2, 4
    b1 := A_PriorHotKey

    If (PressKeyRecorded=0 && DisableTypingMode=0 && SecondaryTypingMode=0 && InStr(b1, "vk") && (A_TickCount-DeadKeyPressed>400) && (A_TickCount-LastTypedSince>15))
    {
       If !InStr(TypedKeysHistory, a2)
       {
          TypedKeysHistory := 0
          OnLetterPressed(1)
       }
    }

    OnKeyUp()
    PressKeyRecorded := 0
    If (KeyBeeper=1 && SecondaryTypingMode=0) || (CapslockBeeper=1 && SecondaryTypingMode=0)
       SoundsThread.ahkPostFunction["OnLetterPressed", ""]
}

OnMudUp() {
    Global Tickcount_start := A_TickCount
    If (OSDshowLEDs=1)
       SetTimer, ModsLEDsIndicatorsManager, -370, 50
    If (StrLen(Typed)>1)
       SetTimer, ReturnToTyped, % -DisplayTime/4
}

;================================================================
; Section 2. Various functions used in typing mode.
; - To keep track of the caret, process and display text.
; - Letters, symbols and numbers identified in Loop, 256
;   from CreateHotkey() are assigned to OnLetterPressed()
;   found in Section 1.
; - TypedLetter() receives the VK of the pressed key.
;   and its name is identified with toUnicodeExtended().
; - The text caret is Lola, Lola2 is used for the selector.
; - What the user types is held in Typed, and
;   what the OSD can display in the provided MaxGuiWidth
;   is held in VisibleTextField.
; - InsertChar2caret() is the main function through which
;   text is inserted into Typed.
;================================================================

TypedLetter(key,onLatterUp:=0) {
;  Sleep, 50 ; megatest

   If (ShowSingleKey=0 || DisableTypingMode=1)
   {
      cleanTypeSlate()
      Return
   }
   If (OutputOSDtoToolTip=0 && NeverDisplayOSD=1)
   {
      cleanTypeSlate()
      Return
   }

   If (SecondaryTypingMode=0)
   {
      If (onLatterUp=0)
         TypedKeysHistory .= key
      StringRight, TypedKeysHistory, TypedKeysHistory, 30

      If InStr(A_ThisHotkey, "+")
         shiftPressed := 1

      If (EnableAltGr=1 && (InStr(A_ThisHotkey, "^!") || InStr(A_ThisHotkey, "<^>")))
         AltGrPressed := 1

      If (AlternativeHook2keys=1 && DeadKeys=0)
         Sleep, 30

      vk := "0x0" SubStr(key, InStr(key, "vk", 0, 0)+2)
      sc := "0x0" GetKeySc("vk" vk)
      key := toUnicodeExtended(vk, sc, shiftPressed, AltGrPressed,0,onLatterUp)

      If (AlternativeHook2keys=1) && TrueRmDkSymbol && (A_TickCount-deadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DeadKeys=0) && (A_TickCount-DeadKeyPressed < 9000) || (AlternativeHook2keys=1) && (DoNotBindDeadKeys=1) && (A_TickCount - LastTypedSince > 200)
      {
         Sleep, 30
         If (ExternalKeyStrokeRecvd=TrueRmDkSymbol && DoNotBindDeadKeys=0)
            ExternalKeyStrokeRecvd .= key
         Typed := (ExternalKeyStrokeRecvd && AlternativeHook2keys=1) ? InsertChar2caret(ExternalKeyStrokeRecvd) : InsertChar2caret(key)
         If (!ExternalKeyStrokeRecvd && AlternativeHook2keys=1 && IsKeystrokesFile)
         {
            Static KeyStrokesRestarts
            If (KeyStrokesRestarts>6)
               skipIt := 1
            If (KeyStrokesRestarts<2 && skipIt!=1)
            {
               KeyStrokesThread.ahkassign("AlternativeHook2keys", AlternativeHook2keys)
               KeyStrokesThread.ahkPostFunction["MainLoop"]
               KeyStrokesRestarts++
            }
            If (KeyStrokesRestarts>=2 && skipIt!=1)
            {
               KeyStrokesThread.ahkReload[]
               Sleep, 50
               KeyStrokesThread.ahkassign("AlternativeHook2keys", AlternativeHook2keys)
               KeyStrokesRestarts++
            }
         }
         ExternalKeyStrokeRecvd := ""
         If (DeadKeys=0) && (A_TickCount-DeadKeyPressed > 1000)
            Global DeadKeyPressed := 15000
      } Else (Typed := InsertChar2caret(key))

      ExternalKeyStrokeRecvd := ""
      TrueRmDkSymbol := ""
      Global LastTypedSince := A_TickCount
   }
   Return Typed
}


StartKeystrokesThread() {
   Static hasInit
   If (hasInit=1 || !IsKeystrokesFile)
      Return
   AlternativeHook2keys := (AltHook2keysUser=1) ? 1 : 0
   KeyStrokesThread.ahkassign("AlternativeHook2keys", AlternativeHook2keys)
   KeyStrokesThread.ahkPostFunction["MainLoop"]
   hasInit := 1
}

toUnicodeExtended(uVirtKey,uScanCode,shiftPressed:=0,AltGrPressed:=0,wFlags:=0,onLatterUp:=0) {
; Many thanks to Helgef for helping me with this function:
; https://autohotkey.com/boards/viewtopic.php?f=5&t=41065&p=187582#p187582
  PressKeyRecorded := 1
  nsa := DllCall("user32\MapVirtualKeyW", "UInt", uVirtKey, "UInt", 2)
  If (nsa<=0 && DeadKeys=0 && SecondaryTypingMode=1)
      Return

  If (nsa<=0 && DeadKeys=0 && SecondaryTypingMode=0)
  {
     StartKeystrokesThread()
     Global DeadKeyPressed := A_TickCount
     If (DeadKeyBeeper=1 && ShowSingleKey=1)
        SoundsThread.ahkPostFunction["OnDeathKeyPressed", ""]

     StringReplace, VisibleTextField, VisibleTextField, %Lola%, %CSx3%
     ShowHotkey(VisibleTextField)
     If (AlternativeHook2keys=0)
        Sleep, % 250 * TypingDelaysScale

     If (StrLen(Typed)<2)
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
  VarSetCapacity(pwszBuff, (cchBuff+1)*2, 0) ; this will hold cchBuff (3) characters and the null terminator.

  If (onLatterUp=1)
  {
     For modifier, vk in {Shift:0x10, Control:0x11, Alt:0x12}
         NumPut(128*(GetKeyState("L" modifier) || GetKeyState("R" modifier)) , lpKeyState, vk, "Uchar")
  }

  If (shiftPressed=1)
     NumPut(128, lpKeyState, 0x10, "UChar")

  If (AltGrPressed=1)
  {
     NumPut(128, lpKeyState, 0x12, "UChar")
     NumPut(128, lpKeyState, 0x11, "UChar")
  }

  NumPut(GetKeyState("CapsLock", "T") , &lpKeyState+0, 0x14, "UChar")
  Loop, 2
  {
    n := DllCall("user32\ToUnicodeEx"
       , "UInt" , uVirtKey
       , "UInt" , uScanCode
       , "Ptr"  , &lpKeyState
       , "Ptr"  , &pwszBuff
       , "Int"  , cchBuff
       , "UInt" , wFlags
       , "Ptr"  , HKL)
  }
  Return StrGet(&pwszBuff, n, "utf-16")
}

InsertChar2caret(char) {
;  Sleep, 150 ; megatest
  If (NeverDisplayOSD=1 && OutputOSDtoToolTip=0)
     Return

  If (SecondaryTypingMode=0 && DisableTypingMode=1)
     cleanTypeSlate()

  If (st_count(Typed, Lola2)>0)
     ReplaceSelection()

  If (CaretPos = 2000)
     CaretPos := 1

  If (CaretPos = 3000)
     CaretPos := StrLen(Typed)+1

  StringGetPos, CaretPos, Typed, %Lola%
  StringReplace, Typed, Typed, %Lola%

  CaretPos := (IsLangRTL=1) ? StrLen(Typed)+1 : CaretPos+1
  Typed := ST_Insert(char Lola, Typed, CaretPos)
  If (A_TickCount-DeadKeyPressed>150)
      CalcVisibleText()
  Else
      SetTimer, CalcVisibleTextFieldDummy, -250, 50
  Return Typed
}

CalcVisibleTextFieldDummy() {
    CalcVisibleText()
    If (StrLen(VisibleTextField)>0)
    {
       ShowHotkey(VisibleTextField)
       SetTimer, HideGUI, % -DisplayTimeTyping
    }
}

CalcVisibleText() {
;  Sleep, 30 ; megatest
   MaxTextLimit := 0
   If (IsLangRTL=1)
   {
      StringReplace, VisibleTextField, Typed, %Lola%, %A_Space%
   } Else
   {
      VisibleTextField := Typed
      Text_width0 := GetTextExtentPoint(Typed, FontName, FontSize) / (OSDsizingFactor/100)
      If (Text_width0 > MaxAllowedGuiWidth && Typed)
         MaxTextLimit := 1
   }

   If (MaxTextLimit>0 && IsLangRTL=0)
   {
      cola := Lola
      MaxA_Index := (MaxTextChars<6) ? StrLen(Typed) : Round(MaxTextChars*1.3)

      If (st_count(Typed, Lola2)>0)
      {
         StringGetPos, RealCaretPos, Typed, %Lola%
         StringGetPos, SelCaretPos, Typed, %Lola2%
         AddSelMarker := 1
         AddSelMarkerLocation := (SelCaretPos < RealCaretPos) ? 1 : 2
         cola := Lola2
      }
      LoopJumpStart := (MaxTextChars > StrLen(Typed)-5) ? 1 : Round(MaxTextChars/2)

      Loop
      {
        StringGetPos, vCaretPos, Typed, %cola%
        Stringmid, NEWVisibleTextField, Typed, vCaretPos+1+Round(MaxTextChars/3.5), LoopJumpStart+A_Index, L
        Text_width2 := GetTextExtentPoint(NEWVisibleTextField, FontName, FontSize) / (OSDsizingFactor/100)
        If (Text_width2 >= MaxAllowedGuiWidth-30-(OSDsizingFactor/15))
           allGood := 1
      } Until (AllGood=1 || A_Index=Round(MaxA_Index) || A_Index>=5000)

      If (AllGood!=1)
      {
          Loop
          {
            Stringmid, NEWVisibleTextField, Typed, vCaretPos+A_Index, , L
            Text_width3 := GetTextExtentPoint(NEWVisibleTextField, FontName, FontSize) / (OSDsizingFactor/100)
            If (Text_width3 >= MaxAllowedGuiWidth-30-(OSDsizingFactor/15))
               StopLoop2 := 1
          } Until (StopLoop2 = 1 || A_Index=Round(MaxA_Index/1.25) || A_Index>=5000)
      }

      If (AddSelMarker=1 && (st_count(NEWVisibleTextField, Lola)<1))
         NEWVisibleTextField := (AddSelMarkerLocation=2) ? CSx3 " " NEWVisibleTextField : NEWVisibleTextField " " CSx3
      If (IsLangRTL=1)
         StringReplace, NEWVisibleTextField, NEWVisibleTextField, %Lola%
      VisibleTextField := NEWVisibleTextField
      MaxTextChars := MaxTextChars<3 ? MaxTextChars : StrLen(VisibleTextField)+3
   }
}

caretSymbolChangeIndicator(NewSymbol,timerz:=1300,DKsleep:=0) {
   StringReplace, VisibleTextField, VisibleTextField, %Lola%, %NewSymbol%
   ShowHotkey(VisibleTextField)
   StringReplace, VisibleTextField, VisibleTextField, %NewSymbol%, %Lola%
   If (DKsleep=1)
      Sleep, 400
   SetTimer, CalcVisibleTextFieldDummy, % - timerz, 50
}

ReturnToTyped() {
    If (StrLen(Typed)>2 && KeyCount<10 && (A_TickCount-LastTypedSince < ReturnToTypingDelay) && ShowSingleKey=1 && DisableTypingMode=0 && !A_IsSuspended)
    {
        ShowHotkey(VisibleTextField)
        SetTimer, HideGUI, % -DisplayTimeTyping
    }
}

CaretMover(direction,inLoop:=0) {
  If (IsLangRTL=1)
     Return

  StringGetPos, CaretPos, Typed, %Lola%
  StringGetPos, CaretPosSelly, Typed, %Lola2%
  Direction2check := (direction=2) ? CaretPos+3 : CaretPos
  TestChar := SubStr(Typed, Direction2check, 1)
  If RegExMatch(TestChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<5) && (CaretPosSelly<0)
     MustRepeat := 1

  If (st_count(Typed, Lola2)>0)
  {
     StringGetPos, CaretPos2, Typed, %Lola2%
     If ((CaretPos2>CaretPos && direction=2) || (CaretPos2<CaretPos && direction=0))
     {
        CaretPos := CaretPos2
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     } Else (CaretPos := (direction=2) ? (CaretPos - 2) : (CaretPos + 1))
  }
  StringReplace, Typed, Typed, %Lola%
  StringReplace, Typed, Typed, %Lola2%
  CaretPos := CaretPos + direction
  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(Typed)+1))
     CaretPos := StrLen(Typed)+1

  Typed := ST_Insert(Lola, Typed, CaretPos)
  If InStr(Typed, CSx1 Lola)
  {
     StringGetPos, CaretPos, Typed, %Lola%
     StringReplace, Typed, Typed, %Lola%
     CaretPos := CaretPos + direction
     Typed := ST_Insert(Lola, Typed, CaretPos)
  }
  CalcVisibleText()

; The following loop[s] is required to increase
; compatibility with Indic and other languages;
; it skips over invisible chars.

  If (MustRepeat=1)
  {
     inLoop := inLoop + 1
     If (CaretPos=1 && direction=0)
        Return
     CaretMover(direction,inLoop)
  }
}

CaretMoverSel(direction,inLoop:=0) {
  If (IsLangRTL=1)
     Return

  cola := Lola2
  cola2 := Lola
  StringGetPos, CaretPos, Typed, %cola2%
  If (st_count(Typed, cola)>0)
  {
     StringGetPos, CaretPos, Typed, %cola%
     Direction2check := (direction=1) ? CaretPos+3 : CaretPos
     TestChar := SubStr(Typed, Direction2check, 1)
     If RegExMatch(TestChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<5)
        MustRepeat := 1
  } Else
  {
     StringGetPos, CaretPos, Typed, %cola2%
     Direction2check := (direction=1) ? CaretPos+3 : CaretPos
     TestChar := SubStr(Typed, Direction2check, 1)
     If RegExMatch(TestChar, "[\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") && (inLoop<5)
        MustRepeat := 1
     CaretPos := (direction=1) ? CaretPos + 1 : CaretPos
  }

  StringReplace, Typed, Typed, %cola%
  CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(Typed)+1))
     CaretPos := StrLen(Typed)+1

  Typed := ST_Insert(cola, Typed, CaretPos)
  If InStr(Typed, CSx1 cola)
  {
     StringGetPos, CaretPos, Typed, %cola%
     StringReplace, Typed, Typed, %cola%
     CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
     Typed := ST_Insert(cola, Typed, CaretPos)
  }

  If (InStr(Typed, cola cola2) || InStr(Typed, cola2 cola))
     StringReplace, Typed, Typed, %cola%

  CalcVisibleText()

; The following loop[s] is required to increase compatibility
; with Indic and other languages; it skips over invisible chars.

  If (MustRepeat=1)
  {
     inLoop := inLoop + 1
     CaretMoverSel(direction,inLoop)
  }
}

CaretJumpMain(direction) {
  If (CaretPos<=1)
     CaretPos := 1.5

  theRegEx := "i)((?=[[:space:]|│!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~])[\p{L}\p{Z}\p{N}\p{P}\p{S}]\b(?=\S)|\s(?!\s)(?=\p{L})|\p{So}(?=\S))"
  alternativeRegEx := "i)(((\p{Sc}|\p{So}|\p{L}|\p{N}|\w)(?=\S))([\p{Z}!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~\p{S}\p{C}])|\s\B[[:punct:]]|[[:punct:][:digit:][:alpha:]]\s\B)"
  If (direction=1)
  {
     CaretuPos := RegExMatch(Typed, theRegEx, , CaretPos+1) + 1
     If (AlternativeJumps=1)
     {
        CaretuPosa := RegExMatch(Typed, alternativeRegEx, , CaretPos+1) + 1
        If (CaretuPosa>CaretPos)
           CaretuPos := (CaretuPosa < CaretuPos) ? CaretuPosa : CaretuPos
     }
     CaretPos := (CaretuPos < CaretPos) ? StrLen(Typed)+1 : CaretuPos
  }

  If (direction=0)
  {
     Typed := Typed " z."
     If (CaretPos<=1)
        SkipLoop := 1

     Loop
     {
       CaretuPos := CaretPos - A_Index
       CaretelPos := RegExMatch(Typed, theRegEx, , CaretuPos)+1
       If (AlternativeJumps=1)
       {
          CaretelPosa := RegExMatch(Typed, alternativeRegEx, , CaretuPos)+1
          CaretelPos := (CaretelPosa < CaretelPos) ? CaretelPosa : CaretelPos
       }
       CaretelPos := (CaretelPos < CaretuPos) ? StrLen(Typed)+1 : CaretelPos
       If (CaretelPos < CaretPos+1)
       {
          CaretPos := (CaretelPos > CaretPos) ? 1 : CaretelPos
          AllGood := 1
       }
       If (CaretelPos < CaretuPos+1) || (A_Index>CaretPos+5)
          SkipLoop := 1
     } Until (SkipLoop=1 || AllGood=1 || A_Index=300)

     StringTrimRight, Typed, Typed, 3
  }

  If (CaretPos<=1)
     CaretPos := 1
  If (CaretPos >= (StrLen(Typed)+1))
     CaretPos := StrLen(Typed)+1
}

CaretJumper(direction,inLoop:=0) {
  If (IsLangRTL=1)
     Return

  If (st_count(Typed, Lola2)>0)
     CaretMover(direction*2)

  StringGetPos, CaretPos, Typed, %Lola%
  StringReplace, Typed, Typed, %Lola%
  OldCaretPos := CaretPos
  CaretJumpMain(direction)
  Typed := ST_Insert(Lola, Typed, CaretPos)
  StringGetPos, CaretPose, Typed, %Lola%
  If (SendJumpKeys=1 && inLoop!=1)
  {
     If !(CaretPose-2>=OldCaretPos) && direction=1
        CaretJumper(direction,1)
     If !(CaretPose+2<=OldCaretPos) && direction=0
        CaretJumper(direction,1)
  }

; The following is required to increase compatibility
; with Indic and other languages; it skips over invisible chars.

  StringGetPos, CaretPoza, Typed, %Lola%
  Direction2check := CaretPoza+2
  TestChar := SubStr(Typed, Direction2check, 1)
  If RegExMatch(TestChar, "[\▫\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]") || InStr(Typed, CSx2)
     CaretMover(direction*2, 1)
}

CaretJumpSelector(direction,inLoop:=0) {
  If (st_count(Typed, Lola2)>0)
  {
     StringGetPos, CaretPos, Typed, %Lola2%
     StringReplace, Typed, Typed, %Lola2%
  } Else
  {
     StringGetPos, CaretPos, Typed, %Lola%
     CaretPos := (direction=1) ? CaretPos+1 : CaretPos
  }

  OldCaretPos := CaretPos
  CaretJumpMain(direction)
  Typed := ST_Insert(Lola2, Typed, CaretPos)
  If (InStr(Typed, Lola Lola2) || InStr(Typed, Lola2 Lola))
     StringReplace, Typed, Typed, %Lola2%

  StringGetPos, CaretPose, Typed, %Lola2%
  If (SendJumpKeys=1 && inLoop!=1)
  {
     If !(CaretPose-2>=OldCaretPos) && direction=1
        CaretJumpSelector(direction,1)
     If !(CaretPose+2<=OldCaretPos) && direction=0
        CaretJumpSelector(direction,1)
  }

; The following is required to increase compatibility
; with Indic and other languages; it skips over
; invisible chars.

  StringGetPos, CaretPoza, Typed, %Lola2%
  Direction2check := CaretPoza+2
  TestChar := SubStr(Typed, Direction2check, 1)
  If RegExMatch(TestChar, "[\▫\p{Mc}\p{Mn}\p{Cc}\p{Cf}\p{Co}\p{Cs}]")  || InStr(Typed, CSx2)
     CaretMoverSel(direction, 1)
}

ReplaceSelection(copy2clip:=0,EraseSelection:=1) {
  BackTypdUndo := Typed
  StringGetPos, CaretPos, Typed, %Lola%
  StringGetPos, CaretPos2, Typed, %Lola2%
  brr := RegExMatch(Typed, "i)((│|║).*?=?(│|║))", loca)
  If (EraseSelection=1)
  {
     StringReplace, Typed, Typed, %loca%, %Lola%
     StringReplace, Typed, Typed, %Lola2%
     StringReplace, Typed, Typed, %Lola%
     CaretBoss := (CaretPos2 > CaretPos) ? CaretPos+1 : CaretPos2+1
     Typed := ST_Insert(Lola, Typed, CaretBoss)
  }

  If (copy2clip=1 && SecondaryTypingMode=1)
  {
     StringReplace, loca, loca, %Lola2%
     StringReplace, loca, loca, %Lola%
     Clipboard := loca
  }
}

SelectHomeEnd(direction) {
  StringGetPos, CaretPos3, Typed, %Lola%
  If (CaretPos3>=(StrLen(Typed)-1) && direction=1) || (CaretPos3<=1 && direction=0)
  {
     StringReplace, Typed, Typed, %Lola2%
     Return
  }
  If ((Typed ~= "i)^(║)") && direction=0) || ((Typed ~= "i)(║)$") && direction=1) || (CaretPos<=1 && direction!=1) || (CaretPos>=StrLen(Typed) && direction=1)
     Return

  StringReplace, Typed, Typed, %Lola2%
  CaretPos2 := (direction=0) ? 1 : StrLen(Typed)+1
  Typed := ST_Insert(Lola2, Typed, CaretPos2)
  MaxTextChars := MaxTextChars*2
}

selectAllText() {
    StringReplace, Typed, Typed, %Lola%
    StringReplace, Typed, Typed, %Lola2%
    CaretPos := StrLen(Typed)+1
    Typed := ST_Insert(Lola2, Typed, CaretPos)
    CaretPos := 1
    Typed := ST_Insert(Lola, Typed, CaretPos)
}

cleanTypeSlate() {
     Typed := ""
     BackTypdUndo := ""
     BackTypeCtrl := "" 
}

recordTypedHistory() {
   StringGetPos, CaretPos4, Typed, %Lola%
   StringReplace, Typed1, Typed, %Lola%
   StringReplace, Typed1, Typed, %Lola2%
   EditField1 := EditField2
   EditField2 := Typed1
   EditingField := 3
}

; -------------------------------------------------------------------------------------
; String Things - Common String & Array Functions, 2014
; by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/
ST_Insert(insert,input,pos=1) {
  Length := StrLen(input)
  ((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
  output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
  If (StrLen(output) > StrLen(input) + StrLen(insert))
    ((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
  Return, output
}

ST_Count(string, searchFor="`n") {
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   Return ErrorLevel
}

ST_Delete(string, start=1, length=1) {
   If (Abs(start+length) > StrLen(string))
      Return string
   If (start>0)
      Return SubStr(string, 1, start-1) . SubStr(string, start + length)
   Else If (start<=0)
      Return SubStr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}
; -------------------------------------------------  String Things by tidbit

ShellMessage(wParam, lParam) {
; function used for EraseTextWinChange=1

   ; WinGetTitle, title, ahk_id %lParam%
   If (SecondaryTypingMode=0 && (A_TickCount-DoNotRepeatTimer>2000) && EraseTextWinChange=1 && StrLen(Typed)>1 && (wParam == 4 || wParam == 17 || wParam == 32772))
   {  ; HSHELL_WINDOWACTIVATED Or HSHELL_RUDEAPPACTIVATED
      If (EnableTypingHistory=1)
         recordTypedHistory()
      cleanTypeSlate()
      HideGUI()
   }
}

GetDeadKeySymbol(hotkeya) {
   lenghty := InStr(DKnamez, hotkeya)
   lenghty := (lenghty=0) ? 2 : lenghty
   symbol := SubStr(DKnamez, lenghty-1, 1)
   symbol := (symbol="") || (symbol="v") || (symbol="k") ? CSx3 : symbol
   Return symbol
}

deadKeyProcessing() {

  If (ShowDeadKeys=0) || (DisableTypingMode=1) || (ShowSingleKey=0) || (DeadKeys=0) || (SecondaryTypingMode=1) || (AlternativeHook2keys=1)
     Return

  Loop, 5
  {
    deadkeyPosition := RegExMatch(Typed, "\▫[\p{Z}\p{N}\p{P}\p{S}]")
    nextChar := SubStr(Typed, deadkeyPosition+1, 1)

    If (nextChar!=CSx1) && (deadkeyPosition>=1)
       Typed := RegExReplace(Typed, "\▫(?=([\p{Z}\p{N}\p{P}\p{S}]))", CSx3)
  }
}

textClipboard2OSD(toPaste) {
    BackTypdUndo := StrLen(Typed)>1 ? Typed : CSx4
    Stringleft, toPaste, toPaste, 950
    StringReplace, toPaste, toPaste, `r`n, %A_Space%, All
    StringReplace, toPaste, toPaste, `n, %A_Space%, All
    StringReplace, toPaste, toPaste, `r, %A_Space%, All
    StringReplace, toPaste, toPaste, `f, %A_Space%, All
    StringReplace, toPaste, toPaste, %A_TAB%, %A_SPACE%, All
    StringReplace, toPaste, toPaste, %Lola%,, All
    StringReplace, toPaste, toPaste, %Lola2%,, All
    InsertChar2caret(toPaste)
    CaretPos := CaretPos + StrLen(toPaste)
    maxTextChars := StrLen(Typed)+2
    CalcVisibleText()
    ShowHotkey(VisibleTextField)
    Global lastTypedSince := A_TickCount
    Global DoNotRepeatTimer := A_TickCount
    SetTimer, HideGUI, % -DisplayTimeTyping
}

MatchProxyWord() {
  TypedTrim := SubStr(Typed, CaretPos)
  StringReplace, TypedTrim2, Typed, %TypedTrim%
  If InStr(TypedTrim2, A_Space)
  {
     TypedTrim3 := SubStr(TypedTrim2, InStr(TypedTrim2, A_Space,, -1))
     StringReplace, TypedTrim3, TypedTrim3, %A_Space%
  } Else (TypedTrim3 := TypedTrim2)
  Return TypedTrim3
}

ExpandFeatureFunction() {
  If (LastMatchedExpandPair="!") || (A_TickCount-DoNotRepeatTimer < 900)
  {
     LastMatchedExpandPair := ""
     Return
  }
  LastMatchedExpandPair := ""
  UserTypedWord := MatchProxyWord()
  FilterText(0, abz, zba, TxtLen, UserTypedWord)

  If ExpandWordsList[UserTypedWord] && (A_TickCount-LastTypedSince < NoExpandAfter)
  {
     StringReplace, Typed, Typed, %UserTypedWord%%A_Space%%Lola%, % ExpandWordsList[UserTypedWord] Lola
     StringGetPos, CaretPos, Typed, %Lola%
     times2pressKey := TxtLen + 1
     DoNotRepeatTimer := A_TickCount
     If (SecondaryTypingMode!=1)
     {
        SendInput, {BackSpace %times2pressKey% }
        Sleep, 25
        Text2Send := ExpandWordsList[UserTypedWord]
        SendInput, {text}%Text2Send%
     }
     LastMatchedExpandPair := UserTypedWord " // " ExpandWordsList[UserTypedWord]
  }
}

CreateWordPairsFile(WordPairsFile) {
      ExpandPairs =
      (LTrim
          afaik // as far as I know
          afk // away from the keyboard
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
          fubar // f*cked up beyond any repair
          ftw // for the win
          fyi // for your information
          gmo // genetically modified organism
          iirc // if I recall correctly
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
      FileAppend, %ExpandPairs%, %WordPairsFile%, UTF-16
      Return ExpandPairs
}

InitExpandableWords(ForceIT:=0) {
  Static hasInit
  If (hasInit=1 && PrefOpen=0 && ForceIT=0)
     Return

  If FileExist(WordPairsFile)
     Try FileRead, ExpandPairs, %WordPairsFile%
  Else
     ExpandPairs := CreateWordPairsFile(WordPairsFile)

  If StrLen(ExpandPairs)<10
     ExpandPairs := CreateWordPairsFile(WordPairsFile)

  For each, line in StrSplit(ExpandPairs, "`n", "`r")
  {
    If !line
       Continue
    lineArr := StrSplit(line, " // ")
    key := lineArr[1]
    value := lineArr[2]
    If (StrLen(key)<2 || StrLen(value)<2 || InStr(key, A_Space))
    {
       needsResave := 1
       Continue
    }
    ExpandWordsList[key] := value
    ExpandWordsListEdit .= key " // " value "`n"
  }
  If (needsResave=1)
  {
     Sleep, 25
     FileDelete, %WordPairsFile%
     Sleep, 25
     FileAppend, %ExpandWordsListEdit%, %WordPairsFile%, UTF-16
  }
  hasInit := 1
}

;================================================================
; Section 3. The OSD GUI - CreateOSDGUI()
; - This section includes functions that generate key names
;   [eg., GetKeyStr()]; to be displayied [eg., with ShowHotkey()]
;   or to keep track of key states, e.g., LEDs indicators.
; - GetTextExtentPoint() and GuiGetSize() are constantly used
;   to determine text and window sizes.
;================================================================

calcOSDresizeFactor() {
  Return Round(A_ScreenDPI / 1.1)
}

CreateOSDGUI() {
    Global
    smallLEDheight := 10
    Gui, OSD: Destroy
    Sleep, 25
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow +HwndhOSD
    Gui, OSD: Margin, 20, %smallLEDheight%
    Gui, OSD: Color, %OSDbgrColor%
    If (ShowPreview=0 || PrefOpen=0)  ; In my version 'ShowPreview' can be always enabled per user preference (stored in ini) and this if/else would break the normal display
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
    dragOSDhandles := hOSDind1 "," hOSDind2 "," hOSDind3 "," hOSDind4
    If (OSDalignment>1)
       CreateOSDGUIghost()
    LEDsIndicatorsManager()
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
    If (OutputOSDtoToolTip=1 && PrefOpen=0)
    {
       OSDcontentOutput := HotkeyStr
       SetTimer, OSDoutputToolTip, 70
       OSDvisible := 1
    }

    If ((HotkeyStr ~= "i)^(\s+)$") || NeverDisplayOSD=1)
       Return

    If ((HotkeyStr ~= "i)( \+ )") && !(Typed ~= "i)( \+ )") && OnlyTypingMode=1)
       Return

    Global Tickcount_start2 := A_TickCount
    Static oldText_width, Wid, Heig
    If (OSDautosize=1)
    {
        If (StrLen(HotkeyStr)!=oldText_width || ShowPreview=1 || StrLen(Typed)<2)
        {
           growthIncrement := (FontSize/2)*(OSDsizingFactor/150)
           startPoint := GetTextExtentPoint(HotkeyStr, FontName, FontSize) / (OSDsizingFactor/100) + 35
           If ((startPoint > Text_width+growthIncrement) || (startPoint < Text_width-growthIncrement) || StrLen(Typed)<2)
              Text_width := Round(startPoint)
           Text_width := (Text_width > MaxAllowedGuiWidth-growthIncrement*2) ? Round(MaxAllowedGuiWidth) : Round(Text_width)
        }
        oldText_width := StrLen(HotkeyStr)
    } Else If (OSDautosize=0)
        Text_width := MaxAllowedGuiWidth

    dGuiX := Round(GuiX)
    GuiControl, OSD: , HotkeyText, %HotkeyStr%
    If (OSDalignment>1)
    {
        Gui, OSDghost: Show, NoActivate Hide x%dGuiX% y%GuiY% w%Text_width%, KeyPressOSDghost
        GuiGetSize(Wid, Heig, 0)
        If (OSDalignment=3)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid) : Round(dGuiX)
        If (OSDalignment=2)
           dGuiX := Round(Wid) ? Round(GuiX) - Round(Wid)/2 : Round(dGuiX)
        GuiControl, OSD: Move, HotkeyText, w%Text_width% Left
    }
    SetTimer, checkMousePresence, on, 950, -15
    If (OSDalignment>1)
       Gui, OSDghost: Show, NoActivate Hide x%dGuiX% y%GuiY% w%Text_width%, KeyPressOSDghost
    Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%Text_width%, KeyPressOSDwin
    WinSet, AlwaysOnTop, On, KeyPressOSDwin
    OSDvisible := 1
}

ShowLongMsg(stringo) {
   BkcpNvrDisplayOSD := (NeverDisplayOSD=1) ? "y" : "n"
   NeverDisplayOSD := 0
   Text_width2 := GetTextExtentPoint(stringo, FontName, FontSize) / (OSDsizingFactor/100)
   MaxAllowedGuiWidth := Text_width2 + 30
   ShowHotkey(stringo)
   MaxAllowedGuiWidth := (OSDautosize=1) ? MaxGuiWidth : GuiWidth
   NeverDisplayOSD := (BkcpNvrDisplayOSD="y") ? 1 : 0
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

GetTextExtentPoint(sString, sFaceName, nHeight, initialStart := 0) {
; Function by Sean from:
; https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363
; modified by Marius Șucan and Drugwash
; Sleep, 60 ; megatest

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
    GuiHeight := GuiHeight / (OSDsizingFactor/100) + (OSDsizingFactor/10) + 4
    GuiHeight := (GuiHeight<minHeight) ? minHeight+1 : Round(GuiHeight)
    GuiHeight := (GuiHeight>maxHeight) ? maxHeight-1 : Round(GuiHeight)
  }
  Return nWidth
}

GuiGetSize(ByRef W, ByRef H, vindov) {
; function by VxE from https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
; Sleep, 60 ; megatest

  If (vindov=0)
     Gui, OSDghost: +LastFoundExist
  If (vindov=1)
     Gui, OSD: +LastFoundExist
  If (vindov=5)
     Gui, SettingsGUIA: +LastFoundExist
  VarSetCapacity(rect, 16, 0)
  DllCall("user32\GetClientRect", "Ptr", MyGuiHWND := WinExist(), "Ptr", &rect)
  W := NumGet(rect, 8, "UInt")
  H := NumGet(rect, 12, "UInt")
}

checkMousePresence() {
    If (A_TickCount - LastTypedSince < 1500) || (A_TickCount - DeadKeyPressed < 2000)
       Return

    Thread, Priority, -20
    Critical, off

    WinGetTitle, activeWindow, A
    If ((activeWindow ~= "i)^(KeyPressOSDwin)") && DragOSDmode=0 && SecondaryTypingMode=0)
       HideGUI()

    If (JumpHover=1 && !A_IsSuspended && DragOSDmode=0 && PrefOpen=0)
    {
        MouseGetPos, , , id, control
        WinGetTitle, title, ahk_id %id%
        If (title = "KeyPressOSDwin")
           TogglePosition()
    }
}

MouseMove(wP, lP, msg, hwnd) {
; Function by Drugwash
  Global
  Local A
  SetFormat, Integer, H
  hwnd+=0, A := WinExist("A")
  SetFormat, Integer, D

  If InStr(OSDhandles, hwnd)
  {
    If (DragOSDmode=0 && JumpHover=0 && PrefOpen=0 && (A_TickCount - LastTypedSince > 1000) && (A_TickCount - DoNotRepeatTimer > 1000) && !InStr(dragOSDhandles, hwnd))
       HideGUI()
    Else If (DragOSDmode=1 || PrefOpen=1 || InStr(dragOSDhandles, hwnd))
    {
        If InStr(dragOSDhandles, hwnd)
           SetTimer, HideGUI, Off
        DllCall("user32\SetCursor", "Ptr", hCursM)
        If !(wP&0x13)    ; no LMR mouse button is down, we hover
        {
           If A not in %OSDhandles%
              hAWin := A
        } Else If (wP&0x1)  ; L mouse button is down, we're dragging
        {
           SetTimer, HideGUI, Off
           SetTimer, ReturnToTyped, Off
           GuiControl, OSD: Disable, Edit1  ; it won't drag if it's not disabled
           While GetKeyState("LButton", "P")
           {
              PostMessage, 0xA1, 2,,, ahk_id %hOSD%
              DllCall("user32\SetCursor", "Ptr", hCursM)
           }
           GuiControl, OSD: Enable, Edit1
           SetTimer, trackMouseDragging, -1
           Sleep, 0
        } Else If ((wP&0x2) || (wP&0x10))
           HideGUI()
    }
  }
  Else If ColorPickerHandles
       If hwnd in %ColorPickerHandles%
          DllCall("user32\SetCursor", "Ptr", hCursH)
}

trackMouseDragging() {
; Function by Drugwash
  Global
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

saveGuiPositions() {
; function called after dragging the OSD to a new position

  If (PrefOpen=0)
  {
     Sleep, 700
     SetTimer, HideGUI, 1500
  }

  If (GUIposition=1)
  {
     GuiYa := GuiY
     GuiXa := GuiX
     If (PrefOpen=0)
     {
        INIaction(1, "GuiXa", "OSDprefs")
        INIaction(1, "GuiYa", "OSDprefs")
     }

     If (PrefOpen=1)
     {
       GuiControl, SettingsGUIA:, GuiXa, %GuiX%
       GuiControl, SettingsGUIA:, GuiYa, %GuiY%
     }
  } Else
  {
     GuiYb := GuiY
     GuiXb := GuiX
     If (PrefOpen=0)
     {
        INIaction(1, "GuiXb", "OSDprefs")
        INIaction(1, "GuiYb", "OSDprefs")
     }

     If (PrefOpen=1)
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

LEDsIndicatorsManager() {
    If (OSDshowLEDs=0)
       Return
    GetKeyState, CapsState, CapsLock, T
    GetKeyState, NumState, NumLock, T
    GetKeyState, ScrolState, ScrollLock, T
    GuiControl, OSD:, CapsLED, % (CapsState = "D") ? 100 : 0
    GuiControl, OSD:, NumLED, % (NumState = "D") ? 100 : 0
    GuiControl, OSD:, ScrolLED, % (ScrolState = "D") ? 100 : 0
}

ModsLEDsIndicatorsManager() {
    profix := checkIfModsHeld()
    GuiControl, OSD:, ModsLED, % profix ? 100 : 0
    If profix
    {
       SetTimer, modsTimer, 100, 50
       modHeldDownBeeper()
    }
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

        SetTimer, LEDsIndicatorsManager, -300, 50
    }
    Return tehResult
}

IsDoubleClick() {
    DCT := DllCall("user32\GetDoubleClickTime")
    Return (A_ThisHotKey = A_PriorHotKey && A_TimeSincePriorHotkey < DCT)
}

ClicksTimer() {
    Critical, Off
    Thread, Priority, -50
    ClicksList := ["LButton", "RButton", "MButton"]    
    For i, clicky in ClicksList
    {
        If GetKeyState(clicky)
           profix .= clicky "+"
    }

    If profix
    {
       If (SilentMode=0 && BeepFiringKeys=1 && (A_TickCount-Tickcount_start>950))
          SoundsThread.ahkPostFunction["firingKeys", ""]
       SetTimer, HideGUI, % -DisplayTime
    }
    If !profix
       SetTimer,, off
}

modsTimer() {
    Critical, Off
    Thread, Priority, -50

    GlobalPrefix := profix := ""
    profix := checkIfModsHeld()
    GlobalPrefix := profix
    If (OSDshowLEDs=1)
    {
       GuiControl, OSD:, ModsLED, % profix ? 100 : 0
       SetTimer, ModsLEDsIndicatorsManager, -370, 50
    }
    If profix
    {
       modHeldDownBeeper()
       SetTimer, HideGUI, % -DisplayTime
    }
    If !profix
    {
       GlobalPrefix := profix
       SetTimer,, off
    }
}

modHeldDownBeeper() {
   If (SilentMode=0 && BeepFiringKeys=1 && (A_TickCount-Tickcount_start>950))
      SoundsThread.ahkPostFunction["holdingKeys", ""]
}

CompactModifiers(ztr) {
    CompactPattern := {"LCtrl":"Ctrl", "RCtrl":"Ctrl", "LShift":"Shift", "RShift":"Shift", "LAlt":"Alt", "LWin":"WinKey", "RWin":"WinKey", "RAlt":"AltGr"}
    If (DifferModifiers=0)
    {
        StringReplace, ztr, ztr, LCtrl+RAlt, AltGr, All
        StringReplace, ztr, ztr, AltGr+RAlt, AltGr, All
        StringReplace, ztr, ztr, AltGr+LCtrl, AltGr, All
        For k, v in CompactPattern
            StringReplace, ztr, ztr, %k%, %v%, All
    }
    Return ztr
}

checkIfModsHeld(displayIT:=1) {
    Static LastNoDisplay
    For i, mod in MainModsList
    {
        If GetKeyState(mod)
           modsHeld .= mod "+"
    }

    If (displayIT=1 && modsHeld && OSDvisible && !Typed && ShowSingleModifierKey=1 && OnlyTypingMode=0 && (A_TickCount-Tickcount_start > ShowPrevKeyDelay*3.5) && (A_TickCount-Tickcount_start2 > 100) && (A_TickCount - lastClickTimer > ShowPrevKeyDelay*3.5) && (A_TickCount - LastNoDisplay > ShowPrevKeyDelay*3))
    {
       profix := CompactModifiers(modsHeld)
       Sort, profix, U D+
       profix := RTrim(profix, "+")
       StringReplace, profix, profix, +, %A_Space%+%A_Space%, All
       ShowHotkey(profix)
    }
    If (displayIT=0)
       LastNoDisplay := A_TickCount

    Return modsHeld
}

GetKeyStr() {
;  Sleep, 40 ; megatest
    If (OutputOSDtoToolTip=0 && NeverDisplayOSD=1)
       Return

    Modifiers_temp := 0
    Static FriendlyKeyNames := {NumpadDot:"[ . ]", NumpadDiv:"[ / ]", NumpadMult:"[ * ]", NumpadAdd:"[ + ]", NumpadSub:"[ - ]", numpad0:"[ 0 ]", numpad1:"[ 1 ]", numpad2:"[ 2 ]", numpad3:"[ 3 ]", numpad4:"[ 4 ]", numpad5:"[ 5 ]", numpad6:"[ 6 ]", numpad7:"[ 7 ]", numpad8:"[ 8 ]", numpad9:"[ 9 ]", NumpadEnter:"[Enter]", NumpadDel:"[Delete]", NumpadIns:"[Insert]", NumpadHome:"[Home]", NumpadEnd:"[End]", NumpadUp:"[Up]", NumpadDown:"[Down]", NumpadPgdn:"[Page Down]", NumpadPgup:"[Page Up]", NumpadLeft:"[Left]", NumpadRight:"[Right]", NumpadClear:"[Clear]", Media_Play_Pause:"Media_Play/Pause", MButton:"Middle Click", RButton:"Right Click", Del:"Delete", PgUp:"Page Up", PgDn:"Page Down"}
    prefix := checkIfModsHeld(0)

    If (!prefix && GlobalPrefix)
       prefix := GlobalPrefix
    GlobalPrefix := ""
    SetTimer, modsTimer, Off
    If (!prefix && !ShowSingleKey)
       Throw

    backupKey := key := A_ThisHotkey
    StringReplace, key, key, %A_Space%up,
    Loop, Parse, % "^~#!+<>$*"
        StringReplace, key, key, %A_LoopField%
    backupKey := !key ? backupKey : key

    If (StrLen(key)=1)
    {
        key := GetKeyChar(key)
    } Else If ((SubStr(key, 1, 2)="vk") && SecondaryTypingMode=0 && (StrLen(Typed)<2 || prefix)) {
        key := GetKeyCharWrapper(key)
    } Else If (StrLen(key)<1) && !prefix {
        key := backupKey ? backupKey : "(unknown key)"
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
           Throw
        key := "Print Screen"
    } Else If InStr(key, "lock") {
        key := GetCrayCrayState(key)
    } Else If InStr(key, "wheel") {
        Global lastClickTimer := A_TickCount
        If (ShowMouseButton=0 || OnlyTypingMode=1)
           Throw
        Else
           StringReplace, key, key, wheel, wheel%A_Space%
    } Else If (key = "LButton" && IsDoubleClick()) {
        key := "Double Click"
    } Else If (key = "LButton") {
        If (HideAnnoyingKeys=1 && !prefix)
        {
            If (!(Typed ~= "i)(  │)") && StrLen(Typed)>3 && ShowMouseButton=1 && (A_TickCount - LastTypedSince > 6000)) {
               If !InStr(Typed, Lola2)
                  InsertChar2caret(" ")
            }
            Throw
        }
        key := "Left Click"
    }
    _key := key        ; what's this for? :)
    prefix := CompactModifiers(prefix)
    Sort, prefix, U D+
    StringReplace, prefix, prefix, +, %A_Space%+%A_Space%, All
    If prefix
       SetTimer, modsTimer, 200, 0
    Static pre_prefix, pre_key
    If (OnlyTypingMode=1)
       KeyCount := (StrLen(Typed)>1) ? 1 : 0
    StringUpper, key, key, T
    If InStr(key, "lock on")
       StringUpper, key, key
    StringUpper, pre_key, pre_key, T
    KeyCount := (key=pre_key && prefix=pre_prefix && repeatCount<1.5) ? KeyCount : 1
    filteredPrevKeys := "i)^(vk|Media_|Volume|.*lock)"
    If (ShowPrevKey=1 && KeyCount<2 && (A_TickCount-Tickcount_start < ShowPrevKeyDelay) && !(pre_key ~= filteredPrevKeys) && !(key ~= filteredPrevKeys))
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
       trackingPresses := (Tickcount_start2 - Tickcount_start < 50) ? 1 : 0
       KeyCount := (trackingPresses=0 && KeyCount<1) ? KeyCount+1 : KeyCount
       If (trackingPresses=1)
          KeyCount := !KeyCount ? 1 : KeyCount+1
       If (trackingPresses=0 && InStr(prefix, "+") && (A_TickCount-Tickcount_start < 600) && (Tickcount_start2 - Tickcount_start < 500))
          KeyCount := !KeyCount ? 1 : KeyCount+1
       ShowKeyCountValid := 1
    } Else If (key=pre_key && ShowKeyCountFired=1 && ShowKeyCount=1 && !(key ~= "i)(volume)"))
    {
       KeyCount := !KeyCount ? 0 : KeyCount+1
       ShowKeyCountValid := 1
    } Else If (key=pre_key && ShowKeyCount=0 && DisableTypingMode=0)
    {
       KeyCount := !KeyCount ? 0 : KeyCount+1
       ShowKeyCountValid := 0
    } Else
    {
       KeyCount := 1
       ShowKeyCountValid := 0
    }

    If (prefix != pre_prefix)
    {
        result := (ShowPrevKeyValid=1) ? prefix key " {" pre_prefix pre_key "}" : prefix key
        KeyCount := 1
    } Else If (ShowPrevKeyValid=1)
        key := (Round(KeyCount)>1 && ShowKeyCountValid=1) ? (key " (" Round(KeyCount) ")") : (key ", " pre_key)
    Else If (ShowPrevKeyValid=0)
        key := (Round(KeyCount)>1 && ShowKeyCountValid=1) ? (key " (" Round(KeyCount) ")") : (key)
    Else (KeyCount := 1)

    pre_prefix := prefix
    pre_key := _key
    prefixed := prefix ? 1 : 0
    Return result ? result : prefix . key
}

GetKeyCharWrapper(code) {
    k := GetKeyChar(code)
    If (k=0 || k)
       Return k
    Else
       k := GetKeyName(code)
    Return k
}

GetKeyChar(key) {
; <tmplinshi>: thanks to Lexikos:
; https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236
;  Sleep, 30 ; megatest
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
        n := DllCall("user32\ToUnicodeEx", "UInt", vk, "UInt", sc, "Ptr", &state, "Ptr", &char, "Int", 2, "UInt", 0, "Ptr", hkl)
    Return StrGet(&char, n, "utf-16")
}

SetMyVolume() {
  If (SafeModeExec=1)
     Return

  SoundGet, master_volume
  If (master_volume>50 && BeepsVolume>50)
     val := BeepsVolume - master_volume/3
  Else If (master_volume<49 && BeepsVolume>50)
     val := BeepsVolume + Round(master_volume/6)
  Else If (master_volume<50 && BeepsVolume<50)
     val := BeepsVolume + master_volume/4
  Else
     val := BeepsVolume
  If (val>99)
     val := 99
  SetVolume(val)
}

SetVolume(val:=100, r:="") {
; Function by Drugwash
  v := Round(val*655.35), vr := r="" ? v : Round(r*655.35)
  DllCall("winmm\waveOutSetVolume", "UInt", 0, "UInt", (v|vr<<16))
}

GetVolume(ByRef vl) {
; Function by Drugwash
  DllCall("winmm\waveOutGetVolume", "UInt", 0, "UIntP", vol)
  vl := Round(100*(vol&0xFFFF)/0xFFFF)
  Return Round(100*(vol>>16)/0xFFFF)
}

;================================================================
; Section 4. Functions pertaining to keyboard layout detection
; - CreateHotkey() is the function that initializes the bindings
;   that the script relies on to display any key press.
; - Additional functions related to keyboard layout detection, 
;   can be found in the Drugwash section.
;================================================================

BindTypeHotKeys() {
    Static keysHaveBound
    If (keysHaveBound=1)
       Return
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
    Hotkey, ~^vk41, OnCtrlA, useErrorLevel
    Hotkey, ~^vk43, OnCtrlC, useErrorLevel
    Hotkey, ~^vk56, OnCtrlV, useErrorLevel
    Hotkey, ~^vk58, OnCtrlX, useErrorLevel
    Hotkey, ~^vk5A, OnCtrlZ, useErrorLevel
    keysHaveBound := 1
}

CreateHotkey() {
    #MaxThreads 255
    #MaxThreadsPerHotkey 255
    #MaxThreadsBuffer On

    If (AutoDetectKBD=1)
    {
       IdentifyKBDlayout()
    } Else
    {
       AlternativeHook2keys := DeadKeys := 0
       KeyStrokesThread.ahkassign("AlternativeHook2keys", AlternativeHook2keys)
    }

    Sleep, 20
    Static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "^!", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    Static mods_list := ["!", "!#", "!#^", "!#^+", "!+", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list

; bind keys relevant to the typing mode
    If (DisableTypingMode=0)
    {
        BindTypeHotKeys()
        If (MediateNavKeys=1 && DisableTypingMode=0)
        {
            Hotkey, Home, OnHomeEndPressed, useErrorLevel
            Hotkey, +Home, OnHomeEndPressed, useErrorLevel
            Hotkey, End, OnHomeEndPressed, useErrorLevel
            Hotkey, +End, OnHomeEndPressed, useErrorLevel
        }

        If (SendJumpKeys=0 && IsLangRTL=0)
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

; identify and bind to the list of possible letters/chars
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
          For each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
          {
            If (InStr(char2skip, "vk" code) || n=char2skip)
               Continue, 2
          }
        }
 
        If (IgnoreAdditionalKeys=1)
        {
          For each, char2skip in StrSplit(IgnorekeysList, ".")        ; dead keys to ignore
          {
            If (n=char2skip && IgnoreAdditionalKeys=1)
               Continue, 2
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
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

; bind to dead keys to show the proper symbol when such a key is pressed

    If (DeadKeys=1 && DoNotBindAltGrDeadKeys=0) || (DeadKeys=1 && DoNotBindDeadKeys=0)
    {
        Loop, Parse, DKaltGR_list, .
        {
            For i, mod in mods_list
            {
                If (EnableAltGr=1)
                {
                  Hotkey, % "~^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                }

                If (EnableAltGr=0)
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
               If (!InStr(DKaltGR_list, A_LoopField) && EnableAltGr=1)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnLetterUp, useErrorLevel
               }

               If (EnableAltGr=0)
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
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

    NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
    Loop, Parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       If (ErrorLevel!=0 && AudioAlerts=1)
          SoundBeep, 1900, 50
    }

    Loop, 10 ; Numpad0 - Numpad9 ; numlock on
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnNumpadsPressed, UseErrorLevel
        Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

    NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
    Loop, Parse, NumpadSymbols, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadsPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       If (ErrorLevel!=0 && AudioAlerts=1)
          SoundBeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|CapsLock|ScrollLock|NumLock|Pause|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen"

    If (DisableTypingMode=1)           
       Otherkeys .= "|Left|Right|Up|Down|BackSpace|Del|Home|End|PgUp|PgDn|space"

    Loop, Parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

    If (DisableTypingMode=0 && (SendJumpKeys=1 || MediateNavKeys=1))
       Hotkey, Esc, OnEscPressed, useErrorLevel

    If (ShowMouseButton=1 || ShowMouseVclick=1)
    {
        Loop, Parse, % "LButton|MButton|RButton", |
        Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
        If (ErrorLevel!=0 && AudioAlerts=1)
           SoundBeep, 1900, 50
    }

    For i, mod in MainModsList
    {
       Hotkey, % "~*" mod, OnMudPressed, useErrorLevel
       Hotkey, % "~*" mod " Up", OnMudUp, useErrorLevel
       If (ErrorLevel!=0 && AudioAlerts=1)
          SoundBeep, 1900, 50
    }
}

GenerateDKnames() {
     Loop, Parse, DKnotShifted_list, .
     {
           backupSymbol := SubStr(A_LoopField, InStr(A_LoopField, "vk")+2, 2)
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc)
              DKnamez .= toUnicodeExtended(vk, sc) "~" A_LoopField
           Else If GetKeyName("vk" backupSymbol)
              DKnamez .= GetKeyName("vk" backupSymbol) "~" A_LoopField
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

     IniRead, DKshAltGR_list, %LangFile%, %KbLayoutRaw%, DKshAltGr, %A_Space%
     Loop, Parse, DKshAltGR_list, .
     {
           vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
           sc := "0x0" GetKeySc("vk" vk)
           If toUnicodeExtended(vk, sc, 1, 1)
              DKnamez .= toUnicodeExtended(vk, sc, 1, 1) "~+^!" A_LoopField
     }
}

tehDKcollector() {
; The list of dead keys VKs is loaded from %LangFile%,
; If DKnamez is not defined, the dead keys symbols are
; generated and saved.

  StringRight, shortKBDtest2, KbLayoutRaw, 6
  IniRead, IMEtest, %LangFile%, IMEs, % "00" shortKBDtest2, 0
  If IMEtest
     Return

  IniRead, hasDKs, %LangFile%, %KbLayoutRaw%, hasDKs
  If (hasDKs=1)
  {
      DeadKeys := 1
      IniRead, DKnotShifted_list, %LangFile%, %KbLayoutRaw%, DK, %A_Space%
      IniRead, DKshift_list, %LangFile%, %KbLayoutRaw%, DKshift, %A_Space%
      IniRead, DKaltGR_list, %LangFile%, %KbLayoutRaw%, DKaltGr, %A_Space%
      IniRead, DKshAltGR_list, %LangFile%, %KbLayoutRaw%, DKshAltGr, %A_Space%
      IniRead, DKnamez, %LangFile%, %KbLayoutRaw%, DKnamez, %A_Space%

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
         IniWrite, %DKnamez%, %LangFile%, %KbLayoutRaw%, DKnamez
      }
  } Else If (hasDKs=0)
  {
      AlternativeHook2keys := DeadKeys := 0
      KeyStrokesThread.ahkassign("AlternativeHook2keys", AlternativeHook2keys)
  } Else If (hasDKs="ERROR")
         troubledWaterz := 10
  Return troubledWaterz
}

initLangFile(ForceIT:=0) {
; The script uses %LangFile% to cache data. This allows 
; for considerably faster [re]starts of the script.
;
; If %LangFile% does not exist, it is generated using 
; three main functions:
;
; GetLayoutsInfo(). It detects the installed layouts using
; DllCall("GetKeyboardLayoutList");, the list of dead keys
; identified by VKs and other details, for each layout.
;
; checkInstalledLangs(). Detects installed keyboard layouts
; by reading from Preload and Substitutes registry entries
; (HKCU). This function has the role mainly to double-check
; the list and fill-in the gaps. GetLayoutsInfo() fails
; sometimes to detect all the installed keyboard layouts.
;
; listIMEs(). It attempts to detect installed IMEs such that 
; the user can see these layouts listed as unsupported.
; Beyond this, it has no use. The detection is performed by
; reading registry entries from HKCU\Software\Microsoft\CTP.
;
; Amongst the different functions, inter-conditions are in
; place to attempt avoid incorrect results.

  IniRead, KLIDlist, %LangFile%, Options, KLIDlist, -
  IniRead, UseMUInames2, %LangFile%, Options, UseMUInames, -
  If (!InStr(KLIDlist, KbLayoutRaw) || UseMUInames2!=UseMUInames)
     FileDelete, %LangFile%

  If (!FileExist(LangFile) || ForceIT=1)
  {
      dbg := GetLayoutsInfo()
      FileAppend, %dbg%, %LangFile%, UTF-16
      Sleep, 50
      checkInstalledLangs()
      Sleep, 50
      listIMEs()
      Sleep, 50
      IniRead, KLIDlist, %LangFile%, Options, KLIDlist, %A_Space%
      IniRead, KLIDlist2, %LangFile%, Options, KLIDlist2, %A_Space%
      KLIDlist := KLIDlist "," KLIDlist2
      Sort, KLIDlist, U D,
      Sleep, 50
      IniWrite, %KLIDlist%, %LangFile%, Options, KLIDlist
      IniWrite, %UseMUInames%, %LangFile%, Options, UseMUInames
      Sleep, 25
      IniDelete, %LangFile%, Options, KLIDlist2
      Sleep, 50
  } Else (LoadedLangz := 1)
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
    IniWrite, %PreloadList%, %LangFile%, REGdumpData, PreloadList
    IniWrite, %kbdSubsInstList%, %LangFile%, REGdumpData, SubstitutesList
    REGdump := SubsOnlyList "," PreloadList
    Return REGdump
}

GetInputHKL(win := "") {
; Function from [CLASS] Lyt - Keyboard layout (language) operation
; by Stealzy: https://autohotkey.com/boards/viewtopic.php?t=28258

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

IdentifyKBDlayout() {
; In addition to the mandatory detection of the keys to bind to,
; from Loop, 256 in CreateHotkey(), this function and the
; related ones determine if the current layout is supported
; or not, and to detect dead keys. Beyond this, for the
; user's sake, a list of installed keyboard layouts is
; created, with details for each.

  KbLayoutRaw := checkWindowKBD()
  langFriendlySysName := ISOcodeCulture(KbLayoutRaw) GetLayoutDisplayName(KbLayoutRaw)
  langFriendlySysName := RegExReplace(langFriendlySysName, "i)^(\s)", "")
  perWindowKbLayout := DllCall("user32\GetKeyboardLayout", "UInt", DllCall("user32\GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr",0), "Ptr")
  SetFormat, Integer, H
  PrettyKbLayout := perWindowKbLayout
  SetFormat, Integer, D
  PrettyKbLayout := RegExReplace(PrettyKbLayout, "i)^(\-?0x)", "0")
  If InStr(PrettyKbLayout, "FFFFF")
     PrettyKbLayout := ""

  If (StrLen(langFriendlySysName)<2 && StrLen(PrettyKbLayout)>2)
     langFriendlySysName := ISOcodeCulture(KbLayoutRaw) GetLayoutDisplayName(perWindowKbLayout)

  initLangFile()
  If !ScriptInitialized
  {
     testLangExist := tehDKcollector()
     Sleep, 25
     If (testLangExist=10)
     {
         hkl := GetInputHKL()
         Sleep, 50
         IniDelete, %LangFile%, %KbLayoutRaw%
         dbg := GetLayoutInfo(KbLayoutRaw, hkl)
         FileAppend, %dbg%, %LangFile%, UTF-16
         Sleep, 50
         tehDKcollector()
         Sleep, 50
     }
  }
  IniRead, IsLangRTL, %LangFile%, %KbLayoutRaw%, isRTL
  IniRead, isVertUp, %LangFile%, %KbLayoutRaw%, isVertUp
  If (isVertUp=1)
     KBDisUnsupported := 1

  StringRight, shortKBDtest0, KbLayoutRaw, 4
  If (StrLen(PrettyKbLayout)>2 && InStr(PrettyKbLayout, shortKBDtest0))
  {
     StringLeft, shortKBDtest1, PrettyKbLayout, 4
     shortKBDtest1 := "0000" shortKBDtest1
     StringRight, shortKBDtest2, PrettyKbLayout, 4
     shortKBDtest2 := "0000" shortKBDtest2
     IniRead, IMEtest, %LangFile%, IMEs, %shortKBDtest2%, 0
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

  CurrentKBD := "Detected: " langFriendlySysName ". " KbLayoutRaw " " PrettyKbLayout
  If (IsLangRTL=1)
     CurrentKBD := "Partial support: " langFriendlySysName ". " KbLayoutRaw " " PrettyKbLayout

  If (KBDisUnsupported=1)
     CurrentKBD := "Unsupported: " langFriendlySysName ". " KbLayoutRaw " " PrettyKbLayout

  If (SilentDetection=0 && !ScriptInitialized)
  {
      ShowLongMsg("Detected: " langFriendlySysName)
      If (KBDisUnsupported=1 || IsLangRTL=1)
      {
         ShowLongMsg(CurrentKBD)
         SoundBeep, 300, 900
      }
      SetTimer, HideGUI, % -DisplayTime/2
  }

  If !ScriptInitialized
  {
     StringLeft, clayout, langFriendlySysName, 25
     Menu, Tray, Add, %clayout%, dummy
     Menu, Tray, Disable, %clayout%
     Menu, Tray, Add
     If (ConstantAutoDetect=1 && AutoDetectKBD=1)
        SetTimer, ConstantKBDdummyDelay, -4000, 915
  }
}

GetLocaleInfo(ByRef strg, loc, HKL:=0) {
; Function by Drugwash
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

HasIME(HKL, bool:=1) {
; Function by Drugwash
  If (A_OSVersion!="WIN_XP")
     Return False
  If bool
     Return ((HKL>>28)&0xF=0xE) ? 1 : 0
  Return ((HKL>>28)&0xF=0xE) ? "Yes" : "No"
}

GetIMEName(subkey, usemui:=1) {
; Function by Drugwash
    Static key := "Software\Microsoft\CTF\TIP"
    RegRead, mui, HKLM, %key%\%subkey%, Display Description
    If (!mui OR !usemui)
      RegRead, Dname, HKLM, %key%\%subkey%, Description
    Else
      Dname := SHLoadIndirectString(mui)
    Return Dname
}

findIMEname(givenKLID) {
; Function by Drugwash
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
; Function by Drugwash
    r := "0x" KLID
    Return (r & 0xFFFF)
}

GetLocaleTextDir(KLID, ByRef rtl, ByRef vh, ByRef vbt, bool:=1) {
; Function by Drugwash, inspired by Michael S. Kaplan:
; http://archives.miloush.net/michkap/archive/2006/03/03/542963.html
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
; Function by Drugwash
    Global dbg
    Static MODei := ",shift,altGr,shAltGr"

    LoadedLangz := 1
    IniWrite, %LoadedLangz%, %LangFile%, Options, LoadedLangz
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
; Function by Drugwash
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
        LoadedLangz := 1, KBDsCount := 0
        IniWrite, %LoadedLangz%, %LangFile%, Options, LoadedLangz
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
        IniWrite, %KLIDlist%, %LangFile%, Options, KLIDlist
        IniWrite, %KBDsCount%, %LangFile%, Options, KBDsDetected
      }
      VarSetCapacity(hklbuf, 0)
    }
    While DllCall("msvcrt\_kbhit", "CDecl")
          DllCall("msvcrt\_getche", "CDecl")      ; Clear keyboard buffer
    DllCall("user32\ActivateKeyboardLayout", "Ptr", currHKL, "UInt", 0)  ; Restore layout for current thread
    Return dbg
}

GetDeadKeys(hkl, i, c:=0) {
; Function by Drugwash. Many thanks!
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
          , "UInt"  , 3                ; MAPVK_VSC_TO_VK_EX=3
          , "Ptr"    , hkl)
      If !n := DllCall("ToUnicodeEx"   ; -1=dead key, 0=no trans, 1=1 char, 2+=uncombined dead char+char
          , "UInt"  , uVirtKey
          , "UInt"  , uScanCode
          , "Ptr"    , &lpKeyState
          , "Ptr"    , &pwszBuff
          , "Int"    , cchBuff
          , "UInt"  , 0
          , "Ptr"    , hkl)
          Continue
      If n<0
      {
        n := DllCall("ToUnicodeEx"
        , "UInt"  , uVirtKey     ; VK_SPACE 0x20
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
; Function by Drugwash
    VarSetCapacity(out, (len+1)*2, 32), c := caps ? "X" : "x"
    DllCall("msvcrt\sprintf", "AStr", out, "AStr", "%0" len "ll" c, "UInt64", val, "CDecl")
    Return x ? "0x" out : out
}

SHLoadIndirectString(in) {
; Function by Drugwash
    ; uses WStr for both in and out
    VarSetCapacity(out, 2*(sz:=256), 0)
    DllCall("shlwapi\SHLoadIndirectString", "Str", in, "Str", out, "UInt", sz, "Ptr", 0)
    Return out
}

GetLayoutDisplayName(subkey) {
; Function by Drugwash
    Static key := "SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    RegRead, mui, HKLM, %key%\%subkey%, Layout Display Name
    If (StrLen(mui)<4 || UseMUInames=0)
       RegRead, Dname, HKLM, %key%\%subkey%, Layout Text
    Else
       Dname := SHLoadIndirectString(mui)
    Return Dname
}

checkWindowKBD() {
; Function by Drugwash
    threadID := GetFocusedThread(hwnd := WinExist("A"))
    hkl := DllCall("user32\GetKeyboardLayout", "UInt", threadID)        ; 0 for current thread
    If !DllCall("user32\ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0x100)  ; hkl: 1=next, 0=previous | flags: 0x100=KLF_SETFORPROCESS
    {
      SetFormat, Integer, H
      l := SubStr(hkl & 0xFFFF, 3)
      klid := SubStr("00000000" l, -7)
      SetFormat, Integer, D
      DllCall("user32\LoadKeyboardLayoutW", "Str", klid, "UInt", 0x103)    ; AW, flags: 0x100=KLF_SETFORPROCESS 0x1=KLF_ACTIVATE 0x2=KLF_SUBSTITUTE_OK
    }
    DllCall("user32\GetKeyboardLayoutNameW", "Str", klid:="00000000")  ; AW
;    ToolTip, hwndA=%hwnd% -- hkl=%hkl% -- klid=%klid%
    Return klid
}

GetFocusedThread(hwnd := 0) {
; Function by Drugwash
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
      IniRead, hasThisIME, %LangFile%, %A_LoopField%, hasIME, 0
      IniRead, KBDisUnsupported, %LangFile%, %langRealInstalled%, KBDisUnsupported, 0
      If (isVertUp=1 || hasThisIME=1)
         KBDisUnsupported := 1

      If StrLen(langFriendlySysName)<2
      {
         langFriendlySysName := "Unrecognized"
         KBDisUnsupported := 1
      }
      IniWrite, %langFriendlySysName%, %LangFile%, %langRealInstalled%, name
      IniWrite, %isRTL%, %LangFile%, %langRealInstalled%, isRTL
      IniWrite, %hasThisIME%, %LangFile%, %langRealInstalled%, hasIME
      IniWrite, %isVertUp%, %LangFile%, %langRealInstalled%, isVertUp
      IniWrite, %KBDisUnsupported%, %LangFile%, %langRealInstalled%, KBDisUnsupported
      countedLayouts++
    }
    StringTrimRight, langRealInstList, langRealInstList, 1
    IniWrite, %countedLayouts%, %LangFile%, Options, KBDsDetected
    IniWrite, %langRealInstList%, %LangFile%, Options, KLIDlist2
}

listIMEs() {
    If (A_OSVersion ~= "i)(WIN_XP|WIN_2000)")
       Return

    IniRead, KBDsDetected, %LangFile%, Options, KBDsDetected, -
    IniRead, PreloadList, %LangFile%, REGdumpData, PreloadList, -
    skey := "Software\Microsoft\CTF\SortOrder\AssemblyItem"
    countedIMEs := 0
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
               IniWrite, %s1ss%, %LangFile%, IMEs, %s1s%
               IniWrite, %description%, %LangFile%, IMEs, name%countedIMEs%
               Sleep, 50
               If s1ss
               {
                  StringRight, TeHstart, s1ss, 4
                  testS1nonIME := TeHstart s1end
                  StringReplace, kbdList, KeyboardLayoutsList, 0x, 0
               }
             }
         }
         If (!InStr(KeyboardLayoutsList, testS1nonIME) && testS1nonIME)
         {
            IniRead, kbdName, %LangFile%, %s1s%, name, -
            IniRead, testIMEz, %LangFile%, IMEs, %s1s%, -
            Sleep, 25
            If (StrLen(kbdName)>1 && StrLen(testIMEz)>2)
               IniWrite, 1, %LangFile%, %s1s%, doNotList
         }
      }
    }
    Loop, Reg, HKEY_CURRENT_USER\Software\Microsoft\CTF\HiddenDummyLayouts, KV
    {
         RegRead, value
         IniWrite, %value%, %LangFile%, IMEs, %a_LoopRegName%
    }
    KBDsDetected := KBDsDetected + countedIMEs
    IniWrite, %KBDsDetected%, %LangFile%, Options, KBDsDetected
;    IniWrite, %TehBigList%, %LangFile%, REGdumpData, Assemblies
;    IniWrite, %CLSIDlist%, %LangFile%, REGdumpData, CLSIDlist
}

ConstantKBDdummyDelay() {
  Thread, Priority, -20
  Critical, off
  Sleep, 5
  IniRead, KBDsDetected, %LangFile%, Options, KBDsDetected
  If (KBDsDetected<2)
  {
     ConstantAutoDetect := 0
     Menu, Tray, % (ConstantAutoDetect=0 ? "Uncheck" : "Check"), &Monitor keyboard layout
     Return
  }
  SetTimer, ConstantKBDtimer, 950, -25
}

ConstantKBDtimer() {
    If (A_TimeIdle > 5000)
       Return

    If (A_IsSuspended || SecondaryTypingMode=1 || (A_TickCount - LastTypedSince < 1000) || (A_TickCount - DeadKeyPressed < 6900) || AnyWindowOpen>0)
       Return

    Critical, off
    newLayout := checkWindowKBD()
    If (newLayout!=KbLayoutRaw)
    {
       If (SilentDetection=0 && SilentMode=0)
          SoundsThread.ahkPostFunction["firingKeys", ""]
       If (A_TickCount - LastTypedSince > 1500) && (A_TickCount - Tickcount_start > 700)
          ReloadScript()
    }
}

;================================================================
; Section A. Alternate typing mode functions.
;================================================================

createTypingWindow() {
    Global

    Gui, TypingWindow: Destroy
    Gui, TypingWindow: Margin, 20, 10
    Gui, TypingWindow: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow
    Gui, TypingWindow: Color, %TypingColorHighlight%
    WinSet, Transparent, 155
}

SwitchSecondaryTypingMode() {
   If (Capture2Text=1 || PrefOpen=1)
   {
      SoundBeep, 300, 900
      Return
   }
   Static BkcpShowDeadKeys, BkcpShowSingleKey, BkcpEnterErasesLine, BkcpEnableTypingHistory, BkcpOnlyTypingMode, BkcpDisableTypingMode, BkcpNeverDisplayOSD, BkcpPrioritizeBeepers
   BindTypeHotKeys()
   Sleep, 10
   checkWindowKBD()
   Sleep, 10
   Global DoNotRepeatTimer := A_TickCount
   createTypingWindow()
   SecondaryTypingMode := !SecondaryTypingMode

   If (SecondaryTypingMode=1)
   {
       Window2ActivateHwnd := WinExist("A")
       Sleep, 25
       checkWindowKBD()
       Sleep, 25
       BkcpShowDeadKeys := (ShowDeadKeys=1) ? "y" : "n"
       BkcpShowSingleKey := (ShowSingleKey=1) ? "y" : "n"
       BkcpEnterErasesLine := (EnterErasesLine=1) ? "y" : "n"
       BkcpEnableTypingHistory := (EnableTypingHistory=1) ? "y" : "n"
       BkcpOnlyTypingMode := (OnlyTypingMode=1) ? "y" : "n"
       BkcpDisableTypingMode := (DisableTypingMode=1) ? "y" : "n"
       BkcpNeverDisplayOSD := (NeverDisplayOSD=1) ? "y" : "n"
       BkcpPrioritizeBeepers := (PrioritizeBeepers=1) ? "y" : "n"
       WinGetTitle, Window2Activate, A
       toggleWidth := FontSize/2 < 11 ? 11 : FontSize/2 + 40
       typeGuiX := GuiX - toggleWidth/2 - 15
       Gui, TypingWindow: Show, x%typeGuiX% y%GuiY% h%GuiHeight% w%toggleWidth%, KeyPressOSDtyping
       WinSet, AlwaysOnTop, On, KeyPressOSDtyping
       ShowDeadKeys := 0
       ShowSingleKey := 1
       EnterErasesLine := 1
       EnableTypingHistory := 1
       NeverDisplayOSD := 0
       DisableTypingMode := 0
       OnlyTypingMode := 1
       PrioritizeBeepers := 1
       SoundsThread.ahkassign("PrioritizeBeepers", PrioritizeBeepers)
       Typed := ""
       BackTypeCtrl := ""
       CalcVisibleText()
       OnMSGchar := ""
       SetTimer, checkTypingWindow, on, 700, -10
   } Else
   {
       OnMSGchar := ""
       OnMSGdeadChar := ""
       Gui, TypingWindow: Destroy
       ShowDeadKeys := (BkcpShowDeadKeys="y") ? 1 : 0
       ShowSingleKey := (BkcpShowSingleKey="y") ? 1 : 0
       EnterErasesLine := (BkcpEnterErasesLine="y") ? 1 : 0
       EnableTypingHistory := (BkcpEnableTypingHistory="y") ? 1 : 0
       OnlyTypingMode := (BkcpOnlyTypingMode="y") ? 1 : 0
       DisableTypingMode := (BkcpDisableTypingMode="y") ? 1 : 0
       NeverDisplayOSD := (BkcpNeverDisplayOSD="y") ? 1 : 0
       PrioritizeBeepers := (BkcpPrioritizeBeepers="y") ? 1 : 0
       BkcpShowDeadKeys := BkcpShowSingleKey := BkcpEnterErasesLine := BkcpEnableTypingHistory := BkcpOnlyTypingMode := BkcpDisableTypingMode := BkcpNeverDisplayOSD := BkcpPrioritizeBeepers := ""
       CalcVisibleText()
       SoundsThread.ahkassign("PrioritizeBeepers", PrioritizeBeepers)
       SetTimer, checkTypingWindow, off
   }
   If (NeverDisplayOSD=0)
   {
      ShowHotkey(VisibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
   } Else
   {
      Sleep, 300
      HideGUI()
   }
   OnMessage(0x102, "CharMSG", 2)
   OnMessage(0x103, "deadCharMSG", 2)
}

checkTypingWindow() {
   IfWinNotActive, KeyPressOSDtyping
   {
       BackTypeCtrl := (Typed || A_TickCount-LastTypedSince > DisplayTimeTyping) ? Typed : BackTypeCtrl
       Sleep, 200
       If (PasteOnClick=1)
          sendOSDcontent()
       Sleep, 45
       If (EnableTypingHistory=1)
          recordTypedHistory()
       Sleep, 5
       SwitchSecondaryTypingMode()
       cleanTypeSlate()
   }
}

CharMSG(wParam, lParam) {
    If (SecondaryTypingMode=0)
       Return

    OnMSGchar := chr(wParam)
    If RegExMatch(OnMSGchar, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
       InsertChar2caret(OnMSGchar)

    Global DeadKeyPressed := 9900
    Global LastTypedSince := A_TickCount
    OnMSGchar := ""
    OnMSGdeadChar := ""
    CalcVisibleText()
    ShowHotkey(VisibleTextField)
    If (KeyBeeper=1 || CapslockBeeper=1)
       SetTimer, charMSGbeeper, -40, 30
}

charMSGbeeper() {
    SoundsThread.ahkPostFunction["OnLetterPressed", ""]
}

deadCharMSG(wParam, lParam) {
  If (SecondaryTypingMode=0)
     Return
  Sleep, 50
  OnMSGdeadChar := chr(wParam) ; & 0xFFFF
  If (DeadKeyBeeper=1)
     SoundsThread.ahkPostFunction["OnDeathKeyPressed", ""]
  CaretSymbolChangeIndicator(OnMSGdeadChar, 950, 1)
  Global DeadKeyPressed := A_TickCount
}

KeyStrokeReceiver(wParam, lParam) {
    If (NeverDisplayOSD=1 || SecondaryTypingMode=1 || PrefOpen=1)
       Return True

    If TrueRmDkSymbol && (A_TickCount-DeadKeyPressed < 9000) || (DeadKeys=0) && (A_TickCount-DeadKeyPressed < 9000) || (DoNotBindDeadKeys=1)
    {
       StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
       testKey := StrGet(StringAddress)  ; Copy the string out of the structure.
       If RegExMatch(testKey, "[\p{L}\p{M}\p{N}\p{P}\p{S}]")
          ExternalKeyStrokeRecvd := testKey
    }
    Return True
}

;================================================================
; Section B. Clipboard history manager functions.
;================================================================

processClippy(troll, clippyMode:=1) {
   Stringleft, troll, troll, 200
   StringReplace, troll, troll, %A_TAB%, %A_Space%, All
   StringReplace, troll, troll, %Lola%,, All
   StringReplace, troll, troll, %Lola2%,, All
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
    Static PrivateMode
    ClippyData := Clipboard
    PrivateMode := (NeverDisplayOSD=1 || A_IsSuspended=1) ? 1 : 0
    If (EnableClipManager=1 && StrLen(clippyData)>0 && (A_TickCount-DoNotRepeatTimer>2000))
       ClipboardManager(PrivateMode, ClippyData)

    If (A_IsSuspended=1 || (OutputOSDtoToolTip=0 && NeverDisplayOSD=1))
       Return

    If (Type=1 && ClipMonitor=1 && (A_TickCount-LastTypedSince > DisplayTimeTyping/2))
    {
       troll := ProcessClippy(ClippyData, 0)
       If (NeverDisplayOSD=0)
          ShowLongMsg(troll)
       Else
          ShowHotkey(troll)
       SetTimer, HideGUI, % -DisplayTime*2
    } Else If (type=2 && ClipMonitor=1 && (A_TickCount-LastTypedSince > DisplayTimeTyping))
    {
       If (NeverDisplayOSD=0)
          ShowLongMsg("Clipboard data changed")
       Else
          ShowHotkey("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

InitClipboardManager() {
    INIaction(0, "ClipDataMD5s", "ClipboardManager")
    INIaction(0, "CurrentClippyCount", "ClipboardManager")
    If !FileExist(A_ScriptDir "\ClipsSaved")
    {
        FileCreateDir, ClipsSaved
        ClipDataMD5s := ""
        CurrentClippyCount := 0
    }
}

varMD5(V) {
; Found on / posted by SKAN:
; https://autohotkey.com/board/topic/59576-filecrc32-filesha1-filemd5-and-md5/
; Function from: www.autohotkey.com/forum/viewtopic.php?p=275910#275910

   StringReplace, v, v, %Lola%,, All
   StringReplace, v, v, %Lola2%,, All
   L := StrLen(V)
   VarSetCapacity( MD5_CTX,104,0 )
   DllCall( "advapi32\MD5Init", Str,MD5_CTX )
   DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,V, UInt,L ? L : StrLen(V) )
   DllCall( "advapi32\MD5Final", Str,MD5_CTX )
   Loop % StrLen( Hex:="123456789ABCDEF0" )
        N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
   Return MD5
}

ClipboardManager(PrivateMode, ClipData) {
    Static PrivateClipsMD5s
    Sleep, 150
    If (StrLen(ClipData) > Round(MaxRTFtextClipLen/2))
       Sleep, 1500

    If (ClipData ~= "i)^(.?\:\\.?.?)") && StrLen(ClipData)>5
       Return
    MD5check := VarMD5(ClipData)
    If InStr(ClipDataMD5s, MD5check)
       Return
    If InStr(PrivateClipsMD5s, MD5check)
       Return
    If (PrivateMode=1)
    {
       PrivateClipsMD5s .= MD5check ","
       Return
    }
    If StrLen(MD5check)<3
       Return

    ClipTXT := ProcessClippy(ClipData)
    If !ClipTXT
       Return

    ClipDataMD5s .= MD5check ","
    MaxLengthMD5s := (StrLen(MD5check)+1)*MaximumTextClips
    StringRight, ClipDataMD5s, ClipDataMD5s, MaxLengthMD5s
    CurrentClippyCount++
    If (CurrentClippyCount>MaximumTextClips)
       CurrentClippyCount := 1
    AddZero := CurrentClippyCount<10 ? "0" : ""
    FileDelete, ClipsSaved\Clip%AddZero%%CurrentClippyCount%.clp
    Sleep, 25
    FileDelete, ClipsSaved\clip%addZero%%currentClippyCount%.ctx
    Sleep, 25
    If (StrLen(ClipData) > MaxRTFtextClipLen)
       FileAppend, %ClipData%, ClipsSaved\clip%addZero%%currentClippyCount%.ctx
    Else
       FileAppend, %ClipboardAll%, ClipsSaved\clip%addZero%%currentClippyCount%.clp
    Sleep, 25
    IniWrite, %ClipTXT%, %IniFile%, ClipboardManager, ClipTXT%CurrentClippyCount%
    INIaction(1, "CurrentClippyCount", "ClipboardManager")
    INIaction(1, "ClipDataMD5s", "ClipboardManager")
}

DeleteAllClippy() {
    MsgBox, 4,, Are you sure you want to delete all the stored text clips?
    IfMsgBox, Yes
    {
        CurrentClippyCount := 0
        ClipDataMD5s := ""
        IniDelete, %IniFile%, ClipboardManager
        Sleep, 25
        INIaction(1, "ClipMonitor", "ClipboardManager")
        INIaction(1, "DoNotPasteClippy", "ClipboardManager")
        INIaction(1, "EnableClipManager", "ClipboardManager")
        INIaction(1, "MaximumTextClips", "ClipboardManager")
        INIaction(1, "MaxRTFtextClipLen", "ClipboardManager")
        Sleep, 25
        FileDelete, ClipsSaved\clip*.c*
        Sleep, 25
        VerifyKeybdOptions()
    }
}

GenerateClippyMenu() {
    Sleep, 25
    Static PrivateMode
    Loop, Files, ClipsSaved\clip*.c*
    {
        If (A_Index>MaximumTextClips)
           Break
        TheIndex := A_Index
        IniRead, ClipTXT, %IniFile%, ClipboardManager, ClipTXT%TheIndex%, -
        StringReplace, FillName, A_LoopFileName, clip
        StringReplace, FillName, FillName, .clp
        StringReplace, FillName, FillName, .ctx
        TheClippyList .= A_LoopFileTimeModified "|-[-|" FillName ". " ClipTXT "`n"
    }
    ClippyData := Clipboard
    troll := ProcessClippy(ClippyData)
    StringLeft, troll, troll, 45
    Sort, TheClippyList, R
    Menu, ClippyMenu, Delete
    PrivateMode := (NeverDisplayOSD=1 || A_IsSuspended=1) ? 1 : 0
    If (StrLen(troll)>0 && PrefOpen=0)
    {
        If (StrLen(ClippyData) < Round(MaxRTFtextClipLen/2))
        {
            MD5checkTest := VarMD5(ClippyData)
;           MD5checkList .= "," varMD5(Clipboard)
            If !InStr(ClipDataMD5s, md5checkTest)
               ClipboardManager(PrivateMode, ClippyData)
        }
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
        CountClippies++
    }
    Menu, ClippyMenu, Add
    If (CountClippies<1)
    {
       Menu, ClippyMenu, Add, No saved clipboards, dummy
       Menu, ClippyMenu, Disable, No saved clipboards
    }

    If (PrefOpen=0)
    {
       If (EnableTypingHistory=1)
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
    } Else If (CountClippies>0)
       Menu, ClippyMenu, Add, { Delete All }, DeleteAllClippy

    If (PrefOpen=0 && DisableTypingMode=0 && (SendJumpKeys=1 || MediateNavKeys=1))
    {
       Menu, ClippyMenu, Add
       Menu, ClippyMenu, Add, { Close }, dummy
    }
}

PasteCurrentClippy() {
  Sleep, 70
  If (SecondaryTypingMode=0)
  {
     Sendinput ^{vk56}
     Sleep, 600
  }

  If (DisableTypingMode=0)
     textClipboard2OSD(Clipboard)
}

PasteSelectedClippy() {
  If (PrefOpen=1)
     Return
  ErrorLevel := 0
  StringLeft, ReadThisFile, A_ThisMenuItem, 2
  Global DoNotRepeatTimer := A_TickCount
  FileGetSize, FileSize, ClipsSaved\clip%readThisFile%.clp, M
  Try FileRead, Clipboard, *c ClipsSaved\clip%ReadThisFile%.clp
  If ErrorLevel
  {
     Sleep, 50
     FileGetSize, FileSize, ClipsSaved\clip%readThisFile%.ctx, M
     Try FileRead, ClipData, ClipsSaved\clip%readThisFile%.ctx
     Clipboard := ClipData
     TxtMode := 1
  }
  If ErrorLevel
  {
     ShowLongMsg("Unable to change clipboard...")
     SoundBeep, 900, 500
     SetTimer, HideGUI, % -DisplayTime
     Return
  }
  Global DoNotRepeatTimer := A_TickCount
  Sleep, 70
  If (DoNotPasteClippy!=1 || SecondaryTypingMode=1)
  {
      If (SecondaryTypingMode=0)
      {
         ClipWait, 5
         Sendinput ^{vk56}
         Sleep, 500
         If (FileSize>7)
            Sleep, 1500
      }

      If (DisableTypingMode=0)
      {
         If (TxtMode=1)
            TextClipboard2OSD(ClipData)
         Else
            TextClipboard2OSD(Clipboard)
      }
  }
}

PasteSelectedHistory() {
  StringLeft, ThisField, A_ThisMenuItem, 2
  StringReplace, ThisField, ThisField, h
  content := editField%ThisField%
  StringReplace, content, content, %Lola%,, All
  StringReplace, content, content, %Lola2%,, All
  Sleep, 50
  If (DoNotPasteClippy!=1 || SecondaryTypingMode=1)
  {
     If (SecondaryTypingMode=0)
        SendInput, {text}%content%
     Sleep, 350
     If (DisableTypingMode=0)
        textClipboard2OSD(content)
  } Else (Clipboard := content)
}

ToggleTypingHistory() {
    EnableTypingHistory := !EnableTypingHistory
    INIaction(1, "EnableTypingHistory", "TypingMode")
}

;================================================================
; Section 5. KeyPress features invoked by keyboard shortcuts
; - The hotkeys registered replace the system default
;   behavior / action of the key.
; - Functions related to the features associated
;   to these hotkeys are grouped here.
;================================================================

RegisterGlobalShortcuts(HotKate,destination,apriori) {
   testHotKate := RegExReplace(HotKate, "i)^(\!|\^|\#|\+)$", "")
   If (InStr(HotKate, "disa") || StrLen(HotKate)<1)
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
    If (AlternateTypingMode=1)
       KBDaltTypeMode := RegisterGlobalShortcuts(KBDaltTypeMode,"SwitchSecondaryTypingMode", "!^CapsLock")

    If (PasteOSDcontent=1 && DisableTypingMode=0)
    {
       KBDpasteOSDcnt1 := RegisterGlobalShortcuts(KBDpasteOSDcnt1,"sendOSDcontent", "^+Insert")
       KBDpasteOSDcnt2 := RegisterGlobalShortcuts(KBDpasteOSDcnt2,"sendOSDcontent2", "^+!Insert")
    }

    If (DisableTypingMode=0 && GlobalKBDhotkeys=1)
    {
       KBDsynchApp1 := RegisterGlobalShortcuts(KBDsynchApp1,"SynchronizeApp", "#Insert")
       KBDsynchApp2 := RegisterGlobalShortcuts(KBDsynchApp2,"SynchronizeApp2", "#!Insert")
    }

    If (EnableClipManager=1)
       KBDclippyMenu := RegisterGlobalShortcuts(KBDclippyMenu,"InvokeClippyMenu", "#v")

    If (GlobalKBDhotkeys=1)
    {
       KBDTglNeverOSD := RegisterGlobalShortcuts(KBDTglNeverOSD,"ToggleNeverDisplay", "!+^F8")
       KBDTglPosition := RegisterGlobalShortcuts(KBDTglPosition,"TogglePosition", "!+^F9")
       If (IsSoundsFile && MissingAudios=0 && SafeModeExec=0 && NoAhkH!=1)
          KBDTglSilence := RegisterGlobalShortcuts(KBDTglSilence,"ToggleSilence", "!+^F10")
       KBDidLangNow := RegisterGlobalShortcuts(KBDidLangNow,"DetectLangNow", "!+^F11")
       KBDReload := RegisterGlobalShortcuts(KBDReload,"ReloadScriptNow", "!+^F12")
       If (IsAcc1File=1 && IsAcc2File=1 && A_OSVersion!="WIN_XP")
          KBDCapText := RegisterGlobalShortcuts(KBDCapText,"AccCaptureTextNow", "Disabled")
    }
}

ForceReleaseMODs() {
   Loop
   {
       If GetKeyState("Ctrl")
       {
           Sleep, 5
           Sendinput, {Ctrl up}
       } Else (CtrlhasUpped := 1)

       If GetKeyState("Alt")
       {
           Sleep, 5
           Sendinput, {Alt up}
       } Else (AlthasUpped := 1)

       If GetKeyState("Shift")
       {
           Sleep, 5
           Sendinput, {Shift up}
       } Else (ShifthasUpped := 1)

       If GetKeyState("LWin")
       {
           Sleep, 5
           Sendinput, {LWin up}
       } Else (LWinhasUpped := 1)

       If GetKeyState("RWin")
       {
           Sleep, 5
           Sendinput, {RWin up}
       } Else (RWinhasUpped := 1)

       if (ShifthasUpped=1 && CtrlhasUpped=1 && AlthasUpped=1 && RWinhasUpped=1 && LWinhasUpped=1)
          hasUpped := 1
   } Until (hasUpped=1 || A_Index>200)
}

SynchronizeApp(SynchronizeMode:=0) {
  If (A_IsSuspended=1 || SecondaryTypingMode=1)
     Return
  If (OutputOSDtoToolTip=0 && NeverDisplayOSD=1)
     Return
  BkcpEnableClipManager := (EnableClipManager=1) ? "y" : "n"
  EnableClipManager := 0
  Global DoNotRepeatTimer := A_TickCount
  clipBackup := ClipboardAll
  Clipboard := ""
  WinGetTitle, Window2ActivateNow, A
  hwndStart := WinExist("A")
  If !SynchronizeMode
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
     ClipWait, 2
  
  ClipData := Clipboard
  If (StrLen(ClipData)>0)
  {
     StringRight, Typed, ClipData, 950
     StringReplace, Typed, Typed, %A_TAB%, %A_SPACE%, All
     StringReplace, Typed, Typed, `r`n, %A_SPACE%, All
     CaretPos := StrLen(Typed)+1
     Typed := ST_Insert(Lola, Typed, CaretPos)
     KeyCount := 1
     CalcVisibleText()
     ShowHotkey(VisibleTextField)
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
  ClipData := " "
  Global LastTypedSince := A_TickCount
  EnableClipManager := (BkcpEnableClipManager="y") ? 1 : 0
}

SynchronizeApp2() {
  If (SecondaryTypingMode=1 || A_IsSuspended=1)
     Return
  SynchronizeApp(1)
}

sendOSDcontent(ForceIT:=0, mode:=0) {
  If (ForceIT=0)
  {
     If (A_IsSuspended=1 || NeverDisplayOSD=1)
        Return
  }
  Typed := BackTypeCtrl
  If (StrLen(Typed)<2 && (A_TickCount-LastTypedSince < ReturnToTypingDelay/2))
     Typed := EditField2
  If (StrLen(Typed)>1)
  {
     StringReplace, Typed, Typed, %Lola%
     StringReplace, Typed, Typed, %Lola2%
     Sleep, 25
     If (mode=1)
     {
        Sendinput ^{vk41}
        Sleep, 25
     }
     Sendinput {text}%Typed%
     Sleep, 25
     CaretPos := StrLen(Typed)+1
     Typed := ST_Insert(Lola, Typed, CaretPos)
     Global LastTypedSince := A_TickCount
     CalcVisibleText()
     ShowHotkey(VisibleTextField)
     SetTimer, HideGUI, % -DisplayTimeTyping
  } Else
  {
     ShowLongMsg("Nothing to paste...")
     SetTimer, HideGUI, % -DisplayTime
  }
}

sendOSDcontent2() {
  If (SecondaryTypingMode=1 || A_IsSuspended=1)
     Return
  sendOSDcontent(0,1)
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

   If (PrefOpen=1 && A_IsSuspended=1)
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }
 
   If (Capture2Text=1)
      ToggleCapture2Text()
   If (AccTextCaptureActive=1)
      ToggleAccCaptureText()
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
   cleanTypeSlate()
   friendlyName := A_IsSuspended ? "activated" : "deactivated"
   ShowLongMsg("KeyPress OSD " friendlyName)
   SetTimer, HideGUI, % -DisplayTime/2
   If (NoAhkH!=1 && partially=0)
   {
      ScriptelSuspendel := A_IsSuspended ? 0 : "Y"
      MouseFuncThread.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
      Sleep, 5
      MouseFuncThread.ahkPostFunction["ToggleMouseTimerz", ScriptelSuspendel]
      SoundsThread.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
      MouseRipplesThread.ahkassign("ScriptelSuspendel", ScriptelSuspendel)
      Sleep, 5
      MouseRipplesThread.ahkPostFunction["ToggleMouseRipples", ScriptelSuspendel]
   }
   Sleep, 50
   Suspend
}

ToggleNeverDisplay() {
   If (SecondaryTypingMode=1)
      Return

   cleanTypeSlate()
   NeverDisplayOSD := !NeverDisplayOSD
   INIaction(1, "NeverDisplayOSD", "OSDprefs")
   Menu, Tray, % (NeverDisplayOSD=0 ? "Uncheck" : "Check"), &Do not show the OSD
   ShowLongMsg("Hide OSD = " NeverDisplayOSD)
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
        INIaction(1, "GUIposition", "OSDprefs")
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
    INIaction(1, "SilentMode", "Sounds")
    Sleep, 50
    SoundsThread.ahkassign("SilentMode", SilentMode)
    SoundsThread.ahkPostFunction["CheckInit", ""]
    Menu, PrefsMenu, % (SilentMode=0 ? "Uncheck" : "Check"), S&ilent mode
    ShowLongMsg("Silent mode = " SilentMode)
    SetTimer, HideGUI, % -DisplayTime
}

AccCaptureTextNow() {
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
       Global DoNotRepeatTimer := A_TickCount
       %gay%(1)
    } Else SoundBeep, 300, 900
}

DetectLangNow() {
    CreateOSDGUI()
    AutoDetectKBD := 1
    INIaction(1, "AutoDetectKBD", "SavedSettings")
    ShowLongMsg("Detecting keyboard layout...")
    Sleep, 1100
    ReloadScript()
}

ReloadScriptNow() {
    ReloadScript(0)
}

InvokeClippyMenu() {
  If (PrefOpen=0)
  {
     ShowLongMsg("Clipboard history menu...")
     SetTimer, HideGUI, % -DisplayTime
  }
  Global DoNotRepeatTimer := A_TickCount
  GenerateClippyMenu()
  Menu, ClippyMenu, Show
}

;================================================================
; Section 6. Tray menu and related functions.
;================================================================

QuickSettingsMenu() {
    Menu, QuickMenu, Add, &KeyPress activated, SuspendScriptNow
    Menu, QuickMenu, Add, &Restart, ReloadScriptNow
    Menu, QuickMenu, Add
    Menu, QuickMenu, Add, &Monitor keyboard layout, ToggleConstantDetection
    Menu, QuickMenu, Add, &Allow OSD drag, ToggleOSDdragMode
    Menu, QuickMenu, Add, &Private mode, ToggleNeverDisplay
    Menu, QuickMenu, Add, L&arge UI fonts, QuickToggleLargeFonts
    Menu, QuickMenu, Add, S&ilent mode, ToggleSilence
    Menu, QuickMenu, Add, Sta&rt at boot, SetStartUp
    If !A_IsAdmin
       Menu, QuickMenu, Add, R&un in Admin Mode, RunAdminMode
    If (SafeModeExec=1)
    {
       Menu, QuickMenu, Add, Ru&n in Safe Mode, ToggleRunSafeMode
       Menu, QuickMenu, Check, Ru&n in Safe Mode
    }
    Menu, QuickMenu, Add
    UpdateInfo := checkUpdateExistsAbout()
    If UpdateInfo
       Menu, QuickMenu, Add, &Check for updates, updateNow
    Menu, QuickMenu, Add, &Help, HelpFAQstarter
    Menu, QuickMenu, Add, &About, AboutWindow
    Menu, QuickMenu, Add, &Quick start presets, PresetsWindow
;    Menu, QuickMenu, Add, Prefere&nces, OpenLastWindow

    If (MouseOSDbehavior=3)
       Menu, QuickMenu, Check, &Allow OSD drag

    If !A_IsSuspended
       Menu, QuickMenu, Check, &KeyPress activated

    RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
    If StrLen(currentReg)>5
       Menu, QuickMenu, Check, Sta&rt at boot

    If (SilentMode=1)
       Menu, QuickMenu, Check, S&ilent mode

    If (NeverDisplayOSD=1)
    {
       Menu, QuickMenu, Check, &Private mode
       Menu, QuickMenu, Delete, &Allow OSD drag
    }

    If (ConstantAutoDetect=1)
       Menu, QuickMenu, Check, &Monitor keyboard layout

    If (PrefsLargeFonts=1)
       Menu, QuickMenu, Check, L&arge UI fonts

    If (!IsSoundsFile || MissingAudios=1 || SafeModeExec=1)     ; keypress-beeperz-functions.ahk
       Menu, QuickMenu, Delete, S&ilent mode

    faqHtml := "Lib\help\presentation.html"
    If !FileExist(faqHtml)
       If A_IsCompiled
         FileInstall, Lib\help\presentation.html, Lib\help\presentation.html
       Else Menu, QuickMenu, Delete, &Help / Troubleshoot
}

QuickMenuPrefPanels() {
    Menu, QuickPrefsMenu, Add, &Keyboard, ShowKBDsettings
    Menu, QuickPrefsMenu, Add, &Typing mode, ShowTypeSettings
    Menu, QuickPrefsMenu, Add, &Sounds, ShowSoundsSettings
    Menu, QuickPrefsMenu, Add, &Mouse, ShowMouseSettings
    Menu, QuickPrefsMenu, Add, &OSD appearance, ShowOSDsettings
    Menu, QuickPrefsMenu, Add, &Global shortcuts, ShowShortCutsSettings

    If (!IsSoundsFile || MissingAudios=1 || SafeModeExec=1)     ; keypress-beeperz-functions.ahk
       Menu, QuickPrefsMenu, Delete, &Sounds

    If (!IsMouseFile || SafeModeExec=1) ; keypress-mouse-functions.ahk
       Menu, QuickPrefsMenu, Delete, &Mouse
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
    Menu, PrefsMenu, Add, R&un in Admin Mode, RunAdminMode
    Menu, PrefsMenu, Add, Ru&n in Safe Mode, ToggleRunSafeMode
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, R&estore defaults, DeleteSettings
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, Key &history, KeyHistoryWindow
    Menu, PrefsMenu, Add
    Menu, PrefsMenu, Add, &Check for updates, updateNow

    If A_IsAdmin
    {
       Menu, PrefsMenu, Check, R&un in Admin Mode
       Menu, PrefsMenu, Disable, R&un in Admin Mode
    }

    RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
    If StrLen(currentReg)>5
       Menu, PrefsMenu, Check, Sta&rt at boot

    If (SilentMode=1)
       Menu, PrefsMenu, Check, S&ilent mode

    If (PrefsLargeFonts=1)
       Menu, PrefsMenu, Check, L&arge UI fonts

    If (!IsSoundsFile || MissingAudios=1 || SafeModeExec=1)     ; keypress-beeperz-functions.ahk
    {
       Menu, PrefsMenu, Disable, S&ilent mode
       Menu, PrefsMenu, Disable, &Sounds
    }
    If (!IsMouseFile || SafeModeExec=1) ; keypress-mouse-functions.ahk
       Menu, PrefsMenu, Disable, &Mouse

    RunType := A_IsCompiled ? "" : " [script]"
    Menu, Tray, NoStandard
    Menu, Tray, Add, &Monitor keyboard layout, ToggleConstantDetection
    If (ConstantAutoDetect=1)
       Menu, Tray, Check, &Monitor keyboard layout

    Menu, Tray, Add, &Installed keyboard layouts, InstalledKBDsWindow
    If (ConstantAutoDetect=0 && LoadedLangz=1)
       Menu, Tray, Add, &Detect keyboard layout now, DetectLangNow

    Menu, Tray, Add
    Menu, Tray, Add, &Quick start presets, PresetsWindow
    Menu, Tray, Add, &Preferences, :PrefsMenu
    Menu, Tray, Add
    Menu, Tray, Add, &Toggle OSD positions, TogglePosition
    Menu, Tray, Add, &Do not show the OSD, ToggleNeverDisplay
    Menu, Tray, Add
    Menu, Tray, Add, &Capture2Text mode (OCR), ToggleCapture2Text
    Menu, Tray, Add, Mouse text collector, ToggleAccCaptureText
    Menu, Tray, Add
    Menu, Tray, Add, &KeyPress activated, SuspendScriptNow
    Menu, Tray, Check, &KeyPress activated
    Menu, Tray, Add, &Restart, ReloadScriptNow, P50
    Menu, Tray, Add
    Menu, Tray, Add, &Help / Troubleshoot, HelpFAQstarter
    Menu, Tray, Add, &About, AboutWindow
    Menu, Tray, Add
    Menu, Tray, Delete, E&xit
    Menu, Tray, Delete, Initializing...
    Menu, Tray, Add, E&xit, KillScript, P50
    Menu, Tray, Default, &Installed keyboard layouts
    Menu, Tray, Tip, KeyPress OSD v%Version%%RunType%

    If (NeverDisplayOSD=1)
       Menu, Tray, Check, &Do not show the OSD

    If (IsAcc1File!=1 || IsAcc2File!=1 || A_OSVersion="WIN_XP") ; keypress-acc-viewer-functions.ahk
       Menu, Tray, Disable, Mouse text collector

    If (SafeModeExec=1)
    {
       Menu, PrefsMenu, Check, Ru&n in Safe Mode
       Menu, Tray, Disable, &Capture2Text mode (OCR)
    }

    faqHtml := "Lib\help\presentation.html"
    If !FileExist(faqHtml)
       If A_IsCompiled
         FileInstall, Lib\help\presentation.html, Lib\help\presentation.html
       Else Menu, Tray, Disable, &Help / Troubleshoot
}

ToggleConstantDetection() {
   If (PrefOpen=1 && A_IsSuspended=1)
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   AutoDetectKBD := 1
   ConstantAutoDetect := !ConstantAutoDetect
   INIaction(1, "ConstantAutoDetect", "SavedSettings")
   INIaction(1, "AutoDetectKBD", "SavedSettings")
   Menu, Tray, % (ConstantAutoDetect=0 ? "Uncheck" : "Check"), &Monitor keyboard layout
   If (ConstantAutoDetect=1)
      SetTimer, ConstantKBDtimer, 950, -25
   Else
      SetTimer, ConstantKBDtimer, off
   Sleep, 500
}

ToggleRunSafeMode(quickMode:=0) {
    SafeModeExec := !SafeModeExec
    AutoDetectKBD := 0
    ConstantAutoDetect := 0
    ClipMonitor := 0
    EnableClipManager := 0
    INIaction(1, "SafeModeExec", "SavedSettings")
    INIaction(1, "AutoDetectKBD", "SavedSettings")
    INIaction(1, "ConstantAutoDetect", "SavedSettings")
    INIaction(1, "ClipMonitor", "ClipboardManager")
    INIaction(1, "EnableClipManager", "ClipboardManager")
    Sleep, 50
    If (quickMode=1)
    {
       Cleanup()
       Sleep, 50
       Reload
       Sleep, 50
       ExitApp
    }
    Sleep, 25
    ReloadScriptNow()
}

SetStartUp() {
  regEntry := """" A_ScriptFullPath """"
  StringReplace, regEntry, regEntry, .ahk", .exe"
  RegRead, currentReg, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, KeyPressOSD
  If (ErrorLevel=1 || currentReg!=regEntry)
  {
     StringReplace, TestThisFile, ThisFile, .ahk, .exe
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

ToggleAccCaptureText() {
    If (!IsFunc("Acc_Init") OR !IsFunc("UIA_Interface")) ; keypress-acc-viewer-functions.ahk / UIA_Interface.ahk
    {
      ShowLongMsg("ERROR: Missing files...")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    AccTextCaptureActive := !AccTextCaptureActive
    Menu, Tray, % (AccTextCaptureActive=0 ? "Uncheck" : "Check"), Mouse text collector
    gay := "GetAccInfo"
    If IsFunc(gay)
    {
        If (AccTextCaptureActive=1)
          SetTimer, %gay%, 120, 50
        Else
          SetTimer, %gay%, off
    }
    Sleep, 400
}

ToggleLargeFonts() {
    PrefsLargeFonts := !PrefsLargeFonts
    INIaction(1, "PrefsLargeFonts", "SavedSettings")
    Menu, PrefsMenu, % (PrefsLargeFonts=0 ? "Uncheck" : "Check"), L&arge UI fonts
    Sleep, 200
}

OSDbehaviorConditions() {
    If (MouseOSDbehavior=1)
    {
        DragOSDmode := 0
        JumpHover := 0
    } Else If (MouseOSDbehavior=2)
    {
        DragOSDmode := 0
        JumpHover := 1
    } Else If (MouseOSDbehavior=3)
    {
        DragOSDmode := 1
        JumpHover := 0
    }
}

ToggleOSDdragMode() {
    MouseOSDbehavior := MouseOSDbehavior=1 ? 3 : 1
    OSDbehaviorConditions()
    Sleep, 10
    CreateOSDGUI()
    INIaction(1, "MouseOSDbehavior", "OSDprefs")
}

QuickToggleLargeFonts() {
    ToggleLargeFonts()
    InstalledKBDsWindow()
}

ReloadScript(silent:=1) {
    Thread, Priority, 50
    Critical, On
    If (ScriptInitialized!=1)
    {
       Cleanup()
       Sleep, 25
       Reload
       Sleep, 50
       ExitApp
    }
    If (PrefOpen=1)
    {
       CloseSettings()
       Return
    }

    CreateOSDGUI()
    If FileExist(ThisFile)
    {
        If (silent!=1)
           ShowLongMsg("Restarting...")
        Cleanup()
        Reload
        Sleep, 50
        ExitApp
    } Else
    {
        ShowLongMsg("FATAL ERROR: Main file missing. Execution terminated.")
        SoundBeep
        Sleep, 2000
        Cleanup() ; if you don't do it HERE you're not doing it right, Run %i% will force the script to close before cleanup
        MsgBox, 4,, Do you want to choose another file to execute?
        IfMsgBox, Yes
        {
            FileSelectFile, i, 2, %A_ScriptDir%\%A_ScriptName%, Select a different script to load, AutoHotkey script (*.ahk; *.ah1u)
            If !InStr(FileExist(i), "D")  ; we can't run a folder, we need to run a script
               Run, %i%
        } Else (Sleep, 500)
        ExitApp
    }
}

capture2textTimer() {
    Critical, off
    Thread, Priority, -50
    If (A_TimeIdlePhysical<3000 && !A_IsSuspended && (A_TickCount-LastTypedSince > 1500))
       SendInput, {Pause}             ; set here the keyboard shortcut configured in Capture2Text
    Sleep, 1
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
    IfWinNotExist, Capture2Text
    {
        If (Capture2Text!=1)
        {
            SoundBeep, 300, 900
            MsgBox, 4,, Capture2Text was not detected. Do you want to continue? `nThis is an external application. `nPlease see Help for more details.
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
        EnableClipManager := 0
        DragOSDmode := 0
        SetTimer, capture2textTimer, 1500, -20
        ToggleMouseThings(0)
        ShowLongMsg("Enabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
    } Else If (featureValidated=1)
    {
        Capture2Text := !Capture2Text
        INIaction(0, "GUIposition", "OSDprefs")
        INIaction(0, "JumpHover", "OSDprefs")
        INIaction(0, "DragOSDmode", "OSDprefs")
        INIaction(0, "EnableClipManager", "ClipboardManager")
        INIaction(0, "ClipMonitor", "ClipboardManager")
        GuiX := (GUIposition=1) ? GuiXa : GuiXb
        GuiY := (GUIposition=1) ? GuiYa : GuiYb
        Gui, OSD: Destroy
        Sleep, 50
        CreateOSDGUI()
        Sleep, 50
        Menu, Tray, Uncheck, &Capture2Text mode (OCR)
        ToggleMouseThings()
        SetTimer, capture2textTimer, off
        Capture2Text := !Capture2Text
        ShowLongMsg("Disabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
    }
    Sleep, 15
    Pause, off
}

ToggleMouseThings(on:=1) {
; timers on/off, hotkeys on/off
    If !on
    {
       MouseFuncThread.ahkassign("ScriptelSuspendel", "Y")
       MouseFuncThread.ahkPostFunction["ToggleMouseTimerz", "Y"]
       MouseRipplesThread.ahkassign("ScriptelSuspendel", "Y")
       MouseRipplesThread.ahkPostFunction["ToggleMouseRipples", "Y"]
    } Else
    {
       MouseFuncThread.ahkassign("ScriptelSuspendel", 0)
       MouseFuncThread.ahkPostFunction["ToggleMouseTimerz", ""]
       MouseRipplesThread.ahkassign("ScriptelSuspendel", 0)
       MouseRipplesThread.ahkPostFunction["ToggleMouseRipples", ""]
    }
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
      Try {
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
       FileSetAttrib, -R, %LangFile%
       FileDelete, %IniFile%
       FileDelete, %LangFile%
       checkFilesRan := 2
       IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
       ReloadScriptNow()
    }
}

KillScript(showMSG:=1) {
   Thread, Priority, 50
   Critical, On
   If (ScriptInitialized!=1)
      ExitApp

   PrefOpen := 0
   RegWrite, REG_SZ, %KPregEntry%, PrefOpen, %PrefOpen%
   If (FileExist(ThisFile) && showMSG)
   {
      INIsettings(1)
      ShowLongMsg("Bye byeee :-)")
      Sleep, 350
   } Else If showMSG
   {
      ShowLongMsg("Adiiooosss :-(((")
      Sleep, 950
   }
   Cleanup()
   ExitApp
}

;================================================================
; Section 7. Settings window.
; - In this section you can find each preferences window
;   or any other window based on SettingsGUI() and 
;   various functions used in the UI.
;================================================================

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
    If (PrefOpen=1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        doNotOpen := 1
        Return doNotOpen
    }

    If (A_IsSuspended!=1)
       SuspendScript(1)

    PrefOpen := 1
    RegWrite, REG_SZ, %KPregEntry%, PrefOpen, %PrefOpen%
    SettingsGUI()
}

verifySettingsWindowSize() {
    If (PrefsLargeFonts=0) || (A_TickCount-DoNotRepeatTimer<40000)
       Return
    GuiGetSize(Wid, Heig, 5)
    SysGet, SM_CXMAXIMIZED, 61
    SysGet, SM_CYMAXIMIZED, 62
    If (Heig>SM_CYMAXIMIZED-75) || (Wid>SM_CXMAXIMIZED-50)
    {
       Global DoNotRepeatTimer := A_TickCount
       SoundBeep, 300, 900
       MsgBox, 4,, The option "Large UI fonts" is enabled. The window seems to exceed your screen resolution. `nDo you want to disable Large UI fonts?
       IfMsgBox, Yes
       {
           ToggleLargeFonts()
           If (PrefOpen=1)
              SwitchPreferences(1)
           Else If (AnyWindowOpen=1)
              AboutWindow()
           Else If (AnyWindowOpen=2)
              InstalledKBDsWindow()
       }
    }
}

SwitchPreferences(forceReopenSame:=0) {
    testPrefWind := (forceReopenSame=1) ? "lol" : CurrentPrefWindow
    GuiControlGet, CurrentPrefWindow
    If (testPrefWind=CurrentPrefWindow)
       Return

    If (NoAhkH=1 && (CurrentPrefWindow=4 || CurrentPrefWindow=3))
    {
      ShowLongMsg("ERROR: AHK_L detected. Features unavailable.")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    If ((!IsSoundsFile || MissingAudios=1 || NoAhkH=1) && CurrentPrefWindow=3) || ((!IsMouseFile || NoAhkH=1) && CurrentPrefWindow=4) ; keypress-beeperz-functions.ahk / keypress-mouse-functions.ahk
    {
      If (SafeModeExec!=1)
         ShowLongMsg("ERROR: Missing files...")
      Else
         ShowLongMsg("Safe mode is activated. Features are disabled.")
      SoundBeep, 300, 900
      SetTimer, HideGUI, % -DisplayTime
      Return
    }
    PrefOpen := 0
    GuiControlGet, ApplySettingsBTN, Enabled
    Gui, Submit
    Gui, SettingsGUIA: Destroy
    Sleep, 25
    SettingsGUI()
    CheckSettings()
    If (CurrentPrefWindow!=5)
       HideGUI()
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
}

OpenLastWindow() {
    InstKBDsWinOpen := 1
    RegRead, win2open, %KPregEntry%, LastOpen
    If (win2open=1)
       ShowKBDsettings()
    Else If (win2open=2)
       ShowTypeSettings()
    Else If (win2open=3)
       ShowSoundsSettings()
    Else If (win2open=4)
       ShowMouseSettings()
    Else If (win2open=5)
       ShowOSDsettings()
    Else If (win2open=6)
       ShowShortCutsSettings()
    Else
    {
      InstKBDsWinOpen := 0
      Menu, QuickPrefsMenu, Delete
      QuickMenuPrefPanels()
      Menu, QuickPrefsMenu, Show
    }
}

ApplySettings() {
    Gui, SettingsGUIA: Submit, NoHide
    CheckSettings()
    PrefOpen := 0
    RegWrite, REG_SZ, %KPregEntry%, PrefOpen, %PrefOpen%
    RegWrite, REG_SZ, %KPregEntry%, LastOpen, %CurrentPrefWindow%
    If CurrentTab
       RegWrite, REG_SZ, %KPregEntry%, Window%CurrentPrefWindow%, %CurrentTab%
    INIsettings(1)
    Sleep, 100
    ReloadScript()
}

CloseWindow() {
    If hPaypalImg
       DllCall("gdi32\DeleteObject", "Ptr", hPaypalImg)
    If hIconImg
       DllCall("gdi32\DestroyIcon", "Ptr", hIconImg)
    AnyWindowOpen := 0
    Gui, SettingsGUIA: Destroy
}

CloseSettings() {
   If (CurrentPrefWindow="2b")
   {
      CloseTypeSetHelp()
      Return
   }

   GuiControlGet, ApplySettingsBTN, Enabled
   GuiControlGet, CurrentTab
   PrefOpen := 0
   RegWrite, REG_SZ, %KPregEntry%, PrefOpen, %PrefOpen%
   RegWrite, REG_SZ, %KPregEntry%, LastOpen, %CurrentPrefWindow%
   If CurrentTab
      RegWrite, REG_SZ, %KPregEntry%, Window%CurrentPrefWindow%, %CurrentTab%
   CloseWindow()
   If (ApplySettingsBTN=0)
   {
      Sleep, 25
      SuspendScript()
      If (InstKBDsWinOpen=1)
        InstalledKBDsWindow()
      InstKBDsWinOpen := 0
      Return
   }
   Sleep, 100
   ReloadScript()
}

SettingsGUIAGuiEscape:
   If (A_TickCount-Tickcount_start < 1000)
      Return
   If (PrefOpen=1)
      CloseSettings()
   Else
      CloseWindow()
Return

SettingsGUIAGuiClose:
   If (PrefOpen=1)
      CloseSettings()
   Else
      CloseWindow()
Return

OpenExpandableWordsFile() {
  Run, %WordPairsFile%
}

RestoreExpandableWordsFile() {
  FileDelete, %WordPairsFile%
  Sleep, 25
  ExpandPairs := CreateWordPairsFile(WordPairsFile)
  GuiControl, Disable, SaveWordPairsBTN
  GuiControl, Disable, DefaultWordPairsBTN
  GuiControl, , ExpandWordsListEdit, %ExpandPairs%
  VerifyTypeOptions()
}

SaveWordPairsNow() {
  FileDelete, %WordPairsFile%
  Sleep, 25
  ExpandWordsListEdit := ""
  GuiControlGet, ExpandWordsListEdit
  FileAppend, %ExpandWordsListEdit%, %WordPairsFile%, UTF-16
  ExpandWordsListEdit := ""
  InitExpandableWords(1)
  GuiControl, Disable, SaveWordPairsBTN
  GuiControl, , ExpandWordsListEdit, %ExpandWordsListEdit%
  VerifyTypeOptions()
}

wordPairsEditing() {
    GuiControl, Enable, SaveWordPairsBTN
    GuiControl, Enable, DefaultWordPairsBTN
}

editsTypeWin() {
  If (A_TickCount-DoNotRepeatTimer<1000)
     Return
  VerifyTypeOptions()
}

ShowTypeSettings() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    deadKstatus := (DeadKeys=1 && AutoDetectKBD=1) ? "Dead keys present." : "No dead keys detected."
    deadKstatus := (AutoDetectKBD=1) ? deadKstatus : ""
    Global CurrentPrefWindow := 2
    Global DoNotRepeatTimer := A_TickCount
    Global txt1, txt2, txt3, txt4, txt5, txt6, editF1, editF2, editF3, editF4, SaveWordPairsBTN, DefaultWordPairsBTN, OpenWordPairsBTN
    txtWid := 350
    If (PrefsLargeFonts=1)
    {
       txtWid := txtWid + 220
       Gui, Font, s%LargeUIfontValue%
    }
    editWid := txtWid - 50
    If StrLen(ExpandWordsListEdit)<2
       InitExpandableWords()

    RegRead, LastTab, %KPregEntry%, Window%CurrentPrefWindow%
    Gui, Add, Tab3, AltSubmit Choose%LastTab% vCurrentTab, General|Dead keys|Behavior|Auto-replace

    Gui, Tab, 1 ; general
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys in the OSD (mandatory for the main typing mode)
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%EnableAltGr% vEnableAltGr, Enable {Ctrl + Alt} / {AltGr} support
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%DisableTypingMode% vDisableTypingMode, Disable main typing mode
    Gui, Add, Checkbox, y+7 Section gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only
    Gui, Add, Checkbox, y+12 gVerifyTypeOptions Checked%AlternateTypingMode% vAlternateTypingMode, Enable global keyboard shortcut to enter in alternate typing mode
    Gui, Add, Text, xp+15 y+5 w%txtWid% vtxt3, Type through KeyPress OSD and send text on {Enter}. Full support for dead keys and predictable results.
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%PasteOnClick% vPasteOnClick, Paste on click what you typed
    Gui, Add, Text, xs+0 y+15 vtxt1, OSD display time when typing (in seconds)
    Gui, Add, Edit, x+15 w60 geditsTypeWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyTypeOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Text, xs+0 y+7 vtxt2, Time to resume typing with text related keys (in sec.)
    Gui, Add, Edit, x+15 w60 geditsTypeWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %ReturnToTypingUser%
    Gui, Add, UpDown, vReturnToTypingUser gVerifyTypeOptions Range2-99, %ReturnToTypingUser%

    Gui, Tab, 2 ; dead keys
    Gui, Add, Checkbox, x+15 y+15 section gVerifyTypeOptions Checked%ShowDeadKeys% vShowDeadKeys, Insert generic dead key symbol when using such a key and typing
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%AltHook2keysUser% vAltHook2keysUser, Alternative hook to keys (applies to the main typing mode)
    Gui, Font, Bold
    Gui, Add, Text, y+10 w%txtWid%, If dead keys do not work, change the following options:
    Gui, Font, Normal
    Gui, Add, Text, y+10, Typing delays scale (1 = no delays)
    Gui, Add, Edit, x+15 w60 geditsTypeWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %TypingDelaysScaleUser%
    Gui, Add, UpDown, vTypingDelaysScaleUser gVerifyTypeOptions Range1-40, %TypingDelaysScaleUser%
    Gui, Add, Checkbox, xs+0 y+12 gVerifyTypeOptions Checked%DoNotBindDeadKeys% vDoNotBindDeadKeys, Do not bind (ignore) known dead keys
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%DoNotBindAltGrDeadKeys% vDoNotBindAltGrDeadKeys, Ignore dead keys associated with AltGr as well

    Gui, Font, Bold
    Gui, Add, Text, xp-15 y+15, Keyboard layout status: %deadKstatus%
    Gui, Add, Text, y+8 w%txtWid%, %CurrentKBD%.
    If (LoadedLangz!=1 && AutoDetectKBD=1)
       Gui, Add, Text, y+9 w%txtWid%, WARNING: Language definitions file is missing. Support for dead keys is limited.
    If (!IsKeystrokesFile)     ; keypress-keystrokes-helper.ahk
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Some option(s) are disabled because files are missing.
    If (SafeModeExec=1)
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Some features are disabled because the application is running in Safe Mode.
    If (AutoDetectKBD=0)
    {
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Automatic keyboard layout detection is deactivated. For dead keys support, please enable it.
       Gui, Add, Checkbox, xp+15 y+8 Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    }
    Gui, Font, Normal

    Gui, Tab, 3  ; behavior
    Gui, Add, Checkbox, x+15 y+15 gVerifyTypeOptions Checked%EnableTypingHistory% vEnableTypingHistory, Typed text history with {Page Up} / {Page Down}
    Gui, Add, Checkbox, y+7 gVerifyTypeOptions Checked%PgUDasHE% vPgUDasHE, {Page Up} / {Page Down} should behave as {Home} / {End}
    Gui, Add, Checkbox, y+7 Section gVerifyTypeOptions Checked%UpDownAsHE% vUpDownAsHE, {Up} / {Down} arrow keys should behave as {Home} / {End}
    Gui, Add, Checkbox, xp+15 y+7 gVerifyTypeOptions Checked%UpDownAsLR% vUpDownAsLR, ... or as the {Left} / {Right} keys
    Gui, Add, Checkbox, xp-15 y+12 gVerifyTypeOptions Checked%PasteOSDcontent% vPasteOSDcontent, Enable global shortcuts to paste the OSD content into the active text area
    Gui, Add, Checkbox, xs+0 y+10 gVerifyTypeOptions Checked%EnterErasesLine% vEnterErasesLine, In "only typing" mode, {Enter} and {Escape} erase text from KeyPress
    Gui, Add, Checkbox, y+10 gVerifyTypeOptions Checked%EraseTextWinChange% vEraseTextWinChange, Erase text from KeyPress OSD when active window changes
    Gui, Add, Checkbox, y+10 Section gVerifyTypeOptions Checked%AlternativeJumps% vAlternativeJumps, Alternative rules to jump between words with {Ctrl + Bksp / Del / Left / Right}
    Gui, Add, Checkbox, xp+15 y+7 w350 gVerifyTypeOptions Checked%SendJumpKeys% vSendJumpKeys, Mediate the key strokes for caret jumps
    Gui, Add, Checkbox, xs+0 y+7 gVerifyTypeOptions Checked%MediateNavKeys% vMediateNavKeys, Mediate {Home} / {End} keys presses
    Gui, Add, Checkbox, y+7 Section gVerifyTypeOptions Checked%EnforceSluggishSynch% vEnforceSluggishSynch, Attempt to synchronize with sluggish host apps (for slow PCs only)

    Gui, Tab, 4 ; text expand
    Gui, Add, Checkbox, x+15 y+15 Section gVerifyTypeOptions Checked%ExpandWords% vExpandWords, Automatically replace words or abbreviations
    Gui, Add, Text, y+10 vtxt4, Do not replace words after (in seconds)
    Gui, Add, Edit, x+15 w60 geditsTypeWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %NoExpandAfterTuser%
    Gui, Add, UpDown, vNoExpandAfterTuser gVerifyTypeOptions Range1-30, %NoExpandAfterTuser%
    Gui, Add, Text, xs+0 y+10 vtxt5, When {Space} is pressed... string* to match // string* to replace with
    Gui, Add, Edit, y+10 r7 w%editWid% gwordPairsEditing vExpandWordsListEdit, %ExpandWordsListEdit%
    If (PrefsLargeFonts=1)
    {
       Gui, Add, Button, xp+0 y+15 w90 h30 gSaveWordPairsNow vSaveWordPairsBTN, Save li&st
       Gui, Add, Button, x+10 yp+0 w110 hp gOpenExpandableWordsFile vOpenWordPairsBTN, Open &file
       Gui, Add, Button, x+10 yp+0 w150 hp gRestoreExpandableWordsFile vDefaultWordPairsBTN, Restore d&efaults
    } Else
    {
       Gui, Add, Button, xp+0 y+15 w70 h30 gSaveWordPairsNow vSaveWordPairsBTN, Save li&st
       Gui, Add, Button, x+10 yp+0 w80 hp gOpenExpandableWordsFile vOpenWordPairsBTN, Open &file
       Gui, Add, Button, x+10 yp+0 w120 hp gRestoreExpandableWordsFile vDefaultWordPairsBTN, Restore d&efaults
    }
    Gui, Add, Text, xs+0 y+10 vtxt6, (*) Each string must be at least two characters long.

    Gui, Tab
    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, Button, x+8 wp hp gOpenTypeSetHelp, &Help
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Typing mode settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifyTypeOptions(0)
}

TypeOptionsShowHelp() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    deadKstatus := (DeadKeys=1) ? "Dead keys present." : "No dead keys detected."
    Global CurrentPrefWindow := "2b"
    txtWid := 350
    If (PrefsLargeFonts=1)
    {
       txtWid := txtWid + 220
       Gui, Font, s%LargeUIfontValue%
    }
    RegRead, LastTab, %KPregEntry%, Window%CurrentPrefWindow%
    Gui, Add, Tab3, AltSubmit Choose%LastTab% vCurrentTab, General|Dead keys|Behavior [1]| Behavior [2]

    Gui, Tab, 1 ; general
    Gui, Add, Text, x+15 y+15 Section, The main typing mode
    Gui, Add, Text, xp+15 y+5 w%txtWid%, The main typing mode works by attempting to shadow the host app. KeyPress will attempt to reproduce text cursor actions that mimmick common text areas/fields.
    Gui, Add, Text, xs+0 y+10, Enable global keyboard shortcut to enter in alternate typing mode
    Gui, Add, Text, xp+15 y+5 w%txtWid%, Default shortcut: {Ctrl + CapsLock}. In this typing mode, You type in KeyPress. You send the text to the previously active host app by pressing {Enter}. This ensures full support for dead keys and full predictability.
    Gui, Add, Text, y+10, Paste on click what you typed
    Gui, Add, Text, xp+15 y+5 w%txtWid%, With this option enabled, you can click where you want the text to be inserted, in any visible text field.
    Gui, Add, Text, xs+0 y+15, Time to resume typing with text related keys: %ReturnToTypingUser% seconds.
    Gui, Add, Text, xp+15 y+7 w%txtWid%, Even if the OSD hides, you can resume typing with text related keys: arrow keys, backspace, delete and home/end. By pressing letter or number keys, you always resume typing.

    Gui, Tab, 2 ; dead keys
    Gui, Add, Text, x+15 y+15 Section, Alternative hook to keys (applies to the main typing mode)
    Gui, Add, Text, xp+15 y+5 w%txtWid%, This enables full support for dead keys. However, please note that some applications can disrupt this feature.
    Gui, Font, Bold
    Gui, Add, Text, xp-15 y+10, Troubleshooting:
    Gui, Font, Normal
    Gui, Add, Text, xp+15 y+5 w%txtWid%, If you cannot use dead keys on supported layouts in host apps, Increase the "Typing delays scale" multiplier progressively until dead keys work. Apply settings and then test dead keys in the host app. If you cannot identify the right delay, activate "Do not bind known dead keys".

    Gui, Font, Bold
    Gui, Add, Text, xp-15 y+15, Keyboard layout status: %deadKstatus%
    Gui, Add, Text, y+8 w%txtWid%, %CurrentKBD%.
    If (LoadedLangz!=1 && AutoDetectKBD=1)
       Gui, Add, Text, y+9 w%txtWid%, WARNING: Language definitions file is missing. Support for dead keys is limited.
    If (AutoDetectKBD=0)
       Gui, Add, Text, y+8 w%txtWid%, WARNING: Automatic keyboard layout detection is deactivated. For dead keys support, please enable it.
    Gui, Font, Normal

    Gui, Tab, 3  ; behavior
    Gui, Add, Text, x+15 y+15 Section, Enable global shortcuts to paste the OSD content into the active text area
    Gui, Add, Text, xp+15 y+5 w%txtWid%, The default keyboard shortcut is {Ctrl + Shift + Insert}. To replace the entire text in the active text area, use {Ctrl + Alt + Insert}.
    Gui, Add, Text, xs+0 y+7, Synchronization with the host application
    Gui, Add, Text, xp+15 y+5 w%txtWid%, To capture text from the host app, {Ctrl + A}, select all, is used. The default global keyboard shortcut to synchronize / capture text from the host app is {Winkey + Insert}.`nA second mode is accessible by pressing {Winkey + Alt + Insert}. In this mode, KeyPress attempts to capture only the current line.

    Gui, Add, Text, xs+0 y+10, Alternative rules to jump between words with {Ctrl + Bksp / Del / Left / Right}
    Gui, Add, Text, xp+15 y+5, Please note, applications implement inconsistent rules for this.
    Gui, Add, Text, y+7 w%txtWid%, Mediate the key strokes for caret jumps
    Gui, Add, Text, xp+15 y+5 w%txtWid%, This option increases the likelihood of KeyPress staying synchronized with the host app. Key strokes that attempt to reproduce the actions you see in the OSD will be sent to the host app.

    Gui, Tab, 4 ; behavior 2
    Gui, Add, Text, x+15 y+15 Section, Mediate {Home} / {End} keys presses
    Gui, Add, Text, xp+15 y+5 w%txtWid%, This can ensure a stricter synchronization with the host app when typing in short multi-line text fields. Key strokes will be sent to the host app that attempt to reproduce the caret location from the OSD.
    Gui, Add, Text, xs+0 y+7, Attempt to synchronize with sluggish host apps (for slow PCs only)
    Gui, Add, Text, xp+15 y+5 w%txtWid%, This option applies only for {Left}, {Right} and {Delete} keys. If the caret position in the OSD does not stay in synch with the caret position from the host app when pressing repetitively these keys, this option can help.

    Gui, Tab
    Gui, Add, Button, xm+0 y+10 w90 h30 Default gCloseTypeSetHelp, C&lose
    Gui, Show, AutoSize, Typing mode settings [Help]: KeyPress OSD
}

OpenTypeSetHelp() {
    PrefOpen := 0
    Gui, Submit
    Gui, SettingsGUIA: Destroy
    Sleep, 25
    SettingsGUI()
    CheckSettings()
    TypeOptionsShowHelp()
}

CloseTypeSetHelp() {
    PrefOpen := 0
    Gui, SettingsGUIA: Destroy
    Sleep, 25
    SettingsGUI()
    ShowTypeSettings()
    Sleep, 25
    VerifyTypeOptions(1)
}

ToggleUITypeElements(activate) {
   action := (activate=1) ? "Enable" : "Disable"
   GuiControl, %action%, AltHook2keysUser
   GuiControl, %action%, CapslockBeeper
   GuiControl, %action%, DisplayTimeTypingUser
   GuiControl, %action%, editF1
   GuiControl, %action%, editF2
   GuiControl, %action%, EnableTypingHistory
   GuiControl, %action%, EnforceSluggishSynch
   GuiControl, %action%, EnterErasesLine
   GuiControl, %action%, EraseTextWinChange
   GuiControl, %action%, MediateNavKeys
   GuiControl, %action%, OnlyTypingMode
   GuiControl, %action%, PasteOSDcontent
   GuiControl, %action%, PgUDasHE
   GuiControl, %action%, ReturnToTypingUser
   GuiControl, %action%, SendJumpKeys
   GuiControl, %action%, ShowDeadKeys
   GuiControl, %action%, txt1
   GuiControl, %action%, txt2
   GuiControl, %action%, UpDownAsHE
   GuiControl, %action%, UpDownAsLR
}

VerifyTypeOptions(enableApply:=1) {
    GuiControlGet, DisableTypingMode
    GuiControlGet, ShowSingleKey
    GuiControlGet, EnableAltGr
    GuiControlGet, EnableTypingHistory
    GuiControlGet, ShowDeadKeys
    GuiControlGet, DisplayTimeTypingUser
    GuiControlGet, ReturnToTypingUser
    GuiControlGet, OnlyTypingMode
    GuiControlGet, EnterErasesLine
    GuiControlGet, PgUDasHE
    GuiControlGet, UpDownAsHE
    GuiControlGet, UpDownAsLR
    GuiControlGet, editF1
    GuiControlGet, editF2
    GuiControlGet, DoNotBindDeadKeys
    GuiControlGet, DoNotBindAltGrDeadKeys
    GuiControlGet, AlternateTypingMode
    GuiControlGet, AltHook2keysUser
    GuiControlGet, PasteOnClick
    GuiControlGet, SendJumpKeys
    GuiControlGet, MediateNavKeys
    GuiControlGet, ExpandWords

    GuiControl, % (enableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (ShowSingleKey=0)
    {
       GuiControl, Disable, DisableTypingMode
       ToggleUITypeElements(0)
    } Else
    {
       GuiControl, Enable, DisableTypingMode
       ToggleUITypeElements(1)
    }
  
    If (DisableTypingMode=1)
       ToggleUITypeElements(0)
    Else If (ShowSingleKey!=0)
    {
       GuiControl, Enable, AlternativeJumps
       GuiControl, Enable, ExpandWords
       ToggleUITypeElements(1)
    }

    If (OnlyTypingMode=0)
       GuiControl, Disable, EnterErasesLine
    
    If (DoNotBindDeadKeys=1)
       GuiControl, Disable, ShowDeadKeys
    Else If (DisableTypingMode=0 && ShowSingleKey!=0)
       GuiControl, Enable, ShowDeadKeys

    If (AltHook2keysUser=1)
       GuiControl, Disable, ShowDeadKeys

    GuiControl, % (DoNotBindDeadKeys=1 ? "Enable" : "Disable"), DoNotBindAltGrDeadKeys
    If (UpDownAsHE=1)
       GuiControl, , UpDownAsLR, 0

    If (UpDownAsLR=1)
       GuiControl, , UpDownAsHE, 0

    If (EnableTypingHistory=1)
       GuiControl, Disable, PgUDasHE

    GuiControl, % (AlternateTypingMode=0 ? "Disable" : "Enable"), PasteOnClick
    GuiControl, % (AlternateTypingMode=0 ? "Disable" : "Enable"), txt3
    If (AlternateTypingMode=1)
    {
      GuiControl, Enable, ExpandWords
      GuiControl, Enable, AlternativeJumps
    }

    If (EnterErasesLine=0 && OnlyTypingMode=1)
    {
       GuiControl, Disable, SendJumpKeys
       GuiControl, Disable, MediateNavKeys
       GuiControl, Disable, EnableTypingHistory
       GuiControl, Enable, PgUDasHE
    }

    If (SafeModeExec=1 || !IsKeystrokesFile || NoAhkH=1) ; keypress-keystrokes-helper.ahk
    {
       GuiControl, Disable, AltHook2keysUser
       GuiControl, , AltHook2keysUser, 0
       GuiControl, Enable, ShowDeadKeys
    }

   action1 := (ExpandWords=0) ? "Disable" : "Enable"
   If (AlternateTypingMode=0 && (DisableTypingMode=1 || ShowSingleKey=0))
   {
       GuiControl, Disable, AlternativeJumps
       GuiControl, Disable, ExpandWords
       GuiControl, Disable, SaveWordPairsBTN
       action1 := "Disable"
   }

   GuiControl, %action1%, editF4
   GuiControl, %action1%, txt4
   GuiControl, %action1%, txt5
   GuiControl, %action1%, txt6
   GuiControl, %action1%, DefaultWordPairsBTN
   GuiControl, %action1%, OpenWordPairsBTN
   GuiControl, %action1%, ExpandWordsListEdit

   If (enableApply=0)
      GuiControl, Disable, SaveWordPairsBTN
}

AddKBDmods(HotKate, HotKateRaw) {
    Global
    modBtnWidth := (PrefsLargeFonts=1) ? 45 : 32
    reused := "x+0 +0x1000 w" modBtnWidth " hp gGenerateHotkeyStrS "
    C%HotKate% := InStr(HotKateRaw, "^")
    S%HotKate% := InStr(HotKateRaw, "+")
    A%HotKate% := InStr(HotKateRaw, "!")
    W%HotKate% := InStr(HotKateRaw, "#")

    Gui, Add, Checkbox, % reused " Checked" C%HotKate% " vCtrl" HotKate, Ctrl
    Gui, Add, Checkbox, % reused " Checked" A%HotKate% " vAlt" HotKate, Alt
    Gui, Add, Checkbox, % reused " Checked" S%HotKate% " vShift" HotKate, Shift
    Gui, Add, Checkbox, % reused " Checked" W%HotKate% " vWin" HotKate, Win
}

AddKBDcombo(HotKate, HotKateRaw) {
    Global
    col2width := (PrefsLargeFonts=1) ? 140 : 90
    ComboChoice := ProcessChoiceKBD(HotKateRaw)
    Gui, Add, ComboBox, % "x+0 w"col2width " gProcessComboKBD vCombo" HotKate, %KeysComboList%|%ComboChoice%||
}

ShowShortCutsSettings() {
    Global
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    CurrentPrefWindow := 6
    col1width := 290
    If (PrefsLargeFonts=1)
    {
       col1width := 430
       Gui, Font, s%LargeUIfontValue%
    }

    Gui, Add, Text, x15 y15 Section, All the shortcuts listed in this panel are available globally, in any application.
    Gui, Add, Checkbox, xs+0 y+10 w%col1width% gVerifyShortcutOptions Checked%AlternateTypingMode% vAlternateTypingMode, Enter alternate typing mode
    AddKBDcombo("KBDaltTypeMode", KBDaltTypeMode)
    AddKBDmods("KBDaltTypeMode", KBDaltTypeMode)

    Gui, Add, Checkbox, xs+0 y+1 w%col1width% gVerifyShortcutOptions Checked%EnableClipManager% vEnableClipManager, Invoke the Clipboard History menu
    AddKBDcombo("KBDclippyMenu", KBDclippyMenu)
    AddKBDmods("KBDclippyMenu", KBDclippyMenu)

    Gui, Add, Checkbox, xs+0 y+1 w%col1width% gVerifyShortcutOptions Checked%PasteOSDcontent% vPasteOSDcontent, Paste the OSD content in the active text area
    AddKBDcombo("KBDpasteOSDcnt1", KBDpasteOSDcnt1)
    AddKBDmods("KBDpasteOSDcnt1", KBDpasteOSDcnt1)

    Gui, Add, Text, xs+0 y+1 w%col1width%, %A_Space%Replace entire text from the active text area with the OSD content
    AddKBDcombo("KBDpasteOSDcnt2", KBDpasteOSDcnt2)
    AddKBDmods("KBDpasteOSDcnt2", KBDpasteOSDcnt2)

    Gui, Add, Checkbox, xs+0 y+25 w%col1width% gVerifyShortcutOptions Checked%GlobalKBDhotkeys% vGlobalKBDhotkeys, Other global keyboard shortcuts
    Gui, Add, Text, xs+0 y+10 w%col1width%, Capture all the text from the active text area
    AddKBDcombo("KBDsynchApp1", KBDsynchApp1)
    AddKBDmods("KBDsynchApp1", KBDsynchApp1)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Capture only the current line from the active text area
    AddKBDcombo("KBDsynchApp2", KBDsynchApp2)
    AddKBDmods("KBDsynchApp2", KBDsynchApp2)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle Private mode / Do not display the OSD
    AddKBDcombo("KBDTglNeverOSD", KBDTglNeverOSD)
    AddKBDmods("KBDTglNeverOSD", KBDTglNeverOSD)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle OSD positions (A / B)
    AddKBDcombo("KBDTglPosition", KBDTglPosition)
    AddKBDmods("KBDTglPosition", KBDTglPosition)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Toggle Silent mode
    AddKBDcombo("KBDTglSilence", KBDTglSilence)
    AddKBDmods("KBDTglSilence", KBDTglSilence)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Detect keyboard layout
    AddKBDcombo("KBDidLangNow", KBDidLangNow)
    AddKBDmods("KBDidLangNow", KBDidLangNow)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Capture text underneath the mouse
    AddKBDcombo("KBDCapText", KBDCapText)
    AddKBDmods("KBDCapText", KBDCapText)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Restart / reload KeyPress OSD
    AddKBDcombo("KBDReload", KBDReload)
    AddKBDmods("KBDReload", KBDReload)

    Gui, Add, Text, xs+0 y+1 w%col1width%, Suspend / deactivate KeyPress OSD
    AddKBDcombo("KBDsuspend", KBDsuspend)
    AddKBDmods("KBDsuspend", KBDsuspend)

    Gui, Add, Button, xs+0 y+15 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings vCancelBTN, C&ancel
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Global shortcuts: KeyPress OSD
    verifySettingsWindowSize()
    VerifyShortcutOptions(0)
    ProcessComboKBD(0)
}

GenerateHotkeyStrS(enableApply:=1) {
  GuiControlGet, ApplySettingsBTN

  kW1 := "disa"
  kW2 := "resto"
  kWa := "(Disabled)"
  kWb := "(Restore Default)"

  Loop, Parse, GlobalKBDsList, CSV
  {
     GuiControlGet, Combo%A_LoopField%
     GuiControlGet, Ctrl%A_LoopField%
     GuiControlGet, Shift%A_LoopField%
     GuiControlGet, Alt%A_LoopField%
     GuiControlGet, Win%A_LoopField%
     %A_LoopField% := ""
     %A_LoopField% .= Ctrl%A_LoopField%=1 ? "^" : ""
     %A_LoopField% .= Shift%A_LoopField%=1 ? "+" : ""
     %A_LoopField% .= Alt%A_LoopField%=1 ? "!" : ""
     %A_LoopField% .= Win%A_LoopField%=1 ? "#" : ""
     %A_LoopField% .= ProcessChoiceKBD2(Combo%A_LoopField%)
     If InStr(Combo%A_LoopField%, kW1)
        %A_LoopField% := kWa

     If InStr(Combo%A_LoopField%, kW2)
        %A_LoopField% := kWb
  }

  keywords := "i)(disa|resto)"
  KBDsTestDuplicate := KBDaltTypeMode "&" KBDpasteOSDcnt1 "&" KBDpasteOSDcnt2 "&" KBDsynchApp1 "&" KBDsynchApp2 "&" KBDTglNeverOSD "&" KBDTglPosition "&" KBDTglSilence "&" KBDidLangNow "&" KBDCapText "&" KBDReload "&" KBDsuspend "&" KBDclippyMenu
  For each, kbd2test in StrSplit(KBDsTestDuplicate, "&")
  {
      countDuplicate := 0
      Loop, Parse, KBDsTestDuplicate, &
      {
          If RegExMatch(A_LoopField, keywords)
             Continue
          If (kbd2test=A_LoopField)
             countDuplicate++
      }
      If countDuplicate>1
         disableButtons := 1
  }

  If (disableButtons=1)
  {
     ToolTip, Duplicate keyboard shorcuts...
     SoundBeep, 300, 900
     GuiControl, Disable, ApplySettingsBTN
     GuiControl, Disable, CurrentPrefWindow
     GuiControl, Disable, CancelBTN
     SetTimer, DupeHotkeysToolTipDummy, -1500
  } Else
  {
     GuiControl, % (!enableApply ? "Disable" : "Enable"), ApplySettingsBTN
     GuiControl, Enable, CurrentPrefWindow
     GuiControl, Enable, CancelBTN
  }
}

DupeHotkeysToolTipDummy() {
  ToolTip
}

ProcessComboKBD(enableApply:=1) {
  forbiddenChars := "(\~|\*|\!|\+|\^|\#|\$|\<|\>|\&)"
  keywords := "i)(\(.|^([\p{Z}\p{P}\p{S}\p{C}\p{N}].)|disa|resto|\s|\[\[|\]\])"
  GuiControlGet, activeCtrl, FocusV
  Loop, Parse, GlobalKBDsList, CSV
  {
      GuiControlGet, CbEdit%A_LoopField%,, Combo%A_LoopField%
      If RegExMatch(CbEdit%A_LoopField%, forbiddenChars)
         GuiControl,, Combo%A_LoopField%, | %KeysComboList%
      If RegExMatch(CbEdit%A_LoopField%, keywords)
         SwitchStateKBDbtn(A_LoopField, 0, 0)
  }

  StringReplace, activeCtrl, activeCtrl, ComboK, K
  If (RegExMatch(CbEdit%activeCtrl%, keywords) || StrLen(CbEdit%activeCtrl%)<1)
     SwitchStateKBDbtn(activeCtrl, 0, 0)
  Else
     SwitchStateKBDbtn(activeCtrl, 1, 0)
  
  GuiControl, % (!enableApply ? "Disable" : "Enable"), ApplySettingsBTN
  GenerateHotkeyStrS(enableApply)
}

ProcessChoiceKBD(strg) {
     Loop, Parse, % "^~#&!+<>$*"
         StringReplace, strg, strg, %A_LoopField%
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

SwitchStateKBDbtn(HotKate, do, noCombo:=1) {
    action := (do=0) ? "Disable" : "Enable"
    If (noCombo=1)
       GuiControl, %action%, Combo%HotKate%
    GuiControl, %action%, Ctrl%HotKate%
    GuiControl, %action%, Shift%HotKate%
    GuiControl, %action%, Alt%HotKate%
    GuiControl, %action%, Win%HotKate%
}

VerifyShortcutOptions(enableApply:=1) {
    GuiControlGet, AlternateTypingMode
    GuiControlGet, PasteOSDcontent
    GuiControlGet, GlobalKBDhotkeys
    GuiControlGet, EnableClipManager

    GuiControl, % (!enableApply ? "Disable" : "Enable"), ApplySettingsBTN
    If (AlternateTypingMode=0)
       SwitchStateKBDbtn("KBDaltTypeMode", 0)
    Else
       SwitchStateKBDbtn("KBDaltTypeMode", 1)

    If (EnableClipManager=0)
       SwitchStateKBDbtn("KBDclippyMenu", 0)
    Else
       SwitchStateKBDbtn("KBDclippyMenu", 1)

    If (PasteOSDcontent=0)
    {
       SwitchStateKBDbtn("KBDpasteOSDcnt1", 0)
       SwitchStateKBDbtn("KBDpasteOSDcnt2", 0)
    } Else
    {
       SwitchStateKBDbtn("KBDpasteOSDcnt1", 1)
       SwitchStateKBDbtn("KBDpasteOSDcnt2", 1)
    }

    If (GlobalKBDhotkeys=0)
    {
        SwitchStateKBDbtn("KBDsynchApp1", 0)
        SwitchStateKBDbtn("KBDsynchApp2", 0)
        SwitchStateKBDbtn("KBDTglNeverOSD", 0)
        SwitchStateKBDbtn("KBDTglPosition", 0)
        SwitchStateKBDbtn("KBDTglSilence", 0)
        SwitchStateKBDbtn("KBDidLangNow", 0)
        SwitchStateKBDbtn("KBDReload", 0)
        SwitchStateKBDbtn("KBDCapText", 0)
    } Else
    {
        If (DisableTypingMode=0)
        {
           SwitchStateKBDbtn("KBDsynchApp1", 1)
           SwitchStateKBDbtn("KBDsynchApp2", 1)
        }
        SwitchStateKBDbtn("KBDsynchApp1", 1)
        SwitchStateKBDbtn("KBDsynchApp2", 1)
        SwitchStateKBDbtn("KBDTglNeverOSD", 1)
        SwitchStateKBDbtn("KBDTglPosition", 1)
        SwitchStateKBDbtn("KBDTglSilence", 1)
        SwitchStateKBDbtn("KBDidLangNow", 1)
        SwitchStateKBDbtn("KBDReload", 1)
        SwitchStateKBDbtn("KBDCapText", 1)
    }

    If (DisableTypingMode=1)
    {
       SwitchStateKBDbtn("KBDpasteOSDcnt1", 0)
       SwitchStateKBDbtn("KBDpasteOSDcnt2", 0)
       SwitchStateKBDbtn("KBDsynchApp1", 0)
       SwitchStateKBDbtn("KBDsynchApp2", 0)
    }

    If (MissingAudios=1 || SafeModeExec=1 || NoAhkH=1)
       SwitchStateKBDbtn("KBDTglSilence", 0)

    If (A_OSVersion="WIN_XP")
       SwitchStateKBDbtn("KBDCapText", 0)
    ProcessComboKBD()
}

PresetsWindow() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    Global ApplySettingsBTN, PresetChosen, EnableBeeperzPresets, MediateKeysFeatures
    EnableBeeperzPresets := 0
    MediateKeysFeatures := 0

    If (PrefsLargeFonts=1)
       Gui, Font, s%LargeUIfontValue%
    Gui, Add, Text, x15 y15, Choose the preset based on `nwhat you would like to use KeyPress for.
    If (NoAhkH!=1 && SafeModeExec!=1 && IsSoundsFile && IsMouseFile && MissingAudios!=1)
       Gui, Add, DropDownList, y+7 wp+110 gVerifyPresetOptions AltSubmit vPresetChosen, [ Presets list ] ||Screen casts / presentations|Typing mode only|Mixed mode|Only beep on key presses [anything else deactivated]|Mouse features only [anything else deactivated]
    Else
       Gui, Add, DropDownList, y+7 wp+110 gVerifyPresetOptions AltSubmit vPresetChosen, [ Presets list ] ||Screen casts / presentations|Typing mode only|Mixed mode
    Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%OutputOSDtoToolTip% vOutputOSDtoToolTip, Show the OSD as a mouse tooltip
    If (NoAhkH!=1 && SafeModeExec!=1 && IsSoundsFile && MissingAudios!=1)
       Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%EnableBeeperzPresets% vEnableBeeperzPresets, Sounds on key presses
    Gui, Add, Checkbox, y+7 gVerifyPresetOptions Checked%MediateKeysFeatures% vMediateKeysFeatures, Mediate navigation keys when typing `n[this helps to enforce consistency across applications]`n(strongly recommended)
    Gui, Add, Button, y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, Button, x+35 w150 hp gDeleteSettings, Restore de&faults
    Gui, Show, AutoSize, Quick start presets: KeyPress OSD
    VerifyPresetOptions(0)
}

VerifyPresetOptions(EnableApply:=1) {
    GuiControlGet, PresetChosen
    GuiControlGet, EnableBeeperzPresets
    GuiControlGet, MediateKeysFeatures

    GuiControl, % (EnableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (PresetChosen=1)
    {
        GuiControl, Disable, EnableBeeperzPresets
        GuiControl, Disable, MediateKeysFeatures
        GuiControl, Disable, OutputOSDtoToolTip
    } Else
    {
        GuiControl, Enable, EnableBeeperzPresets
        GuiControl, Enable, MediateKeysFeatures
    }

    If (EnableApply=0)
       Return

    If (PresetChosen=2)
    {
        GuiControl, Enable, EnableBeeperzPresets
        GuiControl, Enable, OutputOSDtoToolTip
        GuiControl, Disable, MediateKeysFeatures
        AutoDetectKBD := 1
        ClipMonitor := 0
        ConstantAutoDetect := 1
        DisableTypingMode := 1
        EnableTypingHistory := 0
        ShowMouseIdle := 0
        ShowMouseRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 0
        OutputOSDtoToolTip := 0
        ShiftDisableCaps := 0
        ShowKeyCount := 1
        ShowKeyCountFired := 1
        ShowMouseHalo := 1
        ShowSingleKey := 1
        ShowSingleModifierKey := 1
        SilentMode := 1
        ShowMouseVclick := 1
    }

    If (PresetChosen=3)
    {
        GuiControl, Enable, EnableBeeperzPresets
        GuiControl, Disable, OutputOSDtoToolTip
        GuiControl, Enable, MediateKeysFeatures
        GuiControl, , OutputOSDtoToolTip, 0
        AlternateTypingMode := 1
        AutoDetectKBD := 1
        ClipMonitor := 0
        ConstantAutoDetect := 1
        DisableTypingMode := 0
        EnableAltGr := 1
        EnableTypingHistory := 1
        EnterErasesLine := 1
        ShowMouseIdle := 0
        ImmediateAltTypeMode := 0
        ShowMouseRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 1
        OutputOSDtoToolTip := 0
        PasteOnClick := 1
        PasteOSDcontent := 1
        ShiftDisableCaps := 1
        ShowKeyCount := 0
        ShowKeyCountFired := 0
        ShowMouseHalo := 0
        ShowSingleKey := 1
        ShowSingleModifierKey := 0
        SilentMode := 1
        ShowMouseVclick := 0
    }

    If (PresetChosen=4)
    {
        GuiControl, , OutputOSDtoToolTip, 0
        AlternateTypingMode := 1
        AutoDetectKBD := 1
        ClipMonitor := 1
        ConstantAutoDetect := 1
        DisableTypingMode := 0
        EnableAltGr := 1
        EnableTypingHistory := 0
        ShowMouseIdle := 0
        ImmediateAltTypeMode := 0
        ShowMouseRipples := 0
        NeverDisplayOSD := 0
        OnlyTypingMode := 0
        OutputOSDtoToolTip := 0
        PasteOnClick := 1
        PasteOSDcontent := 1
        ShiftDisableCaps := 1
        ShowKeyCount := 1
        ShowKeyCountFired := 1
        ShowMouseHalo := 0
        ShowSingleKey := 1
        ShowSingleModifierKey := 1
        SilentMode := 0
        ShowMouseVclick := 0
    }

    If (PresetChosen>4)
    {
        GuiControl, Disable, EnableBeeperzPresets
        GuiControl, Disable, MediateKeysFeatures
        GuiControl, Disable, OutputOSDtoToolTip
        ClipMonitor := 0
        ShiftDisableCaps := 0
        DisableTypingMode := 1
        NeverDisplayOSD := 1
        OutputOSDtoToolTip := 0
        ConstantAutoDetect := 0
        AutoDetectKBD := 0
    }

    If (EnableBeeperzPresets=1)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        DeadKeyBeeper := 1
        KeyBeeper := 1
        MouseBeeper := 0
        ModBeeper := 1
        BeepFiringKeys := 0
        TypingBeepers := 0
        DTMFbeepers := 0
    } Else (SilentMode := 1)

    If (PresetChosen=4)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        DeadKeyBeeper := 1
        If (enableBeeperzPresets=0)
        {
            KeyBeeper := 0
            ModBeeper := 0
            MouseBeeper := 0
            BeepFiringKeys := 0
            TypingBeepers := 0
            DTMFbeepers := 0
        }
    }

    If (presetChosen=5)
    {
        SilentMode := 0
        ToggleKeysBeeper := 1
        CapslockBeeper := 1
        DeadKeyBeeper := 1
        KeyBeeper := 1
        ModBeeper := 1
        MouseBeeper := 1
        BeepFiringKeys := 1
        TypingBeepers := 1
        DTMFbeepers := 1
        ShowMouseHalo := 0
        ShowMouseVclick := 0
        ShowMouseRipples := 0
        ShowMouseIdle := 0
    }

    If (presetChosen=6)
    {
        SilentMode := 1
        ShowMouseHalo := 1
        ShowMouseIdle := 1
        ShowMouseVclick := 0
        ShowMouseRipples := 1
    }

    If (MediateKeysFeatures=1)
    {
        SendJumpKeys := 1
        MediateNavKeys := 1
    } Else
    {
        SendJumpKeys := 0
        MediateNavKeys := 0
    }

    If (MissingAudios=1)
       GuiControl, Disable, enableBeeperzPresets
}

volSlider() {
    GuiControlGet, result , , BeepsVolume, 
    GuiControl, , volLevel, % "Volume: " result " %"
    BeepsVolume := result
    SetMyVolume()
    SoundsThread.ahkPostFunction["PlaySoundTest", ""]
    VerifySoundsOptions()
}

ShowSoundsSettings() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    VerifyNonCrucialFiles()
    Global ApplySettingsBTN, volLevel, txt1
    Global CurrentPrefWindow := 3
    txtWid := 285
    If (PrefsLargeFonts=1)
    {
       txtWid := 470
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Text, x15 y15 vtxt1, Make a beep when the following keys are released:
    Gui, Add, Checkbox, gVerifySoundsOptions xp+15 y+7 Checked%KeyBeeper% vKeyBeeper, All bound keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%DeadKeyBeeper% vDeadKeyBeeper, Recognized dead keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%ModBeeper% vModBeeper, Modifiers (Ctrl, Alt, WinKey, Shift)
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%ToggleKeysBeeper% vToggleKeysBeeper, Toggle keys (Caps / Num / Scroll lock)
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%MouseBeeper% vMouseBeeper, On mouse clicks
    Gui, Add, Checkbox, gVerifySoundsOptions xp-15 y+14 Checked%CapslockBeeper% vCapslockBeeper, Beep distinctively when typing and CapsLock is on
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%TypingBeepers% vTypingBeepers, Distinct beeps for different key groups
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%DTMFbeepers% vDTMFbeepers, DTMF beeps for numpad keys
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%BeepFiringKeys% vBeepFiringKeys, Generic beep for every key fire
    If (A_OSVersion!="WIN_XP")
       Gui, Add, Checkbox, gVerifySoundsOptions y+14 Checked%BeepSentry% vBeepSentry, Generate visual sound event [for Windows Accessibility]
    Gui, Add, Checkbox, gVerifySoundsOptions y+7 Checked%PrioritizeBeepers% vPrioritizeBeepers, Attempt to play every beep (may interfere with typing mode)`nIf beeps rarely play, enable this.
    Gui, Add, Text, y+10 h25 +0x200 Section vvolLevel, % "Volume: " BeepsVolume " %"
    Gui, Add, Slider, x+5 hp ToolTip NoTicks gVolSlider w200 vBeepsVolume Range5-99, %BeepsVolume%
    Gui, Add, Checkbox, x+5 hp +0x1000 gVerifySoundsOptions Checked%SilentMode% vSilentMode, Silent
    If (DisableTypingMode=1)
       Gui, Add, Text, xs+0 y+15 w%txtWid%, Some options are disabled, because typing mode is not activated.

    If (MissingAudios=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, xs+0 y+15 w%txtWid%, WARNING. Files required for these features are missing. The attempts to download them seem to have failed. Features unavailable.
       Gui, Font, Normal
    }
    Gui, Add, Button, xs+0 y+20 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Sounds settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifySoundsOptions(0)
}

VerifySoundsOptions(EnableApply:=1) {
    GuiControlGet, KeyBeeper
    GuiControlGet, TypingBeepers
    GuiControlGet, SilentMode

    GuiControl, % (EnableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (!IsSoundsFile || MissingAudios=1 || SafeModeExec=1 || NoAhkH=1)
       SilentMode := 1

    action := (SilentMode=1) ? "Disable" : "Enable"
    GuiControl, %action%, BeepSentry
    GuiControl, %action%, CapslockBeeper
    GuiControl, %action%, DeadKeyBeeper
    GuiControl, %action%, TypingBeepers
    GuiControl, %action%, MouseBeeper
    GuiControl, %action%, DTMFbeepers
    GuiControl, %action%, PrioritizeBeepers
    GuiControl, %action%, KeyBeeper
    GuiControl, %action%, ModBeeper
    GuiControl, %action%, ToggleKeysBeeper
    GuiControl, %action%, BeepFiringKeys
    GuiControl, %action%, BeepSentry
    GuiControl, %action%, BeepsVolume
    GuiControl, %action%, volLevel
    GuiControl, %action%, txt1

    If (SilentMode=0)
       GuiControl, % (KeyBeeper=0 ? "Disable" : "Enable"), TypingBeepers

    If (AutoDetectKBD=0 || DoNotBindDeadKeys=1)
       GuiControl, Disable, DeadKeyBeeper

    If (DisableTypingMode=1)
       GuiControl, Disable, CapslockBeeper
}

Switch2KBDsList() {
  GenerateKBDlistMenu()
  Sleep, 25
  Menu, kbdLista, Show
}

GenerateKBDlistMenu() {
    Static ListGenerated
    If (ListGenerated=1)
       Return
    initLangFile()
    Sleep, 25
    IniRead, KLIDlist, %LangFile%, Options, KLIDlist, -
    Loop, Parse, KLIDlist, CSV
    {
      IniRead, doNotList, %LangFile%, %A_LoopField%, doNotList, -
      If (StrLen(A_LoopField)<2 || doNotList=1)
         Continue
      IniRead, langFriendlySysName, %LangFile%, %A_LoopField%, name, -
      IniRead, isRTL, %LangFile%, %A_LoopField%, isRTL, -
      IniRead, KBDisUnsupported, %LangFile%, %A_LoopField%, KBDisUnsupported, -

      If (StrLen(langFriendlySysName)<2 && A_LoopField ~= "i)^(d00)")
      {
         StringReplace, newKLID, A_LoopField, d00, 000
         If InStr(loadedKLIDs, newKLID)
            Continue
         langFriendlySysName := GetLayoutDisplayName(newKLID)
         Sleep, 25
         If StrLen(langFriendlySysName)>1
            IniWrite, %langFriendlySysName%, %LangFile%, %A_LoopField%, name
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
      IniRead, IMEname, %LangFile%, IMEs, name%A_Index%, --
      If (IMEname="--")
         Break
      StringReplace, IMEname, IMEname, Version, ver.
      StringReplace, IMEname, IMEname, Microsoft, MS.
      StringReplace, IMEname, IMEname, traditional, trad.
      Menu, kbdLista, Add, %IMEname% (unsupported), dummy
      Menu, kbdLista, Disable, %IMEname% (unsupported)
    }
    ListGenerated := 1
}

editsKBDwin() {
  If (A_TickCount-DoNotRepeatTimer<1000)
     Return
  VerifyKeybdOptions()
}

ShowKBDsettings() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    Global RealTimeUpdates := 0
    Global DoNotRepeatTimer := A_TickCount
    Global CurrentPrefWindow := 1
    Global EditF22, EditF23, EditF24, EditF25, EditF26, EditF27, EditF28, EditF29, EditF30, EditF31, EditF32, EditF33, EditF34, DeleteAllClippyBTN
    txtWid := 250
    btnWid := 130
    sliderWidth := 85
    If (PrefsLargeFonts=1)
    {
       sliderWidth := sliderWidth + 60
       txtWid := txtWid + 120
       btnWid := btnWid + 50
       Gui, Font, s%LargeUIfontValue%
    }
    RegRead, LastTab, %KPregEntry%, Window%CurrentPrefWindow%
    Gui, Add, Tab3, AltSubmit Choose%LastTab% vCurrentTab, Keyboard layouts|Behavior|Clipboard|Text caret

    Gui, Tab, 1 ; layouts
    Gui, Add, Checkbox, x+15 y+15 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continuously detect layout changes
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%UseMUInames% vUseMUInames, Use system default language names for layouts
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%SilentDetection% vSilentDetection, Silent detection (no messages)
    Gui, Add, Checkbox, y+7 Section gVerifyKeybdOptions Checked%EnableAltGr% vEnableAltGr, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xs+0 y+7 gVerifyKeybdOptions Checked%IgnoreAdditionalKeys% vIgnoreAdditionalKeys, Ignore specific keys (dot separated)
    Gui, Add, Edit, xp+20 y+5 gVerifyKeybdOptions w180 r1 -multi -wantReturn -wantTab -wrap vIgnorekeysList, %IgnorekeysList%
    Gui, Font, Bold
    Gui, Add, Text, xp-20 y+7, Current keyboard layout:
    Gui, Add, Text, y+7 w%txtWid%, %CurrentKBD%
    IniRead, KBDsDetected, %LangFile%, Options, KBDsDetected, -
    If (KBDsDetected>0)
       Gui, Add, Text, y+7, Total layouts detected: %KBDsDetected%

    If (LoadedLangz!=1 && AutoDetectKBD=1)
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
    Gui, Add, Edit, x+5 w60 geditsKBDwin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vEditF22, %ShowPrevKeyDelay%
    Gui, Add, UpDown, vShowPrevKeyDelay gVerifyKeybdOptions Range100-990, %ShowPrevKeyDelay%
    Gui, Add, Checkbox, xs+0 y+2 gVerifyKeybdOptions Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, y+7 gVerifyKeybdOptions Checked%OSDshowLEDs% vOSDshowLEDs, Show LEDs to indicate key states
    Gui, Add, Text, xp+15 y+5 w%txtWid% vEditF26, This applies for Alt, Ctrl, Shift, Winkey and `nCaps / Num / Scroll lock.

    If (OnlyTypingMode=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, xs y+7 w%txtWid%, Some options are disabled because Only Typing mode is activated.
       Gui, Font, Normal
    }

    Gui, Tab, 3 ; clipboard
    Gui, Add, Checkbox, x+15 y+15 gVerifyKeybdOptions Checked%ClipMonitor% vClipMonitor, Show clipboard changes in the OSD
    Gui, Add, Checkbox, y+10 Section gVerifyKeybdOptions Checked%EnableClipManager% vEnableClipManager, Enable Clipboard History (only for text)
    Gui, Add, Text, xs+15 y+12 veditF24, Maximum text clips to store
    Gui, Add, Edit, x+5 w60 geditsKBDwin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap vEditF23, %MaximumTextClips%
    Gui, Add, UpDown, vMaximumTextClips gVerifyKeybdOptions Range3-30, %MaximumTextClips%
    Gui, Add, Text, xs+15 y+7 veditF32, Do not preserve formatting for `ntexts exceeding (characters)
    Gui, Add, Edit, x+5 w75 gVerifyKeybdOptions r1 limit6 -multi number -wantCtrlA -wantReturn -wantTab -wrap vMaxRTFtextClipLen, %MaxRTFtextClipLen%
    Gui, Add, Checkbox, xs+15 y+25 gVerifyKeybdOptions Checked%DoNotPasteClippy% vDoNotPasteClippy, Do not paste, just change the clipboard content
    Gui, Add, Text, xs+0 y+7 w%txtWid% veditF25, To access the stored clipboard history from any application, press WinKey + V (default keyboard shortcut).
    INIaction(0, "ClipDataMD5s", "ClipboardManager")
    If StrLen(ClipDataMD5s)>5
       Gui, Add, Button, y+10 w170 h30 gInvokeClippyMenu vDeleteAllClippyBTN, List stored entries

    Gui, Tab, 4 ; caret
    Gui, Add, Checkbox, x+15 y+15 Section gVerifyKeybdOptions Checked%ShowCaretHalo% vShowCaretHalo, Highlight text caret in host app `n(when detectable)
    Gui, Add, ListView, xs+15 y+15 w55 h25 %CCLVO% Background%CaretHaloColor% vCaretHaloColor hwndhLV12,
    Gui, Add, Slider, x+5 w%sliderWidth% ToolTip NoTicks Line3 gVerifyKeybdOptions vCaretHaloAlpha Range20-240, %CaretHaloAlpha%
    Gui, Add, Text, x+5 veditF27, % Round(CaretHaloAlpha / 255 * 100) " % opacity"
    Gui, Add, Text, xs+15 y+20 veditF28, Size width / height. Thickness.
    Gui, Add, Edit, y+7 w60 geditsKBDwin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF34, %CaretHaloWidth%
    Gui, Add, UpDown, vCaretHaloWidth gVerifyKeybdOptions Range10-350, %CaretHaloWidth%
    Gui, Add, Edit, x+10 w60 geditsKBDwin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF29, %CaretHaloHeight%
    Gui, Add, UpDown, vCaretHaloHeight gVerifyKeybdOptions Range10-350, %CaretHaloHeight%
    Gui, Add, Edit, x+10 w60 geditsKBDwin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF30, %CaretHaloThick%
    Gui, Add, UpDown, vCaretHaloThick gVerifyKeybdOptions Range0-60, %CaretHaloThick%
    Gui, Add, DropDownList, y+10 xs+15 w105 AltSubmit gVerifyKeybdOptions choose%CaretHaloShape% vCaretHaloShape, Circle|Rectangle
    Gui, Add, Checkbox, x+10 hp gVerifyKeybdOptions Checked%CaretHaloFlash% vCaretHaloFlash, Flashing
    If (!IsMouseFile || SafeModeExec=1 || NoAhkH=1)
    {
       Gui, Font, Bold
       Gui, Add, Text, xs+0 y+15 w%txtWid%, Text caret halo is disabled, because the application is executed in a limited mode or missing files.
       Gui, Font, Normal
    } Else Gui, Add, Text, xs+15 y+15 w%txtWid% veditF31, If thickness is set below 5, a solid shape of the specified dimensions will be painted.

    Gui, Add, Checkbox, y+15 gVerifyKeybdOptions Checked%RealTimeUpdates% vRealTimeUpdates, Update settings in real time

    Gui, Tab
    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, Keyboard settings: KeyPress OSD
    ColorPickerHandles := hLV12
    verifySettingsWindowSize()
    VerifyKeybdOptions(0)
}

VerifyKeybdOptions(EnableApply:=1) {
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
    GuiControlGet, EnableAltGr
    GuiControlGet, ShowCaretHalo
    GuiControlGet, EnableClipManager
    GuiControlGet, OSDshowLEDs
    GuiControlGet, CaretHaloShape
    GuiControlGet, CaretHaloWidth
    GuiControlGet, CaretHaloHeight
    GuiControlGet, CaretHaloThick
    GuiControlGet, CaretHaloFlash
    GuiControlGet, RealTimeUpdates

    GuiControl, % (EnableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (EnableApply=1 ? "Disable" : "Enable"), DeleteAllClippyBTN
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

    GuiControl, % (AutoDetectKBD=1 ? "Enable" : "Disable"), ConstantAutoDetect
    GuiControl, % (AutoDetectKBD=1 ? "Enable" : "Disable"), SilentDetection
    GuiControl, % (IgnoreAdditionalKeys=0 ? "Disable" : "Enable"), IgnorekeysList

    If (!IsMouseFile || SafeModeExec=1)
    {
        GuiControl, , ShowCaretHalo, 0
        GuiControl, Disable, ShowCaretHalo
        ShowCaretHalo := 0
    }

    action1 := (ShowCaretHalo=0) ? "Disable" : "Enable"
    GuiControl, %action1%, CaretHaloFlash
    GuiControl, %action1%, CaretHaloColor
    GuiControl, %action1%, CaretHaloAlpha
    GuiControl, %action1%, CaretHaloShape
    GuiControl, %action1%, RealTimeUpdates
    GuiControl, %action1%, EditF27
    GuiControl, %action1%, EditF28
    GuiControl, %action1%, EditF29
    GuiControl, %action1%, EditF30
    GuiControl, %action1%, EditF31
    GuiControl, %action1%, EditF34
    If (ShowCaretHalo=1)
       GuiControl, , EditF27, % Round(CaretHaloAlpha / 255 * 100) " % opacity"

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
    action2 := (EnableClipManager=0) ? "Disable" : "Enable"
    GuiControl, %action2%, EditF23
    GuiControl, %action2%, EditF24
    GuiControl, %action2%, EditF25
    GuiControl, %action2%, EditF32
    GuiControl, %action2%, MaxRTFtextClipLen
    GuiControl, %action2%, DoNotPasteClippy
    GuiControl, % (OSDshowLEDs=0 ? "Disable" : "Enable"), EditF26
    If (RealTimeUpdates=1)
       SetTimer, updateRealTimeSettings, -400, -50
}


editsMouseWin() {
  If (A_TickCount-DoNotRepeatTimer<1000)
     Return
  VerifyMouseOptions()
}

ShowMouseSettings() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    Global RealTimeUpdates := 0
    Global CurrentPrefWindow := 4
    Global DoNotRepeatTimer := A_TickCount
    Global editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, editF10, editF11, editF12, editF13, editF14, editF15, editF16, editF17

    sliderWidth := 85
    txtWid := 275
    If (PrefsLargeFonts=1)
    {
       txtWid := txtWid + 90
       sliderWidth := sliderWidth + 60
       Gui, Font, s%LargeUIfontValue%
    }
    RegRead, LastTab, %KPregEntry%, Window%CurrentPrefWindow%
    Gui, Add, Tab3, AltSubmit Choose%LastTab% vCurrentTab, Mouse clicks|Mouse location

    Gui, Tab, 1 ; clicks
    Gui, Add, Checkbox, gVerifyMouseOptions x+15 y+15 w250 Checked%MouseBeeper% vMouseBeeper, Beep on mouse clicks
    If (OnlyTypingMode!=1)
       Gui, Add, Checkbox, gVerifyMouseOptions y+5 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Text, y+15 Section, Show on mouse clicks: 
    Gui, Add, Checkbox, x+5 gVerifyMouseOptions Checked%ShowMouseVclick% vShowMouseVclick, Blocks
    Gui, Add, Checkbox, x+5 gVerifyMouseOptions Checked%ShowMouseRipples% vShowMouseRipples, Ripples
    Gui, Add, Text, xs+16 y+10 veditF17, Scale. Color, Opacity.
    Gui, Add, Edit, y+5 w55 geditsMouseWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %MouseVclickScaleUser%
    Gui, Add, UpDown, vMouseVclickScaleUser gVerifyMouseOptions Range5-70, %MouseVclickScaleUser%
    Gui, Add, ListView, x+5 w50 hp %CCLVO% Background%MouseVclickColor% vMouseVclickColor hwndhLV6,
    Gui, Add, Slider, x+5 w%sliderWidth% hp ToolTip NoTicks Line3 gVerifyMouseOptions vMouseVclickAlpha Range20-240, %MouseVclickAlpha%
    Gui, Add, Text, x+5 veditF2, % Round(MouseVclickAlpha / 255 * 100) " %"
    Gui, Add, Text, xs+16 y+30 veditF11, Size. Thickness. Speed (higher is slower).
    Gui, Add, Edit, y+10 w55 geditsMouseWin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %MouseRippleMaxSize%
    Gui, Add, UpDown, vMouseRippleMaxSize gVerifyMouseOptions Range130-400, %MouseRippleMaxSize%
    Gui, Add, Edit, x+10 w55 geditsMouseWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %MouseRippleThickness%
    Gui, Add, UpDown, vMouseRippleThickness gVerifyMouseOptions Range5-50, %MouseRippleThickness%
    Gui, Add, Edit, x+10 w55 geditsMouseWin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF10, %MouseRippleFrequency%
    Gui, Add, UpDown, vMouseRippleFrequency gVerifyMouseOptions Range3-40, %MouseRippleFrequency%
    Gui, Add, Text, xs+16 y+11 veditF13, Colors. Opacity:
    Gui, Add, Slider, x+5 w%sliderWidth% ToolTip NoTicks Line3 gVerifyMouseOptions vMouseRippleOpacity Range20-240, %MouseRippleOpacity%
    Gui, Add, Text, x+5 veditF12, % Round(MouseRippleOpacity / 255 * 100) " %"
    Gui, Add, ListView, xs+16 y+20 w50 h25 %CCLVO% Background%MouseRippleLbtnColor% vMouseRippleLbtnColor hwndhLV8,
    Gui, Add, ListView, x+5 wp hp %CCLVO% Background%MouseRippleMbtnColor% vMouseRippleMbtnColor hwndhLV9,
    Gui, Add, ListView, x+5 wp hp %CCLVO% Background%MouseRippleRbtnColor% vMouseRippleRbtnColor hwndhLV10,
    Gui, Add, ListView, x+5 wp hp %CCLVO% Background%MouseRippleWbtnColor% vMouseRippleWbtnColor hwndhLV11,

    Gui, Tab, 2 ; location
    Gui, Add, Checkbox, gVerifyMouseOptions section x+15 y+15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Edit, xs+16 y+15 w60 geditsMouseWin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %MouseHaloRadius%
    Gui, Add, UpDown, vMouseHaloRadius gVerifyMouseOptions Range25-950, %MouseHaloRadius%
    Gui, Add, Text, x+5 hp +0x200 veditF16, diameter
    Gui, Add, ListView, xs+16 y+15 w60 h25 %CCLVO% Background%MouseHaloColor% vMouseHaloColor hwndhLV4,
    Gui, Add, Slider, x+5 w%sliderWidth% ToolTip NoTicks Line3 gVerifyMouseOptions vMouseHaloAlpha Range20-240, %MouseHaloAlpha%
    Gui, Add, Text, x+5 veditF4, % Round(MouseHaloAlpha / 255 * 100) " % opacity"

    Gui, Add, Checkbox, gVerifyMouseOptions xs+0 y+25 Checked%ShowMouseIdle% vShowMouseIdle, Show idle mouse halo
    Gui, Add, Checkbox, gVerifyMouseOptions x+15 yp Checked%MouseIdleFlash% vMouseIdleFlash, Flashing
    Gui, Add, Edit, xs+16 y+15 w60 geditsMouseWin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %MouseIdleAfter%
    Gui, Add, UpDown, vMouseIdleAfter gVerifyMouseOptions Range3-950, %MouseIdleAfter%
    Gui, Add, Text, x+5 hp +0x200 veditF15, idle after (in seconds)
    Gui, Add, Edit, xs+16 y+15 w60 geditsMouseWin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %MouseIdleRadius%
    Gui, Add, UpDown, vMouseIdleRadius gVerifyMouseOptions Range25-950, %MouseIdleRadius%
    Gui, Add, Text, x+5 hp +0x200 veditF14, halo diameter
    Gui, Add, ListView, xs+16 y+15 w60 h25 %CCLVO% Background%MouseIdleColor% vMouseIdleColor hwndhLV7,
    Gui, Add, Slider, x+5 w%sliderWidth% ToolTip NoTicks Line3 gVerifyMouseOptions vMouseIdleAlpha Range20-240, %MouseIdleAlpha%
    Gui, Add, Text, x+5 veditF7, % Round(MouseIdleAlpha / 255 * 100) " % opacity"

    Gui, Tab
    Gui, Add, Checkbox, gVerifyMouseOptions y+10 Checked%RealTimeUpdates% vRealTimeUpdates, Update settings in real time
    If (!IsSoundsFile || SafeModeExec=1 || NoAhkH=1 || !IsMouseFile || !IsRipplesFile) ; keypress-beeperz-functions.ahk / keypress-mouse-ripples-functions.ahk
    {
       Gui, Font, Bold
       Gui, Add, Text, y+7 w%txtWid%, Most options are disabled because files are missing or running in a limited mode.
       Gui, Font, Normal
    }

    Gui, Add, Button, xm+0 y+15 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts

    Gui, Show, AutoSize, Mouse settings: KeyPress OSD
    verifySettingsWindowSize()
    VerifyMouseOptions(0)
    ColorPickerHandles := hLV4 "," hLV6 "," hLV7 "," hLV8 "," hLV9 "," hLV10 "," hLV11
}

VerifyMouseOptions(EnableApply:=1) {
    GuiControlGet, ShowMouseIdle
    GuiControlGet, ShowMouseHalo
    GuiControlGet, MouseIdleAfter
    GuiControlGet, MouseIdleRadius
    GuiControlGet, MouseHaloRadius
    GuiControlGet, ShowMouseButton
    GuiControlGet, ShowMouseVclick
    GuiControlGet, ShowMouseRipples
    GuiControlGet, RealTimeUpdates
    GuiControlGet, MouseIdleFlash
    GuiControlGet, MouseVclickAlpha
    GuiControlGet, MouseVclickScaleUser
    GuiControlGet, MouseRippleOpacity
    GuiControlGet, MouseRippleFrequency
    GuiControlGet, MouseRippleThickness
    GuiControlGet, MouseRippleMaxSize

    If (!IsRipplesFile || SafeModeExec=1 || NoAhkH=1)
       ShowMouseRipples := 0

    If (!IsMouseFile || SafeModeExec=1 || NoAhkH=1)
    {
       ShowMouseVclick := 0
       ShowMouseHalo := 0
       ShowMouseIdle := 0
       GuiControl, Disable, ShowMouseVclick
       GuiControl, Disable, ShowMouseHalo
       GuiControl, Disable, ShowMouseIdle
    }

    GuiControl, % (EnableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    If (ShowMouseVclick=0)
    {
       GuiControl, Disable, MouseVclickScaleUser
       GuiControl, Disable, MouseVclickAlpha
       GuiControl, Disable, MouseVclickColor
       GuiControl, Enable, ShowMouseRipples
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
       GuiControl, Disable, editF17
    } Else
    {
       GuiControl, Enable, MouseVclickScaleUser
       GuiControl, Enable, MouseVclickAlpha
       GuiControl, Enable, MouseVclickColor
       GuiControl, Disable, ShowMouseRipples
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
       GuiControl, Enable, editF17
    }
    action1 := (ShowMouseIdle=0) ? "Disable" : "Enable"
    GuiControl, %action1%, MouseIdleFlash
    GuiControl, %action1%, MouseIdleAfter
    GuiControl, %action1%, MouseIdleRadius
    GuiControl, %action1%, MouseIdleColor
    GuiControl, %action1%, MouseIdleAlpha
    GuiControl, %action1%, editF5
    GuiControl, %action1%, editF6
    GuiControl, %action1%, editF7
    GuiControl, %action1%, editF14
    GuiControl, %action1%, editF15

    action2 := (ShowMouseHalo=0) ? "Disable" : "Enable"
    GuiControl, %action2%, MouseHaloRadius
    GuiControl, %action2%, MouseHaloColor
    GuiControl, %action2%, MouseHaloAlpha
    GuiControl, %action2%, editF3
    GuiControl, %action2%, editF4
    GuiControl, %action2%, editF16

    action3 := (ShowMouseRipples=0) ? "Disable" : "Enable"
    GuiControl, % (ShowMouseRipples=1) ? "Disable" : "Enable", ShowMouseVclick
    GuiControl, %action3%, MouseRippleThickness
    GuiControl, %action3%, MouseRippleMaxSize
    GuiControl, %action3%, editF8
    GuiControl, %action3%, editF9
    GuiControl, %action3%, editF10
    GuiControl, %action3%, editF11
    GuiControl, %action3%, editF12
    GuiControl, %action3%, editF13
    GuiControl, %action3%, MouseRippleOpacity
    GuiControl, %action3%, MouseRippleLbtnColor
    GuiControl, %action3%, MouseRippleRbtnColor
    GuiControl, %action3%, MouseRippleMbtnColor
    GuiControl, %action3%, MouseRippleWbtnColor

    If !IsSoundsFile ; keypress-beeperz-functions.ahk
       GuiControl, Disable, MouseBeeper

    If (RealTimeUpdates=1)
       SetTimer, updateRealTimeSettings, -400, -50
    If (ShowMouseVclick=1)
       GuiControl, , editF2, % Round(MouseVclickAlpha / 255 * 100) " %"
    If (ShowMouseHalo=1)
       GuiControl, , editF4, % Round(MouseHaloAlpha / 255 * 100) " % opacity"
    If (ShowMouseIdle=1)
       GuiControl, , editF7, % Round(MouseIdleAlpha / 255 * 100) " % opacity"
    If (ShowMouseRipples=1)
       GuiControl, , editF12, % Round(MouseRippleOpacity / 255 * 100) " % opacity"

    If (!IsRipplesFile || SafeModeExec=1 || NoAhkH=1)
       GuiControl, Disable, ShowMouseRipples
    If (!IsMouseFile || SafeModeExec=1 || NoAhkH=1)
    {
       GuiControl, Disable, ShowMouseVclick
       GuiControl, Disable, ShowMouseHalo
       GuiControl, Disable, ShowMouseIdle
    }
    If (SafeModeExec=1 || NoAhkH=1)
       GuiControl, Disable, RealTimeUpdates
}

SendVarsMouseAHKthread(initMode) {
   sendMouseVar("MouseHaloAlpha")
   sendMouseVar("MouseHaloColor")
   sendMouseVar("MouseHaloRadius")
   sendMouseVar("MouseIdleAfter")
   sendMouseVar("MouseIdleAlpha")
   sendMouseVar("MouseIdleColor")
   sendMouseVar("MouseIdleFlash")
   sendMouseVar("MouseIdleRadius")
   sendMouseVar("MouseVclickAlpha")
   sendMouseVar("MouseVclickColor")
   sendMouseVar("MouseVclickScale")
   sendMouseVar("ShowMouseHalo")
   sendMouseVar("ShowMouseIdle")
   sendMouseVar("ShowMouseVclick")
   sendMouseVar("ShowCaretHalo")
   sendMouseVar("CaretHaloAlpha")
   sendMouseVar("CaretHaloColor")
   sendMouseVar("CaretHaloHeight")
   sendMouseVar("CaretHaloWidth")
   sendMouseVar("CaretHaloShape")
   sendMouseVar("CaretHaloFlash")
   sendMouseVar("CaretHaloThick")
   If (initMode=1)
      MouseFuncThread.ahkPostFunction["MouseInit"] 
}

sendSndVar(var) {
   varValue := %var%
   SoundsThread.ahkassign(var, varValue)
}

sendRiplVar(var) {
   varValue := %var%
   MouseRipplesThread.ahkassign(var, varValue)
}

sendMouseVar(var) {
   varValue := %var%
   MouseFuncThread.ahkassign(var, varValue)
}

SendVarsSoundsAHKthread() {
   SendSndVar("beepFiringKeys")
   SendSndVar("BeepSentry")
   SendSndVar("CapslockBeeper")
   SendSndVar("DTMFbeepers")
   SendSndVar("KeyBeeper")
   SendSndVar("ModBeeper")
   SendSndVar("MouseBeeper")
   SendSndVar("PrioritizeBeepers")
   SendSndVar("SilentMode")
   SendSndVar("ToggleKeysBeeper")
   SendSndVar("TypingBeepers")
   SoundsThread.ahkPostFunction["CreateHotkey"] 
}

SendVarsRipplesAHKthread(initMode) {
   sendRiplVar("ShowMouseRipples")
   sendRiplVar("MouseRippleMaxSize")
   sendRiplVar("MouseRippleThickness")
   sendRiplVar("MouseRippleFrequency")
   sendRiplVar("MouseRippleOpacity")
   sendRiplVar("MouseRippleLbtnColor")
   sendRiplVar("MouseRippleRbtnColor")
   sendRiplVar("MouseRippleMbtnColor")
   sendRiplVar("MouseRippleWbtnColor")
   If (ShowMouseRipples=1 && initMode=1)
      MouseRipplesThread.ahkPostFunction["MouseRippleSetup"]
}

updateRealTimeSettings() {
  Gui, Submit, NoHide
  CheckSettings()
  Sleep, 20
  If (CurrentPrefWindow=4)
  {
     MouseVclickScale := MouseVclickScaleUser/10
     SendVarsMouseAHKthread(0)
     If ShowMouseVclick
        MouseFuncThread.ahkPostFunction["ShowMouseClick", "0", "1"]
     Sleep, 5
     SendVarsRipplesAHKthread(0)
     MouseRipplesThread.ahkPostFunction["MouseRippleUpdate"]
  } Else If (CurrentPrefWindow=1)
  {
     SendVarsMouseAHKthread(0)
     MouseFuncThread.ahkPostFunction["CaretHalo", "1"]
  }
  MouseFuncThread.ahkPostFunction["MouseInit"]
}

hexRGB(c) {
; unknown source
  r := ((c&255)<<16)+(c&65280)+((c&0xFF0000)>>16)
  c := "000000"
  DllCall("msvcrt\sprintf", "AStr", c, "AStr", "%06X", "UInt", r, "CDecl")
  Return c
}

Dlg_Color(Color,hwnd) {
; Function by maestrith 
; from: [AHK 1.1] Font and Color Dialogs 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/
; Modified by Marius Șucan and Drugwash

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

  SetFormat, Integer, H
  Color := NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
  SetFormat, Integer, D
  GuiControlGet, RealTimeUpdates
  If (RealTimeUpdates=1)
     SetTimer, updateRealTimeSettings, -400, -50

  Return Color
}

setColors(hC, event, c, err=0) {
; Function by Drugwash
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
  If (CurrentPrefWindow=5)
     OSDpreview()
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
    If (A_TickCount-Tickcount_start2 < 150)
       Return

    If (ShowPreview=0 || CurrentPrefWindow!=5)
    {
       Gui, OSD: Hide
       Return
    }
    SetTimer, checkMousePresence, on, 950, -15
    Sleep, 10
    DragOSDmode := 1
    NeverDisplayOSD := 0
    MaxAllowedGuiWidth := (OSDautosize=1) ? MaxGuiWidth : GuiWidth
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
    ShowHotkey(PreviewWindowText)
}

editsOSDwin() {
  If (A_TickCount-DoNotRepeatTimer<1000)
     Return
  VerifyOsdOptions()
}

ShowOSDsettings() {
    doNotOpen := initSettingsWindow()
    If (doNotOpen=1)
       Return

    If ShowPreview             ; If OSD is already visible don't hide/show it,
       SetTimer, HideGUI, Off  ; just update the text (avoids the flicker)
    Global CurrentPrefWindow := 5
    Global DoNotRepeatTimer := A_TickCount
    Global positionB, editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, editF10, editF35, editF36, editF37, Btn1, Btn2
    GUIposition := GUIposition + 1
    columnBpos1 := columnBpos2 := 125
    editFieldWid := 220
    If (PrefsLargeFonts=1)
    {
       Gui, Font, s%LargeUIfontValue%
       editFieldWid := 285
       columnBpos1 := columnBpos2 := columnBpos2 + 125
    }
    columnBpos1b := columnBpos1 + 70

    RegRead, LastTab, %KPregEntry%, Window%CurrentPrefWindow%
    Gui, Add, Tab3, AltSubmit Choose%LastTab% vCurrentTab, Size and position|Style and colors

    Gui, Tab, 1 ; size/position
    Gui, Add, Text, x+15 y+15 section, OSD location presets:
    Gui, Add, Radio, y+7 Group Section gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, yp+30 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, DropDownList, xs+%columnBpos1% ys+0 w65 gVerifyOsdOptions AltSubmit Choose%OSDalignment2% vOSDalignment2, Left|Center|Right|
    Gui, Add, Edit, x+5 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %GuiXa%
    Gui, Add, UpDown, vGuiXa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXa%
    Gui, Add, Edit, x+5 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %GuiYa%
    Gui, Add, UpDown, vGuiYa gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYa%
    Gui, Add, Button, x+5 w25 h20 gLocatePositionA vBtn1, L
    Gui, Add, DropDownList, xs+%columnBpos1% ys+30 Section w65 gVerifyOsdOptions AltSubmit Choose%OSDalignment1% vOSDalignment1, Left|Center|Right|
    Gui, Add, Edit, x+5 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %GuiXb%
    Gui, Add, UpDown, vGuiXb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiXb%
    Gui, Add, Edit, x+5 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %GuiYb%
    Gui, Add, UpDown, vGuiYb gVerifyOsdOptions 0x80 Range-9995-9998, %GuiYb%
    Gui, Add, Button, x+5 w25 h20 gLocatePositionB vBtn2, L

    Gui, Add, Text, xm+15 ys+30 Section veditF35, Width (fixed size)
    Gui, Add, Text, xp+0 yp+30, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+30 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (max. width)
    Gui, Add, Text, xp+0 yp+30, When mouse cursor hovers the OSD
    Gui, Add, Checkbox, xp+0 y+10 gVerifyOsdOptions Checked%OutputOSDtoToolTip% vOutputOSDtoToolTip, Display OSD as a mouse tooltip

    Gui, Add, Edit, xs+%columnBpos1b% ys+0 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %GuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vGuiWidth Range55-2900, %GuiWidth%
    Gui, Add, Edit, xp+0 yp+30 w65 geditsOSDwin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %OSDsizingFactor%
    Gui, Add, UpDown, gVerifyOsdOptions vOSDsizingFactor Range20-399, %OSDsizingFactor%
    Gui, Add, Edit, xp+0 yp+30 w65 geditsOSDwin r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %MaxGuiWidth%
    Gui, Add, UpDown, gVerifyOsdOptions vMaxGuiWidth Range90-2900, %MaxGuiWidth%
    Gui, Add, DropDownList, xp+0 yp+30 w160 gVerifyOsdOptions AltSubmit Choose%MouseOSDbehavior% vMouseOSDbehavior, Immediately hide|Toggle positions (A/B)|Allow drag to reposition

    Gui, Tab, 2 ; style
    Gui, Add, Text, x+15 y+15 Section, Font name and size
    Gui, Add, Text, xs yp+30, Text and background colors
    Gui, Add, Text, xs yp+30 veditF36, Caps lock highlight color
    If (AlternateTypingMode=1)
       Gui, Add, Text, xs yp+30, Alternative typing mode highlight color
    Gui, Add, Text, xs yp+30, OSD display time / when typing (in sec.)
    Gui, Add, Checkbox, y+9 gVerifyOsdOptions Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, y+7 gVerifyOsdOptions Checked%OSDshowLEDs% vOSDshowLEDs, Show LEDs to indicate key states
    Gui, Add, text, xp+15 y+5 w310 veditF37, This applies for Alt, Ctrl, Shift, Winkey `nand Caps / Num / Scroll lock.

    Gui, Add, DropDownList, xs+%columnBpos2% ys+0 section w145 gVerifyOsdOptions Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+150 yp+0 w55 geditsOSDwin r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %FontSize%
    Gui, Add, UpDown, gVerifyOsdOptions vFontSize Range7-295, %FontSize%
    Gui, Add, ListView, xp-60 yp+30 w55 h20 %CCLVO% Background%OSDtextColor% vOSDtextColor hwndhLV1,
    Gui, Add, ListView, xp+60 yp w55 h20 %CCLVO% Background%OSDbgrColor% vOSDbgrColor hwndhLV2,
    Gui, Add, ListView, xp-60 yp+30 w55 h20 %CCLVO% Background%CapsColorHighlight% vCapsColorHighlight hwndhLV3,
    If (AlternateTypingMode=1)
       Gui, Add, ListView, xp+0 yp+30 w55 h20 %CCLVO% Background%TypingColorHighlight% vTypingColorHighlight hwndhLV5,
    Gui, Add, Edit, xp+60 yp+30 w55 geditsOSDwin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF10, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser gVerifyOsdOptions Range2-99, %DisplayTimeTypingUser%
    Gui, Add, Edit, xp-60 yp w55 hp geditsOSDwin r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %DisplayTimeUser%
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
       Gui, Add, Text, y+5, WARNING: The option "Do not display the OSD" is activated.
    Gui, Add, Checkbox, y+8 gVerifyOsdOptions Checked%ShowPreview% vShowPreview, Show preview window
    Gui, Add, Edit, x+7 gVerifyOsdOptions w%editFieldWid% limit80 r1 -multi -wantReturn -wantTab -wrap vPreviewWindowText, %PreviewWindowText%
    Gui, Font, Normal

    Gui, Add, Button, xm+0 y+10 w70 h30 Default gApplySettings vApplySettingsBTN, A&pply
    Gui, Add, Button, x+8 wp hp gCloseSettings, C&ancel
    Gui, Add, DropDownList, x+8 AltSubmit gSwitchPreferences choose%CurrentPrefWindow% vCurrentPrefWindow , Keyboard|Typing mode|Sounds|Mouse|Appearance|Shortcuts
    Gui, Show, AutoSize, OSD appearance: KeyPress OSD
    verifySettingsWindowSize()
    VerifyOsdOptions(0)
    ColorPickerHandles := hLV1 "," hLV2 "," hLV3 "," hLV5
}

VerifyOsdOptions(EnableApply:=1) {
    GuiControlGet, OSDautosize
    GuiControlGet, GUIposition
    GuiControlGet, ShowPreview
    GuiControlGet, DragOSDmode
    GuiControlGet, OSDshowLEDs
    GuiControlGet, OSDsizingFactor

    GuiControl, % (EnableApply=0 ? "Disable" : "Enable"), ApplySettingsBTN
    GuiControl, % (ShowPreview=1 ? "Enable" : "Disable"), PreviewWindowText
    GuiControl, % (OSDshowLEDs=1 ? "Enable" : "Disable"), CapsColorHighlight
    GuiControl, % (OSDshowLEDs=1 ? "Enable" : "Disable"), editF36
    GuiControl, % (OSDshowLEDs=1 ? "Enable" : "Disable"), editF37

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
        GuiControl, Enable, editF35
        GuiControl, Disable, MaxGuiWidth
        GuiControl, Disable, editF8
    } Else
    {
        GuiControl, Disable, GuiWidth
        GuiControl, Disable, editF7
        GuiControl, Disable, editF35
        GuiControl, Enable, MaxGuiWidth
        GuiControl, Enable, editF8
    }

    If (DisableTypingMode=1)
    {
        GuiControl, Disable, editF10
        GuiControl, Disable, DisplayTimeTypingUser
    }
    If (OSDsizingFactor>398 || OSDsizingFactor<12)
       GuiControl, , editF9, % calcOSDresizeFactor()

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
; Function by errorseven from:
; https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
    hash := {}, newArr := []
    For e, v in arr
        If (!hash.Haskey(v))
            hash[(v)] := 1, newArr.push(v)
    Return newArr
}

DonateNow() {
   Run, https://www.paypal.me/MariusSucan/15
   CloseWindow()
}

OpenGitHub() {
   Run, https://github.com/marius-sucan/KeyPress-OSD
   CloseWindow()
}

AboutWindow() {
    If (PrefOpen=1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        Return
    }

    If (AnyWindowOpen=1)
    {
       CloseWindow()
       Return
    }

    Static checkVersion
    SettingsGUI()
    If !checkVersion
       IniRead, checkVersion, %IniFile%, SavedSettings, Version, 0
    If (checkVersion!=Version)
    {
       INIaction(1, "ReleaseDate", "SavedSettings")
       INIaction(1, "Version", "SavedSettings")
    }
    hPaypalImg := LoadImage(A_IsCompiled ? A_ScriptFullPath : "Lib\paypal.bmp", "B", 100)
    hIconImg := LoadImage(A_IsCompiled ? A_ScriptFullPath : "Lib\keypress.ico", "I", 159, 128)
    AnyWindowOpen := 1
    btnWid := 100
    txtWid := 360
    Global btn1
    Gui, Font, s20 Bold, Arial, -wrap
    Gui, Add, Picture, x15 y15 w66 h-1 +0x3 hwndhIcon gOpenGitHub, HICON:%hIconImg%
    Gui, Add, Text, x+7 y10, KeyPress OSD v%Version%
    Gui, Font
    Gui, Add, Text, y+2, Based on KeyPressOSD v2.2 by Tmplinshi.
    If (PrefsLargeFonts=1)
    {
       btnWid := btnWid + 50
       txtWid := txtWid + 105
       Gui, Font, s%LargeUIfontValue%
    }
    Gui, Add, Link, y+4, Developed by <a href="http://marius.sucan.ro">Marius Şucan</a> on AHK_H v1.1.28.
    Gui, Add, Text, x15 y+9, Freeware. Open source. For Windows XP, 7, 8, and 10.
    Gui, Add, Text, y+10 w%txtWid%, My gratitude to Drugwash for directly contributing with considerable improvements and code to this project.
    Gui, Add, Text, y+10 w%txtWid%, Many thanks to the great people from #ahk (irc.freenode.net), in particular to Phaleth, Tidbit and Saiapatsu. Special mentions to: Burque505 / Winter (for continued feedback) and Neuromancer.
    Gui, Add, Text, y+10 w%txtWid% Section, This application contains code from various entities. You can find more details in the source code.
    Gui, Font, Bold
    Gui, Add, Link, xp+25 y+10, To keep the development going, `n<a href="https://www.paypal.me/MariusSucan/15">please donate</a> or <a href="mailto:marius.sucan@gmail.com">send me feedback</a>.
    Gui, Add, Picture, x+5 yp+0 gDonateNow hp w-1 +0xE hwndhDonateBTN, HBITMAP:%hPaypalImg%
    UpdateInfo := checkUpdateExistsAbout()
    If UpdateInfo
       Gui, Add, Text, xs+0 y+20, %UpdateInfo%
    Gui, Font, Normal
    Gui, Add, Button, xs+0 y+20 w75 Default gCloseWindow, &Close
    Gui, Add, Button, x+5 w%btnWid% gOpenChangeLog vBtn1, Version &history
    Gui, Add, Text, x+8 hp +0x200, Released: %ReleaseDate%
    Gui, Show, AutoSize, About KeyPress OSD v%Version%
    verifySettingsWindowSize()
    ColorPickerHandles := hDonateBTN "," hIcon
    Sleep, 25
    SetTimer, miniUpdateChecker, -950, -20
}

OpenChangeLog() {
     GuiControl, Disable, btn1
     historyFileName := "keypress-osd-changelog.txt"
     historyFile := "Lib\" historyFileName
     historyFileURL := BaseURL historyFileName

     If (!FileExist(historyFile) || ForceDownloadExternalFiles=1)
     {
         SoundBeep
         UrlDownloadToFile, %historyFileURL%, %historyFile%
         Sleep, 4000
     }

     If FileExist(historyFile)
     {
         Sleep, 350
         Try FileRead, Contents, %historyFile%
         If !ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             If InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                 FileGetTime, fileDate, %historyFile%
                 timeNow := %A_Now%
                 EnvSub, timeNow, %fileDate%, Days

                 If (timeNow > 10)
                    MsgBox, Version history seems too old. Please use the Update now option from the tray menu. The file will be opened now.
                 Gui, SettingsGUIA: Destroy
                 Run, %historyFile%
             } Else
             {
                SoundBeep
                MsgBox, 4,, Corrupt file: keypress-osd-changelog.txt. The attempt to download it seems to have failed. To Try again file must be deleted. Do you agree?
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

LoadImage(fpath, t, idx:=0, sz:=0) {
; Function by Drugwash
; used for the images from AboutWindow()
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
    Return hImg
}

ActionListViewKBDs() {
  If (A_GuiEvent = "DoubleClick")
  {
      LV_GetText(KLIDselected, A_EventInfo, 5)  ; Get the text from the row's first field.
      IniRead, HKL, %LangFile%, %KLIDselected%, HKL, !
      If !InStr(HKL, "!")
      {
          CloseWindow()
          Sleep, 50
          Global LastTypedSince := 6000
          Global Tickcount_start := 6000
          Sleep, 150
          ChangeKBDGlobal(HKL)
          Sleep, 150
          SetTimer, ConstantKBDtimer, 250, 50
          Sleep, 150
      } Else SoundBeep, 300, 100
  }
}

ChangeKBDGlobal(HKL, INPUTLANGCHANGE:=0) { ; in all windows
; Function from [CLASS] Lyt - Keyboard layout (language) operation
; by Stealzy: https://autohotkey.com/boards/viewtopic.php?t=28258
    WinGet List, List
    Loop % List
         ChangeKBD(HKL, INPUTLANGCHANGE, List%A_Index%)
}

ChangeKBD(HKL, INPUTLANGCHANGE, hWnd) {
; Function from [CLASS] Lyt - Keyboard layout (language) operation
; by Stealzy: https://autohotkey.com/boards/viewtopic.php?t=28258
    PostMessage, 0x0050, % HKL ? "" : INPUTLANGCHANGE, % HKL ? HKL : "",
    , % "ahk_id" ((hWndOwn := DllCall("GetWindow", Ptr,hWnd, UInt,GW_OWNER:=4, Ptr)) ? hWndOwn : hWnd)
}

InvokeQuickMenu() {
    Menu, QuickMenu, Delete
    QuickSettingsMenu()
    Sleep, 10
    Menu, QuickMenu, Show
}

InstalledKBDsWindow() {
    If (PrefOpen=1)
    {
       SoundBeep, 300, 900
       WinActivate, KeyPress OSD
       Return
    }

    If (AnyWindowOpen=2)
    {
       AboutWindow()
       Return
    } Else If (AnyWindowOpen=1)
    {
       CloseWindow()
       Return
    }

    Global ListViewKBDs, btn100, RefreshBTN
    If (AutoDetectKBD=0 || !FileExist(LangFile))
    {
       IdentifyKBDlayout()
       Sleep, 50
    }
    AnyWindowOpen := 2
    IniRead, KBDsDetected, %LangFile%, Options, KBDsDetected, 1
    DLC := (KBDsDetected>10) ? 10 : StrLen(KBDsDetected)>0 ? KBDsDetected+1 : 5 
    IniRead, checkVersion, %IniFile%, SavedSettings, Version, 0
    If (checkVersion!=Version)
    {
      Sleep, 25
      INIaction(1, "ReleaseDate", "SavedSettings")
      INIaction(1, "Version", "SavedSettings")
      Sleep, 25
    }
    SettingsGUI()
    countList := 0
    txtWid := 370
    btnWid := 70
    If (PrefsLargeFonts=1)
    {
       txtWid := txtWid + 200
       btnWid := btnWid + 35
       Gui, Font, s%LargeUIfontValue%
    }
    kbdCode := SubStr(CurrentKBD, InStr(CurrentKBD, ". ")+2, 100)
    StringReplace, kbdDescript, CurrentKBD, %kbdCode%
    Gui, Font, Bold
    Gui, Add, Text, x15 y10, Current keyboard layout: %kbdCode%
    Gui, Add, Text, y+5 w%txtWid%, %kbdDescript%
    Gui, Font, Normal
    Gui, Add, ListView, y+10 w%txtWid% r%DLC% Grid Sort gActionListViewKBDs vListViewKBDs, Layout name|RTL|Dead keys|Support|KLID

    IniRead, KLIDlist, %LangFile%, Options, KLIDlist, -
    Loop, Parse, KLIDlist, CSV
    {
      IniRead, doNotList, %LangFile%, %A_LoopField%, doNotList, -
      If (StrLen(A_LoopField)<2 || doNotList=1)
         Continue
      IniRead, langFriendlySysName, %LangFile%, %A_LoopField%, name, -
      IniRead, isRTL, %LangFile%, %A_LoopField%, isRTL, -
      IniRead, hasDKs, %LangFile%, %A_LoopField%, hasDKs, -
      IniRead, hasThisIME, %LangFile%, %A_LoopField%, hasIME, -
      IniRead, isVertUp, %LangFile%, %A_LoopField%, isVertUp, -
      IniRead, KBDisUnsupported, %LangFile%, %A_LoopField%, KBDisUnsupported, -
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
            IniWrite, %langFriendlySysName%, %LangFile%, %A_LoopField%, name
      }
      loadedKLIDs .= "." A_LoopField "." newKLID
      If StrLen(langFriendlySysName)<2
      {
         langFriendlySysName := A_LoopField " (unrecognized) ³"
         note3 := 1
      }
      If RegExMatch(langFriendlySysName, "i)(input sys|input meth|ime 3.?|ime.?200.?)")
         hasThisIME := 1

      KBDisSupported := KBDisUnsupported=0 ? "Yes"
                      : isVertUp=1         ? "No *"
                      : hasThisIME=1       ? "No ²"
                      : isRTL=1            ? "Partial ¹"
                      : "?"
      KBDisSupported := isRTL=1 ? "Partial ¹" : KBDisSupported
      isRTL := isRTL=1 ? "Yes" : isRTL=0 ? "No" : isRTL
      hasDKs := hasDKs=1 ? "Yes" : hasDKs=0 ? "No" : hasDKs
      countList++
      LV_Add("", langFriendlySysName, isRTL, hasDKs, KBDisSupported, A_LoopField)
    }

    Loop
    {
      IniRead, IMEname, %LangFile%, IMEs, name%A_Index%, --
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
    Gui, Add, Button, y+15 w%btnWid% Default gCloseWindow, &Close
    Gui, Add, Button, x+5 w%btnWid% gOpenLastWindow, &Settings
    Gui, Add, Button, x+1 w20 gInvokeQuickMenu, %CSmo%
    If FileExist(LangFile)
       Gui, Add, Button, x+5 w%btnWid% gDeleteLangFile vRefreshBTN, &Refresh list
    Gui, Add, Text, x+10 hp +0x200, Layouts detected: %countList%
    Gui, Show, AutoSize, KeyPress OSD: Installed keyboard layouts
    If (KBDsDetected!=countList)
       IniWrite, %countList%, %LangFile%, Options, KBDsDetected
    verifySettingsWindowSize()
    Sleep, 25
    SetTimer, miniUpdateChecker, -950, -20
}

DeleteLangFile() {
  GuiControl, Disable, RefreshBTN
  FileDelete, %LangFile%
  Sleep, 10
  initLangFile()
  Sleep, 50
  InstalledKBDsWindow()
  Sleep, 10
}

;================================================================
; Section 8. Other functions:
; - Updater, file existence checks.
; - Load, verify and save settings
;================================================================

miniUpdateChecker() {
   Static execTimes
   If (execTimes>1)
      Return
   iniURL := BaseURL IniFile
   iniTMP := "updateInfo.ini"
   UrlDownloadToFile, %iniURL%, %iniTmp%
   Sleep, 700
   If FileExist(iniTmp)
   {
      IniRead, checkVersion, %iniTmp%, SavedSettings, Version
      IniRead, newDate, %iniTmp%, SavedSettings, ReleaseDate
      Sleep, 20
      IniDelete, %iniTmp%, ClipboardManager
      Sleep, 20
      IniWrite, %checkVersion%, %iniTmp%, SavedSettings, Version
      IniWrite, %newDate%, %iniTmp%, SavedSettings, ReleaseDate 
   }
   execTimes++
}

checkUpdateExistsAbout() {
  iniTMP := "updateInfo.ini"
  If FileExist(iniTMP)
  {
     IniRead, checkVersion, %iniTmp%, SavedSettings, Version
     IniRead, newDate, %iniTmp%, SavedSettings, ReleaseDate
  } Else Return 0

  If (checkVersion="ERROR")
  {
      Return 0
  } Else If (Version!=checkVersion)
  {
      msgReturn := "Version available online: "checkVersion ". Released: " newDate
      Return msgReturn
  } Else If (Version=checkVersion)
  {
      Return 0
  } Else Return 0
}

checkUpdateExists() {
  Static uknUpd := "Unable to determine if`na new version is available."
       , noUpd := "No new version is available."
       , forceUpd := "`n`nForce an update attempt?"
  iniURL := BaseURL IniFile
  iniTMP := "externINI.ini"
  UrlDownloadToFile, %iniURL%, %iniTmp%
  Sleep, 900
  Global LastTypedSince := A_TickCount
  If FileExist(iniTMP)
  {
     IniRead, checkVersion, %iniTmp%, SavedSettings, Version
     IniRead, newDate, %iniTmp%, SavedSettings, ReleaseDate
     Sleep, 25
     FileDelete, %iniTMP%
  } Else
  {
     Sleep, 25
     MsgBox, 4,, %uknUpd%%forceUpd%
     IfMsgBox, Yes
        Return 1
     Else Return 0
  }
  If (checkVersion="ERROR")
  {
     MsgBox, 4,, %uknUpd%%forceUpd%
     IfMsgBox, Yes
       Return 1
     Else Return 0
  } Else If (Version!=checkVersion)
  {
     ShowLongMsg("Version available online: v" checkVersion " - " newDate)
     Sleep, 1500
     Return 1
  } Else If (Version=checkVersion)
  {
     MsgBox, 4,, %noUpd%%forceUpd%
     IfMsgBox, Yes
       Return 1
     Else Return 0
  }
  Return 0
}

updateNow() {
     If (PrefOpen=1)
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
       checkFilesRan := 1
       IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
       Return
     }
     If (A_IsSuspended!=1)
        SuspendScript()
     Sleep, 150
     PrefOpen := 1
     mainFileBinary := (Is64BitExe(A_ScriptName)=1) ? "keypress-osd-x64.exe" : "keypress-osd-x32.exe"
     mainFileTmp := A_IsCompiled ? "new-keypress-osd.exe" : "temp-keypress-osd.ahk"
     mainFile := A_IsCompiled ? mainFileBinary : "keypress-osd.ahk"
     mainFileURL := BaseURL mainFile
     zipFile := "lib.zip"
     zipFileTmp := zipFile
     zipUrl := BaseURL zipFile

     ShowLongMsg("Updating files: 1 / 2. Please wait...")
     UrlDownloadToFile, %mainFileURL%, %mainFileTmp%
     Sleep, 3000

     If FileExist(mainFileTmp)
     {
         Try FileRead, Contents, %mainFileTmp%
         If !ErrorLevel
         {
            StringLeft, Contents, Contents, 31
            If InStr(contents, "; KeypressOSD.ahk - main file") || (InStr(contents, "MZ")=1)
            {
               ShowLongMsg("Updating files: Main code: OK")
               If (DoBackup || ForceUpdate)
               {
                  bkpDir := A_ScriptDir "\bkp-" A_Now
                  FileCreateDir, %bkpDir%
                  FileCopy, %ThisFile%, %bkpDir%
                  FileCopy, %IniFile%, %bkpDir%
               }
               If !A_IsCompiled
                  FileMove, %mainFileTmp%, %ThisFile%, 1
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
         Try FileRead, Contents, %zipFileTmp%
         If !ErrorLevel
         {
            StringLeft, Contents, Contents, 50
            If InStr(contents, "PK")
            {
               ShowLongMsg("Auxiliary files: OK")
               Extract2Folder(zipFileTmp,,, ((DoBackup || ForceUpdate) ? bkpDir : ""))
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
        MsgBox, 4, Error, Unable to download any file. `n Server is offline or no Internet connection. `n`nDo you want to Try again?
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
     checkFilesRan := 1
     IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
     If (completeSucces=1)
     {
        MsgBox, Update seems to be succesful. No errors detected. `nThe script will now reload.
        If (A_IsCompiled && ahkDownloaded=1)
        {
           Run, %binaryUpdater% %ThisFile%,, hide
           ExitApp
        } Else ReloadScript()
     }

     If (someErrors=1)
     {
        MsgBox, Errors occured during the update. `nThe script will now reload.
        If (A_IsCompiled && ahkDownloaded=1)
        {
           Run, %binaryUpdater% %ThisFile%,, Hide
           ExitApp
        } Else ReloadScript()
     }
}

checkSndFiles() {
    sndFiles := "caps,clickM,clickR,clicks,cups,deadkeys,firedkey,functionKeys,holdingKeys,keys,media,modfiredkey,mods,num0pad,num1pad,num2pad,num3pad,num4pad,num5pad,num6pad,num7pad,num8pad,num9pad,numApad,numpads,otherDistinctKeys,typingkeysArrowsD,typingkeysArrowsL,typingkeysArrowsR,typingkeysArrowsU,typingkeysBksp,typingkeysDel,typingkeysEnd,typingkeysEnter,typingkeysHome,typingkeysPgDn,typingkeysPgUp,typingkeysSpace"
    Loop, Parse, sndFiles, CSV
        soundFile%A_Index% := "sounds\" A_LoopField ".wav"

    MissingAudios := 0
    Loop, 38
    {
      If !FileExist(soundFile%A_Index%)
      {
         dlPackNow := 1
         MissingAudios := 1
      }
    } Until (MissingAudios=1)
    Return dlPackNow
}

VerifyNonCrucialFiles() {
     If (A_IsSuspended!=1)
     {
        GetTextExtentPoint("Initializing", FontName, FontSize, 1)
        ShowLongMsg("Initializing...")
        SetTimer, HideGUI, % -DisplayTime/2
     }

     bckpDlExtFiles := DownloadExternalFiles
     INIaction(0, "DownloadExternalFiles", "SavedSettings")
     DownloadExternalFiles := (DownloadExternalFiles=1 && bckpDlExtFiles=1) ? 1 : 0
     If (DownloadExternalFiles=0 || DownloadExternalFiles2=0)
     {
        If !A_isCompiled
           test := checkSndFiles()
        Return
     }

     If StrLen(A_GlobalStruct)<4   ; testing for AHK_H presence
        Return

     binaryUpdater := "updater.bat"
     binaryUpdaterURL := BaseURL binaryUpdater
     If (!FileExist(binaryUpdater) && A_IsCompiled)
     {
        FileInstall, updater.bat, updater.bat
        StringLeft, Contents, Contents, 50
        If !InStr(contents, "TIMEOUT /T")
           FileDelete, %binaryUpdater%
     }

    zipFile := "lib.zip"
    zipFileTmp := zipFile
    zipUrl := BaseURL zipFile
    SoundsZipFile := "keypress-sounds.zip"
    SoundsZipFileTmp := SoundsZipFile
    SoundsZipUrl := BaseURL SoundsZipFile
    historyFile := "Lib\keypress-osd-changelog.txt"
    beepersFile := "Lib\keypress-beeperz-functions.ahk"
    DeadKeysAidFile := "Lib\keypress-keystrokes-helper.ahk"
    ripplesFile := "Lib\keypress-mouse-ripples-functions.ahk"
    mouseFile := "Lib\keypress-mouse-functions.ahk"

    faqHtml := "Lib\help\faq.html"
    presentationHtml := "Lib\help\presentation.html"
    shortcutsHtml := "Lib\help\shortcuts.html"
    featuresHtml := "Lib\help\features.html"

    FilePack := "DeadKeysAidFile,beepersFile,ripplesFile,mouseFile,historyFile,faqHtml,presentationHtml,shortcutsHtml,featuresHtml"
    If !FileExist(A_ScriptDir "\Lib")
    {
        FileCreateDir, Lib
        If FileExist(A_ScriptDir "\keypress-files")
        {
           ErrorCount := MoveFilesAndFolders(A_ScriptDir "\keypress-files\*.*", A_ScriptDir "\Lib\")
           If (ErrorCount <> 0)
              MsgBox, The KeyPress files could not be moved to \Lib.
           Else
              reloadRequired := 1
        }
        FileCreateDir, Lib\Help
        If A_IsCompiled
        {
           FileInstall, Lib\Help\faq.html, %faqHtml%
           FileInstall, Lib\Help\presentation.html, %presentationHtml%
           FileInstall, Lib\Help\shortcuts.html, %shortcutsHtml%
           FileInstall, Lib\Help\features.html, %featuresHtml%
        }
    }

    IniRead, checkFilesRan, %IniFile%, TempSettings, checkFilesRan, 0
    IniRead, checkVersion, %IniFile%, SavedSettings, Version, 0
    If (Version!=checkVersion)
       checkFilesRan := 0

    If !A_IsCompiled
    {
      downloadSoundPackNow := checkSndFiles()
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
      checkFilesRan := 2
      IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
    }

    If (downloadPackNow=1 && checkFilesRan>2)
       Return

    If (downloadPackNow=1 && checkFilesRan<3 && !A_IsCompiled)
    {
       checkFilesRan := checkFilesRan+1
       IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2
       UrlDownloadToFile, %zipUrl%, %zipFileTmp%
       Sleep, 1500

       If FileExist(zipFileTmp)
       {
           Try FileRead, Contents, %zipFileTmp%
           If !ErrorLevel
           {
              StringLeft, Contents, Contents, 50
              If InStr(contents, "PK")
              {
                 Extract2Folder(zipFileTmp,,, ((DoBackup || ForceUpdate) ? bkpDir : ""))
                 Sleep, 1500
                 FileDelete, %zipFileTmp%
                 reloadRequired := 1
              } Else FileDelete, %zipFileTmp%
           }
       }
    }

    If (downloadSoundPackNow=1 && checkFilesRan<4)
    {
       checkFilesRan := checkFilesRan+1
       IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
       ShowLongMsg("Downloading files...")
       SetTimer, HideGUI, % -DisplayTime*2

       UrlDownloadToFile, %SoundsZipUrl%, %SoundsZipFileTmp%
       Sleep, 1500

       If FileExist(SoundsZipFileTmp)
       {
           Try FileRead, Contents, %SoundsZipFileTmp%
           If !ErrorLevel
           {
              StringLeft, Contents, Contents, 50
              If InStr(contents, "PK")
              {
                 Extract2Folder(SoundsZipFileTmp, "sounds",, ((DoBackup || ForceUpdate) ? bkpDir : ""))
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
           RegWrite, REG_SZ, %KPregEntry%, Initializing, No
           IniWrite, %checkFilesRan%, %IniFile%, TempSettings, checkFilesRan
           INIaction(1, "version", "SavedSettings")
           ReloadScript()
        }
    }
    If !A_isCompiled
       finalTest := checkSndFiles()
}

Is64BitExe(path) {
  DllCall("kernel32\GetBinaryType", "AStr", path, "UInt*", type)
  Return (6 = type)
}

MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = true) {
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires [v1.0.38+]
; because it uses FileMoveDir's mode 2.
    If (DoOverwrite = 1)
        DoOverwrite := 2  ; See FileMoveDir for description of mode 2 vs. 1.
    ; First move all the files (but not the folders):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now move all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        If ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
    }
    Return ErrorCount
}

Extract2Folder(Zip, Dest="", Filename="", bkp:="") {
; Function by Jess Harpur [2013] based on code by shajul (backup by Drugwash)
; https://autohotkey.com/board/topic/60706-native-zip-and-unzip-xpvista7-ahk-l/page-2

    SplitPath, Zip,, SourceFolder
    If !SourceFolder
        Zip := A_ScriptDir . "\" . Zip
    
    If !Dest
    {
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
    If ((DoBackup || ForceUpdate) && FileExist(bkp) && fso.FolderExists(Dest))
    {
       FileMoveDir, %MoveDest%, %bkp%\%dName%
       fso.CreateFolder(Dest)
    } Else If !fso.FolderExists(Dest)   ;  http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fso.CreateFolder(Dest)
       
    AppObj := ComObjCreate("Shell.Application")
    FolderObj := AppObj.Namespace(Zip)
    If Filename
    {
        FileObj := FolderObj.ParseName(Filename)
        AppObj.Namespace(Dest).CopyHere(FileObj, 4|16)
    } Else
    {
        FolderItemsObj := FolderObj.Items()
        AppObj.Namespace(Dest).CopyHere(FolderItemsObj, 4|16)
    }
}

INIaction(act, var, section) {
  varValue := %var%
  If (act=1)
     IniWrite, %varValue%, %IniFile%, %section%, %var%
  Else
     IniRead, %var%, %IniFile%, %section%, %var%, %varValue%
}

INIsettings(a) {
  FirstRun := 0
  If (a=1) ; a=1 means save into INI
  {
     INIaction(1, "DownloadExternalFiles", "SavedSettings")
     INIaction(1, "FirstRun", "SavedSettings")
     INIaction(1, "ReleaseDate", "SavedSettings")
     INIaction(1, "Version", "SavedSettings")
  }
  INIaction(a, "AutoDetectKBD", "SavedSettings")
  INIaction(a, "ConstantAutoDetect", "SavedSettings")
  INIaction(a, "DoBackup", "SavedSettings")
  INIaction(a, "IgnoreAdditionalKeys", "SavedSettings")
  INIaction(a, "IgnorekeysList", "SavedSettings")
  INIaction(a, "PrefsLargeFonts", "SavedSettings")
  INIaction(a, "SilentDetection", "SavedSettings")
  INIaction(a, "UseMUInames", "SavedSettings")
  INIaction(a, "SafeModeExec", "SavedSettings")

; Clipboard settings
  INIaction(a, "ClipMonitor", "ClipboardManager")
  INIaction(a, "DoNotPasteClippy", "ClipboardManager")
  INIaction(a, "EnableClipManager", "ClipboardManager")
  INIaction(a, "MaximumTextClips", "ClipboardManager")
  INIaction(a, "MaxRTFtextClipLen", "ClipboardManager")

; Typing related settings
  INIaction(a, "AlternateTypingMode", "TypingMode")
  INIaction(a, "AlternativeJumps", "TypingMode")
  INIaction(a, "AltHook2keysUser", "TypingMode")
  INIaction(a, "DisableTypingMode", "TypingMode")
  INIaction(a, "DisplayTimeTypingUser", "TypingMode")
  INIaction(a, "DoNotBindAltGrDeadKeys", "TypingMode")
  INIaction(a, "DoNotBindDeadKeys", "TypingMode")
  INIaction(a, "EnableAltGr", "TypingMode")
  INIaction(a, "EnableTypingHistory", "TypingMode")
  INIaction(a, "EnforceSluggishSynch", "TypingMode")
  INIaction(a, "EnterErasesLine", "TypingMode")
  INIaction(a, "EraseTextWinChange", "TypingMode")
  INIaction(a, "ExpandWords", "TypingMode")
  INIaction(a, "NoExpandAfterTuser", "TypingMode")
  INIaction(a, "MediateNavKeys", "TypingMode")
  INIaction(a, "OnlyTypingMode", "TypingMode")
  INIaction(a, "PasteOnClick", "TypingMode")
  INIaction(a, "PasteOSDcontent", "TypingMode")
  INIaction(a, "PgUDasHE", "TypingMode")
  INIaction(a, "ReturnToTypingUser", "TypingMode")
  INIaction(a, "SendJumpKeys", "TypingMode")
  INIaction(a, "ShiftDisableCaps", "TypingMode")
  INIaction(a, "ShowDeadKeys", "TypingMode")
  INIaction(a, "TypingDelaysScaleUser", "TypingMode")
  INIaction(a, "UpDownAsHE", "TypingMode")
  INIaction(a, "UpDownAsLR", "TypingMode")

; OSD settings
  INIaction(a, "DifferModifiers", "OSDprefs")
  INIaction(a, "HideAnnoyingKeys", "OSDprefs")
  INIaction(a, "ShowKeyCount", "OSDprefs")
  INIaction(a, "ShowKeyCountFired", "OSDprefs")
  INIaction(a, "ShowMouseButton", "OSDprefs")
  INIaction(a, "ShowPreview", "OSDprefs")
  INIaction(a, "ShowPrevKey", "OSDprefs")
  INIaction(a, "ShowPrevKeyDelay", "OSDprefs")
  INIaction(a, "ShowSingleKey", "OSDprefs")
  INIaction(a, "ShowSingleModifierKey", "OSDprefs")
  INIaction(a, "CapsColorHighlight", "OSDprefs")
  INIaction(a, "DisplayTimeUser", "OSDprefs")
  INIaction(a, "DragOSDmode", "OSDprefs")
  INIaction(a, "FontName", "OSDprefs")
  INIaction(a, "FontSize", "OSDprefs")
  INIaction(a, "GUIposition", "OSDprefs")
  INIaction(a, "GuiWidth", "OSDprefs")
  INIaction(a, "GuiXa", "OSDprefs")
  INIaction(a, "GuiXb", "OSDprefs")
  INIaction(a, "GuiYa", "OSDprefs")
  INIaction(a, "GuiYb", "OSDprefs")
  INIaction(a, "JumpHover", "OSDprefs")
  INIaction(a, "MaxGuiWidth", "OSDprefs")
  INIaction(a, "MouseOSDbehavior", "OSDprefs")
  INIaction(a, "NeverDisplayOSD", "OSDprefs")
  INIaction(a, "OSDalignment1", "OSDprefs")
  INIaction(a, "OSDalignment2", "OSDprefs")
  INIaction(a, "OSDautosize", "OSDprefs")
  INIaction(a, "OSDsizingFactor", "OSDprefs")
  INIaction(a, "OSDbgrColor", "OSDprefs")
  INIaction(a, "OSDborder", "OSDprefs")
  INIaction(a, "OSDshowLEDs", "OSDprefs")
  INIaction(a, "OSDtextColor", "OSDprefs")
  INIaction(a, "OutputOSDtoToolTip", "OSDprefs")
  INIaction(a, "TypingColorHighlight", "OSDprefs")

; Sounds settings
  INIaction(a, "AudioAlerts", "Sounds")
  INIaction(a, "BeepFiringKeys", "Sounds")
  INIaction(a, "BeepSentry", "Sounds")
  INIaction(a, "BeepsVolume", "Sounds")
  INIaction(a, "CapslockBeeper", "Sounds")
  INIaction(a, "DeadKeyBeeper", "Sounds")
  INIaction(a, "DTMFbeepers", "Sounds")
  INIaction(a, "KeyBeeper", "Sounds")
  INIaction(a, "ModBeeper", "Sounds")
  INIaction(a, "MouseBeeper", "Sounds")
  INIaction(a, "PrioritizeBeepers", "Sounds")
  INIaction(a, "SilentMode", "Sounds")
  INIaction(a, "ToggleKeysBeeper", "Sounds")
  INIaction(a, "TypingBeepers", "Sounds")

; Mouse settings
  INIaction(a, "MouseVclickScaleUser", "Mouse")
  INIaction(a, "ShowMouseHalo", "Mouse")
  INIaction(a, "ShowMouseIdle", "Mouse")
  INIaction(a, "ShowMouseVclick", "Mouse")
  INIaction(a, "ShowMouseRipples", "Mouse")
  INIaction(a, "ShowCaretHalo", "Mouse")
  INIaction(a, "MouseHaloAlpha", "Mouse")
  INIaction(a, "MouseHaloColor", "Mouse")
  INIaction(a, "MouseHaloRadius", "Mouse")
  INIaction(a, "MouseIdleAfter", "Mouse")
  INIaction(a, "MouseIdleAlpha", "Mouse")
  INIaction(a, "MouseIdleColor", "Mouse")
  INIaction(a, "MouseIdleRadius", "Mouse")
  INIaction(a, "MouseIdleFlash", "Mouse")
  INIaction(a, "MouseVclickAlpha", "Mouse")
  INIaction(a, "MouseVclickColor", "Mouse")
  INIaction(a, "MouseRippleMaxSize", "Mouse")
  INIaction(a, "MouseRippleThickness", "Mouse")
  INIaction(a, "MouseRippleFrequency", "Mouse")
  INIaction(a, "MouseRippleOpacity", "Mouse")
  INIaction(a, "MouseRippleWbtnColor", "Mouse")
  INIaction(a, "MouseRippleLbtnColor", "Mouse")
  INIaction(a, "MouseRippleRbtnColor", "Mouse")
  INIaction(a, "MouseRippleMbtnColor", "Mouse")
  INIaction(a, "CaretHaloAlpha", "Mouse")
  INIaction(a, "CaretHaloColor", "Mouse")
  INIaction(a, "CaretHaloHeight", "Mouse")
  INIaction(a, "CaretHaloWidth", "Mouse")
  INIaction(a, "CaretHaloFlash", "Mouse")
  INIaction(a, "CaretHaloThick", "Mouse")
  INIaction(a, "CaretHaloShape", "Mouse")

; Hotkey settings
  INIaction(a, "GlobalKBDhotkeys", "Hotkeys")
  INIaction(a, "KBDaltTypeMode", "Hotkeys")
  INIaction(a, "KBDpasteOSDcnt1", "Hotkeys")
  INIaction(a, "KBDpasteOSDcnt2", "Hotkeys")
  INIaction(a, "KBDsynchApp1", "Hotkeys")
  INIaction(a, "KBDsynchApp2", "Hotkeys")
  INIaction(a, "KBDCapText", "Hotkeys")
  INIaction(a, "KBDsuspend", "Hotkeys")
  INIaction(a, "KBDTglNeverOSD", "Hotkeys")
  INIaction(a, "KBDTglSilence", "Hotkeys")
  INIaction(a, "KBDTglPosition", "Hotkeys")
  INIaction(a, "KBDidLangNow", "Hotkeys")
  INIaction(a, "KBDReload", "Hotkeys")
  INIaction(a, "KBDclippyMenu", "Hotkeys")

  If (a=0) ; a=0 means to load from INI
  {
     CheckSettings()
     GuiX := (GUIposition=1) ? GuiXa : GuiXb
     GuiY := (GUIposition=1) ? GuiYa : GuiYb
  }
}

BinaryVar(ByRef givenVar, defy) {
    givenVar := (Round(givenVar)=0 || Round(givenVar)=1) ? Round(givenVar) : defy
}

HexyVar(ByRef givenVar, defy) {
   If (givenVar ~= "[^[:xdigit:]]") || (StrLen(givenVar)!=6)
      givenVar := defy
}

MinMaxVar(ByRef givenVar, miny, maxy, defy) {
    If givenVar is not digit
    {
       givenVar := defy
       Return
    }
    givenVar := (Round(givenVar) < miny) ? miny : Round(givenVar)
    givenVar := (Round(givenVar) > maxy) ? maxy : Round(givenVar)
}

CheckSettings() {

; verify check boxes
    BinaryVar(AlternateTypingMode, 1)
    BinaryVar(AlternativeJumps, 0)
    BinaryVar(AltHook2keysUser, 1)
    BinaryVar(AudioAlerts, 0)
    BinaryVar(AutoDetectKBD, 1)
    BinaryVar(BeepFiringKeys, 0)
    BinaryVar(BeepSentry, 0)
    BinaryVar(CapslockBeeper, 1)
    BinaryVar(CaretHaloFlash, 1)
    BinaryVar(ClipMonitor, 1)
    BinaryVar(ConstantAutoDetect, 1)
    BinaryVar(DeadKeyBeeper, 1)
    BinaryVar(DifferModifiers, 0)
    BinaryVar(DisableTypingMode, 1)
    BinaryVar(DoBackup, 0)
    BinaryVar(DoNotBindAltGrDeadKeys, 0)
    BinaryVar(DoNotBindDeadKeys, 0)
    BinaryVar(DoNotPasteClippy, 0)
    BinaryVar(DragOSDmode, 0)
    BinaryVar(DTMFbeepers, 0)
    BinaryVar(EnableAltGr, 1)
    BinaryVar(EnableClipManager, 0)
    BinaryVar(EnableTypingHistory, 0)
    BinaryVar(EnforceSluggishSynch, 0)
    BinaryVar(EraseTextWinChange, 0)
    BinaryVar(ExpandWords, 0)
    BinaryVar(GUIposition, 1)
    BinaryVar(HideAnnoyingKeys, 1)
    BinaryVar(IgnoreAdditionalKeys, 0)
    BinaryVar(JumpHover, 0)
    BinaryVar(KeyBeeper, 0)
    BinaryVar(GlobalKBDhotkeys, 1)
    BinaryVar(MediateNavKeys, 0)
    BinaryVar(ModBeeper, 0)
    BinaryVar(MouseBeeper, 0)
    BinaryVar(MouseIdleFlash, 1)
    BinaryVar(NeverDisplayOSD, 0)
    BinaryVar(OSDautosize, 1)
    BinaryVar(OSDborder, 0)
    BinaryVar(OSDshowLEDs, 1)
    BinaryVar(OutputOSDtoToolTip, 0)
    BinaryVar(PasteOnClick, 1)
    BinaryVar(PasteOSDcontent,  0)
    BinaryVar(PgUDasHE, 0)
    BinaryVar(PrefsLargeFonts, 0)
    BinaryVar(PrioritizeBeepers, 0)
    BinaryVar(SendJumpKeys, 0)
    BinaryVar(ShiftDisableCaps, 1)
    BinaryVar(ShowCaretHalo, 0)
    BinaryVar(ShowDeadKeys, 0)
    BinaryVar(ShowKeyCount, 1)
    BinaryVar(ShowKeyCountFired, 1)
    BinaryVar(ShowMouseButton, 1)
    BinaryVar(ShowMouseHalo, 0)
    BinaryVar(ShowMouseIdle, 0)
    BinaryVar(ShowMouseRipples, 0)
    BinaryVar(ShowMouseVclick, 0)
    BinaryVar(ShowPrevKey, 1)
    BinaryVar(ShowSingleKey, 1)
    BinaryVar(ShowSingleModifierKey, 1)
    BinaryVar(SilentDetection, 1)
    BinaryVar(SilentMode, 0)
    BinaryVar(ToggleKeysBeeper, 1)
    BinaryVar(TypingBeepers, 0)
    BinaryVar(UpDownAsHE, 0)
    BinaryVar(UpDownAsLR, 0)
    BinaryVar(UseMUInames, 1)
    CaretHaloShape := (CaretHaloShape=1 || CaretHaloShape=2) ? CaretHaloShape : 2
    MouseOSDbehavior := (MouseOSDbehavior=1 || MouseOSDbehavior=2 || MouseOSDbehavior=3) ? MouseOSDbehavior : 1
    OSDalignment1 := (OSDalignment1=1 || OSDalignment1=2 || OSDalignment1=3) ? OSDalignment1 : 1
    OSDalignment2 := (OSDalignment2=1 || OSDalignment2=2 || OSDalignment2=3) ? OSDalignment2 : 3

; correct contradictory settings

    OSDbehaviorConditions()
    If (A_OSVersion="WIN_XP")
       BeepSentry := 0

    If (UpDownAsHE=1 && UpDownAsLR=1)
       UpDownAsLR := 0

    If (ShowMouseVclick=1 && ShowMouseRipples=1)
       ShowMouseVclick := 0

    If (ShowSingleKey=0)
       DisableTypingMode := 1

    If (DisableTypingMode=1)
    {
       OnlyTypingMode := 0
       MediateNavKeys := 0
       SendJumpKeys := 0
       EnforceSluggishSynch := 0
    }

    If (OnlyTypingMode=1 && EnterErasesLine=0)
    {
       SendJumpKeys := 0
       MediateNavKeys := 0
       EnableTypingHistory := 0
    }

    If (DisableTypingMode=0 && OnlyTypingMode=0)
       EnterErasesLine := 1

    If (AutoDetectKBD=0)
       ConstantAutoDetect := 0

; verify numeric values: min, max and default values
    MinMaxVar(BeepsVolume, 5, 99, 60)
    MinMaxVar(CaretHaloAlpha, 20, 240, 175)
    MinMaxVar(CaretHaloHeight, 10, 350, 70)
    MinMaxVar(CaretHaloWidth, 10, 350, 15)
    MinMaxVar(CaretHaloThick, 0, 60, 0)
    MinMaxVar(DisplayTimeTypingUser, 3, 99, 10)
    MinMaxVar(DisplayTimeUser, 1, 99, 3)
    MinMaxVar(FontSize, 6, 300, 20)
    MinMaxVar(GuiWidth, 70, 2995, 350)
    MinMaxVar(GuiWidth, FontSize*2, 2995, 350)
    MinMaxVar(GuiXa, -9999, 9999, 40)
    MinMaxVar(GuiXb, -9999, 9999, 700)
    MinMaxVar(GuiYa, -9999, 9999, 250)
    MinMaxVar(GuiYb, -9999, 9999, 500)
    MinMaxVar(MaxGuiWidth, 90, 2995, 500)
    MinMaxVar(MaxGuiWidth, FontSize*2, 2995, 500)
    MinMaxVar(MaximumTextClips, 3, 31, 10)
    MinMaxVar(MaxRTFtextClipLen, 10000, 250500, 60000)
    MinMaxVar(MouseHaloAlpha, 20, 240, 130)
    MinMaxVar(MouseHaloRadius, 25, 999, 85)
    MinMaxVar(MouseIdleAfter, 3, 999, 10)
    MinMaxVar(MouseIdleAlpha, 20, 240, 70)
    MinMaxVar(MouseIdleRadius, 25, 999, 130)
    MinMaxVar(MouseRippleFrequency, 3, 40, 20)
    MinMaxVar(MouseRippleMaxSize, 130, 400, 155)
    MinMaxVar(MouseRippleOpacity, 20, 240, 160)
    MinMaxVar(MouseRippleThickness, 5, 50, 10)
    MinMaxVar(MouseVclickAlpha, 20, 240, 150)
    MinMaxVar(MouseVclickScaleUser, 6, 70, 10)
    MinMaxVar(NoExpandAfterTuser, 1, 30, 4)
    MinMaxVar(OSDsizingFactor, 20, 400, calcOSDresizeFactor())
    MinMaxVar(ReturnToTypingUser, DisplayTimeTypingUser+1, 99, 20)
    MinMaxVar(ShowPrevKeyDelay, 100, 999, 300)
    MinMaxVar(TypingDelaysScaleUser, 2, 40, 7)
    CaretHaloThick := (CaretHaloThick<5) ? 0 : CaretHaloThick
    CaretHaloThick := (CaretHaloThick > Round(CaretHaloHeight/2-1)) ? Round(CaretHaloHeight/2-1) : Round(CaretHaloThick)
    CaretHaloThick := (CaretHaloThick > Round(CaretHaloWidth/2-1)) ? Round(CaretHaloWidth/2-1) : Round(CaretHaloThick)

; verify HEX values

   HexyVar(CapsColorHighlight, "88AAff")
   HexyVar(CaretHaloColor, "BBAA99")
   HexyVar(MouseHaloColor, "888888")
   HexyVar(MouseIdleColor, "333333")
   HexyVar(MouseRippleLbtnColor, "ff2211")
   HexyVar(MouseRippleMbtnColor, "33cc33")
   HexyVar(MouseRippleRbtnColor, "4499ff")
   HexyVar(MouseRippleWbtnColor, "33cc33")
   HexyVar(MouseVclickColor, "555555")
   HexyVar(OSDbgrColor, "131209")
   HexyVar(OSDtextColor, "FFFEFA")
   HexyVar(TypingColorHighlight, "12E217")

   FontName := (StrLen(FontName)>2) ? FontName
             : (A_OSVersion!="WIN_XP") ? "Arial"
             : FileExist(A_WinDir "\Fonts\ARIALUNI.TTF") ? "Arial Unicode MS" : "Arial"
}

CheckIfRunningWindow() {
  Sleep, 10
  WinGet, otherKP, ID, KeyPressOSDwin
  If otherKP not in %OSDhandles%
     KillScript(0)
}

CheckIfRunning(ForceIT:=0) {
    RegRead, PrefOpen2, %KPregEntry%, PrefOpen
    If (PrefOpen2=1 || ForceIT=1)
    {
        SoundBeep, 300, 900
        PrefOpen := 0
        RegWrite, REG_SZ, %KPregEntry%, PrefOpen, %PrefOpen%
        MsgBox, 4,, The app seems to be running `nor did not close properly. Continue?
        IfMsgBox, Yes
          Return True
        ExitApp
    } Else SetTimer, CheckIfRunningWindow, -2000, 500
}

;================================================================
; Section 9. Functions not written by Marius Sucan.
; Here, I placed only the functions I was unable to decide
; where to place within the code structure. Yet, they had 
; one thing in common: written by other people.
;
; : Maestrith (color picker functions), Alguimist (font list
; generator), VxE (GuiGetSize), Sean (GetTextExtentPoint),
; Helgef (toUnicodeEx), Jess Harpur (Extract2Folder),
; Tidbit (String Things), jballi (Font Library 3), Lexikos and others.
;
; Please note, some of the functions borrowed may or may not
; be modified/adapted/transformed by Marius Șucan or other people.
;================================================================

;================================================================
; Functions by Drugwash. Direct contribuitor to this script. Many thanks!
; ===============================================================

FindRes(lib, res, type) {
; based on AHK_H ResGet.ahk script and MSDN info [from Drugwash]
  If !lib
    hM := 0  ; current module
  Else If !hM := DllCall("kernel32\GetModuleHandleW", "Str", lib, "Ptr")
    If !hL := hM := DllCall("kernel32\LoadLibraryW", "Str", lib, "Ptr")
      Return
  If !hR := DllCall("kernel32\FindResourceW"
    , "Ptr" , hM
    , "Str" , res
    , "Str" , type
    , "Ptr")
  OutputDebug, % FormatMessage(A_ThisFunc "(" lib ", " res ", " type ", " l ")", A_LastError)
  If hL
    DllCall("kernel32\FreeLibrary", "Ptr", hL)
  Return hR
}

GetRes(ByRef bin, lib, res, type) {
  If !lib
    hM := 0  ; current module
  Else If !hM := DllCall("kernel32\GetModuleHandleW", "Str", lib, "Ptr")
    If !hL := hM := DllCall("kernel32\LoadLibraryW", "Str", lib, "Ptr")
      Return
  If !hR := DllCall("kernel32\FindResourceW"
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
    DllCall("kernel32\FreeResource", "Ptr" , hD)
    If hL
      DllCall("kernel32\FreeLibrary", "Ptr", hL)
  Return
  }
  VarSetCapacity(bin, 0), VarSetCapacity(bin, sz, 0)
  DllCall("ntdll\RtlMoveMemory", "Ptr", &bin, "Ptr", hB, "UInt", sz)
  DllCall("kernel32\FreeResource", "Ptr" , hD)
  If hL
    DllCall("kernel32\FreeLibrary", "Ptr", hL)
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

InitAHKhThreads() {
    Static func2exec := "ahkThread"
    If IsFunc(func2exec)
    {
      If A_IsCompiled
      {
         If GetRes(data, 0, "KEYPRESS-MOUSE-FUNCTIONS.AHK", "LIB")
         {
            MouseFuncThread := %func2exec%(StrGet(&data))
            While !IsMouseFile := MouseFuncThread.ahkgetvar.IsMouseFile
                  Sleep, 10
         }
         If GetRes(data, 0, "KEYPRESS-MOUSE-RIPPLES-FUNCTIONS.AHK", "LIB")
         {
            MouseRipplesThread := %func2exec%(StrGet(&data))
            While !IsRipplesFile := MouseRipplesThread.ahkgetvar.IsRipplesFile
                  Sleep, 10
         }
         If GetRes(data, 0, "KEYPRESS-BEEPERZ-FUNCTIONS.AHK", "LIB")
         {
            SoundsThread := %func2exec%(StrGet(&data))
            While !IsSoundsFile := SoundsThread.ahkgetvar.IsSoundsFile
                  Sleep, 10
            SoundsThread.ahkassign("beepFromRes", A_IsCompiled ? "Y" : 0)
         }

         If (DisableTypingMode=0 && ShowSingleKey=1)
         {
            If FindRes(0, "KEYPRESS-KEYSTROKES-HELPER.AHK", "LIB")
            {
              IsKeystrokesFile := 1
              If AlternativeHook2keys=1
              {
                  GetRes(data, 0, "KEYPRESS-KEYSTROKES-HELPER.AHK", "LIB")
                  KeyStrokesThread := %func2exec%(StrGet(&data))
                  While !IsKeystrokesFile := KeyStrokesThread.ahkgetvar.IsKeystrokesFile
                        Sleep, 10
                  OnMessage(0x4a, "KeyStrokeReceiver")  ; 0x4a is WM_COPYDATA
              }
            }
         }
         VarSetCapacity(data, 0)
      } Else
      {
          IsMouseFile := FileExist("Lib\keypress-mouse-functions.ahk")
          IsRipplesFile := FileExist("Lib\keypress-mouse-ripples-functions.ahk")
          IsSoundsFile := FileExist("Lib\keypress-beeperz-functions.ahk")
          IsKeystrokesFile := FileExist("Lib\keypress-keystrokes-helper.ahk")
          MouseFuncThread := %func2exec%(" #Include *i Lib\keypress-mouse-functions.ahk ")
          MouseRipplesThread := %func2exec%(" #Include *i Lib\keypress-mouse-ripples-functions.ahk ")
          SoundsThread := %func2exec%(" #Include *i Lib\keypress-beeperz-functions.ahk ")
          If (AlternativeHook2keys=1 && DisableTypingMode=0 && ShowSingleKey=1 && IsKeystrokesFile)
          {
              KeyStrokesThread := %func2exec%(" #Include *i Lib\keypress-keystrokes-helper.ahk ")
              OnMessage(0x4a, "KeyStrokeReceiver")  ; 0x4a is WM_COPYDATA
          }
      }
      Sleep, 10
      If IsRipplesFile
         SendVarsRipplesAHKthread(1)
      Sleep, 10
      If IsMouseFile
         SendVarsMouseAHKthread(1)
      Sleep, 10
      If IsSoundsFile
         SendVarsSoundsAHKthread()
    } Else (NoAhkH := 1)
}

Cleanup() {
    OnMessage(0x4a, "")
    OnMessage(0x200, "")
    OnMessage(0x102, "")
    OnMessage(0x103, "")
    Fnt_DeleteFont(hFont)
    func2exec := "ahkThread_Free"
    If (NoAhkH!=1 || SafeModeExec!=1)
    {
       If IsMouseFile
       {
          MouseFuncThread.ahkFunction["ToggleMouseTimerz", "Y"] ; force all timers off
          %func2exec%(MouseFuncThread) ; Should call MouseClose() in thread's OnExit
          MouseFuncThread := ""
       }

       If IsRipplesFile
       {
          %func2exec%(MouseRipplesThread) ; Should call MouseRippleClose() in thread's OnExit, otherwise bad things happen!
          MouseRipplesThread := ""
       }

       If IsSoundsFile
       {
          %func2exec%(SoundsThread)
          SoundsThread := ""
       }

       If IsKeystrokesFile
       {
          %func2exec%(KeyStrokesThread)
          KeyStrokesThread := ""
       }
    }
    Sleep, 10
    a := "Acc_Init"
    If IsFunc(a)
       %a%(1)
    DllCall("kernel32\FreeLibrary", "Ptr", hWinMM)
    If (SafeModeExec!=1)
       SetVolume(VolL, VolR)

    If hMutex
    {
       r := DllCall("kernel32\ReleaseMutex", "Ptr", hMutex)
       rr := DllCall("kernel32\CloseHandle", "Ptr", hMutex)
    }
}
; ------------------------------------------------------------- ; from Drugwash

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
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hControl%
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

dummy() {
    Return
}

#SPACE::
Return

CheckAcc:
  #Include *i %A_ScriptDir%\Lib\keypress-acc-viewer-functions.ahk
  #Include *i %A_ScriptDir%\Lib\UIA_Interface.ahk
  If (SafeModeExec!=1)
  {
     Sleep, 1
     addScript("ahkThread_Free(deleteME)",0)   ; comment/delete this line to execute this script with AHK_L
  }
Return

