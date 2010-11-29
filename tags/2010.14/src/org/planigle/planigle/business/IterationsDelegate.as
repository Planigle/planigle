package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class IterationsDelegate extends Delegate
	{
		protected var time:String;
		
		public function IterationsDelegate( responder:IResponder, time:String = null )
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
			return "iterationRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "iterations.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "iterations/" + object.id + ".xml"
		}
	}
}