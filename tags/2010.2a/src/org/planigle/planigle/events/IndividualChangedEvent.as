package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class IndividualChangedEvent extends CairngormEvent
	{
		public static const INDIVIDUAL_CHANGED:String = "IndividualChanged";
		
		public function IndividualChangedEvent()
		{
			// Call Caignorm constructor.
			super(INDIVIDUAL_CHANGED);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new IndividualChangedEvent();
		}
	}
}