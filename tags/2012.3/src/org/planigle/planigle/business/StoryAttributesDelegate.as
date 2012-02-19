package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class StoryAttributesDelegate extends Delegate
	{
		public function StoryAttributesDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "story_attributes.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "story_attributes/" + object.id + ".xml"
		}
	}
}