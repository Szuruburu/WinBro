;;_______________________________;;
; WinBro 1.xx
; Released under the MIT licence
; Author: Michał Szulecki
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

; Global variables, "g_" prefix is arbitrary
global AppTitle := "WinBro"
global Version := "0.4"

; KDE variables
global KDE_winfade_time_in := 50
global KDE_winfade_time_out := 12
global KDE_winfade_opacity := 200
global KDE_Mdrag_distance := 100
global KDE_MBReleaseOffset := 60
global KDE_winopacity_lock_opacity := 180
global KDE_winopacity_lock_effect_time := 5

global RunBrowser1:="iexplore.exe"
global RunBrowser2:="firefox.exe"
global logFile := A_ScriptDir "\log.txt"
global iniFile := % A_AppData "\Szuruburu\" AppTitle "\" A_UserName "Settings.ini"

; Arrays
global Gui_OLIndex := 1
global Gui_OLSet := Object()
global KDE_MinRestoreHistory := Object()
GuiList=

global VolumeDestroyTime := -1200

WM_MOUSEHOVER = 0x200
TME_HOVER := 0x1
TME_CANCEL := 0x80000000

; Initiate libraries
#include lib\Acc.ahk ; Required for scrolling in MS Office applications
#include lib\HoverScroll.ahk
#include lib\JSON_ToObj.ahk
#include lib\SetSystemCursor.ahk
Menu, Tray, Tip,% AppTitle " v" Version
Menu, Tray, Add,% "Settings `tCapslock+O",SettingsWindow
Menu, Tray, Add,% "Captain's log",_log_open
Menu, Tray, default,% "Captain's log"
Menu, Tray, Add, ;-------------------------------
Menu, Tray, Add, ;-------------------------------
Menu, Tray, Add,% "Clear logs",_log_erase
Menu, Tray, Add,% "Restart`tShift+Esc",Restart
Menu, Tray, Add,% "Close " AppTitle,Quit
Menu, Tray, icon,%A_ScriptDir%\so.ico
Menu, Tray, click,1

if (!A_IsCompiled || ShowDebugMenu)
	menu,Tray,Standard
else
	menu,Tray,NoStandard

RunCode:
RestoreCursors()
FileCreateDir, % A_AppData "\Szuruburu\" AppTitle
iniRead, Autostart, %iniFile%, General, bStartWithWindows, 1
iniRead, ALMouseHoverThresholdSetting, %iniFile%, General, iALMouseHoverThresholdSetting, 5

if !FileExist(iniFile) {
	SaveSettings()
} else {
	CheckWindowsStartup(Autostart)
}

; log file format:
; "[Action:ie."Sprawdzenie klienta w Gus"]" _log_timestamp [variable] "," [variable] "," ...
log_header_line := DrawLine("=",62)
fileReadLine, _log_firstline, %logFile%, 1

global _log_mainheader := % "Captain's log, " A_UserName "`n" A_YYYY "-" A_MM "-" A_DD ", time: " A_Hour "." A_Min "`n" log_header_line "`n"
if !InStr(_log_firstline, "Captain's log")
	fileAppend, %_log_mainheader%, %logFile%

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

Hotkey, IfWinActive
Hotkey, +Esc, Restart
Hotkey, #WheelUp, VolumeUp
Hotkey, #WheelDown, VolumeDown
Hotkey, %modk_main% & o, SettingsWindow
Hotkey, #F1, HideDesktopIcons
; Hotkey, ``, LinkBarGui
Hotkey, %modk_main% & Esc, AnyWindowAlwaysOnTopToggle
;Hotkey, WheelUp, HoverScroll_ScrollUP, P5000
;Hotkey, WheelDown, HoverScroll_ScrollDOWN, P5000
Hotkey, %modk_main% & WheelDown, HoverScroll_ScrollRIGHT, P5000
Hotkey, %modk_main% & WheelUp, HoverScroll_ScrollLEFT, P5000
; General Environement Navigation
;--in: Navigation.ahk
Hotkey, %modk_main% & %navUp%, GEN_xUp_aToTheTop_sEOL
Hotkey, %modk_main% & %navDown%, GEN_xDown_aToTheBottom_sBOL
Hotkey, %modk_main% & %navLeft%, GEN_xLeft_aBack_sSelectToLeft_cSelectTLW
Hotkey, %modk_main% & %navRight%, GEN_xRight_aForward_sSelectToRight_cSelectTRW
Hotkey, %modk_main% & %navAuxUp%, GEN_Home_mScrollLeft_mmfToTheTop
Hotkey, %modk_main% & %navAuxDown%, GEN_End_mScrollRight_mmfToTheBottom
Hotkey, %modk_main% & Space, GEN_Enter_mBackspace
Hotkey, %modk_main% & r, GEN_Delete
Hotkey, %modk_main% & x, GEN_Delete_alt
Hotkey, %modk_main% & z, GEN_Undo
Hotkey, %modk_main% & c, CenterAndResizeWindow
Hotkey, IfWinActive
Hotkey, %modk_main% & c, GEN_fCopy
Hotkey, %modk_main% & v, GEN_fPasteNormal
Hotkey, ^+v, GEN_fPasteCCAndGo
;Hotkey, IfWinNotActive, ahk_class XLMAIN
;Hotkey, ^v, GEN_fPasteCC
; KDE-like windows moving/resizing
Hotkey, %modk_main% & RButton, KDE_fResize ; turned off on native GUI (in the subroutine), it's designed to be of a fixed size
Hotkey, %modk_main% & LButton, KDE_fMove
Hotkey, %modk_main% & MButton, KDE_fMinMax
Hotkey, %modk_main% & Tab, KDE_fClose
; File Explorer Navigation
Hotkey, IfWinActive, ahk_group FileExplorer
Hotkey, %modk_main% & %navUp%, FEN_Up_mfToTheTop_mmsSelectToTop
Hotkey, %modk_main% & %navDown%, FEN_Down_mfToTheBottom_mmsSelectToBottom
Hotkey, %modk_main% & %navLeft%, FEN_Left_mfDirUp_mmsSelectToLeft
Hotkey, %modk_main% & %navRight%, FEN_Right_mfDirBack_mmsSelectToRight
Hotkey, %modk_main% & Space, FEN_Enter_mfBack
Hotkey, %modk_main% & %navAuxUp%, FEN_fToTheTop
Hotkey, %modk_main% & %navAuxDown%, FEN_fToTheBottom
Hotkey, IfWinActive

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}

SplashScreen()
;	LinkBarLauncher()
	; gosub, ToolKit
;	SetTimer, ActivateLauncher, 1000
return

;==============  THE END OF...
;==============----------------------------------------------------------==============;
;==============----------------------------------------------------------==============;
;==============--  A  --  U  --  T  --  O  --  E  --  X  --  E  --  C  --==============;
;==============----------------------------------------------------------==============;
;==============----------------------------------------------------------==============;

SendUnicodeChar(charCode)
{
	VarSetCapacity(ki, 28 * 2, 0)
	EncodeInteger(&ki + 0, 1)
	EncodeInteger(&ki + 6, charCode)
	EncodeInteger(&ki + 8, 4)
	EncodeInteger(&ki +28, 1)
	EncodeInteger(&ki +34, charCode)
	EncodeInteger(&ki +36, 4|2)

	DllCall("SendInput", "UInt", 2, "UInt", &ki, "Int", 28)
}

EncodeInteger(ref, val)
{
	DllCall("ntdll\RtlFillMemoryUlong", "Uint", ref, "Uint", 4, "Uint", val)
}

UpdateLogSliderVar:
GuiControl,,ALMHT_handler, % ALMouseHoverThresholdSetting
return

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}

; Initiate modules
#include %A_ScriptDir%\modules\CP.ahk
#include %A_ScriptDir%\modules\Navigation.ahk
#include %A_ScriptDir%\modules\Excel.ahk
; #include %A_ScriptDir%\modules\LinkBar.ahk
#include %A_ScriptDir%\modules\ToolTip.ahk
#include %A_ScriptDir%\modules\Log.ahk
#include %A_ScriptDir%\modules\FloGUI.ahk
#include %A_ScriptDir%\modules\Volume.ahk
#include %A_ScriptDir%\modules\Utils.ahk
#include %A_ScriptDir%\modules\HideDestkopIcons.ahk

; Additional data
#include %A_ScriptDir%\data\Webapp.ahk
#include %A_ScriptDir%\data\pwb.ahk
#include %A_ScriptDir%\data\Gdip.ahk
#include %A_ScriptDir%\data\GdipHelper.ahk

#IfWinActive
SaveSettings() {
		global
		iniWrite, %Autostart%, %iniFile%, General, bStartWithWindows
		CheckWindowsStartup(Autostart)
		iniWrite, %ALMouseHoverThresholdSetting%, %iniFile%, General, iALMouseHoverThresholdSetting
	}

DefaultSettings:
DialogWindow("Sure?",240,"Restore defaults","ConfirmDefault")
return

ConfirmDefault:
fileDelete, %iniFile%
gosub, DialogDestroy

if (pwb) && (WinExist("ahk_id " WEBGUI_hwnd)) {
	Gui, 90: Destroy
}

if (pwb) {
	pwb.quit()
}

if (__Webapp_wb) {
	__Webapp_wb.quit()
}
/*
	if (WinExist("ahk_id " LBr_hwnd)) {
		gosub LinkBarDestroy
	} 
*/
gosub, Restart
return

ButtonSave:
Gui, Submit
SaveSettings()
gosub, CPDestroy
gosub, SettingsDestroy

if (pwb)
	pwb.quit()
gosub, Restart
return

CheckWindowsStartup(enable) {
	LinkFile=%A_Startup%\%AppTitle%.lnk
	if !FileExist(LinkFile) {
		if (enable) {
			FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
		}
	} else {
		if (!enable) {
			FileDelete, %LinkFile%
		}
	}
}

; Restart the app
/*
+esc::
gosub, Restart
return
*/

Restart:
Critical
RestoreCursors()
gosub ExitCode
	;gosub _logREL
reload
return

; Tray subroutine
Quit:
if A_ExitReason not in Logoff, Shutdown
{
	DialogWindow("Leaving " AppTitle "?",240,"Close", "ConfirmQuit")
}

else
	gosub ConfirmQuit
return

ExitCode:
if (FileExist(tempvar))
	FileDelete, % tempvar

RestoreCursors()
;	gosub, LBrLauncherDestroy
log_erase_elapsed_time := A_TickCount - log_erase_start_time
FileAppend, % log_erase_elapsed_time "`n", % tempvar
return

ConfirmQuit:
if !(WinExist("ahk_id " DIALOG_hwnd)) {
	gosub DialogDestroy
}

gosub ExitCode
FileDelete, % logFile
ExitApp
return



;======================================================================
; Color and position dev tool
capslock & y::
if (tooltip) {
	gosub HideMouseTip
	return
}

MouseGetPos, mX, mY, A_ID
if (getkeystate(modkey_shift) == 1) {
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
		send {blind down}
		MouseClick, %sendButton%, %move_x%, %move_y%, %clickcount%
		send {blind up}
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
		send {blind down}
		MouseClick, %sendButton%, %move_x%, %move_y%
		send {blind up}
		Critical off
		mouseMove %mx%, %my%
		BlockInput, MousemoveOff
		
		time:=1
		fW:=20
		fH:=20
		indx:=move_x+wx-(fW/3)
		indy:=move_y+wy-(fH/3)
		
		ClickIndDestroy()
		Gui, ClickInd: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
		CLK_hwnd := WinExist()
		WinSet, ExStyle, +0x20
		WinSet, Region,0-0 w%fW% h%fH% r50-50
		Gui, ClickInd: Color, 0x00D0FA
		
		Gui, ClickInd: Show, w%fW% h%fH% x%indx% y%indy% NoActivate
		ClickIndDestroy()
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
GEN_fPasteNormal:
if (getkeystate(modk_shift) == 1)
	send ^v{enter}

else
	send ^v
return

GEN_fCopy:
send ^c
return

; Paste w/ ClipboardCleaner
; check for inserts

GEN_fPasteCCAndGo:
gosub, GEN_fPasteCC
send {enter}
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

GEN_fPasteCC:
WinGetClass, A_class, A
WinGetTitle, A_title, A
if !(A_class=="Notepad++") &&
	!(A_title~="^AHK Studio") {
		gosub ClipboardCleaner
		send ^v
	} else {
	send ^v
}
return

#ifWinActive ahk_class MSPaintApp
	^v:: 
sendinput ^v
return
#ifWinActive ahk_group FileExplorer
	^v::
sendinput ^v
return
#IfWinActive ahk_class Photoshop
	^v::
sendinput ^v
return

#ifWinActive
	
DrawBorder:
WinGetPos, BWinX, BWinY, BWinW, BWinH, A
Gui, AOTBorder: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
AOTB_hwnd := WinExist()
WinSet, Transparent, 255
WinSet, ExStyle, +0x20
Gui, AOTBorder: Color, 0xFF1010
Gui, AOTBorder: Show, x%BWinX% y%BWinY% w%BWinW% h%BWinH% NoActivate
return

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

$*capslock up::
ClOff()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Contextual hotkeys for WorkFlo's GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#if WinActive("ahk_id " LR_hwnd)
	
^+s::
gosub LogReaderSaveAs
return

^w::
gosub LogReaderAlwaysOnTopToggle
return

#if WinActive("ahk_id " SETTINGS_hwnd)
	
esc::
gosub SettingsDestroy
winActivate ahk_id %CONTROL_hwnd%
return

#if WinActive("Restore default") && WinActive("ahk_id " DIALOG_hwnd)
	
enter::
gosub ConfirmDefault
return

esc::
gosub DialogDestroy
return

#if WinActive("Close") && WinActive("ahk_id " DIALOG_hwnd)
	
enter::
gosub ConfirmQuit
return

esc::
gosub DialogDestroy
return

#If WinActive("ahk_id " CONTROL_hwnd)
	
; Toned down a bit for smoothety
WheelUp::
Lines := ScrollLines_3(1, 10, 0, 1)
HoverScroll(Lines)
return

WheelDown::
Lines := -ScrollLines_3(1, 10, 0, 1)
HoverScroll(Lines)
return

esc::
gosub CPDestroy
return

; Disable zooming in and out the ActiveX GUI component
; GUI's designed to be of a fixed size

^wheelup::
return
^wheeldown::
return
^=::
return
^-::
return

~LButton:: ; cheap fix to reattach JS_AHK
gosub __Webapp_JS_AHK_Attach
return

; Tab and Shift+Tab to go through tabs

^tab::
if (tabCount == 1) {
	gosub __Wb_GotoTab2
} else if (tabCount == 2) {
	gosub __Wb_GotoTab3
} else if (tabCount == 3) {
	gosub __Wb_GotoTab4
} else {
	gosub __Wb_GotoTab1
}
return

^+tab::
if (tabCount == 4) {
	gosub __Wb_GotoTab3
} else if (tabCount == 3) {
	gosub __Wb_GotoTab2
} else if (tabCount == 2) {
	gosub __Wb_GotoTab1
} else {
	gosub __Wb_GotoTab4
}
return

;_________________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DESTROYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;=================================================================

#ifWinActive
	/*
	LBrLauncherDestroy:
	if (WinExist("ahk_id " LBrL_hwnd)) {
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 18, lbl_Y
			Sleep, 25/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 15, lbl_Y
			Sleep, 25/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 12, lbl_Y
			Sleep, 30/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 9, lbl_Y
			Sleep, 35/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 6, lbl_Y
			Sleep, 39/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 4, lbl_Y
			Sleep, 43/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 2, lbl_Y
			Sleep, 49/2
			WinMove, % "ahk_id " LBrL_hwnd,,lbl_X - 1, lbl_Y
			Gui, LBrLauncher: Destroy
			SetTimer, ActivateLauncher, 1000
		}
	return
	
	LinkBarDestroy:
	LinkBarGuiEscape:
	LinkBarGuiClose:
	if WinExist("ahk_id " LBr_hwnd)
	{
			LinkBarLauncher()
			WinFade("ahk_id " LBr_hwnd,0,35)
			Gui, LinkBar: Destroy
		}
	return
	
*/
; A solution for dynamic variables error
; when closing GUI with F4 and reopening again
!F4::
WinGet, hwnd_ID, ID, A
if (hwnd_ID == CONTROL_hwnd) {
	gosub CPDestroy
} else if (hwnd_ID == SETTINGS_hwnd) {
	gosub SettingsDestroy
} else if (hwnd_ID == DIALOG_hwnd) {
	gosub DialogDestroy
} else {
	SendInput !{F4}
	Sleep 200
}
return

LogReaderDestroy:
LogReaderGuiEscape:
LogReaderGuiClose:
if WinExist("ahk_id " LR_hwnd)
{
	WinFade("ahk_id " LR_hwnd,0,35)
	Gui, LogReader: Destroy
}
return

LockScreenDestroy:
LockScreenGuiEscape:
if WinExist("ahk_id " LockS_hwnd)
{
	WinFade("ahk_id " LockS_hwnd,0,15)
	Gui, LockScreen: Destroy
}
return

WorkingDestroy:
if WinExist("ahk_id " LOAD_hwnd)
{
	SetTimer, WorkingDestroy, off
	WinFade("ahk_id " LOAD_hwnd,0,5)
	Gui, Work: Destroy
}
return

CornerDoneDestroy:
global CD_hwnd, cdsaved ; cd_position
if WinExist("ahk_id " CD_hwnd)
{
	SetTimer,CornerDoneDestroy,off
	end_x:=330
	x:=0
	
	CornerNotify("Nowy zapis w dzienniku!",cdsaved,,,3,1000)
	
	Gui, cdsh: Destroy
			;Gui, cdsh: Destroy
	WinFade("ahk_id " CD_hwnd,0,8)
	Gui, CDone: Destroy
}
return

CNotifyDestroy:
SetTimer, CNotifyDestroy, Off

if WinExist("ahk_id" CNOT_hwnd)
{
	Gui, cnot: Destroy
	WinFade("ahk_id " CNOT_hwnd,0,30)
	Gui, CNotify: Destroy
}
return

SplashDestroy:
SetTimer, SplashDestroy, Off
WinFade("ahk_id " SC_hwnd,0,35)
WinFade("ahk_id " SCSH_hwnd,0,15)
Gui, Notify: Destroy
Gui, AniGIF: Destroy
Gui, SplashShadow: Destroy
return

SettingsDestroy:
gosub UpdateLogSliderVar
Gui, Settings: Destroy
return

NotifyDestroy:
SetTimer, NotifyDestroy, Off
Gui, not: Destroy
WinFade("ahk_id " NOT_hwnd,0,15,2)
Gui, Notify: Destroy
Sleep, 1000
return

DialogDestroy:
WinSet,ExStyle,+0x20, ahk_id %DIALOG_hwnd%
WinSet,ExStyle,+0x20, ahk_id %SHD_hwnd%
WinSet,ExStyle,+0x20, ahk_id %SHD_hwnd_bak%
WinFade("ahk_id" DIALOG_hwnd,0,25)
Gui, Dialog: Destroy
WinFade("ahk_id" SHD_hwnd,0,25)
return

CPDestroy:
if (WinExist("ahk_id" DIALOG_hwnd)) {
	gosub DialogDestroy
}

if (WinExist("ahk_id" SETTINGS_hwnd)) {
	gosub SettingsDestroy
}

Gui, __Webapp_: Destroy
return

CNLookForEsc:
getkeystate, kEsc_state, Esc
if (kEsc_state == D)
	gosub CNotifyDestroy
return

; Caret loosing focus from input fields on frame-based website (CRM_M, Opti) after switching tabs with ctrl+tab / ctrl+shift+tab
#ifWinActive ahk_class MozillaWindowClass
	
^tab::
sendinput ^{pgdn}
return

^+tab::
sendinput ^{pgup}
return

+wheelUp::
return

+wheelDown::
return


