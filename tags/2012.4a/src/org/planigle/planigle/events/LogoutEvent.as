package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class LogoutEvent extends CairngormEvent
	{
		public static const LOGOUT:String = "Logout";
		
		public function LogoutEvent()
		{
			// Call Caignorm constructor.
			super(LOGOUT);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new LogoutEvent();
		}
	}
}