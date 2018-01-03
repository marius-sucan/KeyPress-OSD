; Script by MrRight in 2015.
; from https://autohotkey.com/boards/viewtopic.php?t=8963
; Modified by Marius Sucan in 2018. Included in KeyPress OSD.

#NoTrayIcon
#NoEnv
#SingleInstance force
#MaxHotkeysPerInterval 500
SetWorkingDir, %A_ScriptDir%

global MouseClickRipples := 0
 , MouseRippleMaxSize    := 155
 , MouseRippleThickness  := 10
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0
  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, MouseClickRipples, %inifile%, SavedSettings, MouseClickRipples, %MouseClickRipples%
  IniRead, MouseRippleThickness, %inifile%, SavedSettings, MouseRippleThickness, %MouseRippleThickness%
  IniRead, MouseRippleMaxSize, %inifile%, SavedSettings, MouseRippleMaxSize, %MouseRippleMaxSize%

if (ScriptelSuspendel=1) || (MouseClickRipples=0)
   Return

CoordMode Mouse, Screen
MouseRippleSetup()

~LButton::ShowRipple(LeftClickRippleColor, _style:="GdipDrawEllipse")
~RButton::ShowRipple(RightClickRippleColor, _style:="GdipDrawEllipse")
~MButton::ShowRipple(MiddleClickRippleColor, _style:="GdipDrawRectangle")
~WheelUp::ShowRipple(WheelColor, _style:="GdipDrawRectangle")
~WheelDown::ShowRipple(WheelColor, _style:="GdipDrawRectangle")

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
    
    DllCall("LoadLibrary", Str, "gdiplus.dll")
    VarSetCapacity(buf, 16, 0)
    NumPut(1, buf)
    DllCall("gdiplus\GdiplusStartup", UIntP, pToken, UInt, &buf, UInt, 0)
    
    Gui Ripple: -Caption +LastFound +AlwaysOnTop +ToolWindow +Owner +E0x80000
    Gui Ripple: Show, NA, RippleWin
    hRippleWin := WinExist("RippleWin")
    hRippleDC := DllCall("GetDC", UInt, 0)
    VarSetCapacity(buf, 40, 0)
    NumPut(40, buf, 0)
    NumPut(RippleWinSize, buf, 4)
    NumPut(RippleWinSize, buf, 8)
    NumPut(1, buf, 12, "ushort")
    NumPut(32, buf, 14, "ushort")
    NumPut(0, buf, 16)
    hRippleBmp := DllCall("CreateDIBSection", UInt, hRippleDC, UInt, &buf, UInt, 0, UIntP, ppvBits, UInt, 0, UInt, 0)
    DllCall("ReleaseDC", UInt, 0, UInt, hRippleDC)
    hRippleDC := DllCall("CreateCompatibleDC", UInt, 0)
    DllCall("SelectObject", UInt, hRippleDC, UInt, hRippleBmp)
    DllCall("gdiplus\GdipCreateFromHDC", UInt, hRippleDC, UIntP, pRippleGraphics)
    DllCall("gdiplus\GdipSetSmoothingMode", UInt, pRippleGraphics, Int, 4)
    Return
}

ShowRipple(_color, _style, _interval:=10) {
    Global
    if (RippleVisible)
    	Return
    Sleep, 200
    RippleColor := _color
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
    DllCall("gdiplus\GdipGraphicsClear", UInt, pRippleGraphics, Int, 0)
    if ((RippleDiameter += RippleStep) < RippleMaxSize) {
        DllCall("gdiplus\GdipCreatePen1", Int, ((RippleAlpha -= RippleAlphaStep) << 24) | RippleColor, float, MouseRippleThickness, Int, 2, UIntP, pRipplePen)
        DllCall("gdiplus\"RippleStyle, UInt, pRippleGraphics, UInt, pRipplePen, float, 2.5, float, 2.5, float, RippleDiameter - 1, float, RippleDiameter - 1)
        DllCall("gdiplus\GdipDeletePen", UInt, pRipplePen)
    } else
    {
        RippleVisible := False
        SetTimer RippleTimer, Off
    }

    VarSetCapacity(buf, 8)
    NumPut(_pointerX - RippleDiameter // 2, buf, 0)
    NumPut(_pointerY - RippleDiameter // 2, buf, 4)
    DllCall("UpdateLayeredWindow", UInt, hRippleWin, UInt, 0, UInt, &buf, Int64p, (RippleDiameter + 5) | (RippleDiameter + 5) << 32, UInt, hRippleDC, Int64p, 0, UInt, 0, UIntP, 0x1FF0000, UInt, 2)
Return
