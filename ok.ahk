#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MaxThreadsPerHotkey 2

ScrCmp( X, Y, W, H, Hwnd:=0x0, Sleep* )  {                                        ; v0.66 By SKAN on D3B3/D3B6 @ tiny.cc/scrcmp
Local
Global A_Args
  Sleep[1] := Sleep[1]="" ? 100 : Format("{:d}", Sleep[1])
  Sleep[2] := Sleep[2]="" ? 100 : Format("{:d}", Sleep[2])

  VarSetCapacity(BITMAPINFO, 40, 0)
  NumPut(32, NumPut(1, NumPut(0-H*2, NumPut(W, NumPut(40,BITMAPINFO,"Int"),"Int"),"Int"),"Short"),"Short")

  hBM := DllCall("Gdi32.dll\CreateDIBSection", "Ptr",0, "Ptr",&BITMAPINFO, "Int",0, "PtrP",pBits := 0, "Ptr",0, "Int",0, "Ptr")
  sDC := DllCall("User32.dll\GetDC", "Ptr",(Hwnd := WinExist("ahk_id" . Hwnd)), "Ptr")
  mDC := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr",sDC, "Ptr")
  DllCall("Gdi32.dll\SaveDC", "Ptr",mDC)
  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hBM)
  DllCall("Gdi32.dll\BitBlt", "Ptr",mDC, "Int",0, "Int",H, "Int",W, "Int",H, "Ptr",sDC, "Int",X, "Int",Y, "Int",0x40CC0020)

  A_Args.ScrCmp := {"Wait": 1},   Bytes := W*H*4,  Count := 0
  hMod := DllCall("Kernel32.dll\LoadLibrary", "Str","ntdll.dll", "Ptr")
  While ( A_Args.ScrCmp.Wait && (Count<2) )
  {
      DllCall("Gdi32.dll\BitBlt", "Ptr",mDC, "Int",0, "Int",0, "Int",W, "Int",H, "Ptr",sDC, "Int",X, "Int",Y, "Int",0x40CC0020)
      Count := ( (Byte := DllCall("ntdll.dll\RtlCompareMemory", "Ptr",pBits, "Ptr",pBits+Bytes, "Ptr",Bytes) ) != Bytes )
               ? (Count + 1) : 0
      Sleep % (Count ? Sleep[2] : Sleep[1])
  }   Byte +=1
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",hMod)

  SX := (CX := Mod((Byte-1)//4, W) + X),    SY := (CY := (Byte-1) // (W*4)   + Y)
  If (Hwnd)
    VarsetCapacity(POINT,8,0), NumPut(CX,POINT,"Int"), NumPut(CY,POINT,"Int")
  , DllCall("User32.dll\ClientToScreen", "Ptr",Hwnd, "Ptr",&POINT)
  , SX := NumGet(POINT,0,"Int"),  SY := NumGet(POINT,4,"Int")

  If (Wait := A_Args.ScrCmp.Wait)
      A_Args.ScrCmp := { "Wait":0, "CX":CX, "CY":CY, "SX":SX, "SY":SY }
  DllCall("Gdi32.dll\RestoreDC", "Ptr",mDC, "Int",-1)
  DllCall("Gdi32.dll\DeleteDC", "Ptr",mDC)
  DllCall("User32.dll\ReleaseDC", "Ptr",Hwnd, "Ptr",sDC)
  DllCall("Gdi32.dll\DeleteObject", "Ptr",hBM)
Return ( !!Wait )
}

SetTitleMatchMode, 2

On = 0

Gui, Add, Button, Center x110 y12.5 w80 h25 vToggleButton gToggleOnOff, Start
Gui, Show, w300 h50, okTyper - Paused

loop {
while (On = 1)
  {
  ScrCmp(-1600,900,300,50)
  if (On = 1){
  WinGet, active_id
  WinActivate, Discord
  Send ok{return}
  WinActivate, ahk_id %active_id%
  Sleep 1000
  }
}
}
return

ToggleOnOff:
On := !On

if (On = 1)
{
  GuiControl,, ToggleButton, Pause
  Gui, Show,, okTyper - Running
}
else
{
  GuiControl,, ToggleButton, Start
  Gui, Show,, okTyper - Paused
}
return



GuiClose:
ExitApp