package com.zf.objects.enemy.types
{
	import com.zf.objects.enemy.Enemy;
	
	public class EnemyA extends Enemy
	{
		public function EnemyA() {
			super();
			// speed for EnemyA
			_updateSpeed(1.2);
		}
		
		override protected function _setupAnimData():void {
			_animTexturesPrefix = 'enemies/enemyA';
			super._setupAnimData();
		}
	}
}
