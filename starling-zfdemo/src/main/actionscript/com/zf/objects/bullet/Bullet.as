package com.zf.objects.bullet
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.objects.enemy.Enemy;
	import com.zf.objects.tower.Tower;
	import com.zf.states.Play;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.extensions.PDParticleSystem;
	
	public class Bullet extends Sprite
	{
		public static const BULLET_STATE_1:String = '1';
		
		public var srcObj:Tower;
		public var destObj:Enemy;
		public var damage:Number;
		public var speed:Number;
		public var type:String;
		public var isDestroyed:Boolean = false;
		public var hitEnemy:Boolean = false;
		public var play:Play;
		public var uid:int;
		
		// used for movement
		public var angleRad:Number;
		public var angleDeg:Number;
		
		private var _animState:String;
		private var _animData:Object;
		private var _bulletGameSpeedFPS:Number;
		private var _bulletGameSpeed:Number;
		
		/**
		 * todo implement bullet animation
		 */
		private var _bulletBaseFPS:int = 4;
		

		private var _distToTargetX:Number;
		private var _distToTargetY:Number;
		private var _dx:Number;
		private var _dy:Number;
		private var _p1:Point = new Point(0, 0);
		private var _p2:Point = new Point(0, 0);
		private var _mapBounds:Rectangle;
		private var _img:Image;
		private var ps:PDParticleSystem;
		
		public function Bullet()
		{
			uid = Config.getUID();
			_animState = '';
		}
		
		public function init(t:Tower, e:Enemy, p:Play):void {
			srcObj = t;
			destObj = e;
			play = p;
			_mapBounds = play.map.paddedBounds;
			
			damage = t.nextDamage;
			speed = t.bulletSpeed;
			type = t.bulletType;
			hitEnemy = false;
			isDestroyed = false;
			
			_img = new Image(Assets.ta.getTexture(type));
			_img.width = t.bulletWidth;
			_img.height = t.bulletHeight;
			pivotX = _img.width >> 1;
			pivotY = _img.height >> 1;
			addChild(_img);
			
			x = t.x;
			y = t.y;
			
			// set up particles
			ps = new PDParticleSystem(Assets.sparkle1PEX, Assets.ta.getTexture('bullets/sparkle1'));
			_distToTargetX = x - destObj.x;
			_distToTargetY = y - destObj.y;
			angleRad = Math.atan2(_distToTargetY , _distToTargetX);
			ps.emitAngle = angleRad;
			
			_setInternalSpeeds();
			_addPEXToJuggler();
			//_setupAnimData();
			//_changeAnimState(BULLET_STATE_1);
		}
		
		
		public function update():void {
			_distToTargetX = x - destObj.x;
			_distToTargetY = y - destObj.y;
			
			angleRad = Math.atan2(_distToTargetY , _distToTargetX);
			angleDeg = (180 * angleRad) / Math.PI;
			
			// give the bullet a little spin
			rotation = angleRad + Math.random()*50;
			
			// find amount to move x and y by
			_dx = _bulletGameSpeed * Math.cos(angleRad);
			_dy = _bulletGameSpeed * Math.sin(angleRad);
			
			// actually move x and y
			x -= _dx;
			y -= _dy;
			_img.alpha = Math.random() + 0.3;
			
			ps.emitterX = x;
			ps.emitterY = y;
			ps.emitAngle = angleRad;
			
			// get bullet/enemy x/y points for distance hit test
			_p1.x = x;
			_p1.y = y;
			_p2.x = destObj.x;
			_p2.y = destObj.y;
			
			// check if bullet hit enemy by adding pivotX/Y divided by 2 
			// so the bullet hits closer to the center of the enemy
			if((Point.distance(_p1, _p2) < (pivotX + destObj.pivotX) >> 2)
				|| (Point.distance(_p1, _p2) < (pivotX + destObj.pivotX) >> 2))
			{
				hitEnemy = true;
			} 
				// if bullet didnt hit enemy, make sure it is still in map
			else if((x < _mapBounds.x) || (x > _mapBounds.width)
				|| (y < _mapBounds.y) || (y > _mapBounds.height))
			{
				destroy();
			}
		}
		private function _setInternalSpeeds():void {
			_bulletGameSpeed = Config.currentGameSpeed * speed;
			_bulletGameSpeedFPS = int(Config.currentGameSpeed * _bulletBaseFPS);
			// make sure _bulletGameSpeedFPS is at least 1
			if(_bulletGameSpeedFPS < 1) {
				_bulletGameSpeedFPS = 1;
			}
		}
		
		private function _setupAnimData():void {
			_animData = {};
			_animData[BULLET_STATE_1] = new MovieClip(Assets.ta.getTextures(type), _bulletGameSpeedFPS);
		}
		
		private function _changeAnimState(newState:String, forceChange:Boolean = false):void {
			// make sure they are different states before removing and adding MCs
			// unless foreceChange is true
			if(_animState != newState || forceChange) {
				_removeAnimDataFromJuggler()
				
				_animState = newState;
				
				_addAnimDataToJuggler()
			}
		}
		
		private function _removePEXFromJuggler():void {
			// remove the old particleSystem from juggler
			Play.zfJuggler.remove(ps);
			// remove the old particleSystem from Play
			play.removeChild(ps);
		}
		
		private function _addPEXToJuggler():void {
			// add the new particleSystem to the Juggler
			Play.zfJuggler.add(ps);
			// add the old particleSystem from Play
			play.addChild(ps);
			ps.emitterX = x;
			ps.emitterY = y;

			ps.start();
		}

		private function _removeAnimDataFromJuggler():void {
			// remove the old MovieClip from juggler
			Play.zfJuggler.remove(_animData[_animState]);
			// remove the old MovieClip from this Sprite
			removeChild(_animData[_animState]);
		}
		
		private function _addAnimDataToJuggler():void {
			// add the new MovieClip to the Juggler
			Play.zfJuggler.add(_animData[_animState]);
			// add the new MovieClip to the Sprite
			addChild(_animData[_animState]);
			// update pivot based on new data
			pivotX = width >> 1;
			pivotY = height >> 1;
		}
		
		public function onGameSpeedChange():void {
			// remove old data from juggler
			_removeAnimDataFromJuggler();
			
			// reset internal speeds
			_setInternalSpeeds();
			
			// reset animation data
			_setupAnimData();
			
			// reset animation state
			_changeAnimState(_animState, true);
		}
		
		public function destroy():void {
			//_removeAnimDataFromJuggler();
			removeChild(_img);
			_removePEXFromJuggler();

			isDestroyed = true;
		}
	}
}
