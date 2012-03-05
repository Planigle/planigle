package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.StoriesDelegate;
	import org.planigle.planigle.model.Story;
	import org.planigle.planigle.model.StoryFactory;
	
	public class GetStoriesCommand implements ICommand, IResponder
	{
		static protected var commands:ArrayCollection = new ArrayCollection();		
		static protected var currentId:int = 0;
		protected var id:int;
		protected var page:int;
		protected var cancelled:Boolean = false;

		static public function isLoading():Boolean
		{
			for each (var command:Object in commands)
			{
				if (command is GetStoriesCommand && !command.cancelled)
					return Story.shouldGetMore();
			}
			
			return false;
		}

		static public function cancelCommandsInProgress():void
		{
			for each (var command:Object in commands)
				command.cancelled = true;
		}
		
		static public function addCommand(command:Object):void
		{
			commands.addItem(command);
		}
		
		public function GetStoriesCommand(page:int = 1)
		{
			this.id = ++currentId;
			this.page = page;
			addCommand(this);
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			if (!cancelled && (page == 1 || Story.shouldGetMore()))
				new StoriesDelegate( this, page == 1 ? StoryFactory.getInstance().timeUpdated : null, page ).get();
			else
				remove();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (id == currentId && result.records != null && !cancelled)
			{
				var stories:Array = result.records as Array;
				if (stories.length == 0)
					cancelled = true;
				if (page == 1)
					StoryFactory.getInstance().populate(result.time, stories);
				else
					StoryFactory.getInstance().populateMore(stories);
				++page;
				execute(null);
			} else
				remove();
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			remove();
			if (page == 1)
				Alert.show(event.fault.faultString);
		}
		
		protected function remove():void
		{
			commands.removeItemAt(commands.getItemIndex(this));
		}
	}
}