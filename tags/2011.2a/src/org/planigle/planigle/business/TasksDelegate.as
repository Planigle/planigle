package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class TasksDelegate extends Delegate
	{
		public function TasksDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "stories/" + factory.id + "/tasks.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "stories/" + object.story.id + "/tasks/" + object.id + ".xml"
		}
	}
}