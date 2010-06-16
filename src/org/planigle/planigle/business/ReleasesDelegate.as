package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class ReleasesDelegate extends Delegate
	{
		protected var time:String;
		
		public function ReleasesDelegate( responder:IResponder, time:String = null )
		{
			super(responder);
			this.time = time;
		}
		
		// Answer the parameters to send.
		protected override function params():Object
		{
			var params:Object = new Object();
			if (time != null)
				params['time'] = time;
			return params;
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "releaseRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "releases.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "releases/" + object.id + ".xml"
		}
	}
}