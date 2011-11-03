package org.planigle.planigle.model
{
	[RemoteClass(alias='StoryValue')]
	[Bindable]
	public class StoryValue
	{
		public var id:int;
		public var story:Story;
		public var storyId:int;
		public var storyAttributeId:int;
		public var value:String;

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			storyId = xml.child("story-id");
			storyAttributeId = xml.child("story-attribute-id");
			value = xml.value;
		}
	}
}