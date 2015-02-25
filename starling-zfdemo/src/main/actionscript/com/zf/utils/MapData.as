package com.zf.utils
{
	public class MapData
	{
		private var _data:Object;
		
		public function MapData(data:Object)
		{
			_data = {};
			_parseData(data);
		}

		private function _parseData(d:Object):void {
			for each(var map:Object in d.maps) {
				_data[map.id] = map;
			}
		}
		
		public function getMapById(id:String):Object {
			return _data[id];
		}
	}
}