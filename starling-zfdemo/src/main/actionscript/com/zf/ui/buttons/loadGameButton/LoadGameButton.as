package com.zf.ui.buttons.loadGameButton
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.utils.ZFGameData;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class LoadGameButton extends Sprite
	{
		public var onGameSelected:Signal;
		
		private var _gameNameTF:TextField;
		private var _gameName:String;
		private var _gameId:String;
		private var _gameData:ZFGameData;
		private var _texture:Texture;
		private var _gameExists:Boolean;
		private var _loadGameBtn:Button;
		private var _deleteGameBtn:Button;
		
		public function LoadGameButton(gameName:String, gameId:String)  {
			_gameName = gameName;
			_gameId = gameId;
			
			var o:Object = Game.sharedObject.getGameData(_gameId);
			_gameExists = !_isEmptyGameDataObject(o);
			
			if(_gameExists) {
				_gameData = ZFGameData.fromObject(o);
				_texture = Assets.loadGameBtnT;
			} else {
				_texture = Assets.newGameBtnT;
			}

			onGameSelected = new Signal();
			
			_loadGameBtn = new Button(_texture);
			_loadGameBtn.addEventListener(Event.TRIGGERED, _onClick);
			addChild(_loadGameBtn);
			
			_gameNameTF = new TextField(150, 30, _gameName, 'Wizzta', 40, 0xFFFFFF);
			_gameNameTF.y = -40;
			addChild(_gameNameTF);
			
			if(_gameExists) {
				_addDeleteGameBtn();
			}
		}
		
		/**
		 * Sets the currentGameSOID to _gameId and sets data or creates game data
		 */
		public function setCurrentGameData():void {
			Config.currentGameSOID = _gameId;
			if(_gameExists) {
				Config.currentGameSOData = _gameData;
			} else {
				Game.sharedObject.createGameData(Config.currentGameSOID, true);
			}
		}
		
		/**
		 * Destroys the component
		 */
		public function destroy():void {
			_gameNameTF.removeFromParent(true);
			_gameNameTF = null;
			_loadGameBtn.removeEventListener(Event.TRIGGERED, _onClick);
			onGameSelected.removeAll();
			
			if(_deleteGameBtn) {
				_removeDeleteGameBtn();
			}
		}
		
		/**
		 * Adds the delete game button to the component
		 */
		private function _addDeleteGameBtn():void {
			_deleteGameBtn = new Button(Assets.deleteGameBtnT);
			_deleteGameBtn.x = 130;
			_deleteGameBtn.y = 105;
			addChild(_deleteGameBtn);
			_deleteGameBtn.addEventListener(Event.TRIGGERED, _onDeleteGameBtnClicked);
		}
		
		/**
		 * Removes the delete game button from the component
		 */
		private function _removeDeleteGameBtn():void {
			_deleteGameBtn.removeFromParent(true);
			_deleteGameBtn.removeEventListener(Event.TRIGGERED, _onDeleteGameBtnClicked);
			_deleteGameBtn = null;
		}
		
		/**
		 * Handles when the deleteGameBtn is clicked
		 * 
		 * @param Event evt the Starling TRIGGERED event
		 */
		private function _onDeleteGameBtnClicked(evt:Event):void {
			Game.sharedObject.createGameData(_gameId, true);
			_removeDeleteGameBtn();
			_loadGameBtn.removeFromParent(true);
			_loadGameBtn.removeEventListener(Event.TRIGGERED, _onClick);
			_loadGameBtn = new Button(Assets.newGameBtnT);
			addChild(_loadGameBtn);
			_loadGameBtn.addEventListener(Event.TRIGGERED, _onClick);
		}
		
		/**
		 * Handles when the loadGameBtn is clicked
		 * 
		 * @param Event evt the Starling TRIGGERED event
		 */
		private function _onClick(evt:Event):void {
			setCurrentGameData();
			onGameSelected.dispatch();
		}
		
		/**
		 * Helper function to see if an Object is empty or if game data exists
		 */
		private function _isEmptyGameDataObject(obj:Object):Boolean {
			var isEmpty:Boolean=true;
			
			for (var s:String in obj) {
				isEmpty = false;
				break;
			}
			
			// If the object has data, see if it has Relevant data
			if(!isEmpty && obj.mapsAttempted == 0) {
				isEmpty = true;
			}
			return isEmpty;
		}
	}
}