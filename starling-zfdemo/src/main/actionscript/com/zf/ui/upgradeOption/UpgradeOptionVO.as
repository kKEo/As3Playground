package com.zf.ui.upgradeOption
{
	public class UpgradeOptionVO extends Object
	{
		public var id:String;
		public var label:String;
		public var totalRanks:int;
		public var currentRanks:int;
		public var bonusPerRank:Number;
		
		public function UpgradeOptionVO(o:Object) {
			id = o.id;
			label = o.label;
			totalRanks = o.totalRanks;
			currentRanks = o.currentRanks;
			bonusPerRank = o.bonusPerRank;
		}
		
		public function toObject():Object {
			return {
				'id': id,
				'label': label,
				'totalRanks': totalRanks,
				'currentRanks': currentRanks,
				'bonusPerRank': bonusPerRank
			}
		}
	}
}