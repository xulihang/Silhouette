B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Public Sub AlignByText(lines As List,alignedSegments As List) As List
	
	Log(lines)
	Log(alignedSegments)
	Dim newLines As List
	newLines.Initialize

	Dim previousStartTime As String
	Dim appendedLineSource As String
	For i = 0 To lines.Size - 1
		Dim line As Map = lines.Get(i)
		Dim source As String = line.Get("source")
		appendedLineSource = appendedLineSource & source
		Dim index As Int
		Dim indexList As List
		indexList.Initialize
		Dim appendedSource As String
		Dim appendedTarget As String
		For Each segment As Map In alignedSegments
			Dim segmentSource As String = segment.Get("source")
			Dim segmentTarget As String = segment.Get("target")
			appendedSource = appendedSource & segmentSource
			appendedTarget = appendedTarget & segmentTarget
			Log(appendedLineSource)
			Log(appendedSource)
			If segmentSource == "" Then
				Log("new line")
				previousStartTime = ""
				Dim newLine As Map
				newLine.Initialize
				newLine.Put("source",appendedTarget)
				newLine.Put("target","")
				newLine.Put("startTime",line.Get("startTime"))
				newLine.Put("endTime",Utils.GetTimeStringFromMilliseconds(Utils.GetMillisecondsFromTimeString(line.Get("startTime"))+1000))
				newLines.Add(newLine)
				appendedSource = ""
				appendedTarget = ""
				appendedLineSource = ""
				i = i - 1
				indexList.Add(index)
				Exit
			Else
				If appendedSource.Length / appendedLineSource.Length > 1.5 Then 'not match
					Log("source not enough")
					previousStartTime = line.Get("startTime")
					Exit
				End If
				Dim ratio As Double = GetRatio(appendedLineSource,appendedSource)
				If  ratio > 0.9 Then
					Log("suitable")
					If previousStartTime <> "" Then
						line.Put("startTime",previousStartTime)
					End If
					line.Put("source",appendedTarget)
					newLines.Add(line)
					appendedSource = ""
					appendedTarget = ""
					appendedLineSource = ""
					previousStartTime = ""
					indexList.Add(index)
					Exit
				End If
			End If
			indexList.Add(index)
            index = index + 1
		Next
		For Each index As Int In indexList
			Log("delete source: "&alignedSegments.Get(0))
			alignedSegments.RemoveAt(0)
		Next
	Next

	If alignedSegments.Size>0 And newLines.Size>0 Then
		Dim lastLine As Map = newLines.Get(newLines.Size - 1)
		Dim startTime As String = lastLine.Get("endTime")
		For Each segment As Map In alignedSegments
			Dim segmentTarget As String = segment.Get("target")
			Dim newLine As Map
			newLine.Initialize
			newLine.Put("source",segmentTarget)
			newLine.Put("target","")
			newLine.Put("startTime",startTime)
			'new start time
			startTime = Utils.GetTimeStringFromMilliseconds(Utils.GetMillisecondsFromTimeString(startTime)+1000)
			newLine.Put("endTime",startTime)
			newLines.Add(newLine)
		Next
	End If
	Return newLines
End Sub

Private Sub GetRatio(str1 As String,str2 As String) As Double
	If str1.Length>str2.Length Then
		Return str2.Length/str1.Length
	Else
		Return str1.Length/str2.Length
	End If
End Sub