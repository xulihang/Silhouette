B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub

Public Sub RecognizeWav(filepath As String,lang As String) As ResumableSub
	Dim args As List
	args = Array("-m",GetModelPath,"-f",filepath,"-osrt","-l",lang)
	Dim sh As Shell
	sh.Initialize("sh",GetWhisperPath,args)
	sh.WorkingDirectory = File.DirApp
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	Return Success
End Sub

Public Sub GetWhisperPath As String
	If Utils.DetectOS <> "win" Then
		Return File.Combine(File.Combine(File.DirApp,"whisper"),"whisper")
	Else
		Return File.Combine(File.Combine(File.DirApp,"whisper"),"main.exe")
	End If
	
End Sub

Public Sub GetModelPath As String
	Dim modelName As String = "ggml-medium.bin"
	If File.Exists(File.Combine(File.DirApp,"models"),"model") Then
		modelName = File.ReadString(File.Combine(File.DirApp,"models"),"model").Trim
	End If
	Return File.Combine(File.Combine(File.DirApp,"models"),modelName)
End Sub
