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
	mProject.save
	frm.Close
End Sub