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
		
		// Variables
		public var workflowState:uint = 0;
	
		// Constants
		public static const SIGNUP:uint = 1;
		public static const LICENSE_AGREEMENT_SCREEN:uint = 2;
		public static const LOGIN_SCREEN:uint = 3;
		public static const CORE_APPLICATION_SCREEN:uint = 4;
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}