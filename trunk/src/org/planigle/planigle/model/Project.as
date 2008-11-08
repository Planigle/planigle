package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import org.planigle.planigle.commands.CreateTeamCommand;
	import org.planigle.planigle.commands.DeleteProjectCommand;
	import org.planigle.planigle.commands.UpdateProjectCommand;

	[RemoteClass(alias='Project')]
	[Bindable]
	public class Project
	{
		public var id:String;
		public var name:String;
		public var description:String;
		public var surveyKey:String;
		public var surveyMode:int;
		public var premiumExpiry:Date;
		public var premiumLimit:int;
		private static const PRIVATE:int = 0;
		private static const PRIVATE_BY_DEFAULT:int = 1;
		private static const PUBLIC_BY_DEFAULT:int = 2;
		private var myTeams:Array = new Array();
		public var teamSelector:ArrayCollection = new ArrayCollection();
		private var teamMapping:Object = new Object();
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			name = xml.name;
			description = xml.description;
			surveyKey = xml.child("survey-key");
			surveyMode = int(xml.child("survey-mode"));
			premiumExpiry = DateUtils.stringToDate(xml.child("premium-expiry"));			
			premiumLimit = xml.child("premium-limit");			

			var newTeams:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.teams.team.length(); i++)
			{
				var team:Team = new Team();
				team.populate(XML(xml.teams.team[i]));
				newTeams.addItem(team);
			}
			teams = newTeams.source;
		}

		// For projects, the list name is not indented.
		public function get listName():String
		{
			return name;
		}

		// Answer my teams.
		public function get teams():Array
		{
			return myTeams;
		}

		// Set my teams.
		public function set teams(teams:Array):void
		{
			teams.sortOn("name", Array.CASEINSENSITIVE);
			var newTeamSelector:ArrayCollection = new ArrayCollection();
			teamMapping = new Object();
			for each (var team:Team in teams)
			{
				team.project = this;
				newTeamSelector.addItem(team);
				teamMapping[team.id] = team;
			}
				
			myTeams = teams;
			
			var tm:Team = new Team();
			tm.populate( <team><id nil="true" /><name>No Team</name></team> );
			newTeamSelector.addItem( tm );
			teamSelector = newTeamSelector;
		}

		// Resort my teams.
		public function resort():void
		{
			teams=teams.concat(); // set to a copy

			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in ProjectFactory.getInstance().projects)
				projects.addItem(project);
			ProjectFactory.getInstance().updateProjects(projects);
		}

		// Answer my individuals.
		public function individuals():ArrayCollection
		{
			var individuals:ArrayCollection = new ArrayCollection();
			for each (var individual:Individual in IndividualFactory.getInstance().individualSelector)
			{
				if (!individual.id || (!individual.isAdmin() && individual.projectId == id))
					individuals.addItem(individual);
			}
			return individuals;
		}

		// Answer whether this project has premium features.
		public function isPremium():Boolean
		{
			return premiumExpiry > new Date();
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateProjectCommand(this, params, successFunction, failureFunction).execute(null);
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
			new DeleteProjectCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			for each (var individual:Individual in IndividualFactory.getInstance().individuals)
				if (individual.projectId == id)
				{
					if (individual.role == 0)
						individual.projectId = null;
					else
						individual.destroyCompleted();
				}
			if (IndividualFactory.getInstance().currentIndividual.projectId == id)
				IndividualFactory.getInstance().currentIndividual.projectId = null;

			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in ProjectFactory.getInstance().projects)
			{
				if (project != this)
					projects.addItem(project);
			}
			ProjectFactory.getInstance().updateProjects(projects);
		}

		// Create a new team.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createTeam(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateTeamCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An team has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Team
		{
			var newTeam:Team = new Team();
			newTeam.populate(xml);

			// Create copy to ensure any views get notified of changes.
			var newTeams:ArrayCollection = new ArrayCollection();
			for each (var team:Team in teams)
				newTeams.addItem(team);
			newTeams.addItem(newTeam);
			teams = newTeams.source;

			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in ProjectFactory.getInstance().projects)
				projects.addItem(project);
			ProjectFactory.getInstance().projects = projects;

			return newTeam;
		}

		// Find a team given its ID.  If no team, return an Team representing none.
		public function find(id:String):Team
		{
			var team:Team = teamMapping[id];
			return team ? team : Team(teamSelector.getItemAt(teamSelector.length-1));	
		}
		
		// Expand the project to show its teams.
		public function expand():void
		{
			expanded[String(id)] = true;
		}
		
		// Collapse the project to not show its teams.
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
		
		// Answer whether the project is expanded.
		public function isExpanded():Boolean
		{
			return expanded.hasOwnProperty(String(id)) && expanded[String(id)];
		}

		//  Yes, I'm a project.
		public function isProject():Boolean
		{
			return true;
		}
		
		// Answer a label for my expand button.
		public function expandLabel():String
		{
			if (teams.length == 0)
				return "";
			else
				return isExpanded() ? "-" : "+";
		}
		
		// Answer my background color.  -1 means use the default.
		public function backgroundColor():int
		{
			return -1;
		}

		// Answer whether I contain the specified individual.
		public function containsIndividual(individual:Individual):Boolean
		{
			return individual.projectId == id;
		}

		// Return my parent.
		public function get parent():Object
		{
			return null;
		}

		// Answer my children.
		public function get children():ArrayCollection
		{
			return (teamSelector.length > 1) ? teamSelector : individuals();
		}

		// Answer my velocity.
		public function get velocity():Number
		{
			var sum:Number = 0;
			for each(var child:Object in children)
				sum += child.velocity;
			return sum;
		}

		// Answer my velocity in the specified stories.
		public function velocityIn(stories:ArrayCollection):Number
		{
			var sum:Number = 0;
			for each(var child:Object in children)
				sum += child.velocityIn(stories);
			return sum;
		}
	}
}