package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import org.planigle.planigle.business.IndividualsDelegate;
	import org.planigle.planigle.model.ViewModelLocator;
	
	public class GetIndividualsCommand implements ICommand, IResponder
	{
		public var viewModelLocator:ViewModelLocator = ViewModelLocator.getInstance();
		
		public function GetIndividualsCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			//  Delegate acts as both delegate and responder.
			var delegate:IndividualsDelegate = new IndividualsDelegate( this );
			
			delegate.getIndividuals();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var xml:XML = XML(event.result);
			
			// Augment the individuals with a full-name field (combo of first and last name).
			for each (var individual:XML in xml.individual)
				individual.appendChild(<full-name>{individual.child('first-name') + ' ' + individual.child('last-name')}</full-name>);

			viewModelLocator.individuals = xml.children();
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}