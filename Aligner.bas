B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private editorLV As ListView
	Private currentProject As AlignerProject
	Private cursorReachEnd As Boolean
	Type Range(firstIndex As Int,lastIndex As Int)
	Private SegmentsLabel As Label
	Private currentIndex As Int
	Private mEventName As String
	Private mCallBack As Object
	Private ProtectSourceCheckBox As CheckBox
	Private MenuBar1 As MenuBar
	Private path As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callback As Object,eventname As String)
	mCallBack = callback
	mEventName = eventname
	frm.Initialize("frm",600,600)
	frm.RootPane.LoadLayout("Aligner")
	Main.loc.LocalizeForm(frm)
	currentProject.Initialize(File.Combine(File.DirTemp,"1.alp"))
End Sub

Public Sub Show(sourceList As List,targetList As List,sourceLang As String,targetLang As String)
	frm.Show
	currentProject.setProjectFileValue("langPair",CreateMap("source":sourceLang,"target":targetLang))
	currentProject.loadItemsToSegments(CreateMap("source":sourceList,"target":targetList))
	loadSegmentsToListView
	addScrollChangedEvent
End Sub

Public Sub loadSegmentsToListView
	If currentProject.segments<>Null And currentProject.segments.Size<>0 Then
		editorLV.Items.Clear
		For i=0 To currentProject.segments.Size-1
			editorLV.Items.Add("")
		Next
		Dim currentVisibleRange As Range
		currentVisibleRange=getVisibleRange(editorLV)
		fillPane(currentVisibleRange.firstIndex,currentVisibleRange.lastIndex)
		CallSubDelayed(Me,"ListViewParent_Resize")
	End If
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
	frm.Close
	If SubExists(mCallBack,mEventName&"_Completed") Then
		CallSubDelayed2(mCallBack,mEventName&"_Completed", currentProject.segments)
	End If
End Sub


Public Sub createEmptyPane As Pane
	Dim segmentPane As Pane
	segmentPane.Initialize("segmentPane")
	segmentPane.SetSize(editorLV.Width,50dip)
	Return segmentPane
End Sub


Public Sub addTextAreaToSegmentPane(segmentpane As Pane,source As String,target As String)
	segmentpane.LoadLayout("segment")
	segmentpane.SetSize(editorLV.Width,50dip)
	Dim sourceTextArea As TextArea
	sourceTextArea=segmentpane.GetNode(0)
	sourceTextArea.Text=source
	
	addContextMenu(sourceTextArea,True)
	addKeyEvent(sourceTextArea,"sourceTextArea")
	addSelectionChangedEvent(sourceTextArea,"sourceTextAreaSelection")
	Dim targetTextArea As TextArea
	targetTextArea=segmentpane.GetNode(1)
	targetTextArea.Text=target
	
	addContextMenu(targetTextArea,False)
	addKeyEvent(targetTextArea,"targetTextArea")
	addSelectionChangedEvent(targetTextArea,"targetTextAreaSelection")
	sourceTextArea.Left=0
	sourceTextArea.SetSize(editorLV.Width/2-20dip,50dip)
	targetTextArea.Left=sourceTextArea.Left+sourceTextArea.Width
	targetTextArea.SetSize(editorLV.Width/2-20dip,50dip)
End Sub


Sub addSelectionChangedEvent(textarea1 As TextArea,eventName As String)
	Dim Obj As Reflector
	Obj.Target = textarea1
	Obj.AddChangeListener(eventName, "selectionProperty")
End Sub

Sub addKeyEvent(textarea1 As TextArea,eventName As String)
	Dim CJO As JavaObject = textarea1
	Dim O As Object = CJO.CreateEventFromUI("javafx.event.EventHandler",eventName&"_KeyPressed",Null)
	CJO.RunMethod("setOnKeyPressed",Array(O))
	CJO.RunMethod("setFocusTraversable",Array(True))
End Sub


Sub sourceTextArea_KeyPressed_Event (MethodName As String, Args() As Object) As Object
	Dim sourceTextArea As TextArea
	sourceTextArea=Sender

	Dim KEvt As JavaObject = Args(0)
	Dim result As String
	result=KEvt.RunMethod("getCode",Null)
	Log(result)
	If result="ENTER" Then
		splitSegment(sourceTextArea,True)
	Else if result="DELETE" Then
		mergeSegment(sourceTextArea,True)
	Else if result="DOWN" Then
		If 	cursorReachEnd=False Then
			cursorReachEnd=True
		Else
			changeSegment(1,sourceTextArea,0)
		End If
	Else if result="UP" Then
		If 	cursorReachEnd=False Then
			cursorReachEnd=True
		Else
			changeSegment(-1,sourceTextArea,0)
		End If
	else if result="TAB" Then
		changeTextArea(sourceTextArea,1)
	End If
End Sub

Sub targetTextArea_KeyPressed_Event (MethodName As String, Args() As Object) As Object
	Dim KEvt As JavaObject = Args(0)
	Dim result As String
	result=KEvt.RunMethod("getCode",Null)
	Log(result)
	Dim targetTextArea As TextArea
	targetTextArea=Sender
	If result="ENTER" Then
		splitSegment(targetTextArea,False)
	Else if result="DELETE" Then
		mergeSegment(targetTextArea,False)
	Else if result="DOWN" Then
		If 	cursorReachEnd=False Then
			cursorReachEnd=True
		Else
			changeSegment(1,targetTextArea,1)
		End If
	Else if result="UP" Then
		If 	cursorReachEnd=False Then
			cursorReachEnd=True
		Else
			changeSegment(-1,targetTextArea,1)
		End If
	else if result="TAB" Then
		changeTextArea(targetTextArea,0)
	End If
End Sub

Sub sourceTextAreaSelection_changed(old As Object, new As Object)
	cursorReachEnd=False
End Sub

Sub targetTextAreaSelection_changed(old As Object, new As Object)
	cursorReachEnd=False
End Sub

Sub changeTextArea(TextArea As TextArea,nodeIndex As Int)
	TextArea.Text=TextArea.Text.Replace("	","")
	Dim pane As Pane
	pane=TextArea.Parent
	Dim theOtherTA As TextArea
	theOtherTA=pane.GetNode(nodeIndex)
	theOtherTA.RequestFocus
End Sub

Sub frm_Resize (Width As Double, Height As Double)
	CallSubDelayed(Me,"ListViewParent_Resize")
End Sub


Sub changeSegment(offset As Int,TextArea As TextArea,nodeIndex As Int)
	Try
		TextArea.Text=TextArea.Text.Replace(CRLF,"")
		
		Dim pane As Pane
		pane=TextArea.Parent
		Dim index As Int
		index=editorLV.Items.IndexOf(pane)
		If index+offset>=editorLV.Items.Size Or index+offset<0 Then
			Return
		End If
		Dim nextPane As Pane
		nextPane=editorLV.Items.Get(index+offset)
		Dim nextTA As TextArea
		nextTA=nextPane.GetNode(nodeIndex)
		nextTA.RequestFocus
		updateSegmentsLabel(nextTA)
		Dim visibleRange As Range
		visibleRange=getVisibleRange(editorLV)
		If index+offset<visibleRange.firstIndex+1 Or index+offset>visibleRange.lastIndex-1 Then
			If offset<0 Then
				editorLV.ScrollTo(index+offset)
			Else
				editorLV.ScrollTo(index+offset-visibleRange.lastIndex+visibleRange.firstIndex+1)
			End If
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Public Sub fillPane(FirstIndex As Int, LastIndex As Int)
	Try
		Dim segments As List
		segments=currentProject.segments
	Catch
		Log(LastException)
		Return
	End Try
	Log("fillPane")
	Dim ExtraSize As Int
	ExtraSize=15
	For i = Max(0,FirstIndex-ExtraSize*2) To Min(editorLV.Items.Size - 1,LastIndex+ExtraSize*2)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			'visible+
			If editorLV.Items.Get(i)="" Then

				Dim segmentPane As Pane
				segmentPane=createEmptyPane
				Dim bitext As Map
				bitext=segments.Get(i)
				addTextAreaToSegmentPane(segmentPane,bitext.Get("source"),bitext.Get("target"))
				If bitext.GetDefault("complete",True)=False Then
					For Each ta As TextArea In segmentPane.GetAllViewsRecursive
						CSSUtils.SetBackgroundColor(ta,fx.Colors.Red)
					Next
				else if bitext.GetDefault("accurate",True)=False Then
					For Each ta As TextArea In segmentPane.GetAllViewsRecursive
						CSSUtils.SetBackgroundColor(ta,fx.Colors.Yellow)
					Next
				End If
				editorLV.Items.Set(i,segmentPane)
			End If
		Else
			'not visible
			editorLV.Items.Set(i,"")
		End If
	Next
End Sub



'------------------------



Sub checkVisibleRange
	Try
		Sleep(50)
		Dim currentVisibleRange As Range
		currentVisibleRange=getVisibleRange(editorLV)
		fillPane(currentVisibleRange.firstIndex,currentVisibleRange.lastIndex)
		CallSubDelayed(Me,"ListViewParent_Resize")
	Catch
		Log(LastException)
	End Try
End Sub

Sub addScrollChangedEvent
	Dim jo As JavaObject
	jo=editorLV
	Dim ListViewScrollBar As JavaObject
	ListViewScrollBar=jo.RunMethodJO("lookup",Array(".scroll-bar:vertical"))
	Log(ListViewScrollBar)
	Dim r As Reflector
	r.Target=ListViewScrollBar
	r.AddChangeListener("scrollPosition","valueProperty")
End Sub

Sub scrollPosition_changed(old As Object,new As Object)
	Log("ListView1_ScrollPosition_Changed")
	CallSubDelayed(Me,"checkVisibleRange")
End Sub

Sub getVisibleRange(lv As ListView) As Range
	Dim visibleRange As Range
	visibleRange.Initialize
	Try
		Dim jo As JavaObject
		jo=lv
		Dim VirtualFlow As JavaObject
		VirtualFlow=jo.RunMethodJO("getSkin",Null).RunMethodJO("getChildren",Null).RunMethodJO("get",Array(0))
		Dim lastVisibleCell As JavaObject
		lastVisibleCell=VirtualFlow.RunMethodJO("getLastVisibleCell",Null)
		Dim firstVisibleCell As JavaObject
		firstVisibleCell=VirtualFlow.RunMethodJO("getFirstVisibleCell",Null)
		visibleRange.firstIndex=firstVisibleCell.RunMethod("getIndex",Null)
		visibleRange.lastIndex=lastVisibleCell.RunMethod("getIndex",Null)
	Catch
		Log(LastException)
	End Try
	Return visibleRange
End Sub


Sub addContextMenu(ta As TextArea,isSource As Boolean)
	Dim cm As ContextMenu
	cm.Initialize("cm")
	Dim delMi As MenuItem
	delMi.Initialize(Main.loc.Localize("DELETE"),"delmi")
	Dim upMi As MenuItem
	upMi.Initialize(Main.loc.Localize("UP"),"upmi")
	Dim downMi As MenuItem
	downMi.Initialize(Main.loc.Localize("DOWN"),"downmi")
	Dim tagList As List
	tagList.Initialize
	tagList.Add(ta)
	tagList.Add(isSource)
	delMi.Tag=tagList
	upMi.Tag=tagList
	downMi.Tag=tagList
	cm.MenuItems.Add(upMi)
	cm.MenuItems.Add(downMi)
	cm.MenuItems.Add(delMi)
	ta.ContextMenu=cm
End Sub


Sub delmi_Action
	Dim mi As MenuItem
	mi=Sender
	Log(mi.Text)
	Dim tagList As List
	tagList=mi.Tag
	Dim ta As TextArea
	ta=tagList.Get(0)
	deleteCell(tagList.Get(1),ta)
End Sub

Sub deleteCell(isSource As Boolean,ta As TextArea)
	Dim p As Pane
	p=ta.Parent
	
	Dim taIndex As Int
	Dim key As String
	If isSource Then
		taIndex=0
		key="source"
	Else
		taIndex=1
		key="target"
	End If
	Dim theOtherIndex As Int
	theOtherIndex=getTheOtherIndex(taIndex)
	
	Dim index As Int
	index=editorLV.Items.IndexOf(p)
	Dim segment As Map=currentProject.segments.Get(index)
	Dim paraMode As Boolean=False
	Dim paraID As Int
	If segment.ContainsKey("id") Then
		paraMode=True
		paraID=segment.Get("id")
	End If
	Dim size As Int
	size=editorLV.Items.Size
	Dim lastIndex As Int=size-1
	For i=index To size-2
		Dim nextIndex As Int=i+1
		Dim bitext As Map
		bitext=currentProject.segments.Get(i)
		Dim nextbitext As Map
		nextbitext=currentProject.segments.Get(nextIndex)
		If paraMode Then
			If nextbitext.GetDefault("id",-1)<>paraID Then
				lastIndex=i
				Exit
			End If
		End If
		
		bitext.Put(key,nextbitext.Get(key))
		If editorLV.Items.Get(i)<>"" Then
			Dim p As Pane
			Dim ta As TextArea
			p=editorLV.Items.Get(i)
			ta=p.GetNode(taIndex)
			ta.Text=bitext.Get(key)
		End If
		If editorLV.Items.Get(nextIndex)<>"" Then
			Dim nextPane As Pane
			nextPane=editorLV.Items.Get(nextIndex)
			Dim nextTa As TextArea
			nextTa=nextPane.GetNode(taIndex)
			nextTa.Text=nextbitext.Get(key)
		End If
	Next
	
	'set the last segment empty


	Dim bitext As Map
	bitext=currentProject.segments.Get(lastIndex)
	bitext.put(key,"")
	If editorLV.Items.Get(lastIndex)<>"" Then
		Dim p As Pane
		p=editorLV.Items.Get(lastIndex)
		Dim ta As TextArea
		ta=p.GetNode(taIndex)
		ta.Text=""
	End If
	
	'remove empty segments
	Dim toRemoveIndexList As List
	toRemoveIndexList.Initialize
	Dim index As Int=0
	For Each bitext As Map In currentProject.segments
		If bitext.Get("source")="" And bitext.Get("target")="" Then
			toRemoveIndexList.Add(index)
		End If
		index=index+1
	Next
	toRemoveIndexList.Sort(False)
	For Each index As Int In toRemoveIndexList
		currentProject.segments.RemoveAt(index)
		editorLV.Items.RemoveAt(index)
	Next
End Sub


Sub upmi_Action
	Dim mi As MenuItem
	mi=Sender
	Log(mi.Text)
	Dim tagList As List
	tagList=mi.Tag
	Dim ta As TextArea
	ta=tagList.Get(0)
	moveCell(tagList.Get(1),ta,True)
End Sub

Sub downmi_Action
	Dim mi As MenuItem
	mi=Sender
	Log(mi.Text)
	Dim tagList As List
	tagList=mi.Tag
	Dim ta As TextArea
	ta=tagList.Get(0)
	moveCell(tagList.Get(1),ta,False)
End Sub


Sub moveCell(isSource As Boolean,ta As TextArea,isUP As Boolean)
	Dim p As Pane
	p=ta.Parent
	Dim index As Int=editorLV.Items.IndexOf(p)
	
	Dim taIndex As Int
	Dim key As String
	If isSource Then
		taIndex=0
		key="source"
	Else
		taIndex=1
		key="target"
	End If
	
	Dim theOtherIndex As Int
	If isUP Then
		theOtherIndex=index-1
	Else
		theOtherIndex=index+1
	End If
	If theOtherIndex<0 Or theOtherIndex>currentProject.segments.Size-1 Then
		Return
	End If

	Dim bitext,theOtherbitext As Map
	bitext=currentProject.segments.Get(index)
	theOtherbitext=currentProject.segments.Get(theOtherIndex)
	Dim temp As String=bitext.Get(key)
	bitext.Put(key,theOtherbitext.Get(key))
	theOtherbitext.Put(key,temp)


	ta.Text=bitext.Get(key)

	If editorLV.Items.Get(theOtherIndex)<>"" Then
		Dim theOtherPane As Pane
		theOtherPane=editorLV.Items.Get(theOtherIndex)
		Dim theOtherTa As TextArea
		theOtherTa=theOtherPane.GetNode(taIndex)
		theOtherTa.Text=theOtherbitext.Get(key)
	End If
	
End Sub


Sub ListViewParent_Resize

	Dim lv As ListView
	lv=editorLV
	Dim visibleRange As Range=getVisibleRange(lv)
	Dim FirstVisibleIndex,LastVisibleIndex As Int
	FirstVisibleIndex=visibleRange.firstIndex
	LastVisibleIndex=visibleRange.lastIndex
	If lv.Items.Size=0 Then
		Return
	End If
	Dim itemWidth As Double = lv.Width
	Dim ExtraSize As Int
	ExtraSize=5
	For i = Max(0, FirstVisibleIndex - ExtraSize) To Min(LastVisibleIndex + ExtraSize,editorLV.Items.Size - 1)
		Try
			Dim p As Pane
			p=lv.Items.Get(i)
		Catch
			'Log(LastException)
			Continue
		End Try
		Dim sourceTa As TextArea = p.GetNode(0)
		Dim targetTa As TextArea = p.GetNode(1)
		Dim sourcelbl,targetlbl As Label
		sourcelbl.Initialize("")
		targetlbl.Initialize("")
		sourcelbl.Font=fx.DefaultFont(16)
		targetlbl.Font=fx.DefaultFont(16)
		Dim sourceHeight,targetHeight As Int
		Dim sourceLineHeight As Int=Utils.MeasureMultilineTextHeight(sourcelbl.Font,itemWidth/2-20dip,CRLF)
		Dim targetLineHeight As Int=Utils.MeasureMultilineTextHeight(targetlbl.Font,itemWidth/2-20dip,CRLF)
		sourceHeight=Utils.MeasureMultilineTextHeight(sourcelbl.Font,itemWidth/2-20dip,sourceTa.Text)+sourceLineHeight
		targetHeight=Utils.MeasureMultilineTextHeight(targetlbl.Font,itemWidth/2-20dip,targetTa.Text)+targetLineHeight
		Dim h As Int = Max(Max(20, sourceHeight + 10), targetHeight + 10)
		setLayout(p,i,h)
	Next
End Sub


Public Sub setLayout(p As Pane,index As Int,h As Int)
	Dim itemwidth As Double
	itemwidth=editorLV.Width
	p.Left=0
	p.SetSize(itemwidth-40dip,h)
	Dim sourceTa As TextArea = p.GetNode(0)
	Dim targetTa As TextArea = p.GetNode(1)
	sourceTa.Left=0
	sourceTa.SetSize(itemwidth/2-20dip,h)
	targetTa.Left=itemwidth/2-20dip
	targetTa.SetSize(itemwidth/2-20dip,h)
End Sub

Sub mergeSegment(TextArea As TextArea,isSource As Boolean)
	Dim index As Int
	index=editorLV.Items.IndexOf(TextArea.Parent)
	If index+1>currentProject.segments.Size-1 Then
		Return
	End If
	Dim key As String
	Dim textIndex As Int
	If isSource Then
		key="source"
		textIndex=0
	Else
		key="target"
		textIndex=1
	End If
	
	Dim nextPane As Pane
	nextPane=editorLV.Items.Get(index+1)
	Dim nextTa As TextArea
	nextTa=nextPane.GetNode(textIndex)
	

	nextTa.Text=""
	Dim bitext As Map
	Dim nextbitext As Map
	bitext=currentProject.segments.Get(index)
	nextbitext=currentProject.segments.Get(index+1)
	
	Dim whiteSpace As String
	Dim lang As String
	Dim langPair As Map=currentProject.getProjectFileValue("langPair")
	If isSource Then
		lang=langPair.Get("source")
	Else
		lang=langPair.Get("target")
	End If
	If Utils.LanguageHasSpace(lang) Then
		whiteSpace=" "
	Else
		whiteSpace=""
	End If
	
	TextArea.Text=bitext.Get(key)&whiteSpace&nextbitext.Get(key)
	TextArea.Text=TextArea.Text.Trim
	bitext.Put(key,TextArea.Text)
	nextbitext.Put(key,"")
	

	Dim theOtherIndex As Int
	theOtherIndex=getTheOtherIndex(textIndex)
	Dim theOtherNextTa As TextArea
	theOtherNextTa=nextPane.GetNode(theOtherIndex)
	If theOtherNextTa.Text.Trim="" And nextTa.Text.Trim="" Then
		editorLV.Items.RemoveAt(index+1)
		currentProject.segments.RemoveAt(index+1)
	End If
	CallSubDelayed(Me,"ListViewParent_Resize")
End Sub

Sub getTheOtherIndex(textIndex As Int) As Int
	Dim theOtherIndex As Int
	If textIndex=0 Then
		theOtherIndex=1
	Else
		theOtherIndex=0
	End If
	Return theOtherIndex
End Sub

Sub splitSegment(TextArea As TextArea,isSource As Boolean)
	If ProtectSourceCheckBox.Checked And isSource Then
		Return
	End If
	Dim index As Int
	index=editorLV.Items.IndexOf(TextArea.Parent)
	Dim textIndex As Int
	Dim key As String
	If isSource Then
		key="source"
		textIndex=0
	Else
		key="target"
		textIndex=1
	End If
	
	Dim text As String
	text=TextArea.Text.SubString2(0,TextArea.SelectionEnd)
	text=text.Replace(CRLF,"").Trim
	Dim nextText As String
	nextText=TextArea.Text.SubString2(TextArea.SelectionEnd,TextArea.Text.Length).Trim
	
	TextArea.Text=text
	
	Dim bitext As Map
	Dim nextbitext As Map
	bitext=currentProject.segments.Get(index)
	bitext.Put(key,text)

	nextbitext.Initialize
	nextbitext.Put("source","")
	nextbitext.Put("target","")
	nextbitext.Put("note","")
	If bitext.ContainsKey("id") Then
		nextbitext.Put("id",bitext.Get("id"))
	End If
	
	Dim nextPane As Pane=createEmptyPane
	
	Dim nextSource,nextTarget As String
	If isSource Then
		nextSource=nextText
		nextTarget=""
	Else
		nextTarget=nextText
		nextSource=""
	End If
	nextbitext.Put("source",nextSource)
	nextbitext.Put("target",nextTarget)
	If nextSource="" And nextTarget="" Then
		Log("empty pair")
	Else
		currentProject.segments.InsertAt(index+1,nextbitext)
		addTextAreaToSegmentPane(nextPane,nextSource,nextTarget)
		editorLV.Items.InsertAt(index+1,nextPane)
	End If
	If ProtectSourceCheckBox.Checked Then
		deleteCell(True,nextPane.GetNode(0))
	End If
	CallSubDelayed(Me,"ListViewParent_Resize")
End Sub

Sub targetTextArea_TextChanged (Old As String, New As String)
	Dim TextArea1 As TextArea
	TextArea1=Sender
	Try
		Dim p As Pane=TextArea1.Parent
		Dim index As Int= editorLV.Items.IndexOf(p)
		Dim bitext As Map=currentProject.segments.get(index)
		bitext.Put("target",New)
	Catch
		Log(LastException)
	End Try
End Sub

Sub sourceTextArea_TextChanged (Old As String, New As String)
	Dim TextArea1 As TextArea
	TextArea1=Sender
	Try
		Dim p As Pane=TextArea1.Parent
		Dim index As Int= editorLV.Items.IndexOf(p)
		Dim bitext As Map=currentProject.segments.get(index)
		bitext.Put("source",New)
	Catch
		Log(LastException)
	End Try
End Sub

Sub sourceTextArea_FocusChanged (HasFocus As Boolean)
	Log(HasFocus)
	Dim TextArea1 As TextArea
	TextArea1=Sender
	Try
		If HasFocus Then
			updateSegmentsLabel(TextArea1)
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Sub targetTextArea_FocusChanged (HasFocus As Boolean)
	Log(HasFocus)
	Dim TextArea1 As TextArea
	TextArea1=Sender
	Try
		If HasFocus Then
			updateSegmentsLabel(TextArea1)
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Sub updateSegmentsLabel(TextArea1 As TextArea)
	Dim index As Int=editorLV.Items.IndexOf(TextArea1.Parent)
	currentIndex=index
	SegmentsLabel.Text=(index+1)&"/"&editorLV.Items.Size
End Sub

Private Sub AutoAlignButton_MouseClicked (EventData As MouseEvent)
	AutoAlign
End Sub

Sub AutoAlign 
	Dim langPair As Map
	langPair=currentProject.getProjectFileValue("langPair")

	Dim segments As List
	segments.Initialize
	segments.AddAll(currentProject.segments)
	
	Dim newSegments As List
	newSegments.Initialize
	
	progressDialog.Show(Main.loc.Localize("Aligning..."))
	progressDialog.update2(Main.loc.Localize("Processing..."))
	Dim sourceList,targetList,translationList As List
	sourceList.Initialize
	targetList.Initialize
	translationList.Initialize

	For Each segment As Map In segments
		Dim source,target,translation As String
		source=segment.Get("source")
		target=segment.Get("target")
		translation=segment.GetDefault("alt-translation","")
		If source<>"" Then
			sourceList.Add(source)
		End If
		If target<>"" Then
			targetList.Add(target)
		End If
		If translation<>"" Then
			translationList.Add(translation)
		End If
	Next

	Dim lfa As LFAlign
	lfa.Initialize
	wait for (lfa.Align(sourceList,targetList,langPair.Get("source"),langPair.Get("target"))) complete (result As Map)

	If result.Get("success") Then
		Log("success")
		Dim AlignedSources,AlignedTargets As List
		AlignedSources=result.Get("sourceList")
		AlignedTargets=result.Get("targetList")
		
		Dim complete As Boolean=True

		If TextIsIncomplete(sourceList,AlignedSources) Or TextIsIncomplete(targetList,AlignedTargets) Then
			complete=False
		End If

		Dim index As Int=0
		For Each item As String In AlignedSources
			Dim segment As Map
			segment.Initialize
			segment.Put("source",item)
			Dim alignedTarget As String=AlignedTargets.Get(index)
			segment.Put("target",alignedTarget)
			If complete=False Then
				segment.Put("complete",complete)
			End If
			index=index+1
			newSegments.Add(segment)
		Next
	Else
		Log("failed")
	End If
	currentProject.segments.Clear
	currentProject.segments.AddAll(newSegments)
	progressDialog.close
	loadSegmentsToListView
End Sub


Sub TextIsIncomplete(before As List,after As List) As Boolean
	Dim sb As StringBuilder
	sb.Initialize
	For Each segment As String In after
		sb.Append(segment)
	Next
	Dim textAfter As String=sb.ToString
	For Each segment As String In before
		segment=segment.Trim
		If segment<>"" Then
			If textAfter.Contains(segment)=False Then
				Log(segment)
				Log(textAfter)
				Return True
			End If
		End If
	Next
	Return False
End Sub

Private Sub SplitButton_MouseClicked (EventData As MouseEvent)
	Dim sourceList As List
	sourceList.Initialize
	Dim targetList As List
	targetList.Initialize
	For Each segment As Map In currentProject.segments
		Dim source As String = segment.Get("source")
		sourceList.Add(source)
		Dim target As String = segment.Get("target")
		If target <> "" Then
			Wait For (segmentation.segmentedTxt(target,True,currentProject.GetLangPair.Get("target"),"",False)) Complete (segmented As List)
			targetList.AddAll(segmented)
		End If
	Next
	currentProject.loadItemsToSegments(CreateMap("source":sourceList,"target":targetList))
	loadSegmentsToListView
End Sub

Private Sub MenuBar1_Action
	Dim mi As MenuItem = Sender
	Select Main.loc.FindSource(mi.Text)
		Case "_Open"
			Dim fc As FileChooser
			fc.Initialize
			fc.SetExtensionFilter("Aligner",Array As String("*.alp"))
			Dim selectedPath As String = fc.ShowOpen(frm)
			If File.Exists(selectedPath,"") Then
				path = selectedPath
				currentProject.Initialize(path)
				currentProject.readProjectFile
				loadSegmentsToListView
			End If
		Case "_Save"
			If path = "" Then
				Dim fc As FileChooser
				fc.Initialize
				fc.SetExtensionFilter("Aligner",Array As String("*.alp"))
				Dim selectedPath As String = fc.ShowSave(frm)
				path = selectedPath
				currentProject.path = selectedPath
			End If
			currentProject.save
	End Select
End Sub