package com.zf.managers
{
	import com.zf.core.Config;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.tower.Tower;
	import com.zf.states.Play;
	
	public class CollisionManager implements IZFManager
	{
		private var _play:Play;
		private var _enemies:Array;
		private var _towers:Array;
				
		public function CollisionManager(playState:Play)
		{
			_play = playState;
			_enemies = [];
			_towers = [];
		}
		
		public function update():void {
			checkEnemiesInRange();  
		}
		
		public function checkEnemiesInRange():void {
			var eLen:int = _enemies.length,
			    tLen:int = _towers.length;
			
			// If there are no enemies or no towers, abort the check
			if(eLen == 0 || tLen == 0) {
				return;
			}
			
			var tDistX:Number,
			    tDistY:Number,
			    dist:Number;
			
			for(var eCt:int = 0; eCt < eLen; eCt++) 
			{
				for(var tCt:int = 0; tCt < tLen; tCt++) 
				{
					tDistX = _enemies[eCt].x - _towers[tCt].x;
					tDistY = _enemies[eCt].y - _towers[tCt].y;
					
					// save some cycles not square rooting the value
					dist = tDistX * tDistX + tDistY * tDistY;
					
					if(dist < _towers[tCt].rangeSquared) 
					{
						// check if enemy uid is in tower's enemies array
						if(!_towers[tCt].hasEnemyInRange(_enemies[eCt])) {
							// add enemy to tower
							_towers[tCt].addEnemyInRange(_enemies[eCt]);
						}
					} 
					else 
					{
						// enemy not in range of tower, check tower to see
						// if it used to have the enemy in range, and remove
						if(_towers[tCt].hasEnemyInRange(_enemies[eCt])) {
							// Tell the tower to remove the enemy
							_towers[tCt].removeEnemyInRange(_enemies[eCt]);
						}
					}
				}
			}
		}

		public function destroy():void {
			_enemies = null;
			_towers = null;
			_play = null;
		}
		
		public function onEnemyAdded(e:Enemy):void {
			Config.log('CollisionManager', 'onEnemyAdded', "Adding Enemy " + e.uid);
			_enemies.push(e);
		}
		
		public function onEnemyRemoved(e:Enemy):void {
			Config.log('CollisionManager', 'onEnemyRemoved', "Removing Enemy " + e.uid);
			
			var len:int = _enemies.length;
			for(var i:int = 0; i < len; i++) {
				if(e == _enemies[i]) {
					_enemies.splice(i, 1);
					Config.log('CollisionManager', 'onEnemyRemoved', "Enemy " + e.uid + " Removed");
				}
			}
		}
		
		public function onTowerAdded(t:Tower):void {
			_towers.push(t);
		}

		public function onTowerRemoved(t:Tower):void {
			var len:int = _towers.length;
			for(var i:int = 0; i < len; i++) {
				if(t == _towers[i]) {
					_towers.splice(i, 1);
				}
			}
		}
		
		// If CollisionManager needs to do anything on Pause/Resume
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
