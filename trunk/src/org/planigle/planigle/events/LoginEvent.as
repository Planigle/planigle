package org.planigle.planigle.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;
	import org.planigle.planigle.vo.LoginVO;
	
	public class LoginEvent extends CairngormEvent
	{
		public static const LOGIN:String = "Login";
		public var loginParams:LoginVO;
		
		public function LoginEvent( loginParams:LoginVO )
		{
			this.loginParams = loginParams;
			// Call Caignorm constructor.
			super(LOGIN);
		}
		
		// Must override the Cairgnorm clone funtion.
		override public function clone():Event
		{
			return new LoginEvent(loginParams);
		}
	}
}