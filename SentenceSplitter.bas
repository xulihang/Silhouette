B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private CalculateTimeByWordsCheckBox As CheckBox
	Private SourceTextArea As TextArea
	Private TargetTextArea As TextArea
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",600,500)
	frm.RootPane.LoadLayout("sentenceSplitter")
End Sub

Public Sub SetText(source As String,target As String)
	SourceTextArea.Text = source
	TargetTextArea.Text = target
End Sub

Public Sub ShowAndWait As Map	
	frm.ShowAndWait
	Dim result As Map
	result.Initialize
	result.Put("source",SourceTextArea.Text)
	result.Put("target",TargetTextArea.Text)
	result.Put("calculateByWords",CalculateTimeByWordsCheckBox.Checked)
	Return result
End Sub

Public Sub SetCheckboxVisibility(value As Boolean)
	CalculateTimeByWordsCheckBox.Visible = value
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
    frm.Close	
End Sub
