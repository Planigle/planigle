package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateStoryCommand;

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
		
		// Create a new story.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createStory(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateStoryCommand(params, successFunction, failureFunction).execute(null);
		}
		
		// A story has been successfully created.  Change myself to reflect the changes.
		public function createStoryCompleted(xml:XML):Story
		{
			var story:Story = new Story(xml);
			// Create copy to ensure any views get notified of changes.
			var newStories:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < stories.length; i++)
				newStories.addItem(stories.getItemAt(i));
			newStories.addItem(story);
			stories = newStories;
			return story;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}