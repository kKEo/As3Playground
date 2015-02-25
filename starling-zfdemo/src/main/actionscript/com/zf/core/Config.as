package com.zf.core
{
	import com.zf.utils.ZFGameData;
	
	import org.osflash.signals.Signal;
	
	public class Config {
		
		/**
		 * PATH CONSTANTS
		 */
		public static const PATH_ASSETS			: String = "assets/";
		public static const PATH_JSON			: String = Config.PATH_ASSETS + "json/";
		public static const PATH_XML				: String = Config.PATH_ASSETS + "xml/";
		public static const PATH_SCENES			: String = Config.PATH_JSON + "scenes/";
		public static const PATH_IMG				: String = Config.PATH_ASSETS + "images/";
		public static const PATH_SOUNDS			: String = Config.PATH_ASSETS + "sounds/";
		
		/**
		 * dataType constants
		 */
		public static const DATA_XML				: String = 'xml';
		public static const DATA_JSON			: String = 'json';
		public static const DATA_PEX				: String = 'pex';
		public static const DATA_FNT				: String = 'fnt';
		public static const DATA_MP3				: String = 'mp3';

		public static const IMG_PNG				: String = 'png';
		public static const IMG_JPG				: String = 'jpg';
		public static const IMG_GIF				: String = 'gif';
		
		public static const GAME_SPEED_UP		: String = 'up';
		public static const GAME_SPEED_DOWN		: String = 'down';
		
		/**
		 * Signals
		 */
		public static var currentWaveChanged		: Signal = new Signal(int);
		public static var currentHPChanged		: Signal = new Signal(int);
		public static var currentGoldChanged		: Signal = new Signal(int);
		public static var onGameSpeedChange		: Signal = new Signal();
		
		/**
		 * Game Data
		 */
		public static var currentGameSOID		: String = 'game1';
		public static var currentGameSOData		: ZFGameData = new ZFGameData();
		
		/**
		 * Timer Config
		 */
		public static var activeGameTime			: Number = 0;
		public static var pausedGameTime			: Number = 0;
		
		/**
		 * Volume Config
		 */
		public static var musicVolume			: Number = 0.75;
		public static var sfxVolume				: Number = 0.75;
		public static const DEFAULT_SOUND_VOLUME	: Number = 0.75;
		
		/**
		 * Map Config
		 */
		public static var selectedMap			: String = 'map1';
		public static var currentMapNumber		: int = 1;
		public static var currentMapData			: Object = {};
		
		/**
		 * Game Speed Config
		 */
		public static var currentGameSpeed		: Number;

		/**
		 * Maximum number of waves this map
		 */
		public static var maxWave				: int;
		
		/**
		 * What is the game over condition code
		 */
		public static var gameOverCondition		: int;
		
		/**
		 * Keeps track of total number of things
		 */
		public static var totals					: Totals;
		
		/**
		 * Debugger Config
		 */
		public static var debugMode				: Boolean = false;
		public static var debugVerbose			: Boolean = true;
		
		/**
		 * Current Map Stats
		 */
		private static var _currentGold			: int;
		private static var _currentHP			: int;
		private static var _currentWave			: int;
		
		/**
		 * Valid game speeds config
		 */
		private static var _gameSpeeds:Array = 	[0.5, 1, 2];
		private static var _speedIndex:uint = 	1;
		
		/**
		 * Unique ID
		 */
		private static var _currentUID:int = 	0;
		
		public function Config() {
			Config.resetForNewGame();
		}
		
		/**
		 * Handle all resetting of variables to start a new game
		 */
		public static function resetForNewGame():void {
			totals = new Totals();
			
			_currentGold = 0;
			_currentHP = 0;
			_currentWave = 0;
			
			// Speeds
			_speedIndex = 1;
			currentGameSpeed = 1;
		}
		
		/**
		 * Returns a Unique ID number for game objects 
		 * 
		 * @return the next unique id number  
		 */
		public static function getUID():int {
			return ++_currentUID;
		}
		
		/**
		 * Changes the speed of the game
		 * 
		 * @param speedChangeDir the direction to change speeds to: "up" or "down"
		 */
		public static function changeGameSpeed(speedChangeDir:String):void {
			var speedChanged:Boolean = false;

			if(speedChangeDir == GAME_SPEED_UP) 
			{
				// check if we can speed up any
				if(_speedIndex < _gameSpeeds.length - 1) 
				{
					_speedIndex++;
					speedChanged = true;
					trace('_speedIndex changed: ' + _speedIndex);
				}
			} 
			else if(speedChangeDir == GAME_SPEED_DOWN) 
			{
				// check if we can slow down any
				if(_speedIndex > 0) 
				{
					_speedIndex--;
					speedChanged = true;
					trace('_speedIndex changed: ' + _speedIndex);
				}
			}
			
			// only dispatch event if the speed changed
			if(speedChanged) {
				// set currentGameSpeed
				currentGameSpeed = _gameSpeeds[_speedIndex];
				trace('currentGameSpeed changed: ' + currentGameSpeed);
				// dispatch new speed
				onGameSpeedChange.dispatch();
			}
		}
		
		/**
		 * Changes the _currentGold param and dispatches change event so HUD can respond 
		 *  
		 * @param g amount of gold to change _currentGold by
		 * @param addToCurrent if true, the g param will be added to the _currentGold, else it sets _currentGold to that value
		 */
		public static function changeCurrentGold(g:int, addToCurrent:Boolean = true):void {
			if(addToCurrent) {
				_currentGold += g;
			} else {
				_currentGold = g;
			}
			currentGoldChanged.dispatch(_currentGold);
		}
		
		/**
		 * Returns the current gold of the player
		 * 
		 * @return int the current amount of gold
		 */
		public static function get currentGold():int { 
			return _currentGold 
		}
		
		/**
		 * Sets the current gold of the player
		 * 
		 * @param g the current amount of gold
		 */
		public static function set currentGold(g:int):void { 
			_currentGold = g;
		}
		
		/**
		 * Changes the _currentHP param and dispatches change event so HUD can respond 
		 * 
		 * @param hp hitPoints to change _currentHP by
		 * @param addToCurrent if true, the hp param will be added to the _currentHP, else it sets _currentHP to that value
		 */
		public static function changeCurrentHP(hp:int, addToCurrent:Boolean = true):void {
			trace('changeCurrentHP', hp, addToCurrent)
			if(addToCurrent) {
				_currentHP += hp;
			} else {
				_currentHP = hp;
			}
			currentHPChanged.dispatch(_currentHP);
		}
		
		/**
		 * Returns the current hit points of the player
		 * 
		 * @return int the current amount of hit points
		 */
		public static function get currentHP():int { 
			return _currentHP; 
		}
		
		/**
		 * Sets the current hit points of the player
		 * 
		 * @param hp int the current amount of hit points
		 */
		public static function set currentHP(hp:int):void { 
			_currentHP = hp;
		}
		
		/**
		 * Changes the _currentWave param and dispatches change event so HUD can respond 
		 * 
		 * @param w wave number to change _currentWave by
		 * @param addToCurrent if true, the w param will be added to the _currentWave, else it sets _currentWave to that value
		 */
		public static function changeCurrentWave(w:int, addToCurrent:Boolean = true):void {
			if(addToCurrent) {
				_currentWave += w;
			} else {
				_currentWave = w;
			}
			currentWaveChanged.dispatch(_currentWave);
		}
		
		/**
		 * Returns the current current wave number the player is on
		 * 
		 * @return int the current current wave number the player is on
		 */
		public static function get currentWave():int { 
			return _currentWave; 
		}
		
		/**
		 * Sets the current current wave number the player is on
		 * 
		 * @param w int the current current wave number the player is on
		 */
		public static function set currentWave(w:int):void { 
			_currentWave = w;
		}
		
		/**
		 * Quick helper function that increments the game data mapsAttempted then updates the SharedObject
		 * and saves
		 */
		public static function addGameAttempted():void {
			currentGameSOData.mapsAttempted++;
			Game.sharedObject.setGameDataProperty(currentGameSOData.mapsAttempted, 'mapsAttempted', '', true);
		}
		
		/**
		 * Quick helper function that increments the currentGameSOData's upgrades.ptsTotal by one then saves
		 */
		public static function addTotalUpgradePoint():void {
			currentGameSOData.upgrades.ptsTotal++;
			Game.sharedObject.setGameDataProperty(currentGameSOData.upgrades.ptsTotal, 'upgrades.ptsTotal', '', true);
		}
		
		/**
		 * Saves the game options variables from Config to the SharedObject.gameOptions
		 * 
		 * @param {Object} data the gameOptions object from the shared object
		 */
		public static function saveGameOptions():void {
			var opts:Object = {
				musicVolume: musicVolume,
				sfxVolume: sfxVolume
			};
			Game.sharedObject.setGameOptions(opts, true);
		}
		
		/***
		 * Central place to log.  Can trace or eventually log to file or url
		 * 
		 * @param klass String name of the class that is calling log
		 * @param fn String name of the function that is calling log
		 * @param msg String message to log
		 * @param level int a relative level of importance to the log
		 * @param verbose Boolean some log lines may contain whole blocks of XML and may want to not be logged
		 **/
		public static function log(klass:String, fn:String, msg:String, level:int = 0, verbose:Boolean = false):void  {
			if(Config.debugMode)  {
				var levelText:String = '';
				if(level == 0) {
					levelText = 'INFO';
				} else if(level == 1) {
					levelText = 'WARNING';
				} else if(level == 2) {
					levelText = 'ERROR';
				}
				var classNameFn:String = "[" + klass + "." + fn + "]";
				levelText = "[" + levelText + "]";
				
				if(!verbose || (Config.debugVerbose && verbose)) {
					trace(classNameFn + ' ' + levelText + ' => ' + msg);
				}
			}
		}
		
		/***
		 * Alias for Log with level set to 2 for ERROR
		 * 
		 * @param klass String name of the class that is calling log
		 * @param fn String name of the function that is calling log
		 * @param msg String message to log
		 **/
		public static function logError(klass:String, fn:String, msg:String):void  {
			Config.log(klass, fn, msg, 2);
		}
		
		/***
		 * Alias for Log with level set to 1 for WARNING
		 * 
		 * @param klass String name of the class that is calling log
		 * @param fn String name of the function that is calling log
		 * @param msg String message to log
		 **/
		public static function logWarning(klass:String, fn:String, msg:String):void  {
			Config.log(klass, fn, msg, 1);
		}
	}
}
