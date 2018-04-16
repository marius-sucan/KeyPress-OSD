; KeypressOSD.ahk - mouse features file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset For this file must be UTF 8 with BOM.
; it may not function properly otherwise.

#NoEnv
#SingleInstance, Force
#Persistent
#NoTrayIcon
#WinActivateForce
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxHotkeysPerInterval 500
CoordMode, Caret, Screen
CoordMode, Mouse, Screen
SetTitleMatchMode, 2
SetBatchLines, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On
; Menu, Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : "lib\keypress.ico"

Global IniFile           := "keypress-osd.ini"
 , MouseVclickScaleUser  := 10
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , ShowMouseIdle         := 0     ; locate an idling mouse with a (flashing) box
 , ShowMouseVclick       := 0     ; shows visual indicators For different mouse clicks
 , ShowCaretHalo         := 0
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , MouseHaloColor        := "EEDD00"  ; HEX format also accepted
 , MouseHaloRadius       := 85
 , MouseIdleAfter        := 10    ; in seconds
 , MouseIdleAlpha        := 70    ; from 0 to 255
 , MouseIdleColor        := "333333"
 , MouseIdleRadius       := 130
 , MouseIdleFlash        := 1     ; some may find it disturbing
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , MouseVclickColor      := "555599"
 , MouseChangeFeedback   := 0
 , HideMhalosMcurHidden  := 1
 , CaretHaloAlpha        := 128   ; from 0 to 255
 , CaretHaloColor        := "BBAA99"  ; HEX format also accepted
 , CaretHaloHeight       := 30
 , CaretHaloWidth        := 25
 , CaretHaloThick        := 0     ; halo thickness; 0 makes a solid halo
 , CaretHaloShape        := 2     ; 1=circle, 2=square, 3=round square, 4=triangle, 5=crosshair
 , CaretHaloMode         := 1     ; 1=fixed size (obey Radius), 2=variable size based on caret height
 , CaretHaloFlash        := 1     ; some may find it disturbing (me included)
 
 , CaretHeight
 , CaretBlinkTime := DllCall("user32\GetCaretBlinkTime")
 , wa := 0
 , ha := 0
 , SilentMode := 0
 , ScriptelSuspendel := 0
 , MouseClickCounter := 0
 , MouseVclickScale := MouseVclickScaleUser/10
 , WinMouseHalo := "KeyPress OSD: Mouse halo"
 , WinMouseIdle := "KeyPress OSD: Mouse idle"
 , WinMouseVclick := "KeyPress OSD: Mouse click blocks"
 , WinCaretHalo := "KeyPress OSD: Caret halo"
 , MButtons := "LButton|MButton|RButton"
 , Wheels := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2"
 , isMouseFile := 1

OnExit("MouseClose")
Return

MouseInit() {
    If (ScriptelSuspendel="Y" || (ShowMouseVclick=0 && ShowMouseIdle=0
    && ShowMouseHalo=0 && ShowCaretHalo=0))
       Return
    CaretHaloThick := (CaretHaloThick > Round(CaretHaloHeight/2-1)) ? Round(CaretHaloHeight/2-1) : Round(CaretHaloThick)
    CaretHaloThick := (CaretHaloThick > 60) ? 60 : Round(CaretHaloThick)

    If (ShowMouseHalo=1)
       SetTimer, MouseHalo, 40, 0

    If (ShowMouseIdle=1)
       SetTimer, ShowMouseIdleLocation, 300, 0

    If (ShowCaretHalo=1)
       SetTimer, CaretHalo, 70, -50

    If (ShowMouseVclick=1)
    {
       CreateMouseGUI()
       Loop, Parse, MButtons, |
             Hotkey, % "~*" A_LoopField, OnMousePressed, On UseErrorLevel
       Loop, parse, Wheels, |
             Hotkey, % "~*" A_LoopField, OnKeyPressed, On UseErrorLevel
    }
}

MouseClose() {
    Gui, MouseH: Destroy
    Gui, MouseIdlah: Destroy
    Gui, Mouser: Destroy
    Gui, CareH: Destroy
}

ShowMouseIdleLocation() {
    Static

    If (ShowMouseIdle=1 && (A_TimeIdle > MouseIdleAfter*1000) && ScriptelSuspendel!="Y")
    {
       MouseClickCounter := !MouseClickCounter
       AlphaVariator := MouseIdleFlash ? MouseIdleAlpha*MouseClickCounter : MouseIdleAlpha
       mouseCursorVisible := checkMcursorState(hpCursor)
       If (mouseCursorVisible=0 && HideMhalosMcurHidden=1)
       {
          idleOn := 0
          isIdleGui := 0
          Gui, MouseIdlah: Destroy
          MouseHalo(1)
          Return
       }

       If !IdleOn || (LastIAlpha != MouseIdleAlpha)
       || (LastIRad != MouseIdleRadius) || (LastIColor != MouseIdleColor)
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
          Gui, MouseIdlah: Destroy
          IsIdleGui := 0
          IdleOn := 1, LastIAlpha := MouseIdleAlpha, LastIRad := MouseIdleRadius, LastIColor := MouseIdleColor
       }

       If !isIdleGui
       {
          Gui, MouseIdlah: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhIdle
          Gui, MouseIdlah: Color, %OuterColor%  ; outer rectangle
          Gui, MouseIdlah: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor% hwndhIdle1, 100   ; inner rectangle
          WinSet, Region, 0-0 W%RectW% H%RectH% E, ahk_id %hIdle1%
          Gui, MouseIdlah: Show, NoActivate Hide x%mX% y%mY% w%BoxW% h%BoxH%, %WinMouseIdle%
          WinSet, Region, 0-0 W%BoxW% H%BoxH% E, ahk_id %hIdle%
          isIdleGui := 1
       }

       Gui, MouseIdlah: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, %WinMouseIdle%
       WinSet, Transparent, %AlphaVariator%, %WinMouseIdle%
       WinSet, AlwaysOnTop, On, %WinMouseIdle%
    } Else
    {
       Gui, MouseIdlah: Hide
       idleOn := 0
    }

    If (ShowMouseIdle=1 && ScriptelSuspendel="Y")
       Gui, MouseIdlah: Hide
}

checkMcursorState(ByRef hpCursor) {
; thanks to Drugwash
    VarSetCapacity(CI, sz:=16+A_PtrSize, 0), z := NumPut(sz, CI, 0, "UInt")
    r := DllCall("user32\GetCursorInfo", "Ptr", &CI) ; get cursor info
    h := NumGet(CI, 4, "UInt"), hpCursor := NumGet(CI, 8, "Ptr")
    If (StrLen(hpCursor)>8 || hpCursor<100 || !InStr(hpCursor, "655"))
       h := 0
;    ToolTip, %h% - %hpCursor% - %r% - %z%
    Return h
}

mouseBleep() {
    If (SilentMode=0)
       SoundPlay, sounds\mouseGlide.wav
}

MouseHalo(killNow:=0) {
    Static
    If (ShowMouseHalo=0 || killNow=1
    || (HideMhalosMcurHidden=1 && A_TimeIdlePhysical>125000)
    || (A_TimeIdle > MouseIdleAfter*1000))
    {
       Gui, MouseH: Destroy
       IsHaloGui := 0
       Return
    }

    If (A_TimeIdle > 16000)
       Return
  
    If (ShowMouseHalo=1 && ScriptelSuspendel!="Y")
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       mX := mX - BoxW/2
       mY := mY - BoxW/2
       If (HideMhalosMcurHidden=1 || MouseChangeFeedback=1)
       {
          mouseCursorVisible := checkMcursorState(hpCursor)
          If (hpCursor!=oldhpCursor && MouseChangeFeedback=1)
          {
             WinSet, Transparent, % MouseHaloAlpha/2, %WinMouseHalo%
             SetTimer, mouseBleep, -1
             WinSet, Transparent, %MouseHaloAlpha%, %WinMouseHalo%
          }
          oldhpCursor := hpCursor
          If (mouseCursorVisible=0 && HideMhalosMcurHidden=1)
          {
             MouseHalo(1)
             Return
          }
       }

       If (!IsHaloGui || (LastAlpha != MouseHaloAlpha)
       || (LastColor != MouseHaloColor) || (LastRad != MouseHaloRadius))
       {
          Gui, MouseH: Destroy
          Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhHalo
          Gui, MouseH: Margin, 0, 0
          Gui, MouseH: Color, %MouseHaloColor%
          Gui, MouseH: Show, NoActivate Hide x%mX% y%mY% w%BoxW% h%BoxH%, %WinMouseHalo%
          WinSet, Region, 0-0 W%BoxW% H%BoxH% E, ahk_id %hHalo%
          WinSet, Transparent, %MouseHaloAlpha%, %WinMouseHalo%
          WinSet, AlwaysOnTop, On, %WinMouseHalo%
          IsHaloGui := 1, LastAlpha := MouseHaloAlpha , LastColor := MouseHaloColor
          , LastRad := MouseHaloRadius
       }
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, %WinMouseHalo%
       WinSet, AlwaysOnTop, On, %WinMouseHalo%
    }

    If (ShowMouseHalo=1 && ScriptelSuspendel="Y")
       Gui, MouseH: Hide
}

OnMousePressed() {
    If (ShowMouseVclick=1 && ScriptelSuspendel!="Y")
    {
       mkey := SubStr(A_ThisHotkey, 3)
       ShowMouseClick(mkey)
    }
}

OnKeyPressed() {
    If (ShowMouseVclick=1 && ScriptelSuspendel!="Y")
    {
       mkey := SubStr(A_ThisHotkey, 3)
       If InStr(mkey, "wheel")
          SetTimer, visualMouseClicksDummy, -10, -10
    }
}

visualMouseClicksDummy() {
    mkey := SubStr(A_ThisHotkey, 3)
    ShowMouseClick(mkey)
}

CreateMouseGUI() {
    Global
    Gui, Mouser: +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, Mouser: Margin, 0, 0
}

ShowMouseClick(clicky:=0, restartNow:=0) {
    Static
    If (restartNow=1)
    {
       Gui, Mouser: Destroy
       isMouser := 0       
    }
    If !clicky
       Return
    SetTimer, HideMouseClickGUI, 900
    Sleep, 50
    ; Gui, Mouser: Hide
    MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
    TransparencyLevel := MouseVclickAlpha - MouseClickCounter*6
    BoxW := 15 * MouseVclickScale
    BoxH := 40 * MouseVclickScale
    MouseDistance := 10 * MouseVclickScale
    Loop, 2
    {
      MouseGetPos, mX, mY
      mY := ha ? (mY - Ha/2) : (mY - BoxH/2)
      If InStr(clicky, "LButton")
      {
         mX := wa ? (mX - Wa*2 - MouseDistance) : (mX - BoxW*2 - MouseDistance)
      } Else If InStr(clicky, "MButton")
      {
         BoxW := 45 * MouseVclickScale
         mX := wa ? (mX - Wa/2) : (mX - BoxW/2)
      } Else If InStr(clicky, "RButton")
      {
         mX := mX + MouseDistance*2.5
      } Else If InStr(clicky, "Wheelup")
      {
         BoxW := 50 * MouseVclickScale
         BoxH := 15 * MouseVclickScale
         mX := wa ? (mX - Wa/2) : (mX - BoxW/2)
         mY := mY - MouseDistance*2.5
      } Else If InStr(clicky, "Wheeldown")
      {
         BoxW := 50 * MouseVclickScale
         BoxH := 15 * MouseVclickScale
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

      If !isMouser
      {
          CreateMouseGUI()
          Gui, Mouser: Color, %InnerColor%  ; outer rectangle
;          Gui, Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
          isMouser := 1
      } Else
      {
;          GuiControl, Mouser:Move, msctls_progress321, w%RectW% h%RectH%
          Gui, Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, %WinMouseVclick%
          WinSet, Transparent, %TransparencyLevel%, %WinMouseVclick%
          If (A_Index=2)
             Sleep, 250
          GuiGetSize(Wa, Ha, 4)
          WinSet, AlwaysOnTop, On, %WinMouseVclick%
      }
    }
}

HideMouseClickGUI() {
    Loop, {
       MouseDown := 0
       If GetKeyState("LButton","P")
          MouseDown := 1
       If GetKeyState("RButton","P")
          MouseDown := 1
       If GetKeyState("MButton","P")
          MouseDown := 1

       If (MouseDown=0)
       {
          Sleep, 250
          Gui, Mouser: Hide
          MouseClickCounter := 20
          SetTimer, HideMouseClickGUI, off
          Break
       } Else
       {
          WinSet, Transparent, 55, %WinMouseVclick%
       }
    }
}

GuiGetSize( ByRef W, ByRef H, vindov) {
; [modified] function by VxE from:
; https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
  If (vindov=1)
     Gui, OSD: +LastFoundExist
  If (vindov=2)
     Gui, MouseH: +LastFoundExist
  If (vindov=3)
     Gui, MouseIdlah: +LastFoundExist
  If (vindov=4)
     Gui, Mouser: +LastFoundExist
  VarSetCapacity( rect, 16, 0 )
  DllCall("user32\GetClientRect", "Ptr", MyGuiHWND := WinExist(), "Ptr", &rect )
  W := NumGet(rect, 8, "UInt")
  H := NumGet(rect, 12, "UInt")
}

CaretHalo(restartNow:=0) {
    Static
    Static lastFlash := A_TickCount
    If (restartNow=1)
    {
       Gui, CaretH: Destroy
       IsHaloGui := 0
       SetTimer, CaretHalo, 70, -50
    }

    doNotShow := 0
    If (ShowCaretHalo=1 && ScriptelSuspendel!="Y") ; && (A_TimeIdle > 200)
    {
       CaretHeight := GetFocusedCtrl(hwCaret)
       CaretHaloHeight2 := CaretHaloHeight + Round(CaretHeight/2)
       CaretHeight := CaretHeight>10 ? CaretHeight : 15 ; must increase it based on DPI !!!
       CaretHaloW := (CaretHaloWidth>10) ? CaretHaloWidth : 10
       CaretHaloH := (CaretHaloMode=1) ? CaretHaloHeight2 : CaretHeight+2*CaretHaloThick+10
       mX := !A_CaretX ? 2 : A_CaretX - Round(CaretHaloW/2 + 1)
       mY := !A_CaretY ? 2 : Round(A_CaretY + CaretHeight/2 - CaretHaloH/2 + 1)
       mX := !mX ? 2 : mX
       mY := !mY ? 2 : mY

       If (mX=2 && mY=2)
       {
          lastFlash := A_TickCount
          doNotShow := 1
       }
       If !IsHaloGui
       {
           Gui, CaretH: +AlwaysOnTop -Caption +ToolWindow +E0x20 +hwndhHalo
           Gui, CaretH: Margin, 0, 0
           Gui, CaretH: Color, %CaretHaloColor%
           Gui, CaretH: Show, NoActivate Hide x%mX% y%mY% w%CaretHaloW% h%CaretHaloH%, %WinCaretHalo%
;           WinSet, Region, 0-0 W%CaretHaloHeight% H%CaretHaloHeight% E, ahk_id %hHalo%
           HaloRegion%CaretHaloShape%(hHalo, 0, 0, CaretHaloW, CaretHaloH, CaretHaloThick)
           WinSet, Transparent, %CaretHaloAlpha%, %WinCaretHalo%
           WinSet, AlwaysOnTop, On, %WinCaretHalo%
           IsHaloGui := 1
       }
       If (doNotShow!=1)
       {
          Gui, CaretH: Show, NoActivate x%mX% y%mY% w%CaretHaloW% h%CaretHaloH%, %WinCaretHalo%
           HaloRegion%CaretHaloShape%(hHalo, 0, 0, CaretHaloW, CaretHaloH, CaretHaloThick)
          WinSet, Transparent, %CaretHaloAlpha%, %WinCaretHalo%
          WinSet, AlwaysOnTop, On, %WinCaretHalo%
          If ((A_TickCount-lastFlash>CaretBlinkTime*2) && CaretHaloFlash)
          {
              CaretHaloAlphae := CaretHaloAlpha/3
              WinSet, Transparent, %CaretHaloAlphae%, %WinCaretHalo%
              Sleep, CaretBlinkTime/2
              lastFlash := A_TickCount
          }
       }
    }
    If ((ShowCaretHalo=1 && ScriptelSuspendel="Y") || doNotShow=1)
       Gui, CaretH: Hide
}
;================================================================
GetFocusedCtrl(ByRef hCtrl)
{
hcActive := WinExist("A")
tID := DllCall("user32\GetWindowThreadProcessId", "Ptr", hActive, "Ptr", 0)
ctID := DllCall("kernel32\GetCurrentThreadId")
DllCall("user32\AttachThreadInput", "UInt", tID, "UInt", ctID, "UInt", 1)
hcFocus := DllCall("user32\GetFocus", "Ptr")
DllCall("user32\AttachThreadInput", "UInt", tID, "UInt", ctID, "UInt", 0)
VarSetCapacity(GTI, sz := 24+6*A_PtrSize, 0) ; GUITHREADINFO struct
NumPut(sz, GTI, 0, "UInt") ; cbSize
If r:= DllCall("user32\GetGUIThreadInfo", "UInt", tID, "Ptr", &GTI)
	{
	hCaret := NumGet(GTI, 8+5*A_PtrSize, "Ptr")
	hFocus := NumGet(GTI, 8+A_PtrSize, "Ptr")
	hActive := NumGet(GTI, 8, "Ptr")
	hCtrl := hCaret ? hCaret : hFocus ? hFocus : hcFocus ? hcFocus : hActive ? hActive : hcActive
	CaretH := NumGet(GTI, 20+6*A_PtrSize, "Int")-NumGet(GTI, 12+6*A_PtrSize, "Int")
;	CaretW := NumGet(GTI, 16+6*A_PtrSize, "Int")-NumGet(GTI, 8+6*A_PtrSize, "Int")
	}
Else hCtrl := hcFocus ? hcFocus : hcActive
Return CaretH ? CaretH : 0
}
;================================================================

ToggleMouseTimerz(force:=0) {
    If (ScriptelSuspendel="Y" || force)
    {
      If (ShowCaretHalo=1)
         SetTimer, CaretHalo, off

      If (ShowMouseIdle=1)
         SetTimer, ShowMouseIdleLocation, off

      If (ShowMouseHalo=1)
         SetTimer, MouseHalo, Off

      If (ShowMouseVclick=1)
      {
        Loop, Parse, MButtons, |
          Hotkey, % "~*" A_LoopField, Off
        Loop, Parse, Wheels, |
          Hotkey, % "~*" A_LoopField, Off
      }
      Gui, MouseIdlah: Hide
      Gui, MouseH: Hide
      Gui, CaretH: Hide
    } Else
    {
      If (ShowCaretHalo=1)
         SetTimer, CaretHalo, 70, -50

      If (ShowMouseIdle=1)
         SetTimer, ShowMouseIdleLocation, 300, 0

      If (ShowMouseHalo=1)
         SetTimer, MouseHalo, 40, 0

      If (ShowMouseVclick=1)
      {
        Loop, Parse, MButtons, |
          Hotkey, % "~*" A_LoopField, On
        Loop, Parse, Wheels, |
          Hotkey, % "~*" A_LoopField, On
      }
    }
}

;================================================================
; by Drugwash: EVER HEARD OF M.C.HAMMER? DON'T TOUCH THIS !
;================================================================
HaloRegion1(hwnd, x:=0, y:=0, w:=0, h:=0, t:=0) {
  hR1 := DllCall("gdi32\CreateEllipticRgn", "Int", x, "Int", y, "Int", w, "Int", h, "Ptr")
  If t
  {
    hR2 := DllCall("gdi32\CreateEllipticRgn", "Int", x+t, "Int", y+t, "Int", w-t, "Int", h-t, "Ptr")
    DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 3) ; RGN_XOR
    DllCall("gdi32\DeleteObject", "Ptr", hR2)
  }
  Return DllCall("user32\SetWindowRgn", "Ptr", hwnd, "Ptr", hR1, "UInt", 1)
}

HaloRegion2(hwnd, x:=0, y:=0, w:=0, h:=0, t:=0) {
  hR1 := DllCall("gdi32\CreateRectRgn", "Int", x, "Int", y, "Int", w, "Int", h, "Ptr")
  If t
  {
   hR2 := DllCall("gdi32\CreateRectRgn", "Int", x+t, "Int", y+t, "Int", w-t, "Int", h-t, "Ptr")
   DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 3) ; RGN_XOR
   DllCall("gdi32\DeleteObject", "Ptr", hR2)
  }
  Return DllCall("user32\SetWindowRgn", "Ptr", hwnd, "Ptr", hR1, "UInt", 1)
}

HaloRegion3(hwnd, x:=0, y:=0, w:=0, h:=0, t:=0) {
  hR1 := DllCall("gdi32\CreateRoundRectRgn", "Int", x, "Int", y, "Int", w, "Int", h, "Int", 2*t, "Int", 2*t, "Ptr")
  If t
  {
   hR2 := DllCall("gdi32\CreateRoundRectRgn", "Int", x+t, "Int", y+t, "Int", w-t, "Int", h-t, "Int", t, "Int", t, "Ptr")
   DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 3) ; RGN_XOR
   DllCall("gdi32\DeleteObject", "Ptr", hR2)
  }
  Return DllCall("user32\SetWindowRgn", "Ptr", hwnd, "Ptr", hR1, "UInt", 1)
}

HaloRegion4(hwnd, x:=0, y:=0, w:=0, h:=0, t:=0) {
   x1:=Round(w/2-CaretHeight/2-5)-1, y1:=0, x2 := x1+CaretHeight+10, y2:=0, x3:=Round(w/2)-1, y3:=t+4
   VarSetCapacity(buf, 24, 0), NumPut(x1, buf, 0, "Int"), NumPut(x2, buf, 8, "Int")
   NumPut(x3, buf, 16, "Int"), NumPut(y3, buf, 20, "Int")
   hR1 := DllCall("gdi32\CreatePolygonRgn", "Ptr", &buf, "Int", 3, "Int", 1, "Ptr") ; ALTERNATE=1, WINDING=2
   Return DllCall("user32\SetWindowRgn", "Ptr", hwnd, "Ptr", hR1, "UInt", 1)
}

HaloRegion5(hwnd, x:=0, y:=0, w:=0, h:=0, t:=0) {
   x1:=Round(w/2-CaretHeight/2-5)-1, y1:=0, x2:=x1+CaretHeight+10, y2:=0, x3:=Round(w/2)-1, y3:=t+4
   VarSetCapacity(buf, 24, 0), NumPut(x1, buf, 0, "Int"), NumPut(x2, buf, 8, "Int")
   NumPut(x3, buf, 16, "Int"), NumPut(y3, buf, 20, "Int")
   hR1 := DllCall("gdi32\CreatePolygonRgn", "Ptr", &buf, "Int", 3, "Int", 1, "Ptr") ; ALTERNATE=1, WINDING=2

   x1:=w, y1:=Round(h/2-CaretHeight/2-5)-1, x2:=w, y2:=y1+CaretHeight+10, x3:=w-t-5, y3:=Round(h/2-1)
   VarSetCapacity(buf, 24, 0), NumPut(x1, buf, 0, "Int"), NumPut(y1, buf, 4, "Int")
   NumPut(x2, buf, 8, "Int"), NumPut(y2, buf, 12, "Int")
   NumPut(x3, buf, 16, "Int"), NumPut(y3, buf, 20, "Int")
   hR2 := DllCall("gdi32\CreatePolygonRgn", "Ptr", &buf, "Int", 3, "Int", 1, "Ptr") ; ALTERNATE=1, WINDING=2
   DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 2) ; RGN_OR
   DllCall("gdi32\DeleteObject", "Ptr", hR2)

   x1:=Round(w/2+CaretHeight/2+5)-1, y1:=h-1, x2:=x1-CaretHeight-10, y2:=h-1, x3:=Round(w/2)-1, y3:=h-t-6
   VarSetCapacity(buf, 24, 0), NumPut(x1, buf, 0, "Int"), NumPut(y1, buf, 4, "Int")
   NumPut(x2, buf, 8, "Int"), NumPut(y2, buf, 12, "Int")
   NumPut(x3, buf, 16, "Int"), NumPut(y3, buf, 20, "Int")
   hR2 := DllCall("gdi32\CreatePolygonRgn", "Ptr", &buf, "Int", 3, "Int", 1, "Ptr") ; ALTERNATE=1, WINDING=2
   DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 2) ; RGN_OR
   DllCall("gdi32\DeleteObject", "Ptr", hR2)

   x1:=0, y1:=Round(h/2-CaretHeight/2-5)-1, x2:=0, y2:=y1+CaretHeight+10, x3:=t+4, y3:=Round(h/2-1)
   VarSetCapacity(buf, 24, 0), NumPut(x1, buf, 0, "Int"), NumPut(y1, buf, 4, "Int")
   NumPut(x2, buf, 8, "Int"), NumPut(y2, buf, 12, "Int")
   NumPut(x3, buf, 16, "Int"), NumPut(y3, buf, 20, "Int")
   hR2 := DllCall("gdi32\CreatePolygonRgn", "Ptr", &buf, "Int", 3, "Int", 1, "Ptr") ; ALTERNATE=1, WINDING=2
   DllCall("gdi32\CombineRgn", "Ptr", hR1, "Ptr", hR1, "Ptr", hR2, "UInt", 2) ; RGN_OR
   DllCall("gdi32\DeleteObject", "Ptr", hR2)

   Return DllCall("user32\SetWindowRgn", "Ptr", hwnd, "Ptr", hR1, "UInt", 1)
}

