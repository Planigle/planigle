package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class StoryFactory
	{
		public var stories:ArrayCollection = new ArrayCollection();
		private static var instance:StoryFactory;
		
		public function StoryFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One StoryFactory");
		}

		// Returns the single instance.
		public static function getInstance():StoryFactory
		{
			if (instance == null)
				instance = new StoryFactory(new SingletonEnforcer);
			return instance;
		}

		// Populate the stories based on XML.
		public function populate(xml:XMLList):void
		{
			var newStories:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.length(); i++)
				newStories.addItem(new Story(xml[i]));
			stories = newStories;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}