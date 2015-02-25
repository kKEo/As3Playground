package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Config;
	import com.zf.core.Game;
	import com.zf.managers.*;
	import com.zf.objects.map.Map;
	
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Play extends Sprite implements IState
	{
		public static var zfJuggler:Juggler;
		
		public static const GAME_OVER_HP		: int = 0;
		public static const GAME_OVER_ENEMIES	: int = 1;
		public static const GAME_OVER_QUIT		: int = 2;
				
		public static const GAME_STATE_PAUSE: int = 0;
		public static const GAME_STATE_PLAY	: int = 1;
		public static const GAME_STATE_END	: int = 2;
		public static const GAME_STATE_OVER	: int = 3;
		
		public static var gameState			: int = GAME_STATE_PLAY;
		public static var gameOverState		: int = -1;
		
		/**
		 * Public Managers & Objects
		 */
		public var wpMgr	: WaypointManager;
		public var towerMgr	: TowerManager;
		public var keyMgr	: KeyboardManager;
		public var bulletMgr: BulletManager;
		public var enemyMgr	: EnemyManager;
		public var hitMgr	: CollisionManager;
		public var map		: Map;
		public var ns		: Stage;
		
		public var mapOffsetX:int = 36;
		public var mapOffsetY:int = 36;
		public var endGameOnNextFrame:Boolean = false;
		
		/**
		 * Public state values
		 */
		public var isPaused:Boolean = false;
		public var currentGold:int = 100;
		
		public var mapLayer:Sprite;
		public var enemyLayer:Sprite;
		public var towerLayer:Sprite;
		public var hudLayer:Sprite;
		public var topLayer:Sprite;
		
		private var _game:Game;
		
		public var hudMgr:HudManager;           

		// Game Conditions
		private var _gameCondEndOfWaves:Boolean;
		private var _gameCondEndOfEnemies:Boolean;
		
		private var _zfMgrs:Vector.<IZFManager>;
		
		private var _isGameStartPause:Boolean;
		public function Play(g:Game)
		{
			_game = g;
			
			zfJuggler = new Juggler();
			
			_zfMgrs = new Vector.<IZFManager>();
			
			// reset Config variables for new game
			Config.resetForNewGame();
			
			_gameCondEndOfWaves = false;
			_gameCondEndOfEnemies = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			Starling.juggler.add(zfJuggler);
			
			ns = Starling.current.nativeStage;
			
			keyMgr = new KeyboardManager(this, ns);
			keyMgr.onPause.add(onPauseEvent);
			
			mapLayer = new Sprite();
			addChild(mapLayer);
			
			enemyLayer = new Sprite();
			addChild(enemyLayer);
			
			towerLayer = new Sprite();
			addChild(towerLayer);
			
			hudLayer = new Sprite();
			addChild(hudLayer);
			
			topLayer = new Sprite();
			addChild(topLayer);
			
			enemyMgr = new EnemyManager(this);
			_zfMgrs.push(enemyMgr);
			
			hudMgr = new HudManager(this);
			_zfMgrs.push(hudMgr);
			
			wpMgr = new WaypointManager(this);
			
			towerMgr = new TowerManager(this , Assets.towerData);
			_zfMgrs.push(towerMgr);
			
			map = new Map(Config.currentMapData, wpMgr, mapOffsetX, mapOffsetY);
			map.x = mapOffsetX;
			map.y = mapOffsetY;
			mapLayer.addChild(map);

			bulletMgr = new BulletManager(this);
			_zfMgrs.push(bulletMgr);
			
			hitMgr = new CollisionManager(this);
			_zfMgrs.push(hitMgr);
			
			// Set up enemy data
			enemyMgr.handleNewMapData(Config.currentMapData.enemyData);
			
			/**
			 * Set up signals listeners
			 */
			enemyMgr.onEnemyAdded.add(hitMgr.onEnemyAdded);
			enemyMgr.onEnemyRemoved.add(hitMgr.onEnemyRemoved);
			towerMgr.onTowerAdded.add(hitMgr.onTowerAdded);
			towerMgr.onTowerRemoved.add(hitMgr.onTowerRemoved);
			towerMgr.onTowerManagerRemovingEnemy.add(hitMgr.onEnemyRemoved);
			
			hudMgr.endOfHP.add(onEndOfHP);
			enemyMgr.endOfEnemies.add(onEndOfEnemies);

			// set the current start HP
			Config.changeCurrentHP(map.startHP, false);
			
			// set the current start Gold from map data
			Config.changeCurrentGold(map.startGold, false);
			
			hudMgr.showNextWaveButtons();
			
			// update hud ui
			hudMgr.updateUI();
			
			// this is the initial pause at the start of the game
			_isGameStartPause = true;
			
			// pause the game so nothing happens until we resume
			onGamePaused();
		}
		
		/**
		 * Handles the main logic behind any pause event and should be the only function called
		 * when any pause event happens (clicking options, clicking pause btn, etc)
		 * 
		 * @param {Boolean} fromOptions is this function being called from the options panel
		 */
		public function onPauseEvent(fromOptions:Boolean = false):void {
			// Only handle pause/resume if this is not being called from the options panel
			// and this is not the first initial game pause. Otherwise, before the enemy waves
			// start, going to change the options and clicking Save would result in the waves starting
			if(!_isGameStartPause || (_isGameStartPause && !fromOptions)) {
				Config.log('Play', 'onPauseKeyPressed', "Play.onPauseKeyPressed() == " + isPaused);
				
				// the game has started from a means other than options saving so set this to false
				_isGameStartPause = false;
				
				isPaused = !isPaused;
				if(isPaused) {
					onGamePaused();
				} else {
					onGameResumed();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGamePaused():void {
			isPaused = true;
			gameState = GAME_STATE_PAUSE;
			Config.log('Play', 'pauseGame', "Removing juggler");
			Starling.juggler.remove(zfJuggler);
			
			var len:int = _zfMgrs.length;
			for(var i:int = 0; i < len; i++) {
				_zfMgrs[i].onGamePaused();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onGameResumed():void {
			isPaused = false;
			gameState = GAME_STATE_PLAY;
			Config.log('Play', 'resumeGame', "Adding Juggler");
			Starling.juggler.add(zfJuggler);
			
			var len:int = _zfMgrs.length;
			for(var i:int = 0; i < len; i++) {
				_zfMgrs[i].onGameResumed();
			}
		}
		
		public function onQuitGameFromOptions():void {
			handleGameOver(GAME_OVER_QUIT);
		}
		
		/**
		 * @inheritDoc
		 */
		public function update():void {
			if(endGameOnNextFrame) {
				// handle game over before getting back into another round of updates
				handleGameOver(Config.gameOverCondition);
			} else if(!isPaused && gameState != GAME_STATE_OVER) {
				// keeps track of how long the game has been active
				Config.activeGameTime = getTimer() - Config.pausedGameTime;
				
				enemyMgr.update();
				bulletMgr.update();
				hitMgr.update();
				towerMgr.update();
				hudMgr.update();
			} else if(isPaused && gameState != GAME_STATE_OVER) {
				// keeps track of how long the game has been paused
				Config.pausedGameTime = getTimer() - Config.activeGameTime;
			}
		}
		
		/**
		 * MANAGER-SPECIFIC FUNCTIONS 
		 * these are here because I want to check play state criteria before calling
		 * the specific manager's function
		 */
		public function createTower(towerID:String, pos:Point, level:int = 0):void {
			// HANDLE ACTUALLY CREATING THE TOWER
			// remove gold value
			Config.changeCurrentGold(-towerMgr.getTowerCost(towerID, level))
			hudMgr.updateUI();
			
			towerMgr.createNewTower(towerID, pos);
		}
		
		public function canCreateTower(towerID:String, level:int = 0):Boolean {
			var canCreate:Boolean = false;
			var towerCost:int = towerMgr.getTowerCost(towerID, level);
			
			// CHECK CRITERIA FOR CREATING A TOWER
			if(towerCost <= Config.currentGold) {
				canCreate = true;
			}
			
			return canCreate;
		}
		
		public function handleGameOver(gameOverCondition:int):void {
			switch(gameOverCondition) {
				case GAME_OVER_HP:
					Config.log('Play', 'handleGameOver', "LOST GAME LOSER!");
					break;
				
				case GAME_OVER_ENEMIES:
					// set that we won
					Config.totals.mapsWon = 1;
					// Add an upgrade point for the Upgrades screen
					Config.addTotalUpgradePoint();
					Config.log('Play', 'handleGameOver', "GAME WON WINNER!");
					break;
				
				case GAME_OVER_QUIT:
					// player quit
					Config.log('Play', 'handleGameOver', 'Quit Game');
					break;
			}
			
			// Add map totals to currentGameSOData
			Config.currentGameSOData.updateFromTotals(Config.totals);
			
			// Set SharedObject with game data and save
			Game.sharedObject.setGameData(Config.currentGameSOData, '', true);
				
			gameOverState = gameOverCondition;
			_changeGameState(GAME_STATE_OVER);
		}
		
		public function onEndOfHP():void {
			Config.log('Play', 'onEndOfHP', "Play onEndOfHP");
			Config.gameOverCondition = GAME_OVER_HP;
			endGameOnNextFrame = true;
		}
		
		public function onEndOfEnemies():void {
			Config.log('Play', 'onEndOfEnemies', "Play onEndOfEnemies");
			Config.gameOverCondition = GAME_OVER_ENEMIES;
			endGameOnNextFrame = true;
		}
		
		private function _changeGameState(st:int):void {
			Config.log('Play', '_changeGameState', "Game Changing State to: " + st);
			gameState = st;
			if(gameState == GAME_STATE_OVER) {
				_game.changeState(Game.GAME_OVER_STATE);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			Config.log('Play', 'destroy', "Play.destroy()");

			// remove all added listeners first
			_removeListeners();
			_removeManagers();
			_removeLayers();
			
			trace(Config.totals.toString());
		}
		
		
		private function _removeListeners():void {
			Config.log('Play', '_removeListeners', "Play._removeListeners()");
			keyMgr.onPause.remove(onPauseEvent);
			enemyMgr.onEnemyAdded.remove(hitMgr.onEnemyAdded);
			enemyMgr.onEnemyRemoved.remove(hitMgr.onEnemyRemoved);
			towerMgr.onTowerAdded.remove(hitMgr.onTowerAdded);
			towerMgr.onTowerRemoved.remove(hitMgr.onTowerRemoved);
			towerMgr.onTowerManagerRemovingEnemy.remove(hitMgr.onEnemyRemoved);
			hudMgr.endOfHP.remove(onEndOfHP);
			enemyMgr.endOfEnemies.remove(onEndOfEnemies);
		}
		
		/**
		 * Called by destroy() to remove the Sprite layers
		 */
		private function _removeManagers():void {
			Config.log('Play', '_removeManagers', "Play._removeManagers()");
			map.destroy();
			map = null;
			
			keyMgr.destroy();
			keyMgr = null;
			
			wpMgr.destroy();
			wpMgr = null;
			
			// Handles Bullet, Collision, Enemy, Hud, Tower Managers
			var len:int = _zfMgrs.length;
			for(var i:int = len - 1; i >= 0; i--) {
				_zfMgrs[i].destroy();
				_zfMgrs[i] = null;
				_zfMgrs.splice(i, 1);
			}
		}		
		
		/**
		 * Called by destroy() to remove the Sprite layers
		 */
		private function _removeLayers():void {
			Config.log('Play', '_removeLayers', "Play._removeLayers()");

			Starling.juggler.remove(zfJuggler);
			zfJuggler = null;
			removeChild(mapLayer);
			removeChild(enemyLayer);
			removeChild(towerLayer);
			removeChild(hudLayer);
		}
	}
}
