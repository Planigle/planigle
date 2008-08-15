package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateProjectCommand;
	
	[Bindable]
	public class ProjectFactory
	{
		public var projects:ArrayCollection = new ArrayCollection();
		public var projectSelector:ArrayCollection = new ArrayCollection();
		private var projectMapping:Object = new Object();
		private static var instance:ProjectFactory;
		
		public function ProjectFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One ProjectFactory");
		}

		// Returns the single instance.
		public static function getInstance():ProjectFactory
		{
			if (instance == null)
				instance = new ProjectFactory(new SingletonEnforcer);
			return instance;
		}

		// Update my projects to be the specified projects.
		public function updateProjects( newProjects:ArrayCollection ):void
		{
			var newProjectSelector:ArrayCollection = new ArrayCollection();
			projectMapping = new Object();

			for each (var project:Project in newProjects)
			{
				newProjectSelector.addItem(project);
				projectMapping[project.id] = project;
			}
			
			var proj:Project = new Project();
			proj.populate( <project><id nil="true" /><name>None</name></project> );
			newProjectSelector.addItem( proj );
			projects = newProjects;
			projectSelector = newProjectSelector;
		}

		// Populate the projects.
		public function populate(newProjects:Array):void
		{
			updateProjects(new ArrayCollection(newProjects));
		}
		
		// Create a new project.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createProject(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateProjectCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An project has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Project
		{
			var newProject:Project = new Project();
			newProject.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newProjects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in projects)
				newProjects.addItem(project);
			newProjects.addItem(newProject);
			updateProjects(newProjects);
			return newProject;
		}

		// Find an project given its ID.  If no project, return an Project representing the backlog.
		public function find(id:String):Project
		{
			var project:Project = projectMapping[id];
			return project ? project : Project(projectSelector.getItemAt(projectSelector.length-1));	
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}