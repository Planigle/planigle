package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import org.planigle.planigle.vo.LoginVO;
	
	public class SessionDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		private var remoteObject:RemoteObject;
		
		public function SessionDelegate( responder:IResponder )
		{
			remoteObject = ServiceLocator.getInstance().getRemoteObject("sessionRO");
			this.responder = responder;
		}
		
		// Log in to the server.
		public function login( loginParams:LoginVO ):void 
		{
			var params:Object = new Object();
			params["login"] = loginParams.username;
			params["password"] = loginParams.password;
			params["accept_agreement"] = loginParams.acceptAgreement ? true : false;
			params["remember_me"] = loginParams.rememberMe ? true : false;
			
			remoteObject.create.send(params).addResponder(responder);
		}	
		
		// Log out from the server.
		public function logout():void 
		{
			remoteObject.destroy.send(null).addResponder(responder);
		}	
	}
}