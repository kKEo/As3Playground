package com.zf.loaders {
	/**
	 * This class holds any data loaded from ZFLoader as well as the item name loaded
	 */
	public class CallBackObject
	{
		public var name:String;
		public var data:*;
		public var options:Object;
		
		public function CallBackObject(itemName:String, loadedData:*, opts:*) {
			name = itemName;
			data = loadedData;
			options = opts;
		}
	}
}