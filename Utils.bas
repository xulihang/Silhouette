B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private mPref As Map
End Sub

Public Sub getDataShortsFromBytes(Bytes() As Byte) As Short()
	Dim BC As ByteConverter
	BC.LittleEndian = True
	Return BC.ShortsFromBytes(Bytes)
End Sub

Sub JoinBytes(ListOfArraysOfBytes As List) As Byte()
	Dim size As Int
	For Each b() As Byte In ListOfArraysOfBytes
		size = size + b.Length
	Next
	Dim result(size) As Byte
	Dim index As Int
	Dim bc As ByteConverter 'ByteConverter library
	For Each b() As Byte In ListOfArraysOfBytes
		bc.ArrayCopy(b, 0, result, index, b.Length)
		index = index + b.Length
	Next
	Return result
End Sub

Public Sub RemoveBOM(s As String) As String
	If s.StartsWith(Chr(0xFEFF)) Then
		s = s.SubString(1)
	End If
	Return s
End Sub

'windows, mac or linux
Public Sub DetectOS As String
	Dim os As String = GetSystemProperty("os.name", "").ToLowerCase
	If os.Contains("win") Then
		Return "windows"
	Else If os.Contains("mac") Then
		Return "mac"
	Else
		Return "linux"
	End If
End Sub

Sub GetFilenameWithoutExtension(filename As String) As String
	Try
		filename=filename.SubString2(0,filename.LastIndexOf("."))
	Catch
		Log(LastException)
	End Try
	Return filename
End Sub

Public Sub ShiftTimeString(str As String,offsetMS As Int) As String
	Dim ms As Long = GetMillisecondsFromTimeString(str)
	ms = ms + offsetMS
	Return GetTimeStringFromMilliseconds(ms)
End Sub

Public Sub GetMillisecondsFromTimeString(str As String) As Long
	Dim totalMilliseconds As Long
	Dim hours As Int = str.SubString2(0,2)
	Dim minutes As Int = str.SubString2(3,5)
	Dim seconds As Int = str.SubString2(6,8)
	Dim milliseconds As Int = str.SubString2(9,12)
	totalMilliseconds = hours*60*60*1000 + minutes*60*1000 + seconds*1000 + milliseconds
	Return totalMilliseconds
End Sub

'00:00:15,000
Public Sub GetTimeStringFromMilliseconds(ms As Long) As String
	Dim totalSeconds As Int = ms / 1000
	Dim msLeft As Int = ms - totalSeconds * 1000
	Dim hours As Int =  Floor(totalSeconds / 3600)
	Dim secondsLeft As Int = totalSeconds - hours * 3600
	Dim minutes As Int =  Floor(secondsLeft / 60)
	Dim seconds As Int = secondsLeft - minutes*60
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append(NumberFormat(hours,2,0))
	sb.Append(":")
	sb.Append(NumberFormat(minutes,2,0))
	sb.Append(":")
	sb.Append(NumberFormat(seconds,2,0))
	sb.Append(",")
	sb.Append(NumberFormat(msLeft,3,0))
	Return sb.ToString
End Sub

Public Sub GetScreenPosition(n As Node) As Map
	Dim m As Map = CreateMap("x": 0, "y": 0)
	Dim x = 0, y = 0 As Double
	Dim joNode = n, joScene, joStage As JavaObject
  
	'Get the scene position:
	joScene = joNode.RunMethod("getScene",Null)
	If joScene.IsInitialized = False Then Return m
	x = x + joScene.RunMethod("getX", Null)
	y = y + joScene.RunMethod("getY", Null)

	'Get the stage position:
	joStage = joScene.RunMethod("getWindow", Null)
	If joStage.IsInitialized = False Then Return m
	x = x + joStage.RunMethod("getX", Null)
	y = y + joStage.RunMethod("getY", Null)
  
	'Get the node position in the scene:
	Do While True
		y = y + joNode.RunMethod("getLayoutY", Null)
		x = x + joNode.RunMethod("getLayoutX", Null)
		joNode = joNode.RunMethod("getParent", Null)
		If joNode.IsInitialized = False Then Exit
	Loop

	m.Put("x", x)
	m.Put("y", y)
	Return m
End Sub

Public Sub resetPref
	Dim mPref As Map
End Sub

Sub getPrefMap As Map
	Dim map1 As Map
	If mPref.IsInitialized Then
		map1 = mPref
	Else
		Dim preferencesMap As Map
		If File.Exists(Main.prefPath,"") Then
			preferencesMap = readJsonAsMap(File.ReadString(Main.prefPath,""))
		Else
			preferencesMap.Initialize
		End If
		mPref = preferencesMap
		map1 = preferencesMap
	End If
	Return map1
End Sub

Sub readJsonAsMap(s As String) As Map
	Dim json As JSONParser
	json.Initialize(s)
	Return json.NextObject
End Sub

Sub getMap(key As String,parentmap As Map) As Map
	Dim emptymap As Map
	emptymap.Initialize
	Return parentmap.GetDefault(key,emptymap)
End Sub

Sub readLanguageCode(codesfilePath As String) As Map
	Dim linesList As List
	linesList=File.ReadList(File.DirAssets,"langcodes.txt")
	If codesfilePath<>"" Then
		If File.Exists(codesfilePath,"") Then
			linesList=File.ReadList(codesfilePath,"")
		End If
	End If
	
	Dim headsList As List
	headsList.Initialize
	headsList.AddAll(Regex.Split("	",linesList.Get(0)))
	'Log(headsList)
	
	Dim langcodes As Map
	langcodes.Initialize
	Dim lineNum As Int=1
	For Each line As String In linesList
		If lineNum=1 Then
			lineNum=lineNum+1
			Continue
		End If
		Dim colIndex As Int=0
		Dim code As String=Regex.Split("	",line)(0)
		Dim codesMap As Map
		codesMap.Initialize
		For Each value As String In Regex.Split("	",line)
			If colIndex=0 Then
				colIndex=colIndex+1
				Continue
			End If
			If value<>"" Then
				codesMap.Put(headsList.Get(colIndex),value)
			End If
			colIndex=colIndex+1
		Next
		langcodes.Put(code,codesMap)
	Next
	Return langcodes
End Sub

