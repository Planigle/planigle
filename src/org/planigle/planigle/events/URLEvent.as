package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class URLEvent extends CairngormEvent
	{
		public static const URL:String = "URL";
		public var url:String;
		
		public function URLEvent( url:String )
		{
			this.url = url;
			// Call Caignorm constructor.
			super(URL);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new URLEvent(url);
		}
	}
}