package  
{
	
	import net.flashpunk.Sfx;
	import net.flashpunk.FP;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author Six
	 */
	public class GameSettings
	{
		
		// music
		[Embed(source='sounds/bass.mp3')]
		private static const BASS_SRC:Class;		
		private static var musicBass:Sfx;	
		
		[Embed(source='sounds/lead.mp3')]
		private static const LEAD_SRC:Class;		
		private static var musicLead:Sfx;	
		private static var leadMuted:Boolean = false;
		
		public static var lastServerQuerryTime:Date;
		public static var lastServerResponse:String = "Retreving..";
		
		public static function updateLastServerQuerryTime():void
		{
			lastServerQuerryTime = new Date();
		}
		
		public static function checkTimePassedSinceLastQuerry():Number
		{
			return new Date().valueOf() - lastServerQuerryTime.valueOf();
		}
		
		public static function initMusic():void
		{
			if (musicBass == null)
			{
				musicBass = new Sfx(BASS_SRC);
				musicBass.volume = 0.5;
				musicBass.complete = loopMusic;
				
				
				musicLead = new Sfx(LEAD_SRC);
				musicLead.volume = 0.5;
				
			}
		}
		
		public static function startMusic():void
		{
			if (!musicBass.playing)
			{
				musicBass.play(0.5);
				musicLead.play(0.5);
			}
		}
		
		public static function loopMusic():void
		{
			musicBass.play(musicBass.volume);
			musicLead.play(musicLead.volume);
		}
		
		public static function muteLead():void
		{
			leadMuted = true;
			musicLead.volume = 0;
		}
		
		public static function unmuteLead():void
		{
			leadMuted = false;
			musicLead.volume = musicBass.volume;			
		}
		
		public static function volumeToggle():void
		{
			if (musicBass != null)
			{
				if (musicBass.volume > 0)
				{
					if (!leadMuted)
						musicLead.volume -= 0.2;
					musicBass.volume -= 0.2;
				}
				else
				{
					if (!leadMuted)
						musicLead.volume = 0.5;
					musicBass.volume = 0.5;
				}
			}
		}
		
		public static function ChangePage(url:*, window:String = "_blank"):void {
			var req:URLRequest = url is String ? new URLRequest(url) : url;
			if (!ExternalInterface.available) {
				navigateToURL(req, window);
			} else {
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					ExternalInterface.call("window.open", req.url, window);
				} else {
					navigateToURL(req, window);
				}
			}
		}
	}

}