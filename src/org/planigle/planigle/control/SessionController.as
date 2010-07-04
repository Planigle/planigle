package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.commands.LoginCommand;
	import org.planigle.planigle.commands.RefreshCommand;
	import org.planigle.planigle.commands.LogoutCommand;
	import org.planigle.planigle.commands.LoadURLCommand;
	import org.planigle.planigle.events.LoginEvent;
	import org.planigle.planigle.events.RefreshEvent;
	import org.planigle.planigle.events.LogoutEvent;
	import org.planigle.planigle.events.URLEvent;
	
	public class SessionController extends FrontController
	{
		public function SessionController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(LoginEvent.LOGIN, LoginCommand);	
			this.addCommand(RefreshEvent.REFRESH, RefreshCommand);	
			this.addCommand(LogoutEvent.LOGOUT, LogoutCommand);	
			this.addCommand(URLEvent.URL, LoadURLCommand);	
		}
	}
}