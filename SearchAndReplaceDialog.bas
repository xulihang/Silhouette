B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private findTextField As TextField
	Private replaceTextField As TextField
	Private resultListView As ListView
	Private regexCheckBox As CheckBox
	Private searchSourceCheckBox As CheckBox
	Private lines As List
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(pLines As List)
	lines=pLines
	frm.Initialize("frm",600,300)
	frm.RootPane.LoadLayout("searchandreplace")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub show
	frm.Show
End Sub

Sub resultListView_SelectedIndexChanged(Index As Int)
	
End Sub

Sub findButton_Click
	resultListView.Items.Clear
	If regexCheckBox.Checked Then
		showRegexResult
	Else
		showResult
	End If
End Sub

Sub showRegexResult
	Try
		Regex.Matcher(findTextField.Text,"").Find
		Regex.Replace(findTextField.Text,"",replaceTextField.Text)
	Catch
		fx.Msgbox(frm,Main.loc.Localize("Expression not correct"),"")
		Return
		Log(LastException)
	End Try
	Try
		Dim index As Int=-1
		For Each line As Map In lines
			index=index+1
			Dim tf As TextFlow
			tf.Initialize
			Dim source,target,pattern,sourceLeft,targetLeft As String
	        source=line.Get("source")
	        target=line.GetDefault("target","")
			sourceLeft=source
			targetLeft=target
			pattern=findTextField.Text
			'Log(pattern)

			Dim sourceMatcher,targetMatcher As Matcher
			sourceMatcher=Regex.Matcher2(pattern,32,source)
			targetMatcher=Regex.Matcher2(pattern,32,target)
			Dim inSource,inTarget As Boolean
			inSource=Regex.Matcher2(pattern,32,source).Find
			inTarget=Regex.Matcher2(pattern,32,target).Find
		
			Dim shouldShow As Boolean=False
		
			If searchSourceCheckBox.Checked Then
				If inSource Then
					shouldShow=True
				End If
			Else
				If inTarget Then
					shouldShow=True
				End If
			End If
		    Dim textSegmentsToReplace As List
			tf.AddText(Main.loc.Localize("- Source: "))
			If shouldShow Then
				If searchSourceCheckBox.Checked Then
					If inSource Then
						Dim sourceSegments As List
						sourceSegments.Initialize
						Do While sourceMatcher.Find
							'Log("Found: " & sourceMatcher.Match)
							Dim textBefore As String
							textBefore=sourceLeft.SubString2(0,sourceLeft.IndexOf(sourceMatcher.Match))
							If textBefore<>"" Then
								tf.AddText(textBefore)
								sourceSegments.Add(textBefore)
							End If
							tf.AddText(sourceMatcher.Match).SetColor(fx.Colors.Blue).SetUnderline(True)
							sourceSegments.Add(sourceMatcher.Match)
							sourceLeft=sourceLeft.SubString2(sourceLeft.IndexOf(sourceMatcher.Match)+sourceMatcher.Match.Length,sourceLeft.Length)
						Loop
						tf.AddText(sourceLeft)
						sourceSegments.Add(sourceLeft)
						textSegmentsToReplace=sourceSegments
					Else
						tf.AddText(source)
					End If
				Else
					tf.AddText(source)
				End If
				tf.AddText(CRLF&Main.loc.Localize("- Target: "))

				If inTarget And searchSourceCheckBox.Checked=False Then
					Dim targetSegments As List
					targetSegments.Initialize
					Do While targetMatcher.Find
						Dim find As String
						find=targetMatcher.Match
						Dim textBefore As String
						textBefore=targetLeft.SubString2(0,targetLeft.IndexOf(find))
						If textBefore<>"" Then
							tf.AddText(textBefore)
							targetSegments.Add(textBefore)
						End If
						tf.AddText(find).SetColor(fx.Colors.Blue).SetUnderline(True)
						targetSegments.Add(find)
						targetLeft=targetLeft.SubString2(targetLeft.IndexOf(find)+find.Length,targetLeft.Length)
					Loop
					tf.AddText(targetLeft)
					targetSegments.Add(targetLeft)
					textSegmentsToReplace=targetSegments
				Else
					tf.AddText(target)
				End If
				
				tf.AddText(CRLF&Main.loc.Localize("- Replace: "))

				For Each text As String In textSegmentsToReplace
                    If text = "" Then
						Continue
                    End If 
					If Regex.IsMatch2(pattern,32,text) Then
						Dim replace As String
						replace=Regex.Replace2(pattern,32,text,replaceTextField.Text)
						'Log("replace"&replace)
						If replaceTextField.Text="" Then
							replace=""
						End If
						'If replace="" And text=CRLF Then
						'	Continue
						'End If
							
						If replace="" Then
							tf.AddTextWithStrikethrough(text,"").SetColor(fx.Colors.Red)
						Else
							tf.AddText(replace).SetColor(fx.Colors.Green).SetUnderline(True)
						End If
					Else
						tf.AddText(text)
					End If
				Next
				
				Dim tagList As List
				tagList.Initialize
				tagList.Add(index)
				tagList.Add(tf.getText)
				tagList.Add(searchSourceCheckBox.Checked)
				tagList.Add(tf.getTextInDisplay)
				Dim pane As Pane = tf.CreateTextFlow
				pane.Tag=tagList
				pane.SetSize(resultListView.Width,Utils.MeasureMultilineTextHeight(fx.DefaultFont(15),resultListView.Width,tagList.Get(3)))
				resultListView.Items.Add(pane)	
			End If
		Next
	Catch
		Log(LastException)
		fx.Msgbox(frm,Main.loc.Localize("Expression not correct"),"")
		Return
	End Try
End Sub


Sub showResult
	
	Dim index As Int=-1
	For Each line As Map In lines
		index=index+1
		Dim source,target,find As String
		source=line.Get("source")
		target=line.GetDefault("target","")
		find=findTextField.Text

		Dim tf As TextFlow
		tf.Initialize
	
		Dim shouldShow As Boolean=False
		If searchSourceCheckBox.Checked Then
			If source.Contains(find) Then
				shouldShow=True
			End If
		Else
			If target.Contains(find) Then
				shouldShow=True
			End If
		End If

		If shouldShow Then
			tf.AddText(Main.loc.Localize("- Source: "))
			
			Dim textSegmentsToReplace As List
			If searchSourceCheckBox.Checked Then
				Dim sourceSegments As List
				sourceSegments.Initialize
				Utils.splitByFind(source,find,sourceSegments)
				If source.Contains(find) Then
					addText(tf,find,sourceSegments)
				Else
					tf.AddText(source)
				End If
				textSegmentsToReplace=sourceSegments
			Else
				tf.AddText(source)

			End If
        
			tf.AddText(CRLF&Main.loc.Localize("- Target: "))
			If target.Contains(find) And searchSourceCheckBox.Checked=False Then
				Dim targetSegments As List
				targetSegments.Initialize
				Utils.splitByFind(target,find,targetSegments)
				addText(tf,find,targetSegments)
				textSegmentsToReplace=targetSegments
			Else
				tf.AddText(target)
			End If
            
			tf.AddText(CRLF&Main.loc.Localize("- Replace: "))
			For Each text As String In textSegmentsToReplace
				If text=find Then
					If replaceTextField.Text="" Then
						tf.AddTextWithStrikethrough(find,"").SetColor(fx.Colors.Red)
					Else
						tf.AddText(replaceTextField.Text).SetColor(fx.Colors.Green).SetUnderline(True)
					End If
				Else
					tf.AddText(text)
				End If
			Next

			Dim tagList As List
			tagList.Initialize
			tagList.Add(index)
			tagList.Add(tf.getText)
			tagList.Add(searchSourceCheckBox.Checked)
			tagList.Add(tf.getTextInDisplay)
			Dim pane As Pane = tf.CreateTextFlow
			pane.Tag=tagList
			pane.SetSize(resultListView.Width,Utils.MeasureMultilineTextHeight(fx.DefaultFont(15),resultListView.Width,tagList.Get(3)))
			resultListView.Items.Add(pane)
		End If
	Next
End Sub

Sub addText(tf As TextFlow,find As String,textSegments As List)
	For Each segment As String In textSegments
		If segment=find Then
			tf.AddText(find).SetColor(fx.Colors.Blue).SetUnderline(True)
		Else
			tf.AddText(segment)
		End If
	Next
End Sub

Sub resultListView_Resize (Width As Double, Height As Double)
	For Each p As Pane In resultListView.Items
		Dim tagList As List
		tagList=p.Tag
		p.SetSize(Width,Utils.MeasureMultilineTextHeight(fx.DefaultFont(15),Width,tagList.Get(3)))
	Next
End Sub

Sub replaceSelectedButton_MouseClicked (EventData As MouseEvent)
	If resultListView.SelectedItem<>Null Then
		Dim indices As List = resultListView.GetSelectedIndices
		For i = indices.Size - 1 To 0 Step -1
			Dim itemIndex As Int = indices.Get(i)
			Dim p As Pane
			p=resultListView.Items.Get(itemIndex)
			Dim tagList As List
			tagList=p.Tag
			Dim HandleSource As Boolean
			HandleSource=tagList.Get(2)
			Dim text,after As String
			Dim key As String
			If HandleSource Then
				text=Regex.Split(CRLF&"- ",tagList.Get(1))(0)
				text=text.SubString2(Main.loc.Localize("- Source: ").Length,text.Length)
				key="source"
			Else
				text=Regex.Split(CRLF&"- ",tagList.Get(1))(1)
				text=text.SubString2(Main.loc.Localize("Target: ").Length,text.Length)
				key="target"
			End If
		
			after=Regex.Split(CRLF&"- ",tagList.Get(1))(2)
			Dim localized As String=Main.loc.Localize("- Replace: ")
			localized=localized.SubString2(2,localized.Length)
			after=after.SubString2(localized.Length,after.Length)

			Dim index As Int=tagList.Get(0)
			Dim line As Map = lines.Get(index)
			If line.GetDefault(key,"")=text Then
				line.Put(key,after)
			End If
			resultListView.Items.RemoveAt(itemIndex)
		Next
		Main.LoadLinesToTable
	End If
End Sub

Sub replaceAllButton_MouseClicked (EventData As MouseEvent)
	If resultListView.Items.Size>0 Then
		Dim count As Int=0
		Dim tempList As List
		tempList.Initialize
		tempList.AddAll(resultListView.Items)
		For Each p As Pane In tempList
			Dim tagList As List
			tagList=p.Tag
			Dim HandleSource As Boolean
			HandleSource=tagList.Get(2)
			Dim text,after As String
			Dim key As String
			If HandleSource Then
				text=Regex.Split(CRLF&"- ",tagList.Get(1))(0)
				text=text.SubString2(Main.loc.Localize("- Source: ").Length,text.Length)
				key="source"
			Else
				text=Regex.Split(CRLF&"- ",tagList.Get(1))(1)
				text=text.SubString2(Main.loc.Localize("Target: ").Length,text.Length)
				key="target"
			End If
			after=Regex.Split(CRLF&"- ",tagList.Get(1))(2)
			Dim localized As String=Main.loc.Localize("- Replace: ")
			localized=localized.SubString2(2,localized.Length)
			after=after.SubString2(localized.Length,after.Length)
			Dim index As Int=tagList.Get(0)
			Dim line As Map = lines.Get(index)
			If line.GetDefault(key,"")=text Then
				line.Put(key,after)
			End If
			resultListView.Items.RemoveAt(resultListView.Items.IndexOf(p))
			count=count+1
		Next
		fx.Msgbox(frm,Main.loc.LocalizeParams("{1} item(s) replaced",Array As String(count)),"")
		Main.LoadLinesToTable
	End If
End Sub

Sub resultListView_Action
	Dim p As Pane
	p=resultListView.Items.Get(resultListView.SelectedIndex)
	Dim taglist As List
	taglist=p.Tag
	Dim index As Int = taglist.Get(0)
	Main.JumpToRow(index+1,200)
End Sub

Sub replaceTextField_TextChanged (Old As String, New As String)
	resultListView.Items.Clear
End Sub

Sub findTextField_TextChanged (Old As String, New As String)
	resultListView.Items.Clear
End Sub

Private Sub resultListView_MouseClicked (EventData As MouseEvent)
	If EventData.ClickCount == 2 Then
		If resultListView.SelectedIndex <> -1 Then
			resultListView_Action
		End If
	End If
End Sub
