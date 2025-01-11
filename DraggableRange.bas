﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private mBase As Pane
	Private iv As ImageView
	Type PositionData (PressedX As Double, PressedY As Double, isLeft As Boolean)
	Private mStartProgress As Double = 0
	Private mEndProgress As Double = 1
	Private mCallBack As Object 'ignore
	Private mEventName As String 'ignore
	Public Tag As Object
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Callback As Object, EventName As String) As Pane
	mBase.Initialize("Pane")
	iv.Initialize("iv")
	iv.PreserveRatio = True
	mBase.AddNode(iv,0,0,0,0)
	mCallBack = Callback
	mEventName = EventName
	Return mBase
End Sub

Public Sub getPane As Pane
	Return mBase
End Sub

Public Sub setProgress(startProgress As Double,endProgress As Double)
	mStartProgress = startProgress
	mEndProgress = endProgress
	Redraw(mBase.Width,mBase.Height)
End Sub

Public Sub TriggerRangeChanged
	If SubExists(mCallBack,mEventName&"_RangeChanged") Then
		CallSubDelayed3(mCallBack,mEventName&"_RangeChanged",mStartProgress,mEndProgress)
	End If
End Sub

Public Sub getStartProgress As Double
	Return mStartProgress
End Sub

Public Sub getEndProgress As Double
	Return mEndProgress
End Sub

Sub iv_MouseDragged (EventData As MouseEvent)
	Dim event As JavaObject = EventData
	Dim view As ImageView = Sender
	Dim pd As PositionData = view.Tag
	Dim XDiff As Double =  event.RunMethod("getSceneX",Null) - pd.pressedX
	Dim startIndex As Int = view.Width * mStartProgress
	Dim endIndex As Int = view.Width * mEndProgress
	If pd.isLeft Then
		mStartProgress = Max(0, Min(startIndex + XDiff,endIndex) / view.Width)
	Else
		mEndProgress = Min(1, Max(startIndex,endIndex + XDiff) / view.Width)
	End If
	pd.PressedX = event.RunMethod("getSceneX",Null)
	pd.PressedY = event.RunMethod("getSceneY",Null)
	Draw(view.Width,view.Height)
	If SubExists(mCallBack,mEventName&"_RangeChanged") Then
		CallSubDelayed3(mCallBack,mEventName&"_RangeChanged",mStartProgress,mEndProgress)
	End If
End Sub

Sub iv_MousePressed (EventData As MouseEvent)
	Dim view As ImageView = Sender
	Dim pd As PositionData
	Dim event As JavaObject = EventData
	pd.PressedX = event.RunMethod("getSceneX",Null)
	pd.PressedY = event.RunMethod("getSceneY",Null)
	Dim startIndex As Int = view.Width * mStartProgress
	Dim endIndex As Int = view.Width * mEndProgress
	If EventData.X < (startIndex + (endIndex - startIndex)/2) Then
		pd.isLeft = True
	Else
		pd.isLeft = False
	End If
	view.Tag = pd
End Sub

Private Sub iv_MouseMoved (EventData As MouseEvent)
	iv.MouseCursor = fx.Cursors.MOVE
End Sub

Public Sub Redraw(width As Double,height As Double)
	Dim w As Int = width
	Dim h As Int = height
	iv.SetSize(w,h)
	Draw(w,h)
End Sub

Private Sub Pane_Resize(width As Double,height As Double)
	Redraw(width,height)
End Sub

Private Sub Draw(width As Int,height As Int)
	Dim startIndex As Int = width * mStartProgress
	Dim endIndex As Int = width * mEndProgress
	Dim xui As XUI
	Dim bc As BitmapCreator
	bc.Initialize(width,height)
	bc.DrawLine(startIndex,0,startIndex,height,xui.Color_Green,3)
	bc.DrawLine(endIndex,0,endIndex,height,xui.Color_Green,3)
	
	bc.DrawLine(startIndex,0,startIndex+5,0,xui.Color_Green,5)
	bc.DrawLine(startIndex,height-1,startIndex+5,height-1,xui.Color_Green,5)
	
	bc.DrawLine(endIndex,0,endIndex - 5,0,xui.Color_Green,5)
	bc.DrawLine(endIndex,height-1,endIndex - 5,height-1,xui.Color_Green,5)
	
	iv.SetImage(bc.Bitmap)
End Sub