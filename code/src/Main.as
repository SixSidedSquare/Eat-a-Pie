package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author Six
	 */
	public class Main extends Engine 
	{
		
		public function Main():void 
		{
			super(80, 60, 60);
			FP.world = new MenuWorld();
			FP.screen.scale = 8;
			//FP.console.enable();
			
		}
		
	}	
}