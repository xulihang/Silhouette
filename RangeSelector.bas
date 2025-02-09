B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private EndTextField As TextField
	Private StartTextField As TextField
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",400,250)
	frm.RootPane.LoadLayout("RangeSelector")
	Main.loc.Localizeform(frm)
End Sub

Public Sub SetRange(startNumber As Int,endNumber As Int)
	StartTextField.Text = startNumber
	EndTextField.Text = endNumber
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Dim startIndex As Int = StartTextField.Text - 1
	Dim endIndex As Int = EndTextField.Text - 1
	Dim result As Map
	result.Initialize
	result.Put("startIndex",startIndex)
	result.Put("endIndex",endIndex)
	Return result
End Sub

Private Sub Button1_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub
