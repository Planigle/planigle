package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.IndividualsDelegate;
	import org.planigle.planigle.model.Individual;
	
	public class UpdateIndividualCommand implements ICommand, IResponder
	{
		private var individual:Individual;
		private var params:Object;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function UpdateIndividualCommand(anIndividual:Individual, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			individual = anIndividual;
			params = someParams;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			new IndividualsDelegate( this ).updateIndividual(individual, params);
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
				individual.updateCompleted(result);
				if (notifySuccess != null)
					notifySuccess();
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}