﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Public projectPath As String
	Public projectFile As Map
	Public lines As List
	Public settings As Map
	Private manager As UndoManager
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mediaPath As String) As Boolean
	Dim filename As String = File.GetName(mediaPath)
	Dim dir As String = File.GetFileParent(mediaPath)
	projectPath = File.Combine(dir,filename&".sip")
	If File.Exists(projectPath,"") Then
		readProjectFile
		CreateTempFolder
		manager.Initialize(projectFile)
		Return False
	Else
		projectFile.Initialize
		lines.Initialize
		settings.Initialize
		projectFile.Put("mediaPath",mediaPath)
		projectFile.Put("lines",lines)
		projectFile.Put("settings",settings)
		CreateTempFolder
		manager.Initialize(projectFile)
		Return True
	End If
End Sub

Public Sub AddState
	manager.AddState(projectFile)
End Sub

Public Sub Undo
	Dim result As Object=manager.Undo
	If result<>Null Then
		projectFile=result
		If projectFile.ContainsKey("lines") Then
			lines=projectFile.get("lines")
		End If
		If projectFile.ContainsKey("settings") Then
			settings=projectFile.get("settings")
		End If
	End If
End Sub

Public Sub Redo
	Dim result As Object=manager.Redo
	If result<>Null Then
		projectFile=result
		If projectFile.ContainsKey("lines") Then
			lines=projectFile.get("lines")
		End If
		If projectFile.ContainsKey("settings") Then
			settings=projectFile.get("settings")
		End If
	End If
End Sub

Public Sub GetMediaPath As String
	Return projectFile.Get("mediaPath")
End Sub

Public Sub Clear
	lines.Clear
	AddState
End Sub

Public Sub Sort
	Dim newLines As List
	newLines.Initialize
	Dim listForSorting As List
	listForSorting.Initialize
	For Each line As Map In lines
		Dim criteria As SortCriteria
		criteria.Initialize
		criteria.o = line
		criteria.value = Utils.GetMillisecondsFromTimeString(line.Get("startTime"))
		listForSorting.Add(criteria)
	Next
	listForSorting.SortType("value",True)
	For Each criteria As SortCriteria In listForSorting
		newLines.Add(criteria.o)
	Next
	lines.Clear
	lines.AddAll(newLines)
	AddState
End Sub


Public Sub DeleteLine(index As Int)
	lines.RemoveAt(index)
	AddState
End Sub

Public Sub AddLine(startTime As String,endTime As String,source As String,target As String)
	Dim line As Map
	line.Initialize
	line.Put("startTime",startTime)
	line.Put("endTime",endTime)
	line.Put("source",source)
	line.Put("target",target)
	lines.Add(line)
	AddState
End Sub

Private Sub DefaultLine As Map
	Dim line As Map
	line.Initialize
	line.Put("startTime","00:00:00,000")
	line.Put("endTime","00:00:00,000")
	line.Put("source","")
	line.Put("target","")
	Return line
End Sub

Public Sub MergeWithTheNextLine(index As Int)
	If index < lines.Size -2 Then
		Dim line As Map = GetLine(index)
		Dim nextLine As Map = GetLine(index+1)
		line.Put("endTime",nextLine.Get("endTime"))
		line.Put("source",line.Get("source")&nextLine.Get("source"))
		line.Put("target",line.Get("target")&nextLine.Get("target"))
		lines.RemoveAt(index+1)
		AddState
	End If
End Sub

Public Sub AppendLine(index As Int) As Map
	Dim line As Map = DefaultLine
	lines.InsertAt(index+1,line)
	AddState
	Return line
End Sub

Public Sub AppendLineWithTime(index As Int,startTime As String,endTime As String) As Map
	Dim line As Map = DefaultLine
	line.Put("startTime",startTime)
	line.Put("endTime",endTime)
	lines.InsertAt(index+1,line)
	AddState
	Return line
End Sub

Public Sub PrependLineWithTime(index As Int,startTime As String,endTime As String) As Map
	Dim line As Map = DefaultLine
	line.Put("startTime",startTime)
	line.Put("endTime",endTime)
	lines.InsertAt(index,line)
	AddState
	Return line
End Sub

Public Sub PrependLine(index As Int) As Map
	Dim line As Map = DefaultLine
	lines.InsertAt(index,line)
	AddState
	Return line
End Sub

Public Sub GetLine(index As Int) As Map
	Return lines.Get(index)
End Sub

Sub readProjectFile
	Dim json As JSONParser
	json.Initialize(File.ReadString(projectPath,""))
	projectFile=json.NextObject
	lines = projectFile.get("lines")
	settings = projectFile.get("settings")
End Sub

Public Sub save
	AddState
	Dim json As JSONGenerator
	json.Initialize(projectFile)
	File.WriteString(projectPath,"",json.ToPrettyString(4))
End Sub

Private Sub CreateTempFolder
	Dim parent As String = File.GetFileParent(GetMediaPath)
	Dim filename As String = File.GetName(GetMediaPath)
	Dim tmpFolder As String = File.Combine(parent,"tmp")
	Dim dir As String = File.Combine(tmpFolder,filename)
	File.MakeDir(tmpFolder,"")
	File.MakeDir(dir,"")
End Sub

Public Sub GetMediaFolder As String
	Return File.GetFileParent(GetMediaPath)
End Sub

Public Sub GetMediaFilename As String
	Return File.GetName(GetMediaPath)
End Sub

Public Sub GetTmpFolder As String
	Dim parent As String = File.GetFileParent(GetMediaPath)
	Dim filename As String = File.GetName(GetMediaPath)
	Dim tmpFolder As String = File.Combine(parent,"tmp")
	Dim dir As String = File.Combine(tmpFolder,filename)
	Return dir
End Sub

Public Sub setSourceLang(lang As String)
	settings.Put("sourceLang",lang)
End Sub

Public Sub getSourceLang As String
	Return settings.GetDefault("sourceLang","ja")
End Sub

Public Sub setTargetLang(lang As String)
	settings.Put("targetLang",lang)
End Sub

Public Sub getTargetLang As String
	Return settings.GetDefault("targetLang","zh")
End Sub
