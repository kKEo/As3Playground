package com.zf.objects.tower.strategies
{
	import com.zf.objects.enemy.Enemy;

	public interface ITowerStrategy
	{
		function findEnemy(enemies:Array):Enemy;
	}
}