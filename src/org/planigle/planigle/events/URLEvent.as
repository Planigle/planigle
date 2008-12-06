package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class URLEvent extends CairngormEvent
	{
		public static const URL:String = "URL";
		public var url:String;
		public var newWindow:Boolean;
		
		public function URLEvent( url:String, newWindow:Boolean = true )
		{
			this.url = url;
			this.newWindow = newWindow;
			super(URL);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new URLEvent(url, newWindow);
		}
	}
}