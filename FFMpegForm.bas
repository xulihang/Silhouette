B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private ArgumentsTextArea As TextArea
	Private OutputTextArea As TextArea
	Private sh As Shell
	Private workDir As String
	Private StatusLabel As Label
	Private th As Thread
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("FFmpeg")
	Main.loc.LocalizeForm(frm)
	workDir = File.DirApp
	th.Initialise("th")
End Sub

Public Sub SetArguments(arguments As String)
	ArgumentsTextArea.Text = arguments
End Sub

Public Sub SetWorkdir(dir As String)
	workDir = dir
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub Button1_MouseClicked (EventData As MouseEvent)
	Run
End Sub

Private Sub Run As ResumableSub
	StatusLabel.Text = Main.loc.Localize("Processing...")
	Dim args As List = Regex.Split(" ",ArgumentsTextArea.Text)
	Dim sh As Shell
	sh.Initialize("sh",FFMpeg.GetFFMpegPath,args)
	sh.WorkingDirectory = workDir
	sh.RunWithOutputEvents(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	Log(StdOut)
	Log(StdErr)
	StatusLabel.Text = Main.loc.Localize("Done")
	Return Success
End Sub

Private Sub sh_StdOut (Buffer() As Byte, Length As Int)
	Dim bc As ByteConverter
	Dim s As String = bc.StringFromBytes(Buffer,"UTF-8")
	Log(s)
	th.RunOnGuiThread("update",Array As String(s))
End Sub

Private Sub sh_StdErr (Buffer() As Byte, Length As Int)
	Dim bc As ByteConverter
	Dim s As String = bc.StringFromBytes(Buffer,"UTF-8")
	Log(s)
	th.RunOnGuiThread("update",Array As String(s))
End Sub

Private Sub update(s As String)
	OutputTextArea.Text = s
End Sub