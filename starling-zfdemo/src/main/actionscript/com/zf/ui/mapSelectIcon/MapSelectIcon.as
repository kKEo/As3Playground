package com.zf.ui.mapSelectIcon
{
	import com.zf.core.Assets;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	public class MapSelectIcon extends Sprite
	{
		public var onHover:Signal;
		public var onClick:Signal;
		
		private var _icon:Image;
		private var _data:Object;
		private var _tf:TextField;
		
		public function MapSelectIcon(data:Object, textureName:String) {
			_data = data;
			
			_icon = new Image(Assets.ta.getTexture(textureName));
			addChild(_icon);
			
			_tf = new TextField(200, 60, _data.title, 'Wizzta', 42, 0xCC2323);
			_tf.x = -45;
			_tf.y = 100;
			addChild(_tf);
			
			onHover = new Signal(Object);
			onClick = new Signal(Object);
			
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		public function destroy():void {
			onHover.removeAll();
			onClick.removeAll();
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_tf.removeFromParent(true);
			_tf = null;
			
			removeFromParent(true);
		}
		
		private function _onTouch(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(this);
			if(touch) 
			{
				switch(touch.phase) {
					case TouchPhase.BEGAN:
						//Config.log('MapSelectIcon', '_onTouch', "Clicked " + _data.id);
						onClick.dispatch(_data);
						break;
					
					case TouchPhase.HOVER:
						//Config.log('WaveTile', '_onTouch', "Hovered " + _data.id);
						onHover.dispatch(_data);
						break;
				}
			}
		}
	}
}