package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import org.planigle.planigle.model.PlanigleSystem;
	
	public class SystemDelegate extends Delegate
	{
		public function SystemDelegate( responder:IResponder )
		{
			super(responder);
		}
		
		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "system.xml";
		}
	}
}