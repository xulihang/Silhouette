B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Public Sub Align(sourceList As List,targetList As List,sourceLang As String,targetLang As String) As ResumableSub
	Dim sourceTxtPath,targetTxtPath,outputPath As String
	sourceTxtPath=File.Combine(File.DirApp,"source.txt")
	targetTxtPath=File.Combine(File.DirApp,"target.txt")
	outputPath=File.Combine(File.DirApp,"aligned.txt")
	If File.Exists(outputPath,"") Then
		File.Delete(outputPath,"")
	End If
	File.WriteList(sourceTxtPath,"",EmptyItemsRemoved(sourceList))
	File.WriteList(targetTxtPath,"",EmptyItemsRemoved(targetList))
	Dim sh As Shell
	'LF_aligner_4.2.exe --filetype="t" --infiles="./LFAlign/en.txt","./LFAlign/zh.txt" --languages="en","zh" --segment="n" --review="n" --tmx="n" --outfile="./LFAlign/out.txt"
	Dim executable As String
	If Utils.DetectOS="windows" Then
		executable="LFAlign.bat"
	Else
		executable="./LFAlign.sh"
	End If
	sh.Initialize("sh",executable,Array As String(sourceLang,targetLang))
	sh.WorkingDirectory=File.DirApp
	sh.Run(-1)
	Dim result As Map
	result.Initialize
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(Success)
	Log(StdOut)
	Log(StdErr)
	If Success And File.Exists(outputPath,"") Then
		result.Put("success",True)
		Dim sourceList,targetList As List
		sourceList.Initialize
		targetList.Initialize
		For Each line In File.ReadList(outputPath,"")
			Dim strs() As String=Regex.Split("\t",line)
			If strs.Length=3 Then
				sourceList.Add(strs(0))
				targetList.Add(strs(1))
			End If
		Next
		result.Put("sourceList",sourceList)
		result.Put("targetList",targetList)
	Else
		result.Put("success",False)
	End If
	Return result
End Sub

Sub EmptyItemsRemoved(list1 As List) As List
	Dim new As List
	new.Initialize
	For Each item As String In list1
		If item<>"" Then
			new.Add(item)
		End If
	Next
	Return new
End Sub

