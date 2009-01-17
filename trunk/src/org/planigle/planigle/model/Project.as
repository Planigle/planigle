package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateStoryAttributeCommand;
	import org.planigle.planigle.commands.CreateTeamCommand;
	import org.planigle.planigle.commands.DeleteProjectCommand;
	import org.planigle.planigle.commands.UpdateProjectCommand;

	[RemoteClass(alias='Project')]
	[Bindable]
	public class Project
	{
		public var id:String;
		public var company:Company;
		public var companyId:String;
		public var name:String;
		public var description:String;
		public var surveyKey:String;
		public var surveyMode:int;
		public var premiumExpiry:Date;
		public var premiumLimit:int;
		private static const PRIVATE:int = 0;
		private static const PRIVATE_BY_DEFAULT:int = 1;
		private static const PUBLIC_BY_DEFAULT:int = 2;
		private var myStoryAttributes:Array = new Array();
		private var myTeams:Array = new Array();
		public var teamSelector:ArrayCollection = new ArrayCollection();
		private var teamMapping:Object = new Object();
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			companyId = xml.child("company-id").toString() == "" ? null : xml.child("company-id");
			name = xml.name;
			description = xml.description;
			surveyKey = xml.child("survey-key");
			surveyMode = int(xml.child("survey-mode"));
			premiumExpiry = DateUtils.stringToDate(xml.child("premium-expiry"));			
			premiumLimit = xml.child("premium-limit");			

			var newStoryAttributes:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.child("story-attributes").child("story-attribute").length(); i++)
			{
				var storyAttribute:StoryAttribute = new StoryAttribute();
				storyAttribute.populate(XML(xml.child("story-attributes").child("story-attribute")[i]));
				newStoryAttributes.addItem(storyAttribute);
			}
			storyAttributes = newStoryAttributes.source;

			var newTeams:ArrayCollection = new ArrayCollection();
			for (var j:int = 0; j < xml.teams.team.length(); j++)
			{
				var team:Team = new Team();
				team.populate(XML(xml.teams.team[j]));
				newTeams.addItem(team);
			}
			teams = newTeams.source;
		}

		// Answer my story attributes.
		public function get storyAttributes():Array
		{
			return myStoryAttributes;
		}

		// Set my story attributes.
		public function set storyAttributes(storyAttributes:Array):void
		{
			storyAttributes.sortOn(["name"], [Array.CASEINSENSITIVE]);
			for each (var storyAttribute:StoryAttribute in storyAttributes)
				storyAttribute.project = this;

			myStoryAttributes = storyAttributes;
		}
		
		// Answer how much to indent this kind of item.
		public function get indent():int
		{
			return 25;
		}

		// Set the indent (currently ignored; used to prevent binding issue).
		public function set indent(indent:int):void
		{
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
			storyAttributes=storyAttributes.concat(); // set to a copy
			teams=teams.concat(); // set to a copy

			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in company.projects)
				projects.addItem(project);
			company.projects = projects.source;
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
			for each (var project:Project in company.projects)
			{
				if (project != this)
					projects.addItem(project);
			}
			company.projects = projects.source;

			// Create copy to ensure any views get notified of changes.
			var companies:ArrayCollection = new ArrayCollection();
			for each (var aCompany:Company in CompanyFactory.getInstance().companies)
				companies.addItem(aCompany);
			CompanyFactory.getInstance().updateCompanies(companies);
		}

		// Create a new story attribute.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createStoryAttribute(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateStoryAttributeCommand(this, params, successFunction, failureFunction, createStoryAttributeCompleted).execute(null);
		}
		
		// A story attribute has been successfully created.  Change myself to reflect the changes.
		public function createStoryAttributeCompleted(xml:XML):StoryAttribute
		{
			var newStoryAttribute:StoryAttribute = new StoryAttribute();
			newStoryAttribute.populate(xml);

			// Create copy to ensure any views get notified of changes.
			var newStoryAttributes:ArrayCollection = new ArrayCollection();
			for each (var storyAttribute:StoryAttribute in storyAttributes)
				newStoryAttributes.addItem(storyAttribute);
			newStoryAttributes.addItem(newStoryAttribute);
			storyAttributes = newStoryAttributes.source;

			return newStoryAttribute;
		}

		// Create a new team.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createTeam(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateTeamCommand(this, params, successFunction, failureFunction, createTeamCompleted).execute(null);
		}
		
		// An team has been successfully created.  Change myself to reflect the changes.
		public function createTeamCompleted(xml:XML):Team
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
			var companies:ArrayCollection = new ArrayCollection();
			for each (var aCompany:Company in CompanyFactory.getInstance().companies)
				companies.addItem(aCompany);
			CompanyFactory.getInstance().updateCompanies(companies);

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

		//  No, I'm not a company.
		public function isCompany():Boolean
		{
			return false;
		}

		//  Yes, I'm a project.
		public function isProject():Boolean
		{
			return true;
		}

		//  No, I'm not a team.
		public function isTeam():Boolean
		{
			return false;
		}
		
		// Answer whether I have any teams.
		public function hasTeams():Boolean
		{
			return teams.length > 0;
		}

		//  No, I'm not an individual.
		public function isIndividual():Boolean
		{
			return false;
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
	}
}