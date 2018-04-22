;;_______________________________;;
; WinBro 0.xx (Alpha)
; Released under the MIT licence
; Author: Micha? Szulecki
; E-mail: szuru.buru@hotmail.com
;;===============================;;

;========----------------------------------------------------------========;
;========----------------------------------------------------------========;
;========--  A  --  U  --  T  --  O  --  E  --  X  --  E  --  C  --========;
;========----------------------------------------------------------========;
;========----------------------------------------------------------========;

#UseHook
;#Warn All
#NoEnv
#SingleInstance, force
#MaxThreadsBuffer, On
#MaxHotkeysPerInterval, 500 ; Prevents hotkey limit reached warning
#MaxThreadsPerHotkey, 4
#InstallMouseHook
#Persistent
SetControlDelay -1
DetectHiddenWindows On
SetWorkingDir % A_ScriptDir
SetMouseDelay -1
SetWinDelay -1
SetTitleMatchMode 2
GroupAdd FileExplorer, ahk_class CabinetWClass
GroupAdd FileExplorer, ahk_class ExploreWClass
GroupAdd FileExplorer, ahk_class Progman
GroupAdd FileExplorer, ahk_class WorkerW
GroupAdd FileExplorer, ahk_class #32770

;; Global variables
;;;;;;;;;;;;;;;;;;
global apptitle := "WinBro"
global version := "0.83"
global email := "szuru.buru@hotmaiil.com"
global author := "Michał Szulecki"

; KDE variables
;global KDE_winfade_time_in := 50
;global KDE_winfade_time_out := 12
;global KDE_winfade_opacity := 200
global KDE_Mdrag_distance := 100
global KDE_MBReleaseOffset := 60
global KDE_winopacity_lock_effect_time := 5

; Arrays
global Gui_OLSet := Object()
global KDE_MinRestoreHistory := Object()
GuiList=

; File paths
global ini_file := % A_AppData "\Szuruburu\" apptitle "\" A_UserName "Settings.ini"
global tpoc_file := % A_AppData "\Szuruburu\" apptitle "\tpoc.ini"
global ranmsg_file := % A_ScriptDir "\data\rndmsg.txt"

; Volume module
global volume_destroy_time := -1200

; Color palette
global color_main			:= "52bac0"	;global color_main := "00b12d"
global color_aux			:= "e10b46"
global color_main_titletext	:= "bfffff"
global color_main_regulartext	:= "222222"

; Build tray menu
Menu, Tray, Tip,% apptitle " v" version
Menu, Tray, Add, ;-------------------------------
Menu, Tray, Add, ;-------------------------------
Menu, Tray, Add,% "Settings`tCapslock+H",SettingsWindow
Menu, Tray, Add,% "Reload`tShift+Esc",Restart
Menu, Tray, Add,% "Exit " apptitle,Quit
Menu, Tray, icon,%A_ScriptDir%\so.ico
Menu, Tray, click,1

if (!A_IsCompiled || ShowDebugMenu)
	menu,Tray,Standard
else
	menu,Tray,NoStandard

; Initiate libraries
#include %A_ScriptDir%\lib\Acc.ahk ; Required for scrolling in MS Office applications
#include %A_ScriptDir%\lib\HoverScroll.ahk
#include %A_ScriptDir%\lib\SetSystemCursor.ahk

RunCode:
	RestoreCursors()
	FileCreateDir, % A_AppData "\Szuruburu\" apptitle
	iniRead, Autostart, %ini_file%, General, bStartWithWindows, 1
	iniRead, admin_cb_handler, %ini_file%, General, bStartWithAdminRights, 0
	iniRead, KDE_WindowLock_Transparency, %ini_file%, KDElike, iKDElikeWindowTransparency, 240
	iniRead, KDE_winfade_opacity, %ini_file%, KDElike, iKDElikeMoveResizeTransparency, 220
	iniRead, KDE_winfade_time_in, %ini_file%, KDElike, iKDElikeFadeInAnimationDuration, 25
	iniRead, KDE_winfade_time_out, %ini_file%, KDElike, iKDElikeFadeOutAnimationDuration, 12
	iniRead, WL_locked, %tpoc_file%, TempValues, bWL_locked, 0
	iniRead, LOCKED_hwnd, %tpoc_file%, TempValues, idWL_LockedHWND
	
	if (WinExist("ahk_id " LOCKED_hwnd)) {
		iniRead, ct_x, %tpoc_file%, TempValues, iWL_ctx
		iniRead, ct_y, %tpoc_file%, TempValues, iWL_cty
		if (WL_locked == true)
			GoSub, WL_ReleaseButton
	}

	if !FileExist(ini_file) {
		SaveSettings()
	} else {
		CheckWindowsStartup(Autostart)
	}

	ClOff()

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Hotkeys go here
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global modk_main	:= "capslock"
	global modk_alt	:= "alt"
	global modk_shift	:= "shift"
	global modk_ctrl	:= "control"
	global navUp		:= "w"
	global navDown		:= "s"
	global navLeft		:= "a"
	global navRight	:= "d"
	global navAuxUp	:= "q"
	global navAuxDown	:= "e"
	global volModk		:= "#"
	
	global updownjump_size := 4
	
	
	Hotkey, IfWinActive
	
	; GUI testing zone ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;Hotkey, #+1, SplashScreenTest
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Hotkey, %modk_main% & h, SettingsWindow
	Hotkey, +Esc, Restart
	Hotkey, %volModk%WheelUp, VolumeUp
	Hotkey, %volModk%WheelDown, VolumeDown
	Hotkey, %modk_main% & F1, HideDesktopIcons
	Hotkey, %modk_main% & Esc, AnyWindowAlwaysOnTopToggle
	;Hotkey, WheelUp, HoverScroll_ScrollUP, P5000
	;Hotkey, WheelDown, HoverScroll_ScrollDOWN, P5000
	Hotkey, %modk_main% & WheelDown, HoverScroll_ScrollRIGHT, P5000
	Hotkey, %modk_main% & WheelUp, HoverScroll_ScrollLEFT, P5000
	;;;;;; General Environement Navigation
	;;;;;; --in: Navigation.ahk
	Hotkey, %modk_main% & %navUp%, GEN_Up
	Hotkey, %modk_main% & %navDown%, DEN_Down
	Hotkey, %modk_main% & %navLeft%, GEN_Left_Back
	Hotkey, %modk_main% & %navRight%, GEN_Right_Forward
	Hotkey, %modk_main% & %navAuxUp%, GEN_auxUp
	Hotkey, %modk_main% & %navAuxDown%, GEN_auxDown
	Hotkey, %modk_main% & Space, GEN_xEnter_aBackspace
	Hotkey, %modk_main% & r, GEN_Delete
	Hotkey, %modk_main% & z, GEN_Undo
	Hotkey, %modk_main% & c, CenterAndResizeWindow
	Hotkey, %modk_main% & c, GEN_xCopy
	Hotkey, %modk_main% & v, GEN_xPasteNormal
	Hotkey, ^+v, GEN_xPasteCCAndGo
	;;;;;; KDE-like windows moving/resizing
	Hotkey, Space, LockSpacebar
	Hotkey, Space, off
	Hotkey, %modk_main% & RButton, KDE_fResize
	Hotkey, %modk_main% & LButton, KDE_fMove
	Hotkey, %modk_main% & MButton, KDE_fMinMax
	Hotkey, %modk_main% & Tab, KDE_fClose
	;;;;;; File Explorer Navigation
	Hotkey, IfWinActive, ahk_group FileExplorer
	Hotkey, %modk_main% & %navUp%, FEN_xUp_aToTheTop_sSelectToTop
	Hotkey, %modk_main% & %navDown%, FEN_xDown_aToTheBottom_sSelectToBottom
	Hotkey, %modk_main% & %navLeft%, FEN_xLeft_aDirUp_sSelectToLeft
	Hotkey, %modk_main% & %navRight%, FEN_xRight_aDirBack_sSelectToRight
	Hotkey, %modk_main% & Space, FEN_xEnter_aBack
	Hotkey, %modk_main% & %navAuxUp%, FEN_xToTheTop
	Hotkey, %modk_main% & %navAuxDown%, FEN_fToTheBottom
	Hotkey, IfWinActive
	
	if (admin_cb_handler == 1) {
		if not A_IsAdmin
		{
			;MsgBox, % "Running as Admin"
			Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
			ExitApp
		}
	}
	
	GoSub, SplashScreen
return

;==============  THE END OF...
;==============----------------------------------------------------------==============;
;==============----------------------------------------------------------==============;
;==============--  A  --  U  --  T  --  O  --  E  --  X  --  E  --  C  --==============;
;==============----------------------------------------------------------==============;
;==============----------------------------------------------------------==============;

; Initiate modules
#include %A_ScriptDir%\data\Navigation.ahk
#include %A_ScriptDir%\data\ToolTip.ahk
#include %A_ScriptDir%\data\Volume.ahk
#include %A_ScriptDir%\data\Utils.ahk
#include %A_ScriptDir%\data\HideDestkopIcons.ahk
#include %A_ScriptDir%\data\GUI.ahk
#include %A_ScriptDir%\data\Settings.ahk

#IfWinActive

SendUnicodeChar(charCode) {
	VarSetCapacity(ki, 28 * 2, 0)
	EncodeInteger(&ki + 0, 1)
	EncodeInteger(&ki + 6, charCode)
	EncodeInteger(&ki + 8, 4)
	EncodeInteger(&ki +28, 1)
	EncodeInteger(&ki +34, charCode)
	EncodeInteger(&ki +36, 4|2)

	DllCall("SendInput", "UInt", 2, "UInt", &ki, "Int", 28)
}

EncodeInteger(ref, val) {
	DllCall("ntdll\RtlFillMemoryUlong", "Uint", ref, "Uint", 4, "Uint", val)
}

SaveSettings() {
	global
		iniWrite, %Autostart%, %ini_file%, General, bStartWithWindows
		iniWrite, %admin_cb_handler%, %ini_file%, General, bStartWithAdminRights
		iniWrite, %KDE_WindowLock_Transparency%, %ini_file%, KDElike, iKDElikeWindowTransparency
		iniWrite, %KDE_winfade_time_in%, %ini_file%, KDElike, iKDElikeFadeInAnimationDuration
		iniWrite, %KDE_winfade_time_out%, %ini_file%, KDElike, iKDElikeFadeOutAnimationDuration
		iniWrite, %KDE_winfade_opacity%, %ini_file%, KDElike, iKDElikeMoveResizeTransparency
		CheckWindowsStartup(Autostart)
}

Restart:
	Critical
	RestoreCursors()
	;SaveSettings()
	GoSub, ExitCode
	Reload
return

; Tray subroutine
Quit:
	GoSub, ExitCode
	ExitApp
return

ExitCode:
	RestoreCursors()
return



;======================================================================
; Color and position dev tool
capslock & y::
	if (tooltip) {
		gosub HideMouseTip
		return
	}

	MouseGetPos, mX, mY, A_ID
	if (GetKeyState(modkey_shift) == 1) {
		InputBox, mouse_x, X pos, X pos:,, 200, 130
		MouseMove, %mouse_x%, %mY%
		InputBox mouse_y, Y pos, Y pos:,, 200, 130
		MouseMove %mouse_x%, %mouse_y%
		PixelGetColor, pcolor, %mouse_x%, %mouse_y%
		MsgBox, % "color at x" mouse_x ", y" mouse_y ": " pcolor
		clipboard := % pcolor
	} else {
		WinGet, winstate, MinMax, ahk_id %A_ID%
		WinGetTitle, A_title, ahk_id %A_ID%
		WinGetClass, A_class, ahk_id %A_ID%
		pcolor=
		WinGetPos, x, y, wW, wH, ahk_id %A_ID%
		PixelGetColor, pcolor, %mX%, %mY%
		data1 := % "mouse_x: " mX "`nmouse_y: " mY "`npixel_color: " pcolor "`n" DrawLine("-",5) "`n"
		data2 := % "win_x: " x "`nwin_y: " y "`nwin_w: " wW "`nwin_h: " wH "`nwin_title: " A_title "`nwin_ID: " A_ID "`nwin_class: " A_class "`n" DrawLine("-",5) "`n"
		
		data3 := % (winstate = -1) ? "state: min"
			: (winstate = 1) ? "state: max"
			: (winstate = 0) ? "state: normal"
			: data3
		
		data4 := %  DrawLine("-",5) "`nA_ScreenWidth: " A_ScreenWidth "`nA_ScreenHeight: " A_ScreenHeight
		
		data := % data1 data2 data3 data4
		MouseTipUpdateInterval := 10
		Tip(data)
		
			;MsgBox, % data1 data2
		clipboard := % "/*`n" data "`n*/"
	}
return

; Returns 1 if even, 0 if odd
EvenSteven(n) {
	return mod(n, 2) = 0
}

ClickPic(imove_x:=0, imove_y:=0, ind_toggle:=true,sendButton:="left", clickcount:="1") {
	global sx, sy, CLK_hwnd
	
	if errorlevel
		return
	
	if (ind_toggle == false) {
		BlockInput, Mousemove
		mouseGetPos mx, my
		move_x:=sx+imove_x
		move_y:=sy+imove_y
		
		Critical
		Send, {blind down}
		MouseClick, %sendButton%, %move_x%, %move_y%, %clickcount%
		Send, {blind up}
		Critical off
		mouseMove %mx%, %my%
		BlockInput, MousemoveOff
	} else {
		WinGetPos, wx, wy,,,A
		BlockInput, Mousemove
		mouseGetPos mx, my
		move_x:=sx+imove_x
		move_y:=sy+imove_y
		
		Critical
		Send, {blind down}
		MouseClick, %sendButton%, %move_x%, %move_y%
		Send, {blind up}
		Critical off
		mouseMove %mx%, %my%
		BlockInput, MousemoveOff
		
		time:=1
		fW:=20
		fH:=20
		indx:=move_x+wx-(fW/3)
		indy:=move_y+wy-(fH/3)
		
		GoSub, ClickIndicatorDestroy
		Gui, ClickInd: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
		CLK_hwnd := WinExist()
		WinSet, ExStyle, +0x20
		WinSet, Region,0-0 w%fW% h%fH% r50-50
		Gui, ClickInd: Color, 0x00D0FA
		
		Gui, ClickInd: Show, w%fW% h%fH% x%indx% y%indy% NoActivate
		GoSub, ClickIndicatorDestroy
	}
}

; Args
; x1 : the HORIZONTAL position of the TOP LEFT corner point of a search box
; y1 : the VERTICAL position of the TOP LEFT corner point of a search box
; x2 : the HORIZONTAL position of the BOTTOM RIGHT corner point of a search box
; y2 : the VERTICAL position of the BOTTOM RIGHT corner point of a search box
; oc : only check - doesn't click on the pic, just checking it's there
; xO : x position of an offset to a mouse click
; yO : y position of an offset to a mouse click
; click_indicator : points the position of a click with a blue, semi-transparent circle
; btn : which mouse (and/or with a keyboard modifier) button is clicked

ImgSearch(file_path, x1:=0, y1:=0, ix2:=0, iy2:=0, oc:=false, xO:=0, yO:=0, click_indicator:=true, btn:="left",clickcount:="1") {
	global imgFound, sx, sy, wH, wW, x2, y2
	imgFound=
	
	WinGetPos,,,wW,wH,A
	
	if (ix2 == 0 && iy2 != 0) {
		x2:=wW
		y2:=iy2
	} else if (ix2 != 0 && iy2 == 0) {
		x2:=ix2
		y2:=wH
	} else if (ix2 == 0 && iy2 == 0) {
		x2:=wW
		y2:=wH
	}	else {
		x2:=ix2
		y2:=iy2
	}
	
	if (oc == true)
	{
		imageSearch sx, sy, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\data\img-search\%file_path%
		
		if errorlevel {
			imgFound:=false
		} else if (errorlevel == 0) {
			imgFound:=true
		}
	}
	
	else if (oc == false)
	{
		imageSearch sx, sy, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\data\img-search\%file_path%
		
		if errorlevel	{
			imgFound:=false
		}	else if (errorlevel == 0)	{
			imgFound:=true
			ClickPic(xO, yO, click_indicator, btn, clickcount)
		}
	}
}

; Paste w/o ClipboardCleaner
GEN_xPasteNormal:
	if (GetKeyState(modk_shift) == 1)
		Send, ^v{Enter}
	else
		Send, ^v
return

GEN_xCopy:
	Send, ^c
return

; Paste w/ ClipboardCleaner
; check for inserts
GEN_xPasteCCAndGo:
	gosub, GEN_xPasteCC
	Send, {Enter}
return

ClipboardCleaner:
	data := clipboard
	clipboard=
	data := RegExReplace(data, "^\s+","")
	data := RegExReplace(data, "\t+","")
	telepos := RegExMatch(data, "\w{5}\.\d{5}\.\w{3}\/\w{1}\d{3}")
	if (telepos > 0) {
		bscs_processed := SubStr(data, 1, 11)
		data=%bscs_processed%
	}

	loop {
		StringReplace, data, data, %A_Tab%,,all
		StringReplace, data, data, %A_Space%%A_Space%%A_Space%, %A_Space%, all
		StringReplace, data, data, %A_Space%%A_Space%, %A_Space%, all
		if errorlevel <> 0
			break
	}

	data := RTRim(data)
	clipboard := data
	clipwait
return

GEN_xPasteCC:
	WinGetClass, A_class, A
	WinGetTitle, A_title, A
	if !(A_class=="Notepad++") &&
		!(A_title~="^AHK Studio") {
			gosub ClipboardCleaner
			Send, ^v
		} else {
		Send, ^v
	}
return

#ifWinActive ahk_class MSPaintApp
^v:: SendInput, ^v
#ifWinActive ahk_group FileExplorer
^v::SendInput, ^v
#IfWinActive ahk_class Photoshop
^v::SendInput, ^v

#ifWinActive

AnyWindowAlwaysOnTopToggle:
	WinGet, OnTop, ExStyle, A
	if (OnTop & 0x8) {
			;Gui, AOTBorder: Destroy
		WinSet, AlwaysOnTop, Off, A
	} else {
		WinSet, AlwaysOnTop, On, A
			;gosub, DrawBorder
	}
return

ClOff() {
	setcapslockState, AlwaysOff
}

$*capslock up::ClOff()

;_________________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DESTROYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;=================================================================

SplashDestroy:
	SetTimer, SplashDestroy, Off
	WinFade("ahk_id " SC_hwnd,0,35)
	WinFade("ahk_id " SCSH_hwnd,0,15)
	Gui, SplashScreen: Destroy
	Gui, SplashShadow: Destroy
return

SettingsDestroy:
	WinFade("ahk_id " SET_hwnd,0,35)
	Gui, Settings: Destroy
return

; Caret loosing focus from input fields on frame-based website (CRM_M, Opti) after switching tabs with ctrl+tab / ctrl+shift+tab
#ifWinActive ahk_class MozillaWindowClass
	
^tab::
SendInput, ^{pgdn}
return

^+tab::
SendInput, ^{pgup}
return

+wheelUp::
return

+wheelDown::
return


