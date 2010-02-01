package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import org.planigle.planigle.business.AuditsDelegate;
	import org.planigle.planigle.events.AuditChangedEvent;
	import org.planigle.planigle.model.Audit;
	
	public class GetAuditsCommand implements ICommand, IResponder
	{
		public function GetAuditsCommand()
		{
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			var auditEvent:AuditChangedEvent = event as AuditChangedEvent;

			//  Delegate acts as both delegate and responder.
			var delegate:AuditsDelegate = new AuditsDelegate( this, auditEvent.changer, auditEvent.objectType, auditEvent.startDate, auditEvent.endDate, auditEvent.objectId );
			
			delegate.get();
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			Audit.audits = event.result as Array;
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}