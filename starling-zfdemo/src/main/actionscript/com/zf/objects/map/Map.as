package com.zf.objects.map
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.managers.WaypointManager;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import com.zf.objects.tower.Tower;

	public class Map extends Sprite
	{
		public var halfTileWidth:Number;
		public var halfTileHeight:Number;
		public var mapWidth:Number;
		public var mapHeight:Number;
		public var tileWidth:int;
		public var tileHeight:int;
		public var mapOffsetX:int;
		public var mapOffsetY:int;
		
		private var _mapData:Object;
		private var _tileData:Array;
		private var _wpMgr:WaypointManager;
		
		/**
		 * Tile data flattened down without layers, aggregating isWalkable data
		 */
		private var _flatTileData:Array;
		private var _mapWidthOffset:Number;
		private var _mapHeightOffset:Number;
		
		public function Map(data:Object, wpMgr:WaypointManager, mOffsetX:int, mOffsetY:int) {
			_mapData = data;
			_wpMgr = wpMgr;
			
			mapOffsetX = mOffsetX;
			mapOffsetY = mOffsetY;
			tileWidth = _mapData.tileWidth;
			tileHeight = _mapData.tileHeight;
			halfTileWidth = _mapData.tileWidth >> 1;
			halfTileHeight = _mapData.tileHeight >> 1;
			mapWidth = _mapData.tileWidth * _mapData.numCols;
			mapHeight = _mapData.tileHeight * _mapData.numRows;
			_mapWidthOffset = mapWidth + mapOffsetX;
			_mapHeightOffset = mapHeight + mapOffsetY;
			
			// initial layer level
			_tileData = [];
			_flatTileData = [];
			
			_parseMapDataIntoTileData();
			_drawMap();
		}
		
		private function _parseMapDataIntoTileData():void {
			var rowCt:int = 0,
				colCt:int = 0,
				layerCt:int = 0,
				mapLayerCt:int = 0;

			if(_mapData.drawBkgd) {
				var data:Object = {"src": _mapData.bkgdSrc, "isWalkable": false };
				_createBkgdLayerTileData(data);
				layerCt++;
			} else {
				mapLayerCt = layerCt;
			}

			for(layerCt; layerCt <= _mapData.numLayers; layerCt++) 
			{
				_tileData[layerCt] = [];

				for(rowCt = 0; rowCt < _mapData.numRows; rowCt++) 
				{
					_tileData[layerCt][rowCt] = [];

					for(colCt = 0; colCt < _mapData.numCols; colCt++) 
					{
						// map data doesnt have the bkgd layer
						var tileData2:TileData = new TileData(_mapData.tiles[mapLayerCt].layer[rowCt].row[colCt]);
						
						_tileData[layerCt][rowCt][colCt] = tileData2;
						
						if(_flatTileData[rowCt][colCt] is TileData) 
						{
							if(tileData2.isWalkable) 
							{
								// if any tiledata is walkable, set the position to true
								_flatTileData[rowCt][colCt].isWalkable = true;
								_flatTileData[rowCt][colCt].srcImageName = tileData2.srcImageName;
							}
						} 
						else 
						{
							_flatTileData[rowCt][colCt] = tileData2;
						}
					}
				}
				mapLayerCt++;
			}
		}
		
		private function _createBkgdLayerTileData(data:Object):void {
			var rowCt:int = 0;
			var colCt:int = 0;
			
			// create the first empty row array
			_tileData[0] = [];
			
			for(rowCt; rowCt < _mapData.numRows; rowCt++) 
			{
				_tileData[0][rowCt] = [];
				
				if(_flatTileData[rowCt] == undefined) {
					_flatTileData[rowCt] = [];	
				}
				
				for(colCt = 0; colCt < _mapData.numCols; colCt++) 
				{
					var bkgdTile:TileData = new TileData(data);
					_tileData[0][rowCt][colCt] = bkgdTile;
					
					// get another tile for _flatTileData
					bkgdTile = new TileData(data);
					_flatTileData[rowCt][colCt] = bkgdTile;
				}
			}
		}
		
		private function _drawMap():void {
			var currentLayer:int = 0;
			var maxLayers:int = _mapData.numLayers;
			
			if(_mapData.drawBkgd) {
				maxLayers++;
			}
			
			for(currentLayer; currentLayer < maxLayers; currentLayer++) {
				_drawLayer(currentLayer);
			}
			
			// flatten this map once it has been drawn
			this.flatten();
			
			// Map is done drawing and adding waypoints, so lets clean up WaypointManager
			_wpMgr.handleEndpointAndSort();
		}
		
		private function _drawLayer(layer:int):void {
			var srcImage:Image;
			var destPt:Point = new Point();
			var destRect:Rectangle = new Rectangle(0, 0, _mapData.tileWidth, _mapData.tileHeight);
			var rowCt:int = 0;
			var colCt:int = 0;
			var tileData:TileData;
			var pt:Point = new Point();
			
			for(rowCt; rowCt < _mapData.numRows; rowCt++) 
			{
				for(colCt = 0; colCt < _mapData.numCols; colCt++) 
				{
					tileData = _tileData[layer][rowCt][colCt];
					
					// if this tile does not have a source image name for this layer, skip drawing it
					if(tileData.srcImageName == '') {
						continue;
					}

					var tmpTexture:Texture = Assets.ta.getTexture(tileData.srcImageName),
						xOffset:int = (_mapData.tileWidth - tmpTexture.width) >> 1,
						yOffset:int = (_mapData.tileHeight - tmpTexture.height) >> 1,
						rect:Rectangle = new Rectangle(-xOffset, -yOffset, _mapData.tileWidth, _mapData.tileHeight),
						texture:Texture = Texture.fromTexture(tmpTexture, null, rect);

					srcImage = new Image(texture);
					
					srcImage.x = pt.x = (colCt * _mapData.tileWidth);
					srcImage.y = pt.y = (rowCt * _mapData.tileHeight);
					
					addChild(srcImage);
					
					if(tileData.isWaypoint) {
						pt.x += mapOffsetX;
						pt.y += mapOffsetY;
						_wpMgr.addWaypoint(tileData, pt, halfTileWidth, halfTileHeight);
					}
					
					if(tileData.groupStartIconDir != '') {
						// Adding mapOffsets again here because isWaypoint and groupStartIconDir 
						// will never exist on the same tile
						pt.x += mapOffsetX;
						pt.y += mapOffsetY;
						_wpMgr.addGroupStartPosition(tileData.groupStartIconDir, pt, halfTileWidth, halfTileHeight);
					}
				}
			}
		}
		
		public function destroy():void {
			removeFromParent(true);
		}
		
		public function checkCanPlaceTower(p:Point):Object {
			var retObj:Object = {};
			retObj.canPlace = false;
			retObj.point = new Point(-1, -1);

			// make sure we clicked inside the actual map before further checks
			if(clickedInsideMap(p)) {
				// p is a reference to coordinates from the stage, we want to remove the offset
				// to get just the coordinates relative to the map itself for the array keys
				var rowCt:int = int((p.y - mapOffsetX) / _mapData.tileHeight);
				var colCt:int = int((p.x - mapOffsetY) / _mapData.tileWidth);
				var t:TileData = _flatTileData[rowCt][colCt];

				// If isWalkable == true or isTower == true, then canPlace = false, we cannot place tower on walkway/tower
				retObj.canPlace = ((_flatTileData[rowCt][colCt].isWalkable == false) && (_flatTileData[rowCt][colCt].isTower == false));
				if(retObj.canPlace) {
					retObj.point.x = colCt * _mapData.tileWidth;
					retObj.point.y = rowCt * _mapData.tileHeight;
				}
			}
			
			return retObj;
		}
		
		public function placedTower(t:Tower):void {
			var rowCt:int = int((t.y - mapOffsetX) / _mapData.tileHeight);
			var colCt:int = int((t.x - mapOffsetY) / _mapData.tileWidth);
			
			_flatTileData[rowCt][colCt].isTower = true;
		}
		
		public function removeTower(t:Tower):void {
			var rowCt:int = int((t.y - mapOffsetX) / _mapData.tileHeight);
			var colCt:int = int((t.x - mapOffsetY) / _mapData.tileWidth);
			
			_flatTileData[rowCt][colCt].isTower = false;
		}
		
		public function clickedInsideMap(p:Point):Boolean {
			var clickedMap:Boolean = false;

			if(p.x > 0 && p.x < _mapWidthOffset &&
				p.y > 0 && p.y < _mapHeightOffset)  {
				clickedMap = true;
			}
			return clickedMap;
		}
		
		/**
		 * Returns the bounds Rectangle with x & width "padded" by tileWidth 
		 * and y & height padded by tileHeight
		 */
		public function get paddedBounds():Rectangle {
			var paddedBoundsRect:Rectangle = new Rectangle();
			paddedBoundsRect.x -= tileWidth - mapOffsetX;
			paddedBoundsRect.y -= tileHeight - mapOffsetY;
			paddedBoundsRect.width = this.width + tileWidth + mapOffsetX;
			paddedBoundsRect.height = this.height + tileHeight + mapOffsetY;
			return paddedBoundsRect;
		}
		
		public function get startHP():int {
			return _mapData.startHP;
		}
		
		public function get startGold():int {
			return _mapData.startGold;
		}
	}
}