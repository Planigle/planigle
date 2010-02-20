package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	
	import org.planigle.planigle.model.Story;

	public class StoriesDelegate extends Delegate
	{
		public function StoriesDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "storyRO";
		}

		override protected function params():Object
		{
			return Story.conditions;
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "stories.xml";
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "stories/" + object.id + ".xml"
		}
		
		// Split the story as specified.
		public function splitStory( object:Object, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("xmlService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "stories/split/" + object.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}