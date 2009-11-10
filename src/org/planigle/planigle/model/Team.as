package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
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
			id = xml.id.toString() == "" ? null: xml.id;
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			name = xml.name;
			description = xml.description;
		}
		
		// Answer how much to indent this kind of item.
		public function get indent():int
		{
			return 45;
		}

		// Set the indent (currently ignored; used to prevent binding issue).
		public function set indent(indent:int):void
		{
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
			project.resort();
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
			// Update individuals.
			for each (var individual:Individual in IndividualFactory.getInstance().individuals)
			{
				if (individual.teamId == id)
					individual.teamId = null;
			}

			// Update stories.
			for each (var story:Story in StoryFactory.getInstance().stories)
			{
				if (story.teamId == id)
					story.teamId = null;
			}

			// Create copy to ensure any views get notified of changes.
			var teams:ArrayCollection = new ArrayCollection();
			for each (var team:Team in project.teams)
			{
				if (team != this)
					teams.addItem(team);
			}
			project.teams = teams.source;

			// Create copy to ensure any views get notified of changes.
			var companies:ArrayCollection = new ArrayCollection();
			for each (var aCompany:Company in CompanyFactory.getInstance().companies)
				companies.addItem(aCompany);
			CompanyFactory.getInstance().updateCompanies(companies);
			
			StructuralChangeNotifier.getInstance().structureChanged();
		}

		//  No, I'm not a company.
		public function isCompany():Boolean
		{
			return false;
		}

		//  No, I'm not a project.
		public function isProject():Boolean
		{
			return false;
		}

		//  Yes, I'm a team.
		public function isTeam():Boolean
		{
			return true;
		}

		//  No, I'm not an individual.
		public function isIndividual():Boolean
		{
			return false;
		}
		
		// Answer my company.
		public function get company():Company
		{
			return project ? project.company : null;
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

		// Answer my individuals.
		public function individuals():ArrayCollection
		{
			var individuals:ArrayCollection = new ArrayCollection();
			for each (var individual:Individual in IndividualFactory.getInstance().individualSelector)
			{
				if (!individual.id || (individual.teamId == id && individual.isInProject(project)))
					individuals.addItem(individual);
			}
			return individuals;
		}

		// Answer whether I contain the specified individual.
		public function containsIndividual(individual:Individual):Boolean
		{
			return individual.teamId == id;
		}

		// Return my parent.
		public function get parent():Object
		{
			return IndividualFactory.current().selectedProject;
		}

		// Answer my children.  Change none to have me as its team.
		public function get children():ArrayCollection
		{
			var children:ArrayCollection = individuals();
			var none:Individual = Individual(children.removeItemAt(children.length - 1));
			none = Individual(ObjectUtil.copy(none));
			none.teamId = id;
			for (var i:int = children.length - 1; i >= 0; i--)
			{
				if (!children.getItemAt(i).enabled)
					children.removeItemAt(i);
			}
			children.addItem(none);
			return children;
		}
	}
}