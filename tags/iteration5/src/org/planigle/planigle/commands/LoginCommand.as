package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;	
	import org.planigle.planigle.business.SessionDelegate;
	import org.planigle.planigle.events.LoginEvent;
	import org.planigle.planigle.model.ViewModelLocator;
	import org.planigle.planigle.vo.LoginVO;
	
	public class LoginCommand implements ICommand, IResponder
	{
		private var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		private var userInfo:LoginVO;
		
		public function LoginCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			var loginEvent:LoginEvent = event as LoginEvent;
			
			//  Delegate acts as both delegate and responder.
			var delegate:SessionDelegate = new SessionDelegate( this );
			
			userInfo = loginEvent.loginParams;
			delegate.login(userInfo);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:XML = XML(event.result);
			if (result.error.length() > 0)
				Alert.show(result.error);
			else
			{
				viewModelLocator.setUser( userInfo.username );
				viewModelLocator.workflowState = ViewModelLocator.CORE_APPLICATION_SCREEN;
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}