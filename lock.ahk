;#NoTrayIcon
#Include %A_ScriptDir%/lib/Gdip_All.ahk

global LOGIN_IMAGE := "login.png"
global WALLPAPER_IMAGE := "wallpaper.jpg"
global isLocked := false

Tooltip % "Loaded script"
hotkeyFile := A_ScriptDir . "\unlock.key"
FileReadLine, unlockKey, %hotkeyFile%, 1
Hotkey, %unlockKey%, secretUnlock
sleep 500
Tooltip
WinClose, Camera
return


<#b::
setBackground()
return

<#v::
setBackground()
setLockScreen()
return

setLockScreen()
{
	lockImage := "C:\Users\" . A_Username . "\Pictures\" . LOGIN_IMAGE
	Run, % lockImage
	sleep 200
	send {LCtrl down}
	send {l down}
	sleep 50
	send {LCtrl up}
	send {l up}
	sleep 200
	WinClose, %LOGIN_IMAGE%
	return
}

setBackground()
{
	bgImage := "C:\Users\" . A_Username . "\Pictures\" . WALLPAPER_IMAGE
	DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, bgImage, UInt, 1)
	return
}

<#J::  ;LWin + J to enable lockout on all keys
Tooltip % "Lockout enabled"
initiateLock()
sleep 1000
Tooltip
Run, %ComSpec% /c start microsoft.windows.camera:
WinWait Camera
sleep 1000
WinActivate Camera
send {Lalt down}
send {Esc down}
sleep 20
send {LAlt up}
send {Esc up}
return


lockWorkstation:
Loop, 255
{
  Hotkey, % "~" Format("vk{:x}",A_Index), LockWorkStation, Off
  Hotkey, % "" Format("vk{:x}",A_Index), doNothing, On
}
imageFile := cameraCapture()
DllCall("user32.dll\LockWorkStation")
WinClose, % imageFile
reload
return

doNothing:
return

Check_Idle()
{
	if A_TimeIdle > 30000
	{
		MouseMove 30, 30, 50, R
		sleep 100
		MouseMove -30, -30, 50, R
	}
	return
}

cameraCapture()
{
	IfWinNotExist, Camera
	{
	  Run, %ComSpec% /c start microsoft.windows.camera:
	  sleep 1000
	}
	Loop
	{
		if WinExist("Camera")
		{
			fileName := Win2File("Camera")
			WinClose, Camera
			return fileName
			break
		}
		; Delay before checking again
		Sleep, 1000
	}
	return
}

Win2File(WinTitle,Hwnd := "")
{
	if !Hwnd
		WinGet, Hwnd, ID, %WinTitle%
	WinActivate, ahk_id %Hwnd%
	sleep 100
	WinGetPos, X, Y, W, H,  ahk_id %Hwnd%
	pToken := Gdip_Startup()
	pBitmap := Gdip_BitmapFromScreen(X+56 "|" Y+54 "|" W-156 "|" H-83)
	FormatTime, TimeStamp ,, yyyy_MM_dd_HH_mm_ss 
	FileName := TimeStamp ".png"
	FilePath := "C:\Users\" . A_Username . "\Pictures\" . FileName

	Gdip_SaveBitmapToFile(pBitmap, FilePath)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown("pToken")

	; Set background image
	DllCall("SystemParametersInfo", UInt, 0x0014, UInt, 0, Str, FilePath, UInt, 1)
	Run, % FilePath
	sleep 100
	send {LCtrl down}
	send {l down}
	sleep 20
	send {LCtrl up}
	send {l up}
	return FileName
}

initiateLock()
{
	isLocked := true
	;BlockInput, MouseMove
	Loop, 255
	{
		Hotkey, % "~" Format("vk{:x}",A_Index), lockWorkstation, On
	}
	Hotkey, % "!Tab", doNothing, On
	Hotkey, % "#Tab", doNothing, On
	SETTIMER Check_Idle, 5000
}

initiateUnlock()
{
	isLocked := false
	BlockInput, MouseMoveOff
	Loop, 255
	{
		Hotkey, % "~" Format("vk{:x}",A_Index), lockWorkstation, Off
	}
	Hotkey, % "!Tab", doNothing, Off
	Hotkey, % "#Tab", doNothing, Off
	SETTIMER Check_Idle, Delete
	WinClose, Camera
}

secretUnlock:
BlockInput, MouseMoveOff
WinClose, Camera
sleep 100
Reload
return