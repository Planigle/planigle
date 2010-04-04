package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class TeamsDelegate extends Delegate
	{
		public function TeamsDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "projects/" + factory.id + "/teams.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "projects/" + object.project.id + "/teams/" + object.id + ".xml"
		}
	}
}