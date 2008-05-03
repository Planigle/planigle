package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.vo.LoginVO;
	
	public class LoginDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		private var service:Object;
		
		//public var model:ModelLocator = ModelLocator.getInstance();
		
		public function LoginDelegate( responder:IResponder )
		{
			
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getHTTPService("loginService");
			
		}
		
		public function loginToServer( loginParams:LoginVO ):void 
		{
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

	}
}