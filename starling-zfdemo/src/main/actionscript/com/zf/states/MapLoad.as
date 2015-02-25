package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.loaders.CallBackObject;
	import com.zf.ui.gameStateBkgd.GameStateBkgd;
	import com.zf.ui.ProgressBar;
	import com.zf.utils.Utils;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class MapLoad extends Sprite implements IState
	{
		private var _game: Game;
		private var _progBar:ProgressBar;
		private var loadBkgdI:Image;
		private var _playBtn:Button;
		private var _title:TextField;
		private var _gameStateBkgd:GameStateBkgd;
		
		public function MapLoad(game:Game)
		{
			_game = game;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_gameStateBkgd = new GameStateBkgd('Loading...');
			addChild(_gameStateBkgd);
			
			_progBar = new ProgressBar(500, 35);
			_progBar.x = 150;
			_progBar.y = 400;
			addChild(_progBar);
			
			_playBtn = new Button(Assets.playMapBtnT);
			_playBtn.pivotX = _playBtn.width >> 1;
			_playBtn.x = 400;
			_playBtn.y = 450;
			_playBtn.alpha = 0.2;
			addChild(_playBtn);
			
			Game.assetsLoader.onProgress.add(onProgress);
			Game.assetsLoader.onComplete.add(onLoadComplete);
			
			// Load the map data
			var map:String = Config.PATH_JSON + 'maps/' + Config.selectedMap + '.json';
			Game.assetsLoader.addToLoad(map, handleMapData, Config.selectedMap, false);
		}
		
		private function _onPlayMapTriggered(evt:Event):void {
			_game.changeState(Game.PLAY_STATE);
		}
		
		public function onProgress(ratio:Number):void {
			Config.log('MapLoad', 'onProgress', "LOADING :: " + ratio * 100);
			_progBar.ratio = ratio;
		}
		
		public function onLoadComplete():void {
			Game.assetsLoader.onProgress.remove(onProgress);
			Game.assetsLoader.onComplete.remove(onLoadComplete);
			Config.log('GameLoad', 'onLoadComplete', "MapLoad Complete");
			
			_playBtn.alpha = 1;
			_playBtn.addEventListener(Event.TRIGGERED, _onPlayMapTriggered);
		}
		
		public function handleMapData(cbo:CallBackObject):void {
			Config.currentMapData = Utils.JSONDecode(cbo.data);
		}
		
		public function update():void {
		}
		
		public function destroy():void {
			_gameStateBkgd.destroy();
			_gameStateBkgd = null;
			
			_progBar.removeFromParent(true);
			_progBar = null;
			
			_playBtn.removeEventListener(Event.TRIGGERED, _onPlayMapTriggered);
			_playBtn.removeFromParent(true);
			_playBtn = null;
		}
	}
}
