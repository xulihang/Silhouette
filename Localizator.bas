B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.2
@EndOfDesignText@
'version 1.00
Sub Class_Globals
	Private sql As SQL	
	Private Locale As String
	Private strings As Map
	Public sourceLang As String="en"
End Sub
'Initializes the object.
'Dir / FileName - Path to the database file
Public Sub Initialize (Dir As String, FileName As String)
	Dim folder As String
	If Dir = File.DirAssets Then
#if B4A
		folder = File.DirInternal
#else if B4I
		folder = File.DirLibrary
#else if B4J
		folder = File.DirTemp
#end if
		File.Copy(Dir, FileName, folder, "strings.db")
	Else
		folder = Dir
	End If
#if B4J
	sql.InitializeSQLite(folder, "strings.db", False)
#else
	sql.Initialize(folder, "strings.db", False)
#end if
	strings.Initialize
	Locale = FindLocale
	If sql.ExecQuerySingleResult2("SELECT count(*) FROM data WHERE lang = ?", Array(Locale)) = 0 Then
		Log($"Locale not found: ${Locale}. Switching to 'en'."$)
		Locale = "en"
	End If
	Log($"Device locale: ${Locale}"$)
	LoadStrings
End Sub

'Forces the localizator to use a specific language (two letters code)
Public Sub ForceLocale(Language As String)
	Locale = Language
	LoadStrings
End Sub

Sub FindSource(value As String) As String
	Dim key,source As String
	
	Dim rs As ResultSet = sql.ExecQuery2("SELECT key FROM data WHERE lang = ? AND value = ?", Array As String(Locale,value))
	If rs.NextRow Then
		key=rs.GetString2(0)
	Else
		rs.Close
		Return value
	End If
	rs.Close
	
	Dim rs As ResultSet = sql.ExecQuery2("SELECT value FROM data WHERE lang = ? AND key = ?", Array As String(sourceLang,key))
	If rs.NextRow Then
		source=rs.GetString2(0)
	Else
		rs.Close
		Return value
	End If
	rs.Close
	Return source
End Sub

Sub FindSourceWithoutKnowingTheLang(value As String) As String
	Dim key,source As String
	
	Dim rs As ResultSet = sql.ExecQuery2("SELECT key FROM data WHERE value = ?", Array As String(value))
	If rs.NextRow Then
		key=rs.GetString2(0)
	Else
		rs.Close
		Return value
	End If
	rs.Close
	
	Dim rs As ResultSet = sql.ExecQuery2("SELECT value FROM data WHERE lang = ? AND key = ?", Array As String(sourceLang,key))
	If rs.NextRow Then
		source=rs.GetString2(0)
	Else
		rs.Close
		Return value
	End If
	rs.Close
	Return source
End Sub

Private Sub LoadStrings
	strings.Clear
	Dim rs As ResultSet = sql.ExecQuery2("SELECT key, value FROM data WHERE lang = ?", Array As String(Locale))
	Do While rs.NextRow
		strings.Put(rs.GetString2(0), rs.GetString2(1))
	Loop
	rs.Close
	Log($"Found ${strings.Size} strings."$)
End Sub

'Localizes the items from the list and returns a new list.
Public Sub LocalizeList(Items As List) As List
	Dim res As List
	res.Initialize
	For Each s As String In Items
		res.Add(Localize(s))
	Next
	Return res
End Sub

Public Sub GetLangs As List
	Dim langs As List
	langs.Initialize
	Try
		Dim rs As ResultSet = sql.ExecQuery("SELECT key FROM langs")
		Do While rs.NextRow
			Dim key As String = rs.GetString2(0)
			langs.Add(key)
		Loop
		rs.Close
	Catch
		Log(LastException)
	End Try
	Return langs
End Sub

Public Sub GetKeyValuesInLangs As Map
	Dim langs As Map
	langs.Initialize
	Dim rs As ResultSet = sql.ExecQuery("SELECT key, value, lang FROM data")
	Do While rs.NextRow
		Dim key As String = rs.GetString2(0)
		Dim value As String = rs.GetString2(1)
		Dim lang As String = rs.GetString2(2)
		Dim items As List
		If langs.ContainsKey(lang) Then
			items=langs.Get(lang)
		Else
			items.Initialize
			langs.Put(lang,items)
		End If
		Dim item As Map
		item.Initialize
		item.Put("key",key)
		item.Put("value",value)
		items.Add(item)
	Loop
	rs.Close
	Return langs
End Sub

public Sub ResetWithXLSX(path As String) As Boolean
	sql.BeginTransaction
    Try
		sql.ExecNonQuery("DROP TABLE data")
		sql.ExecNonQuery("DROP TABLE IF EXISTS langs")
		sql.ExecNonQuery("CREATE TABLE data (key TEXT, lang TEXT, value TEXT, PRIMARY KEY (lang, key))")
		sql.ExecNonQuery("CREATE TABLE langs (key TEXT, PRIMARY KEY (key))")
		Dim wb As PoiWorkbook
		wb.InitializeExisting(path, "", "", False)
		Dim sheet As PoiSheet = wb.GetSheet(0)
		Dim languagesRow As PoiRow = sheet.GetRow(0)
		If languagesRow.IsInitialized = False Then
			Return False
		End If
		Dim langs As List
		langs.Initialize
		For Each cell As PoiCell In languagesRow.Cells
			If cell.ValueString.ToLowerCase = "key" Then Continue
			langs.Add(cell.ValueString)
			sql.ExecNonQuery2("INSERT INTO langs VALUES (?)", Array (cell.ValueString))
		Next
		For Each row As PoiRow In sheet.Rows
			If row.RowNumber = 0 Then Continue
			Dim key As String
			For Each cell As PoiCell In row.Cells
				Dim value As String = cell.Value
				If cell.ColumnIndex = 0 Then
					key = value
				Else
					Dim lang As String = langs.Get(cell.ColumnIndex - 1)
					sql.ExecNonQuery2("INSERT INTO data VALUES (?, ?, ?)", Array (key.ToLowerCase, lang, value))
				End If
			Next
		Next
		
		sql.TransactionSuccessful
		wb.Close
	Catch
		Log(LastException)
		sql.Rollback
		Return False
	End Try
	Return True
End Sub

'Localizes the given key.
'If the key does not match then the key itself is returned.
'Note that the key matching is case insensitive.
Public Sub Localize(Key As String) As String
	Return strings.GetDefault(Key.ToLowerCase, Key)
End Sub

'Localizes a key with one or more parameters. The parameters need to be defined in the values.
Public Sub LocalizeParams(key As String, Params As List) As String
	Dim value As String = Localize(key)
	For i = 0 To Params.Size - 1
		value = value.Replace("{" & (i + 1) & "}", Params.Get(i))
	Next
	Return value
End Sub

#if B4A
Public Sub LocalizeLayout(PanelOrActivity As Panel)
	For Each v As View In PanelOrActivity.GetAllViewsRecursive
		If v Is Label Then 'this will catch all of Label subclasses which includes EditText, Button and others
			Dim lbl As Label = v
			lbl.Text = Localize(lbl.Text)
		End If
		If v Is EditText Then
			Dim et As EditText = v
			et.Hint = Localize(et.Hint)
		End If
	Next
End Sub
#else if B4I
Public Sub LocalizeLayout(Panel As Panel)
	For Each v As View In Panel.GetAllViewsRecursive
		If v Is Button Then
			Dim btn As Button = v
			btn.Text = Localize(btn.Text)	
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.Text = Localize(lbl.Text)
		Else If v Is TextField Then
			Dim tf As TextField = v
			tf.Text = Localize(tf.Text)
		Else if v Is TextView Then
			Dim tv As TextView = v
			tv.Text = Localize(tv.Text)
		End If
	Next
End Sub
#else if B4J
Public Sub LocalizeForm(frm As Form)
	LocalizeLayout(frm.RootPane)
	frm.Title=Localize(frm.Title)
End Sub

Public Sub LocalizeLayout(Pane As Pane)
	For Each n As Node In Pane.GetAllViewsRecursive
		If n Is TextArea Then
			Dim ta As TextArea = n
			ta.Text = Localize(ta.Text)
			ta.PromptText=Localize(ta.PromptText)
		Else If n Is TextField Then
			Dim tf As TextField = n
			tf.Text = Localize(tf.Text)
			tf.PromptText=Localize(tf.PromptText)
		Else if n Is Button Then
			Dim btn As Button = n
			btn.Text = Localize(btn.Text)
			If btn.TooltipText<>"" Then
				btn.TooltipText=Localize(btn.TooltipText)
			End If
		Else if n Is CheckBox Then
			Dim cbx As CheckBox = n
			cbx.Text = Localize(cbx.Text)
		Else If n Is RadioButton Then
			Dim rbtn As RadioButton = n
			rbtn.Text = Localize(rbtn.Text)
		Else If n Is ToggleButton Then
			Dim tbtn As ToggleButton = n
			tbtn.Text = Localize(tbtn.Text)
			If tbtn.TooltipText<>"" Then
				tbtn.TooltipText=Localize(tbtn.TooltipText)
			End If
		Else If n Is Label Then
			Dim lbl As Label = n
			lbl.Text = Localize(lbl.Text)
		Else If n Is MenuBar Then
			Dim mb As MenuBar=n
			LocalizeMenuItems(mb.Menus)
		Else If n Is ListView Then
			Dim lv As ListView=n
			If lv.ContextMenu.IsInitialized Then
				LocalizeMenuItems(lv.ContextMenu.MenuItems)
			End If
		Else If n Is ScrollPane Then
			LocalizeScrollPane(n)
		Else If n Is SplitPane Then
			LocalizeSplitPane(n)
		Else If n Is TabPane Then
			LocalizeTabPane(n)
	    Else If n Is TableView Then
			LocalizeTableView(n)
		else if n Is ComboBox Then
			Dim combox As ComboBox = n
			If combox.ContextMenu.IsInitialized Then
				LocalizeMenuItems(combox.ContextMenu.MenuItems)
			End If
	    End If
		If Locale<>sourceLang Then
			AddToolTip(n)
		End If
	Next
End Sub

Sub LocalizeScrollPane(sp As ScrollPane)
	If sp.ContextMenu.IsInitialized Then
		LocalizeMenuItems(sp.ContextMenu.MenuItems)
	End If
	If sp.InnerNode Is Pane Then
		LocalizeLayout(sp.InnerNode)
	End If
End Sub

Sub AddToolTip(n As Node)
	Dim fx As JFX
	If n Is Label Then
		Dim lbl As Label=n
		If NeedResize(lbl.PrefWidth,lbl.Font,lbl.Text,lbl.PrefHeight) Then
			If lbl.TooltipText="" Then
				lbl.TooltipText=lbl.Text
			End If
		End If
	else if n Is CheckBox Then
		Dim cb As CheckBox=n
		If cb.TooltipText="" Then
			cb.TooltipText=cb.Text
		End If
	else if n Is Button Then
		Dim btn As Button=n
		If btn.TooltipText="" Then
			btn.TooltipText=btn.Text
		End If
	else if n Is RadioButton Then
		Dim rbtn As RadioButton=n
		If rbtn.TooltipText="" Then
			rbtn.TooltipText=rbtn.Text
		End If
	else if n Is ToggleButton Then
		Dim tbn As ToggleButton=n
		If tbn.TooltipText="" Then
			tbn.TooltipText=tbn.Text
		End If
	End If
End Sub

Sub NeedResize(width As Double,font As Font,text As String,height As Double) As Boolean
	Dim desiredHeight As Double=Utils.MeasureMultilineTextHeight(font,width,text)
	'Log(desiredHeight)
	'Log(height)
	If height<desiredHeight+5 Then
		Return True
	Else
		Return False
	End If
End Sub

Sub LocalizeTabPane(tp As TabPane)
	Dim jo As JavaObject=tp
	Dim tabs As List=jo.RunMethod("getTabs",Null)
	For index=tabs.size-1 To 0 Step -1
		Dim page As TabPage=tabs.Get(index)
		LocalizeLayout(page.Content)
	Next
End Sub

Sub LocalizeSplitPane(sp As SplitPane)
	Dim jo As JavaObject=sp
	Dim items As List=jo.RunMethod("getItems",Null)
	For Each pane As Pane In items
		LocalizeLayout(pane)
	Next
End Sub

Sub LocalizeMenuItems(MenuItems As List)
	For Each item As Object In MenuItems
		If item Is Menu Then
			Dim m As Menu=item
			m.Text=Localize(m.Text)
			LocalizeMenuItems(m.MenuItems)
		else if item Is MenuItem Then
			Try
				Dim mi As MenuItem=item
				mi.Text=Localize(mi.Text)
			Catch
				Log(LastException)
			End Try
		End If
	Next
End Sub

Sub LocalizeTableView(tv As TableView)
	For i=0 To tv.ColumnsCount-1
		tv.SetColumnHeader(i,Localize(tv.GetColumnHeader(i)))
	Next
	If tv.ContextMenu.IsInitialized Then
		LocalizeMenuItems(tv.ContextMenu.MenuItems)
	End If
End Sub

#end If

Private Sub FindLocale As String
	#if B4A or B4J
		Dim jo As JavaObject
		jo = jo.InitializeStatic("java.util.Locale").RunMethod("getDefault", Null)
		Return jo.RunMethod("getLanguage", Null)
	#else if B4i
    Dim no As NativeObject
    Dim lang As String = no.Initialize("NSLocale") _
        .RunMethod("preferredLanguages", Null).RunMethod("objectAtIndex:", Array(0)).AsString
	If lang.Length > 2 Then lang = lang.SubString2(0, 2)
	Return lang
	#end if
End Sub

'Returns the current locale.
Public Sub getLanguage As String
	Return Locale
End Sub