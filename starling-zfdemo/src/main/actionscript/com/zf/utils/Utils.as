package com.zf.utils
{
	import com.adobe.serialization.json.JSON;
	public class Utils
	{
		public static function JSONDecode(s:String):Object {
			return com.adobe.serialization.json.JSON.decode(s);
		}
		
		public static function objectToString(obj:*, props:Array, lineBr:String = '\n', toHTML:Boolean = false, fontSize:int = 20, fontColor:String = '#FFFFFF'):String {
			var str:String = '',
				len:int = props.length;
			for(var i:int = 0; i < len; i++) {
				// add opening tag
				if(toHTML) {
					str += '<font color="' + fontColor + '" size="' + fontSize + '">';
				}
				
				// add property
				str += props[i] + ' = ' + int(obj[props[i]]);
				
				// add closing tag
				if(toHTML) {
					str += '</font>';
				}
				
				// Add line break
				str += lineBr;
			}
			
			return str;
		}
	}
}