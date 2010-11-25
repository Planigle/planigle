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
			var url:String = getURL();
			if (url == null) return null;
			var queryString:String = url.substring(url.indexOf("?")+1);
			var start:int = queryString.indexOf(parameter) + 3; // after =
			if (start == 2) return null;
			var end:int = queryString.indexOf("&");
			if (end == -1) end = queryString.indexOf("#");
			return end == -1 ? queryString.substring(start) : queryString.substring(start,end);
		}
		
		// Answer all request parameters.
		public function getRequestParameters():Object
		{
			var queryString:String = getQueryString();
			var params:Object = new Object();
			if (queryString == null) return params;
			var pos:int = 0;
			while (pos < queryString.length)
			{
				if (queryString.indexOf("=",pos) == -1)
					break;
				var endParam:int = queryString.indexOf("=",pos);
				var next:int = queryString.indexOf("&",pos) == -1 ? queryString.length : queryString.indexOf("&",pos);
				var paramName:String = queryString.substring(pos,endParam);
				if (paramName != "debug") // don't include this parameter
					params[paramName] = queryString.substring(endParam + 1,next);
				pos = next+1;
			}
			return params;
		}
		
		public function hasQueryString():Boolean
		{
			return getQueryString() != null;
		}
		
		public function getQueryString():String
		{
			var url:String = getURL();
			if (url == null) return null;
			var index:int = url.indexOf("?");
			var end:int = url.indexOf("#") == -1 ? url.length : url.indexOf("#");
			return index != -1 ? url.substring(index + 1, end) : null;
		}
		
		public function getURL():String
		{
			if (!ExternalInterface.available) return null;
			var js:String = "function get_request_parameter(){return window.location.href;}"
			return ExternalInterface.call(js).toString();
		}
	}
}