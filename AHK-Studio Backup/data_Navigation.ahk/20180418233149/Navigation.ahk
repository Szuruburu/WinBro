;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GENERAL ENVIRONMENT NAVIGATION:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	[HOLD] CAPSLOCK +
;	{
;
;		w = up
;			+ shift + w = b/o
;			+ alt + w = ctrl + home
;
;		s = down
;			+ shift + w = b/o
;			+ alt + s = ctrl + end
;
;		a = left
;			+ alt + a = back (shift+left)
;
;		d = right
;			+ alt + d = forward (shift+right)
;	}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GEN_Up:
if (getkeystate(modk_alt) == 1)
	SendInput, {PgUp}

else if (getkeystate(modk_ctrl) == 1)
	SendInput, ^{Up}

else
	SendInput, {Up}
return

DEN_Down:
if (getkeystate(modk_alt) == 1)
	SendInput, {PgDn}

else if (getkeystate(modk_ctrl) == 1)
	SendInput, ^{Down}

else
	SendInput, {Down}
return

GEN_Left_Back:
if (getkeystate(modk_alt) == 1)
	SendInput, !{Left}

else if (getkeystate(modk_shift) == 1)
	SendInput, +{Left}

else if (getkeystate(modk_ctrl) == 1)
	SendInput, ^{Left}

else
	SendInput, {Left}
return

GEN_Right_Forward:
if (getkeystate(modk_alt) == 1)
	SendInput, !{Right}

else if (getkeystate(modk_shift) == 1)
	SendInput, +{Right}

else if (getkeystate(modk_ctrl) == 1)
	SendInput, ^{Right}

else
	SendInput, {Right}
return

GEN_auxUp:
	if (getkeystate(modk_alt) == 1) {
		Lines := -ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
		HoverScroll(Lines, 0) ;0 = horizontal, 1 (or omit) = vertical
		return
	} else if (getkeystate(modk_ctrl) == 1) {
		Send, +{Home}
	} else if (getkeystate(modk_shift) == 1) {
		Send, +{Home}
	} else {
		Send, {Home}
	}
return

GEN_auxDown:
	if (getkeystate(modk_alt) == 1) {
		Lines := ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
		HoverScroll(Lines, 0) ;0 = horizontal, 1 (or omit) = vertical
		return
	}  else if (getkeystate(modk_ctrl) == 1) {
		Send, +{Home}
	} else if (getkeystate(modk_shift) == 1) {
		Send, +{End}
	}

	else
		Send, {End}
return

GEN_xEnter_aBackspace:
	if (getkeystate(modk_shift) =+ 1)
		SendInput, {backspace}
	else if (getkeystate(modk_ctrl) == 1)
		SendInput, ^{Enter}
	else
		SendInput, {Enter}
return

; Delete
GEN_Delete:
SendInput, {Delete}
return

; Undo
GEN_Undo:
SendInput, ^z
return

CenterAndResizeWindow:
		margin := 220
		w := A_ScreenWidth - 2 * margin
		h := A_ScreenHeight - margin
		x := (A_ScreenWidth / 2) - (w / 2)
		y := (A_ScreenHeight / 2) - (h / 2)
		WinMove, A,,x,y,w,h
return

ActivateWindow() {
	DetectHiddenWindows Off
	WinGet, WinList, List,,, Program Manager
	loop, %WinList% {
		Current := WinList%A_Index%
		WinGetTitle, WinTitle, ahk_id %Current%
		if WinTitle
			List .= WinTitle "`n"
	}
	
	clipboard := List
	DetectHiddenWindows On
}

; Close window on mouse hover
KDE_fClose:
	MouseGetPos,,,Close_ID
	WinClose, ahk_id %Close_ID%
	Sleep, 200
return

LastMinimizedWindow() {
	WinGet, Windows, List
	Loop, %Windows%
	{
		WinGet, WinState, MinMax, % "ahk_id" Windows%A_Index%
		if (WinState = -1)
		return Windows%A_Index%
	}
}

; Minimize windows on mouse cursor with caps held down and mmb clicked on the window
; Unminimize the most recently minimized window with SHIFT
; Maximize and restore windows with ALT
KDE_fMinMax:
	MouseGetPos,,, MinMax_id
	WinGetClass, MinMax_class, ahk_id %MinMax_id%
	WinGetTitle, MinMax_title, ahk_id %MinMax_id%

	if !(MinMax_id=SETTINGS_hwnd) &&
	!(MinMax_id=LBr_hwnd) &&
	!(MinMax_id=LBrL_hwnd) &&
	!(MinMax_class="Progman") &&
	!(MinMax_class="DV2ControlHost") &&
	!(MinMax_class="Shell_TrayWnd") &&
	!(MinMax_class="SysListView32") &&
	!(MinMax_class="#32768") &&
	!(MinMax_class="WorkerW") &&
	!(MinMax_class="ConsoleWindowClass") &&
	!(MinMax_title="DyspoWindow") {
		;WinActivate ahk_id %MinMax_id%
		if (getkeystate(modk_shift) = 1) {
			gosub RetrieveLastMinimized
			return
		}
		
		if (getkeystate(modk_alt) = 1) {
			WinGet maxCheck, minMax, ahk_id %MinMax_id%
			
			if (maxCheck = 1) {
				WinRestore, ahk_id %MinMax_id%
				return
			} else {
				WinMaximize, ahk_id %MinMax_id%
				return
			}
		} else {
			KDE_MinRestoreHistory.Push(MinMax_id)
			WinMinimize, ahk_id %MinMax_id%
			return
		}
	} else {
		if (getkeystate(modk_shift) = 1) {
			gosub RetrieveLastMinimized
			return
		}
	}
return

RetrieveLastMinimized:
	MinMax_PW_id := KDE_MinRestoreHistory.Pop()
	/*
	KDE_MinRestoreHistory.ShowMe := Func("ShowMe")
	KDE_MinRestoreHistory.ShowMe()
	*/
	WinRestore, ahk_id %MinMax_PW_id%
	WinActivate, ahk_id %MinMax_PW_id%
return

; Resize window under the cursor, KDE-like
KDE_fResize:
	CoordMode, Mouse
	MouseGetPos, KDEr_X1, KDEr_Y1, KDEr_id
	WinGetTitle, KDEr_title, ahk_id %KDEr_id%
	WinGetClass, KDEr_class, ahk_id %KDEr_id%
	WinGet, WinState, MinMax, ahk_id %KDEr_id%
	if (WinState = 1)
		return

	if !(KDEr_id=CONTROL_hwnd) &&
	!(KDEr_id=LBr_hwnd) &&
	!(KDEr_id=LBrL_hwnd) &&
	!(KDEr_class="DV2ControlHost") &&
	!(KDEr_class="Progman") &&
	!(KDEr_class="Shell_TrayWnd") &&
	!(KDEr_class="WorkerW") &&
	!(KDEr_class = "Windows.UI.Core.CoreWindow") &&
	!(KDEr_class ="ConsoleWindowClass") &&
	!(KDEr_title="DyspoWindow") {
		WinGet, WinTrans, Transparent, ahk_id %KDEr_id%
		if (WinTrans <> KDE_winfade_opacity) {
			WinSet, Transparent, %KDE_winfade_opacity%, ahk_id %KDEr_id%
			;WinFade("ahk_id " KDEr_id, KDE_winfade_opacity, KDE_winfade_time_in, true,,true)
		} else {
			WinGet, WinCurrentTrans, Transparent, ahk_id %KDEr_id%
			WinSet, Transparent, %WinCurrentTrans%, ahk_id %KDEr_id%
		}
		
		SetSystemCursor("IDC_SIZEALL")
		; Get the initial window position and size.
		WinGetPos KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDEr_id%
		; Define the window region the mouse is currently in.
		; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
		if (KDEr_X1 < KDE_WinX1 + KDE_WinW / 2)
			KDE_WinLeft := 1
		else
			KDE_WinLeft := -1
		if (KDEr_Y1 < KDE_WinY1 + KDE_WinH / 2)
			KDE_WinUp := 1
		else
			KDE_WinUp := -1
		
		loop
		{
			getkeystate KDEr_Button, RButton, P
			if (KDEr_Button = "U")
				break
			
			MouseGetPos KDEr_X2, KDEr_Y2 ; Get the current mouse position.
			; Get the current window position and size.
			WinGetPos KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDEr_id%
			KDEr_X2 -= KDEr_X1 ; Obtain an offset from the initial mouse position.
			KDEr_Y2 -= KDEr_Y1
			; Then, act according to the defined region.
			WinMove ahk_id %KDEr_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDEr_X2 ; X of resized window
			, KDE_WinY1 + (KDE_WinUp+1)/2*KDEr_Y2 ; Y of resized window
			, KDE_WinW - KDE_WinLeft *KDEr_X2 ; W of resized window
			, KDE_WinH - KDE_WinUp *KDEr_Y2 ; H of resized window
			KDEr_X1 := (KDEr_X2 + KDEr_X1) ; Reset the initial position for the next iteration.
			KDEr_Y1 := (KDEr_Y2 + KDEr_Y1)
		}
	}
	
	getkeystate KDEm_Button, LButton, P
	if (KDEm_Button = "U") {
		RestoreCursors()
		WinGet, WinTrans, Transparent, ahk_id %KDEr_id%
		if (WinTrans != KDE_winopacity_lock_opacity) {
			WinFade("ahk_id " KDEr_id,255,KDE_winfade_time_out)
		}
		Winset, Redraw,,ahk_id %KDEr_id%
	}
return

SpaceBarOn_Delay:
	Hotkey, Space, off
return

; Move windows with caps and lmb
KDE_fMove:
	CoordMode, Mouse
	MouseGetPos, MouseStartX, MouseStartY, KDEm_id
	WinGetClass, KDEm_class, ahk_id %KDEm_id%
	WinGetTitle, KDEm_title, ahk_id %KDEm_id%
	WinGetPos, OriginalPosX, OriginalPosY,,, ahk_id %KDEm_id%
	
	if !(KDEm_id=LBr_hwnd) &&
	!(KDEm_id=LBrL_hwnd) &&
	!(KDEm_class="DV2ControlHost") &&
	!(KDEm_class="Progman") &&
	!(KDEm_class = "Windows.UI.Core.CoreWindow") &&
	!(KDEm_class="Shell_TrayWnd") &&
	!(KDEm_class="WorkerW") &&
	!(KDEm_class ="ConsoleWindowClass") &&
	!(KDEm_title="DyspoWindow") {
		WinGet, WinTrans, Transparent, ahk_id %KDEm_id%
		if (WinTrans <> KDE_winfade_opacity) {
			WinSet, Transparent, %KDE_winfade_opacity%, ahk_id %KDEm_id%
			;WinFade("ahk_id " KDEm_id, KDE_winfade_opacity, KDE_winfade_time_in, true,, true)
			WinActivate, ahk_id %KDEm_id%
		} else {
			WinGet, WinCurrentTrans, Transparent, ahk_id %KDEm_id%
			WinSet, Transparent, %WinCurrentTrans%, ahk_id %KDEm_id%
		}
		; LEFT		RIGHT
		; win_x: 0		win_x: 960
		; win_y: 30		win_y: 30
		; win_w: 960	win_w: 960
		; win_h: 988	win_h: 988
		
		; LEFT		RIGHT
		; win_x: -7		win_x: 793
		; win_y: 0		win_y: 0
		; win_w: 814	win_w: 814
		; win_h: 867	win_h: 867
		
		taskbarMaxH := 50
		WinGetPos, x, y, wW, wH, ahk_id %KDEm_id%
		if (x < 1 && y < 31 && wW < A_ScreenWidth/2 && wH < A_ScreenHeight-taskbarMaxH) {
			kdeR_dir := "left"
			SetSystemCursor("IDC_SIZEALL")
			MouseGetPos, MRPosX, MRPosY
			SetTimer, KDE_WatchMouseWinRestoreLR, 12
			return
		} else if (x < A_ScreenWidth/2 && y < 31 && wW = A_ScreenWidth/2 && wH < A_ScreenHeight-taskbarMaxH) {
			kdeR_dir := "right"
			SetSystemCursor("IDC_SIZEALL")
			MouseGetPos, MRPosX, MRPosY
			SetTimer, KDE_WatchMouseWinRestoreLR, 12
			return
		}
		
		WinGet, WinState, MinMax, ahk_id %KDEm_id%
		if (WinState = 0) {
			SetSystemCursor("IDC_SIZEALL")
			SetTimer, WatchMouse, 10
			return
		} else {
			SetSystemCursor("IDC_SIZEALL")
			MouseGetPos, MRPosX, MRPosY, A
			SetTimer, KDE_WatchMouseWinRestore, 12
			return
		}
	} else {
		RestoreCursors()
	}
return

capslock & 2::
	VideoSize() {
		WinGet, winID, ID, A
		WinSet, ExStyle,-0x20, ahk_id %winID%
		w := 1029
		h := 650
		x := A_ScreenWidth - w + 7
		y := 0
		WinMove, ahk_id %winID%,,x,y,w,h
}
return

capslock & 3::
	
return

ClearWindowLock:
	ClearWindowLock()
return

ClearWindowLock() {
	global
	WinSet, AlwaysOnTop, Off,
	WinSet, ExStyle,-0x20,
	WinFade("ahk_id " ct_hwnd,0,20)
	Gui, Clitog%i%: Destroy
	WinFade("ahk_id " KDEm_id,255,KDE_winfade_time_in)
	WinActivate
	i++
}

ApplyWindowLock(WinX, WinY, hwnd) {
	global
	ct_bgcolor := "252525"
	margin := 50
	ct_x:=WinX+margin,ct_y:=WinY+margin,ct_w:=65,ct_h:=35
	
	CoordMode, Screen
	ct_x := (ct_x > (A_ScreenWidth - margin)) ? A_ScreenWidth - ct_w - margin
	: (ct_x < margin) ? margin
	: ct_x
	
	ct_y := (ct_y > (A_ScreenHeight - margin)) ? A_ScreenHeight ct_h - margin
	: (ct_y < margin) ? margin
	: ct_y
	
	CoordMode,Mouse
	GUi, Clitog%i%:-Caption +LastFound +ToolWindow +AlwaysOnTop
	ct_hwnd := WinExist()
	WinSet, Transparent, 0
	Gui, Clitog%i%: Color, % "0x" ct_bgcolor
	Gui, Clitog%i%: Add, Button, x0 y0 w%ct_w% h%ct_h% gClearWindowLock, % "RELEASE" 
	Gui, Clitog%i%: Show, x%ct_x% y%ct_y% w%ct_w% h%ct_h% NoActivate
	WinFade("ahk_id " ct_hwnd,225,10)

	Gui_OLSet.Insert(ct_hwnd)
	Gui_OLSet.Show_Me := Func("Show_Me")
	Gui_OLSet.Show_Me()
}

Show_me(this) {
	loop % this.MaxIndex()
		GuiList .= A_Index ": " this[A_Index] "`n"
	clipboard=
	clipboard := GuiList
	clipwait
}

WatchMouse:
	getkeystate, LButtonState, LButton, P
	; Button has been released, so drag is complete.
	if (LButtonState = "U")
	{
		CoordMode, Mouse, Screen
		MouseGetPos, MouseReleasePosX, MouseReleasePosY
		getkeystate, SpaceState, Space, P
		if (SpaceState = "D")
		{
			; Transparency lock
			WinFade("ahk_id " KDEm_id,KDE_winopacity_lock_opacity,KDE_winopacity_lock_effect_time)
			WinGetPos, win_x, win_y,,,ahk_id %KDEm_id%
			WinSet, AlwaysOnTop, On, ahk_id %KDEm_id%
			WinSet, ExStyle, +0x20, ahk_id %KDEm_id%
			Gui_OLSet.Insert(KDEm_id)
			;Gui_OLSet.push(KDEm_id)

			ApplyWindowLock(win_x,win_y,KDEm_id)
			SetTimer, SpaceBarOn_Delay, -1000
			RestoreCursors()
			SetTimer, WatchMouse, off
			return
		}
		
		getkeystate, KDEr_Button, RButton, P
		if (KDEr_Button = "U") {
			WinGet, WinTrans, Transparent, ahk_id %KDEm_id%
			if (WinTrans <> KDE_winopacity_lock_opacity) {
				WinFade("ahk_id " KDEm_id,255,KDE_winfade_time_out)
				RestoreCursors()
			}
		}
		
		; Maximize if on mouse button release is an offset value from the top
		if (MouseReleasePosY < KDE_MBReleaseOffset) {
			WinGetPos,,,WinX, WinY, ahk_id %KDEm_id%
			WinMove, A_ScreenWidth / 2 - WinX / 2, A_ScreenHeight / 2 - WinY / 2
			WinMaximize, ahk_id %KDEm_id%
		; Minimize if on mouse button release is an offset value from the bottom
		} else if (MouseReleasePosY > A_ScreenHeight - KDE_MBReleaseOffset) {
			WinGetPos,,,WinX, WinY, ahk_id %KDEm_id%
			WinMove, A_ScreenWidth / 2 - WinX / 2, A_ScreenHeight / 2 - WinY / 2
			WinMinimize, ahk_id %KDEm_id%
		} else if (MouseReleasePosX < KDE_MBReleaseOffset) {
		; Snap to the left if mouse bWinGetPos, x, y, wW, wH, ahk_id %A_ID%utton release is an offset value from the left
			SendInput, {RWin down}{Left}{RWin up}
		; Snap to the right if mouse button release is an offset value from the left
		} else if (MouseReleasePosX > A_ScreenWidth - KDE_MBReleaseOffset) {
			SendInput, {RWin down}{Right}{RWin up}
		}
		
		CoordMode, Mouse
		SetTimer, WatchMouse, off
		return
	}
	
	getkeystate, EscapeState, Escape, P
	; Escape has been pressed, so drag is cancelled.
	if (EscapeState == "D") {
		WinFade("ahk_id " KDEm_id,255,KDE_winfade_time_out)
		RestoreCursors()
		SetTimer, WatchMouse, off
		winMove, ahk_id %KDEm_id%,, %OriginalPosX%, %OriginalPosY%
		winMove, ahk_id %SHD_hwnd%,, %OriginalPosX%, %OriginalPosY%
		winMove, ahk_id %Overlay_id%,, %OriginalPosX%, %OriginalPosY%
		Hotkey, Space, off
		return
	}
	
	; Otherwise, reposition the window to match the change in mouse coordinates
	; caused by the user having dragged the mouse:
	CoordMode, Mouse
	SetWinDelay, -1 ; Makes the below move faster/smoother.
	
	MouseGetPos, MouseX, MouseY
	WinGetPos, WinX, WinY,,, ahk_id %KDEm_id%
	WinGetPos,shx,shy,,, ahk_id %SHD_hwnd%
	WinGetPos,shbx,shby,,, ahk_id %SHD_hwnd_bak%
	WinGetPos,ovx,ovy,,, ahk_id %Overlay_id%

	if (KDEm_id==SETTINGS_hwnd || KDEm_id==DIALOG_hwnd) {
		WinMove, ahk_id %KDEm_id%,, WinX + MouseX - MouseStartX, WinY + MouseY - MouseStartY
		WinMove, ahk_id %Overlay_id%,, ovx + MouseX - MouseStartX, ovy + MouseY - MouseStartY
		WinMove, ahk_id %SHD_hwnd%,, shx + MouseX - MouseStartX , shy + MouseY - MouseStartY
	}
	
	else if (KDEm_id==CONTROL_hwnd) {
		WinMove, ahk_id %KDEm_id%,, WinX + MouseX - MouseStartX, WinY + MouseY - MouseStartY
		WinMove, ahk_id %Overlay_id%,, ovx + MouseX - MouseStartX, ovy + MouseY - MouseStartY
		
		if (WinExist("ahk_id" SHD_hwnd) && !WinExist("ahk_id" SHD_hwnd_bak))
			WinMove, ahk_id %SHD_hwnd%,, shx + MouseX - MouseStartX , shy + MouseY - MouseStartY
		
		else if (WinExist("ahk_id" SHD_hwnd) && WinExist("ahk_id" SHD_hwnd_bak))
			WinMove, ahk_id %SHD_hwnd_bak%,, shbx + MouseX - MouseStartX , shby + MouseY - MouseStartY
	}
	
	else {
		WinMove, ahk_id %KDEm_id%,,WinX+MouseX-MouseStartX,WinY+MouseY-MouseStartY
	}
	
	MouseStartX := MouseX ; Update for the next timer-call to this subroutine.
	MouseStartY := MouseY
return

KDE_WatchMouseWinRestoreLR:
	CoordMode, Mouse
	mousegetpos, MRaPosX, MRaPosY
	MRX_Offset := MRPosX - MRaPosX + 8
	MRY_Offset := MRPosY - MRaPosY - 22
	
	if (MRX_Offset > KDE_Mdrag_distance) || (MRY_Offset > KDE_Mdrag_distance) || (MRX_Offset < -(KDE_Mdrag_distance)) || (MRY_Offset < -(KDE_Mdrag_distance)) {
		SetTimer, KDE_WatchMouseWinRestoreLR, off
		
		if InStr(kdeR_dir, "left")
			Send, {RWin down}{Right}{RWin up}
		else
			Send, {RWin down}{Left}{RWin up}
		
		SetTimer, WatchMouse, on
		sleep 80
		;CoordMode, Mouse
		MouseGetPos, ReleaseX, ReleaseY
		WinGetPos,,, WinW, WinH, ahk_id %KDEm_id%
		CenterWinToMouse_X := ReleaseX - WinW/2
		CenterWinToMouse_Y := ReleaseY - WInH/2
		WinMove, ahk_id %KDEm_id%,, %CenterWinToMouse_X%, %CenterWinToMouse_Y%
	}
	
	getkeystate, WRLButton, LButton, P
	if (WRLButton = "U") {
		RestoreCursors()
		SetTimer, KDE_WatchMouseWinRestoreLR, off
		WinFade("ahk_id " KDEm_id,255,KDE_winfade_time_out)
		return
	}
return

KDE_WatchMouseWinRestore:
	mousegetpos, MRaPosX, MRaPosY, A
	MRX_Offset := MRPosX - MRaPosX + 8
	MRY_Offset := MRPosY - MRaPosY - 22
	;tooltip, % "x: " MRX_Offset ", y: " MRY_Offset, % MRaPosX, MRaPosY

	if (MRX_Offset > KDE_Mdrag_distance) || (MRY_Offset > KDE_Mdrag_distance) || (MRX_Offset < -(KDE_Mdrag_distance)) || (MRY_Offset < -(KDE_Mdrag_distance)) {
		SetTimer, KDE_WatchMouseWinRestore, off
		SetTimer, WatchMouse, 10
		WinRestore, ahk_id %KDEm_id%
		CoordMode, Mouse
		WinGetPos,,,WinX,WinY, ahk_id %KDEm_id%
		WinMove, A_ScreenWidth/2-WinX/2, A_ScreenHeight/2-WinY/2
		tooltip
	}
	
	getkeystate, WRLButton, LButton, P
	;getkeystate, MfRButton, LButton, P
	if (WRLButton = "U") {
		RestoreCursors()
		SetTimer, KDE_WatchMouseWinRestore, off
		WinFade("ahk_id " KDEm_id,255,KDE_winfade_time_out)
		hotkey, space, off
		return
}
return

/*
Acc.ahk courtesy of AHK user "jethrow", for information please refer to the following thread:
http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/
*/

;Params
;HoverScrollMinLines := 1 ;lines per notch
;HoverScrollMaxLines := 4 ;lines per notch
;HoverScrollThreshold := 1 ;Max Miliseconds between two consecutive notches (user defined)
;HoverScrollCurve := 1 ;Acceleration curve: 0 = Straight line (default), 1 = Parabola
; Normal vertical scrolling
HoverScroll_ScrollUP:
	MouseGetPos, x, y,, HoverScrollA_id
	WinGetClass, HoverScrollA_class, ahk_id %HoverScrollA_id%
	if !(HoverScrollA_class=="ApplicationFrameInputSinkWindow1") ||
	!(HoverScrollA_class=="ApplicationManager") ||
	!(HoverScrollA_class=="DesktopShellWindow") ||
	!(HoverScrollA_class=="MSTaskListWClass1") ||
	!(HoverScrollA_class=="Windows.UI.Core.CoreWindow") ||
	!(HoverScrollA_class=="ApplicationFrameWindow") {
		Lines := ScrollLines_3(HoverScrollMinLines, HoverScrollMaxLines, 80, 1)
		HoverScroll(Lines)
	} else {
		SendInput, {wheelup}
	}
return

;id: 0x980864
;classs: ApplicationFrameWindow
;title: Store

HoverScroll_ScrollDOWN:
	MouseGetPos,,,, HoverScrollA_id
	WinGetClass, HoverScrollA_class, ahk_id %HoverScrollA_id%
	if !(HoverScrollA_class=="ApplicationFrameInputSinkWindow1") &&
	!(HoverScrollA_class=="ApplicationManager") &&
	!(HoverScrollA_class=="DesktopShellWindow") &&
	!(HoverScrollA_class=="MSTaskListWClass1") &&
	!(HoverScrollA_class=="Windows.UI.Core.CoreWindow") {
		Lines := -ScrollLines_3(HoverScrollMinLines, HoverScrollMaxLines, 80, 1)
		HoverScroll(Lines)
	} else {
		SendInput, {wheeldown}
	}
return

; Horizontal scrolling
HoverScroll_ScrollRIGHT:
	MouseGetPos,,,,HoverScrollA_id
	WinGetClass, HoverScrollA_class, ahk_id %HoverScrollA_id%
	WinGetTitle, HoverScrollA_title, ahk_id %HoverScrollA_id%
	
	if !(HoverScrollA_class=="ApplicationFrameInputSinkWindow1") &&
	!(HoverScrollA_class=="ApplicationManager") &&
	!(HoverScrollA_class=="DesktopShellWindow") &&
	!(HoverScrollA_class=="MSTaskListWClass1") {
		if (getkeystate(modk_alt) == 1) {
			Lines := ScrollLines_3(HoverScrollMinLines, HoverScrollMaxLines)
			HoverScroll(Lines, 0)
		} else {
			Lines := ScrollLines_3(8, 20, 200, HoverScrollCurve)
			HoverScroll(Lines, 0) ;0 = horizontal, 1 (or omit) = vertical
		}
	} else {
		SendInput, {WheelRight}
	}
return

HoverScroll_ScrollLEFT:
	MouseGetPos,x,y,,HoverScrollA_id
	WinGetClass, HoverScrollA_class, ahk_id %HoverScrollA_id%
	WinGetTitle, HoverScrollA_title, ahk_id %HoverScrollA_id%
	if !(HoverScrollA_class=="ApplicationFrameInputSinkWindow1") &&
	!(HoverScrollA_class=="ApplicationManager") &&
	!(HoverScrollA_class=="DesktopShellWindow") &&
	!(HoverScrollA_class=="MSTaskListWClass1") {
		if (getkeystate(modk_alt) == 1) {
			Lines := -ScrollLines_3(HoverScrollMinLines, HoverScrollMaxLines)
			HoverScroll(Lines, 0)
		} else {
			Lines := -ScrollLines_3(8, 20, 200, HoverScrollCurve)
			HoverScroll(Lines, 0)
		}
	} else {
		SendInput, {WheelLeft}
	}
return

HoverScroll_Switch(s) {
	if (s==true) {
		Hotkey, WheelUp, on
		Hotkey, WheelDown, on
		Hotkey, Capslock & WheelDown, on
		Hotkey, Capslock & WheelUp, on
	} else {
		Hotkey, WheelUp, off
		Hotkey, WheelDown, off
		Hotkey, Capslock & WheelDown, off
		Hotkey, Capslock & WheelUp, off
	}
}

/*========================

File Explorer navigation:

w = up
s = down
a = left
d = right

with +shift mod:

+w = b/o
+s = b/o
+a = select items towards left (shift+left)
+d = same as the previous one

with !alt mod:

!w = home
!s = end
!a = up in the direcotry tree (shift+up)
!d = up in the opened directory history (shift+left)

==========================
*/

FEN_xUp_aToTheTop_sSelectToTop:
	if (getkeystate(modk_alt, "p") == 1)
		SendInput, {Home}{Space}
	
	else if (getkeystate(modk_shift) == 1)
		SendInput, +{Up}

	else
		SendInput, {Up}
return

FEN_xDown_aToTheBottom_sSelectToBottom:
	if (getkeystate(modk_alt) == 1)
		SendInput, {End}{Space}

	else
		SendInput, {Down}
return

FEN_xLeft_aDirUp_sSelectToLeft:
	if (getkeystate(modk_alt) == 1)
		SendInput, !{Right}

	else if (getkeystate(modk_shift) == 1)
		SendInput, +{Left}

	else
		SendInput, {Left}
return

FEN_xRight_aDirBack_sSelectToRight:
	if (getkeystate(modk_alt) == 1)
		SendInput, !{Left}

	else if (getkeystate(modk_shift) == 1)
		SendInput, +{Right}

	else
		SendInput, {Right}
return

; Select the first item after going to the directory (File Explorer)

FEN_xEnter_aBack:
	if (getkeystate(modk_shift) == 1) {
		SendInput, {backspace}
	} else {
		Send, {Enter}
		Sleep, 100
		Send, {Space}
}
return

FEN_xToTheTop:
	SendInput, !{Up}
return

FEN_fToTheBottom:
	SendInput, !{Left}
return



