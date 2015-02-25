package com.zf.objects.pool
{
	import starling.display.DisplayObject;
	
	public class ZFMultiPool
	{
		public var items:Array;
		private var counter:int;
		private var _pool:Object;
		
		public function ZFMultiPool(requests:Vector.<ZFPoolRequest>)
		{
			var len:int = requests.length;
			var req:ZFPoolRequest;
			
			for(var i:int = 0; i < len; i++) {
				req = requests[i];
				// create a new array to hold this class type
				_pool[req.className] = [];
				
				var lenCreate:int = req.amount;
				for(var j:int = 0; j < lenCreate; j++) {
					_pool[req.className][j] = new req.klass();
				}
			}
			items = new Array();
			counter = len;
			
			var i:int = len;
			while(--i > -1)
				items[i] = new type();
		}
		
		public function getSprite():DisplayObject
		{
			if(counter > 0) {
				counter--;
				return items.pop();
			} else {
				throw new Error("You exhausted the pool!");
			}
		}
		
		public function returnSprite(s:DisplayObject):void
		{
			items[counter++] = s;
		}
		
		public function destroy():void
		{
			items = null;
		}
	}
}