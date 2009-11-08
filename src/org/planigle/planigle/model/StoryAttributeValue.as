package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias='StoryAttributeValue')]
	[Bindable]
	public class StoryAttributeValue
	{
		public var id:int;
		public var storyAttributeId:int;
		public var releaseId:String;
		public var value:String;

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			storyAttributeId = xml.child("story-attribute-id").toString() == "" ? null : xml.child("story-attribute-id");
			releaseId = xml.child("release-id").toString() == "" ? null : xml.child("release-id");
			value = xml.value;
		}
		
		// Name is an alias for value.  It allows Story Attribute Values to be interchanged with other kinds of objects.
		public function get name():String
		{
			return value;
		}
		
		// Name is an alias for value.  It allows Story Attribute Values to be interchanged with other kinds of objects.
		public function set name(name:String):void
		{
			value = name;
		}
	}
}