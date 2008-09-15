package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.commands.GetStoriesCommand;
	import org.planigle.planigle.events.StoryChangedEvent;
	
	public class StoriesController extends FrontController
	{
		public function StoriesController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(StoryChangedEvent.STORY_CHANGED, GetStoriesCommand);	
		}
	}
}