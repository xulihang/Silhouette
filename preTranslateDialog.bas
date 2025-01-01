B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.51
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private result As Map
	Private mtComboBox As ComboBox
	Private IntervalSpinner As Spinner
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",600,200)
	frm.RootPane.LoadLayout("pretranslate")
	result.Initialize
	result.Put("type","")
	mtComboBox.Items.AddAll(MT.getMTList)
	mtComboBox.SelectedIndex=0
	IntervalSpinner.Value=1000
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Return result
End Sub

Sub cancelButton_MouseClicked (EventData As MouseEvent)
	result.Put("type","")
	frm.Close
End Sub

Sub applyTMButton_MouseClicked (EventData As MouseEvent)
	result.Put("type","TM")
	frm.Close
End Sub

Sub applyMTButton_MouseClicked (EventData As MouseEvent)
	Dim engine As String
	engine=mtComboBox.Items.Get(mtComboBox.SelectedIndex)
	result.Put("engine",engine)
	result.Put("interval",IntervalSpinner.Value)
	result.Put("type","MT")
	frm.Close
End Sub

Private Sub mtComboBox_SelectedIndexChanged(Index As Int, Value As Object)
	If Value<>"baidu" Then
		IntervalSpinner.Value=0
	Else
		IntervalSpinner.Value=1000
	End If
End Sub
