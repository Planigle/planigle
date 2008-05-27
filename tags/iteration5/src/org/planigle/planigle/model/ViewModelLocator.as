package org.planigle.planigle.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import flash.events.Event;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import org.planigle.planigle.events.*;

	[Bindable]
	public class ViewModelLocator implements IModelLocator
	{
		// Single instance of our viewModelLocator
		private static var instance:ViewModelLocator;
		private var currentUsername:String;
		
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
			ChangeWatcher.watch( this, "individuals", individualsChanged );
			ChangeWatcher.watch( this, "currentUser", currentUserChanged );
		}
		
		// Update variables that rely on project info.
		private function projectsChanged(event:Event):void
		{
			projectSelector = <project><id nil="true" /><name>All</name></project> + projects;
			projectCount = projects.length();
		}
	
		// Update variables that rely on individual info.
		private function individualsChanged(event:Event):void
		{
			individualSelector = <individual><id nil="true" /><full-name>No Owner</full-name></individual> + individuals;
			individualCount = individuals.length();
			currentUser = individuals.(login == currentUsername);
		}
	
		// Update info relevant to the current user.
		private function currentUserChanged(event:Event):void
		{
			if ( currentUser && !isAdmin() )
			{ // Admins don't need this info.
				new IterationChangedEvent().dispatch();			
				new StoryChangedEvent().dispatch();			
			}			
		}
		
		// Answer whether the current user is an admin.
		public function isAdmin():Boolean
		{
			return currentUser && currentUser.child("project-id") == ""
		}
	
		// Update after a new user is logged in.
		public function setUser(username:String):void
		{
			currentUsername = username;
			new IndividualChangedEvent().dispatch();		
			new ProjectChangedEvent().dispatch();
		}
		
		// Variables
		public var workflowState:uint = 0;
		public var projects:XMLList = new XMLList();
		public var projectSelector:XMLList = new XMLList();
		public var projectCount:int = 0;
		public var individuals:XMLList = new XMLList();
		public var individualSelector:XMLList = new XMLList();
		public var individualCount:int = 0;
		public var currentUser:XMLList = null;
	
		// Constants
		public static const LOGIN_SCREEN:uint = 0;
		public static const CORE_APPLICATION_SCREEN:uint = 1;
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}