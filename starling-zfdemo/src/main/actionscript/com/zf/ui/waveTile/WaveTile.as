package com.zf.ui.waveTile
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class WaveTile extends Sprite
	{
		public var onClick:Signal;
		public var onHover:Signal;
		
		private var _tileImg:Image;
		private var _data:Object;
		
		public function WaveTile(waveTileData:Object) {
			_data = waveTileData;
			
			_tileImg = new Image(Assets.ta.getTexture(_data.image));
			addChild(_tileImg);
			
			onHover = new Signal(String, Point);
			onClick = new Signal(String);
			
			addEventListener(TouchEvent.TOUCH, _onTileImageClick);
		}
		
		private function _onTileImageClick(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(this);
			if(touch) 
			{
				switch(touch.phase) {
					case TouchPhase.BEGAN:
						Config.log('WaveTile', '_onTileImageClick', "WaveTile::_onTileImageClick CLICKED " + id);
						onClick.dispatch(id);
						break;
					
					case TouchPhase.HOVER:
						//Config.log('WaveTile', '_onTileImageClick', "WaveTile::_onTileImageClick HOVERED"  + id);
						onHover.dispatch(id, touch.getLocation(this));
						break;
				}
			}
		}
		
		public function get id():String {
			return _data.id;
		}
		
		public function get image():String {
			return _data.image;
		}
		
		public function get title():String {
			return _data.title;
		}
		
		public function get desc():String {
			return _data.desc;
		}
		
		public function destroy():void {
			Config.log('WaveTile', 'destroy', "Destroying Wave Tile " + id);
			removeEventListener(TouchEvent.TOUCH, _onTileImageClick);
			removeChild(_tileImg);
			onHover.removeAll();
			onClick.removeAll();
		}
	}
}
