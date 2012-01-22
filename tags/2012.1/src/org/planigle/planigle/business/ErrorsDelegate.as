package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class ErrorsDelegate extends Delegate
	{
		public function ErrorsDelegate( responder:IResponder, time:String = null )
		{
			super(responder);
		}
		
		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "errorRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "errors.xml"
		}
	}
}