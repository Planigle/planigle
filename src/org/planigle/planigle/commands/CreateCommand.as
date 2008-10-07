package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;

	import org.planigle.planigle.business.Delegate;
	
	public class CreateCommand implements ICommand, IResponder
	{
		private var factory:Object;
		private var params:Object;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function CreateCommand(factory:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			this.factory = factory;
			params = someParams;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			createDelegate().create(factory, params);
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
				var item:Object = factory.createCompleted(result);
				if (notifySuccess != null)
					notifySuccess(item);
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