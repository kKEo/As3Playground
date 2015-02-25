package com.zf.objects.tower
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.managers.TowerManager;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.tower.strategies.*;
	import com.zf.states.Play;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class Tower extends Sprite
	{
		public static const TOWER_STATE_NEW		: int = 0;
		public static const TOWER_STATE_INIT	: int = 1;
		public static const TOWER_STATE_READY	: int = 2;
		public static const TOWER_STATE_RELOAD	: int = 3;
		public static const TOWER_STATE_FIRING	: int = 4;
		
		public static const TOWER_ANIM_STATE_SAME:String = 'towerAnimStateSame';
				
		// Sound states
		public static const TOWER_SND_STATE_FIRE:String = 'onFire';
		
		public var uid:int;
		
		public var towerName:String;
		public var index:int;
		public var level:int;
		public var range:Number;
		public var damage:Number;
		public var speed:Number;
		public var dps:Number;
		public var cost:int;
		public var maxLevel:int;
		
		public var halfWidth:Number;
		public var halfHeight:Number;
		public var state:int = TOWER_STATE_NEW;
		public var onFiring:Signal;
		public var bulletType:String;
		public var bulletSpeed:int;
		public var bulletWidth:int;
		public var bulletHeight:int;
		public var centerX:Number;
		public var centerY:Number;
		public var towerStrategy:ITowerStrategy;
		public var levelData:Object;
		public var nextDamage:Number;
		
		public var onUpgrade:Signal;
		
		/**
		 * Range distance Squared
		 */
		public var rangeSquared:Number;
		
		/**
		 * If this tower is currently clicked on
		 */
		public var activated:Boolean = false;
		
		protected var _animState:String;
		protected var _animData:Object;
		protected var _imageName:String;
		protected var _bulletImageName:String;
		
		
		protected var _rangeRing  : Image;
		protected var _badRangeRing : Image;
		protected var _rangeRingDepthIndex:int;
		
		protected var _reloadTimer:Timer;
		
		protected var _soundData:Object;
		
		// reload timer delay with game speed factored in
		protected var _reloadTimerGameSpeedDelay:Number;
		
		/**
		 * Enemies in range
		 */
		protected var _enemiesObj:Object;
		protected var _enemies:Array;
		
		protected var _currentRange:int;
		protected var _lowestSqrt:Number;
		
		/**
		 * Range ring graphics options
		 */
		protected var _rangeRingFillColor:int = 0X009999;
		protected var _badRangeRingFillColor:int = 0XFF0000;
		protected var _borderColor:int = 0X000000;
		protected var _borderSize:int = 1;
		
		protected var _mgr:TowerManager
		
		private var _interval:uint;
		
		public function Tower(towerData:Object, tMgr:TowerManager)
		{
			uid                 = Config.getUID();
			_mgr                = tMgr;
			
			towerName           = towerData.name;
			index               = towerData.name;
			level               = 1;
			range               = towerData.levelData[0].range;
			damage              = towerData.levelData[0].damage;
			speed               = towerData.levelData[0].speed;
			cost                = towerData.levelData[0].cost;
			dps					= towerData.levelData[0].dps;
			maxLevel			= towerData.maxLevel;
			_imageName          = towerData.imageName;
			_bulletImageName    = towerData.bulletImageName;
			halfWidth           = towerData.towerWidth >> 1;
			halfHeight          = towerData.towerHeight >> 1;
			bulletType          = towerData.bulletImageName;
			bulletSpeed         = towerData.bulletSpeed;
			bulletWidth			= towerData.bulletWidth;
			bulletHeight        = towerData.bulletHeight;
			
			_updateStatsByUpgrades();
			
			nextDamage = 0
			
			onUpgrade = new Signal(Tower);
			onFiring = new Signal(Tower, Enemy);
			
			_enemiesObj = {};
			_enemies = [];
			_soundData = {};
			
			resetTowerAfterUpgrade();
			
			_parseLevelData(towerData.levelData);
			_setupAnimData();
			_createRangeRing();
			_createBadRangeRing();
			
			setTowerStrategy(new TowerStrategyNearest());
		}
		
		public function setTowerStrategy(strat:ITowerStrategy):void {
			towerStrategy = strat;	
		}
		
		protected function resetTowerAfterUpgrade():void {
			rangeSquared = range * range;
			
			// set up reloadTimer
			_reloadTimerGameSpeedDelay = Config.currentGameSpeed * speed;

			_reloadTimer = new Timer(_reloadTimerGameSpeedDelay, 1);
			_reloadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reloadDoneReadyTower, false, 0, true);
		}
		
		protected function _parseLevelData(data:Array):void {
			levelData = {};
			for each(var tData:Object in data) {
				levelData[tData.level] = tData;                                
			}
		}
		
		/**
		 * Initializes the tower, lets the tower know it has been placed so it can
		 * do any other setup it needs
		 */
		public function init():void {
			// call _init in 100ms because of the stupid fucking touchevents
			_interval = flash.utils.setInterval(_init, 100);
		}
		
		public function setSoundData(soundData:Array):void {
			var len:int = soundData.length;
			for(var i:int = 0; i<len; i++) {
				_soundData[soundData[i].state] = soundData[i].soundId;
			}
		}
		
		protected function _init():void {
			// clear the stupid interval because of the stupid fucking touchevents
			flash.utils.clearInterval(_interval);
			
			hideRangeRing();
			
			// let tower listen for game speed change
			Config.onGameSpeedChange.add(onGameSpeedChange);
			
			centerX = this.x + halfWidth;
			centerY = this.y + halfHeight;
			
			// since we dont need this anymore, null it out
			_badRangeRing.visible = false;
			_badRangeRing = null;
			
			_addListeners();
			state = TOWER_STATE_READY;
		}
		
		public function update():void {
			if(state == TOWER_STATE_READY && _enemies.length > 0) {
				var targetEnemy:Enemy = towerStrategy.findEnemy(_enemies);
			
				if(targetEnemy) {
					// get the next shot's damage
					_generateNextShotDamage();
					// found the closest
					if(targetEnemy.willDamageBanish(nextDamage)) {
						Config.log('Tower', 'update', "==== Tower " + uid + " -> Enemy " + targetEnemy.uid + " will DIE next hit -- FINAL SHOT -- RemovingEnemyFromTowers()");
						_mgr.removeEnemyFromTowers(targetEnemy);
					}
					// fire at enemy
					fireBullet(targetEnemy);
					
				}
			}
		}
		
		/**
		 * This is where calculations for the next shot's damage would happen taking into 
		 * consideration any tower buffs/effects/etc assuming the tower does variable damage.
		 * For now, just setting nextDamage to the flat damage property of the tower
		 */
		protected function _generateNextShotDamage():void {
			nextDamage = damage;
		}
		
		protected function fireBullet(targetEnemy:Enemy):void {
			state = TOWER_STATE_FIRING;
			_playIfStateExists(TOWER_SND_STATE_FIRE);
			onFiring.dispatch(this, targetEnemy);
			
			reload();
		}
		
		/**
		 * Set up tower animation state data
		 */
		protected function _setupAnimData():void {
			_animData = {};
			
			_animData[TOWER_ANIM_STATE_SAME] = new MovieClip(Assets.ta.getTextures(_imageName), 8);
			
			_changeAnimState(TOWER_ANIM_STATE_SAME);
		}
		
		public function enterFrameTowerPlaceCheck(canPlace:Boolean):void {
			if(canPlace) {
				_rangeRing.visible = true;
				_badRangeRing.visible = false;
			} else {
				_rangeRing.visible = false;
				_badRangeRing.visible = true;
			}
		}
		
		public function addEnemyInRange(e:Enemy):void {
			Config.log('Tower', 'addEnemyInRange', "Tower " + uid + " Adding Enemy " + e.uid + " in range");
			_enemiesObj[e.uid] = e;
			e.onBanished.add(removeEnemyInRange);
			_enemies.push(e);
		}
		
		public function removeEnemyInRange(e:Enemy):void {
			if(_enemiesObj[e.uid]) {
				Config.log('Tower', 'removeEnemyInRange', "Tower " + uid + " Removing Enemy " + e.uid + " from target range");
				// remove listener
				e.onBanished.remove(removeEnemyInRange);
				
				// delete object version
				delete _enemiesObj[e.uid];
				
				// remove array version
				var len:int = _enemies.length;
				for(var i:int = 0; i < len; i++) {
					if(e == _enemies[i]) {
						_enemies.splice(i, 1);
					}
				}
			}       
		}
		
		/**
		 * Checks if we can upgrade this tower
		 */
		public function canUpgrade():Boolean {
			var canUp:Boolean = false;
			
			if(level < maxLevel && levelData[level + 1].cost <= Config.currentGold) {
				canUp = true;
			}
			
			return canUp;
		}
		
		public function upgrade():void {
			level++;
			range = levelData[level].range;
			damage = levelData[level].damage;
			speed = levelData[level].speed;
			dps = levelData[level].range;
			cost = levelData[level].cost;
			
			// apply upgrade bonuses
			_updateStatsByUpgrades();
			
			// remove (add a negative cost) gold to currentGold in Config
			Config.changeCurrentGold(-cost);
			
			// redraw the range ring
			_createRangeRing();
			resetTowerAfterUpgrade();
			onUpgrade.dispatch(this);
		}
		
		public function hasEnemyInRange(e:Enemy):Boolean {
			return (_enemiesObj[e.uid]);
		}
		
		public function showRangeRing():void {  
			_rangeRing.visible = true;
		}
		
		public function hideRangeRing():void {
			_rangeRing.visible = false;
		}
		
		protected function _changeAnimState(newState:String):void {
			// make sure they are different states before removing and adding MCs
			if(_animState != newState) {
				// remove the old MovieClip from juggler
				Starling.juggler.remove(_animData[_animState]);
				// remove the old MovieClip from this Sprite
				removeChild(_animData[_animState]);
				
				_animState = newState;
				
				// add the new MovieClip to the Juggler
				Starling.juggler.add(_animData[_animState]);
				// add the new MovieClip to the Sprite
				addChild(_animData[_animState]);
			}
		}
		
		/**
		 * Adds any internal event listeners needed
		 */
		protected function _addListeners():void {
			addEventListener(TouchEvent.TOUCH, _onTowerSelected);
			state = TOWER_STATE_READY;
		}
		
		/**
		 * Removes any internal event listeners added
		 */
		protected function _removeListeners():void {
			removeEventListener(TouchEvent.TOUCH, _onTowerSelected);
		}
		
		public function destroy():void {
			// remove the old MovieClip from juggler
			Starling.juggler.remove(_animData[_animState]);
			// remove the old MovieClip from this Sprite
			removeChild(_animData[_animState]);
		}
		
		protected function reload():void {
			state = TOWER_STATE_RELOAD;
			_reloadTimer.reset();
			// If game speed has changed, update the delay after the tower is done reloading
			_reloadTimer.delay = _reloadTimerGameSpeedDelay;
			
			_reloadTimer.start();           
		}
		
		public function onGameSpeedChange():void {
			// update the game speed timer
			_reloadTimerGameSpeedDelay = int(speed / Config.currentGameSpeed); 
			_reloadTimer.delay = _reloadTimerGameSpeedDelay - _reloadTimer.currentCount;
		}
		
		protected function reloadDoneReadyTower(evt:TimerEvent):void {
			state = TOWER_STATE_READY;
		}
		
		public function activate():void {
			activated = true;
			showRangeRing();
			_mgr.addListenerToDeactivateTower(this);
			_mgr.play.hudMgr.showTowerData(this);
		}
		
		public function deactivate():void {
			activated = false;
			hideRangeRing();
			_addListeners();
		}
		
		/**
		 * Runs current stats past any upgrade bonuses
		 */
		private function _updateStatsByUpgrades():void {
			range = Config.currentGameSOData.applyUpgradeToValue(range, 'towerRng');
			speed = Config.currentGameSOData.applyUpgradeToValue(speed, 'towerSpd');
			damage = Config.currentGameSOData.applyUpgradeToValue(damage, 'towerDmg');
		}
		
		/**
		 * Handle what needs to happen when users click on the tower
		 */
		protected function _onTowerSelected(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(this, TouchPhase.BEGAN);
			if (touch)
			{
				_removeListeners();
				activate();
			}
		}
		
		protected function _playIfStateExists(state:String):void {
			if(_soundData.hasOwnProperty(state)) {
				Game.soundMgr.playFx(_soundData[state], Config.sfxVolume);
			}
		}
		
		protected function _createRangeRing():void {
			if(contains(_rangeRing)) {
				_rangeRing.removeFromParent(true);
			}
				
			var _s:Shape = new Shape();
			_s.graphics.lineStyle(1);
			_s.graphics.beginFill(_rangeRingFillColor);
			_s.graphics.lineStyle(_borderSize , _borderColor);
			_s.graphics.drawCircle(0, 0, range);
			
			var matrix:Matrix = new Matrix();
			matrix.tx = _s.width >> 1;
			matrix.ty = _s.height >> 1;
			
			var _bmd:BitmapData = new BitmapData(_s.width << 1, _s.height << 1, true, 0x000000);
			_bmd.draw(_s, matrix);
			
			_rangeRing = Image.fromBitmap(new Bitmap(_bmd, "auto", true));
			_rangeRing.name = "rangeRing";
			_rangeRing.alpha = .4;
			
			_rangeRing.x = -(_rangeRing.width >> 2) + halfWidth;
			_rangeRing.y = -(_rangeRing.height >> 2) + halfHeight;
			
			_rangeRingDepthIndex = numChildren - 1;
			_rangeRing.touchable = false;
			
			addChildAt(_rangeRing, _rangeRingDepthIndex);
		}
		
		protected function _createBadRangeRing():void {
			var _s:Shape = new Shape();
			_s.graphics.lineStyle(1);
			_s.graphics.beginFill(_badRangeRingFillColor);
			_s.graphics.lineStyle(_borderSize, _borderColor);
			_s.graphics.drawCircle(0, 0, range);
			
			var matrix:Matrix = new Matrix();
			matrix.tx = _s.width >> 1;
			matrix.ty = _s.height >> 1;
			
			var _bmd:BitmapData = new BitmapData(_s.width << 1, _s.height << 1, true, 0x000000);
			_bmd.draw(_s, matrix);
			
			_badRangeRing = Image.fromBitmap(new Bitmap(_bmd, "auto", true));
			_badRangeRing.name = "badRangeRing";
			_badRangeRing.alpha = .4;
			_badRangeRing.visible = false;
			
			_badRangeRing.x = -(_badRangeRing.width >> 2) + halfWidth;
			_badRangeRing.y = -(_badRangeRing.height >> 2) + halfHeight;
			_badRangeRing.touchable = false;
			
			addChildAt(_badRangeRing , numChildren - 1);
		}
	}
}
