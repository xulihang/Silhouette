B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private Entities As Map
End Sub

Public Sub TagsRemoved(s As String,keepWrap As Boolean) As String
	s=Regex.Replace2("`<(.*?)>`",32,s,"`&lt;$1&gt;`")
	s=Regex.Replace2("<.*?>",32,s,"")
	If keepWrap Then
		s=Regex.Replace2("`&lt;(.*?)&gt;`",32,s,"`<$1>`")
	Else
		s=Regex.Replace2("`&lt;(.*?)&gt;`",32,s,"<$1>")
	End If
	Return s
End Sub

Public Sub HandleXMLEntities(xml As String,escape As Boolean) As String
	Dim st As SimpleTag
	st.Initialize
	Dim Tags As List=st.getTags(xml)
	If Tags.Size=0 Then
		If escape Then
			Return EscapeXml(xml)
		Else
			Return UnescapeXml(xml)
		End If
	End If
	Dim parts As List
	parts.Initialize
	Dim previousEndIndex As Int=0
	For i=0 To Tags.Size-1
		Dim tag As Tag=Tags.Get(i)
		Dim textBefore As String=xml.SubString2(previousEndIndex,tag.index)
		If escape Then
			textBefore=EscapeXml(textBefore)
		Else
			textBefore=UnescapeXml(textBefore)
		End If
		
		If textBefore<>"" Then
			parts.Add(textBefore)
		End If
		parts.Add(tag.html)
		previousEndIndex=tag.index+tag.html.Length
	Next
	Dim textAfter As String
	textAfter=xml.SubString2(previousEndIndex,xml.Length)
	If textAfter<>"" Then
		If escape Then
			textAfter=EscapeXml(textAfter)
		Else
			textAfter=UnescapeXml(textAfter)
		End If
		parts.Add(textAfter)
	End If
	Dim sb As StringBuilder
	sb.Initialize
	For Each s As String In parts
		sb.Append(s)
	Next
	Return sb.ToString
End Sub


Public Sub EscapeXml(Raw As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To Raw.Length - 1
		Dim c As Char = Raw.CharAt(i)
		Select c
			Case QUOTE
				sb.Append("&quot;")
			Case "'"
				sb.Append("&apos;")
			Case "<"
				sb.Append("&lt;")
			Case ">"
				sb.Append("&gt;")
			Case "&"
				sb.Append("&amp;")
			Case Else
				sb.Append(c)
		End Select
	Next
	Return sb.ToString
End Sub

Public Sub UnescapeXml(Raw As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	Dim i As Int=0
	Dim n As Int=Raw.Length
	Do While i<n
		Dim appended As Boolean=False
		For Each key As String In getEntitiesMap.Keys
			If i+key.Length>n Then
				Continue
			End If
			Dim str As String=Raw.SubString2(i,i+key.Length)
			If str=key Then
				sb.Append(getEntitiesMap.Get(key))
				i=i+key.Length
				appended=True
				Exit
			End If
		Next
		If appended=False Then
			sb.Append(Raw.CharAt(i))
			i=i+1
		End If
	Loop
	Return sb.ToString
End Sub

Sub getEntitiesMap As Map
	If Entities.IsInitialized=False Then
		Entities.Initialize
		Entities.Put("&quot;",QUOTE)
		Entities.Put("&apos;","'")
		Entities.Put("&lt;","<")
		Entities.Put("&gt;",">")
		Entities.Put("&amp;","&")
	End If
	Return Entities
End Sub


Sub printChild(node As XmlNode)
	For Each children As XmlNode In node.Children
		Log(children.Name)
		printChild(children)
	Next
End Sub

Sub parse(xml As String) As XmlNode
	Dim parser As XmlParser
	parser.Initialize
	Dim root As XmlNode = parser.Parse(xml)
	If root.Children.Size=1 Then
		root=root.Children.Get(0)
		If root.Name="?xml" Then
			root=root.Children.Get(0)
		End If
	End If
	Return root
End Sub

Sub asString(Node As XmlNode) As String
	Dim builder As XMLBuilder2
	builder.Initialize
	buildNode(builder,Node,builder.Doc)
	Return builder.asString
End Sub

Sub asStringWithoutXMLHead(node As XmlNode) As String
	Return asString(node).Replace($"<?xml version="1.0" encoding="UTF-8" standalone="no"?>"$,"")
End Sub

Sub buildNode(builder As XMLBuilder2, node As XmlNode,Parent As JavaObject) As JavaObject
	Dim element As JavaObject=builder.e(node.Name)
	setAttr(builder,element,node.Attributes)
	builder.appendChild(Parent,element)
	For Each child As XmlNode In node.Children
		Dim childNode As JavaObject
		If child.Name="text" Then
			childNode=builder.t(child.Text)
		Else
			childNode=buildNode(builder,child,element)
		End If
		builder.appendChild(element,childNode)
	Next
	Return element
End Sub

Sub setAttr(builder As XMLBuilder2, element As JavaObject, attributes As Map)
	If attributes.IsInitialized Then
		For Each key As String In attributes.Keys
			builder.setAttributeNode(builder.createAttribute(key,attributes.Get(key)),element)
		Next
	End If
End Sub

Sub getXmlMap(xmlstring As String) As Map
	Dim ParsedData As Map
	Dim xm As Xml2Map
	xm.Initialize
	ParsedData = xm.Parse(xmlstring)
	Return ParsedData
End Sub


Sub GetElements (m As Map, key As String) As List
	Dim res As List
	If m.ContainsKey(key) = False Then
		res.Initialize
		Return res
	Else
		Dim value As Object = m.Get(key)
		If value Is List Then Return value
		res.Initialize
		res.Add(value)
		Return res
	End If
End Sub


Sub isXLIFFTag(tagName As String) As Boolean
	For Each name As String In Regex.Split(",","bpt,ept,it,ph,g,bx,ex,x,sub,mrk")
		If Regex.Replace("\d",tagName,"")=name Then
			Return True
		End If
	Next
	Return False
End Sub

'&lt;g id="1"&gt; -> `&lt;g id="1"&gt;`
Public Sub EncloseTagText(s As String,XMLEscaped As Boolean) As String
	Dim pattern As String
	If XMLEscaped Then
		pattern="&lt;/*(.*?)/*&gt;"
	Else
		pattern="</*(.*?)/*>"
	End If
	Dim sb As StringBuilder
	sb.Initialize
	Dim parts As List
	parts.Initialize
	Dim tags As List
	tags.Initialize
	Dim matcher As Matcher
	matcher=Regex.Matcher(pattern,s)
	Dim previousEndIndex As Int=0
	Do While matcher.Find
		Dim textBefore As String=s.SubString2(previousEndIndex,matcher.GetStart(0))
		If textBefore<>"" Then
			parts.Add(textBefore)
		End If
		Dim name As String=matcher.Group(1)
		If name.Contains(" ") Then
			name=name.SubString2(0,name.IndexOf(" "))
		End If
		If isXLIFFTag(name) Then
			parts.Add($"`${matcher.Match}`"$)
		Else
			parts.Add(matcher.Match)
		End If
		previousEndIndex=matcher.GetEnd(0)
	Loop
	Dim textAfter As String
	textAfter=s.SubString2(previousEndIndex,s.Length)
	If textAfter<>"" Then
		parts.Add(textAfter)
	End If
	For Each part As String In parts
		sb.Append(part)
	Next
	Return sb.ToString
End Sub

'`&lt;g id="1"&gt;` -> &lt;g id="1"&gt;
Public Sub DiscloseTagText(s As String,escaped As Boolean) As String
	If escaped Then
		Return Regex.Replace("`(&lt;.*?&gt;)`",s,"$1")
	Else
		Return Regex.Replace("`(<.*?>)`",s,"$1")
	End If
	
End Sub

Sub XMLToText(xml As String) As String
	'enclose tags: &lt;g&gt; -> `&lt;g&gt;`
	xml=EncloseTagText(xml,True)
	'unescape: <g1>&amp;</g1>-><g1>&</g1>
	Return HandleXMLEntities(xml,False)
End Sub

Sub TextToXML(s As String) As String
	'escape: <g1>&</g1>-><g1>&amp;</g1> 'xliff tags not escaped except they are enclosed with ``
	Dim Xml As String=HandleXMLEntities(s,True)
	'disclose tags: `&lt;g&gt;` -> &lt;g&gt;
	Xml=DiscloseTagText(Xml,True)
	Return Xml
End Sub

Sub XmlNodeText(node As XmlNode) As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each child As XmlNode In node.Children
		If child.Name="text" Then
			sb.Append(child.Text)
		End If
	Next
	Return sb.ToString
End Sub

Sub XmlNodeContainsOnlyText(node As XmlNode) As Boolean
	For Each child As XmlNode In node.Children
		If child.Name<>"text" Then
			Return False
		End If
	Next
	Return True
End Sub
