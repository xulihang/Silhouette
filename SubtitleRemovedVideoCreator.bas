B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form 
	Private FolderPathTextField As TextField
	Private FPSSpinner As Spinner
	Private OutputPathTextField As TextField
	Private mVideoPath As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(videoPath As String)
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("SubtitleRemovedVideoCreator")
	Main.loc.LocalizeForm(frm)
	mVideoPath = videoPath
End Sub

public Sub Show
	frm.Show
End Sub

Private Sub OKButton_MouseClicked (EventData As MouseEvent)
	Dim videoDir As String = File.GetFileParent(mVideoPath)
	Dim videoName As String = File.GetName(mVideoPath)
	Dim imgDir As String = FolderPathTextField.Text
	Dim wavPath As String = File.Combine(imgDir,"audio.wav")
	Dim outputPath As String = OutputPathTextField.Text
	Dim frameRate As Int = FPSSpinner.Value
	progressDialog.Show("")
	progressDialog.update2(Main.loc.Localize("Extracting audio..."))
	wait for (FFMpeg.Video2RawWav(videoDir,videoName,wavPath)) complete (done As Object)
	progressDialog.update2(Main.loc.Localize("Merging..."))
	wait for (FFMpeg.GenerateVideoFromImagesAndAudio(imgDir,"audio.wav",frameRate,outputPath)) complete (done As Object)
	progressDialog.close
End Sub

Private Sub ChooseOutputPathButton_MouseClicked (EventData As MouseEvent)
	Dim fc As FileChooser
	fc.Initialize
	fc.SetExtensionFilter("MP4",Array As String("*.mp4"))
	Dim path As String = fc.ShowSave(frm)
	If path <> "" Then
		OutputPathTextField.Text = path
	End If
End Sub

Private Sub ChooseFolderButton_MouseClicked (EventData As MouseEvent)
	Dim dc As DirectoryChooser
	dc.Initialize
	Dim path As String = dc.Show(frm)
	If path <> "" Then
		FolderPathTextField.Text = path
	End If
End Sub
