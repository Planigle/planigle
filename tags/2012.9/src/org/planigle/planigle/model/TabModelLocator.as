package org.planigle.planigle.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	
	import mx.core.Container;
	
	import org.planigle.planigle.view.ChangesTab;
	import org.planigle.planigle.view.StoriesTab;

	[Bindable]
	public class TabModelLocator
	{
		// Single instance of our viewModelLocator
		private static var instance:TabModelLocator;
		
		public function TabModelLocator(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One TabModelLocator");
		}

		// Returns the single instance.
		public static function getInstance():TabModelLocator
		{
			if (instance == null)
				instance = new TabModelLocator(new SingletonEnforcer);
			return instance;
		}
		
		public var selectedTab:Container;
		public var stories:StoriesTab;
		public var changes:ChangesTab;
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}