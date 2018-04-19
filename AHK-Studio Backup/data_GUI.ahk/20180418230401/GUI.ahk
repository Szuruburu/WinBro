SplashScreen:
	author := % DrawLine("-",60) . "`nauthor: " email
	splash_width := 350
	splash_height := 100
	splash_shadow_w := splash_width + 1
	splash_shadow_h := splash_height + 1
	splash_position := "b r"
	text_margin_left := 110
	
	Gui, SplashShadow: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
	SCSH_hwnd := WinExist()
	WinSet, Transparent, 0
	WinSet, ExStyle, +0x20
	Gui, SplashShadow: Color, 0x000000
	
	Gui, SplashShadow: Show, w%splash_shadow_w% h%splash_shadow_h% NoActivate
	WinMoveFunc(SCSH_hwnd, splash_position)
	WinFade("ahk_id " SCSH_hwnd,200,15)
	
	Gui, SplashScreen: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
	SC_hwnd := WinExist()
	WinSet, Transparent, 0
	WinSet, Region,6-6 w%splash_shadow_w% h%splash_shadow_h% r0-0 ; R0-0 round corenrs, i.e. R10-10 would be rounded
	WinSet, ExStyle, +0x20
	Gui, SplashScreen: Color,% "0x" color_main
	;AnimatedGif(SC_hwnd, A_ScriptDir "\data\gui\floani.gif", 5, 0 , 100, 100)
	GuiBigPixelFont("SplashScreen","c0" color_main_text)
	Gui, SplashScreen: Add, Text, x%text_margin_left% y20 BackgroundTrans, % apptitle
	GUIRegularFont("SplashScreen",color_main_text)
	Gui, SplashScreen: Add, Text, x%text_margin_left% y43 BackgroundTrans, % "version: " version
	GUISmallFont("SplashScreen",color_main_text)
	Gui, SplashScreen: Add, Text, x%text_margin_left% y60 BackgroundTrans, % author
	Gui, SplashScreen: Show, % "w" splash_width " h" splash_height " NoActivate"
	WinMoveFunc(SC_hwnd, splash_position)
	WinFade("ahk_id " SC_hwnd,255,6)
	SetTimer, SplashDestroy, 2000
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
	Gui, %guiname%: Font, c0%color% s11 w500 q5, Calibri
}

GUISmallFont(guiname,color:=656565) {
	Gui, %guiname%: Font, c0%color% s9 w500 q5, Calibri
}

GuiBigPixelFont(guiname,color:=111111) {
	Gui, %guiname%: Font, c0%color% s18 w1950 q5, Terminal
}