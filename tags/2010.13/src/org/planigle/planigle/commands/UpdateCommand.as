package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.Delegate;
	
	public class UpdateCommand implements ICommand, IResponder
	{
		private var object:Object;
		private var params:Object;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function UpdateCommand(object:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			this.object = object;
			params = someParams;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			createDelegate().update(object, params);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:XML = XML(event.result);
			if (result.error.length() > 0)
			{
				if (result.error == "Someone else has made changes since you last refreshed.")
				{
					Alert.show(result.error + "  Save anyway?", "Conflict", 3, null,
						function(event:CloseEvent):void
						{
							if (event.detail==Alert.YES)
							{
								params["updated_at"] = null;
								execute(null);
							}
							else
							{
								var newObject:Object = object.getCurrentVersion();
								if (newObject != null)
									newObject.updateCompleted(result.records.children()[0]);
							}
						});
				} else if (notifyFailure != null)
					notifyFailure(result.error);
			}
			else
			{
				object.updateCompleted(result);
				if (notifySuccess != null)
					notifySuccess();
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		protected function createDelegate():Delegate
		{
			return new Delegate( this );
		}
	}
}