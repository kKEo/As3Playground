package com.zf.objects.enemy
{
	import com.zf.core.Config;
	import com.zf.utils.GameTimer;
	
	import flash.events.TimerEvent;
	
	import org.osflash.signals.Signal;
	
	public class EnemyGroup
	{
		public var id:String;
		public var name:String;
		public var spawnDelay:Number;
		public var wave:String;
		public var waypointGroup:String;
		public var enemies:Array;
		public var enemyObjects:Array;
		public var spawnTimer:GameTimer;
		public var onSpawnTimerTick:Signal;
		public var onSpawnTimerComplete:Signal;
		public var isFinished:Boolean;
		
		public function EnemyGroup(i:String, n:String, wpGroup:String, sD:Number, w:String, e:Array)
		{
			id = i;
			name = n;
			waypointGroup = wpGroup;
			spawnDelay = sD;
			wave = w;
			enemies = e;
			enemyObjects = [];
			isFinished = false;
			
			spawnTimer = new GameTimer(id, spawnDelay, enemies.length);
			spawnTimer.addEventListener(TimerEvent.TIMER, _onSpawnTimer);
			spawnTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onSpawnTimerComplete);
			
			// dispatches the enemy being spawned
			onSpawnTimerTick = new Signal();
			onSpawnTimerComplete = new Signal();
		}
		
		public function startGroup():void {
			spawnTimer.start();
		}
		
		/**
		 * Pauses all enemy groups' spawn timers
		 */
		public function pauseGroup():void {
			if(!isFinished && spawnTimer.running) {
				spawnTimer.pause();
			}
		}
		
		/**
		 * Resumes all enemy groups' spawn timers
		 */
		public function resumeGroup():void {
			if(!isFinished && spawnTimer.paused) {
				spawnTimer.start();
			}
		}
		
		private function _onSpawnTimer(evt:TimerEvent):void {
			onSpawnTimerTick.dispatch(enemyObjects.pop(), waypointGroup);
		}
		
		private function _onSpawnTimerComplete(evt:TimerEvent):void {
			isFinished = true;
		}
		
		public function destroy():void {
			Config.log('EnemyGroup', 'destroy', "+++ EnemyGroup Destroying");
			spawnTimer.removeEventListener(TimerEvent.TIMER, _onSpawnTimer);
			spawnTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, _onSpawnTimerComplete);
			spawnTimer = null;
			
			var len:int = enemyObjects.length;
			for(var i:int = 0; i < len; i++) {
				
				enemyObjects[i].destroy();
			}
			enemies = null;
			enemyObjects = null;
			Config.log('EnemyGroup', 'destroy', "--- EnemyGroup Destroyed");
		}
	}
}
