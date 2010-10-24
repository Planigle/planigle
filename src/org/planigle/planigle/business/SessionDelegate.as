package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	import org.planigle.planigle.vo.LoginVO;
	import org.planigle.planigle.model.CompanyFactory;
	import org.planigle.planigle.model.IndividualFactory;
	import org.planigle.planigle.model.ReleaseFactory;
	import org.planigle.planigle.model.IterationFactory;
	import org.planigle.planigle.model.Story;
	import org.planigle.planigle.model.StoryFactory;
	
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
			params["page_size"] = Story.pageSize;
			remoteObject.showBusyCursor = true;
			remoteObject.create.send(params).addResponder(responder);
		}	

		// Refresh the session data.
		public function refresh():void
		{
			var params:Object = new Object();
			params["companies"] = CompanyFactory.getInstance().timeUpdated;
			params["individuals"] = IndividualFactory.getInstance().timeUpdated;
			params["releases"] = ReleaseFactory.getInstance().timeUpdated;
			params["iterations"] = IterationFactory.getInstance().timeUpdated;
			params["stories"] = StoryFactory.getInstance().timeUpdated;
			params["conditions"] = Story.conditions;
			params["page_size"] = Story.pageSize;
			remoteObject.showBusyCursor = false;
			remoteObject.refresh.send(params).addResponder(responder);
		}
		
		// Log out from the server.
		public function logout():void 
		{
			remoteObject.showBusyCursor = true;
			remoteObject.destroy.send(null).addResponder(responder);
		}	
	}
}