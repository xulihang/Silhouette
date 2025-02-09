B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private mProject As Project
	Private DeviceComboBox As ComboBox
	Private TextArea1 As TextArea
	Private Devices As List
	Private CaptureMethod1 As CaptureMethod
	Private AudioFormat As JavaObject
	Private TDL As TargetDataLineWrapper
	Private path As String
	Private ToggleButton As Button
	Private ForTargetCheckBox As CheckBox
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(p As Project)
	frm.Initialize("frm",500,250)
	frm.RootPane.LoadLayout("VoiceInput")
	mProject = p
	LoadDevices
	Dim SampleRateHz As Float = 16000
	Dim SampleSizeInBits As Int = 16
	Dim ChannelConfig As Int = 1
	AudioFormat = jAudioRecord2_Utils.NewAudioFormat(SampleRateHz,SampleSizeInBits,ChannelConfig,True, False)
End Sub

private Sub LoadDevices
	Dim MixerInfos As List = jAudioRecord2_Utils.GetDevices(jAudioRecord2_Utils.DEVICETYPE_INPUT,"")
	Dim names As List
	names.Initialize
	Devices.Initialize
	For Each MI As JavaObject In MixerInfos
		names.add(MI.RunMethod("getName",Null))
		Devices.Add(MI)
	Next
	DeviceComboBox.Items.AddAll(names)
	If DeviceComboBox.Items.Size>0 Then
		DeviceComboBox.SelectedIndex = 0
	End If
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub ToggleButton_MouseClicked (EventData As MouseEvent)
	If ToggleButton.Tag = True Then
		If CaptureMethod1.IsInitialized And CaptureMethod1.IsRecording Then CaptureMethod1.Stop
		If TDL.IsReady Then
			If TDL.IsRunning Then
				TDL.Stop
				'Give Recordfile time to stop and finish writing the file
				Sleep(500)
			End If
			TDL.Close
		End If
		ToggleButton.Text = Main.loc.Localize("Start")
		ToggleButton.Tag = False
	Else
		Dim MI As JavaObject = Devices.Get(DeviceComboBox.SelectedIndex)
		Dim InDevice As JavaObject = jAudioRecord2_Utils.GetTargetDataLine2(AudioFormat, MI)
		
		TDL.Initialize(InDevice)
		CaptureMethod1.Initialize(CaptureMethod_Static.CAPTUREMETHOD_FILE,Me,"CaptureMethod",False)
		path = File.Combine(File.DirTemp, DateTime.Now&"-recorded.wav")
		CaptureMethod1.Start(TDL, path)
		ToggleButton.Text = Main.loc.Localize("Stop")
		ToggleButton.Tag = True
	End If
End Sub

Private Sub CaptureMethod_Complete
	Log("Recording Finished")
	progressDialog.Show("")
	progressDialog.update2(Main.loc.Localize("Recognizing..."))
	Dim lang As String
	If ForTargetCheckBox.Checked Then
		lang = mProject.TargetLang
	Else
		lang = mProject.SourceLang
	End If
	wait for (ASR.RecognizeWavAsText(path,lang,mProject.settings.GetDefault("engine","whisper"))) complete (result As String)
	TextArea1.Text = result
	progressDialog.close
End Sub

Private Sub FillTextButton_MouseClicked (EventData As MouseEvent)
	Main.FillText(TextArea1.Text,ForTargetCheckBox.Checked)
End Sub

