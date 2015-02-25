package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.ui.gameStateBkgd.GameStateBkgd;
	import com.zf.ui.upgradeOption.UpgradeOption;
	import com.zf.ui.upgradeOption.UpgradeOptionVO;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class Upgrades extends Sprite implements IState
	{
		private var _game:Game;
		private var _mapSelectBtn:Button;
		private var _gameStateBkgd:GameStateBkgd;
		private var _upgradeOptions:Array;
		private var _ptsTotal:int;
		private var _ptsSpent:int;
		private var _ptsAvail:int;
		private var _labelTF:TextField;
		private var _ptsTF:TextField;
		private var _resetBtn:Button;
		
		public function Upgrades(game:Game) {
			_game = game;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			var upgrades:Object = Game.sharedObject.getGameDataProperty('upgrades');
			_ptsTotal = upgrades.ptsTotal;
			_ptsSpent = upgrades.ptsSpent;
			_ptsAvail = _ptsTotal - _ptsSpent;

			_gameStateBkgd = new GameStateBkgd('Upgrades');
			addChild(_gameStateBkgd);
			
			_labelTF = new TextField(200, 35, 'Available Points', 'Wizzta', 30, 0xFFFFFF);
			_labelTF.x = 550;
			_labelTF.y = 90;
			addChild(_labelTF);
			
			_ptsTF = new TextField(200, 35, _ptsAvail.toString(), 'Wizzta', 30, 0xFFFFFF);
			_ptsTF.x = 650;
			_ptsTF.y = 90;
			addChild(_ptsTF);
			
			if(_ptsTotal > 0) {
				_resetBtn = new Button(Assets.resetUpgradesBtnT);
				_resetBtn.x = 700;
				_resetBtn.y = 135;
				_resetBtn.addEventListener(Event.TRIGGERED, onResetBtnClicked);
				addChild(_resetBtn);
			}

			_upgradeOptions = [];
			
			_mapSelectBtn = new Button(Assets.mapSelectBtnT);
			_mapSelectBtn.x = 525;
			_mapSelectBtn.y = 450;
			_mapSelectBtn.addEventListener(Event.TRIGGERED, onMapSelectBtnClicked);
			addChild(_mapSelectBtn);

			addUpgradeOptions([
				upgrades.towerSpd,
				upgrades.towerRng,
				upgrades.towerDmg
			]);
		}
		
		public function addUpgradeOptions(opts:Array):void {
			var len:int = opts.length,
				uo:UpgradeOption,
				vo:UpgradeOptionVO,
				shouldEnable:Boolean = (_ptsAvail > 0);
			
			for(var i:int = 0; i < len; i++) {
				vo = new UpgradeOptionVO(opts[i]);
				uo = new UpgradeOption(vo.id, vo.label, vo.totalRanks, vo.bonusPerRank, shouldEnable);
				uo.x = 100;
				uo.y = 200 + (100*i);
				addChild(uo);
				uo.currentRanks = vo.currentRanks;
				_upgradeOptions.push(uo);
			}
			
			if(shouldEnable) {
				toggleUpgradeOptions(true);
			}
		}
		
		public function toggleUpgradeOptions(enable:Boolean):void {
			var len:int = _upgradeOptions.length;
			for(var i:int = 0; i < len; i++) {
				if(enable) {
					_upgradeOptions[i].optionChanged.add(onOptionChange);
					_upgradeOptions[i].enable();
				} else {
					_upgradeOptions[i].optionChanged.remove(onOptionChange);
					_upgradeOptions[i].disable();
				}
			}
		}
		
		public function resetUpgradeOptionsToZero():void {
			var len:int = _upgradeOptions.length;
			for(var i:int = 0; i < len; i++) {
				_upgradeOptions[i].enable()
				_upgradeOptions[i].currentRanks = 0;
				// since we created a new button, have to re-add listener
				_upgradeOptions[i].optionChanged.add(onOptionChange);
			}
		}
		
		/**
		 * Event handler when an UpgradeOption dispatches an optionChanged Signal
		 * Updates _ptsAvail and the textfield for available points
		 * 
		 * @param {Boolean} addedRank if the option changed because player added a rank (true) or removed one (false)
		 * @param {Object} opt the option object
		 */
		public function onOptionChange(addedRank:Boolean, opt:Object):void {
			if(addedRank) {
				_ptsSpent++;
			} else {
				_ptsSpent--;
			}

			_ptsAvail = _ptsTotal - _ptsSpent;
			
			_updatePtsAvailTF();
			
			Config.currentGameSOData.updateFromUpgrades(opt, _ptsTotal, _ptsSpent, _ptsAvail, true);

			if(_ptsAvail <= 0) {
				toggleUpgradeOptions(false);
			}
		}
		
		public function onResetBtnClicked(e:Event):void {
			_ptsSpent = 0;
			_ptsAvail = _ptsTotal;
			resetUpgradeOptionsToZero();
			_updatePtsAvailTF();
		}
		
		private function _updatePtsAvailTF():void {
			_ptsTF.text = _ptsAvail.toString();
		}
		
		private function onMapSelectBtnClicked(evt:Event):void {
			_game.changeState(Game.MAP_SELECT_STATE);
		}		
		
		public function update():void
		{
		}
		
		public function destroy():void
		{
			_mapSelectBtn.removeFromParent(true);
			_mapSelectBtn = null;
			
			_ptsTF.removeFromParent(true);
			_ptsTF = null;
			
			_labelTF.removeFromParent(true);
			_labelTF = null;
			
			if(contains(_resetBtn)) {
				_resetBtn.removeFromParent(true);
				_resetBtn.removeEventListener(Event.TRIGGERED, onResetBtnClicked);
				_resetBtn = null
			}
			
			var len:int = _upgradeOptions.length;
			for(var i:int = 0; i < len; i++) {
				_upgradeOptions[i].destroy();
			}
			
			_gameStateBkgd.destroy();
		}
	}
}