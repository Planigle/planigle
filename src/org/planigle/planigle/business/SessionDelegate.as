package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import org.planigle.planigle.vo.LoginVO;
	
	public class SessionDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		private var service:Object;
		
		public function SessionDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Log in to the server.
		public function login( loginParams:LoginVO ):void 
		{
			this.service = ServiceLocator.getInstance().getHTTPService("loginService");

			// Parameters for HTTPService.
			var params:Object = new Object();
			params["login"] = loginParams.username;
			params["password"] = loginParams.password;
			
			// Make any modifications to the URL here - added for template purposes.
			// var serviceURL:String = service.url;
			// service.url = service.url + extraParmsHere
			
			// Login to the service with the userID and password.
			var makeServiceRequest:Object = service.send( params );
			makeServiceRequest.addResponder( responder );
		}	
		
		// Log out from the server.
		public function logout():void 
		{
			this.service = ServiceLocator.getInstance().getHTTPService("logoutService");
			
			// Make any modifications to the URL here - added for template purposes.
			// var serviceURL:String = service.url;
			// service.url = service.url + extraParmsHere
			
			var params:Object = new Object();
			params['_method'] = "DELETE";
			params['random'] = Math.random();
			var makeServiceRequest:Object = service.send(params);
			makeServiceRequest.addResponder( responder );
		}	
	}
}