B4J=true
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
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mediaPath As String)
	Dim filename As String = File.GetName(mediaPath)
	Dim dir As String = File.GetFileParent(mediaPath)
	projectPath = File.Combine(dir,Utils.GetFilenameWithoutExtension(filename)&".sip")
	If File.Exists(projectPath,"") Then
		readProjectFile
	Else
		projectFile.Initialize
		lines.Initialize
		settings.Initialize
		projectFile.Put("mediaPath",mediaPath)
		projectFile.Put("lines",lines)
		projectFile.Put("settings",settings)
		CreateTempFolder
	End If
End Sub

Public Sub GetMediaPath As String
	Return projectFile.Get("mediaPath")
End Sub

Public Sub Clear
	lines.Clear
End Sub

Public Sub DeleteLine(index As Int)
	lines.RemoveAt(index)
End Sub

Public Sub AddLine(startTime As String,endTime As String,source As String,target As String)
	Dim line As Map
	line.Initialize
	line.Put("startTime",startTime)
	line.Put("endTime",endTime)
	line.Put("source",source)
	line.Put("target",target)
	lines.Add(line)
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

Public Sub AppendLine(index As Int) As Map
	Dim line As Map = DefaultLine
	lines.InsertAt(index+1,line)
	Return line
End Sub

Public Sub PrependLine(index As Int) As Map
	Dim line As Map = DefaultLine
	lines.InsertAt(index,line)
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