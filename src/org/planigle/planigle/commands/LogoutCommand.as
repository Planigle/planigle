package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import org.planigle.planigle.business.SessionDelegate;
	import org.planigle.planigle.model.ViewModelLocator;
	
	public class LogoutCommand implements ICommand, IResponder
	{
		public var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		
		public function LogoutCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			//  Delegate acts as both delegate and responder.
			var delegate:SessionDelegate = new SessionDelegate( this );
			
			delegate.logout();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:XML = XML(event.result);
			if (result.error.length() > 0)
				Alert.show(result.error);
			else
			{
				viewModelLocator.workflowState = ViewModelLocator.LOGIN_SCREEN;
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}