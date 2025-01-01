﻿B4J=true
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
	Return File.Combine(File.Combine(File.DirApp,"whisper"),"main.exe")
End Sub

Public Sub GetModelPath As String
	Return File.Combine(File.Combine(File.DirApp,"models"),"ggml-medium.bin")
End Sub