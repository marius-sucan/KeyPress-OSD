; KeypressOSD.ahk - mouse ripples functions file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

; The script is based on a script by MrRight, from 2015.
; found on https://autohotkey.com/boards/viewtopic.php?t=8963
; Considerably modified by Marius Sucan and Drugwash in 2018. Included in KeyPress OSD.

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

Global IniFile           := "keypress-osd.ini"
 , ShowMouseRipples      := 0
 , MouseRippleMaxSize    := 140
 , MouseRippleThickness  := 10
 , MouseRippleFrequency  := 15
 , MouseRippleLbtnColor  := "ff2211"
 , MouseRippleMbtnColor  := "33cc33"
 , MouseRippleRbtnColor  := "4499ff"
 , MouseRippleWbtnColor  := "888888"
 , MouseRippleOpacity    := 160

 , ScriptelSuspendel := 0
 , WinMouseRipples := "KeyPress OSD: Mouse click ripples"
 , MButtons := "LButton|MButton|RButton|WheelDown|WheelUp|WheelLeft|WheelRight"
 , MainMouseRippleThickness
 , Period, PointDir, tf, PrefOpen
 , isRipplesFile := 1
 , style1        := "GdipDrawEllipse"
 , style2        := "GdipDrawRectangle"
 , style3        := "GdipDrawPolygon"

OnExit("MouseRippleClose")
Return

MouseRippleClose() {
    Global
    If !moduleInitialized
       Return

    MREnd()
    If pToken
       DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    Sleep, 10
    If hGdiplus
       DllCall("kernel32\FreeLibrary", "Ptr", hGdiplus)
    Return 0
}
    
MouseRippleSetup() {
; Gdiplus initialization. Proper shutdown is done in MouseRippleClose()
    Global
    If hGdiplus := DllCall("kernel32\LoadLibraryW", "Str", "gdiplus.dll")
    {
      VarSetCapacity(buf, 16, 0)
      NumPut(1, buf)
      DllCall("gdiplus\GdiplusStartup", "PtrP", pToken, "Ptr", &buf, "Ptr", 0)
      ModuleInitialized := 1
    } Else
    {
      IsRipplesFile := 0
      ModuleInitialized := 0
      Return IsRipplesFile
    }

    If ShowMouseRipples
       MRInit()
}

MRInit() {
    Global
    If (!ModuleInitialized || !pToken)
       MouseRippleSetup()
    MouseRippleMaxSize := MouseRippleMaxSize < 100 ? 101 : MouseRippleMaxSize

    RippleWinSize := MouseRippleMaxSize + 3*MouseRippleThickness + 1
    MainMouseRippleThickness := (MouseRippleMaxSize < 200 && MouseRippleThickness > 35) ? MouseRippleThickness/1.7 : MouseRippleThickness
    RippleMinSize := 2*MouseRippleThickness + 2
    RippleMaxSize := RippleWinSize - 3*MouseRippleThickness - 2
    RippleStep := MouseRippleMaxSize < 160 ? 4 : 6
    RippleAlphaMax := MouseRippleOpacity
    RippleAlphaStep := RippleAlphaMax // ((RippleMaxSize - RippleMinSize) / RippleStep)

    RippleVisible := False
    LeftClickRippleColor := "0x" MouseRippleLbtnColor
    WheelColor := "0x" MouseRippleWbtnColor
    RightClickRippleColor := "0x" MouseRippleRbtnColor
    MiddleClickRippleColor := "0x" MouseRippleMbtnColor

    DCT := DllCall("user32\GetDoubleClickTime")

    hDeskDC := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
    VarSetCapacity(buf, 40, 0)
    NumPut(40, buf, 0)
    NumPut(RippleWinSize, buf, 4)
    NumPut(RippleWinSize, buf, 8)
    NumPut(1, buf, 12, "UShort")
    NumPut(32, buf, 14, "UShort")
    NumPut(0, buf, 16)
    hRippleBmp := DllCall("gdi32\CreateDIBSection"
                     , "Ptr" , hDeskDC
                     , "Ptr" , &buf
                     , "UInt", 0
                     , "PtrP", ppvBits
                     , "Ptr" , 0
                     , "UInt", 0
                     , "Ptr")
    DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", hDeskDC)
    hRippleDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", 0, "Ptr")
    hOldRippleBmp := DllCall("gdi32\SelectObject", "Ptr", hRippleDC, "Ptr", hRippleBmp, "Ptr")
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hRippleDC, "PtrP", pRippleGraphics)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pRippleGraphics, "Int", 4)
    Loop, Parse, MButtons, |
          Hotkey, % "~*" A_LoopField, OnMouse%A_LoopField%, UseErrorLevel
    ToggleMouseRipples()
}

MREnd() {
    Global
    ToggleMouseRipples(True)
    SetTimer RippleTimer, Off
    If hRippleDC
    {
      DllCall("gdi32\SelectObject", "Ptr", hRippleDC, "Ptr", hOldRippleBmp)
      DllCall("gdiplus\GdipDeleteGraphics", "Ptr", pRippleGraphics)
      DllCall("DeleteObject", "Ptr", hRippleBmp)
      DllCall("DeleteDC", "Ptr", hRippleDC)
      Gui, Ripple: Hide
    }
}

MouseRippleUpdate() {
    Global
    MREnd()
    If ShowMouseRipples
       MRInit()
}

ShowRipple(_color, _style, _interval:=10, _dir:="") {
    Global
    Static lastStyle, lastEvent, lastClk := A_TickCount
    If (ScriptelSuspendel="Y" || PrefOpen=1)
       Return

    Sleep, 60
    Gui Ripple: Destroy
    Sleep, 15
    Gui Ripple: -Caption +LastFound +AlwaysOnTop +ToolWindow +Owner +E0x80000 +hwndhRippleWin
    Gui Ripple: Show, NoActivate, %WinMouseRipples%
    WinSet, ExStyle, -0x20, %WinMouseRipples%

    If (RippleVisible)
       Return
    w := InStr(_style, "Poly") ? 1 : 0  ; wheel
    RippleStart := w ? RippleMinSize+50 : RippleMinSize
    If ((A_TickCount-lastClk<DCT) && lastEvent=_color && !w)
    {
       Sleep, 25
       tf := 1.5
       MouseRippleThickness := MainMouseRippleThickness*tf
       RippleColor := _color & 0xBFBFBF
       _style := lastStyle
       lastEvent := ""
       Period := _interval*1.3
    } Else
    {
       tf := 1
       MouseRippleThickness := MainMouseRippleThickness
       RippleColor := _color
       lastEvent := _color
       lastStyle := _style
       Period := _interval
       lastClk := A_TickCount
    }
    PointDir := _dir
    RippleStyle := _style
    RippleDiameter := RippleStart
    RippleAlpha := RippleAlphaMax
    WinSet, AlwaysOnTop, On, %WinMouseRipples%
    GetPhysicalCursorPos(_pointerX, _pointerY)
    RippleTimer()
    SetTimer RippleTimer, %Period%
    Return
}

RippleTimer() {
    Global
    Static PolyBuf, c := Cos(4*ATan(1)/6), offset
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", pRippleGraphics, "Int", 0)
    If ((RippleDiameter += RippleStep) < RippleMaxSize)
    {
       offset := MouseRippleThickness*tf/2
       DllCall("gdiplus\GdipCreatePen1"
          , "UInt"  , ((RippleAlpha -= RippleAlphaStep) << 24) | RippleColor
          , "Float" , MouseRippleThickness
          , "Int"   , 2
          , "PtrP"  , pRipplePen)
        If (RippleStyle != "GdipDrawPolygon")
        {
           DllCall("gdiplus\"RippleStyle
              , "Ptr"   , pRippleGraphics
              , "Ptr"   , pRipplePen
              , "Float" , offset
              , "Float" , offset
              , "Float" , RippleDiameter - 1
              , "Float" , RippleDiameter - 1)
        } Else
        {
            ; cos(pi/6):=(l/2)/(RippleDiameter/2) => l := 2*(cos(Pi/6)*(RippleDiameter/2))
            VarSetCapacity(PolyBuf, 32, 0)
            L := 2*c*(RippleDiameter/2), H := c*L
            vx1:=(RippleDiameter-L)/2+offset ; left X
            vx2:=RippleDiameter/2+offset     ; middle X
            vx3:=RippleDiameter/2+L/2+offset ; right X
            vy1:=H
            vy2:=offset
            vy3:=RippleDiameter-H
            vy4:=RippleDiameter-offset
            hx1:=offset
            hx2:=H
            hx3:=RippleDiameter-H
            hx4:=RippleDiameter-offset
            hy1:=RippleDiameter/2+offset
            hy2:=offset
            hy3:=RippleDiameter-offset
            x1 := (PointDir="U" || PointDir="D") ? vx1 : PointDir="L" ? hx1 : hx3
            x2 := (PointDir="U" || PointDir="D") ? vx2 : PointDir="L" ? hx2 : hx4
            x3 := (PointDir="U" || PointDir="D") ? vx3 : PointDir="L" ? hx2 : hx3
            x4 := (PointDir="U" || PointDir="D") ? vx1 : PointDir="L" ? hx1 : hx3
            y1 := PointDir="U" ? vy1 : PointDir="D" ? vy3 : PointDir="L" ? hy1 : hy2
            y2 := PointDir="U" ? vy2 : PointDir="D" ? vy4 : PointDir="L" ? hy2 : hy1
            y3 := PointDir="U" ? vy1 : PointDir="D" ? vy3 : PointDir="L" ? hy3 : hy3
            y4 := PointDir="U" ? vy1 : PointDir="D" ? vy3 : PointDir="L" ? hy1 : hy2
            NumPut(x1, PolyBuf, 0, "Float"), NumPut(y1, PolyBuf, 4, "Float")
            NumPut(x2, PolyBuf, 8, "Float"), NumPut(y2, PolyBuf, 12, "Float")
            NumPut(x3, PolyBuf, 16, "Float"), NumPut(y3, PolyBuf, 20, "Float")
            NumPut(x4, PolyBuf, 24, "Float"), NumPut(y4, PolyBuf, 28, "Float")
            DllCall("gdiplus\GdipDrawPolygon"
               , "Ptr" , pRippleGraphics
               , "Ptr" , pRipplePen
               , "Ptr" , &PolyBuf
               , "UInt", 4)
        }
        DllCall("gdiplus\GdipDeletePen", "Ptr", pRipplePen)
    } Else
    {
        RippleVisible := False
        SetTimer RippleTimer, Off
        Gui Ripple: Destroy
    }

    L := RippleDiameter+MouseRippleThickness*tf
    ; WinDim, dimension used for UpdateLayeredWindow. Needs to be a bit larger than L
    ; to prevent ripple cropping in some systems [fixed by i-give-up on GitHub]
    WinDim := L+8
    VarSetCapacity(buf, 8)
    NumPut(_pointerX - L // 2, buf, 0)
    NumPut(_pointerY - L // 2, buf, 4)
    DllCall("user32\UpdateLayeredWindow"
       , "Ptr"    , hRippleWin
       , "Ptr"    , 0
       , "Ptr"    , &buf
       , "Int64P" , WinDim|WinDim<<32
       , "Ptr"    , hRippleDC
       , "Int64P" , 0
       , "UInt"   , 0
       , "UIntP"  , 0x1FF0000
       , "UInt"   , 2)
}

ToggleMouseRipples(force:=0) {
    Global
    If (ScriptelSuspendel="Y" || force)
    {
       Loop, Parse, MButtons, |
           Hotkey, % "~*" A_LoopField, OnMouse%A_LoopField%, Off UseErrorLevel
    } Else
    {
       Loop, Parse, MButtons, |
           Hotkey, % "~*" A_LoopField, OnMouse%A_LoopField%, On UseErrorLevel
    }
}

OnMouseLButton:
ShowRipple(LeftClickRippleColor, style1, MouseRippleFrequency)
Return

OnMouseRButton:
Sleep, 160
ShowRipple(RightClickRippleColor, style1, MouseRippleFrequency)
Return

OnMouseMButton:
ShowRipple(MiddleClickRippleColor, style2, MouseRippleFrequency)
Return

OnMouseWheelDown:
Sleep, 15
ShowRipple(WheelColor, style3, MouseRippleFrequency, "D")
Return

OnMouseWheelUp:
Sleep, 15
ShowRipple(WheelColor, style3, MouseRippleFrequency, "U")
Return

OnMouseWheelLeft:
ShowRipple(WheelColor, style3, MouseRippleFrequency, "L")
Return

OnMouseWheelRight:
ShowRipple(WheelColor, style3, MouseRippleFrequency, "R")
Return

GetPhysicalCursorPos(ByRef mX, ByRef mY) {
; function from: https://github.com/jNizM/AHK_DllCall_WinAPI/blob/master/src/Cursor%20Functions/GetPhysicalCursorPos.ahk
; by jNizM, modified by Marius Șucan
    Static POINT, init := VarSetCapacity(POINT, 8, 0) && NumPut(8, POINT, "Int")
    If !(DllCall("user32.dll\GetPhysicalCursorPos", "Ptr", &POINT))
       Return MouseGetPos, mX, mY
;       Return DllCall("kernel32.dll\GetLastError")
    mX := NumGet(POINT, 0, "Int")
    mY := NumGet(POINT, 4, "Int")
    Return
}


