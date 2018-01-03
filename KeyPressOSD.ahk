; KeypressOSD.ahk
;--------------------------------------------------------------------------------------------------------------------------
;
;by Saiapatsu from irc.frteenode.net #ahk
; ChangeLog : v2.54 (2017-09-21) - Scrolls through n recently typed characters instead of just the latest word
;             v2.53 (2017-09-21) - Case change effect limited to the 95 letters only.
;             v2.52 (2017-09-21) - Now supports backspace. Commented out CapsLock beeper.
;             v2.51 (2017-09-21) - Changed labels to functions, added ToolWindow style to window, changed DisplayTime
;                                  calculation, made it show last word typed, hid spacebar presses
;                                  todo: make Shift look less ugly
;
; by Marius Sucan (robodesign)
;             v2.50 (2017-09-20) - Changed the OSD positioning and sizing. Now it is always fixed in a specific place. Capslock beeper.
;
;by tmplinshi from https://autohotkey.com/boards/viewtopic.php?f=6&t=225
;             v2.22 (2017-02-25) - Now pressing same combination keys continuously more than 2 times,
;                                  for example press Ctrl+V 3 times, will displayed as "Ctrl + v (3)"
;             v2.21 (2017-02-24) - Fixed LWin/RWin not poping up start menu
;             v2.20 (2017-02-24) - Added displaying continuous-pressed combination keys.
;                                  e.g.: With CTRL key held down, pressing K and U continuously will shown as "Ctrl + k, u"
;             v2.10 (2017-01-22) - Added ShowStickyModKeyCount option
;             v2.09 (2017-01-22) - Added ShowModifierKeyCount option
;             v2.08 (2017-01-19) - Fixed a bug
;             v2.07 (2017-01-19) - Added ShowSingleModifierKey option (default is True)
;             v2.06 (2016-11-23) - Added more keys. Thanks to SashaChernykh.
;             v2.05 (2016-10-01) - Fixed not detecting "Ctrl + ScrollLock/NumLock/Pause". Thanks to lexikos.
;             v2.04 (2016-10-01) - Added NumpadDot and AppsKey
;             v2.03 (2016-09-17) - Added displaying "Double-Click" of the left mouse button.
;             v2.02 (2016-09-16) - Added displaying mouse button, and 3 settings (ShowMouseButton, FontSize, GuiHeight)
;             v2.01 (2016-09-11) - Display non english keyboard layout characters when combine with modifer keys.
;             v2.00 (2016-09-01) - Removed the "Fade out" effect because of its buggy.
;                                - Added support for non english keyboard layout.
;                                - Added GuiPosition setting.
;             v1.00 (2013-10-11) - First release.
;--------------------------------------------------------------------------------------------------------------------------

#SingleInstance force
#NoEnv
SetBatchLines, -1
ListLines, Off

; Settings
    global TransN                := 190      ; 0~255
    global ShowSingleKey         := true
    global ShowMouseButton       := true
    global ShowSingleModifierKey := true
    global ShowModifierKeyCount  := true
    global ShowStickyModKeyCount := true  ; for sticky keys
    global DisplayTime           := 2000  ; In milliseconds
    global GuiWidth              := 300
    global GuiHeight             := 52
    global GuiX                  := 50
    global GuiY                  := 250
    global FontSize              := 22
    global NumLetters            := 16 ; amount of recently typed letters to display

global typed := ""
global visible := 0
global prefixed := 0 ; hack, used to determine if last keypress had a modifier

CreateGUI()
CreateHotkey()

TypedLetter(key)
{
    isTyping := 1 ; testing
    return typed := SubStr(typed key, -NumLetters)
}

OnKeyPressed()
{
    try {
        key := GetKeyStr()
        typed := "" ; concerning TypedLetter(" ")
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
    }
}

OnLetterPressed()
{
    try {
        key := GetKeyStr(1) ;consider it a letter
        if prefixed
        {
            ShowHotkey(key)
        } else {
            TypedLetter(key)
            ShowHotkey(typed)
        }
        SetTimer, HideGUI, % -DisplayTime
    }
}

OnSpacePressed()
{
    try {
        if (visible)
            TypedLetter(" ")
        else {
            ShowHotkey("Space")
        }
        SetTimer, HideGUI, % -DisplayTime
    }
}

OnBspPressed()
{
    try {
        if typed
        {
            typed := SubStr(typed, 1, StrLen(typed) - 1)
            ShowHotkey(typed)
        } else
            ShowHotkey("Backspace")
        SetTimer, HideGUI, % -DisplayTime
    }
}

OnKeyUp()
{
}

_OnKeyUp()
{
    tickcount_start := A_TickCount

    ; if you want beeps when capslock is on 
    GetKeyState, CapsState, CapsLock, T
    If CapsState = D
    {
      sleep, 50
      soundbeep, 650, 250
    }
    else {
    }

}

; ===================================================================================
CreateGUI() {
    global

    Gui, +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow +E0x20
    Gui, Margin, 0, 0
    Gui, Color, Black
    Gui, Font, cWhite s%FontSize% bold, Arial
    Gui, Add, Text, vHotkeyText left x10 y10 -wrap

    WinSet, Transparent, %TransN%
}

CreateHotkey() {
    Loop, 95
    {
        k := Chr(A_Index + 31)
        if k not in 96,39,94

        ; k := (k = " ") ? "Space" : k

        if (k = " ")
        {
            Hotkey, % "~*Space", OnSpacePressed
            Hotkey, % "~*Space Up", _OnKeyUp
        } else {
            Hotkey, % "~*" k, OnLetterPressed
            Hotkey, % "~*" k " Up", _OnKeyUp
        }
    }

    Hotkey, % "~*Backspace", OnBspPressed

    Loop, 24 ; F1-F24
    {
        Hotkey, % "~*F" A_Index, OnKeyPressed
        Hotkey, % "~*F" A_Index " Up", _OnKeyUp
    }

    Loop, 10 ; Numpad0 - Numpad9
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnKeyPressed
        Hotkey, % "~*Numpad" A_Index - 1 " Up", _OnKeyUp
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|Tab|Enter|Esc"
               . "|Del|Insert|Home|End|PgUp|PgDn|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|Pause|sc145|sc146|sc046|sc123"
    Loop, parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed
        Hotkey, % "~*" A_LoopField " Up", _OnKeyUp
    }

    If ShowMouseButton {
        Loop, Parse, % "LButton|MButton|RButton", |
            Hotkey, % "~*" A_LoopField, OnKeyPressed
    }

    for i, mod in ["Ctrl", "Alt"] { ;"Shift", 
        Hotkey, % "~*" mod, OnKeyPressed
        Hotkey, % "~*" mod " Up", OnKeyUp
    }
    for i, mod in ["LWin", "RWin"]
        Hotkey, % "~*" mod, OnKeyPressed
}

ShowHotkey(HotkeyStr) {
     GuiControl,     , HotkeyText, %HotkeyStr%

    {
        visible := 1
        GuiControl, Move, HotkeyText, w%GuiWidth% left
        Gui, Show, NoActivate x%GuiX% y%GuiY% w%GuiWidth% h%GuiHeight%
    }
}

GetKeyStr(letter := 0) {
    static modifiers := ["Ctrl", "Alt", "Shift", "LWin", "RWin"]
    static repeatCount := 1

    for i, mod in modifiers {
        ;If any mod but shift, go
        ;If shift, check if not letter
        if (mod = "Shift" ? (!letter && GetKeyState(mod)) : GetKeyState(mod))
            prefix .= mod " + "
    }

    if (!prefix && !ShowSingleKey)
        throw

    key := SubStr(A_ThisHotkey, 3)

    if (key ~= "i)^(Ctrl|Shift|Alt|LWin|RWin)$") {
        if !ShowSingleModifierKey {
            throw
        }
        key := ""
        prefix := RTrim(prefix, "+ ")

        if ShowModifierKeyCount {
            if !InStr(prefix, "+") && IsDoubleClickEx() {
                if (A_ThisHotKey != A_PriorHotKey) || ShowStickyModKeyCount {
                    if (++repeatCount > 1) {
                        prefix .= " ( * " repeatCount " )"
                    }
                } else {
                    repeatCount := 0
                }
            } else {
                repeatCount := 1
            }
        }
    } else {
        if ( StrLen(key) = 1 ) {
            key := GetKeyChar(key, "A")
        } else if ( SubStr(key, 1, 2) = "sc" ) {
            key := SpecialSC(key)
        } else if (key = "LButton") && IsDoubleClick() {
            key := "Double-Click"
        }
        _key := (key = "Double-Click") ? "LButton" : key

        static pre_prefix, pre_key, keyCount := 1
        global tickcount_start
        if (prefix && pre_prefix) && (A_TickCount-tickcount_start < 350) {
            if (prefix != pre_prefix) {
                result := pre_prefix pre_key ", " prefix key
            } else {
                keyCount := (key=pre_key) ? (keyCount+1) : 1
                key := (keyCount>1) ? (key " (" keyCount ")") : (key)
            }
        } else {
            keyCount := 1
        }

        pre_prefix := prefix
        pre_key := _key

        repeatCount := 1
    }
    prefixed := prefix ? 1 : 0
    ;handle capslock and shift interaction unless we've got modifier keys
    return result ? result : (prefix ? prefix . key : (letter && (GetKeyState("CapsLock", "T") ^ GetKeyState("Shift", "P")) ? StrUpper(key) : key))
}

StrUpper(str)
{
    StringUpper, str, str
    return str
}

SpecialSC(sc) {
    static k := {sc046: "ScrollLock", sc145: "NumLock", sc146: "Pause", sc123: "Genius LuxeMate Scroll"}
    return k[sc]
}

; by Lexikos -- https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236
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

IsDoubleClick(MSec = 300) {
    Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < MSec)
}

IsDoubleClickEx(MSec = 300) {
    preHotkey := RegExReplace(A_PriorHotkey, "i) Up$")
    Return (A_ThisHotKey = preHotkey) && (A_TimeSincePriorHotkey < MSec)
}

HideGUI() {
    visible := 0
    Gui, Hide
}



