package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateTaskCommand;
	import org.planigle.planigle.commands.DeleteStoryCommand;
	import org.planigle.planigle.commands.SplitStoryCommand;
	import org.planigle.planigle.commands.UpdateStoryCommand;
	
	[RemoteClass(alias='Story')]
	[Bindable]
	public class Story
	{
		public var id:int;
		public var projectId: int;
		public var name:String;
		public var description:String;
		public var acceptanceCriteria:String;
		public var releaseId:String;
		public var iterationId:String;
		public var individualId:String;
		public var effort:String;
		public var statusCode:int;
		public var isPublic:Boolean;
		public var priority:Number;
		public var userPriority:String = "";
		public var normalizedPriority:String = ""; // Calculated by StoryFactory
		private var myTasks:Array = new Array();
		public static const CREATED:int = 0;
		public static const IN_PROGRESS:int = 1;
		public static const ACCEPTED:int = 2;
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			name = xml.name;
			description = xml.description;
			acceptanceCriteria = xml.child("acceptance-criteria");
			releaseId = xml.child("release-id");
			iterationId = xml.child("iteration-id");
			individualId = xml.child("individual-id");
			effort = xml.effort;
			statusCode = xml.child("status-code");
			isPublic = xml.child("is_public") == "true";
			priority = xml.priority;
			userPriority = xml.child("user-priority");

			var newTasks:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.tasks.task.length(); i++)
			{
				var task:Task = new Task();
				task.populate(XML(xml.tasks.task[i]));
				newTasks.addItem(task);
			}
			tasks = newTasks.source;
		}

		// Answer my tasks.
		public function get tasks():Array
		{
			return myTasks;
		}

		// Set my tasks.
		public function set tasks(tasks:Array):void
		{
			myTasks = tasks;
			for each (var task:Task in myTasks)
				task.story = this;
		}

		// For stories, the list name is the same as the name.
		public function get listName():String
		{
			return name;
		}

		// For stories, if not set locally, the calculated effort is the sum of its tasks.
		public function get calculatedEffort():String
		{
			if (!effort || effort == "")
			{
				var sum:Number = 0;
				for each (var task:Task in tasks)
				{
					if (task.effort != "")
						sum += Number(task.effort);
				}
				return (sum == 0) ? "" : sum.toString();				
			}
			else
				return effort;
		}

		// Only show user priority if not accepted.
		public function get modifiedUserPriority():String
		{
			return statusCode < 2 ? userPriority : "";
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
			var taskCollect:ArrayCollection = new ArrayCollection(tasks);
			for(var i:int = 0; i < xml.tasks.task.length(); i++)
			{ // Remove any tasks that were moved to the new story.  Do it before creating the story to prevent multiple events.
				var id:int = int(xml.tasks.task[i].id);
				for (var j:int = tasks.length - 1; j >= 0; j--) // Go backwards since deleting
				{
					var task:Task = Task(tasks[j]);
					if (id == task.id)
						taskCollect.removeItemAt(j);
				}
			}
			tasks = taskCollect.source;
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
			for each (var story:Story in StoryFactory.getInstance().stories)
			{
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
			var task:Task = new Task();
			task.populate(xml);
			var taskCollect:ArrayCollection = new ArrayCollection(tasks);
			taskCollect.addItem(task);
			tasks = taskCollect.source;

			// Create copy to ensure any views get notified of changes.
			var stories:ArrayCollection = new ArrayCollection();
			for each (var story:Story in StoryFactory.getInstance().stories)
				stories.addItem(story);
			StoryFactory.getInstance().stories = stories;
			
			return task;
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