B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private frm As Form
	Private Label1 As Label
	Private ProgressBar1 As ProgressBar
End Sub

'input a random type name
Sub Show(title As String)
	close
	frm.Initialize("frm",600,200)
	frm.RootPane.LoadLayout("progress")
	frm.Title=title
	frm.Show
End Sub

'show with width and height
Sub Show2(title As String,width As Int,height As Int)
	close
	frm.Initialize("frm",width,height)
	frm.RootPane.LoadLayout("progress")
	frm.Title=title
	frm.Show
End Sub

Sub isShowing As Boolean
	Return frm.Showing
End Sub


Sub hideProgressBar
	ProgressBar1.Visible=False
End Sub

Sub update(completed As Int,segmentSize As Int)
	ProgressBar1.Visible=True
	Label1.Text=completed&"/"&segmentSize
	ProgressBar1.Progress=completed/segmentSize
End Sub

Sub update2(info As String)
	Label1.Text=info
	hideProgressBar
End Sub

Sub delayedInfo(info As String)
	Label1.Text=info
	Sleep(2000)
	close
End Sub

Sub close
	If frm.IsInitialized Then
		frm.Close
	End If
End Sub

Sub frm_CloseRequest (EventData As Event)
	EventData.Consume
End Sub

Sub Button1_MouseClicked (EventData As MouseEvent)
	ASR.KillCurrentShell
	frm.Close
End Sub