B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private RateSpinner As Spinner
	Private frm As Form
	Private mVLC As jVLC
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(vlc As jVLC)
	mVLC = vlc
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("PlayControl")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub RateSpinner_ValueChanged (Value As Object)
	mVLC.Rate = RateSpinner.Value
End Sub