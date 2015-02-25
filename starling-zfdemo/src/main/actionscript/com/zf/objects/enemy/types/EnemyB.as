package com.zf.objects.enemy.types
{
	import com.zf.objects.enemy.Enemy;
	
	public class EnemyB extends Enemy
	{
		public function EnemyB() {
			super();
		}
		
		override protected function _setupAnimData():void {
			_animTexturesPrefix = 'enemies/enemyB';
			super._setupAnimData();
		}
	}
}
