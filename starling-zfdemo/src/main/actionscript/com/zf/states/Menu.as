package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Game;
	import com.zf.ui.buttons.loadGameButton.LoadGameButton;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Menu extends Sprite implements IState
	{
		private var _game: Game;
		private var _bkgd: Image;
		private var _logo: Image;
		private var _playBtn: Button;
		private var _loadBtn: Button;
		private var _game1:LoadGameButton;
		private var _game2:LoadGameButton;
		private var _game3:LoadGameButton;
		
		public function Menu(g:Game) {
			_game = g;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_bkgd = new Image(Assets.bkgdT);
			addChild(_bkgd);
			
			_logo = new Image(Assets.logoT);
			_logo.x = 75;
			_logo.y = 75;
			addChild(_logo);

			_game1 = new LoadGameButton('Game 1', 'game1');
			_game1.x = 50;
			_game1.y = 450;
			_game1.onGameSelected.add(_onGameSelected);
			addChild(_game1);
			
			_game2 = new LoadGameButton('Gra 2', 'game2');
			_game2.x = 300;
			_game2.y = 450;
			_game2.onGameSelected.add(_onGameSelected);
			addChild(_game2);
			
			_game3 = new LoadGameButton('Game 3', 'game3');
			_game3.x = 525;
			_game3.y = 450;
			_game3.onGameSelected.add(_onGameSelected);
			addChild(_game3);
		}

		private function _onGameSelected():void {
			_game.changeState(Game.MAP_SELECT_STATE);
		}
		
		public function update():void {
		}
		
		public function destroy():void {
			_bkgd.removeFromParent(true);
			_bkgd = null;
			
			_logo.removeFromParent(true);
			_logo = null;

			_game1.removeFromParent(true);
			_game1.destroy();
			_game1 = null;
			
			_game2.removeFromParent(true);
			_game2.destroy();
			_game2 = null;
			
			_game3.removeFromParent(true);
			_game3.destroy();
			_game3 = null;
			
			removeFromParent(true);
		}
	}
}
