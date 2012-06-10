package org.planigle.planigle.model
{
	import flash.events.ErrorEvent;
	import org.planigle.planigle.commands.CreateErrorCommand;
	
	[Bindable]
	[RemoteClass(alias='Error')]
	public class PlanigleError
	{
		public var message:String;
		public var stackTrace:String;
		
		public function PlanigleError(e:*)
		{
			e.preventDefault();
			if(e.error is Error)
			{
				var error:Error = e.error as Error;
				message = error.message;
				stackTrace = error.getStackTrace();
				if (stackTrace==null)
					stackTrace = "To get more details on the error, please install the debug version of Flash.  See http://www.adobe.com/support/flashplayer/downloads.html for more info.";
				else
					createError(); // Pass on to the server so that we can resolve.
			} else
			{
				var errorEvent:ErrorEvent = e.error as ErrorEvent;
				message = errorEvent.text;
				stackTrace = "";
			}
		}

		protected function createError():void
		{
			var params:Object = new Object();
			params["record[message]"] = message;
			params["record[stack_trace]"] = stackTrace;
			new CreateErrorCommand(this, params, null, null).execute(null);
		}
		
		// A project has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):PlanigleError
		{
			return this;
		}
	}
}