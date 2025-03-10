; SetKeyDelay, 0, 50

#Persistent
Menu,Tray,NoStandard
Menu,Tray,Add,&Suspend,ContextMenu
Menu,Tray,Add,E&xit,ContextMenu
Menu,Tray,Default,E&xit
Menu,Tray,Icon,mute_ON.ico
Return

ContextMenu:
If (A_ThisMenuItem="&Suspend")
{
  If (A_IsSuspended)
  {
    Suspend,Off
    Menu,Tray,Uncheck,&Suspend
    Menu,Tray,Icon,mute_ON.ico
  }
  Else
  {
    Menu,Tray,Check,&Suspend
    Menu,Tray,Icon,mute_OFF.ico,,1
    Suspend,On
  }
  Return
}
If (A_ThisMenuItem="E&xit")
  ExitApp

Media_Play_Pause::                    ; QC35II middle button (between volume + and -)
  if (!A_IsSuspended) {
    WinGetTitle, active_title, A		  ; looks at the active program on your screen and puts it into variable "active_title"
    if active_title contains Discord		; if active program is Discord, move on
      {
         Send ^+M		                  ; send CTRL + SHIFT + M for Discord microphone mute on/off
      }
    else	   							  ; if active program is not Discord then go to Discord 
      {
        SetTitleMatchMode, 2			  ; set Title search to exact
        WinActivate, Discord	  ; bring "VRChat" to the foreground so the shortcut will work
	    Send ^+M		                  ; send CTRL + SHIFT + M for Discord microphone mute on/off
      }
  }