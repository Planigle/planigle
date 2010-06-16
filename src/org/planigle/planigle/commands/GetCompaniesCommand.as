package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import org.planigle.planigle.business.CompaniesDelegate;
	import org.planigle.planigle.model.CompanyFactory;
	
	public class GetCompaniesCommand implements ICommand, IResponder
	{
		public function GetCompaniesCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			//  Delegate acts as both delegate and responder.
			var delegate:CompaniesDelegate = new CompaniesDelegate( this, CompanyFactory.getInstance().timeUpdated );
			
			delegate.get();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (result.records != null)
				CompanyFactory.getInstance().populate(result.time, result.records as Array);
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}