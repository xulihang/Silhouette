B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private settings As Map
	Private mProject As Project
	Private TabPane1 As TabPane
	Private LangPairLabel As Label
	Private EngineComboBox As ComboBox
	Private PromptTextField As TextField
	Private ExtraParamsTextField As TextField
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(p As Project)
	frm.Initialize("frm",600,700)
	frm.RootPane.LoadLayout("projectSetting")
	settings=p.settings
	mProject=p
	TabPane1.LoadLayout("generalSettings", Main.loc.Localize("General"))
	Dim langmap As Map
	langmap.Initialize
	Dim sourceLang As String
	Dim targetLang As String
	If settings.ContainsKey("sourceLang") And settings.ContainsKey("targetLang") Then
		sourceLang = settings.Get("sourceLang")
		targetLang = settings.Get("targetLang")
		LangPairLabel.Text=sourceLang&"_"&targetLang
	End If
	langmap.Put("source",sourceLang)
	langmap.Put("target",targetLang)
	LangPairLabel.Tag=langmap
	EngineComboBox.Items.Add("whisper")
	EngineComboBox.Items.AddAll(ASR.getASRPluginList)
	If settings.ContainsKey("engine") Then
		EngineComboBox.SelectedIndex = EngineComboBox.Items.IndexOf(settings.GetDefault("engine","whisper"))
	End If
	If EngineComboBox.SelectedIndex = -1 Then
		EngineComboBox.SelectedIndex = 0
	End If
	PromptTextField.Text = settings.GetDefault("prompt","")
	ExtraParamsTextField.Text = settings.GetDefault("extra_params","")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub Show
	frm.Show
End Sub

Private Sub SetLangPairButton_MouseClicked (EventData As MouseEvent)
	Dim langSelector As LanguagePairSelector
	langSelector.Initialize
	Dim langmap As Map = langSelector.ShowAndWait
	Dim sourceLang As String = langmap.Get("source")
	Dim targetLang As String = langmap.Get("target")
	LangPairLabel.Text=sourceLang&"_"&targetLang
	LangPairLabel.Tag=langmap
End Sub

Sub CancelButton_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub

Sub ApplyButton_MouseClicked (EventData As MouseEvent)
	Dim langmap As Map = LangPairLabel.Tag
	Dim sourceLang As String = langmap.Get("source")
	Dim targetLang As String = langmap.Get("target")
	settings.Put("sourceLang",sourceLang)
	settings.Put("targetLang",targetLang)
	settings.Put("engine",EngineComboBox.Items.Get(EngineComboBox.SelectedIndex))
	settings.Put("prompt",PromptTextField.Text)
	settings.Put("extra_params",ExtraParamsTextField.Text)
	mProject.save
	frm.Close
End Sub

Private Sub CheckParamsButton_MouseClicked (EventData As MouseEvent)
	wait for (ASR.GetParams(EngineComboBox.Items.Get(EngineComboBox.SelectedIndex))) complete (note As String)
	Dim inp As InputBox
	inp.Initialize
	inp.show(note)
End Sub