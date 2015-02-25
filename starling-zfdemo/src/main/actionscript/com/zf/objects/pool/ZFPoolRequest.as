package com.zf.objects.pool
{
	public class ZFPoolRequest
	{
		public var className:String;
		public var klass:Class;
		public var amount:int;
		
		public function ZFPoolRequest(c:Class, n:String, amt:int)
		{
			klass = c;
			className = n;
			amount = amt;
		}
	}
}