package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteTeamCommand;
	import org.planigle.planigle.commands.UpdateTeamCommand;

	[RemoteClass(alias='Team')]
	[Bindable]
	public class Team
	{
		public var project:Project;
		public var id:String;
		public var projectId:String;
		public var name:String;
		public var description:String;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			projectId = xml.child("project-id") == "" ? null : xml.child("project-id");
			name = xml.name;
			description = xml.description;
		}

		// For teams, the list name is indented.
		public function get listName():String
		{
			return "     " + name;
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateTeamCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteTeamCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			var teamCollect:ArrayCollection = new ArrayCollection(project.teams);
			teamCollect.removeItemAt(teamCollect.getItemIndex(this));
			project.teams = teamCollect.source;

			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var aProject:Project in ProjectFactory.getInstance().projects)
				projects.addItem(aProject);
			ProjectFactory.getInstance().projects = projects;
		}

		//  No, I'm not a project.
		public function isProject():Boolean
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

		// Answer whether I contain the specified individual.
		public function containsIndividual(individual:Individual):Boolean
		{
			return individual.teamId == id;
		}
	}
}