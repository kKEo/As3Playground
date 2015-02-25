package com.zf.ui.text
{
	import com.zf.core.Assets;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	public class ZFTextField extends Sprite
	{
		public var componentIsInvalid:Signal;
		
		private var _tf:TextField;
		private var _icon:Image;
		private var _textVal:String;
		private var _bkgdShape:Image;
		
		public function ZFTextField(iconName:String, fontName:String, startValue:String = '')
		{
			var _s:Shape = new Shape();
			_s.graphics.lineStyle(2);
			_s.graphics.beginFill(0xFFFFFF);
			_s.graphics.drawRoundRect(0, 0, 80, 26, 8, 8)
			_s.graphics.endFill();

			var _bmd:BitmapData = new BitmapData(_s.width, _s.height, true, 0);
			_bmd.draw(_s);
			
			_bkgdShape = Image.fromBitmap(new Bitmap(_bmd, "auto", true));
			_bkgdShape.alpha = .4;
			_bkgdShape.x = 20;
			_bkgdShape.y = 5;
			_bkgdShape.touchable = false;
			addChild(_bkgdShape);
			
			_icon = new Image(Assets.ta.getTexture(iconName));
			_icon.x = 0;
			_icon.y = 2;
			_icon.touchable = false;
			addChild(_icon);
			
			_tf = new TextField(80, 32, startValue);
			_tf.fontName = fontName
			_tf.x = 30;
			_tf.y = 2;
			_tf.color = 0xCC2323;
			_tf.fontSize = 20;
			_tf.touchable = false;
			addChild(_tf);
			
			componentIsInvalid = new Signal(ZFTextField);
			
			touchable = false;
		}
		
		/**
		 * Updates TextField with text value and renders
		 */
		public function update():void {
			_tf.text = _textVal;
		}
		
		/**
		 * Set _textVal and dispatches componentIsInvalid so the component will be re-rendered next render
		 */
		public function set text(val:String):void {
			_textVal = val;
			componentIsInvalid.dispatch(this);
		}
		
		/**
		 * Get _textVal
		 * 
		 * @return {Boolean} _textVal
		 */
		public function get text():String {
			return _textVal;
		}
		
		/**
		 * Handles removing all items from this sprite and removing listeners
		 */
		public function destroy():void {
			componentIsInvalid.removeAll();
			componentIsInvalid = null;
			
			_tf.removeFromParent(true);
			_tf = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_bkgdShape.removeFromParent(true);
			_bkgdShape = null;
			
			_textVal = null;
		}
	}
}