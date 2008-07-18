package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import org.planigle.planigle.model.PlanigleSystem;
	
	public class SystemDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		
		public function SystemDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Update the system as specified.
		public function updateSystem( system:PlanigleSystem, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateSystemService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "system.xml";
			service.send(params).addResponder( responder );
		}
	}
}