package org.planigle.planigle.model
{
	[Bindable]
	public class Story
	{
		public var id:int;
		public var name:String;
		public var description:String;
		public var acceptanceCriteria:String;
		public var iterationId:int;
		public var ownerId:int;
		public var effort:String;
		public var statusCode:int;
		public var priority:int;
		public static const CREATED:int = 0;
		public static const IN_PROGRESS:int = 1;
		public static const ACCEPTED:int = 2;

		// Construct a story based on XML.
		public function Story(xml:XML)
		{
			id = xml.id;
			name = xml.name;
			description = xml.description;
			acceptanceCriteria = xml.child("acceptance-criteria");
			iterationId = xml.child("iteration-id");
			ownerId = xml.child("individual-id");
			effort = xml.effort;
			statusCode = xml.child("status-code");
			priority = xml.priority;
		}
	}
}