package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.rpc.IResponder;	
	import org.planigle.planigle.business.SessionDelegate;
	import org.planigle.planigle.events.RefreshEvent;
	import org.planigle.planigle.model.PlanigleSystem;
	import org.planigle.planigle.model.CompanyFactory;
	import org.planigle.planigle.model.IndividualFactory;
	import org.planigle.planigle.model.ReleaseFactory;
	import org.planigle.planigle.model.IterationFactory;
	import org.planigle.planigle.model.StoryFactory;
	import org.planigle.planigle.model.ViewModelLocator;
	
	public class RefreshCommand implements ICommand, IResponder
	{
		protected var storiesCommand:GetStoriesCommand;

		public function RefreshCommand()
		{
			storiesCommand = new GetStoriesCommand(2);
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			var refreshEvent:RefreshEvent = event as RefreshEvent;
			
			//  Delegate acts as both delegate and responder.
			var delegate:SessionDelegate = new SessionDelegate( this );
			
			delegate.refresh(refreshEvent.showCursor);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (!result.error)
			{
				ViewModelLocator.getInstance().refreshInProgress = true;
				if (result.companies != null)
					CompanyFactory.getInstance().populate( result.time, result.companies as Array );
				if (result.individuals != null)
					IndividualFactory.getInstance().populate( result.time, result.individuals as Array );
				if (result.releases != null)
				{
					ReleaseFactory.getInstance().currentId = result.currentRelease ? result.currentRelease.id : null;
					ReleaseFactory.getInstance().populate( result.time, result.releases ? result.releases as Array : new Array() );
				}
				if (result.iterations != null)
				{
					IterationFactory.getInstance().currentId = result.currentIteration ? result.currentIteration.id : null;
					IterationFactory.getInstance().populate( result.time, result.iterations ? result.iterations as Array : new Array() );
				}
				if (result.stories != null)
					StoryFactory.getInstance().populate( result.time, result.stories ? result.stories as Array : new Array() );
				ViewModelLocator.getInstance().refreshInProgress = false;
				storiesCommand.execute(null);
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
		}
	}
}