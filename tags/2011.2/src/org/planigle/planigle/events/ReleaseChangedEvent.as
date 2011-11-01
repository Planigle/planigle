package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class ReleaseChangedEvent extends CairngormEvent
	{
		public static const RELEASE_CHANGED:String = "ReleaseChanged";
		
		public function ReleaseChangedEvent()
		{
			// Call Caignorm constructor.
			super(RELEASE_CHANGED);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new ReleaseChangedEvent();
		}
	}
}