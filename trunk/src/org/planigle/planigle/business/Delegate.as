package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	
	public class Delegate
	{
		protected var responder:IResponder;
		
		public function Delegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Answer the parameters to send.
		protected function params():Object
		{
			return null;
		}
		
		// Get the latest objects (subclasses should override getRemoteObjectName).
		public function get():void 
		{
			var remoteObject:RemoteObject = ServiceLocator.getInstance().getRemoteObject(getRemoteObjectName());
			remoteObject.showBusyCursor = showBusyCursorOnGet();
			if (params() == null)
				remoteObject.index.send().addResponder(responder);
			else
				remoteObject.index.send(params()).addResponder(responder);
		}	
		
		// Answer whether to show the busy cursor on get.
		protected function showBusyCursorOnGet():Boolean
		{
			return true;
		}

		// Create the object as specified.
		public function create( factory:Object, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("xmlService");
			params['random'] = Math.random(); // Prevents caching
			service.url = getFactoryUrl(factory);
			service.send(params).addResponder( responder );
		}
		
		// Update the object as specified.
		public function update( object:Object, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("xmlService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = getObjectUrl(object);
			service.send(params).addResponder( responder );
		}
		
		// Delete the object.
		public function destroy( object:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("xmlService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = getObjectUrl(object);
			service.send(params).addResponder( responder );
		}

		// Answer the name of the remote object (should be overridden).
		protected function getRemoteObjectName():String
		{
			return "";
		}

		// Answer the name of the factory URL (should be overridden).
		protected function getFactoryUrl(factory:Object):String
		{
			return "";
		}

		// Answer the name of the object URL (should be overridden).
		protected function getObjectUrl(object:Object):String
		{
			return "";
		}
	}
}