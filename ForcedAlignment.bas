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
	For Each line As Map In lines
		Dim source As String = line.Get("source")
		Dim appendedSource As String
		Dim appendedTarget As String
		Dim index As Int
		Dim indexList As List
		indexList.Initialize
		For Each segment As Map In alignedSegments
			indexList.Add(index)
			Dim segmentSource As String = segment.Get("source")
			Dim segmentTarget As String = segment.Get("target")
			appendedSource = appendedSource & segmentSource
			appendedTarget = appendedTarget & segmentTarget
			If segmentSource == "" Then
				Dim newLine As Map
				newLine.Initialize
				newLine.Put("source",appendedTarget)
				newLine.Put("target","")
				newLine.Put("startTime",line.Get("endTime"))
				newLine.Put("endTime",Utils.GetTimeStringFromMilliseconds(Utils.GetMillisecondsFromTimeString(line.Get("endTime"))+1000))
				newLines.Add(newLine)
				Exit
			Else
				If GetRatio(source,appendedSource) > 0.9 Then
					line.Put("source",appendedTarget)
					newLines.Add(line)
					Exit
				End If
			End If
            index = index + 1
		Next
		For Each index As Int In indexList
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
			startTime = Utils.GetTimeStringFromMilliseconds(Utils.GetMillisecondsFromTimeString(lastLine.Get("endTime"))+1000)
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