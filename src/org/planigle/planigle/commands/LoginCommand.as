package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.SessionDelegate;
	import org.planigle.planigle.events.LoginEvent;
	import org.planigle.planigle.model.CompanyFactory;
	import org.planigle.planigle.model.IndividualFactory;
	import org.planigle.planigle.model.IterationFactory;
	import org.planigle.planigle.model.PlanigleSystem;
	import org.planigle.planigle.model.ReleaseFactory;
	import org.planigle.planigle.model.StoryFactory;
	import org.planigle.planigle.model.ViewModelLocator;
	import org.planigle.planigle.vo.LoginVO;
	
	public class LoginCommand implements ICommand, IResponder
	{
		[Bindable]
		public static var agreement:String = "";

		public static var lastLogin:LoginVO;
		public var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		protected var storiesCommand:GetStoriesCommand;
		
		public function LoginCommand()
		{
			storiesCommand = new GetStoriesCommand(2);
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			var loginEvent:LoginEvent = event as LoginEvent;
			
			//  Delegate acts as both delegate and responder.
			var delegate:SessionDelegate = new SessionDelegate( this );
			
			lastLogin = loginEvent.loginParams;
			delegate.login(lastLogin);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (result.error)
			{
				if (result.agreement)
				{
					agreement = result.agreement;
					viewModelLocator.workflowState = ViewModelLocator.LICENSE_AGREEMENT_SCREEN;
				}
				else
				{
					if (!lastLogin.test)
						Alert.show(result.error, "Login Error");
					viewModelLocator.workflowState = ViewModelLocator.LOGIN_SCREEN;
				}
			}
			else
			{
				ViewModelLocator.getInstance().refreshInProgress = true;
				PlanigleSystem.getInstance().populateFromObject( result.system );
				IndividualFactory.getInstance().setCurrent( result.currentIndividual.login );
				CompanyFactory.getInstance().populate( result.time, result.companies as Array );
				IndividualFactory.getInstance().populate( result.time, result.individuals as Array );
				ReleaseFactory.getInstance().populate( result.time, result.releases ? result.releases as Array : new Array() );
				IterationFactory.getInstance().populate( result.time, result.iterations ? result.iterations as Array : new Array() );
				StoryFactory.getInstance().populate( result.time, result.stories ? result.stories as Array : new Array() );
				viewModelLocator.workflowState = ViewModelLocator.CORE_APPLICATION_SCREEN;
				ViewModelLocator.getInstance().refreshInProgress = false;
				storiesCommand.execute(null);
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			if (!lastLogin.test)
				Alert.show(event.fault.faultString);
			viewModelLocator.workflowState = ViewModelLocator.LOGIN_SCREEN;
		}
	}
}