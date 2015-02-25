package com.zf.core
{
	import com.zf.utils.Utils;

	public class Totals
	{
		// Damage
		public var totalDamage:Number;
		
		// Towers
		public var towersPlaced:int;
		
		// Enemies #'s
		public var enemiesSpawned:int;
		public var enemiesBanished:int;
		public var enemiesEscaped:int;
		
		public var bulletsFired:int;
		
		public var mapsCompleted:int;
		public var mapsWon:int;
		
		private var _str:String;
		private var _props:Array = ['totalDamage', 'towersPlaced', 'enemiesSpawned', 'enemiesBanished', 'enemiesEscaped', 'bulletsFired']
			
		public function Totals() {
			reset();
		}
		
		public function reset():void {
			totalDamage 	= 0;
			towersPlaced 	= 0;
			enemiesSpawned 	= 0;
			enemiesBanished = 0;
			enemiesEscaped 	= 0;
			bulletsFired 	= 0;
			
			mapsCompleted	= 1;
			
			// if player wins, update this to 1
			mapsWon			= 0;
			
			_str = '';
		}
		
		/**
		 * Converts the Totals to a String
		 */
		public function toString():String {
			return 'Game Stats:\n\n' + Utils.objectToString(this, _props, '\n');
		}
		
		/**
		 * Converts the Totals to HTML
		 */
		public function toHtml():String {
			var s:String = '<font color="#FFFFFF" size="20">Game Stats: <br><br>';
			if(mapsWon) {
				s += 'MAP WON!';
			} else {
				s += 'Map Lost :(';
			}
			s += '</font><br><br>';
			
			s += Utils.objectToString(this, _props, '<br>', true);
			
			return s;
		}
	}
}