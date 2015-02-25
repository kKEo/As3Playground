package com.zf.ui.gameOptions
{
	import com.greensock.TweenLite;
	import com.zf.core.Assets;
	import com.zf.core.Config;
	
	import flash.geom.Point;
	
	import feathers.controls.Slider;
	import feathers.themes.AzureMobileTheme;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class GameOptionsPanel extends Sprite
	{
		public var onActivated:Signal;
		public var onDeactivated:Signal;
		public var onQuitGame:Signal;
		
		private var _bkgd:Image;
		private var _musicSlider:Slider;
		private var _sfxSlider:Slider;
		private var _musicTF:TextField;
		private var _sfxTF:TextField;
		private var _fontName:String = 'Wizzta';
		private var _saveBtn:Button;
		private var _cancelBtn:Button;
		private var _quitBtn:Button;
		
		private var _startPos:Point;
		private var _endPos:Point;
		private var _activateTween:TweenLite;
		private var _deactivateTween:TweenLite;
		private var _sfxVolume:Number;
		private var _musicVolume:Number;
		
		public function GameOptionsPanel(startPos:Point, endPos:Point) {
			_startPos = startPos;
			_endPos = endPos;
			
			onActivated = new Signal();
			onDeactivated = new Signal();
			onQuitGame = new Signal();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_bkgd = new Image(Assets.gameOptionsBkgdT);
			addChild(_bkgd);
			
			new AzureMobileTheme(this);

			_musicSlider = new Slider();
			_musicSlider.name = 'musicVolume';
			_musicSlider.minimum = 0;
			_musicSlider.maximum = 100;
			_musicSlider.value = Config.musicVolume * 100;
			_musicSlider.step = 1;
			_musicSlider.page = 10;
			_musicSlider.x = 160;
			_musicSlider.y = 75;
			_musicSlider.width = 200;
			addChild(_musicSlider);
			
			_sfxSlider = new Slider();
			_sfxSlider.name = 'sfxVolume';
			_sfxSlider.minimum = 0;
			_sfxSlider.maximum = 100;
			_sfxSlider.value = Config.sfxVolume * 100;
			_sfxSlider.step = 1;
			_sfxSlider.page = 10;
			_sfxSlider.x = 160;
			_sfxSlider.y = 105;
			_sfxSlider.width = 200;
			addChild(_sfxSlider);
			
			_musicTF = new TextField(50, 32, _getPercentText(Config.musicVolume));
			_musicTF.fontName = _fontName
			_musicTF.x = 365;
			_musicTF.y = 60;
			_musicTF.color = 0xFFFFFF;
			_musicTF.fontSize = 24;
			addChild(_musicTF);
			
			_sfxTF = new TextField(50, 32, _getPercentText(Config.sfxVolume));
			_sfxTF.fontName = _fontName
			_sfxTF.x = 365;
			_sfxTF.y = 90;
			_sfxTF.color = 0xFFFFFF;
			_sfxTF.fontSize = 24;
			addChild(_sfxTF);
			
			_saveBtn = new Button(Assets.optsSaveBtnT);
			_saveBtn.x = 380;
			_saveBtn.y = 235;
			addChild(_saveBtn);
			
			_cancelBtn = new Button(Assets.optsCancelBtnT);
			_cancelBtn.x = 200;
			_cancelBtn.y = 235;
			addChild(_cancelBtn);
			
			_quitBtn = new Button(Assets.optsQuitBtnT);
			_quitBtn.x = 20;
			_quitBtn.y = 235;
			addChild(_quitBtn);
			
			x = _startPos.x;
			y = _startPos.y;
			visible = false;
			touchable = false;
		}
		
		public function init():void {
			_musicVolume = Config.musicVolume;
			_sfxVolume = Config.sfxVolume;
			_musicSlider.value = _musicVolume * 100;
			_sfxSlider.value = _sfxVolume * 100;
		}
		
		public function activate():void {
			init();
			visible = true;
			touchable = true;
			_addListeners();
			TweenLite.to(this, 1, {x: _endPos.x, y: _endPos.y, onComplete: _activateTweenComplete});
		}
		
		public function deactivate():void {
			_removeListeners();
			TweenLite.to(this, 1, {x: _startPos.x, y: _startPos.y, onComplete: _deactivateTweenComplete});
		}
		
		public function saveOptions():void {
			Config.musicVolume = _musicVolume;
			Config.sfxVolume = _sfxVolume;
			Config.saveGameOptions();
		}
		
		private function _onSaveTriggered(evt:Event):void {
			saveOptions();
			deactivate();
		}
		
		private function _onCancelTriggered(evt:Event):void {
			deactivate();
		}
		
		private function _onQuitTriggered(evt:Event):void {
			deactivate();
			onQuitGame.dispatch();
		}
		
		private function _sliderChangeHandler(evt:Event):void {
			var slider:Slider = Slider(evt.currentTarget),
				val:Number = slider.value / 100;
			
			switch(slider.name) {
				case 'musicVolume':
					_musicVolume = val;
					_musicTF.text = _getPercentText(_musicVolume)
					break;
				case 'sfxVolume':
					_sfxVolume = val;
					_sfxTF.text = _getPercentText(_sfxVolume)
					break;
			}
		}
		
		private function _getPercentText(percent:Number):String {
			return (int(percent * 100)).toString() + '%';
		}
		
		private function _activateTweenComplete():void {
			onActivated.dispatch();
		}
		
		private function _deactivateTweenComplete():void {
			visible = false;
			touchable = false;
			onDeactivated.dispatch();
		}
		
		private function _addListeners():void {
			_musicSlider.addEventListener(Event.CHANGE, _sliderChangeHandler);
			_sfxSlider.addEventListener(Event.CHANGE, _sliderChangeHandler);
			_saveBtn.addEventListener(Event.TRIGGERED, _onSaveTriggered);
			_cancelBtn.addEventListener(Event.TRIGGERED, _onCancelTriggered);
			_quitBtn.addEventListener(Event.TRIGGERED, _onQuitTriggered);
		}
		
		private function _removeListeners():void {
			_musicSlider.removeEventListener(Event.CHANGE, _sliderChangeHandler);
			_sfxSlider.removeEventListener(Event.CHANGE, _sliderChangeHandler);
			_saveBtn.removeEventListener(Event.TRIGGERED, _onSaveTriggered);
			_cancelBtn.removeEventListener(Event.TRIGGERED, _onCancelTriggered);
			_quitBtn.removeEventListener(Event.TRIGGERED, _onQuitTriggered);
		}
		
		public function destroy():void {
			_removeListeners();
			
			_bkgd.removeFromParent(true);
			_bkgd = null;
			
			_musicSlider.removeFromParent(true);
			_musicSlider = null;
			
			_sfxSlider.removeFromParent(true);
			_sfxSlider = null;
			
			_musicTF.removeFromParent(true);
			_musicTF = null;
			
			_sfxTF.removeFromParent(true);
			_sfxTF = null;
			
			_saveBtn.removeFromParent(true);
			_saveBtn = null;
			
			_cancelBtn.removeFromParent(true);
			_cancelBtn = null;
		}
	}
}