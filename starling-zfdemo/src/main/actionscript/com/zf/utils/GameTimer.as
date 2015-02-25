package com.zf.utils
{
	import flash.utils.Timer;
	
	public class GameTimer extends Timer
	{
		public var name				: String;
		public var paused 			: Boolean = false; 
		
		private var _initialCount	: int;
		private var _startTime 		: Number;
		private var _initialDelay 	: Number;
		private var _delay			: Number;
		private var _timerCount		: int;
		
		public function GameTimer(name:String, delay:Number, repeatCount:int=0) {
			super(delay, repeatCount);
			name = name;
			_initialDelay = delay;  
			_initialCount = repeatCount;
			
		}
		
		override public function reset():void  {
			super.reset();
			start();
		}
		
		override public function start() : void  {  
			if(currentCount < repeatCount)  {  
				paused = false;  
				_startTime = new Date().time;  
				super.start();  
			}  
		}  
		
		public function pause() : void {  
			if(running)  {  
				paused = true;  
				stop();  
				_delay = _delay - (new Date().time - _startTime);  
			}  
		}   
	}
}