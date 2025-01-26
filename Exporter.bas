B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub

Public Sub ExportToSRT(lines As List,path As String,askOption As Boolean)
	Dim option As Int = 0
	If askOption Then
		Dim optionsForm As ExportOptions
		optionsForm.Initialize
		option = optionsForm.ShowAndWait
		If option = -1 Then
			Return
		End If
	End If
	Dim sb As StringBuilder
	sb.Initialize
	Dim index As Int = 0
	For Each line As Map In lines
		sb.Append(index+1)
		sb.Append(Chr(13))
		sb.Append(Chr(10))
		sb.Append(line.Get("startTime"))
		sb.Append(" --> ")
		sb.Append(line.Get("endTime"))
		sb.Append(Chr(13))
		sb.Append(Chr(10))
		If option = 0 Then
			sb.Append(line.Get("source"))
		else if option = 1 Then
			sb.Append(line.Get("target"))
		Else
			sb.Append(line.Get("source"))
			sb.Append(Chr(13))
			sb.Append(Chr(10))
			sb.Append(line.Get("target"))
		End If
		sb.Append(Chr(13))
		sb.Append(Chr(10))
		sb.Append(Chr(13))
		sb.Append(Chr(10))
		index = index + 1
	Next
	File.WriteString(path,"",sb.ToString)
End Sub


Public Sub ExportToTXT(lines As List,path As String)
	Dim sb As StringBuilder
	sb.Initialize
	For Each line As Map In lines
		sb.Append(line.Get("startTime"))
		sb.Append("	")
		sb.Append(line.Get("endTime"))
		sb.Append("	")
		sb.Append(Escape(line.Get("source")))
		sb.Append("	")
		sb.Append(Escape(line.Get("target")))
	    sb.Append(CRLF)
	Next
	File.WriteString(path,"",sb.ToString)
End Sub

Private Sub Escape(str As String) As String
	str = str.Replace("	","\t")
	str = str.Replace(CRLF,"\n")
	If str = "" Then
		str = " "
	End If
	Return str
End Sub

public Sub Unescape(str As String) As String
	str = str.Replace("\t","	")
	str = str.Replace("\n",CRLF)
	Return str.Trim
End Sub
