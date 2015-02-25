package com.zf.managers
{
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.enemy.EnemyGroup;
	import com.zf.objects.enemy.EnemyType;
	import com.zf.states.Play;
	import com.zf.utils.GameTimer;
	
	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	
	public class EnemyManager implements IZFManager
	{
		public var play:Play;
		public var onEnemyAdded:Signal;
		public var onEnemyRemoved:Signal;
		public var endOfEnemies:Signal;
		public var enemiesLeft:int;
		public var activeEnemies:int;
		public var delayCount:int = 0;
		public var onSpawnWave:Signal;
		
		private var _enemies:Array;
		private var _canvas:Sprite;
		private var _enemyDeathParticles:Array;
		
		/**
		 * Holds the current map's enemy groups
		 */
		private var _enemyGroups:Object;
		
		/**
		 * Holds the current map's enemy types
		 */
		private var _enemyTypes:Object;
		
		private var _enemyWaves:Object;
		
		public function EnemyManager(playState:Play)
		{
			play = playState;
			_canvas = play.enemyLayer;
			_enemyDeathParticles = [];
			_enemies = [];  
			activeEnemies = 0;
			
			onEnemyAdded = new Signal(Enemy);
			onEnemyRemoved = new Signal(Enemy);
			endOfEnemies = new Signal();
			onSpawnWave = new Signal(String);
			
			_enemyGroups = {};
			_enemyTypes = {};
			_enemyWaves = {};
		}
		
		public function update():void {
			if(_enemies.length > 0) {
				var e:Enemy;
				var len:int = _enemies.length;
				for(var i:int = len - 1; i >= 0; i--) {
					e = _enemies[i];
					e.update();

					if(e.isEscaped) {
						_handleEnemyEscaped(e);
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGamePaused():void {
			_pauseGroups();
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGameResumed():void {
			_resumeGroups();
		}
		
		private function _pauseGroups():void {
			for each(var group:EnemyGroup in _enemyGroups) {
				group.pauseGroup();
			}
		}
		
		private function _resumeGroups():void {
			for each(var group:EnemyGroup in _enemyGroups) {
				group.resumeGroup();
			}
		}
		
		public function destroyEnemy(e:Enemy):void {
			var len:int = _enemies.length;
			for(var i:int = 0; i < len; i++) {
				if(e == _enemies[i]) {
					Config.log('Enemy', 'destroyEnemy', "Destroying Enemy " + e.uid);
					_enemies.splice(i, 1);
					/*
					var _enemyDeathPS:PDParticleSystem = new PDParticleSystem(Assets.enemyDiePEX), Assets.ta.getTexture('misc/enemyDieSparkle1'));
					_enemyDeathPS.x = e.x;
					_enemyDeathPS.y = -e.y;
					_enemyDeathPS.emitterX = e.x;
					_enemyDeathPS.emitterY = e.y;
					Play.zfJuggler.add(_enemyDeathPS);
					play.addChild(_enemyDeathPS);
					_enemyDeathPS.addEventListener(Event.COMPLETE, removePEX);
					_enemyDeathParticles.push(_enemyDeathPS);
					_enemyDeathPS.start(0.5);
					*/
					e.destroy();
					e.removeFromParent(true);
				}
				
			}
		}
		
		public function removePEX(evt:Event):void {
			var len:int = _enemyDeathParticles.length;
			if(len == 1) {
				Play.zfJuggler.remove(_enemyDeathParticles[0]);
				play.removeChild(_enemyDeathParticles[0]);
				_enemyDeathParticles[0].stop();
				_enemyDeathParticles = []
			} else {
				for(var i:int = 0; i < len; i++) {
					if(evt.target == _enemyDeathParticles[i]) {
						Play.zfJuggler.remove(_enemyDeathParticles[i]);
						play.removeChild(_enemyDeathParticles[i]);
						_enemyDeathParticles[i].stop();
						_enemyDeathParticles.splice(i, 1);
					}
				}
			}
		}
		
		private function _spawn(e:Enemy, wpGroup:String):void {
			var waypoints:Array = play.wpMgr.getWaypointsByGroup(wpGroup);
			var totalDist:Number = play.wpMgr.getRouteDistance(wpGroup);
			
			Config.totals.enemiesSpawned++;
			
			e.init(waypoints, totalDist);
			
			e.onBanished.add(handleEnemyBanished);
			
			_enemies.push(e);
			
			activeEnemies++;
			
			_canvas.addChild(e);
			
			onEnemyAdded.dispatch(e);
		}
		
		public function spawnWave(waveId:String):void {
			Game.soundMgr.playFx('ding1', Config.sfxVolume);
			
			// dispatch that we spawned a wave
			onSpawnWave.dispatch(waveId);
			
			// increment the wave counter
			Config.changeCurrentWave(1);
			
			for each(var groupName:String in _enemyWaves[waveId]) {
				_enemyGroups[groupName].startGroup();
			}
		}
		
		/**
		 * Do anything we need to do when the enemy escapes... deduct hitpoints etc
		 * before we destroy the enemy
		 */
		private function _handleEnemyEscaped(e:Enemy):void {
			enemiesLeft--;
			activeEnemies--;
			
			Config.totals.enemiesEscaped++;
			
			Config.changeCurrentHP(-e.damage);
			destroyEnemy(e)
			onEnemyRemoved.dispatch(e);
			
			if(enemiesLeft <= 0) {
				endOfEnemies.dispatch();
			}
		}
		
		public function handleEnemyBanished(e:Enemy):void {
			Config.log('EnemyManager', 'handleEnemyBanished', 'Enemy ' + e.uid + " is being destroyed");
			enemiesLeft--;
			activeEnemies--;
			
			Config.totals.enemiesBanished++;

			Config.changeCurrentGold(e.reward);
			
			onEnemyRemoved.dispatch(e);
			destroyEnemy(e);
			
			if(enemiesLeft <= 0) {
				endOfEnemies.dispatch();
			}
		}
		
		/**
		 * PARSE LEVEL DATA
		 */
		public function handleNewMapData(data:Object):void {
			var type:Object;
			var group:Object;
			
			var enemyType:EnemyType;
			var enemy:*;
			
			// Create all enemy types
			for each(type in data.enemyTypes) {
				_enemyTypes[type.id] = new EnemyType(type.id, type.name, type.klass, type.sounds);
			}
			
			Config.maxWave = 0;
			
			// Create enemy wave mappings
			for each(var wave:Object in data.enemyWaves) {
				_enemyWaves[wave.id] = [];
				if(wave.groups.indexOf(',') != -1) {
					var groups:Array = wave.groups.split(',');
					_enemyWaves[wave.id] = groups;
				} else {
					_enemyWaves[wave.id].push(wave.groups);
				}
				Config.maxWave++;
			}
			
			// Create all enemy groups
			for each(group in data.enemyGroups) {
				_enemyGroups[group.id] = new EnemyGroup(group.id, group.name, group.waypointGroup, group.spawnDelay, group.wave, group.enemies);
				_enemyGroups[group.id].onSpawnTimerTick.add(onGroupSpawnTimerTick);
				_enemyGroups[group.id].onSpawnTimerComplete.add(onGroupSpawnTimerComplete);     
			}
			// Create all actual enemies
			for each(group in _enemyGroups) {
				for each(var enemyObj:Object in group.enemies) {
					// get the enemyType
					enemyType = _enemyTypes[enemyObj.typeId];
					
					// Creates a new enemy type from the fullClass name
					var newEnemy:Enemy = new (getDefinitionByName(enemyType.fullClass) as Class)();
					newEnemy.setSoundData(enemyType.soundData);
					
					enemiesLeft++;
					
					// push new enemy onto object array
					group.enemyObjects.push(newEnemy);
				}
				
				// reverse array
				group.enemyObjects.reverse();
			}
		}
		
		public function onGroupSpawnTimerTick(e:Enemy, wpGroup:String):void {
			Config.log('EnemyManager', 'onGroupSpawnTimerTick', "onGroupSpawnTimerTick: " + e);
			_spawn(e, wpGroup);
		}
		
		public function onGroupSpawnTimerComplete(e:Enemy):void {
			Config.log('EnemyManager', 'onGroupSpawnTimerComplete', "onGroupSpawnTimerComplete: " + e);
		}
		
		public function destroy():void {
			Config.log('EnemyManager', 'destroy', "EnemyManager Destroying");
			_enemyTypes = null;
			
			var group:Object;
			for each(group in _enemyGroups) {
				group.destroy();
			}
			_enemyGroups = null;
			
			var len:int = _enemies.length;
			for(var i:int = 0; i < len; i++) {
				_enemies[i].destroy();
			}
			
			_enemies = null;
			
			Config.log("EnemyManager", "destroy", "EnemyManager Destroyed");
		}
		

	}
}
