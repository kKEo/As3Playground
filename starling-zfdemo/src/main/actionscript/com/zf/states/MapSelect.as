package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.ui.gameStateBkgd.GameStateBkgd;
	import com.zf.ui.mapSelectIcon.MapSelectIcon;
	
	import feathers.controls.ScrollText;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;

	
	public class MapSelect extends Sprite implements IState
	{
		private var _game:Game;
		private var _gameStateBkgd:GameStateBkgd;
		
		private var _map1:MapSelectIcon;
		private var _map2:MapSelectIcon;
		
		private var _activeMapId:String;
		private var _activeMap:Object;
		private var _mapText:ScrollText;
		private var _gameStatsText:ScrollText;
		private var _upgradesBtn:Button;
		
		public function MapSelect(game:Game) {
			_game = game;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_gameStateBkgd = new GameStateBkgd('Wybierz mapę');
			addChild(_gameStateBkgd);
			
			_map1 = new MapSelectIcon(Assets.mapData.getMapById('map1'), 'misc/mapSelect_map1');
			_map1.x = 100;
			_map1.y = 120;
			_map1.onClick.add(onMapSelectClicked);
			_map1.onHover.add(onMapSelectHovered);
			addChild(_map1);
			
			_map2 = new MapSelectIcon(Assets.mapData.getMapById('map2'), 'misc/mapSelect_map2');
			_map2.x = 100;
			_map2.y = 300;
			_map2.onClick.add(onMapSelectClicked);
			_map2.onHover.add(onMapSelectHovered);
			addChild(_map2);
			
			_mapText = new ScrollText();
			_mapText.x = 95;
			_mapText.y = 475;
			_mapText.width = 400;
			_mapText.height = 200;
			_mapText.isHTML = true;
			addChild(_mapText);
			
			_gameStatsText = new ScrollText();
			_gameStatsText.x = 400;
			_gameStatsText.y = 120;
			_gameStatsText.width = 200;
			_gameStatsText.height = 400;
			_gameStatsText.isHTML = true;
			addChild(_gameStatsText);
			_gameStatsText.text = Config.currentGameSOData.toHtml();
			
			_upgradesBtn = new Button(Assets.upgradesBtnT);
			_upgradesBtn.x = 525;
			_upgradesBtn.y = 425;
			_upgradesBtn.addEventListener(Event.TRIGGERED, onUpgradesBtnClicked);
			addChild(_upgradesBtn);
		}
		
		private function onUpgradesBtnClicked(evt:Event):void {
			_game.changeState(Game.UPGRADES_STATE);
		}
		
		public function onMapSelectClicked(map:Object):void {
			Config.addGameAttempted();
			Config.selectedMap = map.id;
			_game.changeState(Game.MAP_LOAD_STATE);
		}
		
		public function onMapSelectHovered(map:Object):void {
			if(map.id != _activeMapId) {
				_activeMapId = map.id;
				_activeMap = map;
				_updateMapText();
			}
		}

		private function _updateMapText():void {
			var fontOpenTag:String = '<font color="#FFFFFF" size="22">';
			var fontCloseTag:String = '</font>';
			var txt:String = fontOpenTag + 'Map Title: ' + _activeMap.title + fontCloseTag + '<br>' + fontOpenTag + 'Desc: ' + _activeMap.desc + fontCloseTag; 
			_mapText.text = txt;
		}
		
		public function update():void {
			
		}

		public function destroy():void {
			_gameStateBkgd.destroy();
			_map1.destroy();
			_map2.destroy();
			
			_mapText.removeFromParent(true);
			_mapText = null;
			
			_gameStatsText.removeFromParent(true);
			_gameStatsText = null;
		}
	}
}