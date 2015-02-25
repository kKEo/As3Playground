package com.zf.ui.upgradeOption
{
	import com.zf.core.Assets;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;

	public class UpgradeOption extends Sprite
	{
		public var optionChanged:Signal;
		
		private var _id:String;
		private var _label:String;
		private var _labelTF:TextField;
		private var _enabled:Boolean;
		private var _totalRanks:int;
		private var _currentRanks:int;
		private var _bonusPerRank:Number;
		private var _plusBtn:Button;
		private var _minusBtn:Button;
		private var _ranks:Array;
		private var _onStage:Boolean = false;
		
		public function UpgradeOption(id:String, label:String, numRanks:int, bonus:Number, enabled:Boolean = false) {
			_id = id;
			_label = label;
			_totalRanks = numRanks;
			_bonusPerRank = bonus;
			_enabled = enabled;

			optionChanged = new Signal(Boolean, Object);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Sets the number of ranks that are selected and updates the graphics
		 */
		public function set currentRanks(i:int):void {
			_currentRanks = i;
			if(_onStage) {
				update();	
			}
		}
		
		/**
		 * Called to update the visual elements of this component
		 */
		public function update():void {
			_updateButtons();
			_updateRanks();
		}
		
		/**
		 * Handler for when this is added to stage
		 */
		public function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_onStage = true;
			_ranks = [];
			
			_labelTF = new TextField(200, 35, _label, 'Wizzta', 30, 0xFFFFFF);
			_labelTF.y = -40;
			addChild(_labelTF);

			update();
		}
		
		/**
		 * Returns an Object of the properties of this UpgradeOption
		 */
		public function getOptionValue():Object {
			return {
				'id': _id,
				'label': _label,
				'totalRanks': _totalRanks,
				'currentRanks': _currentRanks,
				'bonusPerRank': _bonusPerRank
			}
		}
		
		/**
		 * Disables the UpgradeOption, not allowing it to be clicked
		 */
		public function disable():void {
			_enabled = false;
			update();
		}
		
		/**
		 * Enables the UpgradeOption allowing it to be clicked
		 */
		public function enable():void {
			_enabled = true;
			update();
		}
		
		/**
		 * Adds the plus button to the stage
		 */
		private function _addPlusButton():void {
			// check if the _minusBtn already exists on stage
			if(contains(_plusBtn)) {
				_plusBtn.removeFromParent(true);
			}
			
			var texture:String = 'upgrade_add_disabled';
			var addListener:Boolean = false;
			if(_enabled && _currentRanks < _totalRanks) {
				texture = 'upgrade_add_enabled';
				addListener = true;
			}
			
			_plusBtn = new Button(Assets.ta.getTexture(texture));
			_plusBtn.x = 40;
			_plusBtn.y = 0;
			_plusBtn.name = 'add';
			addChild(_plusBtn);
			
			if(addListener) {
				_plusBtn.enabled = true;
				_plusBtn.addEventListener(Event.TRIGGERED, _onButtonClicked);
			} else {
				_plusBtn.enabled = false;
				_plusBtn.removeEventListener(Event.TRIGGERED, _onButtonClicked);
			}
		}
		
		/**
		 * Adds the minus button to the stage
		 */
		private function _addMinusButton():void {
			// check if the _minusBtn already exists on stage
			if(contains(_minusBtn)) {
				_minusBtn.removeFromParent(true);
			}

			var texture:String = 'upgrade_sub_disabled';
			var addListener:Boolean = false;
			if(_enabled && _currentRanks > 0) {
				texture = 'upgrade_sub_enabled';
				addListener = true;
			}
			
			_minusBtn = new Button(Assets.ta.getTexture(texture));
			_minusBtn.x = 10;
			_minusBtn.y = 0;
			_minusBtn.name = 'sub';
			addChild(_minusBtn);
			
			if(addListener) {
				_minusBtn.enabled = true;
				_minusBtn.addEventListener(Event.TRIGGERED, _onButtonClicked);
			} else {
				_minusBtn.enabled = false;
				_minusBtn.removeEventListener(Event.TRIGGERED, _onButtonClicked);
			}
		}
		
		/**
		 * Adds event listeners to the buttons
		 */
		private function _addListeners():void {
			_plusBtn.addEventListener(Event.TRIGGERED, _onButtonClicked);
			_minusBtn.addEventListener(Event.TRIGGERED, _onButtonClicked);
		}
		
		/**
		 * Removes event listeners to the buttons
		 */
		private function _removeListeners():void {
			_plusBtn.removeEventListener(Event.TRIGGERED, _onButtonClicked);
			_minusBtn.removeEventListener(Event.TRIGGERED, _onButtonClicked);
		}
		
		/**
		 * Event handler for when the button is clicked
		 */
		private function _onButtonClicked(e:Event):void {
			var addedRank:Boolean = false;
			if(Button(e.currentTarget).name == 'add') {
				_currentRanks++;
				addedRank = true;
			} else {
				_currentRanks--;
			}
			
			update();
			
			// dispatch signal with option value Object
			optionChanged.dispatch(addedRank, getOptionValue());
		}
		
		/**
		 * Wrapper for adding both plus and minus buttons
		 */
		private function _updateButtons():void {
			_addPlusButton();
			_addMinusButton();
		}
		
		/**
		 * Updates the rank ui images based on currentRanks
		 */
		private function _updateRanks():void {
			var rank:Image;
			var texture:String = '';
			for(var i:int = 0; i < _totalRanks; i++) {
				if(i < _currentRanks) {
					texture = 'upgrade_rank_selected'
				} else {
					texture = 'upgrade_rank_notselected';
				}
				
				rank = new Image(Assets.ta.getTexture(texture));
				rank.x = 70 + (30 * i);
				rank.y = 0;
				addChild(rank);
				
				_ranks.push(rank);
			}
		}
		
		/**
		 * Destroys the UpgradeOption
		 */
		public function destroy():void {
			_labelTF.removeFromParent(true);
			_labelTF = null;
			
			for(var i:int = 0; i < _ranks.length; i++) {
				_ranks[i].removeFromParent(true);
				_ranks[i] = null;
				_ranks.splice(i, 1);
			}
			
			_plusBtn.removeFromParent(true);
			_plusBtn = null;
			
			_minusBtn.removeFromParent(true);
			_minusBtn = null;
		}
	}
}