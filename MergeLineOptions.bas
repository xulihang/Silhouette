B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private CheckTimestampCheckBox As CheckBox
	Private MaxWordNumberCheckBox As CheckBox
	Private MaxWordNumberSpinner As Spinner
	Private MergeByPunctuationCheckBox As CheckBox
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("MergeLineOptions")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Dim m As Map
	m.Initialize
	m.Put("mergeByPunctuation",MergeByPunctuationCheckBox.Checked)
	m.Put("mergeByMaxWordNumber",MaxWordNumberCheckBox.Checked)
	m.Put("checkTimestamp",CheckTimestampCheckBox.Checked)
	m.Put("maxWordNumber",MaxWordNumberSpinner.Value)
	Return m
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub
