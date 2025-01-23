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
	If ExitCode <> 0 Then
		Utils.ReportError(StdOut)
	End If
	Return Success
End Sub

Public Sub GetWhisperPath As String
	If Utils.DetectOS <> "windows" Then
		Return File.Combine(File.Combine(File.DirApp,"whisper"),"whisper")
	Else
		Return File.Combine(File.Combine(File.DirApp,"whisper"),"main.exe")
	End If
	
End Sub

Public Sub GetModelPath As String
	If Utils.getPrefMap.ContainsKey("whisper_model_path") Then
		Return Utils.getPrefMap.Get("whisper_model_path")
	End If
	Dim modelDir As String = File.Combine(File.DirApp,"models")
	Dim modelName As String = "ggml-medium.bin"
	If File.Exists(modelDir,"model") Then
		modelName = File.ReadString(modelDir,"model").Trim
	End If
	If File.Exists(modelDir,modelName) = False Then
	    For Each filename As String In File.ListFiles(modelDir)
			If filename.EndsWith(".bin") Then
				modelName = filename
				Exit
			End If
	    Next
	End If
	Return File.Combine(modelDir,modelName)
End Sub
