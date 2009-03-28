package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteIndividualCommand;
	import org.planigle.planigle.commands.UpdateIndividualCommand;

	[RemoteClass(alias='Individual')]
	[Bindable]
	public class Individual
	{
		public var id:String;
		public var companyId:String;
		public var mySelectedProjectId:String
		public var projectId:String
		public var teamId:String;
		public var login:String;
		public var email:String;
		public var firstName:String;
		public var lastName:String;
		public var role:int;
		public var activatedAt:Date;
		public var enabled:Boolean;
		public var lastLogin:Date;
		public var acceptedAgreement:Date;
		public var phoneNumber:String;
		public var notificationType:int;
		private static const ADMIN:int = 0;
		private static const PROJECT_ADMIN:int = 1;
		private static const PROJECT_USER:int = 2;
		private static const READ_ONLY:int = 3;
		private static var NO_PROJECT:Project = null;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			companyId = xml.child("company-id").toString() == "" ? null : xml.child("company-id");
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			selectedProjectId = xml.child("selected-project-id").toString() == "" ? null : xml.child("selected-project-id");
			teamId = xml.child("team-id").toString() == "" ? null : xml.child("team-id");
			login = xml.login;
			email = xml.email;
			firstName = xml.child("first-name");
			lastName = xml.child("last-name");
			role = int(xml.role);
			var activatedDate:String = xml.child("activated-at");
			activatedAt = activatedDate == "" ? null : DateUtils.stringToDate(activatedDate);
			enabled = xml.enabled == "true";
			var loginDate:String = xml.child("last-login");
			lastLogin = loginDate == "" ? null : DateUtils.stringToDate(loginDate);
			var acceptedDate:String = xml.child("accepted-agreement");
			acceptedAgreement = acceptedDate == "" ? null : DateUtils.stringToDate(acceptedDate);
			phoneNumber = xml.child("phone-number");
			notificationType = int(xml.child("notification-type"));
		}

		// Answer my full name.
		public function get fullName():String
		{
			return firstName + " " + lastName;
		}

		// Answer whether I have been activated.
		public function get activated():Boolean
		{
			return activatedAt != null;
		}
		
		// Answer a prettier formatted login time.
		public function get lastLoginTime():String
		{
			return lastLogin ? DateUtils.formatTime(lastLogin) : "";
		}
		
		public function set lastLoginTime(time:String):void
		{
		}

		// Answer my company.
		public function get company():Company
		{
			return CompanyFactory.getInstance().find(companyId);
		}

		// Set my company.
		private function set company(company:Company):void
		{
		}

		public function get allProjects():ArrayCollection
		{
			var projects:ArrayCollection = new ArrayCollection();
			if (isAdmin() || isPremium())
			{
				for each (var company:Company in CompanyFactory.getInstance().companies)
				{
					for each (var project:Project in company.projects)
						projects.addItem(project);
				}
				if (isAdmin())
					projects.addItem(noProject);
			}
			else
				projects.addItem(project);
			return projects;
		}
		
		// Answer an object that represents no project.
		private function get noProject():Project
		{
			if (NO_PROJECT == null)
			{
				NO_PROJECT = new Project();
				NO_PROJECT.name = "None";
			}
			return NO_PROJECT;
		}
		
		// All projects have changed.
		public function set allProjects(allProjects:ArrayCollection):void
		{
		}
		
		// Call when all projects have changed.
		public function allProjectsChanged():void
		{
			allProjects = new ArrayCollection();
		}

		// Answer my project.
		public function get project():Project
		{
			return company.find(projectId);
		}

		// Set my project.
		private function set project(project:Project):void
		{
		}

		// Answer my selected project.
		public function get selectedProject():Project
		{
			if (selectedProjectId == null || selectedProjectId == "")
				return isAdmin() ? noProject : project;
			else
			{
				for each (var company:Company in CompanyFactory.getInstance().companies)
				{
					for each (var project:Project in company.projects)
					{
						if (project.id == selectedProjectId)
							return project;
					}
				}
				return null;
			}
		}
		
		public function set selectedProject( project:Project ):void
		{
		}

		//  No, I'm not a project.
		public function isProject():Boolean
		{
			return false;
		}

		//  Yes, I'm an individual.
		public function isIndividual():Boolean
		{
			return true;
		}

		// Answer whether this user is a premium user.
		public function isPremium():Boolean
		{
			return selectedProject && selectedProject.isPremium();
		}

		// Answer my team.
		public function get team():Team
		{
			return project.find(teamId);
		}

		// Set my team.
		public function set team(team:Team):void
		{
		}

		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateIndividualCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			var oldProjectId:String = projectId;
			var oldTeamId:String = teamId;
			populate(xml);
			if (oldProjectId != projectId || oldTeamId != teamId)
				StructuralChangeNotifier.getInstance().structureChanged();
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteIndividualCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Update stories and tasks.
			for each (var story:Story in StoryFactory.getInstance().stories)
			{
				if (story.individualId == id)
					story.individualId = null;
				// Update tasks.
				for each (var task:Task in story.tasks)
				{
					if (task.individualId == id)
						task.individualId = null;
				}
			}


			// Create copy to ensure any views get notified of changes.
			var individuals:ArrayCollection = new ArrayCollection();
			for each (var individual:Individual in IndividualFactory.getInstance().individuals)
			{
				if (individual != this)
					individuals.addItem(individual);
			}
			IndividualFactory.getInstance().updateIndividuals(individuals);
			
			StructuralChangeNotifier.getInstance().structureChanged();
		}
		
		// Answer whether I am an admin.
		public function isAdmin():Boolean
		{
			return role == ADMIN;
		}
		
		// Answer whether I am an admin.
		public function isAtLeastProjectAdmin():Boolean
		{
			return role <= PROJECT_ADMIN;
		}

		// Answer whether I am read only.
		public function isReadOnly():Boolean
		{
			return role >= READ_ONLY;
		}
		
		// Answer whether I am a project user.
		public function get isAtLeastProjectUser():Boolean
		{
			return isAtLeastProjectAdmin() || (role <= PROJECT_USER && (selectedProjectId == null || selectedProjectId == projectId));
		}
		
		// Whether I am a project user has changed.
		public function set isAtLeastProjectUser(isSo: Boolean):void
		{
		}
		
		// Answer whether I an admin only (no project).
		public function isAdminOnly():Boolean
		{
			return isAdmin() && (selectedProjectId == null || selectedProjectId == "");
		}

		// Answer my selected project id.
		public function get selectedProjectId():String
		{
			return mySelectedProjectId;
		}

		// Set my selected project id.
		public function set selectedProjectId(id:String):void
		{
			mySelectedProjectId = id;
		}

		// Answer my name.
		public function get name():String
		{
			return fullName;
		}

		// Return my parent.
		public function get parent():Object
		{
			return IndividualFactory.current().selectedProject.find(teamId);
		}

		// Answer my children.
		public function get children():ArrayCollection
		{
			return null;
		}
	}
}