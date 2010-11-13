package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.utils.ObjectUtil;
	
	import org.planigle.planigle.model.Story;

	public class StoriesDelegate extends Delegate
	{
		protected var time:String;
		protected var page:int;
		
		public function StoriesDelegate( responder:IResponder, time:String = null, page:int = 1  )
		{
			super(responder);
			this.time = time;
			this.page = page;
		}
		
		// Answer the parameters to send.
		protected override function params():Object
		{
			var params:Object = new Object();
			for (var key:String in Story.conditions)
				params[key] = Story.conditions[key];
			params['page_size'] = Story.pageSize;
			params['page'] = page;
			if (time != null)
				params['time'] = time;
			return params;
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "storyRO";
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
		
		// Answer whether to show the busy cursor on get.
		override protected function showBusyCursorOnGet():Boolean
		{
			return page == 1;
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