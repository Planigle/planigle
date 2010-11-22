package org.planigle.planigle.util
{
	import flash.external.ExternalInterface;
	
	public class RequestProcessor
	{
		public function RequestProcessor()
		{
		}
		
		// Answer a request parameter exists with the given name (or null if not present).
		public function getRequestParameter(parameter:String):String
		{
			if (!ExternalInterface.available) return null;
			var js:String = "function get_request_parameter(){return window.location.href;}"
			var url:String = ExternalInterface.call(js).toString();
			var queryString:String = url.substring(url.indexOf("?")+1);
			var start:int = queryString.indexOf(parameter) + 3; // after =
			if (start == 2) return null;
			var end:int = queryString.indexOf("&");
			if (end == -1) end = queryString.indexOf("#");
			return end == -1 ? queryString.substring(start) : queryString.substring(start,end);
		}
	}
}