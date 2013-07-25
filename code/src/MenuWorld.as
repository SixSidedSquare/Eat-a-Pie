package  
{
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import GameSettings;
	
	/**
	 * ...
	 * @author Six
	 */
	public class MenuWorld extends World
	{
		[Embed(source = 'images/Menu.png')]
		private static const BACKGROUND_IMAGE:Class;
		private var backgroundSprite:Spritemap;	
		
		[Embed(source='images/Start.png')]
		private static const START_IMAGE:Class;	
		
		[Embed(source='images/Math.png')]
		private static const MATH_IMAGE:Class;	
		
		[Embed(source='images/M.png')]
		private static const M_IMAGE:Class;			
		
		
		public function MenuWorld() 
		{
			
			backgroundSprite = new Spritemap(BACKGROUND_IMAGE, 80, 60);
			backgroundSprite.add("Idle", [0, 1], 0.7);
			backgroundSprite.play("Idle");
			
			addGraphic(backgroundSprite);
			
			add(new ClickableImage(new Image(START_IMAGE), 2, 40, start));
			add(new ClickableImage(new Image(MATH_IMAGE), 3, 49, math));	
			add(new ClickableImage(new Image(M_IMAGE), 2, 1, GameSettings.volumeToggle));
			
			GameSettings.initMusic();
			GameSettings.unmuteLead();
			
		}
		
		override public function begin():void 
		{
			//if (FP.focused)
			//	GameSettings.startMusic();
			
			super.begin();
		}
		
		override public function focusGained():void 
		{
			GameSettings.startMusic();
			
			super.focusGained();
		}
		
		public function start():void
		{
			FP.world = new GameWorld();
		}
		
		public function math():void
		{
			FP.world = new MathWorld();
		}
		
	}

}