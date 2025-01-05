﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private xui As XUI
	Private mData() As Short
	Private mAmplitude As Int = 1
	Private mStartIndex As Int = -1
	Private mEndIndex As Int = -1
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(data() As Short)
	mData = data
End Sub

Public Sub getSampleLength As Int
	Return mData.Length
End Sub

Public Sub setAmplitude(value As Int)
	mAmplitude = value
End Sub

Public Sub getAmplitude As Int
	Return mAmplitude
End Sub

Public Sub setStartIndex(index As Int)
	mStartIndex = index
End Sub

Public Sub setEndIndex(index As Int)
	mEndIndex = index
End Sub

Public Sub getStartIndex As Int
	Return mStartIndex
End Sub

Public Sub getEndIndex As Int
	Return mEndIndex
End Sub

Public Sub Draw() As B4XBitmap
	Dim data() As Short
	data = Cut(mData)
	data = Compress(data)
	Dim normalized() As Float= Normalize(data)
	Dim bc As BitmapCreator
	bc.Initialize(3000,500)
	Dim height As Int = 500 - 200
	Dim NbSamples As Int = normalized.Length
	For i = 0 To NbSamples - 1
		If i = NbSamples - 1 Then
			Exit
		End If
		Dim centerY As Double = 250
		Dim x1 As Int = i
		Dim y1 As Double = centerY + normalized(i)*height*mAmplitude
		Dim x2 As Int = i+1
		Dim y2 As Double = centerY + normalized(i+1)*height*mAmplitude
		bc.DrawLine(x1,y1,x2,y2,xui.Color_Red,1)
	Next
	Return bc.Bitmap
End Sub

Private Sub Cut(data() As Short) As Short()
	If mStartIndex <> -1 And mEndIndex <> -1 Then
		Dim length As Long = mEndIndex - mStartIndex
		Dim part(length) As Short
		For i = mStartIndex To mEndIndex - 1
			part(i - mStartIndex) = data(i)
		Next
		Return part
	Else
		Return data
	End If
End Sub

Private Sub Compress(data() As Short) As Short()
	Dim times As Int 
	If data.Length > 3000 Then
		times = data.Length / 3000
	Else
		Return data
	End If
	Dim compressed(3000) As Short
	For i = 0 To compressed.Length - 1
		compressed(i) = data(i*times)
	Next
	Return compressed
End Sub

Private Sub Normalize(data() As Short) As Float()
	Dim normalized(data.Length) As Float
	Dim maxValue As Short = 0
	For i = 0 To data.Length - 1
		Dim value As Short = data(i)
		maxValue = Max(maxValue,value)
	Next
	For i = 0 To data.Length - 1
		normalized(i) = data(i) / maxValue
	Next
	Return normalized
End Sub