package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.ui.gameStateBkgd.GameStateBkgd;
	
	import feathers.controls.ScrollText;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GameOver extends Sprite implements IState
	{
		private var _game:Game;
		
		private var _tryAgainBtn:Button;
		private var _gameStateBkgd:GameStateBkgd;
		private var _gameStatsText:ScrollText;
		
		public function GameOver(g:Game)
		{
			_game = g;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_gameStateBkgd = new GameStateBkgd('Game Over');
			addChild(_gameStateBkgd);
			
			_tryAgainBtn = new Button(Assets.tryAgainBtnT);
			_tryAgainBtn.x = 500;
			_tryAgainBtn.y = 400;
			_tryAgainBtn.addEventListener(Event.TRIGGERED, _onTryAgainTriggered);
			addChild(_tryAgainBtn);
			
			_gameStatsText = new ScrollText();
			_gameStatsText.x = 100;
			_gameStatsText.y = 120;
			_gameStatsText.width = 300;
			_gameStatsText.height = 400;
			_gameStatsText.isHTML = true;
			addChild(_gameStatsText);
			var txt:String = Config.totals.toHtml();
			if(Config.totals.mapsWon) {
				txt += '<br><br><font color="#FFFFFF" size="20">*Gained 1 Upgrade Point*</font>';
			}
			_gameStatsText.text = txt;
		}
		
		public function update():void {

		}
		
		public function destroy():void {
			_gameStateBkgd.destroy();
			_gameStateBkgd = null;
						
			_tryAgainBtn.removeFromParent(true);
			_tryAgainBtn.removeEventListener(Event.TRIGGERED, _onTryAgainTriggered);
			_tryAgainBtn = null;
		}
		
		private function _onTryAgainTriggered(evt:Event):void {
			_game.changeState(Game.MAP_SELECT_STATE);
		}
	}
}