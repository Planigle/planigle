package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.LoginDelegate;
	import org.planigle.planigle.events.LoginEvent;
	import org.planigle.planigle.model.ViewModelLocator;
	
	public class LoginCommand implements ICommand, IResponder
	{
		public var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		
		public function LoginCommand()
		{
			
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			var loginEvent:LoginEvent = event as LoginEvent;
			
			//  Delegate acts as both delegate and responder.
			var delegate:LoginDelegate = new LoginDelegate( this );
			
			delegate.loginToServer(loginEvent.loginParams);
			
		}
		
		public function result( event:Object ):void
		{
			if(event.result == " ")
			{
				// Change view
				viewModelLocator.workflowState = ViewModelLocator.CORE_APPLICATION_SCREEN;
			}
			else if (event.result.error == "Invalid Credentials")
			{
				var errorString:String = event.result.error;
				
				errorString = (errorString + "::Please try again");
				mx.controls.Alert.show(errorString);
				
			}
			else
			{
				// Don't change view - handle error
			}
			
		}
		
		public function fault( event:Object ):void
		{
			var faultString:String = event.fault.faultString;
			
			faultString = (faultString + "::Please try again");
            mx.controls.Alert.show(faultString);
			
		}
		

	}
}