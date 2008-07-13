package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	import org.planigle.planigle.model.Individual;
	
	public class IndividualsDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		
		public function IndividualsDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Get the latest individuals.
		public function getIndividuals():void 
		{
			var remoteObject:RemoteObject = ServiceLocator.getInstance().getRemoteObject("individualRO");
			remoteObject.index.send().addResponder(responder);
		}	
		
		// Create the individual as specified.
		public function createIndividual( params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("createIndividualService");
			params['random'] = Math.random(); // Prevents caching
			service.send(params).addResponder( responder );
		}
		
		// Update the individual as specified.
		public function updateIndividual( individual:Individual, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateIndividualService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "individuals/" + individual.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Delete the individual.
		public function deleteIndividual( individual:Individual ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("deleteIndividualService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = "individuals/" + individual.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}