package com.zf.managers
{
	import com.leebrimelow.starling.StarlingPool;
	import com.zf.core.Config;
	import com.zf.objects.bullet.Bullet;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.tower.Tower;
	import com.zf.states.Play;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	public class BulletManager implements IZFManager
	{
		public var onBulletHitEnemy:Signal;
		public var delayCount:int = 0;
		public var play:Play;
		
		private var _bullets:Array;
		private var _pool:StarlingPool;
		private var _mapBounds:Rectangle;
		private var _enemies:Object;
		
		// Reusable Point variables so we're not constantly doing new Point
		private var _p1:Point = new Point(0,0);
		private var _p2:Point = new Point(0,0);

		public function BulletManager(playState:Play)
		{
			play = playState;
			_bullets = [];  
			_enemies = {};
			_pool = new StarlingPool(Bullet, 40);
			_mapBounds = play.map.paddedBounds;
			onBulletHitEnemy = new Signal(Bullet);
		}
		
		public function update():void {
			if(_bullets.length > 0 && delayCount % 2 == 0) {
				var b:Bullet,
				    len:int = _bullets.length;
				for(var i:int = len - 1; i >= 0; i--) {
					b = _bullets[i];
					
					// doublecheck that this bullet still exists
					if(b != null) {
						b.update();
						
						if(b.hitEnemy) {
							bulletHitEnemy(b);
						} else if(b.isDestroyed) {
							destroyBullet(b);
						}
					} else {
						// if it doesnt, we need to update our len
						len = _bullets.length;
					}
				}
			}
			delayCount++;
		}
		
		public function bulletHitEnemy(b:Bullet):void {
			Config.log('BulletManager', 'bulletHitEnemy', "Bullet " + b.uid + " hit enemy " + b.destObj.uid);
			b.destObj.takeDamage(b.damage);
			onBulletHitEnemy.dispatch(b);
			destroyBullet(b);
		}
		
		public function destroyBullet(b:Bullet):void {
			var len:int = _bullets.length,
			    tLen:int,
			    enemyBulletArr:Array;
			
			for(var i:int = 0; i < len; i++) 
			{
				if(b == _bullets[i]) 
				{
					Config.log('BulletManager', 'destroyBullet', "- destroying bullet " + b.uid);
					
					// First remove the reference of the bullet firing at the enemy
					enemyBulletArr = _enemies[b.destObj.uid];
					
					// check if the enemy has already been removed or destroyed 
					if(enemyBulletArr) {
						tLen = enemyBulletArr.length;
						for(var j:int = 0; j < tLen; j++) {
							if(b == enemyBulletArr[j]) {
								enemyBulletArr.splice(j, 1);
								Config.log('BulletManager', 'destroyBullet', "Removing bullet " + b.uid + " from Enemy " + b.destObj.uid + " enemyBulletArr -> Still " + _enemies[b.destObj.uid].length + " Bullets out for this Enemy");
							}
						}
					}
					
					b.destroy();
					_bullets.splice(i, 1);
					Config.log('BulletManager', 'destroyBullet', "Active Bullets (_bullets.length) " + _bullets.length);
					b.removeFromParent(true);
					_pool.returnSprite(b);
				}
			}
		}
		
		
		/**
		 * Handles firing bullets
		 * 
		 * @param tower {Tower} the tower that is firing
		 * @param projType {String} the bullet type that is being fired
		 * @param enemy {Enemy} the enemy that is being fired upon
		 */
		public function onTowerFiring(t:Tower, e:Enemy):void {
			var b:Bullet = _pool.getSprite() as Bullet;
			b.init(t, e, play);
			play.addChild(b);
			b.x = t.centerX;
			b.y = t.centerY;
			Config.log('BulletManager', 'onTowerFiring', "+ Adding Bullet " + b.uid + " is firing from Tower " + t.uid + " at Enemy " + e.uid);
			
			_bullets.push(b);
			_addListenerOnEnemy(e, b);
			
			Config.totals.bulletsFired++;
		}
		
		private function _addListenerOnEnemy(e:Enemy, b:Bullet):void {
			if(!_enemies[e.uid]) {
				_enemies[e.uid] = [];
				e.onDestroy.add(onEnemyDestroyed);
				Config.log('BulletManager', '_addListenerOnEnemy', "Adding listeners for Enemy " + e.uid);
			}
			
			_enemies[e.uid].push(b);
			Config.log('BulletManager', '_addListenerOnEnemy', "Enemy " + e.uid + " has " +  _enemies[e.uid].length + " bullets aimed at it");
		}
		
		public function onEnemyDestroyed(e:Enemy):void {
			Config.log('BulletManager', 'onEnemyDestroyed', "Removing " + _enemies[e.uid].length + " bullets aimed at " + e.uid + " -- Removing Listeners");
			
			// remove listener
			e.onDestroy.remove(onEnemyDestroyed);
			
			// destroy all bullets enroute to this enemy
			for each(var b:Bullet in _enemies[e.uid]) {
				destroyBullet(b);
			}
			
			// delete the entry for that enemy uid
			delete _enemies[e.uid];
		}
		
		public function get activeBullets():String {
			return _bullets.length.toString();
		}
		
		public function destroy():void {
			_bullets = null;
			_enemies = null;
			_pool = null;
			onBulletHitEnemy.removeAll();
		}
		
		// If BulletManager needs to do anything on Pause/Resume
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
