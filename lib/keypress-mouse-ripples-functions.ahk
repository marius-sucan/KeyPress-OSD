; Script by MrRight in 2015.
; from https://autohotkey.com/boards/viewtopic.php?t=8963
; Modified by Marius Sucan in 2018. Included in KeyPress OSD.

#NoEnv
#SingleInstance, Force
#Persistent
#NoTrayIcon
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxHotkeysPerInterval 500
CoordMode Mouse, Screen
SetBatchLines, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

Global MouseClickRipples := 0
 , MouseRippleMaxSize    := 155
 , MouseRippleThickness  := 10
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0
 , pToken
 , isRipplesFile := 1
 ;  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, MouseClickRipples, %inifile%, SavedSettings, MouseClickRipples, %MouseClickRipples%
  IniRead, MouseRippleThickness, %inifile%, SavedSettings, MouseRippleThickness, %MouseRippleThickness%
  IniRead, MouseRippleMaxSize, %inifile%, SavedSettings, MouseRippleMaxSize, %MouseRippleMaxSize%

Global MainMouseRippleThickness := MouseRippleThickness

If (ScriptelSuspendel=1 || MouseClickRipples=0)
   Return

MouseRippleSetup()

~LButton::ShowRipple(LeftClickRippleColor, _style:="GdipDrawEllipse")
~RButton::ShowRipple(RightClickRippleColor, _style:="GdipDrawEllipse")
~MButton::ShowRipple(MiddleClickRippleColor, _style:="GdipDrawRectangle")
~WheelUp::ShowRipple(WheelColor, _style:="GdipDrawRectangle")
~WheelDown::ShowRipple(WheelColor, _style:="GdipDrawRectangle")

MouseRippleClose() {
    Global
    SetTimer RippleTimer, Off
    Sleep, 10
    DllCall("gdi32\SelectObject", "Ptr", hRippleDC, "Ptr", hOldRippleBmp)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", pRippleGraphics)
;    DllCall("gdiplus\GdipDisposeImage", "Ptr", hRippleBmp)
    DllCall("DeleteObject", "Ptr", hRippleBmp)
    DllCall("DeleteDC", "Ptr", hRippleDC)
    If pToken
       DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    Sleep, 150
    If hGdiplus
       DllCall("kernel32\FreeLibrary", "Ptr", hGdiplus)
}
    
MouseRippleSetup() {
    Global
    RippleWinSize := MouseRippleMaxSize
    RippleStep := MouseRippleMaxSize < 156 ? 4 : 6
    RippleMinSize := MouseRippleMaxSize < 156 ? 30 : 65
    RippleMaxSize := RippleWinSize - 10
    RippleAlphaMax := 0x60
    RippleAlphaStep := RippleAlphaMax // ((RippleMaxSize - RippleMinSize) / RippleStep)
    RippleVisible := False
    LeftClickRippleColor := 0xff2211
    WheelColor := 0x999999
    RightClickRippleColor := 0x4499ff
    MiddleClickRippleColor := 0x33cc33
    MouseIdleRippleColor := LeftClickRippleColor
    DCT := DllCall("user32\GetDoubleClickTime")

    ; Gdiplus initilaization. Proper shutdown is done in MouseRippleClose()
    If hGdiplus := DllCall("kernel32\LoadLibraryW", "Str", "gdiplus.dll")
    {
      VarSetCapacity(buf, 16, 0)
      NumPut(1, buf)
      DllCall("gdiplus\GdiplusStartup", "PtrP", pToken, "Ptr", &buf, "Ptr", 0)
    } Else Return, isRipplesFile := 0

    hDeskDC := DllCall("user32\GetDC", "Ptr", 0)
    VarSetCapacity(buf, 40, 0)
    NumPut(40, buf, 0)
    NumPut(RippleWinSize, buf, 4)
    NumPut(RippleWinSize, buf, 8)
    NumPut(1, buf, 12, "UShort")
    NumPut(32, buf, 14, "UShort")
    NumPut(0, buf, 16)
    hRippleBmp := DllCall("gdi32\CreateDIBSection", "Ptr", hDeskDC, "Ptr", &buf, "UInt", 0, "PtrP", ppvBits, "Ptr", 0, "UInt", 0)
    DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", hDeskDC)
    hRippleDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", 0)
    hOldRippleBmp := DllCall("gdi32\SelectObject", "Ptr", hRippleDC, "Ptr", hRippleBmp)
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hRippleDC, "PtrP", pRippleGraphics)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pRippleGraphics, "Int", 4)
    Return
}

ShowRipple(_color, _style, _interval:=10) {
    Global
    If (ScriptelSuspendel="Y")
       Return
       
    Static lastClk := A_TickCount
    Static lastEvent
    Gui Ripple: Destroy
    Sleep, 30
    Gui Ripple: -Caption +LastFound +AlwaysOnTop +ToolWindow +Owner +E0x80000
    Gui Ripple: Show, NA, RippleWin
    WinSet, ExStyle, -0x20, RippleWin
    hRippleWin := WinExist("RippleWin")

    If (RippleVisible)
       Return
    If ((A_TickCount-lastClk<DCT) && lastEvent=_color && WheelColor!=_color)
    {
       MouseRippleThickness := MainMouseRippleThickness*3
       RippleColor := 0x888888
    } Else
    {
       MouseRippleThickness := MainMouseRippleThickness
       RippleColor := _color
    }
    lastClk := A_TickCount
    lastEvent := _color
    Sleep, %DCT%-20
    InnerRippleColor := OtherColor
    RippleStyle := _style
    RippleDiameter := RippleMinSize
    RippleAlpha := RippleAlphaMax
    WinSet, AlwaysOnTop, On, RippleWin

    MouseGetPos _pointerX, _pointerY
    SetTimer RippleTimer, % _interval
    Return
}

RippleTimer:
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", pRippleGraphics, "Int", 0)
    If ((RippleDiameter += RippleStep) < RippleMaxSize) {
        DllCall("gdiplus\GdipCreatePen1", "UInt", ((RippleAlpha -= RippleAlphaStep) << 24) | RippleColor, "Float", MouseRippleThickness, "Int", 2, "PtrP", pRipplePen)
        DllCall("gdiplus\"RippleStyle, "Ptr", pRippleGraphics, "Ptr", pRipplePen, "Float", 2.5, "Float", 2.5, "Float", RippleDiameter - 1, "Float", RippleDiameter - 1)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pRipplePen)
    } Else
    {
        RippleVisible := False
        SetTimer RippleTimer, Off
        Gui Ripple: Destroy
    }

    VarSetCapacity(buf, 8)
    NumPut(_pointerX - RippleDiameter // 2, buf, 0)
    NumPut(_pointerY - RippleDiameter // 2, buf, 4)
    DllCall("user32\UpdateLayeredWindow", "Ptr", hRippleWin, "Ptr", 0, "Ptr", &buf, "Int64P", (RippleDiameter + 5) | (RippleDiameter + 5) << 32, "Ptr", hRippleDC, "Int64P", 0, "UInt", 0, "UIntP", 0x1FF0000, "UInt", 2)
Return
