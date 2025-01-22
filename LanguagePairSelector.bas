B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private result As Map
	Private sourceComboBox As ComboBox
	Private sourceTextField As TextField
	Private targetComboBox As ComboBox
	Private targetTextField As TextField
	Private langcodes As Map
	Private LanguageNames As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",500,300)
	frm.RootPane.LoadLayout("LangaugePairSelector")
	result.Initialize
	LanguageNames.Initialize
	If File.Exists(File.DirApp,"langcodes.txt")=False Then
		File.Copy(File.DirAssets,"langcodes.txt",File.DirApp,"langcodes.txt")
	End If
	langcodes=Utils.readLanguageCode(File.Combine(File.DirApp,"langcodes.txt"))
	fillComboBox
	ReadLastLangs
End Sub

Sub fillComboBox
	For Each key As String In langcodes.Keys
		Dim codesMap As Map
		codesMap=langcodes.Get(key)
		Dim langName As String=codesMap.Get("language name")
		LanguageNames.Put(langName,key)
		sourceComboBox.Items.Add(langName)
		targetComboBox.Items.Add(langName)
	Next
End Sub


Public Sub ShowAndWait As Map
	frm.ShowAndWait
	Return result
End Sub

Sub close
	frm.Close
End Sub

Sub targetComboBox_SelectedIndexChanged(Index As Int, Value As Object)
	targetTextField.Text=LanguageNames.Get(Value)
End Sub

Sub sourceComboBox_SelectedIndexChanged(Index As Int, Value As Object)
	sourceTextField.Text=LanguageNames.Get(Value)
End Sub

Sub OkButton_MouseClicked (EventData As MouseEvent)
	If sourceTextField.Text="" Or targetTextField.Text="" Then
		fx.Msgbox(frm,"Please set the language pair","")
		Return
	End If
	result.put("source",sourceTextField.Text)
	result.put("target",targetTextField.Text)
	File.WriteMap(File.DirData("ImageTrans"),"lastLangs",result)
	close
End Sub

Sub ReadLastLangs
	If File.Exists(File.DirData("ImageTrans"),"lastLangs") Then
		Dim map1 As Map
		map1=File.ReadMap(File.DirData("ImageTrans"),"lastLangs")
		If map1.ContainsKey("source") Then
			sourceTextField.Text=map1.Get("source")
		End If
		If map1.ContainsKey("target") Then
			targetTextField.Text=map1.Get("target")
		End If
	End If
End Sub
