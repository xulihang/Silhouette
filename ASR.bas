B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private sh As Shell
End Sub

Public Sub RecognizeCut(dir As String,filename As String,startTime As String,endTime As String,lang As String) As ResumableSub
	wait for (FFMpeg.CutWav(dir,filename,"cut.wav",startTime,endTime)) Complete (done As Object)
	File.Copy(dir,"cut.wav",dir,"cut-o.wav")
	wait for (FFMpeg.AddPadding(dir,"cut-o.wav","cut.wav",2)) complete (done As Object)
	File.Delete(dir,"cut-o.wav")
	Wait For (RecognizeWavAsText(File.Combine(dir,"cut.wav"),lang)) Complete (str As String)
	Return str
End Sub

Public Sub RecognizeWavAsText(filepath As String,lang As String) As ResumableSub
	wait for (RecognizeWav(filepath,lang)) complete (done As Object)
	Dim filename As String = File.GetName(filepath)
	Dim dir As String = File.GetFileParent(filepath)
	Dim content As String
	If File.Exists(dir,filename&".srt") Then
		content = File.ReadString(dir,filename&".srt")
	End If
	If File.Exists(dir,Utils.GetFilenameWithoutExtension(filename)&".srt") Then
		content = File.ReadString(dir,Utils.GetFilenameWithoutExtension(filename)&".srt")
	End If
	content = Utils.RemoveBOM(content)
	Dim parser As SrtParser
	parser.Initialize
	Dim parsedlines As List = parser.Parse(content)
	Dim sb As StringBuilder
	sb.Initialize
	For Each parsedline As SpeechLine In parsedlines
		sb.Append(parsedline.text)
	Next
	Return sb.ToString
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

Public Sub KillCurrentShell
	If sh.IsInitialized Then
		sh.KillProcess
	End If
End Sub
