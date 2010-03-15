package org.planigle.planigle.model
{
	[RemoteClass(alias='Criterium')]
	[Bindable]
	public class Criterium
	{
		public var story:Story;
		public var id:int;
		public var storyId:int;
		public var description:String;
		public var statusCode:int;
		public var priority:Number;
		public static const NOT_DONE:int = 0;
		public static const DONE:int = 1;

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			storyId = xml.child("story-id");
			description = xml.description;
			statusCode = xml.child("status-code");
			priority = xml.child("priority");
		}
		
		public function toggleStatus():void
		{
			statusCode = statusCode == 0 ? 1 : 0;
		}
	}
}