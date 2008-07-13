package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	
	import org.planigle.planigle.model.Story;
	
	public class StoriesDelegate
	{
		private var responder:IResponder;
		
		public function StoriesDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Get the latest stories.
		public function getStories():void 
		{
			var remoteObject:RemoteObject = ServiceLocator.getInstance().getRemoteObject("storyRO");
			remoteObject.index.send().addResponder(responder);
		}
		
		// Create the story as specified.
		public function createStory( params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("createStoryService");
			params['random'] = Math.random(); // Prevents caching
			service.send(params).addResponder( responder );
		}
		
		// Update the story as specified.
		public function updateStory( story:Story, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateStoryService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "stories/" + story.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Split the story as specified.
		public function splitStory( story:Story, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("splitStoryService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "stories/split/" + story.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Delete the story.
		public function deleteStory( story:Story ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("deleteStoryService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = "stories/" + story.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}