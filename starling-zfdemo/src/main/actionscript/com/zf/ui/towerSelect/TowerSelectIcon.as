package com.zf.ui.towerSelect
{
	import com.zf.core.Assets;
	
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TowerSelectIcon extends Sprite
	{
		public var onHover:Signal;
		public var onClick:Signal;
		
		private var _icon:Image;
		private var _data:Object;
		
		public function TowerSelectIcon(data:Object) {
			_data = data;
			_data.level = 0;
			
			// currently just a static image
			_icon = new Image(Assets.ta.getTexture(_data.imageName));
			addChild(_icon);
			
			onHover = new Signal(Object);
			onClick = new Signal(Object, Point);
			
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		private function _onTouch(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(this);
			if(touch) 
			{
				switch(touch.phase) {
					case TouchPhase.BEGAN:
						// using Sprite's localToGlobal function to take the x/y clicked on locally 
						// and convert it to stage x/y values
						onClick.dispatch(_data, localToGlobal(touch.getLocation(this)));
						break;
					
					case TouchPhase.HOVER:
						onHover.dispatch(_data);
						break;
				}
			}
		}
		
		public function destroy():void {
			removeEventListener(TouchEvent.TOUCH, _onTouch);
			
			onHover.removeAll();
			onClick.removeAll();
			
			_icon.removeFromParent(true);
			_icon = null;
			
			removeFromParent(true);
		}
	}
}