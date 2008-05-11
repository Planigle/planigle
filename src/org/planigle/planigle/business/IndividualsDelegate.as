package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class IndividualsDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		private var service:Object;
		
		public function IndividualsDelegate( responder:IResponder )
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getHTTPService("getIndividualsService");
		}
		
		// Get the latest individuals.
		public function getIndividuals():void 
		{
			// Make any modifications to the URL here - added for template purposes.
			// var serviceURL:String = service.url;
			// service.url = service.url + extraParmsHere
			
			var makeServiceRequest:Object = service.send({random: Math.random()}); // Note: random prevents caching
			makeServiceRequest.addResponder( responder );
		}	
	}
}