








SettingsWindow:
	if (WinExist("ahk_id " SET_hwnd)) {
		GoSub, SettingsDestroy
	} else {
		init_settings_w := 450
		init_settings_h := A_ScreenHeight - 200
		p := 30
		p_ms := 5
		Gui, Settings: +LastFound +0x00040000 +MinSize%init_settings_w%x%init_settings_h%
		SET_hwnd := WinExist()
		WinSet, Transparent, 0, ahk_id %SET_hwnd%
		
		bb_h := 30
		bb_y := init_settings_h - bb_h - p/2
		save_w := 55
		save_pos := % "x" init_settings_w - save_w - p/2 " y" bb_y " w" save_w " h" bb_h 
		
		bottom_buttons_h := bb_h + p
		
		tabs_x := 0
		tabs_y := 5
		tabs_w := init_settings_w + 3
		tabs_h := init_settings_h - bottom_buttons_h
		
		g_x := tabs_x + p_ms
		g1_y := tabs_y + p
		g1_h := 100
		g2_h := 200
		s_x := g_x + p
		s_h := 30
		
		GUIRegularFont("Settings")
		Gui, Settings: Add, Tab3, % "x" tabs_x " y" tabs_y " w" tabs_w " h" tabs_h " vtabs_handler", General|Navigation|KDE Window Effects|About
		
		Gui, Settings: Tab, 1
		
		GUIHeaderFont("Settings")
		Gui, Settings: Add, GroupBox, % "x" g_x " y" g1_y " h" g1_h " vt1g1_handler", % "System Settings"
		GUIRegularFont("Settings")
		Gui, Settings: Add, CheckBox, % "x" s_x " y" g1_y + p " h" s_h " vAutostart gChangeWindowsStartup Checked" Autostart, % "Start " apptitle " when Windows starts"
		Gui, Settings: Add, CheckBox, % "x" s_x " h" s_h " vadmin_cb_handler Checked" admin_cb_handler, % "Start " apptitle " with admin privileges"
		
		Gui, Settings: Tab, 2
		
		;;;;;;;;;;;;;;;;
		;; CONTENT HERE
		;;;;;;;;;;;;;;;;
		
		Gui, Settings: Tab, 3
		
		GUIHeaderFont("Settings")
		Gui, Settings: Add, GroupBox, % "x" g_x " y" g1_y " h" g1_h " vt3g1_handler", % "Window Lock"
		GUIRegularFont("Settings")
		Gui, Settings: Add, Edit, % "y" g1_y + p " vg1s1c_handler r1 w40 ReadOnly 0x1 0x8000000", % KDE_WindowLock_Transparency
		Gui, Settings: Add, Text, % "x" s_x " y" g1_y + p " vg1s1a_handler +BackgroundTrans", % "Locked window transparency"
		Gui, Settings: Add, Slider, % "y" g1_y + p " w" 140 " h" s_h " vKDE_WindowLock_Transparency gUpdateWLTSliderVar Range1-255 Tooltip", % KDE_WindowLock_Transparency
		
		GUIHeaderFont("Settings")
		Gui, Settings: Add, GroupBox, % "x" g_x " y" g1_y + g1_h + p_ms " h" g2_h " vt3g2_handler", % "KDE Move / KDE Resize"
		GUIRegularFont("Settings")
		Gui, Settings: Add, Edit, % "vg2s1c_handler r1 w40 ReadOnly 0x1 0x8000000", % KDE_winfade_opacity
		Gui, Settings: Add, Text, % "x" s_x " vg2s1a_handler +BackgroundTrans", % "Transparency while moving/resizing"
		Gui, Settings: Add, Slider, % "w" 140 " h" s_h " vKDE_winfade_opacity gUpdateWLTSliderVar Range1-255 Tooltip", % KDE_winfade_opacity
		
		Gui, Settings: Add, Edit, % "vg2s2c_handler r1 w40 ReadOnly 0x1 0x8000000", % KDE_winfade_time_in
		Gui, Settings: Add, Text, % "x" s_x " vg2s2a_handler +BackgroundTrans", % "Fade-in animation duration"
		Gui, Settings: Add, Slider, % "w" 140 " h" s_h " vKDE_winfade_time_in gUpdateWLTSliderVar Range1-25 Tooltip", % KDE_winfade_time_in
		
		Gui, Settings: Add, Edit, % "vg2s3c_handler r1 w40 ReadOnly 0x1 0x8000000", % KDE_winfade_time_out
		Gui, Settings: Add, Text, % "x" s_x " vg2s3a_handler +BackgroundTrans", % "Fade-out animation duration"
		Gui, Settings: Add, Slider, % "w" 140 " h" s_h " vKDE_winfade_time_out gUpdateWLTSliderVar Range1-25 Tooltip", % KDE_winfade_time_out
		
		Gui, Settings: Tab, 2
		
		;;;;;;;;;;;;;;;;
		;; CONTENT HERE
		;;;;;;;;;;;;;;;;
		
		Gui, Settings: Tab,
		
		Gui, Settings: Add, Button, % save_pos " gS_ButtonSave vsave_handler +Default", &Save	
		
		Gui, Settings: Show, % "w" init_settings_w " h" init_settings_h " NoActivate", % apptitle "'s Settings"
		WinActivate, ahk_id %SET_hwnd%
		WinMoveFunc(SET_hwnd,"t l", 70, 50)
		WinFade("ahk_id " SET_hwnd,255,20)
		;Gui, Settings: Add, Button, % "x" gx + p " y" gy + p " w" 100 " h" 40 " gS_PickWindow", % "Choose Window"
	}
return

PromptRestart:
	GoSub, S_ButtonSave
	GoSub, Restart
return

SettingsGuiSize:
	tabs_w := A_GuiWidth + 3
	tabs_h := A_GuiHeight - bottom_buttons_h
	
	g_w := tabs_w - 2*p_ms
	g1_push_x := tabs_x + p_ms
	g1_push_y := tabs_y + p
	g1_push_w := tabs_w - p_ms
	g1_push_h := tabs_h - p_ms
	
	GuiControl, Settings: Move, t3g1_handler, % "w" g_w
	GuiControl, Settings: Move, t3g2_handler, % "w" g_w
	GuiControl, Settings: Move, t1g1_handler, % "w" g_w
	
	GuiControlGet, g1s1c_pos, Settings: Pos, g1s1c_handler
	GuiControlGet, g1s1b_pos, Settings: Pos, KDE_WindowLock_Transparency
	GuiControl, Settings: Move, g1s1c_handler, % "x" A_GuiWidth - g1s1c_posW - p/2
	GuiControl, Settings: Move, KDE_WindowLock_Transparency, % "x" A_GuiWidth - g1s1c_posW - g1s1b_posW - p/2
	
	GuiControlGet, g1_pos, Settings: Pos, t3g1_handler
	GuiControlGet, g2_pos, Settings: Pos, t3g2_handler
	GuiControlGet, t1g1_pos, Settings: Pos, t1g1_handler
	GuiControlGet, g2s1c_pos, Settings: Pos, g2s1c_handler
	GuiControlGet, g2s2c_pos, Settings: Pos, g2s2c_handler
	GuiControlGet, g2s3c_pos, Settings: Pos, g2s3c_handler
	GuiControlGet, g2s1b_pos, Settings: Pos, KDE_winfade_opacity
	GuiControlGet, g2s2b_pos, Settings: Pos, KDE_winfade_time_in
	GuiControlGet, g2s2b_pos, Settings: Pos, KDE_winfade_time_out
	
	; KDE opacity level while moving/resizing
	GuiControl, Settings: Move, g2s1c_handler, % "x" A_GuiWidth - g2s1c_posW - p/2 " y" g1_posY + g1_posH + p/2
	GuiControl, Settings: Move, KDE_winfade_opacity, % "x" A_GuiWidth - g2s1c_posW - g2s1b_posW - p/2 " y" g1_posY + g1_posH + p/2
	GuiControl, Settings: Move, g2s1a_handler, % "y" g1_posY + g1_posH + p/2
	
	; KDE fade duration (IN)
	GuiControl, Settings: Move, g2s2c_handler, % "x" A_GuiWidth - g2s2c_posW - p/2 " y" g1_posY + g1_posH + g2s2c_posH + p/2
	GuiControl, Settings: Move, KDE_winfade_time_in, % "x" A_GuiWidth - g2s2c_posW - g2s2b_posW - p/2 " y" g1_posY + g1_posH + g2s2c_posH + p/2
	GuiControl, Settings: Move, g2s2a_handler, % "y" g1_posY + g1_posH + g2s2c_posH + p/2
	
	; KDE fade duration (OUT)
	GuiControl, Settings: Move, g2s3c_handler, % "x" A_GuiWidth - g2s3c_posW - p/2 " y" g1_posY + g1_posH + g2s2c_posH + g2s3c_posH + p/2
	GuiControl, Settings: Move, KDE_winfade_time_out, % "x" A_GuiWidth - g2s2c_posW - g2s2b_posW - p/2 " y" g1_posY + g1_posH + g2s2c_posH + g2s3c_posH + p/2
	GuiControl, Settings: Move, g2s3a_handler, % "y" g1_posY + g1_posH + g2s2c_posH + g2s3c_posH + p/2
	
	; TAB 1
	GuiControl, Settings: Move, admin_cb_handler, % "y" t1g1_posY + p
	
	GuiControl, Settings: Move, save_handler, % "x" A_GuiWidth - save_w - p/2 " y" A_GuiHeight - bb_h - p/2 " w" save_w " h" bb_h 
	GuiControl, Settings: Move, tabs_handler, % "x" tabs_x " y " tabs_y " w" tabs_w " h" tabs_h
	Winset, Redraw,,ahk_id %SET_hwnd%
return

S_ButtonSave:
	Gui, Submit
	GoSub, SettingsDestroy
	SaveSettings()
return

UpdateWLTSliderVar:
	GuiControl,,g1s1c_handler, % KDE_WindowLock_Transparency
	GuiControl,,g2s1c_handler, % KDE_winfade_opacity
	GuiControl,,g2s2c_handler, % KDE_winfade_time_in
	GuiControl,,g2s3c_handler, % KDE_winfade_time_out
return

S_PickWindow:
	GoSub, ShowTipUnderTheCursor
	SetSystemCursor("IDC_CROSS")
return

ShowTipUnderTheCursor:
	GoSub, GatherWindowData
	Tip(data)
	SetTimer, UpdateTheTip, 20
return

GatherWindowData:
	MouseGetPos,,, A_ID
	WinGetTitle, A_title, ahk_id %A_ID%
	WinGetClass, A_class, ahk_id %A_ID%
	data := % "Window title: " A_title "`nWindow ID: " A_ID "`nWindow Class: " A_class
	if (data <> p_data)
		Tip(data)
	p_data := data
return

UpdateTheTip:
	GoSub, GatherWindowData
return

SettingsGuiClose:
	WinFade("ahk_id " SET_hwnd,0,30)
	Gui, Settings: Destroy
return

ChangeWindowsStartup:
	CheckWindowsStartup(Autostart)
return

CheckWindowsStartup(enable) {
	LinkFile=%A_Startup%\%apptitle%.lnk
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