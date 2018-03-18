; Accessible Info Viewer
; by Sean and jethrow
; http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/
; https://dl.dropbox.com/u/47573473/Accessible%20Info%20Viewer/AccViewer%20Source.ahk
/*
DetectHiddenWindows, On
OnMessage(0x200,"WM_MOUSEMOVE")
ComObjError(false)

SetTimer, GetAccInfo, 450, 50
Return
*/
Global isAcc1File := 1

GetAccInfo(skipVerification:=0) {
  DetectHiddenWindows, On
  If (A_TickCount-lastTypedSince < DisplayTimeTyping/2 && skipVerification=0) || A_IsSuspended
     Return
  Acc := Acc_ObjectFromPoint(ChildId)
  UpdateAccInfo(Acc, ChildId)
}

UpdateAccInfo(Acc, ChildId, Obj_Path="") {
  Global InputMsg, AccViewName, AccViewValue, CtrlTextVar, NewCtrlTextVar
  Global uia := UIA_Interface()
  Global Element := uia.ElementFromPoint()
  
  MouseGetPos, , , id, controla, 2
  ControlGetText, NewCtrlTextVar , , ahk_id %controla%
  CtrlTextVar := StrLen(NewCtrlTextVar)>1 || !OSDvisible ? NewCtrlTextVar : CtrlTextVar

  NewAccViewName := Element.CurrentName
  If !NewAccViewName
     NewAccViewName := Acc.accName(ChildId)
  AccViewName := StrLen(NewAccViewName)>1 || !OSDvisible ? NewAccViewName : AccViewName

  For each, value in [30093,30092,30045] ; lvalue,lname,value
      NewAccViewValue := Element.GetCurrentPropertyValue(value)
  Until r != ""
  If !NewAccViewValue
     NewAccViewValue := Acc.accValue(ChildId)
  AccViewValue := StrLen(NewAccViewValue)>1 || !OSDvisible ? NewAccViewValue : AccViewValue
  CtrlTextVar := RegExReplace(CtrlTextVar, "i)^(\s+)")
  AccViewName := RegExReplace(AccViewName, "i)^(\s+)")
  AccViewValue := RegExReplace(AccViewValue, "i)^(\s+)")
  If (StrLen(AccViewName) = StrLen(CtrlTextVar)-1) || (StrLen(AccViewName) = StrLen(CtrlTextVar)+1)
     CtrlTextVar := ""
  If (AccViewName=AccViewValue)
     AccViewValue := ""
  If (AccViewName=CtrlTextVar) || (AccViewValue=CtrlTextVar)
     CtrlTextVar := ""

  otherDetails := Acc_GetRoleText(Acc.accRole(ChildId)) " " Acc_GetStateText(Acc.accState(ChildId)) " " Acc.accDefaultAction(ChildId) " " Acc.accDescription(ChildId) " " Acc.accHelp(ChildId)
  NewInputMsg := AccViewName " " AccViewValue " " CtrlTextVar " " otherDetails
  StringReplace, NewInputMsg, NewInputMsg, %A_TAB%, %A_SPACE%, All
  StringReplace, NewInputMsg, NewInputMsg, %A_SPACE%%A_SPACE%, %A_SPACE%, All
  If (NewInputMsg!=InputMsg) || (AccTextCaptureActive=0)
  {
     ShowLongMsg(NewInputMsg)
     InputMsg := NewInputMsg
     SetTimer, HideGUI, % -DisplayTime
  }
}

GetClassNN(Chwnd, Whwnd) {
  Global _GetClassNN := {}
  _GetClassNN.Hwnd := Chwnd
  Detect := A_DetectHiddenWindows
  WinGetClass, Class, ahk_id %Chwnd%
  _GetClassNN.Class := Class
  DetectHiddenWindows, On
  EnumAddress := RegisterCallback("GetClassNN_EnumChildProc")
  DllCall("user32\EnumChildWindows", "UInt",Whwnd, "UInt",EnumAddress)
  DetectHiddenWindows, %Detect%
  Return, _GetClassNN.ClassNN, _GetClassNN:=""
}

GetClassNN_EnumChildProc(hwnd, lparam) {
  Static Occurrence
  Global _GetClassNN
  WinGetClass, Class, ahk_id %hwnd%
  If _GetClassNN.Class == Class
    Occurrence++
  If Not _GetClassNN.Hwnd == hwnd
    Return true
  Else {
    _GetClassNN.ClassNN := _GetClassNN.Class Occurrence
    Occurrence := 0
    Return false
  }
}

TV_Expanded(TVid) {
  For Each, TV_Child_ID in TVobj[TVid].Children
    If TVobj[TV_Child_ID].need_children
      TV_BuildAccChildren(TVobj[TV_Child_ID].obj, TV_Child_ID)
}

TV_BuildAccChildren(AccObj, Parent, Selected_Child="", Flag="") {
  TVobj[Parent].need_children := false
  Parent_Obj_Path := Trim(TVobj[Parent].Obj_Path, ",")
  For wach, child in Acc_Children(AccObj) {
    If Not IsObject(child) {
      added := TV_Add("[" A_Index "] " Acc_GetRoleText(AccObj.accRole(child)), Parent)
      TVobj[added] := {is_obj:false, obj:Acc, childid:child, Obj_Path:Parent_Obj_Path}
      If (child = Selected_Child)
        TV_Modify(added, "Select")
    }
    Else {
      added := TV_Add("[" A_Index "] " Acc_Role(child), Parent, "bold")
      TVobj[added] := {is_obj:true, need_children:true, obj:child, childid:0, Children:[], Obj_Path:Trim(Parent_Obj_Path "," A_Index, ",")}
    }
    TVobj[Parent].Children.Insert(added)
    If (A_Index = Flag)
      Flagged_Child := added
  }
  Return Flagged_Child
}

GetAccPath(Acc, byref hwnd="") {
  hwnd := Acc_WindowFromObject(Acc)
  WinObj := Acc_ObjectFromWindow(hwnd)
  WinObjPos := Acc_Location(WinObj).pos
  While Acc_WindowFromObject(Parent:=Acc_Parent(Acc)) = hwnd {
    t2 := GetEnumIndex(Acc) "." t2
    If Acc_Location(Parent).pos = WinObjPos
      Return {AccObj:Parent, Path:SubStr(t2,1,-1)}
    Acc := Parent
  }
  While Acc_WindowFromObject(Parent:=Acc_Parent(WinObj)) = hwnd
    t1.="P.", WinObj:=Parent
  Return {AccObj:Acc, Path:t1 SubStr(t2,1,-1)}
}

GetEnumIndex(Acc, ChildId=0) {
  If Not ChildId {
    ChildPos := Acc_Location(Acc).pos
    For Each, child in Acc_Children(Acc_Parent(Acc))
      If IsObject(child) and Acc_Location(child).pos=ChildPos
        Return A_Index
  } 
  Else {
    ChildPos := Acc_Location(Acc,ChildId).pos
    For Each, child in Acc_Children(Acc)
      If Not IsObject(child) and Acc_Location(Acc,child).pos=ChildPos
        Return A_Index
  }
}

GetAccLocation(AccObj, Child=0, byref x="", byref y="", byref w="", byref h="") {
  AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
  Return  "x" (x:=NumGet(x,0,"Int")) "  "
  .  "y" (y:=NumGet(y,0,"Int")) "  "
  .  "w" (w:=NumGet(w,0,"Int")) "  "
  .  "h" (h:=NumGet(h,0,"Int"))
}

;================================================================
; Acc Library
;================================================================
  Acc_Init(unload:=0) {
    Static  h
    If Not  h
      h:=DllCall("kernel32\LoadLibraryW","Str","oleacc","Ptr")
   If (h && unload)
     Dllcall("kernel32\FreeLibrary", "Ptr", h)
  }

  Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild) {
    Acc_Init()
    If DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
       Return  ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
  }

  Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "") {
    Acc_Init()
    If  DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("user32\GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
    Return  ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
  }

  Acc_ObjectFromWindow(hWnd, idObject = 0) {
    Acc_Init()
    If  DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
    Return  ComObjEnwrap(9,pacc,1)
  }

  Acc_WindowFromObject(pacc) {
    If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
    Return  hWnd
  }

  Acc_GetRoleText(nRole) {
    nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
    VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
    DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
    Return sRole
  }

  Acc_GetStateText(nState) {
    nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
    VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
    DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
    Return sState
  }

  Acc_Role(Acc, ChildId=0) {
    try Return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
  }

  Acc_State(Acc, ChildId=0) {
    try Return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
  }

  Acc_Children(Acc) {
    If ComObjType(Acc,"Name")!="IAccessible"
      error_message := "Cause:`tInvalid IAccessible Object`n`n"
    Else
    {
      Acc_Init()
      cChildren:=Acc.accChildCount, Children:=[]
      If DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0, "Int", cChildren, "Ptr", VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*", cChildren)=0
      {
        Loop %cChildren%
          i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=3?child:Acc_Query(child)), ObjRelease(child)
      Return Children
      }
    }
    error:=Exception("",-1)
    MsgBox, 262148, Acc_Children Failed, % (error_message?error_message:"") "File:`t" (error.file==A_ScriptFullPath?A_ScriptName:error.file) "`nLine:`t" error.line "`n`nContinue Script?"
    IfMsgBox, No
      ExitApp
  }

  Acc_Location(Acc, ChildId=0) {
    try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
    catch
    Return
    Return  {x:NumGet(x,0,"Int"), y:NumGet(y,0,"Int"), w:NumGet(w,0,"Int"), h:NumGet(h,0,"Int")
    ,  pos:"x" NumGet(x,0,"Int")" y" NumGet(y,0,"Int") " w" NumGet(w,0,"Int") " h" NumGet(h,0,"Int")}
  }

  Acc_Parent(Acc) {
    try parent:=Acc.accParent
    Return parent?Acc_Query(parent):
  }

  Acc_Child(Acc, ChildId=0) {
    try child:=Acc.accChild(ChildId)
    Return child?Acc_Query(child):
  }

  Acc_Query(Acc) {
    try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
  }
;================================================================
; Anchor
;================================================================

Anchor(i, a = "", r = false) {
  Static c, cs := 12, cx := 255, cl := 0, g, gs := 8, gl := 0, gpi, gw, gh, z := 0, k := 0xffff
  If z = 0
    VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
  If (!WinExist("ahk_id" . i))
  {
    GuiControlGet, t, Hwnd, %i%
    If ErrorLevel = 0
    i := t
    Else ControlGet, i, Hwnd, , %i%
  }
  VarSetCapacity(gi, 68, 0), DllCall("user32\GetWindowInfo", "UInt", gp := DllCall("user32\GetParent", "UInt", i), "Ptr", &gi)
  , giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
  If (gp != gpi)
  {
    gpi := gp
    Loop, %gl%
      If (NumGet(g, cb := gs * (A_Index - 1)) == gp, "UInt")
      {
        gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
        Break
      }
    If (!gf)
      NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
  }
  ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
  Loop, %cl%
  If (NumGet(c, cb := cs * (A_Index - 1), "UInt") == i)
  {
    If a =
    {
      cf = 1
      Break
    }
    giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
    , cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
    Loop, Parse, a, xywh
      If A_Index > 1
        av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
        , d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
    DllCall("user32\SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
    , "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
    If r != 0
      DllCall("user32\RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101)
    Return
  }
  If cf != 1
    cb := cl, cl += cs
  bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
  If cf = 1
    dw -= giw - gw, dh -= gih - gh
  NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
  , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
  Return, true
}

WinGetAll(Which="Title", DetectHidden="Off"){
O_DHW := A_DetectHiddenWindows, O_BL := A_BatchLines ;Save original states
DetectHiddenWindows, % (DetectHidden != "off" && DetectHidden) ? "on" : "off"
SetBatchLines, -1
    WinGet, all, list ;get all hwnd
    If (Which="Title") ;return Window Titles
    {
        Loop, %all%
        {
            WinGetTitle, WTitle, % "ahk_id " all%A_Index%
            If WTitle ;Prevent to get blank titles
                Output .= WTitle "`n"        
        }
    }
    Else If (Which="Process") ;return Process Names
    {
        Loop, %all%
        {
            WinGet, PName, ProcessName, % "ahk_id " all%A_Index%
            Output .= PName "`n"
        }
    }
    Else If (Which="Class") ;return Window Classes
    {
        Loop, %all%
        {
            WinGetClass, WClass, % "ahk_id " all%A_Index%
            Output .= WClass "`n"
        }
    }
    Else If (Which="hwnd") ;return Window Handles (Unique ID)
    {
        Loop, %all%
            Output .= all%A_Index% "`n"
    }
    Else If (Which="PID") ;return Process Identifiers
    {
        Loop, %all%
        {
            WinGet, PID, PID, % "ahk_id " all%A_Index%
            Output .= PID "`n"        
        }
        Sort, Output, U N ;numeric order and remove duplicates
    }
DetectHiddenWindows, %O_DHW% ;back to original state
SetBatchLines, %O_BL% ;back to original state
    Sort, Output, U ;remove duplicates
    Return Output
}
