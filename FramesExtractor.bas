B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private FileTextField As TextField
	Private FPSSpinner As Spinner
	Private OutputTextField As TextField
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("FramesExtractor")
	Main.loc.LocalizeForm(frm)
End Sub

public Sub Show(presetFilePath As String)
	FileTextField.Text = presetFilePath
	OutputTextField.Text = File.GetFileParent(presetFilePath)
	frm.Show
End Sub

Private Sub ExtractButton_MouseClicked (EventData As MouseEvent)
	If OutputTextField.Text = "" Or FileTextField.Text = "" Then
		Return
	End If
	progressDialog.Show("")
	progressDialog.update2(Main.loc.Localize("Extracting..."))
	wait for (FFMpeg.ExtractFrames(File.GetFileParent(FileTextField.Text),File.GetName(FileTextField.Text),FPSSpinner.Value,OutputTextField.Text)) complete (done As Object)
	WriteVideoInfo
	progressDialog.close
End Sub

Private Sub WriteVideoInfo
	Dim info As Map
	info.Initialize
	info.Put("fps",FPSSpinner.Value)
	File.WriteMap(OutputTextField.Text,"info.map",info)
End Sub

Private Sub ChooseFolderButton_MouseClicked (EventData As MouseEvent)
	Dim dc As DirectoryChooser
	dc.Initialize
	Dim path As String = dc.Show(frm)
	If path <> "" Then
		OutputTextField.Text = path
	End If
End Sub

Private Sub ChooseFileButton_MouseClicked (EventData As MouseEvent)
	Dim fc As FileChooser
	fc.Initialize
	Dim path As String = fc.ShowOpen(frm)
	If path <> "" Then
		FileTextField.Text = path
	End If
End Sub
