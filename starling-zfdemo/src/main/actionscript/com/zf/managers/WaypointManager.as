package com.zf.managers
{
	import com.zf.objects.map.TileData;
	import com.zf.objects.map.WaypointData;
	import com.zf.objects.enemy.Enemy;
	
	import flash.geom.Point;
	import com.zf.states.Play;

	public class WaypointManager
	{
		public var groupStartPositions	: Array;
		
		private var _waypoints		: Object;
		private var _waypointDist	: Object;
		private var _tempEndpoints  : Object;
		private var _play:Play;
		private var _halfTileWidth 	: Number;
		private var _halfTileHeight : Number;
		
		
		public function WaypointManager(p:Play) {
			_play = p;
			_waypoints = {};
			_waypointDist = {};
			_tempEndpoints = {};
			groupStartPositions = [];
		}
		
		public function addWaypoint(tileData:TileData, pos:Point, halfTileWidth:Number, halfTileHeight:Number):void {
			// save values so we can use later
			_halfTileWidth = halfTileWidth;
			_halfTileHeight = halfTileHeight;
			var wpData:WaypointData = new WaypointData(tileData);
			wpData.setPoint(pos, halfTileWidth, halfTileHeight);
			
			for each(var group:String in wpData.groups) {
				if(!_waypoints[group]) {
					_waypoints[group] = [];
				}
			}
			
			// If this is a spawnpoint, add another point offscreen for the "real" spawnpoint
			if(wpData.isSpawnpoint) {
				// set index to 0, this will be the first point
				var tmpObj:Object = { 
					"src": wpData.srcImageName, 
					"isWalkable": true, 
					"wp": true, 
					"wpGroup": wpData.wpGroup, 
					"wpIndex": 0, 
					"sp": true, 
					"spDirection": wpData.spDirection
				};

				// create a new 'real' spawnpoint with data
				var spWaypoint:WaypointData = new WaypointData(new TileData(tmpObj));
				
				// add the newly created WP
				_waypoints[group].push(spWaypoint);
				
				// unset the former spawnpoint wp
				wpData.isSpawnpoint = false;
				wpData.spDirection = '';
			}
			
			// handle if this is an endpoint, saving the data for later
			if(wpData.isEndpoint) {
				for each(var groupName:String in wpData.groups) {
					if(!_tempEndpoints[groupName]) {
						_tempEndpoints[groupName] = [];
					}
					
					// Keep a copy to the last wp "so far", when we sort, we'll take this "last" wp
					// and add another one with the right values to be the real off-screen endpoint
					_tempEndpoints[groupName].push(wpData);
				}
			}
			
			_waypoints[group].push(wpData);
		}
		
		public function addGroupStartPosition(dir:String, pos:Point, halfTileWidth:Number, halfTileHeight:Number):void {
			groupStartPositions.push({dir: dir, pos: new Point(pos.x + halfTileWidth, pos.y + halfTileHeight)});
		}	
		
		/**
		 * Sorts all waypoints by group in _waypoints
		 */
		public function handleEndpointAndSort():void {
			var groupName:String;
			
			// Before sorting, handle the _tempEndpoints by adding a new WP that's the real
			// off-screen final endpoint wp
			for(groupName in _tempEndpoints) {
				// should only be ONE endpoint per group, so grab the 0th element
				var tempWP:WaypointData = _tempEndpoints[groupName][0];
				
				// Add one to the index so this point comes after the other endpoint
				var lastIndex:int = tempWP.wpIndex + 1;
				
				var tmpObj:Object = { 
					"src": tempWP.srcImageName, 
					"isWalkable": true, 
					"wp": true, 
					"wpGroup": tempWP.wpGroup, 
					"wpIndex": lastIndex, 
					"ep": true, 
					"epDirection": tempWP.epDirection
				};
				
				// create a new 'real' spawnpoint with XML
				var newWP:WaypointData = new WaypointData(new TileData(tmpObj));
				
				// add the newly created WP
				_waypoints[groupName].push(newWP);
				
				// set the former endpoint wp to be a regular waypoint now that we've added the new endpoint
				_waypoints[groupName][tempWP.wpIndex].isEndpoint = false;
				_waypoints[groupName][tempWP.wpIndex].epDirection = '';
				
				// empty vector of endpoints for the group
				_tempEndpoints[groupName] = null;
				delete _tempEndpoints[groupName];
			}
			
			// Loop through groups and sort them
			for(groupName in _waypoints) {
				// sort each group
				_waypoints[groupName].sort(_waypointSort);
			}
			
			_calcRouteDistance();
		}
		
		/**
		 * Returns a Vector of WaypointDatas for the groupName
		 */
		public function getWaypointsByGroup(groupName:String):Array {
			return _waypoints[groupName];	
		}
		
		/**
		 * Returns the total distance a group has to go before escaping
		 */
		public function getRouteDistance(groupName:String):Number {
			return _waypointDist[groupName];
		}
		
		/**
		 * The sort algorithm for sorting _.waypoints subgroups
		 */
		private function _waypointSort(a:WaypointData, b:WaypointData):int {
			if(a.wpIndex < b.wpIndex) {
				return -1;
			} else if(a.wpIndex > b.wpIndex) {
				return 1;
			} else {
				return 0;
			}
		}
		
		/**
		 * This function gets called when MAP_DRAW_COMPLETE event is triggered 
		 * after all waypoints (Except spawn/endpoints) have had x,y points assigned to them
		 * This iterates through groups and assigns the proper distance between waypoints
		 */
		private function _calcRouteDistance():void {
			// handle the xy values of spawn and endpoints before getting distances
			_handleSpawnEndpointXYValues();
			
			for(var groupName:String in _waypoints) {
				
				// Get distance of the route
				var dist:Number = 0;
				var prevWP:WaypointData;
				
				var newX:Number;
				var newY:Number;
				var dx:Number;
				var dy:Number
				var addedDist:Number = 0;
				
				for each(var wp:WaypointData in _waypoints[groupName]) {
					// handle the first vo
					if(!prevWP) {
						prevWP = wp;
						// skip the rest of the loop this round and get the next wp
						continue;
					}
					
					// figure out which direction we're heading next, get dx,dy 
					dx = wp.point.x - prevWP.point.x;
					dy = wp.point.y - prevWP.point.y;
					
					// Set the previousWP's next direction
					// So "from prevWP, which way should I face to the next WP"
					if(dx > 0 && dy == 0) {
						prevWP.nextDir = Enemy.ENEMY_DIR_RIGHT;
					} else if(dx < 0 && dy == 0) {
						prevWP.nextDir = Enemy.ENEMY_DIR_LEFT;
					} else if(dx == 0 && dy > 0) {
						prevWP.nextDir = Enemy.ENEMY_DIR_DOWN;
					} else if(dx == 0 && dy < 0) {
						prevWP.nextDir = Enemy.ENEMY_DIR_UP;
					}
					
					// find the distance
					// regular distance formula: Math.sqrt(dx * dx + dy * dy);
					// since we're only moving up, down, left, or right, never any diagonals
					// we can simplify because dx OR dy will always be 0 making squaring, then squarerooting useless
					// but we do want the Absolute value so distance is a positive number
					addedDist = Math.abs(dx) + Math.abs(dy);
					
					// sum the distance for later group totals
					dist += addedDist;
					
					// When unit begins heading towards this wp, now it knows the distance
					prevWP.distToNext = addedDist;
			
					// set current waypoint to previous
					prevWP = wp;
				}
				
				// add total distance to the group route
				_waypointDist[groupName] = dist;
			}
		}
		
		/**
		 * Once all waypoints have proper x,y values, this assigns the spawn/endpoints with proper x,y
		 */
		public function _handleSpawnEndpointXYValues():void {
			// quadrupling halfTileWidth and halfTileHeight so mobs start 2 full tile widths/heights off screen
			var tileWidth:int = _halfTileWidth << 2;
			var tileHeight:int = _halfTileHeight << 2;
			
			for(var groupName:String in _waypoints) {
				// get the length of this group
				var groupLen:int = _waypoints[groupName].length;
				
				// temp spawnpoint
				var sp:WaypointData = _waypoints[groupName][0];
				// temp first wp
				var fwp:WaypointData = _waypoints[groupName][1];
				
				// temp endpoint
				var ep:WaypointData = _waypoints[groupName][groupLen - 1];
				// temp next-to-last waypoint
				var ntlwp:WaypointData = _waypoints[groupName][groupLen - 2];
				
				// use fwp.regPoint to get the top-left corner coordinate for the tile
				var newX:Number = fwp.regPoint.x;
				var newY:Number = fwp.regPoint.y;
				var halfWidth:int = 0;
				var halfHeight:int = 0;
				
				switch(sp.spDirection) {
					case 'left':
						newX -= tileWidth;
						halfHeight = _halfTileHeight;
						sp.nextDir = Enemy.ENEMY_DIR_RIGHT;
						break;
					
					case 'up':
						newY -= tileHeight;
						halfWidth = _halfTileWidth;
						sp.nextDir = Enemy.ENEMY_DIR_DOWN;
						break;
					
					case 'right':
						newX += tileWidth;
						halfHeight = _halfTileHeight;
						sp.nextDir = Enemy.ENEMY_DIR_LEFT;
						break;
					
					case 'down':
						newY += tileHeight;
						halfWidth = _halfTileWidth;
						sp.nextDir = Enemy.ENEMY_DIR_UP;
						break;
				}
				
				// set the new point for the spawnpoint
				sp.setPoint(new Point(newX, newY), halfWidth, halfHeight);
				
				// reuse vars
				newX = ntlwp.regPoint.x;
				newY = ntlwp.regPoint.y;
				halfWidth = halfHeight = 0;
				
				switch(ep.epDirection) {
					case 'left':
						newX -= tileWidth;
						halfHeight = _halfTileHeight;
						break;
					
					case 'up':
						newY -= tileHeight;
						halfWidth = _halfTileWidth;
						break;
					
					case 'right':
						newX += tileWidth;
						halfHeight = _halfTileHeight;
						break;
					
					case 'down':
						newY += tileHeight;
						halfWidth = _halfTileWidth;
						break;
				}
				
				// set the new point for the endpoint
				ep.setPoint(new Point(newX, newY), halfWidth, halfHeight);
			}
		}
		
		public function destroy():void {
			_waypoints = null;
		}
	}
}