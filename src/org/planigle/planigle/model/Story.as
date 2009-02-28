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
		public var projectId:int;
		public var teamId:String;
		public var name:String;
		public var description:String;
		public var reasonBlocked:String;
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
		public var custom:String; // Used for sorting
		private var myStoryValues:Array = new Array();
		private var myTasks:Array = new Array();
		public static const CREATED:int = 0;
		public static const IN_PROGRESS:int = 1;
		public static const BLOCKED:int = 2;
		public static const ACCEPTED:int = 3;
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			teamId = xml.child("team-id").toString() == "" ? null : xml.child("team-id");
			id = xml.id;
			name = xml.name;
			description = xml.description;
			acceptanceCriteria = xml.child("acceptance-criteria");
			releaseId = xml.child("release-id").toString() == "" ? null : xml.child("release-id");
			iterationId = xml.child("iteration-id").toString() == "" ? null : xml.child("iteration-id");
			individualId = xml.child("individual-id").toString() == "" ? null : xml.child("individual-id");
			effort = xml.effort;
			statusCode = xml.child("status-code");
			reasonBlocked = xml.child("reason-blocked");
			isPublic = xml.child("is-public").toString() == "true";
			priority = xml.priority;
			userPriority = xml.child("user-priority");

			var newStoryValues:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.child("story-values").child("story-value").length(); i++)
			{
				var storyValue:StoryValue = new StoryValue();
				storyValue.populate(XML(xml.child("story-values").child("story-value")[i]));
				newStoryValues.addItem(storyValue);
			}
			storyValues = newStoryValues.source;

			var newTasks:ArrayCollection = new ArrayCollection();
			for (var j:int = 0; j < xml.tasks.task.length(); j++)
			{
				var task:Task = new Task();
				task.populate(XML(xml.tasks.task[j]));
				newTasks.addItem(task);
			}
			tasks = newTasks.source;
		}
		
		// Answer the value for a custom value (or nil if it does not exist).
		public function getCustomValue(id:int):String
		{
			for each (var val:StoryValue in storyValues)
			{
				if (val.storyAttributeId == id)
					return val.value;
			}
			return null;
		}
		
		// Answer the value for a custom value formatted to something the user can understand.
		public function getCustomFormattedValue(attrib:StoryAttribute):String
		{
			var value:String = getCustomValue(attrib.id);
			switch (attrib.valueType)
			{
				case StoryAttribute.LIST:
				case StoryAttribute.RELEASE_LIST:
					for each (var attribValue:StoryAttributeValue in attrib.storyAttributeValues)
					{
						if (attribValue.id == int(value))
							return attribValue.value;
					}
					return "None"; // Couldn't find a value;
				default:
					return value;
			}
		}
		
		// Answer my story values.
		public function get storyValues():Array
		{
			return myStoryValues;
		}

		// Set my story values.
		public function set storyValues(storyValues:Array):void
		{
			for each (var storyValue:StoryValue in storyValues)
				storyValue.story = this;

			myStoryValues = storyValues;
		}

		// Answer my project.
		public function get project():Project
		{
			return IndividualFactory.current().project;
		}

		// Answer my team.
		public function get team():Team
		{
			return project.find(teamId);
		}

		// Answer my tasks.
		public function get tasks():Array
		{
			return myTasks;
		}

		// Set my tasks.
		public function set tasks(tasks:Array):void
		{
			tasks.sortOn(["statusCode", "name"], [Array.NUMERIC | Array.DESCENDING, Array.CASEINSENSITIVE]);
			for each (var task:Task in tasks)
				task.story = this;

			myTasks = tasks;
		}

		// Resort my tasks.
		public function resort():void
		{
			tasks=tasks.concat(); // set to a copy
		}

		// Answer how much to indent this kind of item.
		public function get indent():int
		{
			return 5;
		}

		// Set the indent (currently ignored; used to prevent binding issue).
		public function set indent(indent:int):void
		{
		}

		// Answer my sizing.
		public function get size():String
		{
			return effort != null && effort != "" ? Number(effort).toString() : effort;
		}

		// For stories, the calculated effort is the sum of the effort of its tasks.
		public function get calculatedEffort():String
		{
			var sum:Number = 0;
			for each (var task:Task in tasks)
			{
				if (task.effort != null && task.effort != "")
					sum += Number(task.effort);
			}
			return ((sum == 0) ? "" : sum.toString());
		}

		// Only show user priority if not accepted.
		public function get modifiedUserPriority():String
		{
			return statusCode < ACCEPTED ? (userPriority != null && userPriority != "" ? Number(userPriority).toString() : userPriority) : "";
		}

		// Answer what my status should be if it is out of date (-1 otherwise).
		public function newStatus():int
		{
			var blocked:Boolean = false;
			var inProgress:Boolean = false;
			for each (var task:Task in tasks)
			{
				if (task.statusCode == BLOCKED)
					blocked = true;
				else if (task.statusCode != CREATED)
					inProgress = true;
			}
			if (blocked && statusCode != BLOCKED)
				return BLOCKED;
			else if (!blocked && statusCode == BLOCKED && reasonBlocked == "")
				return IN_PROGRESS;
			else if (inProgress && statusCode == CREATED)
				return IN_PROGRESS;
			else
				return -1;
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
			var currentStatus:int = statusCode;
			populate(xml);
			StoryFactory.getInstance().normalizePriorities()
			if (currentStatus != ACCEPTED && statusCode == ACCEPTED)
			{
				for each (var task:Task in tasks)
				{
					if (task.statusCode != ACCEPTED)
						task.update({'record[status_code]': ACCEPTED}, null, null);
				}
			}
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
			StoryFactory.getInstance().createCompleted(xml);
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
		public function createCompleted(xml:XML):Task
		{
			var task:Task = new Task();
			task.populate(xml);
			task.story = this;

			// Adjust my tasks
			var taskCollect:ArrayCollection = new ArrayCollection();
			for each (var oldTask:Task in tasks)
				taskCollect.addItem(oldTask);
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
		
		// Answer my background color.  -1 means use the default.
		public function backgroundColor():int
		{
			return -1;
		}
	}
}