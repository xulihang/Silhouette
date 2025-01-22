B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private Bconv As ByteConverter
	Private mtResultStore As Map
End Sub

public Sub getMTList As List
	Dim mtList As List
	mtList.Initialize
	mtList.AddAll(Array As String("baidu","tencent","microsoft","youdao","mymemory"))
	mtList.AddAll(getMTPluginList)
	Return mtList
End Sub

Sub getMTPluginList As List
	Dim mtList As List
	mtList.Initialize
	For Each name As String In Main.plugin.GetAvailablePlugins
		If name.EndsWith("MT") Then
			mtList.Add(name.Replace("MT",""))
		End If
	Next
	Return mtList
End Sub

public Sub getMT(source As String,sourceLang As String,targetLang As String,MTEngine As String) As ResumableSub
	If source="" Then
		Return ""
	End If
	wait for (getMTImpl(source,sourceLang,targetLang,MTEngine)) Complete (result As String)
	Return result
End Sub

Private Sub getMTImpl(source As String,sourceLang As String,targetLang As String,MTEngine As String) As ResumableSub
	sourceLang=convertLangCode(sourceLang,MTEngine)
	targetLang=convertLangCode(targetLang,MTEngine)
	
	If mtResultStore.IsInitialized=True Then
		Dim key As String=getMTResultKey(source,MTEngine,sourceLang,targetLang)
		If mtResultStore.ContainsKey(key) Then
			Return mtResultStore.Get(key)
		End If
	End If
	
	Select MTEngine
		Case "baidu"
			wait for (BaiduMT(Array As String(source),sourceLang,targetLang)) Complete (targetList As List)
			Dim result As String
			Dim sb As StringBuilder
			sb.Initialize
			For Each text As String In targetList
				sb.Append(text)
			Next
			result=sb.ToString
		Case "microsoft"
			wait for (microsoftMT(source,sourceLang,targetLang)) Complete (result As String)
		Case "tencent"
			wait for (tencentMT(source,sourceLang,targetLang)) Complete (result As String)
		Case "youdao"
			wait for (youdaoMT(source,sourceLang,targetLang)) Complete (result As String)
		Case "mymemory"
			wait for (MyMemory(source,sourceLang,targetLang)) Complete (result As String)
	End Select
	
	If result="" And getMTPluginList.IndexOf(MTEngine)<>-1 Then
		Dim params As Map
		params.Initialize
		params.Put("source",source)
		params.Put("sourceLang",sourceLang)
		params.Put("targetLang",targetLang)
		params.Put("preferencesMap",getPreferencesMap(MTEngine))
		wait for (Main.plugin.RunPlugin(MTEngine&"MT","translate",params)) complete (result As String)
		Log("pluginMT"&result)
	End If
	If result<>"" Then
		storeMTResult(source,result,MTEngine,sourceLang,targetLang)
	End If
	Return result
End Sub

Sub getPreferencesMap(MTEngine As String) As Map
	Dim preferencesMap As Map
	preferencesMap.Initialize
	Dim storedMap As Map = Utils.getPrefMap
	For Each key As String In storedMap.Keys
		preferencesMap.Put(key,storedMap.Get(key))
	Next
	If preferencesMap.ContainsKey("api") Then
		Dim apiMap As Map=preferencesMap.Get("api")
		Dim newMap As Map
		newMap.Initialize
		For Each key As String In apiMap.Keys
			If key=MTEngine Then
				newMap.Put(key,apiMap.Get(key))
			End If
		Next
		preferencesMap.Put("api",newMap)
		preferencesMap.Put("mt",newMap)
	End If
    Return preferencesMap
End Sub

Sub storeMTResult(source As String,target As String,engine As String,sourceLang As String,targetLang As String)
	If mtResultStore.IsInitialized=False Then
		mtResultStore.Initialize
	End If
	mtResultStore.Put(getMTResultKey(source,engine,sourceLang,targetLang),target)
End Sub

Public Sub clearStore
	mtResultStore.Clear
End Sub

Sub getMTResultKey(source As String,engine As String,sourceLang As String,targetLang As String) As String
	Dim map1 As Map
	map1.Initialize
	map1.Put("source",source)
	map1.Put("engine",engine)
	map1.Put("sourceLang",sourceLang)
	map1.Put("targetLang",targetLang)
	Dim json As JSONGenerator
	json.Initialize(map1)
	Return json.ToString
End Sub

Sub convertLangCode(lang As String,engine As String) As String
	If File.Exists(File.DirData("BasicCAT"),"langcodes.txt")=False Then
		File.Copy(File.DirAssets,"langcodes.txt",File.DirData("BasicCAT"),"langcodes.txt")
	End If
	Dim langcodes As Map
	langcodes=Utils.readLanguageCode(File.Combine(File.DirData("BasicCAT"),"langcodes.txt"))
	Dim codeMap As Map
	If langcodes.ContainsKey(lang)=False Then
		Return lang
	End If
	codeMap=langcodes.Get(lang)
	If codeMap.ContainsKey(engine) Then
		lang=codeMap.Get(engine)
	End If
	Return lang
End Sub

Sub BaiduMT(sourceList As List,sourceLang As String,targetLang As String) As ResumableSub
	sourceLang=sourceLang.ToLowerCase
	targetLang=targetLang.ToLowerCase
	
	Dim source As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each text As String In sourceList
		text = text.Replace(CRLF,"<br/>")
		sb.Append(text).Append(CRLF)
	Next
	source=sb.ToString
	Dim targetList As List
	targetList.Initialize
	Dim salt As Int
	salt=Rnd(1,1000)
	Dim appid,sign,key As String
	appid=Utils.getMap("baidu",Utils.getMap("api",Utils.getPrefMap)).Get("appid")
	key=Utils.getMap("baidu",Utils.getMap("api",Utils.getPrefMap)).Get("key")
	If appid="" Then
		Return ""
	End If

	
	sign=appid&source&salt&key
	Dim md As MessageDigest
	sign=Bconv.HexFromBytes(md.GetMessageDigest(Bconv.StringToBytes(sign,"UTF-8"),"MD5"))
	sign=sign.ToLowerCase
	
	Dim su As StringUtils
	source=su.EncodeUrl(source,"UTF-8")
	Dim param As String
	param="?appid="&appid&"&q="&source&"&from="&sourceLang&"&to="&targetLang&"&salt="&salt&"&sign="&sign
	Dim job As HttpJob
	job.Initialize("job",Me)
	job.Download("https://api.fanyi.baidu.com/api/trans/vip/translate"&param)
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Log(job.GetString)
		Try
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim result As List
			result=json.NextObject.Get("trans_result")
			For Each resultMap As Map In result
				Dim dst As String = resultMap.Get("dst")
				dst = dst.Replace("<br/>",CRLF)
				targetList.Add(dst)
			Next
		Catch
			Log(LastException)
		End Try
	End If
	job.Release
	Return targetList
End Sub

Sub microsoftMT(source As String,sourceLang As String,targetLang As String) As ResumableSub
	Dim target,key As String
	key=Utils.getMap("microsoft",Utils.getMap("api",Utils.getPrefMap)).Get("key")
	If key="" Then
		Return ""
	End If
	
	Dim sourceList As List
	sourceList.Initialize
	sourceList.Add(CreateMap("Text":source))
	Dim jsong As JSONGenerator
	jsong.Initialize2(sourceList)
	source=jsong.ToString
	Dim job As HttpJob
	job.Initialize("job",Me)
	Dim params As String
	params="&from="&sourceLang&"&to="&targetLang
	
	job.PostString("https://api.cognitive.microsofttranslator.com/translate?api-version=3.0"&params,source)
	job.GetRequest.SetContentType("application/json")
	job.GetRequest.SetHeader("Ocp-Apim-Subscription-Key",key)
	job.GetRequest.SetHeader("X-ClientTraceId",UUID)
	job.GetRequest.SetHeader("Content-Type","application/json")
	job.GetRequest.SetHeader("Accept","application/json")
	wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim result As List
			result=json.NextArray
			Dim innerMap As Map
			innerMap=result.Get(0)
			Dim translations As List
			translations=innerMap.Get("translations")
			Dim map1 As Map
			map1=translations.Get(0)
			target=map1.Get("text")
		Catch
			target=""
			Log(LastException)
		End Try
	Else
		target=""
	End If
	job.Release
	Return target
End Sub

Sub UUID As String
	Dim jo As JavaObject
	Return jo.InitializeStatic("java.util.UUID").RunMethod("randomUUID", Null)
End Sub

Sub tencentMT(source As String, sourceLang As String, targetLang As String) As ResumableSub
	Dim target As String
	Dim id,key As String
	id=Utils.getMap("tencent",Utils.getMap("api",Utils.getPrefmap)).Get("id")
    key=Utils.getMap("tencent",Utils.getMap("api",Utils.getPrefmap)).Get("key")
	If id="" Then
		Return ""
	End If
	
	
	Dim su As StringUtils

	Dim params As String
	Dim nounce As Int
	Dim timestamp As Int=DateTime.Now/1000
	nounce=Rnd(1000,2000)
	params="Action=TextTranslate&Nonce="&nounce&"&ProjectId=0&Region=ap-shanghai&SecretId="&id&"&Source="&sourceLang&"&SourceText="&source&"&Target="&targetLang&"&Timestamp="&timestamp&"&Version=2018-03-21"
	'add signature
	source=su.EncodeUrl(source,"UTF-8")
	params="Action=TextTranslate&Nonce="&nounce&"&ProjectId=0&Region=ap-shanghai&SecretId="&id&"&Signature="&getSignature(key,params)&"&Source="&sourceLang&"&SourceText="&source&"&Target="&targetLang&"&Timestamp="&timestamp&"&Version=2018-03-21"
	'Log(params)
	Dim job As HttpJob
	job.Initialize("job",Me)
	job.Download("https://tmt.ap-shanghai.tencentcloudapi.com/?"&params)
	wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		Log(job.GetString)
		Try
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim Response As Map
			Response=json.NextObject.Get("Response")
			target=Response.Get("TargetText")
		Catch
			Log(LastException)
		End Try
	Else
		target=""
	End If
	job.Release
	Return target
End Sub

Sub getSignature(key As String,params As String) As String
	Dim mactool As Mac
	Dim k As KeyGenerator
	k.Initialize("HMACSHA1")
	Dim su As StringUtils
	Dim combined As String="GETtmt.ap-shanghai.tencentcloudapi.com/?"&params
	k.KeyFromBytes(Bconv.StringToBytes(key,"UTF-8"))
	mactool.Initialise("HMACSHA1",k.Key)
	mactool.Update(combined.GetBytes("UTF-8"))
	Dim bb() As Byte
	bb=mactool.Sign
	Dim base As Base64
	Dim sign As String=base.EncodeBtoS(bb,0,bb.Length)
	sign=su.EncodeUrl(sign,"UTF-8")
	Return sign
End Sub

Sub youdaoMT(source As String,sourceLang As String,targetLang As String) As ResumableSub
	Dim salt As Int
	salt=Rnd(1,1000)
	Dim appid,sign,key As String
	appid=Utils.getMap("youdao",Utils.getMap("api",Utils.getPrefMap)).Get("appid")
	key=Utils.getMap("youdao",Utils.getMap("api",Utils.getPrefMap)).Get("key")
	If key = "" Then
		Return ""
	End If
	
	sign=appid&source&salt&key
	
	Dim md As MessageDigest
	sign=Bconv.HexFromBytes(md.GetMessageDigest(Bconv.StringToBytes(sign,"UTF-8"),"MD5"))
	sign=sign.ToLowerCase
	
	Dim su As StringUtils
	source=su.EncodeUrl(source,"UTF-8")
	Dim param As String
	param="?appKey="&appid&"&q="&source&"&from="&sourceLang&"&to="&targetLang&"&salt="&salt&"&sign="&sign
	Dim job As HttpJob
	job.Initialize("job",Me)
	job.Download("https://openapi.youdao.com/api"&param)
	wait for (job) JobDone(job As HttpJob)
	Dim target As String=""
	If job.Success Then
		Log(job.GetString)
		Try
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim result As Map
			result=json.NextObject
			If result.Get("errorCode")="0" Then
				Dim translationList As List
				translationList=result.Get("translation")
				target=translationList.Get(0)
			End If
		Catch
			Log(LastException)
		End Try
	End If
	job.Release
	Return target
End Sub

Sub MyMemory(source As String,sourceLang As String,targetLang As String) As ResumableSub
    Dim email As String
	Dim preferencesMap As Map = Utils.getPrefMap
	email=Utils.getMap("mymemory",Utils.getMap("api",preferencesMap)).GetDefault("email","")
	Dim su As StringUtils
	source=su.EncodeUrl(source,"UTF-8")
	Dim job As HttpJob
	job.Initialize("job",Me)
	Dim langpair As String
	langpair=sourceLang&"|"&targetLang
	langpair=su.EncodeUrl(langpair,"UTF-8")
	Dim param As String
	param="?q="&source&"&langpair="&langpair
	If email<>"" Then
		param=param&"&de="&email
	End If
	
	job.Download("https://api.mymemory.translated.net/get"&param)
	Dim translatedText As String=""
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Log(job.GetString)
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim response As Map
			response=json.NextObject.Get("responseData")
			translatedText=response.Get("translatedText")
		Catch
			Log(LastException)
		End Try
	End If
	job.Release
	Return translatedText
End Sub
