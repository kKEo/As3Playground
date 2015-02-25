package
{
	import com.zf.core.Game;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;

	[SWF(width='800', height='600', frameRate='60', wmode='direct', backgroundColor='0x002c66')]
	public class ZFStarlingTDDemo extends Sprite
	{
		public function ZFStarlingTDDemo()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			var star:Starling = new Starling(Game, stage);
			star.showStats = true;
			star.stage.stageWidth = 800;
			star.stage.stageHeight = 600;
			star.stage.color = 0x002c66;
			star.start();
		}
	}
}
