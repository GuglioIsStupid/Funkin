package;

import flixel.FlxG;
import flixel.FlxState;
import openfl.events.Event;
import openfl.media.Video;
import openfl.net.NetStream;
import vlc.VlcBitmap;

class VideoHandler {
    public static var video:Video;
    public static var netStream:NetStream;
    public static var vlcBitmap:VlcBitmap;
    public static var finishCallback:FlxState;
    public var onComplete:Void->Void;

    public function new()
    {
        FlxG.autoPause = false;

        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

    }

    public function playVideo(path:String, ?isFullscreen:Bool = false):Void
    {
        vlcBitmap = new VlcBitmap();
        vlcBitmap.set_height(FlxG.height);
        vlcBitmap.set_width(FlxG.width);

        vlcBitmap.onVideoReady = onVLCVideoReady;
        vlcBitmap.onComplete = onVLCComplete;
        vlcBitmap.onError = onVLCErr;

        FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

        vlcBitmap.repeat = 0;

        vlcBitmap.inWindow = false; // we don't want the video to be a separate window ☠️

        FlxG.addChildBelowMouse(vlcBitmap);
        vlcBitmap.play(checkFile(path));
    }

    function checkFile(path:String):String
    {
        var dir = "";
        var appDir = "file:///" + Sys.getCwd() + "/";
    
        if (path.indexOf(":") == -1) // Not a path
            dir = appDir;
        else if (path.indexOf("file://") == -1 || path.indexOf("http") == -1)
            dir = "file:///";
    
        return dir + path;
    }


    function onVLCVideoReady() {
        trace("Video loadedd!!!!!!");
    }

    public function onVLCComplete() {
        vlcBitmap.stop();

        vlcBitmap.dispose();

        if (FlxG.game.contains(vlcBitmap))
            FlxG.game.removeChild(vlcBitmap);

        // do func
        if (onComplete != null)
            onComplete();
    }

    function onVLCErr() {
        trace("Video error!!!!!! what da fukk!!!!!");

        if (onComplete != null)
            onComplete();
    }

    public function update(e:Event)
    {
        vlcBitmap.volume = FlxG.sound.volume;
    }

    private function client_onMetaData(path)
    {
        video.attachNetStream(netStream);
    
        video.width = FlxG.width;
        video.height = FlxG.height;
        // video.
    }
    
    private function netConnection_onNetStatus(path):Void
    {
        if (path.info.code == 'NetStream.Play.Complete')
        {
            finishVideo();
        }
    }

    function finishVideo()
    {
        netStream.dispose();

        if (FlxG.game.contains(video))
            FlxG.game.removeChild(video);

        if (onComplete != null)
            onComplete();
    }

}