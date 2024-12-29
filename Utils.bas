B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

'windows, mac or linux
Public Sub DetectOS As String
	Dim os As String = GetSystemProperty("os.name", "").ToLowerCase
	If os.Contains("win") Then
		Return "windows"
	Else If os.Contains("mac") Then
		Return "mac"
	Else
		Return "linux"
	End If
End Sub

Sub GetFilenameWithoutExtension(filename As String) As String
	Try
		filename=filename.SubString2(0,filename.LastIndexOf("."))
	Catch
		Log(LastException)
	End Try
	Return filename
End Sub

