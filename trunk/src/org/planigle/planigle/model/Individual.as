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
		public var myProjectIds:String;
		public var myProjects:Array;
		public var teamId:String;
		public var login:String;
		public var email:String;
		public var firstName:String;
		public var lastName:String;
		public var role:int;
		public var activatedAt:Date;
		public var enabled:Boolean;
		public var refreshInterval:int;
		public var lastLogin:Date;
		public var acceptedAgreement:Date;
		public var phoneNumber:String;
		public var notificationType:int;
		public var capacity:Number;
		public var updatedAtString:String;
		private static const ADMIN:int = 0;
		private static const PROJECT_ADMIN:int = 1;
		private static const PROJECT_USER:int = 2;
		private static const READ_ONLY:int = 3;
		private static var NO_PROJECT:Project = null;

		public function getCurrentVersion():Object
		{
			return IndividualFactory.getInstance().find(id);
		}
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			companyId = xml.child("company-id").toString() == "" ? null : xml.child("company-id");
			projectIds = xml.child("project-ids").toString() == "" ? null : xml.child("project-ids").toString();
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
			refreshInterval = xml.child("refresh-interval");
			var loginDate:String = xml.child("last-login");
			lastLogin = loginDate == "" ? null : DateUtils.stringToDate(loginDate);
			var acceptedDate:String = xml.child("accepted-agreement");
			acceptedAgreement = acceptedDate == "" ? null : DateUtils.stringToDate(acceptedDate);
			phoneNumber = xml.child("phone-number");
			notificationType = int(xml.child("notification-type"));
			updatedAtString = xml.child("updated-at");
		}
		
		public function get projectIds():String
		{
			return myProjectIds;
		}
				
		public function set projectIds(ids:String):void
		{
			myProjects = null;
			allProjects = null;
			myProjectIds = ids;
		}
		
		public function get projects():Array
		{
			if (myProjects == null)
			{
				if (projectIds == null)
					return new Array(0);
				else
				{
					var projectIdArray:Array = projectIds.split(",");
					var array:Array = new Array(projectIdArray.length);
					var i:int = 0;
					for each (var projectId:String in projectIdArray)
					{
						array[i] = CompanyFactory.getInstance().findProject(projectId);
						i++;
					}
					array.sortOn("name");
					myProjects = array;
				}
			}
			return myProjects;
		}

		public function reloadProjects():void
		{
			projectIds = projectIds;
		}

		public function isInProject(project:Project):Boolean
		{
			for each (var myProject:Project in projects)
			{
				if (project.id == myProject.id)
					return true;
			}
			return false;
		}
		
		// Remove a project if it is in my list of projects.
		public function removeProject(project:Project):void
		{
			if (isInProject(project))
			{
				var array:Array = new Array(projects.length - 1);
				var i:int = 0;
				for each (var myProject:Project in projects)
				{
					if (project.id != myProject.id)
					{
						array[i] = project;
						i++;
					} 
				}
			}
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
			var allProjects:ArrayCollection = new ArrayCollection();
			if (CompanyFactory.getInstance().companySelector.length == 0)
				return allProjects; // too early to call this; still setting up
			if (isAdmin() || isPremium)
			{
				for each (var company:Company in CompanyFactory.getInstance().companies)
				{
					for each (var project:Project in company.projects)
						allProjects.addItem(project);
				}
			}
			return allProjects;
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
			allProjects = null;
		}

		// Answer my selected project.
		public function get selectedProject():Project
		{
			if (selectedProjectId == null || selectedProjectId == "")
				return noProject;
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
				return noProject;
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
		public function get isPremium():Boolean
		{
			var co:Company = selectedProject && selectedProject.company ? selectedProject.company : company;
			return co.isPremium;
		}

		// Set whether this user is a premium user.
		public function set isPremium(isPremium:Boolean):void
		{
		}

		// Answer my team.
		public function get team():Team
		{
			for each(var project:Project in projects)
			{
				var team:Team = project.find(teamId);
				if (team.id != null)
					return team;
			}
			return Project.noTeam;
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
			params["updated_at"] = updatedAtString;
			new UpdateIndividualCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			mySelectedProjectId = xml.child("selected-project-id").toString() == "" ? null : xml.child("selected-project-id");

 			var oldProjects:Array = projects;
			var oldTeamId:String = teamId;
			populate(xml);

			if (selectedProject.storyAttributes.length == 0)
				return; // When changing projects, we want to ignore this change and let the refresh update

			if (oldTeamId  != teamId)
				StructuralChangeNotifier.getInstance().structureChanged();
			else
			{
				for each (var project:Project in oldProjects)
				{
					if (!isInProject(project))
					{
						StructuralChangeNotifier.getInstance().structureChanged();
						break;
					}
				}
			}
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
			return isAtLeastProjectAdmin() || (role <= PROJECT_USER && (selectedProjectId == null || isInProject(selectedProject)));
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
		
		public function get initials():String
		{
			var initials:String = "";
			if (firstName != "")
				initials += firstName.charAt(0);
			if (lastName != "")
				initials += lastName.charAt(0);
			return initials;
		}
	}
}