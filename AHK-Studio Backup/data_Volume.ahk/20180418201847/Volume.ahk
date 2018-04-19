#IfWinActive

VolumeUp:
	vupdt("+2")
return

VolumeDown:
	vupdt("-2")
return

;This routine is isolated to avoid icon flashing
vupdt(dir) {
	global VOLUME_hwnd, master_volume, VolumeDestroyTime
	SoundSet, dir
	SoundSet, dir, wave
	if WinExist("ahk_id " VOLUME_hwnd) {
		SoundGet, master_volume
		GuiControl, Volume:, _volMP, % master_volume
		SetTimer,VolumeDestroy, % VolumeDestroyTime 
		return
	}
	gosub, VolumeShow
}

VolChangePic:
	MaxV_threshold := 70
	MinV_threshold := 15
	if (master_volume < MinV_threshold) {
		GuiControl, Volume: Hide, VolPic_handler
		GuiControl, Volume: Hide, VolMdPic_handler
		GuiControl, Volume: Show, VolMPic_handler
	} else if (master_volume > MinV_threshold) && (master_volume < MaxV_threshold) {
		GuiControl, Volume: Hide, VolPic_handler
		GuiControl, Volume: Hide, VolMPic_handler
		GuiControl, Volume: Show, VolMdPic_handler
	} else {
		GuiControl, Volume: Hide, VolMPic_handler
		GuiControl, Volume: Hide, VolMdPic_handler
		GuiControl,  Volume:Show, VolPic_handler
	}
return

VolumeShow:
	if !WinExist("ahk_id " VOLUME_hwnd) {
		margin := 20
		volW := 120
		volH := 120
		volX := (A_ScreenWidth/2)-(volW/2)
		volY := (A_ScreenHeight/2)-(volH/2)
		volC := "cfcfcf"
		volT := 215
		VBd_W := volW + margin/2
		VBd_H := volH + margin/2
		VolIconPath := A_ScriptDir . "\data\gui\vol.png"
		VolIconPath_Mute := A_ScriptDir . "\data\gui\volmute.png"
		VolIconPath_Mid := A_ScriptDir . "\data\gui\volmid.png"
		vi_x := 7
		vi_y := 13
		viPB_w := volW - margin
		viPB_h := 5
		viPB_x := (volW/2)-(viPB_w/2)
		viPB_y := volH - viPB_h - margin + (margin/2)
		viPB_c := "b6b6b6"
		picW := 64
		picH := picW
		picX := (volW/2)-(picW/2)
		picY := ((volH/2)-(picH/2)) - viPB_h
		SoundGet, master_volume
		SoundGet, m_m, Microphone, mute
		SoundGet, v_m, master, mute
		Gui, VolBackdrop: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
		VOLBDP_hwnd := WinExist()
		WinSet, Transparent, 0
		WinSet, ExStyle, +0x20
		WinSet, Region,0-0 w%VBd_W% h%VBd_H% r10-10 ; R0-0 round corenrs, i.e. R10-10 would be rounded
		Gui, VolBackdrop: Color, 0x000000
		
		Gui, Volume: -SysMenu -Caption +LastFound +ToolWindow +AlwaysOnTop
		VOLUME_hwnd := WinExist()
		WinSet, Transparent, 0
		WinSet, ExStyle, +0x20
		WinSet, Region,0-0 w%volW% h%volH% r10-10 ; R0-0 round corenrs, i.e. R10-10 would be rounded
		Gui, Volume: Color, % "0x" volC
		Gui, Volume: Add, Progress, % "x" viPB_x " y" viPB_y " w" viPB_w " h" viPB_h " v_volMP c" viPB_c " +BackgroundTrans", % master_volume
		;Tip(master_volume)
		
		if (master_volume < 20) {
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolPic_handler Hide", % VolIconPath
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolMdPic_handler Hide", % VolIconPath_Mid
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolMPic_handler", % VolIconPath_Mute
		} else {
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolMPic_handler Hide", % VolIconPath_Mute
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolMdPic_handler Hide", % VolIconPath_Mid
			Gui, Volume: Add, Pic, % "x" picX " y" picY " w" picW " h" picH " vVolPic_handler", % VolIconPath
		}
		
		SetTimer, VolChangePic, 10
		
		shadow_offset := 20
		shadow_offset_h := % volH + shadow_offset
		shadow_offset_w := % volW + shadow_offset
		shadow_offset_x := % shadow_offset/4
		shadow_offset_y := % shadow_offset/4
		Gui, VolBackdrop: Show, % "w" shadow_offset_w " h" shadow_offset_h " NoActivate"
		WinMoveFunc(VOLBDP_hwnd,"hc vc",shadow_offset_x,shadow_offset_y)
		WinSet, Transparent, 200, ahk_id %VOLBDP_hwnd%
		;WinFade("ahk_id " VOLBDP_hwnd,160,30)
		
		Gui, Volume: Show, % "x" volX " y" volY " w" volW " h" volH " NoActivate", volume
		WinMoveFunc(VOLUME_hwnd,"hc vc",0)
		WinSet, Transparent, %volT%, ahk_id %VOLUME_hwnd%
		;WinFade("ahk_id " VOLUME_hwnd, volT,30)
	} else {
		GoSub, VolumeDestroy
	}

	SetTimer,VolumeDestroy, % VolumeDestroyTime 
return

VolumeDestroy:
	if (WinExist("ahk_id " VOLUME_hwnd))
	|| (WinExist("ahk_id" VOLBDP_hwnd)) {
		SetTimer,VolumeDestroy, off
		SetTimer,VolChangePic, off
		WinFade("ahk_id " VOLUME_hwnd)
		WinFade("ahk_id " VOLBDP_hwnd)
		Gui, Volume: Destroy
		Gui, VolBackdrop: Destroy
	}
return