package org.planigle.planigle.model
{
	import com.adobe.cairngorm.model.IModelLocator;

	[Bindable]
	public class ViewModelLocator implements IModelLocator
	{
		// Single instance of our viewModelLocator
		private static var instance:ViewModelLocator;
		
		public function ViewModelLocator(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One ModelLocator");
		}

		// Returns the single instance.
		public static function getInstance():ViewModelLocator
		{
			if (instance == null)
				instance = new ViewModelLocator(new SingletonEnforcer);
			return instance;
		}

		// Keep track of whether we are waiting for data.
		public function waitingForData():void
		{
			dataCount++
		}

		// We are no longer waiting for data.
		public function gotData():void
		{
			dataCount--
			if (dataCount == 0) // Can now show the screen
				workflowState = ViewModelLocator.CORE_APPLICATION_SCREEN;
		}
		
		// Variables
		public var workflowState:uint = 0;
		private var dataCount:int = 0;
	
		// Constants
		public static const LOGIN_SCREEN:uint = 0;
		public static const CORE_APPLICATION_SCREEN:uint = 1;
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}