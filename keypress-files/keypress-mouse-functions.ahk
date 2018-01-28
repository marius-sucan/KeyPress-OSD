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

Global VisualMouseClicks := 0     ; shows visual indicators for different mouse clicks
 , ClickScaleUser        := 10
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , IdleMouseAlpha        := 70    ; from 0 to 255
 , LowVolBeeps           := 1
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , MouseVclickColor      := "555555"
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloRadius       := 85
 , MouseIdleAfter        := 10    ; in seconds
 , MouseIdleRadius       := 130
 , MouseIdleColor        := "333333"
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , CaretHaloAlpha        := 130   ; from 0 to 255
 , CaretHaloColor        := "bbaa99"  ; HEX format also accepted
 , CaretHaloRadius       := 70
 , hostCaretHighlight    := 0
 , IniFile               := "keypress-osd.ini"
 , visible := 0
 , ClickScale := ClickScaleUser/10
 , MouseClickCounter := 0
 , ScriptelSuspendel := 0
 , SilentMode        := 0
 , wa := 0
 , ha := 0

  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, hostCaretHighlight, %inifile%, SavedSettings, hostCaretHighlight, %hostCaretHighlight%
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
  IniRead, MouseVclickColor, %inifile%, SavedSettings, MouseVclickColor, %MouseVclickColor%
  IniRead, MouseIdleColor, %inifile%, SavedSettings, MouseIdleColor, %MouseIdleColor%

if (ScriptelSuspendel=1)
   Return

if (hostCaretHighlight=1)
{
   CoordMode, Caret, Screen ; Window ;Client
   SetTitleMatchMode, 2
   SetTimer, CaretHalo, 70, -50
}

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
    Static

    if (FlashIdleMouse=1) && (A_TimeIdle > (MouseIdleAfter*1000)) && !A_IsSuspended
    {
       MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
       AlphaVariator := IdleMouseAlpha - MouseClickCounter*3
       if !idleOn
       {
          MouseGetPos, mX, mY
          BoxW := MouseIdleRadius
          BoxH := BoxW
          mX := mX - BoxW/2
          mY := mY - BoxW/2
          BorderSize := 4
          RectW := BoxW - BorderSize*2
          RectH := BoxH - BorderSize*2
          InnerColor := "0x" MouseIdleColor
          SetFormat, Integer, H
          OuterColor := 0x222222 + InnerColor
          SetFormat, Integer, D
          idleOn := 1
       }

       if !isIdleGui
       {
          Gui, MouseIdlah: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhIdle
          Gui, MouseIdlah: Color, %OuterColor%  ; outer rectangle
          Gui, MouseIdlah: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor% hwndhIdle1, 100   ; inner rectangle
          WinSet, Region, 0-0 W%RectW% H%RectH% E, ahk_id %hIdle1%
          Gui, MouseIdlah: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MouseIdlah
          WinSet, Region, 0-0 W%BoxW% H%BoxH% E, ahk_id %hIdle%
          isIdleGui := 1
       }

       Gui, MouseIdlah: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MouseIdlah
       WinSet, Transparent, %AlphaVariator%, MouseIdlah
       WinSet, AlwaysOnTop, On, MouseIdlah
    } else
    {
        Gui, MouseIdlah: Hide
        idleOn := 0
    }

    if (FlashIdleMouse=1) && A_IsSuspended
    {
        Gui, MouseIdlah: Hide
        FlashIdleMouse := 0
    }
}

MouseHalo() {
    Static
    if (A_TimeIdle > 2000)
       Return

    if (ShowMouseHalo=1) && !A_IsSuspended
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       mX := mX - BoxW/2
       mY := mY - BoxW/2
       if !isHaloGui
       {
           Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhHalo
           Gui, MouseH: Margin, 0, 0
           Gui, MouseH: Color, %MouseHaloColor%
           Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
           WinSet, Region, 0-0 W%BoxW% H%BoxH% E, ahk_id %hHalo%
           WinSet, Transparent, %MouseHaloAlpha%, MousarHallo
           WinSet, AlwaysOnTop, On, MousarHallo
           isHaloGui := 1
       }
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
       WinSet, AlwaysOnTop, On, MousarHallo
    }

    if (ShowMouseHalo=1) && A_IsSuspended
    {
       Gui, MouseH: Hide
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
    Global
    Gui, Mouser: +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, Mouser: Margin, 0, 0
}

ShowMouseClick(clicky) {
    Static
    SetTimer, HideMouseClickGUI, 900
    Sleep, 150
    Gui, Mouser: Hide
    MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
    TransparencyLevel := MouseVclickAlpha - MouseClickCounter*6
    BoxW := 15*ClickScale
    BoxH := 40*ClickScale
    MouseDistance := 10 * ClickScale
    Loop, 2
    {
      MouseGetPos, mX, mY
      mY := ha ? (mY - Ha/2) : (mY - BoxH/2)
      if InStr(clicky, "LButton")
      {
         mX := wa ? (mX - Wa*2 - MouseDistance) : (mX - BoxW*2 - MouseDistance)
      } else if InStr(clicky, "MButton")
      {
         BoxW := 45 * ClickScale
         mX := wa ? (mX - Wa/2) : (mX - BoxW/2)
      } else if InStr(clicky, "RButton")
      {
         mX := mX + MouseDistance*2.5
      } else if InStr(clicky, "Wheelup")
      {
         BoxW := 50 * ClickScale
         BoxH := 15 * ClickScale
         mX := wa ? (mX - Wa/2) : (mX - BoxW/2)
         mY := mY - MouseDistance*2.5
      } else if InStr(clicky, "Wheeldown")
      {
         BoxW := 50 * ClickScale
         BoxH := 15 * ClickScale
         mX := wa ? (mX - Wa/2) : (mX - BoxW/2)
         mY := mY + BoxH*2 + MouseDistance/2
      }
      InnerColor := "0x" MouseVclickColor
      SetFormat, Integer, H
      OuterColor := 0x222222 + InnerColor
      SetFormat, Integer, D
      BorderSize := 4
      RectW := BoxW - BorderSize*2
      RectH := BoxH - BorderSize*2

      if !isMouser
      {
          CreateMouseGUI()
          Gui, Mouser: Color, %OuterColor%  ; outer rectangle
          Gui, Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
          isMouser := 1
      }  else
      {
          GuiControl, Mouser:Move, msctls_progress321, w%RectW% h%RectH%
          Gui, Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
          WinSet, Transparent, %TransparencyLevel%, MousarWin
          if A_Index=2
             Sleep, 250
          GuiGetSize(Wa, Ha, 4)
          WinSet, AlwaysOnTop, On, MousarWin
      }
    }
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

       if (MouseDown=0)
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
  DllCall("GetClientRect", "Ptr", MyGuiHWND := WinExist(), "Ptr", &rect )
  W := NumGet(rect, 8, "UInt")
  H := NumGet(rect, 12, "UInt")
}

CaretHalo() {
    Static
    doNotShow := 0
    if (hostCaretHighlight=1) && !A_IsSuspended ; && (A_TimeIdle > 200)
    {
       mX := !A_CaretX ? 2 : A_CaretX - CaretHaloRadius/2
       mY := !A_CaretY ? 2 : A_CaretY - CaretHaloRadius/3
       mX := !mX ? 1 : mX
       mY := !mY ? 1 : mY

       if (mX=2 && mY=2)
       {
          lastFlash := A_TickCount
          doNotShow := 1
       }
       if !isHaloGui
       {
           Gui, CaretH: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhHalo
           Gui, CaretH: Margin, 0, 0
           Gui, CaretH: Color, %CaretHaloColor%
           Gui, CaretH: Show, NoActivate x%mX% y%mY% w%CaretHaloRadius% h%CaretHaloRadius%, CaratHallo
           WinSet, Region, 0-0 W%CaretHaloRadius% H%CaretHaloRadius% E, ahk_id %hHalo%
           WinSet, Transparent, %CaretHaloAlpha%, CaratHallo
           WinSet, AlwaysOnTop, On, CaratHallo
           isHaloGui := 1
       }
       if (doNotShow!=1)
       {
          Gui, CaretH: Show, NoActivate x%mX% y%mY% w%CaretHaloRadius% h%CaretHaloRadius%, CaratHallo
          WinSet, Transparent, %CaretHaloAlpha%, CaratHallo
          WinSet, AlwaysOnTop, On, CaratHallo
          if (A_TickCount-lastFlash>300)
          {
              CaretHaloAlphae := CaretHaloAlpha/2
              WinSet, Transparent, %CaretHaloAlphae%, CaratHallo
              lastFlash := A_TickCount
          }
       }
    }

    if (hostCaretHighlight=1) && A_IsSuspended || (doNotShow=1)
       Gui, CaretH: Hide
}
