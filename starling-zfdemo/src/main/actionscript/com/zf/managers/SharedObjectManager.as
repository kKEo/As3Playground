package com.zf.managers
{
	import com.zf.core.Config;
	import com.zf.utils.ZFGameData;
	
	import flash.net.SharedObject;

	public class SharedObjectManager
	{
		public var so:SharedObject;

		private static var instance				: SharedObjectManager;
		private static var allowInstantiation	: Boolean;

		private const LOCAL_OBJECT_NAME			: String = 'zombieflambe_demo';

		/***
		 * Gets the singleton instance of SharedObjectManager or creates a new one
		 */
		public static function getInstance():SharedObjectManager {
			if (instance == null) {
				allowInstantiation = true;
				
				instance = new SharedObjectManager();
				
				allowInstantiation = false;
			}
			return instance;
		}

		public function SharedObjectManager() {
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SharedObjectManager.getInstance() instead of new.");
			} else {
				init();
			}
		}
		
		/**
		 * Initializes the class, if gameOptions hasn't been set before, create gameOptions
		 * Otherwise it initializes Config gameOptions from the shared object
		 */
		public function init():void {
			so = SharedObject.getLocal(LOCAL_OBJECT_NAME);
			if(!so.data.hasOwnProperty('gameOptions')) {
				// set up the global game options
				so.data.gameOptions = {
					musicVolume: Config.DEFAULT_SOUND_VOLUME,
					sfxVolume: Config.DEFAULT_SOUND_VOLUME
				};
				Config.musicVolume = Config.DEFAULT_SOUND_VOLUME
				Config.sfxVolume = Config.DEFAULT_SOUND_VOLUME
			} else {
				Config.musicVolume = so.data.gameOptions.musicVolume;
				Config.sfxVolume = so.data.gameOptions.sfxVolume;
			}
		}
		
		/**
		 * Create a new ZFdata object in name's place in data
		 * 
		 * @param {String} name the current game name
		 * @param {Boolean} updateThenSave if true, the function will call save, otherwise the user can save manually
		 */
		public function createGameData(name:String, updateThenSave:Boolean = false):void {
			so.data[name] = new ZFGameData();
			so.data.gameOptions = {
				musicVolume: Config.DEFAULT_SOUND_VOLUME,
				sfxVolume: Config.DEFAULT_SOUND_VOLUME
			};
			
			// Reset config values
			Config.musicVolume = Config.DEFAULT_SOUND_VOLUME;
			Config.sfxVolume = Config.DEFAULT_SOUND_VOLUME;

			if(updateThenSave) { 
				save();
			}
		}

		/**
		 * Gets a whole block of game data
		 * 
		 * @param {String} name the current game name
		 * @returns {Object} the game data Object requested by game name
		 */
		public function getGameData(name:String):Object {
			return (so.data[name]) ? so.data[name] : {};
		}

		/**
		 * Sets a whole block of game data
		 * 
		 * @param {Object} data the data we want to add
		 * @param {String} name the current game name or blank to use Config.currentGameSOID
		 * @param {Boolean} updateThenSave if true, the function will call save, otherwise the user can save manually
		 */
		public function setGameData(data:Object, name:String = '', updateThenSave:Boolean = false):void {
			if(name == '') {
				name = Config.currentGameSOID;
			}
			
			so.data[name] = Object(data);
			
			if(updateThenSave) { 
				save();
			}
		}

		/**
		 * Sets a single property from game data
		 * 
		 * @param {*} data the data we want to add
		 * @param {String} prop the name of the property to update
		 * @param {String} name the current game name or blank to use Config.currentGameSOID
		 * @param {Boolean} updateThenSave if true, the function will call save, otherwise the user can save manually
		 */
		public function setGameDataProperty(data:*, prop:String, name:String = '', updateThenSave:Boolean = false):void {
			if(name == '') {
				name = Config.currentGameSOID;
			}
			
			// check for nested property
			if(prop.indexOf('.') != -1) {
				// happens when you pass in 'upgrades.ptsTotal' will split by the . and
				// pass data in to so.data[name]['upgrades']['ptsTotal']
				var props:Array = prop.split('.');
				so.data[name][props[0]][props[1]] = data;
			} else {
				so.data[name][prop] = data;
			}
			
			
			if(updateThenSave) { 
				save();
			}
		}

		/**
		 * Gets a single property from game data
		 * 
		 * @param {String} prop the name of the property to update
		 * @param {String} name the current game name or blank to use Config.currentGameSOID
		 * @returns {*} the game data property requested
		 */
		public function getGameDataProperty(prop:String, name:String = ''):* {
			if(name == '') {
				name = Config.currentGameSOID;
			}
			return so.data[name][prop];
		}

		/**
		 * Sets the global gameOptions Object on the SO
		 * 
		 * @param {Object} data the gameOptions data we want to add
		 * @param {Boolean} updateThenSave if true, the function will call save, otherwise the user can save manually
		 */
		public function setGameOptions(data:Object, updateThenSave:Boolean = false):void {
			so.data.gameOptions.musicVolume = (!isNaN(data.musicVolume)) ? data.musicVolume : 0;
			so.data.gameOptions.sfxVolume = (!isNaN(data.sfxVolume)) ? data.sfxVolume : 0;
			
			if(updateThenSave) {
				trace("Saving game options: music: " + data.musicVolume + " -- sfx: " + data.sfxVolume);
				save();
			}
		}

		public function dev_WipeAllMem():void {
			createGameData('game1', true);
			createGameData('game2', true);
			createGameData('game3', true);
		}
		
		/**
		 * Gets the global gameOptions Object from the SO
		 * 
		 * @returns {Object} the saved gameOptions data
		 */
		public function getGameOptions():Object {
			return so.data.gameOptions;
		}

		/**
		 * Checks to see if a game name exists on the SO
		 * 
		 * @param {String} name the game name we want to check for to see if it exists
		 * @returns {Boolean} if the game exists or not
		 */
		public function gameExists(name:String):Boolean {
			return (so.data[name])
		}

		/**
		 * Saves the SO to the user's HD
		 */
		public function save():void {
			so.flush();
		}
	}
}