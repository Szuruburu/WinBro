#IfWinActive

HideDesktopIcons:
ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
if !(HWND <> "")
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
if DllCall("IsWindowVisible", UInt, HWND) {
	;Tip("Hidden")
	WinFade("ahk_id " HWND, 0, 20,true)
	WinHide, ahk_id %HWND%
} else {
	;Tip("Shown")
	WinShow, ahk_id %HWND%
	WinFade("ahk_id " HWND, 255, 20,true)
}
return