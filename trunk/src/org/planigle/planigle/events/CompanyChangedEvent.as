package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class CompanyChangedEvent extends CairngormEvent
	{
		public static const COMPANY_CHANGED:String = "CompanyChanged";
		
		public function CompanyChangedEvent()
		{
			// Call Caignorm constructor.
			super(COMPANY_CHANGED);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new CompanyChangedEvent();
		}
	}
}