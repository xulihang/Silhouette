B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private ExistingSegmentsRadioButton As RadioButton
	Private SplitRadioButton As RadioButton
	Private options As Map
	Private WholeRadioButton As RadioButton
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,270)
	frm.RootPane.LoadLayout("ASROptions")
	options.Initialize
	options.Put("split_method",-1)
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Return options
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	If SplitRadioButton.Selected Then
		options.Put("split_method",1)
	Else if ExistingSegmentsRadioButton.Selected Then
		options.Put("split_method",0)
	Else
		options.Put("split_method",2)
	End If
	frm.Close
End Sub
