package  
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.FP;
	import quiero.Quiero;
	import quiero.RequestEvent;
	import GameSettings;
	
	
	/**
	 * ...
	 * @author Six
	 */
	public class MathWorld extends World
	{
		[Embed(source = 'images/MathBack.png')]
		private static const BACKGROUND_IMAGE:Class;
		private var backgroundSprite:Spritemap;	
		
		[Embed(source='images/Snail.png')]
		private static const SNAIL_IMAGE:Class;
		private var snailSprite:Spritemap;
		
		[Embed(source='images/Back.png')]
		private static const BACK_IMAGE:Class;
		
		[Embed(source='images/M.png')]
		private static const M_IMAGE:Class;	
		
		[Embed(source = 'images/GlobalPies.png')]
		private static const GLOBAL_IMAGE:Class;
		private var globalImage:Image;
		
		[Embed(source='images/Names.png')]
		private static const NAMES_IMAGE:Class;	
		private var namesImage:Image;
		
		[Embed(source = 'images/SixSided.png')]
		private static const SIX_IMAGE:Class;	
		private var sixImage:Image;
		private var sixButton:ClickableImage;
		
		[Embed(source='images/Mappum.png')]
		private static const MAPPUM_IMAGE:Class;	
		private var mappumImage:Image;
		private var mappumButton:ClickableImage;
		
		private var globalText:Text;
		private var refreshTimer:Number;
		private var refreshTimerMax:Number = 15; // update every 15 seconds
		
		public function MathWorld() 
		{
			// setup text, then query server
			globalText = new Text("RETREVING...", -18, 7);
			globalText.width = 72;
			globalText.size = 8;
			globalText.align = "right";
			if (GameSettings.lastServerQuerryTime == null || GameSettings.checkTimePassedSinceLastQuerry() > 10 * 1000) // first time
			{
				Quiero.request( { url:'http://eatapie.jit.su/pies', method:'get', onComplete:updateGlobalPieNumber, forceRefresh:true }, true, false );
				GameSettings.updateLastServerQuerryTime();
			}
			else
			{
				globalText.text = GameSettings.lastServerResponse;
			}
			
			refreshTimer = refreshTimerMax;
			
			backgroundSprite = new Spritemap(BACKGROUND_IMAGE, 80, 60);
			backgroundSprite.add("Idle", [0, 1, 2, 3], 6);
			backgroundSprite.play("Idle");
			
			snailSprite = new Spritemap(SNAIL_IMAGE, 6, 4);
			snailSprite.add("Idle", [0, 1], 0.8);
			snailSprite.play("Idle");
			
			globalImage = new Image(GLOBAL_IMAGE);
			namesImage = new Image(NAMES_IMAGE);
			
			sixImage = new Image(SIX_IMAGE);
			mappumImage = new Image(MAPPUM_IMAGE);
			
			globalImage.color = namesImage.color = globalText.color = 0x000000;
			
			sixImage.color = mappumImage.color = 0x0000C0;
			
			// background
			addGraphic(backgroundSprite);
			
			// snail
			addGraphic(snailSprite, 0, 46, 26);
			
			// global pie text
			addGraphic(globalText);
			
			// global pie number
			addGraphic(globalImage);
			
			// names text
			addGraphic(namesImage);
			
			// back button
			add(new ClickableImage(new Image(BACK_IMAGE), 1, 10, back));
			// volume button
			add(new ClickableImage(new Image(M_IMAGE), 9, 10, GameSettings.volumeToggle));
			
			// name links
			sixButton = new ClickableImage(sixImage, 39, 31, linkToSix, 1.0, 0.8, true);
			mappumButton = new ClickableImage(mappumImage, 42, 49, linkToMappum, 1.0, 0.8, true);
			add(sixButton);
			add(mappumButton);
			
			FP.stage.addEventListener(MouseEvent.CLICK, checkLinks);
		}
		
		private function checkLinks(e:Event):void
		{
			if (sixButton.hasMouseInside())
			{
				navigateToURL(new URLRequest("https://twitter.com/xiSided"), "_blank");
			}
			else if (mappumButton.hasMouseInside())
			{
				navigateToURL(new URLRequest("https://twitter.com/mappum"), "_blank");
			}
		}
		
		private function linkToSix():void
		{
			//set the desired URL here
			//var url_str:String = "https://twitter.com/xiSided"

			//GameSettings.ChangePage("https://twitter.com/xiSided");
		
			
		}
		
		private function linkToMappum():void
		{
			try {
				//navigateToURL(new URLRequest("https://twitter.com/mappum"), "_blank");
			} catch (e:Error) {
				trace("Error trying to reach url");
			}			
		}
		
		override public function update():void 
		{
			refreshTimer -= FP.elapsed;
			
			if (refreshTimer <= 0) // every refreshTimerMax seconds, update the pie count
			{
				globalText.text = "RETREVING...";
				
				Quiero.request( { url:'http://eatapie.jit.su/pies', method:'get', onComplete:updateGlobalPieNumber, forceRefresh:true }, true, false );
				GameSettings.updateLastServerQuerryTime();
				
				refreshTimer = refreshTimerMax;
			}
			
			super.update();
		}
		
		public function updateGlobalPieNumber(e:RequestEvent):void
		{
			globalText.text = "" + e.data;
			GameSettings.lastServerResponse = "" + e.data;
		}
		
		public function back():void
		{
			FP.world = new MenuWorld();
		}
	}

}