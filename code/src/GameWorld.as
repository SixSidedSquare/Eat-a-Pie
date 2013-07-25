package  
{
	import quiero.Quiero;
	import quiero.RequestEvent;
	import flash.events.Event;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.FP;
	import GameSettings;
	
	/**
	 * ...
	 * @author Six
	 */
	public class GameWorld extends World
	{
		[Embed(source='images/Back.png')]
		private static const BACK_IMAGE:Class;
		
		[Embed(source='images/M.png')]
		private static const M_IMAGE:Class;			
		
		[Embed(source = 'images/InstructionText.png')]
		private static const INSTRUCTION_IMAGE:Class;
		private var instructionSprite:Spritemap;
		
		private var instructionTimerMax:Number = 5;
		private var instructionTimer:Number = 5;;
		
		[Embed(source='images/Bodies.png')]
		private static const BODY_IMAGE:Class;
		private var bodySprite:Spritemap;
		
		[Embed(source='images/Face.png')]
		private static const FACE_IMAGE:Class;
		private var faceSprite:Spritemap;
		
		[Embed(source='images/Arms.png')]
		private static const ARM_IMAGE:Class;
		private var armSprite:Spritemap;
		
		[Embed(source = 'images/Pies.png')]
		private static const PIE_IMAGE:Class;
		private var pieSprite:Spritemap;
		
		[Embed(source='images/Table.png')]
		private static const TABLE_IMAGE:Class;
		
		[Embed(source = 'images/GameBackground.png')]
		private static const BACKGROUND_IMAGE:Class;
		
		
		private var chewTimeMax:Number = 2;
		private var chewTimer:Number = 0;
		
		private var chewWobbleTimeMax:Number = 0.2;
		private var chewWobbleTimer:Number = 0;
		
		private var chewing:Boolean = false;
		
		private var messyFace:FaceMess;
		private var messChance:Number = 0.3;
		
		private var pieScore:Number = 0;
		private var scoreText:Text;
		
		private var firstPie:Boolean = true;
		private var pieReady:Boolean = false;
		private var pieEaten:Boolean = true;
		private var bitesLeft:Number;
		
		// list of pie sprite index possibilities
		private var possiblePieEatingFrames:Vector.<Array>;
		private var pieEatingFrames:Array;
		
		
		// server comunication stuff
		private var newPiesForServer:Number = 0;
		private var numberOfPiesToSendOn:Number = 20;
		private var numberOfSecondsToSendOn:Number = 30;
		private var serverPieSendtimer:Number = numberOfSecondsToSendOn;

		public function GameWorld() 
		{
			GameSettings.muteLead();
						
			instructionSprite = new Spritemap(INSTRUCTION_IMAGE, 80, 60);
			instructionSprite.visible = false;
			bodySprite = new Spritemap(BODY_IMAGE, 80, 60);
			faceSprite = new Spritemap(FACE_IMAGE, 80, 60);
			armSprite = new Spritemap(ARM_IMAGE, 80, 60);
			
			pieSprite = new Spritemap(PIE_IMAGE, 80, 60);
			pieSprite.add("FirstPie", [0, 1, 2, 3, 4, 5], 20, false); 
			pieSprite.add("NewPie", [6, 7, 8, 9, 10, 5], 20, false);
			
			// set the callback for the pie animation ending, to allow more eating
			pieSprite.callback = pieDoneAnimating;
			
			possiblePieEatingFrames = new Vector.<Array>;
			possiblePieEatingFrames.push([12, 11]);
			possiblePieEatingFrames.push([13]);
			
			messyFace = new FaceMess();
			
			scoreText = new Text("" + pieScore, 4, 0);
			scoreText.width = 72;
			scoreText.size = 8;
			scoreText.align = "right";
			
			
			// order of layers from back to front:
			// wall -> (piedishes backing) -> body -> table -> pie dish -> crust -> (face mess) -> face -> arm
			// wall
			addGraphic(new Backdrop(BACKGROUND_IMAGE));
			
			// dishes
			
			
			// body
			addGraphic(bodySprite);
			
			// table			
			addGraphic(new Image(TABLE_IMAGE));
			
			// pies
			addGraphic(pieSprite);
			
			// face mess
			add(messyFace);
			
			// face
			addGraphic(faceSprite);
			
			// arm
			addGraphic(armSprite);
			
			// score
			addGraphic(scoreText);
			
			// text
			addGraphic(instructionSprite);
			
			// back button
			add(new ClickableImage(new Image(BACK_IMAGE), 1, 1, back));
			// volume button
			add(new ClickableImage(new Image(M_IMAGE), 9, 1, GameSettings.volumeToggle));
		}
		
		public function back():void
		{
			FP.world = new MenuWorld();
		}
		
		override public function update():void
		{
			super.update();
			
			if (Input.check(Key.Z))
			{
				//check if the pie is eaten, and a new pie is needed
				if (pieEaten)
				{
					pieEaten = false;
					pieReady = false;
					
					// if first pie, play first animation, otherwise play the replacing one
					if (firstPie)
					{
						firstPie = false;
						pieSprite.play("FirstPie");
					}
					else
					{
						pieSprite.play("NewPie");
					}
					
					instructionTimer = instructionTimerMax;
					instructionSprite.visible = false;
				}
			}
			else if (Input.check(Key.X))
			{
				// if still chewing, and the pie is not all eaten, add mess
				if (chewing && !pieEaten)
				{
					// only add it some times
					if (FP.random < messChance)
					{
						messyFace.addMess();
					}
				}
				
				armSprite.frame = 1;
				
				// if pie is avalible set up to start eating it
				if (pieReady)
				{
					chewTimer = chewTimeMax;
					chewWobbleTimer = 0;
					
					instructionTimer = instructionTimerMax;
					instructionSprite.visible = false;
				}
				
				chewing = false;
			}
			else if (chewTimer > 0)
			{
				if (!chewing && !pieEaten)
				{
					chewing = true;
					
					// decrease current pie size, check if pie is done
					bitesLeft--;
					
					if (bitesLeft == 0)
					{
						pieSprite.frame = 6;
						pieEaten = true;
						pieReady = false;
						
						pieScore++;
						newPiesForServer++;
						scoreText.text = "" + pieScore;
						
						// check for nunmbers to increase body frame
						if (pieScore == 10) // 10
						{
							bodySprite.frame = 1;
						}
						else if (pieScore <= 100 && pieScore % 25 == 0) // 25, 50, 75, 100
						{
							bodySprite.frame = pieScore / 25 + 1;
						}
						else if (pieScore % 50 == 0) // starts at 150
						{
							bodySprite.frame = pieScore / 50 + 3;
							if (bodySprite.frame >= bodySprite.frameCount)
								bodySprite.frame = bodySprite.frameCount - 1;
						}
					}
					else if (bitesLeft > 0)
					{
						// if pie is not all eaten, go to the next frame
						pieSprite.frame = pieEatingFrames[bitesLeft-1];
					}
				}
				
				// wobble the hand and face sprite frames
				if (chewWobbleTimer <= 0)
				{
					armSprite.frame = (armSprite.frame == 2) ? 3 : 2;
					faceSprite.frame = (faceSprite.frame == 1) ? 0 : 1;
					chewWobbleTimer = FP.random * 0.2 + 0.05;
				}
				else
					chewWobbleTimer -= FP.elapsed
				
				// lower chew timer
				chewTimer -= FP.elapsed;
			}
			else
			{
				armSprite.frame = 0;
				chewing = false;
				
				if (!instructionSprite.visible && instructionTimer <= 0)
				{
					//set frame based on if the pie is eaten or not
					if (pieEaten)
					{
						instructionSprite.frame = 0;
					}
					else
					{
						instructionSprite.frame = 1;
					}
					instructionSprite.visible = true;
				}
				else if (instructionTimer > 0)
					instructionTimer -= FP.elapsed;
				
			}
			
			// finally check for server sending update
			dealWithServerUpdate();
		}
		
		private function pieDoneAnimating():void
		{
			pieEaten = false;
			pieReady = true;
			
			// set up how many bites it will take to empty the pie, and what frames to use
			pieEatingFrames = possiblePieEatingFrames[FP.rand(possiblePieEatingFrames.length)];
			bitesLeft = pieEatingFrames.length + 1;
			
		}
		
		private function dealWithServerUpdate():void
		{
			// if number of pies to send if over the limit, or of timer has expired, send those suckers on
			if (newPiesForServer >= numberOfPiesToSendOn || serverPieSendtimer <= 0)
			{
				sendServerPieUpdate();
			}
			
			serverPieSendtimer -= FP.elapsed;
		}
		
		private function sendServerPieUpdate():void
		{
			trace("Checking update..");
			if (newPiesForServer > 0)
			{
				// send the new pies to the server
				trace("Sending " + newPiesForServer + " pies.");
				try {
					Quiero.request( { url:'http://eatapie.jit.su/pies', method:'post', data: { value:newPiesForServer } } );
				} catch (error:Error) {
					trace("Ruh roh! Server comunication went wrong");
				}
				
				//Quiero.request( { url:'http://eatapie.jit.su/pies', method:'get', onComplete:traceServerResponse, forceRefresh:true }, true, false );
				
				
				// reset all the numbers
				newPiesForServer = 0;
			}
			
			serverPieSendtimer = numberOfSecondsToSendOn;
		}
		
		private function traceServerResponse(e:RequestEvent):void {
			trace(e.data);		
		}
		
		override public function end():void 
		{
			sendServerPieUpdate();
			
			super.end();
		}
		
	}

}