package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import org.planigle.planigle.commands.CreateStoryCommand;

	[Bindable]
	public class StoryFactory
	{
		public var timeUpdated:String;
		public var stories:ArrayCollection = new ArrayCollection();
		private static var instance:StoryFactory;
		private var storyMapping:Object = new Object();
		
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
		
		public function clearTimeUpdated():void {
			timeUpdated = null;
		}

		public function epicSelector():ArrayCollection
		{
			var newEpicSelector:ArrayCollection = new ArrayCollection();
			for each(var story:Story in stories)
			{
				if (story.canBeEpic())
					newEpicSelector.addItem(story);
			}
			var noEpic:Story = new Story();
			noEpic.populate( <story><id nil="true" /><name>No Epic</name></story> );
			newEpicSelector.addItem( noEpic );
			return newEpicSelector;
		}

		// Populate the stories.
		public function populate(timeUpdated:String, someStories:Array):void
		{
			this.timeUpdated = timeUpdated;
			stories = new ArrayCollection();
			storyMapping = new Object();
			populateMore(someStories);
		}

		// Populate additional stories.
		public function populateMore(someStories:Array):void
		{
			var newStories:ArrayCollection = new ArrayCollection(someStories);
			for each (var story:Story in newStories)
				storyMapping[story.id] = story;
			var temp:ArrayCollection = new ArrayCollection();
			temp.addAll(stories);
			temp.addAll(newStories);
			stories = temp;
			normalizePriorities();
		}
		
		// Create a new story.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createStory(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateStoryCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// A story has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Story
		{
			var newStory:Story = new Story();
			newStory.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newStories:ArrayCollection = new ArrayCollection();
			for each (var story:Story in stories)
				newStories.addItem(story);
			newStories.addItem(newStory);
			sortStories(newStories);
			populate(timeUpdated, newStories.toArray());
			return newStory;
		}
		
		protected function sortStories(stories:ArrayCollection):void
		{
			var sortField:SortField = new SortField();
			sortField.name = "priority";
			sortField.numeric = true;
			var sort:Sort = new Sort();
			sort.fields = [sortField];
			stories.sort = sort;
			stories.refresh();
		}

		// Find a story given its ID.  If no story, return null.
		public function find(id:int):Story
		{
			var story:Story = storyMapping[id];
			if(story == null)
			{
				for each (var candidate:Story in stories)
				{
					story = candidate.findStory(id);
					if(story != null)
						break;
				}
			}
			return story;
		}
		
		// Normalize the priorities so that they are 1..n (excluding accepted stories).
		public function normalizePriorities():void
		{
			stories.source.sortOn("priority", Array.NUMERIC);
			var i:int = 1;
			for each (var story:Story in stories)
			{
				if (story.statusCode == Story.ACCEPTED)
					story.normalizedPriority = '';
				else
				{
					story.normalizedPriority = String(i);
					i++;
				}
			}
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}