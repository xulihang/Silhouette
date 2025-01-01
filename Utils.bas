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

Public Sub GetMillisecondsFromTimeString(str As String) As Long
	Dim totalMilliseconds As Long
	Dim hours As Int = str.SubString2(0,2)
	Dim minutes As Int = str.SubString2(3,5)
	Dim seconds As Int = str.SubString2(6,8)
	Dim milliseconds As Int = str.SubString2(9,12)
	totalMilliseconds = hours*60*60*1000 + minutes*60*1000 + seconds*1000 + milliseconds
	Return totalMilliseconds
End Sub
