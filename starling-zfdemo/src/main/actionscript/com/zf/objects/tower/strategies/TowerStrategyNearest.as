package com.zf.objects.tower.strategies
{
	import com.zf.objects.enemy.Enemy;

	public class TowerStrategyNearest implements ITowerStrategy
	{
		public function TowerStrategyNearest() {
		}
		
		public function findEnemy(enemies:Array):Enemy {
			var targetEnemy:Enemy,
			    len:int = enemies.length,
				tmpEnemy:Enemy,
				closestDist:Number = -1;
			
			for(var i:int =0; i <  len; i++) {
				tmpEnemy = enemies[i];
				// if it hasnt been initialized properly yet, 
				if(closestDist == -1) {
					// might as well start here, set closestDist to this enemy's totalDist
					// and make this the closestEnemy
					closestDist = tmpEnemy.totalDist;
					targetEnemy = tmpEnemy;
				} else if(tmpEnemy.totalDist < closestDist) {
					// if this enemy is closer to escaping, make it the closestEnemy/Dist to beat
					closestDist = tmpEnemy.totalDist;
					targetEnemy = tmpEnemy;
				}
			}
			
			return targetEnemy;
		}
	}
}