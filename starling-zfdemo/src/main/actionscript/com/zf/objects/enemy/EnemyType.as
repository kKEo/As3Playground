package com.zf.objects.enemy
{
	import com.zf.objects.enemy.types.EnemyA;
	import com.zf.objects.enemy.types.EnemyB;
	
	public class EnemyType
	{
		public var id:String;
		public var name:String;
		public var fullClass:String;
		public var soundData:Array;
		
		public function EnemyType(i:String, n:String, fC:String, sD:Array)
		{
			id = i;
			name = n;
			fullClass = 'com.zf.objects.enemy.types.' + fC;
			soundData = sD;
		}
		
		
		// create dummy versions of each enemy type, these will never be used
		private var _dummyEnemyA:EnemyA;
		private var _dummyEnemyB:EnemyB;
	}
}
