B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.51
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private TextArea1 As TextArea
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",400,200)
	frm.RootPane.LoadLayout("inputbox")
	main.loc.LocalizeForm(frm)
End Sub

Public Sub setTitle(title As String)
	frm.Title = title
End Sub


Public Sub showAndWait(default As String) As String
	TextArea1.Text=default
    frm.ShowAndWait
	Return TextArea1.Text
End Sub

Sub Button1_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub
