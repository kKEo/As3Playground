package com.zf.managers
{
	import com.zf.core.Config;
	import com.zf.states.Play;
	import com.zf.utils.KeyCode;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import org.osflash.signals.Signal;

	public class KeyboardManager
	{
		/**
		 * onPause will handle both Pause and Resume events by passing a Boolean value
		 * true - game is paused
		 * false - game is resumed
		 */
		public var onPause:Signal;
		
		private var _stage:Stage;
		private var _play:Play;
		private var _signals:Array = [];
		
		public function KeyboardManager(play:Play, stage:Stage) {
			_play = play;
			_stage = stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			// not going to use this now
			//_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyUp);
			
			onPause = new Signal();
			_signals.push(onPause);
		}
		
		protected function _onKeyDown(evt:KeyboardEvent):void {
			// Handle events the game uses
			switch(evt.keyCode) {
				case KeyCode.SPACE:
					handleOnPause();
					break;
				
				case KeyCode.PLUS:
				case KeyCode.ADD:
					changeGameSpeed(Config.GAME_SPEED_UP);
					break;
				
				case KeyCode.MINUS:
				case KeyCode.SUBTRACT:
					changeGameSpeed(Config.GAME_SPEED_DOWN);
					break;
			}
		}
		
		/**
		 * Handles when the pause button is pressed
		 */
		protected function handleOnPause():void {
			onPause.dispatch();
		}
		
		protected function changeGameSpeed(dir:String):void {
			Config.changeGameSpeed(dir);
		}
		
		
		public function destroy():void {
		}
	}
}