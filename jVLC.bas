B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private mediaPlayerFactory As JavaObject
	Private embeddedMediaPlayer As JavaObject
	Private jo As JavaObject = Me
	Private surface As JavaObject
	Private mStopped As Boolean = True
	Private mRate As Float = 1.0
	Private th As Thread
	Private mCallback As Object
	Private mEventName As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Callback As Object,EventName As String)
	mCallback = Callback
	mEventName = EventName
	th.Initialise("th")
	Dim meJo As JavaObject = Me
	meJo.RunMethod("setBAStatic",Array(meJo.GetField("ba")))
	meJo.RunMethod("setTarget",Array(meJo))
End Sub

Public Sub LoadAsync As ResumableSub
	th.Start(Me,"Load",Array())
	wait for th_Ended(endedOK As Boolean, error As String)
	return endedOK
End Sub

Sub ThrowError
	Dim i As Int
	i = "VLC initialization failed"
End Sub

Public Sub Load
	mediaPlayerFactory = jo.RunMethodJO("getMediaPlayerFactory",Null)
	embeddedMediaPlayer = jo.RunMethodJO("getMediaPlayer",Array(mediaPlayerFactory))
End Sub

Public Sub setImageView(iv As ImageView)
	surface = jo.RunMethod("setVideoSurface",Array(embeddedMediaPlayer,iv))
	embeddedMediaPlayer.RunMethodJO("videoSurface",Null).RunMethod("set",Array(surface))
End Sub

Public Sub setStopped(value As Boolean)
	mStopped = value
End Sub

Public Sub getStopped As Boolean
	Return mStopped
End Sub

Public Sub Release
	embeddedMediaPlayer.RunMethodJO("release",Null)
End Sub

Public Sub Pause
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("pause",Null)
End Sub

Public Sub setRate(value As Float)
	mRate = value
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("setRate",Array(value))
End Sub

Public Sub getRate As Float
	Return mRate
End Sub

Public Sub Stop
	mStopped = True
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("stop",Null)
End Sub

Public Sub Resume
	mStopped = False
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("play",Null)
End Sub

Public Sub vlc_paused
	If SubExists(mCallback,mEventName&"_Paused") Then
		CallSubDelayed(mCallback,mEventName&"_Paused")
	End If
End Sub

Public Sub SetTime(time As Long)
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("setTime",Array(time))
End Sub

Public Sub SetPosition(pos As Float)
	embeddedMediaPlayer.RunMethodJO("controls",Null).RunMethod("setPosition",Array(pos))
End Sub

Public Sub Play(mrl As String)
	mStopped = False
	jo.RunMethod("play",Array(embeddedMediaPlayer,mrl))
End Sub

Public Sub PlayWithOptions(mrl As String,options() As String)
	mStopped = False
	embeddedMediaPlayer.RunMethodJO("media",Null).RunMethod("play",Array(mrl,options))
End Sub

Public Sub SetMute(mute As Boolean)
	embeddedMediaPlayer.RunMethodJO("audio",Null).RunMethod("setMute",Array(mute))
End Sub

Public Sub SetVolume(Volume As Int)
	embeddedMediaPlayer.RunMethodJO("audio",Null).RunMethod("setVolume",Array(Volume))
End Sub

Public Sub GetVolume As Int
	Return embeddedMediaPlayer.RunMethodJO("audio",Null).RunMethod("volume",Null)
End Sub

Public Sub CanPause As Boolean
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("canPause",Null)
End Sub

Public Sub IsPlayable As Boolean
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("isPlayable",Null)
End Sub

Public Sub IsPlaying As Boolean
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("isPlaying",Null)
End Sub

Public Sub IsSeekable As Boolean
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("isSeekable",Null)
End Sub

Public Sub GetLength As Long
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("length",Null)
End Sub

Public Sub GetPosition As Float
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("position",Null)
End Sub

Public Sub GetTime As Float
	Return embeddedMediaPlayer.RunMethodJO("status",Null).RunMethod("time",Null)
End Sub

#if java
import anywheresoftware.b4a.keywords.Common;
import javafx.scene.image.ImageView;
import uk.co.caprica.vlcj.factory.MediaPlayerFactory;
import uk.co.caprica.vlcj.player.base.MediaPlayer;
import uk.co.caprica.vlcj.player.base.MediaPlayerEventAdapter;
import uk.co.caprica.vlcj.player.embedded.EmbeddedMediaPlayer;
import uk.co.caprica.vlcj.javafx.videosurface.ImageViewVideoSurface;

//to void jna objects from being garbage collected
public static ImageViewVideoSurface surface;
public static MediaPlayerFactory factory;
public static EmbeddedMediaPlayer embeddedMediaPlayer;

public static BA baStatic;
public static jvlc target;

public static void setBAStatic(BA ba) {
    baStatic = ba;
}

public static void setTarget(jvlc t) {
    target = t;
}

public static ImageViewVideoSurface setVideoSurface(EmbeddedMediaPlayer embeddedMediaPlayer,ImageView videoImageView) {
    surface = new ImageViewVideoSurface(videoImageView);
    embeddedMediaPlayer.videoSurface().set(surface);
	return surface;
}

public static MediaPlayerFactory getMediaPlayerFactory(){
    factory = new MediaPlayerFactory();
    return factory;
}

public static EmbeddedMediaPlayer getMediaPlayer(MediaPlayerFactory factory){
    embeddedMediaPlayer = factory.mediaPlayers().newEmbeddedMediaPlayer();
	embeddedMediaPlayer.events().addMediaPlayerEventListener(new MediaPlayerEventAdapter() {
        @Override
		public void mediaPlayerReady​(MediaPlayer mediaPlayer) {
		    
		}
		@Override
		public void opening​(MediaPlayer mediaPlayer) {

		}
		
		@Override
        public void playing(MediaPlayer mediaPlayer) {

        }

        @Override
        public void paused(MediaPlayer mediaPlayer) {
		    if (baStatic != null) {
			    baStatic.raiseEvent(target, "vlc_paused", new Object[] {});
			}
        }

        @Override
        public void stopped(MediaPlayer mediaPlayer) {

        }

        @Override
        public void timeChanged(MediaPlayer mediaPlayer, long newTime) {

        }
    });
	return embeddedMediaPlayer;
}

public static void play(EmbeddedMediaPlayer embeddedMediaPlayer, String mrl){
    embeddedMediaPlayer.media().play(mrl);
}
#End If