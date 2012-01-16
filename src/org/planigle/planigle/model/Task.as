package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteTaskCommand;
	import org.planigle.planigle.commands.UpdateTaskCommand;

	[RemoteClass(alias='Task')]
	[Bindable]
	public class Task
	{
		public var story:Story;
		public var id:int;
		public var storyId:int;
		public var myName:String;
		public var myDescription:String;
		public var myReasonBlocked:String;
		public var myIndividualId:String;
		public var updatedAtString:String;
		protected var myEffort:String;
		protected var myEstimate:String;
		protected var myActual:String;
		public var myStatusCode:int;
		public var priority:Number;
		public var projectedIterationId:String = "-1"; // Not used for tasks, but needed for the grid.

		public function getCurrentVersion():Object
		{
			var newStory:Story = StoryFactory.getInstance().find(storyId);
			return newStory == null ? null : newStory.find(id);
		}

		// Remove me from the UI.
		public function remove():void
		{
			var oldTasks:Array = story.tasks;
			var newTasks:Array = new Array();			
			for (var i:int = 0, j:int = 0; i < oldTasks.length; i++)
			{
				if (oldTasks[i] != this)
				{
					newTasks[j] = oldTasks[i];
					j++;
				}
			}
			story.tasks = newTasks;
		}

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			storyId = xml.child("story-id");
			name = xml.name;
			description = xml.description;
			individualId = xml.child("individual-id").toString() == "" ? null : xml.child("individual-id");
			effort = xml.effort;
			estimate = xml.estimate;
			actual = xml.actual;
			statusCode = xml.child("status-code");
			reasonBlocked = xml.child("reason-blocked");
			priority = xml.child("priority");
			updatedAtString = xml.child("updated-at");
		}

		// Answer how much to indent this kind of item.
		public function get indent():int
		{
			return story.indent + 25;
		}

		// Set the indent (currently ignored; used to prevent binding issue).
		public function set indent(indent:int):void
		{
		}

		// Answer my sizing.
		public function get size():String
		{
			return "";
		}

		public function get estimate():String
		{
			return convertString(myEstimate);			
		}
		
		public function set estimate(estimate:String):void
		{
			myEstimate = estimate;
		}

		public function get effort():String
		{
			return convertString(myEffort);			
		}
		
		public function set effort(effort:String):void
		{
			myEffort = effort;
		}

		// For tasks, the calculated effort is the same as the effort.
		public function get calculatedEffort():String
		{
			return convertString(effort);
		}

		public function get actual():String
		{
			return convertString(myActual);			
		}
		
		public function set actual(actual:String):void
		{
			myActual = actual;
		}

		protected function convertString(string:String):String
		{ // Convert to Number to ensure consistent formatting.
			return string != null && string != "" ? Number(string).toString() : string;
		}

		// Answer my user facing id.
		public function get fullId():String
		{	
			return "T" + id;
		}

		// Tasks aren't assigned directly to iterations.
		public function get iterationId():int
		{
			return -1;
		}

		// Tasks aren't assigned directly to releases.
		public function get releaseId():int
		{
			return -1;
		}

		// Update the task.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			params["updated_at"] = updatedAtString;
			new UpdateTaskCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
			story.resort();
			if (storyId != story.id)
			{
				var oldTasks:ArrayCollection = new ArrayCollection();
				for each (var oldTask:Task in story.tasks)
				{
					if (oldTask != this)
						oldTasks.addItem(oldTask);
				}
				story.tasks = oldTasks.toArray();

				story = StoryFactory.getInstance().find(storyId);

				var newTasks:ArrayCollection = new ArrayCollection();
				for each (var newTask:Task in story.tasks)
					newTasks.addItem(newTask);
				newTasks.addItem(this);
				story.tasks = newTasks.toArray();
				story.resort();
				story.expand();
			}
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
		
		public function copy(story:Story, priority:Number, notifySuccess: Function, notifyFailure: Function):void
		{
			var params:Object = new Object();
			params["record[story_id]"] = story.id;
			params["record[name]"] = name;
			params["record[description]"] = description;
			params["record[reason_blocked]"] = reasonBlocked;
			params["record[individual_id]"] = individualId;
			params["record[effort]"] = effort;
			params["record[estimate]"] = estimate;
			params["record[actual]"] = actual;
			params["record[status_code]"] = statusCode;
			params["record[priority]"] = priority;
			story.createTask(params, notifySuccess, notifyFailure);
		}
		
		public function get boardLabel():String
		{
			if (individualId == null)
				return name;
			else {
				return name + " - " + IndividualFactory.getInstance().find(individualId).initials;
			}
		}
		
		public function set boardLabel(boardLabel:String):void
		{
		}
		
		public function get boardDescription():String
		{
			var blocked:String = isBlocked ? "Blocked: " + reasonBlocked : "";
			if (blocked != "" && description != "")
				blocked += "\n\n";
			return blocked + description;
		}
		
		public function set boardDescription(boardDescription:String):void
		{
		}
		
		public function get isBlocked():Boolean
		{
			return statusCode == Story.BLOCKED;
		}
		
		public function set isBlocked(isBlocked:Boolean):void
		{
			boardDescription = boardDescription; // force update
		}
		
		public function get name():String
		{
			return myName;
		}
		
		public function set name(name:String):void
		{
			myName = name;
			boardLabel = boardLabel; // force update
		}
		
		public function get description():String
		{
			return myDescription;
		}
		
		public function set description(description:String):void
		{
			myDescription = description;
			boardDescription = boardDescription; // force update
		}
		
		public function get reasonBlocked():String
		{
			return myReasonBlocked;
		}
		
		public function set reasonBlocked(reasonBlocked:String):void
		{
			myReasonBlocked = reasonBlocked;
			boardDescription = boardDescription; // force update
		}
		
		public function get individualId():String
		{
			return myIndividualId;
		}
		
		public function set individualId(individualId:String):void
		{
			myIndividualId = individualId;
			boardLabel = boardLabel; // force update
		}
		
		public function get statusCode():int
		{
			return myStatusCode;
		}
		
		public function set statusCode(statusCode:int):void
		{
			myStatusCode = statusCode;
			isBlocked = isBlocked; // force update
		}
	}
}