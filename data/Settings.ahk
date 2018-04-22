








SettingsWindow:
	if (WinExist("ahk_id " SET_hwnd)) {
		GoSub, SettingsDestroy
	} else {
		global _sg1_handler, KDE_WindowLock_Transparency
		settings_w := 600
		settings_h := 400
		gx := 20
		gy := gx
		gw := settings_w - 2*gx
		gh := settings_h - 2*gy
		p := 30
		Gui, Settings: +LastFound +0x00040000 +MinSize%settings_w%x%settings_h%
		SET_hwnd := WinExist()
		WinSet, Transparent, 0, ahk_id %SET_hwnd%
		
		GUIHeaderFont("Settings")
		Gui, Settings: Add, GroupBox, % "x" gx " y" gy " w" gw " h" gh " v_sg1_handler", % "Window Lock"
		GUIRegularFont("Settings")
		lwtx := gx + p
		lwty := gy + p
		Gui, Settings: Add, Text, % "x" lwtx " y" lwty " vlwt_ttext +BackgroundTrans", % "Locked window transparency"
		GuiControlGet, lwtT_pos, Settings: Pos, lwt_ttext
		Gui, Settings: Add, Slider, % "x" lwtT_posX + lwtT_posW + p/2 " y" lwty " w" 140 " h" 30 " vKDE_WindowLock_Transparency gUpdateWLTSliderVar Range1-255 Tooltip", % KDE_WindowLock_Transparency
		GuiControlGet, lwtS_pos, Settings: Pos, KDE_WindowLock_Transparency
		Gui, Settings: Add, Edit, % "x" lwtS_posX + lwtS_posW + p/2 " y" lwty " vlwt_handler r1 w40 ReadOnly 0x1 0x8000000", % KDE_WindowLock_Transparency
		;Gui, Settings: Add, Button, % "x" gx + p " y" gy + p " w" 100 " h" 40 " gS_PickWindow", % "Choose Window"
		
		bb_h := 30
		bb_y := settings_h - bb_h - p
		save_w := 55
		
		Gui, Settings: Add, Button, % "x" settings_w - save_w - p " y" bb_y " w" save_w " h" bb_h " gS_ButtonSave v_savebutton_handler Default", &Save	
		
		Gui, Settings: Show, % "w" settings_w " h" settings_h " NoActivate", % apptitle "'s Settings"
		WinActivate, ahk_id %SET_hwnd%
		WinMoveFunc(SET_hwnd,"t l", 50, 50)
		WinFade("ahk_id " SET_hwnd,255,20)
	}
return

S_ButtonSave:
	Gui, Submit
	GoSub, SettingsDestroy
	SaveSettings()
return

UpdateWLTSliderVar:
	GuiControl,,lwt_handler, % KDE_WindowLock_Transparency
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

SettingsGuiSize:
	sg1_push_w := A_GuiWidth - 2*gx
	sg1_push_h := A_GuiHeight - 2*gx
	GuiControl, Settings: Move, _sg1_handler, % "w" sg1_push_w " h" sg1_push_h
	Winset, Redraw,,ahk_id %SET_hwnd%
return

SettingsGuiClose:
	WinFade("ahk_id " SET_hwnd,0,30)
	Gui, Settings: Destroy
return