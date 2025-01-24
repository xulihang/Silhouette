B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private vadDetector As JavaObject
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
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

Public Sub Detect(wavPath As String) As List
	Dim fileJO As JavaObject
	fileJO.InitializeNewInstance("java.io.File",Array(wavPath))
	Dim result As List = vadDetector.RunMethod("getSpeechSegmentList",Array(fileJO))
	Dim timeSegments As List
	timeSegments.Initialize
	For Each segment As JavaObject In result
		Dim m As Map
		m.Initialize
		m.Put("startTime",segment.RunMethod("getStartSecond",Null))
		m.Put("endTime",segment.RunMethod("getEndSecond",Null))
		timeSegments.Add(m)
	Next
	Return timeSegments
End Sub
