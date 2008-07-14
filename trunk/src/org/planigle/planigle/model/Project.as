package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
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
		private static const PRIVATE:int = 0;
		private static const PRIVATE_BY_DEFAULT:int = 1;
		private static const PUBLIC_BY_DEFAULT:int = 2;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id == "" ? null: xml.id;
			name = xml.name;
			description = xml.description;
			surveyKey = xml.child("survey-key");
			surveyMode = int(xml.child("survey-mode"));
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
			// Create copy to ensure any views get notified of changes.
			var projects:ArrayCollection = new ArrayCollection();
			for each (var project:Project in ProjectFactory.getInstance().projects)
			{
				if (project != this)
					projects.addItem(project);
			}
			ProjectFactory.getInstance().updateProjects(projects);
		}
	}
}