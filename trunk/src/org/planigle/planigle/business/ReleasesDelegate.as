package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class ReleasesDelegate extends Delegate
	{
		public function ReleasesDelegate( responder:IResponder )
		{
			super(responder);
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