B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private ProjectFile As Map
	Public segments As List
	Public paragraphs As Map
	Private path As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(projectPath As String)
	ProjectFile.Initialize
	segments.Initialize
	paragraphs.Initialize
	path=projectPath
End Sub

Public Sub GetLangPair As Map
	Return ProjectFile.Get("langPair")
End Sub

' segment paragraphs into sentences
Public Sub loadSegmentsInSentenceLevel(srxPath As String) As ResumableSub
	Log("segmenting...")
	Log(srxPath)
	Dim segmentsForIteration As List
	segmentsForIteration.Initialize
	segmentsForIteration.AddAll(segments)
	segments.Clear
	Dim sourceSegments,targetSegments,notes,ids As List
	sourceSegments.Initialize
	targetSegments.Initialize
	notes.Initialize
	ids.Initialize
	For i=0 To segmentsForIteration.Size-1
		'Log(i)
		Dim initSize As Int=sourceSegments.Size
		Dim segment As Map
		segment=segmentsForIteration.Get(i)
		Dim source,target As String
		source=segment.Get("source")
		target=segment.Get("target")
		Dim para As Map
		para.Initialize
		para.Put("source",source)
		para.Put("target",target)
		
		Dim langPair As Map=ProjectFile.Get("langPair")
		Dim index As Int=0
		wait for (segmentation.segmentedTxt(source,True,langPair.Get("source"),srxPath,True)) Complete (segmented As List)
		For Each sentence As String In segmented
			If sentence.Trim<>"" Then
				sourceSegments.Add(sentence.Trim)
				If index=0 Then
					notes.Add(segment.Get("note"))
				Else
					notes.Add("")
				End If
				index=index+1
			End If
		Next
		
		Wait For (segmentation.segmentedTxt(target,True,langPair.Get("target"),srxPath,False)) Complete (segmented As List)
		For Each sentence As String In segmented
			If sentence.Trim<>"" Then
				targetSegments.Add(sentence.Trim)
			End If
		Next
		
		If targetSegments.Size<sourceSegments.Size Then
			For j=1 To sourceSegments.Size-targetSegments.Size
				targetSegments.Add("")
			Next
		else if targetSegments.Size>sourceSegments.Size Then
			For j=1 To targetSegments.Size-sourceSegments.Size
				sourceSegments.Add("")
				notes.Add("")
			Next
		End If
		
		For k=1 To sourceSegments.Size-initSize
			ids.Add(i)
		Next
		Dim paraNum As String=i
		para.Put("size",sourceSegments.Size-initSize)
		paragraphs.Put(paraNum,para)
	Next
	Dim result As Map
	result.Initialize
	result.Put("source",sourceSegments)
	result.Put("target",targetSegments)
	result.Put("notes",notes)
	result.Put("ids",ids)
	Log("done")
	Log(ids.Size)
	Log(sourceSegments.Size)
	loadItemsToSegments(result)
	Return ""
End Sub

Sub AddEmptySegmentsForNonTranslated(sourceList As List,targetList As List)
	Dim index As Int=0
	Dim positions As List
	positions.Initialize
	For Each text As String In sourceList
		Dim neighboringText As String=NeighboringSegmentsText(index+positions.Size,targetList)
		If sourceList.Size<>targetList.Size Then
			For Each number As String In NumbersInSegment(text)
				If neighboringText.Contains(number)=False Then
					If index<targetList.Size-1 Then
						positions.Add(index)
					End If
					Exit
				End If
			Next
		Else
			Return
		End If
		index=index+1
	Next
	positions.Sort(True)
	Log(positions)
	For Each pos As Int In positions
		Log(pos)
		targetList.InsertAt(pos,"")
	Next
End Sub

Sub NeighboringSegmentsText(index As Int,targetList As List) As String
	Dim neighbor As List
	neighbor.Initialize
	For i=Max(0,index-5) To Min(index+5,targetList.size-1)
		neighbor.Add(targetList.Get(i))
	Next
	Dim sb As StringBuilder
	sb.Initialize
	For Each text As String In neighbor
		sb.Append(text)
	Next
	Return sb.ToString
End Sub

Sub NumbersInSegment(text As String) As List
	Dim result As List
	result.Initialize
	Dim matcher As Matcher
	matcher=Regex.Matcher("\d+",text)
	Do While matcher.Find
		result.Add(matcher.Match)
	Loop
	Return result
End Sub

Public Sub loadItemsToSegments(result As Map)
	segments.Clear
	Dim sourceSegments,targetSegments,notes,ids As List
	sourceSegments=result.Get("source")
	targetSegments=result.Get("target")
	'AddEmptySegmentsForNonTranslated(sourceSegments,targetSegments)
	If result.ContainsKey("notes") Then
		notes=result.Get("notes")
	Else
		notes.Initialize
	End If
	If result.ContainsKey("ids") Then
		ids=result.Get("ids")
	Else
		ids.Initialize
	End If
	appendSegments(sourceSegments,targetSegments,notes,ids)
End Sub

Sub appendSegments(sourceSegments As List,targetSegments As List,notes As List,ids As List)
	For i=0 To Max(sourceSegments.Size-1,targetSegments.size-1)
		Dim segment As Map
		segment.Initialize
		If i<=sourceSegments.Size-1 Then
			segment.Put("source",sourceSegments.Get(i))
		Else
			segment.Put("source","")
		End If
		If i<=targetSegments.Size-1 Then
			segment.Put("target",targetSegments.Get(i))
		Else
			segment.Put("target","")
		End If
		If i<=notes.Size-1 Then
			segment.Put("note",notes.Get(i))
		Else
			segment.Put("note","")
		End If
		If i<=ids.Size-1 Then
			segment.Put("id",ids.Get(i))
		End If
		segments.Add(segment)
	Next
End Sub

Public Sub RemoveSegments(segmentTexts As List,isSource As Boolean)
	Dim new As List
	new.Initialize
	For Each segment As Map In segments
		Dim text As String
		If isSource Then
			text=segment.Get("source")
		Else
			text=segment.Get("target")
		End If
		If segmentTexts.IndexOf(text)=-1 Then
			new.Add(segment)
		End If
	Next
	segments.Clear
	segments.AddAll(new)
End Sub

Public Sub setProjectFileValue(key As Object,value As Object)
	ProjectFile.Put(key,value)
End Sub

Public Sub getProjectFileValue(key As Object) As Object
	Return ProjectFile.GetDefault(key,Null)
End Sub

Public Sub saveProjectFile
	Dim json As JSONGenerator
	json.Initialize(ProjectFile)
	File.WriteString(path,"",json.ToPrettyString(4))
End Sub

Public Sub readProjectFile
	Dim json As JSONParser
	json.Initialize(File.ReadString(path,""))
	ProjectFile=json.NextObject
	If ProjectFile.ContainsKey("segments") Then
		segments=ProjectFile.Get("segments")
	End If
	If ProjectFile.ContainsKey("paragraphs") Then
		paragraphs=ProjectFile.Get("paragraphs")
	End If
End Sub

Public Sub save
	ProjectFile.Put("segments",segments)
	ProjectFile.Put("paragraphs",paragraphs)
	Dim json As JSONGenerator
	json.Initialize(ProjectFile)
	File.WriteString(path,"",json.ToPrettyString(4))
End Sub