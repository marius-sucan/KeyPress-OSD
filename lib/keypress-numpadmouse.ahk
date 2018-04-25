; KeypressOSD.ahk - mouse keys functions file
; Latest version at:
; https://github.com/marius-sucan/KeyPress-OSD
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

/*
o------------------------------------------------------------o
| Using Keyboard Numpad as a Mouse                           |
(------------------------------------------------------------)
| by Marius Șucan ---------------------------------- in 2018 |
| based on/inspired by a script with the same name by deguix |
|------------------------------------------------------------|
| Keys                  | Description                        |
|------------------------------------------------------------|
| NumLock (toggled ON)  | Activates numpad mouse mode.       |
|-----------------------|------------------------------------|
| Numpad0               | Right mouse button click.          |
| Numpad5               | Left mouse button click.           |
| NumpadDot             | Middle mouse button click.         |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.     |
| NumpadDiv/NumpadMult  | Wheel left/right or X1/X2 buttons. |
| NumpadEnter           | Locks down previously pressed click|
|-----------------------|------------------------------------|
| NumpadEnd/Down/PgDn/  | Mouse movement directions.         |
| /Left/Right/Home/Up/  |                                    |
| /PgUp                 |                                    |
|-----------------------|------------------------------------|
| CapsLock (toggled ON) | Activates alternate mouse          |
|                       | movement speeds.                   |
|-----------------------|------------------------------------|
| ScrollLock            | Activates locked mouse clicks.     |
| (toggled ON)          | In this mode, every click gets     |
|                       | locked until it is pressed again,  |
|                       | or one is pressed.                 |
o------------------------------------------------------------o
*/

;START OF CONFIG SECTION

#SingleInstance force
#MaxHotkeysPerInterval 500
#NoTrayIcon
#NoEnv
#Persistent
SetKeyDelay, -1
SetMouseDelay, -1
; SetBatchLines, -1
; ListLines, Off

Global IsMouseNumpadFile := 1
 , MouseNumpadSpeed1     := 1
 , MouseNumpadAccel1     := 5
 , MouseNumpadTopSpeed1  := 35
 , MouseCapsSpeed        := 2  ; 1 - 25
 , MouseKeys             := 1
 , MouseKeysWrap         := 0
 , MouseKeysHalo         := 1
 , MouseWheelSpeed       := 7
 , DifferModifiers       := 0
; others
, MouseSpeed := 0
, MouseAccelerationSpeed := 0
, MouseMaxSpeed := 0
, lastClick := "Left"
, clickHeldDown := 0
, locked := 0
, Monitors := 1
, LockMode := 0
, moduleInitialized := 0
, MainExe := AhkExported()
, DCT := DllCall("user32\GetDoubleClickTime")
, bHWrap := 1
, bVWrap := 1
, iBorderLeft, bVWrap, iBorderRight, iBorderTop, iBorderBottom, PrefOpen := 0
, buttonsDownList := ""
, MainModsList := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]

Return

MouseKeysInit() {
  Hotkey, ~#l, DeactivateMouseKeys, UseErrorLevel
  Hotkey, ~MButton, ButtonTheClicks, UseErrorLevel
  Hotkey, ~RButton, ButtonTheClicks, UseErrorLevel
  Hotkey, ~LButton, ButtonTheClicks, UseErrorLevel
  Hotkey, *NumpadClear, ButtonLeftClick, UseErrorLevel
  Hotkey, *NumpadIns, ButtonRightClick, UseErrorLevel
  Hotkey, *NumpadDel, ButtonMiddleClick, UseErrorLevel
  Hotkey, *NumpadEnter, ButtonEnter, UseErrorLevel
  Hotkey, *NumpadSub, ButtonWheels, UseErrorLevel
  Hotkey, *NumpadAdd, ButtonWheels, UseErrorLevel
/*
  Hotkey, *NumpadDiv, ButtonX1Click
  Hotkey, *NumpadMult, ButtonX2Click
*/
  Hotkey, *NumpadDiv, ButtonWheels, UseErrorLevel
  Hotkey, *NumpadMult, ButtonWheels, UseErrorLevel

  Hotkey, *NumpadUp, MouseMover, UseErrorLevel
  Hotkey, *NumpadDown, MouseMover, UseErrorLevel
  Hotkey, *NumpadLeft, MouseMover, UseErrorLevel
  Hotkey, *NumpadRight, MouseMover, UseErrorLevel
  Hotkey, *NumpadHome, MouseMover, UseErrorLevel
  Hotkey, *NumpadEnd, MouseMover, UseErrorLevel
  Hotkey, *NumpadPgUp, MouseMover, UseErrorLevel
  Hotkey, *NumpadPgDn, MouseMover, UseErrorLevel

  Hotkey, ~NumLock Up, ToggleNumLock, UseErrorLevel
  Hotkey, ~CapsLock Up, ToggleCapsLock, UseErrorLevel
  Hotkey, ~#NumpadSub, WinKeyZoomInOut, UseErrorLevel
  Hotkey, ~#NumpadAdd, WinKeyZoomInOut, UseErrorLevel
  Hotkey, ~Esc, CancelLock, UseErrorLevel
  Hotkey, ~Enter, CancelLock, UseErrorLevel
  Hotkey, ~ScrollLock, ToggleLockMode, UseErrorLevel

  moduleInitialized := 1
  Sleep, 15
  ToggleNumLock(0,1)    ; Initialize based on current numlock state.
}

DeactivateMouseKeys() {
  SetNumLockState, On
  Sleep, 5
  ToggleNumLock(0,1)
  MainExe.ahkPostFunction("LEDsIndicatorsManager")
}

SuspendScript(killNow:=1) {
  If (MouseKeys=0 && moduleInitialized=0)
     Return

  If (MouseKeys=1 && moduleInitialized=0)
     MouseKeysInit()

  If (killNow=0)
  {
     ToggleNumLock(1,1)
     Hotkey, ~#l, Off
     Hotkey, ~NumLock Up, Off
     Hotkey, ~CapsLock Up, Off
  } Else
  {
     ToggleNumLock(0,1)
     Hotkey, ~#l, On
     Hotkey, ~NumLock Up, On
     Hotkey, ~CapsLock Up, On
  }
}

;Key activation support

HotkeysList(act) {
     Hotkey, *NumpadIns, %act%
     Hotkey, *NumpadClear, %act%
     Hotkey, *NumpadDel, %act%
     Hotkey, *NumpadDiv, %act%
     Hotkey, *NumpadMult, %act%
     Hotkey, *NumpadEnter, %act%

     Hotkey, *NumpadSub, %act%
     Hotkey, *NumpadAdd, %act%

     Hotkey, *NumpadUp, %act%
     Hotkey, *NumpadDown, %act%
     Hotkey, *NumpadLeft, %act%
     Hotkey, *NumpadRight, %act%
     Hotkey, *NumpadHome, %act%
     Hotkey, *NumpadEnd, %act%
     Hotkey, *NumpadPgUp, %act%
     Hotkey, *NumpadPgDn, %act%

     Hotkey, ~MButton, %act%
     Hotkey, ~RButton, %act%
     Hotkey, ~LButton, %act%
     Hotkey, ~#NumpadSub, %act%
     Hotkey, ~#NumpadAdd, %act%
     Hotkey, ~ScrollLock, %act%
}

ToggleNumLock(stopAll:=0,silent:=0) {
  Static activated

  If (MouseKeys=0 && moduleInitialized=0)
     Return
  If (moduleInitialized=0)
     MouseKeysInit()

  NumLockState := GetKeyState("NumLock", "T")
  If (NumLockState=0 && MouseKeys=1 && activated!=1)
  {
     buttonsDownList := ""
     If (MouseKeysWrap=1)
        ScreenInfos()
     HotkeysList("On")
     ToggleCapsLock(1)
     activated := 1
  }

  If ((NumLockState=1 || stopAll=1 || MouseKeys=0) && activated!=0)
  {
     testLock := ButtonEnter(0)
     SetTimer, MouseMoverTimer, Off
     HotkeysList("Off")
     activated := 0
  }
  Sleep, 25
  If (MouseKeysHalo=1 && stopAll=0 && MouseKeys=1)
     MainExe.ahkFunction("ToggleMouseKeysHalo")

  If (silent=0)
  {
     If (activated=0)
        ToolTip, Disabled Mouse keys
     Else If (activated=1)
        ToolTip, Enabled mouse keys
     SetTimer, TurnOFFtooltip, -950
  }
}

TurnOFFtooltip() {
  ToolTip
}

ToggleLockMode() {
  ScrLockState := GetKeyState("ScrollLock", "T")
  If (ScrLockState=0)
     ToolTip, Enabled Auto-Lock Mode
  Else
     ToolTip, Disabled Auto-Lock Mode
  SetTimer, TurnOFFtooltip, -950
}

ToggleCapsLock(silent:=0) {
  True2ndSpeed := MouseCapsSpeed/10
  SetTimer, MouseMoverTimer, Off
  NumLockState := GetKeyState("NumLock", "T")
  CapsLockState := GetKeyState("CapsLock", "T")
  If (CapsLockState=0)
  {
     MouseSpeed := MouseNumpadSpeed1
     MouseAccelerationSpeed := MouseNumpadAccel1
     MouseMaxSpeed := MouseNumpadTopSpeed1
  } Else 
  {
     MouseSpeed := MouseNumpadSpeed1 * True2ndSpeed
     If (MouseSpeed<1)
        MouseSpeed := 0.5
     MouseAccelerationSpeed := MouseNumpadAccel1 * True2ndSpeed
     If (MouseAccelerationSpeed<1)
        MouseAccelerationSpeed := 0.5
     MouseMaxSpeed := MouseNumpadTopSpeed1 * True2ndSpeed
     If (MouseMaxSpeed<1)
        MouseMaxSpeed := 1
  }
  If (silent=0)
  {
     If (CapsLockState=0 && NumLockState=0 && locked=0)
        ToolTip, Normal speed
     Else If (NumLockState=0 && locked=0)
        ToolTip, Alternate speed
     If (locked=0)
        SetTimer, TurnOFFtooltip, -950
  }
}

;Mouse click support

CancelLock() {
  If (locked=1)
     ButtonEnter(0)
}

ButtonTheClicks() {
  ButtonEnter(0)
  StringReplace, lastClick, A_ThisHotkey, ~LButton, Left
  StringReplace, lastClick, lastClick, ~RButton, Right
  StringReplace, lastClick, lastClick, ~MButton, Middle
}

ButtonLeftClick() {
  testLock := ButtonEnter(0)
  lastClick := "Left"
  If testLock
     Return
  GetKeyState, already_down_state, LButton
  If (already_down_state = "D")
     Return

  ScrollLockState := GetKeyState("ScrollLock", "T")
  If (ScrollLockState=1)
  {
     ButtonEnter()
     Return
  }
  SetTimer, ButtonClickStart, -10
}

ButtonMiddleClick() {
  testLock := ButtonEnter(0)
  lastClick := "Middle"
  If testLock
     Return
  GetKeyState, already_down_state, MButton
  If (already_down_state = "D")
     Return

  ScrollLockState := GetKeyState("ScrollLock", "T")
  If (ScrollLockState=1)
  {
     ButtonEnter()
     Return
  }
  SetTimer, ButtonClickStart, -10
}

ButtonRightClick() {
  testLock := ButtonEnter(0)
  lastClick := "Right"
  If testLock
     Return

  GetKeyState, already_down_state, RButton
  If (already_down_state = "D")
     return

  ScrollLockState := GetKeyState("ScrollLock", "T")
  If (ScrollLockState=1)
  {
     ButtonEnter()
     Return
  }
  SetTimer, ButtonClickStart, -10
}

ButtonEnter(doNotLock:=1) {
  If (!lastClick || PrefOpen=1)
     Return

  If (locked=1)
  {
     SetTimer, MouseMoverTimer, Off
     MouseClick, %lastClick%,,, 1, 0, U
     locked := 0
     MainExe.ahkPostFunction("OnMouseKeysPressed", lastClick " Click (unlocked)")
     ToolTip
     Return 1
  }

  If (doNotLock=1)
  {
     SetTimer, MouseMoverTimer, Off
     MouseClick, %lastClick%,,, 1, 0, D
     locked := 1
     MainExe.ahkPostFunction("OnMouseKeysPressed", lastClick " Click (locked down)")
     ToolTip, %lastClick% Click locked.
  }
}

checkModsHeld() {
  For i, mod in MainModsList
  {
      If GetKeyState(mod)
         modsHeld .= mod "+"
  }
  profix := CompactModifiers(modsHeld)
  Sort, profix, U D+
  StringReplace, profix, profix, +, %A_Space%+%A_Space%, All
  Return profix
}

ButtonClickStart() {
  MouseClick, %lastClick%,,, 1, 0, D
  clickHeldDown := 1
  modsHeld := checkModsHeld()
  MainExe.ahkPostFunction("OnMouseKeysPressed", modsHeld lastClick " Click")
  SetTimer, ButtonClickEnd, 20
}

ButtonClickEnd() {
  Static lastUpped
  LClickDown := GetKeyState("NumpadClear", "P")
  RClickDown := GetKeyState("NumpadIns", "P")
  MClickDown := GetKeyState("NumpadDel", "P")
  if (LClickDown=1 || RClickDown=1 || MClickDown=1 )
     Return
  SetTimer,, Off
  ; MouseClick, %lastClick%,,, 1, 0, U

  GetKeyState, already_down_state, RButton
  If (already_down_state = "D")
     MouseClick, Right,,, 1, 0, U

  GetKeyState, already_down_state, MButton
  If (already_down_state = "D")
     MouseClick, Middle,,, 1, 0, U

  GetKeyState, already_down_state, LButton
  If (already_down_state = "D")
     MouseClick, Left,,, 1, 0, U
  If lastUpped && (A_TickCount - lastUpped < DCT)
     MainExe.ahkPostFunction("OnMouseKeysPressed", "Double Click")
  clickHeldDown := 0
  lastUpped := A_TickCount
}

ButtonX1Click() {
  testLock := ButtonEnter(0)
  If testLock
     Return
  GetKeyState, already_down_state, XButton1
  If (already_down_state = "D")
     return
  MouseClick, X1,,, 1, 0
}

ButtonX2Click() {
  testLock := ButtonEnter(0)
  If testLock
     Return
  GetKeyState, already_down_state, XButton2
  If (already_down_state = "D")
     return
  MouseClick, X2,,, 1, 0
}

;Mouse movement support

CalculateSpeed(ByRef MoveX, ByRef MoveY,reset:=0, wheelMode:=0) {
  Static repeats, lastCalc
  accelDelay := (wheelMode=1) ? 0.4 : 0.9
  repeats := (reset=1) ? 0 : repeats + accelDelay
  CurrentSpeed := MouseSpeed + (MouseAccelerationSpeed/1.5) * repeats/3
  If (CurrentSpeed>MouseMaxSpeed)
     CurrentSpeed := MouseMaxSpeed
  MoveX := Round(CurrentSpeed/2)
  MoveY := Round(CurrentSpeed/2)
 ; If (CurrentSpeed!=MouseNumpadSpeed1)
;     ToolTip, %currentspeed% - %repeats%, 500, 500 ; - %MouseMaxSpeed% - %MouseSpeed%
}

MouseEventAPI(x, y) {
  DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y) ; move
  ; MouseMove, %x%, %y%, 1, R
}

MouseMover() {
  If (PrefOpen!=1)
     SetTimer, MouseMoverTimer, -25
}

MouseMoverTimer() {
  Static lastCalc, AllPadsState, dF := 1.25   ; diagonals max-speed scaling factor
  If (A_TickCount - lastCalc > 15000)
     buttonsDownList := ""

  StringReplace, NumPadButton, A_ThisHotkey, *num
  If !InStr(buttonsDownList, NumPadButton)
     buttonsDownList .= NumPadButton ","
  ; StringRight, buttonsDownList, buttonsDownList, 20
  PadUpDown := GetKeyState("NumpadUp", "P")
  PadDownDown := GetKeyState("NumpadDown", "P")
  PadLeftDown := GetKeyState("NumpadLeft", "P")
  PadRightDown := GetKeyState("NumpadRight", "P")
  PadPgUpDown := GetKeyState("NumpadPgUp", "P")
  PadHomeDown := GetKeyState("NumpadHome", "P")
  PadEndDown := GetKeyState("NumpadEnd", "P")
  PadPgDnDown := GetKeyState("NumpadPgDn", "P")
  newAllPadsState := PadUpDown PadDownDown PadLeftDown PadRightDown PadPgUpDown PadHomeDown PadEndDown PadPgDnDown
  resetSpeed := (newAllPadsState!=AllPadsState) ? 1 : 0
  CalculateSpeed(MoveX, MoveY, resetSpeed)
  AllPadsState := newAllPadsState
  MoveX0 := MoveX1 := MoveX2 := MoveX3 := MoveX4 := MoveX5 := MoveX6 := MoveX7 := 0
  MoveY0 := MoveY1 := MoveY2 := MoveY3 := MoveY4 := MoveY5 := MoveY6 := MoveY7 := 0

    If (PadUpDown=1) && InStr(buttonsDownList, "PadUp")
    {
       MoveY0 := -1 * MoveY*2
       MoveX0 := 0
    }
    if (PadDownDown=1) && InStr(buttonsDownList, "PadDown")
    {
       MoveY1 := MoveY*2
       MoveX1 := 0
    }
    if (PadLeftDown=1) && InStr(buttonsDownList, "PadLeft")
    {
       MoveX2 := -1 * MoveX*2
       MoveY2 := 0
    }
    if (PadRightDown=1) && InStr(buttonsDownList, "PadRight")
    {
       MoveX3 := MoveX*2
       MoveY3 := 0
    }
    if (PadHomeDown=1) && InStr(buttonsDownList, "PadHome")
    {
       MoveX4 := -dF * MoveX
       MoveY4 := -dF * MoveY
    }
    if (PadPgUpDown=1) && InStr(buttonsDownList, "PadPgUp")
    {
       MoveY5 := -dF * MoveY
       MoveX5 := MoveX * dF
    }
    if (PadEndDown=1) && InStr(buttonsDownList, "PadEnd")
    {
       MoveX6 := -dF * MoveX
       MoveY6 := MoveY * dF
    }
    if (PadPgDnDown=1) && InStr(buttonsDownList, "PadPgDn")
    {
       MoveX7 := MoveX * dF
       MoveY7 := MoveY * dF
    }

  FinMoveX := MoveX0 + MoveX1 + MoveX2 + MoveX3 + MoveX4 + MoveX5 + MoveX6 + MoveX7
  FinMoveY := MoveY0 + MoveY1 + MoveY2 + MoveY3 + MoveY4 + MoveY5 + MoveY6 + MoveY7
  testHighest := Max(Abs(FinMoveX), Abs(FinMoveY))
;  ToolTip, %AllPadsState% %FinMoveX% - %FinMoveY% - %NumPadButton% - %buttonsDownList% - %A_ThisHotkey%
  If (testHighest>MouseMaxSpeed)
  {
     Loop
     {
       FinMoveX := FinMoveX/1.05
       FinMoveY := FinMoveY/1.05
       total := Abs(FinMoveY) + Abs(FinMoveX)
     } Until (total<MouseMaxSpeed*dF)
  }
  MouseEventAPI(Ceil(FinMoveX), Ceil(FinMoveY))
  If InStr(AllPadsState, "1") && StrLen(NumPadButton)>2 && testHighest>0
     SetTimer, MouseMoverTimer, -25

  If (MouseKeysWrap=1)
     ScreenWrap()

  If (locked=1)
     SetTimer, ActivateWinUM, -900

  lastCalc := A_TickCount
}

ActivateWinUM() {
  If (locked!=1)
     Return
  MainExe.ahkPostFunction("genericBeeper")
  MouseGetPos,,, WinUMID
  WinActivate, ahk_id %WinUMID%
}

;Mouse wheel movement support

ButtonWheels() {
  Static NumPidButton, lastCalc
  StringReplace, NewButton, A_ThisHotkey, *
  reset := 0
  If (NewButton!=NumPidButton) || (A_TickCount - lastCalc > 200)
  {
     reset := 1
     showMsg := 1
  }
  CalculateSpeed(MoveX, MoveY, reset, 1)
  StringReplace, NumPidButton, A_ThisHotkey, *
  MoveX := Round(MoveX/MouseWheelSpeed)
  If (MoveX<1)
     MoveX := 1

  modsHeld := checkModsHeld()
  If (NumPidButton="NumpadDiv")
  {
     MouseClick, WheelLeft,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", modsHeld "Wheel Left")
  } else if (NumPidButton="NumpadMult")
  {
     MouseClick, WheelRight,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", modsHeld "Wheel Right")
  } else if (NumPidButton="NumpadAdd")
  {
     MouseClick, WheelDown,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", modsHeld "Wheel Down")
  } else if (NumPidButton="NumpadSub")
  {
     MouseClick, WheelUp,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", modsHeld "Wheel Up")
  }
  lastCalc := A_TickCount
}

WinKeyZoomInOut() {
  btn := InStr(A_ThisHotkey, "sub") ? "[ - ]" : "[ + ]"
  MainExe.ahkPostFunction("OnMouseKeysPressed", "WinKey + " btn)
  Return
}

CompactModifiers(ztr) {
    Static CompactPattern := {"LCtrl":"Ctrl", "RCtrl":"Ctrl", "LShift":"Shift", "RShift":"Shift"
             , "LAlt":"Alt", "LWin":"WinKey", "RWin":"WinKey", "RAlt":"AltGr"}
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


; The following two functions were extracted and modified
; from MouseWrapper v1.2 by Paegus (paegus@gmail.com)
; Released under GNU General Public Licence.

ScreenInfos() {
  Global
  SysGet Monitors, MonitorCount
  iBorderLeft := 0
  iBorderRight := 0
  iBorderTop := 0
  iBorderBottom := 0
  Loop, %Monitors%
  {
    SysGet Monitor, Monitor, %A_Index%
    if (MonitorLeft < iBorderLeft)
       iBorderLeft := MonitorLeft
    
    if (MonitorRight > iBorderRight)
       iBorderRight := MonitorRight - 1
    
    if (MonitorTop < iBorderTop)
       iBorderTop := MonitorTop
    
    if (MonitorBottom > iBorderBottom)
       iBorderBottom := MonitorBottom - 1
  }
}

ScreenWrap() {
  If (Monitors>1)
     Return
  CoordMode Mouse, Screen
  GetPhysicalCursorPos(PosX, PosY)

  if (bHWrap=1)
  {
    if (PosX <= iBorderLeft)
    {
      NPosX := iBorderRight - 1
      MouseMove %NPosX%, %PosY%, 0
    } else if (PosX >= iBorderRight-1)
    {
      NPosX := iBorderLeft + 1
      MouseMove %NPosX%, %PosY%, 0
    }
  }
  
  if (bVWrap=1)
  {
    if (PosY <= iBorderTop)
    {
      NPosY := iBorderBottom - 1
      MouseMove %PosX%, %NPosY%, 0
    } else if (PosY >= iBorderBottom) 
    {
      NPosY := iBorderTop + 1
      MouseMove %PosX%, %NPosY%, 0
    }
  }
}

SessionIsLocked() {
  static WTS_CURRENT_SERVER_HANDLE := 0, WTSSessionInfoEx := 25, WTS_SESSIONSTATE_LOCK := 0x00000000, WTS_SESSIONSTATE_UNLOCK := 0x00000001 ;, WTS_SESSIONSTATE_UNKNOWN := 0xFFFFFFFF
  ret := False
  if (DllCall("ProcessIdToSessionId", "UInt", DllCall("GetCurrentProcessId", "UInt"), "UInt*", sessionId)
     && DllCall("wtsapi32\WTSQuerySessionInformation", "Ptr", WTS_CURRENT_SERVER_HANDLE, "UInt", sessionId, "UInt", WTSSessionInfoEx, "Ptr*", sesInfo, "Ptr*", BytesReturned))
  {
    SessionFlags := NumGet(sesInfo+0, 16, "Int")
    ; "Windows Server 2008 R2 and Windows 7: Due to a code defect, the usage of the WTS_SESSIONSTATE_LOCK and WTS_SESSIONSTATE_UNLOCK flags is reversed."
    ret := A_OSVersion != "WIN_7" ? SessionFlags == WTS_SESSIONSTATE_LOCK : SessionFlags == WTS_SESSIONSTATE_UNLOCK
    DllCall("wtsapi32\WTSFreeMemory", "Ptr", sesInfo)
  }
  return ret
}

GetPhysicalCursorPos(ByRef mX, ByRef mY) {
; function from: https://github.com/jNizM/AHK_DllCall_WinAPI/blob/master/src/Cursor%20Functions/GetPhysicalCursorPos.ahk
; by jNizM, modified by Marius Șucan
    If (A_OSVersion="WIN_XP")
    {
       MouseGetPos, mX, mY
       Return
    }

    Static POINT, init := VarSetCapacity(POINT, 8, 0) && NumPut(8, POINT, "Int")
    If !(DllCall("user32.dll\GetPhysicalCursorPos", "Ptr", &POINT))
    {
       MouseGetPos, mX, mY
       Return
;       Return DllCall("kernel32.dll\GetLastError")
    }
    mX := NumGet(POINT, 0, "Int")
    mY := NumGet(POINT, 4, "Int")
    Return
}


