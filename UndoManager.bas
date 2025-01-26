B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.7
@EndOfDesignText@
Sub Class_Globals
	Private stack As List
	Private ser As B4XSerializator
	Private index As Int
	Private const MAX_STACK_SIZE As Int = 100
	Private const interval As Int=1000
	Private lastTime As Long
End Sub

Public Sub Initialize (InitialState As Object)
	stack.Initialize
	index = -1
	AddState(InitialState)	
End Sub

Public Sub AddState (state As Object)
	If DateTime.Now-lastTime<interval Then
		Return
	End If
	Dim b() As Byte = ser.ConvertObjectToBytes(state)
	If DifferentThanPrevState(b) Then
		If index < stack.Size - 1 Then
			'this happens when a new state is added after one or more undo actions.
			For i = stack.Size - 1 To index + 1 Step - 1
				stack.RemoveAt(i)
			Next
		End If
		stack.Add(b)
		If stack.Size >= MAX_STACK_SIZE Then
			stack.RemoveAt(1) 'keep the initial state
		End If
		index = stack.Size - 1
		lastTime=DateTime.Now
	End If	
	'Log($"Stack size: ${stack.Size}"$)
End Sub

Public Sub Undo As Object
	If index > 0 Then index = index - 1
	Return ser.ConvertBytesToObject(stack.Get(index))
End Sub

'Will return Null if there is no redo state available.
Public Sub Redo As Object
	If index < stack.Size - 1 Then
		index = index + 1
		Return ser.ConvertBytesToObject(stack.Get(index))
	End If
	Return Null
End Sub

Private Sub DifferentThanPrevState(b() As Byte) As Boolean
	If index = -1 Then Return True
	Dim prev() As Byte = stack.Get(index)
	Return Not(CompareArrays(prev, b))
End Sub

Private Sub CompareArrays(a1() As Byte, a2() As Byte) As Boolean
	If a1.Length <> a2.Length Then Return False
	For i = 0 To a1.Length - 1
		If a1(i) <>  a2(i) Then Return False
	Next
	Return True
End Sub