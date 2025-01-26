B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private ComboBox1 As ComboBox
	Private Label1 As Label
	Private OkayButton As Button
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("ExportOptions")
	ComboBox1.items.Add(Main.loc.Localize("Source only"))
	ComboBox1.items.Add(Main.loc.Localize("Target only"))
	ComboBox1.items.Add(Main.loc.Localize("Source + target"))
	ComboBox1.SelectedIndex = 1
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub ShowAndWait As Int
	frm.ShowAndWait
	Return ComboBox1.SelectedIndex
End Sub

Sub frm_CloseRequest (EventData As Event)
	ComboBox1.SelectedIndex = -1
	frm.Close
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub