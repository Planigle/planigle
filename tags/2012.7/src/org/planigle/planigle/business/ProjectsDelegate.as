package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class ProjectsDelegate extends Delegate
	{
		public function ProjectsDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "projectRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "projects.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "projects/" + object.id + ".xml"
		}
	}
}