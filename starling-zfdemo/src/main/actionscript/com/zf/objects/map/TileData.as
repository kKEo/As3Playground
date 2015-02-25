package com.zf.objects.map
{
	public class TileData
	{
		/**
		 * is the tile able to be walked on
		 */
		public var isWalkable	: Boolean = false;
		
		/**
		 * if this tile contains a tower
		 */
		public var isTower		: Boolean = false;
		
		/**
		 * zero-index source rect to use from the tilesheet
		 */
		public var srcImageName	: String;
		
		/**
		 * is this tile a waypoint
		 */
		public var isWaypoint	: Boolean = false;
		
		/**
		 * Which waypoint group(s) does this tile belong to
		 */
		public var wpGroup		: String;
		
		/**
		 * What is the waypoint index of this tile
		 */
		public var wpIndex		: int;
		
		/**
		 * Is this tile a spawnpoint
		 */
		public var isSpawnpoint	: Boolean = false;
		
		/**
		 * If isSpawnpoint, which direction should the spawnpoint be?
		 */
		public var spDirection	: String;
		
		/**
		 * Is this tile an endpoint
		 */
		public var isEndpoint	: Boolean = false;
		
		/**
		 * If isEndpoint, which direction should the endpoint be?
		 */
		public var epDirection	: String;
		
		/**
		 * If this is where a NextWaveButton should go
		 */
		public var groupStartIconDir : String = '';

		/**
		 * Hold the initial object data that was used to create the tile
		 */
		private var _data:Object;
		
		public function TileData(data:Object) {
			_data = data;
			
			if(data.hasOwnProperty('src')) {
				srcImageName = data.src;
			} else if(data.hasOwnProperty('src')) {
				srcImageName = data.srcImageName;
			} else {
				srcImageName = '';
			}
			
			isWalkable = data.isWalkable;
			
			/**
			 * Handle if this is a waypoint
			 */
			if(data.hasOwnProperty('wp')) {
				isWaypoint = data.wp;
				wpIndex = data.wpIndex;
				wpGroup = data.wpGroup;
			} else if(data.hasOwnProperty('isWaypoint')) {
				isWaypoint = data.isWaypoint;
				wpIndex = data.wpIndex;
				wpGroup = data.wpGroup;
			}
			
			/**
			 * Handle if this is a spawnpoint
			 */
			if(data.hasOwnProperty('sp')) {
				isSpawnpoint = data.sp;
				spDirection = data.spDirection;
			} else if(data.hasOwnProperty('isSpawnpoint')) {
				isSpawnpoint = data.isSpawnpoint;
				spDirection = data.spDirection;
			}
			
			/**
			 * Handle if this is an endpoint
			 */
			if(data.hasOwnProperty('ep')) {
				isEndpoint = data.ep;
				epDirection = data.epDirection;
			} else if(data.hasOwnProperty('isEndpoint')) {
				isEndpoint = data.isEndpoint;
				epDirection = data.epDirection;
			}
			
			/**
			 * Handle if this is a groupStart location
			 */
			if(data.hasOwnProperty('groupStartIcon')) {
				groupStartIconDir = data.groupStartIcon;
			}
		}
	}
}