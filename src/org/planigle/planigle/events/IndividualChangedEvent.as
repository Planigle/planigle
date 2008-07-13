package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	import org.planigle.planigle.model.ViewModelLocator;
	
	public class IndividualChangedEvent extends CairngormEvent
	{
		public static const INDIVIDUAL_CHANGED:String = "IndividualChanged";
		
		public function IndividualChangedEvent()
		{
			// Call Caignorm constructor.
			super(INDIVIDUAL_CHANGED);
			ViewModelLocator.getInstance().waitingForData();
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new IndividualChangedEvent();
		}
	}
}