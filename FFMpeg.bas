B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals
	
End Sub

Public Sub ExtractFrames(dir As String,filename As String,fps As Int,outputDir As String,format As String) As ResumableSub
	'ffmpeg -i big_buck_bunny_720p_2mb.mp4 -r 1 frame%d.png
	Dim args As List
	args = Array As String("-i",File.Combine(dir,filename),"-r",fps,"frame%d."&format)
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = outputDir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	Return Success
End Sub

Public Sub PlayCut(dir As String,filename As String,startTime As String,endTime As String,lang As String,engine As String) As ResumableSub
	wait for (CutWav(dir,filename,"cut.wav",startTime,endTime)) Complete (done As Object)
	wait for (PlayAudio(dir,"cut.wav")) Complete (done As Object)
	Return ""
End Sub

Public Sub PlayAudio(dir As String,filename As String) As ResumableSub
	Dim args As List
	args = Array As String("-i",filename,"-showmode",0)
	Dim sh As Shell
	sh.Initialize("sh",GetFFPlayPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	Return Success
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
	Return ffmpegPath
End Sub

Public Sub GetFFPlayPath As String
	Dim path As String
	If Utils.DetectOS = "windows" Then
		path = File.Combine(File.Combine(File.DirApp,"ffmpeg"),"ffplay.exe")
	Else
		path = File.Combine(File.Combine(File.DirApp,"ffmpeg"),"ffplay")
	End If
	If File.Exists(path,"") Then
		Return path
	End If
	If Utils.DetectOS <> "windows" Then
		path = "ffplay"
	End If
	Return path
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
	Log(StdOut)
	Log(StdErr)
	Return Success
End Sub

Public Sub AddPadding(dir As String,filename As String,outName As String,pad As Int) As ResumableSub
	Dim args As List
	args = Array As String("-i",filename,"-af",$""apad=pad_dur=${pad}""$,outName,"-y")
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
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

Public Sub Video2RawWav(dir As String,filename As String,outpath As String) As ResumableSub
	Dim args As List
	args = Array("-i",$"${filename}""$,$"${outpath}""$)
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	Return Success
End Sub

Public Sub GenerateVideoFromImagesAndAudio(dir As String,audioName As String,frameRate As String,outpath As String) As ResumableSub
	'ffmpeg -r 25 -i out.wav -i frame%d.png -vcodec libx264 output.mp4
	Dim args As List
	args = Array("-r",frameRate,"-i",$"${audioName}""$,"-i","frame%d.png","-vcodec","libx264",$"${outpath}""$)
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

Public Sub DrawWaveForm(dir As String,filename As String,res As String,out As String) As ResumableSub
	'FFMpeg -i in.flac -f lavfi -i color=c=black:s=640x320 -filter_complex \
	'"[0:a]showwavespic=s=640x320:colors=white[fg];[1:v][fg]overlay=format=auto" \
	'-frames:v 1 out.png
	Dim args As List
	args = Array As String("-i",filename,"-f","lavfi","-i",$"color=c=black:s=${res}"$,"-filter_complex",$""[0:a]showwavespic=s=${res}:colors=white[fg];[1:v][fg]overlay=format=auto""$,"-frames:v","1",out)
	Dim sh As Shell
	sh.Initialize("sh",GetFFMpegPath,args)
	sh.WorkingDirectory = dir
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
    Return Success
End Sub
