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

Public Sub ExportToSRT(lines As List,path As String)
	Dim optionsForm As ExportOptions
	optionsForm.Initialize
	Dim option As Int = optionsForm.ShowAndWait
	If option = -1 Then
		Return
	Else
		Dim sb As StringBuilder
		sb.Initialize
		Dim index As Int = 0
		For Each line As Map In lines
			sb.Append(index+1)
			sb.Append(CRLF)
			sb.Append(line.Get("startTime"))
			sb.Append(" --> ")
			sb.Append(line.Get("endTime"))
			sb.Append(CRLF)
			If option = 0 Then
				sb.Append(line.Get("source"))
			else if option = 1 Then
				sb.Append(line.Get("target"))
			Else
				sb.Append(line.Get("source"))
				sb.Append(CRLF)
				sb.Append(line.Get("target"))
			End If
			sb.Append(CRLF)
			index = index + 1
		Next
		File.WriteString(path,"",sb.ToString)
	End If
End Sub