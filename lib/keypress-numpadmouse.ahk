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

Global IsMouseNumpadFile := 1
 , MouseNumpadSpeed1     := 5
 , MouseNumpadAccel1     := 20
 , MouseNumpadTopSpeed1  := 65
 , MouseCapsSpeed        := 2  ; 1 - 25
 , MouseKeys             := 1
 , MouseKeysWrap         := 0
 , MouseKeysHalo         := 1
 , MouseWheelSpeed       := 7
; others
, MouseSpeed := 0
, MouseAccelerationSpeed := 0
, MouseMaxSpeed := 0
, lastClick := "Left"
, clickHeldDown := 0
, locked := 0
, moduleInitialized := 0
, MainExe := AhkExported()
, DCT := DllCall("user32\GetDoubleClickTime")
, bHWrap := 1
, bVWrap := 1
, iBorderLeft, bVWrap, iBorderRight, iBorderTop, iBorderBottom

Return

MouseKeysInit() {
  ; OnMessage(0x02B1, "WM_WTSSESSION_CHANGE")

  Hotkey, ~#l, DeactivateMouseKeys, UseErrorLevel
  Hotkey, ~MButton, ButtonTheClicks, UseErrorLevel
  Hotkey, ~RButton, ButtonTheClicks, UseErrorLevel
  Hotkey, ~LButton, ButtonTheClicks, UseErrorLevel
  Hotkey, *NumpadIns, ButtonRightClick, UseErrorLevel
  Hotkey, *NumpadClear, ButtonLeftClick, UseErrorLevel
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

  Hotkey, *NumpadUp Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadDown Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadLeft Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadRight Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadHome Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadEnd Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadPgUp Up, ReleaseKey, UseErrorLevel
  Hotkey, *NumpadPgDn Up, ReleaseKey, UseErrorLevel

  Hotkey, ~NumLock Up, ToggleNumLock, UseErrorLevel
  Hotkey, ~CapsLock Up, ToggleCapsLock, UseErrorLevel
  Hotkey, ~#NumpadSub, dummy, UseErrorLevel
  Hotkey, ~#NumpadAdd, dummy, UseErrorLevel

  moduleInitialized := 1
  Sleep, 15
  ToggleNumLock()    ; Initialize based on current numlock state.
  Sleep, 15
  ToggleCapsLock()
}

DeactivateMouseKeys() {
  SetNumLockState, On
  Sleep, 5
  ToggleNumLock()
  MainExe.ahkPostFunction("LEDsIndicatorsManager")
}

SuspendScript(killNow:=1) {
  If (MouseKeys=0 && moduleInitialized=0)
     Return

  If (MouseKeys=1 && moduleInitialized=0)
     MouseKeysInit()

  If (killNow=0)
  {
     ToggleNumLock(1)
     Hotkey, ~#l, Off
     Hotkey, ~NumLock Up, Off
     Hotkey, ~CapsLock Up, Off
  } Else
  {
     ToggleNumLock()
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

     Hotkey, *NumpadUp Up, %act%
     Hotkey, *NumpadDown Up, %act%
     Hotkey, *NumpadLeft Up, %act%
     Hotkey, *NumpadRight Up, %act%
     Hotkey, *NumpadHome Up, %act%
     Hotkey, *NumpadEnd Up, %act%
     Hotkey, *NumpadPgUp Up, %act%
     Hotkey, *NumpadPgDn Up, %act%

     Hotkey, ~MButton, %act%
     Hotkey, ~RButton, %act%
     Hotkey, ~LButton, %act%
     Hotkey, ~#NumpadSub, %act%
     Hotkey, ~#NumpadAdd, %act%
}

ToggleNumLock(stopAll:=0) {
  Static activated

  If (MouseKeys=0 && moduleInitialized=0)
     Return
  If (moduleInitialized=0)
     MouseKeysInit()

  NumLockState := GetKeyState("NumLock", "T")
  If (NumLockState=0 && MouseKeys=1 && activated!=1)
  {
     If (MouseKeysWrap=1)
        ScreenInfos()
     HotkeysList("On")
     activated := 1
  }

  If ((NumLockState=1 || stopAll=1 || MouseKeys=0) && activated!=0)
  {
     testLock := ButtonEnter(0)
     SetTimer, MouseMoverTimer, Off
     HotkeysList("Off")
     SendInput, {NumpadUp Up}
     SendInput, {NumpadDown Up}
     SendInput, {NumpadLeft Up}
     SendInput, {NumpadRight Up}
     SendInput, {NumpadHome Up}
     SendInput, {NumpadEnd Up}
     SendInput, {NumpadPgUp Up}
     SendInput, {NumpadPgDn Up}
     activated := 0
  }

  If (MouseKeysHalo=1 && stopAll=0 && MouseKeys=1)
     MainExe.ahkPostFunction("ToggleMouseKeysHalo")
}

ToggleCapsLock() {
  True2ndSpeed := MouseCapsSpeed/10
  SetTimer, MouseMoverTimer, Off
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
}

;Mouse click support

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
  If !lastClick
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

ButtonClickStart() {
  MouseClick, %lastClick%,,, 1, 0, D
  clickHeldDown := 1
  MainExe.ahkPostFunction("OnMouseKeysPressed", lastClick " Click")
  SetTimer, ButtonClickEnd, 20
}

ButtonClickEnd() {
  Static lastUpped
  LClickDown := GetKeyState("NumpadClear", "P")
  RClickDown := GetKeyState("NumpadIns", "P")
  MClickDown := GetKeyState("NumpadDel", "P")
  if (LClickDown=1 || RClickDown=1 || MClickDown=1)
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

CalculateSpeed(ByRef MoveX, ByRef MoveY,reset:=0) {
  Static repeats, lastCalc
  If (reset=1) || (A_TickCount - lastCalc > 100)
     repeats := 0
  Else
     repeats++
  CurrentSpeed := MouseSpeed + (MouseAccelerationSpeed/1.5) * repeats/3
  If (CurrentSpeed>MouseMaxSpeed)
     CurrentSpeed := MouseMaxSpeed
  MoveX := Round(CurrentSpeed/2)
  MoveY := Round(CurrentSpeed/2)
  lastCalc := A_TickCount
;    ToolTip, %currentspeed% - %MouseMaxSpeed% - %MouseSpeed%
}

MouseEventAPI(x, y) {
  DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y) ; move
  ; MouseMove, %x%, %y%, 1, R
}

MouseMover() {
  SetTimer, MouseMoverTimer, -10
}

MouseMoverTimer() {
  Static NumPadButton
  StringReplace, NewButton, A_ThisHotkey, *
  reset := 0
  If (NewButton!=NumPadButton)
     reset := 1
  CalculateSpeed(MoveX, MoveY, reset)
  total := MoveX + MoveY
  StringReplace, NumPadButton, A_ThisHotkey, *

  PadUpDown := PadDownDown := PadLeftDown := PadRightDown := PadPgUpDown := PadHomeDown := PadEndDown := PadPgDnDown := 0
  PadUpDown := GetKeyState("NumpadUp", "P")
  PadDownDown := GetKeyState("NumpadDown", "P")
  PadLeftDown := GetKeyState("NumpadLeft", "P")
  PadRightDown := GetKeyState("NumpadRight", "P")
  PadPgUpDown := GetKeyState("NumpadPgUp", "P")
  PadHomeDown := GetKeyState("NumpadHome", "P")
  PadEndDown := GetKeyState("NumpadEnd", "P")
  PadPgDnDown := GetKeyState("NumpadPgDn", "P")

  If ((NumPadButton = "NumpadUp" || PadUpDown=1) && PadDownDown=0)
  {
     MoveY0 := -1 * MoveY*2
     MoveX0 := 0
     MouseEventAPI(MoveX0, MoveY0)
  }
  if ((NumPadButton = "NumpadDown" || PadDownDown=1)  && PadUpDown=0)
  {
     MoveY1 := MoveY*2
     MoveX1 := 0
     MouseEventAPI(MoveX1, MoveY1)
  }
  if ((NumPadButton = "NumpadLeft" || PadLeftDown=1) && PadRightDown=0)
  {
     MoveX2 := -1 * MoveX*2
     MoveY2 := 0
     MouseEventAPI(MoveX2, MoveY2)
  }
  if ((NumPadButton = "NumpadRight" || PadRightDown=1) && PadLeftDown=0)
  {
     MoveX3 := MoveX*2
     MoveY3 := 0
     MouseEventAPI(MoveX3, MoveY3)
  }
  if ((NumPadButton = "NumpadHome" || PadHomeDown=1) && PadPgDnDown=0)
  {
     MoveX4 := -1.35 * MoveX
     MoveY4 := -1.35 * MoveY
     MouseEventAPI(MoveX4, MoveY4)
  }
  if ((NumPadButton = "NumpadPgUp" || PadPgUpDown=1) && PadEndDown=0)
  {
     MoveY5 := -1.35 * MoveY
     MoveX5 := MoveX * 1.35
     MouseEventAPI(MoveX5, MoveY5)
  }
  if ((NumPadButton = "NumpadEnd" || PadEndDown=1) && PadPgUpDown=0)
  {
     MoveX6 := -1.35 * MoveX
     MoveY6 := MoveY * 1.35
     MouseEventAPI(MoveX6, MoveY6)
  }
  if ((NumPadButton = "NumpadPgDn" || PadPgDnDown=1) && PadHomeDown=0)
  {
     MouseEventAPI(MoveX * 1.35, MoveY * 1.35)
  }
; 
  If (PadUpDown=1 || PadDownDown=1 || PadLeftDown=1 || PadRightDown=1
  || PadHomeDown=1 || PadPgUpDown=1 || PadEndDown=1 || PadPgDnDown=1)
     SetTimer, MouseMoverTimer, -50

  If (MouseKeysWrap=1)
     ScreenWrap()
}

ReleaseKey() {
  if (locked=1 || clickHeldDown=1)
     Return
  StringReplace, btn2release, A_ThisHotkey, *,
  StringReplace, btn2release, btn2release, %A_Space%Up,
  SendInput, {%btn2release% Up}
  ; ToolTip, %btn2release%
}
;Mouse wheel movement support

ButtonWheels() {
  Static NumPadButton, lastCalc
  StringReplace, NewButton, A_ThisHotkey, *
  reset := 0
  If (NewButton!=NumPadButton)
     reset := 1
  If (NewButton!=NumPadButton) || (A_TickCount - lastCalc > 200)
     showMsg := 1
  CalculateSpeed(MoveX, MoveY, reset)
  StringReplace, NumPadButton, A_ThisHotkey, *
  MoveX := Round(MoveX/MouseWheelSpeed)
  If (MoveX<1)
     MoveX := 1
  If (NumPadButton="NumpadDiv")
  {
     MouseClick, WheelLeft,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", "Wheel Left")
  } else if (NumPadButton="NumpadMult")
  {
     MouseClick, WheelRight,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", "Wheel Right")
  } else if (NumPadButton="NumpadAdd")
  {
     MouseClick, WheelDown,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", "Wheel Down")
  } else if (NumPadButton="NumpadSub")
  {
     MouseClick, WheelUp,,, %MoveX%, 0
     If (showMsg=1)
        MainExe.ahkPostFunction("OnMouseKeysPressed", "Wheel Up")
  }
  lastCalc := A_TickCount
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
  CoordMode Mouse, Screen
  MouseGetPos PosX, PosY

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


WM_WTSSESSION_CHANGE(wParam, lParam, Msg, hWnd){
; function by Nextron
; found on https://autohotkey.com/boards/viewtopic.php?t=8023
  static init := DllCall("Wtsapi32.dll\WTSRegisterSessionNotification", UInt, A_ScriptHwnd, UInt, 1)
  
  If (wParam=0x7)       ; lock
     SuspendScript(0)
  Else If (wParam=0x8)  ; unlock
     SuspendScript(1)
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

dummy() {
  Return
}
