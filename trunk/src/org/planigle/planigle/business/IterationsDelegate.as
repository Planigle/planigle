package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	
	import org.planigle.planigle.model.Iteration;
	
	public class IterationsDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		
		public function IterationsDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Get the latest iterations.
		public function getIterations():void 
		{
			var remoteObject:RemoteObject = ServiceLocator.getInstance().getRemoteObject("iterationRO");
			remoteObject.index.send().addResponder(responder);
		}	
		
		// Create the iteration as specified.
		public function createIteration( params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("createIterationService");
			params['random'] = Math.random(); // Prevents caching
			service.send(params).addResponder( responder );
		}
		
		// Update the iteration as specified.
		public function updateIteration( iteration:Iteration, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateIterationService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "iterations/" + iteration.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Delete the iteration.
		public function deleteIteration( iteration:Iteration ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("deleteIterationService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = "iterations/" + iteration.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}