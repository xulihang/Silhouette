B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.9
@EndOfDesignText@
Sub Class_Globals
	Private globalScreen As JavaObject
	Private mCallBack As Object 'ignore
	Private mEventName As String 'ignore
	Private listener As JavaObject
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Callback As Object, EventName As String)
	mCallBack = Callback
	mEventName = EventName
	globalScreen.InitializeStatic("com.github.kwhat.jnativehook.GlobalScreen")
	globalScreen.RunMethod("registerNativeHook",Null)
	Dim jo As JavaObject = Me
	listener = jo.RunMethod("newInstance",Null)
	globalScreen.RunMethod("addNativeKeyListener",Array(listener))
End Sub

Public Sub cleanup
	globalScreen.RunMethod("removeNativeKeyListener",Array(listener))
	globalScreen.RunMethod("unregisterNativeHook",Null)
End Sub

public Sub getKeyCode(e As JavaObject) As String
	Return e.RunMethod("getKeyCode",Null)
End Sub

private Sub nativeKeyPressed(e As Object)
	If SubExists(mCallBack,mEventName&"_NativeKeyPressed") Then
		CallSubDelayed2(mCallBack,mEventName&"_NativeKeyPressed",getKeyCode(e))
	End If
End Sub

private Sub nativeKeyTyped(e As Object)
	If SubExists(mCallBack,mEventName&"_NativeKeyTyped") Then
		CallSubDelayed2(mCallBack,mEventName&"_NativeKeyTyped",getKeyCode(e))
	End If
End Sub

private Sub nativeKeyReleased(e As Object)
	If SubExists(mCallBack,mEventName&"_NativeKeyReleased") Then
		CallSubDelayed2(mCallBack,mEventName&"_NativeKeyReleased",getKeyCode(e))
	End If
End Sub

#If Java
import com.github.kwhat.jnativehook.NativeHookException;
import com.github.kwhat.jnativehook.keyboard.NativeKeyEvent;
import com.github.kwhat.jnativehook.keyboard.NativeKeyListener;

public GlobalKeyListenerExample newInstance(){
    return new GlobalKeyListenerExample();
}

public class GlobalKeyListenerExample implements NativeKeyListener {
	public void nativeKeyPressed(NativeKeyEvent e) {
		if (ba.subExists("nativekeypressed")) {
	        ba.raiseEvent2(null, true, "nativekeypressed", false, e);
	    }
	}

	public void nativeKeyReleased(NativeKeyEvent e) {
		if (ba.subExists("nativekeyreleased")) {
	        ba.raiseEvent2(null, true, "nativekeyreleased", false, e);
	    }
	}

	public void nativeKeyTyped(NativeKeyEvent e) {
		//System.out.println("Key Typed: " + e.getKeyText(e.getKeyCode()));
		if (ba.subExists("nativekeytyped")) {
	        ba.raiseEvent2(null, true, "nativekeytyped", false, e);
	    }
	}
}
#End If