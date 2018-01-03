; KeypressOSD.ahk - mouse features file
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

global VisualMouseClicks     := 0     ; shows visual indicators for different mouse clicks
 , ClickScaleUser        := 10
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , IdleMouseAlpha        := 70    ; from 0 to 255
 , LowVolBeeps           := 1
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloRadius       := 35
 , MouseIdleAfter        := 10    ; in seconds
 , MouseIdleRadius       := 40
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , IniFile               := "keypress-osd.ini"
 , visible := 0
 , ClickScale := ClickScaleUser/10
 , MouseClickCounter := 0
 , ScriptelSuspendel := 0
 , SilentMode        := 0

  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, ClickScaleUser, %inifile%, SavedSettings, ClickScaleUser, %ClickScaleUser%
  IniRead, SilentMode, %inifile%, SavedSettings, SilentMode, %SilentMode%
  IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
  IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
  IniRead, MouseHaloAlpha, %inifile%, SavedSettings, MouseHaloAlpha, %MouseHaloAlpha%
  IniRead, MouseHaloColor, %inifile%, SavedSettings, MouseHaloColor, %MouseHaloColor%
  IniRead, MouseHaloRadius, %inifile%, SavedSettings, MouseHaloRadius, %MouseHaloRadius%
  IniRead, MouseIdleAfter, %inifile%, SavedSettings, MouseIdleAfter, %MouseIdleAfter%
  IniRead, MouseIdleRadius, %inifile%, SavedSettings, MouseIdleRadius, %MouseIdleRadius%
  IniRead, MouseVclickAlpha, %inifile%, SavedSettings, MouseVclickAlpha, %MouseVclickAlpha%
  IniRead, VisualMouseClicks, %inifile%, SavedSettings, VisualMouseClicks, %VisualMouseClicks%
  IniRead, IdleMouseAlpha, %inifile%, SavedSettings, IdleMouseAlpha, %IdleMouseAlpha%
  IniRead, LowVolBeeps, %inifile%, SavedSettings, LowVolBeeps, %LowVolBeeps%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%

if (ScriptelSuspendel=1)
   Return

CoordMode Mouse, Screen

if (FlashIdleMouse=1)
   SetTimer, ShowMouseIdleLocation, 300, 0

if (ShowMouseHalo=1)
   SetTimer, MouseHalo, 40, 0

if (visualMouseClicks=1)
{
    CreateMouseGUI()
    Loop, Parse, % "LButton|MButton|RButton", |
          Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel

    Wheels := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2"
    Loop, parse, Wheels, |
          Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
}

ShowMouseIdleLocation() {

    If (FlashIdleMouse=1) && (A_TimeIdle > (MouseIdleAfter*1000)) && !A_IsSuspended
    {
       MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
       AlphaVariator := IdleMouseAlpha - MouseClickCounter*3
       MouseGetPos, mX, mY
       BoxW := MouseIdleRadius
       BoxH := BoxW
       GuiGetSize(W, H, 3)
       mX := mX - W/2
       mY := mY - W/2
       BorderSize := 4
       RectW := BoxW - BorderSize*2
       RectH := BoxH - BorderSize*2
       InnerColor := "111111"
       OuterColor := "eeeeee"
       Gui, MouseIdlah: +AlwaysOnTop -Caption +ToolWindow +E0x20
       Gui, MouseIdlah: Color, %OuterColor%  ; outer rectangle
       Gui, MouseIdlah: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
       Gui, MouseIdlah: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MouseIdlah
       WinSet, Transparent, %AlphaVariator%, MouseIdlah
       WinSet, AlwaysOnTop, On, MouseIdlah
    } else
    {
        Gui, MouseIdlah: Destroy
    }
    if (FlashIdleMouse=1) && A_IsSuspended
    {
       Gui, MouseIdlah: Destroy
       FlashIdleMouse := 0
    }
}

MouseHalo() {

    If (ShowMouseHalo=1) && !A_IsSuspended
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       GuiGetSize(W, H, 2)
       mX := mX - W/2
       mY := mY - W/2
       Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow +E0x20
       Gui, MouseH: Margin, 0, 0
       Gui, MouseH: Color, %MouseHaloColor%
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
       WinSet, Transparent, %MouseHaloAlpha%, MousarHallo
       WinSet, AlwaysOnTop, On, MousarHallo
    }

    If (ShowMouseHalo=1) && A_IsSuspended
    {
       Gui, MouseH: Destroy
       ShowMouseHalo := 0
    }
}

OnMousePressed() {

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       ShowMouseClick(mkey)
    }
}

OnKeyPressed() {

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       if InStr(mkey, "wheel")
          SetTimer, visualMouseClicksDummy, 10, -10
    }

}

visualMouseClicksDummy() {
    mkey := SubStr(A_ThisHotkey, 3)
    ShowMouseClick(mkey)
    SetTimer, , off
}

CreateMouseGUI() {
    global

    Gui, Mouser: +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, Mouser: Margin, 0, 0
}

ShowMouseClick(clicky) {
    GuiGetSize(Wa, Ha, 4)
    SetTimer, HideMouseClickGUI, 900
    Sleep, 150
    Gui, Mouser: Destroy
    MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
    TransparencyLevel := MouseVclickAlpha - MouseClickCounter*4
    BoxW := 15*ClickScale
    BoxH := 40*ClickScale
    MouseDistance := 10 * ClickScale
    MouseGetPos, mX, mY
    mY := mY - Ha/2
    if InStr(clicky, "LButton")
    {
       mX := mX - Wa*2 - MouseDistance
    } else if InStr(clicky, "MButton")
    {
       BoxW := 45 * ClickScale
       mX := mX - Wa/2
    } else if InStr(clicky, "RButton")
    {
       mX := mX + MouseDistance*2.5
    } else if InStr(clicky, "Wheelup")
    {
       BoxW := 50 * ClickScale
       BoxH := 15 * ClickScale
       mX := mX - Wa/2
       mY := mY - MouseDistance*2.5
    } else if InStr(clicky, "Wheeldown")
    {
       BoxW := 50 * ClickScale
       BoxH := 15 * ClickScale
       mX := mX - Wa/2
       mY := mY + Ha*2 + MouseDistance/2
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
          Break
       } else
       {
          WinSet, Transparent, 55, MousarWin
       }
    }
}


GuiGetSize( ByRef W, ByRef H, vindov) {          ; function by VxE from https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
  if (vindov=1)
     Gui, OSD: +LastFoundExist
  if (vindov=2)
     Gui, MouseH: +LastFoundExist
  if (vindov=3)
     Gui, MouseIdlah: +LastFoundExist
  if (vindov=4)
     Gui, Mouser: +LastFoundExist
  VarSetCapacity( rect, 16, 0 )
  DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
  W := round(NumGet( rect, 8, "int" ))
  H := round(NumGet( rect, 12, "int" ))
}
