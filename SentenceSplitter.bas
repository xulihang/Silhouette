B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private CalculateTimeByWordsCheckBox As CheckBox
	Private SourceTextArea As TextArea
	Private TargetTextArea As TextArea
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	frm.Initialize("frm",600,500)
	frm.RootPane.LoadLayout("sentenceSplitter")
	Main.loc.LocalizeForm(frm)
End Sub

Public Sub SetText(source As String,target As String)
	SourceTextArea.Text = source
	TargetTextArea.Text = target
End Sub

Public Sub ShowAndWait As Map	
	frm.ShowAndWait
	Dim result As Map
	result.Initialize
	result.Put("source",SourceTextArea.Text)
	result.Put("target",TargetTextArea.Text)
	result.Put("calculateByWords",CalculateTimeByWordsCheckBox.Checked)
	Return result
End Sub

Public Sub SetCheckboxVisibility(value As Boolean)
	CalculateTimeByWordsCheckBox.Visible = value
End Sub

Private Sub OkayButton_MouseClicked (EventData As MouseEvent)
    frm.Close	
End Sub

Public Sub GetNewLines(startTime As String,endTime As String,lang As String,source As String,target As String,calculateTimeByWords As Boolean) As List
	Dim lines As List
	lines.Initialize
	Dim startTimeMs As Long = Utils.GetMillisecondsFromTimeString(startTime)
	Dim endTimeMs As Long = Utils.GetMillisecondsFromTimeString(endTime)
	Dim duration As Long = endTimeMs - startTimeMs
	Dim splittedSource() As String = Regex.Split(CRLF,source)
	Dim splittedTarget() As String = Regex.Split(CRLF,target)
	If calculateTimeByWords Then
		Dim syllableCount As Int = GetSyllablesLength(lang,source)
		Dim singleSyllableDuration As Int = duration/syllableCount
		Dim previousEndTime As Long = startTimeMs
		For i = 0 To splittedSource.Length - 1
			Dim source As String = splittedSource(i)
			Dim target As String
			If i<splittedTarget.Length Then
				target = splittedTarget(i)
			End If
			syllableCount = GetSyllablesLength(lang,source)
			Dim expectedDuration As Long = singleSyllableDuration * syllableCount
			Dim newLine As Map
			newLine.Initialize
			newLine.Put("source",source)
			newLine.Put("target",target)
			newLine.Put("startTime",Utils.GetTimeStringFromMilliseconds(previousEndTime))
			previousEndTime = previousEndTime + expectedDuration
			newLine.Put("endTime",Utils.GetTimeStringFromMilliseconds(previousEndTime))
			lines.Add(newLine)
		Next
	Else
		Dim fixedSpan As Int = duration/splittedSource.Length
		Dim previousEndTime As Long = startTimeMs
		For i = 0 To splittedSource.Length - 1
			Dim source As String = splittedSource(i)
			Dim target As String
			If i<splittedTarget.Length Then
				target = splittedTarget(i)
			End If
			Dim newLine As Map
			newLine.Initialize
			newLine.Put("source",source)
			newLine.Put("target",target)
			newLine.Put("startTime",Utils.GetTimeStringFromMilliseconds(previousEndTime))
			previousEndTime = previousEndTime + fixedSpan
			newLine.Put("endTime",Utils.GetTimeStringFromMilliseconds(previousEndTime))
			lines.Add(newLine)
		Next
	End If
	Return lines
End Sub

Private Sub GetSyllablesLength(lang As String,text As String) As Int
	If lang.StartsWith("zh") Or lang.StartsWith("ja") Then
		Return Regex.Split("",text).Length
	Else
		Return getPhonemeCount(text)
	End If
End Sub

'https://www.zhangxinxu.com/wordpress/2024/12/js-word-speach-split-time-calc/
Sub getPhonemeCount(s As String) As Int
	Dim totalSyllables As Int = 0
	' qu to tq
	s = s.Replace("qu", "qw")
	' replace endings
	s = Regex.Replace("(es$)|(que$)|(gue$)",s, "")
	s = Regex.Replace("^re",s, "ren")
	s = Regex.Replace("^gua",s, "ga")
	s = Regex.Replace("([aeiou])(l+e$)",s, "$1")
	Dim matcher As Matcher
	matcher = Regex.Matcher("([bcdfghjklmnpqrstvwxyz])(l+e$)", s)
	Dim syllables As Int = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	
	totalSyllables = totalSyllables + syllables
	s = Regex.Replace("([bcdfghjklmnpqrstvwxyz])(l+e$)",s, "$1")
	s = Regex.Replace("([aeiou])(ed$)",s, "$1")
	matcher = Regex.Matcher("([bcdfghjklmnpqrstvwxyz])(ed$)", s)
	syllables = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	
	totalSyllables = totalSyllables + syllables
	s = Regex.Replace("([bcdfghjklmnpqrstvwxyz])(ed$)",s, "$1")
	Dim endsp As String = "(ly$)|(ful$)|(ness$)|(ing$)|(est$)|(er$)|(ent$)|(ence$)"
	matcher = Regex.Matcher(endsp, s)
	syllables = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	totalSyllables = totalSyllables + syllables
	s =  Regex.Replace(endsp,s, "")
	matcher = Regex.Matcher(endsp, s)
	syllables = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	totalSyllables = totalSyllables + syllables
	
	s = Regex.Replace(endsp,s, "")
	s = Regex.Replace("(^y)([aeiou][aeiou]*)",s, "$2")
	s = Regex.Replace("([aeiou])(y)",s, "$1t")
	s = Regex.Replace("aa+",s, "a")
	s = Regex.Replace("ee+",s, "e")
	s = Regex.Replace("ii+",s, "i")
	s = Regex.Replace("oo+",s, "o")
	s = Regex.Replace("uu+",s, "u")
	
	' Dipthongs
	Dim dipthongs As String = "(eau)|(iou)|(are)|(ai)|(au)|(ea)|(ei)|(eu)|(ie)|(io)|(oa)|(oe)|(oi)|(ou)|(ue)|(ui)"
	matcher = Regex.Matcher(dipthongs, s)
	syllables = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	totalSyllables = totalSyllables + syllables
	s = Regex.Replace(dipthongs,s, "")
	' Remove silent 'e' if length is greater than 3
	If s.Length > 3 Then
		s = Regex.Replace("([bcdfghjklmnpqrstvwxyz])(e$)",s, "$1")
	End If
	' Count vowels
	matcher  = Regex.Matcher("[aeiouy]", s)
	syllables = 0
	Do While matcher.Find
	    syllables = syllables + 1
	Loop
	totalSyllables = totalSyllables + syllables
	Return totalSyllables
End Sub