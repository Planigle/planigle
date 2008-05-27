package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import org.planigle.planigle.commands.UpdateTaskCommand;
	import org.planigle.planigle.commands.DeleteTaskCommand;

	[Bindable]
	public class Task
	{
		public var story:Story;
		public var id:int;
		public var name:String;
		public var listName:String; // allows for indentation in list.
		public var description:String;
		public var iterationId:int = -1; // stubbed out to look like a Story in tables.
		public var ownerId:int;
		public var effort:String;
		public var calculatedEffort:String; // stubbed out to look like a Story in tables.
		public var statusCode:int;
		public var priority:String = ""; // stubbed out to look like a Story in tables.

		// Populate myself from XML.
		private function populate(xml:XML):void
		{
			id = xml.id;
			name = xml.name;
			listName = "     " + name;
			description = xml.description;
			ownerId = xml.child("individual-id");
			effort = xml.effort;
			calculatedEffort = effort;
			statusCode = xml.child("status-code");
		}

		// Construct a task based on XML.
		public function Task(aStory:Story, xml:XML)
		{
			story = aStory;
			populate(xml);
		}
		
		// Update the task.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateTaskCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
			story.updateEffort();
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteTaskCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			story.tasks.removeItemAt(story.tasks.getItemIndex(this));
			story.updateEffort();

			// Create copy to ensure any views get notified of changes.
			var stories:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < StoryFactory.getInstance().stories.length; i++)
				stories.addItem(StoryFactory.getInstance().stories.getItemAt(i));
			StoryFactory.getInstance().stories = stories;
		}

		//  No, I'm not a story.
		public function isStory():Boolean
		{
			return false;
		}

		// Answer a label for my expand button.
		public function expandLabel():String
		{
			return "";	
		}
		
		// Answer my background color.
		public function backgroundColor():int
		{
			return 0xDDDDDD;
		}
	}
}