/**
 * 
 Example usage:
 _ttf1 = new ZFTimedTextField(200, 50, 0, 1000);
 _ttf1.x = 30;
_ttf1.y = 100;
addChild(_ttf1);
_ttf1.label = "Complete1:";
_ttf1.start();
 
 *  */
package com.zf.ui.text
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	
	public class ZFTimedTextField extends Sprite
	{
		public var fontName:String = 'Verdana';
		public var fontSize:int = 15;
		public var fontColor:uint = 0xFFFFFF;
		public var labelWidth:int = 100;
		
		private var _timer:Timer;
		private var _start:Number;
		private var _end:Number;
		private var _repeatCount:int;
		private var _currentCt:Number;
		private var _increment:Number;
		private var _tf:TextField;
		private var _tfLabel:TextField;
		
		// basically clocks in at 40FPS
		private var _timerDelay:int = 20;
		
		public function ZFTimedTextField(w:int, h:int, start:Number, end:Number, runTime:int = 2000) {
			_start = _currentCt = start;
			_end = end;
			_repeatCount = int(runTime / _timerDelay);
			_increment = (_end - _start) / _repeatCount;
			
			_timer = new Timer(_timerDelay, _repeatCount);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, _onTimerComplete);
			
			_tf = new TextField(w, h, _start.toString(), fontName, fontSize, fontColor);
			_tf.hAlign = 'left';
			addChild(_tf);
		}
		
		public function start():void {
			_timer.start();
		}
		
		public function set label(text:String):void {
			if(text != '') {
				_tfLabel = new TextField(labelWidth, _tf.height, text, fontName, fontSize, fontColor);
				_tfLabel.x = 0;
				_tfLabel.y = 0;
				addChild(_tfLabel);
				_tf.x = _tfLabel.width + 5;
			} else {
				if(contains(_tfLabel)) {
					_tfLabel.removeFromParent(true);
					_tfLabel = null;
				}
			}
			
		}
		public function destroy():void {
			_tf.removeFromParent(true);
			_tf = null;
			
			if(contains(_tfLabel)) {
				_tfLabel.removeFromParent(true);
				_tfLabel = null;
			}
		}
		
		private function _onTimer(evt:TimerEvent):void {
			_currentCt += _increment;
			_tf.text = int(_currentCt).toString();
		}
		
		private function _onTimerComplete(evt:TimerEvent):void {
			_tf.text = _end.toString();
			
			_timer.removeEventListener(TimerEvent.TIMER, _onTimer);
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, _onTimerComplete);
			_timer = null;
		}
	}
}