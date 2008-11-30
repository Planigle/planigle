package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	
	public class AuditChangedEvent extends CairngormEvent
	{
		public static const AUDIT_CHANGED:String = "AuditChanged";
		public var changer:Object;
		public var objectType:Object;
		public var startDate:Date;
		public var endDate:Date;
		public var objectId:String;
		
		public function AuditChangedEvent(changer:Object = null, objectType:Object = null, startDate:Date = null, endDate:Date = null, objectId:String = null)
		{
			super(AUDIT_CHANGED);
			this.changer = changer;
			this.objectType = objectType;
			this.startDate = startDate;
			this.endDate = startDate;
			this.objectId = objectId;
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new AuditChangedEvent(changer, objectType, startDate, endDate, objectId);
		}
	}
}