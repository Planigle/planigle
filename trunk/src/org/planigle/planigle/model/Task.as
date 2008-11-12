package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import org.planigle.planigle.commands.UpdateTaskCommand;
	import org.planigle.planigle.commands.DeleteTaskCommand;

	[RemoteClass(alias='Task')]
	[Bindable]
	public class Task
	{
		public var story:Story;
		public var id:int;
		public var storyId: int;
		public var name:String;
		public var description:String;
		public var reasonBlocked:String;
		public var individualId:String;
		public var effort:String;
		public var statusCode:int;

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			name = xml.name;
			description = xml.description;
			individualId = xml.child("individual-id").toString() == "" ? null : xml.child("individual-id");
			effort = xml.effort;
			statusCode = xml.child("status-code");
			reasonBlocked = xml.child("reason-blocked");
		}

		// Answer how much to indent this kind of item.
		public function get indent():int
		{
			return 25;
		}

		// For tasks, the calculated effort is the same as the effort.
		public function get calculatedEffort():String
		{ // Convert to Number to ensure consistent formatting.
			return effort != null && effort != "" ? Number(effort).toString() : effort;
		}

		// Tasks aren't assigned directly to iterations.
		public function get iterationId():int
		{
			return -1;
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
			story.resort();
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
			var taskCollect:ArrayCollection = new ArrayCollection(story.tasks);
			taskCollect.removeItemAt(taskCollect.getItemIndex(this));
			story.tasks = taskCollect.source;

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
		
		// Answer my background color.
		public function backgroundColor():int
		{
			return 0xDDDDDD;
		}
	}
}