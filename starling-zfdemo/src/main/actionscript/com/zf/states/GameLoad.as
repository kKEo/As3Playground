package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.ui.ProgressBar;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GameLoad extends Sprite implements IState {
		private var _game: Game;
		private var _progBar:ProgressBar;
		
		public function GameLoad(game:Game) {
			_game = game;
//			Game.so.dev_WipeAllMem();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_progBar = new ProgressBar(500, 35);
			_progBar.x = 150;
			_progBar.y = 400;
			addChild(_progBar);
			
			Game.assetsLoader.onProgress.add(onProgress);
			Assets.onInitialLoadComplete.add(onLoadComplete);
			
			Assets.loadInitialAssets();
		}
		
		public function onProgress(ratio:Number):void {
			Config.log('GameLoad', 'onProgress', "LOADING :: " + ratio * 100);
			_progBar.ratio = ratio;
		}
		
		public function onLoadComplete():void {
			Game.assetsLoader.onProgress.remove(onProgress);
			Assets.onInitialLoadComplete.remove(onLoadComplete);
			
			Assets.init();
			_progBar.removeFromParent(true);
			_progBar = null;
			
			_game.changeState(Game.MENU_STATE);
			
			//_game.changeState(Game.TEST_STATE);
			
			//_game.changeState(Game.UPGRADES_STATE);
		}
		
		public function update():void {
		}
		
		public function destroy():void {
		}
	}
}