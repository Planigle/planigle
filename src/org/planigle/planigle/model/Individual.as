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
		private var _projectId:String;
		private var _project:Project;
		private var _teamId:String;
		private var _team:Team;
		private static const ADMIN:int = 0;
		private static const PROJECT_ADMIN:int = 1;
		private static const PROJECT_USER:int = 2;
		private static const READ_ONLY:int = 3;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
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

		// Answer my project.
		public function get project():Project
		{
			if (!_project && projectId)
				_project = ProjectFactory.getInstance().find(projectId);
			return _project;
		}

		// Set my project.
		private function set project(project:Project):void
		{
			_project = project;
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
			return project && project.isPremium();
		}

		// Answer my project id.
		public function get projectId():String
		{
			return _projectId;
		}

		// Set my project id.
		public function set projectId(newId:String):void
		{
			_projectId = newId;
			project = null;
		}

		// Answer my team.
		public function get team():Team
		{
			if (!_team && teamId)
				_team = project.find(teamId);
			return _team;
		}

		// Answer my team id.
		public function get teamId():String
		{
			return _teamId;
		}

		// Set my team id.
		public function set teamId(newId:String):void
		{
			_teamId = newId;
			_team = null;
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
			populate(xml);
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
		
		// Answer whether I am an admin.
		public function isAtLeastProjectUser():Boolean
		{
			return role <= PROJECT_USER;
		}
		
		// Answer whether I an admin only (no project).
		public function isAdminOnly():Boolean
		{
			return !projectId;
		}

		// Answer my name.
		public function get name():String
		{
			return fullName;
		}

		// Return my parent.
		public function get parent():Object
		{
			return IndividualFactory.current().project.find(teamId);
		}

		// Answer my children.
		public function get children():ArrayCollection
		{
			return null;
		}
	}
}