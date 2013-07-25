package  
{
	import net.flashpunk.Entity;
	import flash.display.BitmapData;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author Six
	 */
	public class FaceMess extends Entity
	{
		private var graphicBitmap:BitmapData;
		private var graphicImage:Image;
		private var colour:Number;
		private var xOffset:Number;
		private var yOffset:Number;
		
		public function FaceMess() 
		{
			graphicBitmap = new BitmapData(80, 60, true, 0x00FFFFFF);
			graphicImage = new Image(graphicBitmap);
			graphic = graphicImage;
			
			super();
		}
		
		public function addMess(atX:Number = 33, atY:Number = 29, radius:Number = 13):void
		{
			
			colour = FP.choose(0xFFE35503, 0xFFF6FEBA);
			xOffset = normalRandom(atX - radius, atX + radius - 2);
			yOffset = normalRandom(atY - radius, atY + radius);
			graphicBitmap.setPixel32(xOffset, yOffset, colour);
			
			graphicImage.updateBuffer();
		}
		
		private function normalRandom(min:Number, max:Number):Number
		{
			return ((FP.random + FP.random + FP.random + FP.random + FP.random) / 5) * (max - min) + min;
		}
		
	}

}