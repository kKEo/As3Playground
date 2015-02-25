package com.zf.utils
{
	import com.zf.core.Game;
	import com.zf.core.Totals;
	import com.zf.utils.Utils;
	
	public class ZFGameData extends Object
	{
		// Map game data
		public var mapsAttempted:int;
		public var mapsCompleted:int;
		public var mapsWon:int;
		
		// Totals game data
		public var totalDamage:int;
		public var towersPlaced:int;
		public var enemiesSpawned:int;
		public var enemiesBanished:int;
		public var enemiesEscaped:int;
		public var bulletsFired:int;

		public var soundVolume:Number;
		public var musicVolume:Number;
		
		public var upgrades:Object;
		
		private var _props:Array = [
			'mapsAttempted', 'mapsCompleted', 'mapsWon', 'totalDamage', 'towersPlaced', 
			'enemiesSpawned', 'enemiesBanished', 'enemiesEscaped', 'bulletsFired'
		];

		public function ZFGameData()
		{
			super();
			mapsAttempted 	= 0;
			mapsCompleted 	= 0;
			mapsWon 		= 0;
			totalDamage 	= 0;
			towersPlaced 	= 0;
			enemiesSpawned 	= 0;
			enemiesBanished = 0;
			enemiesEscaped 	= 0;
			bulletsFired 	= 0;
			
			upgrades = {};
			upgrades.towerSpd = { 'id': 'towerSpd', 'label': 'Tower Attack Speed', 'currentRanks': 0, 'totalRanks': 5, 'bonusPerRank': 0.1 };
			upgrades.towerRng = { 'id': 'towerRng', 'label': 'Tower Range', 'currentRanks': 0, 'totalRanks': 5, 'bonusPerRank': 0.15 };
			upgrades.towerDmg = { 'id': 'towerDmg', 'label': 'Tower Damage', 'currentRanks': 0, 'totalRanks': 5, 'bonusPerRank': 0.2 };

			upgrades.ptsAvail = 0;
			upgrades.ptsSpent = 0;
			upgrades.ptsTotal = 0;
		}
		
		public function updateFromTotals(t:Totals, updateThenSave:Boolean = false):void {
			totalDamage 	+= t.totalDamage;
			towersPlaced 	+= t.towersPlaced;
			enemiesSpawned 	+= t.enemiesSpawned;
			enemiesBanished += t.enemiesBanished;
			enemiesEscaped 	+= t.enemiesEscaped;
			bulletsFired 	+= t.bulletsFired;
			mapsCompleted	+= t.mapsCompleted;
			mapsWon			+= t.mapsWon;
			
			if(updateThenSave) {
				Game.sharedObject.setGameData(this, '', true);
			}
		}

		public function updateFromLoadedSO(data:Object):void {
			mapsAttempted 	= data.mapsAttempted;
			mapsCompleted 	= data.mapsCompleted;
			mapsWon 		= data.mapsWon;
			
			totalDamage 	= data.totalDamage;
			towersPlaced 	= data.towersPlaced;
			enemiesSpawned 	= data.enemiesSpawned;
			enemiesBanished = data.enemiesBanished;
			enemiesEscaped 	= data.enemiesEscaped;
			bulletsFired 	= data.bulletsFired;
			
			upgrades = {};
			upgrades.towerSpd = data.upgrades.towerSpd;
			upgrades.towerRng = data.upgrades.towerRng;
			upgrades.towerDmg = data.upgrades.towerDmg;
			upgrades.ptsAvail = data.upgrades.ptsAvail;
			upgrades.ptsSpent = data.upgrades.ptsSpent;
			upgrades.ptsTotal = data.upgrades.ptsTotal;
			
		}
		
		/**
		 * Helper function taking an Object from the GameOptionsPanel and updating this
		 */
		public function updateFromOptions(opts:Object, updateThenSave:Boolean = false):void {
			soundVolume = opts.soundVolume;
			musicVolume = opts.musicVolume;
			
			if(updateThenSave) {
				Game.sharedObject.setGameData(this, '', true);
			}
		}
		
		public function updateFromUpgrades(opt:Object, ptsTotal:int, ptsSpent:int, ptsAvail:int, updateThenSave:Boolean = false):void {
			upgrades[opt.id] = opt;
			upgrades.ptsTotal = ptsTotal;
			upgrades.ptsSpent = ptsSpent;
			upgrades.ptsAvail = ptsAvail;
			
			if(updateThenSave) {
				Game.sharedObject.setGameData(this, '', true);
			}
		}
		
		public function applyUpgradeToValue(val:*, prop:String):* {
			var bonus:Number;
			
			switch(prop) {
				// towerSpd will come in as a timer delay "1500", 
				// the bonus is reducing the value
				case 'towerSpd':
					if(upgrades.towerSpd.currentRanks > 0) {
						bonus = upgrades.towerSpd.currentRanks * upgrades.towerSpd.bonusPerRank;
						if(bonus > 0) {
							// force to whole int values for range
							val -= int(val * bonus);
						}
					}
					
					break;
				
				// towerRng will come in as an int "200"
				// the bonus is adding to the range value
				case 'towerRng':
					if(upgrades.towerRng.currentRanks > 0) {
						bonus = upgrades.towerRng.currentRanks * upgrades.towerRng.bonusPerRank;
						if(bonus > 0) {
							// force to whole int values for range
							val += int(val * bonus);
						}						
					}
					break;
				
				// towerDmg will come in as a Number damage value "2.5", 
				// the bonus is reducing the value
				case 'towerDmg':
					if(upgrades.towerDmg.currentRanks > 0) {
						bonus = upgrades.towerDmg.currentRanks * upgrades.towerDmg.bonusPerRank;
						if(bonus > 0) {
							val += val * bonus;
							// clip to 2-decimal precision
							val = (val*100)/100;
						}						
					}
					break;
			}
			
			return val;
		}
		
		/**
		 * Helper function to convert a basic SO Object into a ZFGameData type
		 * 
		 * @param {Object} so the shared object Object to convert to ZFGameData 
		 */
		public static function fromObject(so:Object):ZFGameData {
			var data:ZFGameData = new ZFGameData();
			data.updateFromLoadedSO(so);
			
			return data;
		}
		
		/**
		 * Converts the ZFGameData to a String
		 */
		public function toString():String {
			return 'Game Data:\n\n' + Utils.objectToString(this, _props, '\n');
		}
		
		/**
		 * Converts the ZFGameData to HTML
		 */
		public function toHtml():String {
			return Utils.objectToString(this, _props, '<br>', true);
		}
	}
}