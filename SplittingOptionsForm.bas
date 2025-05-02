B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private SplitByWordNumberCheckBox As CheckBox
	Private SplitSentencesCheckBox As CheckBox
	Private WordNumberSpinner As Spinner
	Private result As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("SplittingOptions")
	Main.loc.LocalizeForm(frm)
	result.Initialize
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Return result
End Sub

Sub frm_CloseRequest (EventData As Event)
	frm.Close
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	result.Put("split_sentences",SplitSentencesCheckBox.Checked)
	result.Put("split_by_word_number",SplitByWordNumberCheckBox.Checked)
	result.Put("word_number",WordNumberSpinner.Value)
	frm.Close
End Sub