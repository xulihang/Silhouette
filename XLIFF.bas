B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.8
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub


Sub Export(lines As List,path As String,sourceLang As String,targetLang As String)
	Dim rootmap As Map
	rootmap.Initialize
	Dim xliffMap As Map
	xliffMap.Initialize
	xliffMap.Put("Attributes",CreateMap("version":"1.2","xmlns":"urn:oasis:names:tc:xliff:document:1.2"))
	Dim filesList As List
	filesList.Initialize
	Dim fileMap As Map
	fileMap.Initialize
	fileMap.Put("Attributes",CreateMap("original":"1.srt","source-language":sourceLang,"target-language":targetLang,"datatype":"plaintext"))
	filesList.Add(fileMap)
	Dim body As Map
	body.Initialize
	Dim tus As List
	tus.Initialize
	body.Put("trans-unit",tus)
	fileMap.Put("body",body)
	Dim index As Int = 0
	For Each line As Map In lines
		Dim tu As Map
		tu.Initialize
		tu.Put("Attributes",CreateMap("id":index))
		tu.Put("source",line.Get("source"))
		tu.Put("target",line.Get("target"))
		index=index+1
		tus.Add(tu)
	Next
	xliffMap.Put("file",filesList)
	rootmap.Put("xliff",xliffMap)
	Dim m2x As Map2Xml
	m2x.Initialize
	File.WriteString(path,"",m2x.MapToXml(rootmap))
End Sub

Sub Import(path As String) As List
	Dim segments As List
	segments.Initialize
	Dim xmlstring As String=File.ReadString(path,"")
	For Each fileMap As Map In getFilesList(xmlstring)
		Try
			Dim body As Map=fileMap.Get("body")
			Dim tus As List
			tus=GetElements(body,"trans-unit")
			For Each tu As Map In tus
				'Dim Attributes As Map=tu.Get("Attributes")
				'Dim index As Int=Attributes.Get("id")
				Dim source As String=getText("source",tu)
				Dim target As String=getText("target",tu)
				Dim segment As List
				segment.Initialize
				segment.Add(source)
				segment.Add(target)
				segments.Add(segment)
			Next
		Catch
			Log(LastException)
		End Try
	Next
	Return segments
End Sub

Sub getText(key As String, m As Map) As String
	Dim text As String=""
	Try
		Dim map1 As Map
		map1=m.Get(key)
		text=map1.get("Text")
	Catch
		Log(LastException)
		text=m.Get(key)
	End Try
	Return text
End Sub

Sub getFilesList(xmlstring As String) As List
	'Log("read")
	Dim x2m As Xml2Map
	x2m.Initialize
	Dim xmlMap As Map
	xmlMap=x2m.Parse(xmlstring)
	'Log(xmlMap)
	Dim xliffMap As Map
	xliffMap=xmlMap.Get("xliff")
	Return GetElements(xliffMap,"file")
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