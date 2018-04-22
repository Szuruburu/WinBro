
GenRndStrFromFile(input_file) {
 global tpoc_file
	i := 1
	loop, Read, %input_file%
	{
		sm%i% := A_LoopReadLine
		i++
	}
	
	Random, fmsg, 1, i-1
	iniRead, pmsg, %tpoc_file%, TempValues, iRAN_msgPreviousPhraseIndex
	
	; Avoid message repeating
	if (fmsg == pmsg) {
		fmsg := (fmsg < 1) ? fmsg + round(Fmsg/2)
		: (fmsg == i) ? fmsg fmsg - round(Fmsg/2) : fmsg + 1
	}
	
	;Tip("previous: " pmsg "`ncurrent: " fmsg)
	iniWrite, %fmsg%, %tpoc_file%, TempValues, iRAN_msgPreviousPhraseIndex
	return sm%fmsg%
}

SplashScreen:
	author := % "author: " email
	splash_width := 350
	splash_height := 120
	splash_shadow_w := splash_width + 1
	splash_shadow_h := splash_height + 1
	splash_position := "b r"
	text_margin_left := 110
	
	Gui, SplashShadow: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
	SCSH_hwnd := WinExist()
	WinSet, Transparent, 0
	WinSet, ExStyle, +0x20
	Gui, SplashShadow: Color, 0x%color_aux%
	Gui, SplashShadow: Show, w%splash_shadow_w% h%splash_shadow_h% NoActivate
	WinMoveFunc(SCSH_hwnd, splash_position)
	WinFade("ahk_id " SCSH_hwnd,180,30)
	
	Gui, SplashScreen: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
	SC_hwnd := WinExist()
	WinSet, Transparent, 0
	WinSet, Region,6-6 w%splash_shadow_w% h%splash_shadow_h% r0-0 ; R0-0 round corenrs, i.e. R10-10 would be rounded
	WinSet, ExStyle, +0x20
	Gui, SplashScreen: Color,% "0x" color_main
	Gui, SplashScreen: Add, Picture, x15 y15, %A_ScriptDir%\data\gui\logo_splash.png
	GuiBigPixelFont("SplashScreen",color_main_titletext)
	Gui, SplashScreen: Add, Text, x%text_margin_left% y30 BackgroundTrans, % apptitle
	GUIRegularFont("SplashScreen","364243")
	Gui, SplashScreen: Add, Text, x%text_margin_left% y+-2 x+-103 BackgroundTrans, % GenRndStrFromFile(ranmsg_file)
	GUISmallFont("SplashScreen","426a6c")
	Gui, SplashScreen: Add, Text, x%text_margin_left% y+18 BackgroundTrans, % "version: " version "`n" author
	Gui, SplashScreen: Show, % "w" splash_width " h" splash_height " NoActivate"
	WinMoveFunc(SC_hwnd,splash_position)
	WinFade("ahk_id " SC_hwnd,255,6)
	SetTimer, SplashDestroy, 3000
return

SplashScreenTest:
	TestHK(SC_hwnd,"SplashScreen","SplashDestroy")
return

; PARAMS
; t_hwnd = the handler of the tested GUI
; t_br = Tested GUI's build routine
; t_dr = Tested GUI's destroy routine
TestHK(t_hwnd, t_br, t_dr) {
	if !WinExist("ahk_id " t_hwnd) {
		GoSub, %t_br%
		SetTimer, %t_dr%, off
	} else {
		GoSub, %t_dr%
	}
}

WL_ReleaseButton:
	WinGetPos, win_x, win_y,,, ahk_id %LOCKED_hwnd%
	ct_bgcolor := "252525"
	margin := 50
	ct_x:=win_x+margin,ct_y:=win_y+margin,ct_w:=65,ct_h:=35
	
	CoordMode, Screen
	ct_x := (ct_x > (A_ScreenWidth - margin)) ? A_ScreenWidth - ct_w - margin
	: (ct_x < margin) ? margin
	: ct_x
	
	iniWrite, %ct_x%, %tpoc_file%, TempValues, iWL_ctx
	
	ct_y := (ct_y > (A_ScreenHeight - margin)) ? A_ScreenHeight ct_h - margin
	: (ct_y < margin) ? margin
	: ct_y
	
	iniWrite, %ct_y%, %tpoc_file%, TempValues, iWL_cty
	reloaded := false
	
	CoordMode, Mouse
	Gui, Clitog:-Caption +LastFound +ToolWindow +AlwaysOnTop
	ct_hwnd := WinExist()
	WinSet, Transparent, 0
	Gui, Clitog: Color, % "0x" ct_bgcolor
	Gui, Clitog: Add, Button, x0 y0 w%ct_w% h%ct_h% gClearWindowLock, % "RELEASE" 
	Gui, Clitog: Show, x%ct_x% y%ct_y% w%ct_w% h%ct_h% NoActivate
	WinFade("ahk_id " ct_hwnd,225,10)
	
	Gui_OLSet.Insert(ct_hwnd)
	SetTimer, CorrectAlwaysOnTop, 50
	/*
	Gui_OLSet.Show_Me := Func("Show_Me")
	Gui_OLSet.Show_Me()
	*/
return

CorrectAlwaysOnTop:
	if (WinActive("ahk_id " LOCKED_hwnd)) {
		WinSet, AlwaysOnTop, On, ahk_id %ct_hwnd%
	}
return

ClickIndicatorDestroy:
	SetTimer, ClickIndicatorDestroy, off
	WinFade("ahk_id " CLK_hwnd,0,30)
	Gui, ClickInd: Destroy
return

WinFade(winID:="", transparency:=128, increment:=100, delay:= 1) {
	winID := (winID = "") ? ("ahk_id " WinActive("A")) : winID
	transparency := (transparency > 255) ? 255 : (transparency<0 ) ? 0 : transparency
	WinGet s, Transparent, %winID%
	s := (s = "") ? 255 : s ;prevent trans unset bug
	WinSet Transparent, %s%, %winID%
	increment := (s < transparency) ? abs(increment) : -1 * abs(increment)
	while (k:=(increment < 0) ? (s > transparency) : (s < transparency) && WinExist(winID)) {
		if !(WinExist(winID))
			break
		WinGet s, Transparent, %winID%
		s+=increment
		WinSet Transparent, %s%, %winID%
		Sleep, %delay%
	}

}

WinMoveFunc(hwnd, position:="b r", h_offset:=0, v_offset:=0) {
	global x, y
	SysGet, Mon, MonitorWorkArea
	WinGetPos,ix,iy,w,h, ahk_id %hwnd%
	x := InStr(position,"l") ? MonLeft + h_offset
	: InStr(position,"hc") ? ((MonRight-w)/2) + h_offset
	: InStr(position,"r") ? MonRight - w + h_offset
	: ix

	y := InStr(position,"t") ? MonTop + v_offset
	: InStr(position,"vc") ? (MonBottom-h)/2 + v_offset
	: InStr(position,"b") ? MonBottom - h + v_offset
	: iy
		
	WinMove, ahk_id %hwnd%,,x,y
}

DrawLine(char,length) {
	loop % length {
		draw_line .= char
	}
	return draw_line
}

; Font settings
GUIRegularFont(guiname,color:=111111) {
	Gui, %guiname%: Font, c0%color% s10 w400 q5, Franklin Gothic Medium Cond
}

GUISmallFont(guiname,color:=656565) {
	Gui, %guiname%: Font, c0%color% s9 w500 q5, Franklin Gothic Medium Cond
}

GuiBigPixelFont(guiname,color:=111111) {
	Gui, %guiname%: Font, c0%color% s18 w1950 q5, Terminal
}

GUIHeaderFont(guiname,color:=313131) {
	Gui, %guiname%: Font, c0%color% s12 w100 q5, Calibri
}