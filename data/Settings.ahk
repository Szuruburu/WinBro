SettingsWindow:
	global _sg1_handler
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
	Gui, Settings: Add, GroupBox, % "x" gx " y" gy " w" gw " h" gh " v_sg1_handler", % "Modules"
	GUIRegularFont("Settings")
	Gui, Settings: Add, Button, % "x" gx + p " y" gy + p " w" 100 " h" 40 " gS_PickWindow", % "Choose Window"
	
	Gui, Settings: Show, % "w" settings_w " h" settings_h " NoActivate", % apptitle "'s Settings"
	WinActivate, ahk_id %SET_hwnd%
	WinMoveFunc(SET_hwnd,"hc vc")
	WinFade("ahk_id " SET_hwnd,255,20)
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