B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.51
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private TabPane1 As TabPane
	Private APITableView As TableView
	Private MTListview As ListView
	Private preferencesMap As Map
	Private apiPreferences As Map
	Private mtPreferences As Map
	Private WhisperModelPathTextField As TextField
	Private LanguageComboBox As ComboBox
	Private EnableMultipleSentenceMTCheckBox As CheckBox
	Private MaxLengthForMTSpinner As Spinner
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mb As MenuBar)
	frm.Initialize("frm",650,700)
	frm.RootPane.LoadLayout("projectSetting")
	frm.Title = Main.loc.Localize("Preferences")
	TabPane1.LoadLayout("generalPreference", Main.loc.Localize("General"))
	TabPane1.LoadLayout("APISetting", "API")
	TabPane1.LoadLayout("MTSetting", Main.loc.Localize("Machine Translation"))
	TabPane1.LoadLayout("modelPreference", Main.loc.Localize("Speech Recognition"))
	APITableView.SetColumns(Array(Main.loc.Localize("API Name"),Main.loc.Localize("value")))
	preferencesMap.Initialize
	apiPreferences.Initialize
	mtPreferences.Initialize
	If File.Exists(Main.prefPath,"") Then
		Dim json As JSONParser
		json.Initialize(File.ReadString(Main.prefPath,""))
		preferencesMap=json.NextObject
		If preferencesMap.ContainsKey("api") Then
			apiPreferences=preferencesMap.Get("api")
		End If
		If preferencesMap.ContainsKey("mt") Then
			mtPreferences=preferencesMap.Get("mt")
		End If
		WhisperModelPathTextField.Text = preferencesMap.GetDefault("whisper_model_path","")
    End If
	EnableMultipleSentenceMTCheckBox.Checked = preferencesMap.GetDefault("multiple_sentence_mt",True)
	MaxLengthForMTSpinner.Value = preferencesMap.GetDefault("multiple_sentence_mt_char_length",2000)
	loadAPI
	loadMT
	LoadLanaugesList
	LoadSelectedLang
	Main.loc.LocalizeForm(frm)
End Sub

Private Sub LoadLanaugesList
	LanguageComboBox.Items.Clear
	If File.Exists(File.DirApp,"supportedLangs.txt") Then
		LanguageComboBox.Items.AddAll(File.ReadList(File.DirApp,"supportedLangs.txt"))
	Else
		LanguageComboBox.Items.Add("zh (中文)")
		LanguageComboBox.Items.Add("en (English)")
		For Each lang As String In Main.loc.GetLangs
			If lang.StartsWith("zh") == False And lang.StartsWith("en") == False Then
				LanguageComboBox.Items.Add(lang)
			End If
		Next
	End If
End Sub

Private Sub LoadSelectedLang
	If preferencesMap.ContainsKey("lang") Then
		For i = 0 To LanguageComboBox.Items.Size-2
			Dim languageItem As String = LanguageComboBox.Items.Get(i)
			If languageItem.Contains(" ") Then
				languageItem = languageItem.SubString2(0,languageItem.IndexOf(" "))
			End If
			If languageItem=preferencesMap.Get("lang") Then
				LanguageComboBox.SelectedIndex=i
				Exit
			End If
		Next
	End If
End Sub

Public Sub Show
	frm.Show
End Sub

Public Sub SwitchTab(index As Int)
	TabPane1.SelectedIndex = index
End Sub

Sub loadAPI
	APITableView.Items.Clear
	
	Dim items As List
	items.Initialize
	items.AddAll(Array("tencent","microsoft","baidu","youdao","mymemory"))
	items.AddAll(MT.getMTPluginList)
	
	Dim set As B4XSet
	set.Initialize
	For Each item As String In items
		set.Add(item)
	Next
	For Each item As String In set.AsList
		Dim value As String
		If apiPreferences.ContainsKey(item) Then
			value=apiPreferences.Get(item)
		End If
		Dim Row() As Object = Array (item,value)
		APITableView.Items.Add(Row)
	Next
End Sub

Sub loadMT
	MTListview.Items.Clear
	Dim items As List
	items.Initialize
	items.AddAll(MT.getMTList)
	For Each item As String In items
		Dim chk As CheckBox
		chk.Initialize("Chk")
		chk.Text=item
		chk.Checked = mtPreferences.GetDefault(item&"_enabled",False)
		MTListview.Items.Add(chk)
	Next
End Sub

Sub Chk_CheckedChange(Checked As Boolean)
	Dim chk As CheckBox=Sender
	mtPreferences.Put(chk.Text&"_enabled",Checked)
	Log(mtPreferences)
End Sub

Sub APITableView_MouseClicked (EventData As MouseEvent)
	If APITableView.SelectedRowValues<>Null Then
		Dim engineName As String
		engineName=APITableView.SelectedRowValues(0)
		Dim filler As APIParamsFiller
		filler.Initialize(engineName,preferencesMap)
		Dim result As Map = filler.showAndWait
		apiPreferences.Put(engineName,result)
		loadAPI
	End If
End Sub

Sub CancelButton_MouseClicked (EventData As MouseEvent)
	frm.Close
End Sub

Sub ApplyButton_MouseClicked (EventData As MouseEvent)
	preferencesMap.Put("mt",mtPreferences)
	preferencesMap.Put("api",apiPreferences)
	preferencesMap.Put("whisper_model_path",WhisperModelPathTextField.Text)
	preferencesMap.Put("multiple_sentence_mt_char_length",MaxLengthForMTSpinner.Value)
	preferencesMap.Put("multiple_sentence_mt",EnableMultipleSentenceMTCheckBox.Checked)
	Dim lang As String
	If LanguageComboBox.SelectedIndex<>-1 Then
		lang=LanguageComboBox.Items.Get(LanguageComboBox.SelectedIndex)
		If lang.Contains(" ") Then
			lang=lang.SubString2(0,lang.IndexOf(" "))
		End If
		If lang<>preferencesMap.GetDefault("lang","") Then
			preferencesMap.Put("lang",lang)
			If Main.loc.Language=Main.loc.sourceLang Then
				Main.loc.ForceLocale(lang)
				Main.LocalizeMainFrom
			Else
				fx.Msgbox(frm,Main.loc.Localize("Please restart the program."),"")
			End If
		End If
	End If
	
	Utils.resetPref
	Dim json As JSONGenerator
	json.Initialize(preferencesMap)
	File.WriteString(Main.prefPath,"",json.ToPrettyString(4))
	frm.Close
End Sub

Private Sub ChooseWhisperModelButton_MouseClicked (EventData As MouseEvent)
	Dim fc As FileChooser
	fc.Initialize
	Dim path As String = fc.ShowOpen(frm)
	WhisperModelPathTextField.Text = path
End Sub

Private Sub DownloadModelButton_MouseClicked (EventData As MouseEvent)
	fx.ShowExternalDocument("https://github.com/xulihang/Silhouette_plugins/blob/main/README.md#whisper-models")
End Sub
