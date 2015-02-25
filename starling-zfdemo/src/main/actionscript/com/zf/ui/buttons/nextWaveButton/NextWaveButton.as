package com.zf.ui.buttons.nextWaveButton
{
	import com.greensock.TweenLite;
	import com.zf.core.Config;
	import com.zf.core.Game;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class NextWaveButton extends Sprite
	{
		public var onClicked:Signal;
		
		private var _btn:Button;
		
		public function NextWaveButton(btnT:Texture) {
			super();
		
			onClicked = new Signal();
			
			_btn = new Button(btnT);
			addChild(_btn);
			
			pivotX = _btn.width >> 1;
			pivotY = _btn.height >> 1;
			
			_btn.addEventListener(Event.TRIGGERED, _onBtnTriggered);
			expand();
		}
		
		/**
		 * Called by HudManager when this or any other NextWaveButton is clicked
		 * This makes the NextWaveButton shrink to 0 and fade out, then when 
		 * the tween is complete, it calls destroy to remove itself
		 */
		public function fadeOut():void {
			TweenLite.to(this, .5, {alpha: 0, scaleX: 0, scaleY: 0, onComplete: destroy});
		}
		
		private function _onBtnTriggered(evt:Event):void {
			_btn.removeEventListener(Event.TRIGGERED, _onBtnTriggered);
			onClicked.dispatch();
		}
		
		private function expand():void {
			TweenLite.to(this, 0.5, {scaleX: 1.2, scaleY: 1.2, onComplete: contract});
		}
		
		private function contract():void {
			TweenLite.to(this, 0.5, {scaleX: 0.8, scaleY: 0.8, onComplete: expand});
		}

		public function destroy():void {
			_btn.removeFromParent(true);
			_btn = null;
			
			onClicked.removeAll();
			
			removeFromParent(true);
		}
	}
}