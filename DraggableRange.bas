B4J=true
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
	Private mCurrentProgress As Double = -1
	Private mStopProgress As Double = -1
	Private mMouseOverProgress As Double = -1
	Private mLastMouseOverProgress As Double
	Private mPreviousRangeStartProgress As Double
	Private mPreviousRangeEndProgress As Double
	Private mNextRangeStartProgress As Double
	Private mNextRangeEndProgress As Double
	Public Tag As Object
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Callback As Object, EventName As String) As Pane
	mBase.Initialize("Pane")
	iv.Initialize("iv")
	iv.PreserveRatio = True
	iv.PickOnBounds = True
	mBase.AddNode(iv,0,0,0,0)
	mCallBack = Callback
	mEventName = EventName
	Return mBase
End Sub

Public Sub getPane As Pane
	Return mBase
End Sub

Public Sub getImageView As ImageView
	Return iv
End Sub

Public Sub setProgress(startProgress As Double,endProgress As Double)
	mStartProgress = startProgress
	mEndProgress = endProgress
	Redraw(mBase.Width,mBase.Height)
End Sub

Public Sub setPreviousAndNextProgress(previousStartProgress As Double,preivousEndProgress As Double,nextStartProgress As Double,nextEndProgress As Double)
	Log(previousStartProgress)
	Log(preivousEndProgress)
	Log(nextStartProgress)
	Log(nextEndProgress)
	mPreviousRangeStartProgress = previousStartProgress
	mPreviousRangeEndProgress = preivousEndProgress
	mNextRangeStartProgress = nextStartProgress
	mNextRangeEndProgress = nextEndProgress
	Redraw(mBase.Width,mBase.Height)
End Sub

Public Sub setPlayTimeProgress(progress As Double)
	mCurrentProgress = progress
	Redraw(mBase.Width,mBase.Height)
End Sub

Public Sub getPlayTimeProgress As Double
	Return mCurrentProgress
End Sub

Public Sub setStopProgress(progress As Double)
	mStopProgress = progress
	Redraw(mBase.Width,mBase.Height)
End Sub

Public Sub getStopProgress As Double
	Return mStopProgress
End Sub

Public Sub getMouseOverProgress As Double
	Return mMouseOverProgress
End Sub

Public Sub getLastMouseOverProgress As Double
	Return mLastMouseOverProgress
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
	mLastMouseOverProgress = mMouseOverProgress
	mMouseOverProgress = -1
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
	mMouseOverProgress = EventData.X / iv.Width
	mLastMouseOverProgress = mMouseOverProgress
	Draw(iv.Width,iv.Height)
	If SubExists(mCallBack,mEventName&"_MouseMoved") Then
		CallSubDelayed2(mCallBack,mEventName&"_MouseMoved",mMouseOverProgress)
	End If
End Sub

Private Sub iv_MouseClicked (EventData As MouseEvent)
	If SubExists(mCallBack,mEventName&"_MouseClicked") Then
		CallSubDelayed2(mCallBack,mEventName&"_MouseClicked",EventData)
	End If
End Sub


Private Sub iv_MouseExited (EventData As MouseEvent)
	mMouseOverProgress = -1
	Draw(iv.Width,iv.Height)
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
	Dim xui As XUI
	Dim bc As BitmapCreator
	bc.Initialize(width,height)
	
	Dim i As Int
	For Each progress As Double In Array(mPreviousRangeStartProgress,mPreviousRangeEndProgress,mNextRangeStartProgress,mNextRangeEndProgress)
		If progress <> -1 Then
			If i Mod 2 == 0 Then
				DrawLeftLine(bc,width,height,progress,xui.Color_LightGray)
			Else
				DrawRightLine(bc,width,height,progress,xui.Color_LightGray)
			End If
		End If
		i = i+1
	Next
	
	DrawLeftLine(bc,width,height,mStartProgress,xui.Color_Green)
	DrawRightLine(bc,width,height,mEndProgress,xui.Color_Green)

	If mCurrentProgress <> -1 Then
		bc.DrawLine(width * mCurrentProgress,0,width * mCurrentProgress,height,xui.Color_Blue,1)
	End If
	
	If mMouseOverProgress <> -1 Then
		bc.DrawLine(width * mMouseOverProgress,0,width * mMouseOverProgress,height,xui.Color_Black,1)
	End If
	
	If mStopProgress <> -1 Then
		bc.DrawLine(width * mStopProgress,0,width * mStopProgress,height,xui.Color_Yellow,1)
	End If
	
	iv.SetImage(bc.Bitmap)
End Sub

Private Sub DrawLeftLine(bc As BitmapCreator,width As Int,height As Int,progress As Double,color As Int)
	Dim startIndex As Int = width * progress
	bc.DrawLine(startIndex,0,startIndex,height,color,3)
	bc.DrawLine(startIndex,0,startIndex+5,0,color,5)
	bc.DrawLine(startIndex,height-1,startIndex+5,height-1,color,5)
End Sub

Private Sub DrawRightLine(bc As BitmapCreator,width As Int,height As Int,progress As Double,color As Int)
	Dim endIndex As Int = width * progress
	bc.DrawLine(endIndex,0,endIndex,height,color,3)
	bc.DrawLine(endIndex,0,endIndex - 5,0,color,5)
	bc.DrawLine(endIndex,height-1,endIndex - 5,height-1,color,5)
End Sub