package com.zf.objects
{
	import com.zf.core.Assets;
	import com.zf.objects.enemy.types.EnemyA;
	import com.zf.objects.tower.Tower;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class Projectile extends Sprite
	{
		public var srcObj:Tower;
		public var destObj:EnemyA;
		public var damage:Number;
		public var speed:Number;
		
		public function Projectile()
		{
			var img:Image = new Image(Assets.ta.getTexture('projectiles/sparkle_blue_001'));
			img.scaleX = .5;
			img.scaleY = .5;
			pivotX = img.width >> 1;
			pivotY = img.height >> 1;
			addChild(img);
		}
		
		public function setBulletObject(t:Tower, e:EnemyA):void {
			srcObj = t;
			destObj = e;
			damage = t.damage;
			speed = t.speed;
		}
	}
}