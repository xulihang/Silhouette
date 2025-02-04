B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private ListView1 As ListView
	Private ProgressLabel As Label
	Private mProject As Project
	Private mSettings As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(p As Project)
	mProject = p
	If mProject.IsInitialized Then
		Dim jsonG As JSONGenerator
		jsonG.Initialize(p.settings)
		Dim jsonP As JSONParser
		jsonP.Initialize(jsonG.ToString)
		mSettings = jsonP.NextObject
	Else
		mSettings.Initialize
	End If
	
	frm.Initialize("frm",600,600)
	frm.RootPane.LoadLayout("BatchTranslator")
	Main.loc.LocalizeForm(frm)
End Sub

Private Sub SelectFilesButton_MouseClicked (EventData As MouseEvent)
	Dim fc As FileChooser
	fc.Initialize
	Dim files As List = fc.ShowOpenMultiple(frm)
	ListView1.Items.AddAll(files)
End Sub

Private Sub ProcessButton_MouseClicked (EventData As MouseEvent)
	Dim langSelector As LanguagePairSelector
	langSelector.Initialize
	Dim langpairMap As Map = langSelector.ShowAndWait
	mSettings.Put("sourceLang",langpairMap.Get("source"))
	mSettings.Put("targetLang",langpairMap.Get("target"))
	Dim dialog As preTranslateDialog
	dialog.Initialize
	Dim mtOptions As Map = dialog.ShowAndWait
	Dim optionsForm As ASROptions
	optionsForm.Initialize
	Dim options As Map = optionsForm.ShowAndWait
	Dim method As Int = options.GetDefault("split_method",-1)
	If method = -1 Then
		Return
	End If
	Dim index As Int = 0
	For Each filepath As String In ListView1.Items
		ListView1.SelectedIndex = index
		Wait For (Main.TranslateOneFile(mSettings,filepath,mtOptions,method)) complete (done As Object)
		ProgressLabel.Text = index & "/" & ListView1.Items.Size
		index = index + 1
	Next
	ProgressLabel.Text = Main.loc.Localize("Done")
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub ClearButton_MouseClicked (EventData As MouseEvent)
	ListView1.Items.Clear
End Sub

Private Sub ExportSRTButton_MouseClicked (EventData As MouseEvent)
	Dim dc As DirectoryChooser
	dc.Initialize
	Dim path As String = dc.Show(frm)
	If File.Exists(path,"") Then
		Dim optionsForm As ExportOptions
		optionsForm.Initialize
		Dim option As Int = optionsForm.ShowAndWait
		For Each filepath As String In ListView1.Items
			Dim filename As String = File.GetName(filepath)
			Dim srtname As String = Utils.GetFilenameWithoutExtension(filename) & ".srt"
			Dim p As Project
			p.Initialize(filepath,Me,"")
			Exporter.ExportToSRT(p.lines,File.Combine(path,srtname),False,option)
		Next
		fx.Msgbox(frm,Main.loc.Localize("Done"),"")
	End If
End Sub
