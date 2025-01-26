B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private IndexRadioButton As RadioButton
	Private IndexTextField As TextField
	Private TimeRadioButton As RadioButton
	Private TimeTextField As TextField
	Private options As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",400,300)
	frm.RootPane.LoadLayout("JumpOptions")
	options.Initialize
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	If TimeRadioButton.Selected Then
		options.Put("time",TimeTextField.Text)
	Else
		options.Put("index",IndexTextField.Text)
	End If
	Return options
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub
