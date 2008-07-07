package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateTaskCommand;
	import org.planigle.planigle.commands.DeleteStoryCommand;
	import org.planigle.planigle.commands.SplitStoryCommand;
	import org.planigle.planigle.commands.UpdateStoryCommand;
	
	[Bindable]
	public class Story
	{
		public var id:int;
		public var name:String;
		public var listName:String; // Allows for different representation in list.
		public var description:String;
		public var acceptanceCriteria:String;
		public var iterationId:int;
		public var ownerId:int;
		public var effort:String; // My actual effort.
		public var calculatedEffort:String; // My effort when looking at my tasks.
		public var statusCode:int;
		public var isPublic:Boolean;
		public var priority:Number;
		public var normalizedPriority:String = "";
		public var userPriority:String = "";
		public var tasks:ArrayCollection = new ArrayCollection();
		public static const CREATED:int = 0;
		public static const IN_PROGRESS:int = 1;
		public static const ACCEPTED:int = 2;
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading

		// Populate myself from XML.
		private function populate(xml:XML):void
		{
			id = xml.id;
			name = xml.name;
			listName = name;
			description = xml.description;
			acceptanceCriteria = xml.child("acceptance-criteria");
			iterationId = xml.child("iteration-id");
			ownerId = xml.child("individual-id");
			effort = xml.effort;
			statusCode = xml.child("status-code");
			isPublic = xml.public == "true";
			priority = xml.priority;
			userPriority = statusCode < 2 ? xml.child("user-priority") : "";

			tasks = new ArrayCollection();
			for (var i:int = 0; i < xml.tasks.task.length(); i++)
			  tasks.addItem( new Task(this, XML(xml.tasks.task[i])));
			updateEffort();
		}

		// Construct a story based on XML.
		public function Story(xml:XML)
		{
			populate(xml);
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateStoryCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
			StoryFactory.getInstance().normalizePriorities()
		}
		
		// Split me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function split(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new SplitStoryCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully split.  Change myself to reflect the changes.
		public function splitCompleted(xml:XML):void
		{
			for(var i:int = 0; i < xml.tasks.task.length(); i++)
			{ // Remove any tasks that were moved to the new story.  Do it before creating the story to prevent multiple events.
				var id:int = int(xml.tasks.task[i].id);
				for (var j:int = tasks.length - 1; j >= 0; j--) // Go backwards since deleting
				{
					var task:Task = Task(tasks.getItemAt(j));
					if (id == task.id)
						tasks.removeItemAt(j);
				}
			}
			updateEffort();
			StoryFactory.getInstance().createStoryCompleted(xml);
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteStoryCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Create copy to ensure any views get notified of changes.
			var stories:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < StoryFactory.getInstance().stories.length; i++)
			{
				var story:Story = Story(StoryFactory.getInstance().stories.getItemAt(i));
				if (story != this)
					stories.addItem(story);
			}
			StoryFactory.getInstance().stories = stories;
			StoryFactory.getInstance().normalizePriorities();
		}
		
		// Create a new task for me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createTask(params:Object, successFunction:Function, failureFunction:Function):void
		{
			params["record[story_id]"] = id;
			new CreateTaskCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// A task has been successfully created.  Change myself to reflect the changes.
		public function createTaskCompleted(xml:XML):Task
		{
			var task:Task = new Task(this, xml);
			tasks.addItem(task);

			// Create copy to ensure any views get notified of changes.
			var stories:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < StoryFactory.getInstance().stories.length; i++)
				stories.addItem(StoryFactory.getInstance().stories.getItemAt(i));
			StoryFactory.getInstance().stories = stories;
			updateEffort();
			
			return task;
		}
		
		// Update my effort based on the tasks I contain.
		public function updateEffort():void
		{
			if (effort == "")
			{
				var sum:Number = 0;
				for (var i:int; i < tasks.length; i++)
				{
					var task:Task = Task(tasks.getItemAt(i));
					if (task.effort != "")
						sum += Number(task.effort);
				}
				calculatedEffort = (sum == 0) ? "" : sum.toString();
				
			}
			else
			  calculatedEffort = effort;
		}
		
		// Expand the story to show its tasks.
		public function expand():void
		{
			expanded[String(id)] = true;
		}
		
		// Collapse the story to not show its tasks.
		public function collapse():void
		{
			expanded[String(id)] = false;
		}
		
		// Expand me if collapsed.  Collapse me if expanded.
		public function toggleExpanded():void
		{
			if (isExpanded())
				collapse();
			else
				expand();
		}
		
		// Answer whether the story is expanded.
		public function isExpanded():Boolean
		{
			return expanded.hasOwnProperty(String(id)) && expanded[String(id)];
		}

		//  Yes, I'm a story.
		public function isStory():Boolean
		{
			return true;
		}
		
		// Answer a label for my expand button.
		public function expandLabel():String
		{
			if (tasks.length == 0)
				return "";
			else
				return isExpanded() ? "-" : "+";
		}
		
		// Answer my background color.  -1 means use the default.
		public function backgroundColor():int
		{
			return -1;
		}
	}
}