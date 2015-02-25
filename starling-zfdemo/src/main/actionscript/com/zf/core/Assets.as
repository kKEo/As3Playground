package com.zf.core {
	import com.zf.loaders.CallBackObject;
	import com.zf.utils.MapData;
	import com.zf.utils.Utils;
	
	import flash.display.Bitmap;
	
	import org.osflash.signals.Signal;
	
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class Assets
	{
		public static var ta					: TextureAtlas;
		public static var atlas				: Bitmap;
		public static var atlasXML			: XML;
		
		/**
		 * Image Textures
		 */
		public static var bkgdT				: Texture;
		public static var logoT				: Texture;
		public static var gameStateBkgdT		: Texture;
		public static var optsCancelBtnT		: Texture;
		public static var optsSaveBtnT		: Texture;
		public static var optsQuitBtnT		: Texture;
		public static var optsBtnT			: Texture;
		public static var pauseBtnT			: Texture;
		public static var playBtnT			: Texture;
		public static var playBkgdT			: Texture;
		public static var deleteGameBtnT	: Texture;
		public static var playGameBtnT		: Texture;
		public static var newGameBtnT		: Texture;
		public static var upgradesBtnT		: Texture;
		public static var resetUpgradesBtnT : Texture;
		public static var mapSelectBtnT		: Texture;
		public static var loadGameBtnT		: Texture;
		public static var gameOverBkgdT		: Texture;
		public static var playMapBtnT		: Texture;
		public static var tryAgainBtnT		: Texture;
		public static var waveTileBkgdT		: Texture;
		public static var gameOptionsBkgdT	: Texture;
		
		// holds _mapSelectJSON
		public static var mapSelectData		: Object;
		public static var mapSelectJSON		: String;
		public static var mapData			: MapData;
		
		// holds _towerDataJSON
		public static var towerData			: Object;
		public static var towerDataJSON		: String;

		/**
		 * Particle files
		 */
		public static var sparkle1PEX		: XML;
		public static var enemyDiePEX		: XML;

		/**
		 * Fonts
		 */
		private static var calistoMT			: Bitmap;
		private static var calistoMTXML		: String;
		private static var wizztaB			: Bitmap;
		private static var wizztaXML			: String;
		
		private static var _soundLoadComplete	: Boolean = false;
		private static var _itemLoadComplete		: Boolean = false;
		private static var _soundsToLoad			: int = 0;
		private static var _itemsToLoad			: int = 0;
		
		public static var onInitialLoadComplete:Signal = new Signal();
		
		/**
		 * Loads initialAssets file
		 */
		public static function loadInitialAssets():void {
			Game.assetsLoader.addToLoad('initialAssets.json', onInitialAssetsLoadComplete);
			Game.assetsLoader.addToLoad('sounds.json', onInitialSoundsLoadComplete);
		}
		
		/**
		 * Callback function when initialAssets.json finishes loading
		 * 
		 * @param CallBackObject cbo 
		 */
		public static function onInitialAssetsLoadComplete(cbo:CallBackObject):void {
			var initAssets:Object = Utils.JSONDecode(cbo.data);
			_itemsToLoad = initAssets.files.length;
			var obj:Object;
			for(var i:int = 0; i < _itemsToLoad; i++) {
				obj = initAssets.files[i];
				Game.assetsLoader.addToLoad(obj.file, onAssetLoadComplete, obj.id, false, false, obj)
			}
			Game.assetsLoader.queue.load();
		}
		
		/**
		 * Callback handler for when the sounds json file has finished loading, 
		 * parses file and loads individual sounds
		 * 
		 * @param CallBackObject cbo 
		 */
		public static function onInitialSoundsLoadComplete(cbo:CallBackObject):void {
			var sndAssets:Object = Utils.JSONDecode(cbo.data);
			_soundsToLoad = sndAssets.files.length;
			var obj:Object;
			for(var i:int = 0; i < _soundsToLoad; i++) {
				obj = sndAssets.files[i];
				Game.assetsLoader.addToLoad(obj.file, onSoundAssetLoadComplete, obj.id, false, false)
			}
			Game.assetsLoader.queue.load();
		}
		
		/**
		 * Callback function when loading initialAssets
		 * 
		 * @param CallBackObject cbo 
		 */
		public static function onAssetLoadComplete(cbo:CallBackObject):void {
			_itemsToLoad--;
			Config.log('Assets', 'onAssetLoadComplete', 'LoadComplete: ' + cbo.name + " -- _itemsToLoad: " + _itemsToLoad);

			if(cbo.options != null 
				&& cbo.options.hasOwnProperty('convertToTexture') && cbo.options.convertToTexture) 
			{
				// Add a T to the end of the file id, and auto convert it from bitmap
				Assets[cbo.name + 'T'] = Texture.fromBitmap(cbo.data);
			} 
			else 
			{
				Assets[cbo.name] = cbo.data;
			}
			
			
			if(_itemsToLoad == 0) {
				_itemLoadComplete = true;
				_checkReady();
			}
		}
		
		/**
		 * Callback handler for sound assets load completion
		 * 
		 * @param CallBackObject cbo 
		 */
		public static function onSoundAssetLoadComplete(cbo:CallBackObject):void {
			_soundsToLoad--;
			Config.log('Assets', 'onSoundAssetLoadComplete', 'LoadComplete: ' + cbo.name + " -- Size: " + cbo.data.bytesTotal + " -- _soundsToLoad: " + _soundsToLoad);
			Game.soundMgr.addSound(cbo.name, cbo.data);
			
			if(_soundsToLoad == 0) {
				_soundLoadComplete = true;
				_checkReady();
			}
		}
		
		/**
		 * Called when assets load to check if everything has loaded
		 */
		private static function _checkReady():void {
			Config.log('Assets', 'onSoundAssetLoadComplete', "CheckReady: _itemLoadComplete: " + _itemLoadComplete + " || _soundLoadComplete: " + _soundLoadComplete);
			if(_itemLoadComplete && _soundLoadComplete) {
				onInitialLoadComplete.dispatch();
			}
		}
		
		/**
		 * Initializes Assets class converting some assets to more usable classes
		 */
		public static function init():void {
			ta = new TextureAtlas(Texture.fromBitmap(atlas), XML(atlasXML));
			
			TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(calistoMT), XML(calistoMTXML)));
			TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(wizztaB), XML(wizztaXML)));
			
			towerData = Utils.JSONDecode(towerDataJSON);
			mapData = new MapData(Utils.JSONDecode(mapSelectJSON));
		}
	}
}