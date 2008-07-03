package org.planigle.planigle.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import flash.events.Event;
	import mx.binding.utils.ChangeWatcher;

	[Bindable]
	public class ViewModelLocator implements IModelLocator
	{
		// Single instance of our viewModelLocator
		private static var instance:ViewModelLocator;
		
		public function ViewModelLocator(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One ModelLocator");
			initializeWatchers();
		}

		// Returns the single instance.
		public static function getInstance():ViewModelLocator
		{
			if (instance == null)
				instance = new ViewModelLocator(new SingletonEnforcer);
			return instance;
		}

		// Register interest in key variables so that dependent variables can be updated.
		private function initializeWatchers():void
		{
			ChangeWatcher.watch( this, "projects", projectsChanged );
		}
		
		// Update variables that rely on project info.
		private function projectsChanged(event:Event):void
		{
			projectSelector = <project><id nil="true" /><name>None</name></project> + projects;
			projectCount = projects.length();
		}
		
		// Variables
		public var workflowState:uint = 0;
		public var projects:XMLList = new XMLList();
		public var projectSelector:XMLList = new XMLList();
		public var projectCount:int = 0;
	
		// Constants
		public static const LOGIN_SCREEN:uint = 0;
		public static const CORE_APPLICATION_SCREEN:uint = 1;
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}