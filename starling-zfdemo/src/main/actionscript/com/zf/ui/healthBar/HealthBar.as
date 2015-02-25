package com.zf.ui.healthBar
{
	import com.zf.objects.enemy.Enemy;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class HealthBar extends Sprite
	{
		private var _healthBar  : Image;
		private var _healthCurrent:int;
		private var _healthMax:int;
		private var _drawWidth:int;
		private var _enemy:Enemy;
		private var _healthWidth:Number;
		private var _percentDmg:Number;
		
		private var _s:Shape;
		private var _bmd:BitmapData;
		
		public function HealthBar(parentEnemy:Enemy, currentHP:int, maxHP:int, drawWidth:int = 20)
		{
			_enemy = parentEnemy;
			_healthCurrent = currentHP;
			_healthMax = maxHP;
			_drawWidth = drawWidth;
			
			_percentDmg = 0;
			_healthWidth = _drawWidth;
			
			_s = new Shape();
			update();
		}

		public function update():void {
			if(contains(_healthBar)) {
				_healthBar.removeFromParent(true);
			}
			
			_s.graphics.clear();
			
			// draw container
			_s.graphics.lineStyle(1, 0);
			_s.graphics.beginFill(0, 0);
			_s.graphics.drawRect(0, 0, _drawWidth, 5);
			_s.graphics.endFill();
			
			var fillCol:uint = 0x009999;
			
			if(_percentDmg > .35 && _percentDmg <= .69) {  
				fillCol = 0xE3EF24;
			} else if(_percentDmg > 0 && _percentDmg <= .34) {
				fillCol = 0xFF0000;
			}
			
			// draw current health
			_s.graphics.lineStyle(0, fillCol, 1, true);
			_s.graphics.beginFill(fillCol);
			_s.graphics.drawRect(1, 1, _healthWidth - 2, 3);
			_s.graphics.endFill();
			
			_bmd = new BitmapData(_s.width << 1, _s.height << 1, true, 0);
			_bmd.draw(_s);
			
			_healthBar = Image.fromBitmap(new Bitmap(_bmd, "auto", true));
			_healthBar.touchable = false;
			_healthBar.x = _s.width >> 1;
			addChild(_healthBar);
		}

		public function takeDamage(dmg:Number):void {
			_healthWidth -= _drawWidth * (dmg / _healthMax);
			_percentDmg = _healthWidth / _drawWidth;
			update();
		}
	}
}
