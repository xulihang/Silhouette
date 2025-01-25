B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals
	
End Sub

Public Sub GetFFMpegPath As String
	Dim ffmpegPath As String
	If Utils.DetectOS = "windows" Then
		ffmpegPath = File.Combine(File.Combine(File.DirApp,"ffmpeg"),"ffmpeg.exe")
	Else
		ffmpegPath = File.Combine(File.Combine(File.DirApp,"ffmpeg"),"ffmpeg")
	End If
	If File.Exists(ffmpegPath,"") Then
		Return ffmpegPath
	End If
	If Utils.DetectOS <> "windows" Then
		ffmpegPath = "ffmpeg"
	End If
	Log(ffmpegPath)
	Return ffmpegPath
End Sub

Public Sub CutWav(dir As String,filename As String,outName As String,startTime As String,endTime As String) As ResumableSub
	startTime = Utils.GetMillisecondsFromTimeString(startTime) & "ms"
	endTime = Utils.GetMillisecondsFromTimeString(endTime) & "ms"
	Dim args As List
	args = Array As String("-i",filename,"-ss",startTime,"-to",endTime,"-c","copy",outName,"-y")
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Return Success
End Sub

Public Sub MergeWavFiles(dir As String,filenames As List,outName As String) As ResumableSub
	GenerateWavListFile(dir,filenames)
	Dim args As List
	args = Array As String("-f","concat","-i","mylist.txt","-c","copy",outName,"-y")
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	File.Delete(dir,"mylist.txt")
	Return Success
End Sub

Private Sub GenerateWavListFile(dir As String,filenames As List)
	Dim sb As StringBuilder
	sb.Initialize
	For Each filename As String In filenames
		sb.Append("file")
		sb.Append(" ")
		sb.Append(filename)
		sb.Append(CRLF)
	Next
	File.WriteString(dir,"mylist.txt",sb.ToString)
End Sub

Public Sub Video2Wav(dir As String,filename As String,outpath As String) As ResumableSub
	Dim args As List
	args = Array("-i",$"${filename}""$,"-ac","1","-ar","16000",outpath)
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	Return Success
End Sub

Public Sub SplitWav(duration As Int,dir As String,filename As String) As ResumableSub
	Dim args As List
	args = Array As String("-i",filename,"-f","segment","-segment_time",duration,"-c","copy","segment-%05d.wav")
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
    Return Success
End Sub
