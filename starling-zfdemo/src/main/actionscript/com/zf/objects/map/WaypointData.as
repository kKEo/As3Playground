package com.zf.objects.map
{
	import flash.geom.Point;
	
	public class WaypointData extends TileData
	{
		/**
		 * Distance to next waypoint
		 */
		public var distToNext:Number = -1;
		
		/**
		 * The next direction the entity should face
		 */
		public var nextDir:String;
		
		/**
		 * the registration 0,0 X/Y point of the waypoint
		 */
		private var _regPointXY		: Point;
		
		/**
		 * the center X/Y point of the tile  
		 */
		private var _centerPointXY	: Point;
		
		/**
		 * the groups this waypoint belongs to
		 */
		public var groups		: Array;
		
		public function WaypointData(tileData:TileData)
		{
			super(tileData);

			_centerPointXY = new Point();
			_regPointXY = new Point();
			
			if(this.wpGroup.indexOf(',') != -1) {
				groups = this.wpGroup.split(',');
			} else {
				groups = [wpGroup]
			}
		}
		
		public function setPoint(p:Point, halfWidth:int = 0, halfHeight:int = 0):void {
			_regPointXY.x = p.x;
			_regPointXY.y = p.y;

			_centerPointXY.x = p.x + halfWidth;
			_centerPointXY.y = p.y + halfHeight;
		}
		
		public function get point():Point {
			return _centerPointXY;
		}
		
		public function get regPoint():Point {
			return _regPointXY;
		}	
		
		public function get centerPoint():Point {
			return _centerPointXY;
		}	
	}
}