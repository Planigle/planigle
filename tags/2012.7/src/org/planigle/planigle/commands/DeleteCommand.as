package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.Delegate;
	
	public class DeleteCommand implements ICommand, IResponder
	{
		private var object:Object;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function DeleteCommand(object:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			this.object = object;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			createDelegate().destroy(object);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:XML = XML(event.result);
			if (result.error.length() > 0)
			{
				if (notifyFailure != null)
					notifyFailure(result.error);
			}
			else
			{
				object.destroyCompleted();
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