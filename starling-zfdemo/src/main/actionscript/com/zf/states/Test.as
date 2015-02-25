/**
 * Test state is the state I use when just needing a state to go add stuff and test things in
 */
package com.zf.states
{
	import com.zf.core.Assets;
	import com.zf.core.Game;
	import com.zf.ui.buttons.nextWaveButton.NextWaveButton;
	import com.zf.ui.gameOptions.GameOptionsPanel;
	import com.zf.ui.text.ZFTimedTextField;
	import com.zf.ui.upgradeOption.UpgradeOption;
	
	import flash.geom.Point;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Test extends Sprite implements IState
	{
		private var _game:Game;
		/*
		private var _ttf1:ZFTimedTextField;
		private var _ttf2:ZFTimedTextField;
		private var _ttf3:ZFTimedTextField;
		private var _ttf4:ZFTimedTextField;
		private var _ttf5:ZFTimedTextField;
		private var _ttf6:ZFTimedTextField;
		*/
		
		private var _opts:GameOptionsPanel;
		private var showOpts:Boolean = false;
		public function Test(g:Game)
		{
			_game = g;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
/*
			_opts = new GameOptionsPanel(new Point(150,-350), new Point(150,150));
			addChild(_opts);
			
			var btn:Button = new Button(Assets.tryAgainBtnT);
			btn.addEventListener(Event.TRIGGERED, _onButtonClicked);
			btn.x = 600;
			btn.y = 450;
			addChild(btn);
			*/

			var uo:UpgradeOption = new UpgradeOption('test', 'Test', 5, 0.1, true);
			uo.x = 100;
			uo.y = 100;
			addChild(uo);
			
			/*
			_ttf1 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf1.x = 30;
			_ttf1.y = 100;
			addChild(_ttf1);
			_ttf1.label = "Complete1:";
			
			_ttf2 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf2.x = 30;
			_ttf2.y = 200;
			addChild(_ttf2);
			_ttf2.label = "Complete2:";
			
			_ttf3 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf3.x = 30;
			_ttf3.y = 300;
			addChild(_ttf3);
			_ttf3.label = "Complete3:";
			
			_ttf4 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf4.x = 300;
			_ttf4.y = 100;
			addChild(_ttf4);
			_ttf4.label = "Complete4:";
			
			_ttf5 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf5.x = 300;
			_ttf5.y = 200;
			addChild(_ttf5);
			_ttf5.label = "Complete5:";
			
			_ttf6 = new ZFTimedTextField(200, 50, 0, 1000);
			_ttf6.x = 300;
			_ttf6.y = 300;
			addChild(_ttf6);
			_ttf6.label = "Complete6:";
			
			
			_ttf1.start();
			_ttf2.start();
			_ttf3.start();
			_ttf4.start();
			_ttf5.start();
			_ttf6.start();
			*/
			
		}
		public function onBtnClicked():void {
			trace('Button Clicked!');
		}
		public function update():void {

		}
		
		public function destroy():void {
			
		}
		
		private function _onButtonClicked(evt:Event):void {
			showOpts = !showOpts;
			
			if(showOpts) {
				_opts.activate();
			} else {
				_opts.deactivate();	
			}
			
			
		}
	}
}