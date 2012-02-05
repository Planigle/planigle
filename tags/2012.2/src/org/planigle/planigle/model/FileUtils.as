package org.planigle.planigle.model
{
	public class FileUtils
	{
		import flash.external.ExternalInterface;

		// Return the session id.
		public static function getSession():String
		{
			if (ExternalInterface.available)
				return getCookie("_planigle_session_id");
			else
				return null;
		}

		// Answer cookie with the given name (or null if there is no such cookie).
		private static function getCookie(cookie:String):String
		{
			var js:String = "function get_cookie(){return document.cookie;}"
			var result:String = ExternalInterface.call(js).toString();
			var start:int = result.indexOf(cookie + "=") + cookie.length + 1;
			if (start == -1)
				return null;
			else
			{
				var end:int = result.indexOf(';', start) != -1 ? result.indexOf(';', start) : result.length;
				return result.substring(start, end);
			}
		}
	}
}