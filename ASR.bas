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
	Private mCallback As Object
	Private mEventName As String
	Private mSize As Int
	Private mCurrentIndex As Double
End Sub

Public Sub RecognizeCut(dir As String,filename As String,startTime As String,endTime As String,lang As String,engine As String) As ResumableSub
	wait for (FFMpeg.CutWav(dir,filename,"cut.wav",startTime,endTime)) Complete (done As Object)
	File.Copy(dir,"cut.wav",dir,"cut-o.wav")
	wait for (FFMpeg.AddPadding(dir,"cut-o.wav","cut.wav",2)) complete (done As Object)
	File.Delete(dir,"cut-o.wav")
	Wait For (RecognizeWavAsText(File.Combine(dir,"cut.wav"),lang,engine)) Complete (str As String)
	File.Delete(dir,"cut.wav.srt")
	File.Delete(dir,"cut.srt")
	Return str
End Sub

Public Sub RecognizeWavAsText(filepath As String,lang As String,engine As String) As ResumableSub
	wait for (RecognizeWav(filepath,lang,engine)) complete (done As Object)
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

Public Sub RecognizeWav(filepath As String,lang As String,engine As String) As ResumableSub
	If engine = "whisper" Then
		Dim args As List
		args.Initialize
		args.AddAll(Array("-m",GetModelPath,"-f",filepath,"-osrt","-l",lang))
		Dim prompt As String =  Utils.getSetting("prompt","")
		If prompt <> "" Then
			args.Add("--prompt")
			args.Add(prompt)
		End If
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
	Else
		If getASRPluginList.IndexOf(engine)<>-1 Then
			Dim params As Map
			params.Initialize
			params.Put("path",filepath)
			params.Put("lang",lang)
			params.Put("preferencesMap",Utils.getPrefMap)
			wait for (Main.plugin.RunPlugin(engine&"ASR","recognize",params)) complete (lines As List)
			Dim convertedLines As List
			convertedLines.Initialize
			For Each line As Map In lines
				Dim converted As Map
				converted.Initialize
				converted.Put("startTime",Utils.GetTimeStringFromMilliseconds(line.Get("start")*1000))
				converted.Put("endTime",Utils.GetTimeStringFromMilliseconds(line.Get("end")*1000))
				converted.Put("source",line.Get("text"))
				converted.Put("target","")
				convertedLines.Add(converted)
			Next
			Exporter.ExportToSRT(convertedLines,filepath&".srt",False,0)
		End If
	End If
	Return False
End Sub

Public Sub RecognizeWavWithProgressInfo(callback As Object, eventname As String, filepath As String,lang As String,engine As String,size As Int) As ResumableSub
	mCallback = callback
	mEventName = eventname
	mCurrentIndex = 0
	mSize = size
	If engine = "whisper" Then
		Dim args As List
		args.Initialize
		args.AddAll(Array("-m",GetModelPath,"-f",filepath,"-osrt","-l",lang))
		Dim prompt As String =  Utils.getSetting("prompt","")
		If prompt <> "" Then
			args.Add("--prompt")
			args.Add(prompt)
		End If
		Dim sh As Shell
		sh.Initialize("sh",GetWhisperPath,args)
		sh.WorkingDirectory = File.DirApp
		sh.RunWithOutputEvents(-1)
		wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
		Log(StdOut)
		Log(StdErr)
		If ExitCode <> 0 Then
			Utils.ReportError(StdOut)
		End If
		Return Success
	Else
		If getASRPluginList.IndexOf(engine)<>-1 Then
			Dim params As Map
			params.Initialize
			params.Put("path",filepath)
			params.Put("lang",lang)
			params.Put("preferencesMap",Utils.getPrefMap)
			wait for (Main.plugin.RunPlugin(engine&"ASR","recognize",params)) complete (lines As List)
			Dim convertedLines As List
			convertedLines.Initialize
			For Each line As Map In lines
				Dim converted As Map
				converted.Initialize
				converted.Put("startTime",Utils.GetTimeStringFromMilliseconds(line.Get("start")*1000))
				converted.Put("endTime",Utils.GetTimeStringFromMilliseconds(line.Get("end")*1000))
				converted.Put("source",line.Get("text"))
				converted.Put("target","")
				convertedLines.Add(converted)
			Next
			Exporter.ExportToSRT(convertedLines,filepath&".srt",False,0)
		End If
	End If
	Return False
End Sub

Private Sub sh_StdOut (Buffer() As Byte, Length As Int)
	Log("StdOut")
	Log(Length)
	Dim bc As ByteConverter
	Dim s As String = bc.StringFromBytes(Buffer,"UTF-8")
	Log(s)
	mCurrentIndex = mCurrentIndex + 0.5
	File.WriteString(File.DirApp,"progress",s)
	If SubExists(mCallback,mEventName&"_ProgressChanged") Then
		CallSubDelayed3(mCallback,mEventName&"_ProgressChanged", mCurrentIndex, mSize)
	End If
End Sub

Public Sub GetWhisperPath As String
	If Utils.DetectOS <> "windows" Then
		If Utils.getPref("use_gpu",True) Then
			Return File.Combine(File.Combine(File.DirApp,"whisper"),"whisper")
		Else
			Return File.Combine(File.Combine(File.DirApp,"whisper"),"whisper-cpu")
		End If
	Else
		If Utils.getPref("use_gpu",True) Then
			Return File.Combine(File.Combine(File.DirApp,"whisper"),"main.exe")
		Else
			Return File.Combine(File.Combine(File.Combine(File.DirApp,"whisper"),"cpp"),"whisper-cli.exe")
		End If
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

Sub getASRPluginList As List
	Dim asrList As List
	asrList.Initialize
	For Each name As String In Main.plugin.GetAvailablePlugins
		If name.EndsWith("ASR") Then
			asrList.Add(name.Replace("ASR",""))
		End If
	Next
	Return asrList
End Sub
