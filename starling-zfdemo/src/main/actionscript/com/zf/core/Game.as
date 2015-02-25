package com.zf.core
{
	import com.zf.loaders.AssetsLoader;
	import com.zf.managers.SharedObjectManager;
	import com.zf.states.GameLoad;
	import com.zf.states.GameOver;
	import com.zf.states.IState;
	import com.zf.states.MapLoad;
	import com.zf.states.MapSelect;
	import com.zf.states.Menu;
	import com.zf.states.Play;
	import com.zf.states.Test;
	import com.zf.states.Upgrades;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	import treefortress.sound.SoundManager;
	
	public class Game extends Sprite
	{
		public static const GAME_LOAD_STATE	: int = 0;
		public static const MENU_STATE		: int = 3;
		public static const MAP_LOAD_STATE	: int = 6;
		public static const MAP_SELECT_STATE: int = 9;
		public static const PLAY_STATE		: int = 12;
		public static const UPGRADES_STATE	: int = 15;
		public static const GAME_OVER_STATE : int = -1;

		public static const TEST_STATE : int = 99;
		
		public var currentState:IState;
		
		// All states need access to loading
		public static var assetsLoader:AssetsLoader = AssetsLoader.getInstance();
		public static var sharedObject:SharedObjectManager = SharedObjectManager.getInstance();
		
		// All states need access to sounds
		public static var soundMgr:SoundManager;
		
		public function Game() {
			super();
			soundMgr = new SoundManager();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			sharedObject.init();
			changeState(GAME_LOAD_STATE);
			_addUpdateListener();
		}
		
		/**
		 * Updates the current state
		 */
		private function update():void {
			currentState.update();
		}
		
		/**
		 * Adds update listener
		 */
		private function _addUpdateListener():void {
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		/**
		 * Removes update listener
		 */
		private function _removeUpdateListener():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		/**
		 * Changes state to the new state specified by state param
		 * 
		 * @param int state the state constant to change to
		 */
		public function changeState(state:int):void {
			Config.log('Game', 'changeState', 'Changing state to ' + state);
			var removed:Boolean = false;
			
			if(currentState != null) {
				_removeUpdateListener();
				currentState.destroy();
				removeChild(Sprite(currentState));
				currentState = null;
				removed = true;	
			}

			switch(state) {
				case GAME_LOAD_STATE:
					currentState = new GameLoad(this);
					break;
				
				case MENU_STATE:
					currentState = new Menu(this);
					break;
				
				case MAP_SELECT_STATE:
					currentState = new MapSelect(this);
					break;
				
				case MAP_LOAD_STATE:
					currentState = new MapLoad(this);
					break;
				
				case PLAY_STATE:
					currentState = new Play(this);
					break;
				
				case GAME_OVER_STATE:
					currentState = new GameOver(this);
					break;
				
				case UPGRADES_STATE:
					currentState = new Upgrades(this);
					break;
				
				case TEST_STATE:
					currentState = new Test(this);
					break;
			}

			addChild(Sprite(currentState));
			
			if(removed) {
				// Add update listeners back
				_addUpdateListener();
				removed = false;
			}
		}
	}
}