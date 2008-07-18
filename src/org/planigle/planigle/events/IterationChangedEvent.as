package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class IterationChangedEvent extends CairngormEvent
	{
		public static const ITERATION_CHANGED:String = "IterationChanged";
		
		public function IterationChangedEvent()
		{
			// Call Caignorm constructor.
			super(ITERATION_CHANGED);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new IterationChangedEvent();
		}
	}
}