package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.events.*;
	import org.planigle.planigle.commands.*;
	
	public class LoginController extends FrontController
	{
		public function LoginController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(LoginEvent.LOGIN, LoginCommand);	
			
		}

	}
}