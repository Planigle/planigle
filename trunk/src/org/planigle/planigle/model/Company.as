package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import org.planigle.planigle.commands.CreateProjectCommand;
	import org.planigle.planigle.commands.UpdateCompanyCommand;
	import org.planigle.planigle.commands.DeleteCompanyCommand;

	[RemoteClass(alias='Company')]
	[Bindable]
	public class Company
	{
		public var id:String;
		public var name:String;
		private var myProjects:Array = new Array();
		public var projectSelector:ArrayCollection = new ArrayCollection();
		private var projectMapping:Object = new Object();
		private static var expanded:Object = new Object(); // Keep in static so that it persists after reloading
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			name = xml.name;

			var newProjects:ArrayCollection = new ArrayCollection();
			for (var j:int = 0; j < xml.projects.project.length(); j++)
			{
				var project:Project = new Project();
				project.populate(XML(xml.projects.project[j]));
				newProjects.addItem(project);
			}
			projects = newProjects.source;
		}

		// Answer my display name.
		public function get displayName():String
		{
			return IndividualFactory.current() ? (IndividualFactory.current().isAdmin() ? name : projects[0].name) : '';
		}

		// Set the display name (currently ignored; used to prevent binding issue).
		public function set displayName(displayName:String):void
		{
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

		// Answer my projects.
		public function get projects():Array
		{
			return myProjects;
		}

		// Set my projects.
		public function set projects(projects:Array):void
		{
			projects.sortOn("name", Array.CASEINSENSITIVE);
			var newProjectSelector:ArrayCollection = new ArrayCollection();
			projectMapping = new Object();
			for each (var project:Project in projects)
			{
				project.company = this;
				newProjectSelector.addItem(project);
				projectMapping[project.id] = project;
			}
				
			myProjects = projects;
			
			var tm:Project = new Project();
			tm.populate( <project><id nil="true" /><name>No Project</name></project> );
			tm.teams = new Array();
			newProjectSelector.addItem( tm );
			projectSelector = newProjectSelector;
		}

		// Answer the description of my first project.
		public function get description():String
		{
			return projects[0].description;
		}
		
		// Answer the survey mode of my first project.
		public function get surveyMode():int
		{
			return projects[0].surveyMode;
		}

		// Resort my projects.
		public function resort():void
		{
			projects=projects.concat(); // set to a copy

			// Create copy to ensure any views get notified of changes.
			var companies:ArrayCollection = new ArrayCollection();
			for each (var company:Company in CompanyFactory.getInstance().companies)
				companies.addItem(company);
			CompanyFactory.getInstance().updateCompanies(companies);
		}

		// Answer my individuals.
		public function individuals():ArrayCollection
		{
			var individuals:ArrayCollection = new ArrayCollection();
			for each (var individual:Individual in IndividualFactory.getInstance().individualSelector)
			{
				if (!individual.id || (!individual.isAdmin() && individual.companyId == id))
					individuals.addItem(individual);
			}
			return individuals;
		}

		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateCompanyCommand(this, params, successFunction, failureFunction).execute(null);
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
			new DeleteCompanyCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			for each (var individual:Individual in IndividualFactory.getInstance().individuals)
				if (individual.companyId == id)
				{
					if (individual.role == 0)
						individual.companyId = null;
					else
						individual.destroyCompleted();
				}
			if (IndividualFactory.getInstance().currentIndividual.companyId == id)
				IndividualFactory.getInstance().currentIndividual.companyId = null;

			// Create copy to ensure any views get notified of changes.
			var companies:ArrayCollection = new ArrayCollection();
			for each (var company:Company in CompanyFactory.getInstance().companies)
			{
				if (company != this)
					companies.addItem(company);
			}
			CompanyFactory.getInstance().updateCompanies(companies);
		}

		// Create a new company.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createProject(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateProjectCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// A project has been successfully created.  Change myself to reflect the changes.
		public function createProjectCompleted(xml:XML):Project
		{
			var newProject:Project = new Project();
			newProject.populate(xml);

			// Create copy to ensure any views get notified of changes.
			var newProjects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in projects)
				newProjects.addItem(project);
			newProjects.addItem(newProject);
			projects = newProjects.source;

			// Create copy to ensure any views get notified of changes.
			var companies:ArrayCollection = new ArrayCollection();
			for each (var company:Company in CompanyFactory.getInstance().companies)
				companies.addItem(company);
			CompanyFactory.getInstance().companies = companies;

			return newProject;
		}

		// Find a project given its ID.  If no project, return a Project representing none.
		public function find(id:String):Project
		{
			var project:Project = projectMapping[id];
			return project ? project : Project(projectSelector.getItemAt(projectSelector.length-1));	
		}

		//  Yes, I'm a company.
		public function isCompany():Boolean
		{
			return true;
		}

		//  No, I'm not a project.
		public function isProject():Boolean
		{
			return false;
		}
		
		// Expand the project to show its projects.
		public function expand():void
		{
			expanded[String(id)] = true;
		}
		
		// Collapse the project to not show its projects.
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
		
		// Answer a label for my expand button.
		public function expandLabel():String
		{
			if (projects[0].teams.length == 0)
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
			return individual.companyId == id;
		}
	}
}