package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class IndividualsDelegate extends Delegate
	{
		public function IndividualsDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "individualRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "individuals.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "individuals/" + object.id + ".xml"
		}
	}
}