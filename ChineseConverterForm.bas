B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private AllRadioButton As RadioButton
	Private OnlySelectedRadioButton As RadioButton
	Private mLines As List
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(lines As List)
	mLines = lines
	frm.Initialize("frm",350,200)
	frm.RootPane.LoadLayout("ChineseConverter")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub ToTraditionalButton_MouseClicked (EventData As MouseEvent)
	Convert(False)
End Sub

Private Sub ToSimpleButton_MouseClicked (EventData As MouseEvent)
	Convert(True)
End Sub

Private Sub Convert(toSimple As Boolean)
	Dim lines As List
	If OnlySelectedRadioButton.Selected Then
		lines = Main.GetSelectedLines
	Else
		lines = mLines
	End If
	Dim cc As OpenCC
	cc.Initialize
	For Each line As Map In lines
		Dim source As String = line.Get("source")
		If toSimple Then
			source = cc.ConvertToSimple(source)
		Else
			source = cc.ConvertToTraditional(source)
		End If
		line.Put("source",source)
	Next
	Main.LoadLinesToTable
End Sub