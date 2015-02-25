package com.zf.ui.gameStateBkgd
{
	import com.zf.core.Assets;
	
	import starling.events.Event;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;

	public class GameStateBkgd extends Sprite
	{
		private var _bkgd:Image;
		private var _title:TextField;
		private var _titleText:String;
		public function GameStateBkgd(titleText:String)
		{
			_titleText = titleText;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_bkgd = new Image(Assets.gameStateBkgdT);
			addChild(_bkgd);
			
			_title = new TextField(700, 125, _titleText, "Wizzta", 100, 0xCC2323, true);
			_title.pivotX = 0;
			_title.pivotY = 0;
			_title.x = -150;
			_title.y = -10;
			addChild(_title);
		}
		
		public function destroy():void {
			_bkgd.removeFromParent(true);
			_bkgd = null;
			
			_title.removeFromParent(true);
			_title = null;
		}
	}
}