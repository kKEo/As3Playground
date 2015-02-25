package com.zf.objects.enemy
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.states.Play;
	import com.zf.ui.healthBar.HealthBar;
	
	import org.osflash.signals.Signal;
	
	import starling.display.MovieClip;
	import starling.display.Sprite;
	
	public class Enemy extends Sprite
	{
		public static const ENEMY_DIR_UP:String = 'enemyUp';
		public static const ENEMY_DIR_RIGHT:String = 'enemyRight';
		public static const ENEMY_DIR_DOWN:String = 'enemyDown';
		public static const ENEMY_DIR_LEFT:String = 'enemyLeft';
		
		public static const ENEMY_SND_STATE_BANISH:String = "onBanish";
		public static const ENEMY_SND_STATE_ESCAPE:String = "onEscape";
		
		// set default speed to 1
		public var speed:Number = 1;
		public var maxHP:Number = 10;
		public var currentHP:Number = 10;
		public var reward:int = 5;
		public var damage:int = 1;
		public var isEscaped:Boolean = false;
		public var isBanished:Boolean = false;
		public var willBeBanished:Boolean = false;
		
		public var onDestroy:Signal;
		public var onBanished:Signal;
		public var type:String = "Enemy";
		public var uid:int;
		public var totalDist:Number;
		
		protected var _animState:String;
		protected var _animData:Object;
		protected var _animTexturesPrefix:String;

		protected var _soundData:Object;
		
		
		protected var _distToNext:Number;
		protected var _currentWPIndex:int;
		protected var _waypoints:Array = [];
		protected var _healthBar:HealthBar;
		
		// enemy speed * currentGameSpeed
		protected var _enemyGameSpeed:Number;
		protected var _enemyGameSpeedFPS:int;
		protected var _enemyBaseFPS:int = 12;
		
		/**
		 * This is an Enemy's "currentHP" factoring in all bullets currently
		 * flying towards it. So if this is <= 0, the enemy may still be alive,
		 * but bullets have already been spawned with it's name on it
		 */
		protected var _fluxHP:Number;
		
		public function Enemy()
		{
			uid = Config.getUID();
			
			_setInternalSpeeds();
			
			_setupAnimData();
			_changeAnimState(ENEMY_DIR_RIGHT);
			pivotX = width >> 1;
			pivotY = height >> 1;
			
			_soundData = {};
			
			onDestroy = new Signal(Enemy);
			onBanished = new Signal(Enemy);
			
			// let enemy listen for game speed change
			Config.onGameSpeedChange.add(onGameSpeedChange);
		}
		
		/**
		 * Since enemies are pooled, this lets us reset some data each time an enemy is removed from the pool
		 */
		public function init(wps:Array, dist:Number):void {
			isEscaped = false;
			isBanished = false;
			willBeBanished = false
			_waypoints = wps;
			totalDist = dist;
			_distToNext = _waypoints[0].distToNext;
			
			// clear the old animState
			_animState = '';
			// set new animState
			_changeAnimState(_waypoints[0].nextDir);
			
			// reset WP index
			_currentWPIndex = 0;
			x = _waypoints[0].centerPoint.x;
			y = _waypoints[0].centerPoint.y;
			
			// reset current and _flux back to maxHP
			currentHP = _fluxHP = maxHP;
			
			_healthBar = new HealthBar(this, currentHP, maxHP, 30);
			_healthBar.x = -20;
			_healthBar.y = -10;
			addChild(_healthBar);
		}
		public function update():void {
			// subtract next speed increment from distance to next
			_distToNext -= _enemyGameSpeed;
			
			// subtract next speed increment from total distance
			totalDist -= _enemyGameSpeed;
			
			// If we reached the next waypoint
			if(_distToNext <= 0) {
				// get the next WP
				_getNextWaypoint();
			}
			
			switch(_animState) {
				case ENEMY_DIR_UP:
					y -= _enemyGameSpeed;
					break;
				
				case ENEMY_DIR_RIGHT:
					x += _enemyGameSpeed;
					break;
				
				case ENEMY_DIR_DOWN:
					y += _enemyGameSpeed;
					break;
				
				case ENEMY_DIR_LEFT:
					x -= _enemyGameSpeed;
					break;
			}
		}
		
		public function takeDamage(dmgAmt:Number):void {
			Config.log('Enemy', 'takeDamage', uid + " is taking " + dmgAmt + " damage");
			if(!isEscaped) {
				Config.totals.totalDamage += dmgAmt;
				
				currentHP -= dmgAmt;
				if(_healthBar) {
					_healthBar.takeDamage(dmgAmt);
				}
				
				
				if(currentHP <= 0) {
					_handleBanished();
				}
				Config.log('Enemy', 'takeDamage', "Enemy " + uid + " has " + currentHP + " hp remaining");
			}
		}
		
		public function onGameSpeedChange():void {
			// remove old data from juggler
			_removeAnimDataFromJuggler();
			
			// reset internal speeds
			_setInternalSpeeds();
			
			// reset animation data
			_setupAnimData();

			// reset animation state
			_changeAnimState(_animState, true);
		}
		
		public function willDamageBanish(dmg:Number):Boolean {
			// deal damage to _fluxHP to see if this 
			// damage amount will banish enemy
			_fluxHP -= dmg;
			if(_fluxHP <= 0) {
				willBeBanished = true;
			}
			Config.log('Enemy', 'willDamageBanish', "Enemy " + uid + " _fluxHP " + _fluxHP + " and willBeBanished is " + willBeBanished);
			return willBeBanished;
		}
		
		public function setSoundData(soundData:Array):void {
			var len:int = soundData.length;
			for(var i:int = 0; i<len; i++) {
				_soundData[soundData[i].state] = soundData[i].soundId;
			}
		}
		
		/**
		 * Called when a waypoint has been reached, update values for the next WP or else handle escaped
		 */
		protected function _getNextWaypoint():void {
			_currentWPIndex++;
			
			if(_currentWPIndex < _waypoints.length - 1) {
				_changeAnimState(_waypoints[_currentWPIndex].nextDir);
				_distToNext = _waypoints[_currentWPIndex].distToNext;
			} else {
				_handleEscape();
			}
		}
		
		/**
		 * Last chance to handle any escape penalties before this mob gets disposed
		 */
		protected function _handleEscape():void {
			isEscaped = true;
			_playIfStateExists(ENEMY_SND_STATE_ESCAPE);
		}
		
		protected function _handleBanished():void {
			Config.log('Enemy', '_handleBanished', "Enemy " + uid + " is below 0 health and isBanished = true");
			isBanished = true;
			onBanished.dispatch(this);
			_playIfStateExists(ENEMY_SND_STATE_BANISH);
		}
		
		protected function _playIfStateExists(state:String):void {
			if(_soundData.hasOwnProperty(state)) {
				Game.soundMgr.playFx(_soundData[state], Config.sfxVolume);
			}
		}
		
		protected function _setupAnimData():void {
			//_animState = '';
			_animData = {};

			_animData[ENEMY_DIR_UP] = new MovieClip(Assets.ta.getTextures(_animTexturesPrefix + '_t_'), _enemyGameSpeedFPS);
			_animData[ENEMY_DIR_RIGHT] = new MovieClip(Assets.ta.getTextures(_animTexturesPrefix + '_r_'), _enemyGameSpeedFPS);
			_animData[ENEMY_DIR_DOWN] = new MovieClip(Assets.ta.getTextures(_animTexturesPrefix + '_b_'), _enemyGameSpeedFPS);
			_animData[ENEMY_DIR_LEFT] = new MovieClip(Assets.ta.getTextures(_animTexturesPrefix + '_l_'), _enemyGameSpeedFPS);
		}
		
		protected function _changeAnimState(newState:String, forceChange:Boolean = false):void {
			// make sure they are different states before removing and adding MCs
			// unless foreceChange is true
			if(_animState != newState || forceChange) {
				// _animState == '' on subsequent play throughs since init doesn't get called again
				if(_animState != '') {
					_removeAnimDataFromJuggler();
				}
				
				_animState = newState;
				
				_addAnimDataToJuggler()
			}
		}

		protected function _removeAnimDataFromJuggler():void {
			// remove the old MovieClip from juggler
			Play.zfJuggler.remove(_animData[_animState]);
			// remove the old MovieClip from this Sprite
			removeChild(_animData[_animState]);
		}
		
		protected function _addAnimDataToJuggler():void {
			// add the new MovieClip to the Juggler
			Play.zfJuggler.add(_animData[_animState]);
			// add the new MovieClip to the Sprite
			addChild(_animData[_animState]);
		}
		
		protected function _setInternalSpeeds():void {
			_enemyGameSpeed = Config.currentGameSpeed * speed;
			_enemyGameSpeedFPS = int(Config.currentGameSpeed * _enemyBaseFPS);
			// make sure _enemyGameSpeedFPS is at least 1
			if(_enemyGameSpeedFPS < 1) {
				_enemyGameSpeedFPS = 1;
			}
		}
		
		protected function _updateSpeed(spd:Number):void {
			// change speed from child classes
			speed = spd;
			// Call _setInternalSpeeds to reset internal speeds
			_setInternalSpeeds();
		}
		
		public function destroy():void {
			//Config.log('Enemy', 'destroy', "+ + " + uid + " destroying");
			onDestroy.dispatch(this);
			onDestroy.removeAll();
			_removeAnimDataFromJuggler();
			removeChild(_healthBar);
			_healthBar = null;
			removeFromParent(true);
			Config.log('Enemy', 'destroy', "+ + " + uid + " destroyed");
		}
	}
}
