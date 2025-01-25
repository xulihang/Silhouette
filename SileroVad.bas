B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private vadDetector As JavaObject
	Private th As Thread
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	th.Initialise("th")
	Dim MODEL_PATH As String = File.Combine(File.DirApp,"silero_vad.onnx")
	Dim SAMPLE_RATE As Int = 16000
	Dim THRESHOLD As Float= 0.5f
	Dim MIN_SPEECH_DURATION_MS As Int = 250
	Dim FloatJO As JavaObject
	FloatJO.InitializeStatic("java.lang.Float")
	Dim MAX_SPEECH_DURATION_SECONDS As Float = FloatJO.GetField("POSITIVE_INFINITY")
	Dim MIN_SILENCE_DURATION_MS As Int = 100
	Dim SPEECH_PAD_MS As Int = 30
	vadDetector.InitializeNewInstance("org.silerovad.SileroVadDetector",Array(MODEL_PATH, THRESHOLD, SAMPLE_RATE, MIN_SPEECH_DURATION_MS, MAX_SPEECH_DURATION_SECONDS, MIN_SILENCE_DURATION_MS, SPEECH_PAD_MS))
End Sub

Public Sub DetectAsync(wavPath As String) As ResumableSub
	Dim result As List
	result.Initialize
	th.Start(Me,"DetectInner",Array As Map(CreateMap("path":wavPath,"result":result)))
	wait for th_Ended(endedOK As Boolean, error As String)
	Log(endedOK)
	Log(error)
	Return result
End Sub

Public Sub Detect(wavPath As String) As List
	Dim result As List
	result.Initialize
	Return DetectInner(CreateMap("path":wavPath,"result":result))
End Sub

Public Sub DetectInner(map1 As Map) As List
	Dim result As List = map1.Get("result")
	Dim wavPath As String = map1.Get("path")
	Dim fileJO As JavaObject
	fileJO.InitializeNewInstance("java.io.File",Array(wavPath))
	Dim segments As List = vadDetector.RunMethod("getSpeechSegmentList",Array(fileJO))
	For Each segment As JavaObject In segments
		Dim m As Map
		m.Initialize
		m.Put("startTime",segment.RunMethod("getStartSecond",Null))
		m.Put("endTime",segment.RunMethod("getEndSecond",Null))
		result.Add(m)
	Next
	Return result
End Sub

