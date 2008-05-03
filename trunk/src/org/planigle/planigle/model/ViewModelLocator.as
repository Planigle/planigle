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
	        {
	        	throw new Error("You Can Only Have One ModelLocator");
	        }	
			
		}
		
		// Returns the single instance
		public static function getInstance():ViewModelLocator
		{
			if (instance == null)
			{
				instance = new ViewModelLocator(new SingletonEnforcer);
			}
			return instance;
		}
		
		// Variables
		public var workflowState:uint = 0;
		
		// Contants
		public static const LOGIN_SCREEN:uint = 0;
		public static const CORE_APPLICATION_SCREEN:uint = 1;
		

	}
}
// Utility class to deny access to contructor.
class SingletonEnforcer {}