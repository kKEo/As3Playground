package com.zf.ui.waveTile
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;

	public class WaveTileBar extends Sprite
	{
		public var waveTileTouched:Signal;
		
		// currently at 60 FPS, delay how many frames before updating tiles
		// so 30 means update tiles twice a second
		private const UPDATE_DELAY:int = 15;
		private const TILE_X_MOVE_PER_TICK:Number = 0.5;
		private const UPDATE_DELAY_HURRIED:int = 4;
		private const TILE_X_MOVE_PER_TICK_HURRIED:Number = 5;
		
		private var _tiles:Array;
		private var _data:Object;
		private var _waveXCt:int;
		private var _waveXBuffer:int = 10;
		private var _updateCt:int;
		private var _waveTileBarBkgd:Image;
		private var _barSpeed:int;
		private var _lastTouchedTileId:String;
		private var _updateDelay:int;
		private var _tileXMovePerTick:Number;
		
		public function WaveTileBar(data:Object) {
			_data = data;
			_tiles = [];
			
			_waveXCt = 0;
			_updateCt = 0;
			_barSpeed = 0;
			
			waveTileTouched = new Signal(String);
			
			// add background
			_waveTileBarBkgd = new Image(Assets.waveTileBkgdT);
			_waveTileBarBkgd.touchable = false;
			addChild(_waveTileBarBkgd);
			
			_setDelayToDefault();
			
			_createWaveTiles();
		}
		
		private function _setDelayToDefault():void {
			_updateDelay = UPDATE_DELAY;
			_tileXMovePerTick = TILE_X_MOVE_PER_TICK;
		}
		
		private function _setDelayToHurried():void {
			_updateDelay = UPDATE_DELAY_HURRIED;
			_tileXMovePerTick = TILE_X_MOVE_PER_TICK_HURRIED;
		}
		
		public function update():void {
			if(_tiles.length > 0 && _updateCt % _updateDelay == 0) {
				var len:int = _tiles.length;
				for(var i:int = 0; i < len; i++) {
					_tiles[i].x -= _tileXMovePerTick;
				}
				
				if(_tiles[0].x <= 0) {
					// If user touched this tile to speed all tiles up
					if(_tiles[0].id == _lastTouchedTileId) {
						// reset vars so bar doesnt go faster anymore
						_lastTouchedTileId = '';
						_setDelayToDefault();
					}
					
					waveTileTouched.dispatch(_tiles[0].id);
					_removeFirstWaveTile();
				}
			}
			
			_updateCt++;
		}
		
		private function _removeFirstWaveTile():void {
			_tiles[0].removeFromParent(true);
			// have the tile run it's destroy function
			_tiles[0].destroy();
			// remove it from the array
			_tiles.shift();
		}
		
		private function _createWaveTiles():void {
			var len:int = _data.numWaves;
			for(var i:int = 0; i < len; i++) {
				var tile:WaveTile = new WaveTile(_data.waveTiles[i]);
				tile.onClick.add(onTileTouched);
				tile.onHover.add(onTileHovered);
				tile.x = _waveXCt;
				addChild(tile);
				
				_tiles.push(tile);
				
				_waveXCt += tile.width + _waveXBuffer;
			}
		}
		
		public function onTileTouched(tileId:String):void {
			Config.log('WaveTileBar', 'onTileTouched', "tile clicked " + tileId + " -- Speeding up bar!");
			
			_lastTouchedTileId = tileId;
			_setDelayToHurried();
		}
		
		public function onTileHovered(tileId:String, tilePt:Point):void {
			//Config.log('WaveTileBar', 'onTileHovered', tileId + " hovered");
		}
		
		public function destroy():void {
			var len:int = _tiles.length;
			for(var i:int = 0; i < len; i++) {
				_tiles[i].onTouch.remove();
				_tiles[i].onHover.remove();
				_tiles[i].removeFromParent(true);
				_tiles[i].destroy();
			}
			_tiles = null;
		}
	}
}
