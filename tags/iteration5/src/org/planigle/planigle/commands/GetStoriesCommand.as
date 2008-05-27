package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import org.planigle.planigle.business.StoriesDelegate;
	import org.planigle.planigle.model.ViewModelLocator;
	import org.planigle.planigle.model.StoryFactory;
	
	public class GetStoriesCommand implements ICommand, IResponder
	{
		public var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		
		public function GetStoriesCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			//  Delegate acts as both delegate and responder.
			var delegate:StoriesDelegate = new StoriesDelegate( this );
			
			delegate.getStories();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			StoryFactory.getInstance().populate(event.result.children());
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}