package  
{
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author Six
	 */
	public class ClickableImage extends Entity
	{
		private var image:Image;
		
		private var clickFunction:Function;
		
		private var hoverOffOpacity:Number = 0.4;
		private var hoverOnOpacity:Number = 1.0;
		
		private var linkMode:Boolean = false;
		
		private var currentlyHovering:Boolean = false;
		
		public function ClickableImage(graphicImage:Image, xPos:Number, yPos:Number, clickFunctionIn:Function, onHover:Number = 1.0, offHover:Number = 0.4, linkModeOn:Boolean = false ) 
		{
			hoverOnOpacity = onHover;
			hoverOffOpacity = offHover;
			linkMode = linkModeOn;
			
			image = graphicImage;
			width = image.width;
			height = image.height;
			
			image.alpha = hoverOffOpacity;
			
			clickFunction = clickFunctionIn;
			
			
			
			super(xPos, yPos, image);
		}
		
		override public function update():void 
		{
			// check if mouse is over the entity
			if (!currentlyHovering && collidePoint(x, y, Input.mouseX, Input.mouseY))
			{
				// now entered, so hovering
				currentlyHovering = true;
				
				// if link mode, turn cursor inro a hand
				if (linkMode)
					Mouse.cursor = MouseCursor.BUTTON;
				
				image.alpha = hoverOnOpacity;
			}
			else if (currentlyHovering && !collidePoint(x, y, Input.mouseX, Input.mouseY)) //only check for exit while inside
			{
				// exited
				currentlyHovering = false;
				
				image.alpha = hoverOffOpacity;
				
				if (linkMode)
					Mouse.cursor = MouseCursor.ARROW;
			}	
			
			// check for click
			if (Input.mousePressed && currentlyHovering)
			{
				clickFunction();
			}
			
			super.update();
		}
		
		public function hasMouseInside():Boolean
		{
			return currentlyHovering;
		}
		
	}

}