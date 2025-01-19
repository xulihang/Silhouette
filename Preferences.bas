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
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mb As MenuBar)
	frm.Initialize("frm",650,700)
	frm.RootPane.LoadLayout("projectSetting")
	frm.Title = "Preferences"
	TabPane1.LoadLayout("APISetting", "API")
	TabPane1.LoadLayout("MTSetting", "Machine Translation")
	APITableView.SetColumns(Array("API Name","value"))
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
    End If
	loadAPI
	loadMT
End Sub

Public Sub Show
	frm.Show
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
	Utils.resetPref
	Dim json As JSONGenerator
	json.Initialize(preferencesMap)
	File.WriteString(Main.prefPath,"",json.ToPrettyString(4))
	frm.Close
End Sub
