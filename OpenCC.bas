B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private bootstrap As JavaObject
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	bootstrap = bootstrap.InitializeStatic("com.github.houbb.opencc4j.core.impl.ZhConvertBootstrap").RunMethod("newInstance",Null)
End Sub

Public Sub ConvertToSimple(str As String) As String
	Return bootstrap.RunMethod("toSimple",Array(str))
End Sub

Public Sub ConvertToTraditional(str As String) As String
	Return bootstrap.RunMethod("toTraditional",Array(str))
End Sub
