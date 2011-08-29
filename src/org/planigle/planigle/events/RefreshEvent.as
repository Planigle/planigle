package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class RefreshEvent extends CairngormEvent
	{
		public static const REFRESH:String = "Refresh";
		public var showCursor:Boolean = false;
		
		public function RefreshEvent(showCursor:Boolean = false)
		{
			this.showCursor = showCursor;

			// Call Caignorm constructor.
			super(REFRESH);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new RefreshEvent(showCursor);
		}
	}
}