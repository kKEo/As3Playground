package com.zf.managers
{
	public interface IZFManager
	{
		/**
		 * Called when the game tick updates
		 */
		function update():void;
		
		/**
		 * Called when the game is over and states are being changed
		 */
		function destroy():void;
		
		/**
		 * Called when the game is paused
		 */
		function onGamePaused():void;
		
		/**
		 * Called when the game is resumed from being paused
		 */
		function onGameResumed():void;
	}
}
