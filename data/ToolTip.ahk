Tip(tip, duration:= 0) {
	global Tooltip

	; Show our tip immediately
	Tooltip := tip
	Tip_MouseOff()
	Tip_ForceUpdate()

	; Set the duration of the tip automatically unless specified
	if (duration == 0)
		duration := 100 * StrLen(Tooltip)

	; Hide tip after duration
	SetTimer, HideMouseTip, -%duration%
}

Tip_MouseOn() {
	global MouseTipUpdateInterval

	; turn mouse tip on
	SetTimer, ShowMouseTip, %MouseTipUpdateInterval%

	; let the timer tick, so the tip gets updated
	; right after being turned on; a successive
	; Send could block the timer otherwise
	Sleep % MouseTipUpdateInterval * 2
}

Tip_MouseOff() {
	SetTimer, ShowMouseTip, Off
	SetTimer, HideMouseTip, Off
	ToolTip,
}

Tip_ForceUpdate() {
	Tip_ForceUpdate_delayed()
	SetTimer, ShowMouseTip, 1 ; "undelayed"
}

Tip_ForceUpdate_delayed() {
	global LastMouseTipX, LastMouseTipY

	; this forces the mouse tip to get updated next timer tick
	LastMouseTipX := LastMouseTipY := 0
}

ShowMouseTip:
	SetTimer, ShowMouseTip, %MouseTipUpdateInterval%
	CoordMode Mouse, Relative
	MouseGetPos, xpos, ypos

	if (LastMouseTipMsg != Tooltip || LastMouseTipX != xpos || LastMouseTipY != ypos)
	{
	LastMouseTipMsg := Tooltip
	LastMouseTipX := xpos
	LastMouseTipY := ypos
	tip := Tooltip
	ToolTip, %tip%, xpos + 25, ypos + 10
	}
return

HideMouseTip:
	Tip_MouseOff()
	Tooltip := ""
return