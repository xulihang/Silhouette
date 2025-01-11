B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
Sub Class_Globals
	Type WavHeaderType(StartPos As Long, Length As Long)
	Private mRaf As RandomAccessFile
	Private mDataChunkStart As Long
	Private mDataChunkEnd As Long
	Private mDataChunkLength As Long
	Private mLengthInFrames As Int
	Private mFrameLength As Int
	Private mDuration As Long
	Private mAudioFormat As JavaObject
	Private mSampleRateInHz As Float
	Private mSampleSizeInBits As Int
	Private mChannelConfig As Int
	Private mDirPath As String
	Private mFileName As String
	Private mWavHeaderChunkMap As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(DirPath As String,FileName As String) As Boolean
	mDirPath = DirPath
	mFileName = FileName
	
	mRaf.Initialize(mDirPath,FileName,True)
	mWavHeaderChunkMap.Initialize
	
	If ReadWavHeaderChunks(mRaf,mWavHeaderChunkMap) = False Then
		Log("Invalid header format")
		Return False
	End If
	
	Dim jFile As JavaObject
	jFile.InitializeNewInstance("java.io.File",Array(mDirPath,FileName))
	
	Dim Audsys As JavaObject
	Audsys.InitializeStatic("javax.sound.sampled.AudioSystem")
	mAudioFormat = Audsys.RunMethodJO("getAudioFileFormat",Array(jFile)).RunMethod("getFormat",Null)
	
	mSampleRateInHz = mAudioFormat.RunMethod("getSampleRate",Null)
	mSampleSizeInBits = mAudioFormat.RunMethod("getSampleSizeInBits",Null)
	mChannelConfig = mAudioFormat.RunMethod("getChannels",Null)
	
	Dim data As WavHeaderType = mWavHeaderChunkMap.Get("data")
	If data.IsInitialized Then
		mFrameLength = (mChannelConfig * (mSampleSizeInBits / 8))
		mDataChunkStart = data.StartPos
		mDataChunkLength = data.Length
		mDataChunkEnd = mDataChunkStart + data.Length
		mDuration = (mDataChunkLength) / (mSampleRateInHz * mFrameLength)
		mLengthInFrames = (mDataChunkLength) / mFrameLength
	End If
	
	Return True
End Sub

Public Sub getWavHeaderChunkMap As Map
	Return mWavHeaderChunkMap
End Sub

Public Sub getAudioFormat As JavaObject
	Return mAudioFormat
End Sub

Public Sub getSampleRateInHz As Float
	Return mSampleRateInHz
End Sub

Public Sub getSamplesizeInBits As Int
	Return mSampleSizeInBits
End Sub

Public Sub getChannelConfig As Int
	Return mChannelConfig
End Sub

Public Sub getDirPath As String
	Return mDirPath
End Sub

Public Sub getFileName As String
	Return mFileName
End Sub

'Track Duration in Seconds
Public Sub getDuration As Long
	Return mDuration
End Sub

'Track Duration in milliSeconds
Public Sub getDuration_ms As Long
	Return mDuration * 1000
End Sub

Public Sub getLengthInFrames As Int
	Return mLengthInFrames
End Sub

Public Sub getFrameLength As Int
	Return mFrameLength
End Sub

'Get the underlying RandomAccessFile
Public Sub getRandomAccessFile As RandomAccessFile
	Return mRaf
End Sub

'Start of the 'data' chunk in the file
Public Sub getDataChunkStart As Long
	Return mDataChunkStart
End Sub
'end of the 'data' chunk in the file
Public Sub getDataChunkEnd As Long
	Return mDataChunkEnd
End Sub
Public Sub getDataChunkLength As Long
	Return mDataChunkLength
End Sub

Public Sub Read8bitAsShort(Length As Int, Position As Int) As Short()
	Dim Shorts(Length) As Short
	Dim Bytes(Length) As Byte
	mRaf.ReadBytes(Bytes,0,Length,Position)
	For i = 0 To Bytes.Length - 1
		Shorts(i) = Bytes(i)
	Next
	Return Shorts
End Sub

Public Sub Read8bitAsFloats(Length As Int, Position As Int) As Float()
	Dim Floats(Length) As Float
	Dim Bytes(Length) As Byte
	mRaf.ReadBytes(Bytes,0,Length,Position)
	For i = 0 To Bytes.Length - 1
		Floats(i) = Bytes(i)
	Next
	Return Floats
End Sub

Public Sub Read8BitAsNormalizedFloats(Length As Int, Position As Int) As Float()
	Dim Floats(Length) As Float
	Dim Bytes(Length) As Byte
	mRaf.ReadBytes(Bytes,0,Length,Position)
	Dim B As JavaObject
	B.InitializeNewInstance("java.lang.Byte",Array("0"))
	Dim BYTE_MAXVALUE As Byte = B.GetField("MAX_VALUE")
	For i = 0 To Bytes.Length - 1
		Floats(i) = Bytes(i) / BYTE_MAXVALUE
	Next
	Return Floats
End Sub

Public Sub Read8bitAsDoubles(Length As Int, Position As Int) As Double()
	Dim Doubles(Length) As Double
	Dim Bytes(Length) As Byte
	mRaf.ReadBytes(Bytes,0,Length,Position)
	For i = 0 To Bytes.Length - 1
		Doubles(i) = Bytes(i)
	Next
	Return Doubles
End Sub

'Convienience function : Returns An array of Doubles Length / 2 in length.
Public Sub Read16bitAsDoubles(Length As Int, Position As Long) As Double()
	Dim Shorts() As Short = Read16bitAsShort(Length, Position)
	Dim Doubles(Shorts.Length) As Double
	For i = 0 To Shorts.Length - 1
		Doubles(i) = Shorts(i)
	Next
	Return Doubles
End Sub

'Convienience function : Returns An array of Floats Length / 2 in length.
Public Sub Read16bitAsFloats(Length As Int, Position As Long) As Float()
	Dim Shorts() As Short = Read16bitAsShort(Length, Position)
	Dim Floats(Shorts.Length) As Float
	For i = 0 To Shorts.Length - 1
		Floats(i) = Shorts(i)
	Next
	Return Floats
End Sub

'Convienience function : Returns An array of Floats Length / 2 in length with values between - 1 and 1
Public Sub Read16bitAsNormalisedFloats(Length As Int, Position As Long) As Float()
	Dim Shorts() As Short = Read16bitAsShort(Length, Position)
	Dim S As JavaObject
	S.InitializeNewInstance("java.lang.Short",Array("0"))
	Dim SHORT_MAXVALUE As Short = S.GetField("MAX_VALUE")
	Dim Floats(Shorts.Length) As Float
	For i = 0 To Shorts.Length - 1
		Floats(i) = Shorts(i) / SHORT_MAXVALUE
	Next
	Return Floats
End Sub

'Convienience function : Returns An array of Floats Length / 2 in length with values between - 1 and 1
Public Sub Read16bitAsNormalisedDoubles(Length As Int, Position As Long) As Double()
	Dim Shorts() As Short = Read16bitAsShort(Length, Position)
	Dim S As JavaObject
	S.InitializeNewInstance("java.lang.Short",Array("0"))
	Dim SHORT_MAXVALUE As Short = S.GetField("MAX_VALUE")
	Dim dobles(Shorts.Length) As Double
	For i = 0 To Shorts.Length - 1
		dobles(i) = Shorts(i) / SHORT_MAXVALUE
	Next
	Return dobles
End Sub

'Convienience function : Returns An array of Shorts Length / 2 in length.
Public Sub Read16bitAsShort(Length As Int, Position As Long) As Short()
	Dim BC As ByteConverter
	BC.LittleEndian = True
	Dim Bytes(Length) As Byte
	mRaf.ReadBytes(Bytes,0,Length,Position)
	Return BC.ShortsFromBytes(Bytes)
End Sub

Public Sub getDataBytes As Byte()
	Dim Buffer(mDataChunkEnd - mDataChunkStart) As Byte
	mRaf.ReadBytes(Buffer,0,Buffer.Length,mDataChunkStart)
	Return Buffer
End Sub

Public Sub getDataShorts As Short()
	Dim BC As ByteConverter
	BC.LittleEndian = True
	Dim Bytes() As Byte = getDataBytes
	Return BC.ShortsFromBytes(Bytes)
End Sub

Public Sub getDataDoubles As Double()
	Dim ShortBuffer() As Short = getDataShorts
	Dim DoubleBuffer(ShortBuffer.Length) As Double
	For i = 0 To ShortBuffer.Length - 1
		DoubleBuffer(i) = ShortBuffer(i)
	Next
	Return DoubleBuffer
End Sub

'Close the RandomAccessFile
Public Sub Close
	mRaf.close
End Sub

'Parse the waf file header and find the start and end positions for each chunk.
'Returns false if a data chunk is not found.
'Parse the wav file header and find the start and end positions for each chunk.
'Returns false if a data chunk is not found.
Public Sub ReadWavHeaderChunks(Raf As RandomAccessFile, M As Map) As Boolean
	
	Try
		If M.IsInitialized = False Then M.Initialize
		Dim Bytes(4) As Byte
		Dim Pos As Long = 0
		Dim DataFound As Boolean
		Dim StartPos As Long
		Dim Length As Int
		Dim BC As ByteConverter
		BC.LittleEndian = True
	
		If Raf.ReadBytes(Bytes,0,4,Pos) <= 0 Then Return False
		Dim Name As String = BytesToString(Bytes,0,4,"UTF-8")
		If Name.ToLowerCase <> "riff" Then Return False
		Pos = Pos + 4
		StartPos = Pos
		Length = Raf.ReadInt(Pos)
		M.Put(Name,CreateWavHeaderType(StartPos,Length))
	
	
		'Get the file format while we are here
		Pos = 22															'Number of channels
	
		Dim ConvertBuffer(2) As Byte
		Raf.ReadBytes(ConvertBuffer,0,2,Pos)
		mChannelConfig = BC.ShortsFromBytes(ConvertBuffer)(0)
	
		Pos = 24															'SampleRate
		Dim ConvertBuffer(4) As Byte
		Raf.ReadBytes(ConvertBuffer,0,4,Pos)
		mSampleRateInHz = BC.IntsFromBytes(ConvertBuffer)(0)
	
		Pos = 34															'Bits per sample
		Dim ConvertBuffer(2) As Byte
		Raf.ReadBytes(ConvertBuffer,0,2,Pos)
		mSampleSizeInBits = BC.ShortsFromBytes(ConvertBuffer)(0)
	
	
		'First subchunk will always be at byte 12.
		Pos = 12
		Do While True
			If Raf.ReadBytes(Bytes,0,4,Pos) <= 0 Then Exit
			Dim Name As String = BytesToString(Bytes,0,4,"UTF-8")
			If Name.ToLowerCase = "data" Then DataFound = True
			If Name.ToLowerCase = "list" Then
				Dim LPos As Long = Pos + 8
				If Raf.ReadBytes(Bytes,0,4,LPos) <= 0 Then Return False
				Dim ListName As String = BytesToString(Bytes,0,4,"UTF-8")
				Name = Name & "-" & ListName
			End If
			Pos = Pos + 4
			If Raf.ReadBytes(Bytes,0,4,Pos) <= 0 Then Exit
			Length = BC.IntsFromBytes(Bytes)(0)
			Pos = Pos + 4
			StartPos = Pos
			If Length = 0 Then Exit
			M.Put(Name,CreateWavHeaderType(StartPos,Length))
			Pos = Pos + Length
		Loop
	
		If DataFound Then Return True
		Return False
	Catch
		Log(LastException)
		Return False
	End Try
End Sub

Public Sub ReadListData(Raf As RandomAccessFile, ListName As String,MSource As Map, MResult As Map, Chrset As String) As Boolean
	If ListName.Contains("-") = False Then ListName = "list-" & ListName
	Dim Name, Content As String
	Dim Length As Int
	Dim BC As ByteConverter
	BC.LittleEndian = True
	
	For Each Key As String In MSource.Keys
		If Key.ToLowerCase = ListName.ToLowerCase Then
			Dim data As WavHeaderType = MSource.Get(Key)
			Dim Pos As Long = data.StartPos
			Pos = Pos + 4
			Do While Pos < data.StartPos + data.Length
				Dim Bytes(4) As Byte
				If Raf.ReadBytes(Bytes,0,4,Pos) <= 0 Then Return False
				Name = BytesToString(Bytes,0,4,Chrset)
				Pos = Pos + 4
				If Raf.ReadBytes(Bytes,0,4,Pos) <= 0 Then Return False
				Length = BC.IntsFromBytes(Bytes)(0)
				Pos = Pos  + 4
				Dim Bytes(Length) As Byte
				If Raf.ReadBytes(Bytes,0,Length,Pos) <= 0 Then Return False
				Content = BytesToString(Bytes,0,Length,Chrset)
				Pos = Pos + Length
				MResult.Put(Name,Content)
			Loop
		End If
	Next
	If MResult.Size = 0 Then Return False
	Return True
End Sub

Private Sub CreateWavHeaderType (StartPos As Long, Length As Long) As WavHeaderType
	Dim t1 As WavHeaderType
	t1.Initialize
	t1.StartPos = StartPos
	t1.Length = Length
	Return t1
End Sub

