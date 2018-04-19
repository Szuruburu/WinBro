; Move window under cursor with _mod key
Capslock & LButton::
	coordMode, Mouse  ; Switch to screen/absolute coordinates.
	mouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
	winGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
	winGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
	if EWD_WinState = 0  ; Only if the window isn't maximized
		setTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

EWD_WatchMouse:
	getkeystate, EWD_LButtonState, LButton, P
		if EWD_LButtonState = U  ; Button has been released, so drag is complete.
		{
			setTimer, EWD_WatchMouse, off
			return
		}
	getkeystate, EWD_EscapeState, Escape, P
	if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
	{
		setTimer, EWD_WatchMouse, off
		winMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
		return
	}
	; Otherwise, reposition the window to match the change in mouse coordinates
	; caused by the user having dragged the mouse:
	coordMode, Mouse
	mouseGetPos, EWD_MouseX, EWD_MouseY
	winGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
	setWinDelay, -1   ; Makes the below move faster/smoother.
	winMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
	EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
	EWD_MouseStartY := EWD_MouseY
return

; Resize window under cursor with _mod key
Capslock & RButton::
	coordMode, Mouse
	; Get the initial mouse position and window id, and
	; abort if the window is maximized.
	mouseGetPos KDE_X1, KDE_Y1, KDE_id
	winGet KDE_Win, MinMax, ahk_id %KDE_id%
	if KDE_Win
	 return
	; Get the initial window position and size.
	winGetPos KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_id%
	; Define the window region the mouse is currently in.
	; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
		if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
			KDE_WinLeft := 1
		else
			KDE_WinLeft := -1
		if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
			KDE_WinUp := 1
		else
			KDE_WinUp := -1
			
		loop
		{
			getkeystate KDE_Button, RButton, P ; Break if button has been released.
				if KDE_Button = U
				break
			mouseGetPos KDE_X2, KDE_Y2 ; Get the current mouse position.
			; Get the current window position and size.
			winGetPos KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_id%
			KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
			KDE_Y2 -= KDE_Y1
			; Then, act according to the defined region.
			winMove ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2 ; X of resized window
			, KDE_WinY1 + (KDE_WinUp+1)/2*KDE_Y2 ; Y of resized window
			, KDE_WinW - KDE_WinLeft *KDE_X2 ; W of resized window
			, KDE_WinH - KDE_WinUp *KDE_Y2 ; H of resized window
			KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
			KDE_Y1 := (KDE_Y2 + KDE_Y1)
		}
return
