package com.zf.managers
{
	import com.zf.core.Config;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.tower.Tower;
	import com.zf.states.Play;
	
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class TowerManager implements IZFManager
	{
		public var play:Play;
		public var onTowerRemoved:Signal;
		public var onTowerAdded:Signal;
		public var onTowerManagerRemovingEnemy:Signal;
		
		private var _towers:Array;
		private var _towerData:Object;
		private var _currentTower:Tower;
		private var _p:Point = new Point();
		private var _isDragging:Boolean = false;
		private var _canvas:Sprite;
		
		public function TowerManager(playState:Play, towerData:Object)
		{
			play = playState;
			_canvas = play.towerLayer;
			_towers = [];
			_setTowerData(towerData);
			
			onTowerAdded = new Signal(Tower);
			onTowerRemoved = new Signal(Tower);
			onTowerManagerRemovingEnemy = new Signal(Enemy);
		}
		
		public function update():void
		{
			if(_towers.length > 0) {
				var t:Tower;
				var len:int = _towers.length;
				for(var i:int = len - 1; i >= 0; i--) {
					t = _towers[i];
					t.update();
				}
			}
		}
		
		public function destroy():void {
		}
		
		public function destroyTower(t:Tower):void {
			var len:int = _towers.length;
			for(var i:int = 0; i < len; i++) {
				if(t == _towers[i]) {
					_towers.splice(i, 1);
					t.destroy();
					t.removeFromParent(true);
				}
			}
			
			onTowerRemoved.dispatch(t);
		}
		
		public function createNewTower(towerID:String, pos:Point):void
		{
			if(_currentTower) {
				_currentTower.deactivate();
			}
			
			var tower:Tower = new Tower(_towerData[towerID], this);
			tower.setSoundData(_towerData[towerID].sounds);
			tower.x = pos.x - tower.halfWidth;
			tower.y = pos.y - tower.halfHeight;
			tower.activated = true;
			_currentTower = tower;
			
			play.addChild(tower);
			play.addEventListener(TouchEvent.TOUCH, towerFollowMouse);
		}
		
		public function towerFollowMouse(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(play);
			if(touch)
			{
				switch(touch.phase) {
					case TouchPhase.BEGAN:
						if(_isDragging) {
							var checkObject:Object = play.map.checkCanPlaceTower(_p);
							if(checkObject.canPlace) {
								// remove the touch listener so it doesnt fire again during placeTower
								play.removeEventListener(TouchEvent.TOUCH, towerFollowMouse);
								// stop the event from leaving this function
								evt.stopImmediatePropagation();
								// place the tower
								placeTower(checkObject.point);
								_isDragging = false;
							}
						} else {
							_isDragging = true;
						}
						break;
					
					case TouchPhase.ENDED:
						break;
					
					case TouchPhase.MOVED:
						//trace("touch MOVED");
						break;
					
					case TouchPhase.HOVER:
						var tPos:Point = touch.getLocation(play);
						_currentTower.x = _p.x = tPos.x - _currentTower.halfWidth;
						_currentTower.y = _p.y = tPos.y - _currentTower.halfHeight;
						
						// Check if we can place, then update the tower image accordingly
						_currentTower.enterFrameTowerPlaceCheck(play.map.checkCanPlaceTower(_p).canPlace);
						break;
				}
			}
		}
		
		public function removeEnemyFromTowers(e:Enemy):void {
			Config.log('TowerManager', 'removeEnemyFromTowers', "Removing Enemy " + e.uid + " from Towers");
			var len:int = _towers.length;
			for(var i:int = 0; i < len; i++) {
				_towers[i].removeEnemyInRange(e);
			}
			
			onTowerManagerRemovingEnemy.dispatch(e);
		}
		
		public function addListenerToDeactivateTower(t:Tower):void {
			if(_currentTower != t) {
				// handle previous _currentTower
				Config.log('TowerManager', 'addListenerToDeactivateTower', 'TowerManager.addListenerToDeactivateTower() -- deactivating old tower');
				_currentTower.deactivate();
			}
			_currentTower = t;
			Config.log('TowerManager', 'addListenerToDeactivateTower', "TowerManager.addListenerToDeactivateTower() -- adding listener: " + play.map.width + ", " + play.map.height);
			play.map.addEventListener(TouchEvent.TOUCH, _onMapClicked);
		}
		
		/**
		 * Handles placing the _currentTower onto the stage 
		 */
		public function placeTower(p:Point):void {
			Config.totals.towersPlaced++;
			
			/**
			 * Take the tileWidth/tileHeight of the tiles, subtract the width/height of just the tower image
			 * since the _currentTower.width is currently expanded due to the Tower's range ring, 
			 * get the halfWidth/halfHeight and multiply them by 2 (bitwise << 1) to get just the width/height
			 * of the tower image itself and not the width of the Tower Sprite including range ring
			 * then divide that by 2 (bitwise >> 1)
			 * 
			 */
			var xOffset:int = int((play.map.tileWidth - (_currentTower.halfWidth << 1)) >> 1) + play.mapOffsetX;
			var yOffset:int = int((play.map.tileHeight - (_currentTower.halfHeight << 1)) >> 1) + play.mapOffsetY;
			
			// set the tower sprite's x/y
			_currentTower.x = p.x + xOffset;
			_currentTower.y = p.y + yOffset;
			
			// now that we're ready for the tower to be placed BEHIND the UI, 
			// add the tower to the towerLayer (_canvas) instead of play
			_canvas.addChild(_currentTower);
			
			play.map.placedTower(_currentTower);
			
			_towers.push(_currentTower);
			
			// Initialize the currentTower
			_currentTower.init();
			
			// Set up the ProjectileManager to handle when this tower is firing
			_currentTower.onFiring.add(play.bulletMgr.onTowerFiring);
			
			// Let managers know a new Tower has been added
			onTowerAdded.dispatch(_currentTower);
		}
		
		public function sellTower(t:Tower):void {
			// Add half the cost back to currentGold This can be modified later!
			Config.changeCurrentGold(int(t.cost >> 1));
			destroyTower(t);
		}
		
		private function _onMapClicked(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(play.map, TouchPhase.BEGAN);
			if (touch)
			{
				var localPos:Point = touch.getLocation(play.map);
				Config.log('TowerManager', '_onMapClicked', "mapClicked! " + play.map.width + " -- " + localPos.x);

				// if we clicked anywhere but the tower
				if(touch.target != _currentTower) {
					play.hudMgr.hideTowerData(_currentTower);
					_currentTower.deactivate();
					play.map.removeEventListener(TouchEvent.TOUCH, _onMapClicked);
					
				}
			}
		}
		
		public function getTowerCost(towerID:String, level:int):int {
			return _towerData[towerID].levelData[level].cost;
		}
		
		private function _setTowerData(td:Object):void {
			_towerData = {};
			for each(var data:Object in td.towers) {
				_towerData[data.id] = data;                              
			}
		}
		
		// If TowerManager needs to do anything on Pause/Resume
		/**
		 * @inheritDoc
		 */
		public function onGamePaused():void {}
		
		/**
		 * @inheritDoc
		 */
		public function onGameResumed():void {}
	}
}
