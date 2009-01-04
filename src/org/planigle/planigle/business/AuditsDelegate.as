package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class AuditsDelegate extends Delegate
	{
		public var changer:Object;
		public var objectType:Object;
		public var startDate:Date;
		public var endDate:Date;
		public var objectId:String;

		public function AuditsDelegate( responder:IResponder, changer:Object = null, objectType:Object = null, startDate:Date = null, endDate:Date = null, objectId:String = null )
		{
			super(responder);
			this.changer = changer;
			this.objectType = objectType;
			this.startDate = startDate;
			this.endDate = endDate;
			this.objectId = objectId;
		}
		
		// Answer the parameters to send.
		protected override function params():Object
		{
			var params:Object = new Object();
			if (changer)
				params['user_id'] = changer;
			if (objectType)
				params['type'] = objectType;
			if (startDate)
				params['start'] = startDate;
			if (endDate)
				params['end'] = endDate;
			if (objectId)
				params['object_id'] = objectId;
			return params;
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "auditRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "audits.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "audits/" + object.id + ".xml"
		}
	}
}