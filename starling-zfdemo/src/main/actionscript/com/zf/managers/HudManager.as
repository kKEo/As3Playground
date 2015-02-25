package com.zf.managers
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.objects.tower.Tower;
	import com.zf.states.Play;
	import com.zf.ui.buttons.nextWaveButton.NextWaveButton;
	import com.zf.ui.gameOptions.GameOptionsPanel;
	import com.zf.ui.text.ZFTextField;
	import com.zf.ui.towerSelect.TowerSelectIcon;
	import com.zf.ui.waveTile.WaveTileBar;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import feathers.controls.ScrollText;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	
	public class HudManager extends Sprite implements IZFManager
	{
		public var play		: Play;
		public var endOfHP	: Signal;
		
		private var _invalidComponents	: Array;
		private var _playBkgd			: Image;
		private var _canvas				: Sprite;
		private var _p					: Point = new Point(-1,-1);
		private var _tf					: TextFormat;
		private var _goldTF				: ZFTextField;
		private var _hpTF				: ZFTextField;
		private var _waveTF				: ZFTextField;
		private var _waveTileBar		: WaveTileBar;
		private var _tower1				: TowerSelectIcon;
		private var _tower2				: TowerSelectIcon;
		private var _infoText			: ScrollText;
		private var _activeTower		: Tower;
		private var _gameOptions		: GameOptionsPanel;
		private var _optsBtn			: Button;
		private var _sellTowerBtn		: Button;
		private var _upgradeTowerBtn	: Button;
		private var _pauseBtn			: Button;
		private var _optionsVisible		: Boolean;
		private var _nextWaveBtns		: Array;
		
		public function HudManager(playState:Play) {
			play = playState;
			_canvas = play.hudLayer;
			
			_invalidComponents = [];
			_nextWaveBtns = [];
			
			endOfHP = new Signal();
			
			_optionsVisible = false;

			_waveTileBar = new WaveTileBar(Config.currentMapData.enemyWaveData);
			_waveTileBar.x = 36;
			_waveTileBar.y = 567;
			// when a tile is touched, let EnemyManager handle spawning a new wave
			_waveTileBar.waveTileTouched.add(play.enemyMgr.spawnWave);
			_canvas.addChild(_waveTileBar);
			
			_playBkgd = new Image(Assets.playBkgdT);
			_playBkgd.x = 0;
			_playBkgd.y = 0;
			_playBkgd.width = 800;
			_playBkgd.height = 600;
			_playBkgd.touchable = false;
			_canvas.addChild(_playBkgd);

			// place tower image
			_tower1 = new TowerSelectIcon(Assets.towerData.towers[0]);
			_tower1.x = 590;
			_tower1.y = 90;
			_canvas.addChild(_tower1);
			_tower1.onHover.add(_onHoverTowerSelectIcon);
			_tower1.onClick.add(_onClickTowerSelectIcon);
			
			_tower2 = new TowerSelectIcon(Assets.towerData.towers[1]);
			_tower2.x = 630;
			_tower2.y = 90;
			_canvas.addChild(_tower2);
			_tower2.onHover.add(_onHoverTowerSelectIcon);
			_tower2.onClick.add(_onClickTowerSelectIcon);
			
			_goldTF = new ZFTextField('goldCoin', 'CalistoMT', Config.currentGold.toString());
			_goldTF.x = 100;
			_goldTF.y = 0;
			_goldTF.componentIsInvalid.add(handleInvalidTFComponent);
			_goldTF.touchable = false;
			_canvas.addChild(_goldTF);
			Config.currentGoldChanged.add(updateGoldTF);

			_hpTF = new ZFTextField('heartIcon', 'CalistoMT', Config.currentHP.toString());
			_hpTF.x = 200;
			_hpTF.y = 0;
			_hpTF.componentIsInvalid.add(handleInvalidTFComponent);
			_hpTF.touchable = false;
			_canvas.addChild(_hpTF);
			Config.currentHPChanged.add(updateHPTF);
			
			var waveTxt:String = Config.currentWave.toString() + ' / ' + Config.maxWave.toString();
			_waveTF = new ZFTextField('waveIcon', 'CalistoMT', waveTxt);
			_waveTF.x = 300;
			_waveTF.y = 0;
			_waveTF.componentIsInvalid.add(handleInvalidTFComponent);
			_waveTF.touchable = false;
			_canvas.addChild(_waveTF);
			Config.currentWaveChanged.add(updateWaveTF);
			
			_infoText = new ScrollText();
			_infoText.x = 588;
			_infoText.y = 250;
			_infoText.isHTML = true;
			_infoText.textFormat = new TextFormat('CalistoMT', 16, 0xFFFFFF);
			_infoText.text = "";
			_canvas.addChild(_infoText);
			
			_upgradeTowerBtn = new Button(Assets.ta.getTexture('upgradeTowerBtn'));
			_upgradeTowerBtn.x = 580;
			_upgradeTowerBtn.y = 520;
			_canvas.addChild(_upgradeTowerBtn);
			
			_sellTowerBtn = new Button(Assets.ta.getTexture('sellTowerBtn'));
			_sellTowerBtn.x = 660;
			_sellTowerBtn.y = 520;
			_canvas.addChild(_sellTowerBtn);
			
			_hideTowerButtons();
			
			// Set up options stuff but do not add to stage yet
			_gameOptions = new GameOptionsPanel(new Point(150,-350), new Point(150,150));
			_gameOptions.onQuitGame.add(play.onQuitGameFromOptions);
			
			_optsBtn = new Button(Assets.optsBtnT);
			_optsBtn.x = 667;
			_optsBtn.y = 0;
			_optsBtn.addEventListener(Event.TRIGGERED, _onOptionsClicked);
			_canvas.addChild(_optsBtn);
			
			_resetPauseBtn(Assets.playBtnT);
			play.enemyMgr.onSpawnWave.add(onSpawnWave);
		}
		
		/**
		 * Handles if the enemyMgr spawns a wave and the user hasn't clicked the NextWaveButton yet
		 */
		public function onSpawnWave(waveID:String):void {
			// remove after the first time since we dont show the nextWaveButtons 
			// except for the first round
			play.enemyMgr.onSpawnWave.remove(onSpawnWave);
			
			// remove the next wave buttons but dont trigger a pause event
			removeNextWaveButtons(false);
		}
		
		public function update():void {
			updateUI();
			// always update the _waveTileBar, it will handle it's own optimization
			_waveTileBar.update();
		}
		
		/**
		 * Updates just the UI elements that need to be updated without triggering the enemy waves
		 */
		public function updateUI():void {
			if(_invalidComponents.length > 0) {
				for(var i:int = 0; i < _invalidComponents.length; i++) {
					_invalidComponents[i].update();
					_invalidComponents.splice(i, 1);
				}
			}
		}
		
		/**
		 * Updates the text of the gold TextField
		 */
		public function updateGoldTF(amt:int):void {
			_goldTF.text = amt.toString();
		}
		
		/**
		 * Updates the text of the hit point TextField
		 */
		public function updateHPTF(amt:int):void {
			_hpTF.text = amt.toString();
			
			if(amt <= 0) {
				Config.log('HudManager', 'updateHPTF', "HudManager at Zero HP");
				_removeListeners();
				Config.log('HudManager', 'updateHPTF', "HudManager dispatching endOfHP");
				endOfHP.dispatch();
			}
		}
		
		/**
		 * Updates the text of the waves TextField
		 */
		public function updateWaveTF(amt:int):void {
			_waveTF.text = amt.toString() + ' / ' + Config.maxWave.toString();
		}
		
		/**
		 * Handles when a ZFTextField needs to be rerendered
		 */
		public function handleInvalidTFComponent(tf:ZFTextField):void {
			_invalidComponents.push(tf);
		}
		
		/**
		 * Gets all groupStartPositions from the WaypointManager and loops through, creating
		 * a new NextWaveButton for each point and adds them to the screen
		 */
		public function showNextWaveButtons():void {
			var p:Array = play.wpMgr.groupStartPositions,
				len:int = p.length;
			for(var i:int = 0; i < len; i++) {
				var nextWaveBtn:NextWaveButton = new NextWaveButton(Assets.ta.getTexture('nextWaveBtn_' + p[i].dir));
				nextWaveBtn.x = p[i].pos.x;
				nextWaveBtn.y = p[i].pos.y;
				nextWaveBtn.onClicked.add(removeNextWaveButtons);
				_canvas.addChild(nextWaveBtn);
				_nextWaveBtns.push(nextWaveBtn);
			}
		}
		
		/**
		 * Handles the click event from the NextWaveButton, loops through all _nextWaveBtns
		 * and tells each one to fade out and destroy itself
		 */
		public function removeNextWaveButtons(triggerPause:Boolean = true):void {
			var len:int = _nextWaveBtns.length;			
			for(var i:int = 0; i < len; i++) {
				// tell all buttons to fade out and destroy
				_nextWaveBtns[i].fadeOut();
			}
			
			if(triggerPause) {
				play.onPauseEvent();
			}
		}
		
		private function _onTowerUpgradeClicked(evt:Event):void {
			if(_activeTower.canUpgrade()) {
				_activeTower.upgrade();
				showTowerData(_activeTower);
				if(_activeTower.level == _activeTower.maxLevel) {
					_hideTowerButtons();
					_showTowerButtons(false);
				}
			} else {
				trace("Cant create tower" );
			}
		}
		
		private function _onSellTowerClicked(evt:Event):void {
			play.towerMgr.sellTower(_activeTower);
		}
		
		private function _onPauseClicked(evt:Event):void {
			play.onPauseEvent();
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGamePaused():void {
			_resetPauseBtn(Assets.playBtnT);
			if(_optionsVisible) {
				_removeListeners();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGameResumed():void {
			_resetPauseBtn(Assets.pauseBtnT);
			if(!_optionsVisible) {
				_addListeners();
			}
		}
		
		private function _resetPauseBtn(t:Texture):void {
			if(_canvas.contains(_pauseBtn)) {
				_pauseBtn.removeFromParent(true);
				_pauseBtn.removeEventListener(Event.TRIGGERED, _onPauseClicked);
			}
			_pauseBtn = new Button(t);
			_pauseBtn.x = 520;
			_pauseBtn.y = 0;
			_pauseBtn.addEventListener(Event.TRIGGERED, _onPauseClicked);
			_canvas.addChild(_pauseBtn);
		}
		
		private function _onOptionsClicked(evt:Event):void {
			_optionsVisible = true;

			// clear any infotext, it will display OVER the options box
			showInfo('');
			
			// if gameOptions isn't already added to play.topLayer
			if(!play.topLayer.contains(_gameOptions)) {
				play.topLayer.addChild(_gameOptions);
			}
			
			play.onPauseEvent(true);
			_gameOptions.onDeactivated.add(_onOptionsDeactivated);
			_gameOptions.activate();
			_pauseBtn.removeEventListener(Event.TRIGGERED, _onPauseClicked);
		}
		
		private function _onOptionsDeactivated():void {
			_optionsVisible = false;
			
			_gameOptions.onDeactivated.remove(_onOptionsDeactivated);
			play.onPauseEvent(true);
			_pauseBtn.addEventListener(Event.TRIGGERED, _onPauseClicked);
		}
		
		/**
		 * Handles when the user clicks to create a tower
		 */
		private function _onClickTowerSelectIcon(towerData:Object, p:Point):void {
			if(!_optionsVisible && play.canCreateTower(towerData.id)) {
				play.createTower(towerData.id, p);
			}
		}
		
		private function _onHoverTowerSelectIcon(towerData:Object):void {
			if(!_optionsVisible) {
				generateTowerInfoHTML(towerData);
			}
		}
		
		public function showTowerData(t:Tower):void {
			_activeTower = t;
			var showUpgrade:Boolean = false;
			if(_activeTower.level < _activeTower.maxLevel) {
				showUpgrade = true;
			}
			_showTowerButtons(showUpgrade);
			generateTowerInfoHTML(t);
		}
		
		public function hideTowerData(t:Tower):void {
			if(_activeTower && _activeTower == t) {
				_activeTower = null;
				_hideTowerButtons();
				showInfo('');
			}
		}
		
		public function generateTowerInfoHTML(towerData:Object):void {
			var fontOpenH1Tag:String = '<font color="#FFFFFF" size="22">',
			    fontOpenLabelTag:String = '<font color="#FFFFFF" size="18">',
			    fontCloseTag:String = '</font>',
			    tName:String = '',
				isTower:Boolean = towerData is Tower;

			if(isTower) {
				tName = towerData.towerName;
			} else {
				tName = towerData.name;
			}
			
			var txt:String = fontOpenH1Tag + tName + fontCloseTag + '<br><br>'
				+ fontOpenLabelTag + 'Level: ' + towerData.level + fontCloseTag + '<br>'
				+ fontOpenLabelTag + 'Cost: ' + towerData.levelData[towerData.level].cost + fontCloseTag + '<br>'
				+ fontOpenLabelTag + 'Damage: ' + towerData.levelData[towerData.level].damage + fontCloseTag + '<br>'
				+ fontOpenLabelTag + 'DPS: ' + towerData.levelData[towerData.level].dps + fontCloseTag + '<br>'
				+ fontOpenLabelTag + 'Speed: ' + towerData.levelData[towerData.level].speed + fontCloseTag + '<br>'
				+ fontOpenLabelTag + 'Range: ' + towerData.levelData[towerData.level].range + fontCloseTag + '<br>';
			
			if(isTower && towerData.level < towerData.maxLevel) {
				txt += fontOpenLabelTag + 'Upgrade Cost: ' + towerData.levelData[towerData.level + 1].cost + fontCloseTag + '<br>'
			}			
			
			showInfo(txt);
		}
		
		public function showInfo(msg:String):void {
			_infoText.text = msg;
		}
		
		private function _removeListeners():void {
			Config.currentWaveChanged.remove(updateWaveTF);
			Config.currentHPChanged.remove(updateHPTF);
			Config.currentGoldChanged.remove(updateGoldTF);
			_tower1.onHover.remove(_onHoverTowerSelectIcon);
			_tower1.onClick.remove(_onClickTowerSelectIcon);
			_tower2.onHover.remove(_onHoverTowerSelectIcon);
			_tower2.onClick.remove(_onClickTowerSelectIcon);
			
			_upgradeTowerBtn.removeEventListener(Event.TRIGGERED, _onTowerUpgradeClicked);
			_sellTowerBtn.removeEventListener(Event.TRIGGERED, _onSellTowerClicked);
			_optsBtn.removeEventListener(Event.TRIGGERED, _onOptionsClicked);
			_pauseBtn.removeEventListener(Event.TRIGGERED, _onPauseClicked);
		}
		
		private function _addListeners():void {
			Config.currentWaveChanged.add(updateWaveTF);
			Config.currentHPChanged.add(updateHPTF);
			Config.currentGoldChanged.add(updateGoldTF);
			_tower1.onHover.add(_onHoverTowerSelectIcon);
			_tower1.onClick.add(_onClickTowerSelectIcon);
			_tower2.onHover.add(_onHoverTowerSelectIcon);
			_tower2.onClick.add(_onClickTowerSelectIcon);
			
			_upgradeTowerBtn.addEventListener(Event.TRIGGERED, _onTowerUpgradeClicked);
			_sellTowerBtn.addEventListener(Event.TRIGGERED, _onSellTowerClicked);
			_optsBtn.addEventListener(Event.TRIGGERED, _onOptionsClicked);
			_pauseBtn.addEventListener(Event.TRIGGERED, _onPauseClicked);
		}
		
		private function _hideTowerButtons():void {
			_upgradeTowerBtn.visible = false;
			_sellTowerBtn.visible = false;
			_upgradeTowerBtn.removeEventListener(Event.TRIGGERED, _onTowerUpgradeClicked);
			_sellTowerBtn.removeEventListener(Event.TRIGGERED, _onSellTowerClicked);
		}
		
		private function _showTowerButtons(showUpgrade:Boolean = true):void {
			_sellTowerBtn.visible = true;
			_sellTowerBtn.addEventListener(Event.TRIGGERED, _onSellTowerClicked);
			
			if(showUpgrade) {
				_upgradeTowerBtn.visible = true;
				_upgradeTowerBtn.addEventListener(Event.TRIGGERED, _onTowerUpgradeClicked);
			}
		}
		
		public function destroy():void {
			Config.log('HudManager', 'destroy', "HudManager Destroying");
			
			_activeTower = null;

			_tower1.destroy();
			_tower1.removeFromParent(true);
			_tower1 = null;
			
			_tower2.destroy();
			_tower2.removeFromParent(true);
			_tower2 = null;
			
			Config.currentGoldChanged.removeAll();
			Config.currentHPChanged.removeAll();
			Config.currentWaveChanged.removeAll();
			
			_goldTF.destroy();
			_goldTF.removeFromParent(true);
			_goldTF = null;

			_hpTF.destroy();
			_hpTF.removeFromParent(true);
			_hpTF = null;
			
			_waveTF.destroy();
			_waveTF.removeFromParent(true);
			_waveTF = null;

			_upgradeTowerBtn.removeFromParent(true);
			_upgradeTowerBtn = null;
			
			_sellTowerBtn.removeFromParent(true);
			_sellTowerBtn = null;
			
			_optsBtn.removeFromParent(true);
			_sellTowerBtn = null;
			
			Config.log('HudManager', 'destroy', "HudManager Destroyed");
		}
	}
}
